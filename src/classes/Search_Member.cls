public with sharing class Search_Member {
	public String SSNQuery {get; set;}
	public Boolean searchMsg {get; set;}
	public Boolean appsearchMsg {get; set;}
	public Boolean searchMsgDetails {get; set;}
	public String imageURL{get; set;}
	//public List<Product__c> accDetails = new List<Product__c>();
	public Boolean ShowMemberNo {get; set;}
	public Boolean ShowApplicantNo {get; set;}
	public Boolean ShowappMemberNo {get; set;}
	public Boolean ShowPersonNo {get; set;}
	public Boolean ShowStartApplication {get; set;}
	public String Customer_Id{get; set;}
	// Declaring variables to paginate search results
	public ApexPages.StandardSetController assc {get; set;}
	public Integer counter = 0;
	public Integer appcounter = 0;
	// Declaring variables to maintain member search result limitations
	public Integer maxSearchResults{get; set;}
	public Integer recordsPerPage {get; set;}
	// Application Search Criteria
	public String appfirstnameQuery {get; set;}
	public String applastnameQuery {get; set;}
	public String appssnLast4Query {get; set;}
	public String appEmailQuery {get; set;}
	public String ApplicationQuery {get; set;}
	public String appMemberQuery {get; set;}
	public String FromDate {get; set;}
	public String ToDate {get; set;}
	public String dat {get; set;}
	public List<String> flagList {get; set;}
	public List<TF4SF__Application__c> applications = new List<TF4SF__Application__c>();
	public List<TF4SF__Identity_Information__c> identity = new List<TF4SF__Identity_Information__c>();
	public List<String> IdenList = new List<String>();
	public List<ApplicationWrapper> appWrapper{get; set;}
	public boolean displayPopup {get; set;}
	public String CustomerId {get; set;}
	public List<Object> Accounts {get; set;}
	public String ExistingAccount_Id {get; set;}
	public String Account_id {get; set;} 
	
	// Constructor
	public Search_Member() {
		//imageURL='/servlet/servlet.FileDownload?file=';
		//List< document > documentList = [SELECT Name FROM Document WHERE Name = 'Golden One Logo'];
		// fetching Search limitation from Service Configuration custom settings
		//if (Service_Configuration__c.getOrgDefaults().Search_Member_Limit__c != null) {
		//    maxSearchResults = Integer.valueOf(Service_Configuration__c.getOrgDefaults().Search_Member_Limit__c);
		//} else {
			maxSearchResults = 100;
		//}
		
		//if (Service_Configuration__c.getOrgDefaults().Search_Member_Result_Per_Page__c != null) {
		//    recordsPerPage = Integer.valueOf(Service_Configuration__c.getOrgDefaults().Search_Member_Result_Per_Page__c);
		//} else {
			recordsPerPage = 25;
		//}

		//if (documentList.size() > 0) { imageURL=imageURL+documentList[0].id; }
	}

	public void closePopup() {
		displayPopup = false;
	}

	public void showPopup() {
		displayPopup = true;
	}

	public Pagereference SearchResults() {
		Pagereference p = null;
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String url ='';
		String header = '';
		String responseJson = '';

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
		url += 'api/cache/customers/?federalid=' + SSNQuery + '&fullaccounts=true';
		//String header = 'Token c1cb7333444e8a890882fd459c945692c9f4a47f'; 
		req.setEndpoint(url);
		req.setHeader('authorization', header);
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
		List<TF4SF__Customer_Account__c> customerAccList = new List<TF4SF__Customer_Account__c>();
		Set<String> customerList = new Set<String>();
		List<TF4SF__Existing_Account__c> existingAccountList = new List<TF4SF__Existing_Account__c>();
		//****************************************DUMMY RESPONSE****************************************
		//responseJson = '[{"success":true,"value":[{"cached_timestamp":"2017-11-24T00:00:00","id":"386975","type":"PERSON","registration_date":"2013-12-10","first_name":"TEST","middle_name":"ACCOUNT","last_name":"APPLE","suffix":null,"birth_date":"1950-01-01","federal_id":"888111111","member_id":"156520","married":false,"spouse_id":null,"immigration_status":"US Citizen","country_of_citizenship":"USA","fico_score":null,"fico_score_date":null,"financial_institution_relationships":["CUST"],"last_contact_date":"2015-08-12","last_detail_update_date":null,"passphrase":null,"primary_email_address":"safaribrowsertest@me.com","email_addresses":["safaribrowsertest@me.com"],"primary_phone_number":null,"phone_numbers":["4088051677"],"primary_occupancy_address":{"address_lines":["2805 BOWERS AVE"],"township":"SANTA CLARA","state_code":"CA","country_code":"USA","zip_code":"95051"},"occupancy_addresses":[{"address_lines":["2805 BOWERS AVE"],"township":"SANTA CLARA","state_code":"CA","country_code":"USA","zip_code":"95051"}],"statement_delivery_method":"EMAIL","identification_documents":[{"type":"Unexpired Drivers License","id":"A1234567","state_code":"CA","country_code":"USA","expiration_date":"2016-01-01","issue_date":"2010-01-01"}],"accounts":[{"relationship":"Tax Reported Owner             ","id":"44151356","account":{"cached_timestamp":"2017-11-24T20:00:05","id":"44151356","opened_date":"2013-12-10","status":"IACT ","type":"CK   _CK01 ","name":"Organic                        ","balance":0.0,"available_balance":0.0,"average_balance_month_to_date":0.0,"average_balance_year_to_date":null,"unpaid_accrued_interest":null,"statement_delivery_method":"EMAIL","monthly_payment":null,"interest_rate":0.0,"term":null,"next_payment_due_date":null,"credit_limit":null,"available_credit":null,"courtesy_pay":false,"escrow_balance":null,"escrow_payment":null,"maturity_date":null,"purchase":null,"customers":[{"id":"386975","relationship":"Tax Reported Owner             ","first_name":"TEST","middle_name":"ACCOUNT","last_name":"APPLE","suffix":null}],"flags":["PERN","NOTE","BAI2","EMP","VADD"]}},{"relationship":"Tax Reported Owner             ","id":"44151390","account":{"cached_timestamp":"2017-11-24T20:00:05","id":"44151390","opened_date":"2013-12-10","status":"IACT ","type":"SAV  _SA01 ","name":"Smart                          ","balance":0.0,"available_balance":0.0,"average_balance_month_to_date":0.0,"average_balance_year_to_date":null,"unpaid_accrued_interest":0.0,"statement_delivery_method":"EMAIL","monthly_payment":null,"interest_rate":0.05,"term":null,"next_payment_due_date":null,"credit_limit":null,"available_credit":null,"courtesy_pay":false,"escrow_balance":null,"escrow_payment":null,"maturity_date":null,"purchase":null,"customers":[{"id":"386975","relationship":"Tax Reported Owner             ","first_name":"TEST","middle_name":"ACCOUNT","last_name":"APPLE","suffix":null}],"flags":[]}}],"flags":[]}],"error_type":null,"error_message":null}]';
		//System.debug('responseJson dummy: '+responseJson);
		//****************************************DUMMY RESPONSE****************************************
		List<Object> a = (List<Object>)JSON.deserializeUntyped(responseJson);
		System.debug('the response is ' + a[0]);
		Map<String, Object> m = (Map<String, Object>)a[0];
		System.debug('the response is ' + m.get('value'));
		List<Object> k = (List<Object>)m.get('value');

		if (k.size() > 0) {
			for (Object u : k) {
				Map<String, Object> l = (Map<String, Object>)u;
				CustomerId = String.valueOf(l.get('id'));
				Accounts = (List<Object>)l.get('accounts');
				System.debug('the accounts list is ' + Accounts);

				for (Object q : Accounts) {
					Map<String, Object> w = (Map<String, Object>)q;
					Account_id = String.valueOf(w.get('id'));
					Map<String, Object> h = (Map<String, Object>)w.get('account');
					List<Object> e = (List<Object>)h.get('customers');
					System.debug('the Customers is ' + e);

					for (Object g : e) {
						Map<String, Object> j = (Map<String, Object>)g;
						System.debug('the customer id is ' + j.get('id'));
						System.debug('the customer relationship is ' + j.get('relationship'));
						System.debug('the customer first_name is ' + j.get('first_name'));
						System.debug('the customer middle_name is ' + j.get('middle_name'));
						System.debug('the customer last_name is ' + j.get('last_name'));
						System.debug('the customer suffix is ' + j.get('suffix'));
						customerList.add(String.valueOf(j.get('id')));
					}

					List<String> e1 = String.valueOf((List<Object>)h.get('flags')).split(',');
					flagList = new List<String>();
					System.debug('the flags is ' + e1);

					for (String g1 : e1) {
						flagList.add(g1); 
						System.debug('the flag is ' + g1.replace('(', '').replace(')', '')); 
					}

					if (Account_id != null) {
						List<TF4SF__Existing_Account__c> oldExistingAccountList = [SELECT Id, TF4SF__Account_Number__c FROM TF4SF__Existing_Account__c WHERE TF4SF__Account_Number__c = :Account_id LIMIT 1];

						if (oldExistingAccountList.size() > 0) {
							ExistingAccount_Id = Account_id;
						} else {
							TF4SF__Existing_Account__c existAcc = new TF4SF__Existing_Account__c();
							existAcc.TF4SF__Account_Number__c = Account_id;
							existingAccountList.add(existAcc);      
						}
					}
				}
			}

			if (existingAccountList.size() > 0) { insert existingAccountList; }
			TF4SF__Customer__c customer;
			List<String> allCustomerList = new List<String>();
			List<TF4SF__Customer__c> insertCustomerList = new List<TF4SF__Customer__c>();
			allCustomerList.addAll(customerList);

			if (allCustomerList.size() > 0) {
				List<TF4SF__Customer__c> exitingCustomerList = [SELECT Id, TF4SF__Person_Identifier__c FROM TF4SF__Customer__c WHERE TF4SF__Person_Identifier__c IN :allCustomerList];
				if (exitingCustomerList.size() > 0) {
				} else {
					for (String custId : allCustomerList) {
						customer = new TF4SF__Customer__c();
						customer.TF4SF__Person_Identifier__c = custId;  
						insertCustomerList.add(customer);
					}
				}

				insert insertCustomerList;
			}

			for (TF4SF__Customer__c custList : insertCustomerList) {
				for (TF4SF__Existing_Account__c extacc : existingAccountList) {
					TF4SF__Customer_Account__c customerAcc = new TF4SF__Customer_Account__c();
					customerAcc.TF4SF__Account_Number__c = extacc.TF4SF__Account_Number__c;
					customerAcc.TF4SF__Existing_Account__c = extacc.Id;
					customerAcc.TF4SF__Person_Identifier__c = custList.TF4SF__Person_Identifier__c;
					customerAcc.TF4SF__Customer__c = custList.Id;
					customerAccList.add(customerAcc);
				}
			}

			if (customerAccList.size() > 0) { insert customerAccList; }
			if(String.isNotBlank(CustomerId)) {
				Customer_Id = [SELECT Id, TF4SF__Person_Identifier__c FROM TF4SF__Customer__c WHERE TF4SF__Person_Identifier__c = :CustomerId].Id;
				p = new PageReference('/' + Customer_Id);
				p.setRedirect(true);

				return p;
			}
		}
		else {
			apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Sorry, We cannot find a customer with the SSN you have entered'));
		}
		return null;
	}

	public PageReference startApplication() {
		Pagereference p = null;
		String usr = UserInfo.getUserId();
		User u = [SELECT Id, Email, TF4SF__Location__c, TF4SF__Channel__c, Active_Directory_Id__c, Teller_Id__c FROM User WHERE Id = :usr];

		TF4SF__Application__c app = new TF4SF__Application__c ();
		TF4SF__Application2__c app2 = new TF4SF__Application2__c ();
		TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
		TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
		TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
		TF4SF__Application_Activity__c appact = new TF4SF__Application_Activity__c();

		app.TF4SF__Created_Person__c = u.Id;
		app.Ownerid = u.Id;
		app.TF4SF__Created_Branch_Name__c  = u.TF4SF__Location__c;
		app.TF4SF__Created_Channel__c = u.TF4SF__Channel__c;
		app.TF4SF__Created_User_Email_Address__c = u.Email;
		app.TF4SF__Custom_Text1__c = u.Teller_Id__c;
		app.TF4SF__Custom_Text2__c = u.Active_Directory_Id__c;
		// Updating the current user/type/channel information
		app.TF4SF__Current_Person__c = u.Id;
		app.TF4SF__Current_Branch_Name__c = u.TF4SF__Location__c;
		app.TF4SF__Current_Channel__c = u.TF4SF__Channel__c;
		app.TF4SF__Current_User_Email_Address__c = u.Email;
		app.TF4SF__Custom_Text3__c = u.Teller_Id__c;
		app.TF4SF__Custom_Text4__c = u.Active_Directory_Id__c;
		app.TF4SF__Current_Timestamp__c = System.now();
		app.TF4SF__Created_Timestamp__c = System.now(); 
		app.TF4SF__Application_Page__c = 'GetStartedPage';

		if (TF4SF__Application__c.SObjectType.getDescribe().isCreateable()) { insert app; }
		app2.TF4SF__Application__c= app.Id;
		emp.TF4SF__Application__c= app.Id;
		iden.TF4SF__Application__c= app.Id;
		acc.TF4SF__Application__c= app.Id;

		appact.TF4SF__Application__c= app.Id;
		appact.TF4SF__Action__c = 'Created the Application';
		appact.TF4SF__Activity_Time__c = System.now();

		if (TF4SF__Application2__c.SObjectType.getDescribe().isCreateable()) { insert app2; }
		if (TF4SF__Employment_Information__c.SObjectType.getDescribe().isCreateable()) { insert emp; }
		if (TF4SF__Identity_Information__c.SObjectType.getDescribe().isCreateable()) { insert iden; }
		if (TF4SF__About_Account__c.SObjectType.getDescribe().isCreateable()) { insert acc; }
		if (TF4SF__Application_Activity__c.SObjectType.getDescribe().isCreateable()) { insert appact; }
		String appId = app.Id;

		if (appId != null) {
			System.debug('appID = ' + appId);
			app = [SELECT Id, TF4SF__User_Token__c FROM TF4SF__Application__c WHERE Id = :appId];
			StartApplication.setAppToken(app);
			update app;
			String userToken = StartApplication.decrypt(app.TF4SF__User_Token__c);
			
			Cookie id = ApexPages.currentPage().getCookies().get('id');
			Cookie ut = ApexPages.currentPage().getCookies().get('ut');
			id = new Cookie('id', appId, null, -1, true);
			ut = new Cookie('ut', userToken, null, -1, true);
			System.debug('ut:' + ut);
			System.debug('userToken:' + userToken);
			System.debug('User_Token__c:' + app.TF4SF__User_Token__c);

			// Set the new cookie for the page
			ApexPages.currentPage().setCookies(new Cookie[]{id,ut});
			p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'TF4SF__OfflinePage?id=' + appId);
			p.setRedirect(true);
		}

		return p;
	}
	
	// Method executed when "Search" button om the SearchMember page is clicked
	public void executeAppSearch() {
		try {
			applications = new List<TF4SF__Application__c>();
			IdenList = new List<String>();
			// Trimming all the variable to get rid of empty spaces
			System.debug('appssnLast4Query in executeAppSearch= ' + appssnLast4Query);
			//appfirstnameQuery = appfirstnameQuery.trim();
			// applastnameQuery = applastnameQuery.trim();
			// appssnLast4Query = appssnLast4Query.trim();
			// appEmailQuery = appEmailQuery.trim();
			// ApplicationQuery = ApplicationQuery.trim();
			// appMemberQuery = appMemberQuery.trim();

			System.debug('the First_Name__c is ' + appfirstnameQuery);
			System.debug('the Last_Name__c is ' + applastnameQuery);
			System.debug('the ssnlast4 is ' + appssnLast4Query);
			System.debug('the email is ' + appEmailQuery);
			System.debug('the App Number is ' + ApplicationQuery);
			System.debug('the Member Number is ' + appMemberQuery);

			System.debug('the fromDate ' + FromDate);
			System.debug('the ToDate ' + ToDate);
			System.debug('the Date ' + dat);
			date fromDay = date.parse(FromDate);
			date toDay = date.parse(ToDate);
			System.debug('the fromDate ' + fromDay);
			System.debug('the toDate ' + toDay);
			if (FromDate == ToDate) { Date sameDay = date.parse(ToDate); }

			//List<TF4SF__Application__c> app = [SELECT Id, TF4SF__Created_TimeStamp__c, LastModifiedDate FROM TF4SF__Application__c WHERE TF4SF__Created_Timestamp__c >: fromDay AND TF4SF__Created_Timestamp__c <: toDay ORDER BY LastModifiedDate];
			// for query optimization wirting quesries based on the information provided by the User
			if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query == '' && appEmailQuery == '') {
				ShowApplicantNo = true;
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE (((TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Last_Name__c = :applastnameQuery) OR (TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Last_Name_J__c = :applastnameQuery) OR (TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Last_Name_J2__c = :applastnameQuery)) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER BY LastModifiedDate LIMIT :maxSearchResults];
			} else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query == '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE (((TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER BY LastModifiedDate LIMIT :maxSearchResults];
			} else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query !='' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, App_Number__c, TF4SF__Number_of_Products__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c,  TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query !='' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, App_Number__c, TF4SF__Number_of_Products__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c,  TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery != ''&& appssnLast4Query !='' && applastnameQuery=='' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >=: fromDay AND TF4SF__Application__r.CreatedDate__c <=: toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery != ''&& appssnLast4Query !='' && applastnameQuery=='' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (applastnameQuery != ''&& appssnLast4Query !='' && appfirstnameQuery=='' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (applastnameQuery != ''&& appssnLast4Query !='' && appfirstnameQuery=='' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery != '' && applastnameQuery == '' && appssnLast4Query == '' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
					System.debug('the cretedDate is '+applications[0].CreatedDate__c);
			} else if (appfirstnameQuery != '' && applastnameQuery == '' && appssnLast4Query == '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery != '' && appssnLast4Query == '' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery != '' && appssnLast4Query == '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query != '' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query != '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query == '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query == '' && appEmailQuery == '' && appMemberQuery == '' && ApplicationQuery == '') {
				ShowApplicantNo = false;
			} else {
				ShowApplicantNo = false;
			}

			//accDetails = new List<Product__c>(); 
			Set<Id> personIdSet = new Set<Id>();

			if (appMemberQuery != '') {
				ShowappMemberNo = true;
				//accDetails = [SELECT Id,Name,Product_type__c, (SELECT Id, Name FROM Applications__r)
				//                FROM Product__c 
				//                WHERE Name = :appMemberQuery AND Product_type__c = 'Membership' LIMIT :maxSearchResults];
				
				//for (Product__c p : accDetails) {
				//    List<TF4SF__Application__c> ppList = p.Applications__r;
				//    System.debug('the pplist is '+ppList[0].Id);
				//    for (TF4SF__Application__c pp: ppList) {
				//        String personId = pp.Id;
				//        personIdSet.add(personId);
				//    }
				//}

				if (personIdSet.size() > 0) {
					applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
									FROM TF4SF__Application__c WHERE Id IN :personIdSet AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay) ORDER BY LastModifiedDate];
				} else {
					ShowappMemberNo = false;
				}

			} else if (appMemberQuery != '' && ApplicationQuery != '') {
				ShowappMemberNo = true;

				if (personIdSet.size() > 0) {
					applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
									FROM TF4SF__Application__c WHERE Id IN :personIdSet AND App_Number__c = :ApplicationQuery AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay) ORDER BY LastModifiedDate];
				} else {
					ShowappMemberNo = false;
				}
			} else {
				ShowappMemberNo = false;
			}

			if (ApplicationQuery != '') {
				ShowappMemberNo = true;
				applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
								FROM TF4SF__Application__c WHERE ((App_Number__c = :ApplicationQuery OR TF4SF__External_App_ID__c = :ApplicationQuery) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER BY LastModifiedDate LIMIT :maxSearchResults];
			}

			if (applications == null || applications.size() == 0) {
				appsearchMsg = true;
				assc = null;
				// ShowStartApplication = true;
			} else {
				appsearchMsg = false;
				// ShowStartApplication = false; 
				// Adding StandardSetController to paginate the search results
				assc = new ApexPages.StandardSetController(applications);
				assc.setPageSize(recordsPerPage);
			}
		} catch (Exception e) {
			System.debug('An error was encountered in the Execute method under SearchMember class ' + e);
		} 
	}
	
	public List<TF4SF__Application__c> getApplicationDetails() {
		return applications;
	}

	// New method to enable pagination on the MemberSearch page
	public List<TF4SF__Application__c> getApplicationList() {
		if (assc != null) {
			return (List<TF4SF__Application__c>)assc.getRecords();
		} else {
			return null;    
		}
	}
	
	public List<ApplicationWrapper> getappWrapperList() {
		appWrapper = new List<ApplicationWrapper>();
		//List<TF4SF__Application__c> appList = new List<TF4SF__Application__c>();

		if (assc != null) {
			Integer currentPageNumber = assc.getPageNumber();
			if (currentPageNumber != null) { appcounter = (assc.getPageSize()) * (currentPageNumber - 1); }
			
			for (TF4SF__Application__c a : (List<TF4SF__Application__c>)assc.getRecords()) {
				if (a.TF4SF__Number_of_Products__c != NULL) {
					Boolean hasMultipleProducts = false;
					appcounter++;

					for (Integer m = 1; m <= a.TF4SF__Number_of_Products__c; m++) {
						System.debug('the product no is ' + m);
						if (m == 1) {
							appWrapper.add(new ApplicationWrapper(a, a.TF4SF__Sub_Product__c, a.TF4SF__Primary_Product_Status__c, appcounter));
						} 

						if (m == 2) {
							appWrapper.add(new ApplicationWrapper(a, a.TF4SF__Primary_Offer__c, a.TF4SF__Primary_Offer_Status__c, null));
						} 

						if (m == 3) {
							appWrapper.add(new ApplicationWrapper(a, a.TF4SF__Second_Offer__c, a.TF4SF__Second_Offer_Status__c, null));
						}

						if (m == 4) {
							appWrapper.add(new ApplicationWrapper(a, a.TF4SF__Third_Offer__c, a.TF4SF__Third_Offer_Status__c, null));
						} 
					}
				}
			}
		}

		return appWrapper;
	}

	class ApplicationWrapper {
		public Integer count {get; set;}
		public String productName {get; set;}
		public String decision {get;set;}
		public TF4SF__Application__c app {get; set;}

		public ApplicationWrapper(TF4SF__Application__c a, String productName, String decision, Integer c) {
			this.count = c;
			this.productName = productName;
			this.decision = decision;
			this.app = a;
		}
	}

	public void appfirstPage() {
		assc.first();
	}

	public void apppreviousPage() {
		assc.previous();
	}

	public void appnextPage() {
		assc.next();
	}

	public void applastPage() {
		assc.last();
	}

	public Boolean getapphasPrevious() {
		if (assc != null) {
			return assc.getHasPrevious();
		} else {
			return false;
		}
		
	}

	public Boolean getapphasNext() {
		if (assc != null) {
			return assc.getHasNext();
		} else {
			return false;
		}
		
	}

	public Integer getappPageNumber(){
		if (assc != null) {
			return assc.getPageNumber();
		} else {
			return null;
		}
	}

	public Integer getappTotalPages(){
		if (assc != null) {
			Decimal apptotalSize = assc.getResultSize();
			Decimal apppageSize = assc.getPageSize();
			Decimal apppages = apptotalSize/apppageSize;
			
			return (Integer)apppages.round(System.RoundingMode.CEILING);
		} else {
			return null;
		}
	}

	public Integer getappTotalResults() {
		if (assc != null) {
			return assc.getResultSize();    
		} else {
			return null;
		}
	}
	
	public void clearAll() {
		SSNQuery = '';
		searchMsg = false;
		searchMsgDetails = false;
		ShowStartApplication = false;
	}
	
	//Method to return all the account details records based on user input

	public void appclearAll() {
		appfirstnameQuery = '';
		applastnameQuery = '';
		appssnLast4Query = '';
		appMemberQuery = '';
		ApplicationQuery = '';
		appEmailQuery = '';
		applications.clear();
		appsearchMsg = false;
	}
} //End Class