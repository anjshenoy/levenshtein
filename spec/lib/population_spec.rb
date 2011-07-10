require File.dirname(__FILE__) + "./../../lib/population"

describe Population do

  let(:path) {"path/to/file"}
  let(:iostream) {stub("iostream")}
  let(:pop) { Population.new("./config/test/test1.list")}

  before(:each) do
    iostream.stub(:each_line).and_yield("a\n")
  end

  it "loads the population from a file given a path" do
    File.should_receive(:open).and_return(iostream)
    Population.new(path)
  end

  it "removes the \\n (if it exists) from each line read from disk" do
    File.stub(:open).and_return(iostream)
    Population.new(path).citizens[1].keys.first.should == "a"
  end


  it "loads each line of the file into a datastructure called citizens, indexed by length" do
    File.stub(:open).and_return(iostream)
    pop = Population.new(path)
    pop.citizens.keys.should == [1]
  end

  it "links each word it encounters to a Node datastructure" do
    pop.citizens.keys.each do |len|
      pop.citizens[len].each do |word, node|
        node.name.should == word
        node.first_degree_friends.should == []
      end
    end
  end

  context "it builds connections between nodes" do

    it "does not scan queues which have no siblings and an empty queue below and above it (i.e. no children/parents)" do
      redmosquito_node = pop.citizens[11]["redmosquito"]
      redmosquito_node.should_not_receive(:child_word_list)
      pop.build_connections
    end


    it "starts at the longest word queue" do
      cake_node = pop.citizens[4]["cake"]
      aae_node = pop.citizens[3]["aae"]
      aa_node = pop.citizens[2]["aa"]

      #sibling_word_list calls child_word_list internally
      cake_node.should_receive(:child_word_list).ordered.exactly(:twice).and_return([])
      aae_node.should_receive(:child_word_list).ordered.exactly(:twice).and_return([])
      aa_node.should_receive(:child_word_list).ordered.exactly(:twice).and_return([])
      pop.build_connections
    end

    context "it finds the children of each node one layer below that node" do
      it "gets a list of all possible child-word combinations" do
        node = pop.citizens[4]["cake"]
        node.should_receive(:child_word_list).exactly(:twice).and_return(["ake", "cke", "cae", "cak"])
        pop.build_connections
      end

      it "iterates through the child-word-list and looks for children in the layer below" do
        node = pop.citizens[4]["cake"]
        child_node = pop.citizens[3]["cae"]
        node.should_receive(:add_friend).with(child_node).exactly(:once)
        pop.build_connections
      end
    end

    context "it finds the siblings of each node at the same layer as the node in question" do

      it "first gets a list of all possible sibling word matches" do
        node = pop.citizens[3]["cae"]
        node.should_receive(:sibling_word_list).exactly(:once).and_return(
          ["0ake", "c1ke", "ca2e", "cak3"])
        pop.build_connections
      end

      it "iterates through the sibling_word_list and looks for siblings in the same layer as the node" do
        node = pop.citizens[3]["cae"]
        sibling_node = pop.citizens[3]["aae"]
        node.should_receive(:add_friend).with(sibling_node).exactly(:once)
        pop.build_connections
      end
    end
  end

  context "walking and counting nodes" do
    it "returns 0 if the word does not exist in the population" do
      pop.walk_and_count("boo").should == 0
    end
    it "walks through the network and counts all the friends of that word" do
      pop.build_connections
      pop.walk_and_count("cae").should == 4
    end
  end
end
