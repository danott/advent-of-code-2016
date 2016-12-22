require "minitest/autorun"

class TlsTest < Minitest::Test
  def test_allows_tls
    assert allows_tls "abba[mnop]qrst" # supports TLS (abba outside square brackets).
    refute allows_tls "abcd[bddb]xyyx" #does not support TLS (bddb is within square brackets, even though xyyx is outside square brackets).
    refute allows_tls "aaaa[qwer]tyui" #does not support TLS (aaaa is invalid; the interior characters must be different).
    assert allows_tls "ioxxoj[asdfgh]zxcvbn" # supports TLS (oxxo is outside square brackets, even though it's within a larger string).
  end

  def test_allows_ssl
    assert allows_ssl "aba[bab]xyz" # supports SSL (aba outside square brackets with corresponding bab within square brackets).
    refute allows_ssl "xyx[xyx]xyx" # does not support SSL (xyx, but no corresponding yxy).
    assert allows_ssl "aaa[kek]eke" # supports SSL (eke in supernet with corresponding kek in hypernet; the aaa sequence is not related, because the interior character must be different).
    assert allows_ssl "zazbz[bzb]cdb" # supports SSL (zaz has no corresponding aza, but zbz has a corresponding bzb, even though zaz and zbz overlap).
  end
end

def strings_outside_brackets(string)
  string.gsub(/\[.*?\]/, " ").split
end

def strings_within_brackets(string)
  string.scan(/\[(.*?)\]/).flatten
end

def allows_tls(string)
  candidates = strings_outside_brackets(string)
  rejectors = strings_within_brackets(string)

  includes_4_char_multichar_palendrome?(candidates) &&
    !includes_4_char_multichar_palendrome?(rejectors)
end

def allows_ssl(string)
  outside_brackets = strings_outside_brackets(string)
  within_brackets = strings_within_brackets(string)


  outside_paledromes = palendromes_of_3(outside_brackets).map { |i| i.slice(0, 2) }
  within_palendromes = palendromes_of_3(within_brackets).map { |i| i.slice(0, 2).reverse }

  outside_paledromes.any? do |outside|
    within_palendromes.include?(outside)
  end
end

def palendromes_of_3(candidates)
  candidates.each_with_object([]) do |string, memo|
    strings_of_n(3, string).each do |string|
      memo << string if palendrome?(string) && multichar?(string)
    end
  end
end

def includes_4_char_multichar_palendrome?(candidates)
  candidates.any? do |string|
    strings_of_4(string).any? do |string|
      palendrome?(string) && multichar?(string)
    end
  end
end

def palendrome?(string)
  string == string.reverse
end

def multichar?(string)
  string.chars.uniq.count > 1
end

def strings_of_n(n, string)
  Enumerator.new do |yielder|
    0.upto(string.length - n) do |i|
      yielder << string.slice(i, n)
    end
  end
end

def strings_of_4(string)
  strings_of_n(4, string)
end

real_input = File.read("day_7_input.txt")

counts = real_input.lines.map(&:strip).select do |line|
  allows_ssl(line)
end.count

puts counts


