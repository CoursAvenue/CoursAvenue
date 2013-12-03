
require 'generators/helpers'

class MarionetteCollectionGenerator < Rails::Generators::NamedBase
    include Marionette::Generators::Helpers

    attr_accessor :backbone_class

    source_root File.expand_path("../templates", __FILE__)

    desc <<-DESC
This generator creates a backbone collection. The given name must be a singular
resource name, and this generator will by default create a collection with the
plural name. For example, 'Widget' will produce 'widgets_collection.js'.
Optionally the model can be nested in some subdir, in which case the nesting
appears after 'my_app/models/' and before 'widgets_collection.js'.

If a collection is generated for a token, such as 'Widget', and no model exists
with the name 'widget.js', the user will be prompted to optionally create widget.js.
    DESC
    argument :app,       type: :string, required: true, desc: "The app to which the new collection will belong.",        banner: "MyApp"
    argument :name,      type: :string, required: true, desc: "The singular name of the model used by this collection.", banner: "Widget"
    argument :namespace, type: :string, optional: true, desc: "Optional module nesting.", default: "",                   banner: "Space.Ship"

    # @pre backbone_path is a valid path
    def create_backbone_collection
        self.backbone_class = "Collection"

        ensure_app_exists(app, collection_name(name))
        ensure_model_exists(app, name, namespace)

        template "collection.js", collection_path(app, name, namespace)
    end

end
