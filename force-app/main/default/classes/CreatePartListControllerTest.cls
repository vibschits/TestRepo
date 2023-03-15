@isTest(SeeAllData=false)
public class CreatePartListControllerTest {
    private static testMethod void unit1(){
        Test.setMock(WebServiceMock.class, new PartListMock());
        Integration_Transaction__c it = new Integration_Transaction__c(
            Record_Id__c = 'PLM-01314-01' ,
            Operation__c = 'Create Partlist	'
        );
     insert it;

     System.assertEquals(it.Record_Id__c, 'PLM-01314-01');

    CreatePartListController.getPartList('PLM-01314-01', it.Id);
    }
}