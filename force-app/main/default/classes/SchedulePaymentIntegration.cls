global class SchedulePaymentIntegration implements Schedulable {
	global void execute(SchedulableContext sc){
        CreatePaymentDoc.createPaymentDocFromSAP();
     }
}