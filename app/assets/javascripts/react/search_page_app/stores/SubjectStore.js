var _                    = require('underscore'),
    Backbone             = require('backbone'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    FilterStore          = require('./FilterStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

var SubjectModel = Backbone.Model.extend({});

var SubjectStore = Backbone.Collection.extend({
    model: SubjectModel,
    selected: false,
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        this.initializeGroupSubjects();
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_GROUP_SUBJECT:
                this.loadRootSubjects(payload.data);
                break;
            case ActionTypes.SELECT_ROOT_SUBJECT:
                //SearchPageDispatcher.waitFor([FilterStore.dispatchToken]);
                var associated_group_subject = this.getGroupSubjectFromRootSubjectSlug(payload.data.slug);
                // If root subjects are not loaded, we load them.
                if (!associated_group_subject.root_subjects) {
                    this.loadRootSubjects(associated_group_subject);
                }
                this.loadChildSubjects(payload.data);
                break;
        }
    },

    initializeGroupSubjects: function initializeGroupSubjects () {
        this.group_subjects = [
            {
                name      : 'Danse, Théâtre & Musique',
                group_id  : 1,
                root_slugs: ["danse", "theatre-scene", "musique-chant"]
                // collection: this.filter(function(subject) { return (group_1.indexOf(subject.get('slug')) != -1)})
            },{
                name      : 'Sports, Yoga & Bien-être',
                group_id  : 2,
                root_slugs: ["sports-arts-martiaux", "yoga-bien-etre-sante"]
                // collection: this.filter(function(subject) { return (group_2.indexOf(subject.get('slug')) != -1)}),
            },{
                name      : 'Arts créatifs',
                group_id  : 3,
                root_slugs: ["deco-mode-bricolage", "dessin-peinture-arts-plastiques"]
                // collection: this.filter(function(subject) { return (group_3.indexOf(subject.get('slug')) != -1)}),
            }
        ]
    },

    getGroupSubjects: function getGroupSubjects () {
        return this.group_subjects;
    },

    getGroupSubject: function getGroupSubject (group_subject_id) {
        return _.find(this.group_subjects, function(group_subject) {
            return group_subject.group_id == group_subject_id;
        }, this);
    },

    getGroupSubjectFromRootSubjectSlug: function getGroupSubjectFromRootSubjectSlug (root_subject_slug) {
        return _.find(this.group_subjects, function(group_subject) {
            return (group_subject.root_slugs.indexOf(root_subject_slug) != -1)
        });
    },

    /*
     * Will load root subjects associated with selected group subject
     */
    loadRootSubjects: function loadRootSubjects (group_subject) {
        var slug_facet = _.map(this.getGroupSubject(group_subject.group_id).root_slugs, function(root_slug) {
            return 'slug:' + root_slug
        });
        var data = { hitsPerPage: 5, facets: '*', facetFilters: '(' + slug_facet.join(',') + ')'}
        AlgoliaSearchUtils.searchSubjects(data).then(function(content){
            this.getGroupSubject(group_subject.group_id).root_subjects = content.hits;
            this.trigger('change');
        }.bind(this)).catch(function(error) {
            this.error   = true;
            this.trigger('change');
        }.bind(this));
    },

    /*
     * Will load root subjects associated with selected group subject
     */
    loadChildSubjects: function loadChildSubjects (root_subject) {
        var data = { hitsPerPage: 6,
                     facets: '*',
                     facetFilters: 'root:' + root_subject.slug,
                     numericFilters: 'depth>0' }
        AlgoliaSearchUtils.searchSubjects(data).then(function(content){
            this.reset(content.hits);
            this.trigger('change');
        }.bind(this)).catch(function(error) {
            this.error   = true;
            this.trigger('change');
        }.bind(this));
    }

});

// the Store is an instantiated Collection; a singleton.
module.exports = new SubjectStore();