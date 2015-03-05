Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
  Module.LayoutView = Backbone.Marionette.CompositeView.extend({
    template: Module.templateDirname() + 'layout_view',
    tagName: 'div',

    events: {
      'click [data-layout]': 'selectLayout'
    },

    initialize: function initialize () {
      _.bindAll(this, 'selectLayout');
    },

    selectLayout: function selectLayout (event) {
        console.log(this.model);
    },

    // TODO: Look in the emailings backbone application for example.
    showSavingIndicator: function showSavingIndicator () {
        console.log('saving');
    },

  });
});
