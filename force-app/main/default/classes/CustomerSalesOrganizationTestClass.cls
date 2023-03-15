@isTest(SeeAllData=false) 
public class CustomerSalesOrganizationTestClass {
    @testSetup static void setup(){
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region');
        insert salesReg;
        List<Branch__c> lstBrnach = new List<Branch__c>();
        Branch__c branch1 = new Branch__c(Name='Durgapur',Branch_Code__c='DGP',Sales_Region__c = salesReg.id );
        Branch__c branch2 = new Branch__c(Name='Hyderabad',Branch_Code__c='HYD',Sales_Region__c = salesReg.id);
        Branch__c branch3 = new Branch__c(Name='Bengaluru',Branch_Code__c='BEN');
        List<Sales_Org__c> lstsalesorg = new List<Sales_Org__c>();
        Sales_Org__c salesOrg1 = new Sales_Org__c(Name='TSSO');
        lstsalesorg.add(salesOrg1);
        Sales_Org__c salesOrg2 = new Sales_Org__c(Name='TGSO');
        lstsalesorg.add(salesOrg2);
        //Account acc = new Account(Name = 'Test Account', Mobile_number__c = '9898989898', Phone= '6767676767', Tel_No__c='5454545454');
        List<Account> lstacc = new List<Account>();
        Account acc = new Account(Name = 'Test Account',Sales_Region__c = salesReg.id);
        lstacc.add(acc);
        Account acc1 = new Account(Name = 'Test Account1');
        lstacc.add(acc1);
        //   Account acc1 = new Account(Name = 'Test Account1');
        lstBrnach.add(branch1);
        lstBrnach.add(branch2);
        lstBrnach.add(branch3);
        insert lstBrnach;
        insert lstsalesorg;
        insert lstacc;
        
        List<Company__c> lstCompany = new List<Company__c>();
        Company__c company1 = new Company__c(Name='TEGA INDUSTRIES AFRICA (PTY) LTD',Sales_Organization__c=salesOrg1.Id);
        lstCompany.add(company1);
        Company__c company2 = new Company__c(Name='TEGA INDUSTRIES LTD',Sales_Organization__c=salesOrg2.Id);
        lstCompany.add(company2);
        insert lstCompany;
        //insert company2;
    }
    static testmethod void test_checkBranchValidation(){
        
        Branch__c branch1 = [Select Id,Name from Branch__c where Name = 'Durgapur'];
        Branch__c branch2 = [Select Id,Name from Branch__c where Name = 'Hyderabad'];
        Branch__c branch3 = [Select Id,Name from Branch__c where Name = 'Bengaluru'];
        Sales_Org__c salesOrg1 = [Select Id,Name from Sales_Org__c where Name = 'TSSO'];
        Sales_Org__c salesOrg2 = [Select Id,Name from Sales_Org__c where Name = 'TGSO'];
        
        Company__c company1 = [Select Id,Name from Company__c where Name = 'TEGA INDUSTRIES AFRICA (PTY) LTD'];
        Company__c company2 = [Select Id,Name from Company__c where Name = 'TEGA INDUSTRIES LTD'];
        Account acc = [Select Id,Name from Account where Name = 'Test Account'];
        Account acc1 = [Select Id,Name from Account where Name = 'Test Account1'];
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(
            CreatedFromAccount__c =true,Customer__c = acc.Id, 
            Branch__c = branch1.Id,
            Company__c = company1.Id,
            Sales_Organizations__c = salesOrg1.Id,
            Distribution_Channel__c = 'DS');
        insert custSalesOrg1;
        
        Customer_Sales_Organization__c custSalesOrg2 = new Customer_Sales_Organization__c(
            CreatedFromAccount__c =true,Customer__c = acc.Id, 
            Branch__c = branch2.Id,
            Company__c = company2.Id,
            Sales_Organizations__c = salesOrg2.Id,
            Distribution_Channel__c = 'DS');
        insert custSalesOrg2;
        
        custSalesOrg2.Customer_Code__c = 'SAP1234';
        update custSalesOrg2;        
        
        Customer_Sales_Organization__c custSalesOrg3 = new Customer_Sales_Organization__c(
            CreatedFromAccount__c =true,Customer__c = acc1.Id, 
            Branch__c = branch3.Id,
            Company__c = company2.Id,
            Sales_Organizations__c = salesOrg2.Id,
            Distribution_Channel__c = 'DS');
        insert custSalesOrg3;
        
        delete custSalesOrg2;
        CustomerSalesOrganizationHandler testMethod1 = new CustomerSalesOrganizationHandler();
        testMethod1.getName();
        
    }
    
    private static testMethod void unit3(){
        Branch__c branch1 = [Select Id,Name from Branch__c where Name = 'Durgapur'];
        Sales_Org__c salesOrg1 = [Select Id,Name from Sales_Org__c where Name = 'TSSO'];
        Company__c company1 = [Select Id,Name from Company__c where Name = 'TEGA INDUSTRIES AFRICA (PTY) LTD'];
        Account acc = [Select Id,Name from Account where Name = 'Test Account'];
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(
            CreatedFromAccount__c =true,Customer__c = acc.Id, 
            Branch__c = branch1.Id,
            Company__c = company1.Id,
            Sales_Organizations__c = salesOrg1.Id,
            Distribution_Channel__c = 'DS');
        insert custSalesOrg1;
        
        Delete custSalesOrg1;
        undelete custSalesOrg1;
        
    }
    private static testMethod void unit4(){
        try{
            Branch__c branch1 = [Select Id,Name from Branch__c where Name = 'Durgapur'];
            Sales_Org__c salesOrg1 = [Select Id,Name from Sales_Org__c where Name = 'TSSO'];
            Company__c company1 = [Select Id,Name from Company__c where Name = 'TEGA INDUSTRIES AFRICA (PTY) LTD'];
            Account acc = [Select Id,Name from Account where Name = 'Test Account'];
            Account acc1 = [Select Id,Name from Account where Name = 'Test Account1'];
            Branch__c branch3 = [Select Id,Name from Branch__c where Name = 'Bengaluru'];
            Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(
                CreatedFromAccount__c =true,Customer__c = acc.Id, 
                Branch__c = branch3.Id,
                Company__c = company1.Id,
                Sales_Organizations__c = salesOrg1.Id,
                Distribution_Channel__c = 'DS');
            insert custSalesOrg1;
            
            Delete custSalesOrg1;
            undelete custSalesOrg1;
        }
        catch(Exception e){
            system.debug('error message '+e.getMessage());
        }
        
    }
}