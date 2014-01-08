
UserManagement.module('Views.UserProfilesCollection.UserProfile.EditableText', function(Module, App, Backbone, Marionette, $, _) {

    Module.EditableTextView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'editable_text_view',
        tagName: 'div',
        className: 'editable-text',
        attributes: {
            'data-behavior': 'editable-text'
        }
    });
});
