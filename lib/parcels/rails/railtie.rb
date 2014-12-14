require "parcels"

module Parcels
  module Rails
    class Railtie < ::Rails::Railtie
      initializer :parcels, :after => :finisher_hook do |app|
        parcels = ::Rails.application.assets.parcels

        ::ApplicationController.view_paths.map(&:to_s).each do |view_path|
          view_path = File.expand_path(view_path)
          parcels.add_widget_tree!(view_path)
        end
      end
    end
  end
end
