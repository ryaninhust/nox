(function() {
  define(['app', 'jquery', 'lodash'], function(app, $, _) {
    var MovieInfo;

    return MovieInfo = {
      like: function(e) {
        var target, targetUrl;

        target = $(e.target);
        targetUrl = target.data('url');
        window.open(targetUrl);
        return this;
      },
      "delete": function(e) {
        var id, infoElem, target;

        console.log('movieinfo:delete');
        target = $(e.target);
        infoElem = target.closest('.info');
        id = infoElem.data('id');
        app.movies["delete"](id);
        this.render();
        return this;
      }
    };
  });

}).call(this);
