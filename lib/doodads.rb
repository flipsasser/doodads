# frozen_string_literal: true

lib = File.dirname(File.expand_path(".", __FILE__))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "active_support/all"

module Doodads
end

require "doodads/component"
require "doodads/components"
require "doodads/config"
require "doodads/dsl"
require "doodads/errors"
require "doodads/flags"
require "doodads/strategies"
