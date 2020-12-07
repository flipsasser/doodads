# frozen_string_literal: true

module Doodads
  class Component
    module Rendering
      attr_accessor :content, :options, :output_buffer, :parent_instance, :tag, :url

      def find_component(name)
        self.class.registry[name] || parent_component&.find_component(name)
      end

      def root_component
        self.class.root_component
      end

      def to_s
        render(@tag, @content, @url, @options)
      end

      private

      def build_link_options(is_active, options = {})
        if options.delete(:active) { is_active }
          return deep_merge_options(
            options,
            class: strategy.flag_name_for(options[:class] || class_name, flag: Doodads.config.active_flag),
          )
        end

        options
      end

      def flags
        self.class.component_flags
      end

      def normalize_args(*args, &block)
        options = args.extract_options!
        options = options.with_indifferent_access

        tag = options.delete(:tag) || self.class.tag
        self.parent_instance = options.delete(:parent_instance)
        # parent_instance&.register(self)

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
        # button("text", "url") #=> <span class="button-content">text</span>
        # button("url") { "text" } #=> <span class="button-content">text</span>
        # button("title", "url") { "block text" } #=> <span class="button-content">title</span>block text
        primary_content = args.shift
        secondary_content = nil

        if block_given?
          args = block.arity == 1 ? [self] : []
          original_buffer, @output_buffer = @output_buffer, ActionView::OutputBuffer.new
          result = view_context.capture { instance_exec(*args, &block).to_s }
          result = output_buffer&.to_s.presence || result
          @output_buffer = original_buffer

          if primary_content.nil?
            primary_content = result
          else
            secondary_content = result
          end
        end

        # Wrap the primary content, if needed
        # if primary_content.present? && secondary_content.present? && Doodads.config.primary_content_wrapper.present?
        #   primary_content = view_context.content_tag(
        #     Doodads.config.primary_content_wrapper,
        #     primary_content,
        #     class: strategy.child_name_for(self, Doodads.config.primary_content_class || "content"),
        #   )
        # end

        # Join the primary and secondary content
        content = view_context.safe_join([
          primary_content,
          secondary_content,
        ])

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
        # option_sets.push({class: strategy.child_name_for(unrelated_ancestor, self)}) if unrelated_ancestor.present?

        # Merge the options together
        root_options = deep_merge_options({class: class_name}, *option_sets)

        ## Step 6: Strip out flags and combine them into the class name
        if flags.any? && root_options.any?
          class_names = Array(root_options[:class])
          root_options.each do |option, value|
            if flags.key?(option)
              root_options.delete(option)
              class_names.push(strategy.flag_name_for(options[:class] || class_name, flag: flags[option][:value])) if value
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

      def render(tag, content, url = nil, options = {})
        # Wrap the content in the component's wrapper hierarchy (excepting the root wrapper)
        content = wrap_content(content)

        if url.present?
          # Return a link if the component IS a link at its root
          link_to(content, url, options)
        else
          # Return a non-link wrapper wrapping the content
          content_tag(tag, content, options)
        end
      end

      # def unrelated_ancestor
      #   return @unrelated_ancestor if defined? @unrelated_ancestor
      #   ancestor = parent_instance
      #   ancestor = ancestor.parent_instance while ancestor&.parent_instance.present? && ancestor.root_component == root_component
      #   @unrelated_ancestor = ancestor
      # end

      def wrap_content(content)
        # Exclude the root wrapper
        sub_wrappers = wrappers[1..-1]

        # Iterate through the non-root wrappers and continue moving the content into them, e.g.
        # given # `component(:nav) { wrapper(:ul) { wrapper(:li) } } }`, this would result in the
        # remaining hierarchy of :ul > :li would be applied in reverse order, such that
        # <%= nav("Test Text") %> would result first in <li>Test Text</li>, and then
        # <ul><li>Test Text</li></ul>. Because the root wrapper is applied differently, later, and
        # based on the presence of a URL, we will wrap it specially, further down the rendering
        # chain.
        while sub_wrappers.any?
          wrapper = sub_wrappers.pop
          content = content_tag(wrapper.tag, content, wrapper.options)
        end

        content
      end

      def wrappers
        self.class.wrappers
      end
    end
  end
end
