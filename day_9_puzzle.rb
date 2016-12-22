require "minitest/autorun"
require "pry"

class ExpandTest < Minitest::Test
  def test_expand
    skip
    assert_equal "ADVENT", expand("ADVENT")
    assert_equal "ABBBBBC", expand("A(1x5)BC")
    assert_equal "XYZXYZXYZ", expand("(3x3)XYZ")
    assert_equal "ABCBCDEFEFG", expand("A(2x2)BCD(2x2)EFG")
    assert_equal "(1x3)A", expand("(6x1)(1x3)A")
    assert_equal "X(3x3)ABC(3x3)ABCY", expand("X(8x2)(3x3)ABCY")
  end

  def test_recursive_expand
    skip
    assert_equal 241920, recursive_expand("(27x12)(20x12)(13x14)(7x10)(1x12)A\n")
    assert_equal 20, recursive_expand("X(8x2)(3x3)ABCY")
    assert_equal 9, recursive_expand("(3x3)XYZ\n")
    assert_equal 445, recursive_expand("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN\n")
  end
end

def expand(input)
  chars = input.chars
  result = ""
  in_parens = nil

  while char = chars.shift
    if in_parens
      if char == ")"
        string_to_repeat = ""
        chars_to_repeat, time_to_repeat = in_parens.split("x").map(&:to_i)
        chars_to_repeat.times { string_to_repeat << chars.shift }
        time_to_repeat.times { result << string_to_repeat }
        in_parens = nil
      else
        in_parens << char
      end
    else
      if char == "("
        in_parens = ""
      else
        result << char
      end
    end
  end

  result.gsub(/\s/, "")
end

def recursive_expand(input)
  chars = input.strip.chars
  length = 0
  in_parens = nil

  while char = chars.shift
    if in_parens
      if char == ")"
        string_to_repeat = ""
        chars_to_repeat, time_to_repeat = in_parens.split("x").map(&:to_i)
        chars_to_repeat.times { string_to_repeat << chars.shift }
        time_to_repeat.times { chars.unshift(*string_to_repeat.chars) }
        in_parens = nil
      else
        in_parens << char
      end
    else
      if char == "("
        in_parens = ""
      else
        length += 1
      end
    end
  end

  length
end

input = File.read("day_9_input.txt")
# puts expand(input).length
puts recursive_expand(input)
