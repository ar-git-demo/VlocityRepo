vlocity.cardframework.registerModule.controller('insCoveragesOsCtrl', ['$scope', '$rootScope', '$timeout', function($scope, $rootScope, $timeout) {
    'use strict';
    
    $scope.bindProducts = function(products) {
        console.info(products);
        $scope.productsList = products;
        baseCtrl.prototype.vlocOSInsConfigProductSet = products;
        console.info('$scope.productsList', $scope.productsList);
    };
    
    $scope.$watch('bpTree.response.MedicalProducts', function() {
        console.info($scope.bpTree.response.MedicalProducts);
    });
    
    $scope.getRates = function(product) {
        console.info(product);
        
        if($scope.bpTree.response.targetSource == 'Quoting'){
            var className = '%vlocity_namespace%.IntegrationProcedureService';
            var classMethod = 'INS_Rating';  
            
            if(className && classMethod) {    
                var inputMap = {};
                inputMap.Input = [];
                $scope.bpTree.response.censusDetails.map(function(member){
                	inputMap.Input.push({
                    	Age : moment().diff(member.dob, 'years'),
                		PlanType : product.Type,
                		ProductId : product.PlanId,
                		RatingArea : 1
                	})
                });
                console.info(inputMap);
                $scope.bpService.GenericInvoke(className, classMethod, angular.toJson(inputMap), '{}').then(function(result){
                        let ratingsData = (JSON.parse(result));
                        console.info(ratingsData);
                        product.TotalPrice = ratingsData.IPResult[0].aggregationResults.TotalPrice;
                });
            }
        }
        else{
            product.TotalPrice = product.Price;
        }
        
        
    }
}]);