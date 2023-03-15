({
    createAccount : function(component, event, helper) {
        var action = component.get("c.saveAccount");
        action.setParams({
            "accRec":component.get("v.acc")
        });
        action.setCallback(this, function(response){            
            if(response.getState()==='SUCCESS'){
                var accId = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(accId){
                    // file upload start
                
                if (component.find("fileId").get("v.files") != null) {
                    helper.uploadHelper(component, event,accId);
                }   
                 // File upload END   
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"Success",
                    "message": "Account created successfully."
                });
                toastEvent.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": accId,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
                else {
                    toastEvent.setParams({
                    "title": "Error!",
                    "type":"Error",
                    "message": "Required field missing."
                });
                toastEvent.fire();    
                }
            }    
        
        });
        $A.enqueueAction(action);
        
    },
   
	doInit : function(component, event, helper) {
	var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
	},
    cancel : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
})