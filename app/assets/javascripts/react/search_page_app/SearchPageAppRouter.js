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
        var card_filters = FilterStore.cardFilters();

        // /:city_id | /paris-12
        if (_.isEmpty(card_filters.subject)) {
            this.navigate(card_filters.city.slug);
        //  /:root_subject_id--:city_id | /danse--paris-12
        } else if (card_filters.subject.slug == card_filters.root_subject.slug) {
            this.navigate(card_filters.subject.slug + '--' + card_filters.city.slug);
        } else {
            this.navigate(card_filters.root_subject.slug + '/' + card_filters.subject.slug + '--' + card_filters.city.slug);
        }
    }

});

module.exports = SearchPageAppRouter;
