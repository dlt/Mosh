require '../mosh.rb'

describe Mosh do
  before do
    @array = [{'a' => 1, 'b' => 2}, {'b' => {'c' => {'d' => 10}}}]
    @mosh = Mosh.new ({
      'rss' => 'items',
      'links' => ['www.google.com', 'www.google.com.br', 'a string'],
      'category' => {'a' => 1},
      'array' => [{'arr:item' => 2}]
    })
  end

  it "should have a default handler that add methods based on the response hash keys" do
    @mosh.first.respond_to?('a').should be_true
    @mosh.first.respond_to?('c').should be_false

    @mosh[1].respond_to?('b').should be_true
    @mosh[1].respond_to?('b_c').should be_true
    @mosh[1].respond_to?('b_c_d').should be_true
    @mosh[1].respond_to?('c_d').should be_false
    @mosh[1].respond_to?('b_d').should be_false

    @mosh.respond_to?('rss').should be_true
    @mosh.respond_to?('category').should be_true
    @mosh.respond_to?('category_a').should be_true
    @mosh.respond_to?('array').should be_true
    @mosh.array.first.respond_to?('arr_item').should be_true

  end

  it "should have metaprogrammed methods to get hash values" do
    @mosh.first.respond_to?('a').should be_true
    @mosh.first.a.should == 1
    @mosh.first.b.should == 2
    @mosh[1].b_c_d.should == 10

    @mosh.rss.should == 'items'

    @mosh.links.should include('a string')
    @mosh.category.keys.should include('a')
    @mosh.category.keys.should_not include('b')

    @mosh.category_a.should == 1
    @mosh.category_a.should == @resp_hash.category['a']
    @mosh.array.first.arr_item.should == 2
  end

end
