module.exports = function (state_name) {
    return {
        componentDidMount: function componentDidMount () {
            if (_.isString(state_name)) {
                this.state[state_name].on('all', this.delegateForceUpdate);
            } else if (_.isArray(state_name)) {
                _.each(state_name, function(state) {
                    this.state[state].on('all', this.delegateForceUpdate);
                }, this);
            }
        },

        componentWillUnmount: function componentWillUnmount () {
            if (_.isString(state_name)) {
                this.state[state_name].off('all', this.delegateForceUpdate);
            } else if (_.isArray(state_name)) {
                _.each(state_name, function(state) {
                    this.state[state].off('all', this.delegateForceUpdate);
                }, this);
            }
        },

        delegateForceUpdate: function delegateForceUpdate () {
            this.forceUpdate();
        },
    };
};
