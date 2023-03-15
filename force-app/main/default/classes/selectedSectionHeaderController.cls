public class selectedSectionHeaderController {
    public boolean DisplayPopup {get; set;}    
    
    public void ClosePopup() {       
        DisplayPopup = false;   
    }
    
    public Boolean SelectAll{get;set;}
    public Boolean CoverletterChecked{get;set;}
    public Boolean IntroductionLetter{get;set;}
    public Boolean AboutTega{get;set;}
    public Boolean OperatingParamaters{get;set;}
    public Boolean ScopeOfSupply{get;set;}
    public Boolean TechnicalSpecification{get;set;}
    public Boolean Selection{get;set;}
    public Boolean Drawing{get;set;}
    public Boolean Simulations{get;set;}
    public Boolean Presentation{get;set;}
    public Boolean priceSchedule{get;set;}
    public Boolean Annexure1{get;set;}
    public Boolean Annexure2{get;set;}
    public Boolean Annexure3{get;set;}
    public Boolean termsandConditions{get;set;}
    public Boolean generalTermsandcondition{get;set;}
    Id offerId;
    public Quote offer{get;set;}
    
    
    public selectedSectionHeaderController(ApexPages.StandardController stdCtrl) {
        offerId = ApexPages.currentPage().getParameters().get('Id');
         
      
            system.debug('offer id-------'+offerId);
        
    }
    
    public PageReference save() {
        
        DisplayPopup = true;
        PageReference pageRef = new PageReference('/Apex/Offer_Template_PDF');
        pageRef.setRedirect(true);
        pageRef.getParameters().put('checked', String.valueof(CoverletterChecked));
        pageRef.getParameters().put('IntroductionChecked', String.valueof(IntroductionLetter));
        pageRef.getParameters().put('AboutTegaChecked', String.valueof(AboutTega));
        pageRef.getParameters().put('OperatingParamatersChecked', String.valueof(OperatingParamaters));
        pageRef.getParameters().put('scopeOfSupplyChecked', String.valueof(ScopeOfSupply));
        pageRef.getParameters().put('technicalSpecificationChecked', String.valueof(TechnicalSpecification));
        pageRef.getParameters().put('selectionChecked', String.valueof(Selection));
        pageRef.getParameters().put('drawingChecked', String.valueof(Drawing));
        pageRef.getParameters().put('simulationChecked', String.valueof(Simulations));
        pageRef.getParameters().put('presentationChecked', String.valueof(Presentation));
        pageRef.getParameters().put('priceScheduleChecked', String.valueof(priceSchedule));
        pageRef.getParameters().put('annexureChecked', String.valueof(Annexure1));
        pageRef.getParameters().put('annexureChecked2', String.valueof(Annexure2));
        pageRef.getParameters().put('annexureChecked3', String.valueof(Annexure3));
        pageRef.getParameters().put('termsandConditionsChecked', String.valueof(termsandConditions));
        pageRef.getParameters().put('generalTermsandconditionChecked', String.valueof(generalTermsandcondition));
        pageRef.getParameters().put('selectedofferid', offerId);
        
        
        return pageRef;
        
    }
    
    public PageReference selectAllHandler() {
        PageReference pageRef = new PageReference('/Apex/selectedSectionHeader');
        SelectAll = true;
        CoverletterChecked = true;
        IntroductionLetter = true;
        AboutTega = true;
        OperatingParamaters = true;
        ScopeOfSupply = true;
        TechnicalSpecification = true;
        Selection = true;
        Drawing = true;
        Simulations = true;
        Presentation = true;
        priceSchedule = true;
        Annexure1 = true;
        Annexure2 = true;
        Annexure3 = true;
        termsandConditions = true;
        generalTermsandcondition = true;
        return pageRef;
    }
    
    public PageReference cancel() {
        pagereference pageRef = new pageReference('/'+offerId);
        
        return pageRef;
    }
    
    
    
}