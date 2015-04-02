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

            _.bindAll(this, 'setCurrentTab', 'updateNav', 'enableNavItem',
                      'nextStep', 'previousStep', 'scrollUp',
                      'selectNewsletterLayout', 'finishEdition',
                      'savingSuccessCallback', 'savingErrorCallback');
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
                case 'metadata'      : this.initializeOrShowMetadataPage(); break;
                case 'preview'       : this.initializeOrShowPreviewPage(); break;
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
            if (this.newsletter.hasChanged('layout_id') || this.newsletter.layout_changed) {
                this.newsletter.layout_changed = false;
                this.getRegion('edit').initialized = false;
                this.getRegion('edit').reset();
            }

            if (this.getRegion('edit').initialized) { this.getRegion('edit').$el.show(); return; }

            var blocs = this.newsletter.get('blocs');

            // Hack: When first creating the Backbone newsletter model, we create the newsletter
            // blocs. However, when the model is saved to the database, it sends back the model with
            // empty blocs. This recreates the blocs if they are empty.
            if (!blocs || _.isEmpty(blocs)) {
                this.newsletter.setBlocs();
                blocs = this.newsletter.get('blocs');
            }

            var bloc_collection = new Newsletter.Models.BlocsCollection(blocs, {
                newsletter: this.newsletter
            });

            var edition_view    = new Newsletter.Views.EditionView({
                model     : this.newsletter,
                collection: bloc_collection
            });

            this.listenTo(edition_view, 'edited',   this.finishEdition);
            this.listenTo(edition_view, 'previous', this.previousStep);

            this.getRegion('edit').show(edition_view);
            this.getRegion('edit').$el.show();
            this.getRegion('edit').initialized = true;
        },

        initializeOrShowMailingListPage: function initializeOrShowMailingListPage (page_name) {
            this.currentStep = ':id/liste-de-diffusion';
            if (this.getRegion('mailing-list').initialized) { this.getRegion('mailing-list').$el.show(); return; }
            var bootstrap = window.coursavenue.bootstrap;

            var mailing_list_collection      = new Newsletter.Models.MailingListsCollection(bootstrap.models.mailingLists);
            var mailing_list_collection_view = new Newsletter.Views.MailingListsCollectionView({
              collection: mailing_list_collection,
              model: this.newsletter
            });

            this.listenTo(mailing_list_collection_view, 'selected', this.selectMailingList);
            this.listenTo(mailing_list_collection_view, 'previous', this.previousStep);

            this.getRegion('mailing-list').show(mailing_list_collection_view);
            this.getRegion('mailing-list').$el.show();
            this.getRegion('mailing-list').initialized = true;
        },

        initializeOrShowMetadataPage: function initializeOrShowMetadataPage (page_name) {
            this.currentStep = ':id/recapitulatif';
            if (this.getRegion('metadata').initialized) { this.getRegion('metadata').$el.show(); return; }

            var bootstrap = window.coursavenue.bootstrap;
            var metadata_view = new Newsletter.Views.MetadataView({
                model: this.newsletter
            });

            this.listenTo(metadata_view, 'edited',   this.finishEdition);
            this.listenTo(metadata_view, 'previous', this.previousStep);

            this.getRegion('metadata').show(metadata_view);
            this.getRegion('metadata').$el.show();
            this.getRegion('metadata').initialized = true;
        },

        initializeOrShowPreviewPage: function initializeOrShowPreviewPage (page_name) {
            this.getRegion('preview').reset();
            this.currentStep = ':id/previsualisation';

            var preview_view = new Newsletter.Views.PreviewView({
                model: this.newsletter
            });

            this.listenTo(preview_view, 'previous', this.previousStep);

            this.getRegion('preview').show(preview_view);
            this.getRegion('preview').$el.show();
            this.getRegion('preview').initialized = true;
        },

        updateNav: function updateNav (event) {
            var eventSender = $(event.toElement);
            var fragment    = eventSender.data('newsletter-nav');
            var disabled    = eventSender.data('newsletter-disabled');

            var memberRoutes = ['remplissage', 'liste-de-diffusion', 'recapitulatif', 'previsualisation'];

            if (memberRoutes.indexOf(fragment) != -1) {
                var id = this.newsletter.get('id') || ':id';
                fragment = id + '/' + fragment;
            }

            if (disabled) {
                COURSAVENUE.helperMethods.flash('Veuillez compléter l’étape actuelle.', 'error');
            } else {
                this.router.navigate(fragment, { trigger: true });
            }
        },

        // Goes to the next step depending on the current step.
        nextStep: function nextStep () {
            // We get the steps from the router routes attributes, and we remove the last element.
            var steps = _.chain(this.router.routes).keys().initial().value();

            // We get the next step by getting the element at the current index + 1.
            // If it is the end, we set the first page. (This will probably never happen).
            var nextStep = steps[steps.indexOf(this.currentStep) + 1]
            if (!nextStep) { nextStep = 'mise-en-page' }

            var navName = nextStep.replace(':id/', '');
            var navItem = this.$el.find('[data-newsletter-nav=' + navName + ']');

            this.enableNavItem(navItem);

            // We replace the `:id` param by the actual model id.
            nextStep = nextStep.replace(':id', this.newsletter.get('id'));

            this.router.navigate(nextStep, { trigger: true });
            this.scrollUp();
        },

        previousStep: function previousStep () {
            var steps = _.chain(this.router.routes).keys().initial().value();

            var previousStep = steps[steps.indexOf(this.currentStep) - 1]
            if (!previousStep) { previousStep = 'mise-en-page' }
            previousStep = previousStep.replace(':id', this.newsletter.get('id'));

            this.router.navigate(previousStep, { trigger: true });
            this.scrollUp();
        },

        scrollUp: function scrollUp () {
            $.scrollTo(0, { easing: 'easeOutCubic', duration: 350 });
        },

        // TODO: Create global error save callback that shows an alert / notice.
        selectNewsletterLayout: function selectNewsletterLayout (data) {
            this.newsletter.set('layout_id', data.model.get('id'));
            this.newsletter.layout_changed = true;
            this.newsletter.save({}, {
                success: this.savingSuccessCallback,
                error:   this.savingErrorCallback,
            });
        },

        finishEdition: function finishEdition (data) {
            if (this.newsletter.hasChanged()) {
                this.newsletter.save({}, {
                    success: this.savingSuccessCallback,
                    error:   this.savingErrorCallback,
                });
            } else {
                this.nextStep();
            }
        },

        selectMailingList: function selectMailingList (data) {
            if (data.model) {
                this.newsletter.set('newsletter_mailing_list_id', data.model.get('id'));
            }

            if (this.newsletter.hasChanged()) {
                this.newsletter.save();
            }
            this.nextStep()
        },

        savingSuccessCallback: function savingSuccessCallback (model, response, options) {
            this.nextStep();
        },

        savingErrorCallback: function savingSuccessCallback (model, response, options) {
            COURSAVENUE.helperMethods.flash('Erreur lors de la sauvegarde de la newsletter, veuillez rééssayer.', 'error');
        },

        enableNavItem: function enableNavItem (navItem) {
            navItem.data('newsletter-disabled', false);
            navItem.removeClass('cursor-disabled')
        },
    });
});
