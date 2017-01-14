updateLocation = ($rootScope, $http, $localStorage, $interval) ->
    updateLocationFunction = ->
        $http.put 'https://primus.grindr.com/2.0/location',
            lat: $localStorage.grindrParams.lat
            lon: $localStorage.grindrParams.lon
            profileId: $localStorage.profileId
    firstTime = true
    $rootScope.$on 'authenticated', ->
        $interval updateLocationFunction, 90000 if firstTime
        firstTime = false
angular
    .module('updateLocation', [])
    .service('updateLocation', ['$rootScope', '$http', '$localStorage', '$interval', updateLocation])
