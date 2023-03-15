@IsTest(SeeAllData=false)
private class LeadTriggerHelperTest {
       static testMethod void testManualShareRead(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales']; 
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
        
        
        //  User testUser = [Select Id,Email from User where Email = 'kandikatla.nikhil@ibm.com' limit 1];
        
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'North America', Manager__c = lstUsers[0].id);
        system.debug('salesReg manager'+salesReg.Manager__c);
        insert salesReg;
        
        list<Lead> ListLd2 = new list<Lead>();
        for(integer i=0;i<3;i++)
        { 
            Lead ld = new Lead(
                LastName = 'QWERTY',
                FirstName = 'Test SIT NIKHIL',
                Company = 'IBM',
                City = 'Hyderabad',
                Country = 'Turks and Caicos Islands',
                CountryCode = 'TC',
                Phone = '(787) 878-7878',
                Email = 'test@gmail.com',
                Status = 'New',
                CurrencyIsoCode = 'USD',
                IsUnreadByOwner = true,
                Department__c = 'Marketing',
                PMG_Associated__c = 'Mill',
                Write_Your_Message__c = 'Test SALESREGION AND COUNTRY TICKET 449',
                Regional_Manager__c = salesReg.Manager__c,
                Sales_Region__c = salesReg.id);
            ListLd2.add(ld);
        }
        insert ListLd2;
        
        system.debug('ListLd2'+ListLd2);
        LeadTriggerHelper.assignrecordtouserORgroup(ListLd2);
        Lead Ldshrs = new Lead(
            //Status = ListLd2[0].id,
            Status = 'New',
            Company='xyz',
            LastName='late',
            //UserOrGroupId =ListLd2[0].Regional_Manager__c,
            Department__c = 'HR'
        );
        
        insert Ldshrs;
           
           Ldshrs.Status = 'Unqualified';
           update Ldshrs;
           delete Ldshrs;
           undelete Ldshrs;
           
           
          /* Leadshare Ldshrss = new Leadshare(
            LeadId = ListLd2[0].id,
            UserOrGroupId =ListLd2[1].Regional_Manager__c,
            LeadAccessLevel = 'read'
        );
        
           update Ldshrss;
        system.debug('Ldshrs==='+Ldshrss);*/
        
          
    }
}