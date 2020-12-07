vlocity.cardframework.registerModule.controller('insSearchTest', ['$scope', '$rootScope', '$timeout', function($scope, $rootScope, $timeout) {
    var className = '%vlocity_namespace%.DefaultDROmniScriptIntegration';            
    var classMethod = 'invokeOutboundDR';
    $scope.searchResult = null;
    $scope.showTable = false;
    $scope.hideWarningInitially = false;

    $scope.searchData = function(key){
        $scope.showTable = true;
        $scope.showWarningInitially = true;
        if(!key){
            $scope.showTable = false;
            $scope.showWarningInitially = false;
            return;
        }
        var inputMap = {DRParams:{Key:key},Bundle:"GlobalSearch"};
        $scope.bpService.GenericInvoke(className, classMethod, angular.toJson(inputMap),'{}').then(function(result){
            let parsedData = JSON.parse(result);
            console.log("parsedData ",parsedData);
            $scope.searchResult = [];
            if(!parsedData && !parsedData.OBDRresp && !parsedData.OBDRresp.Accounts && !parsedData.OBDRresp.Leads && parsedData.OBDRresp.Accounts[0].Type == "Person Account" && parsedData.OBDRresp.Leads[0].Type == "Leads"){
                $scope.showTable = false;
                return;
            }
            JSON.parse(result).OBDRresp.Accounts.map(function(item){
                $scope.searchResult.push(item);
            });
            JSON.parse(result).OBDRresp.Leads.map(function(item){
                $scope.searchResult.push(item);
            });

            console.log("result",$scope.searchResult);

        });
    }
    
    $scope.selectProspect = function(data, value){

        if(value){
            $scope.bpTree.response.prospectId = data.Id;
            $scope.bpTree.response.prospectType = data.Type;
        }
    }

    
}]);