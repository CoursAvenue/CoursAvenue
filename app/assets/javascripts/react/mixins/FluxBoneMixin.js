module.exports = function (state_name) {
    return {
        componentDidMount: function componentDidMount () {
            this.state[state_name].on('all', function() {
                this.forceUpdate();
            }.bind(this));
        },
        componentWillUnmount: function componentWillUnmount () {
            this.state[state_name].off('all', function() {
                this.forceUpdate();
            }.bind(this))
        }
    };
};
