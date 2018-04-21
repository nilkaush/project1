global with sharing class DocusignTemplate implements TF4SF.DSP_Interface{
            
    global Map<String,String> main(Map<String,String> tdata){
        Map<String,String> data = tdata.clone();
        String envelopeId;
        String accountId;
        String userId;
        String password;
        String integratorsKey;
        String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx';
        
        try{
            String appId = data.get('id');
            System.debug('appId = '+appId);
            TF4SF.Logger.inputSource('Docusign class',appId);
            Set<String> fieldsToDisplay = new Set<String>(); // This string is used to contain the fields received from Utility class.
            TF4SF.DSPUtility u= new TF4SF.DSPUtility(); 
            TF4SF.RequiredFieldsUtility rfu= new TF4SF.RequiredFieldsUtility();
            fieldsToDisplay = u.fieldsToRender(appId);
            System.debug('fieldsToDisplay size = '+fieldsToDisplay.size());            
            TF4SF__Application__c app = [Select TF4SF__First_Name__c,TF4SF__Last_Name__c,TF4SF__First_Name_J__c,TF4SF__Last_Name_J__c,TF4SF__First_Name_J2__c,TF4SF__Last_Name_J2__c,TF4SF__First_Name_J3__c,TF4SF__Last_Name_J3__c, TF4SF__Email_Address__c,TF4SF__Email_Address_J__c,TF4SF__Email_Address_J2__c,TF4SF__Email_Address_J3__c,TF4SF__First_Joint_Applicant__c,TF4SF__Second_Joint_Applicant__c,TF4SF__Third_Joint_Applicant__c from TF4SF__Application__c where id = :appId];

            TF4SF__Application_Configuration__c ac = TF4SF__Application_Configuration__c.getOrgDefaults();

            Integer noOfApplicants = 1;
            if(ac.Call_Joint_Docusign__c == true){
                if (app.TF4SF__First_Joint_Applicant__c == true){
                    noOfApplicants = 2;
                } else if (app.TF4SF__Second_Joint_Applicant__c == true) {
                    noOfApplicants = 3;
                } else if (app.TF4SF__Third_Joint_Applicant__c == true) {
                    noOfApplicants = 4;
                }
            }
            /*List<DocuSignAPI.Document> set_docs = new List<DocuSignAPI.Document>();*/
            Docusign_Config__c cred = Docusign_Config__c.getOrgDefaults();        
            if(cred!= NULL){
                accountId = cred.AccountID__c;
                userId = cred.Username__c;
                password = cred.Password__c;
                integratorsKey = cred.IntegratorKey__c ;
            }    
                    
            DocuSignAPI.APIServiceSoap dsApiSend = new DocuSignAPI.APIServiceSoap();
            dsApiSend.endpoint_x = webServiceUrl;
            dsApiSend.timeout_x = 120000;

            //Set Authentication
            String auth = '<DocuSignCredentials><Username>'+ userId +'</Username><Password>' + password + '</Password><IntegratorKey>' + integratorsKey + '</IntegratorKey></DocuSignCredentials>';
            System.debug('Setting authentication to: ' + auth);
                
            dsApiSend.inputHttpHeaders_x = new Map<String, String>();
            dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);

            DocuSignAPI.EnvelopeInformation envelopeInfo = new DocuSignAPI.EnvelopeInformation();
            envelopeInfo.Subject = 'Please Sign this Disclosure';
            envelopeInfo.EmailBlurb = 'Dear ' + app.TF4SF__First_Name__c + ', ' + 'This is my new eSignature service,'+ 'it allows me to get your signoff without having to fax, ' + 'scan, retype, refile and wait forever';
            envelopeInfo.AccountId  = accountId; 

            
            DocuSignAPI.ArrayOfCompositeTemplate arrayCT = new DocuSignAPI.ArrayOfCompositeTemplate();

            List<TF4SF__Disclosure_Names__c>  ddn = TF4SF__Disclosure_Names__c.getall().values();
            List<TF4SF__Disclosure__c> discList = new List<TF4SF__Disclosure__c>();
            /*List<String> DiscNameList = new List<String>();
              for(TF4SF__Disclosure_Names__c dn : ddn){    
                if(fieldsToDisplay.contains(dn.Name+'__c')){
                      String DiscName = TF4SF__Disclosure_Names__c.getValues(dn.Name).TF4SF__Disclosure_Label__c + ' - DS';
                      system.debug('The disc name is '+DiscName);
                    DiscNameList.add(DiscName);    
                }     
              }
              system.debug('the size of the Disclosure Names is '+DiscNameList.size());
              for(Integer i = 0; i< DiscNameList.size();i++){
                List<TF4SF__Disclosure__c> d = [SELECT Id,name,Template_ID__c FROM TF4SF__Disclosure__c WHERE Name = :DiscNameList[i] LIMIT 1];
                if (d.size()> 0) {
                  System.debug('d = '+d);
                  DiscList.add(d[0]);  
                }
              }
              system.debug('the size of the Disclosure is '+DiscList.size());*/

            for(integer i=0; i < ddn.size(); i++){
              //system.debug('the value of i ' +i);
              if(fieldsToDisplay.contains(ddn[i].Name+'__c')){  
                  //discList = [SELECT Id,name,Template_ID__c,Joint1_Template_ID__c,Joint2_Template_ID__c,Joint3_Template_ID__c FROM TF4SF__Disclosure__c WHERE Template_ID__c != NULL AND Joint1_Template_ID__c != NUll];
                List<TF4SF__Disclosure__c> d = [SELECT Id,name,Template_ID__c FROM TF4SF__Disclosure__c WHERE Name = :(TF4SF__Disclosure_Names__c.getValues(ddn[i].Name).TF4SF__Disclosure_Label__c + ' - DS')];
                if(d.size()>0) {
                  System.debug('d = '+d);
                  discList.add(d[0]);  
                }
              }     
            }
            system.debug('the size of the Disclosure '+discList.size());
            
            List<String> tIdList = new List<String>();
                    
            for(TF4SF__Disclosure__c disc : discList){
                if(noOfApplicants == 1){
                    tIdList.add(disc.Template_ID__c); 
                }else if(noOfApplicants == 2){
                    tIdList.add(disc.Joint1_Template_ID__c); 
                }else if(noOfApplicants == 3){
                    tIdList.add(disc.Joint2_Template_ID__c); 
                }else if(noOfApplicants == 4){
                    tIdList.add(disc.Joint3_Template_ID__c); 
                }
            }
            system.debug('the size of the Template Id\'s '+tIdList.size());
                    
            if (tIdList.size()>0) {
                List<DocusignAPI.CompositeTemplate> templateList = new List<DocusignAPI.CompositeTemplate>();
                List<DocuSignAPI.Recipient> recipientList = new List<DocuSignAPI.Recipient>();
                for(integer j=0; j<tIdList.size(); j++){
                    DocusignAPI.CompositeTemplate template = new DocusignAPI.CompositeTemplate();

                    for(integer h=1; h<=noOfApplicants; h++ ){
                        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
                        recipient.ID = h;
                        recipient.Type_x = 'Signer';
                        recipient.RoutingOrder = h;
                        recipient.RequireIDLookup = false;
                        recipient.RoleName = 'Signer'+' '+h;
                        if (h == 1){
                            recipient.Email = app.TF4SF__Email_Address__c;
                            recipient.UserName = app.TF4SF__First_Name__c + ' ' + app.TF4SF__Last_Name__c;    
                        }else if (h == 2){
                            recipient.Email = app.TF4SF__Email_Address_J__c;
                            recipient.UserName = app.TF4SF__First_Name_J__c + ' ' + app.TF4SF__Last_Name_J__c;    
                        } else if (h == 3){
                            recipient.Email = app.TF4SF__Email_Address_J2__c;
                            recipient.UserName = app.TF4SF__First_Name_J2__c + ' ' + app.TF4SF__Last_Name_J2__c;  
                        } else if (h == 4){
                            recipient.Email = app.TF4SF__Email_Address_J3__c;
                            recipient.UserName = app.TF4SF__First_Name_J3__c + ' ' + app.TF4SF__Last_Name_J3__c;  
                        }   
                        recipientList.add(recipient);
                    }

                    DocuSignAPI.ServerTemplate serverTemplate = new DocuSignAPI.ServerTemplate();
                    serverTemplate.Sequence = 1;
                    serverTemplate.TemplateID = tIdList.get(j);
                   
                    template.ServerTemplates = new DocuSignAPI.ArrayOfServerTemplate();
                    template.ServerTemplates.ServerTemplate = new DocuSignAPI.ServerTemplate[1];
                    template.ServerTemplates.ServerTemplate[0] = serverTemplate;
                    
                    DocuSignAPI.InlineTemplate inlineTemplate = new DocuSignAPI.InlineTemplate();
                    inlineTemplate.Sequence = 2;
                    inlineTemplate.Envelope = new DocuSignAPI.Envelope();
                    
                    inlineTemplate.Envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
                    inlineTemplate.Envelope.Recipients.Recipient = new DocuSignAPI.Recipient[noOfApplicants];
                    for(integer l=0;l<noOfApplicants;l++){
                        inlineTemplate.Envelope.Recipients.Recipient[l] = recipientList[l];
                    }
                    inlineTemplate.Envelope.AccountId = accountId;


                    template.InlineTemplates = new DocuSignAPI.ArrayOfInlineTemplate();
                    template.InlineTemplates.InlineTemplate = new DocuSignAPI.InlineTemplate[1];
                    template.InlineTemplates.InlineTemplate[0] = inlineTemplate;

                    templateList.add(template);
                }
                
                arrayCT.CompositeTemplate = new DocuSignAPI.CompositeTemplate[tIdList.size()];
                for(integer k=0; k<tIdList.size(); k++){
                    arrayCT.CompositeTemplate[k] = templateList[k];
                }
            }
             
            System.debug('Calling the API');
            String mssg;
            try {
                if(!Test.isRunningTest()){
                    TF4SF.Logger.addMessage('Making API call',system.now().format());
                    DocuSignAPI.EnvelopeStatus es = dsApiSend.CreateEnvelopeFromTemplatesAndForms(envelopeInfo,arrayCT,true);
                    system.debug('the value of ES is '+es);
                    app.Docusign_EnvelopeID__c  = es.EnvelopeID;
                }
                update app;
                mssg = 'Success';
            } catch ( CalloutException e) {
                System.debug('Exception - ' + e.getMessage());
                mssg = 'Failed';
                TF4SF.Logger.addMessage('Exception: '+ e + '; ' + e.getLineNumber(), system.now().format());
            }
            TF4SF.Logger.writeAllLogs();
            data.put('Docusign response', mssg);
            return data;
        }
        Catch(exception e){
            System.debug('Exception while sending docusign '+e.getLineNumber());
            TF4SF.Logger.addMessage('Exception: '+ e + '; ' + e.getLineNumber(), system.now().format());
            TF4SF.Logger.writeAllLogs();
            data.put('Docusign response', 'Failed');
            return data;
        }
        
   
    }
    
}