window.fuckr = angular.module('fuckr', ['ngRoute', 'ngMap', 'ngStorage'])

fuckr.constant('API_URL', 'https://grindr.mobi/v3/')

fuckr.config ['$httpProvider', '$routeProvider', '$compileProvider', ($httpProvider, $routeProvider, $compileProvider) ->
    $httpProvider.defaults.headers.common.Accept = '*/*' #avoids 406 error
    $httpProvider.interceptors.push ($rootScope) ->
        responseError: (response) ->
            message = switch
                when response.status == 0 then "Can't reach Grindr servers."
                when response.status >= 500 then "Grindr servers temporarily unavailable (HTTP #{response.status})"
                else "Unexpected error (HTTP #{response.status}). Check out http://fuckr.me/ for updates."
            alert(message)
            $rootScope.connectionError = true
            
    for route in ['/login', '/profiles/:id?', '/chat/:id?', '/settings']
        name = route.split('/')[1]
        $routeProvider.when route,
            templateUrl: "views/#{name}.html"
            controller: "#{name}Controller"

    #whitelist chrome-extension:// href/src for nw 0.13+
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|file|mailto|chrome-extension):/)
    $compileProvider.imgSrcSanitizationWhitelist(/^\s*(https?|ftp|file|mailto|chrome-extension):/)
]


fuckr.run ['$location', '$injector', '$rootScope', 'authentication', ($location, $injector, $rootScope, authentication) ->
    $rootScope.runningNodeWebkit = true
    if navigator.onLine
        #ugly: loading every factory with 'authenticated' event listener
        $injector.get(factory) for factory in ['profiles', 'chat']
        authentication.login().then(
            -> $location.path('/profiles/')
            -> $location.path('/login')
        )
        window.addEventListener 'offline', -> $rootScope.connectionError = true
    else
        alert('No Internet connection')
    window.addEventListener 'online', -> window.location.reload('/')
]

#copy-paste/emoji for nw 0.12 on Mac
if process.versions['node-webkit'] < '0.13' and process.platform == 'darwin'
    gui = require('nw.gui')
    nativeMenuBar = new gui.Menu({ type: "menubar" })
    nativeMenuBar.createMacBuiltin "Fuckr"
    gui.Window.get().menu = nativeMenuBar

