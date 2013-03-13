(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.CourseSearchForm = new Class({

        initialize: function(el, options) {
            this.form           = el;
            this.city_input     = this.form.getElement('[name=city]');
            this.subject        = null;
            this.flash          = new GLOBAL.Objects.Flash('Vous devez choisir une ville.');
            this.location_input = $('location-input');
            this.attachEvents();
            this.cityAjax();
            this.city_slugs = {}
        },

        /////////////////////////////////// Cities AJAX
        cityAjax: function() {
            this.city_request = new Request.JSON({
                url: Routes.cities_path({format: 'json'}),
                onSuccess: function(cities) {
                    var values = [];
                    cities.cities.each(function(city) {
                        this.city_slugs[city.name] = city.slug;
                        values.push(city.name)
                    }.bind(this));
                    this.city_autocomplete.addValues(values);
                }.bind(this)
            });
            this.city_autocomplete = new Autocomplete(this.location_input, {
                srcType : "dom",
                useNativeInterface : false,
                onInput : function(newValue, oldValue) {
                    this.city_request.cancel();
                    this.city_request.get('term=' + newValue);
                }.bind(this)
            });

        },
        attachEvents: function() {
            // Do not submit if the city is not valid
            this.form.addEvent('submit', function() {
                if (this.getCity()) {
                    this.updateFormUrl();
                } else {
                    this.flash.showAndHide();
                    this.location_input.focus();
                    return false;
                }
            }.bind(this));
            //this.city_input.addEvent('change', this.updateFormUrl.bind(this));
            // $('start_date').addEvent('change', function() {
            //     $('end_date').set('value', this.get('value'));
            // });

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
            return this.city_slugs[this.city_input.value];// || this.city_input.value;
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
