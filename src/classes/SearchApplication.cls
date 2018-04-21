public with sharing class SearchApplication {
	public Boolean appsearchMsg {get; set;}
	public String imageUrl {get; set;}
	public Boolean ShowApplicantNo {get; set;}
	public Boolean ShowappMemberNo {get; set;}
	public ApexPages.StandardSetController assc {get; set;}
	public Integer counter = 0;
	public Integer appcounter = 0;

	// Declaring variables to maintain member search result limitations
	public Integer maxSearchResults{get; set;}
	public Integer recordsPerPage {get; set;}
	public String appfirstnameQuery {get; set;}
	public String applastnameQuery {get; set;}
	public String appssnLast4Query {get; set;}
	public String appEmailQuery {get; set;}
	public String ApplicationQuery {get; set;}
	public String FromDate {get; set;}
	public String ToDate {get; set;}
	public List<TF4SF__Application__c> applications = new List<TF4SF__Application__c>();
	public List<TF4SF__Identity_Information__c> identity = new List<TF4SF__Identity_Information__c>();
	public List<String> IdenList = new List<String>();
	public List<ApplicationWrapper> appWrapper{get; set;}

	public SearchApplication() {
		//imageURL='/servlet/servlet.FileDownload?file=';
		//List< document > documentList = [SELECT Name FROM Document WHERE Name = 'AmerisLogo'];
		maxSearchResults = 100;
		recordsPerPage = 25;
		//if(documentList.size() > 0) { imageURL=imageURL+documentList[0].id; }
	}

	// Method executed when "Search" button om the SearchMember page is clicked
	public void executeAppSearch() {
		try {
			applications = new List<TF4SF__Application__c>();
			IdenList = new List<String>();
			// Trimming all the variable to get rid of empty spaces
			System.debug('appssnLast4Query in executeAppSearch= ' + appssnLast4Query);
			System.debug('System.today:' + System.today());
			System.debug('the fromDate ' + FromDate);
			System.debug('the ToDate ' + ToDate);

			if (!test.isRunningTest()) {
				appfirstnameQuery = appfirstnameQuery.trim();
				applastnameQuery = applastnameQuery.trim();
				appssnLast4Query = appssnLast4Query.trim();
				appEmailQuery = appEmailQuery.trim();
				ApplicationQuery = ApplicationQuery.trim();
			}

			System.debug('the First_Name__c is ' + appfirstnameQuery);
			System.debug('the Last_Name__c is ' + applastnameQuery);
			System.debug('the ssnlast4 is ' + appssnLast4Query);
			System.debug('the email is ' + appEmailQuery);
			System.debug('the App Number is ' + ApplicationQuery);
			System.debug('the fromDate ' + FromDate);
			System.debug('the ToDate ' + ToDate);
			
			Date fromDay = Date.parse(FromDate);
			Date toDay = Date.parse(ToDate);
			//datetime fromDay = datetime.newInstance(date.parse(FromDate).year(), date.parse(FromDate).month(),date.parse(FromDate).day());
			//datetime toDay = datetime.newInstance(date.parse(ToDate).year(), date.parse(ToDate).month(),date.parse(ToDate).day());
			System.debug('the fromDate ' + fromDay);
			System.debug('the toDate ' + toDay);
			if (FromDate == ToDate) { Date sameDay = Date.parse(ToDate); }

			if (ApplicationQuery != '' && ApplicationQuery != null) {
				System.debug('entered appquery');
				ShowappMemberNo = true;
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
								FROM TF4SF__Application__c WHERE ((Name = :ApplicationQuery OR TF4SF__External_App_ID__c = :ApplicationQuery) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER BY LastModifiedDate LIMIT :maxSearchResults];
			}

			//List<TF4SF__Application__c> app = [SELECT Id, TF4SF__Created_TimeStamp__c, LastModifiedDate FROM TF4SF__Application__c WHERE TF4SF__Created_Timestamp__c >: fromDay AND TF4SF__Created_Timestamp__c <: toDay ORDER BY LastModifiedDate];
			// for query optimization wirting quesries based on the information provided by the User
			if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query == '' && appEmailQuery == '') {
				ShowApplicantNo = true;
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE (((TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Last_Name__c = :applastnameQuery) OR (TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Last_Name_J__c = :applastnameQuery) OR (TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Last_Name_J2__c = :applastnameQuery)) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER BY LastModifiedDate LIMIT :maxSearchResults];
			} else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query == '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE (((TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER BY LastModifiedDate LIMIT :maxSearchResults];
			} else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query !='' && appEmailQuery != '') {
				ShowApplicantNo = true;
				System.debug('fname, lname, ssn, email: '+appfirstnameQuery+'--'+applastnameQuery+'--'+appssnLast4Query+'--'+appEmailQuery);
				
				identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				System.debug('identity: '+identity);
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c,  TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
				System.debug('application: '+applications);
			} else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query !='' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c,  TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery != ''&& appssnLast4Query !='' && applastnameQuery=='' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >=: fromDay AND TF4SF__Application__r.CreatedDate__c <=: toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery != ''&& appssnLast4Query !='' && applastnameQuery=='' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (applastnameQuery != ''&& appssnLast4Query !='' && appfirstnameQuery=='' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (applastnameQuery != ''&& appssnLast4Query !='' && appfirstnameQuery=='' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery != '' && applastnameQuery == '' && appssnLast4Query == '' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery != '' && applastnameQuery == '' && appssnLast4Query == '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery != '' && appssnLast4Query == '' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery != '' && appssnLast4Query == '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query != '' && appEmailQuery == '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query != '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query AND TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query == '' && appEmailQuery != '') {
				ShowApplicantNo = true;
				identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
					FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Email_Address__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Email_Address_J__c = :appEmailQuery) OR (TF4SF__Application__r.TF4SF__Email_Address_J2__c = :appEmailQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER BY TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
				for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE Id IN :IdenList];
			} else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query == '' && appEmailQuery == '' && ApplicationQuery == '') {
				ShowApplicantNo = false;
			} else {
				ShowApplicantNo = false;
			}

			/*  if (ApplicationQuery != '') {
			System.debug('entered appquery');
				ShowappMemberNo = true;
				applications = [SELECT Id, Name, TF4SF__Custom_DateTime1__c, CreatedDate__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
					FROM TF4SF__Application__c WHERE ((Name = :ApplicationQuery OR TF4SF__External_App_ID__c = :ApplicationQuery) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER BY LastModifiedDate LIMIT :maxSearchResults];
			}*/
			System.debug('applications: ' + applications);

			if (applications == null || applications.size() == 0) {
				appsearchMsg = true;
				assc = null;
				//ShowStartApplication = true;
			} else {
				appsearchMsg = false;
				//ShowStartApplication = false; 
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
						System.debug('the product no is '+m);
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
		public String decision {get; set;}
		public TF4SF__Application__c app {get; set;}
		public String createdDateTimePST { get; set;}
		public String submittedDateTimePST { get; set;}
		
		public ApplicationWrapper(TF4SF__Application__c a, String productName, String decision, Integer c) {
			this.count = c;
			this.productName = productName;
			this.decision = decision;
			this.app = a;
			createdDateTimePST  = '';
			if(a.TF4SF__Created_Timestamp__c != null)
			createdDateTimePST  = a.TF4SF__Created_Timestamp__c.format('yyyy-MM-dd HH:mm:ss', 'PST') +' PST';
			submittedDateTimePST = '';
			if(a.TF4SF__Submitted_Timestamp__c != null) 
			submittedDateTimePST =  a.TF4SF__Submitted_Timestamp__c.format('yyyy-MM-dd HH:mm:ss', 'PST') +' PST';
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
			Decimal apppages = apptotalSize / apppageSize;

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

	public void appclearAll() {
		appfirstnameQuery = '';
		applastnameQuery = '';
		appssnLast4Query = '';
		ApplicationQuery = '';
		appEmailQuery = '';
		applications.clear();
		appsearchMsg = false;
	}
}