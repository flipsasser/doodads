# frozen_string_literal: true

require "doodads/errors"
require "doodads/helper"

module Doodads
  module DSL
    def self.included(base)
      message = "It looks like you mixed the Doodads::DSL into #{base} using `include`."
      message = "#{message} Use `extend` instead to generate a DSL for quickly defining Component classes without complex logic."
      message = "#{message} Please double-check the README to ensure you want to mix it in this way!"
      Rails.logger.warn message
    end

    def component(name, options = {}, &block)
      # Build the component
      component = (@_current_component || Doodads::Components).create_component(name, options.merge(parent: @_current_component))

      # Add a named method to just find a component by that name and render it to the helper module
      class_eval <<-EOC, __FILE__, __LINE__ + 1
  def #{name}(*args, &block)
    render_component_named(:#{name}, *args, &block)
  end
      EOC

      # Evaluate additional DSL configuration stuff inside of the component we're creating
      if block_given?
        previous_component = @_current_component
        @_current_component = component

        begin
          instance_exec(&block)
        ensure
          @_current_component = previous_component
        end
      end

      component
    end

    def flag(name, value = name)
      require_current_component!(:flag, name)
      @_current_component.flags[name] = value
    end

    def flag_set(name, options)
      require_no_current_component!(:flag_set, name, options)
      options = Hash[*options.map { |option| [option, option] }.flatten] if options.is_a?(Array)
      Doodads::Flags[name] = options.with_indifferent_access
    end

    def use_flags(name)
      require_current_component!(:use_flags, name)

      flags = Doodads::Flags[name]
      raise Doodads::Errors::FlagSetMissing.new(name) if flags.blank?

      flags.each do |flag, value|
        flag(flag, value)
      end
    end

    def wrapper(tagname, options = {}, &block)
      require_current_component!(:wrapper, tagname)
      @_current_component.add_wrapper(tagname, options)
      instance_eval(&block) if block_given?
    end

    private

    def require_current_component!(method, *args)
      raise Doodads::Errors::ComponentRequiredError.new(method, *args) if @_current_component.blank?
    end

    def require_no_current_component!(method, *args)
      raise Doodads::Errors::NoComponentRequiredError.new(method, *args) if @_current_component.present?
    end
  end
end
