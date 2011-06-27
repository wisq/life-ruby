#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'

class Rules
  def self.still_alive?(living)
    (2..3).include?(living)
  end

  def self.becomes_alive?(living)
    living == 3
  end
end

class Board
  def self.from_file(file)
    File.open(file) do |fh|
      file =~ /\.rle$/ ? from_rle(fh) : from_dots(fh)
    end
  end

  def self.from_dots(fh)
    living = []
    fh.read.lines.each_with_index do |line, y|
      line.chomp.chars.each_with_index do |char, x|
        living << [x, y] if char != ' '
      end
    end
    new(living)
  end

  def self.from_rle(fh)
    living = []
    y = 0
    fh.each_line do |line|
      next unless line =~ /^\d/

      x = 0
      count = 1
      line.chomp.split(/(\D)/).each do |chunk|
        case chunk
        when ''
          # next
        when /\d/
          count = chunk.to_i
        when 'o'
          living += (x...x+count).map {|nx| [nx, y]}
          x += count
          count = 1
        when 'b'
          x += count
          count = 1
        when '$'
          y += 1
        when '!'
          # done
        else
          raise "oops: #{chunk.inspect}"
        end
      end
    end
    p living.count
    new(living)
  end

  attr_reader :living

  def initialize(living = [])
    @living = Set.new(living)
  end

  def neighbour_coords(*coords)
    x, y = coords
    [
      [x-1, y-1], [x, y-1], [x+1, y-1],
      [x-1, y  ],           [x+1, y  ],
      [x-1, y+1], [x, y+1], [x+1, y+1],
    ]
  end

  def living_count_around(*coords)
    (@living & neighbour_coords(*coords)).count
  end

  def dead_neighbours
    @living.inject(Set.new) do |dead, cell|
      dead + neighbour_coords(*cell)
    end - @living
  end

  def cells_staying_alive
    @living.select do |coord|
      Rules.still_alive?(living_count_around(*coord))
    end
  end

  def cells_becoming_alive
    dead_neighbours.select do |coord|
      Rules.becomes_alive?(living_count_around(*coord))
    end
  end

  def next_board
    Board.new(cells_staying_alive + cells_becoming_alive)
  end
end

class BoardWindow < Gosu::Window
  COLOR = Gosu::Color::WHITE
  SCALE = 5
  FPS   = 50
  OFFSET = 300

  def initialize(file)
    @board = Board.from_file(ARGV.first)
    @iter  = 0
    super(1400, 860, false, 1000 / FPS)
  end

  def update
    @iter += 1
    return if @iter == 1

    next_board = @board.next_board
    self.caption = "Iteration #{@iter}: #{@board.living.count} => #{next_board.living.count}"
    @board = next_board
  end

  def min(c)
    OFFSET + c * SCALE
  end
  def max(c)
    min(c+1)
  end

  def draw
    @board.living.each do |x, y|
      draw_quad(
        min(x), min(y), COLOR,
        max(x), min(y), COLOR,
        max(x), max(y), COLOR,
        min(x), max(y), COLOR
      )
    end
  end
end

if __FILE__ == $0
  window = BoardWindow.new(ARGV.first)
  window.show
end
