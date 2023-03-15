/*
Name : ProductInstalledHandlerTest
Desc : This is a Test class of ProductInstalledTrigger 
US :
*/
@isTest
public class ProductInstalledTriggerTest {
    
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
        
        List<RecordType> equipRecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Customer_Equipments__c'];
        Customer_Equipments__c custEquip = new Customer_Equipments__c();
        custEquip.CurrencyIsoCode = 'EUR';
        custEquip.Customer__c = acc.id;
        custEquip.Recordtypeid = equipRecordTypeList[0].Id;
        insert custEquip;
        
        Location__c loc = new Location__c();
        loc.Customer_Equipment__c = custEquip.id;
        loc.Reference_Structure__c='Head Pulley;Tail Pulley;Loading Point;Non Drive Pulley;Snub Pulley;Bend Pulley';
        insert loc;
        
        List<RecordType> PIRecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Product_Installed__c'];
       	
        List<Product_Installed__c> lstPI = new List<Product_Installed__c>();
        for(RecordType rec: PIRecordTypeList){
            
		Product_Installed__c pi = new Product_Installed__c();
		pi.Location__c=loc.Id;
        pi.Price__c = 20;
        pi.RecordTypeId = rec.id;
        lstPI.add(pi);    
        }
        
        insert lstPI;
        Product_Installed__c pi = [select id,name,Price__c from Product_Installed__c limit 1];
        pi.Price__c = 30;
        update pi;
        delete pi;
        undelete pi;
        
            }
    
}