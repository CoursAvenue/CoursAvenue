/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.KeywordFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'keyword_filter_view',
        className: '',

	initialize: function initialize () {
            this.announce = _.debounce(this.announce, 500);
        },

        ui: {
            $search_input: 'input',
        },

        events: {
            'typeahead:selected #search-input': 'announce',
            // Use keydown instead of keypress to handle the case when the user empties the input
            'keydown input':            'announce'
        },

	announce: function announce (event, data) {
            name = (data ? data.name : event.currentTarget.value);
            // Prevent from launching the search if the name is same than previous one
            if (name != this.previous_searched_name) {
                this.previous_searched_name = name;
                this.trigger("filter:search_term", { 'name': name });
            }
        },

	populateInput: function populateInput (name) {
            this.ui.$search_input.attr('value', name);
            this.previous_searched_name = name;
        },

        // Clears all the given filters
	clear: function clear () {
            this.previous_searched_name = null;
            this.ui.$search_input.val('');
            this.announce();
        }

    });
});
