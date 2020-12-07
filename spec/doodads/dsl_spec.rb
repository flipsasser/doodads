# frozen_string_literal: true

require "spec_helper"

module BaseHelper
  extend Doodads::DSL
end

RSpec.describe Doodads::DSL do
  before do
    BaseHelper.component_flags.clear
  end

  describe ".included" do
    it "warns people not to include the DSL" do
      allow(Rails.logger).to receive(:warn).with(an_instance_of(String))
      BaseHelper.send :include, described_class

      expect(Rails.logger).to have_received(:warn).with("It looks like you mixed the Doodads::DSL into BaseHelper using `include`. Use `extend` instead to generate a DSL for quickly defining Component classes without complex logic. Please double-check the README to ensure you want to mix it in this way!")
    end
  end

  describe "#component" do
    describe "when called at the top level" do
      it "defines top-level components" do
        expect {
          button = BaseHelper.component :button
          expect(button).to be < Doodads::Component
        }.to change(Doodads::Components.registry, :length).from(0).to(1)
      end

      it "generates a root-level class name" do
        button = BaseHelper.component :button
        expect(button.class_name).to eq("button")
      end
    end

    describe "when called within other components" do
      let(:button) {
        BaseHelper.component(:button) {
          component :label
        }
      }

      it "defines sub-components inside their parent components' registry" do
        expect(button.registry.length).to eq(1)
        expect(Doodads::Components.registry.length).to eq(1)
      end

      it "tracks the parent class" do
        expect(button.registry[:label].parent_component).to eq(button)
      end
    end

    describe "when configuring linking" do
      it "assumes the component is not linkable" do
        button = BaseHelper.component(:button)
        expect(button.link).to eq(false)
      end

      it "accepts `link: true`" do
        button = BaseHelper.component(:button, link: true)
        expect(button.link).to eq(true)
      end

      it "requires links when `link: true`" do
        button = BaseHelper.component(:button, link: true)
        expect(button.link_required?).to eq(true)
      end

      it "accepts `link: :optional`" do
        button = BaseHelper.component(:button, link: :optional)
        expect(button.link_optional?).to eq(true)
      end

      it "assumes links are not nested" do
        button = BaseHelper.component(:button, link: true)
        expect(button.link_nested?).to eq(false)
      end

      it "accepts `link: :nested`" do
        button = BaseHelper.component(:button, link: :nested)
        expect(button.link_nested?).to eq(true)
      end

      it "requires links when `link: :nested`" do
        button = BaseHelper.component(:button, link: :nested)
        expect(button.link_required?).to eq(true)
      end

      it "does not require links when `link: [:nested, :optional]`" do
        button = BaseHelper.component(:button, link: %i[nested optional])
        expect(button.link_required?).to eq(false)
      end
    end

    describe "when configuring the strategy" do
      it "accepts a class" do
        strategy_class = stub_const("BootstrapStrategy", Class.new(Doodads::Strategies::Base))
        button = BaseHelper.component :button, strategy: strategy_class
        expect(button.strategy).to be_instance_of(strategy_class)
      end

      it "accepts a strategy instance" do
        strategy_class = stub_const("BootstrapStrategy", Class.new(Doodads::Strategies::Base))
        button = BaseHelper.component :button, strategy: strategy_class.new
        expect(button.strategy).to be_instance_of(strategy_class)
      end

      it "accepts a strategy :symbol" do
        strategy_class = stub_const("BootstrapStrategy", Class.new(Doodads::Strategies::Base) {
          def class_name_for(name, parent: nil)
            "foo"
          end
        })
        Doodads::Strategies.register(:bootstrap, strategy_class)
        button = BaseHelper.component :button, strategy: :bootstrap
        expect(button.strategy).to be_instance_of(strategy_class)
      end
    end

    describe "when configuring the tag" do
      it "accepts a tag override" do
        button = BaseHelper.component :sparkle, tag: :ol
        expect(button.tag).to eq(:ol)
      end

      it "infers tag when the component name is a valid HTML element" do
        nav = BaseHelper.component :nav
        expect(nav.tag).to eq(:nav)
      end
    end

    it "re-defines components with new options" do
      button = BaseHelper.component :button
      expect(button.tag).to eq(:button)

      expect {
        button_redefinition = BaseHelper.component :button, tag: :test
        expect(button_redefinition.tag).to eq(:test)
      }.not_to change(Doodads::Components.registry, :length).from(1)
    end
  end

  describe "#flag" do
    it "defines a global flag outside of a component" do
      expect {
        BaseHelper.flag :is_active
      }.to change(BaseHelper.component_flags, :count).from(0).to(1)
    end

    it "defines a flag on a component" do
      button = BaseHelper.component(:button) {
        flag :is_active
      }

      expect(button.component_flags[:is_active]).to eq({value: :is_active}.with_indifferent_access)
    end

    it "aliases a flag name to its value on a component" do
      button = BaseHelper.component(:button) {
        flag :is_active, "button-is-active"
      }

      expect(button.component_flags[:is_active]).to eq({value: "button-is-active"}.with_indifferent_access)
    end
  end

  describe "#flags" do
    it "adds flags the that component ONLY" do
      button = BaseHelper.component(:button) {
        flags %i[danger success warning]
      }

      badge = BaseHelper.component(:badge) {
        flags %i[bad good fun]
      }

      expect(button.component_flags.keys).to eq(%w[danger success warning])
      expect(badge.component_flags.keys).to eq(%w[bad good fun])
      expect(BaseHelper.component_flags).to be_empty
    end

    describe "with an array" do
      it "converts the flags to a hash" do
        BaseHelper.flags %i[informational danger success warning]
        expect(BaseHelper.component_flags).to eq({
          informational: {
            value: :informational,
          },
          danger: {
            value: :danger,
          },
          success: {
            value: :success,
          },
          warning: {
            value: :warning,
          },
        }.with_indifferent_access)
      end
    end

    describe "with a hash" do
      it "uses the hash values" do
        BaseHelper.flags pending: :info,
                         failed: :danger,
                         succeeded: :success,
                         paused: :warning

        expect(BaseHelper.component_flags).to eq({
          pending: {
            value: :info,
          },
          failed: {
            value: :danger,
          },
          succeeded: {
            value: :success,
          },
          paused: {
            value: :warning,
          },
        }.with_indifferent_access)
      end
    end
  end

  describe "#wrapper" do
    it "throws an error outside of a component context" do
      expect {
        BaseHelper.wrapper :ul
      }.to raise_error(NoMethodError)
    end

    it "defines a custom wrapper inside a component" do
      button = BaseHelper.component(:button) {
        wrapper :span, class: "button-label"
      }

      wrapper = button.wrappers.last
      expect(wrapper).to be_instance_of(Doodads::Component::Wrapper)
      expect(wrapper.tag).to eq(:span)
    end
  end
end
