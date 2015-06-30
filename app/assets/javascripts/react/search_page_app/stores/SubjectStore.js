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
                this.selected_group_subject = payload.data;
                this.selected_root_subject  = null;
                this.selected_subject       = null;
                break;
            case ActionTypes.SELECT_ROOT_SUBJECT:
                this.selected_root_subject = payload.data;
                if (!this.selected_group_subject) { this.setSelectedGroupSubject(); }
                //SearchPageDispatcher.waitFor([FilterStore.dispatchToken]);
                var associated_group_subject = this.getGroupSubjectFromRootSubjectSlug(payload.data.slug);
                // If root subjects are not loaded, we load them.
                if (!associated_group_subject.root_subjects) {
                    this.loadRootSubjects(associated_group_subject);
                }
                this.loadChildSubjects(payload.data);
                break;
            case ActionTypes.SELECT_SUBJECT:
                this.selected_subject = payload.data;
                this.setSelectedRootSubject();
                break;
            case ActionTypes.SEARCH_FULL_TEXT:
                this.full_text_search = payload.data;
                break;
            case ActionTypes.UNSET_FILTER:
                this.unsetFilter(payload.data);
                break;
        }
    },

    unsetFilter: function unsetFilter (filter_to_unset) {
        // Change subject_panel_to show regarding the filter we unset
        // If we unset root subject, we can't show child subject panel because we don't have
        // root subject information
        switch(filter_to_unset) {
            case 'group_subject':
                this.selected_group_subject = null;
                this.selected_root_subject  = null;
                this.selected_subject       = null;
                break;
            case 'root_subject':
                this.selected_root_subject = null;
                this.selected_subject = null;
                break;
            case 'subject':
                this.selected_subject = null;
                break;
        }
        this.trigger('change');
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
    },

    setSelectedGroupSubject: function setSelectedGroupSubject () {
        var group_subject = this.getGroupSubjectFromRootSubjectSlug(this.selected_root_subject.slug);
        this.selected_group_subject = group_subject;
    },

    setSelectedRootSubject: function setSelectedRootSubject () {
        var data = { hitsPerPage: 5, facets: '*', facetFilters: 'slug:' + this.selected_subject.slug }
        AlgoliaSearchUtils.searchSubjects(data).then(function(content){
            this.selected_root_subject = { slug: content.hits[0].root, name: content.hits[0].root_name };
            this.setSelectedGroupSubject();
            this.loadRootSubjects(this.selected_group_subject);
            this.loadChildSubjects(this.selected_root_subject);
            this.trigger('change');
        }.bind(this)).catch(function(error) {
            this.error   = true;
            this.trigger('change');
        }.bind(this));
    }

});

// the Store is an instantiated Collection; a singleton.
module.exports = new SubjectStore();