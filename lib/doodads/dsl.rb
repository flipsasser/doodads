require "doodads/component"
require "doodads/renderer"

module Doodads
  module DSL
    def self.extended(base)
      base.send :include, Doodads::Renderer
    end

    def container(tagname, options = {}, &block)
      @context_component.add_container(tagname, options)
      instance_eval(&block) if block_given?
    end

    def component(name, options = {}, &block)
      component = Doodads::Component.new(name, options.merge(parent: @context_component))

      # Top-level components use the top-level registry, so we detect whether
      # they are being declared inside of another component block
      component_registry = @context_component.present? ? @context_component.registry : Doodads.registry
      component_registry[name] = component

      define_method(name) do |*args, &block|
        component = (@current_component && @current_component.registry[name]) || Doodads.registry[name]
        render_component(component, *args, &block)
      end

      # Cache the current component for subcomponents to use and call their
      # defining block (if given one)
      previous_context = @context_component
      @context_component = component
      instance_eval(&block) if block_given?

      # Unset @context_component for future component definitions
      @context_component = previous_context
    end

    def modifier(name, default = false)
      @context_component.add_modifier(name, default)
    end

    def modifiers(name)
      @modifiers ||= {}
      @modifiers[name].each do |modifier, default|
        modifier(modifier, default)
      end
    end

    def modifier_set(name, defaults)
      @modifiers ||= {}
      @modifiers[name] = defaults
    end
  end
end
