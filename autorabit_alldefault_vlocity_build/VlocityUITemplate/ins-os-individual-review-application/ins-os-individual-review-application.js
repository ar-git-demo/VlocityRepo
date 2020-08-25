var insPsCustomEventName = 'vloc-os-ins-product-selection-change-' + Math.round((new Date()).getTime() / 1000);
var insPsLoadedOnce;
baseCtrl.prototype.setSelectedProductSelectionProducts = function(control) {
    var event = new CustomEvent(insPsCustomEventName, {'detail': control.vlcSI[control.itemsKey]});
    baseCtrl.prototype.$scope.currentElementName = control.name;
    if (!baseCtrl.prototype.$scope.insPsControlRef) {
        baseCtrl.prototype.$scope.insPsControlRef = {};
    }
    baseCtrl.prototype.$scope.insPsControlRef[baseCtrl.prototype.$scope.currentElementName] = control;
    insPsLoadedOnce = false; //load template more than once
    document.dispatchEvent(event);
};
vlocity.cardframework.registerModule.controller('insOsProductSelectionCtrl', ['$scope', '$rootScope', '$timeout', '$injector',  '$sldsModal', function($scope, $rootScope, $timeout, $injector, $sldsModal) {
    'use strict';
    var trackSetValueAttrs = {};

 
    var foundCurrentStep = false; // used to track in waitForCurrentStep
    $scope.currencyCode = '$';
    if (baseCtrl.prototype.$scope.bpTree.propSetMap.currencyCode) {
        $scope.currencyCode = baseCtrl.prototype.$scope.bpTree.propSetMap.currencyCode;
    } else if (baseCtrl.prototype.$scope.bpTree.oSCurrencySymbol) {
        $scope.currencyCode = baseCtrl.prototype.$scope.bpTree.oSCurrencySymbol;
    }
    $scope.currentProducts = [];
    $scope.allProducts = [];


    $scope.completedProductAnalysis = false;
    $scope.limitValues = {};

    //*** CUSTOMIZABLE VARIABLES ***//
    $scope.usePagination = true; // Turn on/off pagination
    $scope.pageSize = 3; // Customize pagination page size (cannot be 0, must be an integer) (not applicable for enrollmentFlow)
    $scope.pageDentalSize = 3; 
    if (/Mobi/.test(navigator.userAgent)) {
        $scope.pageSize = 1;
    }

    //*** START LOGIC ***//
    // Listening for a new product selection if the user goes previous and selects a new product
    function listenForMainEvent(e) {
        $rootScope.attributeUserValues = {};
        $scope.insPsInit(e.detail);
    }
    if (!insPsLoadedOnce) {
        document.addEventListener(insPsCustomEventName, listenForMainEvent);
    }
$scope.dependentArray=[];
    $scope.populateDependent=function(){
        $scope.dependentArray=[];
        if(Array.isArray($scope.bpTree.response.ApplicantInformation.Dependents)){
            $scope.dependentArray=$scope.bpTree.response.ApplicantInformation.Dependents;
        }else{
            $scope.dependentArray.push($scope.bpTree.response.ApplicantInformation.Dependents);
        }
        console.log("test dependent",$scope.dependentArray);
    }
    $scope.populateDependent();

    
    $scope.formatDate = function(date, isDatetime) {
        let formattedDate = null;
        if (!date) {
            console.error('This date is invalid', date);
            return formattedDate;
        } else {
            let monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
            if (moment) {
                monthNames = moment.months();
                formattedDate = moment(date).format('MM/DD/YYYY');
                if (isDatetime) {
                    formattedDate = moment(date).format('MM/DD/YY, h:mm a');
                }
            } else {
                const dateObj = new Date(date);
                if (Object.prototype.toString.call(dateObj) === '[object Date]') {
                    if (isNaN(dateObj.getTime())) {
                        if (typeof date === 'string' && date.indexOf('.') > -1) {
                            date = date.split('.')[0];
                            return $scope.formatDate(date);
                        }
                    }
                } else {
                    console.error('This date is invalid', date);
                }
                formattedDate = monthNames[dateObj.getUTCMonth()] + ' ' + dateObj.getUTCDate() + ' ' + dateObj.getUTCFullYear();

                if (isDatetime) {
                    formattedDate = formattedDate + ' ' + dateObj.toLocaleTimeString();
                }
            }
        }
        return formattedDate;
    };

    /*
     * Helper method for repeatable code, called in decideCorrectElement
     * @param {Object} currentStepChild
     * @param {Number} currentStepChildIdx
     */
    function decideCorrectElementHelper(currentStepChild, currentStepChildIdx) {
        var returnObj = {
            correctElement: false,
            path: ''
        };
        angular.forEach(currentStepChild.eleArray, function(osElement, idx) {
            if (osElement && osElement.type === 'Selectable Items' && osElement.children && !osElement.children.length && osElement.propSetMap && !osElement.propSetMap.remoteClass && !osElement.propSetMap.remoteMethod) {
                returnObj.path = 'currentStep.children[' + currentStepChildIdx + '].eleArray[' + idx + ']';
                returnObj.correctElement = true;
                return returnObj;
            }
        });
        return returnObj;
    }

    // OS asIndex is null until the step is instantiated which isn't immediate
    function waitForCurrentStep(callback) {
        $timeout(function() {
            var currentStep = baseCtrl.prototype.$scope.bpTree.children[baseCtrl.prototype.$scope.bpTree.asIndex];
            if (!foundCurrentStep) { // this is set to true in the else block below. it gets set back to false in decideCorrectElement
                if (!currentStep) {
                    waitForCurrentStep(callback);
                } else {
                    foundCurrentStep = true;
                    decideCorrectElement(callback);
                }
            }
        }, 100);
    }

    /**
     * Callback is called once we have a decision. We may have to wait for the baseCtrl.prototype.$scope.bpTree.asIndex
     * as it is null at times when proceding a step
     * @param {Function} callback 
     * @param {Boolean} initial 
     */
    function decideCorrectElement(callback, initial) {
        var currentStep = baseCtrl.prototype.$scope.bpTree.children[baseCtrl.prototype.$scope.bpTree.asIndex];
        var returnObj = {};
        var osElement;
        if (initial) {
            foundCurrentStep = false;
        }
        if (!currentStep) {
            waitForCurrentStep(callback);
        } else {
            if (!rulesWatchTracker.path) {
                angular.forEach(currentStep.children, function(currentStepChild, idx) {
                    returnObj = decideCorrectElementHelper(currentStepChild, idx);
                });
            } else {
                osElement = eval(rulesWatchTracker.path);
                if (osElement && osElement.type === 'Selectable Items' && osElement.children && !osElement.children.length && osElement.propSetMap && !osElement.propSetMap.remoteClass && !osElement.propSetMap.remoteMethod) {
                    returnObj.correctElement = true;
                } else {
                    returnObj.correctElement = false;
                    angular.forEach(currentStep.children, function(currentStepChild, idx) {
                        returnObj = decideCorrectElementHelper(currentStepChild, idx);
                    });
                }
            }
            return callback(returnObj);
        }
    }

    // When the template is loaded, we need to parse the products that get returned:
    $scope.insPsInit = function(products) {
        // const control = baseCtrl.prototype.$scope.insPsControlRef[baseCtrl.prototype.$scope.currentElementName];
        // control.response = products;

        // console.log('Control First: ' , control);
        // console.log('Control First FROM SCOPE: ' , $scope.control);
        // $scope.aggregate($scope, control.index, control.indexInParent, true, -1);
        // var i;
        // var dummmyProductsNeeded = products.length % $scope.pageSize ? products.length % $scope.pageSize : 0;
        // var dummyProducts = [];
        // $scope.parentAttrs = {};
        // $scope.rootAndChildrenProductsKeys = [];

        // $scope.medicalPlansSelected = [];
        // $scope.dentalPlansSelected = [];

        // if ($scope.usePagination && $scope.pageSize < products.length && dummmyProductsNeeded) {
        //     dummyProducts = Array.apply(null, Array(dummmyProductsNeeded)).map(function() { return {dummyProduct: true}; });
        //     products = products.concat(dummyProducts);
        // }

        // // if($scope.control == 'MedicalSelected'){
        // //     $scope.medicalPlansSelected = [];
        // // }else{
        // //     $scope.dentalPlansSelected = [];
        // // }

        
        // for (i = 0; i < products.length; i++) {
            
        //     //products[i].vlcCompSelected = false;
        //    // products[i].originalIndex = i;
        //     // Manually generating our own $$hashKey because Omniscript uses it as a comparison
        //     // and Angular removes it in an ng-repeat that uses 'track by' and we need both.
        //     //products[i].$$hashKey = 'ins-custom-' + i;
        //     if (baseCtrl.prototype.$scope.insPsSelectedRateBand) {
        //         products[i].selectedRateBand = baseCtrl.prototype.$scope.insPsSelectedRateBand;
        //     }
        //     if(products[i].Type__c == 'Medical' ){
        //         $scope.medicalPlansSelected.push(products[i]);
        //         // products.splice(i,1);
        //     }else if(products[i].Type__c == 'Dental' ){
        //         $scope.dentalPlansSelected.push(products[i]);
        //         // products.splice(i,1);
        //     }
        // }
        // console.log('$scope.dentalPlansSelected : ' , $scope.dentalPlansSelected );
        // console.log('$scope.medicalPlansSelected : ' , $scope.medicalPlansSelected );
        // $scope.initProducts = products;
        // if ($scope.usePagination) {
        //     if($scope.control == 'MedicalSelected'){
        //         //$scope.medicalPlansSelected = [];
        //         $scope.allProductMedical = $scope.medicalPlansSelected;
        //         $scope.currentProductsMedical = $scope.allProductMedical.slice(0, $scope.pageSize);
        //     }
        //     if($scope.control == 'DentalSelected'){
        //        // $scope.dentalPlansSelected = [];
        //         $scope.allProductDental = $scope.dentalPlansSelected;
        //         $scope.currentProductsDental = $scope.allProductDental.slice(0, $scope.pageDentalSize);
        //     }
        //    // $scope.allProducts = products;
        //     //$scope.currentProducts = $scope.allProducts.slice(0, $scope.pageSize);
        // } else {
        //     $scope.pageSize = products.length;
        //     $scope.currentProducts = products;
        // }
    };

    // Gets called when clicking next/previous directional buttons at top
    $scope.paginateItems = function(direction) {

        if($scope.control == 'DentalSelected'){
            var startIndex = 0;
            var currentProductsDental = $scope.currentProductsDental;
            if (direction === 'next') {
                startIndex = currentProductsDental[currentProductsDental.length - 1].originalIndex + 1;
            } else if (direction === 'prev') {
                startIndex = currentProductsDental[0].originalIndex - $scope.pageDentalSize;
                if (startIndex < 0) {
                    startIndex = 0;
                }
            }   
            $scope.currentProductsDental = $scope.allProductDental.slice(startIndex, startIndex + $scope.pageDentalSize);
        }else{

            var startIndex = 0;
            var currentProductsMedical = $scope.currentProductsMedical;
            if (direction === 'next') {
                startIndex = currentProductsMedical[currentProductsMedical.length - 1].originalIndex + 1;
            } else if (direction === 'prev') {
                startIndex = currentProductsMedical[0].originalIndex - $scope.pageSize;
                if (startIndex < 0) {
                    startIndex = 0;
                }
            }
            $scope.currentProductsMedical = $scope.allProductMedical.slice(startIndex, startIndex + $scope.pageSize);

        }
      



    };

    // Decides whether the directional button should be active or disabled based on
    // the location we're at in the whole set of products.
    $scope.showPageControl = function(direction) {

        
       
        if($scope.control == 'MedicalSelected'){
            var i;
            var show = false;
            var amountToSubtract = ($scope.allProductMedical.length % 2) + 1; // adding 1 for dummyProduct
            var lastIndex = $scope.allProductMedical.length - amountToSubtract;
            var lastIndexExists = [];
            if (direction === 'next') {

                if ($scope.currentProductsMedical.length === 1 && $scope.pageSize > 1) {
                    show = false;
                } else {
                    for (i = 0; i < $scope.currentProductsMedical.length; i++) {
                        if ($scope.currentProductsMedical[i].originalIndex === lastIndex) {
                            lastIndexExists.push('yes');
                        } else {
                            lastIndexExists.push('no');
                        }
                    }
                    if (lastIndexExists.indexOf('yes') > -1) {
                        show = false;
                    } else {
                        show = true;
                    }
                }
            } else if (direction === 'prev') {
                if ($scope.currentProductsMedical[0].originalIndex > 0) {
                    show = true;
                } else {
                    show = false;
                }
            }
            return show;
        }else{
            var i;
            var show = false;
            var amountToSubtract = ($scope.allProductDental.length % 2) + 1; // adding 1 for dummyProduct
            var lastIndex = $scope.allProductDental.length - amountToSubtract;
            var lastIndexExists = [];
            if (direction === 'next') {

                if ($scope.currentProductsDental.length === 1 && $scope.pageDentalSize > 1) {
                    show = false;
                } else {
                    for (i = 0; i < $scope.currentProductsDental.length; i++) {
                        if ($scope.currentProductsDental[i].originalIndex === lastIndex) {
                            lastIndexExists.push('yes');
                        } else {
                            lastIndexExists.push('no');
                        }
                    }
                    if (lastIndexExists.indexOf('yes') > -1) {
                        show = false;
                    } else {
                        show = true;
                    }
                }
            } else if (direction === 'prev') {
                if ($scope.currentProductsDental[0].originalIndex > 0) {
                    show = true;
                } else {
                    show = false;
                }
            }
            return show;
        }



    };

    /*
    * Set "tier" key for product using Tier__c field first, else productName
    * the tier flag is used only for icon color
    * @param {Object} product
    */
    $scope.setTier = function(product) {
        let tier = product[baseCtrl.prototype.$scope.nsPrefix  + 'RecordTypeName__c'] || product.RecordTypeName__c;
        if (!tier) {
            if (product.productName.indexOf('Silver') > -1) {
                product.tier = 'Silver';
            }
            if (product.productName.indexOf('Gold') > -1) {
                product.tier = 'Gold';
            }
            if (product.productName.indexOf('Bronze') > -1) {
                product.tier = 'Bronze';
            }
        } else {
            product.tier = tier;
        }
    };

    $scope.getSelectableItemClass = function(product, index) {
        var htmlClass = 'slds-size--1-of-' + $scope.pageSize + 
                        ' nds-size--1-of-' + $scope.pageSize + 
                        ' slds-large-size--1-of-' + $scope.pageSize +
                        ' nds-large-size--1-of-' + $scope.pageSize +
                        ' slds-medium-size--1-of-' + $scope.pageSize +
                        ' nds-medium-size--1-of-' + $scope.pageSize +
                        ' slds-small-size--1-of-1 slds-max-small-size--1-of-1 nds-small-size--1-of-1 nds-max-small-size--1-of-1';
        if (product.dummyProduct) {
            htmlClass += ' slds-hidden nds-hidden';
        }
        if ($scope.currentProducts.length === 1) {
            htmlClass += ' vloc-ins-one-product';
        }
        if (product.similarToLastYear) {
            htmlClass += ' vloc-ins-has-similar-flag';
        }
        if (product.disabledByRateBand) {
            htmlClass += ' disabled-by-rate-band';
        }
        return htmlClass;
    };

    $scope.getParentAttributeClass = function(attribute, index) {
        var htmlClass = 'vloc-ins-parent-attr-regular';
        if (attribute.categoryCode.toLowerCase().indexOf('benefit') > -1) {
            if (attribute.dataType !== 'currency' && typeof attribute.valueLabel === 'boolean') {
                htmlClass = 'vloc-ins-parent-attr-non-regular vloc-ins-parent-attr-boolean';
            } else if (attribute.dataType === 'currency') {
                htmlClass = 'vloc-ins-parent-attr-non-regular vloc-ins-parent-attr-currency';
            }
        }
        if (index > 0) {
            htmlClass += ' vloc-ins-hide-on-small-screens vloc-ins-hide-on-large-screens';
        } else if (index > -1) {
            htmlClass += ' vloc-ins-hide-on-small-screens';
        }
        return tmlClass;
    };

    /* Open Detail View Modal
    * @params {obj} product 
    * @params {obj} control osControl - passed from html right now, not used but kept in case needed in modal  
    */
    $scope.openDetailView = function(product, control) {
        $scope.modalRecords = [product];
        $sldsModal({
            backdrop: 'static',
            title: 'Plan Detail',
            scope: $scope,
            animation: true,
            templateUrl: control.propSetMap.modalHTMLTemplateId,
            show: true
        });
    };

    /* Launch Compare to Last Year - send a list of products - i.e. current and it's original
    * @params {obj} product 
    * @params {obj} control osControl - passed from html right now, not used but kept in case needed in modal  
    */
    $scope.compareToLastYearModal = function(product, control) {
        $scope.modalRecords = [product, product.originalPlan.records[0]]; //modalProducts = list of product and last years
        $sldsModal({
            backdrop: 'static',
            title: 'View Changes',
            scope: $scope,
            showLastYear: true,
            animation: true,
            templateUrl: control.propSetMap.modalHTMLTemplateId,
            show: true
        });
    };

    $scope.getNumberUnselected = function(numunsel){
        return _.range(numunsel);
    }

    $scope.getNumberSelected = function(numsel){
        return _.range(numsel);
    }

    //Push the elements to the new empty array
    //Local variable
    $scope.createProductsListInReviewQuoteMedical =  function(plan) {
        //console.log("New Array to sort the attributes");
        //console.log("Plans: ",plan);
        var productData = [];
        plan.prodList = [];
        plan.attributeCategories.records.forEach(function(element) {
            element.productAttributes.records.forEach(function(obj) {
                //console.log("Objetos",obj);
                if (obj.label === 'Annual Deductible') {
                    obj.newPosition = 3;
                }
                if (obj.label === 'Premium Amount (Monthly)') {
                    obj.newPosition = 1;
                }
                if (obj.label === 'Emergency Care') {
                    obj.newPosition = 6;
                }
                if (obj.label === 'Primary Care Provider Office Visits') {
                    obj.newPosition = 4;
                }
                if (obj.label === 'Specialty Care Provider Office Visit - In Network') {
                    obj.newPosition = 5;
                }
                if (obj.label === 'Out of Pocket Maximum - In Network') {
                    obj.newPosition = 2;
                }
                if (obj.label === 'Summary of Benefit & Coverage') {
                    obj.newPosition = 8;
                }
                if (obj.label === 'Evidence of Coverage') {
                    obj.newPosition = 9;
                }
                if (obj.label === 'Provider Directory') {
                    obj.newPosition = 10;
                }
                if (obj.label === 'Pharmacy Directory') {
                    obj.newPosition = 11;
                }
                if (obj.label === 'Prescription Drug List') {
                    obj.newPosition = 12;
                }
                productData = {"name": obj.label, "sortedList": obj.newPosition, "value": obj.userValues};
                plan.prodList.push(productData);
            });
        });
        productData = {"name": "View More Benefits", "sortedList": 7, "value": ""};
        plan.prodList.push(productData);
        console.log("New list - Review Your Quote: ",plan.prodList);
    }

    //Push the elements to the new empty array
    //Local variable
    $scope.createProductsListInReviewQuoteDental = function(plan) {
        //console.log("New Array to sort the attributes");
        console.log("Dental Plan in Review Your Quote: ",plan);
        var productDataQuote = [];
        plan.prodListQuote = [];
        plan.attributeCategories.records.forEach(function(element) {
            element.productAttributes.records.forEach(function(obj) {
                console.log("Objects in Dental Plan",obj);
                if (obj.label === 'Plan Year Maximum') {
                    obj.newPositionDental = 1;
                }
                if (obj.label === 'Individual Deductible (Amount)') {
                    obj.newPositionDental = 2;
                }
                if (obj.label === 'Preventative Care (In Network Amount)') {
                    obj.newPositionDental = 3;
                }
                if (obj.label === 'Routine Care (In Network Amount)') {
                    obj.newPositionDental = 4;
                }
                if (obj.label === 'Major Care (In Network Amount)') {
                    obj.newPositionDental = 5;
                }
                if (obj.label === 'Summary of Benefit & Coverage') {
                    obj.newPositionDental = 7;
                }
                if (obj.label === 'Guide to Benefits') {
                    obj.newPositionDental = 8;
                }
                productDataQuote = {"name": obj.label, "sortedList": obj.newPositionDental, "value": obj.userValues};
                plan.prodListQuote.push(productDataQuote);
            });
        });
        productDataQuote = {"name": "View More Benefits", "sortedList": 6, "value": ""};
        plan.prodListQuote.push(productDataQuote);
        console.log("New list Dental RYQ: ",plan.prodListQuote);
    }

 
   

}]);