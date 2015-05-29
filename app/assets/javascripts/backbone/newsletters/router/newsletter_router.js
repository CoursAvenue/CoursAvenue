Newsletter.module('Router', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterRouter = Backbone.Router.extend({
        routes: {
            'mise-en-page':           'chooseLayout',
            ':id/remplissage':        'edit',
            ':id/liste-de-diffusion': 'setMailingList',
            ':id/previsualisation':   'showPreview',
            '*path':                  'defaultRoute'
        },

        initialize: function initialize (options) {
            this.model = options.model;

            _.bindAll(this, 'saveLayout', 'chooseLayout', 'edit');
        },

        // Save the layout in the router.
        saveLayout: function saveLayout (layout) {
            this.layout = layout;
        },

        // In case the newsletter is new, go to mise-en-page`
        defaultRoute: function defaultRoute () {
            var path = 'mise-en-page';
            if (!this.model.isNew()) {
                var path = this.model.get('id') + '/remplissage';
            }
            this.navigate(path, { trigger: true });
        },

        // Route: /choose_layout
        chooseLayout: function chooseLayout () {
            this.layout.showOrCreatePage('choose-layout');
        },

        // Route: /edit
        edit: function edit () {
            this.layout.showOrCreatePage('edit');
            this.layout.enableNavItemsBefore('edit');
        },

        // Route: /mailing_list
        setMailingList: function setMailingList () {
            this.layout.showOrCreatePage('mailing-list');
            this.layout.enableNavItemsBefore('mailing-list');
        },

        // Route: /preview
        showPreview: function showPreview () {
            this.layout.showOrCreatePage('preview');
            this.layout.enableNavItemsBefore('preview');
        },
    });
});
