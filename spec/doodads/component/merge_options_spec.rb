# frozen_string_literal: true

require "spec_helper"

class MergeOptionsTest
  include Doodads::Component::MergeOptions
end

RSpec.describe Doodads::Component::MergeOptions, clear: false do
  let(:test) { MergeOptionsTest.new }

  describe "#deep_merge_options" do
    it "merges string values with spaces" do
      expect(
        test.deep_merge_options(
          {
            class: "class1",
          },
          {
            class: "class2",
          },
        ),
      ).to eq({class: "class1 class2"}.with_indifferent_access)
    end

    it "merges symbol values with spaces" do
      expect(
        test.deep_merge_options(
          {
            class: :class1,
          },
          {
            class: "class2",
          },
        ),
      ).to eq({class: "class1 class2"}.with_indifferent_access)
    end

    it "merges array values" do
      expect(
        test.deep_merge_options(
          {
            array: %i[a b c],
          },
          {
            array: %i[x y z],
          },
        ),
      ).to eq({array: %i[a b c x y z]}.with_indifferent_access)
    end

    it "deep merges hash values" do
      expect(
        test.deep_merge_options(
          {
            hash: {
              a: 1,
              b: 2,
              c: 3,
            },
          },
          {
            hash: {
              a: 26,
              x: 0,
              y: 0,
            },
          },
        ),
      ).to eq({hash: {
        a: 26,
        b: 2,
        c: 3,
        x: 0,
        y: 0,
      }}.with_indifferent_access)
    end
  end
end
