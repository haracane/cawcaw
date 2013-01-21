module Cawcaw
  module Command
    module Mysql
      module Table
        include Cawcaw::Command::Database::Table
        
        def self.initialize_params(params)
          params[:adapter] ||= "mysql2"
          params[:host] ||= "localhost"
          params[:port] ||= 3306
          params[:adapter_name] ||= "mysql"
          
          params[:graph_title] ||= "#{params[:adapter_name]} records"
          params[:graph_args] ||= "--base 1000"
          params[:graph_vlabel] ||= "records"
          params[:graph_category] ||= params[:adapter_name]
          params[:graph_info] ||= "#{params[:adapter_name]} record size"
          
          params[:label_warning] ||=   50000000
          params[:label_critical] ||= 100000000
        end
      end
    end
  end
end