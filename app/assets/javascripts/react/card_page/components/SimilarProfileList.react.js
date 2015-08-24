var _                   = require('lodash'),
    FluxBoneMixin       = require('../../mixins/FluxBoneMixin'),
    SimilarProfileStore = require('../stores/SimilarProfileStore');

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
        var cities_text;

        if (profile.get('cities_text') && profile.get('cities_text').length > 40) {
            cities_text = profile.get('cities_text').substring(0, 37) + '...'
        } else {
            cities_text = profile.get('cities_text') || '';
        }

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
                                <a href={ Routes.structure_path(profile.get('slug')) } className='muted-link'>{ profile.get('name') }</a>
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

    mixins: [ FluxBoneMixin('similar_profile_store') ],

    getInitialState: function getInitialState () {
        return { similar_profile_store: SimilarProfileStore };
    },

    render: function render () {
        var profiles = SimilarProfileStore.map(function (profile, index) {
            return (
                <SimilarProfile profile={ profile } key={ index } />
            );
        });

        if (_.isEmpty(profiles)) { return false; }

        return (
            <div className='bordered bg-white'>
                <h4 className='flush soft bordered--bottom'>Ces profils pourraient vous intéresser</h4>
                <div className='soft'>
                    { profiles }
                </div>
            </div>
        );
    }
});

module.exports = SimilarProfileList;
