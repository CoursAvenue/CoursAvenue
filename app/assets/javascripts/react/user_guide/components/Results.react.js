var _           = require('lodash'),
  AgeDetails    = require('./results/AgeDetails'),
  MainSubject   = require('./results/MainSubject'),
  SubjectList   = require('./results/SubjectList'),
  SubjectStore  = require('../stores/SubjectStore'),
  AnswerStore   = require('../stores/AnswerStore'),
  CourseSearch  = require('./results/CourseSearch'),
  FluxBoneMixin = require('../../mixins/FluxBoneMixin');

// TODO: Send event to google:
// ga('send', 'event', 'Action', 'message');
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
      var main_subject       = SubjectStore.last(); // The last.
      var alternate_subjects = _.rest(_.toArray(SubjectStore.last(6)).reverse()); // Last 5

      var style = {}
      if (main_subject) {
          style['backgroundImage'] = 'url(' + main_subject.get('image') + ')';
      }

      return (
          <div className='section white relative one-whole relative full-screen-item bg-cover' style={ style }>
                <div className='v-middle black-curtain'>
                    <MainSubject subject={ main_subject } />
                    <AgeDetails  subject={ main_subject } />
                    <SubjectList main_subject={ main_subject } subjects={ alternate_subjects } />
                </div>
          </div>
      );
    },
});

module.exports = Results;
