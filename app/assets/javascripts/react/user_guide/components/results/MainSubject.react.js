var MainSubject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object,
    },

    render: function render () {
        if (!this.props.subject) { return false; }

        var style = {
            backgroundColor: this.props.subject.getColor(),
        };

        return (
            <div>
                <div className='soft push--bottom' style={ style } >
                    <h2 className='alpha palm-beta text--center white'>
                        <span className='ff-kameron'>Notre suggestion : { this.props.subject.get('name') }</span>
                    </h2>
                </div>
                <div className='main-container main-container--medium'>
                    <div className='f-weight-bold line-height-1-5 push--bottom soft--sides palm-text--center'>
                        <div className='delta push--bottom'>
                            { this.props.subject.get('guide_description') }
                        </div>
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = MainSubject;
                // <div className='text--center soft--sides'>
                //     <h1>
                //         Notre suggestion: { this.props.subject.get('name') } ( score: { this.props.subject.get('score') } )
                //     </h1>
                //     <p className='delta'>
                //         { this.props.subject.get('guide_description') }
                //     </p>
                // </div>
