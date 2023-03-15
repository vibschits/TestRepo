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
            {label: 'Application Type', fieldName: 'Application_Type__c'},
            {label: 'Belt Condition', fieldName: 'Belt_Condition__c'},
            {label: 'Capacity', fieldName: 'Capacity_TPH__c'},
            {label: 'Last Modifed Date', fieldName: 'LastModifiedDate'}
        ]);
        var action = component.get("c.fetchInvs");
        action.setParams({
            inventoryId : inventoryId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                console.log('response',response.getReturnValue());
                component.set("v.insList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    yesOption: function(component, event, helper) {
        
        var inLineItemList = component.get("v.instLineItemList");
        var custInvList = component.get("v.custInvUpdatedList");
        var installatonIdStr = component.get("v.installationRecId");
        console.log('inLineItemList '+JSON.stringify(inLineItemList));
        console.log('custInvList '+JSON.stringify(custInvList));
        console.log('installatonId '+installatonIdStr);
        
        var action2 = component.get("c.createInstallationLinesPartial");
        console.log('checking..... if...');
        action2.setParams({
            installationId : installatonIdStr,
            inLineItemStr : JSON.stringify(inLineItemList),
            custInvSTR : JSON.stringify(custInvList)
        });
        action2.setCallback(this, function(response){
            var state = response.getState();
            console.log(response);
            if (state === "SUCCESS") {
                console.log('response');
                var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.getReturnValue(),
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
            }
        });
        $A.enqueueAction(action2);
    },
    noOption: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/Customer_Inventory_Stock__c/list"
        });
        urlEvent.fire();
        
    },
    onRowSelected: function (component, event) {
  		var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows',selectedRows);
        var installationId = JSON.stringify(selectedRows[0].Id);
        console.log('installationId => ',installationId);
        var invIds = component.get("v.inventoryIdList");
        console.log('invIds',invIds);
        var action = component.get("c.createInstallationLines");
        action.setParams({
            installationId : installationId,
            invIds : invIds
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result => ',JSON.stringify(result));
            if(result.status != 'EXCEPTION'){
                var res = response.getReturnValue();
                console.log('res',res);
                if(result.status == 'FAIL'){
                    console.log('inside error msg');                      
                    component.set("v.showModal", true);
                    component.set("v.errorMessage",result.responseMsg);
                    component.set("v.installationRecId",result.installationRecId);
                    component.set("v.custInvUpdatedList",result.custInvUpdatedList);
                    component.set("v.instLineItemList",result.instLineItemList);
                    
                }else if(result.status == 'SUCCESS'){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.getReturnValue(),
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})