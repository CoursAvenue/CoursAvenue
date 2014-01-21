
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
            this.data          = options.data;
            this.attribute     = options.attribute;
            this.url           = options.url;

            /* build a recyclable taggy */
            var taggy = $("<span>")
                .addClass('taggy--tag');
            var saltier = $("<i>")
                .addClass('fa fa-times')
                .attr('data-behavior', "destroy");

            taggy.append(saltier);
            this.$taggy_template = taggy;

            this.taggy_padding = 15;


            this[COMMA] = this.handleComma;
            this[BACKSPACE] = this.handleBackspace;
            this[ESC] = this.handleEscape;
            this[ENTER] = this.handleEnter;
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
            if (this.data === "" || this.data === undefined) {
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
            this.$('.twitter-typeahead').addClass('inline-block v-middle').css({ width: '0%'});
            /* rebind the ui */
            this.bindUIElements();
        },

        /* SPACE: turn the text into a taggy */
        /* TODO yeah, so, this should be a switch eh? */
        handleKeyDown: function (e) {
            var key = e.which;
            var text = this.ui.$input.val();

            if (_.isFunction(this[key])) {
                this[key](text, e); // call the appropriate handler method
            }

            if (key === ENTER || key === ESC) {
                this.trigger("field:key:down", { editable: this, restore: (key === ESC) });
            }
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

            this.announceEdits();
            this.updateInputWidth();
            this.ui.$input.typeahead('setQuery', '');
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
            var edits = this.getEdits();
            this.trigger("field:edits", edits);
        },

        announceClick: function (e) {
            /* always announce the click */
            this.trigger("field:click", e);

            /* we don't care if you click on an input */
            if (this.isEditing()) { return; }

            this.startEditing(); // this field should start right away
            this.trigger("tagbar:click", this.ui.$input);
        },

        /* construct and show the taggy */
        startEditing: function () {
            if (this.isEditing()) { return; }

            this.setEditing(true);

            this.updateInputWidth();
            this.$el.addClass("active");
        },

        /* purely visual: whatever was in the input, change it to text */
        stopEditing: function () {
            this.setEditing(false);
            this.$el.removeClass("active");

            this.ui.$input.css({ display: "none" });
        },

        /* forcibly update the data */
        setData: function (data) {
            this.commit(data);
            this.refresh();
        },

        /* update the data, nothing visual */
        commit: function (data) {
            if (data.tag_name === undefined) {
                return;
            }

            this.data = data.tag_name;

            /* UPON committing data, we must rebuild the tags and set the rollback */
            var tags = this.data.split(",");
            this.ui.$container.empty();

            _.each(tags, _.bind(function (tag) {
                var $tag = this.buildTaggy(tag);
                this.ui.$container.append($tag);
            }, this));

            this.$rollback = this.ui.$container.children().clone();

        },

        /* change the text to the old data */
        rollback: function () {
            this.setEditing(false);
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
        },

        setEditing: function (value) {
            this.is_editing = value;
            this.trigger("set:editing", value);
        },

        handleComma: function (text, e) {
            e.preventDefault();
            this.createTaggy();
        },

        handleBackspace: function (text, e) {
            if (text !== "") {
                return;
            }

            e.preventDefault();
            this.updateTaggy();
        },

        handleEnter: function (text, e) {
            if (text === "") {
                return;
            }

            e.preventDefault();
            this.createTaggy();
        }
    });
});
