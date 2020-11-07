# frozen_string_literal: true

module Doodads
  class Component
    module Rendering
      def find_component(name)
        self.class.registry[name] || parent&.find_component(name)
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

      def render(tag, content, url = nil, options = {})
        # TODO: Someday, let's extract sibling component content and join that here using safe_join
        # Wrap the content in the component's wrapper hierarchy (excepting the root wrapper)
        content = wrap_content(content)

        # TODO: Extract primary and secondary content
        # safe_join([primary_content, sub_components])

        if url.present?
          # Return a link if the component IS a link at its root
          link_to(content, url, options)
        else
          # Return a non-link wrapper wrapping the content
          content_tag(tag, content, options)
        end
      end

      def root
        root = self
        root = root.parent while root&.parent.present?
        root
      end

      # def unrelated_parent
      #   parent&.class == self.class.parent ? nil : parent
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
