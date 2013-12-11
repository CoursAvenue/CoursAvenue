
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureTypeFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'structure_type_filter_view',

        initialize: function() {
            this.announce = _.debounce(this.announce, 800);
        },

        setup: function (data) {
            this.ui.$select.val(data.structure_type);
        },

        ui: {
            '$select': 'select'
        },

        events: {
            'change select': 'announce'
        },

        announce: function (e, data) {
            var value = this.ui.$select.val();
            this.trigger("filter:structure_type", { 'structure_type': value });
        }

    });
});
