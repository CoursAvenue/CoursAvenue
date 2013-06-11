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
        },

        attachEvents: function() {
            var that = this;
            this.textarea.addEvent('keyup', function() {
                this.style.height = "1px";
                if (this.scrollHeight < that.default_scrollheight) {
                    this.style.height = that.default_height;
                } else {
                    this.style.height = (25 + this.scrollHeight) + "px";
                }
            });
        }
    });
})();

// Initialize all textarea objects
window.addEvent('domready', function() {
    $$('textarea[data-behavior=autoresize]').each(function(textarea) {
        new GLOBAL.Objects.TextareaResizer(textarea);
    });
});
