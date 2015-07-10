var Question = React.createClass({
    propTypes: {
        question: React.PropTypes.object.isRequired,
        next_page: React.PropTypes.func.isRequired,
    },

    selectAnswer: function selectAnswer () {
        this.props.next_page();
    },

    render: function render () {
        return (
            <div className='section relative one-whole relative white full-screen-item bg-cover'>
              <div className='flexbox full-screen-item soft'>
                <div className='black-curtain north west one-whole absolute'></div>
                <div className='push--top soft--top one-whole flexbox__item'>
                  <div className='v-middle relative'>
                    <h1 className='flush soft--top text--center f-size-really-big'>
                      { this.props.question.get('content') }
                    </h1>
                    <hr className=' push-half--ends main-container main-container--medium' />
                  </div>
                </div>
              </div>
            </div>
        );
    },
});

module.exports = Question;
