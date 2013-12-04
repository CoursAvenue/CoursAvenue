
require 'generators/helpers'

class MarionetteModelGenerator < Rails::Generators::NamedBase
    include Marionette::Generators::Helpers

    attr_accessor :backbone_class

    source_root File.expand_path("../templates", __FILE__)

    desc <<-DESC
This generator creates a backbone model with the given name, in the appropriate
directory for the given app. Optionally the model can be nested in some subdir,
in which case the nesting appears after 'my_app/models/' and before 'widget.js'
    DESC
    argument :app,       type: :string, required: true, desc: "The app to which the new model will belong.", banner: "MyApp"
    argument :name,      type: :string, required: true, desc: "The name to give the new model.",             banner: "Widget"
    argument :namespace, type: :string, optional: true, desc: "Optional module nesting.", default: "",       banner: "Space.Ship"

    # @pre backbone_path is a valid path
    def create_model
        self.backbone_class = "Model"

        ensure_app_exists(app, name)

        insert_into_file(app_path(name) + 'manifest.js', "#{manifest_require} ./models/#{name.underscore}", after: models_header)
        template "model.js", model_path(app, name, namespace)
    end

end
