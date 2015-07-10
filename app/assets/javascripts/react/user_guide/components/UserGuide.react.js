var _                      = require('underscore'),
    StartPage              = require('./StartPage'),
    QuestionStore          = require('../stores/QuestionStore'),
    FluxBoneMixin          = require('../../mixins/FluxBoneMixin'),
    QuestionActionCreators = require('../actions/QuestionActionCreators');
    AnswerActionCreators   = require('../actions/AnswerActionCreators');

var UserGuide = React.createClass({
    mixins: [
        FluxBoneMixin('question_store')
    ],

    propTypes: {
        guide: React.PropTypes.object.isRequired,
        questions: React.PropTypes.array.isRequired,
        answers: React.PropTypes.array.isRequired,
    },

    getInitialState: function getInitialState () {
        return { question_store: QuestionStore };
    },

    componentDidMount: function componentDidMount () {
        this.bootstrap();
    },

    bootstrap: function bootstrap () {
        QuestionActionCreators.populateQuestions(this.props.guide.questions);
        AnswerActionCreators.populateAnswers(this.props.guide.answers);
    },

    render: function render () {
        return (
            <div className='relative overflow-hidden'>
                <StartPage title={ this.props.guide.title }
                     description={ this.props.guide.description }
                  call_to_action={ this.props.guide.call_to_action }
                />
            </div>
        );
    },
});

module.exports = UserGuide;
