({
   
    handleDialogNo : function(component, event, helper) {
        console.log('@Inside Controller: handleDialogNo');
        $A.get("e.force:closeQuickAction").fire();
    },
    updateToSap : function(component, event, helper) {
        console.log('@Inside Controller: updateToSap');
        helper.sendToSap(component, event, helper);
    },
    
})