(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Autoresize textareas
     */

    objects.TextareaResizer = new Class({

        initialize: function(textarea, options) {
            this.textarea             = textarea;
            this.default_height       = textarea.getStyle('height') || '50px';
            this.default_scrollheight = parseInt(this.default_height);
            this.attachEvents();
            this.resize();
        },

        attachEvents: function() {
            this.textarea.addEvent('keyup', this.resize.bind(this));
        },

        resize: function(event) {
            this.textarea.style.height = "1px";
            if (this.textarea.scrollHeight < this.default_scrollheight) {
                this.textarea.style.height = this.default_height;
            } else {
                this.textarea.style.height = (25 + this.textarea.scrollHeight) + "px";
            }
        }
    });
})();

// Initialize all textarea objects
window.addEvent('domready', function() {
    $$('textarea[data-behavior=autoresize]').each(function(textarea) {
        new GLOBAL.Objects.TextareaResizer(textarea);
    });
});
