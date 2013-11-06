FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.CategoricalFilterView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/categorical_filter_view',
        className: 'header-search-bar push-half--bottom',

        initialize: function () {
            this.announceSearchTerm = _.debounce(this.announceSearchTerm, 500);
        },

        events: {
            'typeahead:selected #search-input': 'announceSearchTerm',
            'keypress #search-input': 'announceSearchTerm',
        },

        announceSearchTerm: function (e, data) {
            name = (data === undefined) ? e.currentTarget.value : data.name;
            this.trigger("filter:search_term", { 'name': name });
        },

        ui: {
            $search_input: '#search-input',
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

        resetCategoricalFilterTool: function (data) {
            this.ui.$search_input.attr('value', data.name);
        }
    });
});
