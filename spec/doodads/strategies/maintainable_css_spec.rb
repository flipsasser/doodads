# frozen_string_literal: true

require "doodads/component"
require "doodads/strategies"

RSpec.describe Doodads::Strategies do
  let(:rendering_context) { double(:rendering_context) }
  let(:strategy) { described_class.get(:maintainable_css) }
  let(:parent) { Doodads::Components.create_component(:parent).new(rendering_context) }
  let(:items) { Doodads::Components.create_component(:items).new(rendering_context) }

  it "generates sane root component names" do
    expect(strategy.class_name_for(:parent)).to eq("parent")
  end

  it "generates sane sub-component names" do
    expect(strategy.class_name_for(:child, parent: parent)).to eq("parent-child")
  end

  it "generates sane plural-parent, singular-child component names" do
    expect(strategy.class_name_for(:item, parent: items)).to eq("item")
  end
end
