
require 'generators/helpers'

class MarionetteScaffoldGenerator < Rails::Generators::NamedBase
    include Marionette::Generators::Helpers

    attr_accessor :backbone_class

    source_root File.expand_path("../templates", __FILE__)

    desc <<-DESC
This generator creates a scaffold of a marionette app with the given name,
as well as a set of views/models for the given singular resource name.

If you want an app with no resource to begin with, use the argument --no-resource.
This is not recommended, since many files depend on the resource name ("Widget"
will be used as a placeholder in those files, but not widget files will be created).
    DESC
    argument :name,     type: :string, required: true, desc: "The name of your app.",                     banner: "MyApp"
    argument :resource, type: :string, required: true, desc: "The model around which your app is built.", banner: "Widget"

    # @pre backbone_path is a valid path
    def create_scaffold
        template "application_manifest.js", app_path(name) + "manifest.js"

        # make the top level dirs and a views/manifest.js
        # TODO for now we are just making the views directory
        (app_path(name) + "views").mkpath
        create_file app_path(name) + "views/manifest.js"
        
        # the order here is important, as it will populate the manifests correctly
        ::Rails::Generators.invoke("marionette_application", [name, resource])
        ::Rails::Generators.invoke("marionette_layout", [name, resource])
        ::Rails::Generators.invoke("marionette_collection", [name, resource])
        ::Rails::Generators.invoke("marionette_view_composite", [name, resource])
    end

end
