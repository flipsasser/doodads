module Doodads
  module Renderer
    def deep_merge_options(*option_sets)
      options = {}
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
        options[option] = [options[option], value].join(" ")
      when Array
        options[option].push(*value)
      when Hash
        options[option].deep_merge!(value)
      else
        options[option] = value
      end
    end

    def options_for_component(component, *option_sets)
      additional_options = deep_merge_options(*option_sets)
      default_options = {class: component.class_name(additional_options)}
      deep_merge_options(default_options, additional_options)
    end

    def render_component(component, *args, &block)
      # Mark this as the current leaf in our rendering tree
      previous_component = @current_component
      @current_component = component

      # Capture the sub-component contents
      options = args.extract_options!
      url = if component.link?
        if args.length >= 2
          # If we received content and a url, pull the URL from the second
          # argument
          args.delete_at(1)
        elsif block_given?
          # We have 0-1 arguments and a content block - so pull the URL from
          # the first argument
          args.shift
        else
          nil
        end
      else
        nil
      end

      raise "You must provide a URL argument for link components" if url.nil? && !component.link_optional?

      content = args.shift

      content ||= "".html_safe
      content << capture(&block) if block_given?

      # Wrap the content in the component hierarchy, applying additional
      # options
      containers = component.hierarchy.reverse
      root_container = containers.pop
      content = render_component_container(component, containers.pop, content) while containers.any?

      # Wrap the content in a link (if needed)
      content = link_to(url, class: component.child_class_name("link")) { content } if component.link_nested? && url.present?

      # Combine the remaining options and context into a set of options for the root container
      context_root = previous_component&.root
      nested_component_options = context_root.present? && component.root != context_root ? {class: component.child_class_name(context_root)} : {}
      root_options = options_for_component(component, options, root_container.options, nested_component_options)

      # Unset the current rendering leaf before returning
      @current_component = previous_component

      if component.link? && url.present? && !component.link_nested?
        # Return a link if the component IS a link at its root
        link_to(url, root_options) { content }
      else
        # Return a non-link container wrapping the content
        content_tag(root_container.tagname, root_options) { content }
      end
    end

    def render_component_container(component, container, content = nil)
      content_tag(container.tagname, deep_merge_options(container.options)) { content || "" }
    end
  end
end
