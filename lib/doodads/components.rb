# frozen_string_literal: true

require "doodads/component/registry"

# This module is used to keep root-level componentry in its own clean namespace
module Doodads
  module Components
    extend Doodads::Component::Registry
  end
end
