@isTest
private class LeadProcessorTest {
    @testSetup
    static void setup() {
        List<Lead> accounts = new List<Lead>();
       
        for (Integer i=0;i<10;i++) {
            accounts.add(new Lead(LastName ='Account '+i, Company = 'abc'
                ));
        }
        insert accounts;
     
    }
    @isTest static void test() {
        Test.startTest();
        LeadProcessor uca = new LeadProcessor();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
     //   System.assertEquals(10, [select count() from contact where MailingCity = 'New York']);
    }
}