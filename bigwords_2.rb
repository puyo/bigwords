# Can we visualise it?

require_relative 'random_letters'
require 'gosu'
require 'chipmunk'

# Visualisation of search index
module SearchVis

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

  # Top level window
  class Window < Gosu::Window
    RED = 0xaa_ff0000
    GREEN = 0xff_00ff00
    HL = 0xff_ffffff
    NORMAL = 0x80_ffffff
    YELLOW = 0xff_ffff00
    WHITE = 0xff_ffffff

    def initialize
      fullscreen = false
      super 1024, 768, fullscreen, 1000
      self.caption = 'Search Visualisation'
      @index = Node.new(load_word_list)
      @font = Gosu::Font.new(20)
      srand 0
      @letters = 'owtac'
      @current_node = @index
      @nodes_left = []
      @t0 = Time.now
      @paused = false
    end

    private

    def draw
      draw_node(@index, width / 2, 100, 200, 80)
      if @paused
        @font.draw("PAUSED", 10, height - @font.height - 10, 0, 1.0, 1.0, WHITE)
      end
    end

    def update
      if !@paused && Time.now > (@t0 + update_interval / 1000)
        advance_search
      end
    end

    def load_word_list
      %w(cat catfish bat emu dog fish cow cad bead at)
    end

    def draw_node(node, x, y, child_dx, child_dy)
      radius = 20
      if @current_node == node
        circle_col = HL
        @letters.chars.each_with_index do |letter, index|
          lcol = letter == @current_node.letter ? GREEN : RED
          xpos = x + radius * 2 + @font.text_width(@letters[0...index])
          @font.draw(letter, xpos, y - @font.height / 2, 0, 1.0, 1.0, lcol)
        end
      else
        circle_col = NORMAL
      end
      if @nodes_left.include?(node)
        circle_col = HL
      end
      draw_circle(x, y, radius, circle_col)
      if node.leaf
        words_col = @current_node == node ? GREEN : WHITE
        rotate(90, x, y) do
          @font.draw(node.leaf.join(', '), x + radius + 5, y - @font.height / 2, 0, 1.0, 1.0, words_col)
        end
      else
        ax = x - child_dx
        ay = y + child_dy
        bx = x + child_dx
        by = y + child_dy
        draw_line(x, y, GREEN, ax, ay, GREEN)
        draw_line(x, y, RED, bx, by, RED)
        draw_node(node.yes, ax, ay, child_dx / 2, child_dy)
        draw_node(node.no, bx, by, child_dx / 2, child_dy)
      end
      @font.draw(node.letter, x - 5, y - @font.height / 2, 0, 1.0, 1.0, YELLOW)
    end

    def advance_search
      node = @current_node
      if node.nil?
        @current_node = @index
        return
      end
      if node.leaf                          # at a terminating node?
        if @nodes_left
          @current_node = @nodes_left.pop
        end
      elsif @letters.include?(node.letter)   # we have this letter
        @current_node = node.yes
        @nodes_left.push node.no
      else                                  # we don't have this letter
        @current_node = node.no
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

    def button_down(id)
      case id
      when Gosu::Button::KbSpace # 'throw'
        @paused = !@paused
      when Gosu::Button::KbEscape, char_to_button_id('q')
        close
      end
    end
  end
end

window = SearchVis::Window.new
window.show
