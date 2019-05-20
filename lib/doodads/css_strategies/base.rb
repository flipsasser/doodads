module Doodads
  module CSSStrategies
    # Base CSS strategy: provides required methods that must be overridden by subclasses
    class Base
      def child_name_for(*chain)
        raise NotImplementedError.new("#{self.class}#child_name_for(*chain) is not implemented")
      end

      def class_name_for(name, parent: nil)
        raise NotImplementedError.new("#{self.class}#class_name_for(name, parent: nil) is not implemented")
      end

      def modifier_name_for(name, modifier:)
        raise NotImplementedError.new("#{self.class}#modifier_name_for(name, modifier:) is not implemented")
      end

    end
  end
end
