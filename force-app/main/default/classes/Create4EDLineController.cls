public with sharing class Create4EDLineController {
    
    @AuraEnabled(cacheable=true)
    public static List<OfferLine> getLineItems(Id EDId){
        System.debug('EDId-->>'+EDId);  
        Set<String> existingLineSet = new Set<String>();
        List<OfferLine> OfferLineList = new List<OfferLine>();

        List<X4E_4D__c> EDList = [SELECT Id,SF_Offer__c,SF_Offer__r.RecordType.DeveloperName  FROM X4E_4D__c WHERE Id = : EDId];
        String offerId = EDList[0].SF_Offer__c;
        System.debug('EDList-->>'+EDList);  

        List<X4E_4D_Line_Item__c> existing4EDLines = [SELECT Id, Description__c FROM X4E_4D_Line_Item__c 
                                                            WHERE  X4E_4D__r.SF_Offer__c=: offerId];

        if(existing4EDLines != null && existing4EDLines.size() > 0 ){
            for(X4E_4D_Line_Item__c line : existing4EDLines){
                existingLineSet.add(line.Description__c);
            }
        }     

        if(EDList[0].SF_Offer__r.RecordType.DeveloperName != 'Offer_Non_Spare'){
                                                           

            List<QuoteLineItem> lineList = [SELECT Id, Product2.Name,L2_L3_Product__c,UnitPrice, L2_L3_Product__r.Product_L2__r.Name, Quantity, Quote.Offer_Generation_at__c  
                                            FROM QuoteLineItem 
                                            WHERE QuoteId=: offerId 
                                            AND Product2.Name NOT IN : existingLineSet];
            
            System.debug('lineList-->>'+lineList);  
            String offerLevel = lineList[0].Quote.Offer_Generation_at__c  ;
            System.debug('offerLevel-->>'+offerLevel);  


            if(offerLevel == 'L3'){
                for (QuoteLineItem qLine : lineList) {
                    OfferLine line = new OfferLine();
                    line.isCheck = false;
                    line.lineId = qLine.Id;
                    line.description = qLine.Product2.Name;
                    line.quantity = qLine.Quantity;
                    line.price = qLine.UnitPrice;
                    line.offerGenLevel = qLine.L2_L3_Product__c != null ? 'L3': '';
                    OfferLineList.add(line);
                }
            }

            if(offerLevel == 'L2' || offerLevel == 'L1'){
                Id RecordTypeId =  TegaUtilityWithoutSharing.getL1L2RecordTypeId(offerLevel == 'L2' ? 'L2' : 'L1');

                List<QuoteLineItem> L3lineList = [SELECT Id, Product2.Name, L2_L3_Product__r.Product_L2__r.Name,
                                                    UnitPrice, Quantity, Quote.Offer_Generation_at__c  
                                                    FROM QuoteLineItem 
                                                    WHERE QuoteId=: offerId AND L2_L3_Product__c = Null 
                                                    AND Product2.Name NOT IN : existingLineSet];

                List<L1_L2_Offer_Line_Item__c> L1L2LineIteamList = [SELECT Id,Product_Description__c,Quantity__c,Offer__c,Amount__c 
                                                                    FROM L1_L2_Offer_Line_Item__c
                                                                    WHERE Offer__c = :offerId
                                                                    AND  recordTypeId =: RecordTypeId
                                                                    AND Product_Description__c NOT IN : existingLineSet];
                
                if(L3lineList.size() > 0 ){
                    for (QuoteLineItem qLine : L3lineList) {
                        OfferLine line = new OfferLine();
                        line.isCheck = false;
                        line.lineId = qLine.Id;
                        line.description = qLine.Product2.Name;
                        line.quantity = qLine.Quantity;
                        line.price = qLine.UnitPrice;
                        if(offerLevel == 'L2'){
                            line.offerGenLevel = 'L2';
                        }
                        if(offerLevel == 'L1'){
                            line.offerGenLevel = 'L1';
                        }
                        OfferLineList.add(line);
                    } 
                }
                
                for (L1_L2_Offer_Line_Item__c ofrLine : L1L2LineIteamList) {
                    OfferLine line = new OfferLine();
                    line.isCheck = false;
                    line.lineId = ofrLine.Id;
                    line.description = ofrLine.Product_Description__c;
                    line.quantity = ofrLine.Quantity__c;
                    line.price = ofrLine.Amount__c;
                    OfferLineList.add(line);
                }
            }   
                
            
        }else {

            List<Scope_With_Selection__c> scopeList = [SELECT Id,Quantity__c,Name,Floor_Price__c,Delivery_SLA_Weeks__c 
                                                      FROM Scope_With_Selection__c  
                                                      WHERE Offer__c =:offerId  
                                                      AND name NOT IN : existingLineSet ];

            for(Scope_With_Selection__c sc : scopeList) {
                OfferLine line = new OfferLine();
                line.isCheck = false;
                line.lineId = sc.Id;
                line.description = sc.name;
                line.quantity = sc.Quantity__c;
                line.price = sc.Floor_Price__c;
                line.deliverySLA = sc.Delivery_SLA_Weeks__c;
                OfferLineList.add(line);
            }
        }
        system.debug('OfferLineList-->>'+OfferLineList);
        return OfferLineList; 
    }

    @AuraEnabled
    public static void saveLines( list<OfferLine> edLines, Id edId){
        List<X4E_4D_Line_Item__c> edLineList = new List<X4E_4D_Line_Item__c>();
        System.debug('edLines-->>'+ edLines); 
        for(OfferLine ofLine : edLines){
            edLineList.add( new X4E_4D_Line_Item__c(
                X4E_4D__c = edId,
                Description__c = ofLine.description,
                Item_Value__c = ofLine.price,
                Quantity__c =  ofLine.quantity,
                Offer_Delivery_SLA_Weeks__c = ofLine.deliverySLA,
                Delivery_Date_Required__c = ofLine.deliveryDateReq
            ));
        }

        if(edLineList.size() > 0 ){
           insert edLineList;
        }

    }  

    public class OfferLine{
        @AuraEnabled public Id lineId{get;set;}
        @AuraEnabled public Boolean isCheck{get;set;}
        @AuraEnabled public String description{get;set;}
        @AuraEnabled public Decimal quantity{get;set;}
        @AuraEnabled public Decimal price{get;set;}
        @AuraEnabled public String offerGenLevel{get;set;}
        @AuraEnabled public Decimal deliverySLA{get;set;}
        @AuraEnabled public Date deliveryDateReq{get;set;}

    }
}