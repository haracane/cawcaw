module Cawcaw
  module Command
    module Postgresql
      module Table
        def self.run(argv, input_stream=$stdin, output_stream=$stdout)
          
          params = Cawcaw.parse_opts(argv)
          
          params[:graph_title] ||= "PostgreSQL Records"
          params[:graph_args] ||= "--base 1000"
          params[:graph_vlabel] ||= "records"
          params[:graph_category] ||= "postgresql"
          params[:graph_info] ||= "PostgreSQL record size"
          
          bytes_flag = (params[:graph_vlabel] == "bytes")
          
          params[:adapter] = "postgresql"
          params[:host] ||= "localhost"
          params[:port] ||= 5432
          
          params[:label_warning] ||=   50000000
          params[:label_critical] ||= 100000000
          
          if params[:stdin_flag]
            table_paths = []
            while line = input_stream.gets
              line.chomp!
              table_paths.push line
            end
          else
            table_paths = argv.shift
            table_paths = table_paths.split(/,/) unless table_paths.nil?
            table_paths ||= []
            table_paths.delete("")
          end
          command = argv.shift
          
          if table_paths == []
            Cawcaw.logger.error("PostgreSQL table name is not set")
            return 1
          end
          
          case command
          when "autoconf"
            output_stream.puts "yes"
          when "config"
            output_stream.puts <<-EOF
graph_title #{params[:graph_title]}
graph_args #{params[:graph_args]}
graph_vlabel #{params[:graph_vlabel]}
graph_category #{params[:graph_category]}
graph_info #{params[:graph_info]}
            EOF
            
            label_draw = "AREA"
            
            table_paths.each do |table_path|
              label = table_path.gsub(/[^a-zA-Z0-9]/, "_").downcase
              output_stream.puts <<-EOF
#{label}.label #{table_path}
#{label}.info #{table_path} size
#{label}.draw #{label_draw}
#{label}.warning #{params[:label_warning]}
#{label}.critical #{params[:label_critical]}
            EOF
              label_draw = "STACK"
            end
          else
            
            ActiveRecord::Base.establish_connection(params)

            full_table_paths = {}
            table_paths.each do |table_path|
              table_path_pair = table_path.split(/\./)
              if /[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)?/ !~ table_path
                Cawcaw.logger.error("PostgreSQL table name '#{table_path}' is invalid")
                return 1
              end
              table_name = table_path_pair.pop
              schema_name = table_path_pair.pop || "public"
              full_table_paths[table_path] = "#{schema_name}.#{table_name}"
            end
            
            if params[:stats_flag]
              count_sql = <<-EOF
select nspname || '.' || relname as full_table_path, reltuples, relpages
from pg_class
inner join pg_namespace
on pg_class.relnamespace = pg_namespace.oid
where relkind='r'
  and (
    #{
      table_paths.map{|table_path|
        "(nspname || '.' || relname) = #{ActiveRecord::Base.sanitize(full_table_paths[table_path])}"
      }.join(" or ")
    }
  )
              EOF
            else
              count_sql = <<-EOF
#{
  table_paths.map{|table_path|
    "(select #{ActiveRecord::Base.sanitize(full_table_paths[table_path])} as full_table_path, count(*) as reltuples from #{full_table_paths[table_path]})"
  }.join(" union ")
}
              EOF
            end

            
            results = ActiveRecord::Base.connection.execute count_sql
            table_sizes = {}
            results.each do |record|
              table_path = record["full_table_path"]
              if bytes_flag
                table_sizes[table_path] = record["relpages"].to_i * 8
              else
                table_sizes[table_path] = record["reltuples"].to_i
              end
            end
            table_paths.each do |table_path|
              label = table_path.gsub(/[^a-zA-Z0-9]/, "_").downcase
              table_size = table_sizes[full_table_paths[table_path]]
              output_stream.puts "#{label}.value #{table_size}"
            end
          end
          
          return 0
        end
        
      end
    end
  end
end