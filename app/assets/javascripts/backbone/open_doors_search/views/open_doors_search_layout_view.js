// TODO this will be done in the rebrand method
OpenDoorsSearch.Views.app = OpenDoorsSearch;

OpenDoorsSearch.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SearchWidgetsLayout = Module.SearchWidgetsLayout.extend({
        template: Module.templateDirname() + 'open_doors_search_layout_view'
    });
});

