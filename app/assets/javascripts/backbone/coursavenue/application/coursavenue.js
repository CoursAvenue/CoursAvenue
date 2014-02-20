
/* this file simply creates a top level Module in which Lib can live */

CoursAvenue = new Backbone.Marionette.Application({ slug: 'coursavenue' });

$(document).ready(function() {
    CoursAvenue.start({});
});

// Data Mining
// -----------
//
// In order to begin building a profile for a given user even before
// they have registered on the site, the DataMining module provides
// the Visitor model. Every time the user interacts with a marked
// element, the visitor object will gather the relevant data (field
// contents, etc...) and save it to the server side on page changes.
//
// **data-api**
//
// To mark an element for the visitor, add the `data-gather` attribute.
CoursAvenue.module('DataMining', function(Module, App, Backbone, Marionette, $, _, Fingerprint, undefined) {

    Module.Visitor = Backbone.Model.extend({
        url: '/visitors.json',

        initialize: function initialize (options) {
            _.bindAll(this, "collect");

            this.set("fingerprint", new Fingerprint().get());
        },

        // given an array of name, value pairs collect
        // adds them as attributes. The attribute for
        // any given name stores the frequency with which
        // that name data was chosen by the user. If,
        // for example, a user frequently search Paris,
        // we may have,
        //
        //  `visitor.get("address_name") === [["Paris", 4], ["Nice", 1]]`
        collectPairs: function collectPairs (pairs) {
            _.each(pairs, this.collect);
        },

        collect: function collect (pair) {
            if (pair.value == "") {
                return;
            }

            var data = this.get(pair.name) || { }; // a hash like { "paris": 8, "nice": 1 }

            // check for the pair.value
            if (_.has(data, pair.value)) {
                data[pair.value] += 1;
            } else {
                data[pair.value] = 1;
            }

            this.set(pair.name, data);
        },

        addComment: function addComment (comment) {
            var comments = this.get("comments") || [];
            comment.submitted = (comment.submitted)? true : false;
            comments.push(comment);

            this.set("comments", comments);
        }
    });

    Module.addInitializer(function dataMiningInitializer () {
        var visitor = new Module.Visitor();

        $("form[data-gather]").on("submit", function collectPairsOnSubmit (e) {
            visitor.collectPairs($(this).serializeArray());
        });

        $("form[data-recover-comment]").on("submit", function markSubmitted () {
            $(this).data("submitted", true);
        });

        // when the page unloads, we want to save the visitor
        window.onbeforeunload = function beforeUnloadCallback (e) {
            $("form[data-recover-comment]").each(function recoverUnsubmittedForm () {
                var form_data = $(this).serializeArray(),
                    comment = {
                        data: form_data,
                        submitted: $(this).data("submitted")
                    };

                visitor.addComment(comment);
            });

            visitor.save();
        }
    });

}, Fingerprint, undefined);
