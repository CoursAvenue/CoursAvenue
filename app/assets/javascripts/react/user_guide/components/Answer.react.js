var Answer = React.createClass({

    propTypes: {
        answer: React.PropTypes.object.isRequired,
        select: React.PropTypes.func.isRequired,
    },

    lengthClass: function lengthClass () {
        switch(this.props.nb_answers) {
            case 1: return 'one-whole';
            case 2: return 'one-half';
            case 3: return 'one-third';
            case 4: return 'one-half';
            case 5:
              return (this.props.index < 3 ? 'one-third' : 'one-half');
            case 6: return 'one-third';
        }
    },

    render: function render () {
        var style = {}
        if (this.props.answer.image) {
            style["backgroundImage"] = "url(" + this.props.answer.image + ")";
        }

        return (
            <div className={ this.lengthClass() + ' palm-soft--top palm-block cursor-pointer black-curtain__fading-on-hover bg-position-top bg-cover relative text--center white v-middle palm-one-whole flexbox__item height-35vh' }
                onClick={ this.props.select } style={ style }>
                <div className='black-curtain north west one-whole absolute'></div>
                <div className='f-weight-600 soft-half--sides one-whole relative'>
                    <div className='text--center alpha palm-delta'>{ this.props.answer.content }</div>
                </div>
            </div>
        );
    },
});

module.exports = Answer;
