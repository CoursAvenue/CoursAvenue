
/* just a basic marionette view */
StructureProfile.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = CoursAvenue.Views.EventLayout.extend({
        className: 'tabs-container',
        template: Module.templateDirname() + 'structure_view',

        ui: {
            '$loader'           : '[data-loader]'
        },

        initialize: function initialize () {
            _.bindAll(this, 'asyncLoadSection', 'hideLoader', 'addOrRemoveFromFavorite', 'initializeAddToFavoriteLinks');

            // Initialize it here because the button is not on structure_view
            $('body').on('click', '[data-behavior=add-to-favorite]', this.addOrRemoveFromFavorite);
            this.initializeAddToFavoriteLinks();

            var $structure_profile_menu = $('#structure-profile-menu');
            this.menu_scrolled_down = false;
            $(window).scroll(function() {
                if (!this.menu_scrolled_down && $(window).scrollTop() > 180 && parseInt($structure_profile_menu.css('top')) != 0 ) {
                    $structure_profile_menu.animate({ 'top': '0' });
                    this.menu_scrolled_down = true;
                } else if ($(window).scrollTop() < 180 && parseInt($structure_profile_menu.css('top')) == 0 ) {
                    $structure_profile_menu.animate({ 'top': '-100px' });
                    this.menu_scrolled_down = false;
                }
            }.bind(this));
            this.initializeContactLink();
        },

        initializeContactLink: function initializeContactLink () {
            $('body').on('click', '[data-behavior=show-contact-panel]', function() {
                this.trigger('planning:register', {});
            }.bind(this));
        },

        addOrRemoveFromFavorite: function addOrRemoveFromFavorite () {
            if (CoursAvenue.currentUser().isLogged()) {
                CoursAvenue.currentUser().addOrRemoveStructureFromFavorite(this.model.get('id'), { success: this.initializeAddToFavoriteLinks });
            } else {
                CoursAvenue.signUp({
                    title: 'Enregistrez-vous pour ajouter à vos favoris',
                    success: function success (response) {
                        CoursAvenue.currentUser().addOrRemoveStructureFromFavorite(this.model.get('id'), { success: this.initializeAddToFavoriteLinks });
                        $.magnificPopup.close();
                    }.bind(this)
                });
            }
            return false;
        },

        initializeAddToFavoriteLinks: function initializeAddToFavoriteLinks () {
            var $add_to_favorite_links = $('[data-behavior=add-to-favorite]');
            if ( CoursAvenue.currentUser().isLogged() &&  CoursAvenue.currentUser().get('favorite_structure_ids').indexOf(this.model.get('id')) != -1 ) {
                $add_to_favorite_links.each(function() {
                    $this = $(this);
                    $this.find('i').removeClass('fa-heart-o').addClass('fa-heart')
                    $this.attr('title', $this.data('added-title')).tooltip('fixTitle');
                    $this.find('span').text($this.data('added-text'));
                });
            } else {
                $add_to_favorite_links.each(function() {
                    $this = $(this);
                    $this.attr('title', $this.data('not-added-title')).tooltip('fixTitle');
                    $this.find('span').text($this.data('not-added-text'));
                    $this.find('i').removeClass('fa-heart').addClass('fa-heart-o')
                });
            }
        },

        onAfterShow: function onAfterShow () {
            this.trigger("filter:breadcrumbs:add", this.model.get("query_params"));
        },

        onRender: function onRender () {
            this.asyncLoadSection('courses');
            this.asyncLoadSection('trainings');
            this.asyncLoadSection('teachers');
        },

        /*
         * Fetch associated relation passing it the query_params
         */
        updateModelWithRelation: function updateModelWithRelation (relation) {
            var fetch = this.model.get(relation).fetch({ data: this.model.get("query_params") });

            if (fetch !== undefined) {
                fetch.then(function (response) {
                    this.model.get(relation).trigger('fetch:done', response);
                }.bind(this));
            }

            return fetch || new $.Deferred().reject();
        },

        asyncLoadSection: function asyncLoadSection (resource_name) {
            var ViewClass, view, model, fetch;

            ViewClass = this.findCollectionViewForResource(resource_name);

            // Only fetch when there is no data
            view = new ViewClass({
                collection : this.model.get(resource_name),
                data_url   : this.model.get("data_url"),
                about      : this.model.get('about'),
                about_genre: this.model.get('about_genre')
            });

            // always fetch, since we don't know whether we have resource_name or just ids
            this.showLoader(resource_name);
            this.updateModelWithRelation(resource_name)
                .then(function (collection) {
                    this.showWidget(view);
                }.bind(this))
                .always(function() { this.hideLoader(resource_name) }.bind(this));
        },

        showLoader: function showLoader (resources_name) {
            $('#tab-' + resources_name).append(this.ui.$loader);
            this.$('[data-' + resources_name + '-loader]').show();
        },

        hideLoader: function hideLoader (resources_name) {
            this.$('[data-' + resources_name + '-loader]').hide();
        },

        /*
         * Return the collectionView related to the resource based on its name
         */
        findCollectionViewForResource: function findCollectionViewForResource (resources) {
            return Module[_.capitalize(resources)][_.capitalize(resources) + 'CollectionView'];
        }

    });
});
