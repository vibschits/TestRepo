@isTest
public class CreateVirtualInventoryLinesTest {
    
    @isTest
    public static void test1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        list<user>lstUsers = new list<user>();
        for(integer i=0;i<3;i++)
        {
            user usr = new user();
            usr.Alias = 'sales'+string.ValueOf(i);
            usr.Email = 'sales'+string.ValueOf(i)+'@testorg.com';
            usr.EmailEncodingKey = 'UTF-8'; 
            usr.firstname = 'Test'; 
            usr.LastName = 'Leadassign'+string.ValueOf(i);
            usr.LanguageLocaleKey = 'en_US';
            usr.LocaleSidKey = 'en_US'; 
            usr.ProfileId = p.Id; 
            usr.TimeZoneSidKey = 'America/Los_Angeles';
            usr.UserName = 'salesuser1'+string.ValueOf(i)+'@testorg.com';
            lstUsers.add(usr);
        }
        insert lstUsers;
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = lstUsers[0].Id);
        insert salesReg;
        Account acc = new Account(Name = 'Test Account',CurrencyIsoCode = 'USD');
        insert acc;
        system.debug('Account'+acc);
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id,Branch_Code__c = 'TBR');
        insert branch;
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(CreatedFromAccount__c =true,Customer__c = acc.Id, Branch__c = branch.Id);
        insert custSalesOrg1;
        acc.Status__c = 'Sync with SAP';
        update acc;
        
        Customer_Inventory_Stock__c stock = new Customer_Inventory_Stock__c();
        stock.Item_Code__c = 'Test';
        stock.Quantity__c = 12;
        stock.Customer__c = acc.id;
        insert stock;
        
        List<Customer_Inventory_Stock__c> lstcsi = new List<Customer_Inventory_Stock__c>();
        lstcsi.add(stock);
        
        Test.startTest();
        Test.setCurrentPage(Page.CreateVirtualInventoryLines);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstcsi);
        stdSetController.setSelected(lstcsi);
        CreateVirtualInventoryLinesController ext = new CreateVirtualInventoryLinesController(stdSetController);
        ext.CreateVirtualInvLines();
        Test.stopTest();
    }
    
}