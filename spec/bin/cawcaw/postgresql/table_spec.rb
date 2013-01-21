require "spec_helper"

describe "bin/cawcaw postgresql table" do
  before :all do
    CawcawName.establish_connection({
      :adapter=>"postgresql",
      :host=>"localhost",
      :port=>5432,
      :username=>"postgres",
      :database=>"cawcaw"
    })
    CawcawName.connection.create_table(:cawcaw_names) do |t|
      t.column :name, :string
    end
    CawcawName.create(:name=>"foo")
    CawcawName.create(:name=>"bar")
    CawcawName.create(:name=>"baz")
  end
  
  after :all do
    CawcawName.connection.drop_table(:cawcaw_names)
  end
  context "when table path is \"cawcaw_names\"" do
    context "when munin param is not set" do
      it "should output record size" do
        result = `ruby -I lib ./bin/cawcaw postgresql table --username postgres --database cawcaw cawcaw_names`
        record = result.chomp.split(/ /, 2)
        record.should == ["cawcaw_names.value", "3"]
      end
    end
    context "when munin param is config" do
      it "should output munin config" do
        result = `ruby -I lib ./bin/cawcaw postgresql table --username postgres --database cawcaw cawcaw_names config`
        result = result.split(/\r?\n/).map{|l|l.split(/ /, 2)}
        # result.each do |record| STDERR.puts record.inspect end
        result.shift.should == ["graph_title", "postgresql records"]
        result.shift.should == ["graph_args", "--base 1000"]
        result.shift.should == ["graph_vlabel", "records"]
        result.shift.should == ["graph_category", "postgresql"]
        result.shift.should == ["graph_info", "postgresql record size"]
        result.shift.should == ["cawcaw_names.label", "cawcaw_names"]
        result.shift.should == ["cawcaw_names.info", "cawcaw_names size"]
        result.shift.should == ["cawcaw_names.draw", "AREA"]
      end
    end
  end  
end
