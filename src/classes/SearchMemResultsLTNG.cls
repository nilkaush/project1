public class SearchMemResultsLTNG {
	@AuraEnabled
	public static MemInfo SearchRes(String custId) {
		TF4SF__Customer__c cust = [SELECT Id, TF4SF__Person_Identifier__c FROM TF4SF__Customer__c WHERE id = :custId];
		MemInfo mInfo = SearchResults1(cust.TF4SF__Person_Identifier__c);
		System.debug('mInfo: '+mInfo);
		//String mmmm = SearchResults1(cust.TF4SF__Person_Identifier__c);
		return mInfo;
	}

	public static MemInfo SearchResults1 (String customerNumber) {
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String rtnStr = null;
		String url = '';
		String header = '';
		String responseJson = '';

		if (alpha.Enable_Production__c == true) {
			url = alpha.Production_URL__c;
			header = 'JWT ' + alpha.Production_Token__c;
		} else {
			url = alpha.Sandbox_URL__c;
			header = 'JWT ' + alpha.Sandbox_Token__c;
		}

		//ssn = '354822777';
		HttpRequest req = new HttpRequest();
		String body = '';
		req.setTimeout(120 * 1000);  //120 seconds
		//req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
		url += 'api/cache/customers/?customerid=' + customerNumber + '&fullaccounts=false';
		req.setEndpoint(url);
		req.setHeader('Authorization', header);
		req.setMethod('GET'); 
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 
		System.debug('request searchMember: '+req);
		System.debug('response SearchMember: '+response.getbody());
		if (response.getStatusCode() != 200) {
			String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
		}

		responseJson = response.getBody();
		System.debug('Response: ' + responseJson);
		//InsertDebugLog(appId, json, 'TIPIntegraion Request');
		//InsertDebugLog(appId, responseJSON, 'TIPIntegraion Response');
		MemInfo m;
		if (responseJson != null ) {
			m = ResponseSearch(responseJson);
			rtnStr = responseJson;
		}

		//return rtnStr;
		return m;
	}

	public static MemInfo ResponseSearch (String response) {
		MemInfo mi = new MemInfo();
		String ResponseJ = response;
		//*****************************************Dummy response********************************
		//ResponseJ = '[{"success":true,"value":[{"cached_timestamp":"2017-11-24T00:00:00","id":"386975","type":"PERSON","registration_date":"2013-12-10","first_name":"TEST","middle_name":"ACCOUNT","last_name":"APPLE","suffix":null,"birth_date":"1950-01-01","federal_id":"888111111","member_id":"156520","married":false,"spouse_id":null,"immigration_status":"US Citizen","country_of_citizenship":"USA","fico_score":null,"fico_score_date":null,"financial_institution_relationships":["CUST"],"last_contact_date":"2015-08-12","last_detail_update_date":null,"passphrase":null,"primary_email_address":"safaribrowsertest@me.com","email_addresses":["safaribrowsertest@me.com"],"primary_phone_number":null,"phone_numbers":["4088051677"],"primary_occupancy_address":{"address_lines":["2805 BOWERS AVE"],"township":"SANTA CLARA","state_code":"CA","country_code":"USA","zip_code":"95051"},"occupancy_addresses":[{"address_lines":["2805 BOWERS AVE"],"township":"SANTA CLARA","state_code":"CA","country_code":"USA","zip_code":"95051"}],"statement_delivery_method":"EMAIL","identification_documents":[{"type":"Unexpired Drivers License","id":"A1234567","state_code":"CA","country_code":"USA","expiration_date":"2016-01-01","issue_date":"2010-01-01"}],"accounts":[{"relationship":"Tax Reported Owner             ","id":"44151356"},{"relationship":"Tax Reported Owner             ","id":"44151390"}],"flags":["PERN","NOTE","BAI2","VADD","EXPL","EMP"]}],"error_type":null,"error_message":null}]';
		//*****************************************Dummy response********************************
		List<Object> a = (List<Object>)JSON.deserializeUntyped(ResponseJ);
		System.debug('the response is ' + a[0]);
		Map<String, Object> m = (Map<String, Object>)a[0];
		System.debug('the response is ' + m.get('value'));
		List<Object> k = (List<Object>)m.get('value');

		for (Object u : k) {
			Map<String, Object> l = (Map<String, Object>)u;
			mi.DateOfBirth = String.valueOf(l.get('birth_date'));
			mi.SSNDisplay = String.valueOf(l.get('federal_id'));
			mi.CustomerId = String.valueOf(l.get('id'));
			mi.FirstName = String.valueOf(l.get('first_name'));
			mi.MiddleName = String.valueOf(l.get('middle_name'));
			mi.LastName = String.valueOf(l.get('last_name'));
			mi.PrimaryEmail = String.valueOf(l.get('primary_email_address'));
			//PrimaryPhone = String.valueOf(l.get('primary_phone_number'));
			List<Object> phnNum = (List<Object>)l.get('phone_numbers');
			mi.phnTypeMap = new Map<String, String>();

			for (Object p : phnNum) {
				Map<String, Object> phnMap = (Map<String, Object>)p;
				if (phnMap.get('type') != null && phnMap.get('value') != null) {
					mi.phnTypeMap.put(String.ValueOf(phnMap.get('type')) +' PHONE', String.ValueOf(phnMap.get('value')));
				}
			}

			if (mi.phnTypeMap.size() > 0) { 
				if (mi.phnTypeMap.containsKey('HOME')) {
					//PrimaryPhone = phnTypeMap.get('HOME PHONE');
				} else {
					List<String> phnList = new List<String>(mi.phnTypeMap.keyset());
					//PrimaryPhone = phnTypeMap.get(phnList[0]);
				}
			}

			//System.debug('phnnummmmmmm: ' + PrimaryPhone + '------' + phnNum);
			mi.RegistrationDate = String.valueOf(l.get('registration_date'));
			if (l.get('married') != null) { mi.IsMarried = Boolean.valueOf(l.get('married')); }
			if (l.get('spouse_id') != null) { mi.SpouseId = String.valueOf(l.get('spouse_id')); }
			mi.ImmigrationStatus = String.valueOf(l.get('immigration_status'));
			mi.CountryofCitizenship = String.valueOf(l.get('country_of_citizenship'));
			if (mi.CountryofCitizenship != '' && mi.CountryofCitizenship == 'USA') { mi.CountryofCitizenship = 'US Citizen'; }
			if (l.get('fico_score') != null ) { mi.FicoScore = String.valueOf(l.get('fico_score')); }
			if (l.get('fico_score_date') != null ) { mi.FicoScoreDate = String.valueOf(l.get('fico_score_date')); }
			mi.LastContactDate =  String.valueOf(l.get('last_contact_date'));
			if (l.get('last_detail_update_date') != null ) { mi.LastUpdatedDate =  String.valueOf(l.get('last_detail_update_date')); }
			if (l.get('passphrase') != null ) { mi.Passphrase =  String.valueOf(l.get('passphrase')); }
			mi.StateDeliveryMethod =  String.valueOf(l.get('statement_delivery_method'));
			System.debug('the type is ' + l.get('type'));
			List<Object> uu = (List<Object>)l.get('identification_documents');

			for (Object u2 : uu) {
				Map<String, Object> u1 = (Map<String, Object>)u2;
				mi.IdentificationType = String.valueOf(u1.get('type'));
				if (mi.IdentificationType.contains('Driver\'s License')) { mi.IdentificationType = 'Driver License'; }
				mi.IdentificationNumber = String.valueOf(u1.get('id'));
				mi.IdState = String.valueOf(u1.get('state_code'));
				mi.Id_ExpirationDate = String.valueOf(u1.get('expiration_date'));
				mi.Id_IssueDate = String.valueOf(u1.get('issue_date'));
			}

			/*nitin List<Object> flagList = (List<Object>)l.get('flags');
			Set<Object> flagSet = new Set<Object>(flagList);
			System.debug('flagList =: ' + flagList);
			flags = new List<String>();
			isEmployee = '';

			for (Integer i = 0; i < flagList.size(); i++) {
			String s = String.ValueOf(flagList[i]);

			if (flagset.contains('EXPL')) {
			  isEmployee = 'Member is expelled';
			} else if (flagSet.contains('EMP')) {
			  isEmployee = 'Member is an employee';
			}

			if (i < flagList.size() - 1) { s = s + ','; }
			flags.add(s);
			}

			System.debug('flags::::::::: ' + flags); nitin*/
			Map<String, Object> o1 = (Map<String, Object>)l.get('primary_occupancy_address');
			System.debug('primary_occupancy_address ' + o1);
			List<String> tt = String.valueOf(o1.get('address_lines')).split(',');

			for (String t1 : tt) {
				System.debug('address_lines ' + t1.replace('(', '').replace(')', ''));
				mi.StreetAddress = t1.replace('(', '').replace(')', '') + '\n';
			}

			System.debug('country_code ' + o1.get('country_code'));
			System.debug('state_code ' + o1.get('state_code'));
			System.debug('township ' + o1.get('township'));
			System.debug('zip_code ' + o1.get('zip_code'));
			mi.City = String.valueOf(o1.get('township') + '\n');
			mi.State = String.valueOf(o1.get('state_code') + '\n');
			mi.ZipCode = String.valueOf(o1.get('zip_code') + '\n');
			mi.CountryCode = String.valueOf(o1.get('country_code'));
			List<Object> oo = (List<Object>)l.get('occupancy_addresses');

			for (Object pp : oo) {
				Map<String, Object> o2 = (Map<String, Object>)pp;
				List<String> ttt = String.valueOf(o2.get('address_lines')).split(',');
				for (String t2 : ttt) { System.debug('address_lines ' + t2.replace('(', '').replace(')', '')); }
				System.debug('occupancy_addresses' + o2);
				System.debug('country_code ' + o2.get('country_code'));
				System.debug('state_code ' + o2.get('state_code'));
				System.debug('township ' + o2.get('township'));
				System.debug('zip_code ' + o2.get('zip_code'));
			}

			List<String> k1 = String.valueOf(l.get('email_addresses')).split(',');
			List<String> k2 = String.valueOf(l.get('phone_numbers')).split(',');
			for (String l1 : k1) { System.debug('email addresses ' + l1.replace('(', '').replace(')', '')); }
			for (String l2 : k2) { System.debug('phone_numbers ' + l2.replace('(', '').replace(')', '')); }
			//Accounts = (List<Object>)l.get('accounts');
			//System.debug('the accounts list is ' + Accounts);
		}

		return mi;
	}

	public class MemInfo {
		@AuraEnabled public String dateOfBirth {get;set;}
		@AuraEnabled public String SSNDisplay {get;set;}
		@AuraEnabled public String CustomerId {get;set;}
		@AuraEnabled public String firstName {get;set;}
		@AuraEnabled public String middleName {get;set;}
		@AuraEnabled public String lastName {get;set;}
		@AuraEnabled public String primaryEmail {get;set;}
		@AuraEnabled public Map<String, String> phnTypeMap {get;set;}
		@AuraEnabled public String registrationDate {get;set;}
		@AuraEnabled public Boolean isMarried {get;set;}
		@AuraEnabled public String spouseId {get;set;}
		@AuraEnabled public String immigrationStatus {get;set;}
		@AuraEnabled public String countryOfCitizenship {get;set;}
		@AuraEnabled public String ficoScore {get;set;}
		@AuraEnabled public String ficoScoreDate {get;set;}
		@AuraEnabled public String lastContactDate {get;set;}
		@AuraEnabled public String lastUpdatedDate {get;set;}
		@AuraEnabled public String passPhrase {get;set;}
		@AuraEnabled public String StateDeliveryMethod {get;set;}
		@AuraEnabled public String IdentificationType {get;set;}
		@AuraEnabled public String IdentificationNumber {get;set;}
		@AuraEnabled public String IdState {get;set;}
		@AuraEnabled public String Id_ExpirationDate {get;set;}
		@AuraEnabled public String Id_IssueDate {get;set;}
		@AuraEnabled public String StreetAddress {get;set;}
		@AuraEnabled public String City {get;set;}
		@AuraEnabled public String State {get;set;}
		@AuraEnabled public String ZipCode {get;set;}
		@AuraEnabled public String CountryCode {get;set;}
	}
}