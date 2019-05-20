require "doodads/css_strategies"

RSpec.describe Doodads::CSSStrategies do
  it "provides a method to retrieve CSS strategies" do
    expect(Doodads::CSSStrategies.get(:maintainable_css)).to be_instance_of(Doodads::CSSStrategies::MaintainableCSS)
  end

  it "throws an error when it cannot retrieve a CSS strategy" do
    expect(-> { Doodads::CSSStrategies.get(:bootstrap) }).to raise_error(Doodads::CSSStrategies::StrategyMissingError)
  end
end