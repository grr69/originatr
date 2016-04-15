directives = angular.module('fuckr.directives', ['ngStorage'])

directives.directive 'rememberPassword', ['$localStorage', ($localStorage) ->
    restrict: 'A'
    link: (_, element) ->
        element.bind 'load', ->
            iframeDocument = element.contents()[0]
            emailInput = iframeDocument.querySelector('input[name=email]') #no getElementByName support
            passwordInput = iframeDocument.querySelector('input[name=password]')
            if $localStorage.email and $localStorage.password
                emailInput.value = $localStorage.email
                passwordInput.value = $localStorage.password
                iframeDocument.getElementById('recaptcha_response_field').focus()
            iframeDocument.querySelector('input[name=commit]').addEventListener 'click', ->
                $localStorage.email = emailInput.value
                $localStorage.password = passwordInput.value
]

directives.directive 'nonDraggable', ->
    restrict: 'A'
    link: (_, element) ->
        element.bind 'dragstart', (event) -> event.preventDefault()

directives.directive 'emoji', ->
    runningOnMac = typeof process isnt 'undefined' and process.platform is 'darwin'
    useOpenSansEmoji = (_, element) -> element.css({'font-family', 'sans-serif, OpenSansEmoji'})
    restrict: 'A'
    link: if runningOnMac then _.noop else useOpenSansEmoji


directives.directive 'highResSrc', ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.bind 'load', ->
        angular.element(this).attr("src", attrs.highResSrc)

if typeof process != 'undefined' and process.versions['node-webkit']
    directives.directive 'target', ->
        gui = require 'nw.gui'
        window.open = (url, target) ->
            gui.Shell.openExternal(url) if target is '_blank'
        restrict: 'A'
        scope:
            target: '@'
            href: '@'
        link: ($scope, $element) ->
            if $scope.target is '_blank'
                $element.bind 'click', (event) ->
                    event.preventDefault()
                    gui.Shell.openExternal $scope.href
