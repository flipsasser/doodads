require "doodads/css_strategies/base"

module Doodads
  module CSSStrategies
    class MaintainableCSS < Base
      def child_name_for(*chain)
        class_names = chain.inject([]) {|class_names, child| class_names + [child.class_name] }
        class_names.join("-")
      end

      def class_name_for(name, parent: nil)
        class_name = name.to_s.dasherize.parameterize
        return class_name unless parent.present?

        "#{parent.class_name}-#{name}"
      end

      def modifier_name_for(name, modifier:)
        "#{class_name_for(name)}--#{modifier}"
      end
    end
  end
end
