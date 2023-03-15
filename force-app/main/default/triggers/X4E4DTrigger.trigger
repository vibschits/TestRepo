trigger X4E4DTrigger on X4E_4D__c (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
    public static string triggerName ='X4E4DTrigger';
    X4E4DTriggerHandler x4E4DTriggerHandlerObj = new X4E4DTriggerHandler();
    TriggerDispatcher.run(x4E4DTriggerHandlerObj);
}