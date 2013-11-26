FilteredSearch.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SearchWidgetsLayout = FilteredSearch.Views.Lib.EventLayout.extend({
        template: Module.templateDirname() + 'search_widgets_layout_view',
        className: 'relative',

        regions: {
            results: "#search-results",
        },

        onShow: function() {
            FilteredSearch.$loader().fadeOut('slow');
        },

    });
});

