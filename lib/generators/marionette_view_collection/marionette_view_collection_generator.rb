
require 'generators/helpers'

class MarionetteViewCollectionGenerator < Rails::Generators::NamedBase
    include Marionette::Generators::Helpers

    attr_accessor :backbone_class

    source_root File.expand_path("../templates", __FILE__)

    desc <<-DESC
This generator creates a marionette collection view for the collection that
governs the model with the given name. That is to say, given a singular name,
this generator creates a collection view for the model by that name. The view
is created, in the appropriate directory for the given app. In addition, the
item view for the relevant model will be created automatically, unless
--no-itemview is specified on the command-line. Optionally the collection view
can be nested in some subdir, in which case the nesting appears after 'my_app/views/'
and before 'widgets_collection/widgets_collection_view.js'.
    DESC
    argument :app,       type: :string, required: true, desc: "The app to which the new view will belong.", banner: "MyApp"
    argument :name,      type: :string, required: true, desc: "The name to give the new view.",             banner: "Widget"
    argument :namespace, type: :string, optional: true, desc: "Optional module nesting.", default: "",       banner: "Space.Ship"

    # @pre backbone_path is a valid path
    def create_backbone_model
        self.backbone_class = "CollectionView"
        self.namespace = namespace

        ensure_app_exists(app, name)
        ensure_item_view_exists(app, name, namespace)

        template "collection_view.js", collection_view_path(app, name, self.namespace)
        template "collection_view.jst.hbs", collection_view_template_path(app, name, self.namespace)
    end

end
