require File.dirname(__FILE__) + "/node"

class Population
  attr_reader :citizens

  def initialize(file_path="./config/word.list")
    @citizens ||= {}
    File.open(file_path, "r").each_line{|word|
      word = word.chomp
      @citizens[word.length] ||= {}
      @citizens[word.length][word] = Node.new(word)
    }
  end

  def build_connections
    hash = {}

    self.citizens.keys.sort.reverse.each{|len|
      #possibility of at least one (sibling || child || parent)
      if self.citizens[len].size > 1 || has_words_in?(len-1) || has_words_in?(len+1)
        self.citizens[len].each_pair {|word, node|
          node.child_word_list.each {|child_word|
            if self.citizens[len-1] && self.citizens[len-1].has_key?(child_word)
              node.add_friend(self.citizens[len-1][child_word])
            end
          }
          node.sibling_word_list.each {|sibling_word|
            if hash.has_key?(sibling_word)
              node.add_friend(hash[sibling_word])
            else
              hash[sibling_word] = node
            end
          }
        }
      end
      hash.clear
    }
  end

  def walk_and_count(word)
    return 0 unless has_word?(word)
    node = self.citizens[word.length][word]
    node.count_friends
  end

  private
  def has_words_in?(key)
    self.citizens[key] && citizens[key].size >=1
  end

  def has_word?(word)
    self.citizens[word.length] && self.citizens[word.length].has_key?(word)
  end
end
