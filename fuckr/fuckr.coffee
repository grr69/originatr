if typeof process != 'undefined' and process.versions['node-webkit']
    #copy/paste and emoji on OS X
    if process.platform == 'darwin'
        gui = require('nw.gui')
        nativeMenuBar = new gui.Menu({ type: "menubar" })
        nativeMenuBar.createMacBuiltin "Fuckr"
        gui.Window.get().menu = nativeMenuBar

    fuckr = angular.module 'fuckr', [
        #works on any browser with SOP disabled
        'ngRoute'
        'profiles'
        'profilesController'
        #requires node-webkit
        'authenticate'
        'chat'
        'chatController'
        'updateLocation'
        'updateProfileController'
    ]


    fuckr.config ['$httpProvider', '$routeProvider', ($httpProvider, $routeProvider) ->
        $httpProvider.defaults.headers.common.Accept = '*/*' #avoids 406 error
        $httpProvider.interceptors.push ($rootScope) ->
            responseError: (response) ->
                message = switch
                    when response.status == 0 then "Can't reach Grindr servers."
                    when response.status >= 500 then "Grindr servers temporarily unavailable (HTTP #{response.status})"
                    else "Unexpected error (HTTP #{response.status}). Check out http://fuckr.me/ for updates."
                alert(message)
                $rootScope.connectionError = true
                
        #login form and controller have been replaced by an iFrame and a webRequest interceptor (see authenticate factory)
        $routeProvider.when('/login', templateUrl: 'views/login.html')
        for route in ['/profiles/:id?', '/chat/:id?', '/updateProfile']
            name = route.split('/')[1]
            $routeProvider.when route,
                templateUrl: "views/#{name}.html"
                controller: "#{name}Controller"
    ]


    fuckr.run ['$location', '$injector', '$rootScope', 'authenticate', ($location, $injector, $rootScope, authenticate) ->
        $rootScope.runningNodeWebkit = true
        if navigator.onLine
            #ugly: loading every factory with 'authenticated' event listener
            $injector.get(factory) for factory in ['profiles', 'chat', 'updateLocation']
            authenticate().then(
                -> $location.path('/profiles/')
                -> $location.path('/login')
            )
            window.addEventListener 'offline', -> $rootScope.connectionError = true
        else
            alert('No Internet connection')
        window.addEventListener 'online', -> window.location.reload('/')
    ]

else #Browsing-only for any browser with SOP disabled
    fuckr = angular.module 'fuckr', ['ngRoute', 'profles', 'profilesController']
    fuckr.config ['$httpProvider', '$routeProvider', ($httpProvider, $routeProvider) ->
        $httpProvider.defaults.headers.common.Accept = '*/*' #avoids 406 error
        $routeProvider.when '/profiles/:id?',
            templateUrl: 'views/profiles'
            controller: 'profilesController'
    ]
