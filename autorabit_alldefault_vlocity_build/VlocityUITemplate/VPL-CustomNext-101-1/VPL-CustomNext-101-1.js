baseCtrl.prototype.next = function(scp){
    var child = scp.$parent.$parent.$parent.child;
    scp.baseCtrl.$scope.nextRepeater(child.nextIndex, child.indexInParent);       
};