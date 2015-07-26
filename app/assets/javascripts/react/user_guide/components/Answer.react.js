var Answer = React.createClass({
    propTypes: {
        answer: React.PropTypes.object.isRequired,
        select: React.PropTypes.func.isRequired,
    },

    render: function render () {
        var style = {}
        if (this.props.answer.image) {
            style["backgroundImage"] = "url(" + this.props.answer.image + ")";
        }

        return (
            <div className='cursor-pointer black-curtain__fading-on-hover bg-position-top bg-cover relative text--center white grid__item one-half palm-one-whole height-35vh'
                onClick={ this.props.select } style={ style }>
              <div className='black-curtain north west one-whole absolute'></div>
              <div className='f-weight-600 soft-half--sides absolute west one-whole quizz-question-text palm-text--milli'
                       style={ { marginTop: 'auto' } } >
                <div className='text--center alpha palm-delta'>{ this.props.answer.content }</div>
              </div>
            </div>
        );
    },
});

module.exports = Answer;
