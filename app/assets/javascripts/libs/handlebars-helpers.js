/* Handlebars Helpers - Dan Harper (http://github.com/danharper) */

/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */


// usage: {{pluralize collection.length 'quiz' 'quizzes'}}
Handlebars.registerHelper('pluralize', function(number, single, plural) {
    return (number === 1) ? single : plural;
});

// usage: {{localizeDate date 'short'}}
Handlebars.registerHelper('localizeDate', function(date, format) {
    return I18n.l('date.formats.short', new Date(date));
});
