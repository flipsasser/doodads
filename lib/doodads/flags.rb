# frozen_string_literal: true

module Doodads
  module Flags
    def component_flags
      @component_flags ||= {}.with_indifferent_access
    end
  end
end
