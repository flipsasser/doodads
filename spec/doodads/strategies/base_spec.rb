# frozen_string_literal: true

require "spec_helper"

class UnimplementedStrategy < Doodads::Strategies::Base
end

RSpec.describe Doodads::Strategies::Base do
  let(:strategy) { UnimplementedStrategy.new }
  let(:component) { double("Doodads::Components", class_name: "test") }

  describe "#child_name_for" do
    it "returns whatever it received as a string" do
      expect(strategy.child_name_for(component)).to eq("test")
    end
  end

  describe "#class_name_for" do
    it "returns whatever it received as a string, ignoring parent" do
      expect(strategy.class_name_for(:thingy, parent: component)).to eq("thingy")
    end
  end

  describe "#flag_name_for" do
    it "returns whatever it received as a string, ignoring base class" do
      expect(strategy.flag_name_for("item", flag: "is-active")).to eq("is-active")
    end
  end
end
