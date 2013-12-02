
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

            def namespace_path(namespace)
                Pathname.new(namespace.underscore.gsub(/\./, File::SEPARATOR))
            end
        end
    end
end

