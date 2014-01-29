
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER     = 13;
    var ESC       = 27;

    Module.TagFilterView = UserManagement.Views.UserProfilesCollection.UserProfile.EditableTagBar.EditableTagBarView.extend({
        template: Module.templateDirname() + 'tag_filter_view',
        className: 'grid--full',
        attributes: {
            'data-behavior': 'tag-filter'
        },

        initialize: function () {
            _.bindAll(this, "afterRender", "onRender");

            this.onRender = _.wrap(this.onRender, this.afterRender);

            this[ESC]       = undefined; // unbind this handler
            this[ENTER]     = this.handleEnter;
        },

        afterRender: function (callback) {
            callback();

            this.startEditing(); // this field should start right away
            this.$input().focus();
        },

        handleEnter: function () {
            this.trigger("filter:tags", { "tags[]": this.getEdits().data });
        },

        buildTaggies: function (tags) {
            // TODO when we get tags from the server we need to make them taggy
        }
    });
});
