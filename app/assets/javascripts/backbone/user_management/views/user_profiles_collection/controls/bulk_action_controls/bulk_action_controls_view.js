
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.Controls.BulkActionControls', function(Module, App, Backbone, Marionette, $, _) {

    Module.BulkActionControlsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'bulk_action_controls_view',
        tagName: 'div',
        className: 'grid--full bulk-action-controls',
        attributes: {
            'data-behavior': 'bulk-action-controls'
        },

        onRender: function () {
            this.$el.sticky();
        }
    });
});
