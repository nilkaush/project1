global class MemberAccountListExt {
	global String accId {get; set;}
	global TF4SF__Existing_Account__c ExistingAccount {get; set;}
	global String accountId {get; set;}
	global String result{get; set;}
	global List<Object> Accounts {get; set;}
	global String cached_timestamp {get; set;}
	global String Account_id {get; set;}
	global String opened_date {get; set;}
	global String status {get; set;}
	global String Type {get; set;} // in json: type
	global String AccountName {get; set;}
	global String balance {get; set;}
	global String available_balance {get; set;}
	global String average_balance_month_to_date {get; set;}
	global String average_balance_year_to_date {get; set;}
	global String unpaid_accrued_interest {get; set;}
	global String statement_delivery_method {get; set;}
	global String monthly_payment {get; set;}
	global String interest_rate {get; set;}
	global String term {get; set;}
	global String next_payment_due_date {get; set;}
	global String credit_limit {get; set;}
	global String available_credit {get; set;}
	global Boolean courtesy_pay {get; set;}
	global String escrow_balance {get; set;}
	global String escrow_payment {get; set;}
	global String maturity_date {get; set;}

	global MemberAccountListExt(ApexPages.StandardController controller) {
		this.ExistingAccount = (TF4SF__Existing_Account__c)controller.getrecord();
		accId = ApexPages.currentpage().getparameters().get('id');
		accountId = [SELECT Id, TF4SF__Account_Number__c FROM TF4SF__Existing_Account__c WHERE Id = :accId].TF4SF__Account_Number__c;
		System.debug('%%%%% ' + accountId);
		result = SearchResults(accountId);
	}

	global String SearchResults (String accountId) {
		String responseJson = '';
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String url = '';
		String header = '';

		if (alpha.Enable_Production__c == true) {
			url = alpha.Production_URL__c;
			header = 'JWT ' + alpha.Production_Token__c;
		} else {
			url = alpha.Sandbox_URL__c;
			header = 'JWT ' + alpha.Sandbox_Token__c;
		}

		HttpRequest req = new HttpRequest();
		String body = '';
		req.setTimeout(120 * 1000);  //120 seconds
		//req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
		url += 'api/cache/accounts/?accountids=' + accountId;
		//blob headerValue = blob.valueOf('Test'+':'+'Testvalue');
		//String header = 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'; //'BASIC '+ EncodingUtil.base64Encode(headerValue);
		req.setEndpoint(url);
		req.setHeader('Authorization', header);
		req.setMethod('GET'); 
		//req.setBody(body);
		//System.debug('Request: ' + body);
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		//req.setHeader('authorization', header);

		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 
		if (response.getStatusCode() != 200) {
			String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
			//System.debug(errorMsg);
		}

		responseJson = response.getBody();
		System.debug('Response: '+responseJson);
		//InsertDebugLog(appId, json, 'TIPIntegraion Request');
		//InsertDebugLog(appId, responseJSON, 'TIPIntegraion Response');
		//String JsonResponsePre = PreQualifiedCrossSell(SSN); 
		//System.debug('the PreCrossSell response is '+JsonResponsePre);
		ResponseSearch(responseJson);

		return responseJson;
	}

	global String ResponseSearch(String responseJ) {
		List<Object> a = (List<Object>)JSON.deserializeUntyped(responseJ);
		System.debug('the response is ' + a[0]);
		Map<String, Object> m = (Map<String, Object>)a[0];
		System.debug('the response is ' + m.get('value'));
		List<Object> k = (List<Object>)m.get('value');

		for (Object u : k) {
			Map<String, Object> h = (Map<String, Object>)u;
			AccountName = String.valueOf(h.get('name'));
			opened_date = String.valueOf(h.get('opened_date'));
			status = String.valueOf(h.get('status'));
			Type = String.valueOf(h.get('type'));
			cached_timestamp = String.valueOf(h.get('cached_timestamp'));
			balance = String.valueOf(h.get('balance'));
			available_balance = String.valueOf(h.get('available_balance'));
			average_balance_month_to_date = String.valueOf(h.get('average_balance_month_to_date'));
			average_balance_year_to_date = String.valueOf(h.get('average_balance_year_to_date'));
			unpaid_accrued_interest = String.valueOf(h.get('unpaid_accrued_interest'));
			statement_delivery_method = String.valueOf(h.get('statement_delivery_method'));
			monthly_payment = String.valueOf(h.get('monthly_payment'));
			interest_rate = String.valueOf(h.get('interest_rate'));
			term = String.valueOf(h.get('term'));
			next_payment_due_date = String.valueOf(h.get('next_payment_due_date'));
			credit_limit = String.valueOf(h.get('credit_limit'));
			available_credit = String.valueOf(h.get('available_credit'));
			courtesy_pay = Boolean.valueOf(h.get('courtesy_pay'));
			escrow_balance = String.valueOf(h.get('escrow_balance'));
			escrow_payment = String.valueOf(h.get('escrow_payment'));
			maturity_date = String.valueOf(h.get('maturity_date'));

			System.debug('the id is ' + h.get('id'));
			System.debug('the name is ' + h.get('name'));
			System.debug('the opened_date is ' + h.get('opened_date'));
			System.debug('the status is ' + h.get('status'));
			System.debug('the type is ' + h.get('type'));
			System.debug('the cached_timestamp is ' + h.get('cached_timestamp'));
			System.debug('the balance is ' + h.get('balance'));
			System.debug('the available_balance is ' + h.get('available_balance'));
			System.debug('the average_balance_month_to_date is ' + h.get('average_balance_month_to_date'));
			System.debug('the average_balance_year_to_date is ' + h.get('average_balance_year_to_date'));
			System.debug('the unpaid_accrued_interest is ' + h.get('unpaid_accrued_interest'));
			System.debug('the statement_delivery_method is ' + h.get('statement_delivery_method'));
			System.debug('the monthly_payment is ' + h.get('monthly_payment'));
			System.debug('the interest_rate is ' + h.get('interest_rate'));
			System.debug('the term is ' + h.get('term'));
			System.debug('the next_payment_due_date is ' + h.get('next_payment_due_date'));
			System.debug('the credit_limit is ' + h.get('credit_limit'));
			System.debug('the available_credit is ' + h.get('available_credit'));
			System.debug('the courtesy_pay is ' + h.get('courtesy_pay'));
			System.debug('the escrow_balance is ' + h.get('escrow_balance'));
			System.debug('the escrow_payment is ' + h.get('escrow_payment'));
			System.debug('the maturity_date is ' + h.get('maturity_date'));
			System.debug('the purchase is ' + h.get('purchase'));

			if (h.get('purchase') != null) {
				Map<String, Object> d1 = (Map<String, Object>)h.get('purchase');
				System.debug('the type is ' + d1.get('type'));
				System.debug('the vin is ' + d1.get('vin'));
				System.debug('the make is ' + d1.get('make'));
				System.debug('the model is ' + d1.get('model'));
				System.debug('the year is ' + d1.get('year'));
				System.debug('the address is ' + d1.get('address'));

				if (d1.get('address') != null) {
					Map<String, Object> d3 = (Map<String, Object>)d1.get('address');
					List<String> d2 = String.valueOf(d3.get('address_lines')).split(',');
					for (String d5 : d2){ System.debug('the Street address ' + d5.replace('(', '').replace(')', '')); }
					System.debug('the township is ' + d3.get('township'));
					System.debug('the state_code is ' + d3.get('state_code'));
					System.debug('the country_code is ' + d3.get('country_code'));
					System.debug('the zip_code is ' + d3.get('zip_code'));
				}
			}

			List<Object> e = (List<Object>)h.get('customers');
			System.debug('the Customers is ' + e);
			for (Object g : e) {
				Map<String, Object> j = (Map<String, Object>)g;
				System.debug('the customer id is ' + j.get('id'));
				System.debug('the customer relationship is ' + j.get('relationship'));
			}
			
			List<String> e1 = String.valueOf((List<Object>)h.get('flags')).split(',');
			System.debug('the flags is ' + e1);
			for (String g1 : e1) {
				//Map<String, Object> j1 = (Map<String, Object>)g1;
				//System.debug('the customer id is '+j.get('id'));
				System.debug('the flag is ' + g1.replace('(', '').replace(')', ''));
			}
		}

		return responseJ;
	}
}