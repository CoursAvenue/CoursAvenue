
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
        className: 'editable-tag-bar cursor-pointer',
        attributes: {
            'data-behavior': 'editable-tag-bar'
        },
        taggy: Handlebars.compile('<span class="taggy--tag"><i class="fa-times cursor-pointer" data-behavior="destroy"></i></span>'),

        constructor: function (options) {
            CoursAvenue.Views.EditableFieldView.prototype.constructor.apply(this, arguments);

            this.url        = options.url;

            this[COMMA]     = this.handleComma;
            this[BACKSPACE] = this.handleBackspace;
            this[ESC]       = this.handleEscape;
            this[ENTER]     = this.handleEnter;
        },

        ui: {
            '$input'    : '.taggy--input:not([disabled])',
            '$container': '[data-type=taggies-container]'
        },

        events: {
            'click'                         : 'announceClick',
            'click [data-behavior=destroy]' : 'destroyTaggy',
            'typeahead:selected [type=text]': 'createTaggy',
            'keydown'                       : 'handleKeyDown',
            'change'                        : 'announceEdits',
            'blur @ui.$input'               : 'blurred',
            'focus @ui.$input'              : 'focused'
        },

        focused: function focused () {
            this.$el.addClass("blue-glow");
            this.ui.$input.typeahead('open');
        },

        blurred: function blurred () {
            this.$el.removeClass("blue-glow");
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
            var engine   = new Bloodhound({
                datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.num); },
                queryTokenizer: Bloodhound.tokenizers.whitespace,
                remote: this.url,
            });
            engine.initialize();
            this.ui.$input.typeahead({
                minLength: 0, // TODO Don't work for now, waiting for new versions of typeahead
            }, {
                displayKey: 'name',
                limit: 15,
                source: engine.ttAdapter()
            });

            this.$('.twitter-typeahead').hide();

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
            this.ui.$input.typeahead('val', '');
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
                                        .css({ width: '100%'})
                                        .show();

            this.$el.addClass("active");
        },

        deactivate: function () {
            this.ui.$input.css({ display: "none" });
            this.$('.twitter-typeahead').hide();

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
            this.removeLastTaggy();
        },

        /* when the user backspaces into a taggy */
        removeLastTaggy: function () {
            var taggy = this.$taggies().last();
            var text = taggy.text();

            taggy.remove();
            this.announceEdits();
        },

        handleEnter: function (text, e) {
            if (text === "") {
                return;
            }

            e.preventDefault();
            this.createTaggy();
        },

        sanitize: function sanitize (data) {
            // NOP
            return data;
        },
    });
});
