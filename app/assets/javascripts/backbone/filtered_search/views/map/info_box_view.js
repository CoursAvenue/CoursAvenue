
FilteredSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.InfoBoxView = CoursAvenue.Views.Map.GoogleMap.InfoBoxView.extend({
        template: Module.templateDirname() + 'info_box_view'
    });
});
