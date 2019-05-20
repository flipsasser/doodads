module Doodads
  module Registry
    def registry
      @component_registry ||= {}.with_indifferent_access
    end
  end
end
