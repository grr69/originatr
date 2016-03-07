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

angular.module('rememberPassword', ['ngStorage'])
       .directive('rememberPassword', ['$localStorage', rememberPassword])
