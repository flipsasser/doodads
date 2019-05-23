require "doodads/css_strategies/base"

module Doodads
  module CSSStrategies
    class MaintainableCSS < Base
      SEPARATOR = "-".freeze
      MODIFIER_SEPARATOR = "--".freeze

      def child_name_for(*chain)
        class_names = chain.inject([]) {|class_names, child| class_names + [clean(object_to_class_name(child))] }
        class_names.join(SEPARATOR)
      end

      def class_name_for(name, parent: nil)
        class_name = clean(name)
        return class_name unless parent.present?

        "#{parent.class_name}#{SEPARATOR}#{name}"
      end

      def modifier_name_for(name, modifier:)
        "#{class_name_for(name)}#{MODIFIER_SEPARATOR}#{clean(modifier)}"
      end

      private

      def clean(name)
        name.to_s.dasherize.parameterize
      end
    end
  end
end
