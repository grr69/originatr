rememberPassword = ($localStorage) ->
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

nonDraggable = ->
    restrict: 'A'
    link: (_, element) ->
        element.bind 'dragstart', (event) -> event.preventDefault()

emoji = ->
    runningOnMac = typeof process isnt 'undefined' and process.platform is 'darwin'
    useOpenSansEmoji = (_, element) -> element.css({'font-family', 'sans-serif, OpenSansEmoji'})
    restrict: 'A'
    link: if runningOnMac then _.noop else useOpenSansEmoji


highResSrc = ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.bind 'load', ->
        angular.element(this).attr("src", attrs.highResSrc)


angular.module('fuckr.directives', ['ngStorage'])
       .directive('rememberPassword', ['$localStorage', rememberPassword])
       .directive('nonDraggable', nonDraggable)
       .directive('highResSrc', highResSrc)
       .directive('emoji', emoji)
