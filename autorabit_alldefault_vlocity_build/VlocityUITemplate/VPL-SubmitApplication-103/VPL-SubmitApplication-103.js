baseCtrl.prototype.submitApp = function(scp){
    debugger;
    if(!scp.bpTree.response.responseJSON){
            debugger;
            var data = JSON.stringify(scp.bpTree.response);
            scp.bpTree.response['responseJSON'] = data;
    }
    var child = scp.$parent.$parent.$parent.child;
    scp.baseCtrl.$scope.nextRepeater(child.nextIndex, child.indexInParent);       
};