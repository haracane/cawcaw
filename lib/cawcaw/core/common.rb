module Cawcaw
  module Core
    module Common
      def self.parse_opts(argv)
        graph_title = nil
        graph_args = nil
        graph_vlabel = nil
        graph_category = nil
        graph_info = nil
        stdin_flag = false
        verbose_flag = false
        
        next_argv = []
        
        while 0 < argv.size do
          val = argv.shift
          case val
          when "--graph-title"
            graph_title = argv.shift
          when "--graph-args"
            graph_args = argv.shift
          when "--graph-vlabel"
            graph_vlabel = argv.shift
          when "--graph-category"
            graph_category = argv.shift
          when "--graph-info"
            graph_info = argv.shift
          when "--label-warning"
            label_warning = argv.shift.to_i
          when "--label-critical"
            label_critical = argv.shift.to_i
          when "--hadoop-command"
            hadoop_command = argv.shift
          when "--stdin"
            stdin_flag = true
          when "--verbose"
            verbose_flag = true
          else
            next_argv.push val
          end
        end
        argv.push(*next_argv)
        
        if verbose_flag then
          Cawcaw.logger.level = Logger::INFO
        else
          Cawcaw.logger.level = Logger::WARN
        end
        
        return {
          :graph_title=>graph_title,
          :graph_args=>graph_args,
          :graph_vlabel=>graph_vlabel,
          :graph_category=>graph_category,
          :graph_info=>graph_info,
          :label_warning=>label_warning,
          :label_critical=>label_critical,
          :hadoop_command=>hadoop_command,
          :stdin_flag=>stdin_flag,
          :verbose_flag=>verbose_flag
        }
      end
    end
  end
end
