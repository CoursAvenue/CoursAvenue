var _             = require('underscore'),
    LocationStore = require('./stores/LocationStore');
    SubjectStore  = require('./stores/SubjectStore');

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
        if (!SubjectStore.selected_subject && !SubjectStore.selected_root_subject && LocationStore.get('address')) {
            this.navigate(LocationStore.getCitySlug());
        //  /:root_subject_id--:city_id | /danse--paris-12
        } else if (SubjectStore.selected_root_subject && SubjectStore.selected_subject && LocationStore.get('address')) {
            this.navigate(SubjectStore.selected_root_subject.slug + '/' + SubjectStore.selected_subject.slug + '--' + LocationStore.getCitySlug());
        } else if (LocationStore.get('address') && SubjectStore.selected_root_subject) {
            this.navigate(SubjectStore.selected_root_subject.slug + '--' + LocationStore.getCitySlug());
        }
    }.debounce(500)

});

module.exports = SearchPageAppRouter;
