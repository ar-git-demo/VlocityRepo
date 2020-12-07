vlocity.cardframework.registerModule.controller('insOsSmallGroupPlanSelectionCtrl1', ['$scope', '$rootScope', '$timeout', '$q', '$document', '$sldsModal', function($scope, $rootScope, $timeout, $q, $document, $sldsModal) {
    'use strict';
    const cartPageSize = 3;
    let bpTreeResponse;
    let scp;
    let remotePageSize;
    let remoteRespCount = 0;
    $scope.currencyCode = '$';
    if (baseCtrl.prototype.$scope.bpTree.propSetMap.currencyCode) {
        $scope.currencyCode = baseCtrl.prototype.$scope.bpTree.propSetMap.currencyCode;
    } else if (baseCtrl.prototype.$scope.bpTree.oSCurrencySymbol) {
        $scope.currencyCode = baseCtrl.prototype.$scope.bpTree.oSCurrencySymbol;
    }

    // Template initialization
    /**
     * @param {Object} baseCtrl OS baseCtrl
     * @param {Object} control Element control
     */
    $scope.insSelectionInit = function(baseCtrl, control) {
        console.log("I am step 2 template");
        console.log('baseCtrl',baseCtrl);
        console.log('control',control);
        // OS dataJSON object
        bpTreeResponse = baseCtrl.$scope.bpTree.response;
        // OS scope
        scp = baseCtrl.$scope;
        
        
        // Determines minimum number of plans that should be added to the page each time you request more
        remotePageSize = control.propSetMap.remoteOptions.pageSize;
        // This key is defined in the OS Script Configuration JSON
        const insSgpsKey = 'planSelection';
        // This creates a custom node in the dataJSON to track plan selections across multiple OS steps
         bpTreeResponse[insSgpsKey] = bpTreeResponse[insSgpsKey] || {};
         $scope.insSgpsNode = bpTreeResponse[insSgpsKey];
        // $scope.insSgpsNode = {};
        $scope.insSgpsNode.selectedPlansMap = $scope.insSgpsNode.selectedPlansMap || {};
        $scope.insSgpsNode.compareSelectMap = {};

        //getdata from quote plan
        console.log("Records pre",$scope.bpTree.response.productConfigurationDetail.records);
        
        
        // Initialize data on the first OS step this template is used
        // if (!$scope.insSgpsNode.cartPlans) {
        //     $scope.insSgpsNode.cartPlans = [];
        //     const selectableItems = control.vlcSI[control.itemsKey];
        //     if (selectableItems.length) {
        //         // Initialization if renewal OS
        //         renewalInit(selectableItems);
        //     }
        // }
        // Remove any compare flags from previous step
        $scope.insSgpsNode.cartPlans = [];
        angular.forEach($scope.insSgpsNode.cartPlans, function(plan) {
            delete plan.vlcCompSelected;
        });
        control[control.name] = {};
        formatCart(0, true);
        // Initial call to get available plans, wrapped in timeout so $rootScope.loading gets set after page is ready

            control[control.name].unselectedNewPlans = [];
            control[control.name].selectedFilters = {};
            //control[control.name].filterAttrValues = remoteResp[control.name].filterAttrValues || {};
            control[control.name].filtersAvailable = _.isEmpty(control[control.name].filterAttrValues) ? false : true;
            //angular.forEach(control[control.name].filterAttrValues, function(filter) {
            //     filter.listOfValues = _.uniq(filter.listOfValues).sort();
            // });
            var newPlans = [];
            try{
                var availableRecords=$scope.bpTree.response.productConfigurationDetail.records;
                for(let i=0;i<availableRecords.length;i++){
                    if(availableRecords[i].Type__c===control.propSetMap.remoteOptions.Type){
                        newPlans.push(availableRecords[i]);
                    }
                }

            }catch(e){console.log("Error Occoured in Medical Init : ",e)}
            console.log("New Plan : ",newPlans)
            formatNewPlans(newPlans, control);
            dataJsonSync();

        //end of initial plan loading
        // $timeout(function() {
        //     remoteInvoke(control)
        //     .then(function(remoteResp) {
                
        //         control[control.name].unselectedNewPlans = [];
        //         control[control.name].selectedFilters = {};
        //         control[control.name].filterAttrValues = remoteResp[control.name].filterAttrValues || {};
        //         control[control.name].filtersAvailable = _.isEmpty(control[control.name].filterAttrValues) ? false : true;
        //         angular.forEach(control[control.name].filterAttrValues, function(filter) {
        //             filter.listOfValues = _.uniq(filter.listOfValues).sort();
        //         });
        //         const newPlans = remoteResp[control.name].ratedProducts.records;
        //         formatNewPlans(newPlans, control);
        //         dataJsonSync();
        //     })
        //     .catch(angular.noop);
        // }, 0);
    };

    // Toggles whether filters dropdown is open
    $scope.toggleFiltersDropdown = function() {
        $scope.openFilterDropdown = !$scope.openFilterDropdown;
    };

    // Toggles selected filter and makes remote call to refresh list of available products
    /**
     * @param {String} filterKey Name of filter type
     * @param {String} value User selected filter value
     * @param {Object} control Element control
     */
    $scope.toggleFilter = function(filterKey, value, control) {
        control[control.name].lastResultReached = false;
        control[control.name].selectedFilters[filterKey] = control[control.name].selectedFilters[filterKey] || [];
        const valueIndex = control[control.name].selectedFilters[filterKey].indexOf(value);
        if (valueIndex > -1) {
            control[control.name].selectedFilters[filterKey].splice(valueIndex, 1);
            if (!control[control.name].selectedFilters[filterKey].length) {
                delete control[control.name].selectedFilters[filterKey];
            }
        } else {
            control[control.name].selectedFilters[filterKey].push(value);
        }
        delete bpTreeResponse.lastRecordId;
        delete control[control.name].lastRecordId;
        remoteInvoke(control)
        .then(function(remoteResp) {
            
            control[control.name].unselectedNewPlans = [];
            const newPlans = remoteResp[control.name].ratedProducts.records;
            formatNewPlans(newPlans, control);
        })
        .catch(angular.noop);
    };

    // Requests additional plans based on lastRecordId
    /**
     * @param {Object} control Element control
     */
    $scope.getMorePlans = function(control) {
        bpTreeResponse.lastRecordId = control[control.name].lastRecordId;
        remoteInvoke(control)
        .then(function(remoteResp) {
            
            const newPlans = remoteResp[control.name].ratedProducts.records;
            formatNewPlans(newPlans, control);
        })
        .catch(angular.noop);
    };

    // Handle renewal plans and new plans in cart
    /**
     * @param {Object} plan Cart plan
     * @param {Object} control Element control
     */
    $scope.toggleCartPlan = function(plan, control) {
        // Flag to determine whether to select or deselect
        const deselecting = plan.selected;
        if (deselecting) {
            if (plan.renewal) {
                // Renewal plans get tracked if they are being deleted
                $scope.insSgpsNode.renewalPlansToDelete[plan.Id] = true;
            } else {
                // Add non-renewal plan back to bottom list
                delete $scope.insSgpsNode.selectedPlansMap[plan.Id];
                $scope.insSgpsNode.cartPlans.splice(plan.originalIndex, 1);
                formatCart($scope.insSgpsNode.displayedCartPlans[0].originalIndex, true);
                control[control.name].unselectedNewPlans.unshift(plan);
            }
        } else {
            // If plan is being renewed nothing needs to be tracked
            delete $scope.insSgpsNode.renewalPlansToDelete[plan.Id];
        }
        plan.selected = !plan.selected;
        dataJsonSync();

        //Add Remove Block message in the UI
        var cantMed = 0;
        var cantDent = 0;
        if( typeof $scope.insSgpsNode.selectedPlansMap != 'undefined'){
            angular.forEach($scope.insSgpsNode.selectedPlansMap, function(selectedPlan){
                if(selectedPlan.Type__c == 'Medical') cantMed ++;
                if(selectedPlan.Type__c == 'Dental') cantDent ++;
            });
        }
        if(cantMed == 1 && plan.Type__c == 'Medical' || cantDent == 1 && plan.Type__c == 'Dental'){
             $scope.bpTree.response.MoreThanOneMedicalSelected = false;
             $scope.bpTree.response.MoreThanOneDentalSelected = false;
           
           
            var total = 0;
             angular.forEach($scope.insSgpsNode.selectedPlansMap, function(selectedPlan){
                total += selectedPlan.Price;
                if(selectedPlan.Type__c == 'Medical'){
                    $scope.bpTree.response.medicalPlanSelectedName = selectedPlan.Name;
                }
                if(selectedPlan.Type__c == 'Dental'){
                $scope.bpTree.response.dentalPlanSelectedName = selectedPlan.Name;
                }
            });
            $scope.bpTree.response.totalSumUp = total;
        }else{
            if(cantMed == 2 || cantDent == 2 ){
                
                $scope.bpTree.response.MoreThanOneDentalSelected = true;
                $scope.bpTree.response.MoreThanOneMedicalSelected = true;
            }
        }

    };

    // Add new plan to cart
    /**
     * @param {Object} plan Selected plan
     * @param {Number} planIndex Index in displayedPlans
     * @param {Object} control Element control
     */
    $scope.addNewPlan = function(plan, planIndex, control) {

        $scope.bpTree.response.MoreThanOneMedicalSelected = false;
        $scope.bpTree.response.MoreThanOneDentalSelected = false;
        plan.selected = true;
        $scope.insSgpsNode.selectedPlansMap[plan.Id] = plan;
        var existMedicalOrDental = false;
        var cantMed = 0;
        var cantDent = 0;
        control[control.name].unselectedNewPlans.splice(planIndex, 1);
        $scope.insSgpsNode.cartPlans.unshift(plan);
        formatCart(0, true);
        dataJsonSync();

        if( typeof $scope.insSgpsNode.selectedPlansMap != 'undefined'){
            angular.forEach($scope.insSgpsNode.selectedPlansMap, function(selectedPlan){
                if(selectedPlan.Type__c == 'Medical') cantMed ++;
                if(selectedPlan.Type__c == 'Dental') cantDent ++;
            });
        }
        if(cantMed == 1 && plan.Type__c == 'Medical' || cantDent == 1 && plan.Type__c == 'Dental'){

            if(plan.Type__c == 'Medical'){
                $scope.bpTree.response.medicalPlanSelectedName = plan.Name;
            }
            if(plan.Type__c == 'Dental'){
                $scope.bpTree.response.dentalPlanSelectedName = plan.Name;
            }
            var total = 0;
             angular.forEach($scope.insSgpsNode.selectedPlansMap, function(selectedPlan){
                total += selectedPlan.Price;
            });
            $scope.bpTree.response.totalSumUp = total;
            $scope.bpTree.response.MoreThanOneMedicalSelected = false;
            $scope.bpTree.response.MoreThanOneDentalSelected = false;


        }else{
            if(cantMed == 2 || cantDent == 2 ){
                 $scope.bpTree.response.MoreThanOneMedicalSelected = true;
                   $scope.bpTree.response.MoreThanOneDentalSelected = true;
            }
        }
     
    };

    // Helper method to display number of selected filters
    $scope.selectedFiltersCount = function(control) {
        let count = 0;
        angular.forEach(control[control.name].selectedFilters, function(array) {
            count += array.length;
        });
        return count;
    };

    // Helper method to display filter checkbox
    /**
     * @param {String} filterKey Filter type
     * @param {String} value Filter value
     */
    $scope.isFilterSelected = function(filterKey, value, control) {
        if (control[control.name].selectedFilters[filterKey] && control[control.name].selectedFilters[filterKey].indexOf(value) > -1) {
            return true;
        }
    };

    // Adds plan to list for compare modal
    /**
     * @param {Object} plan Can be either a renewal or new plan
     */
    $scope.toggleCompareSelect = function(plan) {
        // if (!$scope.insSgpsNode.compareSelectMap[plan.Id]) {
        //     $scope.insSgpsNode.compareSelectMap[plan.Id] = plan;
        //     plan.vlcCompSelected = true;
        // } else {
        //     delete $scope.insSgpsNode.compareSelectMap[plan.Id];
        //     plan.vlcCompSelected = false;
        // }
            if ( !$scope.insSgpsNode.compareSelectMap[plan.Id] ) {
                $scope.insSgpsNode.compareSelectMap[plan.Id] = plan;
                if(Object.keys($scope.insSgpsNode.compareSelectMap).length <= 3){
                    
                    plan.vlcCompSelected = true;
                }else{
                    delete $scope.insSgpsNode.compareSelectMap[plan.Id];
                    plan.vlcCompSelected = false;    
                }
            } else {
                delete $scope.insSgpsNode.compareSelectMap[plan.Id];
                plan.vlcCompSelected = false;
            }
    };

    // Gets called when clicking next/previous directional buttons at top
    /**
     * @param {String} direction Prev or Next
     */
    $scope.paginateItems = function(direction) {
        const currentIndex = $scope.insSgpsNode.displayedCartPlans[0].originalIndex;
        let newIndex = 0;
        if (direction === 'prev') {
            newIndex = currentIndex - cartPageSize;
        } else if (direction === 'next') {
            newIndex = currentIndex + cartPageSize;
        }
        formatCart(newIndex);
    };

    // Count how many cart plans are selected
    $scope.selectedPlansCount = function() {
        let count = 0;
        angular.forEach($scope.insSgpsNode.cartPlans, function(plan) {
            if (plan.selected) {
                count += 1;
            }
        });
        return count;
    };

    //Launch compare modal - right now it is a fixed template but this is exposed js, to-do: use OS modal template
    $scope.openCompareModal = function(plan, control) {
        if (plan) {
            $scope.modalRecords = [plan, plan.originalPlan.records[0]];
            $scope.isSelectable = false;
        } else {
            $scope.modalRecords = _.values($scope.insSgpsNode.compareSelectMap);
            $scope.isSelectable = true;
        }
        $sldsModal({
            backdrop: 'static',
            title: 'Compare Plans',
            scope: $scope,
            showLastYear: true,
            animation: true,
            templateUrl: control.propSetMap.modalHTMLTemplateId,
            show: true
        });
    };

    //Launch compare modal - right now it is a fixed template but this is exposed js, to-do: use OS modal template
    $scope.openDetailModal = function(plan, control) {
        $scope.modalRecords = [plan];//modalProducts = list of product and last years
        $scope.isSelectable = false;
        $sldsModal({
            backdrop: 'static',
            title: 'View Details',
            scope: $scope,
            showLastYear: true,
            animation: true,
            templateUrl: control.propSetMap.modalHTMLTemplateId,
            show: true
        });
    };

    // Toggles plan selection from within compare modal
    /**
     * @param {Object} plan Can be either a renewal or new plan
     * @param {Object} control Element control
     */
    $scope.toggleModalPlan = function(plan, control) {
        if (plan.selected || plan.renewal) {
            $scope.toggleCartPlan(plan, control);
        } else {
            plan.selected = true;
            const unselectedNewPlans = control[control.name].unselectedNewPlans;
            // Find index in new plans to splice and move into cart
            for (let i = 0; i < unselectedNewPlans.length; i++) {
                const newPlan = unselectedNewPlans[i];
                if (plan.Id === newPlan.Id) {
                    $scope.addNewPlan(plan, i, control);
                    break;
                }
            }
        }
    };

    // Initialize data for renewal OS
    /**
    * @param {Object} selectableItems control.vlcSI[control.itemsKey]
    */
    function renewalInit(selectableItems) {
        $scope.insSgpsNode.renewalPlansToDelete = {};
        angular.forEach(selectableItems, function(plan) {
            plan.selected = true;
            plan.renewal = true;
            setTierClass(plan);
            if ($scope.insSgpsNode.renewalPlansToDelete[plan.Id]) {
                plan.selected = false;
            }
        });
        Array.prototype.push.apply($scope.insSgpsNode.cartPlans, selectableItems);
    }

    // Set tier for default icon color
    /**
    * @param {Object} plan
    */
    function setTierClass(plan) {
        try{
            const name = plan.Name || plan.productName;
            if (plan[baseCtrl.prototype.$scope.nsPrefix + 'Tier__c']) {
                plan.tierClass = plan[baseCtrl.prototype.$scope.nsPrefix + 'plan.TierClass__c'].toLowerCase();
            } else if (name.toLowerCase().indexOf('gold') > -1) {
                plan.tierClass = 'gold';
            } else if (name.toLowerCase().indexOf('silver') > -1) {
                plan.tierClass = 'silver';
            } else if (name.toLowerCase().indexOf('bronze') > -1) {
                plan.tierClass = 'bronze';
            }
        }catch(e){console.log("Error Occoured in setTierClass : ",e);}
    };

    // Index cart items
    /**
    * @param {Number} newIndex Starting index of cart plans subset
    * @param {Boolean} [reindex] Flag to refresh original indexes
    */
    function formatCart(newIndex, reindex) {
        if (reindex) {
            angular.forEach($scope.insSgpsNode.cartPlans, function(plan, i) {
                plan.originalIndex = i;
            });
        }
        $scope.insSgpsNode.displayedCartPlans = $scope.insSgpsNode.cartPlans.slice(newIndex, newIndex + cartPageSize);
        $scope.insSgpsNode.prevDisabled = newIndex === 0 ? true : false;
        $scope.insSgpsNode.nextDisabled = newIndex + cartPageSize >= $scope.insSgpsNode.cartPlans.length ? true : false;
    }

    // Dedupes and sets tiers for new plans
    /**
     * @param {Array} newPlans Plans returned from remote method
     * @param {Object} control Element control
     */
    function formatNewPlans(newPlans, control) {
        const newLastRecordId = newPlans ? newPlans[newPlans.length - 1].Id : null;
        if (!newPlans || control[control.name].lastRecordId === newLastRecordId) {
            
            control[control.name].lastResultReached = true;
            remoteRespCount = 0;
            return;
        }
        control[control.name].lastRecordId = newLastRecordId;
        angular.forEach(newPlans, function(plan) {
            if (isNewPlan(plan)) {
                setTierClass(plan);
                control[control.name].unselectedNewPlans.push(plan);
                remoteRespCount += 1;
            }
        });
        if (remoteRespCount < remotePageSize) {
            $scope.getMorePlans(control);
        } else {
            remoteRespCount = 0;
        }
    }

    // Check if new plan is already being tracked
    /**
     * @param {Object} plan
     */
    function isNewPlan(plan) {
        for (let i = 0; i < $scope.insSgpsNode.cartPlans.length; i++) {
            const cartPlan = $scope.insSgpsNode.cartPlans[i];
            if (plan.Id === cartPlan.Id || plan.Id === cartPlan.productId) {
                return false;
            }
        }
        return true;
    }

    // Calls OmniScript buttonClick method, which invokes remote method defined on the Selectable Items action
    /**
     * @param {Object} control Element control} control
     */
    function remoteInvoke(control) {
        const deferred = $q.defer();
        $rootScope.loading = true;
        bpTreeResponse.attributeFilters = control[control.name].selectedFilters;
        scp.buttonClick(bpTreeResponse, control, scp, undefined, 'typeAheadSearch', undefined, function(remoteResp) {
            deferred.resolve(remoteResp);
        });
        return deferred.promise;
    }

    // Keep plan selections in sync across OS steps
    function dataJsonSync() {

        console.log();

        $scope.insSgpsNode.selectedPlans = [];
        angular.forEach($scope.insSgpsNode.selectedPlansMap, function(selectedPlan) {
            $scope.insSgpsNode.selectedPlans.push(selectedPlan);
        });
        // For renewal OS - need to track quote line item ids for deletion from quote
        if (!_.isEmpty($scope.insSgpsNode.renewalPlansToDelete)) {
            $scope.insSgpsNode.unselectedIds = Object.keys($scope.insSgpsNode.renewalPlansToDelete);
        }
    }

    $scope.existInSelected = function(plan){
        if( typeof $scope.bpTree.response.finalList != 'undefined' ){
            var ret = false;

            if(typeof $scope.bpTree.response.finalList.length !== 'undefined' && $scope.bpTree.response.finalList.length > 0){

                for(var i = 0 ; i < $scope.bpTree.response.finalList.length; i++){
                    if($scope.bpTree.response.finalList[i].Id == plan.Id ){
                       
                        plan.Price = $scope.bpTree.response.finalList[i].Price;
                        ret = true;
                        break;
                    }
                }
                return ret;
            }else{
                 console.log('$scope.bpTree.response.finalList.Id: ' , $scope.bpTree.response.finalList.Id);
                 console.log('plan.Id: ' , plan.Id);
                 if($scope.bpTree.response.finalList.Id == plan.Id ){
                     plan.Price = $scope.bpTree.response.finalList.Price;
                     return true;
                 }
            }
           
          
            return ret;
        }else{
            return false;
        }
        console.log('PLna: after' , plan);
    }
    //Custom functionality to add pricing to Plan Medical/Dental Cards - HMSA @author: mdiaz@vlocity.com

    $scope.getProductRating = function(isDental, plan, bpResponse) {
     
               
               
              
                // var className = '%vlocity_namespace%.IntegrationProcedureService';
                // var classMethod = 'Rating_GetMedicalProductRate';  
                // if(className && classMethod) {                     
                //     var inputMap = {
                //         FamilyMembers: bpResponse.AddEditFamilyMember,
                //         productId : plan.Id,
                //         coverageDate: bpResponse.getStarted.CoverageStartDateFormula
                //     };
                //     $scope.medicalData = $scope.bpService.GenericInvoke(className, classMethod, angular.toJson(inputMap), '{}').then(function(result){
                //         $scope.medicalData = JSON.parse(result);            
                //         plan.members = [];
                //         plan.Price = 0;
                //         var membersTemp = [];
                //         var idsMembers = [];
                //         var arrayFamilyReturnedMembers = [];
                //         arrayFamilyReturnedMembers = $scope.medicalData.IPResult.output;
                //         //Check existance of Tobbaco members
                //         if(arrayFamilyReturnedMembers.length == 1  ){
                //             var member = arrayFamilyReturnedMembers[0];
                //             if(member.tobacco == 'Yes'){
                //                 plan.Price = member.tobaccorate;
                //                 arrayFamilyReturnedMembers[0].finalMemberRateValue = arrayFamilyReturnedMembers[0].tobaccorate;
                //             }else{
                //                 plan.Price = member.notobaccorate;
                //                 arrayFamilyReturnedMembers[0].finalMemberRateValue = arrayFamilyReturnedMembers[0].notobaccorate;
                //             }
                //             if(idsMembers.indexOf(member.id) === -1 ) {
                //                 idsMembers.push(member.id);
                //                 plan.members.push(member);
                //             }

                //         }else{
                //             var totalPrice = 0;
                //             var memberTemp = {};
                //             for(var i = 0 ; i < arrayFamilyReturnedMembers.length ; i++){
                //                 if(arrayFamilyReturnedMembers[i].tobacco == 'Yes' ){
                //                     totalPrice += arrayFamilyReturnedMembers[i].tobaccorate;
                //                      arrayFamilyReturnedMembers[i].finalMemberRateValue = arrayFamilyReturnedMembers[i].tobaccorate;
                //                 }else{
                //                     totalPrice += arrayFamilyReturnedMembers[i].notobaccorate;
                //                     arrayFamilyReturnedMembers[i].finalMemberRateValue = arrayFamilyReturnedMembers[i].notobaccorate;
                //                 }
                //                 if(idsMembers.indexOf(memberTemp.id) === -1 ) {
                //                     idsMembers.push(arrayFamilyReturnedMembers[i].id);
                //                     plan.members.push(arrayFamilyReturnedMembers[i]);
                //                 }
                //             }
                //             plan.Price = totalPrice;
                //         }
                //     }).catch(function(err){
                //         console.info("The Error Was...", err)
                //     });   
                // }            

    }
}]);

vlocity.cardframework.registerModule.directive('insOsDropdownHandler', function($document) {
    'use strict';
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            let isFocused = false;
            const dropdownElement = angular.element(element.find('.nds-dropdown')[0]);
            const onClick = function(event) {
                const isChild = dropdownElement.has(event.target).length > 0;
                if (!isChild) {
                    scope.$apply(attrs.insOsDropdownToggle);
                    $document.off('click', onClick);
                    isFocused = false;
                }
            };
            element.on('click', function(e) {
                if (!isFocused) {
                    e.stopPropagation();
                    scope.$apply(attrs.insOsDropdownToggle);
                    $document.on('click', onClick);
                    isFocused = true;
                }
            });
        }
    };
});