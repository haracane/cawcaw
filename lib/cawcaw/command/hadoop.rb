module Cawcaw
  module Command
    module Hadoop
      def self.run(argv, input_stream=$stdin, output_stream=$stdout)
        command = argv.shift
        case command
        when "dfs"
          return Cawcaw::Command::Hadoop::Dfs.run(argv, input_stream, output_stream)
        else
          STDERR.puts "invalid hadoop command: '#{command}'"
        end
      end
    end
  end
end

require "cawcaw/command/hadoop/dfs"
