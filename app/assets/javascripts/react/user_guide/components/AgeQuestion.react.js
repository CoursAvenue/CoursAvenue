var Answer               = require('./Answer'),
    AnswerStore          = require('../stores/AnswerStore'),
    AnswerActionCreators = require('../actions/AnswerActionCreators');

var AgeQuestion = React.createClass({
    propTypes: {
        next_page: React.PropTypes.func.isRequired,
        image: React.PropTypes.string,
    },

    selectAge: function selectAge (age) {
        return function () {
            AnswerActionCreators.selectAge({ age: age });
            this.props.next_page();
        }.bind(this);
    },

    render: function render () {
        var ages = AnswerStore.getAges();

        var answers = ages.map(function(age, index) {
            return <Answer answer={ age } select={ this.selectAge(age.id) } key={ index } />
        }.bind(this));

        var style = {}
        if (this.props.image) {
            style["backgroundImage"] = "url(" + this.props.image + ")";
        }

        return (
            <div className='section relative one-whole relative white full-screen-item bg-cover'
                     style={ style }>
              <div className='black-curtain north west one-whole absolute'></div>
              <div className='relative' style={ { paddingBottom: '10vh', paddingTop: 80 } }>
                <h2 className='flush--bottom f-size-big text--center white orange-box soft-half'>
                    Enfin, quel âge a votre enfant ?
                </h2>
                <div className='grid--full'>
                    { answers }
                </div>
              </div>
            </div>
        );
    }
});

module.exports = AgeQuestion;
