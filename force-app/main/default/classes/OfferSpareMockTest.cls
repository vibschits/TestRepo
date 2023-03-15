@istest(SeeAllData=false) 
public class OfferSpareMockTest {
    
    @testSetup static void setup() {    
        // Create test Opportunity records
        //  Id, Name, RecordType.Name, CurrencyIsoCode, CloseDate, StageName FROM Opportunity
        // User user = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        
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
        //   Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = lstUsers[0].Id);
        Sales_Region__c sales_region = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = lstUsers[0].Id);  
        insert sales_region;
        Account account = new Account(Name = 'Test Account');
        insert account;
        system.debug('Account'+account);
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = sales_region.Id,Branch_Code__c = 'TBR');
        insert branch;
        Customer_Sales_Organization__c customer_sales_organization = new Customer_Sales_Organization__c(CreatedFromAccount__c = true,Customer__c = account.Id, Branch__c = branch.Id);
        insert customer_sales_organization;
        account.Status__c = 'Sync with SAP';
        update account;
        
        
    }
    private static testMethod void sapofferid(){
        Test.setMock(WebServiceMock.class, new offerSpareMock());
        
        Account account = [Select Id,Name,Status__c from Account where Name = 'Test Account'];
        Customer_Sales_Organization__c customer_sales_organization = [Select Id from Customer_Sales_Organization__c where Branch__r.Name = 'Test Branch'];
        Branch__c branch =[SELECT id from Branch__c WHERE name = 'Test Branch'];
        Pricebook2 pricebook2 = new Pricebook2(
            Name = 'Standard Price Book',
            CurrencyIsoCode = 'USD',
            IsActive = true);
        insert pricebook2;
        
        /*   PricebookEntry pricebookentry = new PricebookEntry(
UnitPrice = 112.944,
IsActive = true,
UseStandardPrice = false);
insert pricebookentry;*/
        
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
            //   Pricebook2Id = pricebook2.id,
            IsExcludedFromTerritory2Filter = false,
            Budget_Confirmed__c = false,
            ROI_Analysis_Completed__c = false,
            //ABG_PBG_if_applicable__c = 'Applicable',
            //Delivery_Terms__c = 'FCA',
            //Dispatch_Mode__c = 'FCL (Sea)',
            Drawings__c = false
            //Guarantee_Warranty_Terms_if_applicable__c = 'Applicable',
            //Packing_Forwarding__c = 'Included in price',
            //Payment_Terms__c = '100% due in Immediately',
            //Tax_Duty_if_applicable__c = 'Included in price'
        );
        insert opportunity;
        
        Customer_Equipments__c customer_equipments = new Customer_Equipments__c(
            CurrencyIsoCode = 'EUR',
            Circuit_diagram_available__c = false,
            Dia_m__c = 123.0,
            // Equipment_Type__c = 'Mill Chute',
            Has_GA_Drawing_Cyclone_file_uploaded__c = false,
            Has_GA_drawing_cluster_file_uploaded__c = false,
            Length_m__c = 123.0,
            Link_adjacent_equipment_Stream__c = 'None',
            Mill_Liner_Handler_Capacity__c = false,
            Mill_Type_Stage__c = 'SBM',
            Mill_Type__c = 'SAG Mill',
            Tag__c = 'Test AK Mill 6 Jul',
            Type_of_Discharge__c = 'Grate',
            Has_BU_Frame_Drawing_Attached__c = false,
            Has_Panel_Drawing_Sketch_attached__c = false,
            Has_Panel_Drawing_attached__c = false,
            Has_Plant_Flowsheet_Attached__c = false,
            Has_SF_bar_with_fixing_holes_attached__c = false,
            Has_Screen_Drawing_Attached__c = false,
            Has_bucker_up_frame_details_attached__c = false,
            Has_layout_of_screen_panels_attached__c = false,
            Spiral__c = false,
            Customer__c = account.id);
        insert customer_equipments;
        operating_parameters__c opParam = new operating_parameters__c(customer__c= account.id,ore__c='aggregate');
        insert opParam;
        
        Proposal_Form__c proposal_form = new Proposal_Form__c(
            CurrencyIsoCode = 'EUR',
            Customer_Equipment__c = customer_equipments.id,
            Opportunity__c = opportunity.id,
            Conversion__c = 'Converted potential',
            Conversion_sub_type__c = 'Application conversion',
            Spares__c = 'Spares Without Modification',
            Type__c = 'Conversion',
            Status__c = 'closed',
            Actual_Response_Time_Days__c = 2.0,
            //Backing_plate__c = false,
            Ball_trajectory__c = false,
            Consignment_Stock_Agreement__c = false,
            Energy_Spectrum_Analysis__c = false,
            Equipment_Drawing__c = false,
            Graphic_Force_on_L_B__c = false,
            Life_Expectation_Study_Analysis_Estimate__c = false,
            Offer_Type__c = 'Budgetary Offer',
            Price_variation_clause__c = false,
            Reference_list__c = false,
            SLA_Triggered__c = false,
            //Serrated_Clamp__c = false,
            Warranty__c = false,
            Regret__c = true,
            Revision_No__c = 1.0,
            Operating_Parameters__c= opParam.id);
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
            Version_Number_Component__c = 'C',
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
        //   PricebookEntry pricebookentry = new PricebookEntry(Product2id =product2.Id,UnitPrice = 121, IsActive = true,PriceBook2Id = Test.getStandardPricebookId());
        //  insert pricebookentry;
        
        
        Contact contact = new Contact(
            AccountId = account.id,
            LastName = 'Test Contack AK 6 Jul',
            Email = 'kandikatla.nikhil@gmail.com',
            CurrencyIsoCode = 'EUR',
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
            //  Pricebook2Id = pricebook2.id,
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
        
        
        
        Integration_Transaction__c it = new Integration_Transaction__c(
            Record_Id__c = quote.id ,
            Operation__c = 'Create Offer Spare'
        );
        insert it;
        
        offerSpare.requestSapOfferId(quote.id, it.Id);
        SendToSapController.OfferSendToSap(quote.id);
        try{
            SendToSapController.OfferSendToSap(it.id);
        }
        catch(Exception e){
            
        }
        
        
    }
    
}