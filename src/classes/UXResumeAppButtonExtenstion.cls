public with sharing class UXResumeAppButtonExtenstion {
	public TF4SF__Application__c app{get; set;}
	public String appId{get; set;}

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	public UXResumeAppButtonExtenstion(ApexPages.StandardController stdController) {
		//this.App = (TF4SF__Application__c)stdController.getRecord();
		appId = ApexPages.currentPage().getParameters().get('id');
		app = [SELECT Id, TF4SF__Application_Status__c, Sub_Status__c, TF4SF__Sub_Product__c, ProductId__c, TF4SF__Online_Banking_Enrollment__c, TF4SF__Check_Order__c, TF4SF__ATM_Card__c, TF4SF__Custom_DateTime4__c, TF4SF__Custom_DateTime2__c, TF4SF__Custom_DateTime3__c FROM TF4SF__Application__c WHERE Id = :appId];
	}

	public pageReference save() {
		String updateRes;
		if (app != null && String.isNotBlank(app.ProductId__c)) {
			String status;
			if (app.TF4SF__Sub_Product__c.contains('Checking') || app.TF4SF__Sub_Product__c.contains('Savings') || app.TF4SF__Sub_Product__c.contains('Certificates')) {
				status = 'APPROVED';
			} else {
				status = 'APP';
			}

			app.TF4SF__Primary_Product_Status__c = 'Approved';
			app.Sub_Status__c = 'Approve';
			//updateRes = SendStatusFromCreditReport.CallUpdateApiToSendStatus(app.Id, app.ProductId__c, app.TF4SF__Sub_Product__c, status, 'ApplicationDetailPage');
			System.debug('updateres: '+updateRes);
			update app;
		}

		pagereference pRef = new pagereference('/'+app.id);
		pref.setRedirect(false);
		return pRef;
		//decisionsCall(app.Id, app.ProductId__c);
	}

	public String decisionsCall(String appId, String productId) {
		String  body = '[';
				body += '"' + productId + '"';
				body += ']';
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
		System.debug('responseJSON: ' + responseJSON + '----' + res.getstatus());

		if (res.getStatusCode() == 200) {
			List<Object> k1 = (List<Object>)JSON.deserializeUntyped(responseJSON);

			if (k1 != null && k1.size() > 0) {
				Map<String, Object> k = (Map<String, Object>)k1[0];

				if (k != null) {
					System.debug(k.get('value'));
					Map<String, Object> l = (Map<String, Object>)k.get('value');
					System.debug('kkkkkkkkkk:' + k);
					System.debug('llllllllll:' + l);

					if (l != null) {
						System.debug('l values: ' + l.get('status'));
						TF4SF__Application__c app = new TF4SF__Application__c();
						app.Id = appId;
						app.TF4SF__Primary_Product_Status__c = prodStatMap.get(String.ValueOf(l.get('status'))).Product_Status__c;
						//app.Custom_Text44__c = String.ValueOf(l.get('account_id'));
						System.debug('app UXResumeAppButtonExtenstion::::::: ' + app);
						update app;
					}
				}
			}
		} 

		return null;
	}
	/*public Boolean getOLB() {
		Boolean olb = false;
		if (app.TF4SF__Application_Status__c == 'Submitted' && app.TF4SF__Online_Banking_Enrollment__c == true) {
			olb = true;
			if (app.TF4SF__Custom_DateTime2__c != NULL) { olb = false; }
		} 

		return olb;
	}

	public Boolean getCheckOrder() {
		Boolean checkorder = false;
		if (app.TF4SF__Application_Status__c == 'Submitted' && app.TF4SF__Check_Order__c == true) {
			if (app.TF4SF__Online_Banking_Enrollment__c == true && app.TF4SF__Custom_DateTime2__c != NULL) {
				checkorder = true;
			} else if (app.TF4SF__Online_Banking_Enrollment__c == false && app.TF4SF__Custom_DateTime2__c == NULL) {
				checkorder = true;
			}

			if (app.TF4SF__Custom_DateTime3__c != NULL) { checkorder = false; }
		}

		return checkorder;
	}

	public Boolean getATM() {
		Boolean atm = false;

		if (app.TF4SF__Application_Status__c == 'Submitted' && app.TF4SF__ATM_Card__c == true) {
			if ((app.TF4SF__Online_Banking_Enrollment__c == false && app.TF4SF__Custom_DateTime2__c == NULL) && (app.TF4SF__Check_Order__c == false && app.TF4SF__Custom_DateTime3__c == NULL)) {
				atm = true;
			} else if ((app.TF4SF__Online_Banking_Enrollment__c == true && app.TF4SF__Custom_DateTime2__c != NULL) && (app.TF4SF__Check_Order__c == false && app.TF4SF__Custom_DateTime3__c == NULL)) {
				atm = true;
			} else if ((app.TF4SF__Online_Banking_Enrollment__c == true && app.TF4SF__Custom_DateTime2__c != NULL) && (app.TF4SF__Check_Order__c == true && app.TF4SF__Custom_DateTime3__c != NULL)) {
				atm = true;
			} else if ((app.TF4SF__Online_Banking_Enrollment__c == false && app.TF4SF__Custom_DateTime2__c == NULL) && (app.TF4SF__Check_Order__c == true && app.TF4SF__Custom_DateTime3__c != NULL)) {
				atm = true;
			} 

			if (app.TF4SF__Custom_DateTime4__c != NULL) { atm = false; }
		}

		return atm;
	}

	public PageReference OLBComplete() {
		PageReference p = null;
		app.Sub_Status__c = 'OLB Completed';
		app.TF4SF__Custom_DateTime2__c = System.now();

		if (app.TF4SF__Online_Banking_Enrollment__c == true && app.TF4SF__Check_Order__c == false && app.TF4SF__ATM_Card__c == false) {
			app.OwnerId = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'OLB Enrollment Complete Queue'].Queue.Id;
		} else if (app.TF4SF__Online_Banking_Enrollment__c == true && app.TF4SF__Check_Order__c == true && (app.TF4SF__ATM_Card__c == false || app.TF4SF__ATM_Card__c == true)) {
			app.OwnerId = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'Check Order Enrollment'].Queue.Id;
		} else if (app.TF4SF__Online_Banking_Enrollment__c == true && app.TF4SF__Check_Order__c == false && app.TF4SF__ATM_Card__c == true) {
			app.OwnerId = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'Debit Card Enrollment'].Queue.Id;
		}

		p = new PageReference('/' + appId);//p = Page.UX_ResumeApp_Button;
		p.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
		p.setRedirect(false);
		update app;

		return p;
	}

	public PageReference CheckOrderComplete() {
		PageReference p = null;
		app.Sub_Status__c = 'Check Order Completed';
		app.TF4SF__Custom_DateTime3__c = System.now();

		if (app.TF4SF__Check_Order__c == true && app.TF4SF__ATM_Card__c == false) {
			app.OwnerId = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'Check Order Enrollment Complete'].Queue.Id;
		} else if (app.TF4SF__Check_Order__c == true && app.TF4SF__ATM_Card__c == true) {
			app.OwnerId = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'Debit Card Enrollment'].Queue.Id;
		}
		
		p = new PageReference('/' + appId);//p = Page.UX_ResumeApp_Button;
		p.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
		p.setRedirect(false);
		update app;

		return p;
	}

	public PageReference ATMComplete() {
		PageReference p = null;
		app.Sub_Status__c = 'ATM Completed';
		app.TF4SF__Custom_DateTime4__c = System.now();
		app.OwnerId = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'Debit Card Enrollment Complete'].Queue.Id;
		p = new PageReference('/' + appId);//p = Page.UX_ResumeApp_Button;
		p.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
		p.setRedirect(false);
		update app;

		return p;
	}*/
}