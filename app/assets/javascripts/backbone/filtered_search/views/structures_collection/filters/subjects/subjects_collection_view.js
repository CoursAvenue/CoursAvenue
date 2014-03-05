FilteredSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    Module.KeywordFilterView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'subjects_collection_view',
        itemView: Module.SubjectView,
        itemViewContainer: '.grid__item.one-whole.soft-half.b-white.tab-content',

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
            'keyup #search-input':              'announce',
            'focus @ui.$search_input':          'showMenu',
            'click [data-type=button]':         'activateButton',
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

        onClickOutside: function () {
            this.$("[data-type=menu]").hide();
        },

        onItemviewAnnouncedSubject: function (view, data) {
            this.$("[data-type=menu]").hide();

            this.ui.$search_input.typeahead("val", data.name);
            this.announce({}, data);
        },

        activateButton: function activateButton (e) {
            var slug  = $(e.target).data("value"),
                model = this.collection.findWhere({ slug: slug });

            if (model.get("grand_children") === undefined) {
                model.fetch();
            }

            this.$("[data-type=button]").removeClass("active");
            $(e.target).addClass("active");
        },

        showMenu: function () {
            this.$("[data-type=menu]").show();
        },

        announce: function (event, data) {
            var name = (data ? data.name : event.currentTarget.value);
            // Prevent from launching the search if the name is same than previous one
            if (name != this.previous_searched_name) {
                this.previous_searched_name = name;
                this.trigger("filter:search_term", { 'name': name });
            }
        },

        // Clears all the given filters
        clear: function () {
            this.previous_searched_name = null;
            this.ui.$search_input.val('');
            this.announce();
        },

        // the keyword bar now needs the subjects, in order to provide autocompletion
        serializeData: function() {
            // get just the top level subject names and slugs
            var subjects         = this.collection.map(function (model) {
                return { slug: model.get("slug"), name: model.get("name") }
            });

            subjects[0].is_first = true;

            return { subjects: subjects };
        },

        itemViewOptions: function (model, index) {
            return {
                "is_first": index === 0
            }
        },

    });
});
