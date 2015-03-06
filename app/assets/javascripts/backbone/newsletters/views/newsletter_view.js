Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'newsletter_view',

        events: {
        },

        initialize: function initialize () {
        },

        // We overwrite render so we can call the stickit plugin.
        render: function render () {
            // Invoke original render function
            var args = Array.prototype.slice.apply(arguments);
            var result = Marionette.ItemView.prototype.render.apply(this, args);

            // Return render result
            return result;
        },

        // The templateHelpers function allows us to create helper methods that
        // can be called from our template.
        //
        // More information:
        // <http://git.io/xpMt>
        templateHelpers: function templateHelpers () {
            return {
                // Renders the bloc's template with the bloc's attributes.
                renderBlocs: function renderedBlocs (bloc) {
                    var content = '';

                    this.blocs.forEach(function(bloc) {
                        var path = Module.templateDirname() + 'bloc_' + bloc.get('type');

                        bloc.set('index', bloc.get('position') - 1);
                        content += JST[path](bloc.attributes);
                        bloc.unset('index', { silent: true });
                    });

                    return content;
                },
                formAction: Routes.pro_structure_newsletters_path(window.coursavenue.bootstrap.structure),
                csrfName: $('meta[name="csrf-param"]').attr('content'),
                csrfToken: $('meta[name="csrf-token"]').attr('content'),
            };
        },

        // TODO: Ask for confirmation ("Changing layout will lose your current
        // blocs. Are you sure you want to continue ?").
        updateLayout: function updateLayout (data) {
            var model = data.model;

            // If the layout is already selected, do nothing.
            if (model.get('id') == this.model.get('layout_id')) {
                return ;
            }

            this.model.set('layout_id', model.get('id'));

            this.render();
        },

    });
});
