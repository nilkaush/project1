public class OFACReport {
	public static Map<String, String> OFACRequest_Method(String productId) {
		Map<String, String> data = new Map<String, String>();
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
		Map<String, String> KYCReqRes = new Map<String, String>();
		String responseJson = '';
		HttpRequest req = new HttpRequest();
		req.setTimeout(120 * 1000);  //120 seconds

		if (aPack.Enable_Production__c == false) {
			req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/kyc/?prodappids=' + ProductId);
		} else {
			req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/kyc/?prodappids=' + ProductId);
		}

		if (aPack.Enable_Production__c == false) {
			req.setHeader('Authorization', aPack.Sandbox_Token__c);      
		} else {
			req.setHeader('Authorization', aPack.Production_Token__c);      
		}

		req.setMethod('GET'); 
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 
		System.debug('response getbody: ' + response.getbody());
		data.put('KYC Report', response.getbody());

		return data;
	}
}