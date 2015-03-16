Newsletter.module('Router', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterRouter = Backbone.Router.extend({
        routes: {
            'mise-en-page'       : 'chooseLayout',
            'remplissage'        : 'edit',
            ':id/remplissage'    : 'edit',
            'liste-de-diffusion' : 'setMailingList',
            'recapitulatif'      : 'setMetadata',
            'previsualisation'   : 'showPreview'
        },

        // TODO:
        // - Before route: Empty layout
        // - After route : setCurrentTab.
        initialize: function initialize (options) {
            this.model = options.model;

            _.bindAll(this, 'saveLayout', 'chooseLayout', 'edit');
        },

        // Save the layout in the router.
        saveLayout: function saveLayout (layout) {
            this.layout = layout;
        },

        // Route: /choose_layout
        chooseLayout: function chooseLayout () {
            this.layout.showOrCreatePage('choose-layout');
        },

        // Route: /edit
        edit: function edit () {
            this.layout.showOrCreatePage('edit');
        },

        // Route: /mailing_list
        setMailingList: function setMailingList () {
            this.layout.showOrCreatePage('mailing-list');
        },

        // Route: /metadata
        setMetadata: function setMetadata () {
            this.layout.showOrCreatePage('metadata');
        },

        // Route: /preview
        showPreview: function showPreview () {
            this.layout.showOrCreatePage('preview');
        },
    });
});
