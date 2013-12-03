
require 'generators/helpers'

class MarionetteApplicationGenerator < Rails::Generators::NamedBase
    include Marionette::Generators::Helpers

    attr_accessor :backbone_class

    source_root File.expand_path("../templates", __FILE__)

    desc <<-DESC
This generator creates a directory in the backbone folder by the given name,
and creates an application subdirectory containing an appropriately named
marionette application file. The application file is where the various parts
of the app will be initialized and started up.

Each application should have exactly one application file. This generator
will simply barf at you if you try to make two.
    DESC
    argument :name,        type: :string, required: true,                     desc: "The name of your app.", banner: "MyApp"
    argument :data_source, type: :string, required: false, default: "Widget", desc: "A model used as the main source of data on the page.", banner: "Widget"

    # @pre backbone_path is a valid path
    def create_backbone_model
        self.backbone_class = "Application"
        self.data_source = data_source || "Widget"

        raise "BARF!" if Pathname.new("#{application_path(name)}/#{name.underscore}.js").exist?

        template "application.js", application_path(name)
    end

end
