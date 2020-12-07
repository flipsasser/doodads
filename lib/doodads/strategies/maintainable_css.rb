# frozen_string_literal: true

require "doodads/strategies/base"

module Doodads
  module Strategies
    class MaintainableCSS < Base
      SEPARATOR = "-"
      FLAG_SEPARATOR = "--"

      # Returns a class name for a component chain, e.g. [`nav`, `list`, `item`] becomes "nav-list-item"
      def child_name_for(*chain)
        class_names = chain.compact.inject([]) { |class_names, child| class_names + [clean(object_to_class_name(child))] }
        class_names.join(SEPARATOR)
      end

      def class_name_for(name, parent: nil)
        class_name = clean(name)
        return class_name unless parent&.respond_to?(:class_name)

        # Determine if we have a singular component nested in a plural wrapper,
        # e.g. ".menu > .menu-items > .menu-item" Per the Maintainable CSS handbook, rather than
        # "menu-items-item", this should be "menu-item"
        singular = class_name.singularize
        plural = /#{class_name.pluralize}$/
        if class_name == singular && parent.class_name.match?(plural)
          return clean(parent.class_name.sub(plural, singular))
        end

        parent_class_name = clean(parent.class_name)
        "#{parent_class_name}#{SEPARATOR}#{name}"
      end

      def flag_name_for(name, flag:)
        "#{class_name_for(name)}#{FLAG_SEPARATOR}#{clean(flag)}"
      end

      private

      def clean(name)
        name.to_s.dasherize.parameterize
      end
    end
  end
end
