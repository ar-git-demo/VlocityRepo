global class VPLUpdateGroupClasses implements vlocity_ins.VlocityOpenInterface{
   // global VPLUpdateGroupClasses(){}
    global static Set<Id> idSet;
    global static Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        if(methodName=='updateGroupClasses'){
            updateGroupClasses(input, output,options);
        }
        else  if(methodName=='deleteGroupClasses'){
            deleteGroupClasses(input, output,options);
        }
        return False;    
    }
    global static void updateGroupClasses(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        
                    Map<String,Object> mainObj = input;
                    List<vlocity_ins__GroupClass__c> gcList=new List<vlocity_ins__GroupClass__c>();   
                    vlocity_ins__GroupClass__c gc=new vlocity_ins__GroupClass__c();
                    
                    gc.Id= (Id)mainObj.get('CurrentId');
                    gc.Name=(String)mainObj.get('ClsName');
                    gc.vlocity_ins__ClassCode__c=(String)mainObj.get('ClsClassCode');
                    
                    if(mainObj.get('ClsActive')!=NULL){
                        gc.vlocity_ins__IsActive__c=(Boolean)mainObj.get('ClsActive');
                    }
                    
                    gc.vlocity_ins__EmployerContributionPercent__c=(Decimal)mainObj.get('ClsEmployerContribution');
                    gc.vlocity_ins__EmployerContributionAmount__c=(Decimal)mainObj.get('ClsContributionAmount');
                    gc.vlocity_ins__Description__c=(String)mainObj.get('ClsDescription');
                    gc.vlocity_ins__DependentEmployerContributionAmount__c=(Decimal)mainObj.get('ClsDependentEmployerContributionAmount');
                    gc.vlocity_ins__DependentEmployerContributionPercent__c=(Decimal)mainObj.get('ClsDependentEmployerContribution');
                    gc.vlocity_ins__Type__c=(String)mainObj.get('ClsClassType');
                    
                    gcList.add(gc);
                
                    upsert gcList;
                    
       
    }
    global static void deleteGroupClasses(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        Map<String,Object> mainObj = input;
        
        List<vlocity_ins__GroupClass__c> gcList=[SELECT ID FROM vlocity_ins__GroupClass__c WHERE ID=:(Id)mainObj.get('CurrentId')];
        if(gcList!=NULL && gcList.size()>0){
            delete gcList;
        }
      
       
    }
    
}