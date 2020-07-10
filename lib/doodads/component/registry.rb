# frozen_string_literal: true

module Doodads
  class Component
    module Registry
      def create_component(name, options = {})
        class_name = name.to_s.classify
        const_get(class_name).tap do |component_class|
          component_class.configure(name, options)
        end
      rescue NameError
        Doodads::Component.create(name, options).tap do |component_class|
          const_set(class_name, component_class)
          register(name, component_class)
        end
      end

      def register(name, component_class)
        registry[name] = component_class
      end

      def registry
        @component_registry ||= {}.with_indifferent_access
      end
    end
  end
end
