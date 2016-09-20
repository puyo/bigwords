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

def biggest_words(all_words, letters)
  letters = letters.downcase
  all_words = all_words.group_by(&:size)
  (1..letters.size).reverse_each do |size| # biggest to smallest
    words = all_words[size]
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

words = File.read('wordlist.txt').each_line.to_a.map(&:strip)
50.times do
  letters = random_letters(10)
  puts [letters, biggest_words(words, letters).join(', ')].join(': ')
end
