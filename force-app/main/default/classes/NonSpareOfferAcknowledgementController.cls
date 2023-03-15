/*
Name : NonSpareOfferAcknowledgementController
Description : This class used to update offer in SAP 
Author : Kuhinoor
*/
public with sharing class NonSpareOfferAcknowledgementController implements Queueable, Database.allowscallouts{
    Quote offer;
    Integration_Transaction__c it;
    public NonSpareOfferAcknowledgementController(Quote offer, Integration_Transaction__c it){
        this.offer = offer;
        this.it = it;
    }

    public void execute(QueueableContext qc){
        	 
			NonSpareOfferAcknowledgementHelper.SendAcknowledgementToSAP(offer.Id,it.Id);
    }
}