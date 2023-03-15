public with sharing class CompilePdfController {
    
    public Boolean checked{get;set;}
    public Boolean IntroductionChecked{get;set;}
    public Boolean AboutTegaChecked{get;set;}
    public Boolean OperatingParamatersChecked{get;set;}
    public Boolean scopeOfSupplyChecked{get;set;}
    public Boolean technicalSpecificationChecked{get;set;}
    public Boolean selectionChecked{get;set;}
    public Boolean drawingChecked{get;set;}
    public Boolean simulationChecked{get;set;}
    public Boolean presentationChecked{get;set;}
    public Boolean priceScheduleChecked{get;set;}
    public Boolean annexureChecked{get;set;}
    public Boolean annexureChecked2{get;set;}
    public Boolean annexureChecked3{get;set;}
    public Boolean termsandConditionsChecked{get;set;}
    public Boolean generalTermsandconditionChecked{get;set;}
    public Boolean isPartlistSame {get; set;}
    public string selectedofferid{get;set;}
    public string opportunityRecType{get;set;}
    public List<string> lstFields{get; set;}
    public List<String> AllLabels{get;set;}
    public list<string> allfieldlabels{get;set;}
    public Map<string,Map<string,object>> fieldlablemap{get;set;}
    public Map<string,Map<string,object>> designfieldlablemap{get;set;}
    
    public list<Map<string,object>> combinelistmap{get;set;}
    public list<Map<string,object>> Designcombinelistmap{get;set;}
    public Quote offer{get;set;}
    public string Dia{get;set;}
    public String FileName{get;set;}
    Id offerId;
    public List<QuoteLineItem> offerlineitems{get;set;}
    public Account account{get;set;}
    public List<Operating_Parameters__c> operatingParam{get;set;}
    public List<Design_Parameter__c> designParams{get;set;}
    public List<Operating_Parameters__c>  operatingparameters{get;set;}
    public List<Operating_Parameters__c> OperatingParamList{get;set;}
    public Proposal_Form__c record{get;set;}
    public Offer_Template__c offerTemplate{get;set;}
    public List<Design_Parameter__c> designParam{get;set;}
    public List<Scope_With_Selection__c> selectionitemlist{get;set;}
    public List<L1_L2_Offer_Line_Item__c> L1l2offerLines{get;set;}
    public user u{get;set;}
    public String currentUser {get;set;}
    public String TitleFromOT {get;set;}
    public String TitleFromOT1 {get;set;}
    public String Operatingquery{get;set;}
    public String designquery{get;set;}
    public String CreatedDate{get;set;}
    public list<quote> compileoffer{get;set;}
    //public list<Quote> childOffersOnCombine {get; set;}
    //public List<Quote> QuoteList {get;set;}
    //public List<Wrapper> wrapperList {get; set;}
    //Map <Id, Quote> offerMap{get; set;}
    //List <QuoteLineItem> quoteLineList {get; set;}
    public List<Quote> partlist {get; set;}
    public List<Quote> quotelt{get; set;}
    public List<Quote> combineOfferRecType{get; set;}
    public List<Quote> compileOfferRecType{get; set;}

    
    // public Id combineRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('combine').getRecordTypeId();
    // Id compileRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Compile').getRecordTypeId();
    public Id offerRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer').getRecordTypeId();
    public Id nonSpareOfferRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer_Non_Spare').getRecordTypeId();
    
    
        public CompilePdfController(ApexPages.StandardController controller) {

        }

        public CompilePdfController( ){
            offerId = ApexPages.currentPage().getParameters().get('selectedofferid');
            system.debug('OfferTemplateController offer id-----'+offerId);
            this.checked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('checked'));
            this.IntroductionChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IntroductionChecked'));
            this.AboutTegaChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('AboutTegaChecked'));
            this.OperatingParamatersChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('OperatingParamatersChecked'));
            this.scopeOfSupplyChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('scopeOfSupplyChecked'));
            this.technicalSpecificationChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('technicalSpecificationChecked'));
            this.selectionChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('selectionChecked'));
            this.drawingChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('drawingChecked'));
            this.simulationChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('simulationChecked'));
            this.presentationChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('presentationChecked'));
            this.priceScheduleChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('priceScheduleChecked'));
            this.termsandConditionsChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('termsandConditionsChecked'));
            this.generalTermsandconditionChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('generalTermsandconditionChecked'));
            this.annexureChecked = Boolean.valueOf(ApexPages.currentPage().getParameters().get('annexureChecked'));
            this.annexureChecked2 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('annexureChecked2'));
            this.annexureChecked3 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('annexureChecked3'));
            this.currentUser = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            //this.isPartlistSame = Boolean.valueOf(ApexPages.currentPage().getParameters().get('Is_Partlist_Same__c'));
            
                Try{

                //SK
                System.debug('$OfferID :'+offerId);
                //wrapperList = new List<wrapper>();
                
                /*Map <Id, Quote> offerMap = new Map<Id, Quote >();
                    For(Quote objQuote : [SELECT Id, Name From Quote WHERE Id =: offerId]) {
                        offerMap.put(objQuote.Id, objQuote);
                        System.debug('OfferMap:'+offerMap);
                    }

                    List <QuoteLineItem> quoteLineList = new List<QuoteLineItem>();
                    For (QuoteLineItem Qli: [SELECT Id, QuoteId, Description, Quantity, UnitPrice, Combined_Quantity__c, TotalPrice FROM QuoteLineItem WHERE QuoteId IN: offerMap.Keyset()]){
                        quoteLineList.add(Qli);
                        System.debug('quoteLineList:'+quoteLineList);
                    }*/
                

                offer = [SELECT id,Name,Branch__c,Incoterm_City__c,OpportunityId,Selection__c,Drawing__c,
                         Simulations__c,Presentation__c,Technical_Specification__c,TotalPrice,GrandTotal,
                         Offer_Template__r.Annexure__c, Offer_Template__r.Annexure_2__c, Offer_Template__r.Annexure_3__c,
                         Company__r.name,Offer_Generation_at__c,createddate, RecordType.Name,QuoteNumber, Start_Date__c,
                         Delivery_Date__c, Opportunity_Equipments__r.Customer_Equipment__r.Dia_m__c,
                         Opportunity_Equipments__r.Equipment_Record_Type__c,BTP_Type__c,Opportunity_Equipments__r.Total_Price_Quoted__c,
                         Enquiry_Number__c,Email,Phone,Notes__c,CurrencyIsoCode,Opportunity_Equipments__r.Customer_Equipment__r.Equipment_Type__c,
                         Opportunity_Equipments__r.Design_Parameter__r.name,Opportunity_Equipments__r.Customer_Equipment__c,
                         Opportunity_Equipments__r.Operating_Parameters__c,Opportunity_Equipments__r.Operating_Parameters__r.name,
                         Opportunity_Equipments__r.Customer_Equipment__r.Length_m__c, Account.BillingCity,
                         Account.Billingcountry,RecordType.DeveloperName,Account.BillingpostalCode,Account.Billingstate,
                         Account.Billingstreet,Account.Name,Contact.name,Opportunity.Owner.Name,Branch__r.Name,
                         Account.Regional_Manager__r.name,Is_Partlist_Same__c,Part_List__r.Name,
                         Offer_Template__r.Special_Clause__c,Offer_Template__r.About_Tega__c,
                         Offer_Template__r.Tega_Image_Logo__c, Offer_Template__r.General_Terms_and_Conditions__c,
                         Offer_Template__r.General_T_C_2__c, Offer_Template__r.General_T_C_3__c, Offer_Template__r.General_T_C_4__c,
                         Offer_Template__r.General_T_C_5__c, Offer_Template__r.General_T_C_6__c,  Offer_Template__r.EmailTest_c__c,
                         Offer_Template__r.Tega_Quality_Assurance_Program__c, Offer_Template__r.Email__c,  Offer_Template__r.Tega_Services__c,
                         Offer_Template__r.General_T_C_Footer__c, Opportunity_Equipments__r.Grand_Total__c FROM Quote WHERE id =: offerId];
                system.debug('========offer query===='+offer);
                
                offerTemplate = [SELECT Id,Name, About_Tega__c, EmailTest_c__c, Email__c, Extra_Hidden_Field_c__c, 
                                     General_T_C_2__c, General_T_C_3__c, General_T_C_4__c, General_T_C_5__c, 
                                     General_T_C_6__c, General_T_C_Footer__c, General_Terms_and_Conditions__c, 
                                     Offer__c, Operating_Parameters__c, Special_Clause__c, Tega_Image_Logo__c, 
                                     Tega_Quality_Assurance_Program__c, Tega_Services__c, Annexure__c,Annexure_2__c,Annexure_3__c,
                                     Template_Description__c, Logo__c, Introduction_Letter__c,Tag_Line__c, Mill_Title__c, 
                                      Hydrocyclone_Title__c, Screen_Title__c, Trommel_Title__c, Conveyor_Component_Title__c, 
                                     Wear_Component_Title__c,Confidential_Content__c
                                     FROM Offer_Template__c WHERE Id =: offer.Offer_Template__c];
                
                // Here we may write code for CC Product Sub-Type Inclusion. On VF Page also we need to conditionally render using these fields
                Opportunity opp = [select id, name, RecordType.Name from opportunity where id =: offer.OpportunityId];
                opportunityRecType = opp.RecordType.Name;
                
                String equipRecType = offer.Opportunity_Equipments__r.Equipment_Record_Type__c;
                
                if(equipRecType == 'Mill'){
                    TitleFromOT = offerTemplate.Mill_Title__c;
                }else if(equipRecType == 'Hydrocyclone'){
                    TitleFromOT = offerTemplate.Hydrocyclone_Title__c;
                }else if(equipRecType == 'Screen'){
                    TitleFromOT = offerTemplate.Screen_Title__c;
                }else if(equipRecType == 'Trommel'){
                    TitleFromOT = offerTemplate.Trommel_Title__c;
                }else if(equipRecType == 'Conveyor Component'){
                    TitleFromOT = offerTemplate.Conveyor_Component_Title__c;
                }else if(equipRecType == 'Wear Component'){
                    TitleFromOT = offerTemplate.Wear_Component_Title__c;
                }
                
                compileoffer = [SELECT id,Offer_Template__r.Annexure__c,TotalPrice,CurrencyIsoCode, name,
                                 Opportunity_Equipments__r.Operating_Parameters__r.Customer_Equipment__r.Equipment_Type__c,
                                 Opportunity_Equipments__r.Operating_Parameters__r.Customer_Equipment__r.Dia_m__c,
                                 Opportunity_Equipments__r.Operating_Parameters__r.id,Opportunity_Equipments__r.Name,
                                 Parent_Offer__c,Offer_Name__c,
                                 Opportunity_Equipments__r.Equipment_Record_Type__c,
                                 Opportunity_Equipments__r.Customer_Equipment__r.Equipment_Type__c,
                                Opportunity_Equipments__r.Operating_Parameters__r.Customer_Equipment__r.Length_m__c,Parent_Offer__r.name,
                                Opportunity_Equipments__r.Operating_Parameters__r.name, Opportunity_Equipments__r.Customer_Equipment__r.Dia_m__c,
                                Opportunity_Equipments__r.Customer_Equipment__r.Length_m__c,
                                Opportunity_Equipments__r.Design_Parameter__r.name from quote 
                                where Parent_Offer__c =: offerId and (Opportunity_Equipments__r.name = '' OR Opportunity_Equipments__r.name != '') ];
                system.debug('compileoffer Size===='+compileoffer.size()+'========compileoffer query===='+compileoffer);
               String FileName = offer.Account.Name+'-'+offer.QuoteNumber+'.PDF';
               Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' + FileName );

               compileOfferRecType =[SELECT id,Opportunity_Equipments__r.Equipment_Record_Type__c  FROM Quote where Parent_Offer__c =: offerId];
               
               String equipRecType1 = compileOfferRecType[0].Opportunity_Equipments__r.Equipment_Record_Type__c;
                
                if(equipRecType1 == 'Mill'){
                    TitleFromOT1 = offerTemplate.Mill_Title__c;
                }else if(equipRecType1 == 'Hydrocyclone'){
                    TitleFromOT1 = offerTemplate.Hydrocyclone_Title__c;
                }else if(equipRecType1 == 'Screen'){
                    TitleFromOT1 = offerTemplate.Screen_Title__c;
                }else if(equipRecType1 == 'Trommel'){
                    TitleFromOT1 = offerTemplate.Trommel_Title__c;
                }else if(equipRecType1 == 'Conveyor Component'){
                    TitleFromOT1 = offerTemplate.Conveyor_Component_Title__c;
                }else if(equipRecType1 == 'Wear Component'){
                    TitleFromOT1 = offerTemplate.Wear_Component_Title__c;
                }
              // Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+downloadingFileName );

    
                List<string> listopparam = new List<string>();
                List<string> listdesignParam = new List<string>();
    
                Map<string, quote> Operatingmap = new Map<string, quote>(); 
                For(quote q: compileoffer){
                    listopparam.add(q.Opportunity_Equipments__r.Operating_Parameters__r.id);
                    listdesignParam.add(q.Opportunity_Equipments__r.Design_Parameter__r.id);
    
                    system.debug('Operatingmap======'+Operatingmap);
                }
                
                
                u = [SELECT ID, Name, Designation__c FROM USER WHERE Name =:offer.Opportunity.Owner.Name];
                
                if(this.priceScheduleChecked == TRUE) {
                    partlist = [SELECT id, Is_Partlist_Same__c  FROM Quote where Parent_Offer__c =: offerId];
                    quotelt = [select Id,Name,QuoteNumber,Part_List__r.Name,Is_Partlist_Same__c,GrandTotal,(SELECT id,Description,Quantity,Combined_Quantity__c,UnitPrice,TotalPrice,Product2.Name,Product2ID,QuoteId FROM QuoteLineItems) from Quote where Parent_Offer__c =: offerId];

                    if(( offer.Offer_Generation_at__c  == 'L3')|| offer.Offer_Generation_at__c  == '' ||offer.Offer_Generation_at__c  == NULL){
                        offerlineitems = [SELECT id,Description,Quantity,Combined_Quantity__c,UnitPrice,TotalPrice,Product2.Name,Product2ID,QuoteId  FROM QuoteLineItem  WHERE QuoteId =:offerId ];
                        system.debug('offerlineitems------- Level 3'+offerlineitems);
                        
                    }else if(offer.Offer_Generation_at__c  == 'L2'){
                        L1l2offerLines =[ SELECT id, Quantity__c, Offer__r.name, Offer__c, Amount__c,Unit_price__c, Product_Description__c,RecordType.DeveloperName, CurrencyIsoCode FROM L1_L2_Offer_Line_Item__c  WHERE RecordType.DeveloperName = 'L2' AND  Offer__c =: offerId];
                        offerlineitems = [SELECT id,Description,Quantity,Combined_Quantity__c,UnitPrice,TotalPrice,Product2.Name, Product2ID,  QuoteId  FROM QuoteLineItem  WHERE QuoteId =:offerId AND L2_L3_Product__c = null];
                        system.debug('L1l2offerLines------------ Level 2'+L1l2offerLines);
                        
                    }
                    else if(offer.Offer_Generation_at__c  == 'L1'){
                        L1l2offerLines =[ SELECT id, Quantity__c, Offer__r.name, Offer__c, Amount__c,Unit_price__c, Product_Description__c,RecordType.DeveloperName, CurrencyIsoCode FROM L1_L2_Offer_Line_Item__c  WHERE RecordType.DeveloperName = 'L1' AND  Offer__c =: offerId];
                        offerlineitems = [SELECT id,Description,Quantity,Combined_Quantity__c,UnitPrice,TotalPrice,Product2.Name, Product2ID,QuoteId  FROM QuoteLineItem  WHERE QuoteId =:offerId AND L2_L3_Product__c = null];
                        system.debug('L1l2offerLines---------Level 1'+L1l2offerLines);
                        
                    }
                } 
                
                if(this.OperatingParamatersChecked == TRUE) {
                    list<Operating_Parameters__c>  OperatingParamList = new list<Operating_Parameters__c>();
                    String SobjectApiName = 'Operating_Parameters__c';
                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                    Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                    //fieldMap.put('Customer_Equipment__r.Equipment_Type__c',Customer_Equipment__r.Equipment_Type__c );
                    system.debug('fieldMap----------'+fieldMap);
                    String commaSepratedFields = '';
                    String EquipmentType = 'Customer_Equipment__r.Equipment_Type__c';
                    String Dia = 'Customer_Equipment__r.Dia_m__c';
                    String length = 'Customer_Equipment__r.Length_m__c';
    
                    for(String fieldName : fieldMap.keyset()){
                        if(commaSepratedFields == null || commaSepratedFields == ''){
                            commaSepratedFields = fieldName;
                        }else{
                            //  system.debug('fieldName--->'+fieldName);
                            if(fieldName != 'Createddate')
                                commaSepratedFields = commaSepratedFields + ',' + fieldName ;
                        }
                    }
                    
                    if(offer.RecordTypeId == offerRecordTypeId){
                        
                        Operatingquery = 'select ' + commaSepratedFields + ',' +  EquipmentType + ',' +  Dia + ',' +  length +' from Operating_Parameters__c WHERE Name =\''+ offer.Opportunity_Equipments__r.Operating_Parameters__r.name+'\' ';
                        system.debug('113 is executing'+Operatingquery);
                    }else if(offer.RecordTypeId == nonSpareOfferRecordTypeId){
                        Operatingquery = 'select ' + commaSepratedFields + ',' +  EquipmentType + ',' +  Dia + ',' +  length +' from Operating_Parameters__c WHERE Name =\''+ offer.Opportunity_Equipments__r.Operating_Parameters__r.name+'\' ';
                        system.debug('113 is executing'+Operatingquery);                    
                    }else if(offer.Recordtype.name == 'Compile') {
                        Operatingquery = 'select '  +  Dia + ',' +  length + ',' + commaSepratedFields +  ',' +  EquipmentType + ' from Operating_Parameters__c WHERE id IN :listopparam';
                        system.debug('Operatingmap.Keyset()============='+Operatingmap.Keyset());
                        // Operatingquery = 'select ' + commaSepratedFields + ' from Operating_Parameters__c WHERE Name IN : Operatingmap.Keyset()';
                        system.debug('Operatingquery---------'+Operatingquery);
                    }
                    //  Operatingquery = 'select ' + commaSepratedFields + ' from Operating_Parameters__c WHERE Customer_Equipment__c =\''+ offer.Opportunity_Equipments__r.Customer_Equipment__c+'\'order by LastModifiedDate  DESC  ';
                    system.debug('query'+Operatingquery);
                    list<string> allfieldlabels = new List<string>(); 
                    fieldlablemap = new Map<string, Map<string,object>>();
                    system.debug('fieldlablemap'+fieldlablemap);
                    map<string,object> objfieldmap = new map<string,object>();
                    combinelistmap = new list<Map<string,Object>>();
                    operatingParam = Database.query(Operatingquery);
                    system.debug('operatingParam----'+operatingParam.size());
                    
                    if(operatingParam.size() > 0) {
                        for(Operating_Parameters__c operating : operatingParam) {
                            String equipmentTypeValue = (String)operating.getSObject('Customer_Equipment__r').get('Equipment_Type__c');
                            string diaValue = string.valueOf((Decimal)operating.getSObject('Customer_Equipment__r').get('Dia_m__c'));
                            String lenghtValue = string.valueOf((Decimal)operating.getSObject('Customer_Equipment__r').get('Length_m__c'));
    
                            system.debug('diaValue---'+diaValue );
                            system.debug('operatingParam---'+operatingParam);
                            system.debug('operating---'+operating);
                            if(operating != NULL){
                                for(string field : fieldMap.Keyset()){
                                    string fieldlabel = fieldMap.get(field).getDescribe().getLabel();
                                    if(field != 'Createddate') 
                                       if( field != 'CreatedById')
                                        if( field != 'LastModifiedDate')
                                        if( field != 'LastModifiedById')
                                        if( field != 'LastViewedDate')
                                        if( field != 'SystemModstamp')
                                        if( field != 'LastReferencedDate')
                                        if( field != 'ID')
                                        if( field != 'recordtypeid')
                                        if( field != 'Customer_Equipment__c')
                                        if( field != 'customer__c')
                                        if( field != 'IsDeleted')
                                        if( field != 'CurrencyIsoCode')
    
    
                                        if(operating.get(field) != NUll){
                                            IF(!fieldlablemap.containsKey(operating.Id)) {
                                                fieldlablemap.put(operating.id, new Map<string, object>());
                                            }
                                            If(field == 'Circuit_diagram_available__c') {
                                                if(operating.Circuit_diagram_available__c==false ){
                                                    fieldlablemap.get(operating.id).put(fieldlabel, 'NO'); 
                                                }
                                                else{
                                                    fieldlablemap.get(operating.id).put(fieldlabel, 'YES'); 
                                                }                                       
                                            }
                                            else{
                                                fieldlablemap.get(operating.id).put(fieldlabel, operating.get(field)); 
                                                fieldlablemap.get(operating.id).put('Equipment Type', equipmentTypeValue); 
                                                fieldlablemap.get(operating.id).put('Dia (m)', diaValue); 
                                                fieldlablemap.get(operating.id).put('Length (m)', lenghtValue); 
                                            }
                                        }
                                    allfieldlabels.add(fieldlabel);
                                    system.debug('allfieldlabels========='+allfieldlabels);
                                }
                                
                                combinelistmap.add(fieldlablemap);
                                system.debug('combinelistmap========='+combinelistmap.size()+'---------operating---65'+combinelistmap );
                                OperatingParamList.add(operating);
                                system.debug('OperatingParamListsize-------67'+OperatingParamList.size()+'--------OperatingParamList-------67'+OperatingParamList);
                                
                            }
                        }
                    } 
                    
                    list<Design_Parameter__c>  designParamList = new list<Design_Parameter__c>();
                    String SobjectDesignparameterApiName = 'Design_Parameter__c';
                    Map<String, Schema.SObjectType> DesignschemaMap = Schema.getGlobalDescribe();
                    Map<String, Schema.SObjectField> designfieldMap = DesignschemaMap.get(SobjectDesignparameterApiName).getDescribe().fields.getMap();
                    String designcommaSepratedFields = '';
                    for(String designfieldName : designfieldMap.keyset()){
                        if(designcommaSepratedFields == null || designcommaSepratedFields == ''){
                            designcommaSepratedFields = designfieldName;
                        }
                        else{
                            designcommaSepratedFields = designcommaSepratedFields + ',' + designfieldName;
                        }
                    }
                    if(offer.RecordTypeId == offerRecordTypeId){
                        designquery = 'select ' + designcommaSepratedFields +  ',' +  EquipmentType + ',' +  Dia + ',' +  length + ' from Design_Parameter__c WHERE Name =\''+ offer.Opportunity_Equipments__r.Design_Parameter__r.name+'\'';
                        system.debug('222 is executing'+designquery);
                    }else if(offer.RecordTypeId == nonSpareOfferRecordTypeId){
                        designquery = 'select ' + designcommaSepratedFields +  ',' +  EquipmentType + ',' +  Dia + ',' +  length + ' from Design_Parameter__c WHERE Name =\''+ offer.Opportunity_Equipments__r.Design_Parameter__r.name+'\'';
                        system.debug('222 is executing'+designquery);                  
                    }else if(offer.Recordtype.name == 'Compile') {
                        designquery = 'select ' + designcommaSepratedFields +  ',' +  EquipmentType + ',' +  Dia + ',' +  length +' from Design_Parameter__c WHERE Id IN: listdesignParam ';
                        system.debug('226 is executing'+designquery);
                    }
                    system.debug('query for design paramter------'+designquery);
                    list<string> designfieldlabels = new List<string>();
                    designfieldlablemap = new Map<string, Map<string,object>>();
                    Designcombinelistmap = new list<Map<string,Object>>();
                    system.debug('Designcombinelistmap-------'+Designcombinelistmap);
                    designParams = Database.query(designquery);
                    system.debug('designParam---63'+designParams);
                    
                                    if(operatingParam.size() > 0) {
    
                    for(Design_Parameter__c DesignParam : designParams) {
                         String equipmentTypeValue = (String)DesignParam.getSObject('Customer_Equipment__r').get('Equipment_Type__c');
                            string diaValue = string.valueOf((Decimal)DesignParam.getSObject('Customer_Equipment__r').get('Dia_m__c'));
                            String lenghtValue = string.valueOf((Decimal)DesignParam.getSObject('Customer_Equipment__r').get('Length_m__c'));
    
                        if(DesignParam != NULL){
                            for(string designfield : designfieldMap.Keyset()){
                                string designfieldlabel = designfieldMap.get(designfield).getDescribe().getLabel();
                                if(designfield != 'Createddate' ) 
                                    if( designfield != 'CreatedById')
                                    if( designfield != 'LastModifiedDate')
                                    if( designfield != 'LastModifiedById')
                                    if( designfield != 'LastViewedDate')
                                    if( designfield != 'SystemModstamp')
                                    if( designfield != 'LastReferencedDate')
                                    if( designfield != 'ID')
                                    if( designfield != 'recordtypeid')
                                    if( designfield != 'Customer_Equipment__c')
                                    if( designfield != 'customer__c')
                                    if( designfield != 'IsDeleted')
                                    if( designfield != 'CurrencyIsoCode')
    
                                      if(DesignParam.get(designfield) != NUll){
                                          IF(!designfieldlablemap.containsKey(DesignParam.Id)) {
                                              designfieldlablemap.put(DesignParam.id, new Map<string, object>());
                                          }  
                                           else{
                                                designfieldlablemap.get(DesignParam.id).put(designfieldlabel, DesignParam.get(designfield)); 
                                                designfieldlablemap.get(DesignParam.id).put('Equipment Type', equipmentTypeValue); 
                                                designfieldlablemap.get(DesignParam.id).put('Dia (m)', diaValue); 
                                                designfieldlablemap.get(DesignParam.id).put('Length (m)', lenghtValue); 
                                            }
                                      }
                                
                                designfieldlabels.add(designfieldlabel);
                                system.debug('designfieldlabels===230======'+designfieldlabels);
                            }
                            designcombinelistmap.add(fieldlablemap);
                            system.debug('DesignParam---233'+DesignParam);
                            designParamList.add(DesignParam);
                            system.debug('designParamList-------235'+designParamList);
                        }
                    }
                                } 
            }
                
                //selectionitemlist = [SELECT id,zone__c, Proposal_Form__c, Proposal_Form__r.Customer_Equipment__c, No_of_Rows__c,Item_Desc__c, Quantity__c from Scope_With_Selection__c WHERE Proposal_Form__c = : offer.Opportunity_Equipments__c ];  
                selectionitemlist = [SELECT Id,Item_Category__c,Item_Desc__c,Quantity__c,Unit_Price_Quoted__c,Total_Price_Quoted__c,Total_Cost__c from Scope_With_Selection__c WHERE Proposal_Form__c = : offer.Opportunity_Equipments__c ];
                //  system.debug('selectionitemlist'+selectionitemlist);
                
            } 
            Catch(System.QueryException e){
                system.debug('error line===='+e.getLineNumber()+'====error type-----------'+e.getCause()+'-------error message-------'+e.getMessage()+
                             '-------error gettype-------'+e.getTypeName()+'-------error getStackTraceString-------'+e.getStackTraceString());
                TegaUtility.trackLogs( e,  'OfferTemplateController',  'OfferTemplateController');
                
            }
        }
}