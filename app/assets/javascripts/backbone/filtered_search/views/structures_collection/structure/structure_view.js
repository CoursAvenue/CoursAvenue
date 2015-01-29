/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = CoursAvenue.Views.RelationalAccordionItemView.extend({
        template: Module.templateDirname() + 'structure_view',
        className: 'v-top push-half--bottom inline-block very-soft relative filtered_search__structure-item',
        attributes: {
            'data-type': 'structure-element'
        },

        initialize: function initialize (options) {
            _.bindAll(this, 'initializeAddToFavoriteLinks');
            this.$el.data('url', options.model.get('data_url'));
            this.model.on('user:signed:in', this.initializeAddToFavoriteLinks);
            /* the structure view needs to know how it is being filtered */
            if (options.search_term) {
                this.search_term = options.search_term;
            }

            /* any implementation of RelationalAccordionView must do this */
            this.getModuleForRelation = _.bind(this.getModuleForRelation, Module);
        },

        onRender: function onRender () {
            this.highlight();
            this.initializeAddToFavoriteLinks();
        },

        addOrRemoveFromFavorite: function addOrRemoveFromFavorite () {
            if (CoursAvenue.currentUser().isLogged()) {
                CoursAvenue.currentUser().addOrRemoveStructureFromFavorite(this.model.get('id'), { success: this.initializeAddToFavoriteLinks });
            } else {
                CoursAvenue.signUp({
                    title: 'Enregistrez-vous pour ajouter à vos favoris',
                    success: function success (response) {
                        var current_user = CoursAvenue.currentUser();
                        current_user.addOrRemoveStructureFromFavorite(this.model.get('id'),
                                                                      { success: function() {
                                                                                      $.magnificPopup.close();
                                                                                      this.initializeAddToFavoriteLinks();
                                                                                  }.bind(this)
                                                                      });
                    }.bind(this)
                });
            }
            return false;
        },

        initializeAddToFavoriteLinks: function initializeAddToFavoriteLinks () {
            var $add_to_favorite_links = this.$('[data-behavior=add-to-favorite]');
            if ( CoursAvenue.currentUser().isLogged() && CoursAvenue.currentUser().get('favorite_structure_ids').indexOf(this.model.get('id')) != -1 ) {
                $add_to_favorite_links.find('i').removeClass('fa-heart-o').addClass('fa-heart')
                $add_to_favorite_links.attr('title', $add_to_favorite_links.data('added-title')).tooltip('fixTitle');
            } else {
                $add_to_favorite_links.find('i').removeClass('fa-heart').addClass('fa-heart-o')
                $add_to_favorite_links.attr('title', $add_to_favorite_links.data('not-added-title')).tooltip('fixTitle');
            }
        },

        events: {
            'click'                                  : 'goToStructurePage',
            'click [data-behavior=add-to-favorite]'  : 'addOrRemoveFromFavorite',
            'mouseenter'                             : 'highlightStructure',
            'mouseleave'                             : 'unhighlightStructure'
        },

        /* return toJSON for the places relation */
        placesToJSON: function placesToJSON () {
            return this.model.get('places');
        },

        goToStructurePage: function goToStructurePage (event) {
            // Checking the parent prevent from clicking on an icon that is nested within a link element.
            if (event.target.nodeName !== 'A'
                && $(event.target).parent('a').length === 0
                && $(event.target).closest('[data-el="structure-view"]').length > 0) {
                if (event.metaKey || event.ctrlKey) { // Open in new window if user pushes meta or ctrl key
                    window.open(this.model.get('data_url'));
                } else {
                    window.location = this.model.get('data_url');
                }
            }
        },
        /* a structure was selected, so return the places JSON
        * TODO would it be nicer is this just returned the whole model's
        * json, including the places relation?
        * TODO: this todo is referenced in trello: https://trello.com/c/z8OddcYs */
        highlightStructure: function highlightStructure (e) {
            this.trigger('highlighted', this.placesToJSON());
        },

        unhighlightStructure: function unhighlightStructure (e) {
            this.trigger('unhighlighted', this.placesToJSON());
        },

        highlight: function highlight () {
            if (this.search_term) {
                this.$el.highlight(this.search_term);
            }
        },

        serializeData: function serializeData () {
            var data = this.model.toJSON();
            data.search_term = this.search_term;

            return data;
        }
    });
});
