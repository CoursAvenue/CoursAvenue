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
// To mark a form to be collected on unload add the `data-recover` attribute,
//   with value being the kind of data being recovered (e.g. data-recover=comment)
CoursAvenue.module('DataMining', function(Module, App, Backbone, Marionette, $, _, Fingerprint, undefined) {

    Module.Visitor = Backbone.Model.extend({
        url: Routes.visitors_path({format: 'json'}),

        initialize: function initialize (options) {
            _.bindAll(this, "collect");

            this.set("fingerprint", new Fingerprint().get());
        },

        // @brief given form data from an HTML element,
        // collectPairs tries to add all the data to the
        // visitor in a simple histogram.
        //
        // So, given an array of key value pairs like,
        //
        // ```javascript
        //   [{ "address_name": "Paris", "subject_id": "dance" }]
        // ```
        //
        // and a visitor with properties like,
        //
        // ```javascript
        //   self.get("address_name") === { "Paris": 1, "Nice": 4 };
        //   self.get("subject_id") === { "martial-arts": 2 };
        // ```
        //
        // we expect visitor to have properties like,
        //
        // ```javascript
        //   self.get("address_name") === { "Paris": 2, "Nice": 4 };
        //   self.get("subject_id") === { "martial-arts": 2, "dance": 1 };
        // ```
        //
        // @param the return value of calling `$.serializeArray` on
        //   a form element
        collectPairs: function collectPairs (pairs) {
            _.each(pairs, this.collect);
        },

        // given a hash like { "address_name": "Paris" }, collect
        // looks up a property "address_name" on the visitor, which
        // should be a hash like,
        //
        //   { "Paris": 3, "Nice": 4 }
        //
        // and adds 1 to the score of the entry whose name matches
        // the value of the given pair. If no such entry exists,
        // a new entry is created with a value of 1.
        collect: function collect (pair) {
            if (pair.value == "") {
                return;
            }

            var data = this.get(pair.name) || { }; // a hash like { "paris": 8, "nice": 1 }

            // add or increment the score of the value with the given key
            if (_.has(data, pair.value)) {
                data[pair.value] += 1;
            } else {
                data[pair.value] = 1;
            }

            this.set(pair.name, data);
        },

        // @brief given data from the comments form, along with
        //   a flag indicating whether the form was submitted or not,
        //   addComment adds a comment object the to the array of
        //   comment objects in the visitor's `comments` property.
        //
        // @param comment an object like,
        //
        //   { data: data, submitted: bool }
        //
        // where data is the return value of `$.serializeArray` called
        // on a form element, and submitted is true if an only if that
        // form was submitted before this method call.
        addComment: function addComment (comment) {
            var comments  = this.get("comments") || [],
                submitted = (comment.submitted)? true : false;

            comment           = this.decodeComment(comment.data);
            comment.submitted = submitted;

            comments.push(comment);

            this.set("comments", comments);
        },

        // given the return value of calling `$.serializeArray` on
        // a form element, like
        //
        //   [{ name="field1", value="value1" }, { name="field2", value="value2"}]
        //
        // decodeComment should return an object that has properties for each
        // of the field names, with values being the field values,
        //
        //   { "field1": "value1", "field2": "value2" }
        //
        decodeComment: function decodeComment (comment) {
            return _.inject(comment, function buildCommentObject (memo, field) {
                memo[field.name] = field.value;
                return memo;
            }, {});
        }
    });

    // creates a new visitor and attaches handlers to the marked
    // forms (and potentially other elements) on the page. In addition,
    // the onbeforeunload handler is attached to the window.
    Module.addInitializer(function dataMiningInitializer () {
        var visitor = new Module.Visitor();

        var recoverUnsubmittedForm = function recoverUnsubmittedForm () {
            var form_data = $(this).serializeArray(),
            comment = {
                data: form_data,
                submitted: $(this).data("submitted")? true : false
            };

            visitor.addComment(comment);
        };

        $("form[data-gather]").on("submit", function collectPairsOnSubmit (e) {
            visitor.collectPairs($(this).serializeArray());
        });

        $("form[data-recover=comment]").on("submit", function markSubmitted () {
            $(this).data("submitted", true);
        });

        $(window).unload(function beforeUnloadCallback (e) {
            $("form[data-recover=comment]").each(recoverUnsubmittedForm);

            visitor.save();
        });
    });

}, Fingerprint, undefined);
