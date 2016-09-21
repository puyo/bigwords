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
    COL_NO = 0xc0_ff0000
    COL_YES = 0xff_00ff00
    COL_HL = 0xff_ffffff
    COL_NORMAL = 0x50_ffffff
    COL_LETTER = 0xff_ffff00

    INTERVAL = 0.5 # seconds between updates

    def initialize
      fullscreen = false
      super 1024, 768, fullscreen
      self.caption = 'Search Visualisation'
      @index = Node.new(load_word_list)
      @font = Gosu::Font.new(20)
      srand 0
      @letters = 'owtac'
      @current_node = @index
      @nodes_left = []
      @t0 = Time.now.to_f
      @paused = false
      @results = []
    end

    private

    def draw
      draw_node(@index, width / 2, 100, 200, 80)
      @font.draw(@letters, 10, height - 3*(@font.height + 10), 0)
      @font.draw(@results.join(', '), 10, height - 2*(@font.height + 10), 0, 1.0, 1.0, COL_YES)
      if @paused
        @font.draw("PAUSED", 10, height - @font.height - 10, 0)
      end
    end

    def update
      if !@paused && Time.now.to_f > (@t0 + INTERVAL)
        @t0 = Time.now.to_f
        advance_search
      end
    end

    def load_word_list
      %w(cat catfish bat emu dog fish cow cad bead at)
    end

    def draw_node(node, x, y, child_dx, child_dy)
      radius = 20
      if @current_node == node
        circle_col = COL_HL
        rotate(-45, x, y) do
          @letters.chars.each_with_index do |letter, index|
            lcol = letter == @current_node.letter ? COL_YES : COL_NO
            xpos = x + radius * 2 + @font.text_width(@letters[0...index])
            @font.draw(letter, xpos, y - @font.height / 2, 0, 1.0, 1.0, lcol)
          end
        end
      else
        circle_col = COL_NORMAL
      end
      circle_col = COL_HL if @nodes_left.include?(node) # highlight if node is significant
      draw_circle(x, y, radius, circle_col)
      if node.leaf
        words_col = @current_node == node ? COL_YES : COL_NO
        rotate(90, x, y) do
          @font.draw(node.leaf.join(', '), x + radius + 5, y - @font.height / 2, 0, 1.0, 1.0, words_col)
        end
      else
        ax = x - child_dx
        ay = y + child_dy
        bx = x + child_dx
        by = y + child_dy
        draw_line(x, y, COL_YES, ax, ay, COL_YES)
        draw_line(x, y, COL_NO, bx, by, COL_NO)
        draw_node(node.yes, ax, ay, child_dx / 2, child_dy)
        draw_node(node.no, bx, by, child_dx / 2, child_dy)
      end
      @font.draw(node.letter, x - 5, y - @font.height / 2, 0, 1.0, 1.0, COL_LETTER)
    end

    def advance_search
      node = @current_node
      if node.nil?
        @current_node = @index
        @results = []
      elsif node.leaf                        # at a terminating node?
        @results += node.leaf
        @current_node = @nodes_left.pop
        @paused = true if @current_node.nil?
      elsif @letters.include?(node.letter)   # we have this letter
        @current_node = node.yes
        @nodes_left.push node.no
      else                                   # we don't have this letter
        @current_node = node.no
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
