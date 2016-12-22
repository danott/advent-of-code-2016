require "minitest/autorun"

class Room
  attr_reader :id, :real
  alias real? real

  def initialize(code)
    parts = code.split("-")
    id_and_checksum = parts.pop

    proposed_checksum = id_and_checksum.scan(/[a-z]/).join
    counts = parts.join.chars.each_with_object(Hash.new(0)) { |c, o| o[c] += 1 }
    actual_checksum = parts.join.chars.uniq.sort.reverse.sort { |a, b| if counts[a] == counts[b] then b <=> a else counts[a] <=> counts[b] end }.reverse.take(5).join

    @parts = parts
    @id = id_and_checksum.scan(/\d/).join.to_i
    @real = proposed_checksum == actual_checksum
    @code = code
  end

  def real_name
    @parts.join(" ").chars.map do |c|
      if c == " "
        c
      else
        ((((c.ord - 97) + (id % 26)) % 26) + 97).chr
      end
    end.join
  end
end

def real_room(code)
  Room.new(code).real?
end

def sum_of_real_rooms(*codes)
  ids = codes.map { |c| Room.new(c) }.select(&:real?).map(&:id).reduce(0, &:+)
end

def shift_room(code)
  Room.new(code).real_name
end

class RoomTest < Minitest::Test
  def test_inputs
    assert real_room "aaaaa-bbb-z-y-x-123[abxyz]"
    assert real_room "a-b-c-d-e-f-g-h-987[abcde]"
    assert real_room "not-a-real-room-404[oarel]"
    refute real_room "totally-real-room-200[decoy]"
    sum = sum_of_real_rooms "aaaaa-bbb-z-y-x-123[abxyz]",
                            "a-b-c-d-e-f-g-h-987[abcde]",
                            "not-a-real-room-404[oarel]",
                            "totally-real-room-200[decoy]"
    assert_equal 1514, sum
  end

  def test_shifting
    assert_equal "very encrypted name", shift_room("qzmt-zixmtkozy-ivhz-343")
  end
end

File.open "day_4_input.txt" do |f|
  puts sum_of_real_rooms(*f.each_line.map(&:chomp))
end

File.open "day_4_input.txt" do |f|
  rooms = f.each_line.map { |l| Room.new(l.chomp) }
  rooms.sort_by(&:real_name).select { |a| a.real_name.include? "north" }.each { |r| puts "#{r.real_name} #{r.id}" }
end
