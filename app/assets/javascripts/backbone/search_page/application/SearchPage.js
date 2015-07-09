SearchPage = new Backbone.Marionette.Application({ slug: 'search-page' });

SearchPage.addRegions({
    mainRegion: '#' + SearchPage.slug
});

SearchPage.addInitializer(function(options) {
    var layout   = new SearchPage.Views.SearchPageLayout();
    var map_view = new SearchPage.Views.MapView();
    var router   = new SearchPage.Router.SearchPageRouter();

    var planning_collection       = new SearchPage.Models.PlanningsCollection();
    var plannings_collection_view = new SearchPage.Views.PlanningsCollectionView({ collection: planning_collection });

    SearchPage.mainRegion.show(layout);

    layout.showWidget(map_view, {
        events: {
            'plannings:reset' : 'updateMarkers'
        }
    });
    layout.showWidget(plannings_collection_view, {
        events: {
          'map:bounds:change': 'searchWithNewBounds'
        }
    });

});

$(document).ready(function() {
    /* we only want the current app on the search page */
    if (SearchPage.detectRoot()) {
        SearchPage.start({});
    }
});
