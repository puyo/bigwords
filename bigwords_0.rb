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
  letters = letters.downcase
  all_words = all_words.group_by(&:size)
  (1..letters.size).reverse_each do |size| # biggest to smallest
    words = all_words[size]
    next if words.nil?
    results = words.select { |word| can_be_made?(letters, word) }
    return results if results.any?
  end
end

srand 0

words = File.read('wordlist.txt').each_line.to_a.map(&:strip)
50.times do
  letters = random_letters(10)
  puts [letters, biggest_words(words, letters).sort.join(', ')].join(': ')
end
