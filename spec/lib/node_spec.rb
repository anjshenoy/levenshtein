require File.dirname(__FILE__) + "./../../lib/node"

describe Node do

  let(:n) { Node.new("cake")}
  it "builds a new instance of itself using the name attribute as an identifier" do
    n.name.should == "cake"
  end

  it "has an attribute called 'touched' which is intially set to 0 (meaning untouched)" do
    n.touched.should == 0
  end

  it "sets up an empty array in the hope that it will have siblings and child nodes" do
    n.first_degree_friends.should == []
  end

  it "does not allow me to change the name (i.e. identifier)of the node once set" do
    lambda{n.name = "something else"}.should raise_error(NoMethodError, /^undefined method `name='/)
  end

  context "child word combinations are defined by"do
    it "all possible words with one character less than the name attribute" do
      n.child_word_list.should == ["ake", "cke", "cae", "cak"]
    end
  end
  context "sibling word combinations are defined by"do
    it "same as child word combinations except that each word retains a marker of the index at which the character in question was removed" do
      n.sibling_word_list.should == ["ake0", "cke1", "cae2", "cak3"]
    end
  end

  it "allows me to add another node as a friend" do
    new_node = Node.new("boe")
    n.add_friend(new_node)
    n.first_degree_friends.should == [new_node]
    new_node.first_degree_friends.should == [n]
  end

  context "link traversal" do
    let(:n1) { Node.new("ake") }
    let(:n2) { Node.new("cake")}

    before(:each) do
      n2.add_friend(n1)
    end

    it "counts all the first degree friends in a node" do
      n2.count_friends.should == 2
    end
    it "marks each node it touches so that it will not be counted again" do
      n2.stub(:untouched?).and_return(false, true)
      n1.stub(:untouched?).and_return(true, false)

      [n2, n1].each {|n| n.should_receive(:touch).ordered}
      n2.count_friends
    end

    context "through sub-networks" do
      let(:n3) { Node.new("aae") }

      it "finds friends of (untouched) friends" do
        n1.add_friend(n3)
        n2.count_friends.should == 3
      end
    end
  end

end
