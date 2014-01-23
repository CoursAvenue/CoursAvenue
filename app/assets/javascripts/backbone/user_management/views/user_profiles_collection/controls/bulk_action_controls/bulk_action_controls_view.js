
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.Controls.BulkActionControls', function(Module, App, Backbone, Marionette, $, _) {

    Module.BulkActionControlsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'bulk_action_controls_view',
        tagName: 'div',
        className: 'grid--full bulk-action-controls',
        attributes: {
            'data-behavior': 'bulk-action-controls'
        },

        ui: {
            '$select_all': '[data-behavior=select-all]',
        },

        events: {
            'click [data-behavior=save]'           : 'announceSave',
            'click [data-behavior=cancel]'         : 'announceCancel',
            'click [data-behavior=select-all]'     : 'selectAll',
            'click [data-behavior=deselect-all]'   : 'deselectAll',
            'click [data-behavior=deep-select]'    : 'deepSelect',
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

        deselectAll: function () {
            this.hideDetails("select-all");
            this.trigger("controls:deselect:all");
            this.toggleSelectButton("select-all");
        },

        selectAll: function (options) {
            this.showDetails("select-all");
            this.trigger("controls:select:all", { deep: false });
            this.toggleSelectButton("deselect-all");
        },

        // the UI binding is cached,
        // so this will always refer to the same element
        toggleSelectButton: function (type) {
            this.ui.$select_all.find('i').toggleClass('fa-check fa-times');
            this.ui.$select_all.attr('data-behavior', type);
        },

        deepSelect: function ( ){
            this.trigger("controls:deep:select");
            this.hideDetails("select-all");
        },

        showDetails: function (target) {
            var $details = this.$('[data-target=' + target + ']');
            $details.slideDown();
        },

        hideDetails: function (target) {
            var $details = this.$('[data-target=' + target + ']');
            $details.slideUp();
        },


    });
});
