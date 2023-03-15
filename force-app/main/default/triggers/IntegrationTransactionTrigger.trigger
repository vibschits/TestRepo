trigger IntegrationTransactionTrigger on Integration_Transaction__c (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
    TriggerDispatcher.run(new IntegrationTransactionHandler());
    system.debug('this is integration class');
}