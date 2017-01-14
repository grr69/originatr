if typeof process != 'undefined' and process.versions['node-webkit']
    #copy-paste/emoji for nw 0.12 on Mac
    if process.versions['node-webkit'] < '0.13' and process.platform == 'darwin'
        gui = require('nw.gui')
        nativeMenuBar = new gui.Menu({ type: "menubar" })
        nativeMenuBar.createMacBuiltin "Fuckr"
        gui.Window.get().menu = nativeMenuBar
 
    fuckr = angular.module 'fuckr', [
        #works on any browser with SOP disabled
        'ngRoute'
        'profiles'
        'profilesController'
        'fuckr.directives'
        #requires node-webkit
        'authenticate'
        'chat'
        'chatController'
        'settingsController'
        'updateLocation'
    ]

    fuckr.config ['$httpProvider', '$routeProvider', '$compileProvider', ($httpProvider, $routeProvider, $compileProvider) ->
        $httpProvider.defaults.headers.common.Accept = '*/*' #avoids 406 error
        $httpProvider.interceptors.push ($rootScope) ->
            responseError: (response) ->
                return if response.status == -1
                message = switch
                    when response.status == 0 then "Can't reach Grindr servers."
                    when response.status >= 500 then "Grindr servers temporarily unavailable (HTTP #{response.status})"
                    else "Unexpected error (HTTP #{response.status}). Check out http://fuckr.me/ for updates."
                alert(message)
                $rootScope.connectionError = true
                
        #login form and controller have been replaced by an iFrame and a webRequest interceptor (see authenticate factory)
        $routeProvider.when('/login', templateUrl: 'views/login.html')
        for route in ['/profiles/:id?', '/chat/:id?', '/settings']
            name = route.split('/')[1]
            $routeProvider.when route,
                templateUrl: "views/#{name}.html"
                controller: "#{name}Controller"

        #whitelist chrome-extension:// href/src for nw 0.13+
        $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|file|mailto|chrome-extension):/)
        $compileProvider.imgSrcSanitizationWhitelist(/^\s*(https?|ftp|file|mailto|chrome-extension):/)
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
        window.addEventListener 'online', ->
            authenticate().then -> $rootScope.connectionError = false
    ]

else #Browsing-only for any browser with SOP disabled
    fuckr = angular.module 'fuckr', ['ngRoute', 'profles', 'profilesController']
    fuckr.config ['$httpProvider', '$routeProvider', ($httpProvider, $routeProvider) ->
        $httpProvider.defaults.headers.common.Accept = '*/*' #avoids 406 error
        $routeProvider.when '/profiles/:id?',
            templateUrl: 'views/profiles'
            controller: 'profilesController'
    ]
