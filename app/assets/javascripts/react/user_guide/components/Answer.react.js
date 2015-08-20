var AnswerStore   = require('../stores/AnswerStore'),
    FluxBoneMixin = require('../../mixins/FluxBoneMixin');
var Answer = React.createClass({

    mixins: [
        FluxBoneMixin(['answer_store'])
    ],

    propTypes: {
        answer: React.PropTypes.object.isRequired,
        select: React.PropTypes.func.isRequired,
    },

    getInitialState: function getInitialState () {
        return { answer_store: AnswerStore };
    },

    lengthClass: function lengthClass () {
        switch(this.props.nb_answers) {
            case 1: return 'one-whole';
            case 2: return 'one-half';
            case 3: return 'one-third';
            case 4: return 'one-half';
            case 5: return (this.props.index > 1 ? 'one-third' : 'one-half');
            case 6: return 'one-third';
        }
    },

    render: function render () {
        var check;
        var style = {}
        answer = this.state.answer_store.findWhere({id: this.props.answer.id });
        if (answer.get('selected')) {
            check = (<i className="fa-check fa-4x"></i>)
        }
        if (this.props.answer.image) {
            style["backgroundImage"] = "url(" + this.props.answer.image + ")";
        }

        return (
            <div className={ this.lengthClass() + ' palm-soft--top palm-block cursor-pointer black-curtain__fading-on-hover bg-position-top bg-cover relative text--center white v-middle palm-one-whole flexbox__item height-35vh' }
                onClick={ this.props.select } style={ style }>
                <div className='black-curtain north west one-whole absolute'></div>
                <div className='f-weight-600 soft-half--sides one-whole relative'>
                    <div className='text--center alpha palm-delta'>{ this.props.answer.content }</div>
                    {check}
                </div>
            </div>
        );
    },
});

module.exports = Answer;
