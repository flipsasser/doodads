# frozen_string_literal: true

module Doodads
  class Component
    module DSL
      def flag(name, value = name, global: false, type: :class_name)
        flags[name] = {
          type: type,
          value: value,
        }
      end

      def use_flags(name)
        flags = Doodads::Flags[name]
        raise Doodads::Errors::FlagSetMissing.new(name) if flags.blank?

        flags.each do |flag, value|
          flag(flag, value)
        end
      end

      def wrapper(tagname, options = {}, &block)
        @_current_component.add_wrapper(tagname, options)
        instance_eval(&block) if block_given?
      end
    end
  end
end
