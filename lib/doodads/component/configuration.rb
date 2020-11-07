# frozen_string_literal: true

module Doodads
  class Component
    # This module holds all the configuration metadata for Component classes. These methods are
    # used by the DSL and can be used in subclass configurations, e.g.
    # class ButtonComponent < Doodads::Component
    #   strategy :bootstrap
    # end
    module Configuration
      def self.extended(base)
        base.class_eval do
          add_option :as, default: -> { name.split("::").last.gsub(/Component$/, "") } do |new_as|
            new_as.to_s.underscore.to_sym
          end
          alias_method :name, :as

          # Add some basic options
          add_option :class_name, default: -> { as } do |new_class_name|
            strategy.class_name_for(new_class_name.to_s, parent: parent)
          end
          add_option :default_options, default: {}
          add_option :parent
          add_option :tag, default: :div

          # Add link options - they're more complex
          add_option :link, default: false do |new_link|
            if new_link.is_a?(Array) || new_link.is_a?(String) || new_link.is_a?(Symbol)
              new_link = Array(new_link).map(&:to_sym)
              flag(:has_link) if new_link.include?(:nested)
            end
            new_link
          end

          add_option :link_class, default: -> { Doodads.config.link_class }
          add_option :link_flag, default: -> { Doodads.config.link_flag }

          # Strategy has to massage received values a little bit
          add_option(:strategy, default: -> { Doodads::Strategies.get(Doodads.config.strategy) }) do |new_strategy|
            if new_strategy.is_a?(Class)
              new_strategy.new
            elsif new_strategy.is_a?(Doodads::Strategies::Base)
              new_strategy
            else
              Doodads::Strategies.get(new_strategy)
            end
          end
        end
      end

      def add_option(name, default: nil, &setter)
        variable = "@#{name}".to_sym

        # Add a class method that accepts a single value as an override, or returns the value if called without any args
        define_singleton_method(name) do |*args|
          if args.none?
            ## Called as an accessor
            # Return the variable if it's set
            return instance_variable_get(variable) if instance_variables.include?(variable)

            # Set the default value, including using any custom setter we received
            default_value = default.respond_to?(:call) ? instance_exec(&default) : default
            default_value = instance_exec(default_value, &setter) if block_given?
            return instance_variable_set(variable, default_value)
          end

          # Called as a setter - throw an error if there are too many arguments
          raise ArgumentError.new("wrong number of arguments (given #{args.length}, expected 0..1)") if args.many?

          value = args.first
          value = default.respond_to?(:call) ? instance_exec(&default) : default if value.nil?
          value = instance_exec(value, &setter) if block_given?
          instance_variable_set(variable, value)
        end

        # Add an instance method that simply provides a reader for the class method
        unless instance_methods.include?(name)
          class_eval <<-EOC, __FILE__, __LINE__ + 1
          def #{name}
            self.class.#{name}
          end
          EOC
        end
      end

      def configure(name, options = {})
        name = name.to_s.downcase.to_sym
        options = options.with_indifferent_access

        ## Configure some defaults from the options
        @reset_wrappers = true # We want to reset the wrapper hierarchy in case a block will be adding wrappers

        # Some basic configuration stuff
        as name
        parent options.delete(:parent)
        class_name options.delete(:class)
        strategy options.delete(:strategy)
        tag options.delete(:tag) { VALID_TAGS.include?(name) ? name : :div }

        # Links
        link options.delete(:link)
        link_class options.delete(:link_class)
        link_flag options.delete(:link_flag)

        # Whatever else was left goes into default options when we render an instance
        default_options options

        # Finally, add a default wrapper for the root component
        wrapper(tag, options)
      end

      def create(name, options = {})
        Class.new(Doodads::Component).tap do |component_class|
          component_class.configure(name, options)
        end
      end

      # Auto-register subclasses in the registry
      def inherited(subclass)
        # :nocov:
        unless subclass.module_parents.include?(Doodads::Components)
          # Directly subclassed e.g. in `app/components` or `app/doodads`; go ahead and add to the registry directly
          TracePoint.trace(:end) do |trace|
            if trace.self == subclass
              Doodads::Components.register(subclass.as, subclass)
              trace.disable
            end
          end
        end
        # :nocov:
      end

      VALID_TAGS = %i[
        abbr address area article aside audio bdi bdo blockquote button canvas caption cite code
        col colgroup data datalist dd del details dfn dialog dl dt embed fieldset figcaption
        figure footer form h1 h2 h3 h4 h5 h6 header hgroup hr iframe ins kbd label legend main
        map mark menu meter nav noscript object optgroup option output p param picture pre
        progress rb rp rt rtc ruby samp section select slot small source sub summary sup table
        tbody td template textarea tfoot th thead time tr track var video wbr
      ].freeze
    end
  end
end
