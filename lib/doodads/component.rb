require "doodads/container"
require "doodads/css_strategies"
require "doodads/registry"

module Doodads
  class Component
    include Doodads::Registry

    attr_reader :hierarchy, :link_class_name, :name, :parent

    def self.css_strategy(strategy)
      @css_strategies ||= {}.with_indifferent_access
      @css_strategies[strategy] ||= Doodads::CSSStrategies.get(strategy)
    end

    def initialize(name, options = {}, &block)
      @name = name
      @css_strategy = options.delete(:css_strategy) || Doodads.config.css_strategy

      @parent = options.delete(:parent)
      @class_name = css_strategy.class_name_for(options[:class] || name, parent: @parent)

      # Link options
      @link = options.delete(:link)
      @link_optional = options.delete(:link_optional)
      @link_class_name = child_class_name(options.delete(:link_class) || Doodads.config.link_class) if @link.present?
      add_modifier(:has_link, options.delete(:link_modifier) || Doodads.config.link_modifier) if @link == :nested

      # Container options
      @hierarchy = []
      tagname = options.delete(:tagname) || :div
      add_container(tagname, options)

      instance_eval(&block) if block_given?
    end

    def add_container(tagname, options = {})
      container_class_name = options.delete(:class)

      if container_class_name.present?
        options[:class] = child_class_name(container_class_name)
      end

      @hierarchy.push(Doodads::Container.new(tagname, options))
    end

    def add_modifier(name, value = name)
      @modifiers ||= {}.with_indifferent_access
      @modifiers[name] = value
    end

    def class_name(options = {})
      return @class_name unless @modifiers.present?

      # Step through options and pull out any modifiers that we'll need to add
      # to our base class name
      class_names = [@class_name]
      options.each do |option, value|
        if @modifiers.key?(option)
          options.delete(option)
          class_names.push(css_strategy.modifier_name_for(@class_name, modifier: @modifiers[option])) if value
        end
      end

      class_names.join(" ")
    end

    def child_class_name(*children)
      css_strategy.child_name_for(self, *children)
    end

    def find_component(name)
      component = registry[name]
      component = parent.find_component(name) if component.nil? && parent.present?
      component
    end

    def link?
      !!@link
    end

    def link_nested?
      link? && @link == :nested
    end

    def link_optional?
      !link? || @link_optional || @link == :optional
    end

    def root
      root = self
      root = root.parent while root&.parent.present?
      root
    end

    private

    def css_strategy
      self.class.css_strategy(@css_strategy)
    end
  end
end
