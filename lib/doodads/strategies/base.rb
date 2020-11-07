# frozen_string_literal: true

module Doodads
  module Strategies
    # Base CSS strategy: provides required methods that must be overridden by subclasses
    class Base
      def child_name_for(*chain)
        chain.map { |link| object_to_class_name(link) }.join(" ")
      end

      def class_name_for(name, parent: nil)
        object_to_class_name name
      end

      def flag_name_for(name, flag:)
        object_to_class_name flag
      end

      private

      def object_to_class_name(object)
        if object.respond_to? :class_name
          object.class_name
        elsif object.is_a? Hash
          object[:class] || object["class"]
        else
          object.to_s
        end
      end
    end
  end
end
