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
        // /:city_id | /paris-12
        if (_.isEmpty(FilterStore.get('subject')) && FilterStore.get('city')) {
            this.navigate(FilterStore.get('city').slug);
        //  /:root_subject_id--:city_id | /danse--paris-12
        } else if (FilterStore.get('root_subject') && FilterStore.get('subject') && FilterStore.get('city')) {
            this.navigate(FilterStore.get('root_subject').slug + '/' + FilterStore.get('subject').slug + '--' + FilterStore.get('city').slug);
        } else if (FilterStore.get('city') && FilterStore.get('subject')) {
            this.navigate(FilterStore.get('subject').slug + '--' + FilterStore.get('city').slug);
        }
    }.debounce(500)

});

module.exports = SearchPageAppRouter;
