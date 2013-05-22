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
            this.attachEvents();
        },

        attachEvents: function() {
            this.form.addEvent('submit', function() {
                this.updateFormUrl();
            }.bind(this));
            // Handle subject dropdown
            $$('#dropped-options-subject .subject-element').addEvent('click', function(event) {
                // Hide on click
                var title = $$('#dropped-options-subject .dropped-title')[0];
                $$('#dropped-options-subject .subject-element').removeClass('selected');
                $$('#dropped-options-subject ul').hide();
                event.event.currentTarget.addClass('selected');
                title.set('text', event.event.currentTarget.get('data-name'));
                this.setSubject(event.event.currentTarget.get('data-id'));
            }.bind(this));

        },

        getCity: function() {
            return this.city_slugs[this.city_input.value.toLowerCase()] || this.city_input.value;
        },

        setSubject: function(subject_slug) {
            this.subject = subject_slug
        },
        getSubject: function(subject_slug) {
            return this.subject;
        },

        updateFormUrl: function() {
            if (this.getSubject() === null) {
                var url = '/cours';
            } else {
                var url = '/disciplines/' + this.getSubject() + '/cours';
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
