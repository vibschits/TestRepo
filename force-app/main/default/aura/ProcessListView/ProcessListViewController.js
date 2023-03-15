({
    onPageReferenceChange: function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var invs = myPageRef.state.c__listofInventories;
        
        var listofInventories = JSON.stringify(invs);
        console.log('listofInventories',listofInventories);
        listofInventories = listofInventories.slice(1);
        listofInventories = listofInventories.slice(0, -1);
        console.log('listofInventories',listofInventories);
        
        var separatedArray = listofInventories.split(',');
        component.set("v.inventoryIdList", separatedArray);
        console.log('separatedArray',separatedArray);
        var inventoryId = separatedArray[0];
        console.log('inventoryId',inventoryId);
        
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'Name'},
            {label: 'Customer', fieldName: 'Customer__c'},
            {label: 'All Customer Inventory Applicable', fieldName: 'All_Customer_Inventory_applicable__c'},
            {label: 'Last Modifed Date', fieldName: 'LastModifiedDate'}
        ]);
        var action = component.get("c.fetchISS");
        action.setParams({
            inventoryId : inventoryId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                console.log('response',response.getReturnValue());
                component.set("v.issList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    onRowSelected: function (component, event) {
  		var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows',selectedRows);
        var InventorySimulationId = JSON.stringify(selectedRows[0].Id);
        console.log('InventorySimulationId => ',InventorySimulationId);
        var invIds = component.get("v.inventoryIdList");
        console.log('invIds',invIds);
        var action = component.get("c.createVirtualInvLines");
        action.setParams({
            issId : InventorySimulationId,
            invIds : invIds
        });
        action.setCallback(this, function(response){
            console.log('response',response.getReturnValue());
            if(response.getReturnValue() != 'FAIL'){
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "Detail"
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);
    }
})