function LocateClick ($scope, path, library, valueMap) {
var childblocks=baseCtrl.prototype.$scope.bpTree.response.EditDivisions.ebChild;
var childblockRdos=baseCtrl.prototype.$scope.bpTree.response.EditDivisions.ebChild.length;


breakme: if(childblockRdos){
//alert("childblockRdos:"+childblockRdos);
	for(i = 0; i < childblockRdos; i++) {
      	if (childblocks[i].RdoShowSubdivisions=="Move" || childblocks[i].RdoShowSubdivisions=="Reparent" ) {
        	childblocknum=i;
var childcaller=childblocks[i].ChildId;
var callerIndex=i;
var childcallerName=childblocks[i].ChildName;
//alert("First branch:"+childcaller);
            break breakme;
       		}
		}
	}
	else {
	var childcaller=childblocks.ChildId;
        var callerIndex=1;
        var childcallerName=childblocks.ChildName;
//alert("in here2nd:"+childcaller);
	}
baseCtrl.prototype.$scope.bpTree.response.callerId=childcaller;
baseCtrl.prototype.$scope.bpTree.response.callerIndex=callerIndex;
baseCtrl.prototype.$scope.bpTree.response.callerName=childcallerName;


//alert(childcaller);
	}