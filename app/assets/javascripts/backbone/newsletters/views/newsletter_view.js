Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'newsletter_view',

        events: {
        },

        bindings: {
          '#title': 'title',
        },

        initialize: function initialize () {
        },

        // We overwrite render so we can call the stickit plugin.
        render: function render () {
          // Invoke original render function
          var args = Array.prototype.slice.apply(arguments);
          var result = Marionette.ItemView.prototype.render.apply(this, args);

          // Apply stickit
          this.stickit();

          // Return render result
          return result;
        },

        updateLayout: function updateLayout (data) {
            var model = data.model;
            this.model.set({ layout_id: model.get('id') });

            this.render();
        },
    });
});

