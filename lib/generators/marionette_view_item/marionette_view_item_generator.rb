
require 'generators/helpers'

class MarionetteViewItemGenerator < Rails::Generators::NamedBase
    include Marionette::Generators::Helpers

    attr_accessor :backbone_class

    source_root File.expand_path("../templates", __FILE__)

    desc <<-DESC
This generator creates a marionette itemview for the model with the given name,
in the appropriate directory for the given app. Optionally the itemview can be
nested in some subdir, in which case the nesting appears after 'my_app/views/'
and before 'widget/widget_view.js'. If no namespace is given, and the generator
finds that a collection or composite view already exists for the given name, it
will prompt the user to nest the new itemview inside.

It may be the case that no model exists for a given itemview, so the generator
will not assume anything about the relationship between view and model.
    DESC
    argument :app,       type: :string, required: true, desc: "The app to which the new view will belong.", banner: "MyApp"
    argument :name,      type: :string, required: true, desc: "The name to give the new view.",             banner: "Widget"
    argument :namespace, type: :string, optional: true, desc: "Optional module nesting.", default: "",       banner: "Space.Ship"

    # @pre backbone_path is a valid path
    def create_item_view
        self.backbone_class = "ItemView"
        self.namespace = namespace

        ensure_app_exists(app, name)
        ensure_manifest_exists(app, "Views") # TODO

        connect_namespace_manifests(app, name, namespace, 'Views') unless (self.namespace.blank?)

        self.namespace = detect_related_collection_view(app, name, namespace)

        template "item_view.js", item_view_path(app, name, self.namespace)
        template "item_view.jst.hbs", item_view_template_path(app, name, self.namespace)

        # create a new manifest, and then point the previous manifest to it
        create_file(app_path(name) + 'views' + namespace_path(namespace) + name.underscore + manifest, "#{manifest_require} ./#{item_view_name(name).underscore}\n")
        prepend_to_file(app_path(name) + 'views' + namespace_path(namespace) + manifest, "#{manifest_require} ./#{name.underscore}/manifest\n")
    end

end
