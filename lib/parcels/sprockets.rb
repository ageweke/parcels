require 'active_support'
require 'active_support/core_ext/string'

require "parcels/index"

::Sprockets::Environment.class_eval do
  def parcels
    @parcels ||= ::Parcels::Environment.new(self)
  end

  def index_with_parcels
    parcels.create_and_add_all_workaround_directories!
    index_without_parcels
  end

  alias_method_chain :index, :parcels
end

::Sprockets::Index.class_eval do
  def parcels
    @parcels ||= ::Parcels::Index.new(@environment.parcels)
  end
end

::Sprockets::DirectiveProcessor.class_eval do
  def process_require_parcels_directive(*set_names)
    set_names = set_names.map do |set_name|
      set_name = set_name.to_s.strip
      set_name = $1 if set_name =~ /,?(.*?),?$/i
      set_name.strip.to_sym
    end
    context.environment.parcels.add_all_widgets_to!(context, set_names.map(&:to_sym))
  end
end

::Sprockets::AssetAttributes.class_eval do
  def format_extension_with_parcels
    out = format_extension_without_parcels
    out = nil if out && out =~ /^\.html$/i
    out
  end

  alias_method_chain :format_extension, :parcels
end

::Sprockets::SassImporter.class_eval do
  if defined?(::Sprockets::SassImporter::GLOB)
    def find_relative_with_parcels(name, base, options)
      parcels = context.environment.parcels

      if name =~ ::Sprockets::SassImporter::GLOB && parcels.is_underneath_root?(base)
        imports = nil
        options[:load_paths].each do |load_path|
          imports = glob_imports(name, Pathname.new(File.join(load_path.to_s, "dummy")), :load_paths => [ load_path ])
          return imports if imports
        end
      end

      return find_relative_without_parcels(name, base, options)
    end

    alias_method_chain :find_relative, :parcels
  end
end
