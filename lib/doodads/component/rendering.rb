# frozen_string_literal: true

module Doodads
  class Component
    module Rendering
      def find_component(name)
        self.class.registry[name] || parent&.find_component(name)
      end

      def normalize_args(*args, &block)
        options = args.extract_options!
        options = options.with_indifferent_access
        tagname = options.delete(:tagname) || self.tagname
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
        # button("text", "url") #=> text
        # button("url") { "text" } #=> "text"
        # button("title", "url") { "text" } #=> "titletext"
        content = (args.shift || "").html_safe
        if block_given?
          args = block.arity == 1 ? [self] : []
          content << view_context.capture { view_context.instance_exec(*args, &block) }
        end

        ## Step 3: Wrap the content in a link (if needed)
        has_link = link? && url.present?
        has_nested_link = has_link && link_nested?
        path_is_active = has_link && is_active_path?(url, options)
        if has_nested_link
          content = view_context.link_to(
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
        unrelated_context = unrelated_parent&.root
        option_sets.push({class: strategy.child_name_for(unrelated_context, self)}) if unrelated_context.present?

        # Merge the options together
        root_options = deep_merge_options({class: class_name}, *option_sets)

        ## Step 6: Strip out flags and combine them into the class name
        if flags.any? && root_options.any?
          class_names = [root_options[:class]]
          root_options.each do |option, value|
            if flags.key?(option)
              root_options.delete(option)
              class_names.push(strategy.flag_name_for(options[:class] || class_name, flag: flags[option])) if value
            end
          end

          root_options[:class] = class_names.reject(&:blank?).join(" ")
        end

        # Okay! Return the inferred HTML tagname, the normalized HTML string, the url if a link is
        # needed, and the merged options hash for rendering the root component
        [
          has_link && !has_nested_link ? :a : tagname,
          content,
          has_nested_link ? nil : url,
          root_options,
        ]
      end

      # Used to normalize the arguments into clear content blocks, and then pass them to the render method
      def normalize_args_and_render(*args, &block)
        tagname, content, url, options = normalize_args(*args, &block)
        primary_content = render(tagname, content, url, options)

        # TODO: Someday, let's extract sibling component content and join that here using view_context.safe_join
        primary_content
      end

      def render(tagname, content, url = nil, options = {})
        # Wrap the content in the component's wrapper hierarchy (excepting the root wrapper)
        content = wrap_content(content)

        # Unset the current rendering leaf before returning
        # @current_component = previous_component

        if url.present?
          # Return a link if the component IS a link at its root
          view_context.link_to(content, url, options)
        else
          # Return a non-link wrapper wrapping the content
          view_context.content_tag(tagname, content, options)
        end

        # view_context.safe_join([primary_content, sub_components])
      end

      def root
        root = self
        root = root.parent while root&.parent.present?
        root
      end

      def unrelated_parent
        parent&.class == self.class.parent ? nil : parent
      end

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
          content = view_context.content_tag(wrapper.tagname, wrapper.options) { content }
        end

        content
      end

      def wrappers
        self.class.wrappers
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
        self.class.flags
      end
    end
  end
end
