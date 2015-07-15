var MainSubject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object,
    },

    render: function render () {
        if (!this.props.subject) { return false; }
        return (
            <div className='main-container mega-soft--ends'>
                <div className='text--center soft--sides'>
                    <h1>
                        Notre suggestion: { this.props.subject.get('name') }
                    </h1>
                </div>
                <p className='delta'>
                    { this.props.subject.get('guide_description') }
                </p>
            </div>
        );
    },
});

module.exports = MainSubject;
