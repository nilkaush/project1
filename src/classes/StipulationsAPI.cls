public class StipulationsAPI {
	public static List<TF4SF__Application__c> callStipulations(List<TF4SF__Application__c> app) {
		try {
			Map<String, TF4SF__Application__c> appIdMap = new Map<String, TF4SF__Application__c>();
			List<String> pIds = new List<String>();
			Map<String, TF4SF__Products__c> pMap = new Map<String, TF4SF__Products__c>();
			Map<String, TF4SF__Application__c> pAppMap = new Map<String, TF4SF__Application__c>();
			for (TF4SF__Application__c a : app) { appIdMap.put(a.Id, a); }
			System.debug('appIdMap: ' + appIdMap);
			List<String> pRecId = new List<String>();
			List<TF4SF__Products__c> prodList = [SELECT Id, Name, ProductId__c, TF4SF__Application__c, TF4SF__Requested_Loan_Amount__c, TF4SF__Rate__c, TF4SF__Term__c, TF4SF__Funding_Amount_External__c, TF4SF__Product_Name__c FROM TF4SF__Products__c WHERE TF4SF__Application__c = :appIdMap.keySet()];

			for (TF4SF__Products__c p : prodList) {
				pRecId.add(p.Id);
				pIds.add(p.ProductId__c);
				pMap.put(p.ProductId__c, p);
				pAppMap.put(p.ProductId__c, appIdMap.get(p.TF4SF__Application__c));
			}

			if (pIds.size() == 0 && app.size() == 1) {
				if (String.isNotBlank(app[0].TF4SF__Sub_Product__c)) { pIds.add(app[0].ProductId__c); }
				if (String.isNotBlank(app[0].TF4SF__Primary_Offer__c)) { pIds.add(app[0].ProductIdCS1__c); }
				if (String.isNotBlank(app[0].TF4SF__Second_Offer__c)) { pIds.add(app[0].ProductIdCS2__c); }
				if (String.isNotBlank(app[0].TF4SF__Third_Offer__c)) { pIds.add(app[0].ProductIdCS3__c); }
			}

			String prodIds = '';
			for (String pId : pIds) {
				prodIds = prodIds + '%3B' + pId;
				prodIds = prodIds.removeStart('%3B');
			}

			System.debug('pAppMap in StipulationsAPI: ' + pAppMap);
			System.debug('pMap in StipulationsAPI: ' + pMap);
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
				req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/?prodappids=' + prodIds);
				authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
			} else {
				req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/?prodappids=' + prodIds);
				authorizationHeader = 'JWT ' + aPack.Production_Token__c;
			}

			req.setHeader('Authorization', authorizationHeader);
			//req.setEndpoint('https://outrun.kpcu.com/api/product-applications/?prodappids=' + ProdId);
			Http http = new Http();
			HttpResponse response = http.send(req);
			System.debug('request: ' + req.getbody());
			System.debug('response: ' + response.getbody());
			Set<String> drTypeSet = new Set<String>();
			//List<TF4SF__Products__c> prodList = [SELECT Id, Name, TF4SF__Application__c, TF4SF__Requested_Loan_Amount__c, TF4SF__Rate__c, TF4SF__Term__c FROM TF4SF__Products__c WHERE TF4SF__Application__c = :app.Id];
			//List<TF4SF__Application__c> appList = [SELECT Id, TF4SF__Primary_Product_Status__c,TF4SF__Sub_Product__c FROM TF4SF__Application__c WHERE Id IN :appIdMap.keyset()];
			//Map<String, TF4SF__Documentation_Request__c> drMap = new Map<String, TF4SF__Documentation_Request__c>();
			Map<String, List<TF4SF__Documentation_Request__c>> pdrMap = new Map<String, List<TF4SF__Documentation_Request__c>>();

			if (prodList.size() > 0) {
				List<TF4SF__Documentation_Request__c> drList = [SELECT Id, TF4SF__Type__c, TF4SF__Description__c, TF4SF__Products__r.ProductId__c, TF4SF__Products__r.TF4SF__Application__c FROM TF4SF__Documentation_Request__c WHERE TF4SF__Products__c IN :pRecId];

				for (TF4SF__Documentation_Request__c dr : drList) {
					//drMap.put(dr.TF4SF__Type__c, dr);
					drTypeSet.add(dr.TF4SF__Type__c);
					if (pdrMap.containsKey(dr.TF4SF__Products__r.ProductId__c)) {
						pdrMap.get(dr.TF4SF__Products__r.ProductId__c).add(dr);
					} else {
						pdrMap.put(dr.TF4SF__Products__r.ProductId__c, new List<TF4SF__Documentation_Request__c>{dr});
					}
				}
			}

			if (response.getStatusCode() == 200) {
				List<Object> k1 = (List<Object>)JSON.deserializeUntyped(response.getbody()); 
				System.debug('k1 response: ' + k1);

				for (Object j : k1) {
					Map<String, Object> k = (Map<String, Object>)j;
					if (k.get('success') == true) {
						List<TF4SF__Products__c> prdList = new List<TF4SF__Products__c>();
						Map<String, TF4SF__Application__c> updateAppMap = new Map<String, TF4SF__Application__c>();
						Map<String, Object> l = (Map<String, Object>)k.get('value');
						System.debug('lllllllll in StipulationsAPI: ' + l);
						System.debug('Integer rate: ' + String.valueof(l.get('approved_interest_rate')));
						Decimal rate;
						Integer loanAmt;
						Integer term;
						Integer crLimit;
						String resPrdId;
						if (l.get('approved_interest_rate') != null) { rate = Decimal.valueof(String.ValueOf(l.get('approved_interest_rate'))); }
						if (l.get('approved_loan_amount') != null) { loanAmt = Integer.ValueOf(l.get('approved_loan_amount')); }
						if (l.get('approved_loan_term_months') != null) { term = Integer.ValueOf(l.get('approved_loan_term_months')); }
						if (l.get('approved_credit_limit') != null) { crLimit = Integer.ValueOf(l.get('approved_credit_limit')); }
						if (l.get('id') != null) { resPrdId = String.valueof(l.get('id')); }
						System.debug('resPrdId: '+resPrdId);

						System.debug('pMap in StipulationsAPI: ' + pMap);
						System.debug('l.get(id) in StipulationsAPI: ' + l.get('id'));
						if (pMap.containskey(String.valueOf(l.get('id')))) {
							TF4SF__Products__c prd = pMap.get(String.valueof(l.get('id')));
							prd.TF4SF__Rate__c = rate;
							prd.TF4SF__Term__c = term;
							//if (appList[0].TF4SF__Sub_Product__c.contains('Credit Card')) { prodList[0].TF4SF__Requested_Loan_Amount__c = 0; }

							//prodList[0].TF4SF__Funding_Amount_External__c = loanAmt;
							if (loanAmt != null) {
								prd.TF4SF__Funding_Amount_External__c = loanAmt;
							} else if (crLimit != null) {
								prd.TF4SF__Funding_Amount_External__c = crLimit; 
							}

							prdList.add(prd);
							//update prodList[0];
							List<TF4SF__Application__c> apList = new List<TF4SF__Application__c>();
							TF4SF__Application__c ap;

							System.debug('updateAppMap in StipulationsAPI: ' + updateAppMap);
							System.debug('updateAppMap in StipulationsAPI: ' + updateAppMap);
							if (!updateAppMap.containskey(pAppMap.get(resPrdId).Id)) {
								updateAppMap.put(pAppMap.get(resPrdId).Id, pAppMap.get(resPrdId));
								ap = pAppMap.get(resPrdId);
								System.debug('entered ap: ' + ap);
							} else {
								ap = updateAppMap.get(pAppMap.get(resPrdId).Id);
							}

							String prdName = pMap.get(resPrdId).TF4SF__Product_Name__c;
							System.debug('prdName: ' + pAppMap.get(resPrdId).TF4SF__Sub_Product__c + '----' + prdName);

							System.debug('prdName Before setting primary product status: ' + prdName);
							System.debug('resPrdId Before setting primary product status: ' + resPrdId);
							System.debug('pAppMap in StipulationsAPI: ' + pAppMap);
							System.debug('prodStatMap in StipulationsAPI: ' + prodStatMap);
							if (String.isNotBlank(pAppMap.get(resPrdId).TF4SF__Sub_Product__c) && prdName == pAppMap.get(resPrdId).TF4SF__Sub_Product__c) {
								System.debug('entered prdName: ' + pAppMap.get(resPrdId).TF4SF__Sub_Product__c);
								//pAppMap.get(String.valueOf(l.get('id'))).TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
								ap.TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
							}

							if (String.isNotBlank(pAppMap.get(resPrdId).TF4SF__Primary_Offer__c) && prdName == pAppMap.get(resPrdId).TF4SF__Primary_Offer__c) {
								//pAppMap.get(String.valueOf(l.get('id'))).TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
								ap.TF4SF__Primary_Offer_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
							}

							if (String.isNotBlank(pAppMap.get(resPrdId).TF4SF__Second_Offer__c) && prdName == pAppMap.get(resPrdId).TF4SF__Second_Offer__c) {
								//pAppMap.get(String.valueOf(l.get('id'))).TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
								ap.TF4SF__Second_Offer_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
							}

							if (String.isNotBlank(pAppMap.get(resPrdId).TF4SF__Third_Offer__c) && prdName == pAppMap.get(resPrdId).TF4SF__Third_Offer__c) {
								//pAppMap.get(String.valueOf(l.get('id'))).TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
								ap.TF4SF__Third_Offer_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
							}

							//pAppMap.get(String.valueOf(l.get('id'))).Meridian_Link_Number__c = String.ValueOf(l.get('name')).split(' ')[1];
							ap.Meridian_Link_Number__c = String.ValueOf(l.get('name')).split(' ')[1];
							//update appList[0];
							System.debug('ap.primary status: '+ap+'------'+ap.TF4SF__Primary_Product_Status__c);
							updateAppMap.remove(ap.Id);
							updateAppMap.put(ap.Id, ap);
							List<Object> m = (List<Object>)l.get('tasks');
							List<TF4SF__Documentation_Request__c> dReqList = new List<TF4SF__Documentation_Request__c>();
							System.debug('mlist: ' + m);
							System.debug('success: ' + k.get('success'));
							Set<String> descList = new Set<String>();
							System.debug('appupdates: ' + updateAppMap.values());
							update updateAppMap.values();
							//update appIdMap.values();
							update prdList;

							if (prodList.size() > 0) {
								Map<String, TF4SF__Documentation_Request__c> drMap = new Map<String, TF4SF__Documentation_Request__c>();
								if (pdrMap.size() > 0 && pdrMap.containsKey(resPrdId)) {
									for (TF4SF__Documentation_Request__c d : pdrMap.get(resPrdId)) { drMap.put(d.TF4SF__Type__c, d); }
								}

								if (m != null && m.size() > 0) {
									for (Object t : m) {
										Map<String, Object> task = (Map<String, Object>)t;

										if (task.size() > 0 && String.ValueOf(task.get('type')) == 'STIPULATION') {
											descList.add(String.ValueOf(task.get('description')));
											TF4SF__Documentation_Request__c dReq = new TF4SF__Documentation_Request__c();
											System.debug('entered dreq: ');

											if (drMap.containsKey(String.valueOf(task.get('description')))) { 
												dReq.Id = drMap.get(String.valueOf(task.get('description'))).Id; 
												System.debug('entered updateId:');
											} else {
												dReq.TF4SF__Application__c = prd.TF4SF__Application__c;
											}

											dReq.TF4SF__Products__c = prd.Id;
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
								if (delDReq.size() > 0) { delete delDReq; }
								if (dReqList.size() > 0) { upsert dReqList; }
							}
						} else { System.debug('didnt find a match in StipulationsAPI'); }
					}
				}
			}

			return appIdMap.values();
		} catch (Exception e) {
			System.debug('Error in StipulationAPI Class: ' + e.getMessage() + '---LineNumber---' + e.getLinenumber());
			return null;
		}
	}
}