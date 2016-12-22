require "minitest/autorun"

class DecoderTest < Minitest::Test
  def input
    <<-INPUT
      eedadn
      drvtee
      eandsr
      raavrd
      atevrs
      tsrnev
      sdttsa
      rasrtv
      nssdts
      ntnada
      svetve
      tesnvt
      vntsnd
      vrdear
      dvrsen
      enarar
    INPUT
  end

  def test_known_part_1
    skip
    assert_equal "easter", decoded(input)
  end

  def test_known_part_2
    skip
    assert_equal "advent", decoded_2(input)
  end

  def test_convert_lines_to_columns
    skip
    input = %w(abc def ghi)
    expected = %w(adg beh cfi)
    actual = convert_to_columns(input)
    assert_equal expected, actual
  end
end

def convert_to_columns(lines)
   lines.each_with_object([]) do |line, memo|
    line.chars.each_with_index do |char, i|
      memo[i] ||= ""
      memo[i] << char
    end
  end
end

def least_common_char(string)
  counts = string.chars.each_with_object({}) do |char, memo|
    memo[char] ||= 0
    memo[char] += 1
  end
  min = counts.values.min
  counts.find { |k, v| v == min }.first
end

def most_common_char(string)
  counts = string.chars.each_with_object({}) do |char, memo|
    memo[char] ||= 0
    memo[char] += 1
  end
  maximum = counts.values.max
  counts.find { |k, v| v == maximum }.first
end

def decoded(input)
  lines = input.lines.map(&:strip)
  columns = convert_to_columns(lines)
  most_common_chars = columns.map { |column| most_common_char(column) }
  most_common_chars.join
end

def decoded_2(input)
  lines = input.lines.map(&:strip)
  columns = convert_to_columns(lines)
  most_common_chars = columns.map { |column| least_common_char(column) }
  most_common_chars.join
end

actual_input = File.read("day_6_input.txt")
puts decoded(actual_input)
puts decoded_2(actual_input)
