var ThreadMessage = require("./ThreadMessage");
var Thread = React.createClass({

    componentDidMount: function componentDidMount() {
        if (window.location.hash == ('#thread-' + this.props.thread.get('id'))) {
            $.scrollTo(window.location.hash, { offset: { top: 55 } });
        }
    },

    render: function render () {
        var message;
        if (this.props.thread.get('question')) {
            message = (<ThreadMessage message={this.props.thread.get('question')}
                                      answers={this.props.thread.get('answers')}/>);
        }
        return (
            <section id={'thread-' + this.props.thread.get('id')}>
                {message}
            </section>
        );
    }
});

module.exports = Thread;
