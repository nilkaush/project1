public class StatusAPI {
	public static void updateStatus(String prodId, String appId) {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();

		try {
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			req.setHeader('content-type', 'application/json');
			req.setHeader('Accept', 'application/json');
			req.setMethod('GET');
			req.setTimeout(120000);
			String authorizationHeader;
	
			if (aPack.Enable_Production__c == false) {
				req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/?prodappids=' + prodId);
				authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
			} else {
				req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/?prodappids=' + prodId);
				authorizationHeader = 'JWT ' + aPack.Production_Token__c;
			}
	
			req.setHeader('Authorization', authorizationHeader);
			HttpResponse res = http.send(req);
			String responseJSON = res.getBody();
			System.debug('responsejson: '+responseJSON);

			if (res.getStatusCode() == 200) {
				List<Object> k1 = (List<Object>)JSON.deserializeUntyped(responseJSON);
	
				if (k1 != null && k1.size() > 0) {
					Map<String, Object> k = (Map<String, Object>)k1[0];
					if (k != null && k.get('success') == true) {
						
						System.debug(k.get('value'));
						Map<String, Object> l = (Map<String, Object>)k.get('value');
						System.debug('kkkkkkkkkk:' + k);
						System.debug('llllllllll:' + l);

						if (l != null) {
							System.debug('l values: ' + l.get('status'));
							TF4SF__application__c app = new TF4SF__application__c();
							app.id = appId;
							app.TF4SF__Primary_Product_Status__c = String.ValueOf(l.get('status'));
							if (l.containsKey('account_id')) { app.Custom_Text44__c = String.ValueOf(l.get('account_id')); }
							
							update app;
						}
					}
				}
			}
		} catch (Exception e) {
			System.debug('Error in StatusAPI Class: ' + e.getMessage());
		}
	}
}