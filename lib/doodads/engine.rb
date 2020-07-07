# frozen_string_literal: true

module Doodads
  class Engine < ::Rails::Engine
    isolate_namespace Doodads
  end
end

require "doodads/railtie" if defined? Rails
