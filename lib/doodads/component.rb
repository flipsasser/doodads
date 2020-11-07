# frozen_string_literal: true

require "doodads/component/active_path"
require "doodads/component/configuration"
require "doodads/component/dsl"
require "doodads/component/wrapper"
require "doodads/component/linking"
require "doodads/component/merge_options"
require "doodads/component/rendering"
require "doodads/component/registry"
require "doodads/helper"
require "doodads/strategies"

module Doodads
  class Component
    extend Doodads::Component::Configuration
    extend Doodads::Component::DSL
    extend Doodads::Component::Registry # Each component has its own registry of sub-components
    include Doodads::Component::ActivePath
    include Doodads::Component::Linking
    include Doodads::Component::MergeOptions
    include Doodads::Component::Rendering
    include Doodads::Helper

    attr_reader :content, :options, :tag, :url, :view_context

    def initialize(view_context, *args, &block)
      @view_context = view_context
      normalize_args(*args, &block)
    end

    private

    def method_missing(method, *args, &block) # rubocop:disable Style/MissingRespondToMissing
      if view_context.respond_to?(method)
        view_context.send(method, *args, &block)
      else
        super
      end
    end

    def normalize_args(*args, &block)
      options = args.extract_options!
      options = options.with_indifferent_access
      tag = options.delete(:tag) || self.class.tag
      option_sets = []
      option_sets.push(default_options) if default_options.any?
      option_sets.push(options) if options.any?

      root_wrapper = wrappers.first
      option_sets.unshift(root_wrapper.options) unless root_wrapper.options.empty?

      ## Step 1: Find the URL
      # button("text", "url") #=> url
      # button("url") { "text" } #=> url
      # button("text") #=> nil
      url = link? && (args.many? || block_given?) && args.pop
      raise Doodads::Errors::URLRequiredError.new(name) if url.blank? && link_required?

      ## Step 2: Find the contents
      # button("text", "url") #=> <span class="component-class-content">text</span>
      # button("url") { "text" } #=> <span class="component-class-content">text</span>
      # button("title", "url") { "block text" } #=> <span class="component-class-content">title</span>block text
      content = (args.shift || "")
      if block_given?
        args = block.arity == 1 ? [self] : []
        @output_buffer = ActionView::OutputBuffer.new # if is_a?(Doodads::Component)
        view_context.capture { instance_exec(*args, &block) }
        content = safe_join([
          content,
          @output_buffer,
        ])
        @output_buffer = nil
      end

      ## Step 3: Wrap the content in a link (if needed)
      has_link = link? && url.present?
      has_nested_link = has_link && link_nested?
      path_is_active = has_link && is_active_path?(url, options)
      if has_nested_link
        content = link_to(
          content,
          url,
          build_link_options(
            path_is_active,
            class: strategy.child_name_for(self, link_class),
          ),
        )
        option_sets.push({has_link: true})
      elsif has_link
        option_sets.push(build_link_options(path_is_active))
      end

      ## Step 4: Combine content with content derived from content flags (rather than class or attribute flags)
      # TODO

      ## Step 5: Combine all options for rendering. In order of precedence:
      # Add context-specific options
      # unrelated_context = unrelated_parent&.root
      # option_sets.push({class: strategy.child_name_for(unrelated_context, self)}) if unrelated_context.present?

      # Merge the options together
      root_options = deep_merge_options({class: class_name}, *option_sets)

      ## Step 6: Strip out flags and combine them into the class name
      if flags.any? && root_options.any?
        class_names = Array(root_options[:class])
        root_options.each do |option, value|
          if flags.key?(option)
            root_options.delete(option)
            class_names.push(strategy.flag_name_for(options[:class] || class_name, flag: flags[option])) if value
          end
        end

        root_options[:class] = class_names.reject(&:blank?).join(" ")
      end

      # Okay! Stash the inferred HTML tag, the normalized HTML string, the url if a link is
      # needed, and the merged options hash for rendering the root component. `to_s` will handle
      # the rest.
      @tag = has_link && !has_nested_link ? :a : tag
      @content = content
      @url = has_nested_link ? nil : url
      @options = root_options
    end
  end
end
