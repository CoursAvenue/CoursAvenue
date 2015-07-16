var AgeDetails = React.createClass({
    propTypes: {
        subject: React.PropTypes.object,
        selected_age: React.PropTypes.number
    },

    render: function render () {
        if (!this.props.subject || !this.props.selected_age) { return false; }

        var details = this.props.subject.get('age_details')[this.props.selected_age];

        if (!details) { return (false); }

        return (
            <div>
                <h1>{ this.props.selected_age.title }</h1>
                <p>{ this.props.selected_age.description }</p>
            </div>
        );
    },
});

module.exports = AgeDetails;
