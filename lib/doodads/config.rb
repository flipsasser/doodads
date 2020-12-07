# frozen_string_literal: true

require "ostruct"

module Doodads
  class Config < OpenStruct
  end

  def self.config
    @config ||= Config.new(
      active_flag: "active",
      link_class: "link",
      link_flag: "has-link",
      primary_content_class: "content",
      primary_content_wrapper: :span,
      strategy: :maintainable_css,
      suppress_include_dsl_warning: false,
    )

    yield @config if block_given?

    @config
  end
end
