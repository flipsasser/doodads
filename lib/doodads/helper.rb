# frozen_string_literal: true

require "doodads/dsl"

# The helper that gets mixed in to your ApplicationHelper (if it hasn't been already). We use this
# to render components inside of the Rails view context. Because it gets mixed directly in to a
# helper, outside of an engine namespace, it is designed to have as little surface area as
# possible. It adds one instance method, `render_doodad`, which is called by metaprogrammed-methods
# added via the DSL module. The DSL module adds a flag registry, a component registry, and a few
# class-level DSL methods for defining those items - namely `flag, `flags` and `component`. Everything
# else happens within the context of a component, which has an additional DSL that processes stuff
# like wrappers, subcomponents, and the like.
module Doodads
  module Helper
    def self.included(base)
      base.extend Doodads::DSL
    end

    def render_doodad(name, *args, &block)
      component_class = respond_to?(:find_component) ? find_component(name) : Doodads::Components.registry[name]
      raise Doodads::Errors::ComponentMissingError.new(name, self.class) if is_a?(Doodads::Component) && component_class.blank?

      # Pass the current context in - will either be the view itself (when calling a root-level
      # component), which includes ApplicationHelper or whichever other helper Doodads was mixed
      # into, OR it will be an instance of a component, which has access to the view context
      component_class.new(is_a?(Doodads::Component) ? view_context : self, *args, &block)
    end
  end
end
