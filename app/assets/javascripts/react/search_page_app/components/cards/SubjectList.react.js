var _       = require('underscore'),
    Subject = require('./Subject.react');

SubjectList = React.createClass({
    propTypes: {
        subjectList: React.PropTypes.array.isRequired
    },

    render: function render () {
        if (_.isEmpty(this.props.subjectList)) {
            return false;
        }

        var subjectNodes = this.props.subjectList.map(function(subject, index) {
            return (
                <Subject subject={ subject } key={ index } />
            );
        });

        return (
            <div>
                { subjectNodes }
            </div>
        )
    },
});

module.exports = SubjectList;
