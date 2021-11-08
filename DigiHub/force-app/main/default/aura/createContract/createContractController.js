({
    doInit : function(component, event, helper) {
        let action = component.get("c.getContractCreation");
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            let state = response.getState(); 
            if(state === "SUCCESS" && response.getReturnValue() != null){
                let ctrcId = response.getReturnValue();
                helper.navigate(component,ctrcId);
                helper.dismissQuickAction();
                helper.showToast('Success Creation!','success','The record has been updated successfully.');
            }
            else if(state === "ERROR"){
                helper.dismissQuickAction();
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast('Error on creation!','error',errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
                else {
                    helper.dismissQuickAction();
                    helper.showToast('Error on creation!','error','Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
                }
        });
        
        $A.enqueueAction(action);
        
    }
})