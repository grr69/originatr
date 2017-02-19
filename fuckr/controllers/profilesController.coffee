profilesController = ($scope, $interval, $localStorage, $routeParams, $window, $injector, profiles, pinpoint) ->
    #left part: filter form and thumbnails
    defaultStorage =
        location:
            name: 'San Francisco, CA'
            lat: 37.7833
            lon: -122.4167
            geohash: '9q8yyq4zsjse'
        filters:
            photoOnly: true
        fuckrVersion: 2.0.0
    $scope.$storage = $localStorage.$default(defaultStorage)
    #unless $scope.$storage.fuckrVersion
    #    $scope.$storage = _.extend(defaultStorage, conversations: $scope.$storage.conversations)

    $scope.refresh = ->
        filters = $scope.$storage.filters

        if $scope.view == 'thumbnails'
            profiles.nearby($scope.$storage.location).then (profiles) ->
                $scope.nearbyProfiles = profiles
        else if $scope.view == 'map'
            pinpoint.everyoneAround().then (locations) ->
                $scope.locations = locations

    $scope.changeFilter = (filterName) ->
        filterValue = $scope.$storage.filters[filterName]
        if filterValue
            $scope.$storage.filters["#{filterName}Ids"] = [filterValue]
        else
            delete $scope.$storage.filters["#{filterName}Ids"]
        $scope.refresh()

    $scope.$watch 'view', (view) ->
        $scope.locations = []
        $scope.refresh()
    $scope.view = 'thumbnails'
    $interval($scope.refresh, 420000)

    autocomplete = new google.maps.places.Autocomplete(document.getElementById('location'))
    google.maps.event.addListener autocomplete, 'place_changed', ->
        place = autocomplete.getPlace()
        $scope.$storage.location.name = place.formatted_address
        if place.geometry
            $scope.$storage.location.lat = place.geometry.location.lat()
            $scope.$storage.location.lon = place.geometry.location.lng()
            #$scope.$storage.location.geohash = Geohash.encode($scope.$storage.location.lat, $scope.$storage.location.lon, 12)
            $scope.refresh()

    #right part: detailed profile view
    $scope.open = (id) ->
        profiles.get(id).then (profile) ->
            $scope.profile = profile
    $scope.open(parseInt($routeParams.id)) if $routeParams.id

    $scope.markerClicked = ->
        $scope.open(parseInt(this.id))

    $scope.isNearbyProfile = (id) ->
        _.findWhere($scope.nearbyProfiles, {profileId: id})

    $scope.pinpoint = (id) ->
        $scope.pinpointing = true
        pinpoint.oneGuy(id).then(
            (location) ->
                $scope.pinpointing = false
                url = "https://maps.google.com/?q=loc:#{location.lat},#{location.lon}"
                $window.open(url, '_blank')
            -> $scope.pinpointing = false
        )

    $scope.block = ->
        $injector.get('chat').block($scope.profile.profileId)
        $scope.nearbyProfiles = $scope.nearbyProfiles.filter (profile) ->
            profile.profileId isnt $scope.profile.profileId
        delete $scope.profile

    #managedFields.then (response) -> $scope.managedFields = response.data.fields
    #only included in v3 managed-fields
    $scope.sexualPositions = ['', 'Top', 'Bottom', 'Versatile', 'Vers Bottom', 'Vers Top', 'Oral Only']

gramToLocalUnit = ($localStorage) ->
    (grams) ->
        if !grams
            ''
        else if $localStorage.localUnits == 'US'
            "#{(grams / 453.6).toPrecision(3)}lbs"
        else
            "#{(grams / 1000.0).toPrecision(3)}kg"

cmToLocalUnit = ($localStorage) ->
    (cm) ->
        if !cm
            ''
        else if $localStorage.localUnits == 'US'
            inches = Math.round(cm * 0.3937)
            "#{Math.floor(inches / 12)}' #{inches % 12}\""
        else
            "#{(cm / 100).toPrecision(3)}m"

mToLocalUnit = ($localStorage) ->
    (m) ->
        if !m
            ''
        else if $localStorage.localUnits == 'US'
            (m*0.000621371).toPrecision(3) + ' miles'
        else
            (m/1000).toPrecision(3) + 'km'

lastTimeActive = ->
    (timestamp) ->
        minutes = Math.floor((new Date() - timestamp) / 60000)
        hours = Math.floor(minutes / 60)
        if minutes <= 5 then "Active Now"
        else if minutes < 60 then "Active #{minutes} mins ago"
        else if hours == 1 then "Active 1 hour ago"
        else if hours < 24 then "Active #{hours} hours ago"
        else if hours < 48 then "Active yesterday"
        else "Active #{Math.floor(hours / 24)} days ago"

fuckr
    .filter('gramToLocalUnit', ['$localStorage', gramToLocalUnit])
    .filter('cmToLocalUnit', ['$localStorage', cmToLocalUnit])
    .filter('mToLocalUnit', ['$localStorage', mToLocalUnit])
    .filter('lastTimeActive', lastTimeActive)
    #.factory('managedFields', managedFields)
    .controller 'profilesController',
               ['$scope', '$interval', '$localStorage', '$routeParams', '$window', '$injector', 'profiles', 'pinpoint', profilesController]
