({
    fetchPickListVal: function(component, elementId) {
        var action = component.get("c.getselectOptions");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
            }
        }); 
        $A.enqueueAction(action);
    },
    
    fetchUserListVal: function(component, event) {
        var action = component.get("c.getUserslistValues");
        var selectedgroupName = event.getSource().get("v.value");
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
                alert(result1.avilableUsers);
                  alert(result1.selectedUsers);
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
               // component.set("v.selectedUserList", selectedUserLst);
               var values = ["7", "2", "3"];
                component.set("v.selectedUserList", values);
                
            }
        });
        $A.enqueueAction(action);
        
    },
})