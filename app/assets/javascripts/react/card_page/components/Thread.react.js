var ThreadMessage = require("./ThreadMessage");
var Thread = React.createClass({

    render: function render () {
        var message;
        if (this.props.thread.get('question')) {
            message = (<ThreadMessage message={this.props.thread.get('question')}
                                      answers={this.props.thread.get('answers')}/>);
        }
        return (
            <section>
                {message}
            </section>
        );
    }
});

module.exports = Thread;
