({
    doInit : function(component, event, helper) {
        let assetRec = component.get("v.AssetRecord"); 
        if ( assetRec.Vin__c === null && assetRec.oemVin__c === null ) {
            helper.dismissQuickAction();
            helper.showToast('Error on Retrieve!','error','OemVin / Vin not filled');       
        } else {
            helper.retrieveAsset(component,helper,assetRec);
        }
    }    
    
})