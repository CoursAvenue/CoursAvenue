
require 'generators/helpers'

class MarionetteViewCompositeGenerator < Rails::Generators::NamedBase
    include Marionette::Generators::Helpers

    attr_accessor :backbone_class

    source_root File.expand_path("../templates", __FILE__)

    desc <<-DESC
This generator creates a marionette composite view for the collection that
governs the model with the given name. That is to say, given a singular name,
this generator creates a composite view for the model by that name. The view
is created, in the appropriate directory for the given app. In addition, the
item view for the relevant model will be created automatically, unless
--no-itemview is specified on the command-line. Optionally the composite view
can be nested in some subdir, in which case the nesting appears after 'my_app/views/'
and before 'widgets_collection/widgets_collection_view.js'.

Note that, despite being a composite view, in accordance with out conventions,
the view file and namespaces created will use 'collection' rather than 'composite',
since a composite view is just a collection, plus some fluff.

Finally, if the generator is called with the --with-model option, a model will
be created, if it does not already exist, to serve as the composite portion.
    DESC
    argument :app,       type: :string, required: true, desc: "The app to which the new view will belong.", banner: "MyApp"
    argument :name,      type: :string, required: true, desc: "The name to give the new view.",             banner: "Widget"
    argument :namespace, type: :string, optional: true, desc: "Optional module nesting.", default: "",       banner: "Space.Ship"

    # @pre backbone_path is a valid path
    def create_composite_view
        self.backbone_class = "CompositeView"
        self.namespace = namespace

        ensure_app_exists(app, name)

        template "composite_view.js", collection_view_path(app, name, self.namespace)
        template "composite_view.jst.hbs", collection_view_template_path(app, name, self.namespace)

        # create a new manifest, and then point the previous manifest to it
        create_file(app_path(name) + 'views' + namespace_path(namespace) + collection_name(name).underscore + manifest, "#{manifest_require} ./#{collection_view_name(name).underscore}")
        append_to_file(app_path(name) + 'views' + manifest, "#{manifest_require} ./#{collection_name(name).underscore}/manifest")

        ensure_app_exists(app, name)
        ensure_item_view_exists(app, name, namespace)
    end

end
