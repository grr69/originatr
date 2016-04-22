settingsController = ($scope, $http, $localStorage, profiles, uploadImage) ->
    $scope.$storage = $localStorage
    $scope.$storage.localUnits ||= if navigator.locale == 'en-US' then 'US' else 'metric'

    $scope.profile = {}
    profiles.get($localStorage.profileId).then (profile) ->
        $scope.profile = profile

    $scope.updateAttribute = (attribute) ->
        data = {}
        data[attribute] = $scope.profile[attribute]
        unless data == {}
            $http.put('https://primus.grindr.com/2.0/profile', data)

    $scope.deleteProfile = ->
        if confirm("Sure you want to delete your profile")
            $http.delete('https://primus.grindr.com/2.0/profile').then ->
                $scope.logoutAndRestart()

    $scope.$watch 'imageFile', ->
        if $scope.imageFile
            $scope.uploading = true
            uploadImage.uploadProfileImage($scope.imageFile).then(
                -> alert("Image up for review by some Grindr™ monkey")
                -> alert("Image upload failed")
            ).finally -> $scope.uploading = false

weightInput = ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, element, attributes, ngModel) ->
        ngModel.$formatters.push (gramsInput) -> gramsInput / 1000
        ngModel.$parsers.push (kgInput) -> kgInput * 1000

angular
    .module('settingsController', ['file-model', 'uploadImage'])
    .controller('settingsController', ['$scope', '$http', '$localStorage', 'profiles', 'uploadImage', settingsController])
    .directive('weightInput', weightInput)
