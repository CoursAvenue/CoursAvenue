Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'newsletter_layout',

        events: {
            'click [data-newsletter-nav]': 'updateNav'
        },

        initialize: function initialize (options) {
            this.router = options.router;

            _.bindAll(this, 'updateNav');

        },

        updateNav: function updateNav (event) {
            var event_sender = $(event.toElement);
            var fragment     = event_sender.data('newsletter-nav');

            this.router.navigate(fragment, { trigger: true });
        },

    });
});
