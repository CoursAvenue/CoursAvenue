Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
  Module.NewsletterLayout = CoursAvenue.Views.EventLayout.extend({
    template: Module.templateDirname() + 'newsletter_layout',
    regions: {
      sidebar: '#sidebar',
      master: '#master'
    }
  });
});
