// ------------ This file is here until we really need to use more I18n frontend side

I18n = {
    t: function t(i18n_key) {
        return _.reduce(i18n_key.split('.'), function(memo, key) {
            return memo[key];
        }, I18n);
    },
    day_names_from_english: {
        monday: 'lundi',
        tuesday: 'mardi',
        wednesday: 'mercredi',
        thursday: 'jeudi',
        friday: 'vendredi',
        saturday: 'samedi',
        sunday: 'dimanche'
    }
}

