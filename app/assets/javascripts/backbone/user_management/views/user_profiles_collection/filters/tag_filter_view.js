
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

        onFieldEdits: function () {
            this.handleEnter();
        },

        afterRender: function (callback) {
            callback();

            this.startEditing(); // this field should start right away
            this.$input().focus();
        },

        handleEnter: function () {
            this.trigger("filter:tags", { "tags[]": this.getEdits().data });
        },

        /* when, for example, the page loads, we may need to build
         *  all the little taggies */
        buildTaggies: function (tags) {

            _.each(_.ensureArray(tags), _.bind(function (tag) {
                var $tag = this.buildTaggy(tag);
                this.ui.$container.append($tag);
            }, this));
        }
    });
});
