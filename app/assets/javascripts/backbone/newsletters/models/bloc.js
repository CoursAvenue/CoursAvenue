Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Bloc = Backbone.Model.extend({

      // TODO: Set the url using:
      // - The structure
      // - The newsletter
      // - The bloc itslef.
      url: function url () {
        // var structure = window.coursavenue.bootstrap.structure;
        // return Routes.pro_structure_newsletter_path(structure, this.get('id'));
        return '';
      },

    });
});
