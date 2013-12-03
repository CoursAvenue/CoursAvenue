
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

            def backbone_path
                @backbone_path ||= ::Rails.root.join('app', 'assets', 'javascripts', 'backbone')
            end

            def app_path(app)
                @app_path ||= Pathname.new("#{backbone_path}") + app.underscore
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

            def detect_related_collection_view(app, name)
                return "" unless (collection_view_path(app, name).exist?)

                say "\nWait! We found a collection view for #{name}. Do you want to add #{item_view_name(name)} to the existing collection view?"
                print_table [["1.", "Go ahead and create #{item_view_name(name)} as a stand-alone itemview."],
                             ["2.", "Nest #{item_view_name(name)} inside the existing collection."]]
                selection = ask("? ").to_i

                if (selection == 2)
                  namespace = collection_name(name)
                end

                return namespace || ""
            end
        end
    end
end

