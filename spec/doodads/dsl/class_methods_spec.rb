# frozen_string_literal: true

require "spec_helper"

module BaseHelper
  extend Doodads::DSL::ClassMethods
end

RSpec.describe Doodads::DSL::ClassMethods do
  describe "#component" do
    it "allows us to define a top-level component" do
      expect {
        BaseHelper.component :button
      }.to change(Doodads.registry, :length).from(0).to(1)
    end

    it "allows us to define a sub-component" do
      button = BaseHelper.component :button do
        component :label
      end

      expect(Doodads.registry.length).to eq(1)
      expect(button.registry.length).to eq(1)
    end
  end

  describe "#modifier" do
    it "throws an error outside of a component context" do
      expect {
        BaseHelper.modifier :is_active
      }.to raise_error(Doodads::Errors::ComponentRequiredError)
    end

    it "allows me to define a modifier on a component" do
      button = BaseHelper.component :button do
        modifier :is_active
      end

      expect(button.modifiers[:is_active]).to eq(:is_active)
    end

    it "allows me to alias a modifier value on a component" do
      button = BaseHelper.component :button do
        modifier :is_active, "button-is-active"
      end

      expect(button.modifiers[:is_active]).to eq("button-is-active")
    end
  end
end
