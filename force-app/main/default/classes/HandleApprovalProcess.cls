public class HandleApprovalProcess {
    @InvocableMethod (label = 'Get PRF ID' description = 'returns something.')
    public static void getPRFId (List<ID> ids){
        system.debug('is it coming');
        // Even though we are receiving list of id, we will always receive only one id from flow
        Id userId = UserInfo.getUserId();
        System.debug('ProcessInstance----------'+ids);
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId,ActorId 
                                                   FROM ProcessInstanceWorkitem 
                                                   WHERE ProcessInstance.TargetObjectId IN :ids AND ActorId =: userId];
        system.debug('workItems----------'+workItems);
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            //Valid values are: Approve, Reject, or Removed. 
            //Only system administrators can specify Removed.
            req.setAction('Reject');
            req.setComments('Prf is in Regret Status');
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
    }
}