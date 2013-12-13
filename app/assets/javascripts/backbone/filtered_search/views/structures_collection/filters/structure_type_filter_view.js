
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
            var structure_types = this.ui.$select.val();
            this.trigger("filter:structure_type", { 'structure_type': structure_types });
            this.announceBreadcrumb(structure_types);
        },
        announceBreadcrumb: function(structure_types) {
            structure_types = structure_types || this.ui.$select.val();
            if (structure_types === null) {
                this.trigger("filter:breadcrumb:remove", {target: 'structure_type'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'structure_type'});
            }
        },

        // Clears all the given filters
        clear: function (filters) {
            this.ui.$select.val('').trigger('chosen:updated');
            this.announce();
        }
    });
});
