RSpec::Matchers.define :decode_to_opcode do |expected|
  match do |actual|
    actual.to_s == expected
  end

  failure_message_for_should do |actual|
    "expected that instruction with traits #{actual.traits} would decode to '#{expected}'"
  end

  failure_message_for_should_not do |actual|
    "expected that instruction with traits #{actual.traits} would not decode to '#{expected}'"
  end
end