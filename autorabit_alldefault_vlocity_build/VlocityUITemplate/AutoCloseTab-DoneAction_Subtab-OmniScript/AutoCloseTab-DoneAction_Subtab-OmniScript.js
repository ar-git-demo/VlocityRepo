vlocity.cardframework.registerModule.controller('DoneController', ['$scope', '$window', function($scope, $window) {

    $scope.closePrimaryTab = function() {
        var parentMessage = {
            message:'omni:cancelGoBack', // use this to close the SubTab
            //message: 'actionLauncher:closePrimaryTab' // use this to close PrimaryTab
        };
        console.log("this is the iFrame window ", window.parentIFrame);
        window.parentIFrame.sendMessage(parentMessage);
    }
}]);