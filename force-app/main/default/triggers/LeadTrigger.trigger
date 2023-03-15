trigger LeadTrigger on Lead (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
     public static string triggerName ='LeadTrigger';
    LeadTriggerHandler leadHandlerObj = new LeadTriggerHandler();
    TriggerDispatcher.run(leadHandlerObj);
    

}