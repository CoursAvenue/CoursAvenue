/* just a basic backbone model */
FilteredSearch.Models.Structure = Backbone.Model.extend({
  defaults: {
    data_type: 'structure-element'
  },
  initialize: function() {
    console.log("Structure->initialize");
  },

  subjectsCount: function() {
    if (this.subjects == undefined) return 0;

    return this.subjects.split(',').length;
  }

});

// for later
//  address_name=Paris&
//  city=paris&
//  lat=48.8592&
//  lng=2.3417&
//  name=danse&
//  page=2&
//  radius=5&
//  sort=rating_desc&utf8=%E2%9C%93
