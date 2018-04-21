public class StipulationsAPI {
	public static void callStipulations(String prodId, String appId) {
		try {
			Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
			Map<String, Product_Status_Mapping__c> prodStatMap = Product_Status_Mapping__c.getAll();
			HttpRequest req = new HttpRequest();
			//ProdId = 'e6cabb97d309401bbcec4317c490a2e0';
			//ProdId = '8440186e69f4494da050673798045b26';
			req.setMethod('GET'); 
			req.setHeader('content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');
			String authorizationHeader;

			if (aPack.Enable_Production__c == false) {
				req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/?prodappids=' + ProdId);
				authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
			} else {
				req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/?prodappids=' + ProdId);
				authorizationHeader = 'JWT ' + aPack.Production_Token__c;
			}

			req.setHeader('Authorization', authorizationHeader);
			//req.setEndpoint('https://outrun.kpcu.com/api/product-applications/?prodappids=' + ProdId);
			Http http = new Http();
			HttpResponse response = http.send(req);
			System.debug('request: ' + req.getbody());
			System.debug('response: ' + response.getbody());
			Set<String> drTypeSet = new Set<String>();
			List<TF4SF__Products__c> prodList = [SELECT Id, Name, TF4SF__Application__c, TF4SF__Requested_Loan_Amount__c, TF4SF__Rate__c, TF4SF__Term__c FROM TF4SF__Products__c WHERE TF4SF__Application__c = :appId];
			List<TF4SF__Application__c> appList = [SELECT Id, TF4SF__Primary_Product_Status__c,TF4SF__Sub_Product__c, Custom_Text44__c FROM TF4SF__Application__c WHERE Id = :appId];
			List<TF4SF__Documentation_Request__c> drList = [SELECT Id, TF4SF__Type__c, TF4SF__Description__c FROM TF4SF__Documentation_Request__c WHERE TF4SF__Products__c = :prodList[0].Id];
			Map<String, TF4SF__Documentation_Request__c> drMap = new Map<String, TF4SF__Documentation_Request__c>();

			for (TF4SF__Documentation_Request__c dr : drList) {
				drMap.put(dr.TF4SF__Type__c,dr);
				drTypeSet.add(dr.TF4SF__Type__c);
			}

			System.debug('drMAP: '+drMap);
			if (response.getStatusCode() == 200) {
				List<Object> k1 = (List<Object>)JSON.deserializeUntyped(response.getbody()); 
				System.debug('k1 response: ' + k1);
				Map<String, Object> k = (Map<String, Object>)k1[0];

				if (k.get('success') == true) {
					Map<String, Object> l = (Map<String, Object>)k.get('value');
					System.debug('Integer rate: ' + String.valueof(l.get('approved_interest_rate')));
					Decimal rate = decimal.valueof(String.ValueOf(l.get('approved_interest_rate')));
					Integer loanAmt = Integer.ValueOf(l.get('approved_loan_amount'));
					Integer term = Integer.ValueOf(l.get('approved_loan_term_months'));
					Integer crLimit = Integer.ValueOf(l.get('approved_credit_limit'));
					prodList[0].TF4SF__Rate__c = rate;
					prodList[0].TF4SF__Term__c = term;
					if (appList[0].TF4SF__Sub_Product__c.contains('Credit Card')) {
						//prodList[0].TF4SF__Requested_Loan_Amount__c = 0;
					}

					//prodList[0].TF4SF__Funding_Amount_External__c = loanAmt;
					if (loanAmt != null) {
						prodList[0].TF4SF__Funding_Amount_External__c = loanAmt;
					} else if (crLimit != null) {
						prodList[0].TF4SF__Funding_Amount_External__c = crLimit; 
					}

					update prodList[0];
					appList[0].TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
					appList[0].Meridian_Link_Number__c = String.ValueOf(l.get('name')).split(' ')[1];
					update appList[0];
					List<Object> m = (List<Object>)l.get('tasks');
					List<TF4SF__Documentation_Request__c> dReqList = new List<TF4SF__Documentation_Request__c>();
					System.debug('mlist: ' + m);
					System.debug('success: ' + k.get('success'));   
					Set<String> descList = new Set<String>();

					if (m != null && m.size() > 0) {
						for (Object t : m) {
							Map<String, Object> task = (Map<String, Object>)t;

							if (String.ValueOf(task.get('type')) == 'STIPULATION') {
								descList.add(String.ValueOf(task.get('description')));
								TF4SF__Documentation_Request__c dReq = new TF4SF__Documentation_Request__c();
								System.debug('entered dreq: ');
								if (drMap.containsKey(String.valueOf(task.get('description')))) { 
									dReq.Id = drMap.get(String.valueOf(task.get('description'))).Id; 
									System.debug('entered updateId:');
								} else {
									dReq.TF4SF__Application__c = appId;
								}

								dReq.TF4SF__Products__c = prodList[0].Id;
								//dReq.TF4SF__Type__c = String.ValueOf(task.get('type'));
								dReq.TF4SF__Status__c = (String.ValueOf(task.get('complete')) == 'true') ? 'Completed' : 'Pending';
								dReq.TF4SF__Type__c = String.ValueOf(task.get('description'));
								dReq.TF4SF__Description__c = String.ValueOf(task.get('type'));
								//dReq.TF4SF__Description__c = String.ValueOf(task.get('description'));
								dReqList.add(dReq);
							}
						}
					}

					System.debug('dReqList: ' + dReqList);
					List<TF4SF__Documentation_Request__c> delDReq = new List<TF4SF__Documentation_Request__c>();
					for (String s : drMap.keySet()) { if (!descList.contains(s)) { delDReq.add(drMap.get(s)); } }
					System.debug('delDReq: ' + delDReq);
					if(delDReq.size() > 0) { delete delDReq; }
					if (dReqList.size() > 0) { upsert dReqList; }
				}
			}
		} catch (Exception e) {
			System.debug('Error in StipulationAPI Class: ' + e.getMessage());
		}
	}
}