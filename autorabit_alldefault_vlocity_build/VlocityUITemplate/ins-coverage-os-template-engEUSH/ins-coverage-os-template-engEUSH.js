baseCtrl.prototype.setSelectedProducts = function(products) {
    var event = new CustomEvent('vloc-os-ins-config-product-set', { 'detail': products });
    if (baseCtrl.prototype.vlocOSInsConfigProductSet && baseCtrl.prototype.vlocOSInsConfigProductSet[0].Id !== products[0].Id) {
        document.dispatchEvent(event);
    }
    baseCtrl.prototype.vlocOSInsConfigProductSet = products;
};

vlocity.cardframework.registerModule.controller('insCoveragesOsCtrl', ['$scope', '$rootScope', function($scope, $rootScope) {
    'use strict';
    // Need to clear out rules object so it can track data within this scope:
    $rootScope.attributeUserValues = {};
    $rootScope.evalProductsArray = [];
    // Instantiating sortedCoverages array that will contain data repeated over in the UI
    $scope.sortedCoverages = [];
    // Template Config Options:
    $scope.insCoveragesConfig = {
        showParentProduct: true, // Show Parent Product in UI
        remoteMethod: false, // Boolean to decide whether we can call buttonClick from JS (set to true in setSelectedOption)
        callButtonClick: true, // Manually turn the automatic remote call off even if the class and method are set
        coverageAccordion: true, // Turn on/off accordion on coverages
        coverageAccordionMinAttrs: 2, // The number of minimum coverage attributes needed (throughout all categories) to trigger an accordion if attrCatAccordion is false
        attrCatAccordion: false, // Turn on/off accordion and category name for attribute categories (the accordion will automatically be off if only 1 category, but category name will remain if this is true). To keep category names, but disable the accordions, set 'coverageAccordionMinAttrs' to an unattainably high number
        attrCatAccordionMinCats: 2 // The number of minimum attribute categories needed to trigger a category accordion if attrCatAccordion is true
    };

    // Listening for a new product selection if the user goes previous and selects a new product
    document.addEventListener('vloc-os-ins-config-product-set', function(e) {
        $scope.productsList = e.detail;
        // Need to clear out rules object so it can track data within this scope:
        $rootScope.attributeUserValues = {};
        $rootScope.evalProductsArray = [];
        // Instantiating sortedCoverages array that will contain data repeated over in the UI
        $scope.sortedCoverages = [];
        $scope.setSelectedOption($scope.controlRef, $scope.productsList[0], $scope.optionRef, 0, $scope.scpReference, true);
    });

    function generateHashKey(idxs, childProducts) {
        var hashKey = 'insobject:';
        angular.forEach(idxs, function(idx, i) {
            if (childProducts) {
                hashKey += idx + 5;
            } else {
                hashKey += idx;
            }
        });
        return hashKey;
    }

    function addHashKeys(products, callback, childProducts) {
        if (products[0].RecordTypeName__c === 'Product' || products[0][$scope.nsPrefix + 'RecordTypeName__c'] === 'Product') {
            $scope.productsList[0].Price = products[0].Price;
        }
        angular.forEach(products, function(product, i) {
            // Need to make a dummy $$hashKey because OS needs it, but I can't use the angular generated ones
            // because I need to use track by in my ng-repeats to retain databinding on buttonClick for Rules
            if (!product.$$hashKey) {
                product.$$hashKey = generateHashKey([i], childProducts);
            }
            if (product.attributeCategories && product.attributeCategories.records && product.attributeCategories.records.length) {
                angular.forEach(product.attributeCategories.records, function(attrCat, j) {
                    if (!attrCat.$$hashKey) {
                        attrCat.$$hashKey = generateHashKey([i, j], childProducts);
                    }
                    if (attrCat.productAttributes && attrCat.productAttributes.records && attrCat.productAttributes.records.length) {
                        angular.forEach(attrCat.productAttributes.records, function(prodAttr, k) {
                            if (!prodAttr.$$hashKey && prodAttr.constructor === Object) {
                                prodAttr.$$hashKey = generateHashKey([i, j, k], childProducts);
                            }
                            if (prodAttr.userValues && prodAttr.userValues !== null && prodAttr.userValues.constructor === Array) {
                                angular.forEach(prodAttr.userValues, function(userValue, l) {
                                    if (!userValue.$$hashKey && userValue.constructor === Object) {
                                        userValue.$$hashKey = generateHashKey([i, j, k, l], childProducts);
                                    }
                                });
                            }
                        });
                    }
                });
            }
            // Child Products
            if (product.childProducts && product.childProducts.records && product.childProducts.records.length) {
                addHashKeys(product.childProducts.records, callback(products), true);
            } else if (callback) {
                callback(products);
            }
        });
    }

    // Helper function to loop through service result
    function loopThroughAttributes(products, isChildProducts) {
        var idx;
        var selectedCount = 0;
        var removeProductsArray = [];
        angular.forEach(products, function(product, i) {
            var attrCats;
            product.originalIndex = i;
            // Need to remove the child products that are not of RecordTypeName__c === "CoverageSpec" so the rest of
            // the UI data setup will work properly
            if (isChildProducts && ((!product.RecordTypeName__c && !product[$scope.nsPrefix + 'RecordTypeName__c']) || (product.RecordTypeName__c !== 'CoverageSpec' && product[$scope.nsPrefix + 'RecordTypeName__c'] !== 'CoverageSpec'))) {
                removeProductsArray.push(i);
            } else if (product.attributeCategories) {
                attrCats = product.attributeCategories.records;
                if (attrCats) {
                    if (!product.numberCategories) {
                        product.numberCategories = attrCats.length;
                    } else {
                        product.numberCategories += attrCats.length;
                    }
                    angular.forEach(attrCats, function(attrCat, j) {
                        var prodAttrs;
                        if (attrCat.productAttributes) {
                            prodAttrs = attrCat.productAttributes.records;
                            if (prodAttrs) {
                                if (!product.numberAttributes) {
                                    product.numberAttributes = prodAttrs.length;
                                } else {
                                    product.numberAttributes += prodAttrs.length; 
                                }
                                angular.forEach(prodAttrs, function(prodAttr, k) {
                                    prodAttr.originalProductIndex = i;
                                    prodAttr.originalCategoryIndex = j;
                                    prodAttr.originalAttributeIndex = k;
                                    if (prodAttr.userValues && prodAttr.userValues !== null && typeof prodAttr.userValues === 'object' && prodAttr.userValues.length) {
                                        selectedCount = 0;
                                        angular.forEach(prodAttr.userValues, function(userValue, l) {
                                            angular.forEach(userValue, function(keyValue, key) {
                                                if (keyValue) {
                                                    selectedCount++;
                                                }
                                            });
                                        });
                                        prodAttr.multiSelectLabel = selectedCount + ' Selected';
                                    }
                                    // If dropdown has only 1 option, show as readonly
                                    if (prodAttr.inputType === 'dropdown' && prodAttr.values && prodAttr.values.length === 1) {
                                        prodAttr.readonly = true;
                                    }
                                });
                            }
                        }
                    });
                }
            }
        });
        for (idx = removeProductsArray.length - 1; idx >= 0; idx--) {
            products.splice(removeProductsArray[idx], 1);
        }
        return products;
    }

    // Format data so it can be repeated over in the UI (called on init)
    function formatData(products) {
        var i, j, attrCats, prodAttrs;
        var foundFirstOptional = false;
        var productsReference = loopThroughAttributes(angular.copy(products));
        var coverages = loopThroughAttributes(angular.copy(productsReference[0].childProducts.records), true);
        $scope.sortedCoverages = [];

        if (coverages && !$scope.sortedCoverages.length) {
            $scope.sortedCoverages = coverages.sort(function(x, y) {
                if (x.isSelected && y.isSelected) {
                    if (x.displaySequence === y.displaySequence) {
                        if (x.Name < y.Name) {
                            return -1;
                        } else {
                            return 1;
                        }
                    } else if (x.displaySequence < y.displaySequence) {
                        return -1;
                    } else {
                        return 1;
                    }
                } else if (x.isOptional && !x.isSelected) {
                    return 1;
                } else {
                    return -1;
                }
            });

            angular.forEach($scope.sortedCoverages, function(sortedCoverage, i) {
                if (sortedCoverage.isOptional) {
                    sortedCoverage.isOriginalOptional = true;

                    if (sortedCoverage.isSelected) {
                        sortedCoverage.isAddedOptional = true;
                    }
                }
                if (sortedCoverage.isOptional && !sortedCoverage.isSelected && !foundFirstOptional) {
                    sortedCoverage.firstOptional = true;
                    $scope.sortedCoverages[i - 1].lastNonOptional = true;
                    foundFirstOptional = true;
                } else if (sortedCoverage.isSelected && !foundFirstOptional && i + 1 === $scope.sortedCoverages.length) {
                    sortedCoverage.lastNonOptional = true;
                }
            });
            // Can't have childProducts or it creates an infinite loop of childProducts since
            // the parent product is at the top of the sortedCoverages array
            delete productsReference[0].childProducts;
            $scope.sortedCoverages.unshift(productsReference[0]);
            $scope.sortedCoverages[0].parentProduct = true;
        }
        console.log('$scope.sortedCoverages', $scope.sortedCoverages);
    }

    function loopToUpdatePrice(products, newProductPrices, childProducts) {
        // Add new prices to binded data:
        // Loop over binded root products
        angular.forEach(products, function(product) {
            // Loop over new root products
            angular.forEach(newProductPrices, function(newProductPrice) {
                // Update CalculatedPriceData
                if (product.CalculatedPriceData) {
                    product.CalculatedPriceData = newProductPrice.CalculatedPriceData;
                }
                // Update totalSumInsured
                product.totalSumInsured = newProductPrice.totalSumInsured;
                // Assign new Price to binded dataset
                if (product.Id === newProductPrice.rootId) {
                    product.Price = newProductPrice.rootPrice;
                }
                // Loop over binded childProducts saved in $scope.sortedCoverages
                if (childProducts || (product.childProducts && product.childProducts.records)) {
                    if (!childProducts) {
                        childProducts = product.childProducts.records;
                    }
                    angular.forEach(childProducts, function(childProduct) {
                        // Loop over new childProducts
                        angular.forEach(newProductPrice.childPrices, function(childPrice) {
                            // Assign new child Price to binded dataset
                            if ((childProduct.RecordTypeName__c === 'CoverageSpec' || childProduct[$scope.nsPrefix + 'RecordTypeName__c'] === 'CoverageSpec') && childProduct.pciId === childPrice.childPciId) {
                                childProduct.Price = childPrice.childPrice;
                            }
                        });
                    });
                }
            });
        });
    }

    // When recalculating the price, OmniScript returns the data json to us, but we need to
    // reformat that data's changes into our Angular binded data. We know that the only thing
    // that will change is the Price field, so we kind of manually just update those prices below
    // in an effort to not overwrite any rule evaluations that have already taken place.
    function updatePrices(products, response) {
        var newProductPrices = [];
        var responsePathToProducts = $scope.controlRef.JSONPath.split(':');
        var newResponse;
        angular.forEach(products, function(product, i) {
            // Collect new prices into temporary array
            newProductPrices.push({
                rootPrice: product.Price,
                rootId: product.Id,
                rootProductCode: product.ProductCode,
                CalculatedPriceData: product.CalculatedPriceData,
                childPrices: []
            });
            if (product.childProducts && product.childProducts.records) {
                angular.forEach(product.childProducts.records, function(child) {
                    newProductPrices[newProductPrices.length - 1].childPrices.push({
                        childPrice: child.Price,
                        childPciId: child.pciId,
                        childProductCode: child.ProductCode
                    });
                });
            }
        });
        angular.forEach(responsePathToProducts, function(node, i) {
            if (i === 0) {
                newResponse = response[node];
            } else {
                newResponse = newResponse[node];
            }
        });
        loopToUpdatePrice($scope.productsList, newProductPrices, $scope.sortedCoverages);
        loopToUpdatePrice(newResponse, newProductPrices);
    }

    $scope.bindProducts = function(products) {
        $scope.productsList = products;
        baseCtrl.prototype.vlocOSInsConfigProductSet = products;
        console.log('$scope.productsList', $scope.productsList);
    };

    $scope.setSelectedOption = function(control, p, option, index, scp, bSelected) {
        if (control === undefined || control === null) {
            return;
        }
        console.log('control', control);

        console.log('%c' + p.Name + ' Data:', 'font-size: 14px; color: aqua; font-style: italic;', p);
        control.response = control.vlcSI[control.itemsKey];
        $scope.controlRef = control;
        $scope.optionRef = option;
        $scope.scpReference = scp;
        addHashKeys($scope.productsList, function(products) {
            formatData(products);
            if (control.propSetMap.dataJSON) {
                // scope of the selectable item element in OS, index of the element, parent index of element, optional (true), optional (-1)
                scp.aggregate(scp, control.index, control.indexInParent, true, -1);
            }
            if (control.propSetMap.remoteClass && control.propSetMap.remoteMethod) {
                $scope.insCoveragesConfig.remoteMethod = true;
            }
        });
    };

    // Calls OmniScript buttonClick function, will perform remote action defined on the Seletable Item
    // that houses this template
    $scope.changeCoverage = function(response, control, scp, product, attribute, currentTextValue) {
        var currentProduct;
        if (product.parentProduct) {
            currentProduct = $scope.productsList[0];
        } else {
            currentProduct = $scope.productsList[0].childProducts.records[attribute.originalProductIndex];
        }
        currentProduct.attributeCategories.records[attribute.originalCategoryIndex].productAttributes.records[attribute.originalAttributeIndex].userValues = attribute.userValues;
        if (currentTextValue) {
            if (attribute.userValues && attribute.userValues !== currentTextValue) {
                if ($scope.insCoveragesConfig.callButtonClick && $scope.insCoveragesConfig.remoteMethod) {
                    scp.buttonClick(response, control, scp, undefined, 'typeAheadSearch', undefined, function(remoteResp) {
                        addHashKeys(remoteResp[$scope.controlRef.name], function(products) {
                            console.log('hashKeys regenerated', products);
                            // Cannot just re-run formatData() because it wipes out the rules evaluations
                            updatePrices(products, response);
                            scp.aggregate(scp, control.index, control.indexInParent, true, -1);
                        });
                    });
                }
            }
        } else {
            if ($scope.insCoveragesConfig.callButtonClick && $scope.insCoveragesConfig.remoteMethod) {
                scp.buttonClick(response, control, scp, undefined, 'typeAheadSearch', undefined, function(remoteResp) {
                    addHashKeys(remoteResp[$scope.controlRef.name], function(products) {
                        console.log('hashKeys regenerated', products);
                        // Cannot just re-run formatData() because it wipes out the rules evaluations
                        updatePrices(products, response);
                        scp.aggregate(scp, control.index, control.indexInParent, true, -1);
                    });
                });
            }
        }
    };

    $scope.selectOptionalCoverage = function(child, product, response, control, scp) {
        if (!child.isOptional) {
            console.log('not optional', child);
            return;
        } else {
            child.isSelected = !child.isSelected;
            product.childProducts.records[child.originalIndex].isSelected = !product.childProducts.records[child.originalIndex].isSelected;
            if ($scope.insCoveragesConfig.callButtonClick && $scope.insCoveragesConfig.remoteMethod) {
                scp.buttonClick(response, control, scp, undefined, 'typeAheadSearch', undefined, function(remoteResp) {
                    addHashKeys(remoteResp[$scope.controlRef.name], function(products) {
                        console.log('hashKeys regenerated', products);
                        $scope.$parent.$root.attributeUserValues = {};
                        updatePrices(products, response);
                        scp.aggregate(scp, control.index, control.indexInParent, true, -1);
                        formatData(products);
                    });
                });
            }
        }
    };

    $scope.doAccordion = function(child) {
        if (!$scope.insCoveragesConfig.coverageAccordion) {
            return false;
        } else if (child.parentProduct) {
            return false;
        } else {
            if (!$scope.insCoveragesConfig.attrCatAccordion) {
                if (child.numberAttributes < $scope.insCoveragesConfig.coverageAccordionMinAttrs) {
                    return false;
                } else {
                    return true;
                }
            } else {
                if (child.numberCategories < $scope.insCoveragesConfig.attrCatAccordionMinCats) {
                    return false;
                } else {
                    return true;
                }
            }
        }
    };

    $scope.addCheckboxValue = function(value, response, control, scp, child, attribute) {
        var selectedCount = 0;
        angular.forEach(attribute.userValues, function(userValue, i) {
            if (value.value in userValue) {
                userValue[value.value] = !userValue[value.value];
            }
            angular.forEach(userValue, function(keyValue, key) {
                if (keyValue) {
                    selectedCount++;
                }
            });
        });
        attribute.multiSelectLabel = selectedCount + ' Selected';
        $scope.changeCoverage(response, control, scp, child, attribute);
        console.log('multiselect userValues', attribute.userValues);
        console.log('$scope.sortedCoverages', $scope.sortedCoverages);
    };

    // Only for multiselect dropdowns
    $scope.countSelected = function(attribute) {
        if (attribute.userValues && attribute.userValues.constructor === Array) {
            attribute.multiSelectCount = attribute.userValues.length;
        } else {
            attribute.userValues = [];
            attribute.multiSelectCount = 0;
        }
    };

    // Only for multiselect dropdowns
    $scope.toggleValue = function(attribute, value, index, response, control, scp, child) {
        if (!attribute.userValues) {
            attribute.userValues = [];
        }
        if (attribute.userValues.indexOf(value.value) > -1) {
            attribute.userValues.splice(attribute.userValues.indexOf(value.value), 1);
        } else {
            attribute.userValues.push(value.value);
        }
        $scope.countSelected(attribute);
        $scope.changeCoverage(response, control, scp, child, attribute);
    };

    $rootScope.insOSCoveragesDropdowns = {};
    $rootScope.toggleDropdown = function(attribute) {
        if ($rootScope.insOSCoveragesDropdowns[attribute.attributeId]) {
            $rootScope.insOSCoveragesDropdowns[attribute.attributeId] = false;
        } else {
            $rootScope.insOSCoveragesDropdowns[attribute.attributeId] = true;
        }
    };

    $scope.stopPropagation = function(event) {
        event.stopPropagation();
    };
}]);

vlocity.cardframework.registerModule.directive('insCoveragesDropdownHandler', ['$rootScope', '$document', function($rootScope, $document) {
    'use strict';
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var focused = false;
            var initial = false;
            function insCoveragesDropdownHandler(event) {
                var isChild = element.has(event.target).length > 0;
                var isSelf = element[0] == event.target;
                var isInside = isChild || isSelf;
                var className = event.target.className + ' ' + event.target.parentElement.className;
                if (initial) {
                    initial = false;
                    return;
                }
                if (event.target.nodeName === 'path') {
                    className = event.target.parentElement.parentElement.className;
                } else if (event.target.nodeName === 'svg') {
                    className = event.target.parentElement.className;
                }
                if ((!isInside && className.indexOf(attrs.restrictElement) < 0) || (isInside && className.indexOf(attrs.restrictElement) < 0 && !attrs.hasOwnProperty('ngClick'))) {
                    scope.$apply(attrs.insCoveragesDropdownHandler);
                    $document.off('click', insCoveragesDropdownHandler);
                    focused = false;
                }
            }
            element.on('click', function(event) {
                if (!focused) {
                    scope.$apply(attrs.insCoveragesDropdownHandler);
                    $document.on('click', insCoveragesDropdownHandler);
                    focused = true;
                    initial = true;
                }
            });
        }
    };
}]);