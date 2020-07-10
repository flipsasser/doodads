# frozen_string_literal: true

module Doodads
  module Errors
    class URLRequiredError < StandardError
      def initialize(method)
        message = "#{method} must be provided a URL."
        details = %{ You can provide it as the second argument after a content string (e.g. `#{method}("Hello!", url)`) or inside of a block (e.g. `#{method}(url) { "Hello!" }`). It works just the same as `link_to`!}
        super "#{message} #{details}"
      end
    end
  end
end
