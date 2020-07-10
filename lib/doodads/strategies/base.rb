# frozen_string_literal: true

module Doodads
  module Strategies
    # Base CSS strategy: provides required methods that must be overridden by subclasses
    class Base
      def child_name_for(*chain)
        raise NotImplementedError.new("#{self.class}#child_name_for(*chain) is not implemented")
      end

      def class_name_for(name, parent: nil)
        raise NotImplementedError.new("#{self.class}#class_name_for(name, parent: nil) is not implemented")
      end

      def flag_name_for(name, flag:)
        raise NotImplementedError.new("#{self.class}#flag_name_for(name, flag:) is not implemented")
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
