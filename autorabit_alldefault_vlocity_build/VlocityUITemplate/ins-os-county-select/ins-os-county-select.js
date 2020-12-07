vlocity.cardframework.registerModule.controller('insCountyOsCtrl', ['$scope', '$q', function($scope, $q) { 
        $scope.countyList = [];
        $scope.isZipInvalid = true;
        $scope.isCountySelected = false;
        $scope.isCountySelectable = true;
        $scope.enteredZipCode;

    $scope.init=function(control){
        control.reqTemp=true;
        control.reqTemp=true;
        if($scope.bpTree.response["GetStarted"]["ZipCode"]){
            $scope.enteredZipCode = $scope.bpTree.response["GetStarted"]["ZipCode"];
            $scope.isCountySelected = true;
            $scope.control.countySelect =  $scope.bpTree.response["GetStarted"]["County"];
            $scope.isZipInvalid = false;
            angular.element($('#textinput')[0]).addClass('ng-not-empty ng-dirty');
            $scope.getCounty();
        }
    }

    $scope.getCounty = function() {
        $scope.countyList = [];
        if ($scope.enteredZipCode != null && $scope.enteredZipCode.length === 5) {

            $scope.bpService.GenericInvoke('%vlocity_namespace%.DefaultDROmniScriptIntegration', 
            'invokeOutboundDR','{"DRParams":{"zipCode":"'+$scope.enteredZipCode+'"},"Bundle":"DRGetCounty"}',
            '{"useQueueableApexRemoting":false}').then(function(result){         
                    result = result.replace(/&quot;/g, "\"");
                        result = JSON.parse(result);
                        console.log("I am here",result);
                        if(Array.isArray(result.OBDRresp)){
                            $scope.countyList = result.OBDRresp;
                             console.log("I am here if",$scope.countyList);
                        }else {
                            $scope.countyList[0] = result.OBDRresp;
                            console.log("I am here else",$scope.countyList);
                        }
                        //result.OBDRresp["ZipCode"]=scope.enteredZipCode;
                        $scope.bpTree.response["GetStarted"]["ZipCode"]=$scope.enteredZipCode;
                       // $scope.bpTree.response.NewAccountDetails["ZipCode-Block"]=result.OBDRresp;
                        $scope.isZipInvalid = !$scope.isCountySelectable;
                        if (typeof $scope.countyList != 'undefined' && $scope.countyList != null && $scope.countyList.length > 0) {
                            console.log("inside type of test");
                            $scope.isCountySelected = true;
                            $scope.control.countySelect = $scope.countyList[0];
                            $scope.isZipInvalid = false;
                            $scope.bpTree.response["GetStarted"]["County"]=$scope.control.countySelect;
                        }
            });

          
        } else {
            $scope.isZipInvalid = true;
        }
    }
    $scope.setCounty = function(countySelect) {
        // $scope.bpTree.response.groupProfile.RatingArea = countySelect.Rating_Area__c;
        console.log("countySelect",countySelect);
        $scope.isCountySelected = true;
        $scope.bpTree.response["GetStarted"]["County"]=countySelect;
    }

}]);