module Cawcaw
  module Command
    module Database
      def self.run(argv, input_stream=$stdin, output_stream=$stdout)
        command = argv.shift
        case command
        when "table"
          return Cawcaw::Command::Database::Table.run(argv, input_stream, output_stream)
        else
          STDERR.puts "invalid active-record command: '#{command}'"
        end
      end
    end
  end
end

require "cawcaw/command/database/table"
