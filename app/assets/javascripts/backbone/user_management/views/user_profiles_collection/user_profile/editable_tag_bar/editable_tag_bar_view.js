
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile.EditableTagBar', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER     = 13;
    var ESC       = 27;
    var SPACE     = 32;
    var BACKSPACE = 8;
    var COMMA     = 188;

    Module.EditableTagBarView = CoursAvenue.Views.EditableFieldView.extend({
        template: Module.templateDirname() + 'editable_tag_bar_view',
        tagName: 'div',
        className: 'editable-tag-bar pointer',
        attributes: {
            'data-behavior': 'editable-tag-bar'
        },
        taggy: Handlebars.compile('<span class="taggy--tag"><i class="fa fa-times pointer" data-behavior="destroy"></i></span>'),

        initialize: function (options) {
            this.url        = options.url;

            this[COMMA]     = this.handleComma;
            this[BACKSPACE] = this.handleBackspace;
            this[ESC]       = this.handleEscape;
            this[ENTER]     = this.handleEnter;
        },

        ui: {
            '$input'    : '.taggy--input',
            '$container': '[data-type=taggies-container]'
        },

        events: {
            'click'                         : 'announceClick',
            'click [data-behavior=destroy]' : 'destroyTaggy',
            'typeahead:selected [type=text]': 'createTaggy',
            'keydown'                       : 'handleKeyDown',
            'change'                        : 'announceEdits',
            'blur @ui.$input'               : 'toggleBlueGlow',
            'focus @ui.$input'              : 'toggleBlueGlow'
        },

        /* TODO stop toggling! Just make two methods because it is broken */
        toggleBlueGlow: function () {
            this.$el.toggleClass("blue-glow");
        },

        /* get all the little tags */
        $taggies: function () {
            return this.$(".taggy--tag");
        },

        /* override the $input method to use ui bindings */
        $input: function () {
            return this.ui.$input;
        },

        /* TODO think about storing the data instead of the DOM and
         * actually calling render to rollback. Nima loves render. */
        onRender: function () {
            this.$rollback = this.ui.$container.children().clone();
            this.ui.$input.typeahead([{
                // name: 'keywords', // We don't want to cache
                limit: 15,
                valueKey: 'name',
                prefetch: {
                    url: this.url
                }
            }]);

            this.$('.twitter-typeahead').addClass('inline-block v-middle')
                                        .css({ width: '0%'});

            /* rebind the ui */
            this.bindUIElements();
        },

        getFieldContents: function () {
            return this.ui.$input.val();
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

            this.announceEdits();
            this.ui.$input.val("");
        },

        buildTaggy: function (text) {
            var taggy = $(Marionette.Renderer.render(this.taggy));

            taggy.attr("data-value", text);
            taggy.prepend(text);

            return taggy;
        },

        createTaggy: function () {
            var text  = this.ui.$input.val();

            // stop users from creating weird empty tags
            if (text.trim() === "") {
                return;
            }

            var taggy = this.buildTaggy(text);

            /* append said taggy */
            this.ui.$container.append(taggy);

            this.bindUIElements();

            this.announceEdits();
            this.ui.$input.typeahead('setQuery', '');
        },

        /* no model here */
        serializeData: function () {
            if (!this.data) {
                return;
            }

            var tags = this.data.split(",");

            return {
                tags: tags
            };
        },

        /* TODO make css styles so that all of this
         *  can be done with the class "active" */
        /* TODO see the TODO in the stylesheet _tags */
        /* TODO review stylesheets with NIMA I think my styles
         *  are out of control */
        activate: function () {
            this.ui.$input.css({ display: "" });
            this.$('.twitter-typeahead').toggleClass('inline-block')
                                        .toggleClass('v-middle')
                                        .css({ width: '95%'});

            this.$el.addClass("active");
        },

        deactivate: function () {
            this.ui.$input.css({ display: "none" });
            this.$('.twitter-typeahead').toggleClass('inline-block')
                                        .toggleClass('v-middle')
                                        .css({ width: '0%'});

            this.$el.removeClass("active");
        },

        /* update the data, nothing visual
         * if the tag_name comes back null, then
        *  we set the data to null and populate
        *  an empty array of tags  */
        commit: function (data) {
            if (data.tag_name === undefined) {
                return;
            }

            this.data = data.tag_name;

            /* UPON committing data, we must rebuild the tags and set the rollback */
            var tags = (this.data)? this.data.split(","): [];
            this.ui.$container.empty();

            _.each(tags, _.bind(function (tag) {
                var $tag = this.buildTaggy(tag);
                this.ui.$container.append($tag);
            }, this));

            this.$rollback = this.ui.$container.children().clone();

        },

        /* change the text to the old data */
        rollback: function () {
            this.stopEditing();

            var current = this.ui.$container;
            var old = this.$rollback;

            current.html(old);
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
