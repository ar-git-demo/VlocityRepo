vlocity.cardframework.registerModule.controller('npDetailController', ['$scope', function($scope) {
            $scope.showAlertBox = true;
             $scope.toggleAlertBox = function(){
                $scope.showAlertBox = false;
            }
            
            $scope.resizeFrame = function () {
                 $.each( $(parent.document.getElementsByTagName('IFRAME')), function( key, value ) {
                  if($(value.contentDocument).find('.np-detail--card').length > 0)
                  {
                     window.setTimeout(function(){ $(value).css("cssText","height:"+ value.contentDocument.body.offsetHeight + "px !important"); },100)
                     return;
                  }
                      
                });
            
            }
            
            
            
      }]);