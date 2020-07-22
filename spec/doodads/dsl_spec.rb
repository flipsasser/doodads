# frozen_string_literal: true

require "spec_helper"

module BaseHelper
  extend Doodads::DSL
end

RSpec.describe Doodads::DSL do
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
        expect(button.registry[:label].parent).to eq(button)
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

      it "accepts `link_optional: true`" do
        button = BaseHelper.component(:button, link_optional: true)
        expect(button.link_optional?).to eq(true)
      end

      it "accepts `link_optional: false`" do
        button = BaseHelper.component(:button, link_optional: false)
        expect(button.link_required?).to eq(false)
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

      it "does not require links when `link: :nested, link_optional: true`" do
        button = BaseHelper.component(:button, link: :nested, link_optional: true)
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

    describe "when configuring the tagname" do
      it "accepts a tagname override" do
        button = BaseHelper.component :sparkle, tagname: :ol
        expect(button.tagname).to eq(:ol)
      end

      it "infers tagname when the component name is a valid HTML element" do
        nav = BaseHelper.component :nav
        expect(nav.tagname).to eq(:nav)
      end
    end

    it "re-defines components with new options" do
      button = BaseHelper.component :button
      expect(button.tagname).to eq(:button)

      expect {
        button_redefinition = BaseHelper.component :button, tagname: :test
        expect(button_redefinition.tagname).to eq(:test)
      }.not_to change(Doodads::Components.registry, :length).from(1)
    end
  end

  describe "#flag" do
    it "throws an error outside of a component context" do
      expect {
        BaseHelper.flag :is_active
      }.to raise_error(Doodads::Errors::ComponentRequiredError)
    end

    it "defines a flag on a component" do
      button = BaseHelper.component(:button) {
        flag :is_active
      }

      expect(button.flags[:is_active]).to eq(:is_active)
    end

    it "aliases a flag name to its value on a component" do
      button = BaseHelper.component(:button) {
        flag :is_active, "button-is-active"
      }

      expect(button.flags[:is_active]).to eq("button-is-active")
    end
  end

  describe "#flag_set" do
    it "throws an error inside of a component" do
      expect {
        BaseHelper.component(:button) {
          flag_set :statuses, %i[informational danger success warning]
        }
      }.to raise_error(Doodads::Errors::NoComponentRequiredError)
    end

    describe "with an array" do
      it "converts the flags to a hash" do
        BaseHelper.flag_set :status_array, %i[informational danger success warning]
        expect(Doodads::Flags[:status_array]).to eq({
          informational: :informational,
          danger: :danger,
          success: :success,
          warning: :warning,
        }.with_indifferent_access)
      end
    end

    describe "with a hash" do
      it "uses the hash values" do
        BaseHelper.flag_set :status_hash,
          pending: :info,
          failed: :danger,
          succeeded: :success,
          paused: :warning

        expect(Doodads::Flags[:status_hash]).to eq({
          pending: :info,
          failed: :danger,
          succeeded: :success,
          paused: :warning,
        }.with_indifferent_access)
      end
    end
  end

  describe "#wrapper" do
    it "throws an error outside of a component context" do
      expect {
        BaseHelper.wrapper :ul
      }.to raise_error(Doodads::Errors::ComponentRequiredError)
    end

    it "defines a custom wrapper inside a component" do
      button = BaseHelper.component(:button) {
        wrapper :span, class: "button-label"
      }

      wrapper = button.wrappers.last
      expect(wrapper).to be_instance_of(Doodads::Component::Wrapper)
      expect(wrapper.tagname).to eq(:span)
    end
  end
end
