baseCtrl.prototype.changeStep = function(scp, value, previousNthStepName){
   
    if(value == "Previous"){
        var step = scp.$parent.$parent.$parent.$parent.$parent.child;
        if(scp && step){
            scp.setStepStatus(scp.bpTree.children[step.indexInParent], false, true, true);
            
            var previousStep = [];
              for(i in scp.bpTree.children){
                   if(scp.bpTree.children[i]['name'] == previousNthStepName){
                        previousStep.push(scp.bpTree.children[i]);
                   }
               }
            
            var prevIndex = previousStep[0].indexInParent;
            if(prevIndex !== undefined && prevIndex !== null){
                    
                scp.activateStep(previousStep[0], true);
                scp.bpTree.asIndex = prevIndex;
                // $scope.activeIndex = prevIndex;
                scp.activeIndex = prevIndex;

            }
        } 
    }
}