UserManagement.module('Views.UserProfilesCollection.UserProfile', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER  = 13;
    var ESC    = 27;

    Module.UserProfileView = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'user_profile_view',
        tagName: 'tr',
        className: 'table__cell--editable',
        tagBarView: Module.EditableTagBar.EditableTagBarView,
        textFieldView: Module.EditableText.EditableTextView,

        initialize: function (options) {
            this.finishEditing = _.bind(this.finishEditing, this);
            // callbacks need to be bound to this
            _.bindAll(this, "updateSuccess", "updateError", "flashError");

            this.model.set("checked", options.checked);
            this.tags_url = options.tags_url;
            this.edits = {};

        },

        ui: {
            '$manage_edits': '[data-behavior="manage-edits"]',
            '$show_infos'  : '[data-behavior="show-info"]',
            '$editable': "[data-behavior=editable]",
            '$editing' : "[data-behavior=editable]:has('input')",
            '$checkbox': "[data-behavior=select]"
        },

        events: {
            'change @ui.$checkbox'          : 'addToSelected',
            'click [data-behavior=save]'    : 'save',
            'click [data-behavior=cancel]'  : 'cancel'
        },

        modelEvents: {
            'render': 'rerender',
            'change': 'syncFieldsToModel'
        },

        save: function announceSave (e) {
            this.finishEditing({ restore: false });
        },

        cancel: function announceCancel (e) {
            this.finishEditing({ restore: true });
        },

        announceEditableClicked: function (e) {
            this.trigger("editable:clicked", e);
        },

        /* incrementally build up a set of attributes */
        collectEdits: function (edits) {
            if (edits !== undefined) {
                this.edits[edits.attribute] = edits.data;
            }
        },

        /* options are passed to the initialize method of the
        * klass. event_hash is passed directly to the showwidget method */
        showEditable: function (selector, Klass, event_hash, options) {
            var attribute = this.$(selector).data("name"),
                data      = this.model.get(attribute),
                options   = _.extend(options || {}, { data: data, attribute: attribute }),
                view      = new Klass(options);
            if (Klass == this.tagBarView) {
                this.editable_tag_bar = view;
            }
            if (_.isFunction(event_hash.selector)) {
                event_hash.selector = event_hash.selector(attribute, data);
            }

            this.showWidget(view, event_hash);
        },

        onRender: function () {
            var options = { url: this.tags_url };
            this.showEditable("[data-behavior=editable-tag-bar]", this.tagBarView, {
                events: {
                    'start:editing'     : 'startEditing',
                    'rollback'          : 'rollback',
                    'update:start'      : 'stopEditing',
                    'update:success'    : 'commit',
                    'update:error'      : 'rollback',
                    'update:sync'       : 'setData'
                },
            }, options);

            this.ui.$editable.each(_.bind(function (index, element) {
                this.showEditable(element, this.textFieldView, {
                    events: {
                        'start:editing'     : 'startEditing',
                        'rollback'          : 'rollback',
                        'update:start'      : 'stopEditing',
                        'update:success'    : 'commit',
                        'update:error'      : 'rollback',
                        'update:sync'       : 'setData'
                    }, selector: function (attribute) {
                        return '[data-type=editable-' + attribute + ']';
                    }
                });
            }, this));

        },

        rerender: function rerender () {
            this.render();
            this.$el.yellowFade({ delay: 400 });
        },

        /* when the model changes, we update the fields to represent
         * this change */
        syncFieldsToModel: function (model) {
            if (model.changed.selected !== undefined) {
                this.ui.$checkbox.prop('checked', model.changed.selected);
            }

            /* we don't want to clobber fields with focus */
            if (this.isEditing()) { return; }

            this.trigger("update:sync", model.changed);
        },

        /* when the user uses the fancybox to update the model
        * we have to sync our local model. */
        syncLocalToRemote: function (xhr, data, status) {
            this.model.set(data);

            this.trigger("update:sync", this.model);
        },

        isEditing: function () {
            return this.is_editing;
        },

        /* we have a boolean stored as a mask. It is true when
        * the or of the bits is a true value, and false when it
        * it a false value.
        * The value can become "more" true, but not "more" false.
        * That is, once the value is a false value, it will stop
        * accepting "false" inputs */
        setEditing: function (value) {
            var old = this.is_editing;

            this.is_editing = value;

            if (this.is_editing != old) {
                this.trigger("changed:editing");
            }
        },

        addToSelected: function () {
            this.trigger("add:to:selected");
        },

        /* called: when an editable is clicked */
        /* notifies all the other editables in the layout
        *  and gets them started
        *  gives focus to the editable that was clicked */
        startEditing: function ($target) {
            this.setEditing(true);

            this.ui.$manage_edits.show();
            this.ui.$show_infos.hide();

            /* tell all the other fields to start themselves */
            this.trigger("start:editing");
        },

        /* when it is time for the row to stop being editable, we
         * must either clean up, rollback, or save, based on external
         * inputs and the state of the edits. */
        finishEditing: function (e) {
            this.ui.$manage_edits.hide();
            this.ui.$show_infos.show();

            // rollback if we aught to, or if there are no edits
            if (e.restore || _.isEmpty(this.edits)) {

                // if the model was new, we are done
                if (this.model.get("new")) {
                    this.model.set("new", false);
                    this.destroy();
                } else {
                    this.trigger("rollback");
                }

                // TODO problem: we want to set new to false on the model before
                // the observer of the is editing property sees the change
                // that's why isEditing is called here, and called twice
                this.setEditing(false);
                return;
            }

            this.setEditing(false);

            // Force tagbar view to create a tag of the rest of the text in the input
            if(this.editable_tag_bar) { this.editable_tag_bar.currentView.createTaggy(); }
            // otherwise, collect and save the updates
            var update    = {
                user_profile: this.edits
            };

            this.trigger("update:start"); // let everyone know we've started

            // the updateSuccess callback needs to know the action
            var action = this.model.get("new")? "create" : "update";
            var update_success = _.partial(this.updateSuccess, action);

            this.model.save(update, {
                error: this.flashError,
                wait: true

            }).success(update_success)
              .error(this.updateError);
        },

        /* Callbacks: these are all bound to 'this' */

        updateSuccess: function (action, response) {
            response.action = action;

            this.edits = {};

            this.trigger("update:success", response);
        },

        updateError: function updateError (response) {
            this.trigger("update:error", response);
        },

        flashError: function (model, response) {
            /* display a flash containing the error message */
            GLOBAL.flash(response.responseJSON.errors.join("\n"), "alert");
        },

        serializeData: function () {
            var data = this.model.toJSON();
            if (data.id) { data.edit_path = Routes.edit_pro_structure_user_profile_path(data.structure_id, data.id); }
            return data;
        }
    });
});
