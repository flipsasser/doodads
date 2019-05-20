module Doodads
  module Renderer
    def deep_merge_options(*option_sets)
      options = {}
      option_sets.each do |option_set|
        # Manually redirect class_name into class
        merge_option_values(:class, option_set.delete(:class_name), options) if option_set.key?(:class_name)

        # Merge all other options
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
      default_options = {class_name: component.class_name(additional_options)}
      deep_merge_options(default_options, additional_options)
    end

    def render_component(component, *args, &block)
      # Mark this as the current leaf in our rendering tree
      previous_component = @current_component
      @current_component = component

      # Capture the sub-component contents
      options = args.extract_options!
      url = if component.link?
        # If we received content and a url, pull the URL from the middle -
        # otherwise we didn't receive content, so grab it from the front of the
        # args array
        args.length >= 2 ? args.delete_at(1) : args.shift
      else
        nil
      end
      content = args.shift

      content ||= "".html_safe
      content << capture(&block) if block_given?

      # Wrap the content in the component hierarchy, applying additional
      # options
      containers = component.hierarchy.reverse
      root_container = containers.pop
      content = render_component_container(component, containers.pop, content) while containers.any?
      context_root = previous_component&.root
      nested_component_options = context_root.present? && component.root != context_root ? {class: component.child_class_name(context_root)} : {}

      # Unset the current rendering leaf
      @current_component = previous_component

      root_options = options_for_component(component, options, root_container.options, nested_component_options)
      if component.link?
        link_to(url, root_options) { content }
      else
        content_tag(root_container.tagname, root_options) { content }
      end
    end

    def render_component_container(component, container, content = nil)
      content_tag(container.tagname, deep_merge_options(container.options)) { content || "" }
    end
  end
end
