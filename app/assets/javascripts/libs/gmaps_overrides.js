// See: https://github.com/apneadiving/Google-Maps-for-Rails/wiki/Change-handler-behavior
// Converted from CoffeeScript to js with: http://fiddlesalad.com/coffeescript/
var GMapsCoursAvenueBuilder, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

GMapsCoursAvenueBuilder = (function(_super) {
    __extends(GMapsCoursAvenueBuilder, _super);

    function GMapsCoursAvenueBuilder() {
        _ref = GMapsCoursAvenueBuilder.__super__.constructor.apply(this, arguments);
        return _ref;
    }

    GMapsCoursAvenueBuilder.prototype.create_marker = function() {
        var options;
        options = _.extend(this.marker_options(), this.rich_marker_options());
        return this.serviceObject = new RichMarker(options);
    };

    GMapsCoursAvenueBuilder.prototype.rich_marker_options = function() {
        return {
            content: this.args.marker
        };
    };

    GMapsCoursAvenueBuilder.prototype.create_infowindow = function() {
      this.infowindow = new InfoBox(this.args.infowindow);
      google.maps.event.addListener(this.marker.getServiceObject(), 'click', function() {
          // To be triggered after map clicked
          if (this.infowindow.is_closed) {
              this.infowindow.show();
              this.infowindow.is_closed = false;
          } else {
              this.infowindow.close();
              this.infowindow.is_closed = true;
          }
      }.bind(this));
      return this.infowindow;
    };

    return GMapsCoursAvenueBuilder;

})(Gmaps.Google.Builders.Marker);
