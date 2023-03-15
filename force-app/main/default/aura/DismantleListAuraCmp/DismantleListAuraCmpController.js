({
	onPageReferenceChange: function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
        var insLineItem = myPageRef.state.c__listofInstaLineItems;
        
        var listofInsLineItem = JSON.stringify(insLineItem);
        console.log('listofInsLineItem',listofInsLineItem);
        listofInsLineItem = listofInsLineItem.slice(1);
        listofInsLineItem = listofInsLineItem.slice(0, -1);
        console.log('listofInsLineItem',listofInsLineItem);
        
        var separatedArray = listofInsLineItem.split(',');
        component.set("v.instLineItemIdList", separatedArray);
        console.log('separatedArray',separatedArray);
        var instLineItemId = separatedArray[0];
        console.log('instLineItemId',instLineItemId);
        
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'Name'},
            {label: 'Status', fieldName: 'Status__c'},
            {label: 'Dismantle Date', fieldName: 'Dismantle_Date__c'},
            {label: 'Dismantle Supervisor Id', fieldName: 'Dismantle_Superior_Id__c'},
            {label: 'Dismantle Supervisor Name', fieldName: 'Dismantle_Superior_Name__c'}
        ]);
        var action = component.get("c.fetchDismRecs");
        action.setParams({
            instLineItemId : instLineItemId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                console.log('response',response.getReturnValue());
                component.set("v.DismList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    onRowSelected: function (component, event) {
  		var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows',selectedRows);
        var dismantleId = JSON.stringify(selectedRows[0].Id);
        const dismantleId2 = dismantleId.slice(1, -1);
        console.log('dismantleId2 => ',dismantleId2);
        var insLineItemIds = component.get("v.instLineItemIdList");
        console.log('insLineItemIds',insLineItemIds);
        var action = component.get("c.dismantleInstLineItems");
        action.setParams({
            dismantleId : dismantleId2,
            insLineItemIds : insLineItemIds
        });
        action.setCallback(this, function(response){
            console.log('response',response.getReturnValue());
            if(response.getReturnValue() != 'FAIL'){
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": dismantleId2,
                    "slideDevName": "Detail"
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);
    }
})