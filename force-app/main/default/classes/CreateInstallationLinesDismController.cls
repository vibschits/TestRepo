public class CreateInstallationLinesDismController {
	
    public List<Installation_line_Items__c> selInsLineItemLst;
    public String insLineIds;
    
    public CreateInstallationLinesDismController( ApexPages.StandardSetController cntlr ) {
        selInsLineItemLst = cntlr.getSelected();
        system.debug('selInsLineItemLst'+selInsLineItemLst);
        insLineIds = '';
        for(Installation_line_Items__c insLine : selInsLineItemLst){
            insLineIds += insLine.Id + ',';   
        }
        insLineIds = insLineIds.removeEnd(','); 
    }
    
    public PageReference DismantleController(){
        String returnUrl = '/lightning/cmp/c__DismantleListAuraCmp?c__listofInstaLineItems='+insLineIds;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }
}