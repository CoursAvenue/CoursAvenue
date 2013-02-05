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
            this.attachEvents();
        },

        attachEvents: function() {
            this.city_select_input.addEvent('change', this.updateFormUrl.bind(this));
        },

        getCity: function() {
            return this.city_select_input.get('value');
        },

        // getSubject: function() {
        //     return 'toutes-disciplines'
        // },

        updateFormUrl: function() {
            var url = Routes.city_subjects_path(this.getCity());//, this.getSubject());
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
