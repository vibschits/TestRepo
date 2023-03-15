trigger AccountTrigger on Account (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
    
    public static string triggerName ='AccountTrigger';
    AccountTriggerHandler accountHandlerObj = new AccountTriggerHandler();
    TriggerDispatcher.run(accountHandlerObj);
}