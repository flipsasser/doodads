# frozen_string_literal: true

lib = File.expand_path(".", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "active_support/all"
require "ostruct"
require "doodads/errors"
require "doodads/registry"

module Doodads
  extend Doodads::Registry

  URL_TEST = /^https?:/.freeze

  autoload(:DSL, "doodads/dsl")

  def self.config
    @config ||= Config.new(
      active_modifier: "active",
      link_class: "link",
      link_modifier: "has-link",
      strategy: :maintainable_css,
    )

    yield @config if block_given?

    @config
  end

  private

  class Config < OpenStruct
  end
end
