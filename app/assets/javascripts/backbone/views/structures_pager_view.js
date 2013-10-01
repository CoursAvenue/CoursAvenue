//= require ./../models/structures_pager
//= require ./structure_view

FilteredSearch.Views.StructuresPagerView = Backbone.Marionette.CompositeView.extend({
  template: 'backbone/templates/structures_pager_view',
  itemView: FilteredSearch.Views.StructureView

});
