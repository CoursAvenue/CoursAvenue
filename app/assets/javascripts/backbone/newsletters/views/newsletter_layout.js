Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'newsletter_layout',

        regions: {
            'choose-layout'  : "[data-page=choose-layout]",
            edit             : "[data-page=edit]",
            'user-selection' : "[data-page=user-selection]",
            metadata         : "[data-page=metadata]",
            preview          : "[data-page=preview]"
        },

        events: {
            'click [data-newsletter-nav]': 'updateNav'
        },

        initialize: function initialize (options) {
            this.router = options.router;

            _.bindAll(this, 'setCurrentTab', 'updateNav');
        },

        setCurrentTab: function setCurrentTab (tab) {
            $('[data-newsletter-page]').parent().removeClass('active');
            $('[data-newsletter-page=' + tab + ']').parent().addClass('active');
        },

        showOrCreatePage: function showOrCreatePage (page_name) {
            // Start by hiding all regions
            _.each(this.getRegions(), function(region) { region.$el.hide(); });
            this.setCurrentTab(page_name);
            switch(page_name) {
                case 'choose-layout' : this.initializeOrShowChooseLayoutPage(); break;
                case 'edit'          : this.initializeOrShowEditPage(); break;
                case 'mailing-list'  : alert('TODO'); break;
                case 'metadata'      : alert('TODO'); break;
                case 'preview'       : alert('TODO'); break;
            }
        },

        /*
         * ChooseLayout page initialization
         */
        initializeOrShowChooseLayoutPage: function initializeOrShowChooseLayoutPage (page_name) {
            if (this.getRegion('choose-layout').initialized) { this.getRegion('choose-layout').$el.show(); return; }
            var bootstrap = window.coursavenue.bootstrap;

            var layouts_collection      = new Newsletter.Models.LayoutsCollection(bootstrap.models.layouts);
            var layouts_collection_view = new Newsletter.Views.LayoutsCollectionView({
                collection: layouts_collection
            });

            this.getRegion('choose-layout').show(layouts_collection_view);
            this.getRegion('choose-layout').$el.show();
            this.getRegion('choose-layout').initialized = true;
        },

        /*
         * Edit page initialization
         */
        initializeOrShowEditPage: function initializeOrShowEditPage (page_name) {
            if (this.getRegion('edit').initialized) { this.getRegion('edit').$el.show(); return; }
            var bloc_collection = new Newsletter.Models.BlocsCollection(this.options.newsletter.get('blocs'))
            var edition_view    = new Newsletter.Views.EditionView({
                model     : this.options.newsletter,
                collection: bloc_collection
            });

            this.getRegion('edit').show(edition_view);
            this.getRegion('edit').$el.show();
            this.getRegion('edit').initialized = true;
        },

        onShow: function onShow (event) {
            // this.initializeDesignPage();
        },
        updateNav: function updateNav (event) {
            var event_sender = $(event.toElement);
            var fragment     = event_sender.data('newsletter-nav');

            this.router.navigate(fragment, { trigger: true });
        },

    });
});
