# frozen_string_literal: true

require "doodads/strategies/base"

module Doodads
  module Strategies
    class MaintainableCSS < Base
      SEPARATOR = "-"
      MODIFIER_SEPARATOR = "--"

      def child_name_for(*chain)
        class_names = chain.inject([]) { |class_names, child| class_names + [clean(object_to_class_name(child))] }
        class_names.join(SEPARATOR)
      end

      def class_name_for(name, parent: nil)
        class_name = clean(name)
        return class_name if parent.blank?

        # Determine if we have a singular component nested in a plural container, e.g. ".menu > .menu-items > .menu-item"
        # Per the Maintainable CSS handbook, rather than "menu-items-item", this should be "menu-item"
        singular = class_name.singularize
        plural = /#{class_name.pluralize}$/
        if class_name == singular && parent.class_name.match?(plural)
          return clean(parent.class_name.sub(plural, singular))
        end

        parent_class_name = clean(parent.class_name)
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
