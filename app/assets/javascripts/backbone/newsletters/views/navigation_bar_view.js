Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NavigationBarView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'navigation_bar_view',
        tagName: 'div',
        className: 'hidden',

        ui: {
            '$preview'  : '[data-preview]',
            '$next_link': '[data-next]'
        },
        events: {
            'click [data-previous]': 'previousStep',
            'click [data-next]'    : 'nextStep',
            'click [data-preview]' : 'preview'
        },

        initialize: function initialize (options) {
            this.newsletter = options.newsletter;
        },
        // Do it onAfterShow to be sure the page is rendered and the width and offsets are correctly computed
        onAfterShow: function onAfterShow () {
            this.$('[data-behavior=sticky]').sticky(this.$('[data-behavior=sticky]')[0].dataset);
        },

        nextStep: function nextStep () {
            this.trigger('navigation:next');
        },

        previousStep: function previousStep () {
            this.trigger('navigation:previous');
        },

        setNewsletterID: function setNewsletterID (newsletter) {
            this.ui.$preview.attr('href', Routes.preview_newsletter_pro_structure_newsletter_path(this.newsletter.get('structure_id'), this.newsletter.get('id')))
        },

        updateButtonsVisibility: function updateButtonsVisibility (route) {
            this.ui.$next_link.fadeIn();
            switch(route) {
                case 'chooseLayout':
                    this.$el.slideUp();
                    break;
                case 'edit':
                    this.$el.slideDown();
                    break;
                case 'setMailingList':
                    this.$el.slideDown();
                    break;
                case 'setMetadata':
                    this.$el.slideDown();
                    break;
                case 'showPreview':
                    this.$el.slideDown();
                    this.ui.$next_link.fadeOut();
                    break;
            }
        },

        serializeData: function serializeData () {
            if (this.newsletter.get('structure_id')) {
                return {
                    preview_url: Routes.preview_newsletter_pro_structure_newsletter_path(this.newsletter.get('structure_id'), this.newsletter.get('id'))
                };
            } else {
                return {};
            }
        }

    });
});
