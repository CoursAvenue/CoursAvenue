Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
  Module.LayoutView = Backbone.Marionette.CompositeView.extend({
    template: Module.templateDirname() + 'layout_view',
    tagName: 'div',

    events: {
      'click .layout': 'selectLayout'
    },

    initialize: function initialize () {
      // _.bindAll(this, 'selectLayout', 'showSavingIndicator');
      // this.model.on('change', this.showSavingIndicator);
    },

    // TODO: Look in the emailings backbone application for example.
    showSavingIndicator: function showSavingIndicator () {
        console.log('saving');
    },

  });
});
