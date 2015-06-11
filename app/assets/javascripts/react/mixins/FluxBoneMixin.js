module.exports = function (state_name) {
    return {
        componentDidMount: function componentDidMount () {
            this.state[state_name].on('all', this.delegateForceUpdate);
        },

        componentWillUnmount: function componentWillUnmount () {
            this.state[state_name].off('all', this.delegateForceUpdate);
        },

        delegateForceUpdate: function delegateForceUpdate () {
            this.forceUpdate()
        },
    };
};
