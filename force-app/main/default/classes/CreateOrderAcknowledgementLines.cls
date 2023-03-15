public with sharing class CreateOrderAcknowledgementLines {
    @AuraEnabled(cacheable=true)
    public static List<OALine> getLineItems(Id OAId){
        System.debug('OAId-->>'+OAId);  
        Set<String> existingLineSet = new Set<String>();
        List<OALine> OALineList = new List<OALine>();

        List<Order_Acknowledgement__c> OAList = [SELECT Id,Name,X4E_4D__c,X4E_4D__r.RecordType.DeveloperName  FROM Order_Acknowledgement__c WHERE Id = : OAId];
        String X4E4DId = OAList[0].X4E_4D__c;
        System.debug('OAList-->>'+OAList);  

        List<Order_Acknowledgement_Line_Item__c> existingOALines = [SELECT Id, Name FROM Order_Acknowledgement_Line_Item__c 
                                                            WHERE  Order_Acknowledgement__r.X4E_4D__c=: X4E4DId];

        if(existingOALines != null && existingOALines.size() > 0 ){
            for(Order_Acknowledgement_Line_Item__c line : existingOALines){
                existingLineSet.add(line.Name);
            }
        }   

        List<X4E_4D_Line_Item__c> lineList = [SELECT Id,Name,Category_4E_4D__c,X4E_4D__c,Date_of_Shutdown__c,Delivery_Date_Required__c,Delivery_SLA__c,Description__c,Item_Value__c,Offer_Delivery_SLA_Weeks__c,Quantity__c,Total_Value__C  
                                            FROM X4E_4D_Line_Item__c 
                                            WHERE X4E_4D__c=: X4E4DId
                                            AND Description__c NOT IN : existingLineSet];
            
        System.debug('lineList-->>'+lineList);  

        for (X4E_4D_Line_Item__c qLine : lineList) {
            OALine line = new OALine();
            line.isCheck = false;
            line.lineId = qLine.Id;
            line.description = qLine.Description__c;
            line.quantity = qLine.Quantity__c;
            line.itemValue = qLine.Item_Value__c;
            line.totalValue = qLine.Total_Value__c;
            line.deliverySLA = qLine.Delivery_SLA__c;
            line.deliveryDateReq = qLine.Delivery_Date_Required__c;
            OALineList.add(line);
        }
        system.debug('OALineList-->>'+OALineList);
        return OALineList;
    }        

    @AuraEnabled
    public static void saveLines( list<OALine> oALines, Id oAId){
        List<Order_Acknowledgement_Line_Item__c> oALineList = new List<Order_Acknowledgement_Line_Item__c>();
        System.debug('oALines-->>'+ oALines); 
        for(OALine ofLine : oALines){
            oALineList.add( new Order_Acknowledgement_Line_Item__c(
                Order_Acknowledgement__c = oAId,
                X4E_4D_Line_Item__c = ofLine.lineId,
                Name = ofLine.description
            ));
        }

        if(oALineList.size() > 0 ){
           insert oALineList;
        }

    }  

    public class OALine{
        @AuraEnabled public Id lineId{get;set;}
        @AuraEnabled public Boolean isCheck{get;set;}
        @AuraEnabled public String description{get;set;}
        @AuraEnabled public Decimal quantity{get;set;}
        @AuraEnabled public Decimal itemValue{get;set;}
        @AuraEnabled public Decimal totalValue{get;set;}
        @AuraEnabled public Date deliverySLA{get;set;}
        @AuraEnabled public Date deliveryDateReq{get;set;}
    }
}