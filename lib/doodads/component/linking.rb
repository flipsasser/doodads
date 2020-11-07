# frozen_string_literal: true

module Doodads
  class Component
    module Linking
      OPTIONAL_LINK = :optional
      NESTED_LINK = :nested

      def self.included(base)
        base.extend ClassMethods
      end

      def link?
        self.class.link?
      end

      def link_nested?
        self.class.link_nested?
      end

      def link_required?
        self.class.link_required?
      end

      module ClassMethods
        def link?
          link.present?
        end

        def link_nested?
          link_option?(NESTED_LINK)
        end

        def link_option?(option)
          return false unless link.is_a?(Array)
          link.include? option
        end

        def link_optional?
          link_option?(OPTIONAL_LINK)
        end

        def link_required?
          link? && !link_optional?
        end
      end
    end
  end
end
