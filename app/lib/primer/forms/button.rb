# frozen_string_literal: true

module Primer
  module Forms
    # :nodoc:
    class Button < BaseComponent
      # :nodoc:
      module ButtonAttributeGenerator
        extend ActionView::Helpers::FormTagHelper

        class << self
          alias submit_tag_attributes submit_tag
          alias button_tag_attributes button_tag

          private

          # FormTagHelper#submit_tag ultimately calls the #tag method. We return the options hash here instead
          # of returning a string so it can be merged into the hash of options we pass to the Primer::ButtonComponent.
          def tag(_name, options)
            options
          end

          # FormTagHelper#button_tag ultimately calls the #content_tag method. We return the options hash here instead
          # of returning a string so it can be merged into the hash of options we pass to the Primer::ButtonComponent.
          def content_tag(_name, _content, options)
            options
          end
        end
      end

      delegate :builder, :form, to: :@input

      def initialize(input:, type: :button)
        @input = input
        @type = type

        @input.add_input_classes("FormField-input flex-self-start")
        @input.merge_input_arguments!(tag_attributes.deep_symbolize_keys)

        # rails uses a string for this, but PVC wants a symbol
        @input.merge_input_arguments!(type: type.to_sym)
      end

      def input_arguments
        @input_arguments ||= @input.input_arguments.deep_dup.tap do |args|
          # rails uses :class but PVC wants :classes
          args[:classes] = class_names(
            args[:classes],
            args.delete(:class)
          )
        end
      end

      private

      def tag_attributes
        attrs = { name: @input.name }
        attrs[:value] = @input.value if @input.value

        case @type
        when :submit
          ButtonAttributeGenerator.submit_tag_attributes(@input.label, **attrs)
        else
          ButtonAttributeGenerator.button_tag_attributes(@input.label, **attrs)
        end
      end
    end
  end
end
