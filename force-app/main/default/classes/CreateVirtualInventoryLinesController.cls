public class CreateVirtualInventoryLinesController {

    public List<Customer_Inventory_Stock__c> selInvLst;
    public String invIds;
    
    public CreateVirtualInventoryLinesController( ApexPages.StandardSetController cntlr ) {
        selInvLst = cntlr.getSelected();
        system.debug('selInvLst'+selInvLst);
        invIds = '';
        for(Customer_Inventory_Stock__c inv : selInvLst){
            invIds += inv.Id + ',';   
        }
        invIds = invIds.removeEnd(','); 
    }
    
    public PageReference  CreateVirtualInvLines(){
        String returnUrl = '/lightning/cmp/c__ProcessListView?c__listofInventories='+invIds;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }
}