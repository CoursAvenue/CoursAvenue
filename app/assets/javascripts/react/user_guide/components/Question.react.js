var Answer               = require('./Answer'),
    AnswerActionCreators = require('../actions/AnswerActionCreators');

var Question = React.createClass({
    propTypes: {
        question: React.PropTypes.object.isRequired,
        next_page: React.PropTypes.func.isRequired,
        index: React.PropTypes.number,
    },

    selectAnswer: function selectAnswer (answer) {
        return function () {
            AnswerActionCreators.selectAnswer({
                answer_id:   answer.id,
                question_id: this.props.question.id,
                question_index: this.props.index,
                answer_index: this.props.question.get('answers').indexOf(answer),
            });
            this.props.next_page();
        }.bind(this);
    },

    render: function render () {
        var first_line_answers = [], second_line_answers = [];
        var nb_answers = this.props.question.get('answers').length;
        _.each(this.props.question.get('answers'), function(answer, index) {
            if (index < 2 || (index == 2 && nb_answers == 3)) {
                first_line_answers.push((
                    <Answer nb_answers={nb_answers} index={index} answer={ answer } select={ this.selectAnswer(answer) } key={ index } />
                ));
            } else {
                second_line_answers.push((
                    <Answer nb_answers={nb_answers} index={index} answer={ answer } select={ this.selectAnswer(answer) } key={ index } />
                ));
            }
        }.bind(this));

        return (
            <div className='section relative one-whole relative white full-screen-item bg-cover'>
              <div className='black-curtain north west one-whole absolute'
                       style={ { backgroundColor: this.props.question.get('color') } }>
              </div>
              <div className='relative'>
                <h2 className='palm-gamma flush--bottom f-size-big text--center white soft'
                        style={ { backgroundColor: this.props.question.get('color') } }>
                  { this.props.question.get('content') }
                </h2>
                <div className='palm-block flexbox'>
                    { first_line_answers }
                </div>
                <div className='palm-block flexbox'>
                    { second_line_answers }
                </div>
              </div>
            </div>
        );
    },
});

module.exports = Question;
