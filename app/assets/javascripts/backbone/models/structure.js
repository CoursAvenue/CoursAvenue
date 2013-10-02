/* just a basic backbone model */
FilteredSearch.Models.Structure = Backbone.Model.extend({
  defaults: {
    data_type: 'structure-element'
  },
  initialize: function() {
    console.log("Structure->initialize");
  }

});
