/*Name : CreatePaymentDoc
Desc : This class used to call SOAP api and get Payment data and create Payment Doc Record.
Called from "SchedulePaymentIntegration" Apex Class as this is meant to be schedulable job
Author : */

global class CreatePaymentDoc {
	
    @future(callout = true)
    public static void createPaymentDocFromSAP(){
        Integration_Transaction__c it = new Integration_Transaction__c();
        try{
            //Making a connection
            //Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
            PaymentQASWSDL.ZWS_INV_PAY_DETAILS_V2 zwPaymentDetails = new PaymentQASWSDL.ZWS_INV_PAY_DETAILS_V2();
            //Blob headerValue = Blob.valueOf(sapOrg.Username__c+ ':' + sapOrg.Password__c);
            Blob headerValue = Blob.valueOf('rfcuser1'+ ':' + 'Tega@1234');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            zwPaymentDetails.inputHttpHeaders_x = new map<String,String>();
            zwPaymentDetails.inputHttpHeaders_x.put('Authorization', authorizationHeader);
            
            //Fetching Data from SAP
            PaymentQASWSDL.ZinvPayDetailsResponse_element getDetailsResponse = new PaymentQASWSDL.ZinvPayDetailsResponse_element();
            PaymentQASWSDL.ZpayHdrLn paymentHeaderFields = new PaymentQASWSDL.ZpayHdrLn();
            PaymentQASWSDL.ZpayDocLn paymentItemFields = new PaymentQASWSDL.ZpayDocLn();
            PaymentQASWSDL.ZrevDocLn reverseDocFields = new PaymentQASWSDL.ZrevDocLn();
            List<PaymentQASWSDL.ZpayHdr> paymentHeaderFieldsList = new List<PaymentQASWSDL.ZpayHdr>();
            List<PaymentQASWSDL.ZpayDoc> paymentItemFieldsList = new List<PaymentQASWSDL.ZpayDoc>();
            List<PaymentQASWSDL.ZrevDoc> reverseDocFieldsList = new List<PaymentQASWSDL.ZrevDoc>();            
            getDetailsResponse = zwPaymentDetails.ZinvPayDetails('2021-07-01','10:00:00','2021-07-01','14:00:00');
      
            //AK Changes 06/12/2022
            String responseMsg = getDetailsResponse.ExMessage;
            if(responseMsg != ''){
                it.Status__c = 'fail';
                it.Error__c = responseMsg;
                update it;
            }else{
                /*DateTime todaysDate = System.today();
                String todaysDateStr = todaysDate.format('yyyy-MM-dd');
                String currentTime = String.valueOf(system.now());
                datetime newMinusDate =system.now() - (1/24);
                String currentTime2 = String.valueOf(newMinusDate);
                String formattedTime = currentTime.substringAfter(' ');
                String formattedTimeMinusOne = currentTime2.substringAfter(' ');
                getDetailsResponse = zwPaymentDetails.ZinvPayDetails(todaysDateStr,formattedTimeMinusOne,todaysDateStr,formattedTime);*/
                    
                it.Response__c = String.valueOf(getDetailsResponse); 
                paymentHeaderFields = getDetailsResponse.ExPayHdr;
                paymentItemFields = getDetailsResponse.ExPayItm;
                reverseDocFields = getDetailsResponse.ExReverseDoc;
                paymentHeaderFieldsList = paymentHeaderFields.item;
                paymentItemFieldsList = paymentItemFields.item;
                reverseDocFieldsList = reverseDocFields.item;
                system.debug('paymentHeaderFieldsList==>'+paymentHeaderFieldsList);
                system.debug('paymentItemFieldsList==>'+paymentItemFieldsList);
                system.debug('reverseDocFieldsList==>'+reverseDocFieldsList);
                
                // First we will check Reverse Code Case, if reverse values are coming then update it in relative Payment Doc Record
                List<String> uniqIdentRevList = new List<String>();
                List<Payment_Doc__c> revPDList = new List<Payment_Doc__c>();
                if(reverseDocFieldsList != null){
                    for(PaymentQASWSDL.ZrevDoc rd : reverseDocFieldsList){
                        if(rd != null){
                            String uniqIdent = rd.CompCode + '-' + rd.PmtDocNo + '-' + rd.PmtDocPostDate;
                            uniqIdentRevList.add(uniqIdent);
                        }
                    }
                
                    system.debug('uniqIdentRevList=>'+uniqIdentRevList);
                    
                    List<Payment_Doc__c> getRelatedPD = [Select Id,Unique_Key__c,Company_Code__c,PMT_Doc_Number__c,Posting_Date__c from Payment_Doc__c WHERE Unique_Key__c IN: uniqIdentRevList];
                    system.debug('getRelatedPD=>'+getRelatedPD);  
                    List<Payment_Doc__c> toUpdatePDList = new List<Payment_Doc__c>();
                    if(getRelatedPD != null){
                        for(PaymentQASWSDL.ZrevDoc rd : reverseDocFieldsList){
                            for(Payment_Doc__c pd : getRelatedPD){
                                String uniqIdentRD = rd.CompCode + '-' + rd.PmtDocNo + '-' + rd.PmtDocPostDate;
                                String dateCustom = String.valueOf(pd.Posting_Date__c);
                                String uniqIdentPD = pd.Company_Code__c + '-' + pd.PMT_Doc_Number__c + '-' + dateCustom;
                                system.debug('uniqIdentRD'+uniqIdentRD);
                                system.debug('uniqIdentPD'+uniqIdentPD);
                                
                                
                                if(uniqIdentRD == uniqIdentPD){
                                    pd.Reverse_Doc__c = true;
                                    pd.Reverse_PMT_Doc_Number__c = decimal.valueOf(rd.ReversePmtDocNo);
                                    if(rd.ReverseDate != '0000-00-00'){
                                        pd.Reverse_Date__c = Date.valueOf(rd.ReverseDate);
                                    }
                                    pd.Reverse_Entry_Date__c = Date.valueOf(rd.RevEntryDate);
                                    toUpdatePDList.add(pd);
                                }
                            }
                        }
                        update toUpdatePDList;
                    }
                }          
                
                List<Payment_Doc__c> paymentDocList = new List<Payment_Doc__c>();
                List<Invoice_Payment_Relationship__c> invPmtRelList = new List<Invoice_Payment_Relationship__c>();
                List<String> uniqIdentList = new List<String>();
                
                for(PaymentQASWSDL.ZpayHdr pd : paymentHeaderFieldsList){
                    String uniqIdent = pd.CompCode + '-' + pd.PmtDocNo + '-' + pd.PostingDate;
                    uniqIdentList.add(uniqIdent);
                }
                system.debug('uniqIdentList=>'+uniqIdentList);
                
                List<Payment_Doc__c> existingPDList = [Select Id,Unique_Key__c,Company_Code__c,PMT_Doc_Number__c,Posting_Date__c from Payment_Doc__c where Unique_Key__c IN: uniqIdentList];
                system.debug('existingPDList=>'+existingPDList);
                List<Payment_Doc__c> dupPDList = new List<Payment_Doc__c>();
                
                for(String str : uniqIdentList){
                    for(Payment_Doc__c pd : existingPDList){
                        if(pd.Unique_Key__c == str){
                            dupPDList.add(pd);
                        }
                    }
                }
                system.debug('dupPDList=>'+dupPDList);
                
                
                for(PaymentQASWSDL.ZpayHdr pd : paymentHeaderFieldsList){
                    Payment_Doc__c tempPD = new Payment_Doc__c();
                    tempPD.Fiscal_Year__c = Decimal.valueOf(pd.FiscalYear);
                    tempPD.Bank_Name__c = pd.BankName;
                    tempPD.Bank_Reference_Number__c = pd.BankRefNo;
                    tempPD.Company_Code__c = pd.CompCode;
                    tempPD.Entry_Time__c = pd.EntryTime;
                    if(pd.EntryDate != '0000-00-00'){
                        tempPD.Entry_Date__c = Date.valueOf(pd.EntryDate);
                    }
                    tempPD.PMT_Doc_Number__c = pd.PmtDocNo;
                    if(pd.PostingDate != '0000-00-00'){
                        tempPD.Posting_Date__c = Date.valueOf(pd.PostingDate);
                    }
                    paymentDocList.add(tempPD);
                }
                
                List<Payment_Doc__c> updatePDList = new List<Payment_Doc__c>();
                List<Payment_Doc__c> insertPDList = new List<Payment_Doc__c>();
                List<String> uniqueIdentListofUpdate = new List<String>();
                
                for(Payment_Doc__c tempPd1 : paymentDocList){
                    for(Payment_Doc__c tempPd2 : dupPDList){
                        String dateCustom1 = String.valueOf(tempPd1.Posting_Date__c);
                        String dateCustom2 = String.valueOf(tempPd2.Posting_Date__c);
                        String uniqIdent1 = tempPd1.Company_Code__c + '-' + tempPd1.PMT_Doc_Number__c + '-' + dateCustom1;
                        String uniqIdent2 = tempPd2.Company_Code__c + '-' + tempPd2.PMT_Doc_Number__c + '-' + dateCustom2;
                        system.debug('uniqIdent1=>'+uniqIdent1);
                        system.debug('uniqIdent2=>'+uniqIdent2);
                        if(uniqIdent1 == uniqIdent2){
                            updatePDList.add(tempPd2);
                            uniqueIdentListofUpdate.add(uniqIdent1);
                        }
                    }
                }
                
                for(Payment_Doc__c tempPd1 : paymentDocList){
                    String dateCustom = String.valueOf(tempPd1.Posting_Date__c);
                    String uniqIdent1 = tempPd1.Company_Code__c + '-' + tempPd1.PMT_Doc_Number__c + '-' + dateCustom;
                    tempPd1.Name = uniqIdent1;
                    system.debug('uniqIdent1=>'+uniqIdent1);
                    Boolean isUniq = false;
                    if(uniqueIdentListofUpdate.size() > 0){
                        for(String str : uniqueIdentListofUpdate){
                            if(uniqIdent1 != str){
                                isUniq = true;
                            }else{
                                isUniq = false;
                                break;
                            }
                        }
                    }else{
                        isUniq = true;
                    }
                    
                    if(isUniq == true){
                        system.debug('INSERTING');
                        insertPDList.add(tempPd1);
                    }
                }
                
                system.debug('updatePDList==>'+updatePDList);
                system.debug('insertPDList==>'+insertPDList);
                if(insertPDList.size() > 0){
                    insert insertPDList;
                }
                if(updatePDList.size() > 0){
                    update updatePDList;
                }
                
                // Now from here we will make logic to insert line item and tag to their parent payment
                List<Payment_Doc_Line__c> paymentDocLineList = new List<Payment_Doc_Line__c>();
                List<String> invoiceNumList = new List<String>();
                Set<String> uniqIdentLineSet = new Set<String>();
                
                for(PaymentQASWSDL.ZpayDoc pdLine : paymentItemFieldsList){
                    String uniqIdent = pdLine.CompCode + '-' + pdLine.PmtDocNo + '-' + pdLine.PostingDate;
                    uniqIdentLineSet.add(uniqIdent);
                }
                
                system.debug('uniqIdentLineSet=>'+uniqIdentLineSet);
                
                List<Payment_Doc_Line__c> existingPDLineList = [Select Id,Unique_Key__c,Company_Code__c,PMT_Doc_Number_c__c,Posting_Date__c from Payment_Doc_Line__c where Unique_Key__c IN: uniqIdentLineSet];
                system.debug('existingPDLineList=>'+existingPDLineList);
                List<Payment_Doc_Line__c> dupPDLineList = new List<Payment_Doc_Line__c>();
                
                for(String str : uniqIdentLineSet){
                    for(Payment_Doc_Line__c pd : existingPDLineList){
                        if(pd.Unique_Key__c == str){
                            dupPDLineList.add(pd);
                        }
                    }
                }
                system.debug('dupPDLineList=>'+dupPDLineList);
                
                for(PaymentQASWSDL.ZpayDoc pdLine : paymentItemFieldsList){
                    Payment_Doc_Line__c tempPDLine = new Payment_Doc_Line__c();
                    Invoice_Payment_Relationship__c invPmtRel = new Invoice_Payment_Relationship__c();
                    if(pdLine.AdvPmtInd == 'X'){
                        tempPDLine.Advance_Payment__c = true;
                    }
                    tempPDLine.Fiscal_Year__c = Decimal.valueOf(pdLine.FiscalYear);
                    tempPDLine.Company_Code__c = pdLine.CompCode;
                    tempPDLine.CurrencyIsoCode = pdLine.DocCurrency;
                    tempPDLine.Payment_Amount__c = decimal.valueOf(pdLine.PayAmtDc);
                    tempPDLine.PMT_Doc_Number_c__c = pdLine.PmtDocNo;
                    if(pdLine.PostingDate != '0000-00-00'){
                        tempPDLine.Posting_Date__c = Date.valueOf(pdLine.PostingDate);
                    }
                    //tempPDLine.Posting_Date__c = Date.valueOf(pdLine.PostingDate);
                    tempPDLine.SAP_Invoice_Number__c = pdLine.InvNo;
                    tempPDLine.SO_Number__c = pdLine.SoNo;
                    invoiceNumList.add(pdLine.InvNo);
                    paymentDocLineList.add(tempPDLine);
                }
                
                system.debug('paymentDocLineList ===>'+paymentDocLineList);
                
                // Logic to link Payment Line item with Payment
                List<Payment_Doc__c> paymentList = [Select Id,Unique_Key__c,Company_Code__c,PMT_Doc_Number__c,Posting_Date__c from Payment_Doc__c where Unique_Key__c IN: uniqIdentLineSet];
                for(Payment_Doc__c pd : paymentList){
                    for(Payment_Doc_Line__c pdLine : paymentDocLineList){
                        String dateCustom = String.valueOf(pdLine.Posting_Date__c);
                        String dateCustom2 = String.valueOf(pd.Posting_Date__c);
                        String uniqIdent1 = pdLine.Company_Code__c + '-' + pdLine.PMT_Doc_Number_c__c + '-' + dateCustom;
                        String uniqIdent2 = pd.Company_Code__c + '-' + pd.PMT_Doc_Number__c + '-' + dateCustom2;
                        system.debug('uniqIdent1=>'+uniqIdent1);
                        system.debug('uniqIdent2=>'+uniqIdent2);
                        if(uniqIdent1 == uniqIdent2){
                            pdLine.Payment_Doc__c = pd.Id;
                        }
                    }
                }
                
                /////////////////////////////////////////////////////////////
                
                List<Payment_Doc_Line__c> updatePDLineList = new List<Payment_Doc_Line__c>();
                List<Payment_Doc_Line__c> insertPDLineList = new List<Payment_Doc_Line__c>();
                List<String> uniqueIdentLineListofUpdate = new List<String>();
                
                for(Payment_Doc_Line__c tempPdLine1 : paymentDocLineList){
                    for(Payment_Doc_Line__c tempPdLine2 : dupPDLineList){
                        String dateCustom1 = String.valueOf(tempPdLine1.Posting_Date__c);
                        String dateCustom2 = String.valueOf(tempPdLine2.Posting_Date__c);
                        String uniqIdent1 = tempPdLine1.Company_Code__c + '-' + tempPdLine1.PMT_Doc_Number_c__c + '-' + dateCustom1;
                        String uniqIdent2 = tempPdLine2.Company_Code__c + '-' + tempPdLine2.PMT_Doc_Number_c__c + '-' + dateCustom2;
                        system.debug('uniqIdent1=>'+uniqIdent1);
                        system.debug('uniqIdent2=>'+uniqIdent2);
                        if(uniqIdent1 == uniqIdent2){
                            updatePDLineList.add(tempPdLine2);
                            uniqueIdentLineListofUpdate.add(uniqIdent1);
                        }
                    }
                }
                
                for(Payment_Doc_Line__c tempPdLine1 : paymentDocLineList){
                    String dateCustom = String.valueOf(tempPdLine1.Posting_Date__c);
                    String uniqIdent1 = tempPdLine1.Company_Code__c + '-' + tempPdLine1.PMT_Doc_Number_c__c + '-' + dateCustom;
                    system.debug('uniqIdent1=>'+uniqIdent1);
                    Boolean isUniq = false;
                    if(uniqueIdentLineListofUpdate.size() > 0){
                        for(String str : uniqueIdentLineListofUpdate){
                            if(uniqIdent1 != str){
                                isUniq = true;
                            }else{
                                isUniq = false;
                                break;
                            }
                        }
                    }else{
                        isUniq = true;
                    }
                    
                    if(isUniq == true){
                        system.debug('INSERTING LINE');
                        insertPDLineList.add(tempPdLine1);
                    }
                }
                
                system.debug('updatePDLineList==>'+updatePDLineList);
                system.debug('insertPDLineList==>'+insertPDLineList);
                if(insertPDList.size() > 0){
                    insert insertPDLineList;
                }
                if(updatePDList.size() > 0){
                    update updatePDLineList;
                }
                
                /////////////////////////////////////////////
                
                // Logic to link Invoice with Payment Line Item
                List<Invoice__c> invoiceList = [Select Id,SAP_Invoice_Number__c from Invoice__c where SAP_Invoice_Number__c IN: invoiceNumList];
                
                system.debug('invoiceList===>'+invoiceList);
                
                Integer uniqueKeyJunc = 0;
                for(Payment_Doc_Line__c tempPDLine : paymentDocLineList){
                    uniqueKeyJunc = 0;
                    system.debug('Count tempPDLine');
                    for(Invoice__c inv : invoiceList){
                        if(uniqueKeyJunc == 0){
                            system.debug('tempPDLine.SAP_Invoice_Number__c'+tempPDLine.SAP_Invoice_Number__c);
                            system.debug('inv.SAP_Invoice_Number__c'+inv.SAP_Invoice_Number__c);
                            if(tempPDLine.SAP_Invoice_Number__c == inv.SAP_Invoice_Number__c){
                                Invoice_Payment_Relationship__c invPmtRel = new Invoice_Payment_Relationship__c();
                                invPmtRel.Invoice__c = inv.Id;
                                invPmtRel.Payment_Doc_Line__c = tempPDLine.Id;
                                invPmtRel.Payment_Doc_Number__c = tempPDLine.PMT_Doc_Number_c__c;
                                system.debug('Current INV =>'+invPmtRel);
                                invPmtRelList.add(invPmtRel);
                                uniqueKeyJunc++;
                            }
                        }
                    }
                }
                
                system.debug('invPmtRelList==>'+invPmtRelList);
                
                Set<Id> invoiceIdSet = new Set<Id>();
                Set<Id> pmtDocLineSet = new Set<Id>();
                for(Invoice_Payment_Relationship__c invPmtRel : invPmtRelList){
                    invoiceIdSet.add(invPmtRel.Invoice__c);
                    pmtDocLineSet.add(invPmtRel.Payment_Doc_Line__c);
                }
                
                List<Invoice_Payment_Relationship__c> existingInvPmtRel = [Select Id,Invoice__c,Payment_Doc_Line__c 
                                                                           from Invoice_Payment_Relationship__c 
                                                                           WHERE Invoice__c IN: invoiceIdSet 
                                                                           AND Payment_Doc_Line__c IN: pmtDocLineSet];
                
                system.debug('existingInvPmtRel =>'+existingInvPmtRel);
                
                List<Invoice_Payment_Relationship__c> invPmtRelListToInsert = new List<Invoice_Payment_Relationship__c>();
                
                for(Invoice_Payment_Relationship__c invPmtRel : invPmtRelList){
                    for(Payment_Doc_Line__c pdLine : insertPDLineList){
                        if(pdLine.Id == invPmtRel.Payment_Doc_Line__c){
                            invPmtRelListToInsert.add(invPmtRel);
                        }	
                    }
                }
                
                system.debug('invPmtRelListToInsert'+invPmtRelListToInsert);
                insert invPmtRelListToInsert;
    
                it.Status__c = 'Success';
                it.sync__c = true;
                insert it;
            }
            
            
            
        }catch(Exception ex){
            it.Status__c = 'fail';
			it.Error__c = ex.getMessage()+ex.getLineNumber();
            insert it;
            TegaUtility.trackLogs( ex,  'CreatePaymentDoc',  'createPaymentDocFromSAP');
        }
    }
}