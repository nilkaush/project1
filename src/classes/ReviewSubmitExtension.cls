global with sharing class ReviewSubmitExtension implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		Map<String, String> data = new Map<String, String>();

		try {
			String appId = tdata.get('id');
			String method = tdata.get('method');
			Boolean debug = (tdata.get('debug') == 'true');
			Boolean infoDebug = (tdata.get('infoDebug') == 'true');
			System.debug('method: ' + method);
			TF4SF__Application__c app = [SELECT Id, Name, ProductId__c, TF4SF__Application_Status__c, TF4SF__Primary_Product_Status__c, TF4SF__Sub_Product__c, TF4SF__Current_Channel__c FROM TF4SF__Application__c WHERE Id = :appId];
			TF4SF__About_Account__c abtAcc = [SELECT Id, Name, TF4SF__Requested_Loan_Amount_VehicleLoans__c, TF4SF__Requested_Loan_Amount_PersonalLoans__c,TF4SF__Requested_Credit_Limit_Ccards__c, TF4SF__Term_VehicleLoans__c, TF4SF__Term_Personalloans__c, TF4SF__Application__c FROM TF4SF__About_Account__c WHERE TF4SF__Application__c = :appId];
			List<TF4SF__Products__c> prodList = [SELECT Id FROM TF4SF__Products__c WHERE TF4SF__Application__c = :app.Id];

			if (String.isNotBlank(method)) {
				System.debug('String is not blank.');

				if (method == 'RetrieveCreditReport' && (app.TF4SF__Current_Channel__c != 'Online' && app.TF4SF__Current_Channel__c != 'BizDev') && 
					(app.TF4SF__Sub_Product__c.Contains('Checking') || app.TF4SF__Sub_Product__c.Contains('Savings') || app.TF4SF__Sub_Product__c.Contains('Certificates'))) {
					System.debug('app.ProductId__c: ' + app.ProductId__c);
					data.put('RetrieveCreditReport', 'true');
					if (infoDebug == true) { data.put('ProductId__c', app.ProductId__c); }

					if (app.ProductId__c != null) {
						Map<String, String> JsonResponseKYC = KYCRequestMethod(appId, app.ProductId__c);
						if (infoDebug == true) { data.put('JsonResponseKYC', JSON.serialize(JsonResponseKYC)); }
						System.debug('Jsonresponsekyc: ' + JsonResponseKYC.get('KYC Response'));
						if (!JsonResponseKYC.ContainsKey('KYC Response Failed')) { data.put('CreditReport', JSON.serialize(JsonResponseKYC.get('KYC Response'))); }
					}
				} else if (method == 'CancelApplication') {
					System.debug('method == CancelApplication');
					app.TF4SF__Primary_Product_Status__c = 'CANCELED';
					String res = SendStatusFromCreditReport.CallUpdateApiToSendStatus(appId, app.ProductId__c, app.TF4SF__Sub_Product__c, 'CANCELED','ReviewSubmitPage');
					data.put('CancelApplication', 'true');
				}
				 update app;
			} else {
				// StipulationsAPI.callStipulations(app.ProductId__c, appId);
				String  body = '[';
						body += '"' + app.ProductId__c + '"';
						body += ']';
				Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
				Map<String, Product_Status_Mapping__c> prodStatMap = Product_Status_Mapping__c.getAll();
				Http http = new Http();
				HttpRequest req = new HttpRequest();
				req.setHeader('content-type', 'application/json');
				req.setHeader('Accept', 'application/json');
				req.setMethod('POST');
				req.setTimeout(120000);
				String authorizationHeader;

				if (aPack.Enable_Production__c == false) {
					req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/decisions/');
					authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
				} else {
					req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/decisions/');
					authorizationHeader = 'JWT ' + aPack.Production_Token__c;
				}

				req.setHeader('Authorization', authorizationHeader);
				req.setBody(body);
				HttpResponse res = http.send(req);
				String responseJSON = res.getBody();
				System.debug('requestJSON: ' + req.getbody() + '----' + res.getstatus());
				System.debug('responseJSON: ' + responseJSON + '----' + res.getstatus());
				StipulationsAPI.callStipulations(app.ProductId__c, appId);
				if (res.getStatusCode() == 200) {
					List<Object> k1 = (List<Object>)JSON.deserializeUntyped(responseJSON);

					if (k1 != null && k1.size() > 0) {
						Map<String, Object> k = (Map<String, Object>)k1[0];
						if (k != null) {
							data.put('k', 'object is: ' + k);
							System.debug(k.get('value'));
							Map<String, Object> l = (Map<String, Object>)k.get('value');
							System.debug('kkkkkkkkkk:' + k);
							System.debug('llllllllll:' + l);

							if (l != null) {
								System.debug('l values: ' + l.get('status'));
								String stat = String.ValueOf(l.get('status'));
								app.TF4SF__Primary_Product_Status__c = prodStatMap.get(stat).Product_Status__c;
								//app.TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
								app.Custom_Text44__c = String.ValueOf(l.get('account_id'));
								data.put('account_id', String.ValueOf(l.get('account_id')));

								update app;
							} else {
								data.put('l', 'is null');
							}
						} else {
							data.put('k', 'is null');
						}
					} else {
						data.put('k1', 'is null or empty');
					}
				} else {
					data.put('Error Status Code', String.ValueOf(res.getStatusCode()));
				}
			}

			if (abtAcc != null && prodList.size() == 0) {
				TF4SF__Products__c prod = new TF4SF__Products__c();
				prod.TF4SF__Product_Name__c = app.TF4SF__Sub_Product__c;
				prod.TF4SF__Application__c = abtAcc.TF4SF__Application__c;
				prod.TF4SF__Product_Type__c = 'Primary';
				System.debug('abtacc term: ' + abtAcc.TF4SF__Term_VehicleLoans__c);
				if (abtAcc.TF4SF__Term_VehicleLoans__c != null) {
					prod.TF4SF__Term__c = abtAcc.TF4SF__Term_VehicleLoans__c;
				} else if (abtAcc.TF4SF__Term_Personalloans__c != null) {
					prod.TF4SF__Term__c = abtAcc.TF4SF__Term_Personalloans__c;
				}
				

				if (abtAcc.TF4SF__Requested_Loan_Amount_PersonalLoans__c != null) {
					prod.TF4SF__Requested_Loan_Amount__c = abtAcc.TF4SF__Requested_Loan_Amount_PersonalLoans__c;
				} else if (abtAcc.TF4SF__Requested_Loan_Amount_VehicleLoans__c != null) {
					prod.TF4SF__Requested_Loan_Amount__c = abtAcc.TF4SF__Requested_Loan_Amount_VehicleLoans__c;
				} else if (abtAcc.TF4SF__Requested_Credit_Limit_Ccards__c != null) {
					prod.TF4SF__Requested_Credit_Limit__c = abtAcc.TF4SF__Requested_Credit_Limit_Ccards__c;
				}

				upsert prod;
			}
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in ReviewSubmitExtension class: ' + e.getMessage());
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
		req.setTimeout(120 * 1000); //120 seconds
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
		} else {
			responseJson = response.getBody();
			//if (k.get('Success') == true) {
			System.debug('Response: ' + responseJson);
			//LogStorage.InsertDebugLog(appId, req.getbody(), 'Credit Report Request');
			//LogStorage.InsertDebugLog(appId, responseJSON, 'Credit Report Response');
			KYCReqRes.put('KYC Response', responseJson);
		}

		return KYCReqRes;
	}
}