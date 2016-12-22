require "minitest"
require "minitest/autorun"

class Point
  NORTH = "NORTH"
  EAST = "EAST"
  SOUTH = "SOUTH"
  WEST = "WEST"

  attr_accessor :heading, :x, :y

  def ==(other)
    x == other.x && y == other.y
  end

  def initialize(heading: NORTH, x: 0, y: 0)
    @heading = heading
    @x = x
    @y = y
  end

  def turn_left
    next_heading = case heading
                   when NORTH
                     WEST
                   when WEST
                     SOUTH
                   when SOUTH
                     EAST
                   when EAST
                     NORTH
                   end

    Point.new(heading: next_heading, x: x, y: y)
  end

  def turn_right
    next_heading = case heading
                   when NORTH
                     EAST
                   when EAST
                     SOUTH
                   when SOUTH
                     WEST
                   when WEST
                     NORTH
                   end

    Point.new(heading: next_heading, x: x, y: y)
  end

  def move
    next_x = x
    next_y = y

    case heading
    when NORTH
      next_y = y + 1
    when EAST
      next_x = x + 1
    when SOUTH
      next_y = y - 1
    when WEST
      next_x = x - 1
    end

    Point.new(heading: heading, x: next_x, y: next_y)
  end

  def distance
    x.abs + y.abs
  end
end

def exec(point, instruction)
  case instruction
  when "R"
    point.turn_right
  when "L"
    point.turn_left
  when "M"
    point.move
  end
end

def find_first_duplicate(instructions)
  position = Point.new
  visited = []

  instructions = instructions.gsub(/\s/, "").split ","
  instructions = instructions.reduce([]) do |memo, instruction|
    way_to_turn = instruction[0]
    distance_to_move = instruction[1, 4].to_i
    memo << way_to_turn
    distance_to_move.times do
      memo << "M"
    end
    memo
  end

  instructions.each do |instruction|
    position = exec(position, instruction)
    if instruction == "M"
      break if visited.include?(position)
      visited << position
    end
  end

  position.distance
end

class VisitTwiceTest < MiniTest::Test
  def test_example_1
    assert_equal 4, find_first_duplicate("R8, R4, R4, R8")
  end
end

result = find_first_duplicate "R5, R4, R2, L3, R1, R1, L4, L5, R3, L1, L1, R4, L2, R1, R4, R4, L2, L2, R4, L4, R1, R3, L3, L1, L2, R1, R5, L5, L1, L1, R3, R5, L1, R4, L5, R5, R1, L185, R4, L1, R51, R3, L2, R78, R1, L4, R188, R1, L5, R5, R2, R3, L5, R3, R4, L1, R2, R2, L4, L4, L5, R5, R4, L4, R2, L5, R2, L1, L4, R4, L4, R2, L3, L4, R2, L3, R3, R2, L2, L3, R4, R3, R1, L4, L2, L5, R4, R4, L1, R1, L5, L1, R3, R1, L2, R1, R1, R3, L4, L1, L3, R2, R4, R2, L2, R1, L5, R3, L3, R3, L1, R4, L3, L3, R4, L2, L1, L3, R2, R3, L2, L1, R4, L3, L5, L2, L4, R1, L4, L4, R3, R5, L4, L1, L1, R4, L2, R5, R1, R1, R2, R1, R5, L1, L3, L5, R2"
puts "Result: #{result}"
