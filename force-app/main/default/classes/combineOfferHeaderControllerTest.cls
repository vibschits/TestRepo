@IsTest(SeeAllData=false)
public class combineOfferHeaderControllerTest {
     @testSetup static void setup() {    
        
        //User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
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
         
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = lstUsers[0].Id);
        insert salesReg;
        
        
        Account acc = new Account(Name = 'Test Account' , Status__c = 'Sync with SAP');
        insert acc;
        system.debug('Account'+acc);
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id,Branch_Code__c = 'TBR');
        insert branch;
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(Customer__c = acc.Id, Branch__c = branch.Id , CreatedFromAccount__c = true);
        insert custSalesOrg1;
         
        id  HydrocycloneRecordTypeId = Schema.SObjectType.Customer_Equipments__c.getRecordTypeInfosByDeveloperName().get('Hydrocyclone').getRecordTypeId();
  
           Customer_Equipments__c customer_equipments = new Customer_Equipments__c(
            CurrencyIsoCode = 'EUR',
            Circuit_diagram_available__c = false,
            Dia_m__c = 123.0,
            Mill_Type__c = 'SAG Mill',
            Tag__c = 'Test AK Mill 6 Jul',
            Type_of_Discharge__c = 'Grate',
            Customer__c = acc.id,
            Recordtypeid = HydrocycloneRecordTypeId);
        insert customer_equipments;
        
        
    }
    
    private static testMethod void CombineofferHeadergenerate(){
        
     id offerRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer').getRecordTypeId();
        id  nonSpareOfferRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer_Non_Spare').getRecordTypeId();
        
        Account account = [Select Id,Name,Status__c from Account where Name = 'Test Account'];
        Customer_Equipments__c customer_equipments = [SELECT id, name from Customer_Equipments__c WHERE Createddate = today order by CreatedDate DESC LIMIT 1];
        Customer_Sales_Organization__c customer_sales_organization = [Select Id from Customer_Sales_Organization__c where Branch__r.Name = 'Test Branch'];
        Branch__c branch =[SELECT id from Branch__c WHERE name = 'Test Branch'];
        
        
        
        Pricebook2 pricebook2 = new Pricebook2(
            Name = 'Standard Price Book',
            CurrencyIsoCode = 'USD',
            IsActive = true);
        insert pricebook2;
        
         User user = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        
        Opportunity opportunity = new Opportunity(
            AccountId = account.id,
            Name = 'Test AK OPP 6 Jul',
            Customer_Branch_Assignment__c   = customer_sales_organization.id,
            status__c = 'closed',
            Probability = 100.0,
            CloseDate = Date.newInstance(2022,07,21),
            ForecastCategoryName = 'Closed',
            CurrencyIsoCode = 'USD',
            stagename='closed won',
            RecordTypeId ='012Bl0000000IZfIAM',
            OwnerId = user.id
            
        );
        insert opportunity;
        
       
        
        
       //Quote offer = new Quote( Name = 'test offer' ,OpportunityId =ChildOppMill.id ,  Opportunity_Equipments__c=oppEquip.id , Payment_Months__c =10 , BTP_Type__c= 'FOB' ,  Delivery_Schedule__c=30 );
       // insert offer;
        
        /* Customer_Equipments__c customer_equipments = new Customer_Equipments__c(
CurrencyIsoCode = 'EUR',
Circuit_diagram_available__c = false,
Dia_m__c = 123.0,
Mill_Type__c = 'SAG Mill',
Tag__c = 'Test AK Mill 6 Jul',
Type_of_Discharge__c = 'Grate',
Customer__c = account.id,
Recordtypeid = '012Bl0000000H46IAE');
insert customer_equipments;*/
        
        Operating_Parameters__c operating_parameters = new Operating_Parameters__c(
            CurrencyIsoCode = 'USD',
            Bulk_Density_t_m3__c = 10.0,
            Circuit_diagram_available__c = false,
            Customer_Equipment__c = customer_equipments.id,
            Silica_Content__c = 20.0,
            Status__c = 'Current',
            Moisture__c = 30.0,
            Ore__c = 'Betonite, 100 mesh',
            Shape_of_Particles__c = 'Round',
            customer__c = account.id,
            Recordtypeid = '012Bl0000000H4DIAU');
        insert operating_parameters;
        
        
        
        
        Proposal_Form__c proposal_form = new Proposal_Form__c(
            CurrencyIsoCode = 'EUR',
            Customer_Equipment__c = customer_equipments.id,
            Opportunity__c = opportunity.id,
            Conversion__c = 'Converted potential',
            Conversion_sub_type__c = 'Application conversion',
            Spares__c = 'Spares Without Modification',
            Type__c = 'Conversion',
            Status__c = 'closed',
            Recordtypeid = '012Bl0000000OidIAE',
            Operating_Parameters__c= operating_parameters.id
            //Design_Parameter__c = DesignParam.id
        );
        insert proposal_form;
        
        Port_of_Destination__c port_of_destination = new Port_of_Destination__c(
            Name = 'ALGECIRAS',
            CurrencyIsoCode = 'USD');
        insert port_of_destination;
        
        Part_List__c part_list = new Part_List__c(
            Name = 'PLM-03960-01 SAP2',
            CurrencyIsoCode = 'USD',
            BOM__c = 'BALL DIA- 2400 X 4300 MM EGL',
            Delivery_Req__c = 56.0,
            Description__c = 'BALL DIA- 2400 X 4300 MM EGL',
            Direct_Quoted_Exchange_Rate__c = 54.0,
            Last_Offer_Value_Foreign_Currency__c = 0.0,
            Customer__c=account.id);
        insert part_list;
        
        Product2 product2 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = false,
            CurrencyIsoCode = 'USD',
            Part_List__c = part_list.id,
            Product_Level__c = 'L2',
            Quantity__c = 1.0);
        insert product2;
        
        Contact contact = new Contact(
            AccountId = account.id,
            LastName = 'Test Contack AK 6 Jul1',
            Email = 'kandikatla.nikhil@gmail.com',
            CurrencyIsoCode = 'USD',
            Status__c = 'ACTIVE',
            isActive__c = true);
        insert contact;
        
        
        
        Offer_Template__c offertemplate = new Offer_Template__c(
            General_T_C_2__c = 'General terms 2',
            General_T_C_3__c= 'General terms 3',
            About_Tega__c = 'General terms 1',
            Special_Clause__c= 'General terms 1', 
            Tega_Quality_Assurance_Program__c= 'General terms 1',
            General_T_C_Footer__c= 'General terms 1' );
        insert offertemplate;
        
        
        Quote quote = new Quote(
            Name = 'Test Nikhil offer',
            CurrencyIsoCode = 'EUR',
            OpportunityId = opportunity.id,
            PriceBook2Id = Test.getStandardPricebookId(),
            ContactId = contact.id,
            Status = 'Draft',
            BillingStreet = 'YOUGA, PROVINCE DE BOULGOU,,,,',
            BillingCity = 'YOUGA',
            BillingState = 'Assam',
            BillingPostalCode = '9999',
            BillingCountry = 'India',
            BillingStateCode = 'AS',
            BillingCountryCode = 'IN',
            BillingName = 'BURKINA MINING COMPANY SA',
            ShippingName = 'BURKINA MINING COMPANY SA',
            Email = 'test6@gmail.com',
            Phone = '1234567890',
            RecordTypeId = nonSpareOfferRecordTypeId ,
            Approval_Status__c = 'Delivery SLA Accepted',
            BTP_Type__c = 'CIF',
            Branch__c = branch.id,
            Delivery_Schedule__c = 12.0,
            Opportunity_Equipments__c = proposal_form.id,
            // PMG_Head__c = user.id,
            Part_List__c = part_list.id,
            Payment_Months__c = 12.0,
            Port__c = port_of_destination.id,
            RSM_Approval_Required__c = false,
            // Regional_Sales_Head__c = user.id,
            Customer_code_identification_required__c = false,
            Notes__c = 'We are a leading manufacturer of specialized ‘critical to operate’ and recurring consumable products for the global mineral beneficiation, mining and bulk solids handling industry. Globally, we are the second largest producers of polymer-based mill liners.',
            // Sales_Org__c = sales_org.id,
            // Company__c = company.id,
            Distribution_Channel__c = 'XP',
            Division__c = 'ML',
            Offer_Generation_at__c = 'L3',
            Offer_Template__c = offertemplate.id,
            Company_Branch_Assignment__c = customer_sales_organization.id);
        
        insert quote; 
        
         
        
        PricebookEntry pb2 = new PricebookEntry(Product2id =product2.Id,UnitPrice = 121, IsActive = true,PriceBook2Id = Test.getStandardPricebookId());
        insert pb2;
        QuoteLineItem quotelineitem = new QuoteLineItem(
            Quantity = 3.0,
            UnitPrice = 217.5,
            Discount = 0.0,
            Margin__c = 0.0,
            BTP_Price__c = 217.5,
            QuoteId =quote.id,
            Product2Id =product2.id,
            PricebookEntryid = pb2.id);
        insert quotelineitem;
        
        
        PageReference pageRef = Page.combineOfferSelectedSectionHeader;
        Test.setCurrentPage(pageRef);
        //   this.checked = Boolean.valueOf(ApexPages.currentPage().getParameters(true).get('checked'));
        
        pageRef.getParameters().put('checked',string.valueof(true));
        // pageRef.getParameters().put('IntroductionChecked',true);
        pageRef.getParameters().put('selectedofferid',quote.id);
        pageRef.getParameters().put('IntroductionChecked',string.valueof(true));
        pageRef.getParameters().put('OperatingParamatersChecked',string.valueof(true));
        pageRef.getParameters().put('selectionchecked',string.valueof(true));
        pageRef.getParameters().put('priceScheduleChecked',string.valueof(true));
        pageRef.getParameters().put('termsandConditionsChecked',string.valueof(true));
        pageRef.getParameters().put('generalTermsandconditionChecked',string.valueof(true));
        pageRef.getParameters().put('scopeOfSupplyChecked',string.valueof(true));
        pageRef.getParameters().put('checked',string.valueof(true));
        pageRef.getParameters().put('AboutTegaChecked',string.valueof(true));
        pageRef.getParameters().put('technicalSpecificationChecked',string.valueof(true));
        pageRef.getParameters().put('drawingChecked',string.valueof(true));
        pageRef.getParameters().put('simulationChecked',string.valueof(true));
        pageRef.getParameters().put('presentationChecked',string.valueof(true));
        pageRef.getParameters().put('annexureChecked',string.valueof(true));
        pageRef.getParameters().put('annexureChecked2',string.valueof(true));
        pageRef.getParameters().put('annexureChecked3',string.valueof(true));



        //OfferTemplateController OTC = new OfferTemplateController();
        combineOfferHeaderController COH = new combineOfferHeaderController();
        COH.save();
        COH.selectAllHandler();
        COH.cancel();
        
        
    
}

}