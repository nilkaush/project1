global without sharing class PortalController {
	public static Integer maxSearchResults = 100;
	public static Status_Portal_Settings__c portalSettings{get; set;}
	public static TF4SF__Application_Configuration__c appconfig{get; set;}
	public static String NAMESPACE{get; set;}
	public static String attachmentsRestUrl{get; set;}
	public String PortalApplicationCode{get; set;}
	public String PortalCustomTheme{get; set;}
	public String PortalResourceVersion{get; set;}

	public PortalController() {
		setNameSpace();
		PortalResourceVersion = portalSettings.Portal_Resource_Version__c;
		attachmentsRestUrl = (NAMESPACE == '') ? 'services/apexrest/Attachments/v1' : 'services/apexrest/TF4SF/Attachments/v1';

		List<StaticResource> portalResourceList = [SELECT Name, NameSpacePrefix, SystemModStamp FROM StaticResource WHERE Name = :portalSettings.Portal_Application_Code__c LIMIT 1];
		if (portalResourceList.size() > 0) {
			String ns = portalResourceList[0].NameSpacePrefix;
			PortalApplicationCode = '/resource/' + portalResourceList[0].SystemModStamp.getTime() + '/' + (ns != null && ns != '' ? ns + '__' : '') + portalSettings.Portal_Application_Code__c;
			System.debug('PortalApplicationCode Path is ' + PortalApplicationCode);
		}

		List<StaticResource> themeResourceList = [SELECT Name, NameSpacePrefix, SystemModStamp FROM StaticResource WHERE Name = :portalSettings.Portal_Custom_Theme__c LIMIT 1];
		if (themeResourceList.size() > 0) {
			String ns = themeResourceList[0].NameSpacePrefix;
			PortalCustomTheme = '/resource/' + themeResourceList[0].SystemModStamp.getTime() + '/' + (ns != null && ns != '' ? ns + '__' : '') + portalSettings.Portal_Custom_Theme__c;
			System.debug('PortalCustomTheme Path is ' + PortalCustomTheme);
		}
	}

	global static void setNameSpace() {
		appconfig = TF4SF__Application_Configuration__c.getOrgDefaults();
		portalSettings = Status_Portal_Settings__c.getOrgDefaults();
		NAMESPACE = (String.isEmpty(appconfig.TF4SF__Namespace__c)) ? '' : appconfig.TF4SF__Namespace__c;
	}

	global static void setAppErrors(Map<String, sObject> appData, Boolean debug) {
		List<Apexpages.Message> msgsList = ApexPages.getMessages();
		String errorMsgs = '';
		String warningMsgs = '';
		String infoMsgs = '';

		for (Apexpages.Message m: msgsList) {
			if (m.getSeverity() == ApexPages.Severity.WARNING) {
				warningMsgs += m.getDetail() + '\n';
			} else if (m.getSeverity() == ApexPages.Severity.INFO) {
				infoMsgs += m.getDetail() + '\n';
			} else {
				errorMsgs += m.getDetail() + '\n';
			}
		}

		if (String.isNotEmpty(infoMsgs) && debug) { appData.put('debug-server-errors', TF4SF.DspUtility.getMessageObject(infoMsgs)); }
		if (String.isNotEmpty(warningMsgs) && debug) { appData.put('server-errors-stack-trace', TF4SF.DspUtility.getMessageObject(warningMsgs)); }
		if (String.isNotEmpty(errorMsgs)) { appData.put('server-errors', TF4SF.DspUtility.getMessageObject(errorMsgs)); }
	}

	@RemoteAction
	global static Map<String, sObject> getAppFields(Map<String, String> tdata, String pageName) {
		System.debug('tdataaaa: '+tdata);
		Map<String, sObject> appData = new Map<String, sObject>();
		Map<String, String> data = tdata.clone();
		Boolean debug = (data.get('debug') == 'true');
		Boolean infoDebug = (data.get('infoDebug') == 'true');
		TF4SF.DSPController.debug = debug;
		TF4SF.DSPController.infoDebug = infoDebug;

		try {
			Set<String> subProducts = new Set<String>();
			subProducts.add('All');
			Map<String, Boolean> jointApplicants = new Map<String, Boolean>();
			jointApplicants.put('J1', false);
			jointApplicants.put('J2', false);
			jointApplicants.put('J3', false);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'pageName: ' + pageName + '; subProducts: ' + subProducts + '; jointApplicants: ' + jointApplicants));      
			String jsonResult = TF4SF.DSPController.getPageFields(pageName, 'Online', 'Status Portal', subProducts, jointApplicants);
			System.Debug('jsonResult=>' + jsonResult);
			System.Debug('jsonResult2=>' + TF4SF.DspUtility.getMessageObject(jsonResult));
			if (String.isBlank(jsonResult)) { jsonResult = '{}'; }
			appData.put('pageFields', TF4SF.DspUtility.getMessageObject(jsonResult));
			System.debug('appData: ' + appData);

			if (pageName == TF4SF.DSPController.STATUS_PORTAL_PAGE) {
				Map<Id, TF4SF__Application__c> appMap = getAppData(data, appData);
				String jsData = generateJSON(appMap, debug);
				System.debug('statusjson: ' + jsData);
				appData.put('statusData', TF4SF.DspUtility.getMessageObject(jsData));
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'getAppFields() Error:' + e.getMessage()));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Stack Trace: getAppFields() line 88:' + e.getStackTraceString()));
		}

		setAppErrors(appData, debug);
		return appData;
	}

	global static Map<Id, TF4SF__Application__c> getAppData(Map<String, String> data, Map<String, sObject> appData) {
		Map<Id, TF4SF__Application__c> appMap;
		String login = data.get('Application__c.Login__c');
		String password = data.get('Application__c.Password__c');
		Boolean debug = (data.get('debug') == 'true');
		Boolean loginError = false;
		if (login == null) { login = ''; }
		if (password == null) { password = ''; }

		if (String.isNotBlank(login) && String.isNotBlank(password)) {
			//String enc_password = CryptoHelper.encrypt(password);
			//appData.put('password', DspUtility.getMessageObject(password));
			List<TF4SF__Customer__c> c = [SELECT TF4SF__Date_Of_Birth__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__Person_Identifier__c, TF4SF__SSN__c, TF4SF__Username__c, TF4SF__Password__c FROM TF4SF__Customer__c WHERE TF4SF__Username__c = :login LIMIT 1];

			if (c.size() > 0) {
				//String dec_password = CryptoHelper.decrypt(c.Password__c);
				//appData.put('decrypted-password', dec_password);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'password: ' + password + '; c[0].TF4SF__Password__c: ' + c[0].TF4SF__Password__c));
				if (c[0].TF4SF__Password__c == password) {
					System.debug('Customer__c: ' + c[0]);
					appData.put('Customer__c', c[0]);
					System.debug('appData: ' + appData);

					data.put('Application__c.Last_Name__c', c[0].TF4SF__Last_Name__c);
					data.put('Application__c.Email_Address__c', c[0].TF4SF__Email_Address__c);
					data.put('Identity_Information__c.SSN_Prime__c', c[0].TF4SF__SSN__c);
					data.put('Identity_Information__c.Date_of_Birth__c', c[0].TF4SF__Date_Of_Birth__c);
				} else {
					loginError = true;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your User ID or Password are incorrect. Please try again.'));
				}
			} else {
				loginError = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'username: ' + login));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry, the information entered does not match any applications. Please try again.'));
			}
		}

		String ssn = data.get('Identity_Information__c.SSN_Prime__c');
		String lastName = data.get('Application__c.Last_Name__c');
		String email = data.get('Application__c.Email_Address__c');
		String dob = data.get('Identity_Information__c.Date_of_Birth__c');
		if (ssn == null) { ssn = ''; }
		if (lastName == null) { lastName = ''; }
		if (email == null) { email = ''; }
		if (dob == null) { dob = ''; }
		System.debug('emaillll: '+email);

		if (!loginError && String.isNotBlank(lastName) && String.isNotBlank(email) && String.isNotBlank(ssn) && String.isNotBlank(dob)) {
			List<String> appIdList = new List<String>();
			System.debug('ssn, dob: ' + ssn + '---' + dob + '---' + ssn.right(4));
			List<TF4SF__Identity_Information__c> idenList = [SELECT Id, TF4SF__SSN_Prime__c, TF4SF__SSN_Last_Four_PA__c, TF4SF__Application__c, TF4SF__Date_of_Birth__c FROM TF4SF__Identity_Information__c WHERE TF4SF__SSN_Last_Four_PA__c = :ssn.right(4) AND TF4SF__Date_of_Birth__c = :dob];

			if (idenList.size() > 0) {
				System.debug('identity list: ' + idenlist + '--' + idenlist[0].TF4SF__SSN_Prime__c + '---' + ssn);
				System.debug('date of birth: ' + idenList[0].TF4SF__Date_of_Birth__c + '---' + dob);

				for (TF4SF__Identity_Information__c idt : idenlist) {
					System.debug('identity ssn: ' + idt.TF4SF__SSN_Prime__c + '---' + ssn);
					if (idt.TF4SF__SSN_Prime__c.remove('-') == ssn.remove('-')) {
						System.debug('entered ssn: ' + ssn + '---' + idt);
						appIdList.add(idt.TF4SF__Application__c);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ssn: ' + ssn.remove('-') + '; adding app ID: ' + idt.TF4SF__Application__c));
					}
				}

				System.debug('appIdList: ' + appIdList);
				appMap = new Map<Id, TF4SF__Application__c>([SELECT Id, Name, TF4SF__Sub_Product__c, Meridian_Link_Number_CS1__c, Meridian_Link_Number_CS2__c,
												 Meridian_Link_Number_CS3__c, Meridian_Link_Number__c, TF4SF__Primary_Offer__c, App_Number__c,
												 TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer__c, TF4SF__Second_Offer_Status__c, 
												 TF4SF__Third_Offer__c, TF4SF__Third_Offer_Status__c, TF4SF__Email_Address__c, TF4SF__Last_Name__c, 
												 TF4SF__Full_Name_PA__c, TF4SF__FullName_J__c, TF4SF__FullName_J2__c, TF4SF__Support_Phone_Number__c,
												 TF4SF__FullName_J3__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, 
												 TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__Primary_Product_Status__c,
												 TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, 
												 TF4SF__External_AppID_CrossSell3__c, TF4SF__External_App_Stage__c, 
												 LastModifiedDate FROM TF4SF__Application__c 
												 //TF4SF__Application_Status__c IN ('Save for Later', 'Abandoned' ) LIMIT :maxSearchResults]);
												 
												 WHERE (TF4SF__Last_Name__c = :lastName AND TF4SF__Email_Address__c = :email AND Id IN :appIdList)
												 //WHERE (TF4SF__Last_Name__c = :lastName AND Id IN :appIdList)
												 AND TF4SF__Application_Status__c IN ('Submitted', 'Abandoned', 'Save for Later') 
												 ORDER by LastModifiedDate LIMIT :maxSearchResults]);
				// System.debug('appmapsize: '+appmap.size());
			}

			System.debug('appmapsize: ' + appmap);
			if (appMap == null || appMap.size() == 0) {
				System.debug('entered appmap');
				String appIdStr = '';

				for (String appId : appIdList) {
					if (String.isNotBlank(appIdStr)) { appIdStr += ', '; }
					appIdStr += '\'' + appId + '\'';
				}

				String statusQuery = 'SELECT Id, Name, TF4SF__Sub_Product__c, TF4SF__Primary_Offer__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer__c, TF4SF__Third_Offer_Status__c, TF4SF__Email_Address__c, TF4SF__Last_Name__c, TF4SF__Full_Name_PA__c, TF4SF__FullName_J__c, TF4SF__FullName_J2__c, TF4SF__Support_Phone_Number__c, TF4SF__FullName_J3__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__Primary_Product_Status__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__External_App_Stage__c, LastModifiedDate FROM TF4SF__Application__c WHERE (TF4SF__Last_Name__c = \'' + lastName + '\' AND TF4SF__Email_Address__c = \'' + email + '\' AND Id IN (' + appIdStr + ')) AND TF4SF__Application_Status__c IN (\'Submitted\', \'Abandoned\', \'Save for Later\') ORDER by LastModifiedDate LIMIT ' + maxSearchResults;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'statusQuery: ' + statusQuery));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'lastName: ' + lastName + '; email: ' + email + '; appIdList: ' + appIdList));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry, the information entered does not match any applications. Please try again.'));
			}
		}

		return appMap;
	}

	global static String generateJSON(Map<Id, TF4SF__Application__c> appMap, Boolean debug) {
		JSONGenerator gen = JSON.createGenerator(true);
		String SiteUser = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
		String uName = '';
		Map<String, List<TF4SF__Application__c>> aData = null;
		Map<String, List<TF4SF__Products__c>> aProd = null;
		Map<String, List<Note>> pNotemap = null;
		Map<String, List<TF4SF__Documentation_Request__c>> pDocmap = null;
		Map<String, List<Attachment>> dAttmap = null;

		if (appMap != null && appMap.keySet().size() > 0) {
			Map<Id, TF4SF__Products__c> ProdMap = new Map<Id, TF4SF__Products__c>([SELECT Id, Name, Requested_Term__c, TF4SF__Account_Holder_Name__c, TF4SF__Account_Number__c, TF4SF__Account_Type__c, TF4SF__Application__c, TF4SF__Product_Name__c, TF4SF__Product_Type__c, TF4SF__Requested_Credit_Limit__c, TF4SF__Requested_Loan_Amount__c, TF4SF__Funding_Amount_External__c, TF4SF__Term__c, TF4SF__Rate__c
																	FROM TF4SF__Products__c WHERE TF4SF__Application__c IN :appMap.keySet() LIMIT :maxSearchResults]);

			Map<Id, TF4SF__Documentation_Request__c> DReq = new Map<Id, TF4SF__Documentation_Request__c>([SELECT Id, Name, TF4SF__Application__c, TF4SF__Description__c, 
																											 TF4SF__External_ID__c, TF4SF__Product__c, TF4SF__Products__c,
																											 TF4SF__Status__c, TF4SF__Type__c 
																											 FROM TF4SF__Documentation_Request__c 
																											 WHERE TF4SF__Products__c IN :ProdMap.keySet() LIMIT :maxSearchResults]);
			System.debug('dreq: '+DReq);
			Map<Id, Attachment> attachments = new Map<Id, Attachment>([SELECT Id, Name, ContentType, Description, LastModifiedDate, IsPrivate, ParentId FROM Attachment WHERE ParentId IN :DReq.keySet() LIMIT :maxSearchResults]);
			Map<Id, Note> prodNotes = new Map<Id, Note>([SELECT Id, Title, Body, ParentId, IsPrivate, OwnerId, CreatedDate, Owner.Name, Owner.CommunityNickname FROM Note WHERE ParentId IN :ProdMap.keySet() ORDER BY CreatedDate ASC LIMIT :maxSearchResults]);
			aData = new Map<String, List<TF4SF__Application__c>>();
			aProd = new Map<String, List<TF4SF__Products__c>>();
			pNotemap = new Map<String, List<Note>>();
			pDocmap = new Map<String, List<TF4SF__Documentation_Request__c>>();
			dAttmap = new Map<String, List<Attachment>>();
			String statusKey = '';
			List<TF4SF__Application__c> alist = new List<TF4SF__Application__c>(appMap.values());
			uName = alist[0].TF4SF__Full_Name_PA__c;

			for (TF4SF__Application__c ap : appMap.values()) {
				if (ap.TF4SF__Application_Status__c != null) {
					statusKey = (ap.TF4SF__Application_Status__c == 'Save for Later') ? 'Saved' : ap.TF4SF__Application_Status__c;
					if (aData.containsKey(statusKey)) {
						aData.get(statusKey).add(ap);
					} else {
						aData.put(statusKey, new List<sObject>{ap});
					}
				}
			}

			for (TF4SF__Products__c apro : ProdMap.values()) {
				if (aProd.containsKey(apro.TF4SF__Application__c)) {
					aProd.get(apro.TF4SF__Application__c).add(apro);
				} else {
					if (apro.TF4SF__Application__c != null) { 
						aProd.put(apro.TF4SF__Application__c, new List<sObject>{apro});
						System.debug('Value==>' + new List<sObject>{apro});
					}
				}
			}

			for (Note pn : prodNotes.values()) {
				if (pNotemap.containsKey(pn.ParentId)) {
					pNotemap.get(pn.ParentId).add(pn);
				} else {
					pNotemap.put(pn.ParentId, new List<sObject>{pn});
				}
			}

			for (TF4SF__Documentation_Request__c dr : DReq.values()) {
				if (pDocmap.containsKey(dr.TF4SF__Products__c)) {
					pDocmap.get(dr.TF4SF__Products__c).add(dr);
				} else {
					pDocmap.put(dr.TF4SF__Products__c, new List<sObject>{dr});
				}
			}

			System.debug('pdocmap: '+pDocmap);
			for (Attachment a : attachments.values()) {
				if (dAttmap.containsKey(a.ParentId)) {
					dAttmap.get(a.ParentId).add(a);
				} else {
					dAttmap.put(a.ParentId, new List<sObject>{a});
				}
			}
		}

		gen.writeStartObject();
			gen.writeFieldName('Application__c');
				gen.writeStartObject();
					gen.writeStringField('Application_Page__c', 'StatusPortalPage');
				gen.writeEndObject();
			gen.writeFieldName('User');
				gen.writeStartObject();
					gen.writeStringField('Username', uName);
					gen.writeStringField('sessionToken', '');
				gen.writeEndObject();

			if (aData != null) {
				for (String stat: aData.keySet()) {
					gen.writeFieldName(stat);
					gen.writeStartArray(); 
						for (TF4SF__Application__c aid : aData.get(stat)) {
							if (aProd.containsKey(aid.Id)) {//prod null check

								for (TF4SF__Products__c prd : aProd.get(aid.Id)) {
									gen.writeStartObject();
										gen.writeStringField('Id', aid.Id);
										if (prd.TF4SF__Product_Name__c == aid.TF4SF__Sub_Product__c) {
											gen.writeStringField('Name', (aid.Meridian_Link_Number__c == null) ? '' :aid.Meridian_Link_Number__c);  
										} else if (prd.TF4SF__Product_Name__c == aid.TF4SF__Primary_Offer__c) {
											gen.writeStringField('Name', (aid.Meridian_Link_Number_CS1__c == null) ? '' :aid.Meridian_Link_Number_CS1__c);
										} else if (prd.TF4SF__Product_Name__c == aid.TF4SF__Second_Offer__c) {
											gen.writeStringField('Name', (aid.Meridian_Link_Number_CS2__c == null) ? '' :aid.Meridian_Link_Number_CS2__c);  
										} else if (prd.TF4SF__Product_Name__c == aid.TF4SF__Third_Offer__c) {
											gen.writeStringField('Name', (aid.Meridian_Link_Number_CS3__c == null) ? '' :aid.Meridian_Link_Number_CS3__c);  
										}

										gen.writeStringField('Email_Address__c', (aid.TF4SF__Email_Address__c == null) ? '' : aid.TF4SF__Email_Address__c);
										gen.writeStringField('Full_Name_PA__c', (aid.TF4SF__Full_Name_PA__c == null) ? '' : aid.TF4SF__Full_Name_PA__c);
										gen.writeStringField('FullName_J__c', (aid.TF4SF__FullName_J__c == null) ? '' : aid.TF4SF__FullName_J__c);
										if (aid.TF4SF__FullName_J2__c != null) { gen.writeStringField('FullName_J2__c', aid.TF4SF__FullName_J2__c); }
										if (aid.TF4SF__FullName_J3__c != null) { gen.writeStringField('FullName_J3__c', aid.TF4SF__FullName_J3__c); }
										gen.writeStringField('Application_Status__c', aid.TF4SF__Application_Status__c);

										System.debug('debugProdStatus: ' + aid.TF4SF__Primary_Product_Status__c);
										String pStatus = (prd.TF4SF__Product_Type__c == 'Primary') ? aid.TF4SF__Primary_Product_Status__c :
																					  (prd.TF4SF__Product_Type__c == 'Cross-sell 1') ? aid.TF4SF__Primary_Offer_Status__c :
																					  (prd.TF4SF__Product_Type__c == 'Cross-sell 2') ? aid.TF4SF__Second_Offer_Status__c : 
																					  (prd.TF4SF__Product_Type__c == 'Cross-sell 3') ? aid.TF4SF__Third_Offer_Status__c : '';

										if (pStatus == 'Approved' || pStatus == 'Instant Approved') {
											pStatus = 'Approved';
										} else if (pStatus == 'Declined' || pStatus == 'Instant Declined') {
											pStatus = 'Declined';
										} else {
											pStatus = 'Pending Review';
										}

										gen.writeStringField('Product_Status', pStatus);
										/*gen.writeStringField('Product_Status', (prd.TF4SF__Product_Type__c == 'Primary') ? aid.TF4SF__Primary_Product_Status__c :
																					  (prd.TF4SF__Product_Type__c == 'Cross-sell 1') ? aid.TF4SF__Primary_Offer_Status__c :
																					  (prd.TF4SF__Product_Type__c == 'Cross-sell 2') ? aid.TF4SF__Second_Offer_Status__c : 
																					  (prd.TF4SF__Product_Type__c == 'Cross-sell 3') ? aid.TF4SF__Third_Offer_Status__c : '');*/
										gen.writeDateTimeField('Created_Timestamp__c', aid.TF4SF__Created_Timestamp__c);
										if (aid.TF4SF__Submitted_Timestamp__c != null) { gen.writeDateTimeField('Submitted_Timestamp__c', aid.TF4SF__Submitted_Timestamp__c); }
										gen.writeDateTimeField('LastModifiedDate', aid.LastModifiedDate);

										gen.writeStringField('ProductId', prd.Id);
										gen.writeStringField('ProductName', (prd.TF4SF__Product_Name__c == null) ? '' : prd.TF4SF__Product_Name__c);
										gen.writeStringField('Account_Holder_Name__c', (prd.TF4SF__Account_Holder_Name__c == null) ? '' : prd.TF4SF__Account_Holder_Name__c);
										gen.writeStringField('Account_Number__c', (prd.TF4SF__Account_Number__c == null) ? '' : prd.TF4SF__Account_Number__c);
										gen.writeStringField('Account_Type__c', (prd.TF4SF__Account_Type__c == null) ? '' : prd.TF4SF__Account_Type__c);
										gen.writeStringField('Application__c', (prd.TF4SF__Application__c == null) ? '' : prd.TF4SF__Application__c);
										gen.writeStringField('Support_Phone_Number__c', aid.TF4SF__Support_Phone_Number__c);
										gen.writeStringField('Product_Name__c', (prd.TF4SF__Product_Name__c == null) ? '' : prd.TF4SF__Product_Name__c);
										gen.writeStringField('Product_Type__c', (prd.TF4SF__Product_Type__c == null) ? '' : prd.TF4SF__Product_Type__c);
										gen.writeStringField('AmountRequested', (prd.TF4SF__Requested_Credit_Limit__c != null && prd.TF4SF__Requested_Credit_Limit__c > 0) ? String.valueOf(prd.TF4SF__Requested_Credit_Limit__c) : (prd.TF4SF__Requested_Loan_Amount__c == null) ? '' : String.valueOf(prd.TF4SF__Requested_Loan_Amount__c));
										gen.writeStringField('AmountApproved', (prd.TF4SF__Funding_Amount_External__c == null) ? '' : String.valueOf(prd.TF4SF__Funding_Amount_External__c));
										gen.writeStringField('Requested_Credit_Limit__c', (prd.TF4SF__Requested_Credit_Limit__c == null) ? '' : String.valueOf(prd.TF4SF__Requested_Credit_Limit__c));
										gen.writeStringField('Requested_Loan_Amount__c', (prd.TF4SF__Requested_Loan_Amount__c == null) ? '' : String.valueOf(prd.TF4SF__Requested_Loan_Amount__c));
										String rt;

										if (prd.TF4SF__Rate__c != null) {
											rt = String.valueof(prd.TF4SF__Rate__c).split('\\.')[0]+'.'+String.valueof(prd.TF4SF__Rate__c).split('\\.')[1].left(2);
										} else {
											rt = '0.00';
										}

										gen.writeStringField('Rate__c', rt + '%');
										//gen.writeStringField('Term__c', (prd.Term__c == null) ? '' : String.valueOf(prd.Term__c) + ' months');
										gen.writeStringField('Term__c', (prd.TF4SF__Term__c == null) ? '' : String.valueOf(prd.TF4SF__Term__c));
										gen.writeStringField('Requested_Term__c', (prd.Requested_Term__c == null) ? '' : String.valueOf(prd.Requested_Term__c));

										if (stat == 'Submitted') {//if starts for submitted
											if (pDocmap.containsKey(prd.Id)) { //Documentation Request records start
												gen.writeFieldName('DocumentationRequests');
												System.debug('debug3333: ');
												gen.writeStartArray();

												for (TF4SF__Documentation_Request__c drq : pDocmap.get(prd.Id)) {
													gen.writeStartObject();
														gen.writeStringField('Id', drq.Id);
														gen.writeStringField('Name', (drq.Name == null) ? '' : drq.Name);
														gen.writeStringField('Application__c', drq.TF4SF__Application__c);
														gen.writeStringField('Description__c', (drq.TF4SF__Description__c == null) ? '' : drq.TF4SF__Description__c);
														gen.writeStringField('External Id', (drq.TF4SF__External_ID__c == null) ? '' : drq.TF4SF__External_ID__c);
														System.debug('debug666: ');
														gen.writeStringField('Product__c', (drq.TF4SF__Product__c == null) ? '' : drq.TF4SF__Product__c);
														gen.writeStringField('Products__c', (drq.TF4SF__Products__c == null) ? '' : drq.TF4SF__Products__c);
														gen.writeStringField('Status__c', (drq.TF4SF__Status__c == null) ? '' : drq.TF4SF__Status__c);
														gen.writeStringField('Type__c', (drq.TF4SF__Type__c == null) ? '' : drq.TF4SF__Type__c);
														System.debug('debug4: ');

														//Attachment Start
														if (dAttmap.containsKey(drq.Id)) {
															gen.writeFieldName('Attachments');
															gen.writeStartArray(); 
																for (Attachment att : dAttmap.get(drq.Id)) {
																	gen.writeStartObject();
																		gen.writeStringField('Id', att.Id);
																		gen.writeStringField('Name', att.Name);
																		gen.writeStringField('ParentId', att.ParentId);
																		gen.writeDateTimeField('LastModifiedDate', att.LastModifiedDate);
																		gen.writeStringField('ContentType',(att.ContentType == null) ? '' : att.ContentType);
																		gen.writeStringField('Description', (att.Description == null) ? '' : att.Description);
																	gen.writeEndObject();
																}
															gen.writeEndArray();
														}//Attachments End

													gen.writeEndObject();
												}

												gen.writeEndArray();
											}//docreqif

											//Notes records begin
											if (pNotemap.containsKey(prd.Id)) {
												gen.writeFieldName('Notes');
												gen.writeStartArray(); 
													for (Note nr : pNotemap.get(prd.Id)) {
														if (nr.isPrivate == false) {
															gen.writeStartObject();
																gen.writeStringField('Id', nr.Id);
																gen.writeStringField('Title', nr.Title);
																gen.writeStringField('Body', (nr.Body == null) ? '' : nr.Body);
																gen.writeStringField('ParentId', nr.ParentId);
																gen.writeBooleanField('IsPrivate', nr.IsPrivate);
																//Swap UserName here
																gen.writeStringField('SiteUser', SiteUser);

																if (nr.Owner.Name == SiteUser) {
																	// put the User Name here
																	// gen.writeStringField('UserName', UName);
																	gen.writeStringField('UserName', aid.TF4SF__Full_Name_PA__c);
																} else {
																	gen.writeStringField('UserName', SiteUser);
																	gen.writeBooleanField('SystemUser', true);
																}

																gen.writeDateTimeField('CreatedDate', nr.CreatedDate);
															gen.writeEndObject();
														}
													}
												gen.writeEndArray();
											}//Notes records end
										} else {
											gen.writeStringField('ResumeUrl', TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + NAMESPACE + 'DSPResumeApplication?id=' + aid.Id + '&usr=' + UserInfo.getUserId());
										}//if ends for submitted

									gen.writeEndObject();
								}
							} else { // Just use the Application Object's details
								gen.writeStartObject();
									gen.writeStringField('Id', aid.Id);
									gen.writeStringField('Name', aid.Name);
									gen.writeStringField('ProductName', aid.TF4SF__Sub_Product__c);
									gen.writeStringField('Email_Address__c', (aid.TF4SF__Email_Address__c == null) ? '' : aid.TF4SF__Email_Address__c);
									gen.writeStringField('Full_Name_PA__c', (aid.TF4SF__Full_Name_PA__c == null) ? '' : aid.TF4SF__Full_Name_PA__c);
									gen.writeStringField('FullName_J__c', (aid.TF4SF__FullName_J__c == null) ? '' : aid.TF4SF__FullName_J__c);
									if (aid.TF4SF__FullName_J2__c != null) { gen.writeStringField('FullName_J2__c', aid.TF4SF__FullName_J2__c); }
									if (aid.TF4SF__FullName_J3__c != null) { gen.writeStringField('FullName_J3__c', aid.TF4SF__FullName_J3__c); }
									gen.writeStringField('Application_Status__c', aid.TF4SF__Application_Status__c);
									/*
									gen.writeStringField('Product_Status', (prd.Product_Type__c == 'Primary') ? aid.TF4SF__Primary_Product_Status__c :
																				(prd.Product_Type__c == 'Cross-sell 1')? aid.TF4SF__Primary_Offer_Status__c :
																				(prd.Product_Type__c == 'Cross-sell 2')? aid.TF4SF__Second_Offer_Status__c: 
																				(prd.Product_Type__c == 'Cross-sell 3')?aid.TF4SF__Third_Offer_Status__c:'');
									*/
									gen.writeDateTimeField('Created_Timestamp__c', aid.TF4SF__Created_Timestamp__c);
									if (aid.TF4SF__Submitted_Timestamp__c != null) { gen.writeDateTimeField('Submitted_Timestamp__c', aid.TF4SF__Submitted_Timestamp__c); }
									gen.writeDateTimeField('LastModifiedDate', aid.LastModifiedDate);
									gen.writeStringField('ProductName', aid.TF4SF__Sub_Product__c);
									if (aid.TF4SF__Application_Status__c != 'Submitted') {
										gen.writeStringField('ResumeUrl', TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'tf4sf__DSPResumeApplication?id=' + aid.Id + '&usr=' + UserInfo.getUserId());
									}

								gen.writeEndObject();
							}//prod null check
						}

					gen.writeEndArray();
					System.debug('gen: ' + gen);
				}//aData
			}

		gen.writeEndObject();
		System.debug('statusjson: ' + gen.getAsString());

		return gen.getAsString();
	}

	@RemoteAction
	global static Map<String, sObject> postData(Map<String, String> tdata, String pageName) {
		System.debug('postdata tdata: '+tdata);
		Map<String, sObject> appData = new Map<String, sObject>();
		Map<String,String> data = tdata.clone();
		Boolean debug = (data.get('debug') == 'true');
		System.debug('data=>' + data);
		System.debug('pageName=>' + pageName);

		try {
			Map<Id, TF4SF__Application__c> appMap = getAppData(data, appData);
			String jsData = generateJSON(appMap, debug);
			System.debug('statusjson: ' + jsData);
			appData.put('statusData', TF4SF.DspUtility.getMessageObject(jsData));
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'postData() Error:' + e.getMessage()));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Stack Trace: postData() line 342:' + e.getStackTraceString()));
		}

		setAppErrors(appData, debug);
		return appData;
	}

	@RemoteAction
	global static Map<String, sObject> userLogin(Map<String, String> tdata) {
		Map<String, sObject> appData = new Map<String, sObject>();
		Map<String,String> data = tdata.clone();
		Boolean debug = (data.get('debug') == 'true');
		Boolean infoDebug = (data.get('infoDebug') == 'true');
		TF4SF.DSPController.debug = debug;
		TF4SF.DSPController.infoDebug = infoDebug;

		try {
			setNameSpace();
			if (appconfig.TF4SF__IntegrationClass_ML__c != NULL) {
				Map<String,String> response = TF4SF.DSPController.callExtensionClass(data, appconfig.TF4SF__IntegrationClass_ML__c);
				System.debug('response: ' + response);
				//appData.put('response', TF4SF.DspUtility.getMessageObject(JSON.serialize(response)));
			} else {
				Map<Id, TF4SF__Application__c> appMap = getAppData(data, appData);
				String jsData = generateJSON(appMap, debug);
				System.debug('statusjson: ' + jsData);
				appData.put('statusData', TF4SF.DspUtility.getMessageObject(jsData));
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'userLogin() Error:' + e.getMessage()));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Stack Trace: userLogin() line 224:' + e.getStackTraceString()));
		}
	
		setAppErrors(appData, debug);
		return appData;
	}

	@RemoteAction
	public static Map<String, sObject> addMessage(Map<String, String> data) {
		Map<String, sObject> appData = new Map<String, sObject>();
		String prodId = data.get('prodId');
		String msgText = data.get('msgText');
		Boolean debug = (data.get('debug') == 'true');
		String msgTitle = 'Message from User';
		Note rtn = new Note();

		if (prodId != null) {
			Note n = new Note();
			if (Schema.sObjectType.Note.fields.ParentId.isCreateable()) { n.ParentId = prodId; }
			if (Schema.sObjectType.Note.fields.Title.isCreateable() && Schema.sObjectType.Note.fields.Title.isUpdateable()) { n.Title = msgTitle; }
			if (Schema.sObjectType.Note.fields.Body.isCreateable() && Schema.sObjectType.Note.fields.Body.isUpdateable()) { n.Body = msgText; }
			if (Note.sObjectType.getDescribe().isCreateable()) { insert n; }
			if (n.Id != null) {
				rtn = [SELECT Id, Title, Body, ParentId, IsPrivate, OwnerId, CreatedDate, Owner.Name, Owner.CommunityNickname FROM Note WHERE Id = :n.Id LIMIT 1];
			}

			appData.put('Note', rtn);
		} else {
		  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Id is null'));
		}

		setAppErrors(appData, debug);
		return appData;
	}
}