# frozen_string_literal: true

module Doodads
  class Component
    class Wrapper
      attr_reader :class_name, :options, :tag

      def initialize(tag, options = {})
        @tag = tag
        @class_name = options.delete(:class)
        @options = options
      end
    end
  end
end
