/* global define */

define([
    // Application.
    'backbone',
    'views/page/main'
],

function(Backbone, MainPage) {
    'use strict';
    // Defining the application router, you can attach sub routers here.
    var body = $('body')
    var Router = Backbone.Router.extend({
        routes: {
            '': 'index'
        },
        index: function() {
          this._initPage()
          var mainPage = new MainPage()
          body.append(mainPage.render().el)
        },
        _initPage: function() {
          body.empty()
        }
    });

    return Router;

});

