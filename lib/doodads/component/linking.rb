# frozen_string_literal: true

module Doodads
  class Component
    module Linking
      def self.included(base)
        base.extend ClassMethods
      end

      def link?
        self.class.link?
      end

      def link_nested?
        self.class.link_nested?
      end

      def link_optional?
        self.class.link_optional?
      end

      def link_required?
        self.class.link_required?
      end

      module ClassMethods
        def link?
          link.present?
        end

        def link_nested?
          link == :nested
        end

        def link_optional?
          !link? || link_optional.present? || link == :optional
        end

        def link_required?
          link? && !link_optional?
        end
      end
    end
  end
end
