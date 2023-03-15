/*
Name : TegaUtility
Desc : This is an utility class for Tega specific.
Author : Kuhinoor
*/
public without sharing class TegaUtilityWithoutSharing {
   /*
    Name : getOfferRecordTypeId
    Desc : This method return record type Id
    Params : developerName
    */
    public static Id getOfferRecordTypeId(String developerName) {
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
        return recordTypeId;
     }

      /*
    Name : getL1L2RecordTypeId
    Desc : This method return record type Id
    Params : developerName
    */
    public static Id getL1L2RecordTypeId(String developerName) {
      Id recordTypeId = Schema.SObjectType.L1_L2_Offer_Line_Item__c.getRecordTypeInfosByName().get(developerName).getRecordTypeId();
      return recordTypeId;
   }

   /*
    Name : getProductRecordTypeId
    Desc : This method return record type Id
    Params : developerName
    */
    public static Id getProductRecordTypeId(String developerName) {
      Id recordTypeId = Schema.SObjectType.product2.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
      return recordTypeId;
   }
}