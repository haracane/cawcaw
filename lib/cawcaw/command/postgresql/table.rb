module Cawcaw
  module Command
    module Postgresql
      module Table
        include Cawcaw::Command::Database::Table
        
        def self.initialize_params(params)
          params[:adapter] ||= "postgresql"
          params[:host] ||= "localhost"
          params[:port] ||= 5432
          
          params[:graph_title] ||= "#{params[:adapter]} records"
          params[:graph_args] ||= "--base 1000"
          params[:graph_vlabel] ||= "records"
          params[:graph_category] ||= params[:adapter]
          params[:graph_info] ||= "#{params[:adapter]} record size"
        end
        
        def self.get_full_table_paths(table_paths, params)
          full_table_paths = {}
          table_paths.each do |table_path|
            table_path_pair = table_path.split(/\./)
            if /[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)?/ !~ table_path
              Cawcaw.logger.error("#{params[:adapter]} table name '#{table_path}' is invalid")
              return nil
            end
            table_name = table_path_pair.pop
            schema_name = table_path_pair.pop || "public"
            full_table_paths[table_path] = "#{schema_name}.#{table_name}"
          end
          return full_table_paths
        end
        
        def self.count_table_sizes(full_table_paths, params)
          ActiveRecord::Base.establish_connection(params)
          model_class = ActiveRecord::Base
          if false && params[:stats_flag]
            count_sql = <<-EOF
select nspname || '.' || relname as full_table_path, reltuples as record_size, relpages * 8 as byte_size
from pg_class
inner join pg_namespace
on pg_class.relnamespace = pg_namespace.oid
where relkind='r'
  and (
    #{
      full_table_paths.map{|full_table_path|
        "(nspname || '.' || relname) = #{model_class.sanitize(full_table_path)}"
      }.join(" or ")
    }
  )
            EOF
          else
            count_sql = <<-EOF
#{
  full_table_paths.map{|full_table_path|
    "(select #{model_class.sanitize(full_table_path)} as full_table_path, count(*) as record_size from #{full_table_path})"
  }.join(" union ")
}
            EOF
          end
          results = ActiveRecord::Base.connection.execute count_sql
          return results
        end
      end
    end
  end
end