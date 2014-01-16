
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile.EditableTagBar', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER     = 13;
    var ESC       = 27;
    var SPACE     = 32;
    var BACKSPACE = 8;
    var COMMA     = 188;

    /* TODO when I backspace, it should "untag" the taggie, turning it back into a text */
    /* TODO I need to define clearly what parts of the template will be added/removed over time
    *  and then make UI shortcuts for everything else */

    Module.EditableTagBarView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'editable_tag_bar_view',
        tagName: 'div',
        className: 'editable-tag-bar pointer',
        attributes: {
            'data-behavior': 'editable-tag-bar'
        },

        initialize: function (options) {
            this.announceEdits = _.debounce(_.bind(this.announceEdits, this), 100);
            this.data = options.data;
            this.attribute = options.attribute;
            this.url = options.url;

            /* build a recyclable taggy */
            var taggy = $("<span>")
                .addClass('taggy--tag');
            var saltier = $("<i>")
                .addClass('fa fa-times')
                .attr('data-behavior', "destroy");

            taggy.append(saltier);
            this.$taggy_template = taggy;

            this.taggy_padding = 15;
        },

        events: {
            'click'                         : 'announceClick',
            'click [data-behavior=destroy]' : 'destroyTaggy',
            'keydown'                       : 'handleKeyDown',
            'change'                        : 'announceEdits',
            'typeahead:selected [type=text]': 'createTaggy'
        },

        ui: {
            '$input'    : '.taggy--input',
            '$container': '[data-type=taggies-container]'
        },

        /* no model here */
        serializeData: function () {
            if (this.data === "") {
                return;
            }

            var tags = this.data.split(",");

            return {
                tags: tags
            }
        },

        /* get all the little tags */
        $taggies: function () {
            return this.$(".taggy--tag");
        },

        onRender: function () {
            this.$rollback = this.ui.$container.children().clone();
            this.ui.$input.typeahead([{
                name: 'keywords',
                limit: 10,
                valueKey: 'name',
                prefetch: {
                    url: this.url
                }
            }]);
            this.$('.twitter-typeahead').addClass('v-middle').css({ width: '0%'});
            /* rebind the ui */
            this.bindUIElements();
        },

        /* SPACE: turn the text into a taggy */
        /* TODO yeah, so, this should be a switch eh? */
        handleKeyDown: function (e) {
            var key = e.which;

            if (key === COMMA) {
                e.preventDefault();
                this.createTaggy();
            }

            if (key === BACKSPACE && this.ui.$input.val() === "") {
                e.preventDefault();
                this.updateTaggy();
            }

            /* TODO we are announcing twice in some cases... which is OK because of debounce, I guess? */
            this.announceEdits();

            if (key !== ENTER && key !== ESC) {
                return;
            }

            this.ui.$input.val("");
            this.trigger("field:key:down", { editable: this, restore: (key === ESC) });
        },

        /* when the user backspaces into a taggy */
        updateTaggy: function () {
            var taggy = this.$taggies().last();
            var text = taggy.text();

            this.ui.$input.val(function (index, val) {
                return val + text;
            });

            taggy.remove();
            this.announceEdits();
        },

        /* when the user clicks 'x' */
        destroyTaggy: function (e) {
            $(e.currentTarget).parent().remove();

            this.updateInputWidth();
            this.announceEdits();
            this.ui.$input.val("");
        },

        /* returns the jQuery object representation of a taggy, for a given text */
        buildTaggy: function (text) {
            var taggy = this.$taggy_template.clone();

            taggy.attr("data-value", text);
            taggy.prepend(text);

            return taggy;
        },

        updateInputWidth: function () {
            /* update the input width */
            /* TODO this could be more efficient */
            var field_width = this.$el.width();
            var tags_width  = _.inject(this.$(".taggy--tag"), _.bind(function (memo, element) {

                // use outerWidth(true) to include margin
                memo += $(element).outerWidth(true) + 10; // TODO this works _most_ of the time; some weird offset is happening
                return memo;
            }, this), 0);

            var width = (field_width - (tags_width % (field_width - 70))) + 'px';

            this.$('.twitter-typeahead').css({ width: width, display: "" });
            this.ui.$input.css({ width: width, display: "" });
        },

        createTaggy: function () {

            var text  = this.ui.$input.val(),
                taggy = this.buildTaggy(text);

            /* append said taggy */
            this.ui.$container.append(taggy);

            // bind the new tag to ui.$taggies
            // TODO this is probably a little wasteful,
            // but at the same time we don't expect the
            // user to need to create a million tags/second
            this.bindUIElements();

            this.updateInputWidth();
            this.ui.$input.val("");
        },

        /* gather all the existing taggies */
        getEdits: function () {
            var data = this.$taggies().map(function (index, taggy) {
                return $(taggy).data("value");
            }).toArray();

            var edits = {
                attribute: "tags",
                data: data
            };

            return edits;
        },

        announceEdits: function () {
            this.trigger("field:edits", this.getEdits());
        },

        announceClick: function () {
            /* we don't care if you click on an input */
            if (this.isEditing()) { return; }

            this.startEditing(); // this field should start right away
            this.trigger("field:click", this.ui.$input);
        },

        /* construct and show the taggy */
        startEditing: function () {
            if (this.isEditing()) { return; }

            this.is_editing = true;

            this.updateInputWidth();
            this.$el.addClass("active");
        },

        /* purely visual: whatever was in the input, change it to text */
        stopEditing: function () {
            this.is_editing = false;
            this.$el.removeClass("active");

            this.ui.$input.css({ display: "none" });
            this.ui.$input.val("");
        },

        /* forcibly update the data */
        setData: function (data) {
            this.commit(data);
            this.refresh();
        },

        /* update the data, nothing visual */
        commit: function (data) {
            this.data = data.tag_name;

            this.$rollback = this.ui.$container.children().clone();
        },

        /* change the text to the old data */
        rollback: function () {
            this.is_editing = false;
            this.stopEditing();

            var current = this.ui.$container;
            var old = this.$rollback;

            current.html(old);
        },

        /* maybe the text has fallen out of sync with the data */
        refresh: function () {
            this.rollback();
        },

        isEditing: function () {
            return this.is_editing === true;
        }
    });
});
