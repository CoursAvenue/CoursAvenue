SearchPage.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.SearchPageLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'search_page_layout',

        initialize: function initialize () {
        }

    });
});
