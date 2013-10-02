//= require ./../models/paginated_collection
//= require ./structure_view

/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */
FilteredSearch.Views.PaginatedCollectionView = Backbone.Marionette.CompositeView.extend({
  template: 'backbone/templates/paginated_collection_view',
  itemView: FilteredSearch.Views.StructureView,
  itemViewContainer: 'ul',

  onRender: function() {
    console.log("EVENT  PaginatedCollectionView->onRender");

  }

});
