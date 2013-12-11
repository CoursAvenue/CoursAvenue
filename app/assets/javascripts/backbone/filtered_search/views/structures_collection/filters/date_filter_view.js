
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DateFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'date_filter_view',

        setup: function (data) {
            if (data.date) {
                this.ui.$select.val(data.date);
            } else {
                this.ui.$start_date.val(data.start_date);
                this.ui.$end_date.val(data.end_date);
            }
        },

        ui: {
            '$day':          '[data-type=day]',
            '$time':         '[data-type=time]',
            '$date_pickers': '[data-behaviour=date-picker]',
            '$start_date':   '[data-type=start-date]',
            '$end_date':     '[data-type=end_date-date]',
        },

        serializeData: function(data) {
            return { 'days_of_the_week': ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"] };
        },

        events: {
            'change select': 'announce'
        },

        announce: function (e, data) {
            var value = this.ui.$select.val();
            this.trigger("filter:date", { 'date': value });
            this.trigger("filter:date_range", { 'date_range': [] });
        }
    });
});
