authentication = ($localStorage, $http, $rootScope, $q, $location, API_URL) ->
    GCM_SENDER_ID = 745476177629
    getGCMToken = ->
        $q(resolve, reject) ->
            if $localStorage.gcmToken
                resolve($localStorage.gcmToken)
            else
                google.gcm.register [GCM_SENDER_ID], (token) ->
                    $localStorage.gcmToken = token
                    resolve($localStorage.gcmToken)

    useCredentials = (data) ->
        $localStorage.authToken = data.authToken if data.authToken
        $http.defaults.headers.common['Session-Id'] = data.sessionId
        $http.defaults.headers.common['Authorization'] = "Grindr3 #{data.sessionId}"
        $rootScope.profileId = data.profileId
        $rootScope.$emit('authenticated', data.xmppToken)

    login:
        $q(resolve, reject) ->
            unless $localStorage.authToken or ($localStorage.email and $localStorage.password)
                reject('no login credentials')
                return
            getGCMToken().then (token) ->
                params = {email: $localStorage.email, token: token}
                $http.post API_URL + 'sessions',
                    authToken: $localStorage.authToken
                    email: $localStorage.email
                    password: if !$localStorage.authToken then $localStorage.password else undefined
                    token: token
                .success (data) ->
                    useCredentials(data)
                    resolve()
                .error ->
                    $localStorage.authToken = null
                    reject('Login error')
                    

    signup: (email, password, dateOfBirth) ->
        $q(resolve, reject) ->
            getGCMToken.then (token) ->
                $http.post API_URL + '/users',
                    birthday: Date.parse(dateOfBirth)
                    email: email
                    password: password
                    optIn: false
                    token: token
                .success (data) -> useCredentials(data); resolve()
                .error(reject)
                    

fuckr.factory('authentication', ['$localStorage', '$http', '$rootScope', '$q', '$location', 'API_URL', authenticateFactory])
