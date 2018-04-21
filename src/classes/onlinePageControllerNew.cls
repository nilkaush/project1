@RestResource(urlMapping='/onlinePageNew/*')
global with sharing class onlinePageControllerNew {
	/*********************************online page for get started*******************************/ 
	public List<TF4SF__Product_Codes__c> productlist1 {get; set;}
	public Set<String> prdNameSet1{get; set;}
	public Map<String,List<TF4SF__Product_Codes__c>> prdMap1{get; set;}
	public String ipaddress1{get; set;}
	public String userAgent1{get; set;}
	/*******************************/

	public String startApplicationId{get; set;}
	public boolean boolValStartApp{get; set;}
	public String appid;
	public List<TF4SF__Product_Codes__c> productlist {get; set;}
	public Set<String> prdNameSet{get; set;}
	public Map<String,List<TF4SF__Product_Codes__c>> prdMap{get; set;}
	public User loggedInUser{get; set;}   
	public String xmlString;
	public transient Dom.Document xmlData;
	public Dom.XMLNode address;
	public TF4SF__Application__c app = new TF4SF__Application__c ();
	public TF4SF__Application2__c app2 = new TF4SF__Application2__c ();
	public TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
	public TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
	public TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
	public TF4SF__Application_Activity__c appact = new TF4SF__Application_Activity__c();
	public String ipaddress{get; set;}
	public String userAgent{get; set;}

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	public onlinePageControllerNew() {
		appId=ApexPages.currentPage().getParameters().get('id');
		startApplicationId = ApexPages.currentPage().getParameters().get('flag');
		System.debug('=====startApplicationId====: ' + startApplicationId);
		if (startApplicationId != null && startApplicationId != '') { boolValStartApp = boolean.valueOf(startApplicationId); }
		System.debug('=====boolValStartApp====: ' + boolValStartApp);
		
		String userId = UserInfo.getUserId();
		loggedInUser = [SELECT Id, TF4SF__Channel__c, Name, Email, TF4SF__Location__c, Profile.Name FROM User WHERE Id = :userId];
		ipaddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
		userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');

		if (appId != null) {
			app = [SELECT Id, TF4SF__Created_Channel__c, TF4SF__Current_Channel__c, TF4SF__Created_timestamp__c, TF4SF__Created_Branch_Name__c, TF4SF__Created_User_Email_Address__c, TF4SF__Created_Person__c, TF4SF__Current_timestamp__c, TF4SF__Current_Branch_Name__c, TF4SF__Current_Person__c, TF4SF__Application_Page__c, TF4SF__Product__c, TF4SF__Sub_Product__c, TF4SF__Type_of_Checking__c, TF4SF__Type_Of_Business_CDs__c, TF4SF__Type_Of_Business_Credit_Cards__c, TF4SF__Type_Of_Business_Checking__c, TF4SF__Type_Of_Business_Loans__c, TF4SF__Type_Of_Business_Savings__c, TF4SF__Type_of_Certificates__c, TF4SF__Type_of_Credit_Cards__c, TF4SF__Type_Of_Home_Equity__c, TF4SF__Type_of_Investments__c, TF4SF__Type_of_Mortgage_Loan__c, TF4SF__Type_of_Mortgage_Short_Application__c, TF4SF__Type_of_Personal_Loans__c, TF4SF__Type_of_Savings__c, TF4SF__Type_of_Vehicle_Loans__c FROM TF4SF__Application__c WHERE Id = :appId];
		} 
		//Fetching the XML code
		/*this.xmlString = ApexPages.currentPage().getParameters().get('xmldata');
		this.xmlData = new DOM.Document();
		System.debug('xmlData is:' + this.xmlString);
		if (this.xmlString != null) {
			this.xmlData.load(this.xmlString);
		}   */

		//Nithin
		prdNameSet = new Set<String>();
		prdMap = new Map<String,List<TF4SF__Product_Codes__c>>();
		ipaddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
		userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
		productlist = TF4SF__Product_Codes__c.getAll().values();
		for (TF4SF__Product_Codes__c pcname : productlist) { prdNameSet.add(pcname.TF4SF__Product__c); }
		System.debug('the product name is : ' + prdNameSet);
		System.debug('The Map size is ' + prdNameSet.size());

		for (String prdName : prdNameSet) {
			List<TF4SF__Product_Codes__c> pcList = new List<TF4SF__Product_Codes__c>();
			pcList = [SELECT Id, Name, TF4SF__Product__c, TF4SF__Sub_Product__c FROM TF4SF__Product_Codes__c WHERE TF4SF__Product__c = :prdName ORDER BY TF4SF__Sub_Product__c ASC];
			prdMap.put(prdName,pcList);
			System.debug('the map is : ' + pcList.size());
		}

		//Nithin
		System.debug('prdMap the map is : ' + prdMap);
		System.debug('prdMap the map is : ' + prdMap.values());
		/**********************************************code for online page redirecting to get-started apge***************************************************************/

		prdNameSet1 = new Set<String>();
		prdMap1 = new Map<String,List<TF4SF__Product_Codes__c>>();
		ipaddress1 = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
		userAgent1 = ApexPages.currentPage().getHeaders().get('USER-AGENT');
		productlist1 = TF4SF__Product_Codes__c.getAll().values();

		for (TF4SF__Product_Codes__c pcname : productlist1) { prdNameSet1.add(pcname.TF4SF__Product__c); } 
		System.debug('the product name is : ' + prdNameSet1);
		System.debug('The Map size is ' + prdNameSet1.size());

		for (String prdName : prdNameSet1) {
			List<TF4SF__Product_Codes__c> pcList = new List<TF4SF__Product_Codes__c>();
			pcList = [SELECT Id, Name, TF4SF__Product__c, TF4SF__Sub_Product__c FROM TF4SF__Product_Codes__c WHERE TF4SF__Product__c = :prdName ORDER BY TF4SF__Sub_Product__c ASC];
			prdMap1.put(prdName,pcList);
			System.debug('the map is : ' + pcList.size());
		}
	}

	@HttpPost
	global static String generateApp(){
		TF4SF__Application__c app = new TF4SF__Application__c ();
		TF4SF__Application2__c app2 = new TF4SF__Application2__c ();
		TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
		TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
		TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
		TF4SF__Application_Activity__c appact = new TF4SF__Application_Activity__c();
		String appRecId = '';

		try {
			RestRequest req = RestContext.request;
			RestResponse res = RestContext.response;
			System.debug('requestBody is ' + req);
			String requestPost = req.requestBody.toString();
			System.debug('body from startApplication = ' + requestPost);
			ApplicationData applicationPrefildata = (ApplicationData)JSON.deserializeStrict(requestPost, ApplicationData.class);

			if (applicationPrefildata != null) {
				//if (xmlString != null) {
				//System.debug('xml exists');
				//address = xmlData.getRootElement();

				// prefilling member information
				if (applicationPrefildata.firstName != null) { app.TF4SF__First_Name__c = applicationPrefildata.firstName; }
				if (applicationPrefildata.middleName != null) { app.TF4SF__Middle_Name__c = applicationPrefildata.middleName; }
				if (applicationPrefildata.lastName != null) { app.TF4SF__Last_Name__c = applicationPrefildata.lastName; }
				if (applicationPrefildata.emailAddress != null) { app.TF4SF__Email_Address__c = applicationPrefildata.emailAddress; }
				if (applicationPrefildata.cellPhoneNumber != null) { app.TF4SF__Primary_Phone_Number__c = applicationPrefildata.cellPhoneNumber; }
				if (applicationPrefildata.idType != null) { iden.TF4SF__ID_Type__c = applicationPrefildata.idType; }

				if (applicationPrefildata.customersID != null) {
					app.TF4SF__Customer__c = applicationPrefildata.customersID;
					//try{Qualified_CrossSell__c qcr = [SELECT Id, Messages__c, Customer__c FROM Qualified_CrossSell__c WHERE Customer__c =: applicationPrefildata.customersID LIMIT 1];
					//app.TF4SF__CL_Product_Comments_Only__c = qcr.Messages__c;}catch(Exception e){System.debug('error while fetching the member crossSell');}
				}

				if (applicationPrefildata.memberNo != null) { app.TF4SF__Person_Number__c = applicationPrefildata.memberNo; }
				
				if (applicationPrefildata.ssn != null) {
					if (applicationPrefildata.ssn.length() == 9) { Iden.TF4SF__SSN_Prime__c = applicationPrefildata.ssn; }
				}

				if (applicationPrefildata.dob != null) { Iden.TF4SF__Date_Of_Birth__c = applicationPrefildata.dob; }
				//updating the Address Information for a customer 
				if (applicationPrefildata.customersStreetAddress1 != null) {
					app.TF4SF__Street_Address_1__c = applicationPrefildata.customersStreetAddress1;
				}

				if (applicationPrefildata.customersStreetAddress2 != null) {
					app.TF4SF__Street_Address_2__c = applicationPrefildata.customersStreetAddress2;
				}

				if (applicationPrefildata.customersCity != null) { app.TF4SF__City__c = applicationPrefildata.customersCity; }
				if (applicationPrefildata.customersState != null) { app.TF4SF__State__c = applicationPrefildata.customersState; }
				if (applicationPrefildata.customersZipCode != null) { app.TF4SF__Zip_Code__c = applicationPrefildata.customersZipCode; }

				// Updating the Created user/type/channel information
				if (applicationPrefildata.createdByUserId != null) {
					app.TF4SF__Created_Person__c = applicationPrefildata.createdByUserId;
					app.Ownerid = applicationPrefildata.createdByUserId;
				}

				if (applicationPrefildata.createdByBranch != null) {
					app.TF4SF__Created_Branch_Name__c  = applicationPrefildata.createdByBranch;
				}

				if (applicationPrefildata.createdByChannel != null) {
					app.TF4SF__Created_Channel__c = applicationPrefildata.createdByChannel;
				}

				if (applicationPrefildata.createdEmailAddress != null) {
					app.TF4SF__Created_User_Email_Address__c = applicationPrefildata.createdEmailAddress;
				}

				// Updating the current user/type/channel information
				if (applicationPrefildata.currentPerson != null) { app.TF4SF__Current_Person__c = applicationPrefildata.currentPerson; }
				if (applicationPrefildata.currentBranch != null) { app.TF4SF__Current_Branch_Name__c = applicationPrefildata.currentBranch; }
				if (applicationPrefildata.currentChannel != null) { app.TF4SF__Current_Channel__c = applicationPrefildata.currentChannel; }
				if (applicationPrefildata.currentEmailAddress != null) {
					app.TF4SF__Current_User_Email_Address__c = applicationPrefildata.currentEmailAddress;
				}

				app.TF4SF__Current_Timestamp__c = System.now();
				app.TF4SF__Created_Timestamp__c = System.now(); 
				app.TF4SF__Application_Page__c = 'CrossSellPage';
				// Inserting Application and other child records
				if (TF4SF__Application__c.SObjectType.getDescribe().isCreateable()) { insert app; }

				app2.TF4SF__Application__c= app.Id;
				emp.TF4SF__Application__c= app.Id;
				iden.TF4SF__Application__c= app.Id;

				//Fix for DL details not showing up in start application from 360 degree view
				if (applicationPrefildata.identificationNumber != null) {
					iden.TF4SF__Identity_Number_Primary__c = applicationPrefildata.identificationNumber;
				} 

				if (applicationPrefildata.idState != null) { iden.TF4SF__State_Issued__c = applicationPrefildata.idState; }
				if (applicationPrefildata.id_ExpirationDate != null) { iden.TF4SF__Expiry_Date__c = applicationPrefildata.id_ExpirationDate; }
				if (applicationPrefildata.id_IssueDate != null) { iden.TF4SF__Issue_Date__c = applicationPrefildata.id_IssueDate; }
				if (applicationPrefildata.countryofCitizenship != null) { iden.TF4SF__Citizenship__c = applicationPrefildata.countryofCitizenship; }

				acc.TF4SF__Application__c= app.Id;
				appact.TF4SF__Name__c = app.OwnerId;
				appact.TF4SF__Branch__c = app.TF4SF__Created_Branch_Name__c;
				appact.TF4SF__Channel__c = app.TF4SF__Created_Channel__c; 
				appact.TF4SF__Application__c= app.Id;
				appact.TF4SF__Action__c = 'Created the Application';
				appact.TF4SF__Activity_Time__c = System.now();

				if (TF4SF__Application2__c.SObjectType.getDescribe().isCreateable()) { insert app2; }
				if (TF4SF__Employment_Information__c.SObjectType.getDescribe().isCreateable()) { insert emp; }
				if (TF4SF__Identity_Information__c.SObjectType.getDescribe().isCreateable()) { insert iden; }
				if (TF4SF__About_Account__c.SObjectType.getDescribe().isCreateable()) { insert acc; }
				if (TF4SF__Application_Activity__c.SObjectType.getDescribe().isCreateable()) { insert appact; }
				appRecId = app.Id;
				//Logger.addMessage('Obtained XML with data in it', System.now().format());
			}
		} catch (Exception e) {
			System.debug('Error in the generateApp method in the OfflinePage class ' + e + ' and the line number is ' + e.getLineNumber()); 
		}

		return appRecId;
	}

	global class ApplicationData {
		global String firstName;
		global String middleName;
		global String lastName;
		global String emailAddress;
		global String cellPhoneNumber;
		global String customersID;
		global String memberNo;
		global String prospectID;
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
		global String dob;
		global String personId;
		global String applicationVersion;
		global String identificationNumber;
		global String idState;
		global String id_ExpirationDate;
		global String id_IssueDate ;
		global String countryofCitizenship ;
		global String idType;
	}

	public PageReference ProSub(){
		System.debug(ApexPages.currentPage().getParameters());
		System.debug('The application id is ##########' + appId);
		PageReference p = null;

		if (appId != null) {
			System.debug('The application id is ' + appId);
			//Logger.inputSource('OfflinePageController - ProSub', appId); 
		}

		app.TF4SF__Application_Page__c = 'CrossSellPage';
		app.TF4SF__Number_of_Products__c = 1;
		if (ipaddress != null) { app.TF4SF__IP_Address__c = ipaddress; }
		if (userAgent != null) { app.TF4SF__User_Agent__c =  userAgent; }
		List<TF4SF__Product_Codes__c> productCodeList = [SELECT Id, Name, TF4SF__Product__c, TF4SF__Sub_Product__c FROM TF4SF__Product_Codes__c WHERE Name = :ApexPages.currentPage().getParameters().get('subProductId') ORDER BY TF4SF__Sub_Product__c ASC];
		
		if (productCodeList != null && !productCodeList.isEmpty()) {
			for (TF4SF__Product_Codes__c key : productCodeList){
				app.TF4SF__Product__c = key.TF4SF__Product__c;
				app.TF4SF__Sub_Product__c = key.TF4SF__Sub_Product__c;
				app.TF4SF__Type_of_Checking__c = key.TF4SF__Sub_Product__c;
				app.TF4SF__Type_of_Savings__c = key.TF4SF__Sub_Product__c;
			}
		}

		//app.TF4SF__Product__c = 'Checking';
		//app.TF4SF__Sub_Product__c = 'Checking - Colossal Checking';
		//app.TF4SF__Type_of_Checking__c = 'Checking - Colossal Checking';
		/*if(app.TF4SF__Product__c != null && app.TF4SF__Product__c != '' && app.TF4SF__Product__c.equalsIgnoreCase('Checking')){
			app.TF4SF__Product__c = 'Checking';
			if(app.TF4SF__Sub_Product__c.equalsIgnoreCase('Checking - Colossal Checking')){
				
				app.TF4SF__Sub_Product__c = 'Checking - Colossal Checking';
				app.TF4SF__Type_of_Checking__c = 'Checking - Colossal Checking';
		   
			}else if(app.TF4SF__Sub_Product__c.equalsIgnoreCase('Checking - Classic Checking')){
				
				app.TF4SF__Sub_Product__c = 'Checking - Classic Checking';
				app.TF4SF__Type_of_Checking__c = 'Checking - Classic Checking';
			
			}else if(app.TF4SF__Sub_Product__c.equalsIgnoreCase('Checking - Premier Checking')){
					
				app.TF4SF__Sub_Product__c = 'Checking - Premier Checking';
				app.TF4SF__Type_of_Checking__c = 'Checking - Premier Checking';   
			
			}else{
				
				app.TF4SF__Sub_Product__c = 'Checking - Student Checking';
				app.TF4SF__Type_of_Checking__c = 'Checking - Student Checking';
			}
			

			
	   } else if(app.TF4SF__Product__c != null && app.TF4SF__Product__c != '' && app.TF4SF__Product__c.equalsIgnoreCase('Savings')){
			
			app.TF4SF__Product__c = 'Savings';
			
			if(app.TF4SF__Sub_Product__c.equalsIgnoreCase('Savings - Basic Savings')){
				
				app.TF4SF__Sub_Product__c = 'Savings - Basic Savings';
				app.TF4SF__Type_of_Savings__c = 'Savings - Basic Savings';
		   
			}else if(app.TF4SF__Sub_Product__c.equalsIgnoreCase('Savings - Holiday Club Savings')){
				
				app.TF4SF__Sub_Product__c = 'Savings - Holiday Club Savings';
				app.TF4SF__Type_of_Savings__c = 'Savings - Holiday Club Savings';
			
			}else if(app.TF4SF__Sub_Product__c.equalsIgnoreCase('Savings - Money Market Account')){
					
				app.TF4SF__Sub_Product__c = 'Savings - Money Market Account';
				app.TF4SF__Type_of_Savings__c = 'Savings - Money Market Account'; 
			
			}else if(app.TF4SF__Sub_Product__c.equalsIgnoreCase('Savings - Primary Savings')){
					
				app.TF4SF__Sub_Product__c = 'Savings - Primary Savings';
				app.TF4SF__Type_of_Savings__c = 'Savings - Primary Savings';  
			
			}else if(app.TF4SF__Sub_Product__c.equalsIgnoreCase('Savings - Super5 Savings')){
					
				app.TF4SF__Sub_Product__c = 'Savings - Super5 Savings';
				app.TF4SF__Type_of_Savings__c = 'Savings - Super5 Savings';   
			
			} else{
				
				app.TF4SF__Sub_Product__c = 'Savings - Vacation Club Savings';
				app.TF4SF__Type_of_Savings__c = 'Savings - Vacation Club Savings';
			}
  
	   }*/
		
		//if (TF4SF__Application__c.SObjectType.getDescribe().isCreateable() && appId == null) {
		//    insert app;
		// } else 

		if (TF4SF__Application__c.SObjectType.getDescribe().isUpdateable() && appId != null) { update app; }
		System.debug('########################## application ID' + app.id);
		//Logger.addMessage('Redirecting to INDEX page', System.now().format());
		p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'tf4sf__dsp#cross-sell');
		//p = new PageReference('https://c.cs23.visual.force.com/apex/tf4sf__dsp#cross-sell');
		app = [SELECT Id, TF4SF__User_Token__c FROM TF4SF__Application__c WHERE Id = :app.Id];
		Cookie id = ApexPages.currentPage().getCookies().get('id');
		Cookie ut = ApexPages.currentPage().getCookies().get('ut');
		Cookie fr = ApexPages.currentPage().getCookies().get('fr');
		id = new Cookie('id', app.Id, null, -1, true);
		//ut = new Cookie('ut', StartApplication.decrypt(app.TF4SF__User_Token__c), null, -1, true);
		fr = new Cookie('fr', '0', null, -1, true);
		ApexPages.currentPage().setCookies(new Cookie[]{id, ut, fr});
		p.setRedirect(false);

		return p;
	}
	
	//Checking
	public PageReference CheckingColossalChecking() {
		app.TF4SF__Product__c = 'Checking';
		app.TF4SF__Sub_Product__c = 'Checking - Colossal Checking';
		app.TF4SF__Type_of_Checking__c = 'Checking - Colossal Checking';
		return ProSub();
	}

	public PageReference CheckingClassicChecking() {
		app.TF4SF__Product__c = 'Checking';
		app.TF4SF__Sub_Product__c = 'Checking - Classic Checking';
		app.TF4SF__Type_of_Checking__c = 'Checking - Classic Checking';
		return ProSub();
	}

	//Savings
	public PageReference SavingsMoneyMarket() {
		app.TF4SF__Product__c = 'Savings';
		app.TF4SF__Sub_Product__c = 'Savings - Money Market';
		app.TF4SF__Type_of_Savings__c = 'Savings - Money Market';
		return ProSub();
	}

	public PageReference SavingsPrimarySavings() {
		app.TF4SF__Product__c = 'Savings';
		app.TF4SF__Sub_Product__c = 'Savings - Primary Savings';
		app.TF4SF__Type_of_Savings__c = 'Savings - Primary Savings';
		return ProSub();
	}
}