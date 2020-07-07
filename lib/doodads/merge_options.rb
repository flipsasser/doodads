# frozen_string_literal: true

module Doodads
  module MergeOptions
    def deep_merge_options(*option_sets)
      options = {}.with_indifferent_access
      option_sets.each do |option_set|
        # Merge the option sets together
        option_set.each do |option, value|
          merge_option_values(option, value, options)
        end
      end

      options
    end

    def merge_option_values(option, value, options = {})
      case options[option]
      when String
      when Symbol
        # Strings and symbols are combined into strings
        options[option] = [options[option], value].join(" ")
      when Array
        options[option].push(*value)
      when Hash
        options[option].deep_merge!(value)
      else
        options[option] = value
      end
    end
  end
end
