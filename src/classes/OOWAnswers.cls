global class OOWAnswers implements TF4SF.DSP_Interface {

	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = false;
		Map<String, String> data = tdata.clone();

		try {
			String appId = data.get('id');
			infoDebug = (tdata.get('infoDebug') == 'true');
			//String questionId = data.get('questionId');
			//System.debug('questionId: ' + questionId);
			System.debug('appId ==>' + appId );
			String ProductId;
			List<TF4SF__Application__c> appList = [SELECT ProductId__c, Sub_Status__c FROM TF4SF__Application__c WHERE Id = :appId];
			ProductId = appList[0].ProductId__c;
			List<KYC_OOW__c> kycoow = [SELECT Id, KYC_Id__c, Application_Id__c, Question_1_Response__c, Question_2_Response__c, Question_3_Response__c, Question_4_Response__c, Error__c FROM KYC_OOW__c WHERE Application_Id__c = :appId];
			System.debug('1 ==>' + '1' );
			String questionId;

			if (kycoow.size() > 0) { questionId = kycoow[0].KYC_Id__c; }
			//String QuestionId = '123';
			//String QuestionId = data.get('questionId');
			///System.debug('QuestionId ==>'+ QuestionId );
			//Integer applicant_index = Integer.valueOf(data.get('applicant_index'));
			Integer applicant_index =  0;
			System.debug('applicant_index ==>' + applicant_index );
			System.debug('data complete: '+data);
			System.debug('data: ' + data.get('answers1'));
			System.debug('data ans4: '+data.get('answersOrder4'));
			System.debug('data answer4: '+data.get('answers4'));
			Integer answers1 = Integer.valueOf(data.get('answersOrder1'));
			Integer answers2 = Integer.valueOf(data.get('answersOrder2'));
			Integer answers3 = Integer.valueOf(data.get('answersOrder3'));
			Integer answers4 = Integer.valueOf(data.get('answersOrder4'));
			String ans1 = String.valueOf(data.get('answers1'));
			String ans2 = String.valueOf(data.get('answers2'));
			String ans3 = String.valueOf(data.get('answers3'));
			String ans4 = String.valueOf(data.get('answers4'));
			if (String.isNotBlank(ans1)) { kycoow[0].Question_1_Response__c = ans1; }
			if (String.isNotBlank(ans2)) { kycoow[0].Question_2_Response__c = ans2; }
			if (String.isNotBlank(ans3)) { kycoow[0].Question_3_Response__c = ans3; }
			if (String.isNotBlank(ans4)) { kycoow[0].Question_4_Response__c = ans4; }

			System.debug('the response is ' + answers3 );
			String JsonResponseOOWAnswers = PostOOWAnswers(ProductId, QuestionId, applicant_index, answers1, answers2, answers3, 4); 
			System.debug('the PostOOW response is ' + JsonResponseOOWAnswers);
			String ResponseJ = JsonResponseOOWAnswers;
			//String ResponseJ = '[{"error_message": null,"success": true,"value": {"product_app_id": "863c298d-a27d-4b2f-bb37-e0bd66cd2cfe","question_list_id": "1234","answer_correctness": [true,true,true],"applicant_index": 0},"error_type": null}]';
			List<Object> a = (List<Object>)JSON.deserializeUntyped(ResponseJ);
			System.debug('the response is ' + a[0]);
			Map<String, Object> m = (Map<String, Object>)a[0];
			System.debug('the response is ' + m.get('value'));

			if (m.get('success') == 'true') {
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
			} else {
				kycoow[0].Error__c = String.valueOf(m.get('error_type'));
				appList[0].Sub_Status__c = 'KYC Failed';
			}

			update appList[0];
			update kycoow[0];
			//String JsonResponseOOW = OOWQuestionsRequestMethod(ProductId); 
			//System.debug('the OOW response is '+JsonResponseOOW);
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in OOWAnswers class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in OOWAnswers class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'OOWAnswers - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'OOWAnswers - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}

	global String PostOOWAnswers(String productId, String questionID, Integer applicant_index, Integer answers1, Integer answers2, Integer answers3, Integer answers4) {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
		String responseJson = '';
		String body = '[';
		body    +=    '{';
		body    +=       '"product_app_id": "' + productId + '",';
		body    +=       '"question_list_id": "' + questionID + '",';
		body    +=       '"applicant_index": ' + applicant_index + ',';
		body    +=       '"answer_selections": [';
		body    +=       answers1 + ',';
		body    +=       answers2 + ',';
		body    +=       answers3 + '';
		body    +=       answers4 + '';
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