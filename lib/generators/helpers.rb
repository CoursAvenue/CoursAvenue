
# TODO split this into several helpers so that we can use
# lazy loading in all the generators without having to worry
# about order
module Marionette
    module Generators
        module Helpers
            include ActionView::Helpers::AssetUrlHelper

            def dot_js
                '.js'
            end

            def dot_jst
                '.jst.hbs'
            end

            def manifest
                "manifest.js"
            end

            def manifest_require
                "//= require "
            end

            def models_header
                "//---------- Models"
            end

            def backbone_path
                @backbone_path ||= ::Rails.root.join('app', 'assets', 'javascripts', 'backbone')
            end

            def app_path(app)
                @app_path ||= Pathname.new("#{backbone_path}") + app.underscore
            end

            def application_path(app)
                @application_path ||= app_path(app) + 'application' + "#{app.underscore}#{dot_js}"
            end

            # can't be lazily initialized, because it gets called in different contexts
            def namespace_path(namespace)
                Pathname.new(namespace.underscore.gsub(/\./, File::SEPARATOR))
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

            def item_view_name(name)
                @item_view_name ||= "#{name}View"
            end

            def item_view_path(app, name, namespace = "")
                @item_view_path ||= app_path(app) + 'views' + namespace_path(namespace) + name.underscore + "#{name.underscore}_view#{dot_js}"
            end

            def item_view_template_path(app, name, namespace = "")
                @item_view_template_path ||= app_path(app) + 'templates' + namespace_path(namespace) + name.underscore + "#{name.underscore}_view#{dot_jst}"
            end
            
            def collection_view_name(name)
                @collection_view_name ||= "#{name.pluralize}CollectionView"
            end

            def collection_view_path(app, name, namespace = "")
                @collection_view_path ||= app_path(app) + 'views' + namespace_path(namespace) + collection_name(name).underscore + "#{collection_view_name(name).underscore}#{dot_js}"
            end

            def collection_view_template_path(app, name, namespace = "")
                @collection_view_template_path ||= app_path(app) + 'templates' + namespace_path(namespace) + collection_name(name).underscore + "#{collection_view_name(name).underscore}#{dot_jst}"
            end

            # the ensure methods assume that, if the thing doesn't exist it should be created
            def ensure_app_exists(app, full_name)
                return if (app_path(app).directory?)

                say "\nWait! #{app} is not an app yet! Would you like to create it?"
                print_table [["1.", "Go ahead and create #{full_name}, without creating a new app"],
                             ["2.", "First create #{app}, then continue creating #{full_name}"]]
                selection = ask("? ").to_i

                if (selection == 2)
                    ::Rails::Generators.invoke("marionette_application", [app])
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

            def ensure_item_view_exists(app, name, namespace = "")
                return if (item_view_path(app, name).exist?)

                say "\nWait! We couldn't find an item view called #{item_view_name(name)}, are you sure you still want to create a collection view called #{collection_view_name(name)}?"
                print_table [["1.", "Go ahead and create #{collection_view_name(name)}, without creating #{item_view_name(name)}"],
                             ["2.", "First create #{item_view_name(name)}, then continue creating #{collection_view_name(name)}"]]
                selection = ask("? ").to_i

                if (selection == 2)
                    nested_namespace = (namespace.blank?) ? collection_name(name) : "#{namespace}.#{collection_name(name)}"
                    ::Rails::Generators.invoke("marionette_view_item", [app, name, nested_namespace])
                end
            end

            # detect methods assume that, if an association exists already, you want to nest within it
            def detect_related_collection_view(app, name, namespace = "")
                return namespace unless (collection_view_path(app, name, namespace).exist?)

                say "\nWait! We found a collection view for #{name}. Do you want to add #{item_view_name(name)} to the existing collection view?"
                print_table [["1.", "Go ahead and create #{item_view_name(name)} as a stand-alone itemview."],
                             ["2.", "Nest #{item_view_name(name)} inside the existing collection."]]
                selection = ask("? ").to_i

                if (selection == 2)
                  namespace = namespace + '.' + collection_name(name)
                end

                namespace = namespace[1..-1] if namespace[0] == '.' # trim the god damn leading .

                return namespace || ""
            end
        end
    end
end

