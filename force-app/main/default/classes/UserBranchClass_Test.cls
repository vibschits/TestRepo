@isTest(SeeAllData=false)
public class UserBranchClass_Test {
    
    @testsetup static void setup(){
        List<Branch__c> lstbranch = new List<Branch__c>();
        Branch__c branch1 = new Branch__c(Name='Durgapur',Branch_Code__c='DGP');
        lstbranch.add(branch1);
        Branch__c branch2 = new Branch__c(Name='Hyderabad',Branch_Code__c='HYD');
        lstbranch.add(branch2);
        List<Sales_Org__c> lstsalesorg = new List<Sales_Org__c>();
        Sales_Org__c salesOrg1 = new Sales_Org__c(Name='TSSO');
        lstsalesorg.add(salesOrg1);
        Sales_Org__c salesOrg2 = new Sales_Org__c(Name='TGSO');
        lstsalesorg.add(salesOrg2);
        Account acc = new Account(Name = 'Test Account');
        insert lstbranch;
        //insert branch2;
        insert lstsalesorg;
        // insert salesOrg2;
        insert acc;
        List<Company__c> lstcompany = new List<Company__c>();
        Company__c company1 = new Company__c(Name='TEGA INDUSTRIES AFRICA (PTY) LTD',Sales_Organization__c=salesOrg1.Id);
        lstcompany.add(company1);
        Company__c company2 = new Company__c(Name='TEGA INDUSTRIES LTD',Sales_Organization__c=salesOrg2.Id);
        lstcompany.add(company2);
        insert lstcompany;
        //insert company2;
        
        /*Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(
Customer__c = acc.Id, 
Branch__c = branch1.Id,
Company__c = company1.Id,
Sales_Organizations__c = salesOrg1.Id,
Distribution_Channel__c = 'DS');
insert custSalesOrg1;*/
        
        Customer_Sales_Organization__c custSalesOrg2 = new Customer_Sales_Organization__c(
            Customer__c = acc.Id, 
            Branch__c = branch2.Id,
            Company__c = company2.Id,
            Sales_Organizations__c = salesOrg2.Id,CreatedFromAccount__c =true,
            Distribution_Channel__c = 'DS');
        insert custSalesOrg2;
    }
    
    static testmethod void test_method(){
        Id userId = UserInfo.getUserId();
        String currentUserId = String.valueOf(userId);
        Branch__c branch1=[select id,name from Branch__c where name = 'Durgapur'];
        Company__c company1 = [Select Id,Name,Sales_Organization__c from Company__c where Name =: 'TEGA INDUSTRIES LTD'];
        Sales_Org__c salesorg=new Sales_Org__c();
        salesorg.Name='HESO';
        salesorg.Company_code__c='HE01';
        insert salesorg;
        Sales_Org_Branch_Relationship__c testbranch=new Sales_Org_Branch_Relationship__c(Name='Test',Sales_Organization__c=company1.Sales_Organization__c,Branch__c=branch1.id);
        insert testbranch;
        Company__c company2 = [Select Id,Name,Sales_Organization__c from Company__c where Name =: 'TEGA INDUSTRIES AFRICA (PTY) LTD'];
        Customer_Sales_Organization__c custSalesOrg1 = [Select Id,Company__c from Customer_Sales_Organization__c where Company__c =: company1.Id];
        Account acc = [Select Id,Name from Account where Name = 'Test Account'];
        List<String> companyNamesList = UserBranchClass.getCompanyFromUserBranch(currentUserId);       
        UserBranchClass.getBranchFromSelectedCompany(company1.Name);
        UserBranchClass.saveCSO(custSalesOrg1.Id, 'TEGA INDUSTRIES LTD', 'Hyderabad');
        List<String> divisions = new List<String>();
        divisions.add('ML');
        UserBranchClass.createCSO(acc.Id, company2.Name, 'Durgapur', 'EUR', divisions);
        UserBranchClass.createCSO(acc.Id, company2.Name, 'Durgapur', 'INR', divisions);
    }
    
    static testmethod void test_method1(){
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Geographic_Territories' LIMIT 1];
        System.debug('territory types '+terriType);
        Account acc = [Select Id,Name from Account where Name = 'Test Account'];
        List<Profile> adminProfile = [select id, name from Profile where  name = 'System Administrator'];
        
        Territory2Model terrModel = new Territory2Model();
        terrModel .DeveloperName='ModelName'; // required field
        terrModel.Name = 'Name'; // required field
        insert terrModel ;
        
        List<Territory2> lstterritory = new List<Territory2>();
        Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=terrModel.Id, Name='TestTerritory', Territory2TypeId=terriType[0].Id);
        //insert objTerr;
        lstterritory.add(objTerr);
        Territory2 objTerr1 = new Territory2(ParentTerritory2Id=objTerr.id,DeveloperName = 'TestTerritory1', Territory2ModelId=terrModel.Id, Name='TestTerritory', Territory2TypeId=terriType[0].Id);
        //insert objTerr1;
        lstterritory.add(objTerr1);
        insert lstterritory;
        
        
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        List<User> lstusers = new List<User>();
        User u = new User(firstname= 'Test',
                          lastname='XXXX',
                          Alias='Test',
                          email = 'test1234@test.com',
                          username= 'test1234xxx@test.com', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        //insert u;
        lstusers.add(u);
        User u2 = new User(firstname= 'Test',
                           lastname='XXXX',
                           Alias='Test',
                           email = 'test1234122@test.com',
                           username= 'test1234xxx123@test.com', 
                           profileId= p.id, 
                           emailencodingkey='UTF-8',
                           languagelocalekey='en_US',
                           localesidkey='en_US',
                           timezonesidkey='America/Los_Angeles');
        lstusers.add(u2);
        insert lstusers;
        
        List<UserTerritory2Association> lstuta= new List<UserTerritory2Association>();
        UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u.Id, RoleInTerritory2='Sales / Marketing Manager');
        //insert objUserTerritory2Association;
        lstuta.add(objUserTerritory2Association);
        
        UserTerritory2Association objUserTerritory2Association2 = new UserTerritory2Association(Territory2Id= objTerr1.Id, UserId= u2.Id, RoleInTerritory2='Sales / Marketing Administrator');
        //insert objUserTerritory2Association2 ;
        lstuta.add(objUserTerritory2Association2);
        insert lstuta;
        
        Id userId = UserInfo.getUserId();
        String currentUserId = String.valueOf(userId);
        
        test.startTest();
        UserBranchClass.returnBranchNames(u.id);
        test.stopTest();
        
        
    }
}