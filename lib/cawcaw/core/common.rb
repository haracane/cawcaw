module Cawcaw
  module Core
    module Common
      def self.parse_opts(argv)
        ret = {}
        
        ret[:hadoop_working_directory] = "/user/#{ENV["USER"]}"
        ret[:hadoop_command] = "hadoop"
        
        ret[:stdin_flag] = false
        ret[:verbose_flag] = false
        
        next_argv = []
        
        while 0 < argv.size do
          val = argv.shift
          if val[0..1] == "--"
            label = val[2..-1].gsub(/-/,"_").to_sym
          else
            label = nil
          end
          case label
          when :graph_title, :graph_args, :graph_vlabel, :graph_category, :graph_info, \
               :hadoop_command, :adapter, :host, :database, :username, :password, :encoding
            ret[label] = argv.shift
          when :label_warning, :label_critical, :port
            ret[label] = ret[label].to_i
          when :stdin, :verbose, :stats
            ret["#{label}_flag".to_sym] = true
          when :hadoop_wdir
            hadoop_working_directory = argv.shift
            ret[:hadoop_working_directory] = hadoop_working_directory.gsub(/\/$/, "")
          else
            next_argv.push val
          end
        end
        argv.push(*next_argv)
        
        if ret[:verbose_flag] then
          Cawcaw.logger.level = Logger::INFO
        else
          Cawcaw.logger.level = Logger::WARN
        end
        
        return ret
      end
    end
  end
end
