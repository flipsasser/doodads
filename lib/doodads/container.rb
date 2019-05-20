module Doodads
  class Container
    attr_reader :options, :tagname

    def initialize(tagname, options = {})
      @tagname = tagname
      @options = options
    end
  end
end
