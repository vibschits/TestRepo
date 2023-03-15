({
    offerFinal: function (component, event, helper) {
        console.log('Called helper');

        var offerId = component.get("v.recordId");
        var action = component.get("c.finalOffer"); 

        action.setParams({ 
            offerId : offerId           
        });
        action.setCallback(this,function(response) {
        console.log(response);

            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast("Success", "Success", "Successfully finalized the offer.");
                $A.get("e.force:closeQuickAction").fire();
                 $A.get('e.force:refreshView').fire();
            }else if (state ==="ERROR") {
                var errors = response.getError();
                helper.showToast("Error", "Error", "Something went wrong. Contact your adim.");
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    
     
})