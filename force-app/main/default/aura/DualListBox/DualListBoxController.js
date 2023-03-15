({
    doInit: function(component, event, helper) {
        
    },
     onGroupItemChange: function(component, event, helper) {
        // get the refreshed user list based on given group name
         helper.fetchUserListVal(component, event);
    },
    onUserItemChange: function(component, event, helper) {
        // get the refreshed group list based on given user id       
         helper.fetchGroupListVal(component, event);
    },
    handleUserChange: function (component, event, helper) {  
        var selectedValues = event.getParam("value");

    },
     
    processGroupMembership : function(component, event, helper){
        // helper method to execute for updating membership
        helper.updateGroupMembership(component, event);
        
    },
    processUserMembership : function(component, event, helper){
       // helper method to execute for updating membership
        helper.updateUserMembership(component, event);
        
    }
})