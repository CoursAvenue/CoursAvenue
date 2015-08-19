var Card = React.createClass({
    render: function render () {
        var classes = this.props.classes +
            " search-page-card soft-half palm-one-whole lap-one-third inline-block v-top";

        return (
            <div onMouseEnter={ this.props.onMouseEnter }
                 onMouseLeave={ this.props.onMouseLeave }
                 onClick={ this.props.onClick }
                 className={ classes }>
                <div className="search-page-card__number">{this.props.index}.</div>
                { this.props.children }
            </div>
        );
    },
});

module.exports = Card;
