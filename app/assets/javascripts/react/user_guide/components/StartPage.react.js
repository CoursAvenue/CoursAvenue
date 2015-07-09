var StarPage = React.createClass({
    propTypes: {
        title:          React.PropTypes.string.isRequired,
        description:    React.PropTypes.string.isRequired,
        call_to_action: React.PropTypes.string.isRequired
    },

    start: function start (event) {
        debugger
    },

    render: function render () {
        return (
            <div>
                <h1>{ this.props.title }</h1>
                <p>{ this.props.description }</p>
                <h3>{ this.props.call_to_action }</h3>
                <button onClick={ this.start }>{ "C'est parti !" }</button>
            </div>
        );
    },
});

module.exports = StarPage;

