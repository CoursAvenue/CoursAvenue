FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.KeywordFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'keyword_filter_view',

        initialize: function () {
            this.announce = _.debounce(this.announce, 500);
        },

        setup: function (data) {
            this.ui.$search_input.attr('value', data.name);
            this.previous_searched_name = data.name;
        },

        ui: {
            '$search_input': '#search-input'
        },

        events: {
            'typeahead:selected #search-input': 'announce',
            // Use keyup instead of keypress to handle the case when the user empties the input
            'keyup #search-input':              'announce'
        },

        announce: function (event, data) {
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
            var engine   = new Bloodhound({
              datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.num); },
              queryTokenizer: Bloodhound.tokenizers.whitespace,
              remote: Routes.keywords_path({format: 'json'}) + '?name=%QUERY'
            });
            engine.initialize();
            this.ui.$search_input.typeahead({
                highlight : true
            }, {
                name: 'keywords',
                limit: 10,
                displayKey: 'name',
                source: engine.ttAdapter()
            });
        },
        // Clears all the given filters
        clear: function () {
            this.previous_searched_name = null;
            this.ui.$search_input.val('');
            this.announce();
        }

    });
});
