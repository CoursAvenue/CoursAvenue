Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
  Module.Newsletter = Backbone.Model.extend({

    url: function url () {
      var structure = window.coursavenue.bootstrap.structure;
      return Routes.pro_structure_newsletter_path(structure, this.get('id'));
    }

  });
});
