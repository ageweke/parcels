require 'tilt'

module Parcels
  module Fortitude
    class AlongsideEngine < Tilt::Template
      self.default_mime_type = 'text/css'

      def self.engine_initialized?
        true
      end

      def initialize_engine
        require_template_library 'fortitude'
      end

      def prepare
      end

      def evaluate(context, locals, &block)
        parcels_environment = context.environment.parcels
        widget_file = ::Parcels::Utils::PathUtils.widget_class_file_for_alongside_file(context.pathname)

        unless widget_file
          raise Errno::ENOENT, "Somehow, we're being asked to render CSS from #{context.pathname.to_s.inspect}, but we can't find a Fortitude widget class next to that file"
        end

        widget_class = parcels_environment.widget_class_from_file(widget_file)

        if widget_class
          widget_class._parcels_widget_class_alongside_css(parcels_environment, context)
        else
          ""
        end
      end
    end
  end
end
