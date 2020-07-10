# frozen_string_literal: true

# The helper that gets mixed in to your ApplicationHelper (if it hasn't been already). We use this
# to render components inside of the Rails view context. Because it gets mixed directly in to a
# helper, outside of an engine namespace, it is designed to have as little surface area as
# possible. It adds one method, `render_component_named`, which is called by metaprogrammed-methods
# added via the DSL module.
module Doodads
  module Helper
    def self.included(base)
      base.extend Doodads::DSL
    end

    def render_component_named(name, *args, &block)
      component_class = @_current_doodad_component&.find_component(name) || Doodads::Components.registry[name]
      raise Doodads::Errors::ComponentMissingError.new(name, @_current_doodad_component&.class) if component_class.blank?

      # Mark this as the current leaf in our rendering tree
      previous_component = @_current_doodad_component
      @_current_doodad_component = component_class.new(self, parent: previous_component)

      # Pass the current context in and render the component - this will call `render` on the
      # component class, which can be overridden to receive normalized content and options
      begin
        @_current_doodad_component.normalize_args_and_render(*args, &block)
      ensure
        @_current_doodad_component = previous_component
      end
    end
  end
end
