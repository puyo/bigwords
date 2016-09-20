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

ALPHABET = 'abcdefghijklmnopqrstuvwxyz'.chars
VOWELS = 'aeiou'.chars
CONSONANTS = ALPHABET - VOWELS

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
  if node.leaf
    # No criteria to decide. Consider these words.
    node.leaf
  elsif letters.include?(node.letter) # we have this letter!
    # It could be in the yes or no branch (not all letters must be used)
    possible_words(letters, node.yes) + possible_words(letters, node.no)
  else # we don't have this letter :(
    # Filter out words that have this letter. We can't make them.
    possible_words(letters, node.no)
  end
end

def biggest_words(root_node, letters)
  letters = letters.downcase
  possible_words = possible_words(letters, root_node).group_by(&:size)
  (1..letters.size).reverse_each do |size| # biggest to smallest
    words = possible_words[size]
    next if words.nil?
    results = words.select { |word| can_be_made?(letters, word) }
    return results if results.any?
  end
end

# ------

def random_letters_from(length, source)
  Array.new(length) { source[rand(source.size)] }
end

def random_letters(length)
  vowels = length / 3 # 33% vowels
  consonants = length - vowels
  result = random_letters_from(vowels, VOWELS) + random_letters_from(consonants, CONSONANTS)
  result.shuffle.join
end

# ------

index_path = 'words.idx'
root_node = nil

if !File.exist?(index_path)
  File.open(index_path, 'w') do |f|
    words = File.read('wordlist.txt').each_line.to_a.map(&:strip)
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

#srand(0)
10.times do
  letters = random_letters(10)
  #letters = "Gregory McIntyre"
  puts [letters, biggest_words(root_node, letters).join(', ')].join(': ')
end
