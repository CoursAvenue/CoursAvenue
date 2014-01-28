
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.TagFilterView = UserManagement.Views.UserProfilesCollection.UserProfile.EditableTagBar.EditableTagBarView.extend({
        template: Module.templateDirname() + 'tag_filter_view',
        className: 'hidden grid--full one-half',
        attributes: {
            'data-behavior': 'tag-filter'
        },

        showFilters: function () {
            if (this.$el.css("display") === "none") {
                this.$el.slideDown();
            } else {
                this.$el.slideUp();
            }
        }
    });
});
