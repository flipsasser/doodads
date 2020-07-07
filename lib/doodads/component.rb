# frozen_string_literal: true

require "doodads/container"
require "doodads/strategies"
require "doodads/merge_options"
require "doodads/registry"

module Doodads
  class Component
    include Doodads::MergeOptions
    include Doodads::Registry

    attr_reader :hierarchy, :link_class_name, :modifiers, :name, :parent

    def self.strategy(strategy)
      @strategies ||= {}.with_indifferent_access
      @strategies[strategy] ||= Doodads::Strategies.get(strategy)
    end

    def initialize(name, options = {}, &block)
      @name = name
      @strategy = options.delete(:strategy) || Doodads.config.strategy

      @parent = options.delete(:parent)
      @class_name = strategy.class_name_for(options[:class] || name, parent: @parent)

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

    def child_class_name(*children)
      strategy.child_name_for(self, *children)
    end

    def class_name(options = {})
      return @class_name if @modifiers.blank?

      # Step through options and pull out any modifiers that we'll need to add
      # to our base class name
      class_names = [@class_name]
      options.each do |option, value|
        if @modifiers.key?(option)
          options.delete(option)
          class_names.push(strategy.modifier_name_for(@class_name, modifier: @modifiers[option])) if value
        end
      end

      class_names.join(" ")
    end

    def find_component(name)
      registry[name] || parent&.find_component(name)
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

    def link_options(is_active, options = {})
      return options if options.key?(Doodads.config.active_modifier)

      options = deep_merge_options(options, class: link_class_name)
      options = deep_merge_options(options, class: active_class_name_for(options[:class] || @class_name)) if is_active
      options
    end

    def root
      root = self
      root = root.parent while root&.parent.present?
      root
    end

    private

    def active_class_name_for(class_name = @class_name)
      strategy.modifier_name_for(class_name, modifier: Doodads.config.active_modifier)
    end

    def strategy
      self.class.strategy(@strategy)
    end
  end
end
