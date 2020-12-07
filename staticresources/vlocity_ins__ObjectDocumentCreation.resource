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
angular.module('objectDocumentCreation', ['vlocity', 'ngSanitize', 'sldsangular'])
    .config(['remoteActionsProvider', function(remoteActionsProvider) {
        'use strict';
        var nsPrefixDotNotation = fileNsPrefixDot();
        var remoteActions = {
            createObjectDocument: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationController.createObjectDocument',
                config: {escape: false,  buffer: false}
            },
            savePdf: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationController.savePdf',
                config: {escape: false,  buffer: false}
            },
            downloadPdf: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationController.downloadPdf',
                config: {escape: false,  buffer: false}
            },
            saveDocx: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationController.saveDocx',
                config: {escape: false,  buffer: false}
            },
            getDocTemplateResource: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationController.getDocTemplateResource',
                config: {escape: false,  buffer: false}
            },
            getObjVersionDocument: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationController.getObjVersionDocument',
                config: {escape: false,  buffer: false}
            },
            deleteAttachment: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationController.deleteAttachment',
                config: {escape: false,  buffer: false}
            },
            getTokenData: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationDocxController.getTokenData',
                config: {escape: false,  buffer: false}
            },
            linkContentVersionToObject: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationDocxController.linkContentVersionToObject',
                config: {escape: false,  buffer: false}
            },
            getCommunityDetails: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationDocxController.getCommunityDetails',
                config: {escape: false,  buffer: false}
            },
            generatePdfDocument: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationDocxController.generatePdfDocument',
                config: {escape: false, buffer: false}
            },
            getClientSidePdfLibraries: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationDocxController.getClientSidePdfLibraries',
                config: {escape: false, buffer: false}
            },
            getPDFIntegrationConfig: {
                action: nsPrefixDotNotation + 'ObjectDocumentCreationDocxController.getPDFIntegrationConfig',
                config: {escape: false}
            }
        };
        // Only desktop would need RemoteActions
        if (typeof Visualforce !== 'undefined') {
            remoteActionsProvider.setRemoteActions(remoteActions || {});
        }
    }])
    .run(['$rootScope', function($rootScope) {
        'use strict'; 
        $rootScope.nsPrefix = fileNsPrefix();
        $rootScope.loading = false;
    }]);

// Directives
require('./modules/objectDocumentCreation/directive/FilePreviewEmbedSwf.js');
require('./modules/objectDocumentCreation/directive/FilePreviewPdfTron.js');
require('./modules/objectDocumentCreation/directive/ObjectDocumentCreationDropdownHandler.js');

// Controllers
require('./modules/objectDocumentCreation/controller/ObjectDocumentCreationController.js');
require('./modules/objectDocumentCreation/controller/ObjectDocumentCreationDocXController.js');

// Components
require('./modules/objectDocumentCreation/component/docxTemplateComponent.js');

// Templates
require('./modules/objectDocumentCreation/templates/templates.js');
// Factories
require('./modules/objectDocumentCreation/factory/ObjectDocumentCreationService.js');

},{"./modules/objectDocumentCreation/component/docxTemplateComponent.js":2,"./modules/objectDocumentCreation/controller/ObjectDocumentCreationController.js":3,"./modules/objectDocumentCreation/controller/ObjectDocumentCreationDocXController.js":4,"./modules/objectDocumentCreation/directive/FilePreviewEmbedSwf.js":5,"./modules/objectDocumentCreation/directive/FilePreviewPdfTron.js":6,"./modules/objectDocumentCreation/directive/ObjectDocumentCreationDropdownHandler.js":7,"./modules/objectDocumentCreation/factory/ObjectDocumentCreationService.js":8,"./modules/objectDocumentCreation/templates/templates.js":9}],2:[function(require,module,exports){
angular.module('objectDocumentCreation').component('docxTemplateComponent', {
    templateUrl: 'component/docxTemplateComponent.tpl.html',
    bindings: {
        labels: '<',
        ispdfDownloadReady: '<',
        docType: '<',
        generatedContentVersion: '<',
        pdfSinglePageViewer: '<'
    },
    controller: function($scope) {
        var ctrl = this;
    
        ctrl.$onChanges = function(changes) {
            if (changes.generatedContentVersion) {
                $scope.generatedContentVersion= changes.generatedContentVersion.currentValue;
            }
            if (changes.labels) {
                $scope.labels = changes.labels.currentValue;
            }
            if(changes.ispdfDownloadReady){
                $scope.ispdfDownloadReady = changes.ispdfDownloadReady.currentValue;
            }
            if(changes.docType){
                $scope.docType = changes.docType.currentValue;
            }
            if(changes.pdfSinglePageViewer){
                $scope.pdfSinglePageViewer = changes.pdfSinglePageViewer.currentValue;
            }
        };
    }
});

},{}],3:[function(require,module,exports){
angular.module('objectDocumentCreation').controller('objectDocumentCreationController',
    ['$scope', 'ObjectDocumentCreationService', function($scope, ObjectDocumentCreationService) {
    'use strict';
    $scope.objDocCreationService = ObjectDocumentCreationService;

    // Logic that decides the doctype
    $scope.dropdownItems = [];
    if ($scope.objDocCreationService.documentType === 'attachment') {
        $scope.dropdownItems = [{
            label: 'Generate PDF',
            type: 'pdf'
        }, {
            label: 'Generate Word',
            type: 'word'
        }];
    } else {
        $scope.dropdownItems = [{
            label: 'Generate ' + $scope.objDocCreationService.documentType.toUpperCase(),
            type: $scope.objDocCreationService.documentType
        }];
    }
}]);

},{}],4:[function(require,module,exports){
angular.module('objectDocumentCreation').controller('objectDocumentCreationDocXController', [
    '$scope', 'remoteActions', '$window', '$q', '$timeout', function($scope, remoteActions, $window, $q, $timeout) {
    'use strict';
    sforce.connection.serverUrl = window.sitePrefix + sforce.connection.serverUrl; // for the community portal
    sforce.connection.sessionId = window.sessionId;
    this.$onInit = function() {
        $scope.vlcLoading = true;
        $scope.isPdfDownloadReady = false;
        $scope.labels = (window.labels || {});
        $scope.getCommunityDetails();
        $scope.pdfSinglePageViewer = {};
        $scope.pdfGenerationSourceMethod = 'salesforce';
        $scope.pdfViewer='vlocityclientsideviewer';
        $scope.clientSidePdfGenerationConfig={};
        $scope.generatedContentVersion={};
        $scope.generatedPDFContentVersion={};
        $scope.pdfIntegrationConfig={};
        if (window.pdfViewer !== undefined) {
            $scope.pdfViewer = window.pdfViewer.toLowerCase();
        }
        if (window.nameSpacePrefix !== undefined) {
            $scope.nameSpacePrefix = window.nameSpacePrefix;
        }
        if (window.pdfGenerationSourceMethod !== undefined) {
            $scope.pdfGenerationSourceMethod = window.pdfGenerationSourceMethod.toLowerCase();
        }

        //if pdf generation method is vlocityclientside. Set resource path in coreControls
        if ($scope.pdfGenerationSourceMethod.match(/vlocityclientside/i) || $scope.pdfViewer.match(/VlocityClientsideViewer/i)) {
            pdfTronSetResourcePath(remoteActions, $scope.clientSidePdfGenerationConfig).then(function(result){
                if( $scope.labels.VlocityPDFTronNoSystemUserMsg === result){
                    //$scope.validationErrorHandler($scope.labels.VlocityPDFTronNoSystemUserMsg);
                }
                else{
                    $scope.clientSidePdfGenerationConfig = result.clientSidePdfGenerationConfig
                    $scope.pdfIntegrationConfig= JSON.parse(result.license);
                }
            });
        }
        
        var vlocObjDocCreation = window.vlocObjDocCreation || {};
        if (vlocObjDocCreation.contextId === '' || vlocObjDocCreation.templateId === '') {
            // use bpTree response
            $window.parent.postMessage({'GET_BPTREE_RESPONSE': true}, '*');
        } else {
            $scope.contextId = vlocObjDocCreation.contextId;
            $scope.templateId = vlocObjDocCreation.templateId;
            $scope.templateType = vlocObjDocCreation.templateType;
            $scope.documentType = ((vlocObjDocCreation.documentType && vlocObjDocCreation.documentType.toLowerCase()) || 'all');
            $scope.inTest = (vlocObjDocCreation.inTest && vlocObjDocCreation.inTest === 'true');
            $scope.attachFileFormat =  ((vlocObjDocCreation.attachFileFormat && vlocObjDocCreation.attachFileFormat.toLowerCase()) || 'docx, pptx');
            $scope.showDownloadWord = ($scope.templateType === 'Microsoft Word .DOCX Template' && ($scope.inTest || $scope.documentType === 'all' || $scope.documentType === 'word'));
            $scope.showDownloadPPT = ($scope.templateType === 'Microsoft Powerpoint .PPTX Template' && ($scope.inTest || $scope.documentType === 'all' || $scope.documentType === 'ppt'));
            $scope.showDownloadPDF = ($scope.inTest || $scope.documentType === 'all' || $scope.documentType === 'pdf');

            $scope.generateContractDocumentDocXTemplate();
        }
    };

    $window.addEventListener('message', function(event) {
        if(!event.data.hasOwnProperty('clmDocxBpTreeResponse')) {
            return;
        }
        $scope.bpTreeResponse = event.data.clmDocxBpTreeResponse;

        $scope.contextId = $scope.bpTreeResponse.contextId;
        $scope.templateId = $scope.bpTreeResponse.templateId;
        $scope.templateType = $scope.bpTreeResponse.templateType;
        $scope.documentType = (($scope.bpTreeResponse.documentType && $scope.bpTreeResponse.documentType.toLowerCase()) || 'all');
        $scope.inTest = ($scope.bpTreeResponse.inTest && $scope.bpTreeResponse.inTest === 'true');
        $scope.attachFileFormat = $scope.bpTreeResponse.attachFileFormat && $scope.bpTreeResponse.attachFileFormat.toLowerCase();
        $scope.showDownloadWord = ($scope.templateType === 'Microsoft Word .DOCX Template' && ($scope.inTest || $scope.documentType === 'all' || $scope.documentType === 'word'));
        $scope.showDownloadPPT = ($scope.templateType === 'Microsoft Powerpoint .PPTX Template' && ($scope.inTest || $scope.documentType === 'all' || $scope.documentType === 'ppt'));
        $scope.showDownloadPDF = ($scope.inTest || $scope.documentType === 'all' || $scope.documentType === 'pdf');
        $scope.osPdfViewer = $scope.bpTreeResponse.pdfViewer && $scope.bpTreeResponse.pdfViewer.toLowerCase();
        if($scope.osPdfViewer == 'vlocityclientsideviewer') {
            $scope.pdfViewer = 'vlocityclientsideviewer';
        } else if($scope.osPdfViewer = 'none'){
            $scope.pdfViewer = 'none';
        }

        $scope.generateContractDocumentDocXTemplate();
    }, false);


    $scope.getCommunityDetails = function() {
        remoteActions.getCommunityDetails().then(function(result) {
            $scope.networkId = result.networkId;
            $scope.communityName = result.communityName;
        });
    };

    // Generate a Contract Document based on a DocX Template
    $scope.generateContractDocumentDocXTemplate = function() {
        // (1): get the token data from the document template
        $scope.getDocXTokenData().then(function() {
            // (2): get the attached document template file content
            $scope.getTemplateFileContent($scope.templateContentVersionId).then(function() {
                // (3): generate a new contract document based on the template file content and the token data
                $scope.generateDocXFromTokenData($scope.templateContentVersion.VersionData, $scope.docXTokenData).then(function(data) {
                    // (4): save the generated document file as a new ContentVersion record
                    $scope.saveGeneratedDocXFile(data.fileName, data.fileContent).then(function(generatedContentVersionId) {
                        if ($scope.inTest) {
                            $scope.vlcLoading = false;
                        } else {
                            // (5): link the new ContentVersion record to the Object based on the attachFileFormat setup value.
                            if(($scope.templateType === 'Microsoft Powerpoint .PPTX Template' && $scope.attachFileFormat && $scope.attachFileFormat.indexOf("pptx") > -1) ||
                            ($scope.templateType === 'Microsoft Word .DOCX Template' && $scope.attachFileFormat && $scope.attachFileFormat.indexOf("docx") > -1)) {
                                $scope.linkContentVersionToObject(generatedContentVersionId);
                            }
                        }
                    }, function(error) {
                        console.error('error: ', error);
                        $scope.vlcLoading = false;
                    });
                });
            }, function(error) {
                console.error('error: ', error);
                $scope.vlcLoading = false;
            });
        }, function(error) {
            console.error('error: ', error);
            $scope.vlcLoading = false;
        });
    };

    $scope.getDocXTokenData = function() {
        var deferred = $q.defer();

        $scope.docXTokenData = {};

        $scope.getTokenData();
        
        $scope.$on('tokenDataFetchComplete', function () {
            // all token data has been retrieved; resolve the promise
            deferred.resolve(true);
        });

        return deferred.promise;
    };

    $scope.getTokenData = function(tokenDataQueryInfo) {
        var inputData = {
            'contextId': $scope.contextId,
            'templateId': $scope.templateId,
            'bpTreeResponse': JSON.stringify($scope.bpTreeResponse)
        };
        if (tokenDataQueryInfo !== undefined) {
            inputData['tokenDataQueryInfo'] = JSON.stringify(tokenDataQueryInfo);
        }
        remoteActions.getTokenData(inputData).then(function(result) {
            if (tokenDataQueryInfo === undefined) {
                $scope.templateContentVersionId = result.contentVersionId;
            }
            
            // merge the existing token data with the incoming token data
            $scope.docXTokenData = deepmerge($scope.docXTokenData, result.tokenMap);

            if (result.hasMoreTokenData) {
                // there is more token data that needs to be retreived
                $scope.getTokenData(result.tokenDataQueryInfo);
            } else {
                // all token data has been retrieved
                $scope.$emit('tokenDataFetchComplete');
            }
        }, function(error) {
            console.error('error: ', error);
            $scope.vlcLoading = false;
        });
    };

    $scope.getTemplateFileContent = function(contentVersionId) {
        var deferred = $q.defer();

        var queryString = 'Select Id, Title, FileExtension, VersionData FROM ContentVersion where Id = \'' + contentVersionId + '\'';
        sforce.connection.query(queryString, {
            onSuccess: function(result) {
                $scope.templateContentVersion = {
                    'Id': result.records.Id,
                    'Title': result.records.Title,
                    'VersionData': base64ToArrayBuffer(result.records.VersionData)
                }
                var docName = $scope.templateContentVersion.Title;
                var FileExtension = '.'+result.records.FileExtension;
                $scope.sourceFileName = docName.substr(0, docName.lastIndexOf(FileExtension));
                deferred.resolve(true);
            },  
            onFailure: function(result) {
                var errorMsg = result.faultstring;
                deferred.reject(errorMsg);
            }
        });

        return deferred.promise;
    };

    $scope.generateDocXFromTokenData = function(fileContentData, docXTokenData) {
        var deferred = $q.defer();

        var zip = new JSZip(fileContentData);
        var doc = new Docxtemplater();
        doc.setOptions({
            delimiters: {
                start: '{{', 
                end: '}}'
            },
            nullGetter: function(part) {
                if (!part.module) {
                    return "";
                }
                if (part.module === "rawxml") {
                    return "";
                }
                return "";
            }
        });
        doc.loadZip(zip);

        if ($scope.templateType === 'Microsoft Word .DOCX Template') {
            /* Update table of contents */

            //@TODO: Lots of workarounds or patchs done for updating table of contents; needs to be optimized before using
            var settings = zip.files["word/settings.xml"].asText();
            var settingsXMLDoc = $.parseXML(settings);

            var updateFieldsElement = '<w:updateFields></w:updateFields>';
            var $updateFieldsElement = $(updateFieldsElement).attr("w:val","true");
            $(settingsXMLDoc).children().append($updateFieldsElement);

            // https://github.com/open-xml-templating/docxtemplater/issues/240
            var settingsRaw = (new XMLSerializer()).serializeToString(settingsXMLDoc);
            settingsRaw = settingsRaw.replace(' xmlns="http://www.w3.org/1999/xhtml"', '');
            zip.file("word/settings.xml", settingsRaw);

            // https://blogs.msdn.microsoft.com/pfedev/2010/08/08/openxml-how-to-refresh-a-field-when-the-document-is-opened/
            var documentXML = zip.files["word/document.xml"].asText();
            // @Todo: Update only table of content fields. Code below updates all fields.
            documentXML = documentXML.replace(/<w:fldChar /g, '<w:fldChar w:dirty="true" ');
            zip.file("word/document.xml", documentXML);
        }

        // replace the tokens with real data in the document
        doc.setData(docXTokenData);

        try {
            // render the document
            doc.render();
        } catch (error) {
            $scope.vlcLoading = false;
            console.error('DocXTemplate error:', error);
            // The error thrown here contains additional information when logged with JSON.stringify (it contains a property object).
            throw error;
        }

        var outputFileName = $scope.templateContentVersion.Title;
        var outputFileConfig;
        if ($scope.templateType === 'Microsoft Word .DOCX Template') {
            outputFileConfig = {
                'type': 'blob',
                'mimeType': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
            };
        } else if ($scope.templateType === 'Microsoft Powerpoint .PPTX Template') {
            outputFileConfig = {
                'type': 'blob',
                'mimeType': 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
            };
        }
        var outputContentBlob = doc.getZip().generate(outputFileConfig);

        var dataReader = new FileReader();
        dataReader.addEventListener('load', function() {
            var outputContentBase64 = dataReader.result;
            var base64Mark = 'base64,';
            var dataStart = outputContentBase64.indexOf(base64Mark) + base64Mark.length;
            outputContentBase64 = outputContentBase64.substring(dataStart);
            
            deferred.resolve({'fileName': outputFileName, 'fileContent': outputContentBase64});
        });
        dataReader.readAsDataURL(outputContentBlob);

        return deferred.promise;
    };

    $scope.saveGeneratedDocXFile = function(fileName, fileContent) {
        var deferred = $q.defer();
        
        var contentVersionSObj = new sforce.SObject('ContentVersion');
        contentVersionSObj.Title = fileName;
        contentVersionSObj.PathOnClient = fileName;
        contentVersionSObj.VersionData = fileContent;

        if($scope.networkId) {
            contentVersionSObj.NetworkId = $scope.networkId;
        }
        // create the ContentVersion record
        sforce.connection.create([contentVersionSObj], {
            onSuccess: function(result) {
                var status = result[0].getBoolean('success');
                var generatedContentVersionId = result[0].id;
                $scope.generatedContentVersion = {
                    'Id': generatedContentVersionId,
                    'Title': fileName,
                    'VersionData': fileContent
                };
                $scope.vlcLoading = false;
                if( ($scope.attachFileFormat && $scope.attachFileFormat.indexOf("pdf") > -1) || ($scope.showDownloadPDF) ) {
                    //if pdf generation method is vlocityclientside.
                    if ($scope.pdfGenerationSourceMethod.match(/vlocityclientside/i)) {
                        var inputMap= {
                            "pdfIntegrationConfig" : $scope.pdfIntegrationConfig,
                            "generatedContentVersion" : $scope.generatedContentVersion,
                            "docName" : $scope.sourceFileName,
                            "isDownload":false
                        }
                        generatePDFTronDocument(inputMap).then(function(result){
                        $scope.saveGeneratedPdfFile($scope.sourceFileName + '.pdf', result);
                        }, function(error) {
                            console.error('error: ', error);
                            $scope.vlcLoading = false;
                        });
                    } else {
                        checkPdfDownloadReady($scope.generatedContentVersion.Id);
                    }
                }

                // post a message to the window with the generated ContentVersion Id
                window.parent.postMessage({'docGenContentVersionId': generatedContentVersionId}, '*');
                deferred.resolve(generatedContentVersionId);
            },
            onFailure: function(result) {
                $scope.vlcLoading = false;
                deferred.reject(result.faultstring);
            }
        });

        return deferred.promise;
    };

    $scope.linkContentVersionToObject = function(contentVersionId) {
        var inputData = {
            'contentVersionId': contentVersionId,
            'contextId': $scope.contextId
        };
        remoteActions.linkContentVersionToObject(inputData).then(function(result) {
            //$scope.vlcLoading = false;
        }, function(error) {
            $scope.vlcLoading = false;
        });
    };

    $scope.downloadFile = function(downloadPdf) {
        var urlPrefix = $scope.communityName ? '/'+ $scope.communityName +'/sfc/servlet.shepherd/version/download/' 
                                            : '/sfc/servlet.shepherd/version/download/';
        if(downloadPdf) {
            location.href = urlPrefix + $scope.generatedPDFContentVersion.Id;
        } else {
            location.href = urlPrefix + $scope.generatedContentVersion.Id;
        }
    };

    //generate PDF using pdfTron.
    $scope.saveGeneratedPdfFile = function(fileName, fileContent) {

        var contentVersionSObj = new sforce.SObject('ContentVersion');
        contentVersionSObj.Title = fileName;
        contentVersionSObj.PathOnClient = fileName;
        contentVersionSObj.VersionData = fileContent;

        sforce.connection.sessionId = window.sessionId;
        sforce.connection.create([contentVersionSObj], {
            onSuccess: function(result) {
                var status = result[0].getBoolean('success');
                var generatedContentVersionId = result[0].id;
                
                $scope.generatedPDFContentVersion = {
                     'Id': generatedContentVersionId,
                     'Title': fileName,
                     'VersionData': fileContent
                }
                $scope.vlcLoading = false;
                $scope.isPdfDownloadReady = true;
                $scope.$apply();
                window.parent.postMessage({'pdfGenContentVersionId': $scope.generatedPDFContentVersion.Id}, '*');
                //link the new ContentVersion record to the Object based on the attachFileFormat setup value('PDF' or 'Word,PDF').
                if($scope.attachFileFormat && $scope.attachFileFormat.indexOf("pdf") > -1) {
                    $scope.linkContentVersionToObject($scope.generatedPDFContentVersion.Id);
                }
            },
            onFailure: function(result) {
                $scope.vlcLoading = false;
                console.log('result');
            }
        });
    };

    //generate PDF document using salesforce (default option)
    $scope.generatePdfDocument = function() {        
        var input = {
            'contextId': $scope.contextId,
            'sourceContentVersionId': $scope.generatedContentVersion.Id
        };
        remoteActions.generatePdfDocument(input).then(function(fileContent) {
            $scope.saveGeneratedPdfFile($scope.sourceFileName + '.pdf', fileContent);
        }, function(error) {
            $scope.vlcLoading = false;
            console.log(error);
        })
    }

    function checkPdfDownloadReady(contenVersionId) {
        var urlPrefix = $scope.communityName ? '/'+ $scope.communityName +'/sfc/servlet.shepherd/version/renditionDownload?rendition=SVGZ&versionId=' 
                                            : '/sfc/servlet.shepherd/version/renditionDownload?rendition=SVGZ&versionId=';
        var imgSource = urlPrefix + contenVersionId + '&operationContext=CHATTER&page=0';
        var img = document.createElement("img");
        var retries = 0;

        console.log('imgSource=', imgSource);
        console.log('loading thumbnail');
        
        img.setAttribute('src', imgSource);
           
        img.addEventListener("load", function() {
            console.log('successfully verified thumbnail');
            $scope.generatePdfDocument();
        }, false); 
        
        img.addEventListener("error", function(e) {
            ++retries;
            $timeout(function () {
                img.setAttribute('src', imgSource);
                console.log('retries=' + retries);
                console.log('reloading thumbnail');
            }, 2000 * retries);
                        
        }, false); 

    }
    function base64ToArrayBuffer(base64) {
        var binary_string = window.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes.buffer;
    }
}]);

},{}],5:[function(require,module,exports){
angular.module('objectDocumentCreation').directive('filePreviewEmbedSwf', ['$timeout', function($timeout) {
    'use strict';
    return {
        restrict: 'E',
        scope: {
            width: '=',
            height: '='
        },
        link: function(scope, elem, attrs) { 
            document.getElementById('scaleSelect').addEventListener('change', zoomSelect);

            scope.$parent.$parent.$parent.vlcLoading = true;

            var pdfContentVersionData = scope.$parent.$parent.generatedPdfContentVersion.VersionData;
            var PDFJS = window['pdfjs-dist/build/pdf'];

            // The workerSrc property shall be specified.
            PDFJS.GlobalWorkerOptions.workerSrc = '/resource/' + scope.$parent.$parent.$parent.nameSpacePrefix + 'pdfWorker';
            
            var container = document.getElementById('viewerContainer');
            var pdfLinkService = new pdfjsViewer.PDFLinkService();

            // (Optionally) enable find controller.
            var pdfFindController = new pdfjsViewer.PDFFindController({
                linkService: pdfLinkService,
            });
            //PDFViewer -- loads complete pdf file
            scope.$parent.$parent.pdfSinglePageViewer = new pdfjsViewer.PDFSinglePageViewer ({
                container: container,
                linkService: pdfLinkService,
                findController: pdfFindController,
            });
            pdfLinkService.setViewer(scope.$parent.$parent.pdfSinglePageViewer);
            document.addEventListener('pagesinit', function () {
                // We can use pdfSinglePageViewer now, e.g. let's change default scale.
                scope.$parent.$parent.pdfSinglePageViewer.currentScaleValue = 1;
            });

            getContentVersionData(base64ToArrayBuffer(pdfContentVersionData));

            function getContentVersionData(pdfContentVersionData) {
                scope.$parent.$parent.$parent.vlcLoading = false;
                PDFJS.getDocument(pdfContentVersionData).then(function(pdfDocument) { 
                    scope.numOfPages = pdfDocument.numPages;                       
                    scope.$parent.$parent.pdfSinglePageViewer.setDocument(pdfDocument);
                    pdfLinkService.setDocument(pdfDocument, null);
                    scope.$apply();
                }, function(error) {
                    scope.$apply();
                    console.log(error);
                });

            };

            function base64ToArrayBuffer(base64) {
                var binary_string = window.atob(base64);
                var len = binary_string.length;
                var bytes = new Uint8Array(len);
                for (var i = 0; i < len; i++) {
                    bytes[i] = binary_string.charCodeAt(i);
                }
                return bytes.buffer;
            }

            scope.$parent.$parent.searchFor = function() {
                var searchValue = document.getElementById("searchValue").value;
                pdfFindController.executeCommand('find', { 
                    caseSensitive: false, 
                    findPrevious: undefined,
                    highlightAll: true, 
                    phraseSearch: true,
                    query: searchValue
                });
            }
            /**
             * Displays goTo page.
             */
            scope.$parent.$parent.goToPage = function() {
                var pageNum = parseInt(document.getElementById("goToPage").value);
                if(isNaN(pageNum)) return;
                scope.$parent.$parent.pdfSinglePageViewer.currentPageNumber = pageNum;
            }

            function zoomSelect() {
                var scaleSelect = document.getElementById("scaleSelect");
                var scale = parseFloat(scaleSelect.options[scaleSelect.selectedIndex].value);
                scope.$parent.$parent.pdfSinglePageViewer.currentScaleValue = scale;
            }
        } 
    };
}]);
},{}],6:[function(require,module,exports){
angular.module('objectDocumentCreation').directive('filePreviewPdfTron', ['$timeout', function($timeout) {
    'use strict';
    return {
        restrict: 'E',
        scope: {
            width: '=',
            height: '='
        },
        link: function(scope, elem, attrs) {
            
            var webViewerCustomOptions = {
                'clientSidePdfGenerationConfig':scope.$parent.$parent.$parent.clientSidePdfGenerationConfig
            };
            var wvElement = document.getElementById('viewer');
            var  wv = new PDFTron.WebViewer({
                // get path from pdf config
                path: scope.$parent.$parent.$parent.clientSidePdfGenerationConfig['cs_pdftron_lib'],
                //List the elements that need to hide/disable.
                disabledElements: [
                    'toolsButton',
                    'textPopup'
                ],
                custom: JSON.stringify(webViewerCustomOptions),
                l: atob(scope.$parent.$parent.$parent.pdfIntegrationConfig),
                config:'/resource/' + scope.$parent.$parent.$parent.nameSpacePrefix + 'cs_pdftron_config'
            }, wvElement);
            
           
            window.addEventListener('message', function(event) {
                if (event.data && event.data.constructor === Object && event.data.hasOwnProperty('viewerLoadedExternal')) { //initialize after cs_pdftron_config was loaded
                    console.log('document loaded', wv.getInstance());
                    var instance =wv.getInstance();
                    instance.disableDownload(); // disable download feature
                    instance.disablePrint(); // disable print feature
                    instance.disableTools(); //disable the tools that are used for editing the document.
                    wv.loadDocument(base64ToBlob(scope.$parent.$parent.generatedContentVersion.VersionData),{ filename: 'myfile.docx' });
                }
            });

            var base64ToBlob = function(base64) {
                var binaryString = window.atob(base64);
                var len = binaryString.length;
                var bytes = new Uint8Array(len);
                for (var i = 0; i < len; ++i) {
                  bytes[i] = binaryString.charCodeAt(i);
                }
              
                return new Blob([bytes], { type: 'application/pdf' });
            };
        } 
    };
}]);
},{}],7:[function(require,module,exports){
angular.module('objectDocumentCreation').directive('dropdownHandler', function($document) {
    'use strict';
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var onClick = function(event) {
                var isChild = element.has(event.target).length > 0;
                var isSelf = element[0] === event.target;
                var isInside = isChild || isSelf;
                if (!isInside) {
                    scope.$apply(attrs.dropdownHandler);
                    $document.off('click', onClick);
                }
            };
            element.on('click', function() {
                $document.on('click', onClick);
            });
        }
    };
});

},{}],8:[function(require,module,exports){
angular.module('objectDocumentCreation').factory('ObjectDocumentCreationService',
['$rootScope', '$window', 'remoteActions', function($rootScope, $window, remoteActions) {
    'use strict';
    var vlocObjDocCreation = window.vlocObjDocCreation || {};
    var omniscriptPropSetMap = angular.fromJson(angular.element($('#obj-doc-creation-os-iframe', window.parent.document)).attr('vloc-prop-set'));
    var objDocLabelString = omniscriptPropSetMap.label;
    function getDocumentType() {
        if (omniscriptPropSetMap && (omniscriptPropSetMap.documentType.indexOf('pdf') > -1 && omniscriptPropSetMap.documentType.indexOf('word') > -1)) {
            return 'attachment';
        } else if (omniscriptPropSetMap && (omniscriptPropSetMap.documentType === 'pdf' || omniscriptPropSetMap.documentType === 'word')) {
            return omniscriptPropSetMap.documentType;
        } else {
            return 'pdf';
        }
    }

    function throwNotification(message, type) {
        return {
            message: message,
            type: type,
            active: true
        };
    }

    function b64toBlob(b64Data, contentType, sliceSize) {
        var byteCharacters = atob(b64Data);
        var byteArrays = [];
        var offset, slice, byteNumbers, i, byteArray, blob;
        contentType = contentType || '';
        sliceSize = sliceSize || 512;
        for (offset = 0; offset < byteCharacters.length; offset += sliceSize) {
            slice = byteCharacters.slice(offset, offset + sliceSize);
            byteNumbers = new Array(slice.length);
            for (i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }
            byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }
        blob = new Blob(byteArrays, {type: contentType});
        return blob;
    }

    function getTemplateZip(result) {
        var zip = new JSZip(result.template, {base64: true});
        return zip;
    }

    function getRelsFile(zip) {
        var file = zip.file('word/_rels/document.xml.rels');
        if (file != null) {
            return file.asText();
        }
        return '';
    }

    function generateDocx(result, type, zip) {
        var i, doc, out;
        var contractData = result.contractData;
        var imageCount = result.imageData.numImages;
        for (i = 0; i < imageCount; i++) {
            if (typeof result.imageData['imageData' + i] !== 'undefined' && result.imageData['imageData' + i] !== null) {
                zip.file('word/media/imageData' + i + '.png', result.imageData['imageData' + i], {base64: true});
            }
        }
        if (result.contractData.numberingXML !== null && result.contractData.numberingXML !== '') {
            zip.remove('word/numbering.xml');
            zip.file('word/numbering.xml', result.contractData.numberingXML, {});
        }
        if (typeof result.contractData.DocxRels !== 'undefined' && result.contractData.DocxRels !== null) {
            zip.remove('word/_rels/document.xml.rels');
            zip.file('word/_rels/document.xml.rels', result.contractData.DocxRels, {});
        }
        doc = new Docxtemplater();
        doc.loadZip(zip);
        doc.setData(contractData);
        doc.render();

        if (type === 'blob') {
            out = doc.getZip().generate({type: 'blob'});
        } else {
            out = doc.getZip().generate({type: 'base64'});
        }
        return out;
    }

    // Consolidated method (downloadAttachment) uses downloadPdf or downloadDocx in return object
    function downloadPdf() {
        remoteActions.downloadPdf(vlocObjDocCreation.parentId, vlocObjDocCreation.documentName).then(function(result) {
            var data = result;
            var blob = b64toBlob(data, 'application/pdf');
            saveAs(blob, vlocObjDocCreation.documentName + '.pdf');
        }, function(error) {
            console.log('savePdf error', error);
        });
    }

    function downloadDocx() {
        remoteActions.getDocTemplateResource(vlocObjDocCreation.templateId).then(function(result) {
            var zip = getTemplateZip(result);
            parseContentTypes(zip); // parse the document content to convert all jpeg/jpg images to png
            
            var headerString = getRelsFile(zip);
            console.log('savePdf result', result);
            if (result.errorString !== undefined) {
                alert(result.errorString);
            } else {
                remoteActions.getObjVersionDocument(vlocObjDocCreation.parentId, headerString, vlocObjDocCreation.documentName).then(function(docXresult) {
                    saveAs(generateDocx(docXresult, 'blob', zip), vlocObjDocCreation.documentName + '.docx');
                }, function(error) {
                    console.log('getObjVersionDocument error', error);
                });
            }
        }, function(error) {
            console.log('getDocTemplateResource error', error);
        });
    }

    // Service return object:
    return {
        documentType: getDocumentType(),
        attachmentId: null,
        documentGenerated: false,
        objDocLabel: objDocLabelString,
        notification: {
            message: null,
            type: 'alert-texture',
            active: false
        },
        clearNotification: function() {
            this.notification.active = false;
        },
        attachPdf: function() {
            var self = this;
            this.clearNotification();
            $rootScope.loading = true;
            remoteActions.savePdf(vlocObjDocCreation.contextId, vlocObjDocCreation.parentId, vlocObjDocCreation.documentName).then(function(result) {
                console.log('savePdf result', result);
                self.attachmentId = result;
                self.documentType = 'pdf';
                self.documentGenerated = true;
                self.notification = throwNotification('Successfully generated PDF attachment.', 'success');
                // Post the attachmentId to parent
                window.parent.postMessage({'docGenAttachmentId': self.attachmentId}, '*');
                $rootScope.loading = false;
            }, function(error) {
                console.log('savePdf error', error);
                self.notification = throwNotification('There was an error generating the PDF attachment.', 'error');
                $rootScope.loading = false;
            });
        },
        previewAttachment: function(event) {
            var self = this;
            if (!self.attachmentId || event.target.parentElement.className.indexOf('objdoc-generate-doc') > -1) {
                return;
            } else {
                $window.open(window.location.origin + '/servlet/servlet.FileDownload?file=' + self.attachmentId, '_blank');
            }
        },
        attachDocx: function() {
            var self = this;
            this.clearNotification();
            $rootScope.loading = true;
            remoteActions.getDocTemplateResource(vlocObjDocCreation.templateId).then(function(result) {
                var zip = getTemplateZip(result);
                var headerString = getRelsFile(zip);
                if (result.errorString !== undefined) {
                    alert(result.errorString);
                } else {
                    remoteActions.getObjVersionDocument(vlocObjDocCreation.parentId, headerString, vlocObjDocCreation.documentName).then(function(objResult) {
                        console.log('getObjVersionDocument', objResult);
                        remoteActions.saveDocx(vlocObjDocCreation.contextId, vlocObjDocCreation.documentName, generateDocx(objResult, 'base64', zip)).then(function(result) {
                            console.log('saveDocx result', result);
                            self.attachmentId = result;
                            self.documentGenerated = true;
                            self.documentType = 'word';
                            self.notification = throwNotification('Successfully generated WORD attachment.', 'success');
                            window.parent.postMessage({'docGenAttachmentId': self.attachmentId}, '*');
                            $rootScope.loading = false;
                        }, function(error) {
                            console.log('saveDocx error', error);
                            self.notification = throwNotification('There was an error generating the WORD attachment.', 'error');
                            $rootScope.loading = false;
                        });
                    }, function(error) {
                        console.log('getObjVersionDocument error', error);
                        self.notification = throwNotification('There was an error generating the WORD attachment.', 'error');
                        $rootScope.loading = false;
                    });
                }
            }, function(error) {
                console.log('getDocTemplateResource error', error);
                $rootScope.loading = false;
            });
        },
        downloadAttachment: function(documentType) {
            if (documentType === 'pdf') {
                downloadPdf();
            } else if (documentType === 'word') {
                downloadDocx();
            }
        },
        deleteAttachment: function() {
            var self = this;
            this.clearNotification();
            $rootScope.loading = true;
            remoteActions.deleteAttachment(self.attachmentId).then(function(result) {
                console.log('deleteAttachment result', result);
                self.documentGenerated = false;
                self.attachmentId = null;
                self.documentType = getDocumentType();
                self.notification = throwNotification('Successfully deleted the attachment.', 'success');
                $rootScope.loading = false;
            }, function(error) {
                console.log('deleteAttachment error', error);
                self.notification = throwNotification('There was an error deleting the attachment.', 'error');
                $rootScope.loading = false;
            });
        }
    };
}]);

},{}],9:[function(require,module,exports){
angular.module("objectDocumentCreation").run(["$templateCache",function($templateCache){"use strict";$templateCache.put("component/docxTemplateComponent.tpl.html",'<div class="file-preview">\n    <div class="document-previewer-wrapper" ng-if ="$parent.pdfViewer === \'none\'" style="padding: 70px 65px; box-shadow: 0 0 4px 1px #d8dde6; border: 1px solid #d8dde6;height: 400px; text-align: center"> \n            <div class="slds-grid slds-wrap slds-size_1-of-1 download-buttons buttons-group slds-m-around_medium">\n                <div  ng-if="$parent.$parent.showDownloadWord" ng-class="{\'slds-size_1-of-2 border-right\':docType === \'all\', \'slds-size_1-of-1\': docType === \'word\'}">\n                    <div class="dz-preview dz-file-preview icon-v-file-word"> </div>\n                    <button type="button" class="slds-button slds-button--neutral" title="{{labels.CLMDocGenDownloadWord}}" ng-click="$parent.$parent.$parent.downloadFile(false)">{{labels.CLMDocGenDownloadWord}}</button>\n                </div>\n                <div  ng-if="$parent.$parent.showDownloadPPT" ng-class="{\'slds-size_1-of-2 border-right\':docType === \'all\', \'slds-size_1-of-1\': docType === \'ppt\'}">\n                    <div class="dz-preview dz-file-preview icon-v-file-powerpoint"> </div>\n                    <button type="button" class="slds-button slds-button--neutral slds-m-bottom_x-small" title="{{labels.CLMDocGenDownloadPowerPoint}}" \n                            ng-click="$parent.$parent.$parent.downloadFile(false)" >{{labels.CLMDocGenDownloadPowerPoint}}</button>\n                </div>\n                <div ng-if="$parent.$parent.showDownloadPDF" ng-class="{\'slds-size_1-of-2\':docType === \'all\', \'slds-size_1-of-1\':docType === \'pdf\'}">\n                    <div class="dz-preview dz-file-preview icon-v-file-psd"  ng-style="{ \'color\' : (ispdfDownloadReady) ? \'#fc897a\' : \'#EBEBE4\' }"> </div>\n                    <button type="button" class="slds-button slds-button--neutral slds-m-bottom_x-small" title="{{labels.CLMDocGenDownloadPDF}}" \n                        ng-click="$parent.$parent.$parent.downloadFile(true)"  ng-disabled="!ispdfDownloadReady">{{ ispdfDownloadReady ? labels.CLMDocGenDownloadPDF : labels.CLMDocGeneratingPDF}}</button>\n                </div>\n            </div>\n    </div>\n        \n    <div class="document-container">\n        <div class="slds-m-around_large slds-p-top_large" ng-if ="$parent.pdfViewer !== \'none\' && !generatedContentVersion.Id" style="text-align: center;">\n            <h2 class="slds-text-heading_small slds-m-around_medium"> {{labels.PdfGenerationWaitingMessage}} </h2>\n        </div>\n\n        \x3c!-- Pdfjs previewer --\x3e\n        <div class="file-details"  ng-if ="$parent.pdfViewer === \'pdfjs\' && generatedContentVersion.Id" style="text-align: center;">\n            <div>\n                <slds-button-svg-icon sprite="\'utility\'" icon="\'chevronleft\'" id="prev" ng-click="pdfSinglePageViewer.currentPageNumber = pdfSinglePageViewer.currentPageNumber - 1" style="cursor: pointer;"></slds-button-svg-icon>\n                <input type="text" ng-model="pageNum" ng-change="goToPage()" class="slds-input slds-size_1-of-6" id="goToPage" ng-value="pdfSinglePageViewer.currentPageNumber"/>\n                <slds-button-svg-icon sprite="\'utility\'" icon="\'chevronright\'" id="next" ng-click="pdfSinglePageViewer.currentPageNumber = pdfSinglePageViewer.currentPageNumber + 1" style="cursor: pointer;"></slds-button-svg-icon>\n                &nbsp;\n                <span>Search: </span><input type="search" class="slds-input slds-size_1-of-6" ng-model="searchValue" ng-change="searchFor()" id="searchValue"/>&nbsp;\n                <span> Zoom: </span>\n                <span style="min-width: 120px; max-width: 120px;" id="scaleSelectContainer">\n                    <select style="min-width: 142px;" data-style= "btn-primary" id="scaleSelect" title="Zoom" tabindex="23">\n                        <option title="" value=\'0.5\'>50%</option>\n                        <option title="" value=\'0.75\'>75%</option>\n                        <option title="" value=\'1\' selected="selected">100%</option>\n                        <option title="" value=\'1.25\'>125%</option>\n                        <option title="" value=\'1.5\'>150%</option>\n                        <option title="" value=\'2\'>200%</option>\n                        <option title="" value=\'3\'>300%</option>\n                        <option title="" value=\'4\'>400%</option>\n                    </select>\n                </span>&nbsp;\n                <span>Page: <span id="page_num"></span> {{pdfSinglePageViewer.currentPageNumber}}/{{pdfSinglePageViewer.pdfDocument._pdfInfo.numPages}} <span id="page_count"></span></span>\n            </div>\n            <div id="viewerContainer">\n                    <div id="viewer" class="pdfViewer"></div>\n            </div>\n            <file-preview-embed-swf  width="\'100%\'" height="\'100%\'"></file-preview-embed-swf>\n        </div>\n\n        \x3c!-- PdfTron previewer --\x3e \n        <div class="file-details" ng-if="$parent.pdfViewer === \'vlocityclientsideviewer\' && generatedContentVersion.Id" style="text-align: center;">\n            <div id="viewer" class="pdfViewer" style=\'width: 800px; height: 600px;\'></div>\n            <file-preview-pdf-tron  width="\'100%\'" height="\'100%\'"></file-preview-pdf-tron>\n        </div>\n\n    </div>\n</div>\n')}]);

},{}]},{},[1]);
})();
