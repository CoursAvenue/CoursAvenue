var Answer = require('./Answer');

var Question = React.createClass({
    propTypes: {
        question: React.PropTypes.object.isRequired,
        next_page: React.PropTypes.func.isRequired,
    },

    selectAnswer: function selectAnswer (answer) {
        return function () {
            AnswerActionCreators.selectAnswer({
                answer_id:   answer.id,
                question_id: this.props.question.id,
            });
            this.props.next_page();
        }.bind(this);
    },

    render: function render () {
        var answers = this.props.question.get('answers').map(function(answer, index) {
            return (
                <Answer answer={ answer } select={ this.selectAnswer(answer) } key={ index } />
            );
        }.bind(this));

        return (
            <div className='section relative one-whole relative white full-screen-item bg-cover'>
              <div className='black-curtain north west one-whole absolute'></div>
              <div className='relative' style={ { paddingBottom: '10vh', paddingTop: 80 } }>
                <h2 className='flush--bottom f-size-big text--center white orange-box soft-half'>
                  { this.props.question.get('content') }
                </h2>
                <div className='grid--full'>
                    { answers }
                </div>
              </div>
            </div>
        );
    },
});

module.exports = Question;
