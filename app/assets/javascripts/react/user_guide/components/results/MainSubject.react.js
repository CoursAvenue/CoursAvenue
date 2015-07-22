var MainSubject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object,
    },

    render: function render () {
        if (!this.props.subject) { return false; }
        return (
                <div className='text--center soft--sides'>
                    <h1>
                        Notre suggestion: { this.props.subject.get('name') } ( score: { this.props.subject.get('score') } )
                    </h1>
                    <p className='delta'>
                        { this.props.subject.get('guide_description') }
                    </p>
                </div>
        );
    },
});

module.exports = MainSubject;
