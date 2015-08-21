var SimilarProfile = React.createClass({
    image: function image () {
        var profile = this.props.profile;
        if (profile.get('avatar')) {
            return (
                <img className='rounded--circle block center-block bordered' src={ profile.get('avatar') } width={ 60 } height={ 60 } />
            );
        } else {
            return (
                <div className='comment-avatar-60'></div>
            );
        }
    },

    render: function render () {
        var profile = this.props.profile;
        var style = { height: '70px' };
        var cities_text = ''; // truncate profile.get('cities_text') to 40 chars.

        return (
            <div style={ style }>
                <div className='soft-half--sides'>
                    <div className='grid--full' data-similar-profile={ true } data-structure-id={ profile.id }>
                        <div className='grid__item v-middle one-fifth'>
                            <div itemProp='image' content={ profile.get('logo_url') }>
                                { this.image() }
                            </div>
                        </div>
                        <div className='grid__item v-middle four-fifths soft-half--left opacity-hidden-on-hover__wrapper'>
                            <h6 className='hide-for-fout flush line-height-1-5 text-ellipsis'>
                                <a href={ Routes.structure_path(profile.id) } className='muted-link'>{ profile.get('name') }</a>
                            </h6>
                            <div className='hide-for-fout line-height-1-5'>
                                <i> { cities_text } </i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    },
});

var SimilarProfileList = React.createClass({
    render: function render () {
        // var profiles = this.props.structure.get('profiles').map(function (profile, index) {
        var profiles = [].map(function (profile, index) {
            return (
                <SimilarProfile profile={ profile } key={ index } />
            );
        });

        return (
            <div className='bordered bg-white'>
                <h4 className='flush soft bordered--bottom'>Ces profiles pourraient vous intéresser</h4>
                <div className='soft'>
                    { profiles }
                </div>
            </div>
        );
    }
});

module.exports = SimilarProfileList;
