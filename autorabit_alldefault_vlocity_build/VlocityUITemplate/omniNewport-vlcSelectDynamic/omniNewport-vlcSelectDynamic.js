vlocity.cardframework.registerModule.controller('selectController', ['$scope', '$rootScope', '$timeout', 
function($scope, $rootScope, $timeout) {
     $scope.changeMe=function(){
    if($scope.bpTree.response.PrescriptionDrugs.PrescriptionBlock.Prescription==null)return;
    $scope.bpService.GenericInvoke('%vlocity_namespace%.DefaultDROmniScriptIntegration',
      'invokeOutboundDR',
      '{"DRParams":{"searchkey":"'+$scope.bpTree.response.PrescriptionDrugs.PrescriptionBlock.Prescription+'"},"Bundle":"ExtractDrugDosage"}',
      '{"useQueueableApexRemoting":false}').then(function (result) {
        var serRes = JSON.parse(result);
        $scope.child.eleArray[0].propSetMap.options=serRes.OBDRresp;
        console.log("verifing result",$scope.child.eleArray[0].propSetMap.options);
      });
    }

    $scope.$watch('bpTree.response.PrescriptionDrugs.PrescriptionBlock.Prescription', $scope.changeMe, true);
    
    
}]);