Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'newsletter_layout',

        events: {
            'click [data-newsletter-nav]': 'updateNav'
        },

        initialize: function initialize (options) {
            this.router = options.router;

            _.bindAll(this, 'setCurrentTab', 'updateNav');

        },

        setCurrentTab: function setCurrentTab (tab) {
            $('[data-newsletter-nav]').parent().removeClass('active');
            $('[data-newsletter-nav=' + tab + ']').parent().addClass('active');
        },

        updateNav: function updateNav (event) {
            var event_sender = $(event.toElement);
            var fragment     = event_sender.data('newsletter-nav');

            this.setCurrentTab(fragment);

            this.router.navigate(fragment, { trigger: true });
        },

    });
});
