
/* just a basic marionette view */
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignUpView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_up_view',

        initialize: function initialize () {
            this.render();
            $.fancybox(this.$el, { width: 280, maxWidth: 280, minWidth: 280 });
        }
    });
});
