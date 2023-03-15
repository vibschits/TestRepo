({
    fetchUserListVal: function(component, event) {
      var action = component.get("c.getUserslistValues");
      var selectedgroupName = component.get("v.Group_name");
        action.setParams({
            "groupName": selectedgroupName
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response);
           
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log(result);
                var avilableUserList = [];
                var selectedUserLst = [];
              var result1 = JSON.parse(result);
                for (var i = 0; i < result1.avilableUsers.length; i++) {
                    avilableUserList.push({
                        label: result1.avilableUsers[i],
                        value: result1.avilableUsers[i]
                    });
                }
                for (var j = 0; j < result1.selectedUsers.length; j++) {
                    selectedUserLst.push(  result1.selectedUsers[j]);                 
                }
                component.set("v.UserList", avilableUserList);
                component.set("v.selectedUserList", selectedUserLst);
                
            }
        });
        $A.enqueueAction(action);
        
    },
    fetchGroupListVal: function(component, event) {
        var action = component.get("c.getGrouplistValues");
       var selecteduserId = component.get("v.User_Id");
        action.setParams({
            "userId": selecteduserId
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response);
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var avilableGroupList = [];
                var selectedGroupLst = [];
              var result1 = JSON.parse(result);
                for (var i = 0; i < result1.avilableGroups.length; i++) {
                    avilableGroupList.push({
                        label: result1.avilableGroups[i],
                        value: result1.avilableGroups[i]
                    });
                }
                for (var j = 0; j < result1.selectedGroups.length; j++) {
                    selectedGroupLst.push(  result1.selectedGroups[j]);                   
                }             
                component.set("v.GroupList", avilableGroupList);
                component.set("v.selectedGroupList", selectedGroupLst);
                
            }
        });
        $A.enqueueAction(action);
        
    },
    
    updateGroupMembership: function(component, event) {
        component.set("v.showLoadingSpinner", true);
         var selectedValues = component.get("v.selectedUserList");
         var selectedgroupName = component.get("v.Group_name");
        var action = component.get("c.updateMembershipConByGroupName");
        
         action.setParams({
            "selectedRecords": selectedValues,
             "groupName" : selectedgroupName
            
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
        component.set("v.showLoadingSpinner", false);   
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS" && response.getReturnValue() instanceof Array){
             
              toastEvent.setParams({
                    "title": "Success!",
                    "type":"Success",
                    "message": selectedgroupName+" membership has been updated!."
                });
                toastEvent.fire();
            }
            else {
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"Error",
                    "message": "Some Error has occured. Please check the error logs"
                });
                toastEvent.fire();
                
            }
         
        });   
         $A.enqueueAction(action);
    },
     updateUserMembership: function(component, event) {
        component.set("v.showLoadingSpinner", true);
         var selectedValues = component.get("v.selectedGroupList");
         var selectedUserId = component.get("v.User_Id");
         var selectedUserName = component.get("v.User_name");
        var action = component.get("c.updateMembershipConByUserName");      
         action.setParams({
            "selectedRecords": selectedValues,
             "UserId" : selectedUserId
            
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
        component.set("v.showLoadingSpinner", false);  
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS" && response.getReturnValue() instanceof Array){
             
              toastEvent.setParams({
                    "title": "Success!",
                    "type":"Success",
                    "message": selectedUserName +" Group membership has been updated!."
                });
                toastEvent.fire();
            }
            else {
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"Error",
                    "message": "Some Error has occured. Please check the error logs"
                });
                toastEvent.fire();
                
            }
         
        });   
         $A.enqueueAction(action);
    },
})