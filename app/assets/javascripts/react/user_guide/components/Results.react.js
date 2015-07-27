var _           = require('lodash'),
  AgeDetails    = require('./results/AgeDetails'),
  MainSubject   = require('./results/MainSubject'),
  SubjectList   = require('./results/SubjectList'),
  SubjectStore  = require('../stores/SubjectStore'),
  AnswerStore   = require('../stores/AnswerStore'),
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
      var main_subject       = SubjectStore.last(); // The last.
      var alternate_subjects = _.rest(_.toArray(SubjectStore.last(6)).reverse()); // Last 5

      // TODO: Remove this.
      var answers = AnswerStore.answers.map(function(answer, index) {
          return (
              <div key={ index }>Question { answer.question } : Reponse { answer.answer }</div>
          );
      });

      var style = {}
      if (main_subject) {
          style['backgroundImage'] = 'url(' + main_subject.get('image') + ')';
      }

      return (
          <div className='section white relative one-whole relative full-screen-item bg-cover' style={ style }>
                <div className='v-middle black-curtain'>
                    <MainSubject subject={ main_subject } />
                </div>
          </div>
      );
    },
});

module.exports = Results;
          // <div className='section white relative one-whole relative full-screen-item bg-cover'
          //          style={ style }>
          //     <div className='main-container mega-soft--ends'>
          //         <MainSubject subject={ main_subject } />
          //         <hr />
          //         <div className='text--center soft--sides'>
          //             <h1> Reponses </h1>
          //             { answers }
          //         </div>
          //         <hr />
          //         <AgeDetails subject={ main_subject } />
          //         <hr />
          //         <CourseSearch subject={ main_subject } />
          //         <hr />
          //         <SubjectList subjects={ alternate_subjects } />
          //     </div>
          // </div>
