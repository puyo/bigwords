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
    .map(&:last)
    .reverse
    .map do |words|
      words.select { |word| can_be_made?(letters, word) }.sort
    end.flatten
end

require 'benchmark'

time = Benchmark.measure do
  words = File.read('wordlist.txt').each_line.to_a.map(&:strip).reject{|w| w.size == 0 }

  srand 0
  50.times do
    letters = random_letters(7)
    big = biggest_words(words, letters)
    puts "#{letters}: (#{big.size}) #{big[0..10].join(', ')}..."
  end
end

puts
printf "Search time: %.3fs\n", time.utime
