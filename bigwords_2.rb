# Can we visualise it?

require_relative 'random_letters'
require 'gosu'
require 'chipmunk'

# A node in our word decision tree for a given letter.
class Node
  FIRST = 'a'.freeze
  LAST = 'e'.freeze

  attr_reader :letter, :leaf, :yes, :no

  def initialize(words, letter = FIRST)
    @letter = letter
    if letter == LAST
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

def biggest_words(index, letters)
  possible_words(letters, index)
      .group_by(&:size)
      .sort
      .map { |_size, words| words }
      .reverse_each
      .each do |words|
    result_words = words.select { |word| can_be_made?(letters, word) }
    return result_words if result_words.any?
  end
end

# Visualisation of search index
class SearchVis < Gosu::Window
  def initialize
    super 1024, 768

    self.caption = 'Scrabble Word Search'

    words = load_word_list
    @index = Node.new(words)
    @font = Gosu::Font.new(20)
  end

  def load_word_list
    %w(cat bat frog emu dog fish cow cad bead)
  end

  def draw
    draw_node(@index, self.width / 2, 40, 200)
  end

  def draw_node(node, x, y, children_sep)
    red = Gosu::Color.new(0xff_ff0000)
    draw_circle(x, y, 20, red)
    @font.draw(node.letter, x - 5, y - 10, 0, 1.0, 1.0, 0xff_ffff00)
    if node.leaf
      # OK for now
      rotate(90, x, y) do
        @font.draw(node.leaf.join(', '), x + 25, y - 10, 0)
      end
    else
      ax = x - children_sep
      ay = y + 40
      bx = x + children_sep
      by = y + 40
      draw_line(x, y, red, ax, ay, red)
      draw_line(x, y, red, bx, by, red)
      draw_node(node.yes, ax, ay, children_sep/2)
      draw_node(node.no, bx, by, children_sep/2)
    end
  end

  def update
  end

  def run
    20.times do
      letters = random_letters(10)
      puts [letters, biggest_words(@index, letters).sort.join(', ')].join(': ')
    end
  end

  private

  def draw_circle(x, y, radius, colour, segments: 32)
    coef = 2.0 * Math::PI / segments
    verts = []
    segments.times do |n|
      rads = n * coef
      verts << CP::Vec2.new(radius * Math.cos(rads) + x, radius * Math.sin(rads) + y)
    end
    each_edge(verts) do |a, b|
      draw_line(a.x, a.y, colour, b.x, b.y, colour)
    end
  end

  def each_edge(arr)
    arr.size.times do |n|
      yield arr[n], arr[(n + 1) % arr.size]
    end
  end
end

window = SearchVis.new
window.show
