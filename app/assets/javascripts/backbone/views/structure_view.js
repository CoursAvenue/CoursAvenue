
/* just a basic marionette view */
FilteredSearch.Views.StructureView = Backbone.Marionette.ItemView.extend({
  template: 'backbone/templates/structure_view',
  tagName: 'li',

  initialize: function(options) {
    console.log("StructureView->initialize");
    if (options.context == undefined) return;

    var subject = options.model;
    _.each(_.pairs(options.context), function(pair) {
      console.log(pair);
      var key = pair[0];
      var value = pair[1];

      subject.set(key, value);
    });
  },

  onRender: function() {
    console.log("EVENT  StructureView->onRender")

  }

});
