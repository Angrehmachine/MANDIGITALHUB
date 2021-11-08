({
    navigate : function(component, ctrcId) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": ctrcId
        });
        navEvt.fire();
    },
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
	}
 })