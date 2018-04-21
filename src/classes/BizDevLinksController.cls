global class BizDevLinksController {
	global String SelectedProduct {get; set;}
	global Map<String, List<TF4SF__Product_Codes__c>> prdMap{get; set;}
	global List<TF4SF__Product_Codes__c> productlist {get;set;}
	global String ipaddress{get;set;}
	global String userAgent{get;set;}
	global Set<String> prdNameSet{get; set;}
	global List<String> prdNameList{get; set;}
	global User loggedInUser{get;set;}
	global String PromoCode;
	public String loggedInUserId;
	public List<String> productLists {get; set;}

	global BizDevLinksController() {
		loggedInUserId = Userinfo.getUserId();
		ipaddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
		userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
		prdMap = new Map<String, List<TF4SF__Product_Codes__c>>();
		PromoCode = ApexPages.currentPage().getParameters().get('PromoCode');
		prdNameSet = new Set<String>();
		prdNameList = new List<String>(); 
		//productlist = TF4SF__Product_Codes__c.getAll().values();
		productlist = [SELECT Id, IsDeleted, Name, SetupOwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, TF4SF__Amount_error_message__c, TF4SF__Description__c, TF4SF__Product_Code__c, TF4SF__Product_Theme__c, TF4SF__Product__c, TF4SF__Sub_Product_Code__c, TF4SF__Sub_Product__c, ML_Code__c, Landing_Page_Description__c, Product_Image__c, TF4SF__Description_TextArea1__c, TF4SF__Description_TextArea2__c, TF4SF__Description_TextArea3__c, TF4SF__Description_TextArea4__c, TF4SF__Description_TextArea5__c, TF4SF__Description_Text__c, Order__c, Product_Order__c FROM TF4SF__Product_Codes__c ORDER BY Order__c ASC ];
		productLists = new List<String>();

		for (TF4SF__Product_Codes__c pcname : productlist) { if (prdNameSet.add(pcname.TF4SF__Product__c)) { prdNameList.add(pcname.TF4SF__Product__c); } }
		for (String prdName : prdNameList) {
			List<TF4SF__Product_Codes__c> pcList = new List<TF4SF__Product_Codes__c>();
			pcList = [SELECT Id, Name, TF4SF__Product__c, TF4SF__Sub_Product__c, TF4SF__Description__c, Product_Image__c, Product_Order__c, Landing_Page_Description__c, Order__c FROM TF4SF__Product_Codes__c WHERE TF4SF__Product__c = :prdName ORDER BY Order__c ASC];
			prdMap.put(prdName, pcList);
			System.debug('the map is : ' + pcList.size());
		}

		if (prdMap.size() > 0) { for (String p : prdMap.KeySet()) { if (p != '' || p != null) { productLists.add(p); } } }
	}

	global PageReference ProdSub() {
		Map<String, TF4SF__Product_Codes__c> pCodes = TF4SF__Product_Codes__c.getAll();
		User appUser = [SELECT Id, TF4SF__Channel__c, Name, Email, TF4SF__Location__c, Profile.Name FROM User WHERE Id = :loggedInUserId];
		TF4SF__Application__c app = new TF4SF__Application__c();
		app.TF4SF__Sub_Product__c = pCodes.get(SelectedProduct).TF4SF__Sub_Product__c;
		app.TF4SF__Product__c = pCodes.get(SelectedProduct).TF4SF__Product__c;
		if (pCodes.get(SelectedProduct).TF4SF__Description__c != null) { app.TF4SF__Sub_Product_Description__c = pCodes.get(SelectedProduct).TF4SF__Description__c; }
		app.TF4SF__Created_Channel__c = 'BizDev';
		app.TF4SF__Current_Channel__c = 'BizDev';
		app.TF4SF__Application_Status__c = 'Open';
		app.TF4SF__Application_Page__c = 'eligibility';
		app.TF4SF__Created_timestamp__c = System.now();
		app.TF4SF__Current_timestamp__c = System.now();
		app.TF4SF__Created_Branch_Name__c = appUser.TF4SF__Location__c;
		app.TF4SF__Current_Branch_Name__c = appUser.TF4SF__Location__c;
		app.TF4SF__Current_Person__c = appUser.Id;
		app.TF4SF__Created_Person__c = appUser.Id;
		app.TF4SF__Created_User_Email_Address__c = appUser.Email;
		if (String.isNotBlank(PromoCode)) { app.TF4SF__Promo_Code__c = PromoCode; }
		if (ipaddress != null) { app.TF4SF__IP_Address__c = ipaddress; }
		if (userAgent != null) { app.TF4SF__User_Agent__c = userAgent; }

		TF4SF__Product_Codes__c pc = [SELECT Id, Name, TF4SF__Product__c, TF4SF__Sub_Product__c, TF4SF__Description__c FROM TF4SF__Product_Codes__c WHERE Name = :SelectedProduct LIMIT 1];

		if (pc.TF4SF__Product__c == 'Checking') {
			app.TF4SF__Type_of_Checking__c = pc.TF4SF__Sub_Product__c;
		} else if (pc.TF4SF__Product__c == 'Savings') {
			app.TF4SF__Type_of_Savings__c = pc.TF4SF__Sub_Product__c;
		} else if (pc.TF4SF__Product__c == 'Certificates') {
			app.TF4SF__Type_of_Certificates__c = pc.TF4SF__Sub_Product__c;
		} else if (pc.TF4SF__Product__c == 'Personal Loans') {
			app.TF4SF__Type_of_Personal_Loans__c = pc.TF4SF__Sub_Product__c;
		} else if (pc.TF4SF__Product__c == 'Vehicle Loans') {
			app.TF4SF__Type_of_Vehicle_Loans__c = pc.TF4SF__Sub_Product__c;
		} else if (pc.TF4SF__Product__c == 'Credit Cards') {
			app.TF4SF__Type_of_Credit_Cards__c = pc.TF4SF__Sub_Product__c;
		}

		CryptoHelper.setAppToken(app);
		insert app;

		//String userToken = CryptoHelper.decrypt(app.User_Token__c);
		TF4SF__Application2__c app2 = new TF4SF__Application2__c();
		app2.TF4SF__Application__c = app.Id;
		insert app2;

		TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
		emp.TF4SF__Application__c = app.Id;
		insert emp;

		TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
		iden.TF4SF__Application__c = app.Id;
		insert iden;

		TF4SF__About_Account__c abt = new TF4SF__About_Account__c();
		abt.TF4SF__Application__c = app.Id;
		insert abt;

		PageReference p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'tf4sf__dsp#/eligibility');
		Cookie id = ApexPages.currentPage().getCookies().get('id');
		Cookie ut = ApexPages.currentPage().getCookies().get('ut');
		Cookie fr = ApexPages.currentPage().getCookies().get('fr');
		id = new Cookie('id', app.Id, null, -1, true);
		ut = new Cookie('ut', CryptoHelper.decrypt(app.TF4SF__User_Token__c), null, -1, true);
		fr = new Cookie('fr', '0', null, -1, true);
		// Logger.writeAllLogs();
		// Set the new cookie for the page
		ApexPages.currentPage().setCookies(new Cookie[]{id, ut, fr});
		p.setRedirect(false);  

		return p;
	}
}