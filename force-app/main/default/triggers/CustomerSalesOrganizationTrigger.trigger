trigger CustomerSalesOrganizationTrigger on Customer_Sales_Organization__c (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
    TriggerDispatcher.run(new CustomerSalesOrganizationHandler());
}