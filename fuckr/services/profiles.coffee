#gets, caches and blocks profiles
profiles = ($http, $q, $rootScope, API_URL) ->
    profileCache = {}

    blocked = []
    $rootScope.$on 'authenticated', ->
        $http.get(API_URL + 'me/blocks').then (response) ->
            blocked = _.union(response.blockedBy, response.blocking)

    return {
        nearby: (location) ->
            deferred = $q.defer()
            geohash = Geohash.encode(location.lat, location.lon, 12)
            $http.get("#{API_URL}locations/#{geohash}/profiles/online=true").then (response) ->
                profiles = _.reject response.profiles, (profile) ->
                    _.contains(blocked, profile.profileId)

                for profile in profiles when not profileCache[profile.profileId]
                    profileCache[profile.profileId] = profile
                deferred.resolve(profiles)
            deferred.promise

        get: (id) ->
            if profileCache[id]
                $q.when(profileCache[id])
            else
                deferred = $q.defer()
                $http.post(API_URL + 'profiles', {targetProfileIds: [id]}).then (response) ->
                    deferred.resolve(response.profiles[0])
                deferred.promise

        blockedBy: (id) ->
            blocked.push(id)
            delete profileCache[id]

        block: (id) ->
            self = this
            $http.post("#{API_URL}blocks/#{id}").then ->
                self.blockedBy(id)

        isBlocked: (id) -> _.contains(blocked, id)
    }



fuckr.factory('profiles', ['$http', '$q', '$rootScope', 'API_URL', profiles])
    
