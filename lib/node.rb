class Node
  attr_reader :name, :touched
  attr_accessor :first_degree_friends

  def initialize(word)
    @name = word
    @first_degree_friends = []
    @name.freeze
    @touched = 0
  end

  def child_word_list
    @child_word_list ||= (0...self.name.length).inject([]){ |result, index|
      word = self.name.dup
      word[index] = ""
      result << word
      result
    }
  end

  def sibling_word_list
    self.child_word_list.each_with_index{|item, index|
      item << index.to_s
    }
  end

  def add_friend(node)
    self.first_degree_friends << node
    node.first_degree_friends << self
  end

  def count_friends
    queue, count = [], 0
    self.add_to_queue(queue)
    while(count < queue.size) do
      node = queue[count]
      count += 1
      node.first_degree_friends.each do |n|
        n.add_to_queue(queue) if n.untouched?
      end
    end
    count
  end

  def add_to_queue(q)
    q << self
    self.touch
  end

  def untouched?
    self.touched == 0
  end

  def touched?
    self.touched == 1
  end

  def touch
    @touched = 1
  end
end
