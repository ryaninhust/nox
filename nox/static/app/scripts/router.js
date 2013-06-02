/* global define */

define([
    // Application.
    'backbone',
    'views/page/main'
],

function(Backbone, MainPage) {
    'use strict';
    // Defining the application router, you can attach sub routers here.
    var pageContainer = $('.container')
    var Router = Backbone.Router.extend({
        routes: {
            '': 'index',
        },
        index: function() {
          this._initPage()
          var mainPage = new MainPage()
          pageContainer.append(mainPage.render().el)
        },
        _initPage: function() {
          pageContainer.empty()
        }
    });

    return Router;

});

