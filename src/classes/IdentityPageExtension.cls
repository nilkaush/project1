global class IdentityPageExtension implements TF4SF.DSP_Interface {
	global List<TF4SF__application__c> aList = new List<TF4SF__application__c>();
	global String subCoreJson;
	global String questionId;
	global List<KYC_OOW__c> kycList;
	global Map<String, String> main(Map<String, String> tdata) {
		Map<String, String> data = tdata.clone();

		try {
			TF4SF__application__c a = new TF4SF__application__c();
			String appId = data.get('id');
			String productId = data.get('Application__c.ProductId__c');
			a.Id = appId;
			List<TF4SF__Application__c> application = [SELECT ProductId__c, TF4SF__Sub_Product__c, TF4SF__Current_Channel__c FROM TF4SF__Application__c WHERE Id = :appId LIMIT 1];
			kycList = [SELECT Id,Question_1_Response__c FROM KYC_OOW__c WHERE Application_Id__c = :appId];
			if (String.isBlank(productId)) { productId = application[0].ProductId__c; }
			subCoreJson = SubmitToCore.JSONGenerator(data);
			if(!subCoreJson.Contains('Server Error') ){
			List<Object> k1 = (List<Object>)JSON.deserializeUntyped(subCoreJson); 
			Map<String, Object> k = (Map<String, Object>)k1[0];
			}

			/*if (k.get('success') == true) {
				a.App_Submitted_to_Alfa__c = true;
			} else {
				a.App_Submitted_to_Alfa__c = false;
			}*/

			/*if(application[0].TF4SF__Current_Channel__c != 'Online' && application[0].TF4SF__Current_Channel__c != 'BizDev') {
			Map<String, String> JsonResponseKYC = KYCRequestMethod(appId, productId); 
			System.debug('Jsonresponsekyc: ' + JsonResponseKYC.get('KYC Response'));
			if (!JsonResponseKYC.ContainsKey('KYC Response Failed')) { data.put('CreditReport', JsonResponseKYC.get('KYC Response')); }
			if (JsonResponseKYC.containskey('KYC Response Failed')) { a.Sub_Status__c = 'KYC Failed'; }
			}*/

			aList.add(a);
			System.debug('alist: ' + alist + '----' + a);

			if ((application[0].TF4SF__Current_Channel__c == 'Online' || application[0].TF4SF__Current_Channel__c == 'BizDev') && (application[0].TF4SF__Sub_Product__c.contains('Checking') || application[0].TF4SF__Sub_Product__c.contains('Savings')|| application[0].TF4SF__Sub_Product__c.contains('Certificates'))) {
				String JsonResponseOOW = OOWQuestionsRequestMethod(productId, appId);
				JsonResponseOOW = OOWJSONGenerator.jsonMethod(JsonResponseOOW);
				System.debug('questionIdiden: ' + questionId);
				if((KYCList.size() == 0 || String.isBlank(KYCList[0].Question_1_Response__c)) && String.isNotBlank(JsonResponseOOW)) {
					data.put('primaryInfoResponse', JsonResponseOOW);
				}
				data.put('questionId', questionId);
				//if (aList.size() > 0 && String.isNotBlank(JsonResponseOOW)) { update aList; }
			}

			
			/*else {
				if (aList.size() > 0) { update aList; }
			}*/
			//LogStorage.InsertDebugLog(appId, 'KYC Response', 'KYC Callout');
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in IdentityPageExtension class: ' + e.getMessage());
			System.debug('server-errors: ' + e.getMessage());
		}

		return data;
	}

	public Map<String, String> KYCRequestMethod(String appId, String productId) {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
		Map<String, String> KYCReqRes = new Map<String, String>();
		String responseJson = '';
		HttpRequest req = new HttpRequest();
		String body = '';
		//Id appId = [SELECT Id FROM TF4SF__application__c WHERE ProductId__c = :productId LIMIT 1].Id;
		req.setTimeout(120 * 1000);  //120 seconds
		System.debug('productId: ' + productId);   
		String authorizationHeader;

		if (aPack.Enable_Production__c == false) {
			req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/kyc/?prodappids=' + productId);
			authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
		} else {
			req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/kyc/?prodappids=' + productId);
			authorizationHeader = 'JWT ' + aPack.Production_Token__c;
		}

		req.setHeader('Authorization', authorizationHeader);
		req.setMethod('GET'); 
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 
		System.debug('response getbody: ' + response.getbody());

		if (response.getStatusCode() != 200) {
			KYCReqRes.put('KYC Response Failed', 'KYC-Failed');
			System.debug('entered: ');
			String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
			return KYCReqRes;
		}

		responseJson = response.getBody();
		List<Object> k1 = new List<Object>();
		Map<String, Object> k;

		if (responseJson != null) {
			k1 = (List<Object>)JSON.deserializeUntyped(responseJSON);
			k = (Map<String, Object>)k1[0];
			System.debug('k response: ' + k);
		}

		System.debug('k1 response: ' + k1);

		if (k.get('Success') == true) {
			Map<String, Object> l = (Map<String, Object>)k.get('value');
			System.debug('l response: ' + l);
			//Map<String, Object> m = (Map<String, Object>)l.get('applicant_kyc_info');
			List<Object> m = (List<Object>)l.get('applicant_kyc_info');
			System.debug('m response: ' + m);
			// TF4SF__application__c a = new TF4SF__application__c();
			//List<TF4SF__application__c> aList = new List<TF4SF__application__c>();

			for (Object o : m) {
				System.debug('o response: ' + o);
				Map<String, Object> qDec = (Map<String,Object>)o;
				System.debug('qDec: ' + qDec + '---' + String.valueOf(qDec.get('qualifile_decision')));

				if (String.valueOf(qDec.get('qualifile_decision')) != 'ACCEPT') {
					System.debug('entered KYC failed');
					KYCReqRes.put('KYC Response Failed', 'KYC-Failed');
					return KYCReqRes;
					//a.Id = appId;
					//a.Sub_Status__c = 'KYC Failed';
					//aList.add(a);
				}
			}
		}

		/*if (aList.size() > 0) { update aList; } */
		System.debug('Response: ' + responseJson);
		//InsertDebugLog(appId, json, 'KYC Request');
		//InsertDebugLog(appId, responseJSON, 'KYC Response');
		KYCReqRes.put('KYC Response', responseJson);
		return KYCReqRes;
	}

	public String OOWQuestionsRequestMethod(String ProductId, String appId) {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
		String responseJson = '';
		HttpRequest req = new HttpRequest();
		String body = '';
		req.setTimeout(120 * 1000);  //120 seconds
		String ind = '0';
		//String url = 'https://dev.sandboxbanking.com/api/product-applications/oowquestions/?prodappid=' + ProductId +'&applicantindex=' +ind;
		String authorizationHeader;

		if (aPack.Enable_Production__c == false) {
			req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/oowquestions/?prodappid=' + ProductId + '&applicantindex=' + ind);
			authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
		} else {
			req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/oowquestions/?prodappid=' + ProductId + '&applicantindex=' + ind);
			authorizationHeader = 'JWT ' + aPack.Production_Token__c;
		}

		//String header = 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'; //'BASIC '+ EncodingUtil.base64Encode(headerValue);
		//req.setEndpoint(url);
		req.setHeader('authorization', authorizationHeader);
		req.setMethod('GET'); 
		//req.setBody(body);
		//System.debug('Request: ' + body);
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		//req.setHeader('authorization', header);
		System.debug('request: ' + req);
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 

		if (response.getStatusCode() != 200) { String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus(); }
		System.debug('Response statuscode: ' + response.getStatusCode() + '----' + response.getbody());
		responseJson = response.getBody();
		System.debug('Response: ' + responseJson);
		if (responseJson != null) { parseResponse(appId, responseJson); }
		//LogStorage.InsertDebugLog(appId, json, 'OOWQuestions Request');
		//LogStorage.InsertDebugLog(appId, responseJSON, 'OOWQuestions Response');

		return responseJson;
	}
	
	public void parseResponse(String appId, String js) {
		//Map<String, Object> k = (Map<String, Object>)JSON.deserializeUntyped(js); 
		List<Object> k1 = (List<Object>)JSON.deserializeUntyped(js); 
		System.debug('k parseresponse: ' + k1);
		String stat = '';

		for (Integer u = 0; u < k1.size(); u++) {
			Map<String, Object> k = (Map<String, Object>)k1[u]; 
			if (k.containskey('success')) { stat = String.valueOf(k.get('success')); }
			// Map<String, Object> l = (Map<String, Object>)k.get('value');
			System.debug('k  stat: ' + stat + '-----' + k);

			if (k.containsKey('value') && stat == 'true') {
				KYC_OOW__c objKYC = new KYC_OOW__c();
				System.debug('k value: ' + k);
				Map<String, Object> l = (Map<String, Object>)k.get('value');
				String prodId = String.valueOf(l.get('product_app_id'));
				questionId = String.valueOf(l.get('question_list_id'));
				//Id appId = [SELECT Id FROM TF4SF__Application__c WHERE ProductId__c = :prodId LIMIT 1].Id;
				List<Object> lobj = (List<Object>)l.get('questions');
				objKYC.Application_Id__c = appId;
				objKYC.KYC_Id__c = questionId;

				for (Integer i = 0; i < lobj.size(); i++) {
					// KYC_OOW__c objKYC = new KYC_OOW__c();
					//  objKYC.Application_Id__c = ApplicationId;
					// objKYC.Name = ApplicationName + '-' + res;
					Map<String, Object> m = (Map<String,Object>)lobj[i];
					System.debug('m: ' + m);

					if (i == 0) {
						objKYC.Question_1_Text__c = string.valueof(m.get('question'));
						List<Object> oo = (List<Object>)m.get('answers');

						for (Integer j = 0; j < oo.size(); j++) {
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
						}
					}
					
					if (i == 1) {
						objKYC.Question_2_Text__c = string.valueof(m.get('question'));
						List<Object> oo = (List<Object>)m.get('answers');

						for (Integer j = 0; j < oo.size(); j++) {
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
						}
					}
					
					if (i == 2) {
						objKYC.Question_3_Text__c = string.valueof(m.get('question'));
						List<Object> oo = (List<Object>)m.get('answers');

						for (Integer j = 0; j < oo.size(); j++) {
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
						}
					}
				}
				if(kycList.size()==0) {
					insert objKYC;
				}
			}
		}
	}
}