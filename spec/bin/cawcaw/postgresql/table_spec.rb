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
  context "when table path is absolute" do
    it "should output record size" do
      result = `ruby -I lib ./bin/cawcaw postgresql table --username postgres --database cawcaw cawcaw_names`
      record = result.chomp.split(/ /)
      record.should == ["cawcaw_names.value", "3"]
    end
  end  
end
