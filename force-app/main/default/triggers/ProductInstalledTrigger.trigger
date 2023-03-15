trigger ProductInstalledTrigger on Product_Installed__c (before insert) {
    
    
    public static string triggerName ='ProductInstalledTrigger';
    ProductInstalledHandler piHandlerObj = new ProductInstalledHandler();
    TriggerDispatcher.run(piHandlerObj);
}