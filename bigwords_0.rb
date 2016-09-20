require_relative 'random_letters'

def can_be_made?(letters, word)
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
  all_words
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

time = Benchmark.measure do
  words = File.read('wordlist.txt').each_line.to_a.map(&:strip)

  srand 0
  20.times do
    letters = random_letters(10)
    puts [letters, biggest_words(words, letters).sort.join(', ')].join(': ')
  end
end
puts time.real
