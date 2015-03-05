Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Newsletter = Backbone.Model.extend({

        initialize: function initialize (attributes, options) {
          if (!this.get('layout_id')) {
              this.set('layout_id', 1);
          }

          var layout = options.layouts.get(this.get('layout_id'));
          this.set('layout', layout);
        },

        url: function url () {
            var structure = window.coursavenue.bootstrap.structure;
            return Routes.pro_structure_newsletter_path(structure, this.get('id'));
        },

    });
});
