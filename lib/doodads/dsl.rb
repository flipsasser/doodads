# frozen_string_literal: true

require "doodads/errors"
require "doodads/flags"
require "doodads/helper"

module Doodads
  module DSL
    def self.extended(base)
      base.extend Doodads::Flags
    end

    def self.included(base)
      unless Doodads.config.suppress_include_dsl_warning
        message = "It looks like you mixed the Doodads::DSL into #{base} using `include`."
        message = "#{message} Use `extend` instead to generate a DSL for quickly defining Component classes without complex logic."
        message = "#{message} Please double-check the README to ensure you want to mix it in this way!"
        Rails.logger.warn message
      end
    end

    # Define a component class in this class' component registry
    def component(name, options = {}, &block)
      # Build the component - either within another component's registry, or at the root level
      context = if respond_to?(:create_component)
        options[:parent_component] = self
      else
        Doodads::Components
      end
      component = context.create_component(name, options)

      # Evaluate additional DSL configuration stuff inside of the component we're creating
      component.instance_exec(&block) if block_given?

      # Finally, named methods to just find a component by that name and render it to the helper module
      class_eval <<-EOC, __FILE__, __LINE__ + 1
  def #{name}(*args, &block)
    render_doodad(:#{name}, *args, &block)
  end#{if component # .list?
         %{

  def #{name}_of(items, *args, &block)
    render_doodad_list(:#{name}, items, *args, &block)
  end
  }
       end}
      EOC

      component
    end

    # Define a flag that can be used when rendering a component
    def flag(*args)
      options = args.extract_options!
      options = options.with_indifferent_access
      name = args.shift
      value = args.shift || name
      options[:value] ||= value
      component_flags[name] = options
    end

    # Define multiple flags that can be used when rendering a component
    def flags(flags, options = {})
      flags.each do |name, flag|
        flag(name, flag || name, options)
      end
    end
  end
end
