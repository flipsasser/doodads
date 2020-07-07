# frozen_string_literal: true

require "doodads/component"
require "doodads/errors"

module Doodads
  module DSL
    module ClassMethods
      def component(name, options = {}, &block)
        # Build the component
        current_registry[name] = Doodads::Component.new(name, options.merge(parent: @context_component)).tap do |component|
          add_render_alias(name)
          configure_component(component, &block) if block_given?
        end
      end

      def container(tagname, options = {}, &block)
        require_current_component!(:container, tagname)
        current_component.add_container(tagname, options)
        instance_eval(&block) if block_given?
      end

      def modifier(name, default = name)
        require_current_component!(:modifier, name)
        current_component.add_modifier(name, default)
      end

      def modifier_set(name, options)
        require_no_current_component!(:modifier_set, name, options)
        @modifiers ||= {}
        @modifiers[name] = if options.is_a?(Array)
          Hash[*options.map { |option| [option, option] }.flatten]
        else
          options
        end
      end

      def use_modifiers(name)
        require_current_component!(:use_modifiers, name)
        @modifiers ||= {}
        @modifiers[name].each do |modifier, default|
          modifier(modifier, default)
        end
      end
      alias modifiers use_modifiers

      private

      attr_accessor :current_component

      def add_render_alias(name)
        # TODO: Make this smarter
        class_eval <<-EOC, __FILE__, __LINE__ + 1
  def #{name}(*args, &block)
    render_component_named(:#{name}, *args, &block)
  end
        EOC
      end

      def configure_component(component, &block)
        # Store a reference to the previously active component so we can restore it later
        previous_component = current_component

        # Evaluate the configuration block in the context of the newly-defined component
        self.current_component = component
        instance_eval(&block)

        # Revert current_component for any additional component definitions
        self.current_component = previous_component
      end

      def current_registry
        # Top-level components use the top-level registry, so we detect whether
        # they are being declared inside of another component block
        (current_component || Doodads).registry
      end

      def require_current_component!(method, *args)
        raise Doodads::Errors::ComponentRequiredError.new(method, *args) if current_component.blank?
      end

      def set_current_component(new_component)
        @current_component.tap do
          @current_component = new_component
        end
      end
    end
  end
end
