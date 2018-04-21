global class SubmitToCore {
	public static Map<String, String> JSONGenerator(Map<String, String> data) {
		TF4SF__Application__c app;
		TF4SF__Identity_Information__c iden;
		TF4SF__About_Account__c abtAcc;
		TF4SF__Employment_Information__c empInfo;
		KYC_OOW__c kycInfo;
		//String resJson = '';
		Map<String, String> resJson = new Map<String, String>();

		try {
			String applicationId = data.get('id');
			//SSN__c sNum = SSN__c.getOrgDefaults();

			if (String.isNotBlank(applicationid)) {
				String appquery = selectStar('TF4SF__Application__c') + 'WHERE ID = \'' + applicationId + '\'';
				app = Database.query(appquery);
				String idenQuery = selectStar('TF4SF__Identity_Information__c') + 'WHERE TF4SF__Application__c = \'' + applicationId + '\'';
				iden = Database.query(idenQuery);
				String abtAccQuery = selectStar('TF4SF__About_Account__c') + 'WHERE TF4SF__Application__c = \'' + applicationId + '\'';
				abtAcc = Database.query(abtAccQuery);
				String empQuery = selectStar('TF4SF__Employment_Information__c') + 'WHERE TF4SF__Application__c = \'' + applicationId + '\'';
				empInfo = Database.query(empQuery);
				String kycQuery = selectStar('KYC_OOW__c') + 'WHERE Application_Id__c = \'' + applicationId + '\'';
				if (Database.query(kycQuery).size() > 0) { kycInfo = (KYC_OOW__c)Database.query(kycQuery); }
			}

			Map<String, String> empMap = new Map<String, String>();
			for (Employment_Status__mdt empSt : [SELECT MasterLabel, Employment_Code__c FROM Employment_Status__mdt]) {
				empMap.put(empSt.MasterLabel, empSt.Employment_Code__c);
			}

			Map<String, String> appTypeMap = new Map<String, String>();
			for (Applicant_Type__mdt appType : [SELECT MasterLabel, Code__c FROM Applicant_Type__mdt]) {
				appTypeMap.put(appType.MasterLabel, appType.Code__c);
			}

			Map<String, String> occStatusMap = new Map<String, String>();
			for (Occupancy_Status__mdt occ : [SELECT MasterLabel, Code__c FROM Occupancy_Status__mdt]) {
				occStatusMap.put(occ.MasterLabel, occ.Code__c);
			}

			Map<String, String> immStatusMap = new Map<String, String>();
			for (Immigration_Status__mdt immType : [SELECT MasterLabel, Code__c FROM Immigration_Status__mdt]) {
				immStatusMap.put(immType.MasterLabel, immType.Code__c);
			}

			System.debug('apptypemap: '+appTypeMap);
			Map<String,String> prodMap = new Map<String,String>();
			if (String.isNotBlank(app.ProductId__c)) { prodMap.put(app.TF4SF__Sub_Product__c,app.ProductId__c); }
			if (String.isNotBlank(app.ProductIdCS1__c)) { prodMap.put(app.TF4SF__Primary_Offer__c,app.ProductIdCS1__c); }
			if (String.isNotBlank(app.ProductIdCS2__c)) { prodMap.put(app.TF4SF__Second_Offer__c,app.ProductIdCS2__c); }
			if (String.isNotBlank(app.ProductIdCS3__c)) { prodMap.put(app.TF4SF__Third_Offer__c,app.ProductIdCS3__c); }

			System.debug('identity: ' + iden);
			System.debug('phone, email, ' + data.get('Application__c.Email_Address__c') + '---' + data.get('Application__c.Primary_Phone_Number__c') + '---');
			//http_postMethod(jsonString);
			String template = '';

			SubmitToCoreHelper stch = new SubmitToCoreHelper();

			template = stch.buildJSONRequest(data, prodMap, empMap, occStatusMap, immStatusMap, appTypeMap, app, iden, abtAcc, empInfo, kycInfo);
			System.debug('template after fetching from SubmitToCoreHelper class ::::' + template);

			if (app.ProductId__c != null && app.ProductId__c != '' && String.isNotBlank(template)) {
				resJson = http_postMethod(template, applicationId, app.TF4SF__application_page__c);
			} else {
				try {
					createProdApp.JSONGenerator(applicationId,data);
				} catch (Exception e) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in SubmitToCore class - call to createProdApp.JSONGenerator(): ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; cause: ' + e.getCause() + '; stack trace: ' + e.getStackTraceString()));
					System.debug('server-errors: ' + e.getMessage()+'----LINE NUMBER---'+e.getLineNumber());
				}
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in SubmitToCore class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; cause: ' + e.getCause() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage()+'----LINE NUMBER---'+e.getLineNumber());
		}

		return resJson;
	}

	public static Map<String, String> http_postMethod(String jsonBody, String appId, String page) {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setHeader('content-type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setMethod('PUT');
		req.setTimeout(120000);
		//req.setEndpoint('https://dev.sandboxbanking.com/api/product-applications/');
		String authorizationHeader;

		if (aPack.Enable_Production__c == false) {
			req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/');
			authorizationHeader = 'JWT ' +
			aPack.Sandbox_Token__c;
		} else {
			req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/');
			authorizationHeader = 'JWT ' +
			aPack.Production_Token__c;
		}

		//req.setHeader('Authorization', 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'); 
		req.setHeader('Authorization', authorizationHeader);     
		req.setBody(jsonBody);
		System.debug('jsonbodu: ' + jsonbody);
		System.debug('request: ' + req.getbody());
		HttpResponse res = http.send(req);
		System.debug('response: ' + res.getbody());
		String responseJSON = res.getBody();

		if (res.getStatusCode() == 200) { 
			System.debug('responseJSON: ' + responseJSON);
			List<Object> k1 = (List<Object>)JSON.deserializeUntyped(responseJSON); 
			Map<String, Object> k = (Map<String, Object>)k1[0];
		}

		Map<String, String> reqRes = new Map<String, String>();
		reqRes.put('coreReq', jsonBody);
		reqRes.put('coreRes', responseJSON);
		if (Page != 'IdentityPage' && page != 'ApplicationDetailPage') {
			/*TF4SF__Application__c a = new TF4SF__Application__c();
			List<TF4SF__Application__c> aList = new List<TF4SF__Application__c>();

			if (k.get('success') == true) {
				a.Id = appId;
				a.App_Submitted_to_Alfa__c = true;
				aList.add(a);
			} else {
				a.Id = appId;
				a.App_Submitted_to_Alfa__c = false;
				aList.add(a);
			}

			if (aList.size() > 0) { update aList; }*/
			//InsertDebugLog(appId, jsonBody, page + 'UpdateCoreAPP Request');
			//InsertDebugLog(appId, responseJSON, page + 'UpdateCoreApp Response');
		}

		//Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
		//System.debug('m: ' + m);

		//return responseJson;
		return reqRes;
	}

	@future
	public static void InsertDebugLog (String appId, String json, String Callout) {
		List<TF4SF__Debug_Logs__c> debugList = new List<TF4SF__Debug_Logs__c>();
		TF4SF__Debug_Logs__c debug = new TF4SF__Debug_Logs__c();
		debug.TF4SF__Application__c = appId;
		debug.TF4SF__Debug_Message__c = json;
		debug.TF4SF__Source__c = Callout;
		debug.TF4SF__Timestamp__c = String.valueOf(System.now());
		debugList.add(debug);
		if (debugList.size() > 0) { insert debugList; }
	}

	global static string selectStar(String objectName) {
		SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
		DescribeSObjectResult objDef = objToken.getDescribe();
		Map<String, SObjectField> fields = objDef.fields.getMap(); 
		Set<String> fieldSet = fields.keySet();
		List<String> fieldsToQuery = new List<String>{};

		for (String fieldName : fieldSet) {
			SObjectField fieldToken = fields.get(fieldName);
			DescribeFieldResult selectedField = fieldToken.getDescribe();

			//respect CRUD/FLS
			if (selectedField.isAccessible()) {
				fieldsToQuery.add(selectedField.getName());
			} else {
				//System.debug('not accessible: ' + selectedField.getName());
			}
		}

		String queryString = 'SELECT ';
		queryString += String.join(fieldsToQuery, ', ');
		queryString += ' FROM ' + objectName + ' ';
		return querystring;
	}
}