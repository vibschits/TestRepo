public class LeadProcessor implements
    Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, LeadSource from Lead'
        );
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
        List<Contact> contacts = new List<Contact>();
        for (Lead led : scope) {
            led.LeadSource = 'Dreamforce';
        }
        update scope;
    }
    public void finish(Database.BatchableContext bc){
        
    }
}