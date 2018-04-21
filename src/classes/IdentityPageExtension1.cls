global class IdentityPageExtension1 implements TF4SF.DSP_Interface {
  
  global List<TF4SF__application__c> aList = new List<TF4SF__application__c>();
 
   global String subCoreJson;
    global Map<String, String> main(Map<String, String> tdata) {
        Map<String, String> data = tdata.clone();
        TF4SF__application__c a = new TF4SF__application__c();
        
        String appId = data.get('id');
        a.Id = appId;
        String productId = [SELECT productId__c FROM TF4SF__application__c WHERE Id = :appId LIMIT 1].productId__c;
       //String productId ='022b6a1d-5d81-451d-bfdb-d02a721e64c5';
       // subCoreJson = updateProdApp.JSONGenerator(appId);
        
        subCoreJson = SubmitToCore.JSONGenerator(data);
        List<Object> k1 = (List<Object>)JSON.deserializeUntyped(subCoreJson); 
        Map<String, Object> k = (Map<String, Object>)k1[0];
        if (k.get('success') == true) {
            
            a.App_Submitted_to_Alfa__c = true;
            
        }
        else {
            
            a.App_Submitted_to_Alfa__c = false;
            
        }
        
       // String ProductId = '863c298d-a27d-4b2f-bb37-e0bd66cd2cfe'; //data.get('productId');
        //String ProductId = '08c98b99-0b15-447f-9538-98bf6567b548';
        Map<String, String> JsonResponseKYC = KYCRequestMethod(ProductId); 
        system.debug('jsonResponseKYC: '+JsonResponseKYC);
       /* List<Object> k2 = (List<Object>)JSON.deserializeUntyped(JsonResponseKYC); 
        Map<String, Object> k3 = (Map<String, Object>)k2[0];
        Map<String, Object> l = (Map<String, Object>)k3.get('value');
        Map<String, Object> m = (Map<String, Object>)l.get('applicant_kyc_info');
        if (String.valueOf(m.get('qualifile_decision')) != 'ACCEPT') {*/
        if (JsonResponseKYC.containskey('KYC Response Failed')) {
            a.Sub_Status__c = 'KYC Failed';
        }
          
       // }
        aList.add(a);
        system.debug('alist: '+alist+'----'+a);
        //System.debug('the kyc response is '+JsonResponseKYC);
        String JsonResponseOOW = OOWQuestionsRequestMethod(ProductId, appId);
        JsonResponseOOW=testJSONGenerator.jsonMethod(JsonResponseOOW);
        system.debug('----JsonResponseOOW-----: '+JsonResponseOOW);
        system.debug('aList: '+aList);
        if (aList.size() > 0) {
            update aList;
        }
        LogStorage.InsertDebugLog(appId, 'KYC Response', 'KYC Callout');
       // System.debug('the OOW response is '+JsonResponseOOW);
        data.PUT('primaryInfoResponse',JsonResponseOOW);
        return data;
    }

    public Map<String, String> KYCRequestMethod(String ProductId) {
        Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
        Map<String, String> KYCReqRes = new Map<String, String>();
        String responseJson = '';
        HttpRequest req = new HttpRequest();
        String body = '';
        Id appId = [SELECT Id FROM TF4SF__application__c WHERE productId__c = :ProductId LIMIT 1].Id;
        req.setTimeout(120 * 1000);  //120 seconds
        //req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
        system.debug('productId: '+productId);
        //String url = 'https://dev.sandboxbanking.com/api/product-applications/kyc/?prodappids=' + ProductId;
        if (aPack.Enable_Production__c == false) {
           // req.setEndpoint(aPack.Sandbox_URL__c+'api/product-applications/kyc/?prodappids=' + ProductId);
            req.setEndpoint(aPack.Sandbox_URL__c+'api/product-applications/kyc/?prodappids=' + ProductId);
        }
        else {
            req.setEndpoint(aPack.Production_URL__c+'api/product-applications/kyc/?prodappids=' + ProductId);
        }
        //blob headerValue = blob.valueOf('Test'+':'+'Testvalue');
        //String header = 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'; //'BASIC '+ EncodingUtil.base64Encode(headerValue);
       // req.setEndpoint(url);
        if (aPack.Enable_Production__c == false) {
            req.setHeader('Authorization', aPack.Sandbox_Token__c);      
        }
        else {
            req.setHeader('Authorization', aPack.Production_Token__c);      
        }
       // req.setHeader('Authorization', header);
        req.setMethod('GET'); 
        //req.setBody(body);
        //System.debug('Request: ' + body);
        req.setHeader('content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        //req.setHeader('authorization', header);
        Http http = new Http();
        HttpResponse response;
        System.debug(req);
        response = http.send(req); 
        system.debug('response getbody: '+response.getbody());
        if (response.getStatusCode() != 200) {
        KYCReqRes.put('KYC Response Failed', 'KYC-Failed');
        return KYCReqRes;
        //return 'KYC-Failed';
        system.debug('entered: ');
            String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
            //System.debug(errorMsg);
        }

        responseJson = response.getBody();
        List<Object> k1 = (List<Object>)JSON.deserializeUntyped(responseJSON); 
        system.debug('k1 response: '+k1);
        Map<String, Object> k = (Map<String, Object>)k1[0];
        system.debug('k response: '+k);
        Map<String, Object> l = (Map<String, Object>)k.get('value');
        system.debug('l response: '+l);
        //Map<String, Object> m = (Map<String, Object>)l.get('applicant_kyc_info');
        List<Object> m = (List<Object>)l.get('applicant_kyc_info');
        system.debug('m response: '+m);
       // TF4SF__application__c a = new TF4SF__application__c();
        //List<TF4SF__application__c> aList = new List<TF4SF__application__c>();
        for (Object o: m) {
            system.debug('o response: '+o);
            Map<String, Object> qDec = (Map<String,Object>)o;
            system.debug('qDec: '+qDec+'---'+String.valueOf(qDec.get('qualifile_decision')));
            if (String.valueOf(qDec.get('qualifile_decision')) != 'ACCEPT') {
                system.debug('entered KYC failed');
                KYCReqRes.put('KYC Response Failed', 'KYC-Failed');
             //   a.Id = appId;
            //    a.Sub_Status__c = 'KYC Failed';
               // aList.add(a);
            }
        }
        /*if (aList.size() > 0) {
            update aList;
        }*/
            
        System.debug('Response: ' + responseJson);
        //InsertDebugLog(appId, json, 'KYC Request');
        //InsertDebugLog(appId, responseJSON, 'KYC Response');
        
        KYCReqRes.put('KYC Response', responseJson);
        return KYCReqRes;
    }

    public String OOWQuestionsRequestMethod(String ProductId, String aId) {
        String responseJson = '';
        HttpRequest req = new HttpRequest();
        String body = '';
        
        req.setTimeout(120 * 1000);  //120 seconds
        //req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
        String ind = '0';
       // String url = 'https://dev.sandboxbanking.com/api/product-applications/oowquestions/?prodappid=' + ProductId;
        String url = 'https://dev.sandboxbanking.com/api/product-applications/oowquestions/?prodappid=' + ProductId +'&applicantindex=' +ind;
        //blob headerValue = blob.valueOf('Test'+':'+'Testvalue');
        String header = 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'; //'BASIC '+ EncodingUtil.base64Encode(headerValue);
        req.setEndpoint(url);
        req.setHeader('authorization', header);
        req.setMethod('GET'); 
        //req.setBody(body);
        //System.debug('Request: ' + body);
        req.setHeader('content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        //req.setHeader('authorization', header);
        system.debug('request: '+req);
        Http http = new Http();
        HttpResponse response;
        response = http.send(req); 

        if (response.getStatusCode() != 200) {
            String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
            //System.debug(errorMsg);
        }
        System.debug('Response statuscode: ' + response.getStatusCode()+'----'+response.getbody());
        responseJson = response.getBody();
        parseResponse(responseJson);
        System.debug('Response: ' + responseJson);
      //  LogStorage.InsertDebugLog(aId, json, 'OOWQuestions Request');
        LogStorage.InsertDebugLog(aId, responseJSON, 'OOWQuestions Response');

        return responseJson;
    }
    
    public void parseResponse(String js) {
    
        //Map<String, Object> k = (Map<String, Object>)JSON.deserializeUntyped(js); 
        List<Object> k1 = (List<Object>)JSON.deserializeUntyped(js); 
        system.debug('k parseresponse: '+k1);
        String stat = '';
        KYC_OOW__c objKYC = new KYC_OOW__c();
        for(integer u=0; u<k1.size(); u++) {
        Map<String, Object> k = (Map<String, Object>)k1[u]; 
        if (k.containskey('success')) {
            stat = String.valueOf(k.get('Success'));   
        }
        
       // Map<String, Object> l = (Map<String, Object>)k.get('value');
       if (k.containsKey('value')) {
        system.debug('k value: '+k);
           Map<String, Object> l = (Map<String, Object>)k.get('value');
           String prodId = String.valueOf(l.get('product_app_id'));
           Id appId = [SELECT Id FROM TF4SF__application__c WHERE productId__c = :prodId LIMIT 1].Id;
        
        List<Object> lobj = (List<Object>)l.get('questions');
        
        objKYC.Application_Id__c = appId;
        for (integer i = 0; i<lobj.size(); i++) {
                // KYC_OOW__c objKYC = new KYC_OOW__c();
                //  objKYC.Application_Id__c = ApplicationId;
                // objKYC.Name = ApplicationName + '-' + res;
                Map<String, Object> m = (Map<String,Object>)lobj[i];
                System.debug('m: ' + m);

                if (i == 0) {
                    objKYC.Question_1_Text__c = string.valueof(m.get('question'));
                    
                    List<Object> oo = (List<Object>)m.get('answers');

                    for (integer j=0; j<oo.size(); j++) {
                       // Map<String,Object> m1 = (Map<String,Object>)o1;
                        if (j == 0) {
                            objKYC.Question_1_Choice_1__c = string.valueof(oo[0]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 1) {
                            objKYC.Question_1_Choice_2__c = string.valueof(oo[1]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 2) {
                            objKYC.Question_1_Choice_3__c = string.valueof(oo[2]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 3) {
                            objKYC.Question_1_Choice_4__c = string.valueof(oo[3]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 4) {
                            objKYC.Question_1_Choice_5__c = string.valueof(oo[4]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                       // System.debug('o1: ' + m1.get('answer'));
                    }
                }
                
                if (i == 1) {
                    objKYC.Question_2_Text__c = string.valueof(m.get('question'));
                    
                    List<Object> oo = (List<Object>)m.get('answers');

                    for (integer j=0; j<oo.size(); j++) {
                       // Map<String,Object> m1 = (Map<String,Object>)o1;
                        if (j == 0) {
                            objKYC.Question_2_Choice_1__c = string.valueof(oo[0]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 1) {
                            objKYC.Question_2_Choice_2__c = string.valueof(oo[1]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 2) {
                            objKYC.Question_2_Choice_3__c = string.valueof(oo[2]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 3) {
                            objKYC.Question_2_Choice_4__c = string.valueof(oo[3]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 4) {
                            objKYC.Question_2_Choice_5__c = string.valueof(oo[4]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                       // System.debug('o1: ' + m1.get('answer'));
                    }
                }
                
                if (i == 2) {
                    objKYC.Question_3_Text__c = string.valueof(m.get('question'));
                    
                    List<Object> oo = (List<Object>)m.get('answers');

                    for (integer j=0; j<oo.size(); j++) {
                       // Map<String,Object> m1 = (Map<String,Object>)o1;
                        if (j == 0) {
                            objKYC.Question_3_Choice_1__c = string.valueof(oo[0]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 1) {
                            objKYC.Question_3_Choice_2__c = string.valueof(oo[1]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 2) {
                            objKYC.Question_3_Choice_3__c = string.valueof(oo[2]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 3) {
                            objKYC.Question_3_Choice_4__c = string.valueof(oo[3]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                        if (j == 4) {
                            objKYC.Question_3_Choice_5__c = string.valueof(oo[4]);
                            
                            System.debug('objKYC==>' + objKYC);
                        }

                       // System.debug('o1: ' + m1.get('answer'));
                    }
                }
            }
        }
    }
            insert objKYC;

            
            }
    }