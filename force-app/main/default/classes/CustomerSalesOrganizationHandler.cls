/*
Name : CustomerSalesOrganizationHandler
Desc : This class is use for update customer.
*/

public with sharing class CustomerSalesOrganizationHandler extends TriggerHandler {
    private static final string OBJECT_API = 'Customer_Sales_Organization__c';

    public CustomerSalesOrganizationHandler() {
        super(OBJECT_API);
    }

    public override String getName() {
        return OBJECT_API;
    }

    public override void beforeInsert(List<SObject> newItems) {
    }
    public override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        //checkBranchValidation(newItems);
        setCheckboxToFalseUpdate(newItems,newItemsMap,oldItemsMap);
    }
    public override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUpdate(List<SObject> newItems, Map<Id, SObject>
    newItemsMap, Map < Id, SObject > oldItemsMap) {
       
    updateCustomer(newItems, newItemsMap, oldItemsMap, true); 
       
        
    }
    public override void afterDelete(Map<Id, SObject> oldItemsMap) {
        deleteCustomerSalesOrg(oldItemsMap);
    }
    public override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap) {
        Map<Id, SObject> tempMap = new Map<Id, SObject>(); 
        updateCustomer(newItems, newItemsMap, tempMap, false);           
             
        setCheckboxToFalseNew(newItems);
    }

   
    /*
    Name : updateCustomer
    Desc : this method use to update sales region and branch code in customer.
    */
    public void updateCustomer(List<SObject> newSalesOrgList ,Map<Id, SObject> newSalesOrgMap, Map<Id, SObject> oldMap, Boolean isUpdate){
        try {
        	
            Set<Id> customerIdSet = new Set<Id>();
            Set<Id> validCustomerIdSet = new Set<Id>();
            Map<Id,Account> customerUpdateMap = new Map<Id, Account>();  


            // Check valid CSO
            for(SObject obj : newSalesOrgMap.values()){
                Customer_Sales_Organization__c cso = (Customer_Sales_Organization__c)obj;
                if(isUpdate){
                    Customer_Sales_Organization__c oldCso = (Customer_Sales_Organization__c)oldMap.get(cso.Id);
                    //if(cso.status__c != oldCso.Status__c){
                    if(cso.status__c != null){
                        customerIdSet.add(cso.Customer__c);
                    }
                }
            }
			system.debug('customerIdSet-->>'+customerIdSet);
            // Query to fetch Valid CSO..
            List<Customer_Sales_Organization__c> csoValidList = [SELECT Id, Customer__c FROM Customer_Sales_Organization__c 
                                                                WHERE Customer__c IN : customerIdSet 
                                                               AND status__c = 'Valid'];

            for(Customer_Sales_Organization__c cso : csoValidList ){
                validCustomerIdSet.add(cso.Customer__c);
            }
            
            //Query to fetch all CSO attached with customer...
            Map<Id, Customer_Sales_Organization__c> cSalesOrgMap = new Map<Id, Customer_Sales_Organization__c> ([SELECT Id,Customer__c, Customer__r.Sales_region__c, Customer__r.Branch_Code__c,
                                                                Branch__c,Branch__r.Sales_Region__c, Branch__r.Branch_Code__c,
                                                                Branch__r.Sales_Region__r.Manager__c, Company__c,
                                                                Customer__r.Status__c,Customer_Code__c
                                                                FROM Customer_Sales_Organization__c
                                                                WHERE Id IN : newSalesOrgMap.keySet()]);


            for(Id key : newSalesOrgMap.keySet()){
                Customer_Sales_Organization__c cs = cSalesOrgMap.get(key);
                Customer_Sales_Organization__c oldCs = (Customer_Sales_Organization__c)oldMap.get(key);
                system.debug('oldCs'+oldCs);
                Account customer = new Account(Id = cs.Customer__c); 
				system.debug('cs-->>'+cs);
                system.debug('Sales_region__c-->>'+cs.Customer__r.Sales_region__c);
                system.debug('Branch__r-->>'+cs.Branch__r.Sales_region__c);
                if(cs.Customer__r.Sales_region__c != null){
                    if(cs.Customer__r.Sales_region__c != cs.Branch__r.Sales_Region__c){
                        newSalesOrgList[0].addError(System.label.Sales_and_Customer_region_should_Same);
                    }                
                }else{
                // if(cs.Customer__r.Status__c == 'Sync with SAP'){      As per recent discussion commented this code  Dated : 28-July-2022          
                        customer.Sales_region__c = cs.Branch__r.Sales_region__c;
                        customer.Regional_Manager__c = cs.Branch__r.Sales_region__r.Manager__c;
                // }
                    
                }
                if(cs.Customer__r.Branch_Code__c != null){
                    List<String> branchList = cs.Customer__r.Branch_Code__c.split(',');                
                        if(branchList.contains(cs.Branch__r.Branch_Code__c)){ 
                            
                            if(oldCs != null){
                                System.debug('cs.Branch__c--'+cs.Branch__c);
                                system.debug('oldCs.Branch__c------'+oldCs.Branch__c+' cs.Customer_Code__c '+ cs.Customer_Code__c );
                                if(cs.Branch__c == oldCs.Branch__c && cs.Customer_Code__c == oldCs.Customer_Code__c){ // Checking New branch and old branch
                                  //  newSalesOrgList[0].addError(System.label.Branch_already_added);
                                    system.debug('error from 111');
                                }
                            }
                            else{
                                system.debug('oldCs.Branch__c------'+oldCs.Branch__c+' cs.Customer_Code__c '+ cs.Customer_Code__c );

                             		newSalesOrgList[0].addError(System.label.Branch_already_added);
                                                                    system.debug('error from 115');

                            }                                               
                        }
                    else{
                            branchList.add(cs.Branch__r.Branch_Code__c);
                            customer.Branch_Code__c = ','+String.join(branchList, ',')+',';
                        }                
                }
                else{
                    customer.Branch_Code__c =','+cs.Branch__r.Branch_Code__c+',';
                }

                customerUpdateMap.put(cs.Customer__c, customer);
            }


            system.debug('validCustomerIdSet-->> '+validCustomerIdSet);
        	system.debug('isUpdate-->> '+isUpdate);
        	system.debug('isUpdate-->> '+oldMap);
        	system.debug('isUpdate emty-->> '+oldMap.isEmpty());
            if(isUpdate && !oldMap.isEmpty()){ 
                for(SObject obj : newSalesOrgMap.values()){
                    Id customerId = (Id)obj.get('Customer__c');
                    
                    if(!validCustomerIdSet.contains(customerId)){
                        if(customerUpdateMap.containsKey(customerId)){
                            customerUpdateMap.get(customerId).Sales_region__c = null;
                        }else {
                            customerUpdateMap.put(customerId, new Account(Id= customerId , Sales_region__c = null));
                        }   
                    }
                }
            }  

            if(customerUpdateMap.values().size() > 0 ){
                update customerUpdateMap.values();
            }
        	
        }catch (Exception ex) {
            TegaUtility.trackLogs( ex,  'CustomerSalesOrganizationHandler',  'updateCustomer');  
        }
        
    }
        
  
    /*
    Name : deleteCustomerSalesOrg
    Desc : this method use to update sales region and branch code in customer after delete.
    */
    public void deleteCustomerSalesOrg(Map<Id, SObject> oldItemsMap){
        try {
            Set<Id> IdSet = new Set<Id>();
            Map<Id, Account> updateCustomerMap = new Map<Id, Account>();

            for(SObject obj : oldItemsMap.values()){
                Customer_Sales_Organization__c cs = (Customer_Sales_Organization__c)obj;
                if(cs.Customer__c != null){
                    IdSet.add(cs.Customer__c);
                }            
            }

            //Query to fetch all CSO attached with customer...
            Map<Id, Customer_Sales_Organization__c> cSalesOrgMap  = new Map<Id, Customer_Sales_Organization__c> (
                [SELECT Id,Customer__c, Customer__r.Sales_region__c, Customer__r.Branch_Code__c,
                Branch__c,Branch__r.Sales_Region__c, Branch__r.Branch_Code__c,
                Branch__r.Sales_Region__r.Manager__c
                FROM Customer_Sales_Organization__c
                WHERE Customer__c IN : IdSet]);


                for(Customer_Sales_Organization__c cs : cSalesOrgMap.values()){
                    if(IdSet.contains(cs.Customer__c)){
                        if(!updateCustomerMap.containsKey(cs.Customer__c)){
                            updateCustomerMap.put(cs.Customer__c, new Account( Id = cs.Customer__c,
                                                Branch_Code__c = cs.Branch__r.Branch_Code__c));
                        }else {
                            updateCustomerMap.get(cs.Customer__c).Branch_Code__c +=','+cs.Branch__r.Branch_Code__c;
                        }
                    }
                }
                for(Id key : IdSet){
                    if(!updateCustomerMap.containsKey(key)){
                        updateCustomerMap.put(key, new Account(Id = key,Branch_Code__c='', 
                        Sales_region__c = null, Regional_Manager__c = null));
                    }
                }
            
                if(updateCustomerMap.values().size() > 0 ){
                    update updateCustomerMap.values(); // update Customer
                }
                
            
        } catch (Exception ex) {
            TegaUtility.trackLogs( ex,  'CustomerSalesOrganizationHandler',  'deleteCustomerSalesOrg');  
            
        }
    }
    
    /*
    Name : checkBranchValidation
    Desc : this method is used to check if user is entering correct branch and distribution channel as per their territory assignment.
    
    public void checkBranchValidation(List<Customer_Sales_Organization__c> newCustSalesOrgList){
        
        try{
            // Getting current user's branch name
            String currentUserId = UserInfo.getUserId();
            system.debug('currentUserId '+currentUserId);
            User currentUser = [Select Id from User where Id =: currentUserId];
            system.debug('currentUser '+currentUser);
            List<UserTerritory2Association> userTerritoryRelation = [SELECT Id, UserId, Territory2Id FROM UserTerritory2Association WHERE UserId =: currentUserId];
            system.debug('userTerritoryRelation '+userTerritoryRelation);
            Set<Id> userTerritoryIds = new Set<id>();
            for(UserTerritory2Association userTerritory : userTerritoryRelation){
                userTerritoryIds.add(userTerritory.Territory2Id);
            }
            system.debug('userTerritoryIds '+userTerritoryIds);
            List<Territory2> userTerritoryList = new List<Territory2>();
            if(userTerritoryRelation.size()>0){
                userTerritoryList = [SELECT Id, Name, Territory2TypeId, Description FROM Territory2 where Id IN: userTerritoryIds];
                system.debug('userTerritoryList '+userTerritoryList);
            }
            
            List<String> branchNameList = new List<String>();
            if(userTerritoryRelation.size()>0){
                for(Territory2 territory : userTerritoryList){
                    branchNameList.add(territory.Name);
                }
                system.debug('branchNameList '+branchNameList);
            }
            
            List<Customer_Mapping__mdt> custMetaDataList = [Select Label,Branch__c,Distribution_Channel__c,Sales_Org__c 
                                                            from Customer_Mapping__mdt where Branch__c IN: branchNameList];
            system.debug('custMetaDataList '+custMetaDataList);
            
            Map<String,Customer_Mapping__mdt> custMetaDataMap = new Map<String,Customer_Mapping__mdt>();
            
            
            for(Customer_Mapping__mdt customMetaData : custMetaDataList){
                custMetaDataMap.put(customMetaData.Branch__c,customMetaData);
            }
            system.debug('custMetaDataMap '+custMetaDataMap);
            
            // Bulkified Logic starts from here as user will always be unique
            Set<Id> salesOrgSet = new Set<Id>();
            Set<Id> branchSet = new Set<Id>();
            
            for(Customer_Sales_Organization__c custSalesOrg : newCustSalesOrgList){
                salesOrgSet.add(custSalesOrg.Sales_Organizations__c);
                branchSet.add(custSalesOrg.Branch__c);
            }
            system.debug('salesOrgSet '+salesOrgSet);
            system.debug('branchSet '+branchSet);
            
            List<Sales_Org__c> salesOrgList = [Select Id,Name from Sales_Org__c where Id in: salesOrgSet];
            List<Branch__c> branchList = [Select Id,Name from Branch__c where Id in: branchSet];
            system.debug('salesOrgList '+salesOrgList);
            system.debug('branchList '+branchList);
            
            Map<Id,String> salesOrgMap = new Map<Id,String>();
            Map<Id,String> branchMap = new Map<Id,String>();
            
            for(Sales_Org__c salesOrg : salesOrgList){
                salesOrgMap.put(salesOrg.Id,salesOrg.Name);
            }
            system.debug('salesOrgMap '+salesOrgMap);
            
            for(Branch__c branch : branchList){
                branchMap.put(branch.Id,branch.Name);
            }
            system.debug('salesOrgMap '+salesOrgMap);
            
            for(Customer_Sales_Organization__c custSalesOrg : newCustSalesOrgList){
                String salesOrgName = salesOrgMap.get(custSalesOrg.Sales_Organizations__c);
                String branch = branchMap.get(custSalesOrg.Branch__c);
                String distributionChannel = custSalesOrg.Distribution_Channel__c;
                system.debug('distributionChannel '+distributionChannel);
                system.debug('salesOrgName '+salesOrgName);
                system.debug('branch '+branch);
                Customer_Mapping__mdt customMetaData = custMetaDataMap.get(branch);
                system.debug('customMetaData '+customMetaData);
                if(customMetaData!=null){
                    system.debug('INSIDE FINAL IF');
                    if(distributionChannel == customMetaData.Distribution_Channel__c && 
                       salesOrgName == customMetaData.Sales_Org__c && 
                       branch == customMetaData.Branch__c){
                           
                           system.debug('Validations succeeded');
                    }else{
                           custSalesOrg.addError(System.Label.Wrong_Branch_Combination_in_Customer);
                    }
                }else{
                    custSalesOrg.addError(System.Label.Wrong_Branch_Combination_in_Customer);
                }
            }
        }catch(exception e){
            TegaUtility.trackLogs(e, 'CustomerSalesOrganizationHandler', 'checkBranchValidation');
        }
    }*/
    
    public void setCheckboxToFalseNew(List<Customer_Sales_Organization__c> newCustSalesOrgList){
        try{
            List<Id> accountIdList = new List<Id>();
            for(Customer_Sales_Organization__c custSalesOrg : newCustSalesOrgList){
                accountIdList.add(custSalesOrg.Customer__c);
            }
            
            List<Account> accList = [Select Id,Run_Assignment_Rules__c from Account where Id in: accountIdList];
            for(Account acc : accList){
                acc.Run_Assignment_Rules__c = false;
            }
            update accList;
        }catch(exception e){
            TegaUtility.trackLogs(e, 'CustomerSalesOrganizationHandler', 'setCheckboxToFalse');
        }
    }
    
    public void setCheckboxToFalseUpdate(List<Customer_Sales_Organization__c> newCustSalesOrgList, Map<Id, SObject> newSalesOrgMap,Map<Id, SObject> oldMap){
        try{
            List<Id> accountIdList = new List<Id>();
            //List<Customer_Sales_Organization__c> custSalesOrgList = new List<Customer_Sales_Organization__c>();
            
            Map<Id, Customer_Sales_Organization__c> cSalesOrgMap = new Map<Id, Customer_Sales_Organization__c> ([SELECT Id,Customer__c, Customer__r.Sales_region__c, Customer__r.Branch_Code__c,
                                                              Branch__c,Branch__r.Sales_Region__c, Branch__r.Branch_Code__c,
                                                              Branch__r.Sales_Region__r.Manager__c, Company__c
                                                              FROM Customer_Sales_Organization__c
                                                              WHERE Id IN : newSalesOrgMap.keySet()]);
            
            for(Id custSalesOrgId : newSalesOrgMap.keySet() ){
                Customer_Sales_Organization__c cs = cSalesOrgMap.get(custSalesOrgId);
                Customer_Sales_Organization__c oldCs = (Customer_Sales_Organization__c)oldMap.get(custSalesOrgId);
                if( cs.Branch__c != oldCs.Branch__c ){
                    accountIdList.add(cs.Customer__c);
                    cs.isChecked__c = false;
                    //custSalesOrgList.add(cs);
                }
            }
            
            List<Account> accList = [Select Id,Run_Assignment_Rules__c from Account where Id in: accountIdList];
            for(Account acc : accList){
                acc.Run_Assignment_Rules__c = false;
            }
            
            update accList;
            //update custSalesOrgList;
        }catch(exception e){
            TegaUtility.trackLogs(e, 'CustomerSalesOrganizationHandler', 'setCheckboxToFalse');
        }
    }
}