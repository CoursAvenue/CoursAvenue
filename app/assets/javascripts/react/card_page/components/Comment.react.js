var Comment = React.createClass({

    render: function render () {
        var avatar;
        // {this.props.comment.get('certified')}
        if (this.props.comment.get('has_avatar')) {
            avatar = (<img src={this.props.comment.get('avatar_url')}
                           className="center-block push-half--bottom rounded--circle"
                           height="80" width="80"/>);
        } else {
            avatar = (<div className="push-half--bottom comment-avatar-80"></div>)
        }
        return (
            <div className="grid push--bottom " itemProp='review' itemScope={true} itemType='http://schema.org/Review'>
                <div className="grid__item palm-one-whole palm-text--left three-twelfths">
                    <div className="text--center">
                        <div className="visuallyhidden--palm">
                            { avatar }
                        </div>
                        <div className="line-height-1-5">
                            <strong>{this.props.comment.get('author_name')}</strong>
                        </div>
                    </div>
                </div>
                <div className="grid__item palm-one-whole nine-twelfths">
                    <h6 className="push-half--bottom">{this.props.comment.get('title')}</h6>
                    <div className="line-height-1-3"
                         dangerouslySetInnerHTML={{__html: this.props.comment.get('simple_format_content') }}>
                    </div>
                    <div itemProp='datePublished'
                         content={this.props.comment.get('created_at_iso')}
                         className="gray-light">
                        {this.props.comment.get('created_at_for_human')}
                    </div>
                    <span title={this.props.comment.get('title')} itemProp='reviewRating' itemScope={true} itemType='http://schema.org/Rating'>
                      <meta itemProp='ratingValue' content={this.props.comment.get('rating') || 5} />
                      <meta itemProp='worstRating' content={1} />
                      <meta itemProp='bestRating' content={5} />
                    </span>
                </div>
            </div>
        );
    }
});

module.exports = Comment;
