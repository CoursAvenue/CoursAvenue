var _             = require('underscore'),
    StartPage     = require('./StartPage'),
    QuestionStore = require('../stores/QuestionStore');

var UserGuide = React.createClass({
    propTypes: {
        guide: React.PropTypes.object.isRequired,
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
