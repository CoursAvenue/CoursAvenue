(function() {
    'use strict';
    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.Course = new Class({

        Implements: Options,

        options: {
            course_info_el: 'course-info',
            course_info_template_el: 'course-info-template'
        },

        /*
         * Loads handlbars template associated to the view and associated elements
         */
        loadTemplatesAndElements: function() {
            this.course_info_template = Handlebars.compile($(this.options.course_info_template_el).get('html'));
            this.course_info_el = $(this.options.course_info_el);
        },

        initialize: function(course_hash, options) {
            this.setOptions(options);
            this.loadTemplatesAndElements();

            this.course   = course_hash;
            this.planning = course_hash.planning;
            this.price    = new GLOBAL.Objects.Price(course_hash.price);

            this.planning_el = $$('tr[data-course-id=' + this.course.id + ']')[0];

            this.planning_el.addEvent('click', this.show_course_info_and_price.bind(this));
        },

        show_course_info_and_price: function(event) {
            $$('#planning-schedule tr').removeClass('selected');
            event.event.currentTarget.addClass('selected');
            this.course_info_el.set('html', this.course_info_template(this.planning));
            GLOBAL.Scroller.toElement(this.course_info_el);
            this.price.render();
        }

    });
})();
