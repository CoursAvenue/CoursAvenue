var _                     = require('lodash'),
    SubjectActionCreators = require('../../actions/SubjectActionCreators');

var SubjectList = React.createClass({
    propTypes: {
        main_subject: React.PropTypes.object,
        subjects: React.PropTypes.array,
    },

    // TODO: When the subject is selected, replace the whole result panel by information about the
    // selected subject.
    selectSubject: function selectSubject (subject) {
        return function () {
            SubjectActionCreators.selectSubject({ slug: subject.get('slug') });
        }.bind(this);
    },

    // TODO: Remove score.
    render: function render () {
        if (!this.props.subjects || _.isEmpty(this.props.subjects)) { return false; }
        var subjects = this.props.subjects.map(function(subject, index) {
            // TODO: Show images and add sexy transition on hover.
            var style = {};
            if (subject.get('image')) {
                style["backgroundImage"] = "url(" + subject.get('image') + ")";
            }
            return (
                <div className='cursor-pointer black-curtain__fading-on-hover bg-position-top bg-cover relative text--center grid__item one-fifth palm-one-whole height-150'
                    key={ index } onClick={ this.selectSubject(subject) } style={ style }>
                    <div className='f-weight-600 soft-half--sides absolute west one-whole quizz-question-text palm-text--milli'
                             style={ { marginTop: 'auto' } } >
                      <div className='text--center white'>{ subject.get('name') } ( score: { subject.get('score') } )</div>
                    </div>
                </div>
            );
        }.bind(this));

        var main_style = {
            backgroundColor: this.props.main_subject.getColor(),
        };

        return (
            <div className='soft push--bottom' style={ main_style }>
                <h2 className='alpha palm-beta text--center white'>
                    <span className='ff-kameron'>Nous vous suggérons aussi :</span>
                </h2>
                <div className='grid text--center'> { subjects } </div>
            </div>
        );
    },
});

module.exports = SubjectList;
