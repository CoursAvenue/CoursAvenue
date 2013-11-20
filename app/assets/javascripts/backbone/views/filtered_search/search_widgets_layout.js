FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.SearchWidgetsLayout = Views.EventLayout.extend({
        template: 'backbone/templates/search_widgets_layout_view',
        className: 'relative',

        regions: {
            results: "#search-results",
        },

        onShow: function() {
            FilteredSearch.$loader().fadeOut('slow');
        },

    });
});

