global class createMultiProdApp {
	public static void JSONGenerator(String applicationId) {
		TF4SF__application__c app;
		if (applicationid != null && applicationId != '') {
			String appquery = updateProdApp.selectStar('TF4SF__Application__c') + 'WHERE ID = \'' + applicationId + '\'';
			app = Database.query(appquery);
		}

		Map<String, TF4SF__Product_Codes__c> prodCodeMap = new Map<String, TF4SF__Product_Codes__c>();
		String prodCode = '';

		for (TF4SF__Product_Codes__c pc : TF4SF__Product_Codes__c.getall().values()) {
			prodCodeMap.put(pc.TF4SF__Sub_Product__c, pc);
			if (pc.TF4SF__Sub_Product__c == app.TF4SF__Sub_Product__c) { prodCode = pc.ML_Code__c; }
		}

		Map<Id,TF4SF__Products__c> prods = new Map<Id, TF4SF__Products__c>([SELECT Id, Name, TF4SF__Product_Name__c FROM TF4SF__Products__c WHERE TF4SF__Application__c = :applicationId]);
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartArray();
			gen.writeStartObject();
				gen.writeStringField('product_type', (String.isNotBlank(prodCode) ? prodCode : ''));
				gen.writeStringField('product_name', (app.TF4SF__Sub_Product__c != null ? app.TF4SF__Sub_Product__c : ''));
			gen.writeEndObject();

			if (prods.size() > 0) {
				for (TF4SF__Products__c prod : prods.values()) {
					gen.writeStartObject();
						gen.writeStringField('product_type', (String.isNotBlank(prodCodeMap.get(prod.TF4SF__Product_Name__c).ML_Code__c) ? prodCodeMap.get(prod.TF4SF__Product_Name__c).ML_Code__c : ''));
						gen.writeStringField('product_name', (prod.TF4SF__Product_Name__c != null ? prod.TF4SF__Product_Name__c : ''));
				  
					gen.writeEndObject();
				}
			}

		gen.writeEndArray();
		String jsonString = gen.getAsString();
		http_postMethod(jsonString,app,prods);
	}
	
	public static String http_postMethod(String jsonBody, TF4SF__Application__c app, Map<Id, TF4SF__Products__c> prodMap) {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setHeader('content-type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setMethod('POST');
		req.setTimeout(120000);

		if (aPack.Enable_Production__c == false) {
			req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/');   
		} else {
			req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/');
		}
		
		if (aPack.Enable_Production__c == false) {
			req.setHeader('Authorization', aPack.Sandbox_Token__c);      
		} else {
			req.setHeader('Authorization', aPack.Production_Token__c);      
		}

		// req.setEndpoint('https://dev.sandboxbanking.com/api/product-applications/');
		//req.setHeader('Authorization', 'Token c1cb7333444e8a890882fd459c945692c9f4a47f');      
		req.setBody(jsonBody);
		System.debug('jsonbodu: ' + jsonbody);
		System.debug('request: ' + req.getbody());
		HttpResponse res = http.send(req);
		System.debug('response: ' + res.getbody());
		InsertDebugLog(app.Id, req.getbody(), 'GetStartedPage Request');
		InsertDebugLog(app.Id, res.getbody(), 'GetStartedPage Response');

		if (res.getStatusCode() == 200) { 
			System.debug('success'); 
			List<Object> m = (List<Object>)JSON.deserializeUntyped(res.getBody());
			System.debug('m: ' + m);
			List<TF4SF__Products__c> pList = new List<TF4SF__Products__c>();

			for (Object o : m) {
				Map<String, Object> n = (Map<String, Object>)o;
				System.debug('n1: ' + n);

				if (n.containsKey('value')) {
					System.debug('entered n');
					Map<String, Object> l = (Map<String, Object>)n.get('value');
					System.debug('l: ' + l);
					
					if (l.containsKey('id')) {
						String product_Name = String.ValueOf(l.get('product_name'));
						String productName = app.TF4SF__Product__c;
						 System.debug('-----app.TF4SF__Product__c----' + app.TF4SF__Product__c);
					   // if (l.get('product_name') == app.TF4SF__Product__c) {
						if (product_Name .Contains(productName ) ) {
							System.debug('l: '+l+'----'+l.get('id'));
							TF4SF__Application__c a = new TF4SF__Application__c();
							a.Id = app.Id;
							a.ProductId__c = String.ValueOf(l.get('id'));
							System.debug('---String.ValueOf(l.get(id)--------' + String.ValueOf(l.get('id')));
						   // update a;
							updateApplication(app.Id,a.ProductId__c);
						} else {
							for (TF4SF__Products__c p : prodMap.values()) {
								if (p.TF4SF__Product_Name__c == String.ValueOf(l.get('product_name'))) {
									p.ProductId__c = String.ValueOf(l.get('id'));
									pList.add(p);
								}
							}
						}
					}
				}
			}

			update pList;
		}
		//  Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
		
		return null;
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
		insert debugList;
	}

	@future(callout=true)
		public static void updateApplication (String appId, String prod) {
		TF4SF__Application__c a = new TF4SF__Application__c();
		a.id = appId;
		a.ProductId__c = prod;
		update a;
	}
}