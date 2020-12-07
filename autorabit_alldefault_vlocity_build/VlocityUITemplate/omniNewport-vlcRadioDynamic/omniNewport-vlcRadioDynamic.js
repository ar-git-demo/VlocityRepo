vlocity.cardframework.registerModule.controller('radioDynamic', ['$scope', '$rootScope', '$timeout','$route', 
function($scope, $rootScope, $timeout,$route) {
    $scope.loadOptions=function(parentControl){
      console.log("HIT");
      $scope.parentControl=parentControl;
      $scope.handleChange(parentControl["response"]["PrescriptionTypeAhead-Block"]["PrescriptionTypeAhead"]);
      $scope.$watch("parentControl['response']['PrescriptionTypeAhead-Block']['PrescriptionTypeAhead']", function(newValue, oldValue) {
      console.log("changed",newValue, oldValue);
      $scope.handleChange(newValue);
   }, true);
    }
    var localKey="NULL_KEY"
    $scope.handleChange=function(key){
      if(localKey==key){
        return;
      }
      localKey=key;
    $scope.bpService.GenericInvoke('%vlocity_namespace%.DefaultDROmniScriptIntegration',
      'invokeOutboundDR',
      '{"DRParams":{"searchkey":"'+key+'"},"Bundle":"ExtractDrugDosage"}',
      '{"useQueueableApexRemoting":false}').then(function (result) {
        try{
          var serRes = JSON.parse(result);
          // $scope.child.eleArray[0].propSetMap.options=serRes.OBDRresp;
          console.log("HERE I AM",serRes,serRes.OBDRresp);
          for(let i=0; i<serRes.OBDRresp.dosage.length; i++){
            serRes.OBDRresp.dosage[i].value=serRes.OBDRresp.dosage[i].value+" MG"
          }
          $scope.control.propSetMap.options=serRes.OBDRresp.dosage;
          // if(Object.keys(serRes.OBDRresp).length !== 0){
            
          //   // $scope.options=serRes.OBDRresp;
          // }else{
          //   $scope.control.propSetMap.options=[{"name":"","value":""}]
          // }
          
          // $scope.options=serRes.OBDRresp;
          // $scope.options=serRes.OBDRresp;
          //console.log("verifing result",$scope.child.eleArray[0].propSetMap.options);
        }catch(e){console.log("Error Occored in omniNewport-vlcRadioDynamic template",e);}
        
      });
    }
// angular.element('#appBusyIndicator')
//     $scope.$watch('bpTree.response.PrescriptionDrugs.PrescriptionBlock.Prescription', $scope.changeMe, true);
        // $scope.$watch('bpTree.response.PrescriptionDrugs.PrescriptionBlock', $scope.changeMe, true);

    // $scope.$watch('bpTree.response.PrescriptionDrugs.PrescriptionBlock'
    // , function(newVal,oldVal) {
    //   try{
    //       console.log("Agular watch on ID new",newVal);
    //       console.log("Agular watch on ID old",oldVal);
    //       if(Array.isArray(newVal)){
    //           for(let i=0;i<newVal.length;i++){
    //             if(newVal[i]["PrescriptionTypeAhead-Block"]["PrescriptionTypeAhead"]!==oldVal[i]["PrescriptionTypeAhead-Block"]["PrescriptionTypeAhead"]){
    //               $scope.handleChange(newVal[i]["PrescriptionTypeAhead-Block"]["PrescriptionTypeAhead"]);
    //               return;
    //             }
    //           }
    //       }else{
    //         if(newVal["PrescriptionTypeAhead-Block"]["PrescriptionTypeAhead"]!==oldVal["PrescriptionTypeAhead-Block"]["PrescriptionTypeAhead"]){
    //           $scope.handleChange(newVal["PrescriptionTypeAhead-Block"]["PrescriptionTypeAhead"]);
    //         }
    //     }
    //   }catch(e){console.log("Error Occored in omniNewport-vlcRadioDynamic template listener",e)}
    // },true);
    

}]);