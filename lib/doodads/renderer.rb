# TODO: Support detection of sub-components and make them adjacent to container
# content, rather than within it. e.g.
#
# component :whatever { container :div; component :edit, link: true }
#
# should allow us to do something like
#
# <%= whatever("Title goes here") { edit("Edit Title", edit_title_path) } %>
#
# which should produce:
#
# <div class="whatever"><div>Title goes here</div><a href="/titles/1/edit">Edit Title</a></div>
#
# Currently the above produces something slightly more intuitive but less
# useful:
#
# <div class="whatever"><div>Title goes here <a href="/titles/1/edit">Edit Title</a></div></div>
#
# Ideally we'd like to support hierarchy derived from where the subcomponent
# was defined, e.g. in the container or outside of it.
require "doodads/merge_options"

module Doodads
  module Renderer
    include Doodads::MergeOptions

    def options_for_component(component, *option_sets)
      additional_options = deep_merge_options(*option_sets)
      default_options = {class: component.class_name(additional_options)}
      deep_merge_options(default_options, additional_options)
    end

    def component_path_is_active?(path, options = {})
      exact = options.delete(:exact)
      return options[Doodads.config.active_modifier] if options.key?(Doodads.config.active_modifier)
      return false unless path.present?

      @uri ||= URI.parse(request.url)
      path = URI.parse(path).path if path.match?(Doodads::URL_TEST)
      exact ? path == @uri.path : @uri.path.match(/^#{path}/)
    end

    def render_component(component, *args, &block)
      # Mark this as the current leaf in our rendering tree
      previous_component = @current_component
      @current_component = component

      # Capture the sub-component contents
      options = args.extract_options!
      options = options.with_indifferent_access
      url = if component.link?
        if args.length >= 2
          # If we received content and a url, pull the URL from the second
          # argument
          args.delete_at(1)
        elsif block_given?
          # We have 0-1 arguments and a content block - so pull the URL from
          # the first argument
          args.shift
        end
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
      has_link = component.link? && url.present?
      has_nested_link = has_link && component.link_nested?
      path_is_active = has_link && component_path_is_active?(url, options)
      if has_nested_link
        link_options = component.link_options(path_is_active, options.merge(class: component.link_class_name))
        content = link_to(url, link_options) { content }
      end

      # Combine the remaining options and context into a set of options for the root container
      tagname = options.delete(:tagname) { root_container.tagname }
      context_root = previous_component&.root
      nested_component_options = context_root.present? && component.root != context_root ? {class: context_root.child_class_name(component)} : {}
      root_options = options_for_component(
        component,
        options, # User supplied arguments
        root_container.options, # The root container of the component hierarchy's options
        nested_component_options, # Options inherited from a root component outside of this component's hierarchy
        has_nested_link ? { has_link: true } : {} # Options based on link nesting
      )

      # Unset the current rendering leaf before returning
      @current_component = previous_component

      if component.link? && url.present? && !component.link_nested?
        # Return a link if the component IS a link at its root
        link_to(url, component.link_options(path_is_active, root_options)) { content }
      else
        # Return a non-link container wrapping the content
        content_tag(tagname, root_options) { content }
      end
    end

    def render_component_container(component, container, content = nil)
      content_tag(container.tagname, deep_merge_options(container.options)) { content || "" }
    end
  end
end
