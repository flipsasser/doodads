# frozen_string_literal: true

require "doodads/strategies"

RSpec.describe Doodads::Strategies do
  it "provides a method to retrieve CSS strategies" do
    expect(described_class.get(:maintainable_css)).to be_instance_of(Doodads::Strategies::MaintainableCSS)
  end

  it "throws an error when it cannot retrieve a CSS strategy" do
    expect(-> { described_class.get(:bootstrap) }).to raise_error(Doodads::Errors::StrategyMissingError)
  end

  it "registers a strategy manually" do
    stub_const("Thing", Class.new)
    described_class.register(:fake, Thing)
    expect(described_class.get("fake")).to be_instance_of(Thing)
  end
end
