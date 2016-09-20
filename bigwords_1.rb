# Elle: just thinking: what about if you ignore all the words
# that have letters that are not part of your letters group
# so it is less words to go and process.
#
# So we want an index that helps us ignore words that are not going
# to match, then do our expensive match logic on what's left.
#
# e.g.
#
# words = bat bath tart
#
# []
#   a []
#     b [bath]
#       !c [bat,bath]
#     !b
#       !c
#         ...
#           t [tart]
#
# Traverse this tree to narrow down the possibilities by ignoring
# words that do not contain the letters we want.

require_relative 'random_letters'

# A node in our word decision tree for a given letter.
class Node
  A = 'a'.freeze
  Z = 'z'.freeze

  attr_reader :letter, :leaf, :yes, :no

  def initialize(words, letter = A)
    @letter = letter
    if letter == Z
      @leaf = words
    elsif words.empty?
      @leaf = []
    else
      init_children(words)
    end
  end

  def init_children(words)
    has_letter = []
    i = words.size - 1
    while i >= 0
      word = words[i]
      if word.include?(letter)
        has_letter << words.delete_at(i)
      end
      i -= 1
    end
    @yes = Node.new(has_letter, letter.succ)
    @no = Node.new(words, letter.succ)
    @leaf = nil
  end
end

def can_be_made?(letters, word)
  return false if letters.size < word.size
  word_chars = word.chars
  letters.each_char do |letter|
    i = word_chars.index(letter)
    if i
      word_chars.delete_at(i)
      next
    end
  end
  word_chars.empty?
end

def possible_words(letters, node)
  if node.leaf                          # at a terminating node?
    node.leaf                           # no more tree branches, must check all these words
  elsif letters.include?(node.letter)   # we have this letter
    possible_words(letters, node.yes) + # longest word might be in here
      possible_words(letters, node.no)  # longest word might not use this letter
  else                                  # we don't have this letter
    possible_words(letters, node.no)    # we can only make words that do not have this letter
  end
end

def biggest_words(root_node, letters)
  possible_words(letters, root_node)
      .group_by(&:size)
      .sort
      .map { |_size, words| words }
      .reverse_each
      .each do |words|
    result_words = words.select { |word| can_be_made?(letters, word) }
    return result_words if result_words.any?
  end
end

require 'benchmark'

index_path = 'words.idx'
root_node = nil

index_time = Benchmark.measure do
  if !File.exist?(index_path)
    File.open(index_path, 'w') do |f|
      words = File.read('wordlist.txt')
              .each_line
              .map(&:chomp)
              .select { |word| !word.empty? }
      $stdout.print 'Building word index...'
      $stdout.flush
      root_node = Node.new(words)
      $stdout.puts 'done'
      f << Marshal.dump(root_node)
    end
  else
    $stdout.print 'Loading word index...'
    $stdout.flush
    File.open(index_path) do |f|
      root_node = Marshal.load(f)
    end
    $stdout.puts 'done'
  end
end

puts

search_time = Benchmark.measure do
  srand 0
  50.times do
    letters = random_letters(10)
    puts [letters, biggest_words(root_node, letters).sort.join(', ')].join(': ')
  end
end

puts
printf "Index time: %.3fs, search time: %.3fs\n", index_time.utime, search_time.utime
