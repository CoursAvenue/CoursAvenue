FilteredSearch.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.InfoBoxView = CoursAvenue.Views.Map.GoogleMap.InfoBoxView.extend({
        template: FilteredSearch.Views.StructuresCollection.Structure.templateDirname() + 'structure_view',

        onRender: function onRender (){
            this.$('a').removeClass('bordered--bottom soft-half--ends');
            this.$('[data-content]').addClass('soft-half--left');
        }
    });
});
