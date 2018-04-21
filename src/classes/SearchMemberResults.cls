global class SearchMemberResults {

	global User loggedInUser{get; set;}
	global String prodType {get; set;}
	global String userId;
	global String version{get; set;}
	global TF4SF__Application_Configuration__c appConfig = TF4SF__Application_Configuration__c.getOrgDefaults();
	global String result{get; set;}
	global String customerNumber{get; set;}
	global String custId{get; set;}
	global TF4SF__Customer__c customer{get; set;}
	global String CustomerId {get; set;}
	global String Customer_Id {get; set;}
	global String FirstName {get; set;}
	global String MiddleName {get; set;}
	global String LastName {get; set;}
	global String StreetAddress {get; set;}
	global String City {get; set;}
	global String State {get; set;}
	global String ZipCode {get; set;}
	global String CountryCode {get; set;}
	global String SSNDisplay {get; set;}
	global String DateOfBirth {get; set;}
	global String PrimaryEmail {get; set;}
	global String PrimaryPhone {get; set;}
	global String RegistrationDate {get; set;}
	global Boolean IsMarried {get; set;}
	global String SpouseId {get; set;}
	global String ImmigrationStatus {get; set;}
	global String CountryofCitizenship {get; set;}
	global String FicoScore {get; set;}
	global String FicoScoreDate {get; set;}
	global String LastContactDate {get; set;}
	global String LastUpdatedDate {get; set;}
	global String Passphrase {get; set;}
	global String StateDeliveryMethod {get; set;}
	global String IdentificationType {get; set;}
	global String IdentificationNumber {get; set;}
	global String IdState {get; set;}
	global String Id_ExpirationDate {get; set;}
	global String Id_IssueDate {get; set;}
	global List<Object> Accounts {get; set;}
	global String cached_timestamp {get; set;} 
	global String Account_id {get; set;} 
	global List<String> flags {get; set;}
	global String isEmployee {get; set;}
	global String idType {get; set;}
	
	global SearchMemberResults(ApexPages.StandardController controller) {
		this.customer = (TF4SF__Customer__c)controller.getrecord();
		custId = ApexPages.currentpage().getparameters().get('id');
		userId = UserInfo.getUserId();
		loggedInUser = [SELECT Id, TF4SF__Channel__c, Name, TF4SF__Location__c, Profile.Name, Email FROM User WHERE Id = :userId];
		version = ApexPages.currentPage().getParameters().get('v');
		customerNumber = [SELECT Id, TF4SF__Person_Identifier__c FROM TF4SF__Customer__c WHERE Id = :custId].TF4SF__Person_Identifier__c;
		System.debug('%%%%% ' + customerNumber);
		result = SearchResults(customerNumber);
	}

	global class MemberData {
		global String firstName;
		global String middleName;
		global String lastName;
		global String emailAddress;
		global String cellPhoneNumber;
		global String customersID;
		global String createdByUserId;
		global String createdByBranch;
		global String createdByChannel;
		global String createdEmailAddress;
		global String currentPerson;
		global String currentBranch;
		global String currentChannel;
		global String currentEmailAddress;
		global String customersStreetAddress1;
		global String customersStreetAddress2;
		global String customersCity;
		global String customersState;
		global String customersZipCode;
		global String ssn;
		global String memberNo;
		global String personId;
		global String idType;
		global String identificationNumber;
		global String idState;
		global String id_ExpirationDate;
		global String id_IssueDate ;
		global String countryofCitizenship ;
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////// CRYPTO METHODS TO ENCRYPT THE USERTOKEN FOR OFFLINE APPLICATION//////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	private static final String RANDOM_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

	private static blob key {
		private get{
			return EncodingUtil.base64Decode(TF4SF__Application_Configuration__c.getOrgDefaults().TF4SF__key__c);
		}
		private set;
	}

	private static Decimal timeoutSeconds {
		private get{
			TF4SF__Application_Configuration__c ac = TF4SF__Application_Configuration__c.getOrgDefaults();
			return ac.TF4SF__Timeout_Seconds__c;
		}
		private set;
	}

	private static Decimal popupSeconds {
		private get{
			TF4SF__Application_Configuration__c ac = TF4SF__Application_Configuration__c.getOrgDefaults();
			return ac.TF4SF__Popup_Seconds__c;
		}
		private set;
	}

	private static Integer timeoutMinutes {
		get{
			return Integer.valueOf(timeoutSeconds / 60);
		}
		private set;
	}

	private static String getRandomString(Integer len) {
		String mode = String.valueOf(RANDOM_CHARS.length() - 1);
		String retVal = '';
		if (len != null && len >= 1) {
			Integer chars = 0;
			Integer random;
			do {
				random = Math.round(Math.random() * Integer.valueOf(mode));
				retVal += RANDOM_CHARS.substring(random, random + 1);
				chars++;
			} while (chars < len);
		}

		return retVal;
	}

	public static string encrypt(String clearText) {
		return EncodingUtil.base64Encode(crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(clearText)));
	}

	public static string decrypt(String cipherText) {
		return crypto.decryptWithManagedIV('AES128',key, EncodingUtil.base64Decode(cipherText)).toString();
	}

	public static void setAppToken(TF4SF__Application__c app) {
		String userToken = getRandomString(25);
		app.TF4SF__User_Token__c = encrypt(userToken);
		app.TF4SF__User_Token_Expires__c = System.now().addMinutes(timeoutMinutes);
	}

	//////////////////////////////END OF CRYPTO CLASS METHODS FOR OFFLIE PAGE/////////////////////////////////
	public pageReference startLoanApp() {
		prodType = 'Lending';
		pageReference p = postDetails();
		return p;
	}
	public pageReference startDepositApp() {
		prodType = 'Deposit';
		pageReference p = postDetails();
		return p;
	}

	public PageReference postDetails() {
		PageReference p = null;
		String appId = null;
		String url1 = '&flag=false';
		String url = TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'OnlineLinks?';
		if (version != null) { url += 'v=' + version + '&'; }
		if(String.isNotBlank(prodType)) { url1 += '&productType='+ prodType;}
		url += 'id=';
		System.debug('the url generated is ' + url);

		try {
			Map<String,String> personDataMap = new Map<String,String>();
			personDataMap.put('createdByUserId', loggedInUser.Id);
			personDataMap.put('createdByBranch', loggedInUser.TF4SF__Location__c);
			personDataMap.put('createdByChannel', loggedInUser.TF4SF__Channel__c);
			personDataMap.put('createdEmailAddress', loggedInUser.Email);
			personDataMap.put('currentPerson', loggedInUser.Id);
			personDataMap.put('currentBranch', loggedInUser.TF4SF__Location__c);
			personDataMap.put('currentChannel', loggedInUser.TF4SF__Channel__c);
			personDataMap.put('currentEmailAddress', loggedInUser.Email);
			//personDataMap.put('applicationVersion', (version == null) ? appConfig.TF4SF__Application_Version__c : version);

			if (custId != null) {
				// Code for the REST Request and Response using JSON
				//personDataMap.put('personId',custId);
				personDataMap.put('firstName', FirstName);
				personDataMap.put('middleName', MiddleName);
				personDataMap.put('lastName', LastName);
				personDataMap.put('emailAddress', PrimaryEmail);
				personDataMap.put('cellPhoneNumber', PrimaryPhone);
				personDataMap.put('customersID', custId);
				//personDataMap.put('memberNo', CustomerId);
				personDataMap.put('customersStreetAddress1', StreetAddress);
				personDataMap.put('customersStreetAddress2', '');
				personDataMap.put('customersCity', City);
				personDataMap.put('customersState', State);
				personDataMap.put('customersZipCode', ZipCode);
				personDataMap.put('ssn', SSNDisplay);
				List<String> dob_List = DateOfBirth.split('-');
				DateOfBirth = dob_List[1] + '/' + dob_List[2] + '/' + dob_List[0];
				personDataMap.put('dob', DateOfBirth);
				//Fix for DL details not showing up in start application from 360 degree view
				personDataMap.put('identificationNumber', IdentificationNumber);
				personDataMap.put('idState', IdState );
				
				List<String> expDate_List = Id_ExpirationDate.split('-');
				Id_ExpirationDate = expDate_List[1] + '/' + expDate_List[2] + '/' + expDate_List[0];                
				personDataMap.put('id_ExpirationDate', Id_ExpirationDate);
				System.debug('identificationType: '+identificationType);
				personDataMap.put('idType', identificationType);
				List<String> issueDate_List = Id_IssueDate.split('-');
				Id_IssueDate = issueDate_List[1] + '/' + issueDate_List[2] + '/' + issueDate_List[0];
				personDataMap.put('id_IssueDate', Id_IssueDate  );
				personDataMap.put('countryofCitizenship', CountryofCitizenship );
			} else {
				personDataMap.put('personId','');
			}

			String jsonStr = Json.serialize(personDataMap);
			Blob body = Blob.valueOf(jsonStr);
			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();
			req.requestURI = '/services/apexrest/onlinePageNew';
			req.requestBody = body;
			req.httpMethod = 'POST';
			RestContext.request = req;
			RestContext.response = res;
			appId = OnlineLinksController.generateApp();

			if (appId != null) {
				System.debug('appID = ' + appId);
				TF4SF__Application__c app = [SELECT Id, TF4SF__User_Token__c FROM TF4SF__Application__c WHERE Id = :appId];
				setAppToken(app);
				update app;
				String userToken = decrypt(app.TF4SF__User_Token__c);
				String userId = UserInfo.getUserId();
				Cookie id = ApexPages.currentPage().getCookies().get('id');
				Cookie ut = ApexPages.currentPage().getCookies().get('ut');
				id = new Cookie('id', appId, null, -1, true);
				ut = new Cookie('ut', userToken, null, -1, true);
				System.debug('id:' + id);
				System.debug('ut:' + ut);
				System.debug('userToken:' + userToken);
				System.debug('User_Token__c:' + app.TF4SF__User_Token__c);

				// Set the new cookie for the page
				ApexPages.currentPage().setCookies(new Cookie[]{id, ut});
				p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'OnlineLinks?id=' + appId + '&usr=' + userId+url1);
				p.setRedirect(true);
				System.debug('the url generated is ' + p);
			} else {
				System.debug('App ID returned from REST Callout was NULL');
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to Start Offline Application, Please contact the System administrator for more details'));
			}
		} catch (Exception e) {
			System.debug('The error is ' + e.getMessage() + ' and line number is ' + e.getLineNumber());
			//String s = OfflineApplicationExceptionHandling.createApplication();
			// p = new PageReference(url + s);
		}
		
		return p;
	}
	
	global String SearchResults (String customerNumber) {
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
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
		ResponseSearch(responseJson);
		return responseJson;
	}

	global void ResponseSearch (String response) {
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
			DateOfBirth = String.valueOf(l.get('birth_date'));
			SSNDisplay = String.valueOf(l.get('federal_id'));
			CustomerId = String.valueOf(l.get('id'));
			FirstName = String.valueOf(l.get('first_name'));
			MiddleName = String.valueOf(l.get('middle_name'));
			LastName = String.valueOf(l.get('last_name'));
			PrimaryEmail = String.valueOf(l.get('primary_email_address'));
			PrimaryPhone = String.valueOf(l.get('primary_phone_number'));
			List<Object> phnNum = (List<Object>)l.get('phone_numbers');
			if (String.isBlank(PrimaryPhone) && phnNum.size() > 0) { PrimaryPhone = String.ValueOf(phnNum[0]); }
			System.debug('phnnummmmmmm: ' + primaryPhone+'------' + phnNum);
			RegistrationDate = String.valueOf(l.get('registration_date'));
			if (l.get('married') != null) { IsMarried = Boolean.valueOf(l.get('married')); }
			SpouseId = String.valueOf(l.get('spouse_id'));
			ImmigrationStatus = String.valueOf(l.get('immigration_status'));
			CountryofCitizenship = String.valueOf(l.get('country_of_citizenship'));
			if (CountryofCitizenship != '' && CountryofCitizenship == 'USA') { CountryofCitizenship = 'US Citizen'; }
			FicoScore = String.valueOf(l.get('fico_score'));
			FicoScoreDate = String.valueOf(l.get('fico_score_date'));
			LastContactDate =  String.valueOf(l.get('last_contact_date'));
			LastUpdatedDate =  String.valueOf(l.get('last_detail_update_date'));
			Passphrase =  String.valueOf(l.get('passphrase'));
			StateDeliveryMethod =  String.valueOf(l.get('statement_delivery_method'));
			System.debug('the type is ' + l.get('type'));
			List<Object> uu = (List<Object>)l.get('identification_documents');

			for (Object u2 : uu) {
				Map<String, Object> u1 = (Map<String, Object>)u2;
				IdentificationType = String.valueOf(u1.get('type'));
				if (IdentificationType.contains('Driver\'s License')) { IdentificationType = 'Driver License'; }
				IdentificationNumber = String.valueOf(u1.get('id'));
				IdState = String.valueOf(u1.get('state_code'));
				Id_ExpirationDate = String.valueOf(u1.get('expiration_date'));
				Id_IssueDate = String.valueOf(u1.get('issue_date'));
			}

			List<Object> flagList = (List<Object>)l.get('flags');
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

			System.debug('flags::::::::: ' + flags);
			Map<String, Object> o1 = (Map<String, Object>)l.get('primary_occupancy_address');
			System.debug('primary_occupancy_address ' + o1);
			List<String> tt = String.valueOf(o1.get('address_lines')).split(',');

			for (String t1 : tt){
				System.debug('address_lines ' + t1.replace('(', '').replace(')', ''));
				StreetAddress = t1.replace('(', '').replace(')', '') + '\n';
			}

			System.debug('country_code ' + o1.get('country_code'));
			System.debug('state_code ' + o1.get('state_code'));
			System.debug('township ' + o1.get('township'));
			System.debug('zip_code ' + o1.get('zip_code'));
			City = String.valueOf(o1.get('township') + '\n');
			State = String.valueOf(o1.get('state_code') + '\n');
			ZipCode = String.valueOf(o1.get('zip_code') + '\n');
			CountryCode = String.valueOf(o1.get('country_code'));
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
			Accounts = (List<Object>)l.get('accounts');
			System.debug('the accounts list is ' + Accounts);
		}
	}

	global static String PreQualifiedCrossSell(String SSN, String LastName, String CustomerId) {
		System.debug('ssn is ' + SSN + ' & CustomerId');
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String url = '';
		String header = '';

		if (alpha.Enable_Production__c == true) {
			url = alpha.Production_URL__c;
			header = alpha.Production_Token__c;      
		} else {
			url = alpha.Sandbox_URL__c;
			header = alpha.Sandbox_Token__c;
		}

		String responseJson = '';
		HttpRequest req = new HttpRequest();
		String body = '';
		req.setTimeout(120 * 1000);  //120 seconds
		//req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
		url += 'api/cache/offers/?federalids=' + SSN + '&lastname=' + LastName;
		//blob headerValue = blob.valueOf('Test'+':'+'Testvalue');
		//String header = 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'; //'BASIC '+ EncodingUtil.base64Encode(headerValue);
		req.setEndpoint(url);
		req.setHeader('authorization', header);
		req.setMethod('GET'); 
		//req.setBody(body);
		//System.debug('Request: ' + body);
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		//req.setHeader('authorization', header);
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 
		System.debug('req ' + req);

		if (response.getStatusCode() != 200) {
			String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
			//System.debug(errorMsg);
		}

		responseJson = response.getBody();
		System.debug('Response: ' + responseJson);
		//InsertDebugLog(appId, json, 'TIPIntegraion Request');
		//InsertDebugLog(appId, responseJSON, 'TIPIntegraion Response');
		List<TF4SF__Promotion__c> promotions = [SELECT Id, TF4SF__Customer__c, TF4SF__Sub_Product_Code__c, TF4SF__Url__c, TF4SF__keywords__c, TF4SF__Description__c, TF4SF__Template__c FROM TF4SF__Promotion__c WHERE TF4SF__Customer__c = :CustomerId]; 
		List<TF4SF__Promotion__c> newpromotions = new List<TF4SF__Promotion__c>(); 
		List<TF4SF__Promotion__c> updatepromotions = new List<TF4SF__Promotion__c>(); 
		List<Object> a = (List<Object>)JSON.deserializeUntyped(responseJson);
		Map<String, Object> m = (Map<String, Object>)a[0];
		System.debug('the response is ' + m.get('value'));
		List<Object> k = (List<Object>)m.get('value');

		for (Object u : k) {
			Map<String, Object> l = (Map<String, Object>)u;
			System.debug('the accepted_date is ' + l.get('accepted_date'));
			System.debug('the cached_timestamp is ' + l.get('cached_timestamp'));
			System.debug('the card_type is ' + l.get('card_type'));
			System.debug('the expiration_date is ' + l.get('expiration_date'));
			System.debug('the interest_rate is ' + l.get('interest_rate'));
			System.debug('the max_credit_limit is ' + l.get('max_credit_limit'));
			System.debug('the product_name is ' + l.get('product_name'));
			System.debug('the product_type is ' + l.get('product_type'));
			System.debug('the type is ' + l.get('type'));

			if (promotions.size() > 0) {
				for (TF4SF__Promotion__c promo : promotions) {
					if (promo.TF4SF__Description__c == String.valueof(l.get('product_name')) && promo.TF4SF__Template__c == String.valueof(l.get('type'))) {
						promo.TF4SF__Customer__c = CustomerId;
						promo.TF4SF__Description__c = String.valueof(l.get('product_name'));
						promo.TF4SF__Sub_Product_Code__c = String.valueof(l.get('product_type'));
						promo.TF4SF__Url__c = 'https://keypointdev-developer-edition.na50.force.com/StartOffer?Code=' + promo.TF4SF__Sub_Product_Code__c;
						promo.TF4SF__Template__c = String.valueOf(l.get('type'));
						updatepromotions.add(promo);
					} else {
						TF4SF__Promotion__c pro = new TF4SF__Promotion__c();
						pro.TF4SF__Customer__c = CustomerId;
						pro.TF4SF__Description__c = String.valueof(l.get('product_name'));
						pro.TF4SF__Sub_Product_Code__c = String.valueof(l.get('product_type'));
						pro.TF4SF__Url__c = 'https://keypointdev-developer-edition.na50.force.com/StartOffer?Code=' + pro.TF4SF__Sub_Product_Code__c;
						pro.TF4SF__Template__c = String.valueOf(l.get('type'));
						newpromotions.add(pro);
					}
				}
			} else {
				TF4SF__Promotion__c pr = new TF4SF__Promotion__c();
				pr.TF4SF__Customer__c = CustomerId;
				pr.TF4SF__Description__c = String.valueof(l.get('product_name'));
				pr.TF4SF__Sub_Product_Code__c = String.valueof(l.get('product_type'));
				pr.TF4SF__Url__c = 'https://keypointdev-developer-edition.na50.force.com/StartOffer?Code=' + pr.TF4SF__Sub_Product_Code__c;
				pr.TF4SF__Template__c = String.valueOf(l.get('type'));
				newpromotions.add(pr);
			}
		}

		if (newpromotions.size() > 0) { insert newpromotions; }
		if (updatepromotions.size() > 0) { update updatepromotions; }
		return responseJson;
	}
}