require 'active_support'
require 'active_support/concern'

require 'parcels/fragments/css_fragment'

require 'sass'

module Parcels
  module Fortitude
    module Assets
      extend ActiveSupport::Concern

      module ClassMethods
        def inherited(new_class)
          super(new_class)

          if respond_to?(:caller_locations, true) && false
            locations = caller_locations(1, 1)
            filename = locations.first.absolute_path
            new_class._parcels_inherited_called_from(filename)
          else
            string = caller[0]
            if string =~ /^([^:]+):\d+/
              new_class._parcels_inherited_called_from($1)
            else
              raise "Parcels: #{new_class} inherited from #{self.name}, but caller string was unparseable: '#{string}'"
            end
          end
        end

        def _parcels_inherited_called_from(filename)
          @_parcels_class_definition_files ||= [ ]
          @_parcels_class_definition_files << filename
        end

        def _parcels_class_definition_files
          @_parcels_class_definition_files ||= [ ]
        end

        def _parcels_widget_outer_element_classes
          @_parcels_widget_outer_element_classes ||= begin
            out = [ ]
            out << _parcels_widget_outer_element_class if _parcels_wrapping_css_class_required?
            out += superclass._parcels_widget_outer_element_classes if superclass.respond_to?(:parcels_enabled?) && superclass.parcels_enabled?
            out
          end
        end

        def _parcels_css_fragments
          _parcels_alongside_css_fragments + _parcels_inline_css_fragments
        end

        def _parcels_widget_outer_element_class
          @_parcels_widget_outer_element_class ||= begin
            class_suffix = self.name.gsub('::', '__').underscore.gsub(/[^A-Za-z0-9_]/, '_')

            "parcels_class__#{class_suffix}"
          end
        end

        def _parcels_widget_class_css(parcels_environment, context)
          ::Parcels::Fragments::CssFragment.to_css(parcels_environment, context, _parcels_css_fragments)
        end

        def _parcels_widget_class_inline_css(parcels_environment, context)
          ::Parcels::Fragments::CssFragment.to_css(parcels_environment, context, _parcels_inline_css_fragments)
        end

        def _parcels_widget_class_alongside_css(parcels_environment, context)
          ::Parcels::Fragments::CssFragment.to_css(parcels_environment, context, _parcels_alongside_css_fragments)
        end

        def _parcels_wrapping_css_class_required?
          _parcels_css_fragments.detect { |f| f.wrapping_css_class_required? }
        end

        def _parcels_alongside_css_fragments
          options = { :prefix => _parcels_get_css_prefix }.merge(_parcels_css_options)
          _parcels_alongside_filenames.map do |filename|
            if File.exist?(filename)
              ::Parcels::Fragments::CssFragment.new(File.read(filename), self, filename, 1, options)
            end
          end.compact
        end

        def _parcels_alongside_filenames
          out = [ ]

          _parcels_class_definition_files.each do |filename|
            filename = $1 if filename =~ /^(.*)\.rb$/i
            out << "#{filename}.pcss"
          end

          out.select { |f| File.file?(f) }
        end

        def _parcels_add_wrapper_css_classes_to(attributes, wrapper_classes)
          out = attributes || { }
          key = out.key?('class') ? 'class' : :class
          out[key] = Array(out[key]) + wrapper_classes
          out
        end

        def _parcels_inline_css_fragments
          @_parcels_inline_css_fragments ||= [ ]
        end

        def css_options(options)
          raise ArgumentError, "You must pass a Hash to css_options, not: #{options.inspect}" unless options.kind_of?(Hash)
          options.assert_valid_keys(:engines)

          @_parcels_css_options = options
        end

        def _parcels_css_options
          out = @_parcels_css_options
          out ||= superclass._parcels_css_options if superclass.respond_to?(:_parcels_css_options)
          out || { }
        end

        def css(*css_strings)
          unless parcels_enabled?
            klass = self
            superclasses = all_fortitude_superclasses

            raise %{Before using this Parcels method, you must first enable Parcels on this class. Simply
call 'enable_parcels!', a class method, on the base widget class you want to enable -- typically, this
is your base Fortitude widget class.

This class is #{klass.name};
you may want to enable Parcels on any of its Fortitude superclasses, which are:
#{superclasses.map(&:name).join("\n")}}
          end

          options = { :prefix => _parcels_get_css_prefix }
          options.merge!(css_strings.extract_options!)

          caller_line = caller[0]
          if caller_line =~ /^(.*)\s*:\s*(\d+)\s*:\s*in\s+/i
            caller_file = $1
            caller_line = Integer($2)
          else
            caller_file = caller_line
            caller_line = nil
          end

          @_parcels_inline_css_fragments ||= [ ]
          @_parcels_inline_css_fragments.delete_if do |fragment|
            fragment.file == caller_file && fragment.line >= caller_line
          end
          @_parcels_inline_css_fragments += css_strings.map do |css_string|
            ::Parcels::Fragments::CssFragment.new(css_string, self, caller_file, caller_line, _parcels_css_options.merge(options))
          end
        end

        def css_prefix(prefix = nil, &block)
          if (prefix && block)
            raise ArgumentError, "You can supply either a String or a block, but not both; you passed: #{prefix.inspect} and #{block.inspect}"
          end

          if (prefix != nil) && (! prefix.kind_of?(String))
            raise ArgumentError, "Invalid prefix (must be a String, or nil): #{prefix.inspect}"
          end

          @_parcels_css_prefix = prefix || block
        end

        def parcels_sets(*set_names, &block)
          if set_names.length > 0 && block
            raise ArgumentError, "You can specify either a set name or a block, but not both; you passed: #{set_names.inspect} and #{block.inspect}"
          end

          if set_names == [ nil ]
            @_parcels_sets = [ ]
          else
            @_parcels_sets = block || set_names.map(&:to_sym)
          end
        end

        def _parcels_get_sets(defining_file_path)
          _parcels_get_sets_for_class(self, defining_file_path)
        end

        def _parcels_get_sets_for_class(klass, defining_file_path)
          if @_parcels_sets
            out = @_parcels_sets
            out = out.call(klass, defining_file_path) if out.respond_to?(:call)
            out = Array(out).map(&:to_sym)
            out
          elsif superclass.respond_to?(:_parcels_get_sets_for_class)
            superclass._parcels_get_sets_for_class(klass, defining_file_path)
          else
            [ ]
          end
        end

        def _parcels_get_css_prefix
          _parcels_get_css_prefix_for_class(self)
        end

        def _parcels_get_css_prefix_for_class(klass)
          if @_parcels_css_prefix
            out = @_parcels_css_prefix
            out = out.call(klass) if out.respond_to?(:call)
            out
          elsif superclass.respond_to?(:_parcels_get_css_prefix_for_class)
            superclass._parcels_get_css_prefix_for_class(klass)
          else
            nil
          end
        end
      end
    end
  end
end
