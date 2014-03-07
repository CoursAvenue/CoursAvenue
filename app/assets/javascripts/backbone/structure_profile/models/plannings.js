
Daedalus.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Plannings = Backbone.Collection.extend({

        initialize: function (models) {
            this.course_id = models[0].course_id;
        },

        url: function () {
            var structure_id = window.coursavenue.bootstrap.structure.slug;
            var course_id = this.course_id;

            return '/etablissements/' + structure_id + '/cours/' + course_id + '.json';
        },

        parse: function (data) {
            return data.plannings;

        }
    });
});

