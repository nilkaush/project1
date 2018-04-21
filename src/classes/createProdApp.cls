global class createProdApp {
	public static void JSONGenerator(String applicationId, Map<String, String> data) {
		TF4SF__application__c app;
		String prodCode = '';
		Map<String, String> prodCodeMap = new Map<String, String>();
		System.debug('tdataaaa:' + data);

		try {
			//System.debug('tdataaaa:'+data);
			//JSONGenerator gen = JSON.createGenerator(true);

			if (applicationid != null && applicationId != '') {
				String appquery = submitToCore.selectStar('TF4SF__Application__c') + 'WHERE Id = \'' + applicationId + '\'';
				app = Database.query(appquery);
			}

			System.debug('primaryofffer: ' + app.TF4SF__Primary_Offer__c);
			System.debug('tdataaaa:' + data.get('Application__c.Primary_Offer__c'));
			List<String> pList = new List<String>{app.TF4SF__Sub_Product__c};
			if (String.isNotBlank(data.get('Application__c.Primary_Offer__c'))) { pList.add(data.get('Application__c.Primary_Offer__c')); }
			if (String.isNotBlank(data.get('Application__c.Second_Offer__c'))) { pList.add(data.get('Application__c.Second_Offer__c')); }
			if (String.isNotBlank(data.get('Application__c.Third_Offer__c'))) { pList.add(data.get('Application__c.Third_Offer__c')); }

			for (TF4SF__Product_Codes__c pc : TF4SF__Product_Codes__c.getall().values()) {
				prodCode = pc.ML_Code__c; 
				prodCodeMap.put(pc.TF4SF__Sub_Product__c, pc.ML_Code__c);
				prodCodeMap.put('Personal Loans - Personal Loan', 'PL_3U04');
				prodCodeMap.put('Personal Loans - Personal Line of Credit', 'PL_3U01');
			}

			System.debug('prodcodeMap: ' + prodcodeMap);
			System.debug('Plist: ' + plist);
			/*gen.writeStartArray();
			for (Integer i = 0; i < pList.size(); i++) {
				System.debug('plisti: ' + pList[i]);
				gen.writeStartObject();
					gen.writeStringField('product_type', (String.isNotBlank(prodCodeMap.get(pList[i])) ? prodCodeMap.get(pList[i]) : ''));
					gen.writeStringField('product_name', (app.TF4SF__Sub_Product__c != null ? prodCodeMap.get(pList[i]) : ''));
				gen.writeEndObject();
			}
			gen.writeEndArray();*/

			String template = '';
			template += '[';

			for (Integer i = 0; i < pList.size(); i++) {
				System.debug('plisti: ' + pList[i] + '-----' + prodcodeMap.get(pList[i]));
				template +=   '{';
				template +=    '"product_type": "' + (String.isNotBlank(prodCodeMap.get(pList[i])) ? prodCodeMap.get(pList[i]) : '') + '",';
				template +=    '"product_name": "' + pList[i] + '"';
				template +=  '}';
				if (i < pList.Size() - 1) { template += ','; }
			}

			template += ']';
			//String jsonString = gen.getAsString();
			System.debug('jsonstring: ' + template);
			http_postMethod(template,applicationId);
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in createProdApp class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; cause: ' + e.getCause() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}
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
				String productId;
				String productIdcs1;
				String productIdcs2;
				String productIdcs3;
				System.debug('success');
				List<Object> m = (List<Object>)JSON.deserializeUntyped(res.getBody());
				System.debug('m: ' + m);
				List<TF4SF__Application__c> updateAppList = new List<TF4SF__Application__c>();
				TF4SF__Application__c a = new TF4SF__Application__c();
				a.Id = appId;
				//for (Object o : m) {

				for (Integer i = 0; i < m.Size(); i++) {
					Map<String, Object> n = (Map<String, Object>)m[i];
					System.debug('n1: ' + n);

					if (n.containsKey('value')) {
						System.debug('entered n');
						Map<String, Object> l = (Map<String, Object>)n.get('value');
						System.debug('l: ' + l);

						if (l.containsKey('id')) {
							System.debug('l: ' + l + '----' + l.get('id'));

							if (i == 0) {
								if (String.isNotBlank(String.ValueOf(l.get('id')))) {
									a.ProductId__c = String.ValueOf(l.get('id'));
								}

								if (String.isNotBlank(String.ValueOf(l.get('name')).split(' ')[1])) {
									a.Meridian_Link_Number__c = String.ValueOf(l.get('name')).split(' ')[1];
								}
							}

							if (i == 1) { 
								if (String.isNotBlank(String.ValueOf(l.get('id')))) {
									a.ProductIdCS1__c = String.ValueOf(l.get('id'));
								}

								if (String.isNotBlank(String.ValueOf(l.get('name')).split(' ')[1])) {
									a.Meridian_Link_Number_CS1__c = String.ValueOf(l.get('name')).split(' ')[1];
								}
							}

							if (i == 2) { 
								if (String.isNotBlank(String.ValueOf(l.get('id')))) {
									a.ProductIdCS2__c = String.ValueOf(l.get('id'));
								}

								if (String.isNotBlank(String.ValueOf(l.get('name')).split(' ')[1])) {
									a.Meridian_Link_Number_CS2__c = String.ValueOf(l.get('name')).split(' ')[1];
								}
							}

							if (i == 3) { 
								if (String.isNotBlank(String.ValueOf(l.get('id')))) {
									a.ProductIdCS3__c = String.ValueOf(l.get('id'));
								}

								if (String.isNotBlank(String.ValueOf(l.get('name')).split(' ')[1])) {
									a.Meridian_Link_Number_CS3__c = String.ValueOf(l.get('name')).split(' ')[1];
								}
							}
						}
					}
				}

				update a;
			}
		} catch (Exception e) {
			System.debug('server-errors: ' + e.getMessage() + 'line number-----' + e.getLinenumber());
		}

		return null;
	}
}