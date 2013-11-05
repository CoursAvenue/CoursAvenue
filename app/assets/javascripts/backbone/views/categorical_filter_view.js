FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.CategoricalFilterView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/categorical_filter_view',

        events: {
            'typeahead:selected': 'announceSubject'
        },

        announceSubject: function (e, data) {
            this.trigger("filter:subject", { subject_name: data.name });
        },

        ui: {
            $search_input: '#search-input'
        },

        onRender: function () {
            this.ui.$search_input.typeahead([{
                name: 'subjects' + this.cid,
                valueKey: 'name',
                prefetch: {
                    url: '/disciplines.json'
                },
                header: '<div class="typeahead-dataset-header">Disciplines</div>'
            }]);
        },

        /* data to describe the pagination tool */
        resetCategoricalFilterTool: function (data) {
            this.current_summary_data = data;

            this.render();
        },

        serializeData: function (data) {
            return this.current_summary_data;
        },
    });
});
