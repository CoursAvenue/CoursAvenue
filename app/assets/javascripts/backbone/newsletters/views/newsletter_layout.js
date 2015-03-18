Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'newsletter_layout',

        regions: {
            'choose-layout': "[data-page=choose-layout]",
            edit:            "[data-page=edit]",
            'mailing-list':  "[data-page=mailing-list]",
            metadata:        "[data-page=metadata]",
            preview:         "[data-page=preview]"
        },

        events: {
            'click [data-newsletter-nav]': 'updateNav'
        },

        initialize: function initialize (options) {
            this.router     = options.router;
            this.newsletter = options.newsletter;

            _.bindAll(this, 'setCurrentTab', 'updateNav', 'selectNewsletterLayout', 'nextStep');
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
                case 'mailing-list'  : this.initializeOrShowMailingListPage(); break;
                case 'metadata'      : alert('TODO'); break;
                case 'preview'       : alert('TODO'); break;
            }
        },

        /*
         * ChooseLayout page initialization
         */
        initializeOrShowChooseLayoutPage: function initializeOrShowChooseLayoutPage (page_name) {
            this.currentStep = 'mise-en-page';
            if (this.getRegion('choose-layout').initialized) { this.getRegion('choose-layout').$el.show(); return; }
            var bootstrap = window.coursavenue.bootstrap;

            var layouts_collection      = new Newsletter.Models.LayoutsCollection(bootstrap.models.layouts);
            var layouts_collection_view = new Newsletter.Views.LayoutsCollectionView({
                collection: layouts_collection
            });

            this.listenTo(layouts_collection_view, 'layout:selected', this.selectNewsletterLayout);

            this.getRegion('choose-layout').show(layouts_collection_view);
            this.getRegion('choose-layout').$el.show();
            this.getRegion('choose-layout').initialized = true;
        },

        /*
         * Edit page initialization
         */
        initializeOrShowEditPage: function initializeOrShowEditPage (page_name) {
            this.currentStep = ':id/remplissage';
            if (this.newsletter.hasChanged('layout_id')) {
                this.getRegion('edit').initialized = false;
                this.getRegion('edit').reset();
            }

            if (this.getRegion('edit').initialized) { this.getRegion('edit').$el.show(); return; }

            var bloc_collection = new Newsletter.Models.BlocsCollection(this.options.newsletter.get('blocs'), {
                newsletter: this.newsletter
            });

            var edition_view    = new Newsletter.Views.EditionView({
                model     : this.options.newsletter,
                collection: bloc_collection
            });

            this.getRegion('edit').show(edition_view);
            this.getRegion('edit').$el.show();
            this.getRegion('edit').initialized = true;
        },

        initializeOrShowMailingListPage: function initializeOrShowMailingListPage (page_name) {
            this.currentStep = ':id/liste-de-diffusion';
            if (this.getRegion('mailing-list').initialized) { this.getRegion('mailing-list').$el.show(); return; }
            var mailing_list_view = new Newsletter.Views.MailingListView({
                model: this.options.newsletter
            });

            this.getRegion('mailing-list').show(mailing_list_view);
            this.getRegion('mailing-list').$el.show();
            this.getRegion('mailing-list').initialized = true;
        },

        updateNav: function updateNav (event) {
            var event_sender = $(event.toElement);
            var fragment     = event_sender.data('newsletter-nav');

            this.router.navigate(fragment, { trigger: true });
        },

        // TODO: Create global error save callback that shows an alert / notice.
        selectNewsletterLayout: function selectNewsletterLayout (data) {
            this.newsletter.set('layout_id', data.model.get('id'));
            this.newsletter.save({}, {
                success: function(model, response, options) {
                    this.nextStep();
                }.bind(this)
            });
        },

        // Goes to the next step depending on the current step.
        nextStep: function nextStep () {
            // We get the steps from the router routes attributes, and we remove the last element.
            var steps = _.chain(this.router.routes).keys().initial().value();

            // We get the next step by getting the element at the current index + 1.
            // If it is the end, we set the first page. (This will probably never happen).
            var nextStep = steps[steps.indexOf(this.currentStep) + 1]
            if (!nextStep) { nextStep = 'mise-en-page' }

            // We replace the `:id` param by the actual model id.
            nextStep = nextStep.replace(':id', this.newsletter.get('id'));

            this.router.navigate(nextStep, { trigger: true });
        },

    });
});
