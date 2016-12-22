require "minitest/autorun"
require "digest"

def find_password(input)
  1.upto(5_000_000_000).reduce("") do |memo, i|
    md5 = Digest::MD5.new.update(input + i.to_s).hexdigest
    next_memo = if md5.start_with? "00000"
                  memo + md5[5]
                else
                  memo
                end

    return next_memo if next_memo.length == 8
    next_memo
  end
end

def find_advanced_password(input)
  range = "0".."7"
  1.upto(5_000_000_000).each_with_object(Array.new(8)) do |i, memo|
    md5 = Digest::MD5.new.update(input + i.to_s).hexdigest
    if md5.start_with? "00000"
      proposed_index = md5[5]
      if range.include?(proposed_index)
        memo[proposed_index.to_i] ||= md5[6]
      end
    end
    return memo.join if memo.reject(&:nil?).length == 8
  end
end

class DecodeTest < Minitest::Test
  def test_known_input
    skip
    actual_password = find_password "abc"
    assert_equal "18f47a30", actual_password
  end

  def test_advanced_password
    skip
    actual_password = find_advanced_password "abc"
    assert_equal "05ace8e3", actual_password
  end


  def test_print_find_password
    skip
    puts find_password "cxdnnyjw"
  end

  def test_print_find_advanced_password
    puts find_advanced_password "cxdnnyjw"
  end
end
