@IsTest(SeeAllData=false)
private class AccountTriggerTestClass {
    
    @testSetup static void setup(){
        try{
            User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
            Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = testUser.Id);
            insert salesReg;
            Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id);
            insert branch;
        }catch(exception e){
            TegaUtility.trackLogs(e, 'AccountTriggerTestClass', 'setup');
        }
    }
    
    static testmethod void validateData(){
        try{
            Branch__c branch = [Select Id from Branch__c where Name = 'Test Branch'];
            //Account acc = new Account(Name = 'Test Account', Branch__c = branch.Id);
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            Customer_Sales_Organization__c custSalesOrg = new Customer_Sales_Organization__c(Customer__c = acc.Id, Branch__c = branch.Id);
            insert custSalesOrg;
            acc.Name = 'Test Account Updated';
            update acc;
        }catch(exception e){
            TegaUtility.trackLogs(e, 'AccountTriggerTestClass', 'validateData');
        }
    }
   
     static testMethod void updateAccountType() {
        try{
            account  acc = new account();
            acc.Name ='test';
            acc.Type ='customer';
            insert acc;
            
           
            Account acc1 =  new account();
            acc1.Name = 'test2';
            acc1.Type ='';
           // acc1.ParentId = acc.id;
            insert acc1;
            
             account  acc2 = new account();
            acc2.Name ='test';
             acc2.ParentId = acc1.id;
            insert acc2;
            acc1.ParentId = acc.id;            
            update acc1;
            delete acc1;
            undelete acc1;
            //   acc1.ParentId = acc.id;
            
            
        }catch(exception e){
            TegaUtility.trackLogs(e, 'AccountTriggerTestClass', 'insertaccount');
        }
    }
}