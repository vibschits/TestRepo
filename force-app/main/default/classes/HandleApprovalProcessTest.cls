@isTest
public class HandleApprovalProcessTest {
    @testSetup static void setup() {    
        User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = testUser.Id);
        insert salesReg;
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id, Branch_Code__c = 'TBR');
        insert branch;
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(Customer__c = acc.Id, Branch__c = branch.Id , CreatedFromAccount__c = true);
        insert custSalesOrg1;
        Account acc1 = new Account(Name = 'Test Account1', BillingCountry ='India');
        insert acc1;
        Customer_Sales_Organization__c custSalesOrg2 = new Customer_Sales_Organization__c(Customer__c = acc1.Id, Branch__c = branch.Id , CreatedFromAccount__c = true);
        insert custSalesOrg2;
        acc.Status__c = 'Sync with SAP';
        update acc;
        RecordType millRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Mill'];  
        RecordType hydroRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Hydrocyclone'];
        RecordType MillRecTypeOpp = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
        Customer_Equipments__c millCustEquip = new Customer_Equipments__c(Customer__c = acc.Id,
                                                                          RecordTypeId = millRecType.Id,
                                                                          Tag__c ='Test Record',
                                                                          Mill_Type__c = 'PbM',
                                                                          Mill_Type_Stage__c = 'Pbm',
                                                                          Type_of_Discharge__c= 'Grate',
                                                                          Dia_m__c = 12.00,
                                                                          Length_m__c=12.00);
        insert millCustEquip;
        Customer_Equipments__c hydroCustEquip = new Customer_Equipments__c(Customer__c = acc.Id, RecordTypeId = hydroRecType.Id);
        insert hydroCustEquip;
        Customer_Equipments__c millCustEquip1 = new Customer_Equipments__c(Customer__c = acc1.Id, RecordTypeId = millRecType.Id);
        insert millCustEquip1;
        Opportunity millOpp = new Opportunity(Name = 'Test Child Opp Mill', AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        insert millOpp;
        //Design_Parameter__c desPar = new Design_Parameter__c(Name = 'Test DP',Customer_Equipment__c = hydroCustEquip.Id);
        Design_Parameter__c desPar = new Design_Parameter__c(Customer_Equipment__c = hydroCustEquip.Id);

        insert desPar;
        Operating_Parameters__c operating = new Operating_Parameters__c( Customer__c = acc1.Id, 
                                                                        ore__c = 'Aggregate',
                                                                       Motor_Power_Kwh__c= 12.00,
                                                                       F80_mm__c =12.00,
                                                                       Media_Top_Size_mm__c=12.00,
                                                                       Mill_Speed_rpm__c=13.00,
                                                                        Charge_Volume__c =23.00,
                                                                        Throughput_tph__c =23.00,
                                                                        Type_of_Grinding__c ='wet',
                                                                        Circuit_Type__c ='open',
                                                                        Circulating_Load_if_closed_tph__c=23.00,
                                                                        Max_Temperature__c=23.00,
                                                                        pH_Value_of_the_Slurry__c = 31.00);
        insert operating;
        Proposal_Form__c oppEquip = new Proposal_Form__c(Operating_Parameters__c =operating.id,
                                                         Opportunity__c = millOpp.Id,Customer_Equipment__c = millCustEquip.Id);
        insert oppEquip;
        
    }
    
    static testmethod void runTest(){
        List<Id> newIdList = new List<Id>();
        User us = [Select Id from User limit 1];
        Account acc = [Select Id,Name from Account where Name = 'Test Account'];
        Account acc1 = [Select Id,Name from Account where Name = 'Test Account1'];
        Opportunity opp = [Select Id,Name from Opportunity where Name = 'Test Child Opp Mill'];
        RecordType millRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Mill'];  
        RecordType hydroRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Hydrocyclone'];
        Customer_Equipments__c hydroCustEquip = [Select Id,Customer__c,RecordTypeId from Customer_Equipments__c where RecordTypeId =: hydroRecType.Id];
        Customer_Equipments__c millCustEquip = [Select Id,Customer__c,RecordTypeId from Customer_Equipments__c where RecordTypeId =: millRecType.Id AND Customer__c =: acc.Id];
        Customer_Equipments__c millAnotherCustEquip = [Select Id,Customer__c,RecordTypeId from Customer_Equipments__c where Customer__c =: acc1.Id];
        Design_Parameter__c designPar = [Select Id,Name,Customer_Equipment__c from Design_Parameter__c where Customer_Equipment__c =: hydroCustEquip.id];
        Proposal_Form__c oppEquip =[Select Id,Opportunity__c,Customer_Equipment__c  from Proposal_Form__c order by CreatedDate  desc LIMIT 1];
      //  try{
         //   insert oppEquip;
             newIdList.add(oppEquip.Id);
           system.debug('oppEquip-------'+oppEquip);
		 
	
/*ProcessInstance objProcessInstance = [SELECT Id,TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId =: oppEquip.id];
system.debug('objProcessInstance'+objProcessInstance);
         Processinstanceworkitem processinstanceworkitemObj = new Processinstanceworkitem (
			ProcessInstanceId =objProcessInstance.id , 
			ActorId = us.id
		);
insert processinstanceworkitemObj;*/
       /* Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(oppEquip.id);
        Approval.ProcessResult results = Approval.process(app);
        system.debug(results.getNewWorkitemIds());
        ProcessInstance objProcessInstance = [SELECT Id,TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId =: oppEquip.id];
        system.debug('objProcessInstance'+objProcessInstance);*/
       /* Processinstanceworkitem processinstanceworkitemObj = new Processinstanceworkitem (
            ProcessInstanceId =objProcessInstance.id , 
            ActorId = us.id
           // CurrentNodeId,
           // OriginalActorId,
           // RemindersSent
            
        );
        insert processinstanceworkitemObj;*/
        
       // ProcessInstance objProcessInstance = new ProcessInstance(); 
       /*  Approval.ProcessWorkitemRequest req1 = new Approval.ProcessWorkitemRequest();
            req1.setComments('Approving request.');
            req1.setAction('Approve');
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
// set stuff
Approval.ProcessResult result = Approval.process(req1);*/
            
        
        
            /*Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
app.setObjectId(oppEquip.id);
Approval.ProcessResult result = Approval.process(app); 
Test.StartTest();
HandleApprovalProcess.getPRFId(newIdList);
System.assertEquals(oppEquip.CreatedDate,objProcessInstance.CreatedDate);

Test.StopTest();*/
            
          /*  //Step 2:  Create an approval request for the bid
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval via form');
            req.setObjectId(oppEquip.Id);
            
            //Step 3:  Submit on behalf of a specific submitter
            req.setSubmitterId(UserInfo.getUserId());
            
            //Step 4:  Submit the record to specific process and skip the criteria evaluation
            req.setProcessDefinitionNameOrId('Qualification_Approval');
            req.setSkipEntryCriteria(true);
            
            //Step 5:  Submit the approval request for the bid
            
            //Step 6:  Instantiate the new ProcessWorkitemRequest object and populate it
           
            //Step 7 : To check the next process after approval being submitted/approved etc.(basically next stage)  
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: oppEquip.id];
            
            // Use the ID from the newly created item to specify the item to be worked
            req1.setWorkitemId(pItem.Id);*/
            
            //Step 8 : result of process
          //  result = Approval.process(req1);
            HandleApprovalProcess.getPRFId(newIdList);
           // System.assertEquals(oppEquip.CreatedDate,objProcessInstance.CreatedDate);

        
//}
       // catch(Exception e){
        //    system.debug(e.getMessage());
        //}
        
    }
}