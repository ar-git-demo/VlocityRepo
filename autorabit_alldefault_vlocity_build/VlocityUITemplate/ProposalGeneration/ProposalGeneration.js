baseCtrl.prototype.setIPScope = function(scp)
{
    window.VlocOmniSI = scp;
    var afterSlash = '/' + window.location.href.split('.com/')[1].split('/')[0];
    if (afterSlash === 'apex') {
        afterSlash = '';
    }
    //scp.urlPrefix = window.location.origin + afterSlash;
   scp.applyCallResp({'urlPrefix':window.location.origin + afterSlash});
    //console.log('urlPrefix ', scp.urlPrefix);
}

    window.addEventListener('message', function(event){
         console.log('message received from iframe');
         //if (event.origin === '/apex/ObjectDocumentCreation2'){
//debugger;
              //document.getElementById('response').innerHTML = event.data;
             if(event.data && event.data.constructor===Object && event.data.hasOwnProperty("docGenAttachmentId") ){
              window.VlocOmniSI.applyCallResp(event.data);
             console.log(event.data+' Message');
        }
    }, false);