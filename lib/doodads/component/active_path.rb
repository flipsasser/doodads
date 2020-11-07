# frozen_string_literal: true

module Doodads
  class Component
    module ActivePath
      URL_TEST = /^https?:/.freeze

      def is_active_path?(path, options = {})
        exact = options.delete(:exact) { path == "/" }
        return options[:active] if options.key?(:active)
        return false if path.blank?

        @uri ||= URI.parse(request.url)
        path = url_for(path) unless path.respond_to?(:match?)
        path = URI.parse(path).path if path.match?(URL_TEST)
        exact ? path == @uri.path : @uri.path.match(/^#{path}/)
      end
    end
  end
end
