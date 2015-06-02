var _           = require('underscore'),
    FilterStore = require('./stores/FilterStore');

var SearchPageAppRouter = Backbone.Router.extend({

    // routes: {
    //   ':root_subject_id/:subject_id--:city_id' : 'navigate'
    //   ':root_subject_id--:city_id'
    //   ':city_id'
    // },

    initialize: function initialize () {
        _.bindAll(this, 'updateUrl');
    },

    updateUrl: function updateUrl () {
        var planning_filters = FilterStore.getPlanningFilters();

        // /:city_id | /paris-12
        if (_.isEmpty(planning_filters.subject)) {
            this.navigate(planning_filters.city.slug);
        //  /:root_subject_id--:city_id | /danse--paris-12
        } else if (planning_filters.subject.slug == planning_filters.root_subject.slug) {
            this.navigate(planning_filters.subject.slug + '--' + planning_filters.city.slug);
        } else {
            this.navigate(planning_filters.root_subject.slug + '/' + planning_filters.subject.slug + '--' + planning_filters.city.slug);
        }
    }

});

module.exports = SearchPageAppRouter;
