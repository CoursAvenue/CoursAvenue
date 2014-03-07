
/* EventTemplate
 * -------------
 *
 * An event template listens to an event and provides the data the event
 * contained to a template.
 *
 * **Usage**:
 *
 * ```html.haml
 * %div{ data: { view: 'EventTemplate', for: 'CoursesAnnounce' }}
 * ```
 *
 *  */
Daedalus.module('Views.EventTemplate.Flavors', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    var ParentView = Daedalus.Views.EventTemplate.EventTemplate;

    Module.Accumulating = ParentView.extend({

        // doctor the update arguments so that they accumulate
        update: function update (data) {
            _.each(this.accumulate_keys, function (key) {
                var prev = this.data[key];
                var curr = data[key];

                if (curr !== undefined) {
                    data[key] = (prev === undefined)? curr : prev + curr;
                }
            });

            ParentView.prototype.update.apply(this, [data]);
        },

        events: {
            'click [data-type=button]': 'fetch'
        },

        fetch: function () {
           this.trigger("fetch:everything"); // everything?
        }
    });

}, undefined);
