# frozen_string_literal: true

require "spec_helper"

class UnimplementedStrategy < Doodads::Strategies::Base
end

RSpec.describe Doodads::Strategies::Base do
  let(:strategy) { UnimplementedStrategy.new }
  let(:component) { double("Doodads::Components") }

  describe "#child_name_for" do
    it "throws an error when unimplemented" do
      expect {
        strategy.child_name_for(component)
      }.to raise_error(NotImplementedError)
    end
  end

  describe "#class_name_for" do
    it "throws an error when unimplemented" do
      expect {
        strategy.class_name_for(:thingy, parent: component)
      }.to raise_error(NotImplementedError)
    end
  end

  describe "#flag_name_for" do
    it "throws an error when unimplemented" do
      expect {
        strategy.flag_name_for("item", flag: "is-active")
      }.to raise_error(NotImplementedError)
    end
  end
end
