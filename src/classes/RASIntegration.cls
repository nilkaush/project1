global with sharing class RASIntegration implements TF4SF.DSP_Interface {

	global Map<String,String> main(Map<String,String> tdata) {
		Map<String, String> data = tdata.clone();

		try {
			String custId;
			TF4SF__Customer__c customer;
			String CustomerId;
			String Customer_Id;
			String FirstName;
			String MiddleName;
			String LastName;
			String StreetAddress;
			String City;
			String State;
			String ZipCode;
			String CountryCode;
			String SSNDisplay;
			String DateOfBirth;
			String PrimaryEmail;
			String PrimaryPhone;
			String RegistrationDate;
			Boolean IsMarried;
			String SpouseId;
			String ImmigrationStatus;
			String CountryofCitizenship;
			String FicoScore;
			String FicoScoreDate;
			String LastContactDate;
			String LastUpdatedDate;
			String Passphrase;
			String StateDeliveryMethod;
			String IdentificationType;
			String IdentificationNumber;
			String IdState;
			String Id_ExpirationDate;
			String Id_IssueDate;
			List<Object> Accounts;
			String cached_timestamp;
			String Account_id;

			String appId = tdata.get('id');
			String Username = tdata.get('Application__c.Login__c');
			String Password = tdata.get('Application__c.Password__c');
			String webServiceUrl = 'https://archuat.aciondemand.com/2193/hlm/IDS.Banking.RemoteAuthentication/RAService.asmx';
			OnlineBankingWebservices.AuthenticationServiceSoap obSend = new OnlineBankingWebservices.AuthenticationServiceSoap();
			obSend.endpoint_x = webServiceUrl;
			obSend.timeout_x = 120000;
			String Clear_cargo = '<?xml version="1.0" encoding="utf-8"?><AccountVerificationRequest><User><LoginName>' + Username + '</LoginName><Password>' + Password + '</Password></User></AccountVerificationRequest>';
			String Encrypted_cargo = OLBSimulator.encryptJSON(Clear_cargo);
			String vc = obSend.ValidateCredentials('123456789', Encrypted_cargo);
			String DecyptedString = OLBSimulator.decryptData(vc);
			//XMLParser xm = new XMLParser();
			//String AccountNumbers = xm.parse(DecyptedString);
			String customerSSN = DecyptedString.substringBetween('<InstitutionUserId>', '</InstitutionUserId>');
			System.debug('the response ' + customerSSN);
			//String Respone_Account = SearchResults(AccountNumber);
			//String CustomerIds = ResponseSearch(customerSSN);
			//List<String> CustomerList = CustomerIds.split(':');

			if (String.isNotBlank(customerSSN)) {
				String Response_Customer = SearchResults(customerSSN);
				List<Object> a = (List<Object>)JSON.deserializeUntyped(Response_Customer);
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
					RegistrationDate = String.valueOf(l.get('registration_date'));
					IsMarried = Boolean.valueOf(l.get('married'));
					SpouseId = String.valueOf(l.get('spouse_id'));
					ImmigrationStatus = String.valueOf(l.get('immigration_status'));
					CountryofCitizenship = String.valueOf(l.get('country_of_citizenship'));
					FicoScore = String.valueOf(l.get('fico_score'));
					FicoScoreDate = String.valueOf(l.get('fico_score_date'));
					LastContactDate =  String.valueOf(l.get('last_contact_date'));
					LastUpdatedDate =  String.valueOf(l.get('last_detail_update_date'));
					Passphrase =  String.valueOf(l.get('passphrase'));
					StateDeliveryMethod =  String.valueOf(l.get('statement_delivery_method'));
					System.debug('the type is '+l.get('type'));
					List<Object> uu = (List<Object>)l.get('identification_documents');

					for (Object u2 : uu) {
						Map<String, Object> u1 = (Map<String, Object>)u2;
						IdentificationType = String.valueOf(u1.get('type'));
						IdentificationNumber = String.valueOf(u1.get('id'));
						IdState = String.valueOf(u1.get('state_code'));
						Id_ExpirationDate = String.valueOf(u1.get('expiration_date'));
						Id_IssueDate = String.valueOf(u1.get('issue_date'));
					}
				
					Map<String, Object> o1 = (Map<String, Object>)l.get('primary_occupancy_address');
					System.debug('primary_occupancy_address ' + o1);
					List<String> tt = String.valueOf(o1.get('address_lines')).split(',');

					for (String t1 : tt) {
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

					for (String l2 : k2) { 
						if (String.isBlank(PrimaryPhone)) {
							PrimaryPhone = String.valueOf(l2);
							PrimaryPhone = PrimaryPhone.replace('(', '').replace(')', '');
						}

						System.debug('phone_numbers ' + l2.replace('(', '').replace(')', '')); 
					}

					Accounts = (List<Object>)l.get('accounts');
					System.debug('the accounts list is ' + Accounts);
				}
				
				List<String> dob_List = DateOfBirth.split('-');
				DateOfBirth = dob_List[1] + '/' + dob_List[2] + '/' + dob_List[0];
				
				data.put('Application__c.First_Name__c', FirstName);
				data.put('Application__c.Middle_Name__c', MiddleName);
				data.put('Application__c.Last_Name__c', LastName);
				data.put('Application__c.Street_Address_1__c', StreetAddress);
				data.put('Application__c.City__c', City);
				data.put('Application__c.State__c', State);
				data.put('Application__c.Zip_Code__c', ZipCode);
				data.put('Application__c.Primary_Phone_Number__c', PrimaryPhone);
				data.put('Application__c.Email_Address__c', PrimaryEmail);
				data.put('Identity_Information__c.Date_Of_Birth__c', DateOfBirth);
				data.put('Identity_Information__c.TF4SF__SSN_Prime__c', SSNDisplay);
				data.put('Application__c.Current_Channel__c', 'Online Banking');
			}

			if (String.isNotBlank(appId)) {
				TF4SF__Application__c app = [SELECT Id, TF4SF__Application_Page__c FROM TF4SF__Application__c WHERE Id = :appId];
				TF4SF__Identity_Information__c iden = [SELECT Id, TF4SF__Application__c FROM TF4SF__Identity_Information__c WHERE TF4SF__Application__c = :appId];
				app.TF4SF__Application_Page__c = 'PersonalInfoPage';
				app.TF4SF__First_Name__c = FirstName;
				app.TF4SF__Middle_Name__c = MiddleName;
				app.TF4SF__Last_Name__c=LastName;
				app.TF4SF__Street_Address_1__c = StreetAddress;
				app.TF4SF__City__c = City;
				app.TF4SF__State__c = State;
				app.TF4SF__Zip_Code__c = ZipCode;
				app.TF4SF__Primary_Phone_Number__c = PrimaryPhone;
				app.TF4SF__Email_Address__c = PrimaryEmail;
				app.TF4SF__Current_Channel__c = 'Online Banking';
				app.TF4SF__Current_Timestamp__c = System.now();
				iden.TF4SF__SSN_Prime__c = SSNDisplay;
				iden.TF4SF__Date_of_Birth__c = DateOfBirth;
				iden.TF4SF__Citizenship__c = ImmigrationStatus;
				update iden;
				update app;
			}

			//data.put('resp', vc);
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in RASIntegration class: ' + e.getMessage());
			System.debug('server-errors: ' + e.getMessage());
			//data.put('resp', 'error while making a call');
		}

		return data;
	}

	global static String SearchResults (String customerNumber) {
		String responseJson = '';
		System.debug('SSNIS :' + customerNumber);
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String url = '';
		String authorizationHeader;

		if (alpha.Enable_Production__c == false) {
			authorizationHeader = 'JWT ' + alpha.Sandbox_Token__c;
			url = alpha.Sandbox_URL__c;
		} else {
			authorizationHeader = 'JWT ' + alpha.Production_Token__c;
			url = alpha.Production_URL__c;
		}

		HttpRequest req = new HttpRequest();
		String body = '';
		req.setTimeout(120 * 1000);  //120 seconds
		//req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
		url += '/api/cache/customers/?federalid=' + customerNumber + '&fullaccounts=false';
		req.setEndpoint(url);
		req.setHeader('authorization', authorizationHeader);
		req.setMethod('GET'); 
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 

		if (response.getStatusCode() != 200) {
			String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
		}

		responseJson = response.getBody();
		System.debug('Response: ' + responseJson);
		//InsertDebugLog(appId, json, 'TIPIntegraion Request');
		//InsertDebugLog(appId, responseJSON, 'TIPIntegraion Response');
		//ResponseSearch(responseJson);
		return responseJson;
	}
}