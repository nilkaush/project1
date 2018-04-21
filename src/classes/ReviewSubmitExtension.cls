//Created By: Nithin Kolluri
global with sharing class ReviewSubmitExtension implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = false;
		Map<String, String> data = new Map<String, String>();
		List<TF4SF__Application__c> appl = new List<TF4SF__Application__c>();
		String primaryProdStatus = '';

		try {
			String appId = tdata.get('id');
			String method = tdata.get('method');
			Boolean debug = (tdata.get('debug') == 'true');
			infoDebug = (tdata.get('infoDebug') == 'true');
			System.debug('method: ' + method);
			TF4SF__Application__c app = [SELECT Id, Name, ProductId__c, ProductIdCS1__c, ProductIdCS2__c, ProductIdCS3__c, TF4SF__Application_Status__c, TF4SF__Primary_Product_Status__c, TF4SF__Sub_Product__c, TF4SF__Current_Channel__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c FROM TF4SF__Application__c WHERE Id = :appId];
			TF4SF__Identity_Information__c idn = [SELECT Id, Name, TF4SF__SSN_Prime__c FROM TF4SF__Identity_Information__c WHERE TF4SF__Application__c = :app.Id];
			TF4SF__About_Account__c abtAcc = [SELECT Id, Name, TF4SF__Requested_Loan_Amount_VehicleLoans__c, TF4SF__Requested_Loan_Amount_PersonalLoans__c, TF4SF__Requested_Credit_Limit_Ccards__c, TF4SF__Term_VehicleLoans__c, TF4SF__Term_Personalloans__c, TF4SF__Custom_Currency7__c, TF4SF__Custom_Currency8__c, TF4SF__Custom_Number1__c, TF4SF__Custom_Number2__c, TF4SF__Application__c, TF4SF__Application__r.ProductId__c, TF4SF__Application__r.ProductIdCS1__c,TF4SF__Application__r.ProductIdCS2__c, TF4SF__Application__r.ProductIdCS3__c FROM TF4SF__About_Account__c WHERE TF4SF__Application__c = :appId];
			List<TF4SF__Products__c> prodList = [SELECT Id FROM TF4SF__Products__c WHERE TF4SF__Application__c = :app.Id];
			Map<String, String> prodOrder = new Map<String, String>();
			String SSNPrime;

			// Set<String> custSSN = new Set<String>();
			// for (TF4SF__Customer__c c : [SELECT Id, TF4SF__SSN__c FROM TF4SF__Customer__c]) { custSSN.add(c.TF4SF__SSN__c); }

			if (String.isNotBlank(data.get('Identity_Information__c.SSN_Prime__c')) || String.isNotBlank(idn.TF4SF__SSN_Prime__c)) {
				System.debug('entered ssnprime: ' + data.get('Identity_Information__c.SSN_Prime__c'));
				//SSNPrime = data.get('Identity_Information__c.SSN_Prime__c');
				SSNPrime = idn.TF4SF__SSN_Prime__c;
			}

			if (String.isNotBlank(method)) {
				System.debug('String is not blank.');
				Boolean checkMember = getMemberAPIcall(SSNPrime);
				data.put('debug-server-errors', 'ReviewSubmitExtension method: ' + method);

				if (method == 'RetrieveCreditReport' && infoDebug == true) {
					data.put('ProductId__c', app.ProductId__c);
					data.put('checkMember', String.valueOf(checkMember));
					data.put('SSNPrime', SSNPrime);
					data.put('Current_Channel__c', app.TF4SF__Current_Channel__c);
					data.put('Sub_Product__c', app.TF4SF__Sub_Product__c);
				}

				//Do not display efunds report for Members
				if (String.isNotBlank(SSNPrime) && !checkMember && method == 'RetrieveCreditReport' && (app.TF4SF__Current_Channel__c != 'Online' && app.TF4SF__Current_Channel__c != 'BizDev') && 
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
					String res = SendStatusFromCreditReport.CallUpdateApiToSendStatus(app, 'CANCELED', 'ReviewSubmitPage');
					data.put('CancelApplication', 'true');
				} else if (method == 'Override') {
					System.debug('method == OverrideApplication');
					app.TF4SF__Primary_Product_Status__c = ' Test Pending Review';
					String res = SendStatusFromCreditReport.CallUpdateApiToSendStatus(app, 'APPROVED', 'ReviewSubmitPage');
					//data.put('Application', 'true');
				}

				//update app;
			} else {
				String body = '[';
				if (String.isNotBlank(app.ProductId__c)) {
					body += '"' + app.ProductId__c + '"';
					prodOrder.put(app.TF4SF__Sub_Product__c, 'Primary');
				}

				if (String.isNotBlank(app.ProductIdCS1__c)) {
					body += ',"' + app.ProductIdCS1__c + '"';
					prodOrder.put(app.TF4SF__Primary_Offer__c, 'crosssell1');
				}

				if (String.isNotBlank(app.ProductIdCS2__c)) {
					body += ',"' + app.ProductIdCS2__c + '"';
					prodOrder.put(app.TF4SF__Second_Offer__c, 'crosssell2');
				}

				if (String.isNotBlank(app.ProductIdCS3__c)) {
					body += ',"' + app.ProductIdCS3__c + '"';
					prodOrder.put(app.TF4SF__Third_Offer__c, 'crosssell3');
				}

				body += ']';
				System.debug('body ===== ' + body);
				System.debug('prodOrder ===== ' + prodOrder);

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
				//StipulationsAPI.callStipulations(app);

				if (res.getStatusCode() == 200) {
					List<Object> k1List = (List<Object>)JSON.deserializeUntyped(responseJSON);
					Map<String, TF4SF__Product_Codes__c> pcMap = new Map<String, TF4SF__Product_Codes__c>();
					List<TF4SF__Product_Codes__c> pcList = TF4SF__Product_Codes__c.getall().values();
					for (TF4SF__Product_Codes__c pc : pcList) { pcMap.put(pc.ML_Code__c, pc); }

					//if (k1 != null && k1.size() > 0) {
					for (Object k1 : k1List) {
						Map<String, Object> k = (Map<String, Object>)k1;

						if (k != null) {
							System.debug(k.get('value'));
							Map<String, Object> l = (Map<String, Object>)k.get('value');
							System.debug('kkkkkkkkkk:' + k);
							System.debug('llllllllll:' + l);

							if (l != null) {
								System.debug('l values: ' + l.get('status'));
								String stat = String.ValueOf(l.get('status'));
								String prodName = pcMap.get(String.valueof(l.get('product_type'))).TF4SF__Sub_Product__c; 
								System.debug('l.get(product_type): ' + l.get('product_type'));
								System.debug('stat: ' + stat);
								System.debug('prodName: ' + prodName);
								System.debug('prodOrder: ' + prodOrder);
								System.debug('prodStatMap: ' + prodStatMap);

								if (prodOrder.get(prodName) == 'Primary') {
									app.TF4SF__Primary_Product_Status__c = prodStatMap.get(stat).Product_Status__c;
									primaryProdStatus = prodStatMap.get(stat).Product_Status__c;
									System.debug('app.TF4SF__Primary_Product_Status__c after setting the status ::::: ' + app.TF4SF__Primary_Product_Status__c);

									if (prodName.containsignoreCase('Checking') || prodName.containsignoreCase('Savings') || prodName.containsignoreCase('Certificates')) {
										app.TF4SF__External_App_ID__c = String.ValueOf(l.get('account_id'));
										data.put('account_id', String.ValueOf(l.get('account_id')));
										//data.put('Application__c.Primary_Product_Status__c', app.TF4SF__Primary_Product_Status__c);
									}
								}

								if (prodOrder.get(prodName) == 'crosssell1') {
									app.TF4SF__Primary_Offer_Status__c = prodStatMap.get(stat).Product_Status__c;
									if (prodName.containsignoreCase('Checking') || prodName.containsignoreCase('Savings') || prodName.containsignoreCase('Certificates')) {
										app.TF4SF__External_AppID_CrossSell1__c = String.ValueOf(l.get('account_id'));
										data.put('account_idCS1', String.ValueOf(l.get('account_id')));
									}
								}

								if (prodOrder.get(prodName) == 'crosssell2') {
									app.TF4SF__Second_Offer_Status__c = prodStatMap.get(stat).Product_Status__c;
									if (prodName.containsignoreCase('Checking') || prodName.containsignoreCase('Savings') || prodName.containsignoreCase('Certificates')) {
										app.TF4SF__External_AppID_CrossSell2__c = String.ValueOf(l.get('account_id'));
										data.put('account_idCS2', String.ValueOf(l.get('account_id')));
									}
								}

								if (prodOrder.get(prodName) == 'crosssell3') {
									System.debug('entered crosssell3');
									app.TF4SF__Third_Offer_Status__c = prodStatMap.get(stat).Product_Status__c;
									if (prodName.containsignoreCase('Checking') || prodName.containsignoreCase('Savings') || prodName.containsignoreCase('Certificates')) {
										app.TF4SF__External_AppID_CrossSell3__c = String.ValueOf(l.get('account_id'));
										data.put('account_idCS3', String.ValueOf(l.get('account_id')));
									}
								}

								//app.TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
								//app.TF4SF__External_App_ID__c = String.ValueOf(l.get('account_id'));
								//data.put('account_id', String.ValueOf(l.get('account_id')));
							}
						}
					}

					System.debug('app before StipulationsAPI call: ' + app);
					List<TF4SF__Application__c> aList = new List<TF4SF__Application__c>{app};
					appl = StipulationsAPI.callStipulations(aList);
					System.debug('appl after StipulationsAPI call: ' + appl);
					//if (appl.size() > 0 && appl[0].TF4SF__Primary_Product_Status__c != null) { app.TF4SF__Primary_Product_Status__c = appl[0].TF4SF__Primary_Product_Status__c; }

					System.debug('appl.size() before update in ReviewSubmitExtension: ' + appl.size());
					System.debug('appl[0].TF4SF__Primary_Product_Status__c before update in ReviewSubmitExtension: ' + appl[0].TF4SF__Primary_Product_Status__c);
					//System.debug('app.TF4SF__Primary_Product_Status__c before update in ReviewSubmitExtension: ' + app.TF4SF__Primary_Product_Status__c);
					//update app1;
					System.debug('application after update: ' + app);
				} else {
					data.put('ErrorStatusCode', String.ValueOf(res.getStatusCode()));
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ReviewSubmitExtension - ErrorStatusCode: ' + String.ValueOf(res.getStatusCode())));
				}
			}

			app.TF4SF__Primary_Product_Status__c = primaryProdStatus;
			update app;
			
			List<TF4SF__Products__c> insertProd = new List<TF4SF__Products__c>();
			if (abtAcc != null && prodList.size() == 0 && prodOrder.size() > 0) {
				for (String p : prodOrder.keySet()) {
					TF4SF__Products__c prod = new TF4SF__Products__c();
					prod.TF4SF__Product_Name__c = p;
					prod.TF4SF__Application__c = abtAcc.TF4SF__Application__c;

					if (prodOrder.get(p) == 'Primary') {
						prod.TF4SF__Product_Type__c = 'Primary';
						prod.ProductId__c = (String.isNotBlank(abtAcc.TF4SF__Application__r.ProductId__c) ? abtAcc.TF4SF__Application__r.ProductId__c : '');
					}

					if (prodOrder.get(p) == 'crosssell1') {
						prod.TF4SF__Product_Type__c = 'Cross-Sell 1';
						prod.ProductId__c = (String.isNotBlank(abtAcc.TF4SF__Application__r.ProductIdCS1__c) ? abtAcc.TF4SF__Application__r.ProductIdCS1__c : '');
					}

					if (prodOrder.get(p) == 'crosssell2') {
						prod.TF4SF__Product_Type__c = 'Cross-Sell 2';
						prod.ProductId__c = (String.isNotBlank(abtAcc.TF4SF__Application__r.ProductIdCS2__c) ? abtAcc.TF4SF__Application__r.ProductIdCS2__c : '');
					}

					if (prodOrder.get(p) == 'crosssell3') {
						prod.TF4SF__Product_Type__c = 'Cross-Sell 3';
						prod.ProductId__c = (String.isNotBlank(abtAcc.TF4SF__Application__r.ProductIdCS3__c) ? abtAcc.TF4SF__Application__r.ProductIdCS3__c : '');
					}

					System.debug('abtacc term: ' + abtAcc.TF4SF__Term_VehicleLoans__c);
					if (abtAcc.TF4SF__Term_VehicleLoans__c != null && p.contains('Vehicle Loans')) {
						prod.Requested_Term__c = abtAcc.TF4SF__Term_VehicleLoans__c;
					} else if (abtAcc.TF4SF__Custom_Number1__c != null && p.contains('Vehicle Loans')) {
						prod.Requested_Term__c = abtAcc.TF4SF__Custom_Number1__c;
					} else if (abtAcc.TF4SF__Custom_Number2__c != null && p.contains('Vehicle Loans')) {
						prod.Requested_Term__c = abtAcc.TF4SF__Custom_Number2__c;
					} else if (abtAcc.TF4SF__Term_Personalloans__c != null && p.contains('Personal Loans')) {
						prod.Requested_Term__c = abtAcc.TF4SF__Term_Personalloans__c;
					}

					if (abtAcc.TF4SF__Requested_Loan_Amount_PersonalLoans__c != null && p.contains('Personal Loans')) {
						prod.TF4SF__Requested_Loan_Amount__c = abtAcc.TF4SF__Requested_Loan_Amount_PersonalLoans__c;
					} else if (abtAcc.TF4SF__Requested_Loan_Amount_VehicleLoans__c != null && p.contains('Vehicle Loans')) {
						prod.TF4SF__Requested_Loan_Amount__c = abtAcc.TF4SF__Requested_Loan_Amount_VehicleLoans__c;
					} else if (abtAcc.TF4SF__Custom_Currency7__c != null && p.contains('Vehicle Loans')) {
						prod.TF4SF__Requested_Loan_Amount__c = abtAcc.TF4SF__Custom_Currency7__c;
					} else if (abtAcc.TF4SF__Custom_Currency8__c != null && p.contains('Vehicle Loans')) {
						prod.TF4SF__Requested_Loan_Amount__c = abtAcc.TF4SF__Custom_Currency8__c;
					} else if (abtAcc.TF4SF__Requested_Credit_Limit_Ccards__c != null && p.contains('Credit Cards')) {
						prod.TF4SF__Requested_Credit_Limit__c = abtAcc.TF4SF__Requested_Credit_Limit_Ccards__c;
					}

					insertProd.add(prod);
				}

				upsert insertProd;
			}
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in ReviewSubmitExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in ReviewSubmitExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'ReviewSubmitExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ReviewSubmitExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'));
		System.debug('print data: ' + data);
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
		String errorMsg = null;

		try {
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
			System.debug('req-->' + req);
			System.debug('response getbody: ' + response.getbody());

			if (response.getStatusCode() != 200) {
				KYCReqRes.put('KYC Response Failed', 'KYC-Failed');
				System.debug('entered: ');
				errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
			} else {
				responseJson = response.getBody();
				//if (k.get('Success') == true) {
				System.debug('Response: ' + responseJson);
				//LogStorage.InsertDebugLog(appId, req.getbody(), 'Credit Report Request');
				//LogStorage.InsertDebugLog(appId, responseJSON, 'Credit Report Response');
				KYCReqRes.put('KYC Response', responseJson);
			}

			//return KYCReqRes;
		} catch (Exception ex) {
			errorMsg = ex.getLineNumber() + '  ' + ex.getMessage();
		} finally {
			LogStorage.InsertDebugLog(appId, req.getbody(), 'Credit Report Request');
			LogStorage.InsertDebugLog(appId, responseJSON, 'Credit Report Response');
			if (String.isNotBlank(errorMsg)) {
				LogStorage.InsertDebugLog(appId, errorMsg, 'Credit Report Response');
			}
		}

		return KYCReqRes;
	}

	public Boolean getMemberAPIcall (String ssn) {
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String url ='';
		String header = '';
		String responseJson = '';
		String CustomerId = '';

		if (alpha.Enable_Production__c == true) {
			url = alpha.Production_URL__c;
			header = 'JWT ' + alpha.Production_Token__c;
		} else {
			url = alpha.Sandbox_URL__c;
			header = 'JWT ' + alpha.Sandbox_Token__c;
		}

		try {
			HttpRequest req = new HttpRequest();
			String body = '';
			req.setTimeout(120 * 1000);  //120 seconds
			url += 'api/cache/customers/?federalid=' + ssn + '&fullaccounts=true';
			//String header = 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'; 
			req.setEndpoint(url);
			req.setHeader('authorization', header);
			req.setMethod('GET'); 
			req.setHeader('content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');
			Http http = new Http();
			HttpResponse response;
			response = http.send(req); 

			if (response.getStatusCode() != 200) {
				String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
			}

			responseJson = response.getBody();
			System.debug('Response: ' + responseJson);

			List<Object> a = (List<Object>)JSON.deserializeUntyped(responseJson);
			System.debug('the response is ' + a[0]);
			Map<String, Object> m = (Map<String, Object>)a[0];
			System.debug('the response is ' + m.get('value'));
			List<Object> k = (List<Object>)m.get('value');

			if (k.size() > 0) {
				for (Object u : k) {
					Map<String, Object> l = (Map<String, Object>)u;
					CustomerId = String.valueOf(l.get('id'));
					System.debug('customerId: ' + customerId);

					if (String.isNotBlank(CustomerId)) {
						return true;
					} else {
						return false;
					}
				}
			}

			return false;
		} catch (Exception ex) {
			System.debug('Exception in getMemberAPIcall ' + ex.getLineNumber() + '  ' + ex.getMessage());
			return false;
		}
	}
}