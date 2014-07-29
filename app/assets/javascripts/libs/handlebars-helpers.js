/* Handlebars Helpers - Dan Harper (http://github.com/danharper) */

/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */


// usage: {{pluralize collection.length 'quiz' 'quizzes'}}
Handlebars.registerHelper('capitalize', function(string) {
    return _.capitalize(string);
});

// usage: {{pluralize collection.length 'quiz' 'quizzes'}}
Handlebars.registerHelper('pluralize', function(number, single, plural) {
    return ((number == 1 || number == 0) ? single : plural);
});


// usage: {{truncate 'my long text' length}}
Handlebars.registerHelper('truncate', function(text, length) {
    if (!text) { return ''; }
    if (text.length < length) {
        return text;
    } else {
        return text.slice(0, length) + "...";
    }
});

// usage: {{highlight 'all the text' 'word to highlight' length_of_the_truncated_text}}
Handlebars.registerHelper('highlight', function(text, highlight_word, length) {
    highlight_word = GLOBAL.normalizeAccents(highlight_word);
    text           = GLOBAL.normalizeAccents(text);
    var start_ellipsis;
    if (text.length < length) {
        return text;
    } else {
        if ((start_ellipsis = text.toLowerCase().indexOf(highlight_word.toLowerCase())) != -1 && start_ellipsis > 10) {
            start_ellipsis = start_ellipsis - 10; // Starts 10 character before where the word is.
        }
        start_ellipsis = (start_ellipsis === -1 ? 0 : start_ellipsis);
        return (start_ellipsis === 0 ? '' : '...') + text.slice(start_ellipsis, start_ellipsis + length) + "...";
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
        case '!=':
            return (v1 != v2) ? options.fn(this) : options.inverse(this);
        default:
            return options.inverse(this);
    }
});

Handlebars.registerHelper('simple_format', function (text) {
    var carriage_returns = /\r\n?/g,
        paragraphs       = /\n\n+/g,
        newline          = /([^\n]\n)(?=[^\n])/g;

    if (text) {
        text = text.replace(carriage_returns, "\n"); // \r\n and \r -> \n
        text = text.replace(paragraphs, "</p>\n\n<p>"); // 2+ newline  -> paragraph
        text = text.replace(newline, "$1<br/>"); // 1 newline   -> br
        text = "<p>" + text + "</p>";
    }

    return new Handlebars.SafeString(text);
});

Handlebars.registerHelper('unlessEmpty', function (object, options) {
    // Execute the block if object is not empty
    if (_.isEmpty(object)) {
        return options.inverse(this);
    } else {
        return options.fn(this);
    }
});

// See http://stackoverflow.com/a/21915381/900301
function HandlebarsX (expression, options) {
    var fn = function(){}, result;

    // in a try block in case the expression have invalid javascript
    try {
    // create a new function using Function.apply, notice the capital F in Function
    fn = Function.apply(
        this,
        [
            'window', // or add more '_this, window, a, b' you can add more params if you have references for them when you call fn(window, a, b, c);
            'return ' + expression + ';' // edit that if you know what you're doing
        ]
    );
    } catch (e) {
        console.warn('[warning] {{x ' + expression + '}} is invalid javascript', e);
    }

    // then let's execute this new function, and pass it window, like we promised
    // so you can actually use window in your expression
    // i.e expression ==> 'window.config.userLimit + 10 - 5 + 2 - user.count' //
    // or whatever
    try {
        // if you have created the function with more params
        // that would like fn(window, a, b, c)
        result = fn.bind(this)(window);
    } catch (e) {
        console.warn('[warning] {{x ' + expression + '}} runtime error', e);
    }
    // return the output of that result, or undefined if some error occured
    return result;
}


// Ex. of usage: {{#xif " this.name == 'Sam' && this.age === '12' " }}
Handlebars.registerHelper("xif", function (expression, options) {
    return HandlebarsX.apply(this, [expression, options]) ? options.fn(this) : options.inverse(this);
});

// Ex. of usage: {{ hide_contacts description }}
Handlebars.registerHelper("hide_contacts", function (text, options) {
    return GLOBAL.hideContactsInfo(text);
});

// Ex. of usage: {{ simple_format_hide_contacts description }}
Handlebars.registerHelper("simple_format_hide_contacts", function (text, options) {
    return Handlebars.helpers.simple_format(GLOBAL.hideContactsInfo(text));
});

