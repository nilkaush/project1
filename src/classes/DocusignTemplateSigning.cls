global with sharing class DocusignTemplateSigning implements TF4SF.DSP_Interface{

    global Map<String,String> main(Map<String,String> tdata) {
        Map<String,String> data = tdata.clone();
        String appId = data.get('id');
        TF4SF.Logger.inputSource('Docusign class',appId);
        Set<String> fieldsToDisplay = new Set<String>(); // This string is used to contain the fields received from Utility class.
        TF4SF.DSPUtility u = new TF4SF.DSPUtility();
        TF4SF.RequiredFieldsUtility rfu = new TF4SF.RequiredFieldsUtility();
        fieldsToDisplay = u.fieldsToRender(appId);
        system.debug('the fields rendered are '+fieldsToDisplay.size());
        String username = '';
        String password = '';
        String integratorKey = '';
        String templateId = '';
        String roleName = '';
        String clientUserId = '';
        String accountId = '';   // we will retrieve this through the Login API call

        TF4SF__Application__c app = [Select TF4SF__First_Name__c,TF4SF__Last_Name__c, TF4SF__Email_Address__c from TF4SF__Application__c where id = :appId];
        Docusign_Config__c cred = Docusign_Config__c.getOrgDefaults();
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

        System.debug('the no of applicants are '+noOfApplicants);

        if (cred != NULL) {
            accountId = cred.AccountID__c;
            username = cred.Username__c;
            password = cred.Password__c;
            integratorKey = cred.IntegratorKey__c ;
        }

        String recipientName = app.TF4SF__First_Name__c + ' ' + app.TF4SF__Last_Name__c;
        String recipientEmail = app.TF4SF__Email_Address__c;
        roleName = 'Signer';
        List<TF4SF__Disclosure_Names__c> ddn = [Select Name, TF4SF__Disclosure_Label__c from TF4SF__Disclosure_Names__c];
        System.debug('The size of the list is '+ddn.size());
        List<TF4SF__Disclosure__c> discList = new List<TF4SF__Disclosure__c>();
        // construct the DocuSign authentication header
        String authenticationHeader =
            '<DocuSignCredentials>' +
            '<Username>' + username + '</Username>' +
            '<Password>' + password + '</Password>' +
            '<IntegratorKey>' + integratorKey + '</IntegratorKey>' +
            '</DocuSignCredentials>';

        // additional variable declarations
        String baseURL = '';     // we will retrieve this through the Login API call
        String url = '';     // end-point for each api call
        String body = '';    // request body
        String response = '';    // response body
        integer status;  // response status
        HttpResponse res = null;
        String resBody;  // connection object used for each request

        //============================================================================
        // STEP 1 - Make the Login API call to retrieve your baseUrl and accountId
        //============================================================================

        url = 'https://demo.docusign.net/restapi/v2/login_information';
        body = '';  // no request body for the login call
        if(!Test.isRunningTest()){
            res = InitializeRequest(url, 'GET', body, authenticationHeader);
            status = res.getStatusCode();
            resBody = res.getBody();
            if (status != 200) { // 200 = OK
              data.put('Docusing Embedded Signing URL', 'Failure at 200');
              return data;
            }
        }

        // obtain baseUrl and accountId values from response body
        baseURL = parseXMLBody(resBody, 'baseUrl');
        accountId = parseXMLBody(resBody, 'accountId');

        //============================================================================
        // STEP 2 - Signature Request from Document API Call
        //============================================================================

        url = baseURL + '/envelopes';   // append '/envelopes' to baseUrl for signature request call
        String tempArray = '';
        String bodyEncoded = '';
        Integer n = 0; //number of documents
        List<String> tIdList = new List<String>();
        List<TF4SF__Disclosure__c> newdiscList = new List<TF4SF__Disclosure__c>();
        for (Integer i = 0; i < ddn.size(); i++) {
          System.debug('the value of i ' +i);
          if (fieldsToDisplay.contains(ddn[i].Name+'__c')) {
            system.debug('the disclosure Name is '+ddn[i].TF4SF__Disclosure_Label__c + ' - DS');
            TF4SF__Disclosure__c disclosure = [SELECT Id,name,Template_ID__c,Joint1_Template_ID__c,Joint2_Template_ID__c,Joint3_Template_ID__c FROM TF4SF__Disclosure__c WHERE Name = :(ddn[i].TF4SF__Disclosure_Label__c + ' - DS')];
            //Disclosure__c disclosure = [SELECT Id,Name,Template_ID__c,Joint1_Template_ID__c,Joint2_Template_ID__c,Joint3_Template_ID__c FROM Disclosure__c WHERE Template_ID__c != NULL];
            newdiscList.add(disclosure);
          }
        }

        System.debug('the size of the Disclosure '+newdiscList.size());
        for (TF4SF__Disclosure__c disc : newdiscList) {
              if (noOfApplicants == 1) {
                tIdList.add(disc.Template_ID__c);
              } else if (noOfApplicants == 2) {
                tIdList.add(disc.Joint1_Template_ID__c);
              } else if (noOfApplicants == 3) {
                tIdList.add(disc.Joint2_Template_ID__c);
              } else if (noOfApplicants == 4) {
                tIdList.add(disc.Joint3_Template_ID__c);
              }
            }

            System.debug('the size of the Template Id\'s '+tIdList.size());
            String recipients = '';
            for (Integer h = 1; h <= noOfApplicants; h++) {
              if (h==1) {
                recipients = recipients+'<signer>'+
                '<email>'+app.TF4SF__Email_Address__c+'</email>'+
                '<name>'+app.TF4SF__First_Name__c + ' ' + app.TF4SF__Last_Name__c+'</name>'+
                '<recipientId>'+h+'</recipientId>'+
                '<roleName>'+roleName+' '+h+'</roleName>' +
                '<clientUserId>'+'100'+h+'</clientUserId>' +
                '</signer>';
              } else if (h==2) {
                recipients = recipients+'<signer>'+
                '<email>'+app.TF4SF__Email_Address_J__c+'</email>'+
                '<name>'+app.TF4SF__First_Name_J__c + ' ' + app.TF4SF__Last_Name_J__c+'</name>'+
                '<recipientId>'+h+'</recipientId>'+
                '<roleName>'+roleName+' '+h+'</roleName>' +
                '<clientUserId>'+'100'+h+'</clientUserId>' +
                '</signer>';
              } else if (h==3) {
                recipients = recipients+'<signer>'+
                '<email>'+app.TF4SF__Email_Address_J2__c+'</email>'+
                '<name>'+app.TF4SF__First_Name_J2__c + ' ' + app.TF4SF__Last_Name_J2__c+'</name>'+
                '<recipientId>'+h+'</recipientId>'+
                '<roleName>'+roleName+' '+h+'</roleName>' +
                '<clientUserId>'+'100'+h+'</clientUserId>' +
                '</signer>';
              } else if (h==4) {
                recipients = recipients+'<signer>'+
                '<email>'+app.TF4SF__Email_Address_J3__c+'</email>'+
                '<name>'+app.TF4SF__First_Name_J3__c + ' ' + app.TF4SF__Last_Name_J3__c+'</name>'+
                '<recipientId>'+h+'</recipientId>'+
                '<roleName>'+roleName+' '+h+'</roleName>' +
                '<clientUserId>'+'100'+h+'</clientUserId>' +
                '</signer>';
              }
            }

            System.debug('The recipients body is ' + recipients);
            if (tIdList.size() > 0) {
              for (Integer j = 0; j < tIdList.size(); j++) {
                tempArray = tempArray+'<compositeTemplates>'+
                '<compositeTemplate>'+
                '<serverTemplates>'+
                '<serverTemplate>'+
                '<sequence>1</sequence>'+
                '<templateId>'+tIdList.get(j)+'</templateId>'+
                '</serverTemplate>'+
                '</serverTemplates>'+
                '<inlineTemplates>'+
                '<inlineTemplate>'+
                '<sequence>2</sequence>'+
                '<recipients>'+
                '<signers>'+recipients+'</signers>'+
                '</recipients>'+
                '</inlineTemplate>'+
                '</inlineTemplates>'+
                '</compositeTemplate>'+
                '</compositeTemplates>';
              }
            }

            System.debug('the array of templateid is '+tempArray);

            //Single template id example callout REST API
            /* templateId ='1673B9A2-8079-425D-84FB-EC40A1454092';

            body =  '<envelopeDefinition xmlns=\'https://www.docusign.com/restapi\'>' +
            '<status>sent</status>'+
            '<accountId>' + accountId + '</accountId>' +
            '<emailSubject>Please sign the Disclosures below</emailSubject>' +
            '<templateId>'+ templateId +'</templateId>'+
            '<templateRoles>' +
            '<templateRole>' +
            '<email>' + recipientEmail + '</email>' +
            '<name>' + recipientName + '</name>' +
            '<roleName>' + roleName + '</roleName>' +
            '<clientUserId>1001</clientUserId>' +
            '</templateRole>' +
            '</templateRoles>' +
            '</envelopeDefinition>';*/

            body = '<envelopeDefinition xmlns=\'https://www.docusign.com/restapi\'>' +
            '<status>sent</status>'+
            '<accountId>' + accountId + '</accountId>' +
            '<emailSubject>Please sign the Disclosures below</emailSubject>' +
            '<emailBlurb>Test Email Body</emailBlurb>'+
            tempArray+
            '</envelopeDefinition>';

            System.debug('The Body Build is '+body);

            if (!Test.isRunningTest()) {
              res = InitializeRequest(url,'POST',body,authenticationHeader);
              status = res.getStatusCode();
              resBody = res.getBody();
              if (status != 201) {// 201 = Created
                data.put('Docusign Embedded Signing URL', '201 Failure');
                return data;
              }
            }

            // obtain envelope uri from response body
            String uri = parseXMLBody(resBody,'uri');

            System.debug('uri is: '+uri+'/spaces');
            String envelope = uri.replace('/envelopes/', '');
            System.debug('token is '+uri.replace('/envelopes/', ''));

            //============================================================================
            // STEP 3 - Get the Embedded Signing View
            //============================================================================
            String destination = 'https://www.docusign.com';
            url = baseURL + uri + '/views/recipient';   // append envelope uri + 'views/recipient' to url

            body = '<recipientViewRequest xmlns=\'https://www.docusign.com/restapi\'>'  +
            '<authenticationMethod>email</authenticationMethod>' +
            '<email>'+recipientEmail+'</email>' +
            '<returnUrl>'+destination+'</returnUrl>' +
            '<userName>'+recipientName+'</userName>' +
            '<clientUserId>1001</clientUserId>' +
            '</recipientViewRequest>';

            if (!Test.isRunningTest()) {
              res = InitializeRequest(url, 'POST', body, authenticationHeader);
              status = res.getStatusCode();
              if (status != 201)  {// 201 = Created
                data.put('Docusign Embedded Signing URL', 'Failure at 201');
                return data;
              }
              resBody = res.getBody();
              String urlToken = parseXMLBody(resBody, 'url');
              System.debug('URL TOKEN ' +urlToken);

              app.Docusign_EnvelopeID__c = uri.replace('/envelopes/','');
              update app;
              data.put('Docusign Embedded Signing URL', urlToken);
            }

            return data;
    } //end main()

    // --- HELPER FUNCTIONS ---
    global static HttpResponse InitializeRequest(String url, String method, String body, String httpAuthHeader) {
    HttpResponse res = null;
    try {
      Http http = new Http();
      HttpRequest req = new HttpRequest();
      req.setEndpoint(url);
      req.setHeader('X-DocuSign-Authentication', httpAuthHeader);
      req.setHeader('Content-Type', 'application/xml');
      req.setHeader('Accept', 'application/xml');
      req.setMethod(method);

      if (method == 'POST') {
        req.setHeader('Content-Length', String.valueOf(body.length()));
        req.setbody(body);
      }
      res = http.send(req);
      system.debug('the response is:'+res);
      system.debug('the body of the response is:'+res.getBody());
    }
    catch (Exception e) {
      system.debug(e); // simple exception handling, please review it
    }

    return res;
    }

    global static String parseXMLBody(String body, String searchToken) {
    system.debug('Body : ' +body+ 'Token : ' +searchToken);
    String value = '';
    if (body!= '' && body!= NULL) {
      Dom.Document doc1 = new Dom.Document();
      doc1.load(body);
      Dom.XMLNode xroot1 = doc1.getrootelement();
      Dom.XMLNode[] xrec1 = xroot1.getchildelements(); //Get all Record Elements
      for (Dom.XMLNode firstInnerChild : xrec1) { //Loop Through Records
        if (firstInnerChild.getname() == searchToken) {
          value = firstInnerChild.gettext();
          break;
        } else {
          Dom.XMLNode[] xrec2 = NULL;
          xrec2 = firstInnerChild.getchildelements();
          if (xrec2 != NULL) {
            for (Dom.XMLNode secondInnerChild : xrec2) {
              if (secondInnerChild.getname() == 'loginAccount') {
                for (Dom.XMLNode thirdInnerChild : secondInnerChild.getchildren()) {
                  if (thirdInnerChild.getname() == searchToken) {
                    system.debug('values is: '+ thirdInnerChild.gettext());
                    value = thirdInnerChild.gettext();
                  }
                  if (value != '') {
                    break;
                  }
                }
              }
              if (value != '') {
                break;
              }
            }
          }
        }
        if (value != '') {
          break;
        }
      }
    }

    return value;
  }
} // End Class