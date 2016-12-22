class Triangle
  attr_reader :a, :b, :c

  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
  end

  def real?
    a + b > c &&
      a + c > b &&
      b + c > a
  end
end

input = File.read "day_3_input.txt"

lines = input.split("\n").map do |line|
  line.split.map(&:to_i).reject(&:zero?)
end

triangles = lines.map do |lengths|
  Triangle.new *lengths
end

real_triangles_by_row = triangles.select(&:real?).count
puts "by row: #{real_triangles_by_row}"

columns = input.split.map(&:to_i).reject(&:zero?).group_by.each_with_index do |number, index|
  index % 3
end


triangles = columns.each_with_object([]) do |(_, col), arr|
  while col.any?
    arr << Triangle.new(*col.pop(3))
  end
end

real_triangles_by_column = triangles.select(&:real?).count
puts "by column: #{real_triangles_by_column}"


# vertical = <<-VERTICAL
#   101 301 501
#   102 302 502
#   103 303 503
#   201 401 601
#   202 402 602
#   203 403 603
# VERTICAL


# puts numbers
