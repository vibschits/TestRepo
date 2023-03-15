@isTest
public class ProcessListViewInstApexControllerTest {
    
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
        stock.Group_Items__c = true;
        stock.Installation_Quantity__c =10;
        //insert stock;
        
        Customer_Inventory_Stock__c stock1 = new Customer_Inventory_Stock__c();
        stock1.Item_Code__c = 'Test';
        stock1.Quantity__c = 12;
        stock1.Customer__c = acc.id;
        stock1.Group_Items__c = false;
        stock1.Installation_Quantity__c =10;
        //insert stock1;
        
        List<Customer_Inventory_Stock__c> lstcsi = new List<Customer_Inventory_Stock__c>();
        lstcsi.add(stock);
        lstcsi.add(stock1);
        insert lstcsi;
        
        List<String> invIds = new List<String>();
        invIds.add(stock.Id);
        invIds.add(stock1.Id);
        
        RecordType expInvRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Customer_Equipments__c' AND DeveloperName = 'Mill'];
        Id exportInvoiceRecTypeId = expInvRecType.Id;
        Customer_Equipments__c testCE = new Customer_Equipments__c();
        testCE.RecordTypeId = exportInvoiceRecTypeId;
        testCE.Customer__c = acc.id;
        string values = 'Launder;Bunker';
        testCE.Equipment_Type__c = 'Scrubber';
        insert testCE;
        
        Installation__c tstInstallation = new Installation__c();
        tstInstallation.Name = 'Demo WC Sales Rep';
        tstInstallation.Customer__c = acc.Id;
        tstInstallation.Equipment_Installed_At__c = testCE.Id;
        tstInstallation.Material_Handled__c = 'Aggregate';
        tstInstallation.Moisture_Content_max__c = 10;
        tstInstallation.Shape_of_Material__c = 'Round';
        tstInstallation.Max_Lump_Size_mm__c = 12;
        tstInstallation.Bulk_Density_t_m3__c= 12;
        tstInstallation.Max_Temperature_C__c= 12;
        insert tstInstallation;
        Test.startTest();
        ProcessListViewInstApexController.fetchInvs(stock.id);
        ProcessListViewInstApexController.createInstallationLines(tstInstallation.Id,invIds);
        Test.stopTest();
    }
    
}