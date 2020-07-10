# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/LeakyConstantDeclaration
RSpec.describe Doodads::Component, "subclassing" do
  it "automatically registers the component in the root registry" do
    class TestComponent < Doodads::Component; end

    expect(Doodads::Components.registry[:test]).to eq(TestComponent)
  end

  it "registers the component using its custom alias in the root registry" do
    class FunComponent < Doodads::Component
      as :this_component_aint_fun
    end

    expect(Doodads::Components.registry[:this_component_aint_fun]).to eq(FunComponent)
  end
end
# rubocop:enable RSpec/LeakyConstantDeclaration
