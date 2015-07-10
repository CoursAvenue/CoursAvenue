var _                      = require('underscore'),
    StartPage              = require('./StartPage'),
    Question               = require('./Question'),
    Results                = require('./Results'),
    QuestionStore          = require('../stores/QuestionStore'),
    FluxBoneMixin          = require('../../mixins/FluxBoneMixin'),
    QuestionActionCreators = require('../actions/QuestionActionCreators');
    AnswerActionCreators   = require('../actions/AnswerActionCreators');

var UserGuide = React.createClass({
    mixins: [
        FluxBoneMixin([ 'question_store' ])
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

    componentDidUpdate: function componentDidUpdate (prevProps, prevState) {
        $('#fullpage').fullpage({ controlArrows: false });
        $.fn.fullpage.setMouseWheelScrolling(false);
        $.fn.fullpage.setKeyboardScrolling(false);
    },

    bootstrap: function bootstrap () {
        QuestionActionCreators.populateQuestions(this.props.guide.questions);
        AnswerActionCreators.populateAnswers(this.props.guide.answers);
    },

    nextPage: function nextPage () {
        console.log('next page');
        $.fn.fullpage.moveSectionDown();
    },

    render: function render () {
        var questions = QuestionStore.map(function(question, index) {
            return (
                <Question question={ question } next_page={ this.nextPage } key={ index } />
            );
        }.bind(this));

        return (
            <div id='fullpage' className='relative overflow-hidden'>
                <StartPage title={ this.props.guide.title }
                       next_page={ this.nextPage }
                     description={ this.props.guide.description }
                  call_to_action={ this.props.guide.call_to_action }
                />
                { questions }
                <Results />
            </div>
        );
    },
});

module.exports = UserGuide;
