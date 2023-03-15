@IsTest(SeeAllData=false)
public class ProposalFormTriggerTestClass {
	
    @testSetup static void setup() {    
        User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = testUser.Id);
        insert salesReg;
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id, Branch_Code__c = 'TBR');
        insert branch;
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(Customer__c = acc.Id, Branch__c = branch.Id ,  CreatedFromAccount__c = true);
        insert custSalesOrg1;
        Account acc1 = new Account(Name = 'Test Account1');
        insert acc1;
        Customer_Sales_Organization__c custSalesOrg2 = new Customer_Sales_Organization__c(Customer__c = acc1.Id, Branch__c = branch.Id ,  CreatedFromAccount__c = true);
        insert custSalesOrg2;
        acc.Status__c = 'Sync with SAP';
        update acc;
        RecordType millRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Mill'];  
        RecordType hydroRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Hydrocyclone'];
        RecordType MillRecTypeOpp = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
        Customer_Equipments__c millCustEquip = new Customer_Equipments__c(Customer__c = acc.Id, RecordTypeId = millRecType.Id);
        insert millCustEquip;
        Customer_Equipments__c hydroCustEquip = new Customer_Equipments__c(Customer__c = acc.Id, RecordTypeId = hydroRecType.Id);
        insert hydroCustEquip;
        Customer_Equipments__c millCustEquip1 = new Customer_Equipments__c(Customer__c = acc1.Id, RecordTypeId = millRecType.Id);
        insert millCustEquip1;
        Opportunity millOpp = new Opportunity(Name = 'Test Child Opp Mill', AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        insert millOpp;
      //  Design_Parameter__c desPar = new Design_Parameter__c(Name = 'Test DP',Customer_Equipment__c = hydroCustEquip.Id);
      //  insert desPar;
    }
    
    static testmethod void validateData(){
        Account acc = [Select Id,Name from Account where Name = 'Test Account'];
        Account acc1 = [Select Id,Name from Account where Name = 'Test Account1'];
        Opportunity opp = [Select Id,Name from Opportunity where Name = 'Test Child Opp Mill'];
        RecordType millRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Mill'];  
        RecordType hydroRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Hydrocyclone'];
        Customer_Equipments__c hydroCustEquip = [Select Id,Customer__c,RecordTypeId from Customer_Equipments__c where RecordTypeId =: hydroRecType.Id];
        Customer_Equipments__c millCustEquip = [Select Id,Customer__c,RecordTypeId from Customer_Equipments__c where RecordTypeId =: millRecType.Id AND Customer__c =: acc.Id];
        Customer_Equipments__c millAnotherCustEquip = [Select Id,Customer__c,RecordTypeId from Customer_Equipments__c where Customer__c =: acc1.Id];
       // Design_Parameter__c designPar = [Select Id,Name from Design_Parameter__c where Name = 'Test DP'];
        Proposal_Form__c oppEquip = new Proposal_Form__c(Opportunity__c = opp.Id,Customer_Equipment__c = hydroCustEquip.Id);
        Proposal_Form__c oppEquip1 = new Proposal_Form__c(Opportunity__c = opp.Id,Customer_Equipment__c = millAnotherCustEquip.Id);
        Proposal_Form__c oppEquip2 = new Proposal_Form__c(Opportunity__c = opp.Id,Customer_Equipment__c = millCustEquip.Id);
        
        try{
            insert oppEquip;
        	insert oppEquip1;
       		insert oppEquip2;
            oppEquip2.SAP_Offer_Number__c = 'Test1234';
            update oppEquip2;
            delete oppEquip2;
            undelete oppEquip2;
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
}