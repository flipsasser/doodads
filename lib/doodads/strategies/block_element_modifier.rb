# frozen_string_literal: true

module Doodads
  module Strategies
    class BlockElementModifier < Base
      BLOCK_SEPARATOR = "__"
      MODIFIER_SEPARATOR = "--"

      def block_name_for(element, block: nil)
        class_name = clean(element)
        return class_name unless block&.respond_to?(:class_name)

        block_class_name = clean(block.class_name)
        "#{block_class_name}#{BLOCK_SEPARATOR}#{class_name}"
      end

      # Returns a class name for a component chain, e.g. [`nav`, `list`, `item`] becomes "nav-list-item"
      def child_name_for(*chain)
        class_names = chain.compact.inject([]) { |class_names, child| class_names + [clean(object_to_class_name(child))] }
        class_names.join(SEPARATOR)
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
