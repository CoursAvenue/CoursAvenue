var ThreadMessage = require("./ThreadMessage");
var Thread = React.createClass({

    render: function render () {
        var messages = _.map(this.props.thread.messages, function(message) {
            return message;
        });
        return (
            <section>
                { messages }
                <hr />
            </section>
        );
    }
});

module.exports = Thread;
