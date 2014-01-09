
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile.EditableTagBar.EditableTagBar', function(Module, App, Backbone, Marionette, $, _) {

    Module.EditableTagBarView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'editable_tag_bar_view',
        tagName: 'li',
        className: 'editable-tag-bar',
        attributes: {
            'data-behavior': 'editable-tag-bar'
        }
    });
});
