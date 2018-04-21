global class OOWAnswers1 implements TF4SF.DSP_Interface {
        
        global Map<String, String> main(Map<String, String> tdata) {
            Map<String, String> data = tdata.clone();
            String appId = data.get('id');
            system.debug('appId ==>'+ appId );
            String ProductId = [SELECT ProductId__c FROM TF4SF__Application__c WHERE Id = :appId].ProductId__c ;
            system.debug('1 ==>'+ '1' );
            String QuestionId = '123';
            //String QuestionId = data.get('questionId');
            ///system.debug('QuestionId ==>'+ QuestionId );
            //Integer applicant_index = Integer.valueOf(data.get('applicant_index'));
           Integer applicant_index = 0; //data.get('applicant_index');
            Integer answers1 = Integer.ValueOf(data.get('answersOrder1')) - 1;
            Integer answers2 = Integer.ValueOf(data.get('answersOrder2')) - 1;
            Integer answers3 = Integer.ValueOf(data.get('answersOrder3')) - 1;
            
            
            System.debug('the response is ' + answers3 );
            
            
            String JsonResponseOOWAnswers = PostOOWAnswers(ProductId, QuestionId, applicant_index, answers1, answers2, answers3); 
            System.debug('the PostOOW response is ' + JsonResponseOOWAnswers);
             List<KYC_OOW__c> oowList = new List<KYC_OOW__c>();
            String Question1Response = data.get('answers1');
            String Question2Response = data.get('answers2');
            String Question3Response = data.get('answers3');
            oowList = [SELECT Id, Question_1_Response__c, Question_2_Response__c, Question_3_Response__c FROM KYC_OOW__c WHERE Application_Id__c = :appId LIMIT 1];

            if (oowList.size() > 0) {
                oowList[0].Question_1_Response__c = Question1Response;
                oowList[0].Question_2_Response__c = Question2Response;
                oowList[0].Question_3_Response__c = Question3Response;
                update oowList;
            }

            String ResponseJ = JsonResponseOOWAnswers;
            //String ResponseJ = '[{"error_message": null,"success": true,"value": {"product_app_id": "863c298d-a27d-4b2f-bb37-e0bd66cd2cfe","question_list_id": "1234","answer_correctness": [true,true,true],"applicant_index": 0},"error_type": null}]';
            List<Object> a = (List<Object>)JSON.deserializeUntyped(ResponseJ);
            System.debug('the response is ' + a[0]);
            Map<String, Object> m = (Map<String, Object>)a[0];
            System.debug('the response is ' + m.get('value'));
            Map<String, Object> l = (Map<String, Object>)m.get('value');
            System.debug('the product_app_id is ' + l.get('product_app_id'));
            System.debug('the question_list_id is ' + l.get('question_list_id'));
            System.debug('the applicant_index is ' + l.get('applicant_index'));
            List<String> k1 = String.valueOf(l.get('answer_correctness')).split(',');
            Integer o = 1;  

            for (String l1 : k1) {
                System.debug('answer_correctness ' + o + ' : ' + l1.replace('(', '').replace(')', ''));    
                o++;
            }

            //String JsonResponseOOW = OOWQuestionsRequestMethod(ProductId); 
            //System.debug('the OOW response is '+JsonResponseOOW);

            return data;
        }

        global String PostOOWAnswers(String productId, String questionID, Integer applicant_index, Integer answers1, Integer answers2, Integer answers3) {
            Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
            String responseJson = '';
            String body = '[';
                body    +=    '{';
                body    +=       '"product_app_id": "'+productId+'",';
                body    +=       '"question_list_id": "'+questionID+'",';
                body    +=       '"applicant_index": '+applicant_index+',';
                body    +=       '"answer_selections": [';
                body    +=       answers1+',';
                body    +=       answers2+',';
                body    +=       answers3+'';
                body    +=      ']';
                body    +=    '}';
                body    +=  ']';

            HttpRequest req = new HttpRequest();
            
            req.setTimeout(120 * 1000);  //120 seconds
            //req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
            String url;// = 'https://dev.sandboxbanking.com/api/product-applications/oowquestions/';
            //blob headerValue = blob.valueOf('Test'+':'+'Testvalue');
            String authorizationheader;// = 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'; //'BASIC '+ EncodingUtil.base64Encode(headerValue);
            if (aPack.Enable_Production__c == false) {
                url = aPack.Sandbox_URL__c + 'api/product-applications/oowquestions/';
                authorizationHeader = 'JWT ' +
                aPack.Sandbox_Token__c;
            } else {
                url = aPack.Production_URL__c + 'api/product-applications/oowquestions/';
                authorizationHeader = 'JWT ' +
                aPack.Production_Token__c;
            }
            req.setEndpoint(url);
            req.setHeader('authorization', authorizationheader);
            req.setMethod('POST'); 
            req.setBody(body);
            System.debug('Request: ' + body);
            req.setHeader('content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            //req.setHeader('authorization', header);
            
            Http http = new Http();
            HttpResponse response;
            response = http.send(req); 
            if (response.getStatusCode() != 200) {
                String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
                //System.debug(errorMsg);
            }

            responseJson = response.getBody();
            System.debug('Response: '+responseJson);

            return responseJson;
        }
    }