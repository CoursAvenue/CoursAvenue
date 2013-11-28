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


// usage: {{truncate 'my long text' length}}
Handlebars.registerHelper('truncate', function(text, length) {
    if (text.length < length) {
        return text;
    } else {
        return text.slice(0, length) + "...";
    }
});



Handlebars.registerHelper('ifCond', function (v1, operator, v2, options) {

    switch (operator) {
        case '&&':
            return (v1 && v2) ? options.fn(this) : options.inverse(this);
        case '||':
            return (v1 || v2) ? options.fn(this) : options.inverse(this);
        case '==':
            return (v1 == v2) ? options.fn(this) : options.inverse(this);
        case '===':
            return (v1 === v2) ? options.fn(this) : options.inverse(this);
        case '<':
            return (v1 < v2) ? options.fn(this) : options.inverse(this);
        case '<=':
            return (v1 <= v2) ? options.fn(this) : options.inverse(this);
        case '>':
            return (v1 > v2) ? options.fn(this) : options.inverse(this);
        case '>=':
            return (v1 >= v2) ? options.fn(this) : options.inverse(this);
        default:
            return options.inverse(this);
    }
});
