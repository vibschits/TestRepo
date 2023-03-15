public with Sharing class CreateOfferLineController{
    
    @AuraEnabled
    public static Map<String,Object>  searchPartList(String offerId, string SearchProducts, String picklistProductType,String sortby, String sortorder) {
        system.debug('SearchProducts'+SearchProducts);
        string pType; 
        String currCode;
        Id sOrgId;
        Id partListId;
        Id customerId;
        Boolean isWos = false;
        // AK 02/12/22 Changes
        Boolean isDirectCustomer = false;
        wrapperProducts obj = new wrapperProducts();    
        List<L2_L3_product__c> L2L3Prods = new List<L2_L3_product__c>();
        Map<String,Double> conversion_rates = new Map<String,Double>();
        Map<String, object> resultMap = new Map<String, object>();
        Set<String> ISOCodes = new Set<String>();
        ISOCodes.add(UserInfo.getDefaultCurrency());
       // try{

            //List<Part_List__c> partList = [SELECT Id, Customer__c FROM Part_List__c 
            //                               WHERE Name =: SearchProducts.trim() ORDER BY Revision__c  DESC LIMIT 1];
            //partListId = partList[0].Id;
            //system.debug('partListId-->'+partList);
            List<Derived_SO_Price_Factor__c> derivedSOFactorList = [SELECT Id,SO_Price_Factor__c, Part_List__c,Direct_Customer__c,
                                                                    Part_List__r.Customer__c
                                                                    FROM Derived_SO_Price_Factor__c 
                                                                    WHERE On_Hold__c = false 
                                                                    AND Part_List__r.Name = : SearchProducts.trim()
                                                                    ORDER BY Part_List__r.Revision__c  DESC LIMIT 1 ];
            if(derivedSOFactorList != null && derivedSOFactorList.size() > 0){
                isDirectCustomer = derivedSOFactorList[0].Direct_Customer__c;
                partListId = derivedSOFactorList[0].Part_List__c;
                customerId = derivedSOFactorList[0].Part_List__r.Customer__c;
            } 
            
            
            List<Quote> offerlist = [SELECT id, Name, Opportunity.CurrencyIsoCode,CurrencyIsoCode,Sales_Org__c,
                                    Sales_Org__r.Name, Opportunity.id,Branch__r.Is_WOS__c,AccountId  
                                    FROM Quote WHERE ID =:offerId ]; 
        
        system.debug('offerlist'+offerlist[0].Sales_Org__c+'offerlist size'+offerlist.size()+'offer name'+offerlist[0].Name);

        //if(partList != null && partList.size() > 0 ){
        if(String.isNotBlank(partListId)){
            //if(partList[0].Customer__c == offerlist[0].AccountId){
            if(customerId == offerlist[0].AccountId){
            if(derivedSOFactorList != null && derivedSOFactorList.size() > 0 ){                                                     
                ISOCodes.add(offerlist[0].Opportunity.CurrencyIsoCode);
                currCode = offerlist[0].CurrencyIsoCode;
                sOrgId = offerlist[0].Sales_Org__c;
                system.debug('sOrgId'+sOrgId);
                isWos =  offerlist[0].Branch__r.Is_WOS__c;
                // Added by kuhinoor
                List<CurrencyType> currList = [SELECT IsoCode,ConversionRate FROM CurrencyType WHERE IsoCode IN: ISOCodes];
                for(CurrencyType ct : currList){
                    conversion_rates.put(ct.IsoCode, ct.ConversionRate);
                }
                // End Here
                
                List<CurrencyType> currencylist = [SELECt ID,ConversionRate, DecimalPlaces, IsActive, IsoCode from CurrencyType WHERE isActive = TRUE];   
                
               
                List<SAP_Last_Sale_Price__c> LastSalePriceList = new List<SAP_Last_Sale_Price__c>();
                
                
                    if(picklistProductType == '' || picklistProductType == null){
                        L2L3Prods = [SELECT id, Name, Product_L3__c, Product_L2__c, Product_L2__r.Name,
                                     Product_L2__r.Part_List__c, Product_L3__r.Name,Product_L3__r.Item_Code__c,
                                     Product_L3__r.Description, Product_L3__r.Product_Type__c, 
                                     Product_L3__r.Quantity__c, Quantity__c 
                                     FROM L2_L3_product__c 
                                     WHERE  Part_List__c = : partListId AND Product_L3__c != null 
                                     AND Product_L2__c != null ];
                        
                        system.debug('L2L3Prods without prod type'+L2L3Prods); 
                    }
                    else{
                        ProductType2__c prodtype2 = ProductType2__c.getValues(picklistProductType);
                        system.debug('selected type =----'+prodtype2);
                        List<string> prodTypes= prodtype2.Prod_Type__c.split(','); 
                        system.debug('prodTypes-------'+prodTypes);
                        L2L3Prods = [SELECT id, Name, Product_L3__c, Product_L2__c, Product_L2__r.Part_List__c, 
                                     Product_L2__r.Name, Product_L3__r.Name,Product_L3__r.Item_Code__c,
                                     Product_L3__r.Description, Product_L3__r.Product_Type__c, 
                                     Product_L3__r.Quantity__c, Quantity__c 
                                     FROM L2_L3_product__c 
                                     WHERE  Part_List__c = : partListId
                                     AND Product_L3__r.Product_Type__c =: prodTypes
                                     AND Product_L3__c != null AND Product_L2__c != null ];
                        
                        system.debug('L2L3Prods with prod type'+L2L3Prods);
                    }
                    obj.products = L2L3Prods;
                    obj.partListId = L2L3Prods[0].Product_L2__r.Part_List__c;
                    system.debug('obj.products'+ obj.products);
                    
                    Set<Id> L3ProductIds = new Set<Id>();
                    Map<String,Decimal> L3ProdQtyMap = new Map<String,Decimal>();
                    for(L2_L3_product__c record : L2L3Prods) { // iterating L2L3Prods so that we can gather L3 prod Ids
                        L3ProductIds.add(record.Product_L3__c);
                        system.debug('L3ProductIds'+L3ProductIds);
                        String L2prodName = record.Product_L2__r.Name.split('-')[3];
                        L3ProdQtyMap.put(record.Product_L3__c+L2prodName, record.Quantity__c);
                    }        
                    System.debug(L3ProductIds);

                    //Fixed price 
                    Map<Id, Decimal> fixedPriceMap = new Map<Id, Decimal>();
                    List<Fixed_Contract_Price__c> fixedPriceList = [SELECT Id,Product__c, Price__c
                                                                    FROM Fixed_Contract_Price__c 
                                                                    WHERE  Part_List__c = : partListId];
                
                    System.debug('fixedPriceList-->>'+fixedPriceList);                         
                    for(Fixed_Contract_Price__c fx : fixedPriceList ){
                        fixedPriceMap.put(fx.Product__c, fx.Price__c);
                    }    
                    obj.fixedPriceMap = fixedPriceMap;
                    //

                    List<Sales_Org_Last_SAP_SO__c> sapRecords = [SELECT id, SAP_Last_Sale__c, SAP_Last_Sale__r.Product_L3__c, 
                                                                convertCurrency(Last_Sales_Price__c), Last_Sales_Date__c
                                                                FROM Sales_Org_Last_SAP_SO__c
                                                                WHERE Sales_Org__c = : sOrgId AND
                                                                SAP_Last_Sale__r.Product_L3__c IN : L3ProductIds  /*AND CreatedDate > LAST_N_MONTHS:6*/  ORDER BY CreatedDate desc  ];
                    
                
                    system.debug('sapRecords'+sapRecords);
                    Map<Id, Decimal> latestSapPriceToL3Product = new Map<Id, Decimal>();
                    Map<Id,Date> ProductL3_LastSODate_Map = new Map<Id,Date>();
                    for (Sales_Org_Last_SAP_SO__c sapRecord : sapRecords) {
                       if (latestSapPriceToL3Product.containsKey(sapRecord.SAP_Last_Sale__r.Product_L3__c)) {
                            continue; 
                        }
                        system.debug('sapRecord'+sapRecord.SAP_Last_Sale__r.Product_L3__c + sapRecord.Last_Sales_Price__c );
                        Decimal cRate = conversion_rates.get(UserInfo.getDefaultCurrency());
                        system.debug('cRate'+cRate);
                        Decimal actualRate = 1/cRate;
                        system.debug('actualRate'+actualRate);
                        Integer noOfMonth =sapRecord.Last_Sales_Date__c.monthsBetween(Date.today());
                        System.debug('noOfMonth-->>'+noOfMonth);
                        Integer incrementPercent = 1;
                        if(noOfMonth >= 6 && noOfMonth <= 12){
                            incrementPercent = 6;
                        }
                        if(noOfMonth > 12 && noOfMonth <= 18){
                            incrementPercent = 10;
                        }
                        if(noOfMonth > 18 && noOfMonth <= 24){
                            incrementPercent = 13;
                        }
                        if(noOfMonth > 24){
                            incrementPercent = 6;
                        }
                        
                        // AK 29/12/22 Changes start
                        
                        Decimal lastSlaPrice = sapRecord.Last_Sales_Price__c;
                        system.debug('lastSlaPrice =>'+lastSlaPrice);
                        if(noOfMonth >= 6 && noOfMonth <= 24){
                            system.debug('Inside SI');
                            lastSlaPrice += (sapRecord.Last_Sales_Price__c * incrementPercent)/100;
                            system.debug('lastSlaPrice 2 =>'+lastSlaPrice);
                        }       
                        if(noOfMonth > 24){       
                            system.debug('Inside CI');
                            lastSlaPrice = calculateInterest(lastSlaPrice, noOfmonth, incrementPercent);
                            system.debug('lastSlaPrice 3 =>'+lastSlaPrice);
                        }
                        
                        system.debug('isWos =>'+isWos);
                        system.debug('isDirectCustomer =>'+isDirectCustomer);                        
                        if(isWos && isDirectCustomer != true){
                            system.debug('Inside WOS');
                            Decimal wosValue = 1.333;
                           lastSlaPrice = lastSlaPrice * wosValue;
       
                            lastSlaPrice = lastSlaPrice.setScale(2);
                        }
                        system.debug('lastSlaPrice final =>'+lastSlaPrice);
                        // AK 29/12/22 Changes end
                         
                        latestSapPriceToL3Product.put(sapRecord.SAP_Last_Sale__r.Product_L3__c, lastSlaPrice * actualRate);
                        if(sapRecord.Last_Sales_Date__c != null){
                            ProductL3_LastSODate_Map.put(sapRecord.SAP_Last_Sale__r.Product_L3__c,sapRecord.Last_Sales_Date__c);
                        }
                        system.debug('sapRecord.Product_L3__c'+sapRecord.SAP_Last_Sale__r.Product_L3__c);
                    }
                    if(fixedPriceList.size() > 0 ){
                        for(Fixed_Contract_Price__c fx : fixedPriceList ){
                            latestSapPriceToL3Product.put(fx.Product__c, fx.Price__c);
                        } 
                    }
                
                    system.debug('latestSapPriceToL3Product AK 1 Dec => '+latestSapPriceToL3Product);
                    
                    Map<String,Decimal> IsoCode_cRate = new Map<String,Decimal>();
                    Set<string> setopp = new set<string>();
                    system.debug('currencylist'+currencylist);
                    for(CurrencyType ct: currencylist){
                        IsoCode_cRate.put(ct.IsoCode,ct.ConversionRate);
                        system.debug('ct---------'+ct.ConversionRate);
                        
                    }
                    obj.Currencycode = IsoCode_cRate;
                    
                    
                    obj.sapPriceMap = latestSapPriceToL3Product;
                    obj.sapDateMap = ProductL3_LastSODate_Map;
                    //  system.debug('obj'+obj.sapPriceMap);
                    
                    obj.conversionRate =conversion_rates.get(offerlist[0].Opportunity.CurrencyIsoCode);
                        //  system.debug('obj'+obj);
                        
                    resultMap.put('data',obj);
                    resultMap.put('offerCurrency',currCode);            
                    resultMap.put('BTP', prepareBTPCalculationData(offerId, L3ProductIds, conversion_rates));
                    resultMap.put('L3ProdQtyMap',L3ProdQtyMap);
                    resultMap.put('isErr', false);
                    resultMap.put('SOFactor', derivedSOFactorList[0].SO_Price_Factor__c);
                    resultMap.put('sOrgId', sOrgId);
                    resultMap.put('isWos', isWos);
                    resultMap.put('isDirectCustomer', isDirectCustomer);
                }else {
                    resultMap.put('isErr', true);
                    resultMap.put('ErrorMsg','This partlist is not available to create offer!');
            }
        }else{
            resultMap.put('isErr', true);
            resultMap.put('ErrorMsg','Customer mismatch.');
        }      
    } 
       // }
       // catch(exception e){
       //     system.debug('exception'+e.getLineNumber()+ e.getCause()+e.getMessage());
         //   TegaUtility.trackLogs( e,  'CreateOfferLineController',  'BTPCalculationMethod');
       // }
        return resultMap; 
        
    }
    
  /*  @AuraEnabled
    public static List<string> getProductType(){
    
        Set<string> productType = new Set<string>();
        
        List<Product2> prodList = [SELECT id, Product_Type__c from product2];
        for(Product2 prod : prodList) {
            productType.add(prod.Product_Type__c);
        }
        system.debug('productType'+productType);
       

        return new List<String>(productType);
        
    }*/
    
    
    
    
    /*
    Name : saveOffer
    Desc : this method used to create offer line and dependent records.
    */
    @AuraEnabled
    public static void saveOffer(String offerId, String currCode, String partListId, String recordStr, String l2l3MapStr, Map<String, 
                                 Object> btpMap, Integer fullSetQty, String sOrgId, Boolean isWOS, String headerStr){
       Savepoint sp = Database.setSavepoint();
        System.debug('Save called');
       list<QuoteLineItem> existingOfferLine = [SELECT Id FROM QuoteLineItem 
                                                    WHERE QuoteId =:offerId 
                                                    AND Quote.Part_List__c != null ];

        list<L1_L2_Offer_Line_Item__c> L1L2OfferLine = [SELECT Id FROM L1_L2_Offer_Line_Item__c
                                                        WHERE Offer__c =:offerId ];                                      
        delete existingOfferLine;
        delete L1L2OfferLine;
        
        String headerStr2 = headerStr;
        
        System.debug('offerId-->>'+offerId);
        System.debug('currCode-->>'+currCode);
        System.debug('partListId-->>'+partListId);
        System.debug('recordStr-->>'+recordStr);
        System.debug('headerStr-->>'+headerStr);
        System.debug('l2l3MapStr-->>'+l2l3MapStr);
        System.debug('btpMap-->>'+btpMap);
        System.debug('fullSetQty-->>'+fullSetQty);
        
        
        
        try {            
            Set<Id> productIds = new Set<Id>();
            List<QuoteLineItem> lineIteminsertList = new List<QuoteLineItem>();
            Map<Id, PricebookEntry > pricebookEntryMap = new Map<Id, PricebookEntry >();
            Map<Id, PricebookEntry > pbInsertMap = new Map<Id, PricebookEntry >();
            //Map<Id, Decimal > latestSapPriceMap = new Map<Id, Decimal >();
            //Set<String> ISOCodes = new Set<String>();
            //Map<String,Double> conversion_rates = new Map<String,Double>();
            //String weightObj;
            //Map<Id, Item_Weight__c> weightMap;

            //ISOCodes.add(UserInfo.getDefaultCurrency());
            //ISOCodes.add(currCode);

            List<offerLine> offerLineList = (List<offerLine>) JSON.deserialize(recordStr, List<offerLine>.class);
            system.debug('offerLineList =>'+offerLineList);
            
            // AK 08/12/22 Changes
            //BELOW MAP CONTAINS MAP of <Product L3 ID, Corresponding L2L3 ID>
            Map<String,Id> l2l3Map = (Map<String,Id>) JSON.deserialize(l2l3MapStr, Map<String,Id>.class);            
            system.debug('l2l3Map => '+l2l3Map);
            List<headersWrap> headersWrapList = (List<headersWrap>) JSON.deserialize(headerStr2, List<headersWrap>.class);
            
            Map<String,Decimal> headerMap = new Map<String,Decimal>();
            // AK 09/12/22
            for(headersWrap wrp : headersWrapList){
                if(wrp.isSelected == true){
                    headerMap.put(wrp.Name,wrp.value);
                }
                
            }
            system.debug('headerMap'+headerMap);
            
            //weightObj =JSON.serialize( btpMap.get('weightMap') );
            //weightMap = (Map<Id, Item_Weight__c>) JSON.deserialize(weightObj,  Map<Id, Item_Weight__c>.class);    
            
            //Map<Id, Decimal > l2l3Map = (Map<Id, Decimal>)JSON.deserialize(l2l3MapStr, Map<Id,Decimal>.class); AK 08/12/22

             // Qty calculaiton for L2
             Set<Id> l3ProductIds = new Set<Id>();
             //Double total_weight = 0;
             for(offerLine ofLine : offerLineList){
                 l3ProductIds.add(ofLine.l3ProductId);
                  /*if(weightMap.containsKey(ofLine.l3ProductId) && weightMap.get(ofLine.l3ProductId).Net_Weight__c > 0){
                      Decimal prodWeight = (ofLine.customQuantity + ofLine.level2customQuantity) *  (weightMap.get(ofLine.l3ProductId).Net_Weight__c);
                      System.debug('--prodL3-Id-'+ofLine.l3ProductId);
                      System.debug('--prodL3-level2customQuantity-'+ofLine.level2customQuantity);
                      System.debug('-prodL3-weight'+prodWeight);
                      total_weight = total_weight + prodWeight;*/
             }
             //}
             //System.debug('--total_weight--'+total_weight);   
            //  List<Quote> offerList = [SELECT Id,Branch__r.Is_WOS__c FROM Quote WHERE Id=: offerId];
            //  isWOS = offerList[0].Branch__r.Is_WOS__c;

            /*List<CurrencyType> currList = [SELECT IsoCode,ConversionRate FROM CurrencyType WHERE IsoCode IN: ISOCodes];
            for(CurrencyType ct : currList){
                conversion_rates.put(ct.IsoCode, ct.ConversionRate);
            }
            Decimal cRate = conversion_rates.get(UserInfo.getDefaultCurrency());            
            Decimal actualRate = 1/cRate;

            //Fixed price
            Map<Id, Decimal> fixedPriceMap = new Map<Id, Decimal>();
            List<Fixed_Contract_Price__c> fixedPriceList = [SELECT Id,Product__c, Price__c FROM Fixed_Contract_Price__c 
                                        WHERE Part_List__c =: partListId];
            System.debug('fixedPriceList-->>'+fixedPriceList);                         
            for(Fixed_Contract_Price__c fx : fixedPriceList ){
                fixedPriceMap.put(fx.Product__c, fx.Price__c);
            } 
            
            system.debug('L3ProductIds-->>'+L3ProductIds);
            system.debug('sOrgId-->>'+sOrgId);
            */
            //Last Sales price....
            /*List<Sales_Org_Last_SAP_SO__c> sapRecords = [SELECT id, SAP_Last_Sale__c, SAP_Last_Sale__r.Product_L3__c, 
                                                                convertCurrency(Last_Sales_Price__c), Last_Sales_Date__c
                                                                FROM Sales_Org_Last_SAP_SO__c
                                                                WHERE Sales_Org__c = : sOrgId AND
                                                                SAP_Last_Sale__r.Product_L3__c IN : L3ProductIds  ORDER BY CreatedDate desc  ];
            
                    system.debug('sapRecords'+sapRecords);
                    for(Sales_Org_Last_SAP_SO__c  sapRecord : sapRecords){
                        Integer noOfMonth =sapRecord.Last_Sales_Date__c.monthsBetween(Date.today());
                            System.debug('noOfMonth-->>'+noOfMonth);
                            Integer incrementPercent = 1;
                            if(noOfMonth > 6 && noOfMonth<= 12){
                                incrementPercent = 6;
                            }
                            if(noOfMonth > 12 && noOfMonth<= 18){
                                incrementPercent = 10;
                            }
                            if(noOfMonth > 18 && noOfMonth<= 24){
                                incrementPercent = 13;
                            }
                            if(noOfMonth > 24){ 
                                incrementPercent = 6;
                            }

                            Decimal lastSlaPrice = sapRecord.Last_Sales_Price__c;
                            if(noOfMonth > 6 && noOfMonth <= 24){
                                lastSlaPrice += (sapRecord.Last_Sales_Price__c * incrementPercent)/100;
                            }       
                            if(noOfMonth > 24){                            
                                lastSlaPrice = calculateInterest(lastSlaPrice, noOfmonth, incrementPercent);
                            }
                            if(isWOS){
                                lastSlaPrice =lastSlaPrice * (100/75);
                            }
                            
                            latestSapPriceMap.put(sapRecord.SAP_Last_Sale__r.Product_L3__c, lastSlaPrice * actualRate);
                        }
                        
            //END 
            // Derived SO Factor..
            List<Derived_SO_Price_Factor__c> derivedSOFactorList = [Select Id,SO_Price_Factor__c FROM Derived_SO_Price_Factor__c 
                                                                    WHERE On_Hold__c = false 
                                                                    AND Part_List__c =: partListId ];
            //
            */
            Id stndPriceBookId;
            if(Test.isrunningtest()){
                stndPriceBookId = Test.getStandardPricebookId();
            }else {
                Pricebook2 stdPriceBook = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
                stndPriceBookId = stdPriceBook.Id;
            }

            // List<Pricebook2> standardPbList = [SELECT id,Name FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            // system.debug('standardPbList-->>'+standardPbList);
            if(offerLineList != null && offerLineList.size() > 0 ){
                for(offerLine ofLine : offerLineList){
                    productIds.add(ofLine.l3ProductId); 
                }
                List<PricebookEntry> pbEntryList = [SELECT Id, Product2Id,Pricebook2.isstandard,UnitPrice,CurrencyIsoCode FROM PricebookEntry
                                                    WHERE Product2Id IN : productIds 
                                                    AND CurrencyIsoCode =: currCode AND Pricebook2.isstandard = true];
                for(PricebookEntry pb : pbEntryList){
                    PricebookEntryMap.put(pb.Product2Id, pb);
                }
                // SK - 210223
                List<PricebookEntry> updatedPbEntryList = new  List<PricebookEntry>();
                for(offerLine ofLine : offerLineList){
                    system.debug('ofLine.btpPrice-->>'+ofLine.btpPrice);
                    system.debug('ofLine.margin-->>'+ofLine.margin);
                    Decimal marginAmt = (ofLine.btpPrice * ofLine.margin)/100;
                    if(!PricebookEntryMap.containsKey(ofLine.l3ProductId)){ 
                        pbInsertMap.put(ofLine.l3ProductId, new PricebookEntry(
                            Product2Id = ofLine.l3ProductId,
                            UnitPrice = (ofLine.salesPrice + marginAmt),
                            Pricebook2Id = stndPriceBookId,
                            CurrencyIsoCode = currCode,
                            IsActive=true
                        ));
                    }
                    else{
                        system.debug('Inside Elseif 448-->>');
                        system.debug('offerLineList-->>'+offerLineList);
                        PricebookEntry pb = PricebookEntryMap.get(ofLine.l3ProductId);
                        system.debug('pb -->>'+pb);
                        if(pb.UnitPrice != (ofLine.salesPrice + marginAmt) && pb.CurrencyIsoCode == currCode){
                        //pb.Product2Id = ofLine.l3ProductId;
                        //pb.Pricebook2Id = stndPriceBookId;
                        pb.UnitPrice = (ofLine.salesPrice + marginAmt);
                        updatedPbEntryList.add(pb);
                         system.debug('UnitPrice -->>'+(ofLine.salesPrice + marginAmt));
                    }
                  }
                }
                system.debug('pbInsertMap.value--->>'+pbInsertMap.values());
                if(pbInsertMap.values().size() > 0){
                     insert pbInsertMap.values();   
                    //AK Database.insert(pbInsertMap.values(), false);
                }
                
                if(updatedPbEntryList.size() > 0){
                     update updatedPbEntryList;  
                     System.debug('updatedPbEntryList'+updatedPbEntryList);
                }
                
                //Merge old and new PB Map
                PricebookEntryMap.putAll(pbInsertMap);

                
                System.debug('l3ProductIds-->'+l3ProductIds); 
                System.debug('partListId-->'+partListId); 
                List<L2_L3_product__c> l2l3ProdList = [SELECT Id, Product_L3__c,Product_L2__c, Quantity__c FROM L2_L3_product__c 
                                                        WHERE Product_L3__c IN : l3ProductIds 
                                                        AND Part_List__c =: partListId];

                 
                System.debug('l2l3ProdList-->'+l2l3ProdList);                                   
                Map<Id, L2_L3_product__c> L2L3ProdMap = new Map<Id, L2_L3_product__c>();
                Map<Id, L2_L3_product__c> L2L3QtyMap = new Map<Id, L2_L3_product__c>();
                for(L2_L3_product__c l3Obj : l2l3ProdList){
                    L2L3QtyMap.put(l3Obj.Product_L3__c, l3Obj);
                    L2L3ProdMap.put(l3Obj.Id, l3Obj);
                }
                System.debug('L2L3ProdMap-->'+L2L3ProdMap);                                  
                System.debug('L2L3QtyMap-->'+L2L3QtyMap);                                  

                //AK 08/12/22 Changes
                for(offerLine ofLine : offerLineList){
                    
                    String l2Name = '';
                    Decimal btpPrice = ofLine.btpPrice;
                    Decimal marginAmt = (ofLine.btpPrice * ofLine.margin)/100;
                    Decimal unitPrice = (btpPrice + marginAmt);
                    
                    //AK 13/12/22 Changes
                    List<String> qtyPerL2List = new List<String>();
                    String L2WiseQty = ofLine.quantityL2Wise;
                    
                    // AK 14/12/22 Changes
                    if(L2WiseQty == ''){
                        if(ofLine.customQuantity > 0){
                            QuoteLineItem qLine = new QuoteLineItem();
                            qLine.QuoteId = offerId;
                            qLine.Product2Id = ofLine.l3ProductId;
                            qLine.PricebookEntryId = PricebookEntryMap.get(ofLine.l3ProductId).Id;
                            qLine.UnitPrice = !ofLine.isFG ? unitPrice.setScale(2) : Math.ceil(unitPrice);
                            qLine.Quantity =  ofLine.customQuantity;
                            qLine.Margin__c = marginAmt;
                            qLine.Margin_Discount__c = ofLine.margin;
                            //Discount  =ofLine.discount,
                            qLine.BTP_Price__c = !ofLine.isFG ? btpPrice.setScale(2) : Math.ceil(btpPrice);
                            qLine.Original_BTP_Price__c = !ofLine.isFG ? ofLine.OriginalBTP.setScale(2) : Math.ceil(ofLine.OriginalBTP);
                            //qLine.L2_L3_Product__c = l2l3Map.get(ofLine.l3ProductId); // L2L3ProdMap.get(ofLine.l3ProductId).Id
                            qLine.RMC_Cost__c = ofLine.RMCCost;
                            qLine.Branch_Rate_of_Interest__c = ofLine.branchRateOfInterest;
                            qLine.Offer_Payment__c = ofLine.offerpayment;
                            qLine.Branch_Hedging__c = ofLine.branchHedging;
                            qLine.Cost_Packing_Forwarding__c = ofLine.costPackingForwarding;
                            qLine.Cost_Freight__c = ofLine.CostFreight;
                            qLine.Cost_Insurance__c = ofLine.costInsurance;
                            qLine.Cost_Interest__c = ofLine.costInterest;
                            qLine.Cost_Hedging__c = ofLine.costHedging;
                            qLine.Exchange_Rate__c = ofLine.exchangeRate;
                            qLine.Basic_Price__c = ofLine.basicPrice;
                            
                            system.debug('AK 02/12/22 CustomLineItem => '+qLine);
                            lineIteminsertList.add(qLine);
                        }
                    }else{
                        String[] splitL2WiseQty = L2WiseQty.split(';');
                        system.debug('splitL2WiseQty => '+splitL2WiseQty);
                        for(String str : splitL2WiseQty){
                            String[] getQty = str.split('-');
                            String qtyVal = getQty[1];
                            if(qtyVal != 'undefined'){
                                l2Name = getQty[0];
                                system.debug('l2Name =>'+l2Name);
                                Decimal qtyPerL2 = Decimal.valueOf(qtyVal);
                                //AK 12-12-22 Changes to multiply qty by L2 Times for change in L2 Headers
                                Decimal headerQty = headerMap.get(l2Name);
                                if(headerQty > 0){
                                    qtyPerL2 = qtyPerL2 * headerQty;
                                }
                                String listItem = qtyPerL2 + '-' + l2Name;
                                system.debug('listItem =>'+listItem);
                                qtyPerL2List.add(listItem);
                            }
                            
                        }
                       
                        system.debug('qtyPerL2List => '+qtyPerL2List);
                        
                        for(String qty : qtyPerL2List){
                            
                            String[] getQty = qty.split('-');
                            String qtyVal = getQty[0];
                            Decimal qtyPerL2 = Decimal.valueOf(qtyVal);
                            String l2NameForLineItem = getQty[1];
                            
                            
                            QuoteLineItem qLine = new QuoteLineItem();
                            qLine.QuoteId = offerId;
                            qLine.Product2Id = ofLine.l3ProductId;
                            qLine.PricebookEntryId = PricebookEntryMap.get(ofLine.l3ProductId).Id;
                            qLine.UnitPrice = !ofLine.isFG ? unitPrice.setScale(2) : Math.ceil(unitPrice);
                            qLine.Quantity =  qtyPerL2;//(ofLine.level2customQuantity + ofLine.customQuantity); // ofLine.customQuantity,
                            qLine.Margin__c = marginAmt;
                            qLine.Margin_Discount__c = ofLine.margin;
                            //Discount  =ofLine.discount,
                            qLine.BTP_Price__c = !ofLine.isFG ? btpPrice.setScale(2) : Math.ceil(btpPrice);
                            qLine.Original_BTP_Price__c = !ofLine.isFG ? ofLine.OriginalBTP.setScale(2) : Math.ceil(ofLine.OriginalBTP);
                            String correspondingL2L3 = ofLine.l3ProductId + '-' +l2NameForLineItem;
                            system.debug('correspondingL2L3 => '+correspondingL2L3);
                            qLine.L2_L3_Product__c = l2l3Map.get(correspondingL2L3); // L2L3ProdMap.get(ofLine.l3ProductId).Id
                            qLine.RMC_Cost__c = ofLine.RMCCost;
                            qLine.Branch_Rate_of_Interest__c = ofLine.branchRateOfInterest;
                            qLine.Offer_Payment__c = ofLine.offerpayment;
                            qLine.Branch_Hedging__c = ofLine.branchHedging;
                            qLine.Cost_Packing_Forwarding__c = ofLine.costPackingForwarding;
                            qLine.Cost_Freight__c = ofLine.CostFreight;
                            qLine.Cost_Insurance__c = ofLine.costInsurance;
                            qLine.Cost_Interest__c = ofLine.costInterest;
                            qLine.Cost_Hedging__c = ofLine.costHedging;
                            qLine.Exchange_Rate__c = ofLine.exchangeRate;
                            qLine.Basic_Price__c = ofLine.basicPrice;
                            
                            system.debug('AK 02/12/22 LineItem => '+qLine);
                            lineIteminsertList.add(qLine);
                        }
                        
                        if(ofLine.customQuantity > 0){
                            QuoteLineItem qLine = new QuoteLineItem();
                            qLine.QuoteId = offerId;
                            qLine.Product2Id = ofLine.l3ProductId;
                            qLine.PricebookEntryId = PricebookEntryMap.get(ofLine.l3ProductId).Id;
                            qLine.UnitPrice = !ofLine.isFG ? unitPrice.setScale(2) : Math.ceil(unitPrice);
                            qLine.Quantity =  ofLine.customQuantity;
                            qLine.Margin__c = marginAmt;
                            qLine.Margin_Discount__c = ofLine.margin;
                            //Discount  =ofLine.discount,
                            qLine.BTP_Price__c = !ofLine.isFG ? btpPrice.setScale(2) : Math.ceil(btpPrice);
                            qLine.Original_BTP_Price__c = !ofLine.isFG ? ofLine.OriginalBTP.setScale(2) : Math.ceil(ofLine.OriginalBTP);
                            //qLine.L2_L3_Product__c = l2l3Map.get(ofLine.l3ProductId); // L2L3ProdMap.get(ofLine.l3ProductId).Id
                            qLine.RMC_Cost__c = ofLine.RMCCost;
                            qLine.Branch_Rate_of_Interest__c = ofLine.branchRateOfInterest;
                            qLine.Offer_Payment__c = ofLine.offerpayment;
                            qLine.Branch_Hedging__c = ofLine.branchHedging;
                            qLine.Cost_Packing_Forwarding__c = ofLine.costPackingForwarding;
                            qLine.Cost_Freight__c = ofLine.CostFreight;
                            qLine.Cost_Insurance__c = ofLine.costInsurance;
                            qLine.Cost_Interest__c = ofLine.costInterest;
                            qLine.Cost_Hedging__c = ofLine.costHedging;
                            qLine.Exchange_Rate__c = ofLine.exchangeRate;
                            qLine.Basic_Price__c = ofLine.basicPrice;
                            
                            system.debug('AK 02/12/22 CustomLineItem => '+qLine);
                            lineIteminsertList.add(qLine);
                        }
                    }
                    
                    
                }
                
                
/*AK              for (String key : l2l3Map.keySet()) {
                    for(offerLine ofLine : offerLineList){
                        if(L2L3ProdMap.containsKey(key) && L2L3ProdMap.get(key).Product_L2__c == ofLine.l2ProductId){                          
                            system.debug('PB Id-->>'+PricebookEntryMap.get(ofLine.l3ProductId).Id);
                            Decimal qty = L2L3QtyMap.get(ofLine.l3ProductId).Quantity__c * l2l3Map.get(key);
                          //  BTPClass btp =  calculateBTPPrice(offerId, ofLine.l3ProductId, qty,btpMap,weightMap,total_weight);                            
                            Decimal btpPrice = ofLine.btpPrice;
                            System.debug('---rc-BTP--'+btpPrice);
                            /*if(latestSapPriceMap.containsKey(ofLine.l3ProductId)){
                                
                                System.debug('latestSapPriceMap-->>'+latestSapPriceMap.get(ofLine.l3ProductId));
                                System.debug('btpPrice-->>'+btpPrice);

                                if(latestSapPriceMap.get(ofLine.l3ProductId) > btpPrice){
                                    btpPrice = latestSapPriceMap.get(ofLine.l3ProductId);
                                }
                            }else {
                                Decimal LLP = derivedSOFactorList[0].SO_Price_Factor__c;
                                if(isWOS){
                                    LLP = LLP * (100/75);
                                }
                                Decimal derivedBTP = btpPrice * LLP;
                                if(derivedBTP > btpPrice){
                                    btpPrice = derivedBTP;
                                }
                            }
                            if(fixedPriceMap.containsKey(ofLine.l3ProductId)){
                                btpPrice = fixedPriceMap.get(ofLine.l3ProductId) * qty;
                            }
                            //btpPrice = btpPrice/qty;
                            Decimal marginAmt = (btpPrice * ofLine.margin)/100;
                            Decimal discAmt = (btpPrice * ofLine.discount)/100;
                            //Decimal SalesPrice = (btpPrice + marginAmt) - discAmt;
                            Decimal SalesPrice = (btpPrice + marginAmt);
                           */
                         //Decimal qty =  L2L3ProdMap.get(ofLine.l3ProductId).Quantity__c * l2l3Map.get(key);
                        
/*AK                         Decimal marginAmt = (ofLine.btpPrice * ofLine.margin)/100;
                            Decimal unitPrice = (btpPrice + marginAmt);
                            system.debug('AK 08/12/22 key => '+key);
                            QuoteLineItem qLine = new QuoteLineItem(
                                QuoteId = offerId,
                                Product2Id = ofLine.l3ProductId,
                                PricebookEntryId = PricebookEntryMap.get(ofLine.l3ProductId).Id,
                                UnitPrice = !ofLine.isFG ? unitPrice.setScale(0) : Math.ceil(unitPrice),
                                Quantity =  (ofLine.level2customQuantity + ofLine.customQuantity), // ofLine.customQuantity,
                                Margin__c = marginAmt,
                                Margin_Discount__c = ofLine.margin,
                                //Discount  =ofLine.discount,
                                BTP_Price__c = !ofLine.isFG ? btpPrice.setScale(0) : Math.ceil(btpPrice),
                                Original_BTP_Price__c = ofLine.OriginalBTP.setScale(0),
                                L2_L3_Product__c = key, // L2L3ProdMap.get(ofLine.l3ProductId).Id,
                                RMC_Cost__c = ofLine.RMCCost,
                                Branch_Rate_of_Interest__c = ofLine.branchRateOfInterest,
                                Offer_Payment__c = ofLine.offerpayment,
                                Branch_Hedging__c = ofLine.branchHedging,
                                Cost_Packing_Forwarding__c = ofLine.costPackingForwarding,
                                Cost_Freight__c = ofLine.CostFreight,
                                Cost_Insurance__c = ofLine.costInsurance,
                                Cost_Interest__c = ofLine.costInterest,
                                Cost_Hedging__c = ofLine.costHedging,
                                Exchange_Rate__c = ofLine.exchangeRate,
                                Basic_Price__c = ofLine.basicPrice
                            );
                            system.debug('AK 02/12/22 LineItem => '+qLine);
                            lineIteminsertList.add(qLine);
                        }
                    }
                }
                
                /*for(offerLine ofLine : offerLineList){
                    system.debug('Inside 461 offerLineList'+ofLine);
                    if(ofLine.customQuantity > 0 ){
                       // BTPClass btp =  calculateBTPPrice(offerId, ofLine.l3ProductId, ofLine.customQuantity,btpMap,weightMap,total_weight);
                        Decimal btpPrice = ofLine.btpPrice;
                        system.debug('cust BTP--->>'+btpPrice);
                        system.debug('AK latestSapPriceMap =>'+latestSapPriceMap);
                        if(latestSapPriceMap.containsKey(ofLine.l3ProductId)){
                            system.debug('In LSP%%..-->>'+latestSapPriceMap.get(ofLine.l3ProductId));
                            if(latestSapPriceMap.get(ofLine.l3ProductId) > btpPrice){
                                btpPrice = latestSapPriceMap.get(ofLine.l3ProductId);
                            }
                        }else {
                            Decimal LLP = derivedSOFactorList[0].SO_Price_Factor__c;
                            if(isWOS){
                                LLP = LLP * (100/75);
                            }
                            Decimal derivedBTP = btpPrice * LLP;
                            if(derivedBTP > btpPrice){
                                btpPrice = derivedBTP;
                            }
                        }
                        
                        
                        if(fixedPriceMap.containsKey(ofLine.l3ProductId)){
                            system.debug('In fixed%%..-->>');
                            btpPrice = fixedPriceMap.get(ofLine.l3ProductId); //* ofLine.customQuantity;
                        }
                        //btpPrice = btpPrice/ofLine.customQuantity;
                        Decimal marginAmt = (btpPrice * ofLine.margin)/100;
                        Decimal discAmt = (btpPrice * ofLine.discount)/100;
                        //Decimal SalesPrice = (btpPrice + marginAmt) - discAmt;
                        Decimal SalesPrice = (btpPrice + marginAmt);
                        
                        if(ofLine.isFG){
                            btpPrice = Math.round(btpPrice);
                            SalesPrice = Math.round(SalesPrice);
                        }
                        
                        QuoteLineItem qLine = new QuoteLineItem(
                            QuoteId = offerId,
                            Product2Id = ofLine.l3ProductId,
                            PricebookEntryId = PricebookEntryMap.get(ofLine.l3ProductId).Id,
                            UnitPrice = SalesPrice,
                            Quantity = ofLine.customQuantity,
                            Margin__c = marginAmt,
                            Margin_Discount__c = ofLine.margin,
                            Discount  =ofLine.discount,
                            BTP_Price__c = btpPrice,
                            Original_BTP_Price__c = ofLine.btpPrice
                        );
                        lineIteminsertList.add(qLine);
                        system.debug('lineIteminsertList 508 =>'+lineIteminsertList);
                    }
                }*/
            }        
            if(lineIteminsertList.size() > 0 ){
                system.debug('lineIteminsertList 514 INSIDE =>'+lineIteminsertList);
               // insert lineIteminsertList;
               // AK 08/12/22
                Database.insert(lineIteminsertList, true);
                updateOffer(offerId, partListId, fullSetQty, headerStr2);
            }
        } catch (Exception ex) {
            Database.RollBack(sp);
            TegaUtility.trackLogs( ex,  'CreateOfferLineController',  'saveOffer');
            System.debug('Erorr-->>'+ ex);
        }
    }  
        
    /*
    Name : updateOffer
    Desc : this method used update offer
    */
    private static void updateOffer(String offerId, String partListId, Decimal fullSetQty, String headerStr2){
        try {
            //Quote ofr = new Quote(Id = offerId, Approval_Status__c = 'Submitted', Part_List__c = partListId);
              //update ofr; 
              TegaUtility.createL1L2OfferLine(offerId, fullSetQty, partListId, headerStr2);

        } catch (Exception ex) {
             TegaUtility.trackLogs( ex,  'CreateOfferLineController',  'updateOffer');
            System.debug('Error-->'+ ex);
        }
        
    }
    
    /*
    Name : getBTPPrice
    Desc : this method used to get BTP Price
    */
    @AuraEnabled
    public static BTPClass getBTPPrice(String offerId, String productId, Decimal itemQty,  Map<String, Integer> productQuantity, Map<String, Object> btpMap){
        system.debug('offerId'+offerId);
        system.debug('btpMap22-->>'+btpMap);
        system.debug('productQuantityMap-->>'+productQuantity);
        // Made changes by RC - 23-11-22 weightObj calculation to be done for all items. 
        String weightObj =JSON.serialize( btpMap.get('weightMap') );
        //BTPClass btp;
        Map<Id, Item_Weight__c> weightMap = (Map<Id, Item_Weight__c>) JSON.deserialize(weightObj,  Map<Id, Item_Weight__c>.class);
        Decimal totalWeight = 0;
        for(Id L3Id : weightMap.keySet()){
            Decimal prodWeight = 0;
            if(weightMap.get(L3Id)!= null){
               prodWeight =  productQuantity.get(L3Id) * weightMap.get(L3Id).Net_Weight__c;
            }
            totalWeight = totalWeight + prodWeight;
        }
       // System.debug('--total--weight--'+totalWeight);
        BTPClass btp =  calculateBTPPrice(offerId, productId, itemQty,btpMap,weightMap,totalWeight);
        System.debug('btp11-->>'+ btp);
        return btp;
    }
    
    /*
    Name : prepareBTPCalculationData
    Desc : this method prepare data to calculate BTP
    Params : offerId, prodIds, currencyMap
    */
    public static Map<String, object> prepareBTPCalculationData(Id offerId, Set<Id> prodIds, Map<String,Double> currencyMap){
        Map<String, object> reusltMap = new Map<String, object>();
        Map<Id, Decimal> cotainer20FtMap = new Map<Id, Decimal>(); 
        Map<Id, Item_Weight__c> weightMap = new Map<Id, Item_Weight__c>();
        Map<Id, Sales_Organization_Product__c> productMap = new Map<Id, Sales_Organization_Product__c>();  
        Map<Id, Quote> offerMap;
        Set<Id> protIds = new Set<Id>();     

        System.debug('offerId--->>'+offerId);
        offerMap = new Map<Id, Quote>([SELECT Id, BTP_Type__c, Payment_Months__c,
                                       Branch__c,Branch__r.Mark_Up__c,Branch__r.Rate_PckFwd__c,
                                       Branch__r.CIF_Factor__c, Branch__r.Rate_Freight__c,CurrencyIsoCode,
                                       Branch__r.Rate_Insurance__c,Branch__r.Rate_Interest__c,
                                       Branch__r.Rate_Hedging__c,Port__c,Sales_Org__c,Sales_Org__r.Name
                                       FROM Quote WHERE Id =: offerId AND BTP_Type__c != null 
                                       AND Payment_Months__c != null]);

        system.debug('offerMap-->>'+offerMap);
        for(Quote ofr : offerMap.values()){
            if(String.isNotBlank(ofr.Port__c)){
                protIds.add(ofr.Port__c);
            }
        }

        List<AggregateResult> result = [select Port_Code__c, sum(Container_Rate_20Ft__c)container20ft 
                                        FROM Freight__c 
                                        where Port_Code__c IN :protIds GROUP BY Port_Code__c];
        for(AggregateResult agg : result){
            cotainer20FtMap.put((Id)agg.get('Port_Code__c'), (Decimal)agg.get('container20ft'));
        }
        
        List<Sales_Organization_Product__c> productList = [SELECT Id,Product__c,convertCurrency(Price__c) FROM Sales_Organization_Product__c 
                                                           WHERE Product__c IN : prodIds 
                                                           AND Sales_Org__c = : offerMap.get(offerId).Sales_Org__c];
        
        for(Sales_Organization_Product__c sop : productList){
            productMap.put(sop.Product__c, sop);
        }    
        
        List<Item_Weight__c> weightList = [SELECT Id, Net_Weight__c,Product_L3__c 
                                           FROM Item_Weight__c 
                                           WHERE Product_L3__c IN : prodIds];
        
        for(Item_Weight__c we : weightList){
            weightMap.put(we.Product_L3__c, we);
        }
        
        system.debug('Sorg name1-->'+offerMap.get(offerId));
        Sales_Org_Currency_Mapping__mdt salesOrgCurr = Sales_Org_Currency_Mapping__mdt.getInstance(offerMap.get(offerId).Sales_Org__r.Name);
        system.debug('salesOrgCurr-->'+salesOrgCurr);
        
        CurrencyType cRate =  [select Id,ConversionRate, IsoCode  FROM CurrencyType WHERE IsoCode =: salesOrgCurr.Currency__c];
        
        reusltMap.put('offerMap', offerMap);
        reusltMap.put('productMap', productMap);
        reusltMap.put('cotainer20FtMap', cotainer20FtMap);
        reusltMap.put('weightMap', weightMap);
        reusltMap.put('cRate', cRate.ConversionRate);
        reusltMap.put('currencyMap',currencyMap);
        return reusltMap;
    } 
    
    /*
    Name : calculateBTPPrice
    Desc : this method is used to calculate BTP price.
    Note : Do not do soql and DML inside this method b/c this method calling in a loop.
    */
    public static BTPClass calculateBTPPrice(Id offerId, Id prodId, Decimal itemQty, Map<String, Object> btpMap,Map<Id, Item_Weight__c> weightMap, Decimal totalWeightOffer){                  
            System.debug('btpMap-->>'+btpMap);
            System.debug('itemQty-->>'+itemQty);
           // itemQty = 1;
           // totalWeightOffer = 35936.41;
            BTPClass btp = new BTPClass();
            String offerObj =JSON.serialize( btpMap.get('offerMap') );
            System.debug('offerObj-->>'+btpMap);
            Map<Id, Quote> offerMap = (Map<Id, Quote>) JSON.deserialize(offerObj,  Map<Id, Quote>.class);
            
            String productObj =JSON.serialize( btpMap.get('productMap') );
            Map<Id, Sales_Organization_Product__c> productMap = (Map<Id, Sales_Organization_Product__c>) JSON.deserialize(productObj,  Map<Id, Sales_Organization_Product__c>.class);
            
            String cotainer20FtObj =JSON.serialize( btpMap.get('cotainer20FtMap') );
            Map<Id, Decimal> cotainer20FtMap = (Map<Id, Decimal>) JSON.deserialize(cotainer20FtObj,  Map<Id, Decimal>.class);
            
            
            system.debug('offerid'+offerid);
            system.debug('offerMap'+offerMap);

        Quote offer = offerMap.get(offerId);
        system.debug('offer----'+offer.Branch__c);
        Sales_Organization_Product__c prod = productMap.get(prodId);       
            
            Decimal cRate = (Decimal)btpMap.get('cRate'); 
            
        String currRateObj =JSON.serialize( btpMap.get('currencyMap') );
        system.debug('currRateObj-----------'+currRateObj);
        
        Map<String,Double> conversion_rates = (Map<String,Double>) JSON.deserialize(currRateObj,  Map<String,Double>.class);
        system.debug('conversion_rates-----------'+conversion_rates);
        Decimal userCurConRate = conversion_rates.get(UserInfo.getDefaultCurrency());
        Decimal corporateCurRate = 1/userCurConRate;
        Decimal offerCurConRate = conversion_rates.get(offer.CurrencyIsoCode);
        system.debug('offerCurConRate-----------'+offerCurConRate);
            
            
            if(offer != null && String.isNotBlank(offer.BTP_Type__c) &&  offer.Payment_Months__c != null){
                if(prod != null && prod.Price__c != null && prod.Price__c > 0){  
                    system.debug(' prod.Price__c-->>'+ prod.Price__c);
                    Decimal RMCCost = prod.Price__c; 
                    Branch__c brnch = offer.Branch__r;
                    //system.debug('brnch==='+brnch);
                    //system.debug('brnch.Mark_Up__c--'+brnch.Mark_Up__c);
                    //system.debug('brnch.Rate_PckFwd__c-->>'+brnch.Rate_PckFwd__c);
                    Decimal basicPrice = RMCCost * brnch.Mark_Up__c;
                    Decimal costMould = 0;
                    Decimal costPackingForwarding = RMCCost *(brnch.Rate_PckFwd__c / 100);
                    system.debug('costPackingForwarding-->>'+costPackingForwarding);
                    if(itemQty > 0 ){
                       /* if (weightMap.get(prod.Product__c).Net_Weight__c > 0)
                            totalWeightOffer = itemQty * weightMap.get(prod.Product__c).Net_Weight__c; 
                        else 
                            totalWeightOffer =0;*/
                            
                    DecimaL noOfcontainers;
                            if(totalWeightOffer > 0)
                                noOfcontainers =   Math.round(totalWeightOffer / 15000);
                            else
                                 noOfcontainers = 0;
                                
                        Decimal containerRate20Ft = cotainer20FtMap.get(offer.Port__c);
                        system.debug('noOfcontainers=>'+noOfcontainers);
                        system.debug('containerRate20Ft=>'+containerRate20Ft);

                        Decimal totalFreightAmt = noOfcontainers * containerRate20Ft;
                        system.debug('totalFreightAmt-->>'+totalFreightAmt);
                        system.debug('totalWeightOffer-->>'+totalWeightOffer);
                        
                        Decimal freightAmtPerKg;
                        if ((weightMap.containsKey(prod.Product__c) && weightMap.get(prod.Product__c).Net_Weight__c > 0))
                            freightAmtPerKg = totalFreightAmt / totalWeightOffer;
                        else
                            freightAmtPerKg = 0;
                        system.debug('freightAmtPerKg-->>'+freightAmtPerKg);

                        Decimal costFreight = 0;
                        Decimal costInsurance = 0;
                        system.debug('noOfcontainers-->>'+noOfcontainers);

                        if(offer.BTP_Type__c == 'CIF'){
                            basicPrice = basicPrice * brnch.CIF_Factor__c;
                            if(noOfcontainers < 1){
                                CostFreight = (basicPrice + costPackingForwarding)* brnch.Rate_Freight__c / 100;
                            }else {
                                if ((weightMap.containsKey(prod.Product__c) && weightMap.get(prod.Product__c).Net_Weight__c > 0)){
                                    Decimal item_total_weight =  weightMap.get(prod.Product__c).Net_Weight__c;                                      
                                    CostFreight = item_total_weight * freightAmtPerKg * offerCurConRate ;                                     
                                   } 
                                else 
                                    CostFreight = 0;
                                                              
                            }
                            costInsurance = (basicPrice * brnch.Rate_Insurance__c) /100;
                        }
                        Decimal branchRateOfInterest =(1+(brnch.Rate_Interest__c / 100));            
                        Decimal offerpayment = offer.Payment_Months__c/12; 
                        Decimal branchHedging = (1+(brnch.Rate_Hedging__c / 100));   
                        
                        Decimal interestExpVal = math.pow(branchRateOfInterest.doubleValue(), offerpayment.doubleValue());
                        Decimal costInterest = RMCCost* (interestExpVal - 1);
                        
                        Decimal hedgExpVal = math.pow(branchHedging.doubleValue(), offerpayment.doubleValue());
                        Decimal costHedging =  basicPrice *(hedgExpVal -1);
                        Decimal costInstallation = 0;                             
                        Decimal costTaxDuty = 0;
                        Decimal exchangeRate = cRate; // Need to clarify...
                        
                        system.debug('RMCCost-->>'+ RMCCost);                        
                        system.debug('branchRateOfInterest-->>'+ branchRateOfInterest);
                        system.debug('offerpayment-->>'+ offerpayment);
                        system.debug('branchHedging-->>'+ branchHedging);
                        System.debug('basicPrice-->>'+basicPrice);
                        System.debug('costPackingForwarding-->>'+costPackingForwarding);
                        System.debug('CostFreight-->>'+CostFreight); 
                        System.debug('costInsurance-->>'+costInsurance);
                        System.debug('costInterest-->>'+costInterest);
                        System.debug('costHedging-->>'+costHedging);
                        System.debug('exchangeRate-->>'+exchangeRate);
                        
                        Decimal allCost = (basicPrice+costMould+costPackingForwarding+CostFreight+costInsurance+costInterest+costHedging+costInstallation+costTaxDuty);
                        System.debug('allCost-->>'+allCost);
                        Decimal allCoporateCost = allCost * corporateCurRate;
                        System.debug('corporateCurRate-->>'+corporateCurRate);
                        System.debug('allCoporateCost-->>'+allCoporateCost);
                        System.debug('offerCurConRate-->>'+offerCurConRate);
                        Decimal BTPVal = allCoporateCost * offerCurConRate; 
                        //Decimal BTPVal = (basicPrice+costMould+costPackingForwarding+CostFreight+costInsurance+costInterest+costHedging+costInstallation+costTaxDuty)/exchangeRate;
                        System.debug('BTPVal-->>'+BTPVal);
                        // btp.btpPrice = BTPVal.setScale(0);
                        
                        btp.btpPrice = BTPVal.setScale(2);
                        
                        // AK 02/12/22 Changes
                        btp.RMCCost = RMCCost;                        
                        btp.branchRateOfInterest = branchRateOfInterest;
                        btp.offerpayment = offerpayment;
                        btp.branchHedging = branchHedging;
                        btp.basicPrice = basicPrice;
                        btp.costPackingForwarding = costPackingForwarding;
                        btp.CostFreight = CostFreight; 
                        btp.costInsurance = costInsurance;
                        btp.costInterest = costInterest;
                        btp.costHedging = costHedging;
                        btp.exchangeRate = exchangeRate;
                        
                        // AK 01/12/22 Changes
                        List<Sales_Org_Last_SAP_SO__c> lastSOPriceList = [SELECT id, SAP_Last_Sale__c, SAP_Last_Sale__r.Product_L3__c, 
                                                         convertCurrency(Last_Sales_Price__c), Last_Sales_Date__c
                                                         FROM Sales_Org_Last_SAP_SO__c
                                                         WHERE SAP_Last_Sale__r.Product_L3__c =: prodId ORDER BY CreatedDate desc  ];
                        system.debug('lastSOPriceList'+lastSOPriceList);
                        if(lastSOPriceList.size() > 0){
                            //btp.lastSOPrice = lastSOPriceList[0].Last_Sales_Price__c;
                            Integer noOfMonth =lastSOPriceList[0].Last_Sales_Date__c.monthsBetween(Date.today());
                            System.debug('noOfMonth-->>'+noOfMonth);
                            Integer incrementPercent = 1;
                            if(noOfMonth >= 6 && noOfMonth<= 12){
                                incrementPercent = 6;
                            }
                            if(noOfMonth > 12 && noOfMonth<= 18){
                                incrementPercent = 10;
                            }
                            if(noOfMonth > 18 && noOfMonth<= 24){
                                incrementPercent = 13;
                            }
                            if(noOfMonth > 24){
                                incrementPercent = 6;
                            }
                            Decimal lastSlaPrice = lastSOPriceList[0].Last_Sales_Price__c;
                            Decimal incrementPrice = 0;
                            if(noOfMonth >= 6 && noOfMonth <= 24){
                                system.debug('Inside SI');
                                incrementPrice += (lastSOPriceList[0].Last_Sales_Price__c * incrementPercent)/100;
                            }       
                            if(noOfMonth > 24){       
                                system.debug('Inside CI');
                                incrementPrice = calculateInterest(lastSlaPrice, noOfmonth, incrementPercent);
                            }
                            //btp.incrementRateByTime = incrementPrice;
                        }
                        
                        
                    }else {
                        btp.errMsg = 'Product has no price.';
                    }
                }
            }
            System.debug('btp-->>'+btp);
            return btp;
        
    }


    /// Nikil Coce--------

    @auraEnabled
    public static Map<String,Object>  getl2l3Products(String offerId){
        system.debug('offerId-->'+offerId);
        string partlist;
        Id partListId;
        Id sOrgId;
        String currCode;
        Boolean isWos = false;
        string l2l3prodqtyvalue;
        Decimal totalBTPPrice =0;
        Decimal totalSalesPrice =0;
        Decimal totalSalesPer =0;
        Boolean isFullSet = false;
        Decimal fullSetQty = 0;
        Decimal SOFactor = 0;
        Boolean isDirectCustomer = false;

        Map<String, object> intializedvalues = new Map<String, object>();
        Map<string, wrapperProducts> WrapProds = new Map<string, wrapperProducts>();

        list<L1_L2_Offer_Line_Item__c> l1l2offerline =[SELECT ID,Offer__c, RecordType.DeveloperName, Quantity__c, Product_Description__c from L1_L2_Offer_Line_Item__c WHERE Offer__c =:offerId ]; 

        for(L1_L2_Offer_Line_Item__c ofLine : l1l2offerline ){
            if(ofLine.RecordType.DeveloperName == 'L1'){
                isFullSet = true;
                fullSetQty = ofLine.Quantity__c;
                break;
            }
        }
        
        

        list<L1_L2_Offer_Line_Item__c> l2offerline =[SELECT ID,Offer__c, RecordType.DeveloperName, Quantity__c, Product_Description__c from L1_L2_Offer_Line_Item__c WHERE Offer__c =:offerId AND RecordType.DeveloperName ='L2' ]; 
        
        List<Quote> offerlist = [SELECT id, Opportunity.CurrencyIsoCode,CurrencyIsoCode,Sales_Org__c,Sales_Org__r.Name, Opportunity.id, Part_List__r.name, Part_List__c,Branch__r.Is_WOS__c  from Quote WHERE ID =:offerId AND Part_List__c !=null ];
        system.debug('offerlist-->>'+offerlist);
        if(offerlist != null && offerlist.size() > 0){
            partlist = offerlist[0].Part_List__r.name;
            partListId =  offerlist[0].Part_List__c;
            sOrgId = offerlist[0].Sales_Org__c;
            currCode = offerlist[0].CurrencyIsoCode;
            isWos =  offerlist[0].Branch__r.Is_WOS__c;
            
           
            wrapperProducts obj = new wrapperProducts();
            offerLine line = new offerLine();
            system.debug('line'+line);
            
            // AK 02/12/22 Fixes
            List<Derived_SO_Price_Factor__c> derivedSOFactorList = [Select Id,SO_Price_Factor__c,Direct_Customer__c FROM Derived_SO_Price_Factor__c 
                                                                    WHERE Part_List__c=:partListId ];
            if(derivedSOFactorList != null && derivedSOFactorList.size() > 0){
                SOFactor =  derivedSOFactorList[0].SO_Price_Factor__c;
                isDirectCustomer = derivedSOFactorList[0].Direct_Customer__c;
            } 
            
            
            List<L2_L3_product__c> L2L3Prods = new List<L2_L3_product__c>();
            L2L3Prods = [SELECT id, Name, Product_L3__c,Product_L2__r.Part_List__c, Product_L2__r.Name, 
                         Product_L3__r.Name,Product_L3__r.Item_Code__c,Product_L3__r.Description, 
                         Product_L3__r.Product_Type__c, Product_L3__r.Quantity__c, Quantity__c 
                         FROM L2_L3_product__c 
                         WHERE Part_List__c =:partListId AND Product_L3__c != null 
                         AND Product_L2__c != null ];
            
            obj.products = L2L3Prods; 
            
            system.debug('obj.products'+ obj.products);
            Map<Id,L2_L3_product__c> L3ProductIdsMap = new Map<Id,L2_L3_product__c>();
            Map<String,Decimal> L3ProdQtyMap = new Map<String,Decimal>();
            
            for(L2_L3_product__c record : L2L3Prods) { // iterating L2L3Prods so that we can gather L3 prod Ids
                L3ProductIdsMap.put(record.Product_L3__c,record);
                String L2prodName = record.Product_L2__r.Name.split('-')[3];
                L3ProdQtyMap.put(record.Product_L3__c+L2prodName, record.Quantity__c);
            }
            system.debug('L3ProductIdsMap'+L3ProductIdsMap);
            system.debug('offerId'+offerId);
            system.debug('Part_List__c'+offerlist[0].Part_List__c);

            
            
            List<QuoteLineItem> Qlineitemc =  [SELECT ID, LineNumber, Discount, UnitPrice,Subtotal,TotalPrice,Margin_Discount__c,Quantity,Margin__c, 
                                               Product2Id,Product2.name, Product2.Product_Type__c, BTP_Price__c, Product2.Description, 
                                               QuoteId,Original_BTP_Price__c,  Quote.Part_List__r.name,L2_L3_Product__c  
                                               FROM QuoteLineItem 
                                               WHERE  QuoteId =: offerId AND Quote.Part_List__c != NULL Order by L2_L3_Product__c];
            system.debug('Qlineitemc-->>'+Qlineitemc);
            
            Decimal qtyToPut = 0;
            
            // AK 13/12/22 Linking all L2 Qty to JS Helper
            Map<Id,Decimal> quantityMap = new Map<Id,Decimal>();
            for(QuoteLineItem qli2 : Qlineitemc){
                if(!quantityMap.containsKey(qli2.Product2Id) && String.isNotBlank(qli2.L2_L3_Product__c)){
                    qtyToPut += qli2.quantity;
                    quantityMap.put(qli2.Product2Id,qtyToPut);
                    qtyToPut = 0;
                }else if(String.isNotBlank(qli2.L2_L3_Product__c)){
                    Decimal existQty = quantityMap.get(qli2.Product2Id);
                    system.debug('existQty =>'+existQty);
                    if(existQty != null && qli2.quantity != null){
                        existQty += qli2.quantity;
                    }
                    
                    quantityMap.put(qli2.Product2Id,existQty);
                }
                system.debug('quantityMap =>'+quantityMap);
            }
            
            for(QuoteLineItem qli : Qlineitemc){
                system.debug(qli.Product2Id);
                
                if(L3ProductIdsMap.containsKey(qli.Product2Id)){
                    wrapperProducts Wrp = new wrapperProducts();
                    wrp.QuotelineId = qli.Id;
                    qli.Margin__c =(Decimal.valueOf( Integer.valueOf(qli.Margin__c)));
                    //Decimal unitBTPPrice = (Decimal.valueOf( Integer.valueOf(qli.BTP_Price__c)));
                    Decimal unitBTPPrice = qli.BTP_Price__c;
                    //Wrp.margin = qli.Margin__c > 0 ? (qli.Margin__c/unitBTPPrice)*100 : 0;
                    Wrp.margin = qli.Margin_Discount__c;
                    //Wrp.margin = (Decimal.valueOf( Integer.valueOf( Wrp.margin)));
                    //Wrp.margin = math.ceil(Wrp.margin);
                    //qli.BTP_Price__c =  qli.BTP_Price__c * qli.Quantity;
                   // qli.UnitPrice = qli.BTP_Price__c +qli.Margin__c ;
                    
                    if(String.isNotBlank(qli.L2_L3_Product__c)){
                        
                        Wrp.level2customQuantity = quantityMap.get(qli.Product2Id);
                        system.debug('Wrp.level2customQuantity =>'+Wrp.level2customQuantity);
                        //Wrp.L2btpPrice = qli.BTP_Price__c;
                        Wrp.L2btpPrice = qli.Original_BTP_Price__c;
                        Wrp.customQuantity = WrapProds.containsKey(qli.Product2.name) ? WrapProds.get(qli.Product2.name).customQuantity : 0;
                        Wrp.cusBtpPrice = WrapProds.containsKey(qli.Product2.name) ? WrapProds.get(qli.Product2.name).cusBtpPrice : 0;
                    }else {
                        Wrp.customQuantity = qli.Quantity;    
                        Wrp.cusBtpPrice = qli.BTP_Price__c.setScale(2);
                        Wrp.L2btpPrice = 0;      
                    }
                    
                   // Wrp.margin =  (qli.Margin__c/ qli.UnitPrice)* 100;
                    Wrp.discount = qli.Margin_Discount__c;  
                    
                    if(!WrapProds.containsKey(qli.Product2.name)){
                        system.debug('AK BTP PRICE=> '+qli.BTP_Price__c);
                        Wrp.btpPrice =  qli.BTP_Price__c;
                        Wrp.salesPrice = qli.UnitPrice;
                    }else {
                        system.debug('AK ELSE BTP PRICE1=> '+ WrapProds.get(qli.Product2.name).btpPrice);
                        system.debug('AK ELSE BTP PRICE2=> '+ qli.BTP_Price__c);
                        system.debug('AK ELSE BTP PRICE FINAL=> '+ WrapProds.get(qli.Product2.name).btpPrice + qli.BTP_Price__c);
                        if(WrapProds.get(qli.Product2.name).btpPrice == qli.BTP_Price__c){
                            Wrp.btpPrice = qli.BTP_Price__c;
                            Wrp.salesPrice = WrapProds.get(qli.Product2.name).salesPrice;
                        }else{
                            Wrp.btpPrice = WrapProds.get(qli.Product2.name).btpPrice + qli.BTP_Price__c;
                            Wrp.salesPrice = WrapProds.get(qli.Product2.name).salesPrice + qli.UnitPrice;
                        }
                        
                        
                    }
                    system.debug('AK Before Wrp.btpPrice 07/12/22 => '+Wrp.btpPrice);
                    system.debug('AK Before Wrp.salesPrice 07/12/22 => '+Wrp.salesPrice);
                    Wrp.btpPrice = Wrp.btpPrice.setScale(2);
                    Wrp.salesPrice =    Wrp.salesPrice.setScale(2);
                    /*Decimal disAmt =  (Wrp.btpPrice * qli.Margin_Discount__c) / 100;
                    system.debug('AK disAmt 07/12/22 => '+disAmt);
                    
                    //AK 07/12/22 Fixes
                    if(disAmt > 0.0){
                        Wrp.salesPrice =    Wrp.salesPrice.setScale(0) - disAmt;
                    }else{
                        Wrp.salesPrice =    Wrp.salesPrice.setScale(0) + disAmt;
                    }
                    
                    //Wrp.salesPrice =    Wrp.salesPrice.setScale(0) - disAmt;
                    system.debug('AK Wrp.btpPrice 07/12/22 => '+Wrp.btpPrice);
                    system.debug('AK Wrp.salesPrice 07/12/22 => '+Wrp.salesPrice);
                    */
                    //totalBTPPrice = totalBTPPrice + (qli.BTP_Price__c * qli.Quantity);
                    totalBTPPrice = totalBTPPrice + (qli.BTP_Price__c * qli.Quantity);
                    // AK Fixes 07/12/22
                    //totalSalesPrice = totalSalesPrice + (qli.UnitPrice - disAmt) * qli.Quantity;
                    totalSalesPrice = totalSalesPrice + (qli.UnitPrice) * qli.Quantity;
                    totalSalesPer = (totalSalesPrice / totalBTPPrice) *100;
                    
                    totalBTPPrice = totalBTPPrice.setScale(2);
                    totalSalesPrice = totalSalesPrice.setScale(2);
                    totalSalesPer = totalSalesPer.setScale(2);
                    
                    system.debug(' obj.customQuantity'+ Wrp.customQuantity);
                    system.debug(' obj.btpPrice'+ Wrp.btpPrice);
                    system.debug(' obj.discount'+ Wrp.discount);
                    system.debug(' obj.margin'+ Wrp.margin);
                    
                    WrapProds.put(qli.Product2.name,wrp);  
                }
            }                                  
            system.debug(' WrapProds-->>'+ WrapProds);
            
            
            Map<String,Double> conversion_rates = new Map<String,Double>();
            
            Set<String> ISOCodes = new Set<String>();
            ISOCodes.add(UserInfo.getDefaultCurrency());
            ISOCodes.add(offerlist[0].Opportunity.CurrencyIsoCode);
            
            List<CurrencyType> currList = [SELECT IsoCode,ConversionRate FROM CurrencyType WHERE IsoCode IN: ISOCodes];
            for(CurrencyType ct : currList){
                conversion_rates.put(ct.IsoCode, ct.ConversionRate);
            }
            List<CurrencyType> currencylist = [SELECT ID,ConversionRate, DecimalPlaces, IsActive, IsoCode from CurrencyType WHERE isActive = TRUE];   
            
            //Fixed price 
            Map<Id, Decimal> fixedPriceMap = new Map<Id, Decimal>();
            List<Fixed_Contract_Price__c> fixedPriceList = [SELECT Id,Product__c, Price__c FROM Fixed_Contract_Price__c 
                                                            WHERE Part_List__c =: partListId];
            System.debug('fixedPriceList-->>'+fixedPriceList);                         
            for(Fixed_Contract_Price__c fx : fixedPriceList ){
                fixedPriceMap.put(fx.Product__c, fx.Price__c);
            }    
            obj.fixedPriceMap = fixedPriceMap;
            //
            
            List<Sales_Org_Last_SAP_SO__c> sapRecords = [SELECT id, SAP_Last_Sale__c, SAP_Last_Sale__r.Product_L3__c, 
                                                         convertCurrency(Last_Sales_Price__c), Last_Sales_Date__c
                                                         FROM Sales_Org_Last_SAP_SO__c
                                                         WHERE Sales_Org__c = : sOrgId AND
                                                         SAP_Last_Sale__r.Product_L3__c IN : L3ProductIdsMap.keySet()  /*AND CreatedDate > LAST_N_MONTHS:6*/  ORDER BY CreatedDate desc  ];
            system.debug('sapRecords'+sapRecords);
            Map<Id, Decimal> latestSapPriceToL3Product = new Map<Id, Decimal>();
            Map<Id,Date> ProductL3_LastSODate_Map = new Map<Id,Date>();
            for (Sales_Org_Last_SAP_SO__c sapRecord : sapRecords) {
                if (latestSapPriceToL3Product.containsKey(sapRecord.SAP_Last_Sale__r.Product_L3__c)) {
                    continue; 
                }
                system.debug('sapRecord'+sapRecord.SAP_Last_Sale__r.Product_L3__c + sapRecord.Last_Sales_Price__c );
                Decimal cRate = conversion_rates.get(UserInfo.getDefaultCurrency());
                system.debug('cRate'+cRate);
                Decimal actualRate = 1/cRate;
                system.debug('actualRate'+actualRate);
                Integer noOfMonth =sapRecord.Last_Sales_Date__c.monthsBetween(Date.today());
                System.debug('noOfMonth-->>'+noOfMonth);
                Integer incrementPercent = 1;
                if(noOfMonth > 6 && noOfMonth<= 12){
                    incrementPercent = 6;
                }
                if(noOfMonth > 12 && noOfMonth<= 18){
                    incrementPercent = 10;
                }
                if(noOfMonth > 18 && noOfMonth<= 24){
                    incrementPercent = 13;
                }
                if(noOfMonth > 24){
                    incrementPercent = 6;
                }
                Decimal lastSlaPrice = sapRecord.Last_Sales_Price__c;
                if(noOfMonth > 6 && noOfMonth <= 24){
                    system.debug('Inside SI');
                    lastSlaPrice += (sapRecord.Last_Sales_Price__c * incrementPercent)/100;
                }       
                if(noOfMonth > 24){       
                    system.debug('Inside CI');
                    lastSlaPrice = calculateInterest(lastSlaPrice, noOfmonth, incrementPercent);
                }   
                if(isWos && isDirectCustomer != true){
                    system.debug('Inside WOS');
                    Decimal wosValue = 1.333;
                    lastSlaPrice = lastSlaPrice * wosValue;
                    lastSlaPrice = lastSlaPrice.setScale(2);
                }
                //latestSapPriceToL3Product.put(sapRecord.SAP_Last_Sale__r.Product_L3__c,sapRecord.Last_Sales_Price__c * actualRate);
                latestSapPriceToL3Product.put(sapRecord.SAP_Last_Sale__r.Product_L3__c,lastSlaPrice * actualRate);
                system.debug('sapRecord.Product_L3__c'+sapRecord.SAP_Last_Sale__r.Product_L3__c);
                if(sapRecord.Last_Sales_Date__c != null){
                      ProductL3_LastSODate_Map.put(sapRecord.SAP_Last_Sale__r.Product_L3__c,sapRecord.Last_Sales_Date__c);
                }
            }
            
            if(fixedPriceList.size() > 0 ){
                for(Fixed_Contract_Price__c fx : fixedPriceList ){
                    latestSapPriceToL3Product.put(fx.Product__c, fx.Price__c);
                } 
            }
            
            Map<String,Decimal> IsoCode_cRate = new Map<String,Decimal>();
            Set<string> setopp = new set<string>();
            system.debug('currencylist'+currencylist);
            for(CurrencyType ct: currencylist){
                IsoCode_cRate.put(ct.IsoCode,ct.ConversionRate);
                
            }
            obj.Currencycode = IsoCode_cRate; 
            obj.sapPriceMap = latestSapPriceToL3Product;
            obj.sapDateMap = ProductL3_LastSODate_Map;
            system.debug('obj.sapPriceMap'+  obj.sapPriceMap);
            system.debug('L3ProdQtyMap-->>'+ L3ProdQtyMap);
            
            obj.conversionRate =conversion_rates.get(offerlist[0].Opportunity.CurrencyIsoCode);
            intializedvalues.put('data',obj);
            intializedvalues.put('BTP', prepareBTPCalculationData(offerId, L3ProductIdsMap.keySet(), conversion_rates));
            intializedvalues.put('wrp',WrapProds);
            intializedvalues.put('L3ProdQtyMap',L3ProdQtyMap);
            intializedvalues.put('partListId',partListId);
            intializedvalues.put('offerCurrency',currCode);  
            intializedvalues.put('l1l2',l1l2offerline);
            intializedvalues.put('totalBTPPrice',totalBTPPrice);
            intializedvalues.put('totalSalesPrice',totalSalesPrice);
            intializedvalues.put('totalSalesPer',totalSalesPer);
            intializedvalues.put('isFullSet',isFullSet);
            intializedvalues.put('fullSetQty',fullSetQty);
            intializedvalues.put('isWos', isWos); 
            intializedvalues.put('SOFactor', SOFactor);
            intializedvalues.put('isDirectCustomer', isDirectCustomer);
            intializedvalues.put('sOrgId', sOrgId);
        }
        
        return intializedvalues ;
        
    }
    // Nikil End here
    
    /*
     Name : calculateInterest
     Desc : this method calculate interest value
     */    
    public static Decimal calculateInterest(Decimal pAmount, Decimal noOfmonth, Decimal incrementPercent){
        Decimal rateOfInt = incrementPercent/100;
        system.debug('incrementPercent-->>'+incrementPercent);
        system.debug('rateOfInt-->>'+rateOfInt);
        Decimal n = 1;
        Decimal timeVal = noOfMonth /12;
        timeVal = math.ceil(timeVal);
        system.debug('noOfMonth-->>'+noOfMonth);
        system.debug('timeVal-->>'+timeVal);
        system.debug('timeVal C-->>'+math.ceil(timeVal));
        Decimal temp1 = 1+( rateOfInt/n);
        system.debug('temp1-->>'+temp1);
        Decimal pwVal = math.pow(temp1.doubleValue(), timeVal.doubleValue());
        system.debug('pwVal-->>'+pwVal);
        Decimal finalVal = pAmount * pwVal;
        return finalVal;
    }
    
    public class wrapperProducts{
        @auraEnabled
        public List<L2_L3_product__c> products{get;set;}
        
        @auraEnabled                   
        public Map<id,Decimal> sapPriceMap{get;set;}
        
        @auraEnabled
        public Map<id,Date> sapDateMap{get;set;}

        @auraEnabled                   
        public Map<Id,Decimal> fixedPriceMap{get;set;}
        
        @auraEnabled
        public Map<string,Decimal>  Currencycode{get;set;}
        
        @auraEnabled
        public Decimal conversionRate{get;set;}
        
        @auraEnabled
        public Map<String,Double> conRateMap{get;set;}
        
        @auraEnabled
        public Id partListId{get;set;}
        
         @auraEnabled
        public Decimal customQuantity{get;set;}
      
        @auraEnabled
        public Decimal margin{get;set;}
        
        @auraEnabled
        public Decimal discount{get;set;}
        
        @auraEnabled
        public Decimal btpPrice{get;set;}

        @auraEnabled
        public Decimal cusBtpPrice{get;set;}

        @auraEnabled
        public Decimal L2btpPrice{get;set;}
        
        @auraEnabled
        public Decimal salesPrice{get;set;}
        
        @auraEnabled
        public Id QuotelineId{get;set;}
        
        @auraEnabled
        public decimal level2customQuantity{get;set;}
        
    } 
    
    //Wrapper class
    public class offerLine{
        public decimal discount;
        public decimal margin;
        public decimal salesPrice;
        public decimal btpPrice;
        public String l3ProductId;
        public String l2ProductId;
        public decimal customQuantity;
        public decimal level2customQuantity;
        public Boolean isFG;
        
        //AK 02/12/22 Changes
        public decimal OriginalBTP;
        public decimal RMCCost;
        public decimal branchRateOfInterest;
        public decimal offerpayment;
        public decimal branchHedging;
        public decimal basicPrice;
        public decimal costPackingForwarding;
        public decimal CostFreight;
        public decimal costInsurance;
        public decimal costInterest;
        public decimal costHedging;
        public decimal exchangeRate;
        public String quantityL2Wise;
    }
    
    public class headersWrap{
        public String Name;
        public Boolean isSelected;
        public decimal value;
    }

    public class BTPClass{
        @auraEnabled
        public Decimal btpPrice {get;set;}
        
        @auraEnabled
        public Decimal lastSOPrice {get;set;}
        
        @auraEnabled
        public Decimal incrementRateByTime {get;set;}

        @auraEnabled
        public String errMsg {get;set;}
        
        @auraEnabled
        public Decimal totalItemValue {get;set;}
        
        @auraEnabled
        public Decimal RMCCost {get;set;}
        
        @auraEnabled
        public Decimal branchRateOfInterest {get;set;}
        
        @auraEnabled
        public Decimal offerpayment {get;set;}
        
        @auraEnabled
        public Decimal branchHedging {get;set;}
        
        @auraEnabled
        public Decimal basicPrice {get;set;}
        
        @auraEnabled
        public Decimal costPackingForwarding {get;set;}
        
        @auraEnabled
        public Decimal CostFreight {get;set;}
        
        @auraEnabled
        public Decimal costInsurance {get;set;}
        
        @auraEnabled
        public Decimal costInterest {get;set;}
        
        @auraEnabled
        public Decimal costHedging {get;set;}
        
        @auraEnabled
        public Decimal exchangeRate {get;set;}
        
        public BTPClass(){
            this.btpPrice = 0;
            this.lastSOPrice = 0;
            this.incrementRateByTime = 0;
            this.totalItemValue = 0;
            this.RMCCost = 0;                        
            this.branchRateOfInterest = 0;
            this.offerpayment = 0;
            this.branchHedging = 0;
            this.basicPrice = 0;
            this.costPackingForwarding = 0;
            this.CostFreight = 0; 
            this.costInsurance = 0;
            this.costInterest = 0;
            this.costHedging = 0;
            this.exchangeRate = 0;
            this.errMsg = '';
        }
    }
        // SK-061222 : Finding whether price of the product is updated or not through custom label
        @AuraEnabled
        public static string getProdUpdate(){
            string isProdUpdated = System.Label.Product_price_update;
            System.debug('@ProdUpdate :'+isProdUpdated);
            return isProdUpdated;
        }
}