
module Marionette
    module Generators
        module Helpers
            include ActionView::Helpers::AssetUrlHelper

            def dot_js
                '.js'
            end

            def backbone_path
                @backbone_path ||= ::Rails.root.join('app', 'assets', 'javascripts', 'backbone')
            end

            def app_path(app)
                @app_path ||= Pathname.new("#{backbone_path}") + app.underscore
            end

            def namespace_path(namespace)
                @namespace_path ||= Pathname.new(namespace.underscore.gsub(/\./, File::SEPARATOR))
            end

            def model_path(app, name, namespace = "")
                @model_path ||= app_path(app) + 'models' + namespace_path(namespace) + "#{name.underscore}#{dot_js}"
            end

            def collection_name(name)
                @collection_name ||= "#{name.pluralize}Collection"
            end

            def collection_path(app, name, namespace = "")
                @collection_path ||= app_path(app) + 'models' + namespace_path(namespace) + "#{collection_name(name).underscore}#{dot_js}"
            end

            def ensure_app_exists(app, full_name)
                return if (app_path(app).directory?)

                say "\nWait! #{app} is not an app yet! Would you like to create it?"
                print_table [["1.", "Go ahead and create #{full_name}, without creating a new app"],
                             ["2.", "First create #{app}, then continue creating #{full_name}"]]
                selection = ask("? ").to_i

                if (selection == 2)
                    # TODO invoke the app creation task
                end
            end

            def ensure_model_exists(app, name, namespace = "")
                return if (model_path(app, name).exist?)

                say "\nWait! We couldn't find a model called #{name}, are you sure you still want to create a collection called #{collection_name(name)}?"
                print_table [["1.", "Go ahead and create #{collection_name(name)}, without creating #{name}"],
                             ["2.", "First create #{name}, then continue creating #{collection_name(name)}"]]
                selection = ask("? ").to_i

                if (selection == 2)
                   ::Rails::Generators.invoke("marionette_model", [app, name, namespace])
                end
            end
        end
    end
end

