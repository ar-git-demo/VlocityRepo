let insSgpsCustomEventName = 'vloc-os-ins-small-group-plan-selection-' + Math.round((new Date()).getTime() / 1000);
let insSgpsLoadedOnce = false;
// Called when template loads
/**
 * @param {Object} bpTree baseCtrl.$scope.bpTree
 * @param {Object} control Element control
 * @param {Object} scp Element scope
 */
baseCtrl.prototype.setSmallGroupPlans = function(bpTree, control, scp) {
    const event = new CustomEvent(insSgpsCustomEventName, {
        detail: {
            bpTreeResponse: bpTree.response,
            insSgpsKey: bpTree.propSetMap.insSgpsKey,
            control: control,
            scp: scp
        }
    });
    document.dispatchEvent(event);
};

vlocity.cardframework.registerModule.controller('insOsDentalPlanSelectionCtrl', ['$scope', '$rootScope', '$timeout', '$q', '$document', '$sldsModal', function($scope, $rootScope, $timeout, $q, $document, $sldsModal) {
    'use strict';
    $document.on(insSgpsCustomEventName, function(e) {
        $scope.insSelectionInit(e.detail);
    });
    const cartPageSize = 3;
    let control;
    let bpTreeResponse;
    let scp;
    let insSgpsNode;

    $scope.currencyCode = '$';
    if (baseCtrl.prototype.$scope.bpTree.propSetMap.currencyCode) {
        $scope.currencyCode = baseCtrl.prototype.$scope.bpTree.propSetMap.currencyCode;
    } else if (baseCtrl.prototype.$scope.bpTree.oSCurrencySymbol) {
        $scope.currencyCode = baseCtrl.prototype.$scope.bpTree.oSCurrencySymbol;
    }

    // Template initialization
    /**
     * @param {Object} config OmniScript objects
     */
    $scope.insSelectionInit = function(config) {
        bpTreeResponse = config.bpTreeResponse;
        control = config.control;
        scp = config.scp;
        console.log('insSelectionInit control', control);
        $scope.unselectedNewPlans = [];
        $scope.cartPlans = [];
        $scope.selectedPlansMap = {};
        $scope.selectedFilters = {};
        // Used by the remote method to apply selected filters
        bpTreeResponse.attributeFilters = $scope.selectedFilters;
        $scope.compareSelectMap = {};
        // This is defined in the OS Script Configuration JSON
        //const insSgpsKey = config.insSgpsKey;
        const insSgpsKey = 'planSelection';
        // This creates a special node in the dataJSON to track plan selections across multiple OS steps
        bpTreeResponse[insSgpsKey] = bpTreeResponse[insSgpsKey] || {};
        insSgpsNode = bpTreeResponse[insSgpsKey];
        if (insSgpsNode.selectedPlans) {
            // Initialization for multistep OS
            multistepInit();
        }
        const selectableItems = control.vlcSI[control.itemsKey];
        if (selectableItems.length) {
            // Initialization for renewal OS
            renewalInit(selectableItems);
        }
        $scope.collapsedCart = false;
        formatCart(0, true);
        // Initial call to get available plans, wrapped in timeout so $rootScope.loading gets set after page is ready
        $timeout(function() {
            remoteInvoke()
            .then(function(remoteResp) {
                console.log('insSelectionInit remoteResp', remoteResp);
                $scope.filterAttrValues = remoteResp[control.name].filterAttrValues || {};
                $scope.filtersAvailable = _.isEmpty($scope.filterAttrValues) ? false : true;
                try{
                    angular.forEach($scope.filterAttrValues, function(filter) {
                        filter.listOfValues = _.uniq(filter.listOfValues).sort();
                    });
                }catch(e){
                    console.log("Error occoured",e);
                }
                
                const newPlans = remoteResp[control.name].ratedProducts.records;
                formatNewPlans(newPlans,true);
                dataJsonSync();
            })
            .catch(angular.noop);
        });
    };

    // Toggles whether filters dropdown is open
    $scope.toggleFiltersDropdown = function() {
        $scope.openFilterDropdown = !$scope.openFilterDropdown;
    };

    // Toggles selected filter and makes remote call to refresh list of available products
    /**
     * @param {String} filterKey Name of filter type
     * @param {String} value User selected filter value
     */
    $scope.toggleFilter = function(filterKey, value) {
        $scope.lastResultReached = false;
        $scope.selectedFilters[filterKey] = $scope.selectedFilters[filterKey] || [];
        const valueIndex = $scope.selectedFilters[filterKey].indexOf(value);
        if (valueIndex > -1) {
            $scope.selectedFilters[filterKey].splice(valueIndex, 1);
            if (!$scope.selectedFilters[filterKey].length) {
                delete $scope.selectedFilters[filterKey];
            }
        } else {
            $scope.selectedFilters[filterKey].push(value);
        }
        delete bpTreeResponse.lastRecordId;
        delete $scope.lastRecordId;
        remoteInvoke()
        .then(function(remoteResp) {
            console.log('toggleFilter remoteResp', remoteResp);
            $scope.unselectedNewPlans = [];
            const newPlans = remoteResp[control.name].ratedProducts.records;
            formatNewPlans(newPlans,false, true);
        })
        .catch(angular.noop);
    };

    // Requests additional plans based on lastRecordId
    $scope.getMorePlans = function() {
        bpTreeResponse.lastRecordId = $scope.lastRecordId;
        remoteInvoke()
        .then(function(remoteResp) {
            console.log('getMorePlans remoteResp', remoteResp);
            const newPlans = remoteResp[control.name].ratedProducts.records;
            formatNewPlans(newPlans,false);
        })
        .catch(angular.noop);
    };

    // Handle renewal plans and new plans in cart
    /**
     * @param {Object} plan Cart plan
     */
    $scope.toggleCartPlan = function(plan) {
        // Flag to determine whether to select or deselect
        const deselect = plan.selected;
        plan.selected = !plan.selected;
        if (plan.renewal) {
            if (deselect) {
                // Renewal plans only get tracked if they are being deleted
                $scope.renewalPlansToDelete[plan.Id] = true;
            } else {
                // If renewal plan is selected nothing needs to be tracked
                delete $scope.renewalPlansToDelete[plan.Id];
            }
        } else if (deselect) {
            // Non-renewal plans get removed from selection map
            delete $scope.selectedPlansMap[plan.Id];
            if (!plan.multiStepSelected) {
                // If plan isn't renewal or from previous step (multiStepSelected), move back to unselected list
                $scope.cartPlans.splice(plan.originalIndex, 1);
                formatCart($scope.displayedCartPlans[0].originalIndex, true);
                $scope.unselectedNewPlans.unshift(plan);
            }
        } else {
            // This block is reached by toggling a previous step plan (new plans can only be selected with addNewPlan)
            $scope.selectedPlansMap[plan.Id] = plan;
        }
        dataJsonSync();
    };

    // Add new plan to cart
    /**
     * @param {Object} plan Selected plan
     * @param {Number} planIndex Index in displayedPlans
     */
    $scope.addNewPlan = function(plan, planIndex) {
        plan.selected = true;
        $scope.selectedPlansMap[plan.Id] = plan;
        $scope.unselectedNewPlans.splice(planIndex, 1);
        $scope.cartPlans.unshift(plan);
        formatCart(0, true);
        dataJsonSync();
    };

    // Helper method to display number of selected filters
    $scope.selectedFiltersCount = function() {
        let count = 0;
        angular.forEach($scope.selectedFilters, function(array) {
            count += array.length;
        });
        return count;
    };

    // Helper method to display filter checkbox
    /**
     * @param {String} filterKey Filter type
     * @param {String} value Filter value
     */
    $scope.isFilterSelected = function(filterKey, value) {
        if ($scope.selectedFilters[filterKey] && $scope.selectedFilters[filterKey].indexOf(value) > -1) {
            return true;
        }
    };

    // Adds plan to list for compare modal
    /**
     * @param {Object} plan Can be either a renewal or new plan
     */
    $scope.toggleCompareSelect = function(plan) {
        if (!$scope.compareSelectMap[plan.Id]) {
            $scope.compareSelectMap[plan.Id] = plan;
        } else {
            delete $scope.compareSelectMap[plan.Id];
        }
    };

    // Gets called when clicking next/previous directional buttons at top
    /**
     * @param {String} direction Prev or Next
     */
    $scope.paginateItems = function(direction) {
        const currentIndex = $scope.displayedCartPlans[0].originalIndex;
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
        angular.forEach($scope.cartPlans, function(plan) {
            if (plan.selected) {
                count += 1;
            }
        });
        return count;
    };

    //Launch compare modal - right now it is a fixed template but this is exposed js, to-do: use OS modal template
    $scope.openCompareModal = function(plan) {
        if (plan) {
            $scope.modalRecords = [plan, plan.originalPlan.records[0]];
            $scope.isSelectable = false;
        } else {
            $scope.modalRecords = _.values($scope.compareSelectMap);
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
    $scope.openDetailModal = function(plan) {
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
     */
    $scope.toggleModalPlan = function(plan) {
        if (plan.selected || plan.renewal || plan.multiStepSelected) {
            $scope.toggleCartPlan(plan);
        } else {
            for (let i = 0; i < $scope.unselectedNewPlans.length; i++) {
                const newPlan = $scope.unselectedNewPlans[i];
                if (plan.Id === newPlan.Id) {
                    $scope.addNewPlan(plan, i);
                    break;
                }
            }
        }
    };

    // Initialize data when template is used in multiple steps
    function multistepInit() {
        $scope.cartPlans = insSgpsNode.selectedPlans;
        angular.forEach($scope.cartPlans, function(plan) {
            plan.selected = true;
            plan.multiStepSelected = true;
            $scope.selectedPlansMap[plan.Id] = plan;
        });
    }

    // Initialize data for renewal OS
    /**
    * @param {Object} selectableItems control.vlcSI[control.itemsKey]
    */
    function renewalInit(selectableItems) {
        $scope.quotedPlans = selectableItems;
        $scope.renewalPlansToDelete = {};
        angular.forEach(insSgpsNode.unselectedIds, function(id) {
            $scope.renewalPlansToDelete[id] = true;
        });
        angular.forEach($scope.quotedPlans, function(plan) {
            plan.selected = true;
            plan.renewal = true;
            setTierClass(plan);
            if ($scope.renewalPlansToDelete[plan.Id]) {
                plan.selected = false;
            }
        });
        if ($scope.cartPlans) {
            $scope.cartPlans = $scope.cartPlans.concat($scope.quotedPlans);
        } else {
            $scope.cartPlans = $scope.quotedPlans;
        }
    }

    // Set tier for default icon color
    /**
    * @param {Object} plan
    */
    function setTierClass(plan) {
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
    };

    // Index cart items
    /**
    * @param {Number} newIndex Starting index of cart plans subset
    * @param {Boolean} [reindex] Flag to refresh original indexes
    */
    function formatCart(newIndex, reindex) {
        if (reindex) {
            angular.forEach($scope.cartPlans, function(plan, i) {
                plan.originalIndex = i;
            });
        }
        $scope.displayedCartPlans = $scope.cartPlans.slice(newIndex, newIndex + cartPageSize);
        $scope.prevDisabled = newIndex === 0 ? true : false;
        $scope.nextDisabled = newIndex + cartPageSize >= $scope.cartPlans.length ? true : false;
    }

    // Dedupes and sets tiers for new plans
    /**
     * @param {Array} newPlans Plans returned from remote method
     */
    function formatNewPlans(newPlans,isFirstCall,filtersUpdated) {
        const newLastRecordId = newPlans[newPlans.length - 1].Id;
        if ($scope.lastRecordId === newLastRecordId) {
            console.log('last result reached');
            $scope.lastResultReached = true;
            return;
        }
        sortOnProductOrderRating(newPlans);
        if(ifReverse()){
            newPlans.reverse(); 
        }
            if(isFirstCall){
                bpTreeResponse.bestDentalPlans = [];
                for(let i=0;i<newPlans.length ;i++){
                    if(i>1) break;
                    newPlans[i]["bestMatch"]=true;
                    bpTreeResponse.bestDentalPlans[i] = newPlans[i].ProductCode;
                }
            }
            if (filtersUpdated) {
                for(let i=0;i<newPlans.length ;i++){
                    if (bpTreeResponse.bestDentalPlans.includes(newPlans[i].ProductCode))
                    newPlans[i]["bestMatch"]=true;
                }
            }
        $scope.lastRecordId = newLastRecordId;

        angular.forEach(newPlans, function(plan) {
            if (isNewPlan(plan)) {
                setTierClass(plan);
                $scope.unselectedNewPlans.push(plan);
            }
        });
    }

    // Check if new plan is already being tracked
    /**
     * @param {Object} plan
     */
    function isNewPlan(plan) {
        for (let i = 0; i < $scope.cartPlans.length; i++) {
            const cartPlan = $scope.cartPlans[i];
            if (plan.Id === cartPlan.Id || plan.Id === cartPlan.productId) {
                return false;
            }
        }
        return true;
    }

    // Calls OmniScript buttonClick method, which invokes remote method defined on the Selectable Items action
    function remoteInvoke() {
        const deferred = $q.defer();
        $rootScope.loading = true;
        scp.buttonClick(bpTreeResponse, control, scp, undefined, 'typeAheadSearch', undefined, function(remoteResp) {
            deferred.resolve(remoteResp);
        });
        return deferred.promise;
    }

    // Keep plan selections in sync across OS steps
    function dataJsonSync() {
        insSgpsNode.selectedPlans = [];
        angular.forEach($scope.selectedPlansMap, function(selectedPlan) {
            insSgpsNode.selectedPlans.push(selectedPlan);
        });
        // For renewal OS - need to track quote line item ids for deletion from quote
        if (!_.isEmpty($scope.renewalPlansToDelete)) {
            insSgpsNode.unselectedIds = Object.keys($scope.renewalPlansToDelete);
        }
    }

    //sort based on ProductOrder__Rating
    function sortOnProductOrderRating(newPlans){
        newPlans.sort(function(a,b){
            if(a["CalculatedPriceData"]["ProductOrder__Rating"]<b["CalculatedPriceData"]["ProductOrder__Rating"]){
                return -1;
            }else if(a["CalculatedPriceData"]["ProductOrder__Rating"]>b["CalculatedPriceData"]["ProductOrder__Rating"]){
                return 1;
            }else{
                return 0;
            }
        });
    }

    function ifReverse(){
        try{
        let stmAcc=$scope.bpTree.response.HelpMeShop.Questionaries.StatementAccurate;
        if(!stmAcc) return false;
        if(stmAcc==='PayLittle' || stmAcc==='PayLess'){
            return false;
        }else {
            return true;
        }
        }catch(e){
            console.log("Error Occoured",e);
            return false;
            }
      
    }

    $scope.getNumberUnselected = function(numunsel){
        return _.range(numunsel);
    }
}]);

// vlocity.cardframework.registerModule.directive('insOsDropdownHandler', function($document) {
//     'use strict';
//     return {
//         restrict: 'A',
//         link: function(scope, element, attrs) {
//             let isFocused = false;
//             const dropdownElement = angular.element(element.find('.nds-dropdown')[0]);
//             const onClick = function(event) {
//                 const isChild = dropdownElement.has(event.target).length > 0;
//                 if (!isChild) {
//                     scope.$apply(attrs.insOsDropdownToggle);
//                     $document.off('click', onClick);
//                     isFocused = false;
//                 }
//             };
//             element.on('click', function(e) {
//                 if (!isFocused) {
//                     e.stopPropagation();
//                     scope.$apply(attrs.insOsDropdownToggle);
//                     $document.on('click', onClick);
//                     isFocused = true;
//                 }
//             });
//         }
//     };
// });