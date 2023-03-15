global class myHandler implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          EmailMessage em = new EmailMessage();
    
             em.ToAddress = 'vibhuchits22@gmail.com';
             em.subject = email.subject;
             em.status = '3';
             em.CcAddress = 'test@test.com';
             em.TextBody = email.plainTextBody;
             em.HtmlBody = email.htmlBody;
             em.relatedToId = '0017F00001LkUll';
             insert em;
         
          
          
          return result;
      }
  }