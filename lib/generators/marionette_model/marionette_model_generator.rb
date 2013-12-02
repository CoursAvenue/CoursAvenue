
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
    def create_backbone_model
        app_path = Pathname.new("#{backbone_path}") + app.underscore
        self.backbone_class = "Model"

        if (not app_path.directory?)

            say "\nWait! #{app} is not an app yet! Would you like to create it?"
            print_table [["1.", "Go ahead and create #{name}, without creating a new app"],
                         ["2.", "First create #{app}, then continue creating #{name}"]]
            selection = ask("? ").to_i

            if (selection == 1)
                # TODO invoke the app creation task
            end
        end

        model_path = app_path + 'models' + namespace_path(namespace) + "#{name.underscore}#{dot_js}"
        template "model.js", model_path
    end

end
