# frozen_string_literal: true

require "doodads/component/active_path"
require "doodads/component/class_names"
require "doodads/component/configuration"
require "doodads/component/wrapper"
require "doodads/component/linking"
require "doodads/component/merge_options"
require "doodads/component/rendering"
require "doodads/component/registry"
require "doodads/strategies"

module Doodads
  class Component
    extend Doodads::Component::Configuration
    extend Doodads::Component::Registry
    include Doodads::Component::ActivePath
    include Doodads::Component::ClassNames
    include Doodads::Component::Linking
    include Doodads::Component::MergeOptions
    include Doodads::Component::Rendering

    attr_reader :parent, :view_context

    def initialize(view_context, parent: nil)
      @view_context = view_context
      @parent = parent
    end
  end
end
