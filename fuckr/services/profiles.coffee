#gets, caches and blocks profiles
profiles = ($http, $localStorage, $q, $rootScope, API_URL) ->
    blocked = []
    $rootScope.$on 'authenticated', ->
        $http.get(API_URL_31 + 'me/blocks').then (response) ->
            blocked = _.union(response.blockedBy, response.blocking)

    return {
        nearby: (location) ->
            deferred = $q.defer()
            geohash = Geohash.encode(location.lat, location.lon, 12)
            filterParams = _.map $localStorage.filters, (value, key) ->
                "#{key}=#{encodeURIComponent(value)}" if value
            $http.get("#{API_URL_4}locations/#{geohash}/profiles/?#{_.compact(filterParams).join('&')}").then (response) ->
                profiles = _.reject response.data.profiles, (profile) ->
                    _.contains(blocked, profile.profileId)
                deferred.resolve(profiles)
            deferred.promise

        get: (id) ->
            deferred = $q.defer()
            $http.get("#{API_URL_4}profiles/#{id}").then (response) ->
                deferred.resolve(response.data.profiles[0])
            deferred.promise

        blockedBy: (id) ->
            blocked.push(id)

        block: (id) ->
            $http.post("#{API_URL_31}me/blocks/#{id}").then => @blockedBy(id)

        isBlocked: (id) -> _.contains(blocked, id)
    }



fuckr.factory('profiles', ['$http', '$localStorage', '$q', '$rootScope', 'API_URL', 'API_URL_31', 'API_URL_4', profiles])
