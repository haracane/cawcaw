module Cawcaw
  module Command
    module Database
      module Table
        module ClassMethods
          def initialize_params(params)
            params[:host] ||= "localhost"
            params[:adapter_name] ||= params[:adapter]
            
            params[:graph_title] ||= "#{params[:adapter_name]} Records"
            params[:graph_args] ||= "--base 1000"
            params[:graph_vlabel] ||= "records"
            params[:graph_category] ||= params[:adapter_name]
            params[:graph_info] ||= "#{params[:adapter_name]} record size"
          end
          
          def get_full_table_paths(table_paths, params)
            full_table_paths = {}
            table_paths.each do |table_path|
              full_table_paths[table_path] = table_path
            end
            return full_table_paths
          end
          
          def count_table_sizes(full_table_paths, params)
            ActiveRecord::Base.establish_connection(params)
            count_sql = <<-EOF
#{
  full_table_paths.map{|full_table_path|
    "(select #{ActiveRecord::Base.sanitize(full_table_path)} as full_table_path, count(*) as record_size from #{full_table_path})"
  }.join(" union ")
}
            EOF
            results = ActiveRecord::Base.connection.execute count_sql
          end

          def run(argv, input_stream=$stdin, output_stream=$stdout)
            
            params = Cawcaw.parse_opts(argv)
            self.initialize_params(params)
            bytes_flag = (params[:graph_vlabel] == "bytes")
            
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
              Cawcaw.logger.error("#{params[:adapter]} table name is not set")
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
                EOF
                output_stream.puts "#{label}.warning #{params[:label_warning]}" if params[:label_warning]
                output_stream.puts "#{label}.critical #{params[:label_critical]}" if params[:label_critical]
                label_draw = "STACK"
              end
            else
              
              full_table_paths = self.get_full_table_paths(table_paths, params)
              return 1 if full_table_paths.nil?
              
              results = self.count_table_sizes(table_paths.map{|t|full_table_paths[t]}, params)
              
              table_sizes = {}
              results.each do |record|
                table_path = record[0] || record["full_table_path"]
                if bytes_flag
                  table_sizes[table_path] = (record[2] || record["byte_size"]).to_i
                else
                  table_sizes[table_path] = (record[1] || record["record_size"]).to_i
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
        
        extend ClassMethods
        
        def self.included(klass)
          klass.extend ClassMethods
        end
      end
    end
  end
end