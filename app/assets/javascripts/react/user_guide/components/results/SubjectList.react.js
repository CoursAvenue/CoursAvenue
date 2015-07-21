var _                     = require('lodash'),
    SubjectActionCreators = require('../../actions/SubjectActionCreators');

var SubjectList = React.createClass({
    propTypes: {
        subjects: React.PropTypes.array,
    },

    // TODO: When the subject is selected, replace the whole result panel by information about the
    // selected subject.
    selectSubject: function selectSubject (subject) {
        return function () {
            SubjectActionCreators.selectSubject({ slug: subject.slug });
        }.bind(this);
    },

    render: function render () {
        if (!this.props.subjects || _.isEmpty(this.props.subjects)) { return false; }
        var subjects = this.props.subjects.map(function(subject, index) {
            // TODO: Show images and add sexy transition on hover.
            return (
                <div className='cursor-pointer black-curtain__fading-on-hover bg-position-top bg-cover relative text--center grid__item one-fifth palm-one-whole height-150'
                    key={ index } onClick={ this.selectSubject(subject) } >
                    { subject.get('name') }
                </div>
            );
        }.bind(this));

        return (
            <div className='grid text--center'> { subjects } </div>
        );
    },
});

module.exports = SubjectList;
