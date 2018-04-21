@RestResource(urlMapping='/OLB/v1/*')
global with sharing class OnlineBankingPublicController {

	@HttpPost
	global static void startApplication() {
		System.debug('inside startApplication');
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
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String productCode = req.params.get('productCode');
		String subProductCode = req.params.get('subProductCode');
		String campaignId = req.params.get('campaign');
		String PromoCode = req.params.get('PromoCode');
		String ipaddress = req.headers.get('X-Salesforce-SIP');
		String productValue;
		String subProductValue;
		String subProductDescription;
		String body = req.requestBody.toString(); 
		System.debug('length: ' + body.length() + '; body1: ' + body);
		String jsonKey = 'memInfo';

		if (body != null && body.length() > 0 && body.contains(jsonKey)) {
			List<String> parts = body.split('=');
			if (parts[1] != null && parts[1] != '') { body = parts[1]; }
		}

		if (body.length() == 0) {
			body = req.params.get('memInfo');
			System.debug('body = ' + body);
		}

		String clearText = null;
		OnlineEncryption__c OBC = OnlineEncryption__c.getOrgDefaults();
		System.debug('length of OBC.key__c: ' + OBC.key__c.length());
		TF4SF__Product_Codes__c pc;
		System.debug('the subProductCode is ' + subProductCode);
		if (subProductCode != null) { pc = TF4SF__Product_Codes__c.getValues(subProductCode); }
		System.debug('the PC is ' + pc);

		if (pc != null) {
			System.debug('inside pc if');
			//if (String.isNotBlank(pc.TF4SF__Product_Code__c)) {
				productValue = pc.TF4SF__Product__c;
				System.debug('the PC is ' + pc.TF4SF__Product__c);
			//}
			//if (String.isNotBlank(pc.TF4SF__Sub_Product_Code__c)) {
				subProductValue = pc.TF4SF__Sub_Product__c;
				System.debug('the PC is ' + pc.TF4SF__Sub_Product__c);
				if (String.isNotBlank(pc.TF4SF__Description__c)) { subProductDescription = pc.TF4SF__Description__c; }
				System.debug('subProductDescription' + subProductDescription);
			//}
		}

		System.debug('productValue: ' + productValue + '; subProductValue: ' + subProductValue);
		TF4SF__Application__c app = new TF4SF__Application__c(
			TF4SF__Product__c = productValue,
			TF4SF__Sub_Product__c = subProductValue,
			TF4SF__Sub_Product_Description__c = subProductDescription,
			//TF4SF__Campaign_Id__c = campaignId,
			TF4SF__Special_Promo_Code__c = PromoCode,
			TF4SF__Created_Channel__c = 'Online Banking',
			TF4SF__Current_Channel__c = 'Online Banking',
			//TF4SF__Created_By__c = UserInfo.getUserId(),
			TF4SF__Current_Person__c = UserInfo.getUserId(),
			TF4SF__Current_Timestamp__c = System.now(),
			TF4SF__Application_Status__c = 'Open'
		);

		UserData ud = null;
		Boolean validPrefill = true;

		try { //Deserialize JSON here. Good place for a try/catch
			if (body != null && body != '') {
				blob cryptoKey = EncodingUtil.base64Decode(OBC.key__c);
				blob vector = EncodingUtil.base64Decode(OBC.Vector__c);
				clearText = crypto.decrypt('AES256', cryptoKey, vector, EncodingUtil.base64Decode(body)).toString();
				System.debug('clearText =' + clearText);
				ud = (UserData)JSON.deserialize(clearText, UserData.class);
				String Response_Data = SearchResults(ud.PersNumber);
				List<Object> a = (List<Object>)JSON.deserializeUntyped(Response_Data);
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
					System.debug('the type is ' + l.get('type'));
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
					for (String l2 : k2) { System.debug('phone_numbers ' + l2.replace('(', '').replace(')', '')); }
					Accounts = (List<Object>)l.get('accounts');
					System.debug('the accounts list is ' + Accounts);
				}

				app.TF4SF__First_Name__c = FirstName;
				app.TF4SF__Middle_Name__c = MiddleName;
				app.TF4SF__Last_Name__c = LastName;
				//app.Suffix__c = ud.Suffix;
				app.TF4SF__Is_Member__c = true;
				app.TF4SF__Street_Address_1__c = StreetAddress;
				//app.TF4SF__Street_Address_2__c = ud.Address2;
				app.TF4SF__City__c = City;
				app.TF4SF__State__c = State;
				app.TF4SF__Zip_Code__c = ZipCode;
				app.TF4SF__Primary_Phone_Number__c = PrimaryPhone;
				//app.Secondary_Phone_Number__c = ud.WorkPhone;
				app.TF4SF__Email_Address__c = PrimaryEmail;
				app.TF4SF__IP_Address__c = ipaddress;

				List<String> dob_List = DateOfBirth.split('-');
				DateOfBirth = dob_List[1] + '/' + dob_List[2] + '/' + dob_List[0];

				List<String> expiry_date_List = Id_ExpirationDate.split('-');
				Id_ExpirationDate = expiry_date_List[1] + '/' + expiry_date_List[2] + '/' + expiry_date_List[0];

				List<String> issue_date_List = Id_IssueDate.split('-');
				Id_IssueDate = issue_date_List[1] + '/' + issue_date_List[2] + '/' + issue_date_List[0];
			}
		} catch (Exception e) {
			//Unable to parse encrypted data - fall through and create an application with no prefill data:
			System.debug('Decryption Error: ' + e.getMessage() + e.getStackTraceString());
			//res.addHeader('Refresh', '0; url=https://cs22.salesforce.com/ErrorPage' );
			//clearText = 'Decryption Error: ' + e.getMessage();
			clearText = null;
			validPrefill = false;
		}

		try {
			SearchMemberResults.setAppToken(app);
			if (TF4SF__Application__c.SObjectType.getDescribe().isCreateable() && TF4SF__Application__c.SObjectType.getDescribe().isUpdateable()) {
				insert app;
				parseProductType(app);
				update app;
			}

			TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c(
				TF4SF__Application__c = app.Id,
				TF4SF__Date_of_Birth__c = DateOfBirth,
				TF4SF__SSN_Prime__c = SSNDisplay,
				TF4SF__Citizenship__c = ImmigrationStatus
			);
			if ( IdentificationType.contains('Driver\'s License')) {
				iden.TF4SF__ID_Type__c = 'Driver License';
				iden.TF4SF__Identity_Number_Primary__c = IdentificationNumber;
				iden.TF4SF__State_Issued__c = IdState;
				iden.TF4SF__Expiry_Date__c = Id_ExpirationDate;
				iden.TF4SF__Issue_Date__c = Id_IssueDate;
			}
			

			if (TF4SF__Identity_Information__c.SObjectType.getDescribe().isCreateable()) { insert iden; }
			TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c(TF4SF__Application__c = app.Id);
			if (TF4SF__Employment_Information__c.SObjectType.getDescribe().isCreateable()) { insert emp; }
			TF4SF__About_Account__c acc = new TF4SF__About_Account__c(TF4SF__Application__c = app.Id);
			if (TF4SF__About_Account__c.SObjectType.getDescribe().isCreateable()) { insert acc; }
			TF4SF__Application2__c app2 = new TF4SF__Application2__c(TF4SF__Application__c = app.Id);
			if (TF4SF__Application2__c.SObjectType.getDescribe().isCreateable()) { insert app2; }

			TF4SF__Application_Activity__c appAct = new TF4SF__Application_Activity__c(
				TF4SF__Application__c = app.Id,
				//Branch__c = app.Current_Branch_Name__c,
				TF4SF__Channel__c = app.TF4SF__Current_Channel__c,
				//Name__c = app.Current_Person__c,
				TF4SF__Action__c = 'Created the Application from Online Banking',
				TF4SF__Activity_Time__c = System.now()
			);

			if (TF4SF__Application_Activity__c.SObjectType.getDescribe().isCreateable()) { insert appAct; }
			String userToken = SearchMemberResults.decrypt(app.TF4SF__User_Token__c);
			//String subpage = (validPrefill) ? '#/personal-info' : '#/get-started';
			String subpage = (validPrefill) ? '#/cross-sell' : '#/get-started';
			System.debug('app.Id = ' + app.Id);
			PageReference p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'tf4sf__dsp' + subpage);
			p.getParameters().put('id', app.Id);
			Cookie id = new Cookie('id', app.Id, null, -1, true);
			Cookie ut = new Cookie('ut', userToken, null, -1, true);
			// Set the new cookie for the page
			System.debug('p = ' + p);
			res.AddHeader('Content-Type', 'text/html; charset=UTF-8');
			res.AddHeader('Refresh', '0; url=' + p.getUrl());
			String resBody = '{ "message": "Callout Successfull"}';
		} catch (Exception e) {
			//Add debugging info!! - send to debug logs
			System.debug( 'Online Error: ' + e.getMessage() + e.getStackTraceString());
			res.addHeader('Refresh', '0; url=' + TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'ErrorPage');
		}
	}

	global class UserData {
		//Application__c fields
		public String FirstName {get;set;}
		public String MiddleName {get;set;}
		public String LastName {get;set;}
		public String FullName {get;set;}
		public String Suffix {get;set;}
		public String Address1 {get;set;}
		public String Address2 {get;set;}
		public String City {get;set;}
		public String State {get;set;}
		public String Zip {get;set;}
		public String ZipPlusFour {get;set;}
		public String PrimaryPhone {get;set;}
		public String WorkPhone {get;set;}
		public String TaxIdentifier {get;set;}
		public String PersNumber {get;set;}
		public String DOB {get;set;}
		public String EmailAddress {get;set;}
		public String IDType {get;set;}
		public String IDNumber {get;set;}
		public String IDStateIssued {get;set;}
		public String IDIssueDate {get;set;}
		public String IDExpirationDate {get;set;}
		public String IsEmployee {get;set;}

		public UserData() {}
	}

	public String productCode;
	public String subProductCode;
	public String ipaddress;
	public String userToken;
	public String xmlString;
	public Dom.Document xmlData;
	public Dom.XMLNode address;
	public Boolean hasSSL{get; set;}
	public String fullURL{get; set;}
	public String campaignId;
	public String PromoCode;

	public OnlineBankingPublicController() {
		hasSSL = (ApexPages.currentPage().getHeaders().get('CipherSuite') != null) ? TRUE : FALSE;
		this.productCode = ApexPages.currentPage().getParameters().get('productCode');
		this.subProductCode = ApexPages.currentPage().getParameters().get('subProductCode');
		this.ipaddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
		this.campaignId = ApexPages.currentPage().getParameters().get('campaign');
		this.PromoCode = ApexPages.currentPage().getParameters().get('PromoCode');
		this.xmlString = ApexPages.currentPage().getParameters().get('xmldata');
		System.debug('The xmlstring is ' + this.xmlString);
		this.xmlData = new DOM.Document();
		System.debug('xmlData is:' + this.xmlString);
		if (this.xmlString != null) { this.xmlData.load(this.xmlString); }
	}

	public PageReference goToGetStartedHtml() {
		System.debug('The xmlstring is ' + this.xmlString);

		if (hasSSL == FALSE) {
			fullURL = URL.getCurrentRequestUrl().toExternalForm().replace('http','https');
			System.debug('The full Secure url is' + fullURL);
			PageReference retpage = new pagereference(fullURL);
			retpage.setRedirect(true);

			return retpage;
		} else {
			PageReference p = null;
			TF4SF__Product_Codes__c pc;
			TF4SF__Application__c newApplication = new TF4SF__Application__c ();
			TF4SF__Application2__c newApplication2 = new TF4SF__Application2__c ();
			TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
			TF4SF__Application_Activity__c apphistory = new TF4SF__Application_Activity__c ();
			newApplication.TF4SF__IP_Address__c = ipaddress;
			//newApplication.TF4SF__Campaign_Id__c = campaignId;
			newApplication.TF4SF__Special_Promo_Code__c = PromoCode;
			// This means Application started from Lead but not from Online

			if (xmlString != null) {
				System.debug('xml exists');
				address = xmlData.getRootElement();
				if (xmlString.contains('FirstName')) {
					newApplication.TF4SF__First_Name__c            = address.getChildElement('FirstName', null).getText();
				}

				if (xmlString.contains('LastName')) {
					newApplication.TF4SF__Last_Name__c             = address.getChildElement('LastName', null).getText();
				}

				if (xmlString.contains('LeadEmail')) {
					newApplication.TF4SF__Email_Address__c         = address.getChildElement('LeadEmail', null).getText();
				}

				if (xmlString.contains('Phone')) {
					newApplication.TF4SF__Primary_Phone_Number__c  = address.getChildElement('Phone', null).getText();
				}

				if (xmlString.contains('Product')) {
					newApplication.TF4SF__Product__c               = address.getChildElement('Product', null).getText();
				}

				if (xmlString.contains('Product') && xmlString.contains('SubProduct')) {
					newApplication.TF4SF__Sub_Product__c           = address.getChildElement('Product', null).getText()+'-'+address.getChildElement('SubProduct', null).getText();
				}

				if (xmlString.contains('LeadPersonNumber')) {
					newApplication.TF4SF__Person_Number__c         = address.getChildElement('LeadPersonNumber', null).getText();
				}

				if (xmlString.contains('LeadStreet')) {
					newApplication.TF4SF__Street_Address_1__c      = address.getChildElement('LeadStreet', null).getText(); 
				}

				if (xmlString.contains('LeadCity')) {
					newApplication.TF4SF__City__c                  = address.getChildElement('LeadCity', null).getText();  
				}

				if (xmlString.contains('LeadState')) {
					System.debug('LeadSTate variable exists');
					newApplication.TF4SF__State__c                 = address.getChildElement('LeadState', null).getText();
				}

				if (xmlString.contains('LeadPostalCode')) {
					newApplication.TF4SF__Zip_Code__c              = address.getChildElement('LeadPostalCode', null).getText();  
				}

				// CreatedBy Attributes  
				//if (xmlString.contains('CreatedByUserId'))
				//    newApplication.TF4SF__Created_By__c            = address.getChildElement('CreatedByUserId', null).getText();

				if (xmlString.contains('CreatedByBranch')) {
					newApplication.TF4SF__Created_Branch_Name__c   = address.getChildElement('CreatedByBranch', null).getText();
				}

				if (xmlString.contains('CreatedByChannel')) {
					newApplication.TF4SF__Created_Channel__c       = address.getChildElement('CreatedByChannel', null).getText();
				}

				// Current User attributes
				if (xmlString.contains('CurrentPerson')) {
					newApplication.TF4SF__Current_Person__c       = address.getChildElement('CurrentPerson', null).getText(); 
				}

				if (xmlString.contains('CurrentBranch')) {
					newApplication.TF4SF__Current_Branch_Name__c   = address.getChildElement('CurrentBranch', null).getText();
				}

				if (xmlString.contains('CurrentChannel')) {
					newApplication.TF4SF__Current_Channel__c       = address.getChildElement('CurrentChannel', null).getText();
				}

				newApplication.TF4SF__Current_Timestamp__c       = System.now();
				if (xmlString.contains('ApplicationStatus')) {
					newApplication.TF4SF__Application_Status__c    = address.getChildElement('ApplicationStatus', null).getText();
				}
			} else {
				// Executed when Application is started from Site which means XMLString will be null
				newApplication.TF4SF__Created_Channel__c = 'Online';
				newApplication.TF4SF__Current_Channel__c = 'Online';
				//newApplication.TF4SF__Created_By__c = UserInfo.getUserId();
				newApplication.TF4SF__Current_Person__c = UserInfo.getUserId();
				newApplication.TF4SF__Current_Timestamp__c = System.now();
				if (subProductCode != null) { pc = TF4SF__Product_Codes__c.getValues(subProductCode); }

				if (pc != null) {
					if (pc.TF4SF__Product_Code__c != null) { newApplication.TF4SF__Product__c = pc.TF4SF__Product__c; }
					if (pc.TF4SF__Sub_Product_Code__c != null) { newApplication.TF4SF__Sub_Product__c = pc.TF4SF__Sub_Product__c; }
				} else {
					return null;
				}
			}
			
			SearchMemberResults.setAppToken(newApplication);  
			insert newApplication;
			parseProductType(newApplication);
			update newApplication;
			userToken = SearchMemberResults.decrypt(newApplication.TF4SF__User_Token__c);
			system.debug(' Post decrypt of user token');
			system.debug('The new application Id' + newApplication.Id);
			
			// Creating Application2, AboutAccount and Activity History Records since these objects need Application ID as their parent
			if (newApplication.Id != null) {
				newApplication2.TF4SF__Application__c = newApplication.Id;
				insert newApplication2;
				acc.TF4SF__Application__c = newApplication.Id;
				insert acc;
				apphistory.TF4SF__Application__c = newApplication.id;
				apphistory.TF4SF__Branch__c = newApplication.TF4SF__Current_Branch_Name__c;
				apphistory.TF4SF__Channel__c = newApplication.TF4SF__Current_Channel__c;
				apphistory.TF4SF__Name__c = newApplication.TF4SF__Current_Person__c;
				apphistory.TF4SF__Action__c = 'Created the Application';
				apphistory.TF4SF__Activity_Time__c = System.now();
				insert apphistory;
			}

			if (xmlString == null) {
				p = null;
				p.getParameters().put('product', newApplication.TF4SF__Product__c);
				p.getParameters().put('subProduct', newApplication.TF4SF__Sub_Product__c);
			} else {
				System.debug('going to crosssell');
				p = null;
			}

			p.getParameters().put('id',newApplication.id);
			p.getParameters().put('ut',userToken);

			return p;
		}
	}

	global static void parseProductType(TF4SF__Application__c app) {
		Integer i = 0;
		String prodName;
		String productMappingName;

		if (app.TF4SF__Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('Business').TF4SF__Product_Name__c)) {
			// To update type of BusinessChecking product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessChecking').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {

				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Checking__c.isCreateable()) { app.TF4SF__Type_Of_Business_Checking__c = prodName; }
			if (app.TF4SF__Type_Of_Business_Checking__c != null) { i = i + 1; }

			// To update Type of BusinessSavings Product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessSavings').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Savings__c.isCreateable()) { app.TF4SF__Type_Of_Business_Savings__c = prodName; }
			if (app.TF4SF__Type_Of_Business_Savings__c != null) { i = i + 1; }

			// To update type of BusinessCDs product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessCDs').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_CDs__c.isCreateable()) { app.TF4SF__Type_Of_Business_CDs__c = prodName; }
			if (app.TF4SF__Type_Of_Business_CDs__c != null) { i = i + 1; }

			// To update type of BusinessCreditCards selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessCreditCards').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Credit_Cards__c.isCreateable()) { app.TF4SF__Type_Of_Business_Credit_Cards__c = prodName; }
			if (app.TF4SF__Type_Of_Business_Credit_Cards__c != null) { i = i + 1; }

			// To update type of BusinessLoans selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessLoans').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Loans__c.isCreateable()) { app.TF4SF__Type_Of_Business_Loans__c = prodName; }
			if (app.TF4SF__Type_Of_Business_Loans__c != null) { i = i + 1; }
		} else {
			// to update type of Checking Product Selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('Checking').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Checking__c.isCreateable()) { app.TF4SF__Type_of_Checking__c = prodName; }
			if (app.TF4SF__Type_of_Checking__c != null) { i = i + 1; }

			// To update Type of Savings Product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('Savings').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Savings__c.isCreateable()) { app.TF4SF__Type_of_Savings__c = prodName; }
			if (app.TF4SF__Type_of_Savings__c != null) { i = i + 1; }

			// To update type of Certificates product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('Certificates').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Certificates__c.isCreateable()) { app.TF4SF__Type_of_Certificates__c = prodName; }
			if (app.TF4SF__Type_of_Certificates__c != null) { i = i + 1; }

			// To update type of Credit Cards selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('CreditCards').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Credit_Cards__c.isCreateable()) { app.TF4SF__Type_of_Credit_Cards__c = prodName; }
			if (app.TF4SF__Type_of_Credit_Cards__c != null) { i = i + 1; }

			// To update type of Vehicle Loans selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('VehicleLoans').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Vehicle_Loans__c.isCreateable()) { app.TF4SF__Type_of_Vehicle_Loans__c = prodName; }
			if (app.TF4SF__Type_of_Vehicle_Loans__c != null) { i = i + 1; }

			// To update type of Personal Loan selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('PersonalLoans').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Personal_Loans__c.isCreateable()) { app.TF4SF__Type_of_Personal_Loans__c = prodName; }
			if (app.TF4SF__Type_of_Personal_Loans__c != null) { i = i + 1; }

			// To update type of Mortgage Loan product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('HomeLoan').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Mortgage_Loan__c.isCreateable()) { app.TF4SF__Type_of_Mortgage_Loan__c = prodName; }
			if (app.TF4SF__Type_of_Mortgage_Loan__c != null) { i = i + 1; }

			// To update type of Home Equity product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('HomeEquity').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}
			

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Home_Equity__c.isCreateable()) { app.TF4SF__Type_Of_Home_Equity__c = prodName; }
			if (app.TF4SF__Type_Of_Home_Equity__c != null) { i = i + 1; }
		}

		if (app.TF4SF__Primary_Offer__c != null) {
			List<String> l1 = app.TF4SF__Primary_Offer__c.split('-', 10);
			if (l1[0] != null) {
				prodName = l1[0].trim();
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Cross_Sell_1_Product__c.isCreateable()) { app.TF4SF__Cross_Sell_1_Product__c = prodName; }
			}
		}

		if (app.TF4SF__Second_Offer__c != null) {
			List<String> l2 = app.TF4SF__Second_Offer__c.split('-', 10);
			if (l2[0] != null) {
				prodName = l2[0].trim();
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Cross_Sell_2_Product__c.isCreateable()) { app.TF4SF__Cross_Sell_2_Product__c = prodName; }
			}
		}

		if (app.TF4SF__Third_Offer__c != null) {
			List<String> l3 = app.TF4SF__Third_Offer__c.split('-', 10);
			if (l3[0] != null) {
				prodName = l3[0].trim();
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Cross_Sell_3_Product__c.isCreateable()) { app.TF4SF__Cross_Sell_3_Product__c = prodName; }
			}
		}

		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Number_of_Products__c.isCreateable()) { app.TF4SF__Number_of_Products__c = i; }
		System.debug('after number of products is' + app.TF4SF__Number_of_Products__c); 
	}

	global static String SearchResults (String customerNumber) {
		String responseJson = '';
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String url = '';
		String authorizationHeader = '';

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

		url += '/api/cache/customers/?federalid=' + customerNumber + '&fullaccounts=false';
		req.setEndpoint(url);
		req.setHeader('authorization', authorizationHeader);
		req.setMethod('GET'); 
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 
		if (response.getStatusCode() != 200) { String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus(); }
		responseJson = response.getBody();
		System.debug('Response: ' + responseJson);

		return responseJson;
	}
}