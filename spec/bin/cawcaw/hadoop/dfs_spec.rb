require "spec_helper"

describe "bin/cawcaw hadoop dfs" do
  before :all do
    tmpfile = Tempfile.new("cawcaw_spec.rb")
    tmpfile.puts "foo bar baz"
    tmpfile.close
    system("hadoop dfs -rmr cawcaw-test >/dev/null 2>/dev/null")
    system("hadoop dfs -put #{tmpfile.path} cawcaw-test/")
  end
  context "when hdfs path is absolute" do
    it "should output hadoop dfs config" do
      result = `ruby -I lib ./bin/cawcaw hadoop dfs /user/#{ENV["USER"]}/cawcaw-test config`
      hash = {}
      result.split(/\r?\n/).each do |line|
        record = line.split(/ /, 2)
        hash[record[0]] = record[1]
      end
      result = hash
      # result.each_pair do |key, val| STDERR.puts "result[#{key.inspect}].should == #{val.inspect}" end
      result["graph_title"].should == "HDFS size"
      result["graph_args"].should == "--base 1000"
      result["graph_vlabel"].should == "bytes"
      result["graph_category"].should == "hadoop"
      result["graph_info"].should == "HDFS size"
      result["_user_#{ENV["USER"]}_cawcaw_test.label"].should == "/user/#{ENV["USER"]}/cawcaw-test"
      result["_user_#{ENV["USER"]}_cawcaw_test.info"].should == "/user/#{ENV["USER"]}/cawcaw-test size"
      result["_user_#{ENV["USER"]}_cawcaw_test.draw"].should == "AREA"
      result["_user_#{ENV["USER"]}_cawcaw_test.warning"].should == "5000000"
      result["_user_#{ENV["USER"]}_cawcaw_test.critical"].should == "5000000"
    end
  
    it "should output hadoop dfs value" do
      result = `ruby -I lib ./bin/cawcaw hadoop dfs /user/#{ENV["USER"]}/cawcaw-test`
      hash = {}
      result.split(/\r?\n/).each do |line|
        record = line.split(/ /, 2)
        hash[record[0]] = record[1]
      end
      result = hash
      # result.each_pair do |key, val| STDERR.puts "result[#{key.inspect}].should == #{val.inspect}" end
      result["_user_#{ENV["USER"]}_cawcaw_test.value"].should == "12"
    end
  end
  context "when hdfs path is relative" do
    context "with hadoop-wdir option" do
      it "should output hadoop dfs config" do
        result = `ruby -I lib ./bin/cawcaw hadoop dfs --hadoop-wdir /user #{ENV["USER"]}/cawcaw-test config`
        hash = {}
        result.split(/\r?\n/).each do |line|
          record = line.split(/ /, 2)
          hash[record[0]] = record[1]
        end
        result = hash
        # result.each_pair do |key, val| STDERR.puts "result[#{key.inspect}].should == #{val.inspect}" end
        result["graph_title"].should == "HDFS size"
        result["graph_args"].should == "--base 1000"
        result["graph_vlabel"].should == "bytes"
        result["graph_category"].should == "hadoop"
        result["graph_info"].should == "HDFS size"
        result["#{ENV["USER"]}_cawcaw_test.label"].should == "#{ENV["USER"]}/cawcaw-test"
        result["#{ENV["USER"]}_cawcaw_test.info"].should == "#{ENV["USER"]}/cawcaw-test size"
        result["#{ENV["USER"]}_cawcaw_test.draw"].should == "AREA"
        result["#{ENV["USER"]}_cawcaw_test.warning"].should == "5000000"
        result["#{ENV["USER"]}_cawcaw_test.critical"].should == "5000000"
      end
    
      it "should output hadoop dfs value" do
        result = `ruby -I lib ./bin/cawcaw hadoop dfs --hadoop-wdir /user #{ENV["USER"]}/cawcaw-test`
        hash = {}
        result.split(/\r?\n/).each do |line|
          record = line.split(/ /, 2)
          hash[record[0]] = record[1]
        end
        result = hash
        # result.each_pair do |key, val| STDERR.puts "result[#{key.inspect}].should == #{val.inspect}" end
        result["#{ENV["USER"]}_cawcaw_test.value"].should == "12"
      end
    end
    
    context "without hadoop-wdir option" do
      it "should output hadoop dfs config" do
        result = `ruby -I lib ./bin/cawcaw hadoop dfs cawcaw-test config`
        hash = {}
        result.split(/\r?\n/).each do |line|
          record = line.split(/ /, 2)
          hash[record[0]] = record[1]
        end
        result = hash
        # result.each_pair do |key, val| STDERR.puts "result[#{key.inspect}].should == #{val.inspect}" end
        result["graph_title"].should == "HDFS size"
        result["graph_args"].should == "--base 1000"
        result["graph_vlabel"].should == "bytes"
        result["graph_category"].should == "hadoop"
        result["graph_info"].should == "HDFS size"
        result["cawcaw_test.label"].should == "cawcaw-test"
        result["cawcaw_test.info"].should == "cawcaw-test size"
        result["cawcaw_test.draw"].should == "AREA"
        result["cawcaw_test.warning"].should == "5000000"
        result["cawcaw_test.critical"].should == "5000000"
      end
    
      it "should output hadoop dfs value" do
        result = `ruby -I lib ./bin/cawcaw hadoop dfs cawcaw-test`
        hash = {}
        result.split(/\r?\n/).each do |line|
          record = line.split(/ /, 2)
          hash[record[0]] = record[1]
        end
        result = hash
        # result.each_pair do |key, val| STDERR.puts "result[#{key.inspect}].should == #{val.inspect}" end
        result["cawcaw_test.value"].should == "12"
      end
    end
  end  
end
