require '../mosh.rb'

describe Mosh do
  before do
    @mosh = Mosh.new({
      'rss' => 'items',
      'links' => ['www.google.com', 'www.google.com.br', 'a string'],
      'category' => {'a' => 1},
      'array' => [{'arr:item' => 2}]
    })
  end

  it "should inherit from hash" do
    @mosh.is_a?(Hash).should be_true
  end
  
  it "should have metaprogrammed methods to get hash values" do
    @mosh.rss.should == 'items'

    @mosh.links.should include('a string')
    @mosh.category.keys.should include('a')
    @mosh.category.keys.should_not include('b')

    @mosh.category_a.should == 1
    @mosh.category_a.should == @mosh.category['a']
    @mosh.array.first.arr_item.should == 2
  end

  it "should be able to retrieve hash values through method= calls" do
    @mosh["test"]= "abc"
    @mosh.test.should  == "abc"
    @mosh[:taste] = "mint"
    @mosh[:taste].should == "mint"
    @mosh.taste.should  == "mint"
  end

  it "should convert hash assignments into moshes" do
    @mosh['details'] = {:email => 'dalto@asf.com', :address => {:state => 'TX'} }
    @mosh.details.email.should == 'dalto@asf.com'
    @mosh.details.address.state.should == 'TX'
  end

  it "should convert hashes recursively into moshes" do
  	converted = Mosh.new({:a => {:b => 1, :c => {:d => 23}}})
    converted.a.is_a?(Mosh).should be_true
    converted.a.b.should == 1
    converted.a.c.d.should == 23
  end

  it "should convert hashes in arrays into moshes" do
  	converted = Mosh.new({:a => [{:b => 12}, 23]})
    converted.a.first.b.should == 12
    converted.a.last.should == 23
  end

	it "should convert an existing Mosh into a Mosh" do
  	initial = Mosh.new(:name => 'randy', :address => {:state => 'TX'})
    copy = Mosh.new(initial)
    initial.name.should == copy.name
    initial.object_id.should_not == copy.object_id
    copy.address.state.should == 'TX'
    initial.address.state.should == 'TX'
    copy.address.object_id.should_not == initial.address.object_id
  end
end
