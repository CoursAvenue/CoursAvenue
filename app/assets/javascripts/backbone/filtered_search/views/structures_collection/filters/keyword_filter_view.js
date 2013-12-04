FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.KeywordFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'keyword_filter_view',
        className: 'header-search-bar push-half--bottom',

        initialize: function () {
            this.announceSearchTerm = _.debounce(this.announceSearchTerm, 500);
        },

        setup: function (data) {
            this.ui.$search_input.attr('value', data.name);
            this.previous_searched_name = data.name;
        },

        events: {
            'typeahead:selected #search-input': 'announceSearchTerm',
            // Use keydown instead of keypress to handle the case when the user empties the input
            'keydown #search-input':            'announceSearchTerm'
        },

        announceSearchTerm: function (event, data) {
            name = (data ? data.name : event.currentTarget.value);
            // Prevent from launching the search if the name is same than previous one
            if (name != this.previous_searched_name) {
                this.previous_searched_name = name;
                this.trigger("filter:search_term", { 'name': name });
            }
        },

        ui: {
            $search_input: '#search-input',
        },

        onRender: function () {
            this.ui.$search_input.typeahead([{
                name: 'keywords',
                limit: 10,
                valueKey: 'name',
                prefetch: {
                    url: '/keywords.json'
                }
            }]);
        },
    });
});
