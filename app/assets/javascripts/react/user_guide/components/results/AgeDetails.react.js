var _             = require('lodash'),
    AnswerStore   = require('../../stores/AnswerStore'),
    FluxBoneMixin = require('../../../mixins/FluxBoneMixin');

var AgeDetails = React.createClass({
    propTypes: {
        subject: React.PropTypes.object,
    },

    mixins: [
        FluxBoneMixin(['answer_store'])
    ],

    getInitialState: function getInitialState () {
        return { answer_store: AnswerStore };
    },

    renderAll: function renderAll () {
        if (!this.props.subject) { return false; }
        var ages = this.props.subject.get('advices').map(function(age, index) {
            return (
                <div key={ index }>
                    <h1>{ age.title }</h1>
                    <p>{ age.content }</p>
                </div>
            );
        });

        return (
            <div className='main-container main-container--medium'>
                { ages }
            </div>
        );
    },

    render: function render () {
        var age = AnswerStore.selectedAge();
        if (!age) { return this.renderAll(); }

        var selected_age = _.findWhere(this.props.subject.get('advices'), { id: age.id });

        return (
            <div>
                <h1>{ selected_age.title }</h1>
                <p>{ selected_age.content }</p>
            </div>
        );
    },
});

module.exports = AgeDetails;
