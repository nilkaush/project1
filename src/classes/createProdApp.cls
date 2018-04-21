global class createProdApp {
	public static void JSONGenerator(String applicationId) {
		TF4SF__application__c app;
		String prodCode = '';
		JSONGenerator gen = JSON.createGenerator(true);

		if (applicationid != null && applicationId != '') {
			String appquery = updateProdApp.selectStar('TF4SF__Application__c') + 'WHERE Id = \'' + applicationId + '\'';
			app = Database.query(appquery);
		}

		for (TF4SF__Product_Codes__c pc : TF4SF__Product_Codes__c.getall().values()) {
			if (pc.TF4SF__Sub_Product__c == app.TF4SF__Sub_Product__c) { prodCode = pc.ML_Code__c; }
		}

		gen.writeStartArray();
		gen.writeStartObject();
			gen.writeStringField('product_type', (String.isNotBlank(prodCode) ? prodCode : ''));
			gen.writeStringField('product_name', (app.TF4SF__Sub_Product__c != null ? app.TF4SF__Sub_Product__c : ''));
			/*  gen.writeFieldName('membership_eligibility');
			gen.writeStartObject();
				gen.writeStringField('question', (question != null ? question : ''));
				gen.writeStringField('answer', (answer != null ? answer : ''));
			gen.writeEndObject();
			gen.writeFieldName('applicants');
			gen.writeStartArray();
			gen.writeStartObject();
				gen.writeStringField('first_name', firstName);
				gen.writeStringField('last_name', lastName);
				SSN = (SSN.contains('-')) ? SSN.replace('-','').trim() : SSN;
				gen.writeStringField('federal_id', SSN);
				gen.writeStringField('email_address', (email != null ? email : ''));
			gen.writeEndObject();
			gen.writeEndArray();*/
		gen.writeEndObject();
		gen.writeEndArray();
		String jsonString = gen.getAsString();
		http_postMethod(jsonString,applicationId);
	}

	public static String http_postMethod(String jsonBody, String appId) {
		try {
			Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			String authorizationHeader;
			req.setHeader('content-type', 'application/json');
			req.setHeader('Accept', 'application/json');
			req.setMethod('POST');
			req.setTimeout(120000);

			if (aPack.Enable_Production__c == false) {
				req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/');
				authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
			} else {
				req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/');
				authorizationHeader = 'JWT ' + aPack.Production_Token__c;
			}
			
			req.setHeader('Authorization', authorizationHeader);
			req.setBody(jsonBody);
			System.debug('jsonbodu: ' + jsonbody);
			System.debug('request: ' + req.getbody());
			HttpResponse res = http.send(req);
			System.debug('response: ' + res.getbody());
			LogStorage.InsertDebugLog(appId, req.getBody(),'CreateProdAppClass Request');
			LogStorage.InsertDebugLog(appId, res.getBody(),'CreateProdAppClass Response');

			if (res.getStatusCode() == 200) { 
				System.debug('success'); 
				List<Object> m = (List<Object>)JSON.deserializeUntyped(res.getBody());
				System.debug('m: ' + m);

				for (Object o : m) {
					Map<String, Object> n = (Map<String, Object>)o;
					System.debug('n1: ' + n);

					if (n.containsKey('value')) {
						System.debug('entered n');
						Map<String, Object> l = (Map<String, Object>)n.get('value');
						System.debug('l: ' + l);

						if (l.containsKey('id')) {
							System.debug('l: ' + l + '----' + l.get('id'));
							TF4SF__Application__c a = new TF4SF__Application__c();
							a.Id = appId;
							a.ProductId__c = String.ValueOf(l.get('id'));
							update a;
						}
					}
				}
			}
		} catch (Exception e) {
			System.debug('server-errors: ' + e.getMessage());
		}

		return null;
	}
}