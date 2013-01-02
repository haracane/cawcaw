module Cawcaw
  module Command
    module Hadoop::Dfs
      def self.run(argv, input_stream=$stdin, output_stream=$stdout)
        
        params = Cawcaw.parse_opts(argv)
        
        params[:graph_title] ||= "HDFS size"
        params[:graph_args] ||= "--base 1000"
        params[:graph_vlabel] ||= "bytes"
        params[:graph_category] ||= "hadoop"
        params[:graph_info] ||= "HDFS size"
        
        params[:label_warning] ||= 5000000
        params[:label_critical] ||= 5000000
        
        if params[:stdin_flag]
          hdfs_paths = []
          while line = input_stream.gets
            line.chomp!
            hdfs_paths.push line
          end
        else
          hdfs_paths = argv.shift
          hdfs_paths = hdfs_paths.split(/,/) unless hdfs_paths.nil?
          hdfs_paths ||= []
          hdfs_paths.delete("")
        end
        command = argv.shift
        
        if hdfs_paths == []
          Cawcaw.logger.error("hdfs-path is not set")
          return 1
        end
        
        absolute_hdfs_paths = {}
        hdfs_paths.each do |hdfs_path|
          if /^\// =~ hdfs_path
            absolute_hdfs_paths[hdfs_path] = hdfs_path
          else
            absolute_hdfs_paths[hdfs_path] = "#{params[:hadoop_working_directory]}/#{hdfs_path}"
          end
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
          
          hdfs_paths.each do |hdfs_path|
            label = hdfs_path.gsub(/[^a-zA-Z0-9]/, "_").downcase
            output_stream.puts <<-EOF
#{label}.label #{hdfs_path}
#{label}.info #{hdfs_path} size
#{label}.draw #{label_draw}
#{label}.warning #{params[:label_warning]}
#{label}.critical #{params[:label_critical]}
          EOF
            label_draw = "STACK"
          end
        else
          result = `#{params[:hadoop_command]} dfs -dus #{hdfs_paths.map{|hdfs_path|absolute_hdfs_paths[hdfs_path]}.join(" ")}`
          # STDERR.puts result
          hdfs_sizes = {}
          result.split(/\r?\n/).each do |line|
            record = line.split(/\s+/)
            hdfs_uri = record[0]
            hdfs_uri = URI.parse(hdfs_uri)
            hdfs_sizes[hdfs_uri.path] = record[1]
          end
          # STDERR.puts hdfs_sizes.inspect
          
          hdfs_paths.each do |hdfs_path|
            hdfs_size = hdfs_sizes[absolute_hdfs_paths[hdfs_path]]
            label = hdfs_path.gsub(/[^a-zA-Z0-9]/, "_").downcase
            output_stream.puts "#{label}.value #{hdfs_size}"
          end
        end
        
        return 0
      end
    end
  end
end
