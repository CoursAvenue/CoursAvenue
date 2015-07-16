var _           = require('lodash'),
  AgeDetails    = require('./results/AgeDetails'),
  MainSubject   = require('./results/MainSubject'),
  SubjectList   = require('./results/SubjectList'),
  SubjectStore  = require('../stores/SubjectStore'),
  CourseSearch  = require('./results/CourseSearch'),
  FluxBoneMixin = require('../../mixins/FluxBoneMixin');

var Results = React.createClass({
    mixins: [
        FluxBoneMixin(['subject_store'])
    ],

    getInitialState: function getInitialState () {
        return { subject_store: SubjectStore };
    },

    render: function render () {
      // The store is sorted in ASC order on the score.
      // TODO: Differentiate if the subject is selected or the main result.
      var main_subject   = SubjectStore.last(); // The last.
      var other_subjects = SubjectStore.initial(); // Everything but the last.

      return (
          <div className='section relative one-whole relative full-screen-item bg-cover'>
              <MainSubject subject={ main_subject } />
              <hr />
              <AgeDetails subject={ main_subject } selected_age={ 0 } />
              <hr />
              <CourseSearch subject={ main_subject } />
              <hr />
              <SubjectList subjects={ other_subjects } />
          </div>
      );
    },
});

module.exports = Results;
