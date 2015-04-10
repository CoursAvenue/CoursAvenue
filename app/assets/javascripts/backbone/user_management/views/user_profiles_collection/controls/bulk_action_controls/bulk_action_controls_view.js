
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.Controls.BulkActionControls', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER     = 13;

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
            'click [data-behavior=new]'            : 'newUserProfile',
            'click [data-behavior=select-all]'     : 'selectAll',
            'click [data-behavior=deselect-all]'   : 'clearSelection',
            /* TODO this doesn't actually work yet: when I click on page 2, they don't have checked boxes */
            'click [data-behavior=deep-select]'    : 'deepSelect',
            /* TODO do try to make this a proper tag bar by installing tag bar */
            'click [data-behavior=manage-tags]'    : 'manageTags',
            'click [data-behavior=send-message]'   : 'sendMessage',
            'submit [data-behavior=add-tags-form]' : 'addTags',
            'click [data-behavior=destroy]'        : 'destroySelected'
        },

        /* cases:
        *  - count is 0 we have no reason to show select all, or bulk actions
        *  - select is deep
        *    - everything is selected
        *    - not everything is selected */
        /* TODO I'm sure we could express this more succinctly */
        updateSelected: function updateSelected (data) {
            this.ui.$selected_count.html(data.count);

            if (data.count === 0) {
                this.setSelectButton({ select: true }); // show the select button

                // selection is empty, hide the controls
                this.hideDetails("select-all");
                // this.hideDetails("bulk-actions");
                this.hideDetails("bulk-actions");
                this.hideDetails("manage-tags");
                this.hideDetails("deep-select");
            } else {
                this.setSelectButton({ select: false }); // show the deselect button

                // normally, show everything
                this.showDetails("select-all");
                // this.showDetails("bulk-actions");
                this.showDetails("bulk-actions");
                this.showDetails("deep-select");
            }

            if (data.deep) {
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

        setSelectButton: function setSelectButton (options) {
            if (!options) {
                return;
            }

            var icon     = (options.select ? "fa-check"       : "fa-times");
            var text     = (options.select ? "Tout sélectionner" : "Déselectionner");
            var behavior = (options.select ? "select-all"        : "deselect-all");

            var $button = this.$("[data-type=quick-select]");

            $button.find("i").attr("class", icon);
            $button.find("span").html(text);
            $button.attr("data-behavior", behavior);
        },

        toggleEditManager: function toggleEditManager (is_editing) {
            var rotate = (is_editing)? "rotateX(-180deg)" : "rotateX(0deg)";

            this.ui.$edit_manager.parent().css({ transform: rotate });
        },

        onAfterShow: function onAfterShow () {
            this.setUpRotation();
        },

        setUpRotation: function setUpRotation () {
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
                right: 0,
                top: 0,
                "backface-visibility": "hidden",
            });

            // hide the backside
            this.ui.$edit_manager
                .css({
                    "backface-visibility": "hidden",
                    transform: "rotateX(180deg)"
                });
        },

        selectAll: function selectAll (options) {
            this.showDetails("select-all");
            this.trigger("controls:select:all", { deep: false });
        },

        deepSelect: function deepSelect () {
            this.trigger("controls:deep:select");
        },

        clearSelection: function clearSelection () {
            this.trigger("controls:clear:selected");
        },

        showDetails: function showDetails (target) {
            this.$('[data-target=' + target + ']').slideDown();
        },

        hideDetails: function hideDetails (target) {
            this.$('[data-target=' + target + ']').slideUp();
        },

        manageTags: function manageTags () {
            this.$('[data-target=manage-tags]').slideToggle();
        },

        addTags: function addTags (event) {
            event.preventDefault(); // Prevent the form to be submitted because it's a form
            this.hideDetails("manage-tags");

            var tags = this.ui.$tag_names.val();
            this.trigger("controls:add:tags", tags);
        },

        /* TODO implement the notifications card, and then add
         *  a notification that checks with the user "are you suuuuuuur?" */
        destroySelected: function destroySelected () {
            if (confirm('Êtes-vous sûr de supprimer tous les contacts sélectionnés ?')) {
                this.trigger("controls:destroy:selected");
            }
        },

        newUserProfile: function newUserProfile (event) {
            event.stopPropagation();

            this.trigger("controls:new");
        },

        sendMessage: function sendMessage (event) {
            this.trigger('controls:message:new');
        }
    });
});
