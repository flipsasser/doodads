# frozen_string_literal: true

module Doodads
  module Errors
    class ComponentMissingError < StandardError
      def initialize(name, context)
        context_chain = []
        parent = context
        while parent.present?
          context_chain.unshift(parent.name)
          parent = parent.parent
        end

        message = %(Could not find component "#{name}")
        message = %(#{message}, even as a subcomponent of "#{context_chain.join(" > ")}") if context_chain.any?
        message = "#{message}. Available root components are #{component_list(Doodads::Component)}"
        message = "#{message}, and available context-specific components are #{component_list(context)}" if context.present?
        message = "#{message}."

        super message
      end

      private

      def component_list(root)
        root.registry.keys.map { |name| name.to_s.inspect }.to_sentence
      end
    end
  end
end
