
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.Controls.BulkActionControls', function(Module, App, Backbone, Marionette, $, _) {

    Module.BulkActionControlsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'bulk_action_controls_view',
        tagName: 'div',

        attributes: {
            'data-behavior': 'bulk-action-controls'
        },

        ui: {
            '$select_all'        : '[data-behavior=select-all]',
            '$tag_names'         : '[data-value=tag-names]',
            '$edit_manager'      : '[data-behavior=manage-edits]',
            '$selected_count'    : '[data-behavior=selected-count]'
        },

        events: {
            'click [data-behavior=save]'           : 'announceSave',
            'click [data-behavior=cancel]'         : 'announceCancel',
            'click [data-behavior=new]'            : 'newUserProfile',
            'click [data-behavior=select-all]'     : 'selectAll',
            'click [data-behavior=deselect-all]'   : 'clearSelection',
            /* TODO this doesn't actually work yet: when I click on page 2, they don't have checked boxes */
            'click [data-behavior=deep-select]'    : 'deepSelect',
            /* TODO do try to make this a proper tag bar by installing tag bar */
            'click [data-behavior=manage-tags]'    : 'manageTags',
            'click [data-behavior=add-tags]'       : 'addTags',
            'click [data-behavior=destroy]'        : 'destroySelected',
            'click [data-behavior=filters]'        : 'showFilters',
        },

        showFilters: function () {
            this.trigger("controls:show:filters");
        },

        updateSelected: function (data) {
            this.showDetails("select-all");
            this.showDetails("bulk-actions");
            this.ui.$selected_count.html(data.count);

            if (data.count === 0) {
                this.hideDetails("select-all");
                this.hideDetails("bulk-actions");
            } else if (data.deep) {

                // if we are in a deep select, then whenever
                // the selection shrinks we should give the
                // option to deep select again
                if (data.count === data.total) {
                    this.hideDetails("deep-select");
                } else {
                    this.showDetails("deep-select");
                }
            }
        },

        toggleEditManager: function (is_editing) {
            var rotate = (is_editing)? "rotateX(-180deg)" : "rotateX(0deg)";

            this.ui.$edit_manager.parent().css({ transform: rotate });
        },

        announceSave: function (e) {
            e.stopPropagation();
            this.trigger("controls:save");
        },

        announceCancel: function (e) {
            e.stopPropagation();
            this.trigger("controls:cancel");
        },

        onAfterShow: function () {
            this.setUpRotation();
        },

        setUpRotation: function () {
            this.$("[data-behavior=edits-container]")
                .css({
                    "transform-origin": "right center 0",
                    "transform-style": "preserve-3d",
                    transition: "transform 1s ease 0s"
                })
                .parent()
                .css({ perspective: "800px" });

            this.$('[data-behavior=new]').css({
                position: "absolute",
                right: -2,
                top: -10,
                "backface-visibility": "hidden",
            });

            // hide the backside
            this.ui.$edit_manager
                .css({
                    "backface-visibility": "hidden",
                    transform: "rotateX(180deg)"
                });
        },

        selectAll: function (options) {
            this.showDetails("select-all");
            this.showDetails("deep-select");
            this.trigger("controls:select:all", { deep: false });
        },

        deepSelect: function () {
            this.trigger("controls:deep:select");
            this.hideDetails("deep-select");
        },

        clearSelection: function () {
            this.trigger("controls:clear:selected");
            this.hideDetails("deep-select");
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

        /* TODO implement the notifications card, and then add
         *  a notification that checks with the user "are you suuuuuuur?" */
        destroySelected: function () {
            this.trigger("controls:destroy:selected");
        },

        newUserProfile: function (e) {
            e.stopPropagation();

            this.trigger("controls:new");
        }

    });
});
