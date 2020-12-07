(function(){
  var fileNsPrefix = (function() {
    'use strict';
    var scripts = document.getElementsByTagName('script');
    var lastScript = scripts[scripts.length - 1];
    var scriptName = lastScript.src;
    var parts = scriptName.split('/');
    var partsLength = parts.length - 1;
    var thisScript = parts[partsLength--];
    if (thisScript === "") {
      thisScript = parts[partsLength--];
    }

    // Fix to handle cases where js files are inside zip files
    // https://dev-card.na31.visual.force.com/resource/1509484368000/dev_card__cardframework_core_assets/latest/cardframework.js

    //fix for finding nsPrefix in subpaths and subdomains
    if (scriptName.indexOf('__') != -1) {
      while(thisScript.indexOf('__') == -1 && partsLength >= 0) {
        thisScript = parts[partsLength];
        partsLength--;
      }
    }

    var lowerCasePrefix = thisScript.indexOf('__') == -1 ? '' : thisScript.substring(0, thisScript.indexOf('__') + 2);
    //check for the cached namespace first
    lowerCasePrefix = lowerCasePrefix === '' && localStorage.getItem('nsPrefix') ? localStorage.getItem('nsPrefix'): lowerCasePrefix;
    
    if(lowerCasePrefix !== ''){
        lowerCasePrefix = /__$/.test(lowerCasePrefix) ? lowerCasePrefix : lowerCasePrefix + '__';
    }
    if (lowerCasePrefix.length === 0) {
      return function() {
        //then check if the app has put a namespace and take that one as it is newer
        lowerCasePrefix = window.nsPrefix ? window.nsPrefix: lowerCasePrefix;
        //add the underscore if it doesn't have them    
        if(lowerCasePrefix !== ""){
            lowerCasePrefix = /__$/.test(lowerCasePrefix) ? lowerCasePrefix : lowerCasePrefix + '__';
        }  
        return lowerCasePrefix;
      };
    } else {
      var resolvedNs = null;
      return function() {
        if (resolvedNs) {
          return resolvedNs;
        }
        // hack to make scan SF objects for the correct case
        try {
          var tofind = lowerCasePrefix.replace('__', '');
          var name;
          var scanObjectForNs = function(object, alreadySeen) {
            if (object && object !== window && alreadySeen.indexOf(object) == -1) {
                alreadySeen.push(object);
                Object.keys(object).forEach(function(key) {
                  if (key === 'ns') {
                    // do ns test
                    if (typeof object[key] === 'string' && object[key].toLowerCase() === tofind) {
                      name = object[key] + '__';
                      return false;
                    }
                  }
                  if (Object.prototype.toString.call(object[key]) === '[object Array]') {
                    object[key].forEach(function(value) {
                      var result = scanObjectForNs(value, alreadySeen);
                      if (result) {
                          name = result;
                          return false;
                      }
                    });
                  } else if (typeof object[key] == 'object') {
                    var result = scanObjectForNs(object[key], alreadySeen);
                    if (result) {
                        name = result;
                        return false;
                    }
                  }
                  if (name) {
                    return false;
                  }
                });
                if (name) {
                  return name;
                }
            };
          }
          if(typeof Visualforce !== 'undefined') { //inside VF
            scanObjectForNs(Visualforce.remoting.Manager.providers, []);  
          } else {
            return lowerCasePrefix;
          }
          if (name) {
            return resolvedNs = name;
          } else {
            return resolvedNs = lowerCasePrefix;
          }
        } catch (e) {
          return lowerCasePrefix;
        }
      };
    }
  })();

  var fileNsPrefixDot = function() {
    var prefix = fileNsPrefix();
    if (prefix.length > 1) {
      return prefix.replace('__', '.');
    } else {
      return prefix;
    }
  };(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
var module = angular.module('xomadmin', ['vlocity', 'ngRoute', 'thorIntegration'])
    .config(['remoteActionsProvider','$compileProvider', '$routeProvider', function(remoteActionsProvider, $compileProvider, $routeProvider) {
        remoteActionsProvider.setRemoteActions(window.remoteActions || {});
        $compileProvider.debugInfoEnabled(true); // Remove debug info (angularJS >= 1.3)

        console.log('Configuring routes');

        $routeProvider
                .when('/', {
                    templateUrl: 'XOMAdmin.tpl.html',
                    controller: 'XOMAdminController'
                })
                .when('/configureLayouts', {
                    templateUrl: 'XOMConfigureLayouts.tpl.html',
                    controller: 'XOMConfigureLayoutsController'
                })
                .otherwise({
                    redirectTo: '/'
                });

    }])
    .run(['$route', function() {}]);
    
require('./modules/xomadmin/controller/XOMAdminController.js');
require('./modules/xomadmin/controller/XOMConfigureLayoutsController.js');
require('./modules/xomadmin/templates/templates.js');
},{"./modules/xomadmin/controller/XOMAdminController.js":2,"./modules/xomadmin/controller/XOMConfigureLayoutsController.js":3,"./modules/xomadmin/templates/templates.js":4}],2:[function(require,module,exports){
angular.module('xomadmin').controller('XOMAdminController',
    [
        '$scope', '$window', '$location', '$timeout', 'remoteActions', 'config', '$http',
        'thorIntegrationService', 'labelsSyncService',
        function($scope, $window, $location, $timeout, remoteActions, config, $http,
                 thorIntegrationService, labelsSyncService)
        {

            var BATCH_SIZE = 300;

            $scope.isThorEnabled = config.isThorEnabled == 'true';
            $scope.isDeltaTrackingEnabled = config.isDeltaTrackingEnabled == 'true';
            $scope.isDevEnabled = /devMode=true/.exec(window.location.search);

            console.log('Config:', config);
            console.log('Scope: ', $scope);

            $scope.forcePopulateSyncDelta = function()
            {

                console.log('Force populate Sync Delta');

                $scope.showSpinner = true;
                $scope.showMsg = false;

                var sliceBatch = function(scope, start)
                {

                    console.log('Scope length', scope.length);

                    console.log('Preparing batch starting with', start);

                    var pos = 0;

                    var request = [];

                    for (var i = 0; i < scope.length; i++)
                    {
                        var item = scope[i];

                        //console.log('Pos', pos, 'item', item);

                        var itemReq = '';

                        for (var j = 0; j<item.ids.length; j++)
                        {

                            //console.log('Pos', pos, 'objId', item.ids[j]);

                            if (pos>=start)
                            {
                                // console.log('Starting');
                                if (!itemReq)
                                {
                                    // console.log('New sObjType');
                                    itemReq = {
                                        sObjTypeName: item.sObjTypeName,
                                        ids: []
                                    }

                                    request.push(itemReq);
                                }

                                if (pos >= start + BATCH_SIZE)
                                {
                                    return request;
                                }

                                itemReq.ids.push(item.ids[j]);
                            }

                            pos++;
                        }
                    }

                    return request;
                }

                var populateSyncDelta = function(scope, start)
                {

                    var request = sliceBatch(scope, start);

                    console.log('Creating deltas for ', request);

                    if (request.length > 0)
                    {

                        remoteActions.populateSyncDelta(JSON.stringify(request)).then(function()
                        {
                            populateSyncDelta(scope, start+BATCH_SIZE);
                        }).catch(function(err)
                        {
                            console.error(err);
                            $scope.showSpinner = false;
                            handleError("Error" + err.message);
                        });
                    }
                    else
                    {
                        // Finished
                        $scope.showSpinner = false;
                        showSuccessMsg("Sync Delta Objects were generated successfully");
                    }

                };

                var cleanup = function (cont) {
                    console.log('Cleaning up');
                    remoteActions.cleanupSyncDelta().then(function (result) {
                        if (result) {
                            cont();
                        }
                        else {
                            // Not finished yet, retrying
                            cleanup(cont);
                        }

                    }).catch(function(err)
                    {
                        console.error(err);
                        $scope.showSpinner = false;
                        handleError("Error" + err.message);
                    });
                }

                cleanup(function() {
                    // Don't forget to populate sync deltas
                    console.log('Starting to popuate sync deltas');
                    remoteActions.calcScopeForSyncDelta().then(function(scope)
                    {
                        populateSyncDelta(scope, 0);
                    }).catch(function(err)
                    {
                        console.error(err);
                        $scope.showSpinner = false;
                        handleError("Error" + err.message);
                    });
                });

            }

            $scope.cleanupSyncDelta = function()
            {

                console.log('Cleanup Sync Delta');

                $scope.showSpinner = true;
                $scope.showMsg = false;

                remoteActions.cleanupSyncDelta().then(function(result)
                {
                    if (result)
                    {
                        $scope.showSpinner = false;
                        showSuccessMsg("Sync Delta Objects were deleted successfully");
                    }
                    else
                    {
                        // Not finished yet, retrying
                        $scope.cleanupSyncDelta();
                    }

                }).catch(function(err)
                {
                    console.error(err);
                    $scope.showSpinner = false;
                    handleError("Error" + err.message);
                });

            }

            $scope.ensureGlobalKeys = function()
            {

                console.log('Ensure Global Keys');

                $scope.showSpinner = true;
                $scope.showMsg = false;

                function _ensureGlobalKeys(idx) {

                    remoteActions.ensureGlobalKeysBatch(idx).then(function (idx) {
                        if (idx < 0 ) {
                            $scope.showSpinner = false;
                            showSuccessMsg("All Catalog objects are ensured to have Global Key set");
                        }
                        else {
                            // Have not finished yet
                            _ensureGlobalKeys(idx);
                        }
                    }).catch(function(err)
                    {
                        console.error(err);
                        $scope.showSpinner = false;
                        handleError("Error" + err.message);
                    });

                }

                _ensureGlobalKeys(0);


            }


            $scope.createDataRaptorBundlesForBackSync = function()
            {
                $scope.showSpinner = true;
                $scope.showMsg = false;

                remoteActions.createDataRaptorBundlesForBackSync().then(function()
                {
                    $scope.showSpinner = false;
                    showSuccessMsg("Vlocity DataRaptor Bundler for Thor sync was created successfully");
                }).catch(function(err)
                {
                    console.error(err);
                    $scope.showSpinner = false;
                    handleError("Error" + err.message);
                });
            }

            $scope.syncCatalog = function()
            {
                $window.location.href = config.syncCatalogPage;
            }

            $scope.checkEnvStatus = function()
            {
                $window.location.href = config.checkEnvStatusPage;
            };

            $scope.configureLayouts = function()
            {
                $location.path('/configureLayouts');
            }

            $scope.downloadSyncDeltas = function()
            {
                $scope.showSpinner = true;
                $scope.showMsg = false;
                console.log('Download deltas');

                remoteActions.getBatch(200).then(function(json)
                {
                    $scope.showSpinner = false;
                    console.log('JSON: ', json);
                    var blob = new Blob([JSON.stringify(json)], {type: "application/json;charset=utf-8"});
                    var fileName = new Date().toLocaleString();
                    saveAs(blob, fileName + ".json");
                    console.log('Saving ' + fileName);
                }).catch(function(err)
                {
                    console.error(err);
                    $scope.showSpinner = false;
                    handleError("Error" + err.message);
                });
            }

            $scope.syncLabels = function()
            {
                var labelsUrl = config.labelsUrl;

                $scope.showSpinner = true;
                $scope.showMsg = false;

                function sync(labelsResponse) {

                    console.log(labelsResponse);

                    var labels = labelsResponse.data;

                    console.log(labels);

                    var xmlDoc = document.implementation.createDocument("http://soap.sforce.com/2006/04/metadata", "CustomLabels");

                    function addNode(parentNode, nodeName, value) {
                        var node = xmlDoc.createElement(nodeName);
                        node.appendChild(xmlDoc.createTextNode(value));
                        parentNode.appendChild(node);
                    }

                    for (var i = 0; i < labels.length; i++) {
                        var label = labels[i];
                        var name = label.name, title = label.title;

                        var labelsNode = xmlDoc.createElementNS("http://soap.sforce.com/2006/04/metadata", "labels");
                        xmlDoc.documentElement.appendChild(labelsNode);

                        addNode(labelsNode, 'categories', 'Thor');
                        addNode(labelsNode, 'fullName', name);
                        addNode(labelsNode, 'language', 'en_US');
                        addNode(labelsNode, 'protected', false);
                        addNode(labelsNode, 'shortDescription', label.type + ': ' + title);
                        addNode(labelsNode, 'value', title);

                    }

                    var s = new XMLSerializer();
                    var xml = s.serializeToString(xmlDoc);

                    console.log(xml);

                    var zip = new JSZip();

                    zip.file('labels/CustomLabels.labels', xml);

                    zip.file('package.xml', '<?xml version="1.0" encoding="UTF-8"?>\n' +
                        '<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n' +
                        '\t<types>\n' +
                        '\t\t<members>*</members>\n' +
                        '\t\t<name>CustomLabels</name>\n' +
                        '\t</types>\n' +
                        '\t<version>45.0</version>' +
                        '</Package>');

                    var base64Zip = zip.generate({type: 'base64'});

                    var conn = new jsforce.Connection({ accessToken: config.accessToken });

                    conn.metadata.pollInterval = 3000;
                    conn.metadata.pollTimeout = 120000;

                    conn.metadata.deploy(base64Zip, {singlePackage: true, allowMissingFiles: true})
                        .complete(function (err, result) {

                            console.log('Deployment completed', err, result);
                            if (err)
                            {
                                handleError("Warning: Label deployment took over 2 minutes. See deployment progress in Setup > Deployment Status");
                                $timeout(function()
                                {
                                    $scope.showSpinner = false;
                                });
                            }
                            else
                            {
                                if (result.success == true)
                                {
                                    $scope.isSynced = true;
                                    $scope.refreshLabelsCache();
                                }
                                else
                                {
                                    $scope.outcome = "error";
                                    var msg = "Error: " + result.numberComponentErrors + " out of " +
                                        totalComponents + " components failed. See Setup > Deployment Status for details";
                                    handleError(msg);
                                    $timeout(function()
                                    {
                                        $scope.showSpinner = false;
                                    });
                                }
                            }
                        });
                }

                thorIntegrationService.retryOperationInCaseAuthenticationError(
                    function() {
                        return labelsSyncService.getLabels().then(function(labels)
                        {
                            sync(labels);
                            $scope.refreshLabelsCache();
                        }).catch(function(err)
                        {
                            console.error(err);
                            $scope.showSpinner = false;
                            handleError("Error occurs while retrieving labels from Thor");
                        });
                    }, labelsUrl
                );
            }

            $scope.refreshLabelsCache = function ()
            {
                var conn = new jsforce.Connection({ accessToken: config.accessToken });

                conn.metadata.pollInterval = 3000;
                conn.metadata.pollTimeout = 120000;

                $scope.showSpinner = true;
                $scope.showMsg = false;

                conn.metadata.list({type: 'CustomLabel', folder: null}, 40)
                    .then(function (data, err)
                    {

                        $scope.showSpinner = true;
                        if(err)
                        {
                            console.error(err);
                            $scope.showSpinner = false;
                            handleError("Timeout: operation took over 2 minutes.");
                        }

                        console.log(data);

                        var labels = [];

                        for(var i = 0; i<data.length; i++)
                        {
                            var label = data[i].fullName;
                            labels.push(label);
                        }

                        console.log('Refreshing cache', labels);

                        // Let's update the cache
                        remoteActions.refreshCustomLabelsCache(labels)
                            .then(function(data, err)
                                    {
                                        console.log('/Refreshing cache', data, err);
                                        $scope.showSpinner = false;
                                        var msg;
                                        if ($scope.isSynced) {
                                            msg = "Thor labels were synced with SFDC successfully";
                                            $scope.isSynced = false;
                                        }
                                        else
                                            msg = "Custom labels cache was refreshed successfully";
                                        showSuccessMsg(msg);
                                    }).catch(function(err)
                                    {
                                        console.error(err);
                                        $scope.showSpinner = false;
                                        handleError("Error" + err.message);
                                    });

                    });
            }

            $scope.closeMsg = function ()
            {
                $scope.showMsg = false;
            }
            
            $scope.openDebugLogsUI = function ()
            {
                // open debug logs UI in a separate window
                var debugLogsUIUrl = config.debugLogsUIUrl;
                console.log('opening debug logs UI URL', debugLogsUIUrl);
                window.open(debugLogsUIUrl);
            }

            $scope.openMonitoringUI = function ()
            {
                // open monitoring UI / Grafana in a separate window
                var monitoringUIUrl = config.monitoringUIUrl;
                console.log('opening monitoring UI URL', monitoringUIUrl);
                window.open(monitoringUIUrl);
            }

            $scope.openEncryptionKeysPage = function ()
            {
                // open encryption Keys Page in a separate window
                console.log('opening Encryption Keys Page URL');
                window.open('apex/'+config.namespacePrefix+'XOMManageEncryptionKeys');
            }

            var handleError = function(mesg)
            {
                $scope.Message = mesg;
                $scope.outcome = "error";
                $scope.showMsg = true;
            }

            var showSuccessMsg = function(mesg)
            {
                $scope.outcome = "success";
                $scope.Message = mesg;
                $scope.showMsg = true;
                $timeout(function() {
                    $scope.showMsg = false;
                 }, 5000);
            }

            $scope.updateOrchQueuesCnt = function()
            {
                $scope.showSpinner = true;

                function _updateOrchQueuesCnt(retries)
                {

                    console.log('Update Orchestration Queues count: retry = ' + retries);
                    if (retries > 20)
                    {
                        $scope.showSpinner = false;
                        $scope.hasErrors = true;
                        $scope.errorMessage = "Can't lock OrchestrationQueues. Please try again later";
                    }
                    else
                    {
                        remoteActions.updateOrchQueuesCnt().then(function(success)
                        {
                            if (!success)
                            {
                                _updateOrchQueuesCnt(retries + 1);
                            }
                            else
                            {
                                $scope.showSpinner = false;
                            }
                        });
                    }
                }

                _updateOrchQueuesCnt(0);
            };

            $scope.scheduleJeopardyManagementJobs = function ()
            {
                $scope.showSpinner = true;

                remoteActions.scheduleJeopardyManagementJobs()
                    .then(function(data, err)
                    {
                        console.log('Creating jeopardy management triggers and queueing apex batch jobs', data, err);
                        $scope.showSpinner = false;
                        showSuccessMsg("Jeopardy Management Job has been scheduled");
                    })
                    .catch(function(err)
                    {
                        console.error(err);
                        $scope.showSpinner = false;
                        handleError("Error " + err.message);
                    });

            }

            $scope.scheduleOrchestrationRecoveryJobs = function ()
            {
                $scope.showSpinner = true;

                remoteActions.scheduleOrchestrationRecoveryJobs()
                    .then(function(data, err)
                    {
                        console.log('Queueing orchestration recovery jobs', data, err);
                        $scope.showSpinner = false;
                        showSuccessMsg("Orchestration Recovery Job has been scheduled");
                    })
                    .catch(function(err)
                    {
                        console.error(err);
                        $scope.showSpinner = false;
                        handleError("Error " + err.message);
                    });
            }
        }

    ]);

},{}],3:[function(require,module,exports){
angular.module('xomadmin').controller('XOMConfigureLayoutsController',
    [
        '$scope', '$q', '$location', '$timeout', 'config', 'remoteActions',
        function($scope, $q, $location, $timeout, config, remoteActions)
        {
            console.log('XOMCOnfigureLayoutsController');

            var namespacePrefix = config.namespacePrefix;

            var packageRecordTypesAvailability =
                {
                    'OrchestrationItemDefinition__c':
                    [
                        {
                            recordType: namespacePrefix+'OrchestrationItemDefinition__c.'+namespacePrefix+'Callout',
                            default: false,
                            visible: true
                        },
                        {
                            recordType: namespacePrefix+'OrchestrationItemDefinition__c.'+namespacePrefix+'AutoTask',
                            default: false,
                            visible: true
                        },
                        {
                            recordType: namespacePrefix+'OrchestrationItemDefinition__c.'+namespacePrefix+'Milestone',
                            default: true,
                            visible: true
                        },
                        {
                            recordType: namespacePrefix+'OrchestrationItemDefinition__c.'+namespacePrefix+'ManualTask',
                            default: false,
                            visible: true
                        },
                        {
                            recordType: namespacePrefix+'OrchestrationItemDefinition__c.'+namespacePrefix+'PushEvent',
                            default: false,
                            visible: true
                        },
                        {
                            recordType: namespacePrefix+'OrchestrationItemDefinition__c.'+namespacePrefix+'SubPlan',
                            default: false,
                            visible: true
                        }
                    ]
                };

            var packageLayoutAssignments = {
                'XOM Base': {
                    'Order':
                        [
                            {
                                layout: 'Order-' + namespacePrefix + (config.isInsurance?'Order %28Vlocity Insurance%29 Layout V2':'Order %28Vlocity XOM%29 Layout V6')
                            }
                        ],
                    'InventoryItem__c':
                        config.isInsurance?
                            [
                            ]:
                            [
                                {
                                    layout: namespacePrefix + 'InventoryItem__c-' + namespacePrefix +'Inventory Item %28Vlocity XOM%29 Layout'
                                }
                            ],
                    'ManualQueue__c':
                        [
                            {

                                layout: namespacePrefix + 'ManualQueue__c-' + namespacePrefix + (config.isInsurance?'Manual Queue %28Vlocity Insurance%29 Layout':'Manual Queue %28Vlocity XOM%29 Layout V2')
                            }
                        ],
                    'OrchestrationItem__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationItem__c-' + namespacePrefix + (config.isInsurance?'Orchestration Item %28Vlocity Insurance%29 Layout V5':'Orchestration Item %28Vlocity XOM%29 Layout V2')
                            }
                        ],
                    'OrchestrationPlanDefinition__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationPlanDefinition__c-' + namespacePrefix + (config.isInsurance?'Orchestration Plan Definition %28Vlocity Insurance%29 Layout':'Orchestration Plan Definition %28Vlocity XOM%29 Layout')
                            }
                        ],
                    'OrchestrationPlan__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationPlan__c-' + namespacePrefix + (config.isInsurance?'Orchestration Plan %28Vlocity Insurance%29 Layout':'Orchestration Plan %28Vlocity XOM%29 Layout')
                            }
                        ]
                },
                'XOM Admin': {
                    'Order':
                        [
                            {
                                layout: 'Order-' + namespacePrefix + (config.isInsurance?'Order %28Vlocity Insurance%29 Layout V2':'Order %28Vlocity XOM%29 Layout V6')
                            }
                        ],
                    'FulfilmentRequest__c':
                    [
                        {
                            layout: namespacePrefix + 'FulfilmentRequest__c-' + namespacePrefix + 'Fulfilment Request %28Vlocity XOM%29 Layout'
                        },
                        {
                            layout: namespacePrefix + 'FulfilmentRequest__c-' + namespacePrefix + 'Fulfilment Request %28Vlocity XOM%29 Layout',
                            recordType: namespacePrefix + 'FulfilmentRequest__c.' + namespacePrefix + 'FulfilmentRequest'
                        },
                        {
                            layout: namespacePrefix + 'FulfilmentRequest__c-' + namespacePrefix + 'Fulfilment Request %28Vlocity XOM%29 Layout',
                            recordType: namespacePrefix + 'FulfilmentRequest__c.' + namespacePrefix + 'ServiceQualificationRequest'
                        }
                    ],
                    'InventoryItem__c':
                        config.isInsurance?
                            [
                            ]:
                            [
                                {
                                    layout: namespacePrefix + 'InventoryItem__c-' + namespacePrefix +'Inventory Item %28Vlocity XOM%29 Layout'
                                }
                            ],
                    'DecompositionRelationship__c':
                        [
                            {
                                layout: namespacePrefix + 'DecompositionRelationship__c-' + namespacePrefix +'Decomposition Relationship %28Vlocity XOM%29 Layout V4'
                            }
                        ],
                    'OrchestrationItemDefinition__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix + (config.isInsurance?'Orchestration Item Definition %28Vlocity Insurance%29 Layout':'Orchestration Item Definition %28Vlocity XOM%29 Layout V5')
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix + (config.isInsurance?'Orchestration Item Definition %28Vlocity Insurance%29 Layout':'Orchestration Item Definition %28Vlocity XOM%29 Layout V5'),
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'Milestone'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix +
                                    (config.isInsurance?'Auto Task %28Vlocity Insurance%29 Layout':'Auto Task %28Vlocity XOM%29 Layout V4'),
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'AutoTask'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix +
                                    (config.isInsurance?'Callout %28Vlocity Insurance%29 Layout':'Callout %28Vlocity XOM%29 Layout V5'),
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'Callout'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix +
                                    (config.isInsurance?'Manual Task %28Vlocity Insurance%29 Layout V2':'Manual Task %28Vlocity XOM%29 Layout V6'),
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'ManualTask'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix +
                                    (config.isInsurance?'Push Event %28Vlocity Insurance%29 Layout V2':'Push Event %28Vlocity XOM%29 Layout V6'),
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'PushEvent'
                            }
                        ],
                    'OrchestrationItem__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationItem__c-' + namespacePrefix + (config.isInsurance?'Orchestration Item %28Vlocity Insurance%29 Layout V5':'Orchestration Item %28Vlocity XOM%29 Layout V2')
                            }
                        ],
                    'OrchestrationPlan__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationPlan__c-' + namespacePrefix + (config.isInsurance?'Orchestration Plan %28Vlocity Insurance%29 Layout':'Orchestration Plan %28Vlocity XOM%29 Layout')
                            }
                        ],
                    'Product2':
                        [
                            {
                                layout: 'Product2-' + namespacePrefix + (config.isInsurance?'Product %28Vlocity Insurance%29 Layout V2':'Product %28Vlocity XOM%29 Layout V4')
                            },
                            {
                                layout: 'Product2-' + namespacePrefix + (config.isInsurance?'Product %28Vlocity Insurance%29 Layout V2':'Product %28Vlocity XOM%29 Layout V4'),
                                recordType: 'Product2.' + namespacePrefix + 'Product'
                            },
                            {
                                layout: 'Product2-' + namespacePrefix + (config.isInsurance?'Product %28Vlocity Insurance%29 Layout V2':'Product %28Vlocity XOM%29 Layout V4'),
                                recordType: 'Product2.' + namespacePrefix + 'Class'
                            }
                        ],
                    'OrchestrationScenario__c':
                    [
                        {
                            layout: namespacePrefix + 'OrchestrationScenario__c-' + namespacePrefix + 'Orchestration Scenario %28Vlocity XOM%29 Layout'
                        }
                    ],
                    'System__c':
                    [
                        {
                            layout: namespacePrefix + 'System__c-' + namespacePrefix + 'System %28Vlocity XOM%29 Layout'
                        }
                    ],
                    'ManualQueue__c':
                        [
                            {
                                layout: namespacePrefix + 'ManualQueue__c-' + namespacePrefix + (config.isInsurance?'Manual Queue %28Vlocity Insurance%29 Layout':'Manual Queue %28Vlocity XOM%29 Layout V2')
                            }
                        ],
                    'ItemImplementation__c':
                        [
                            {
                                layout: namespacePrefix + 'ItemImplementation__c-' + namespacePrefix + 'Item Implementation %28Vlocity XOM%29 Layout V3'
                            }
                        ],
                    'OrchestrationPlanDefinition__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationPlanDefinition__c-' + namespacePrefix + 'Orchestration Plan Definition %28Vlocity XOM%29 Layout'
                            }
                        ],
                    'SystemInterface__c':
                        [
                            {
                                layout:namespacePrefix + 'SystemInterface__c-' + namespacePrefix + 'System Interface %28Vlocity XOM%29 Layout'
                            }
                        ],
                     'FulfilmentRequestDecompRelationship__c':
                        [
                            {
                                layout:namespacePrefix + 'FulfilmentRequestDecompRelationship__c-' + namespacePrefix + 'Fulfilment Request Decomp Relationship %28Vlocity XOM%29 Layout'
                            }
                    	],
                     'FulfilmentRequestLine__c':
                        [
                             {
                                 layout:namespacePrefix + 'FulfilmentRequestLine__c-' + namespacePrefix + 'Fulfilment Request Line %28Vlocity XOM%29 Layout'
                             }
                     	],
                     'FulfilmentRequestLineDecompRelationship__c':
                        [
                             {
                                 layout:namespacePrefix + 'FulfilmentRequestLineDecompRelationship__c-' + namespacePrefix + 'Fulfilment Request Line Decomp Relationship %28Vlocity XOM%29 Layout'
                             }
                        ],
                     'InventoryItemDecompositionRelationship__c':
                        [
                             {
                                 layout:namespacePrefix + 'InventoryItemDecompositionRelationship__c-' + namespacePrefix + 'Inventory Item Decomposition Relationship %28Vlocity XOM%29 Layout'
                             }
                        ],
                     'OrchestrationQueueAssignmentRule__c':
                        [
                             {
                                 layout:namespacePrefix + 'OrchestrationQueueAssignmentRule__c-' + namespacePrefix + 'Orchestration Queue Assignment Rule %28Vlocity XOM%29 Layout'
                             }
                        ],
                     'OrchestrationPlan__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationPlan__c-' + namespacePrefix + 'Orchestration Plan %28Vlocity XOM%29 Layout V2'
                            }
                        ],
                     'OrchestrationQueue__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationQueue__c-' + namespacePrefix + 'Orchestration Queue %28Vlocity XOM%29 Layout V2'
                            }
                        ],
                    'OrchestrationPlanDefinition__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationPlanDefinition__c-' + namespacePrefix + (config.isInsurance?'Orchestration Plan Definition %28Vlocity Insurance%29 Layout':'Orchestration Plan Definition %28Vlocity XOM%29 Layout')
                            }
                        ]
                },
                'Thor Admin': {
                    'Order':
                        [
                            {
                                layout: 'Order-'+namespacePrefix+'Order %28Vlocity Thor%29 Layout V4'
                            }
                        ],
                    'FulfilmentRequest__c':
                    [
                        {
                            layout: namespacePrefix + 'FulfilmentRequest__c-' + namespacePrefix + 'Fulfilment Request %28Vlocity XOM%29 Layout'
                        },
                        {
                            layout: namespacePrefix + 'FulfilmentRequest__c-' + namespacePrefix + 'Fulfilment Request %28Vlocity XOM%29 Layout',
                            recordType: namespacePrefix + 'FulfilmentRequest__c.' + namespacePrefix + 'FulfilmentRequest'
                        },
                        {
                            layout: namespacePrefix + 'FulfilmentRequest__c-' + namespacePrefix + 'Fulfilment Request %28Vlocity XOM%29 Layout',
                            recordType: namespacePrefix + 'FulfilmentRequest__c.' + namespacePrefix + 'ServiceQualificationRequest'
                        }
                    ],
                    'InventoryItem__c':
                        config.isInsurance?
                            [
                            ]:
                            [
                                {
                                    layout: namespacePrefix + 'InventoryItem__c-' + namespacePrefix +'Inventory Item %28Vlocity XOM%29 Layout'
                                }
                            ],
                    'DecompositionRelationship__c':
                        [
                            {
                                layout: namespacePrefix + 'DecompositionRelationship__c-' + namespacePrefix +'Decomposition Relationship %28Vlocity XOM%29 Layout V4'
                            }
                        ],
                    'OrchestrationItemDefinition__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix +'Orchestration Item Definition %28Vlocity Thor%29 Layout V2'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix +'Orchestration Item Definition %28Vlocity Thor%29 Layout V2',
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'Milestone'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix + 'Auto Task %28Vlocity Thor%29 Layout V2',
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'AutoTask'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix + 'Callout %28Vlocity Thor%29 Layout V2',
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'Callout'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix + 'Manual Task %28Vlocity Thor%29 Layout V2',
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'ManualTask'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix + 'Push Event %28Vlocity Thor%29 Layout V2',
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'PushEvent'
                            },
                            {
                                layout: namespacePrefix + 'OrchestrationItemDefinition__c-' + namespacePrefix + 'Sub-plan %28Vlocity Thor%29 Layout V2',
                                recordType: namespacePrefix + 'OrchestrationItemDefinition__c.' + namespacePrefix + 'SubPlan'
                            }
                        ],
                    'Product2':
                        [
                            {
                                layout: 'Product2-' + namespacePrefix + 'Product %28Vlocity Thor%29 Layout'
                            },
                            {
                                layout: 'Product2-' + namespacePrefix + 'Product %28Vlocity Thor%29 Layout',
                                recordType: 'Product2.' + namespacePrefix + 'Product'
                            },
                            {
                                layout: 'Product2-' + namespacePrefix + 'Product %28Vlocity Thor%29 Layout',
                                recordType: 'Product2.' + namespacePrefix + 'Class'
                            }
                        ],
                    'OrchestrationScenario__c':
                    [
                        {
                            layout: namespacePrefix + 'OrchestrationScenario__c-' + namespacePrefix + 'Orchestration Scenario %28Vlocity XOM%29 Layout'
                        }
                    ],
                    'ErrorCodeNamespace__c':
                        [
                            {
                                layout: namespacePrefix + 'ErrorCodeNamespace__c-' + namespacePrefix + 'Error Code Namespace %28Vlocity XOM%29 Layout'
                            }
                        ],
                    'IntegrationRetryPolicy__c':
                        [
                            {
                                layout: namespacePrefix + 'IntegrationRetryPolicy__c-' + namespacePrefix +'Monotonous Forever Retry Policy %28Vlocity XOM%29 Layout',
                                recordType: namespacePrefix + 'IntegrationRetryPolicy__c.' + namespacePrefix + 'MonotonousForeverRetryPolicy'
                            },
                            {
                                layout: namespacePrefix + 'IntegrationRetryPolicy__c-' + namespacePrefix +'Monotonous Retry Policy %28Vlocity XOM%29 Layout',
                                recordType: namespacePrefix + 'IntegrationRetryPolicy__c.' + namespacePrefix + 'MonotonousRetryPolicy'
                            },
                            {
                                layout: namespacePrefix + 'IntegrationRetryPolicy__c-' + namespacePrefix +'No Retry Policy %28Vlocity XOM%29 Layout',
                                recordType: namespacePrefix + 'IntegrationRetryPolicy__c.' + namespacePrefix + 'NoRetryPolicy'
                            }
                        ],
                    'System__c':
                    [
                        {
                            layout: namespacePrefix + 'System__c-' + namespacePrefix + 'System %28Vlocity XOM%29 Layout'
                        }
                    ],
                    'ManualQueue__c':
                        [
                            {
                                layout: namespacePrefix + 'ManualQueue__c-' + namespacePrefix + 'Manual Queue %28Vlocity Thor%29 Layout V4'
                            }
                        ],
                    'ItemImplementation__c':
                        [
                            {
                                layout: namespacePrefix + 'ItemImplementation__c-' + namespacePrefix + 'Item Implementation %28Vlocity Thor%29 Layout'
                            }
                        ],
                    'OrchestrationPlanDefinition__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationPlanDefinition__c-' + namespacePrefix + 'Orchestration Plan Definition %28Vlocity XOM%29 Layout'
                            }
                        ],
                    'OperatingHoursEntry__c':
                        [
                            {
                                layout: namespacePrefix + 'OperatingHoursEntry__c-' + namespacePrefix + 'Standard Operating Hours Entry %28Vlocity Thor%29 Layout'
                            },
                            {
                                layout: namespacePrefix + 'OperatingHoursEntry__c-' + namespacePrefix +'Standard Operating Hours Entry %28Vlocity Thor%29 Layout',
                                recordType: namespacePrefix + 'OperatingHoursEntry__c.' + namespacePrefix + 'Standard'
                            },
                            {
                                layout: namespacePrefix + 'OperatingHoursEntry__c-' + namespacePrefix +'Exception Operating Hours Entry %28Vlocity Thor%29 Layout',
                                recordType: namespacePrefix + 'OperatingHoursEntry__c.' + namespacePrefix + 'Exception'
                            }
                        ],
                    'SystemInterface__c':
                        [
                            {
                                layout:namespacePrefix + 'SystemInterface__c-' + namespacePrefix + 'System Interface %28Vlocity XOM%29 Layout'
                            }
                        ],
                    'FulfilmentRequestDecompRelationship__c':
                        [
                           {
                                layout:namespacePrefix + 'FulfilmentRequestDecompRelationship__c-' + namespacePrefix + 'Fulfilment Request Decomp Relationship %28Vlocity XOM%29 Layout'
                           }
                      	],
                    'FulfilmentRequestLine__c':
                        [
                           {
                                layout:namespacePrefix + 'FulfilmentRequestLine__c-' + namespacePrefix + 'Fulfilment Request Line %28Vlocity XOM%29 Layout'
                           }
                        ],
                    'FulfilmentRequestLineDecompRelationship__c':
                        [
                           {
                                layout:namespacePrefix + 'FulfilmentRequestLineDecompRelationship__c-' + namespacePrefix + 'Fulfilment Request Line Decomp Relationship %28Vlocity XOM%29 Layout'
                           }
                        ],
                    'InventoryItemDecompositionRelationship__c':
                        [
                           {
                                layout:namespacePrefix + 'InventoryItemDecompositionRelationship__c-' + namespacePrefix + 'Inventory Item Decomposition Relationship %28Vlocity XOM%29 Layout'
                           }
                        ],
                    'OrchestrationQueueAssignmentRule__c':
                        [
                           {
                                layout:namespacePrefix + 'OrchestrationQueueAssignmentRule__c-' + namespacePrefix + 'Orchestration Queue Assignment Rule %28Vlocity XOM%29 Layout'
                           }
                        ]                 
                },
                'Thor Base':  {
                    'Order':
                        [
                            {
                                layout: 'Order-'+namespacePrefix+'Order %28Vlocity Thor%29 Layout V4'
                            }
                        ],
                    'InventoryItem__c':
                        [
                            {
                                layout: namespacePrefix + 'InventoryItem__c-' + namespacePrefix +'Inventory Item %28Vlocity XOM%29 Layout'
                            }
                        ],
                    'ManualQueue__c':
                        [
                            {
                                layout: namespacePrefix + 'ManualQueue__c-' + namespacePrefix + 'Manual Queue %28Vlocity Thor%29 Layout V3'
                            }
                        ],
                    'OrchestrationPlanDefinition__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationPlanDefinition__c-' + namespacePrefix + 'Orchestration Plan Definition %28Vlocity XOM%29 Layout'
                            }
                        ]
                },
                     'OrchestrationQueue__c':
                        [
                            {
                                layout: namespacePrefix + 'OrchestrationQueue__c-' + namespacePrefix + 'Orchestration Queue %28Vlocity XOM%29 Layout V2'
                            }
                        ]
            }

            $scope.profiles = [];

            $scope.profileOptions = [
                'None', 'XOM Base', 'XOM Admin'
            ];

            $scope.showSpinner = false;
            $scope.showMsg = false;

            if (config.isThorEnabled == 'true')
            {
                $scope.profileOptions.push('Thor Base');
                $scope.profileOptions.push('Thor Admin');
            }

            var conn = new jsforce.Connection({ accessToken: config.accessToken });

            $scope.retrieveProfiles = function ()
            {
                var id2fullName = {};

                conn.metadata.list({type: 'Profile'}, '39.0')
                    .then(function(res)
                      {
                        console.log(res);

                        for (var i = 0; i < res.length; i++)
                        {
                            id2fullName[res[i].id] = res[i].fullName;
                        }

                        return conn.query('select Id, Name, UserLicense.name from Profile where UserLicense.name = \'Salesforce\'');

                      })
                    .then(function(res)
                    {
                        for (var i = 0; i < res.records.length; i++)
                        {
                            res.records[i].fullName = id2fullName[res.records[i].Id];
                        }

                        console.log(res);

                        $scope.$apply(function()
                        {

                            $scope.profiles.length = 0;

                            var current;

                            for (var i = 0; i < res.records.length; i++)
                            {

                                if (i % 3 == 0)
                                {
                                    current = [];
                                    $scope.profiles.push(current);
                                }

                                current.push({
                                    Name: res.records[i].Name,
                                    Id: res.records[i].Id,
                                    FullName: res.records[i].fullName,
                                    xom: 'None'
                                });
                            }

                        });
                    })
                    .catch(function(err)
                    {
                        console.log('Error', err);
                    });

            }

            function stripNamespace(name)
            {
                var parts = name.split('__');


                if (parts.length > 1)
                {
                    // I.e. aaa__c
                    if (parts[1] == 'c')
                    {
                        return name;
                    }
                    else
                    {
                        return parts[1];
                    }
                }
                else
                {
                    return name;
                }
            }

            function updateProfile(zip, profileSettings)
            {

                console.log('Profile settings ', profileSettings);

                var profileName = profileSettings.name;

                var profileType = profileSettings.type;

                var zipFile = zip.file('profiles/' + profileName + '.profile');

                if (!zipFile)
                {
                    console.log('Profile ' + profileName +' is not found');
                }

                var xml = zipFile.asText();

                var xmlDoc = new DOMParser().parseFromString(xml,"text/xml");

                var rootNode = xmlDoc.getElementsByTagName('Profile')[0];

                var recordTypeNodes = rootNode.getElementsByTagName('recordTypeVisibilities');

                var recordTypeNodesToRemove = [];

                for (var i = 0; i<recordTypeNodes.length; i++)
                {
                    var objectType = stripNamespace(recordTypeNodes[i].getElementsByTagName('recordType')[0].childNodes[0].nodeValue.split('.')[0]);

                    if (packageRecordTypesAvailability[objectType])
                    {
                        recordTypeNodesToRemove.push(recordTypeNodes[i]);
                    }

                }

                for (var i = 0; i < recordTypeNodesToRemove.length; i++)
                {
                    rootNode.removeChild(recordTypeNodesToRemove[i]);
                }

                for (var objectType in packageRecordTypesAvailability)
                {
                    var assignments = packageRecordTypesAvailability[objectType];

                    for (var i=0; i < assignments.length; i++)
                    {
                        var assignment = assignments[i];

                        var assignmentNode = xmlDoc.createElement('recordTypeVisibilities');
                        rootNode.insertBefore(assignmentNode, recordTypeNodes[0]);

                        var defaultNode = xmlDoc.createElement('default');
                        assignmentNode.appendChild(defaultNode);
                        defaultNode.appendChild(xmlDoc.createTextNode(assignment['default']));

                        var visibleNode = xmlDoc.createElement('visible');
                        assignmentNode.appendChild(visibleNode);
                        visibleNode.appendChild(xmlDoc.createTextNode('true'));

                        var recordTypeNode = xmlDoc.createElement('recordType');
                        assignmentNode.appendChild(recordTypeNode);
                        recordTypeNode.appendChild(xmlDoc.createTextNode(assignment['recordType']));
                    }
                }

                var layoutAssignmentsNodesToRemove = [];

                var layoutAssignmentsNodes = rootNode.getElementsByTagName('layoutAssignments');

                var standardLayoutAssignments = packageLayoutAssignments[profileType];

                for (var i = 0; i< layoutAssignmentsNodes.length; i++)
                {
                    var layoutAssignmentsNode = layoutAssignmentsNodes[i];

                    var objectType, recordType;

                    var layoutNode = layoutAssignmentsNode.getElementsByTagName('layout')[0];

                    objectType = stripNamespace(layoutNode.childNodes[0].nodeValue.split('-')[0]);

                    if (standardLayoutAssignments[objectType])
                    {
                        layoutAssignmentsNodesToRemove.push(layoutAssignmentsNode);
                    }


                }

                for (var i = 0; i < layoutAssignmentsNodesToRemove.length; i++)
                {
//                    console.log('Removing layout assignments ', layoutAssignmentsNodesToRemove[i]);
                    rootNode.removeChild(layoutAssignmentsNodesToRemove[i]);
                }

                // Now lets setup layoutAssignments
                for (var assignment in standardLayoutAssignments)
                {
                    if (standardLayoutAssignments.hasOwnProperty(assignment))
                    {

                        console.log ('>>>> Assigment ', assignment);

                        var pageAssignments = standardLayoutAssignments[assignment];

                        for (var i=0; i < pageAssignments.length; i++)
                        {

                            var pageAssignment = pageAssignments[i];

                            console.log ('>>>> PageAssigment ', pageAssignment);

                            var newAssignment = xmlDoc.createElement('layoutAssignments');
                            rootNode.insertBefore(newAssignment, layoutAssignmentsNodes[0]);

                            var newLayout = xmlDoc.createElement('layout');
                            newAssignment.appendChild(newLayout);

                            newLayout.appendChild(xmlDoc.createTextNode(pageAssignment['layout']));

                            var recordType = pageAssignment['recordType'];

                            if (recordType)
                            {
                                var newRecordType = xmlDoc.createElement('recordType');
                                newAssignment.appendChild(newRecordType);

                                newRecordType.appendChild(xmlDoc.createTextNode(recordType));
                            }

                        }

                    }
                }

                var s = new XMLSerializer();

                var xml = s.serializeToString(xmlDoc);

                console.log(xml);

                zip.file('profiles/' + profileName + '.profile', xml);
            }

            function updateZip(zipfile, profilesSettings)
            {
                var zip = new JSZip(zipfile, {base64: true});

                for (var i = 0; i < profilesSettings.length; i++)
                {
                    updateProfile(zip, profilesSettings[i]);
                }

                zip.remove('objects');
                zip.remove('layouts');

                console.log ('Zip', zip);

                return zip.generate();

            }

            function setupProfiles(profilesSettings, cont)
            {

                var profilesToUpdate = [];

                for (var i = 0; i < profilesSettings.length; i++)
                {
                    profilesToUpdate.push(profilesSettings[i].name);
                }

                console.log('Profiles to update', profilesToUpdate);

                conn.metadata.retrieve({ packageNames: [], singlePackage: true,
                                        unpackaged:
                                            {   version: '45.0',
                                                types:
                                                [
                                                    {members: profilesToUpdate, name: 'Profile'},
                                                    {members: ['*'], name: 'CustomObject'},
                                                    {members: ['*'], name: 'Layout'}
                                                ]}},
                function(err, data)
                {
                    // console.log('Err', err);
                    // console.log('Data', data);

                    function checkRetrievalStatus(id, cont)
                    {

                        conn.metadata.checkRetrieveStatus(id, function(err, status)
                        {
                            console.log('Status', status);
                            if (status.done == "false")
                            {
                                checkRetrievalStatus(id, cont);
                            }
                            else
                            {
                                cont(status);
                            }

                        })
                    }

                    checkRetrievalStatus(data.id, function(status)
                    {
                        console.log('End status: ', status);
                        var base64upload = updateZip(status.zipFile, profilesSettings);

                        function checkDeploy(id, cont)
                        {
                            conn.metadata.checkDeployStatus(id, function(err, res)
                            {
                                if (err)
                                {
                                    console.log('Error', err);
                                }
                                else
                                {
                                    console.log('Check Deploy Res', res);
                                    if (res.done == "true")
                                    {
                                        cont(res);
                                    }
                                    else
                                    {
                                        checkDeploy(id, cont);
                                    }
                                }
                            });

                        }

                        conn.metadata.pollInterval = 3000;
                        conn.metadata.pollTimeout = 240000;

                        conn.metadata.deploy(base64upload, {singlePackage: true, allowMissingFiles: true})
                           .complete(function(err, result) {
                                if (err) {
                                    console.error(err);
                                    $scope.Message = "Warning: Layout deployment took over 4 minutes. See deployment progress in Setup > Deployment Status";
                                    $scope.outcome = "error";
                                } else {
                                    if (result.success == true) {
                                        $scope.outcome = "success";
                                        $scope.Message = "Layouts were successfully assigned to Profiles selected";
                                        $timeout(function() {
                                            $scope.showMsg = false;
                                         }, 5000);
                                    } else {
                                        $scope.outcome = "error";
                                        var totalComponents = result.numberComponentErrors + result.numberComponentsDeployed;
                                        $scope.Message = "Error: " + result.numberComponentErrors + " out of " +
                                            totalComponents + " components failed. See Setup > Deployment Status for details";
                                    }
                                }
                                $scope.showMsg = true;
                                cont();
                              });
                        });

                });

            }

            $scope.save = function ()
            {

                console.log('Save!');

                $scope.showMsg = false;
                $scope.showSpinner = true;

                var profilesSettings = [];

                for(var i = 0; i < $scope.profiles.length; i++)
                {
                    for (var j = 0; j < $scope.profiles[i].length; j++)
                    {
                        if (packageLayoutAssignments[$scope.profiles[i][j].xom])
                        {
                            profilesSettings.push({name: $scope.profiles[i][j].FullName, type: $scope.profiles[i][j].xom});
                        }
                    }
                }

                setupProfiles(profilesSettings, function()
                {
                    $timeout(function()
                        {
                            $scope.showSpinner = false;
                        });
                });

            }

            $scope.cancel = function()
            {
                $location.path('/');
            }

            $scope.closeMsg = function ()
            {
                $scope.showMsg = false;
            }

            $scope.retrieveProfiles();

        }
    ]);


},{}],4:[function(require,module,exports){
angular.module("xomadmin").run(["$templateCache",function($templateCache){"use strict";$templateCache.put("XOMAdmin.tpl.html",'<div>\n    <div class="slds-clearfix slds-p-around--small">\n    </div>\n    <div style="height: 4rem;" ng-show="showMsg">\n        <div class="slds-notify_container slds-is-relative">\n            <div class="slds-notify slds-notify_toast slds-theme_{{outcome}}" role="alert">\n                <span class="slds-assistive-text">{{outcome}}</span>\n                <span class="slds-icon_container slds-icon-utility-{{outcome}} slds-m-right_small slds-no-flex slds-align-top">\n                    <svg ng-if="outcome == \'success\'"class="slds-icon slds-icon_small" aria-hidden="true">\n                        <use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#success" />\n                    </svg>\n                    <svg ng-if="outcome == \'error\'"class="slds-icon slds-icon_small" aria-hidden="true">\n                        <use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#error" />\n                    </svg>\n                </span>\n                <div class="slds-notify__content">\n                    <h2 class="slds-text-heading_small ">{{Message}}.</h2>\n                </div>\n                <button class="slds-button slds-button_icon slds-notify__close slds-button_icon-inverse" title="Close" ng-click="closeMsg()">\n                    <svg class="slds-button__icon slds-button__icon_large" aria-hidden="true">\n                        <use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#close" />\n                    </svg>\n                    <span class="slds-assistive-text">Close</span>\n                </button>\n            </div>\n        </div>\n    </div>\n    <div class="slds-theme--shade">\n        <div class="job-wrapper slds-p-around--medium">\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Apply Record Types and Page Layout Assignments</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Configures (or restores) Record Types visibility and Page Layouts for Vlocity XOM</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="configureLayouts" type="button" ng-click="configureLayouts()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="createEpcObjectClassesStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Check OM+ Environment Status</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Retrieves OM+ Environment Status Information</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="checkEnvStatus" type="button" ng-click="checkEnvStatus()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="checkEnvStatusStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Synchronize Catalog with Thor</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Synchronizes an associated Thor instance with Thor</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="syncCatalog" type="button" ng-click="syncCatalog()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="createEpcDefaultLayoutsStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isDeltaTrackingEnabled" >\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Delete Sync Delta Objects</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Deletes all Sync Delta Objects</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="forcePopulateSyncDelta" type="button" ng-click="cleanupSyncDelta()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="deleteEpcDefaultLayoutsStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isDeltaTrackingEnabled" >\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Generate Sync Delta Objects</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Regenerates Sync Delta Objects for the whole catalog</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="forcePopulateSyncDelta" type="button" ng-click="forcePopulateSyncDelta()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="deleteEpcDefaultLayoutsStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isDeltaTrackingEnabled" >\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Generate Global Keys</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Ensures that all Catalog objects have Global Key set</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="forcePopulateSyncDelta" type="button" ng-click="ensureGlobalKeys()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="deleteEpcDefaultLayoutsStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isThorEnabled" >\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Create Vlocity DataRaptor Bundles for Thor sync</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Creates or (fully re-creates) Vlocity DataRaptor Bundler for Thor sync</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="forcePopulateSyncDelta" type="button" ng-click="createDataRaptorBundlesForBackSync()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="deleteEpcDefaultLayoutsStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isDevEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Download sync deltas</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Downloads last 200 sync deltas as a file</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="downloadSyncDetas" type="button" ng-click="downloadSyncDeltas()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="deleteEpcDefaultLayoutsStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Synchronize I18n labels and Refresh Cache</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Downloads all labels from Thor and sync them to SFDC</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="syncLabels" type="button" ng-click="syncLabels()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="deleteEpcDefaultLayoutsStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Update Orchestration Queues Counters</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Updates number of active Orchestration Items against Orchestration Queues</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="updateOrchQueuesCount" type="button" ng-click="updateOrchQueuesCnt()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="updateOrchQueuesCountStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            \x3c!--<div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Refresh I18n cache</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Refreshes Custom Labels cache</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="syncLabels" type="button" ng-click="refreshLabelsCache()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="deleteEpcDefaultLayoutsStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>--\x3e\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">OMplus Platform Debug Logs</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Navigate to OMplus Logging UI</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="openDebugLogsUI" type="button" ng-click="openDebugLogsUI()" class="slds-button  slds-button--brand">Open</button>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">OMplus Platform Monitoring</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Navigate to OMplus Monitoring UI</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="openMonitoringUI" type="button" ng-click="openMonitoringUI()" class="slds-button  slds-button--brand">Open</button>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Manage Encryption Keys</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Navigate to Manage Encryption Keys Page</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="openEncryptionKeysPage" type="button" ng-click="openEncryptionKeysPage()" class="slds-button  slds-button--brand">Open</button>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="!isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Schedule Jeopardy Management Job</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Schedule Jeopardy Management Job using intervalMins defined in XOMSetup custom settings</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="scheduleJmJobs" type="button" ng-click="scheduleJeopardyManagementJobs()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="jmJobSchedulingStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n            <div class="job-section slds-m-top--x-small slds-has-divider--bottom" ng-if="!isThorEnabled">\n                <div class="job-content slds-clearfix">\n                    <div class="job-detail slds-float--left">\n                        <div class="job-label">\n                            <a href="javascript:void(0)">Schedule Orchestration Recovery Job</a>\n                        </div>\n                        <div class="job-desc slds-m-top--x-small">Schedule Orchestration Recovery Job to execute periadically (period is defined in XOMSetup custom settings as OrchestrationRecoveryWaitPeriodMins)</div>\n                    </div>\n                    <div class="job-start slds-float--right">\n                        <button id="scheduleOmRecoveryJobs" type="button" ng-click="scheduleOrchestrationRecoveryJobs()" class="slds-button  slds-button--brand">Start</button>\n                    </div>\n                </div>\n                <div class="row">\n                    <div id="omJobSchedulingStatus" class="col-md-12 col-sm-12 col-xs-12">\n                        <div ng-if="hasErrors" class="alert alert-danger" role="alert">{{errorMessage}}</div>\n                    </div>\n                </div>\n            </div>\n        </div>\n    </div>\n</div>\n<div class="slds-spinner_container" ng-show="showSpinner">\n    <div class="slds-spinner--brand slds-spinner slds-spinner--large" aria-hidden="false" role="alert">\n        <div class="slds-spinner__dot-a"></div>\n        <div class="slds-spinner__dot-b"></div>\n    </div>\n</div>'),$templateCache.put("XOMConfigureLayouts.tpl.html",'<div class="_slds-align--absolute-center">\n    <div class="slds-panel">\n        <form class="slds-form--compound">\n            <div class="slds-panel__section slds-has-divider--bottom">\n                <div class="slds-form-element__row">\n                    <div class="slds-form-element slds-size--1-of-1 slds-clearfix">\n                        <button class="slds-button slds-button--brand slds-float--right"\n                                ng-disabled="readOnly" ng-click="cancel()">Cancel</button>\n                        <button class="slds-button slds-button--brand slds-float--right slds-m-right--medium"\n                                ng-disabled="readOnly" ng-click="save()">Update</button>\n                    </div>\n\n                </div>\n            </div>\n            <div style="height: 4rem;" ng-show="showMsg">\n                <div class="slds-notify_container slds-is-relative">\n                    <div class="slds-notify slds-notify_toast slds-theme_{{outcome}}" role="alert">\n                        <span class="slds-assistive-text">{{outcome}}</span>\n                        <span class="slds-icon_container slds-icon-utility-{{outcome}} slds-m-right_small slds-no-flex slds-align-top">\n                            <svg ng-if="outcome == \'success\'"class="slds-icon slds-icon_small" aria-hidden="true">\n                                <use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#success" />\n                            </svg>\n                            <svg ng-if="outcome == \'error\'"class="slds-icon slds-icon_small" aria-hidden="true">\n                                <use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#error" />\n                            </svg>\n                        </span>\n                        <div class="slds-notify__content">\n                            <h2 class="slds-text-heading_small ">{{Message}}.</h2>\n                        </div>\n                        <button class="slds-button slds-button_icon slds-notify__close slds-button_icon-inverse" title="Close" ng-click="closeMsg()">\n                            <svg class="slds-button__icon slds-button__icon_large" aria-hidden="true">\n                                <use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#close" />\n                            </svg>\n                            <span class="slds-assistive-text">Close</span>\n                        </button>\n                    </div>\n                </div>\n            </div>\n            <div class="slds-panel__section slds-has-divider--bottom">\n                <h3 class="slds-text-heading--small slds-m-bottom--medium">Profiles Assignments</h3>\n                <div class="slds-form-element__row" ng-repeat="profileChunk in profiles">\n                    <div class="slds-form-element slds-size--1-of-3" ng-repeat="profile in profileChunk track by profile.Id">\n                        <div class="slds-form-element slds-lookup slds-is-open">\n                            <label class="slds-form-element__label" ng-bind="profile.Name"></label>\n                            <div class="slds-form-element__control">\n                                <div class="slds-select_container">\n                                    <select class="slds-select"\n                                            ng-model="profile.xom"\n                                            ng-options="item for item in profileOptions">\n                                    </select>\n                                </div>\n                            </div>\n                        </div>\n                    </div>\n                </div>\n            </div>\n\n        </form>\n    </div>\n</div>\n<div class="slds-spinner_container" ng-show="showSpinner">\n    <div class="slds-spinner--brand slds-spinner slds-spinner--large" aria-hidden="false" role="alert">\n        <span class="slds-assistive-text">Deploying layouts</span>\n        <div class="slds-spinner__dot-a"></div>\n        <div class="slds-spinner__dot-b"></div>\n    </div>\n</div>')}]);

},{}]},{},[1]);
})();
