# frozen_string_literal: true

module Doodads
  class Component
    module DSL
      def wrapper(tag, options = {}, &block)
        if @reset_wrappers
          wrappers.clear
          @reset_wrappers = false
        end

        options = options.with_indifferent_access

        wrapper_class_name = options.delete(:class)
        options[:class] = strategy.child_name_for(class_name, wrapper_class_name) if wrapper_class_name.present?

        wrappers.push(Wrapper.new(tag, options))

        instance_eval(&block) if block_given?
      end

      def wrappers
        @wrappers ||= []
      end
    end
  end
end
