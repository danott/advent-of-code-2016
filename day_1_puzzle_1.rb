require "minitest"
require "minitest/autorun"

class GridPosition
  NORTH = "NORTH"
  EAST = "EAST"
  SOUTH = "SOUTH"
  WEST = "WEST"

  attr_accessor :direction, :x, :y

  def initialize
    @direction = NORTH
    @x = 0
    @y = 0
  end

  def walk(instructions_string)
    instructions = instructions_string.gsub(/\s/, "").split ","
    instructions.each { |instruction| exec(instruction) }
  end

  def exec(instruction)
    way_to_turn = instruction[0]
    distance_to_move = instruction[1, 4].to_i

    case way_to_turn
    when "R"
      turn_right
    when "L"
      turn_left
    end

    move distance_to_move.to_i
  end

  def turn_left
    self.direction = case direction
                     when NORTH
                       WEST
                     when WEST
                       SOUTH
                     when SOUTH
                       EAST
                     when EAST
                       NORTH
                     end
  end

  def turn_right
    self.direction = case direction
                     when NORTH
                       EAST
                     when EAST
                       SOUTH
                     when SOUTH
                       WEST
                     when WEST
                       NORTH
                     end
  end

  def move(magnitude)
    case direction
    when NORTH
      self.y = y + magnitude
    when EAST
      self.x = x + magnitude
    when SOUTH
      self.y = y - magnitude
    when WEST
      self.x = x - magnitude
    end
  end

  def distance
    x.abs + y.abs
  end
end

def compute_distance(instructions_string)
  grid_position = GridPosition.new
  grid_position.walk(instructions_string)
  grid_position.distance
end

class DistanceTest < MiniTest::Test
  def test_example_1
    assert_equal 5, compute_distance("R2, L3")
  end

  def test_example_2
    assert_equal 2, compute_distance("R2, R2, R2")
  end

  def test_example_3
    assert_equal 12, compute_distance("R5, L5, R5, R3")
  end
end

result = compute_distance "R5, R4, R2, L3, R1, R1, L4, L5, R3, L1, L1, R4, L2, R1, R4, R4, L2, L2, R4, L4, R1, R3, L3, L1, L2, R1, R5, L5, L1, L1, R3, R5, L1, R4, L5, R5, R1, L185, R4, L1, R51, R3, L2, R78, R1, L4, R188, R1, L5, R5, R2, R3, L5, R3, R4, L1, R2, R2, L4, L4, L5, R5, R4, L4, R2, L5, R2, L1, L4, R4, L4, R2, L3, L4, R2, L3, R3, R2, L2, L3, R4, R3, R1, L4, L2, L5, R4, R4, L1, R1, L5, L1, R3, R1, L2, R1, R1, R3, L4, L1, L3, R2, R4, R2, L2, R1, L5, R3, L3, R3, L1, R4, L3, L3, R4, L2, L1, L3, R2, R3, L2, L1, R4, L3, L5, L2, L4, R1, L4, L4, R3, R5, L4, L1, L1, R4, L2, R5, R1, R1, R2, R1, R5, L1, L3, L5, R2"
puts "Result: #{result}"
