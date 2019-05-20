require "doodads/css_strategies"
require "doodads/registry"

module Doodads
  class Component
    include Doodads::Registry

    attr_reader :hierarchy, :name, :parent

    def self.css_strategy(strategy)
      @css_strategies ||= {}.with_indifferent_access
      @css_strategies[strategy] ||= Doodads::CSSStrategies.get(strategy)
    end

    def initialize(name, options = {}, &block)
      @name = name
      @css_strategy = options[:css_strategy] || Doodads.config.css_strategy

      @parent = options[:parent]
      @class_name = css_strategy.class_name_for(options[:class_name] || name, parent: @parent)
      @link = !!options[:link]

      @hierarchy = []
      tagname = options[:tagname] || (@link ? :a : :div)
      add_container(tagname, options.except(:class, :class_name, :css_strategy, :link, :parent, :tagname))

      instance_eval(&block) if block_given?
    end

    def add_container(tagname, options = {})
      container_class_name = options.delete(:class_name) || options.delete(:class)

      if container_class_name.present?
        options[:class_name] = container_class_name.match?(/^#{class_name}/) ? container_class_name : "#{class_name}-#{container_class_name}"
      end

      @hierarchy.push(Doodads::Container.new(tagname, options))
    end

    def add_modifier(name, default = false)
      @modifiers ||= {}.with_indifferent_access
      @modifiers[name] = default
    end

    def class_name(options = {})
      return @class_name unless @modifiers.present?

      class_names = [@class_name]
      options.each do |option, value|
        if @modifiers.key?(option)
          class_names.push(css_strategy.modifier_name_for(@class_name, modifier: @modifiers[option] == true ? option : @modifiers[option]))
        end
      end

      class_names.join(" ")
    end

    def child_class_name(*context)
      css_strategy.child_name_for(*context, self)
    end

    def link?
      @link
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
