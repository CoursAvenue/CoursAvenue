AppProRouter = Backbone.Router.extend({

  routes : {
    ""       : "goToStructure",
    "/avis"  : "goToComments"
  },


  goToStructure: function () {
    var layout = new AppPro.Views.StructureLayoutView();
    AppPro.mainRegion.show(layout);
  },

  goToComments: function () {
    console.log('goToComments');
  }

});
