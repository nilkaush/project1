public with sharing class StartOfferExtension {
	
	public String Code { get; set; }
	public String ipaddress;
	public String version;
	public String nameSpace { get; set; }
	public String promoCode { get; set; }
	public User loggedInUser { get; set; }
	public String userId { get; set; }
	public TF4SF__Application_Configuration__c appConfig = TF4SF__Application_Configuration__c.getOrgDefaults();

	public StartOfferExtension() {
		this.Code = ApexPages.currentPage().getParameters().get('Code');
		System.debug('The product code is ##### ' + Code);
		this.ipaddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
		System.debug('The Ip Address is ##### ' + ipaddress);
		this.nameSpace = (String.isEmpty(appConfig.TF4SF__Namespace__c)) ? '' : appConfig.TF4SF__Namespace__c;
		this.promoCode = ApexPages.currentPage().getParameters().get('PromoCode');
		System.debug('The Promo Code is ## ' + promoCode);
		userId = UserInfo.getUserId();
		loggedInUser = [SELECT Id, TF4SF__Channel__c, Name, Email, TF4SF__Location__c, Profile.Name FROM User WHERE Id = :userId];
	}

	public PageReference beginApp() {
		try {
			TF4SF__Application__c app = new TF4SF__Application__c();
			TF4SF__Application2__c app2 = new TF4SF__Application2__c();
			TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
			TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
			TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
			TF4SF__Application_Activity__c appAct = new TF4SF__Application_Activity__c();
			app = setAppValues(app, Code, ipaddress, loggedInUser, promoCode);
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Application_Version__c.isCreateable()) {
			  app.TF4SF__Application_Version__c = (version == null) ? appConfig.TF4SF__Application_Version__c : version;
			}

			if (TF4SF__Application__c.SObjectType.getDescribe().isCreateable()) { insert app; }
			if (Schema.sObjectType.TF4SF__Application2__c.fields.TF4SF__Application__c.isCreateable()) { app2.TF4SF__Application__c = app.Id; }
			if (Schema.sObjectType.TF4SF__Employment_Information__c.fields.TF4SF__Application__c.isCreateable()) { emp.TF4SF__Application__c = app.Id; }
			if (Schema.sObjectType.TF4SF__Identity_Information__c.fields.TF4SF__Application__c.isCreateable()) { iden.TF4SF__Application__c = app.Id; }
			if (Schema.sObjectType.TF4SF__About_Account__c.fields.TF4SF__Application__c.isCreateable()) { acc.TF4SF__Application__c = app.Id; }
			if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Application__c.isCreateable()) { appact.TF4SF__Application__c = app.Id; }
			if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Channel__c.isCreateable()) { appact.TF4SF__Channel__c = app.TF4SF__Current_Channel__c; }
			if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Name__c.isCreateable()) { appact.TF4SF__Name__c = app.TF4SF__Current_Person__c; }
			if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Action__c.isCreateable()) { appact.TF4SF__Action__c = 'Created the Application'; }
			if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Activity_Time__c.isCreateable()) { appact.TF4SF__Activity_Time__c = System.now(); }
			if (TF4SF__Application2__c.SObjectType.getDescribe().isCreateable()) { insert app2; }
			if (TF4SF__Employment_Information__c.SObjectType.getDescribe().isCreateable()) { insert emp; }
			if (TF4SF__Identity_Information__c.SObjectType.getDescribe().isCreateable()) { insert iden; }
			if (TF4SF__About_Account__c.SObjectType.getDescribe().isCreateable()) { insert acc; }
			if (TF4SF__Application_Activity__c.SObjectType.getDescribe().isCreateable()) { insert appact; }

			String userToken = SearchMemberResults.decrypt(app.TF4SF__User_Token__c);
			String dspUrl = nameSpace + 'dsp';
			PageReference p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + dspUrl);
			Cookie id = ApexPages.currentPage().getCookies().get('id');
			Cookie ut = ApexPages.currentPage().getCookies().get('ut');
			id = new Cookie('id', app.Id, null, -1, true);
			ut = new Cookie('ut', userToken, null, -1, true);

			// Set the new cookie for the page
			ApexPages.currentPage().setCookies(new Cookie[]{id, ut});
			p.setRedirect(false);
			return p;        
		} catch (Exception e) {
			system.debug('Error while begining the application');
			return null;
		}
	}

	public static TF4SF__Application__c setAppValues(TF4SF__Application__c app, String subProductCode, String ipaddress, User appUser, String promoCode) {
		// Instantiating the custom settings for the product codes
		TF4SF__Product_Codes__c pc = new TF4SF__Product_Codes__c();
		TF4SF__Application_Configuration__c appConfig = TF4SF__Application_Configuration__c.getOrgDefaults();
		pc = (subProductCode == null) ? null : TF4SF__Product_Codes__c.getValues(subProductCode);

		if (pc != null) {
			System.debug('LandingPageController - setAppValues() - pc: ' + pc);
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Product__c.isCreateable()) { app.TF4SF__Product__c = pc.TF4SF__Product__c; }
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Sub_Product__c.isCreateable()) { app.TF4SF__Sub_Product__c = pc.TF4SF__Sub_Product__c; }
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Theme_URL__c.isCreateable()) { app.TF4SF__Theme_URL__c = pc.TF4SF__Product_Theme__c; }
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Sub_Product_Description__c.isCreateable()) { app.TF4SF__Sub_Product_Description__c = pc.TF4SF__Description__c; }
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The product Code is Invalid'));
		}

		SearchMemberResults.setAppToken(app);

		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Created_Channel__c.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Channel__c.isCreateable()) {
			if (app.TF4SF__Person_Number__c != null) {
				app.TF4SF__Created_Channel__c = 'Online Banking';
				app.TF4SF__Current_Channel__c = 'Online Banking';
			} else {
				if (appUser.TF4SF__Channel__c == 'Branch') {
					app.TF4SF__Created_Channel__c = 'Branch';
					app.TF4SF__Current_Channel__c = 'Branch';
				} else if (appUser.TF4SF__Channel__c == 'Call Center') {
					app.TF4SF__Created_Channel__c = 'Call Center';
					app.TF4SF__Current_Channel__c = 'Call Center';
				} else if (appUser.TF4SF__Channel__c == 'Online') {
					app.TF4SF__Created_Channel__c = 'Online';
					app.TF4SF__Current_Channel__c = 'Online';
				} else {
					if (appUser.TF4SF__Channel__c != null) {
						app.TF4SF__Created_Channel__c = appUser.TF4SF__Channel__c;
						app.TF4SF__Current_Channel__c = appUser.TF4SF__Channel__c;
					}
				}
			}
		}

		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__IP_Address__c.isCreateable()) { app.TF4SF__IP_Address__c = ipaddress; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Created_timestamp__c.isCreateable()) { app.TF4SF__Created_timestamp__c = System.now(); }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_timestamp__c.isCreateable()) { app.TF4SF__Current_timestamp__c = System.now(); }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Application_Page__c.isCreateable()) { app.TF4SF__Application_Page__c = 'GetStartedPage'; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Application_Status__c.isCreateable()) { app.TF4SF__Application_Status__c = 'Open'; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Created_Branch_Name__c.isCreateable()) { app.TF4SF__Created_Branch_Name__c = appUser.TF4SF__Location__c; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Created_User_Email_Address__c.isCreateable()) { app.TF4SF__Created_User_Email_Address__c = appUser.Email; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Created_Person__c.isCreateable()) { app.TF4SF__Created_Person__c = appUser.Id; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Branch_Name__c.isCreateable()) { app.TF4SF__Current_Branch_Name__c = appUser.TF4SF__Location__c; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Created_User_Email_Address__c.isCreateable()) { app.TF4SF__Created_User_Email_Address__c = appUser.Email; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Person__c.isCreateable()) { app.TF4SF__Current_Person__c = appUser.Id; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Promo_Code__c.isCreateable()) { app.TF4SF__Promo_Code__c = promoCode; }

		//what to do about Type_of_Treasury__c??
		// To update type of BusinessChecking product selected
		if (app.TF4SF__Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('Business').TF4SF__Product_Name__c)) {
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('BusinessChecking').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Checking__c.isCreateable()) { app.TF4SF__Type_Of_Business_Checking__c = app.TF4SF__Sub_Product__c; }
			}

			// To update Type of BusinessSavings Product selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('BusinessSavings').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Savings__c.isCreateable()) { app.TF4SF__Type_Of_Business_Savings__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of BusinessCDs product selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('BusinessCDs').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_CDs__c.isCreateable()) { app.TF4SF__Type_Of_Business_CDs__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of BusinessCreditCards selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('BusinessCreditCards').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Credit_Cards__c.isCreateable()) { app.TF4SF__Type_Of_Business_Credit_Cards__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of BusinessLoans selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('BusinessLoans').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Loans__c.isCreateable()) { app.TF4SF__Type_Of_Business_Loans__c = app.TF4SF__Sub_Product__c; }
			}
		} else {
			// to update type of Checking Product Selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('Checking').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Checking__c.isCreateable()) { app.TF4SF__Type_of_Checking__c = app.TF4SF__Sub_Product__c; }
			}

			// To update Type of Savings Product selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('Savings').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Savings__c.isCreateable()) { app.TF4SF__Type_of_Savings__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of Certificates product selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('Certificates').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Certificates__c.isCreateable()) { app.TF4SF__Type_of_Certificates__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of Credit Cards selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('CreditCards').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Credit_Cards__c.isCreateable()) { app.TF4SF__Type_of_Credit_Cards__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of Vehicle Loans selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('VehicleLoans').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Vehicle_Loans__c.isCreateable()) { app.TF4SF__Type_of_Vehicle_Loans__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of Personal Loan selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('PersonalLoans').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Personal_Loans__c.isCreateable()) { app.TF4SF__Type_of_Personal_Loans__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of Mortgage Loan product selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('HomeLoan').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Mortgage_Loan__c.isCreateable()) { app.TF4SF__Type_of_Mortgage_Loan__c = app.TF4SF__Sub_Product__c; }
			}

			// To update type of Home Equity product selected
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('HomeEquity').TF4SF__Product_Name__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Home_Equity__c.isCreateable()) { app.TF4SF__Type_Of_Home_Equity__c = app.TF4SF__Sub_Product__c; }
			}
		}

		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Number_of_Products__c.isCreateable()) { app.TF4SF__Number_of_Products__c = 1; }
		return app;
	}
}