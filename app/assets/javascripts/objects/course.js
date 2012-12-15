(function() {
    'use strict';
    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.Course = new Class({
        loadTemplates: function() {
            this.planning_info_template = Handlebars.compile($('planning-info-template').get('html'));
        },

        initialize: function(course_hash) {
            this.loadTemplates();

            this.course   = course_hash;
            this.planning = course_hash.planning;
            this.price    = course_hash.price;

            this.planning_el = $$('tr[data-course_id=' + this.course.id + ']')[0];

            this.planning_el.addEvent('click', this.show_planning_info);
        },

        show_planning_info: function() {
            planning_info_template(this.planning);
        }

    });
})();
