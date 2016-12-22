require "minitest/autorun"
require "pry"

class ResponsibilityTest < Minitest::Test
  def test_input
<<-INPUT
value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2
INPUT
  end

  def test_bot_responsible_for
    brokerage = Brokerage.from_input(test_input)
    assert_equal 2, bot_responsible_for_comparing(brokerage, 2, 5)
  end
end

class Rule
  attr_reader :kind, :id

  def initialize(kind:, id:)
    @kind = kind
    @id = id.to_i
  end
end

class Bot
  attr_reader :id, :chips, :low_rule, :high_rule

  def initialize(id:, chips:, low_rule:, high_rule:)
    @id = id.to_i
    @chips = chips.map(&:to_i).sort
    @low_rule = low_rule
    @high_rule = high_rule
  end

  def decider?
    chips.length == 2
  end

  def low_chip
    chips.min
  end

  def high_chip
    chips.max
  end

  def without_chips
    self.class.new(id: id, low_rule: low_rule, high_rule: high_rule, chips: [])
  end

  def with_chip(chip)
    next_chips = chips + [chip]
    self.class.new(id: id, low_rule: low_rule, high_rule: high_rule, chips: next_chips)
  end
end

class Output
  attr_reader :id, :chip

  def initialize(id:, chip: nil)
    @id = id.to_i
    @chip = chip
  end

  def with_chip(chip)
    self.class.new(id: id, chip: chip)
  end
end

class Brokerage
  attr_reader :bots, :outputs

  def self.from_input(input)
    definitions = Hash.new do |hash, key|
      hash[key] = { chips: [] }
    end

    input.lines.each do |line|
      if line.start_with?("bot")
        _, id, _, _, _, low_kind, low_id, _, _, _, high_kind, high_id = line.split(" ")
        definitions[id] = definitions[id].merge(low_kind: low_kind, low_id: low_id, high_kind: high_kind, high_id: high_id)
      else
        _, value, _, _, _, bot_id = line.split(" ")
        definition = definitions[bot_id]
        definitions[bot_id] = definition.merge(chips: definition[:chips] + [value])
      end
    end

    bots = definitions.map do |id, definition|
      id = id
      low_rule = Rule.new(kind: definition[:low_kind], id: definition[:low_id])
      high_rule = Rule.new(kind: definition[:high_kind], id: definition[:high_id])
      chips = definition[:chips]
      Bot.new(id: id, chips: chips, low_rule: low_rule, high_rule: high_rule)
    end

    outputs = definitions.reduce([]) do |memo, (id, definition)|
      if definition[:low_kind] == "output"
        memo << Output.new(id: definition[:low_id])
      end

      if definition[:high_kind] == "output"
        memo << Output.new(id: definition[:high_id])
      end

      memo
    end
    new bots: bots, outputs: outputs
  end

  def initialize(bots:, outputs:)
    @bots = bots.sort_by(&:id)
    @outputs = outputs.sort_by(&:id)
  end

  def decider
    bots.find(&:decider?)
  end

  def step
    low_receiver = find_receiver_for_rule(decider.low_rule)
    high_receiver = find_receiver_for_rule(decider.high_rule)

    next_bots = bots.map do |bot|
      if bot == decider
        decider.without_chips
      elsif bot == low_receiver
        low_receiver.with_chip(decider.low_chip)
      elsif bot == high_receiver
        high_receiver.with_chip(decider.high_chip)
      else
        bot
      end
    end

    next_outputs = outputs.map do |output|
      if output == low_receiver
        output.with_chip(decider.low_chip)
      elsif output == high_receiver
        output.with_chip(decider.high_chip)
      else
        output
      end
    end

    self.class.new(bots: next_bots, outputs: next_outputs)
  end

  def find_receiver_for_rule(rule)
    if rule.kind == "bot"
      bots.find { |b| b.id == rule.id }
    else
      outputs.find { |o| o.id == rule.id }
    end
  end
end

def bot_responsible_for_comparing(brokerage, min, max)
  expected = [min, max]
  while decider = brokerage.decider
    return decider.id if decider.chips == expected
    brokerage = brokerage.step
  end
end

def multiply_outputs(brokerage, ids_of_interest)
  while decider = brokerage.decider
    brokerage = brokerage.step
  end

  outputs = brokerage.outputs.select { |o| ids_of_interest.include?(o.id) }
  outputs.map { |o| o.chip }.reduce(:*)
end

real_input = File.read("day_10_input.txt")
brokerage = Brokerage.from_input(real_input)

puts bot_responsible_for_comparing(brokerage, 17, 61)
puts multiply_outputs(brokerage, [0, 1, 2])
