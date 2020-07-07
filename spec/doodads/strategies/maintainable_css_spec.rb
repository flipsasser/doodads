# frozen_string_literal: true

require "doodads/component"
require "doodads/strategies"

RSpec.describe Doodads::Strategies do
  let(:strategy) { described_class.get(:maintainable_css) }
  let(:parent) { Doodads::Component.new(:parent) }
  let(:items) { Doodads::Component.new(:items) }

  it "generates sane root component names" do
    expect(strategy.class_name_for(:parent)).to eq("parent")
  end

  it "generates sane sub-component names" do
    expect(strategy.class_name_for(:child, parent: parent)).to eq("parent-child")
  end

  it "generates sane plural-container, singular-child component names" do
    expect(strategy.class_name_for(:item, parent: items)).to eq("item")
  end
end
