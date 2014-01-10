
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile.EditableTagBar', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER = 13;
    var ESC   = 27;
    var SPACE = 32;

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
        },

        events: {
            'click'                         : 'announceClick',
            'click [data-behavior=destroy]' : 'destroyTag',
            'keydown'                       : 'handleKeyDown',
            'change'                        : 'announceEdits'
        },

        ui: {
            '$input': 'input',
            '$taggy': '.taggy',
        },

        /* no model here */
        serializeData: function () {
            var tags = this.data.split(",");

            return {
                tags: tags
            }
        },

        onRender: function () {
            this.$rollback = this.$("[data-type=taggies-container]").clone();
        },

        /* SPACE: turn the text into a taggy */
        handleKeyDown: function (e) {
            var key = e.which;

            if (key === SPACE) {
                this.createTaggy();
            }

            this.announceEdits();

            if (key !== ENTER && key !== ESC) {
                return;
            }

            this.trigger("field:key:down", { editable: this, restore: (key === ESC) });
        },

        createTaggy: function () {
            /* make a new taggy */
            var text  = this.ui.$input.val(),
                taggy = $("<span class='taggy--tag' data-value='" + text + "'>" + text + "</span>");

            /* append said taggy */
            this.$("[data-type=taggies-container]").append(taggy);

            /* update the input width */
            /* TODO this could be more efficient */
            var field_width = this.$el.width();
            var tags_width  = _.inject(this.$(".taggy--tag"), function (memo, element) {
                memo += $(element).width() + 35;
                return memo;
            }, 0);

            this.ui.$input.css({ width: (field_width - tags_width ) + 'px', display: "" });
            this.ui.$input.val("");
        },

        /* gather all the existing taggies */
        getEdits: function () {
            var data = this.$(".taggy--tag").map(function (index, taggy) {
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
            this.trigger("field:click", this.$el.find("input")); // TODO we are passing out the whole view for now
        },

        /* construct and show the taggy */
        startEditing: function () {
            if (this.isEditing()) { return; }

            this.is_editing = true;

            /* TODO figure out how to make this rock */
            var field_width = this.$el.width();
            var tags_width  = _.inject(this.$(".taggy--tag"), function (memo, element) {
                memo += $(element).width() + 40;
                return memo;
            }, 0);

            this.ui.$input.css({ width: (field_width - tags_width ) + 'px', display: "" });
            this.ui.$taggy.addClass("active");

            var text = this.$el.text();
            var $input = $("<input>").prop("value", text);
        },

        /* purely visual: whatever was in the input, change it to text */
        stopEditing: function () {
            this.is_editing = false;
            this.ui.$taggy.removeClass("active");
            this.$(".taggy--input").css({ display: "none" });
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
            this.$("[data-type=taggies-container]").replaceWith(this.build_taggy());

            this.$rollback = this.$("[data-type=taggies-container]").clone();
        },

        /* change the text to the old data */
        rollback: function () {
            this.is_editing = false;
            this.stopEditing();

            var current = this.$el.find("[data-type=taggies-container]");
            var old = this.$rollback;

            current.replaceWith(old);
        },

        /* maybe the text has fallen out of sync with the data */
        refresh: function () {
            this.rollback();
        },

        isEditing: function () {
            return this.is_editing === true;
        },

        build_taggy: function () {
            var $html = this.$("[data-type=taggies-container]").empty();

            _.each(this.data.split(","), function (text) {
                $taggy = $("<span class='taggy--tag' data-value='" + text + "'>" + text + "</span>");
                $html.append($taggy);
            });

            return $html;
        }
    });
});
