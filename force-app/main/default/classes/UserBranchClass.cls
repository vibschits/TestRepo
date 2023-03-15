/* This class is used by Customer Branch Assignment LWC Component to display custom new and edit page */
public with sharing class UserBranchClass {
    
    // This method will fetch all the company names which are related to user via User Branch Relation
    @AuraEnabled(cacheable=true)
    public static List<String> getCompanyFromUserBranch(String currentUserId){
        
		List<String> branches = returnBranchNames(currentUserId);
        system.debug('Branches =>'+branches);
        
        List<String> filteredBranchNameList = new List<String>();
        List<String> filteredSalesOrgList = new List<String>();
        for(String branch : branches){
            if(branch.contains('-') == true){
                filteredBranchNameList.add(branch.substringBefore('-'));
                filteredSalesOrgList.add(branch.substringAfter('-'));
            }else{
                filteredBranchNameList.add(branch);
            }
        }
        system.debug('filteredBranchNameList'+filteredBranchNameList);
        system.debug('filteredBranchNameList'+filteredSalesOrgList);
        
        Set<String> uniqueBranchList = new Set<String>();
        uniqueBranchList.addAll(filteredBranchNameList);
        filteredBranchNameList.clear();
        filteredBranchNameList.addAll(uniqueBranchList);
        system.debug('UniqueBranchhNameList'+filteredBranchNameList);
        
        List<Sales_Org__c> filteredSalesOrgRecordsList = [SELECT Id, Name FROM Sales_Org__c where Name IN: filteredSalesOrgList];
        
        //List<Branch__c> branchList = [Select Id,Name,Sales_Organization_del__c from Branch__c where Name IN: filteredBranchNameList];
        List<Branch__c> branchList = [Select Id,Name from Branch__c where Name IN: filteredBranchNameList];
        system.debug('branchList'+branchList);
        
        //AK 24/02/23 Fixes
        Set<Id> branchSet = new Set<Id>();
        for(Branch__c branch : branchList){
            branchSet.add(branch.Id);
        }
        List<Sales_Org_Branch_Relationship__c> salesOrgList = [Select Id,Branch__c,Sales_Organization__c from Sales_Org_Branch_Relationship__c
                                                        where Branch__c IN :branchSet];
        system.debug('salesOrgList'+salesOrgList);
        
        /*Set<Id> salesOrgSet = new Set<Id>();
        for(Branch__c branch : branchList){
            salesOrgSet.add(branch.Sales_Organization_del__c);
        }
        for(Sales_Org__c salesOrg : filteredSalesOrgRecordsList){
            salesOrgSet.add(salesOrg.Id);
        }
        system.debug('salesOrgSet'+salesOrgSet);

        List<Sales_Org__c> salesOrgList = [SELECT Id, Name FROM Sales_Org__c where Id IN: salesOrgSet];
        system.debug('salesOrgList'+salesOrgList);

        Set<Id> salesOrgIdSet = new Set<Id>();
        for(Sales_Org__c salesOrg : salesOrgList){
            salesOrgIdSet.add(salesOrg.Id);
        }
        system.debug('salesOrgIdSet'+salesOrgIdSet);*/
        
        Set<Id> salesOrgIdSet = new Set<Id>();
        for(Sales_Org_Branch_Relationship__c salesOrg : salesOrgList){
            salesOrgIdSet.add(salesOrg.Sales_Organization__c);
        }
        system.debug('salesOrgIdSet'+salesOrgIdSet);

        List<Company__c> companyList = [SELECT Id, Name, Sales_Organization__c FROM Company__c where Sales_Organization__c IN: salesOrgIdSet];
        system.debug('companyList'+companyList);

        List<String> companyNameList = new List<String>();

        for(Company__c comp : companyList){
            companyNameList.add(comp.Name);
        }
        system.debug('companyNameList'+companyNameList);

        return companyNameList;
    }

    // This method will fetch branches which are tagged to user via Territory Management.
    @AuraEnabled(cacheable=true)
    public static List<String> getBranchFromSelectedCompany(String selectedCompany){
        List<Company__c> companyList = [SELECT Id, Name, Sales_Organization__c FROM Company__c where Name =: selectedCompany];
        Id SalesOrgId = companyList[0].Sales_Organization__c;
        
        String userId = UserInfo.getUserId();
        List<String> branches = returnBranchNames(userId);
        system.debug('branches'+branches);
        
        List<String> filteredBranchNameList = new List<String>();
        List<String> filteredBranchNameListHyphon = new List<String>();
        for(String branch : branches){
            if(branch.contains('-') == true){
                filteredBranchNameListHyphon.add(branch.substringBefore('-'));
            }else{
                filteredBranchNameList.add(branch);
            }
        }
        system.debug('filteredBranchNameList After=>'+filteredBranchNameList);
        system.debug('filteredBranchNameListHyphon After=>'+filteredBranchNameListHyphon);
        
        ///
        List<Sales_Org_Branch_Relationship__c> salesOrgBranchList = [SELECT Id, Name, Branch__c, Sales_Organization__c FROM Sales_Org_Branch_Relationship__c where Sales_Organization__c =: SalesOrgId];
        system.debug('salesOrgBranchList'+salesOrgBranchList);
        Set<Id> branchFromSalesOrgBranchRelationship = new Set<Id>();
        for(Sales_Org_Branch_Relationship__c salesOrgBranchRel : salesOrgBranchList){
            branchFromSalesOrgBranchRelationship.add(salesOrgBranchRel.Branch__c);
        }
        system.debug('branchFromSalesOrgBranchRelationship'+branchFromSalesOrgBranchRelationship);

        List<Branch__c> branchList = [Select Id,Name from Branch__c where Id IN: branchFromSalesOrgBranchRelationship];
        system.debug('branchList from Company'+branchList);
        List<String> branchNameList = new List<String>();
        List<String> filteredBranches = new List<String>();
        for(Branch__c branch : branchList){
            branchNameList.add(branch.Name);
        }
		system.debug('branchNameList'+branchNameList);   
        ///
        
        for(String branch1 : filteredBranchNameListHyphon){
            for(String branch2 : branchNameList){
                if(branch1 == branch2){
                    filteredBranches.add(branch1);
                }
            }
        }
        system.debug('filteredBranches=>'+filteredBranches);
        
        
        /*List<Branch__c> branchList2 = [Select Id,Name,Sales_Organization_del__c from Branch__c where Sales_Organization_del__c =: SalesOrgId];
        List<String> branchNameList2 = new List<String>();
        List<String> filteredBranches2 = new List<String>();
        for(Branch__c branch : branchList2){
            branchNameList2.add(branch.Name);
        }
        system.debug('branchNameList2=>'+branchNameList2);*/
        List<String> filteredBranches2 = new List<String>();
        
        for(String branch1 : branches){
            //for(String branch2 : branchNameList2){
            for(String branch2 : branchNameList){
                if(branch1 == branch2){
                    filteredBranches2.add(branch1);
                }
            }
        }
        ////////
        
        system.debug('filteredBranches==>'+filteredBranches);
        system.debug('filteredBranches2==>'+filteredBranches2);
        
        Set<String> uniqueBranchList = new Set<String>();
        uniqueBranchList.addAll(filteredBranches);
        uniqueBranchList.addAll(filteredBranches2);
        system.debug('uniqueBranchList=>'+uniqueBranchList);
        filteredBranches.clear();
        filteredBranches.addAll(uniqueBranchList);
        system.debug('filteredBranches'+filteredBranches);
        
        return filteredBranches;
    }
    
    // Handler class to return branch names which is associated to user via territory management
    public static List<String> returnBranchNames(String currentUserId){
        List<String> branchNameList = new List<String>();
        List<String> allBranchNameList = new List<String>();
        system.debug('currentUserId '+currentUserId);
        
        User us = [SELECT Id, ProfileId FROM User where Id =: currentUserId];
        system.debug('us '+us);
        Profile prof = [Select Id,Name from Profile where Id =: us.ProfileId];
        system.debug('prof '+prof);
        
        String profileName = prof.Name;
        
        List<UserTerritory2Association> userTerritoryRelation = [SELECT Id, UserId, Territory2Id FROM UserTerritory2Association WHERE UserId =: currentUserId];
        system.debug('userTerritoryRelation '+userTerritoryRelation);
        
        Set<Id> userTerritoryIds = new Set<id>();
        for(UserTerritory2Association userTerritory : userTerritoryRelation){
            userTerritoryIds.add(userTerritory.Territory2Id);
        }
        system.debug('userTerritoryIds '+userTerritoryIds);
        
        // ALL Territories
        List<Territory2> allTerritoryList = [SELECT Id, Name, ParentTerritory2Id FROM Territory2];
        system.debug('allTerritoryList '+allTerritoryList);
        
        for(Territory2 territory : allTerritoryList){
            allBranchNameList.add(territory.Name);
        }
        
        // User Territories
        List<Territory2> userTerritoryList = new List<Territory2>();
        
        for(Territory2 territory : allTerritoryList){
            for(Id iteratorId : userTerritoryIds){
                if(territory.Id == iteratorId){
                    userTerritoryList.add(territory);
                }
            }
        }
        system.debug('userTerritoryList '+userTerritoryList);
        
        List<Territory2> relatedTerritoryList = new List<Territory2>();
        relatedTerritoryList.addAll(userTerritoryList);
        List<Territory2> newTerritoryList = new List<Territory2>();
        
        /*for(Territory2 userterritory : userTerritoryList){
            for(Territory2 territory : allTerritoryList){
                if(territory.ParentTerritory2Id == userterritory.Id){
                    relatedTerritoryList.add(territory);   
                }
            }
        }*/
        
        system.debug('relatedTerritoryList'+relatedTerritoryList);
        
        newTerritoryList = childTerritoryFinder(allTerritoryList,relatedTerritoryList);
        system.debug('newTerritoryList1'+newTerritoryList);
        if(newTerritoryList!=null && newTerritoryList.size()>0){
            relatedTerritoryList.addAll(newTerritoryList);
        }
        system.debug('relatedTerritoryList1'+relatedTerritoryList);
        
        while(newTerritoryList.size()>0){
            newTerritoryList = childTerritoryFinder(allTerritoryList,newTerritoryList);
            system.debug('newTerritoryList2'+newTerritoryList);
            relatedTerritoryList.addAll(newTerritoryList);
            system.debug('relatedTerritoryList2'+relatedTerritoryList);
        }
            
        if(userTerritoryRelation.size()>0){
            for(Territory2 territory : relatedTerritoryList){
                 branchNameList.add(territory.Name);
             }
             system.debug('branchNameList '+branchNameList);
         }
        
        if(profileName != 'System Administrator' && profileName != 'PMG'){
            system.debug(' NON ADMIN PMG');
            return branchNameList;
        }else{
            system.debug('ADMIN PMG');
            return allBranchNameList;
        }
    }
	
    /*
    @AuraEnabled
    public static String saveOffer(String offerId, String selectedCompany, String selectedBranch){
        String result = '';
        system.debug('recordId '+offerId);
        Branch__c  branch = [Select Id,Name from Branch__c where Name =: selectedBranch];
        system.debug('branch'+branch);
        Company__c company = [Select Id,Name,Sales_Organization__c from Company__c where Name =: selectedCompany];
        system.debug('company'+company);
        Id salesOrgId = company.Sales_Organization__c;
        system.debug('salesOrgId'+salesOrgId);
        Sales_Org__c salesOrg = [Select Id from Sales_Org__c where Id =: salesOrgId];
        system.debug('salesOrg'+salesOrg);
        List<Quote> offer = [Select Id,Name,Branch__c,Company__c,Sales_Org__c from Quote where Id =: offerId];
        system.debug('offer'+offer);
        offer[0].Branch__c = branch.Id;
        offer[0].Company__c =  company.Id;
        offer[0].Sales_Org__c = salesOrg.Id;
        try{
            update offer;
            result = 'SUCCESS';
        }catch(exception e){
            TegaUtility.trackLogs(e, 'UserBranchC;ass', 'saveOffer');
            result = 'FAIL';
        }
        system.debug('result'+result);
        return result;
    }
*/
	
    // This method is triggered onClick of save button via lwc and it is updating Customer Branch Assignment Record
    @AuraEnabled
    public static String saveCSO(String csoId, String selectedCompany, String selectedBranch){
        String result = '';
        system.debug('recordId '+csoId);
        Branch__c  branch = [Select Id,Name from Branch__c where Name =: selectedBranch];
        system.debug('branch'+branch);
        Company__c company = [Select Id,Name,Sales_Organization__c from Company__c where Name =: selectedCompany];
        system.debug('company'+company);
        Id salesOrgId = company.Sales_Organization__c;
        system.debug('salesOrgId'+salesOrgId);
        Sales_Org__c salesOrg = [Select Id from Sales_Org__c where Id =: salesOrgId];
        system.debug('salesOrg'+salesOrg);
        List<Customer_Sales_Organization__c> cso = [Select Id,Name,Branch__c,Company__c,Sales_Organizations__c,Distribution_Channel__c
        from Customer_Sales_Organization__c where Id =: csoId];
        system.debug('cso'+cso);
        Customer_Mapping__mdt custMetadata = [Select Id,Branch__c,Distribution_Channel__c from Customer_Mapping__mdt where Branch__c =: branch.Name];
        system.debug('custMetadata'+custMetadata);
        String distChannel = custMetadata.Distribution_Channel__c;
        cso[0].Branch__c = branch.Id;
        cso[0].Company__c =  company.Id;
        cso[0].Sales_Organizations__c = salesOrg.Id;
        cso[0].Distribution_Channel__c = distChannel;
        try{
            update cso;
            result = 'SUCCESS';
        }catch(exception e){
            Id errorLogId = TegaUtility.trackLogs(e, 'UserBranchClass', 'saveCSO');
            Error_Log__c errorLog = [Select Id,Error_Message__c from Error_Log__c where Id =: errorLogId];
            String errorMessage1 = errorLog.Error_Message__c;
            String errorMessage2 = errorMessage1.substringAfterLast(',');
            String errorMessage = errorMessage2.substringBefore(':');
            system.debug('errorMessage1'+errorMessage1);
            system.debug('errorMessage2'+errorMessage2);
            result = errorMessage;
        }
        system.debug('result'+result);
        return result;
    }

    // This method is triggered onClick of save button via lwc and it is creating Customer Branch Assignment Reco
    @AuraEnabled
    public static Id createCSO(String customerId, String selectedCompany, String selectedBranch, String currencySelected,
     List<String> divisionsSelected){
        String result = '';
        system.debug('recordId '+customerId);
        system.debug('Multi select picklist '+divisionsSelected);
        for(String str : divisionsSelected){
            system.debug('picklist '+str);
        }
        String div = String.join(divisionsSelected, ';');
        Account cust = [Select Id from Account where Id =: customerId];
        Branch__c  branch = [Select Id,Name from Branch__c where Name =: selectedBranch];
        system.debug('branch'+branch);
        Company__c company = [Select Id,Name,Sales_Organization__c from Company__c where Name =: selectedCompany];
        system.debug('company'+company);
        Id salesOrgId = company.Sales_Organization__c;
        system.debug('salesOrgId'+salesOrgId);
        Sales_Org__c salesOrg = [Select Id from Sales_Org__c where Id =: salesOrgId];
        system.debug('salesOrg'+salesOrg);
        Customer_Sales_Organization__c cso = new Customer_Sales_Organization__c();        
        system.debug('cso'+cso);
        Customer_Mapping__mdt custMetadata = [Select Id,Branch__c,Distribution_Channel__c from Customer_Mapping__mdt where Branch__c =: branch.Name];
        system.debug('custMetadata'+custMetadata);
        String distChannel = custMetadata.Distribution_Channel__c;
        cso.Customer__c = cust.Id;
        cso.Branch__c = branch.Id;
        cso.Company__c =  company.Id;
        cso.Sales_Organizations__c = salesOrg.Id;
        cso.Distribution_Channel__c = distChannel;
        cso.CurrencyIsoCode = currencySelected;
        cso.Division__c = div;
        cso.CreatedFromAccount__c = true;
        try{
            insert cso;
            result = cso.Id;
            system.debug('result'+result);
            return result;
        }catch(exception e){
            Id errorLogId = TegaUtility.trackLogs(e, 'UserBranchClass', 'saveCSO');
            Error_Log__c errorLog = [Select Id,Error_Message__c from Error_Log__c where Id =: errorLogId];
            String errorMessage1 = errorLog.Error_Message__c;
            String errorMessage2 = errorMessage1.substringAfterLast(',');
            String errorMessage = errorMessage2.substringBefore(':');
            system.debug('errorMessage1'+errorMessage1);
            system.debug('errorMessage2'+errorMessage2);
            result = errorMessage;
            system.debug('result'+result);
            return result;
        }
        //system.debug('result'+result);
        //return result;
    }
    
    // This method is a handler method which helps in finding all the child territories of any given territory
    public static List<Territory2> childTerritoryFinder(List<Territory2> allTerritoriesList, List<Territory2> filteredTerritories){
        List<Territory2> newlyAddedTerritoriesList= new List<Territory2>();
        for(Territory2 userterritory : filteredTerritories){
            for(Territory2 territory : allTerritoriesList){
                if(territory.ParentTerritory2Id == userterritory.Id){
                    newlyAddedTerritoriesList.add(territory);   
                }
            }
        }
        return newlyAddedTerritoriesList;
    }

}