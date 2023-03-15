trigger ProposalFormTrigger on Proposal_Form__c (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
    public static string triggerName ='ProposalFormTrigger';
    ProposalFormTriggerHandler proposalFormHandlerObj = new ProposalFormTriggerHandler();
    TriggerDispatcher.run(proposalFormHandlerObj);
}