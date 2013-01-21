module Cawcaw
  module Command
    module Mysql
      def self.run(argv, input_stream=$stdin, output_stream=$stdout)
        command = argv.shift
        case command
        when "table"
          return Cawcaw::Command::Mysql::Table.run(argv, input_stream, output_stream)
        else
          STDERR.puts "invalid postgresql command: '#{command}'"
        end
      end
    end
  end
end

require "cawcaw/command/mysql/table"
