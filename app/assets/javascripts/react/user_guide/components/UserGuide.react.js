var _                      = require('underscore'),
    StartPage              = require('./StartPage'),
    QuestionStore          = require('../stores/QuestionStore'),
    FluxBoneMixin          = require('../../mixins/FluxBoneMixin'),
    QuestionActionCreators = require('../actions/QuestionActionCreators');

var UserGuide = React.createClass({
    mixins: [
        FluxBoneMixin('question_store')
    ],

    propTypes: {
        guide: React.PropTypes.object.isRequired,
    },

    componentDidMount: function componentDidMount () {
        this.bootstrap();
    },

    bootstrap: function bootstrap () {
        QuestionActionCreators.populateQuestions(this.props.guide.questions);
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
