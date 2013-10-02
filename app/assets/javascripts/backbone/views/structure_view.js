
FilteredSearch.Views.StructureView = Backbone.Marionette.ItemView.extend({
  template: 'backbone/templates/structure_view',
  tagName: 'li',

  onRender: function() {
    console.log("EVENT  StructureView->onRender")

  }

});
