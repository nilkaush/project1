public class MessagesAPI {
	public static void callMessages(List<String> prodId) {
		try {
			Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
			Map<String, Product_Status_Mapping__c> prodStatMap = Product_Status_Mapping__c.getAll();
			String pIds = '';
			for (String pid : prodId) { pIds = pIds + ';' + pid; }
			pIds = pIds.removeStart(';');
			System.debug('pIds: ' + pIds);
			HttpRequest req = new HttpRequest();

			req.setMethod('GET'); 
			req.setHeader('content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');
			String authorizationHeader;

			if (aPack.Enable_Production__c == false) {
				req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/messages/?prodappids=' + pIds);
				authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
			} else {
				req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/messages/?prodappids=' + pIds);
				authorizationHeader = 'JWT ' + aPack.Production_Token__c;
			}

			req.setHeader('Authorization', authorizationHeader);
			//req.setEndpoint('https://outrun.kpcu.com/api/product-applications/?prodappids=' + ProdId);
			Http http = new Http();
			HttpResponse response = http.send(req);
			System.debug('request: ' + req.getbody());
			System.debug('response: ' + response.getbody());
			Map<String, TF4SF__Products__c> prdMap = new Map<String, TF4SF__Products__c>();
			List<TF4SF__Products__c> prodList = [SELECT Id, Name, ProductId__c, TF4SF__Application__c, TF4SF__Requested_Loan_Amount__c, TF4SF__Rate__c, TF4SF__Term__c FROM TF4SF__Products__c WHERE ProductId__c IN :prodId];
			for (TF4SF__Products__c p : prodList) { prdMap.put(p.ProductId__c, p); }

			if (response.getStatusCode() == 200) {
				List<Object> k1 = (List<Object>)JSON.deserializeUntyped(response.getbody()); 
				System.debug('k1: ' + k1);
				Map<String, Object> k = (Map<String, Object>)k1[0];
				System.debug('k: ' + k);
				Map<String,Object> m = (Map<String,Object>)k.get('value');
				System.debug('m: ' + m);
				List<Object> msg = (List<Object>)m.get('messages');
				Map<String, Note> ntMap = new Map<String, Note>();
				List<Note> nList = new List<Note>();
				System.debug('msg: ' + msg);

				for (Note nt : [SELECT Id, ParentId, Body FROM Note WHERE parentId = :prdMap.get(prodId[0]).Id]) {
					ntMap.put(nt.Body, nt);
				}

				for (Object o : msg) {
					if (!ntMap.containsKey(String.ValueOf(o))) {
						note n = new note();
						n.parentId = prdMap.get(prodId[0]).Id;
						n.title = 'Message from officer';
						n.body = String.ValueOf(o);
						nList.add(n);
					}
				}

				if (nList.size() > 0) { insert nList; }
			}
		} catch (Exception e) {
			System.debug('exception in the messagesapi class: ' + e.getmessage() + '---' + e.getlinenumber());
		}
	}
}