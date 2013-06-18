(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.CourseSearchForm = new Class({

        initialize: function(el, options) {
            this.form           = el;
            this.subject        = null;
            this.location_input = $('location-input');
            this.base_url       = this.form.get('action');
            this.attachEvents();
        },

        attachEvents: function() {
            this.form.addEvent('submit', function() {
                this.updateFormUrl();
            }.bind(this));

        },

        setSubject: function(subject_slug) {
            this.subject = subject_slug
        },
        getSubject: function(subject_slug) {
            return this.subject;
        },

        updateFormUrl: function() {
            if (this.getSubject() === null) {
                var url = this.base_url;
            } else {
                var url = '/disciplines/' + this.getSubject() + this.base_url;
            }
            this.form.set('action', url);
        }
    });
})();


// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=course-search-form]').each(function(el) {
        new GLOBAL.Objects.CourseSearchForm(el);
    });
});
