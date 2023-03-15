({
   
    handleConfirmDialogNo : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    offerUpdate : function(component, event, helper) {
        console.log('Called controller');
        helper.offerFinal(component, event, helper);
    },
    
    // SK - 211122 : Adding Custom Label 
    doInit:function (component, event, helper){
        var action = component.get("c.customLabelItem");

            action.setCallback(this,function(response){
                    var state = response.getState();
                    if (state == 'SUCCESS'){
                            var result = response.getReturnValue();
                            component.set("v.customLablVal", result);
                    }
            });
            $A.enqueueAction(action);
    },
    
})