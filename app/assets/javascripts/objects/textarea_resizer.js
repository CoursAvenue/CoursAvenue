(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Autoresize textareas
     */

    objects.TextareaResizer = new Class({

        initialize: function(textarea, options) {
            this.textarea             = textarea;
            this.default_height       = textarea.getStyle('height') || '50px';
            this.default_scrollheight = parseInt(this.default_height);
            this.attachEvents();
            this.resize();
        },

        attachEvents: function() {
            this.textarea.addEvent('keyup', this.resize.bind(this));
        },

        resize: function(event) {
            this.textarea.style.height = ""; /* Reset the height*/
            this.textarea.style.height = Math.max(this.textarea.scrollHeight, this.default_scrollheight) + "px";
        }
    });
})();

// Initialize all textarea objects
window.addEvent('domready', function() {
    $$('textarea[data-behavior=autoresize]').each(function(textarea) {
        new GLOBAL.Objects.TextareaResizer(textarea);
    });
});
