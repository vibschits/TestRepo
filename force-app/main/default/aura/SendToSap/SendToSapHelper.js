({
    sendToSap: function (component, event, helper) {
        console.log('@Called helper: sendToSap');

        var offerId = component.get("v.recordId");
        var action = component.get("c.OfferSendToSap"); 

        action.setParams({ 
            offerId : offerId           
        });
        action.setCallback(this,function(response) {
        console.log(response);

            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast("Success", "Success", "Offer Sent to SAP.");
                $A.get("e.force:closeQuickAction").fire();
            }else if (state ==="ERROR") {
                var errors = response.getError();
                helper.showToast("Error", "Unable to send contact your Admin.","Error");
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