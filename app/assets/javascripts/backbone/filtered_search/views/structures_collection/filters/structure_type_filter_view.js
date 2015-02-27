
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureTypeFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'structure_type_filter_view',

        setup: function (data) {
            this.ui.$select.val(data.structure_types);
            this.announceBreadcrumb();
        },

        ui: {
            '$select': 'select'
        },

        events: {
            'change select': 'announce'
        },

        announce: function (e, data) {
            var structure_types = this.ui.$select.val();
            this.trigger("filter:structure_type", { 'structure_types[]': structure_types });
            this.announceBreadcrumb(structure_types);
        }.debounce(COURSAVENUE.constants.DEBOUNCE_DELAY),

        announceBreadcrumb: function(structure_types) {
            structure_types = structure_types || this.ui.$select.val();
            if (structure_types === null) {
                this.trigger("filter:breadcrumb:remove", {target: 'structure_types'});
            } else {
                title = _.map(this.ui.$select.find('option:selected'), function(option) { return $(option).text().trim() });
                this.trigger("filter:breadcrumb:add", {target: 'structure_types', title: title.join(', ')});
            }
        },

        // Clears all the given filters
        clear: function (filters) {
            this.ui.$select.val('').trigger('chosen:updated');
            this.announce();
        }
    });
});
