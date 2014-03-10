FilteredSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    Module.SubjectsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'subjects_filter_view',
        itemView: Module.SubjectView,
        itemViewContainer: '.grid__item.one-whole.soft-half.b-white.tab-content',

        initialize: function initialize () {
            this.announce = _.debounce(this.announce, 500);
        },

        setup: function setup (data) {
            this.ui.$search_input.attr('value', data.name);
            this.previous_searched_name = data.name;
            this.blurIrrelevantSubjects({subject_id: data.subject_id});
        },

        ui: {
            '$search_input'        : '#search-input',
            '$grand_children'      : '[data-type=grand-children]',
            '$buttons'             : '[data-type=button]',
            '$icons'               : '[data-type=button] img',
            '$menu'                : '[data-type=menu]',
            '$search_input_wrapper': '[data-type="search-input-wrapper"]'
        },

        events: {
            'typeahead:selected #search-input': 'announce',
            // Use keyup instead of keypress to handle the case when the user empties the input
            'keyup #search-input':              'announce',
            'focus @ui.$search_input':          'showMenu',
            'click [data-type=button]':         'activateButton',
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

        /*
         * if the "click" is not on the input, we hide the menu
         */
        clickInsinde: function onClickOutside (e) {
            if (this.ui.$menu.find(e.target).length > 0 || this.ui.$search_input_wrapper.find(e.target).length > 0) {
                return;
            }

            this.ui.$menu.hide();
        },
        /* if the "click outside" is on one of the subject buttons at the
         * top of the search page, then we ignore it. Otherwise, we dismiss
         * the modal menu.
         */
        onClickOutside: function onClickOutside (e) {
            // So the question is, why that?
            // `$('[data-type=button]').find('.' + e.target.className.split(' ').join('.'))`
            // Because that :
            // `$('[data-type=button]').find(e.target)`
            // Does not work. Probably because `$('[data-type=button]')` refers to too many elements
            var is_child_of = ( e.target.className.split(' ').join('.').length > 0 ? $('[data-type=button]').find('.' + e.target.className.split(' ').join('.')).length > 0 : true )
            if ($(e.target).data("type") === "button" || is_child_of) {
                return;
            }

            this.ui.$menu.hide();
        },

        onItemviewAnnouncedSubject: function onItemviewAnnouncedSubject (view, data) {
            this.ui.$menu.hide();

            this.ui.$search_input.typeahead("val", data.name);
            this.announce({}, data);
        },

        /* This method is triggered when a filter restricts the available data
         * by subject. In this case we want to visibly deactivate the now irrelevant
         * subject icons, remove their tabbing powers, and stop them from fetching
         * new grand_children.
         *
         * @param data -- should have .subject_id, which is possibly === null
         * */
        blurIrrelevantSubjects: function blurIrrelevantSubjects (data) {
            // If subject_id is null, then we are removing a filter.
            if (data.subject_id === null || data.subject_id == '') {
                this.ui.$icons.removeClass("fade-out").data("irrelevant", false);
                this.ui.$buttons.attr("data-toggle", "tab");
                return;
            }

            // The button that will not be deactivated is the relevant_button.
            var $relevant_button = this.$("[data-value=" + data.subject_id + "]");

            // We add the class fade-out to blur the icons visibly, and data-irrelevant
            // to prevent the icon from becoming "active". We erase data-toggle in
            // order to stop bootstrap from tabbing to an irrelevant tab.
            this.ui.$icons.addClass("fade-out").data("irrelevant", true);
            this.ui.$buttons.attr("data-toggle", false);

            // The relevant button gets to retain its properties.
            $relevant_button.find('img').removeClass("fade-out").data("irrelevant", false);
            $relevant_button.attr("data-toggle", "tab");

            // Finally we trigger a click so that the relevant button becomes active
            // and becomes the current tab.
            $relevant_button.trigger("click", { target: $relevant_button.find('img').get(0), currentTarget: $relevant_button.get(0) });
        },

        /* When a user clicks on one of the icons, if the icon is not currently
         * "irrelevant", then we will activate that icon and try to fetch grand_children
         * for the relevant subject.
         */
        activateButton: function activateButton (e) {
            if ($(e.target).data("irrelevant")) {
                return;
            }

            var $target = $(e.currentTarget),
                slug    = $target.data("value"),
                model   = this.collection.findWhere({ slug: slug });

            if (model.get("grand_children") === undefined) {
                model.fetch();
            }

            this.ui.$buttons.removeClass("active");
            $target.addClass("active");
        },

        showMenu: function showMenu () {
            this.ui.$menu.show();
        },

        announce: function announce (event, data) {
            var name = (data ? data.name : event.currentTarget.value);
            // Prevent from launching the search if the name is same than previous one
            if (name != this.previous_searched_name) {
                this.previous_searched_name = name;
                this.trigger("filter:search_term", { 'name': name });
            }
        },

        // Clears all the given filters
        clear: function clear () {
            this.previous_searched_name = null;
            this.ui.$search_input.val('');
            this.announce();
        },

        // the keyword bar now needs the subjects, in order to provide autocompletion
        serializeData: function serializeData () {
            // get just the top level subject names and slugs
            var subjects         = this.collection.map(function (model) {
                return { slug: model.get("slug"), name: model.get("name") }
            });

            subjects[0].is_first = true;

            return { subjects: subjects };
        },

        itemViewOptions: function itemViewOptions (model, index) {
            return {
                "is_first": index === 0
            }
        },

    });
});
