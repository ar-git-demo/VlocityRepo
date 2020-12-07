vlocity.cardframework.registerModule
    .controller('npViaProfileController',
                ['$scope', '$rootScope', '$timeout', function($scope, $rootScope, $timeout) {
                    
        var self = this;
        $scope.image = "";
        /** Storing the profile image in npProfileImageSrc**/
        $scope.npProfileImageSrc = function()
        {
            $("#npProfileImage").html($scope.image);
        }
    }]);