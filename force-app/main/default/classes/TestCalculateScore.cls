@isTest
public class TestCalculateScore {
    static testmethod void testMethod1(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Part_List__c part_list = new Part_List__c(
            Name = 'PLM-03960-01 SAP2',
            CurrencyIsoCode = 'USD',
            BOM__c = 'BALL DIA- 2400 X 4300 MM EGL',
            Delivery_Req__c = 56.0,
            Description__c = 'BALL DIA- 2400 X 4300 MM EGL',
            Direct_Quoted_Exchange_Rate__c = 54.0,
            Last_Offer_Value_Foreign_Currency__c = 0.0,
            Customer__c=acc.id);
        insert part_list;
        
        Inventory_Score_Simulation__c invScoreSim = new Inventory_Score_Simulation__c(Customer__c = acc.Id,All_Customer_Inventory_applicable__c=true);
        insert invScoreSim;
        
        List<Inventory_Score_Relationship__c> lstRelationship = new List<Inventory_Score_Relationship__c>();
        Inventory_Score_Relationship__c tstScoreRelation = new Inventory_Score_Relationship__c();
        tstScoreRelation.Customer__c = acc.id;
        tstScoreRelation.Inventory_Score_Simulation__c = invScoreSim.id;
        tstScoreRelation.Part_List__c = part_list.id;
        tstScoreRelation.Priority__c = '1';
        tstScoreRelation.L2_Set_Qty__c = 2.0;
        lstRelationship.add(tstScoreRelation);
        
        Inventory_Score_Relationship__c tstScoreRelation1 = new Inventory_Score_Relationship__c();
        tstScoreRelation1.Customer__c = acc.id;
        tstScoreRelation1.Inventory_Score_Simulation__c = invScoreSim.id;
        tstScoreRelation1.Part_List__c = part_list.id;
        tstScoreRelation1.Priority__c = '2';
        tstScoreRelation1.L2_Set_Qty__c = 2.0;
        lstRelationship.add(tstScoreRelation1);
        
        insert lstRelationship;
        
        List<Product2> lstproduct = new List<Product2>();
        
        Product2 product2 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = false,
            CurrencyIsoCode = 'USD',
            Part_List__c = part_list.id,
            Product_Level__c = 'L2',
            Quantity__c = 1.0);
        lstproduct.add(product2);
        
        Product2 l2Prod = new Product2(Name = 'PLM-01256-02-SHELL');
        lstproduct.add(l2Prod);    
        
        Product2 l3Prod = new Product2(Name = 'M34-01026O000-0102');
        lstproduct.add(l3Prod);
        
        insert lstproduct;
        
        List<Zone_Priority_Selection__c> lstzone= new List<Zone_Priority_Selection__c>();
        
        Zone_Priority_Selection__c tstZone = new Zone_Priority_Selection__c();
        tstZone.Inventory_Part_List_Relationship__c = lstRelationship[0].Id;
        tstZone.Part_List__c = part_list.id;
        tstZone.Priority__c =1;
        tstZone.Zone_L2__c = product2.id;
        lstzone.add(tstZone);
        
        Zone_Priority_Selection__c tstZone1 = new Zone_Priority_Selection__c();
        tstZone1.Inventory_Part_List_Relationship__c = lstRelationship[1].Id;
        tstZone1.Part_List__c = part_list.id;
        tstZone1.Priority__c =2;
        tstZone1.Zone_L2__c = product2.id;
        lstzone.add(tstZone1);
        insert lstzone;
        
        List<L2_L3_product__c> lstl2l3Product = new List<L2_L3_product__c>();
        
        L2_L3_product__c l2l3Pro = new L2_L3_product__c(Part_List__c = part_list.Id, 
                                                        Product_L2__c= product2.Id,
                                                        Product_L3__c = product2.Id,Quantity__c = 2
                                                       );
            
        lstl2l3Product.add(l2l3Pro);
        L2_L3_product__c l2l3Pro1 = new L2_L3_product__c(Part_List__c = part_list.Id, 
                                                        Product_L2__c= product2.Id,
                                                        Product_L3__c = product2.Id,Quantity__c = 3
                                                       );
        
        lstl2l3Product.add(l2l3Pro1);
        insert lstl2l3Product;
        
        List<Customer_Inventory_Stock__c> lstInventorystock = new List<Customer_Inventory_Stock__c>();
        Customer_Inventory_Stock__c tstStock = new Customer_Inventory_Stock__c();
        tstStock.Item__c = product2.id;
        tstStock.Quantity__c = 5;
        tstStock.Customer__c = acc.id;
        lstInventorystock.add(tstStock);
        
        Customer_Inventory_Stock__c tstStock1 = new Customer_Inventory_Stock__c();
        tstStock1.Item__c = product2.id;
        tstStock1.Quantity__c = 5;
        tstStock1.Customer__c = acc.id;
        lstInventorystock.add(tstStock1);
        
        Customer_Inventory_Stock__c tstStock2 = new Customer_Inventory_Stock__c();
        tstStock2.Item__c = l2Prod.id;
        tstStock2.Quantity__c = 5;
        tstStock2.Customer__c = acc.id;
        lstInventorystock.add(tstStock2);
        
        Customer_Inventory_Stock__c tstStock3 = new Customer_Inventory_Stock__c();
        tstStock3.Item__c = l3Prod.id;
        tstStock3.Quantity__c = 5;
        tstStock3.Customer__c = acc.id;
        lstInventorystock.add(tstStock3);
        
        insert lstInventorystock;
        List<id> idList = new List<Id>();
        idList.add(invScoreSim.Id);
        CalculateScore.calculateScoreForInventory(idList);
    }
}