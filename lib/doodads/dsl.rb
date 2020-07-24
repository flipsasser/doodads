# frozen_string_literal: true

require "doodads/errors"
require "doodads/helper"

module Doodads
  module DSL
    def self.included(base)
      unless Doodads.config.suppress_include_dsl_warning
        message = "It looks like you mixed the Doodads::DSL into #{base} using `include`."
        message = "#{message} Use `extend` instead to generate a DSL for quickly defining Component classes without complex logic."
        message = "#{message} Please double-check the README to ensure you want to mix it in this way!"
        Rails.logger.warn message
      end
    end

    def component(name, options = {}, &block)
      # Build the component - either within a parent component, or at the root level
      context = respond_to?(:create_component) ? self : Doodads::Components
      component = context.create_component(name, options.merge(parent: self))

      # Evaluate additional DSL configuration stuff inside of the component we're creating
      component.instance_exec(&block) if block_given?

      # Finally, add a named method to just find a component by that name and render it to the helper module
      class_eval <<-EOC, __FILE__, __LINE__ + 1
  def #{name}(*args, &block)
    render_doodad(:#{name}, *args, &block)
  end
      EOC

      component
    end

    def flags(name, options, global: false, type: :class_name)
      options = Hash[*options.map { |option| [option, option] }.flatten] if options.is_a?(Array)
      Doodads::Flags[name] = options.with_indifferent_access
    end
  end
end
