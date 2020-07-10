# frozen_string_literal: true

module Doodads
  class Component
    class Wrapper
      attr_reader :class_name, :options, :tagname

      def initialize(tagname, options = {})
        @tagname = tagname
        @class_name = options.delete(:class)
        @options = options
      end
    end
  end
end
