var _                  = require('lodash'),
    Backbone           = require('backbone'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

var Course = Backbone.Model.extend({
    url: function url () {
        if (this.get('type') == 'indexable_card') {
            return Routes.structure_indexable_card_path(this.get('structure_id'), this.get('id'))
        } else {
            return Routes.structure_course_path(this.get('structure_id'), this.get('id'))
        }
    }
});
var CourseStore = Backbone.Collection.extend({
    model: Course,
    url: function url () {
        return Routes.structure_courses_path(this.structure_id);
    },

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
        this.course_cache = {};
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.BOOTSTRAP_COURSE:
                this.add(payload.data);
                break;
            case ActionTypes.POPULATE_COURSES:
                this.loadCourses(payload.data.structure_id);
                break;
            case ActionTypes.POPULATE_INDEXABLE_CARD:
                this.loadIndexableCard(payload.data.structure_id, payload.data.indexable_card_id);
                break;
            case ActionTypes.REMOVE_CARD_TO_FAVORITES:
                this.removeFromFavorites(payload.data);
                break;
            case ActionTypes.ADD_CARD_TO_FAVORITES:
                this.addToFavorites(payload.data);
                break;
        }
    },

    getCourseByID: function getCourseByID (course_id) {
        if (!this.course_cache[course_id]) {
            this.course_cache[course_id] = this.findWhere({ id: course_id });
        }
        return this.course_cache[course_id];
    },

    loadCourses: function loadCourses (structure_id) {
        if (!this.courses_loaded) {
            this.courses_loaded = true;
            this.structure_id = structure_id;
            this.fetch();
        }
    },

    loadIndexableCard: function loadIndexableCard (structure_id, course_id) {
        var course = this.add({ structure_id: structure_id, id: course_id, type: 'indexable_card' });
        course.fetch();
    },

    addToFavorites: function addToFavorites (data) {
        $.ajax({
            url: Routes.structure_indexable_card_favorite_path(
                data.structure_id, data.indexable_card_id, { format: 'json' }
            ),
            type: 'POST',
            success: function success (response) {
                this.first().set('favorited', true);
            }.bind(this),
        });
    },

    removeFromFavorites: function removeFromFavorites (data) {
        $.ajax({
            url: Routes.structure_indexable_card_favorite_path(
                data.structure_id, data.indexable_card_id, { format: 'json' }
            ),
            type: 'DELETE',
            success: function success (response) {
                this.first().set('favorited', false);
            }.bind(this),
        });
    },
});

module.exports = new CourseStore();
