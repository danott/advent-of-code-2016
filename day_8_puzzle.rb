require "minitest/autorun"

class Pixel
  attr_reader :row, :col, :lit

  def initialize(row:, col:, lit: false)
    @row = row
    @col = col
    @lit = lit
  end

  def to_s
    lit ? "#" : "."
  end
end

class Screen
  attr_reader :pixels, :rows, :cols

  def self.blank(rows:, cols:)
    pixels = (0...rows).each_with_object([]) do |row, array|
      (0...cols).each do |col|
        array << Pixel.new(row: row, col: col)
      end
    end

    new(rows: rows, cols: cols, pixels: pixels)
  end

  def initialize(rows:, cols:, pixels:)
    @rows = rows
    @cols = cols
    @pixels = pixels
  end

  def rect(rows:, cols:)
    next_pixels = pixels.map do |pixel|
      if (0...rows).include?(pixel.row) && (0...cols).include?(pixel.col)
        Pixel.new(row: pixel.row, col: pixel.col, lit: true)
      else
        pixel
      end
    end

    self.class.new(rows: self.rows, cols: self.cols, pixels: next_pixels)
  end

  def rotate(row: nil, col: nil, distance:)
    if row
      rotate_row(row, distance)
    elsif col
      rotate_col(col, distance)
    else
      fail "Provide either row or col you dingus"
    end
  end

  def to_s
    pixels.group_by(&:row).values.map { |row| row.map(&:to_s).join }.join "\n"
  end

  private

  def rotate_row(row, distance)
    next_pixels = pixels.map do |pixel|
      if pixel.row == row
        col = (cols - (distance % cols) + pixel.col) % cols
        Pixel.new(row: pixel.row, col: pixel.col, lit: find_pixel(row, col).lit)
      else
        pixel
      end
    end

    self.class.new(rows: self.rows, cols: self.cols, pixels: next_pixels)
  end

  def rotate_col(col, distance)
    next_pixels = pixels.map do |pixel|
      if pixel.col == col
        row = (rows - (distance % rows) + pixel.row) % rows
        Pixel.new(row: pixel.row, col: pixel.col, lit: find_pixel(row, col).lit)
      else
        pixel
      end
    end

    self.class.new(rows: self.rows, cols: self.cols, pixels: next_pixels)
  end

  def find_pixel(row, col)
    pixels.find do |p|
      p.row == row && p.col == col
    end
  end
end

class ScreenTest < Minitest::Test
  def test_known_operations
    screen = Screen.blank(rows: 3, cols: 7)
    expected = <<-INPUT.lines.map(&:strip).join("\n")
###....
###....
.......
    INPUT
    screen = screen.rect(rows: 2, cols: 3)
    assert_equal expected, screen.to_s

    expected = <<-INPUT.lines.map(&:strip).join("\n")
#.#....
###....
.#.....
    INPUT
    screen = screen.rotate(col: 1, distance: 1)
    assert_equal expected, screen.to_s

    expected = <<-INPUT.lines.map(&:strip).join("\n")
....#.#
###....
.#.....
    INPUT
    screen = screen.rotate(row: 0, distance: 4)
    assert_equal expected, screen.to_s

    expected = <<-INPUT.lines.map(&:strip).join("\n")
.#..#.#
#.#....
.#.....
    INPUT
    screen = screen.rotate(col: 1, distance: 1)
    assert_equal expected, screen.to_s
  end

  def test_comman_parser
    input = <<-INPUT
rect 3x2
rotate column x=1 by 1
rotate row y=0 by 4
rotate column x=1 by 1
    INPUT
    expected = [
      ["rect", cols: 3, rows: 2],
      ["rotate", col: 1, distance: 1],
      ["rotate", row: 0, distance: 4],
      ["rotate", col: 1, distance: 1],
    ]
    assert_equal expected, parse_commands(input)
  end

  def test_running_program
    input = <<-INPUT
rect 3x2
rotate column x=1 by 1
rotate row y=0 by 4
rotate column x=1 by 1
    INPUT
    expected = <<-OUTPUT.lines.map(&:strip).join("\n")
.#..#.#
#.#....
.#.....
    OUTPUT

    screen = Screen.blank(rows: 3, cols: 7)
    actual = run_program(screen: screen, input: input)
    assert_equal expected, actual.to_s
  end
end

def parse_commands(input)
  input.lines.map do |line|
    parse_command(line)
  end
end

def parse_command(line)
  tokens = line.split
  if tokens.first == "rect"
    digits = tokens[1].split("x")
    ["rect", cols: digits.first.to_i, rows: digits.last.to_i]
  elsif "rotate"
    key = tokens[1].slice(0, 3).to_sym
    value = tokens[2].split("=").last.to_i
    distance = tokens.last.to_i
    ["rotate", key => value, distance: distance]
  else
    fail "wat"
  end
end

def run_program(screen: screen, input: input)
  parse_commands(input).reduce(screen) do |memo, command|
    memo.send(*command)
  end
end

input = File.read("day_8_input.txt")
screen = run_program(screen: Screen.blank(rows: 6, cols: 50), input: input)
puts "HOW MANY LIGHTS"
puts screen.to_s
puts screen.pixels.select(&:lit).count
