
require 'generators/helpers'

class MarionetteLayoutGenerator < Rails::Generators::NamedBase
    include Marionette::Generators::Helpers

    attr_accessor :master_region_name

    source_root File.expand_path("../templates", __FILE__)

    desc <<-DESC
This generator creates a marionette layout with the given name. The
master region name provided in the layout implementation will also
use this name, since it is assumed that the layout is named after
the data source it governs.
    DESC
    argument :app,       type: :string, required: true, desc: "The app to which the new layout will belong.", banner: "MyApp"
    argument :name,      type: :string, required: true, desc: "The name to give the new layout.",             banner: "Widget"
    argument :namespace, type: :string, optional: true, desc: "Optional module nesting.", default: "",      banner: "Space.Ship"

    # @pre backbone_path is a valid path
    def create_layout
        self.namespace = namespace
        self.master_region_name = name.underscore.pluralize.gsub(/_/, "-")

        ensure_app_exists(app, name)

        template "layout.js", layout_path(app, name, self.namespace)
        template "layout.jst.hbs", layout_template_path(app, name, self.namespace)

        # create a new manifest, and then point the previous manifest to it
        append_to_file(app_path(name) + 'views' + manifest, "#{manifest_require} ./#{layout_name(name).underscore}")
    end

end
