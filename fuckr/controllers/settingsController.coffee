settingsController = ($scope, $http, $localStorage, profiles, uploadImage) ->
    $scope.$storage = $localStorage
    $scope.$storage.localUnits ||= if navigator.locale == 'en-US' then 'US' else 'metric'

    $scope.profile = {}
    profiles.get($localStorage.profileId).then (profile) ->
        $scope.profile = profile

    $scope.updateProfileAttribute = (attribute) ->
        data = {}
        data[attribute] = $scope.profile[attribute]
        unless data == {}
            $http.put('https://primus.grindr.com/2.0/profile', data)

    $scope.$watch 'imageFile', ->
        if $scope.imageFile
            $scope.uploading = true
            uploadImage.uploadProfileImfuckrSettingsage($scope.imageFile).then(
                -> alert("Image up for review by some Grindr™ monkey")
                -> alert("Image upload failed")
            ).finally -> $scope.uploading = false

angular
    .module('settingsController', ['file-model', 'uploadImage'])
    .controller('settingsController', ['$scope', '$http', '$localStorage', 'profiles', 'uploadImage', settingsController])
