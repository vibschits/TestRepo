@IsTest(SeeAllData=false)
public class combinePdfControllerTest  {
    @testSetup static void setup() {    
        // Create test Opportunity records
        //  Id, Name, RecordType.Name, CurrencyIsoCode, CloseDate, StageName FROM Opportunity
        User user = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
         
        Sales_Region__c sales_region = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = user.Id);
        insert sales_region;
        Account account = new Account(Name = 'Test Account');
        insert account;
        system.debug('Account'+account);
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = sales_region.Id,Branch_Code__c = 'TBR');
        insert branch;
        Customer_Sales_Organization__c customer_sales_organization = new Customer_Sales_Organization__c(Customer__c = account.Id, Branch__c = branch.Id , CreatedFromAccount__c = true);
        insert customer_sales_organization;
        account.Status__c = 'Sync with SAP';
        update account;
        
        id  HydrocycloneRecordTypeId = Schema.SObjectType.Customer_Equipments__c.getRecordTypeInfosByDeveloperName().get('Hydrocyclone').getRecordTypeId();
        id  screenRecordTypeId = Schema.SObjectType.Customer_Equipments__c.getRecordTypeInfosByDeveloperName().get('Screen').getRecordTypeId();
        id offerRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer').getRecordTypeId();
        id  nonSpareOfferRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer_Non_Spare').getRecordTypeId();
        
        id  millRecordTypeId = Schema.SObjectType.Customer_Equipments__c.getRecordTypeInfosByDeveloperName().get('Mill').getRecordTypeId();
        id  tromellRecordTypeId = Schema.SObjectType.Customer_Equipments__c.getRecordTypeInfosByDeveloperName().get('Trommel').getRecordTypeId();
        id ConveyerRecordTypeId = Schema.SObjectType.Customer_Equipments__c.getRecordTypeInfosByDeveloperName().get('Conveyor_Component').getRecordTypeId();
		
        List<Customer_Equipments__c> custEquipList = new List<Customer_Equipments__c>();
        
        List<RecordType> equipRecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Customer_Equipments__c'];
        List<RecordType> opportunityRecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Opportunity'];
        List<RecordType> operatingParamRecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Operating_Parameters__c'];
        List<RecordType> prfRecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Proposal_Form__c'];
        
        Map<Id,String> equipRecordTypeMap = new Map<Id,String>();
        Map<Id,String> opportunityRecordTypeMap = new Map<Id,String>();
        Map<Id,String> operatingParamRecordTypeMap = new Map<Id,String>();
        Map<Id,String> prfRecordTypeMap = new Map<Id,String>();
        
        for(RecordType recType : equipRecordTypeList){
            equipRecordTypeMap.put(recType.Id, recType.DeveloperName);
        }
        
        for(RecordType recType : opportunityRecordTypeList){
            opportunityRecordTypeMap.put(recType.Id, recType.DeveloperName);
        }
        
        for(RecordType recType : operatingParamRecordTypeList){
            operatingParamRecordTypeMap.put(recType.Id, recType.DeveloperName);
        }
        
        for(RecordType recType : prfRecordTypeList){
            prfRecordTypeMap.put(recType.Id, recType.DeveloperName);
        }
        
        
        for(RecordType recType : equipRecordTypeList){
            Customer_Equipments__c custEquip = new Customer_Equipments__c();
            custEquip.CurrencyIsoCode = 'EUR';
            custEquip.Customer__c = account.id;
            custEquip.Recordtypeid = recType.Id;
            custEquipList.add(custEquip);
        }
        
        insert custEquipList;
        system.debug('custEquipList =>'+custEquipList);
        
        Map<String,Id> custEquipRecTypeMap = new Map<String,Id>();
        
        for(Customer_Equipments__c custEquip : custEquipList){
            system.debug('custEquip =>'+custEquip);
            String devName = equipRecordTypeMap.get(custEquip.RecordTypeId);
            custEquipRecTypeMap.put(devName, custEquip.id);
        }
        system.debug('custEquipRecTypeMap =>'+custEquipRecTypeMap);
        
        /*Customer_Equipments__c customer_equipments = new Customer_Equipments__c(
            CurrencyIsoCode = 'EUR',
            Circuit_diagram_available__c = false,
            Dia_m__c = 123.0,
            Mill_Type__c = 'SAG Mill',
            Tag__c = 'Hydro',
            Type_of_Discharge__c = 'Grate',
            Customer__c = account.id,
            Recordtypeid = HydrocycloneRecordTypeId);
        insert customer_equipments;
        
        Customer_Equipments__c customer_equipment = new Customer_Equipments__c(
            CurrencyIsoCode = 'EUR',
            Circuit_diagram_available__c = false,
            Dia_m__c = 123.0,
            Mill_Type__c = 'SAG Mill',
            Tag__c = 'Screen',
            Type_of_Discharge__c = 'Grate',
            Customer__c = account.id,
            Recordtypeid = screenRecordTypeId);
            //Recordtypeid = '012Bl0000000H46IAE');
        insert customer_equipment;
        
           Customer_Equipments__c customer_equipmentTwo = new Customer_Equipments__c(
            CurrencyIsoCode = 'EUR',
            Circuit_diagram_available__c = false,
            Dia_m__c = 123.0,
            Mill_Type__c = 'SAG Mill',
            Tag__c = 'XYZ',
            Type_of_Discharge__c = 'Grate',
            Customer__c = account.id,
            Recordtypeid = millRecordTypeId);
            //Recordtypeid = '012Bl0000000H46IAE');
        insert customer_equipmentTwo;*/
        
        // Way-1 using List and for
       /* for(Customer_Equipments__c custEquip : custEquipList){
            if(custEquip.Recordtype.name == 'Hydrocyclone'){
                Design_Parameter__c DesignParam = new Design_Parameter__c(customer_equipment__c = custEquip.id);
                insert DesignParam;
            }
        }*/
        
        // Way-2 using Map
        Design_Parameter__c DesignParamOne = new Design_Parameter__c(Customer_Equipment__c = custEquipRecTypeMap.get('Hydrocyclone'));
        insert DesignParamOne;
         Design_Parameter__c MillDesignParam = new Design_Parameter__c(Customer_Equipment__c = custEquipRecTypeMap.get('Mill'));
        insert MillDesignParam;
         Design_Parameter__c ScreenDesignParam = new Design_Parameter__c(Customer_Equipment__c = custEquipRecTypeMap.get('Screen'));
        insert ScreenDesignParam;
        
        //Customer_Sales_Organization__c customer_sales_organization = [Select Id from Customer_Sales_Organization__c where Branch__r.Name = 'Test Branch'];
        //Branch__c branch =[SELECT id from Branch__c WHERE name = 'Test Branch'];
        Pricebook2 pricebook2 = new Pricebook2(
            Name = 'Standard Price Book',
            CurrencyIsoCode = 'USD',
            IsActive = true);
        insert pricebook2;
        
        // User user = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        
        
        
        
        List<Opportunity> OpportunityList = new List<Opportunity>();
        
        List<RecordType> OppRecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Opportunity'];
        
        for(RecordType OpprecType : OppRecordTypeList){
            Opportunity OppRec = new Opportunity();
            OppRec.status__c = 'closed';
            OppRec.Customer_Branch_Assignment__c   = customer_sales_organization.id;
            OppRec.AccountId = account.id;
            OppRec.Recordtypeid = OpprecType.Id;
            OppRec.Stagename='closed won';
            OppRec.CloseDate = Date.newInstance(2022,07,21);
            OppRec.Name = 'Opp' + OpprecType.Name;
            OpportunityList.add(OppRec);
            
        }
        
        insert OpportunityList;
        
        Map<String,Id> OppRecTypeMap = new Map<String,Id>();
        
        for(Opportunity OpprecType : OpportunityList){
            String devName = opportunityRecordTypeMap.get(OpprecType.RecordTypeId);
            OppRecTypeMap.put(devName, OpprecType.id);
            //OppRecTypeMap.put(OpprecType.Recordtype.name, OpprecType.id);
        }
        system.debug('OppRecTypeMap =>'+OppRecTypeMap);
             
         
       /* RecordType MillRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
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
            RecordTypeId =MillRecType.id,
            OwnerId = user.id
            
        );
        insert opportunity;
        
        RecordType HydrocycloneRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Hydrocyclone'];
        Opportunity HydroOpportunity = new Opportunity(
            AccountId = account.id,
            Name = 'Test AK OPP 6 Jul',
            Customer_Branch_Assignment__c   = customer_sales_organization.id,
            status__c = 'closed',
            Probability = 100.0,
            CloseDate = Date.newInstance(2022,07,21),
            ForecastCategoryName = 'Closed',
            CurrencyIsoCode = 'USD',
            stagename='closed won',
            RecordTypeId =HydrocycloneRecType.id,
            OwnerId = user.id
            
        );
        insert HydroOpportunity;
        
        
        RecordType ScreenRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Screen'];
        Opportunity Screenopportunity = new Opportunity(
            AccountId = account.id,
            Name = 'Test AK OPP 6 Jul',
            Customer_Branch_Assignment__c   = customer_sales_organization.id,
            status__c = 'closed',
            Probability = 100.0,
            CloseDate = Date.newInstance(2022,07,21),
            ForecastCategoryName = 'Closed',
            CurrencyIsoCode = 'USD',
            stagename='closed won',
            RecordTypeId =ScreenRecType.id,
            OwnerId = user.id
            
        );
        insert Screenopportunity;
        */
       
        /* Customer_Equipments__c customer_equipments = [SELECT id, name from Customer_Equipments__c WHERE tag__c = 'XYZ' ];
        Customer_Equipments__c Hydrocustomer_equipment = [SELECT id,Name,Recordtype.name from Customer_Equipments__c WHERE Recordtype.name = 'Hydrocyclone'];
        Customer_Equipments__c Screencustomer_equipment = [SELECT id, name from Customer_Equipments__c WHERE tag__c = 'Screen' ];
*/
        
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
        
        List<Operating_Parameters__c> OPRList = new List<Operating_Parameters__c>();
        
        List<RecordType> OPRRecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Operating_Parameters__c'];
        
        for(RecordType OprRecType : OPRRecordTypeList){
            Operating_Parameters__c OprRec = new Operating_Parameters__c();
            OprRec.customer__c = account.id;
            OprRec.Customer_Equipment__c = custEquipRecTypeMap.get(OprRecType.DeveloperName);
            OprRec.Status__c = 'Current';
            OprRec.Recordtypeid = OprRecType.Id;
            OPRList.add(OprRec);
        }
        
        insert OPRList;
        
        
        Map<String,Id> OprRecTypeMap = new Map<String,Id>();
        
        for(Operating_Parameters__c OprRecType : OPRList){
            String devName = operatingParamRecordTypeMap.get(OprRecType.RecordTypeId);
            OprRecTypeMap.put(devName, OprRecType.id);
        }
             
		system.debug('OpERTINGRecTypeMap =>'+OprRecTypeMap);
        
       /*RecordType OPMillRecType = [Select Id,Name From RecordType  Where SobjectType = 'Operating_Parameters__c' and DeveloperName = 'Mill'];
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
            Recordtypeid = OPMillRecType.id);
        insert operating_parameters;
        
        RecordType OPHydroRecType = [Select Id,Name From RecordType  Where SobjectType = 'Operating_Parameters__c' and DeveloperName = 'Hydrocyclone'];
        Operating_Parameters__c HydroOperating_parameters = new Operating_Parameters__c(
            CurrencyIsoCode = 'USD',
            Bulk_Density_t_m3__c = 10.0,
            Circuit_diagram_available__c = false,
            Customer_Equipment__c = Hydrocustomer_equipment.id,
            Silica_Content__c = 20.0,
            Status__c = 'Current',
            Moisture__c = 30.0,
            Ore__c = 'Betonite, 100 mesh',
            Shape_of_Particles__c = 'Round',
            customer__c = account.id,
            Recordtypeid = OPHydroRecType.id);
        insert HydroOperating_parameters;
        
        RecordType OPScreenRecType = [Select Id,Name From RecordType  Where SobjectType = 'Operating_Parameters__c' and DeveloperName = 'Screen'];
        Operating_Parameters__c Screenoperating_parameters = new Operating_Parameters__c(
            CurrencyIsoCode = 'USD',
            Bulk_Density_t_m3__c = 10.0,
            Circuit_diagram_available__c = false,
            Customer_Equipment__c = Screencustomer_equipment.id,
            Silica_Content__c = 20.0,
            Status__c = 'Current',
            Moisture__c = 30.0,
            Ore__c = 'Betonite, 100 mesh',
            Shape_of_Particles__c = 'Round',
            customer__c = account.id,
            Recordtypeid = OPScreenRecType.id);
        insert Screenoperating_parameters;
*/
         List<Proposal_Form__c> PRFList = new List<Proposal_Form__c>();
        
        List<RecordType> PRFecordTypeList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType  = 'Proposal_Form__c'];
        
        for(RecordType PrfRecType : PRFecordTypeList){
                Proposal_Form__c PrfRec = new Proposal_Form__c();
                PrfRec.CurrencyIsoCode = 'EUR';
                PrfRec.Customer_Equipment__c =custEquipRecTypeMap.get(PrfRecType.DeveloperName );
                PrfRec.Opportunity__c = OppRecTypeMap.get(PrfRecType.DeveloperName);
                PrfRec.Status__c = 'Closed';
                PrfRec.Operating_Parameters__c = OprRecTypeMap.get(PrfRecType.DeveloperName );
                PrfRec.Recordtypeid = PrfRecType.Id;
                system.debug(PrfRec);
                PRFList.add(PrfRec);
        }
        
        insert PRFList;
        
        Map<String,Id> PrfRecTypeMap = new Map<String,Id>();
        
        for(Proposal_Form__c PrfRecType : PRFList){
            String devName = prfRecordTypeMap.get(PrfRecType.RecordTypeId);
            PrfRecTypeMap.put(devName, PrfRecType.id);
        }
        
     /* RecordType PrfMillRecType = [Select Id,Name From RecordType  Where SobjectType = 'Proposal_Form__c' and DeveloperName = 'Mill'];
        Proposal_Form__c proposal_form = new Proposal_Form__c(
            CurrencyIsoCode = 'EUR',
            Customer_Equipment__c = customer_equipments.id,
            Opportunity__c = opportunity.id,
            Conversion__c = 'Converted potential',
            Conversion_sub_type__c = 'Application conversion',
            Spares__c = 'Spares Without Modification',
            Type__c = 'Conversion',
            Status__c = 'closed',
            Recordtypeid = PrfMillRecType.id,
            Operating_Parameters__c= operating_parameters.id
            //Design_Parameter__c = DesignParam.id
        );
        insert proposal_form;
        
         RecordType PrfHydroRecType = [Select Id,Name From RecordType  Where SobjectType = 'Proposal_Form__c' and DeveloperName = 'Hydrocyclone'];
        Proposal_Form__c Hydroproposal_form = new Proposal_Form__c(
            CurrencyIsoCode = 'EUR',
            Customer_Equipment__c = Hydrocustomer_equipment.id,
            Opportunity__c = HydroOpportunity.id,
            Conversion__c = 'Converted potential',
            Conversion_sub_type__c = 'Application conversion',
            Spares__c = 'Spares Without Modification',
            Type__c = 'Conversion',
            Status__c = 'closed',
            Recordtypeid = PrfHydroRecType.id,
            Operating_Parameters__c= operating_parameters.id
            //Design_Parameter__c = DesignParam.id
        );
        insert Hydroproposal_form;
        
         RecordType PrfScreenRecType = [Select Id,Name From RecordType  Where SobjectType = 'Proposal_Form__c' and DeveloperName = 'Screen'];
        Proposal_Form__c ScreenProposal_form = new Proposal_Form__c(
            CurrencyIsoCode = 'EUR',
            Customer_Equipment__c = Screencustomer_equipment.id,
            Opportunity__c = Screenopportunity.id,
            Conversion__c = 'Converted potential',
            Conversion_sub_type__c = 'Application conversion',
            Spares__c = 'Spares Without Modification',
            Type__c = 'Conversion',
            Status__c = 'closed',
            Recordtypeid = PrfScreenRecType.id,
            Operating_Parameters__c= operating_parameters.id
            //Design_Parameter__c = DesignParam.id
        );
        insert ScreenProposal_form;
*/
        
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
        
        Product2 product3 = new Product2(
            Name = 'PLM-03960-03-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = false,
            CurrencyIsoCode = 'USD',
            Part_List__c = part_list.id,
            Product_Level__c = 'L2',
            Quantity__c = 1.0);
        insert product3;
        
        Product2 product4 = new Product2(
            Name = 'PLM-03960-04-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = false,
            CurrencyIsoCode = 'USD',
            Part_List__c = part_list.id,
            Product_Level__c = 'L2',
            Quantity__c = 1.0);
        insert product4;
        
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
            OpportunityId = OppRecTypeMap.get('Mill'),
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
            Opportunity_Equipments__c = PrfRecTypeMap.get('Mill'),
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
        
        Quote quote1 = new Quote(
            Name = 'Test offer',
            CurrencyIsoCode = 'EUR',
            OpportunityId = OppRecTypeMap.get('Hydrocyclone'),
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
            RecordTypeId =  offerRecordTypeId,
            Approval_Status__c = 'Delivery SLA Accepted',
            BTP_Type__c = 'CIF',
            Branch__c = branch.id,
            Delivery_Schedule__c = 12.0,
            Opportunity_Equipments__c = PrfRecTypeMap.get('Hydrocyclone'),
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
            Parent_Offer__c=quote.id,
            Company_Branch_Assignment__c = customer_sales_organization.id);
        
        insert quote1; 
        
        
        Quote quote2 = new Quote(
            Name = 'Test offer2',
            CurrencyIsoCode = 'EUR',
            OpportunityId = OppRecTypeMap.get('Screen'),
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
            Opportunity_Equipments__c = PrfRecTypeMap.get('Screen'),
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
            Parent_Offer__c=quote.id,
            Company_Branch_Assignment__c = customer_sales_organization.id);
        
        insert quote2; 
        
        
         
        
        PricebookEntry pb2 = new PricebookEntry(Product2id =product2.Id,UnitPrice = 121, IsActive = true,PriceBook2Id = Test.getStandardPricebookId());
        insert pb2;
        PricebookEntry pb3 = new PricebookEntry(Product2id =product3.Id,UnitPrice = 121, IsActive = true,PriceBook2Id = Test.getStandardPricebookId());
        insert pb3;
        PricebookEntry pb4 = new PricebookEntry(Product2id =product4.Id,UnitPrice = 121, IsActive = true,PriceBook2Id = Test.getStandardPricebookId());
        insert pb4;
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
        
        QuoteLineItem quotelineitem2 = new QuoteLineItem(
            Quantity = 3.0,
            UnitPrice = 217.5,
            Discount = 0.0,
            Margin__c = 0.0,
            BTP_Price__c = 217.5,
            QuoteId =quote1.id,
            Product2Id =product2.id,
            PricebookEntryid = pb3.id);
        insert quotelineitem2;
        
        QuoteLineItem quotelineitem3 = new QuoteLineItem(
            Quantity = 3.0,
            UnitPrice = 217.5,
            Discount = 0.0,
            Margin__c = 0.0,
            BTP_Price__c = 217.5,
            QuoteId =quote2.id,
            Product2Id =product2.id,
            PricebookEntryid = pb4.id);
        insert quotelineitem3;
    
    }

    private static testMethod void Combineoffergeneratepdf(){
        
        id offerRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer').getRecordTypeId();
        id  nonSpareOfferRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer_Non_Spare').getRecordTypeId();
        
        Account account = [Select Id,Name,Status__c from Account where Name = 'Test Account'];
        
       Quote offer = [Select Id,Name,RecordTypeId from Quote where Name = 'Test Nikhil offer'];
        PageReference pageRef = Page.Combine_Offer_PDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('checked',string.valueof(true));
        // pageRef.getParameters().put('IntroductionChecked',true);
        pageRef.getParameters().put('selectedofferid',string.valueof(offer.id));
        pageRef.getParameters().put('IntroductionChecked',string.valueof(true));
        pageRef.getParameters().put('OperatingParamatersChecked',string.valueof(true));
        pageRef.getParameters().put('selectionchecked',string.valueof(true));
        pageRef.getParameters().put('priceScheduleChecked',string.valueof(TRUE));
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
        
		ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        combinePdfController OTC1 = new combinePdfController(sc);
      //  OTC1.priceScheduleChecked=TRUE;
        
    }


}