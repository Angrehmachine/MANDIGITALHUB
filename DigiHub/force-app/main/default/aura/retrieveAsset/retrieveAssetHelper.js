({
    showToast : function(title, type, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
    dismissQuickAction : function() {
        let dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    retrieveAsset : function(component,helper,assetRec) {
        
        let action = component.get("c.getAssetFromApi");
        action.setParams({
            assetId : component.get("v.recordId"),
            vin : assetRec.vin__c,
            oemVin : assetRec.oemVin__c
        });
        action.setCallback(this, function(response){
            let state = response.getState(); 
            if ( state === "SUCCESS" && response.getReturnValue() === 'success' ) {
                helper.dismissQuickAction();
                helper.showToast('Success Retrieve!','success','The record has been updated successfully.');
                $A.get('e.force:refreshView').fire();
            } else if(state === "ERROR"){
                helper.dismissQuickAction();
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast('Error Retrieve!','error',errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                helper.dismissQuickAction();
                helper.showToast('Error Retrieve!','error','Asset not existing in API!');
            }
        });
        
        $A.enqueueAction(action);
    }
})