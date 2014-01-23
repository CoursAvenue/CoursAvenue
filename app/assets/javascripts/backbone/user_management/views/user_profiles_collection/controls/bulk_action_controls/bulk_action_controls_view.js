
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.Controls.BulkActionControls', function(Module, App, Backbone, Marionette, $, _) {

    Module.BulkActionControlsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'bulk_action_controls_view',
        tagName: 'div',
        className: 'grid--full bulk-action-controls',
        attributes: {
            'data-behavior': 'bulk-action-controls'
        },

        events: {
            'click [data-behavior=save]'   : 'announceSave',
            'click [data-behavior=cancel]' : 'announceCancel',
        },

        announceSave: function (e) {
            e.stopPropagation();
            this.trigger("controls:save");
        },

        announceCancel: function (e) {
            e.stopPropagation();
            this.trigger("controls:cancel");
        },

        onRender: function () {
            this.$el.sticky();
        },


    });
});
