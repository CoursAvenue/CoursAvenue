/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Structure.Medias', function(Module, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Module.MediaView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + "media_view",
        className: 'soft-half inline-block one-third v-top',
    });
});
