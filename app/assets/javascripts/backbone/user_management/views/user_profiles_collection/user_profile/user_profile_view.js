
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfileView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_profile_view',
        tagName: 'tr',

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
