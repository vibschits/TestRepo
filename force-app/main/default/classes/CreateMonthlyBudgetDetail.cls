public class CreateMonthlyBudgetDetail {
    
    @InvocableMethod (label = 'Create Monthly Budget Detail' description = 'returns nothing')
	public static void createMonthlyBudgetDetailMethod (List<ID> ids){
        
        // Even though we are receiving list of id, we will always receive only one id from flow
        List<L2_Budget_Line_Item__c> budgetLineItemList = [SELECT Id, Name,Budget__c,L2_Projected_Budget__c,Product_L2__c,Product_L2__r.Name,Installation_Date__c,
                                                           Life_Months__c, Lead_Time_Months__c, Transit_Time_Months__c, Negotitation_Time_Months__c 
                                                           FROM L2_Budget_Line_Item__c WHERE Id IN: ids];
        system.debug('budgetLineItemList =>'+budgetLineItemList);
        
        Budget__c budget = [Select Id,Part_List__c,Budget_For_Financial_Year__c,Concurrent_Year__c,Inventory_Part_List_Relationship__c,Financial_Year__c 
                            from Budget__c where Id =: budgetLineItemList[0].Budget__c];
        system.debug('budget =>'+budget);
        
		/*Product2 pl = [Select Id, Life_Monts__c, Lead_Time_Months__c, Transit_Time_Months__c, Negotitation_Time_Months__c from Product2
                          where Id =: budgetLineItemList[0].Product_L2__c];
        system.debug('pl =>'+pl);*/
        
        Decimal lifeMonths = budgetLineItemList[0].Life_Months__c;
        Decimal transitimeMonths = budgetLineItemList[0].Transit_Time_Months__c;
        Decimal negotitationimeMonths = budgetLineItemList[0].Negotitation_Time_Months__c;
        Decimal leadTimeMonths = budgetLineItemList[0].Lead_Time_Months__c;
        
        Decimal orderMonth = lifeMonths - (transitimeMonths + negotitationimeMonths + leadTimeMonths);
        system.debug('orderMonth =>'+orderMonth);
        
        Map<String,Decimal> monthsMap = new Map<String,Decimal>();
        monthsMap.put('April',1);
        monthsMap.put('May',2);
        monthsMap.put('June',3);
        monthsMap.put('July',4);
        monthsMap.put('August',5);
        monthsMap.put('September',6);
        monthsMap.put('October',7);
        monthsMap.put('November',8);
        monthsMap.put('December',9);
        monthsMap.put('January',10);
        monthsMap.put('February',11);
        monthsMap.put('March',12);
        
        Integer lifeMonthInt = (Integer)lifeMonths;
        
        Map<String,Decimal> monthlyBudDetMap= new Map<String,Decimal>();
        
        Integer monthCounter = 1;
        String financialYear = budget.Financial_Year__c;
        String[] financialYearArray = financialYear.split('-');
        String currentYear = financialYearArray[0]; 
        String nextYear = financialYearArray[1]; 
        
        Integer monthMultiplier = 0;
        
        if(budget.Budget_For_Financial_Year__c == 'Current FY Year'){
            
            Date installationDate = budgetLineItemList[0].Installation_Date__c;
            DateTime currentDT = installationDate;
            //DateTime currentDT = Datetime.newInstance(2023, 5, 13);
            String currentMonth = currentDT.format('MMMM');
            system.debug('currentMonth =>'+currentMonth);
            Decimal currentMonthVal = monthsMap.get(currentMonth);
            system.debug('currentMonthVal =>'+currentMonthVal);
            
            Decimal salesDate = currentMonthVal + lifeMonths;
            system.debug('salesDate =>'+salesDate);
            
            while(salesDate <= 12){
                //valid case as current month + life is inside this financial year
                 
                Integer orderMonthInt = (Integer)orderMonth + (monthMultiplier*lifeMonthInt);
                system.debug('orderMonthInt =>'+orderMonthInt);
                DateTime ordDateTime = currentDT.addMonths(orderMonthInt);
                system.debug('ordDateTime =>'+ordDateTime);
                String ordMonth = ordDateTime.format('MMMM');
                monthlyBudDetMap.put(ordMonth,budgetLineItemList[0].L2_Projected_Budget__c);
                system.debug('monthlyBudDetMap =>'+monthlyBudDetMap);
                salesDate += lifeMonths;
                monthMultiplier++;
            }
        }/*else{
            DateTime currentDT = System.now();
            Integer orderMonthInt = (Integer)orderMonth;
            
            DateTime loopDT = System.now();
            String loopDTYear = loopDT.format('yyyy');
            
            while(loopDTYear != budget.Concurrent_Year__c){

                String ordMonth = currentDT.format('MMMM');
                if((ordMonth == currentYear && ordMonth != 'January' && ordMonth != 'February' && ordMonth != 'March') 
                   || (ordMonth == nextYear && (ordMonth == 'January' || ordMonth == 'February' || ordMonth == 'March'))){
                    
                       DateTime ordDateTime = currentDT.addMonths(orderMonthInt) + (monthMultiplier*lifeMonthInt);
                       system.debug('ordDateTime =>'+ordDateTime);
                       String ordMonth2 = ordDateTime.format('MMMM');
                       monthlyBudDetMap.put(ordMonth2,budgetLineItemList[0].L2_Projected_Budget__c);
                       system.debug('monthlyBudDetMap =>'+monthlyBudDetMap);
                       monthMultiplier++;
                }
                loopDT = loopDT.addMonths(lifeMonthInt);
                loopDTYear = loopDT.format('yyyy');  
            }
        }*/
		
        Zone_Priority_Selection__c zps = [SELECT Id, Name, Inventory_Part_List_Relationship__c, Part_List__c, Score__c, Zone_L2Name__c, Zone_L2__c 
                                              FROM Zone_Priority_Selection__c 
                                              WHERE Inventory_Part_List_Relationship__c =: budget.Inventory_Part_List_Relationship__c 
                                              AND Zone_L2Name__c =: budgetLineItemList[0].Product_L2__r.Name];
        system.debug('zps =>'+zps);
        
        List<Monthly_Budget_Detail__c> monthBudDetList = new List<Monthly_Budget_Detail__c>();

        
        for(String str : monthsMap.keySet()){           
            Monthly_Budget_Detail__c monthlyBudDetRec = new Monthly_Budget_Detail__c();
             if(monthCounter <= 9){
                 monthlyBudDetRec.Name = str + '-' + currentYear;
             }else{
                 monthlyBudDetRec.Name = str + '-' + nextYear;
             }
            monthCounter++;
            monthlyBudDetRec.L2_Budget_Line_Item__c = budgetLineItemList[0].Id;
            
            if(!monthlyBudDetMap.containsKey(str)){
                monthlyBudDetRec.Value__c = 0;
            }
            monthBudDetList.add(monthlyBudDetRec);
        }
        
        List<Monthly_Budget_Detail__c> monthBudDetListNonZero = new List<Monthly_Budget_Detail__c>();
        for(Monthly_Budget_Detail__c monthBudDetRec : monthBudDetList){
            if(monthBudDetRec.Value__c != 0){
                monthBudDetListNonZero.add(monthBudDetRec);
            }
        }
        
        Map<String,Decimal> tempMap = new Map<String,Decimal>();

        Decimal scorebyHundred = zps.Score__c/100;
        system.debug('scorebyHundred =>'+scorebyHundred);
        Integer scorebyHundredInt = (Integer)scorebyHundred;
        system.debug('scorebyHundredInt =>'+scorebyHundredInt);
        for(Integer i=scorebyHundredInt; i<monthBudDetListNonZero.size(); i++){
            if(i == scorebyHundredInt){
                Decimal netVal = scorebyHundred - (Decimal)scorebyHundredInt;
                Decimal finalItemVal = budgetLineItemList[0].L2_Projected_Budget__c - (budgetLineItemList[0].L2_Projected_Budget__c * netVal);
                tempMap.put(monthBudDetListNonZero[i].Name,finalItemVal);
            }else{
                tempMap.put(monthBudDetListNonZero[i].Name,budgetLineItemList[0].L2_Projected_Budget__c);
            }
        } 
        
        // This for loop is added so that all items are inserted in organized order
        for(Monthly_Budget_Detail__c monthBudDetRec : monthBudDetList){
            if(tempMap.containsKey(monthBudDetRec.Name)){
                monthBudDetRec.Value__c = tempMap.get(monthBudDetRec.Name);
            }
        }
        
        system.debug('monthBudDetList =>'+monthBudDetList);
        insert monthBudDetList;
    }
}