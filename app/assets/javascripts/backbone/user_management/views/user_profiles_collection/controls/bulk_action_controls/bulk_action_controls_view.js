
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
            '$tag_names' : '[data-value=tag-names]',
        },

        events: {
            'click [data-behavior=save]'           : 'announceSave',
            'click [data-behavior=cancel]'         : 'announceCancel',
            'click [data-behavior=new]'            : 'newUserProfile',
            'click [data-behavior=select-all]'     : 'selectAll',
            'click [data-behavior=deselect-all]'   : 'deselectAll',
            'click [data-behavior=deep-select]'    : 'deepSelect', // TODO deep select is not finished
            'click [data-behavior=manage-tags]'    : 'manageTags',
            'click [data-behavior=add-tags]'       : 'addTags',
            'click [data-behavior=destroy]'        : 'destroySelected',
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

        manageTags: function () {
            this.showDetails("manage-tags");
        },

        addTags: function () {
            this.hideDetails("manage-tags");

            var tags = this.ui.$tag_names.val();
            this.trigger("controls:add:tags", tags);
        },

        manageTags: function () {
            this.showDetails("manage-tags");
        },

        /* TODO prompt user */
        destroySelected: function () {
            this.trigger("controls:destroy:selected");
        },

        newUserProfile: function (e) {
            e.stopPropagation();

            this.trigger("controls:new");
        }

    });
});
