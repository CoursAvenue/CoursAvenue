FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.KeywordFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'keyword_filter_view',
        itemViewContainer: '.grid__item.one-whole.soft-half.bg-white.tab-content',

        setup: function setup (data) {
            this.ui.$search_input.attr('value', data.name);
            this.previous_searched_name = data.name;
            this.announceBreadcrumb(data.name);
        },

        ui: {
            '$search_input'        : '#search-input',
            '$search_input_wrapper': '[data-type="search-input-wrapper"]'
        },

        events: {
            'typeahead:selected #search-input': 'announce',
            // Use keyup instead of keypress to handle the case when the user empties the input
            'keydown #search-input':            'keydown',
            'keyup #search-input':              'keyup',
            'click':                            'clickInsinde',
        },

        onRender: function onRender () {
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

        // This is to prevent the input to be cleared when pressing escape.
        // After investigation, don't know where the input is being cleared...
        // I agree, this is ugly.
        // keydown: function keydown (event) {
        //     this.previous_searched_name = this.ui.$search_input.typeahead('val');
        //     if (event.keyCode === 13 || event.keyCode === 27) { // Enter || Escape
        //         setTimeout(function() { this.ui.$search_input.typeahead('val', this.previous_searched_name) }.bind(this) );
        //     }
        // },

        // Announce on keyup and hide the typeahead on enter or escape
        keyup: function keyup (event) {
            if (event.keyCode === 13 || event.keyCode === 27) { // Enter || Escape
                this.ui.$search_input.typeahead('close');
                this.ui.$search_input.typeahead('val', this.previous_searched_name);
            }
            this.announce(event);
        },

        announce: function announce (event, data) {
            // this.ui.$search_input.typeahead("val", data.name);
            // this.announce({}, data);

            var name = ( data ? data.name : ( event ? event.currentTarget.value : '') );
            // Prevent from launching the search if the name is same than previous one
            if (name != this.previous_searched_name) {
                this.previous_searched_name = name;
                this.trigger("filter:search_term", { 'name': name });
                this.announceBreadcrumb(name);
            }
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        announceBreadcrumb: function announceBreadcrumb (name) {
            if (name.length === 0) {
                this.trigger("filter:breadcrumb:remove", { target: 'search_term' });
            } else {
                this.trigger("filter:breadcrumb:add", { target: 'search_term', title: name });
            }
        },

        // Clears all the given filters
        clear: function clear () {
            this.previous_searched_name = null;
            this.ui.$search_input.val('');
            this.announce();
        }

    });
});
