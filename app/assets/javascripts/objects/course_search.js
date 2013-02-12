(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.CourseSearchForm = new Class({

        initialize: function(el, options) {
            this.form              = el;
            this.city_select_input = this.form.getElement('[name=city]');
            this.subject           = null;
            this.attachEvents();
        },

        attachEvents: function() {
            this.city_select_input.addEvent('change', this.updateFormUrl.bind(this));
            $('start_date').addEvent('change', function() {
                $('end_date').set('value', this.get('value'));
            });

            $$('#dropped-options-subject .subject-element').addEvent('click', function(event) {
                var title = $$('#dropped-options-subject .dropped-title')[0];
                $$('#dropped-options-subject .subject-element').removeClass('selected');
                $$('#dropped-options-subject ul').hide();
                event.target.addClass('selected');
                title.set('text', event.target.get('data-name'));
                this.setSubject(event.target.get('data-id'));
                this.updateFormUrl();
            }.bind(this));

        },

        getCity: function() {
            return this.city_select_input.get('value');
        },

        setSubject: function(subject_slug) {
            this.subject = subject_slug
        },
        getSubject: function(subject_slug) {
            return this.subject;
        },

        updateFormUrl: function() {
            if (this.getSubject() === null) {
                var url = Routes.city_subjects_path(this.getCity());
            } else {
                var url = Routes.city_subject_path(this.getCity(), this.getSubject());
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
