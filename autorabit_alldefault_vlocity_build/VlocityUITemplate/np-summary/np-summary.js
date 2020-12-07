vlocity.cardframework.registerModule.controller('testCont', ['$scope','$rootScope', function($scope,$rootScope) {
        
             $scope.performActionAndReloadNav = function(action) {
    $scope.performAction(action);
    if ('parentIFrame' in window) {
      $scope.Vlocitynamespace = $rootScope.nsPrefix.replace(/_+/g, '')
        window.parentIFrame.sendMessage({
            message: 'ltng:event',
            event: 'e.'+ $scope.Vlocitynamespace +':vlocityCardEvent',
            params: {
                layoutName: 'np-subnavbar-ins',
                message : {
                    event: 'reload'
                }
            }
        });
    }
};
        
      }]);