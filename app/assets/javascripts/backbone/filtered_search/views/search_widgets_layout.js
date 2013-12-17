FilteredSearch.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SearchWidgetsLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'search_widgets_layout_view',
        className: 'relative',
        master_region_name: 'structures',

        regions: {
            master: "#search-results",
        },

        onShow: function() {
            FilteredSearch.$loader().fadeOut('slow');
        },

    });
});

