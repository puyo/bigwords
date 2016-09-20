ALPHABET = 'abcdefghijklmnopqrstuvwxyz'.chars
VOWELS = 'aeiou'.chars
CONSONANTS = ALPHABET - VOWELS

def random_letters(length)
  vowels = length / 3 # 33% vowels
  consonants = length - vowels
  result = random_letters_from(vowels, VOWELS) +
           random_letters_from(consonants, CONSONANTS)
  result.shuffle.join
end

def random_letters_from(length, source)
  Array.new(length) { source[rand(source.size)] }
end
