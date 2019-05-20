module Doodads
  class Container
    attr_reader :options, :tagname

    def initialize(tagname, options = {})
      @tagname = tagname
      @options = options
    end

    def class_name
      @options[:class]
    end
  end
end
