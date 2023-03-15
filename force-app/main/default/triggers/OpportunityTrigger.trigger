trigger OpportunityTrigger on Opportunity (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
    
    public static string triggerName ='OpportunityTrigger';
    OpportunityTriggerHandler opportunityHandlerObj = new OpportunityTriggerHandler();
    TriggerDispatcher.run(opportunityHandlerObj);
}