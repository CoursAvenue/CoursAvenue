
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfileView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_profile_view',
        tagName: 'tr',

        events: {
            'data-behavior="more-detail"': 'edit'
        },

        edit: function() {
            debugger
            var lala = $.fancybox({href: ''}, {
                    openSpeed   : 300,
                    maxWidth    : 800,
                    maxHeight   : 500,
                    fitToView   : false,
                    width       : width,
                    height      : height,
                    autoSize    : false,
                    autoResize  : true
            });

        },

        onRender: function () {
            this.$('[data-behavior=editable]').editable();
            this.$('[data-behavior=editable]').on('save', function(){
                var that = this;
                setTimeout(function() {
                    $(that).closest('td').next().find('[data-behavior=editable]').editable('show');
                }, 200);
            });
        }
    });
});
