global with sharing class DocusignTemplateSigning implements TF4SF.DSP_Interface{

	global Map<String,String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Map<String,String> data = tdata.clone();
		String appId = data.get('id');
		System.debug('the app Id ' + appId);
		Boolean infoDebug = (tdata.get('infoDebug') == 'true');
		TF4SF.Logger.inputSource('Docusign class',appId);
		Set<String> fieldsToDisplay = new Set<String>(); // This string is used to contain the fields received from Utility class.
		TF4SF.DSPUtility u = new TF4SF.DSPUtility();
		TF4SF.RequiredFieldsUtility rfu = new TF4SF.RequiredFieldsUtility();
		fieldsToDisplay = u.fieldsToRender(appId);
		System.debug('the fields rendered are ' + fieldsToDisplay.size());
		String username = '';
		String password = '';
		String integratorKey = '';
		String templateId = '';
		String roleName = '';
		String clientUserId = '';
		String accountId = '';   // we will retrieve this through the Login API call
		TF4SF__Application__c app = new TF4SF__Application__c();
		TF4SF__Application2__c app2 = new TF4SF__Application2__c();
		TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
		TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
		TF4SF__Identity_Information__c idn = new TF4SF__Identity_Information__c();

		List<Docusign_Prefill_Fields__c> dpf = Docusign_Prefill_Fields__c.getAll().values();
		List<Docusign_Prefill_Fields__c> textdpf = new List<Docusign_Prefill_Fields__c>();
		List<Docusign_Prefill_Fields__c> checkboxdpf = new List<Docusign_Prefill_Fields__c>();

		List<String> appQueryFields = new List<String>{'TF4SF__First_Joint_Applicant__c','TF4SF__Second_Joint_Applicant__c','TF4SF__Third_Joint_Applicant__c','TF4SF__Email_Address__c','TF4SF__First_Name__c','TF4SF__Last_Name__c', 'TF4SF__Email_Address_J__c', 'TF4SF__First_Name_J__c', 'TF4SF__Last_Name_J__c', 'TF4SF__Email_Address_J2__c', 'TF4SF__First_Name_J2__c', 'TF4SF__Last_Name_J2__c', 'TF4SF__Email_Address_J3__c', 'TF4SF__First_Name_J3__c','TF4SF__Last_Name_J3__c','Is_Existing_Member__c'};
		Set<String> appQueryFieldSet = new Set<String>();
		List<String> appQueryFieldList = new List<String>();

		List<String> app2QueryFields = new List<String>();
		Set<String> app2QueryFieldSet = new Set<String>();
		List<String> app2QueryFieldList = new List<String>();

		List<String> accQueryFields = new List<String>();
		Set<String> accQueryFieldSet = new Set<String>();
		List<String> accQueryFieldList = new List<String>();

		List<String> empQueryFields = new List<String>();
		Set<String> empQueryFieldSet = new Set<String>();
		List<String> empQueryFieldList = new List<String>();

		List<String> idnQueryFields = new List<String>();
		Set<String> idnQueryFieldSet = new Set<String>();
		List<String> idnQueryFieldList = new List<String>();

		for (Docusign_Prefill_Fields__c dd : dpf) {
			//System.debug('the list is ' + dd.Field_Name__c);

			if (dd.Object__c != NULL) {
				if (dd.Object__c == 'TF4SF__Application__c') {
					if (dd.Field_Name__c != NULL) {
						appQueryFieldSet.add(dd.Field_Name__c);
					}
				} else if (dd.Object__c == 'TF4SF__Application2__c') {
					if (dd.Field_Name__c != NULL) {
						app2QueryFieldSet.add(dd.Field_Name__c);
					}
				} else if (dd.Object__c == 'TF4SF__About_Account__c') {
					if (dd.Field_Name__c != NULL) {
						accQueryFieldSet.add(dd.Field_Name__c);
					}
				} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
					if (dd.Field_Name__c != NULL) {
						empQueryFieldSet.add(dd.Field_Name__c);
					}
				} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
					if (dd.Field_Name__c != NULL) {
						idnQueryFieldSet.add(dd.Field_Name__c);
					}
				}
			}
		}

		appQueryFieldSet.addAll(appQueryFields); // combining prefill fields with required fields to query in a set
		appQueryFieldList.addAll(appQueryFieldSet); // List of the queryFieldSet.

		app2QueryFieldSet.addAll(app2QueryFields); // combining prefill fields with required fields to query in a set
		app2QueryFieldList.addAll(app2QueryFieldSet); // List of the queryFieldSet.

		accQueryFieldSet.addAll(accQueryFields); // combining prefill fields with required fields to query in a set
		accQueryFieldList.addAll(accQueryFieldSet); // List of the queryFieldSet.

		empQueryFieldSet.addAll(empQueryFields); // combining prefill fields with required fields to query in a set
		empQueryFieldList.addAll(empQueryFieldSet); // List of the queryFieldSet.

		idnQueryFieldSet.addAll(idnQueryFields); // combining prefill fields with required fields to query in a set
		idnQueryFieldList.addAll(idnQueryFieldSet); // List of the queryFieldSet.

		try {
			if (!appQueryFieldList.isEmpty()) {
				//System.debug('the app query '+String.join(new List<String>(appQueryFieldList), ', '));
				String appQuery = 'SELECT ' + String.join(new List<String>(appQueryFieldList), ', ') + ' FROM TF4SF__Application__c' + ' WHERE id =\'' + appId + '\'';
				System.debug('the app query '+appQuery);
				app = database.query(appQuery);
			}

			if (!app2QueryFieldList.isEmpty()) {
				String app2Query = 'SELECT ' + String.join(new List<String>(app2QueryFieldList), ', ') + ' FROM TF4SF__Application2__c' + ' WHERE TF4SF__Application__c =\'' + appId+  '\'';
				System.debug('the app2 query '+app2Query);
				app2 = database.query(app2Query);	
			}

			if (!accQueryFieldList.isEmpty()) {
				String accQuery = 'SELECT ' + String.join(new List<String>(accQueryFieldList), ', ') + ' FROM TF4SF__About_Account__c' + ' WHERE TF4SF__Application__c =\'' + appId + '\'';
				System.debug('the acc query '+accQuery);
				acc = database.query(accQuery);
			}

			if (!empQueryFieldList.isEmpty()) {
				String empQuery = 'SELECT ' + String.join(new List<String>(empQueryFieldList), ', ') + ' FROM TF4SF__Employment_Information__c' + ' WHERE TF4SF__Application__c =\'' + appId + '\'';
				System.debug('the emp query '+empQuery);
				emp = database.query(empQuery);
			}

			if (!idnQueryFieldList.isEmpty()) {
				String idnQuery = 'SELECT ' + String.join(new List<String>(idnQueryFieldList), ', ') + ' FROM TF4SF__Identity_Information__c' + ' WHERE TF4SF__Application__c = \'' + appId + '\'';
				System.debug('the idn query '+idnQuery);
				idn = database.query(idnQuery);
			}
		} catch (Exception ex) {
			System.debug('Exception: ' + ex + '; ' + ex.getLineNumber() +' and message is '+ex.getMessage());
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));      
		}


		//TF4SF__Application__c app = [SELECT TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__Email_Address__c FROM TF4SF__Application__c WHERE Id = :appId];
		Docusign_Config__c cred = Docusign_Config__c.getOrgDefaults();
		TF4SF__Application_Configuration__c ac = TF4SF__Application_Configuration__c.getOrgDefaults();
		Integer noOfApplicants = 1;
		System.debug('Call Joints ' + ac.Call_Joint_Docusign__c);
		System.debug('Joint 1 ' + app.TF4SF__First_Joint_Applicant__c);
		System.debug('Joints 2 ' + app.TF4SF__Second_Joint_Applicant__c);
		System.debug('Joints 3 ' + app.TF4SF__Third_Joint_Applicant__c);
		if (ac.Call_Joint_Docusign__c == true) {
			if (app.TF4SF__First_Joint_Applicant__c == true) {
				noOfApplicants = 2;
				if (app.TF4SF__Second_Joint_Applicant__c == true) {
					noOfApplicants = 3;
					if (app.TF4SF__Third_Joint_Applicant__c == true) {
						noOfApplicants = 4;
					}
				}
			} 
		}

		System.debug('the no of applicants are ' + noOfApplicants);
		if (cred != NULL) {
			accountId = cred.AccountID__c;
			username = cred.Username__c;
			password = cred.Password__c;
			integratorKey = cred.IntegratorKey__c ;
		}

		String recipientName = app.TF4SF__First_Name__c + ' ' + app.TF4SF__Last_Name__c;
		String recipientEmail = app.TF4SF__Email_Address__c;
		roleName = 'Signer';
		List<TF4SF__Disclosure_Names__c> ddn = [SELECT Name, TF4SF__Disclosure_Label__c FROM TF4SF__Disclosure_Names__c];
		System.debug('The size of the list is ' + ddn.size());
		List<TF4SF__Disclosure__c> discList = new List<TF4SF__Disclosure__c>();
		// construct the DocuSign authentication header
		String authenticationHeader =
			'<DocuSignCredentials>' +
			'<Username>' + username + '</Username>' +
			'<Password>' + password + '</Password>' +
			'<IntegratorKey>' + integratorKey + '</IntegratorKey>' +
			'</DocuSignCredentials>';

		// additional variable declarations
		String baseURL = '';     // we will retrieve this through the Login API call
		String url = '';     // end-point for each api call
		String body = '';    // request body
		String response = '';    // response body
		Integer status;  // response status
		HttpResponse res = null;
		String resBody;  // connection object used for each request

		//============================================================================
		// STEP 1 - Make the Login API call to retrieve your baseUrl and accountId
		//============================================================================

		url = 'https://demo.docusign.net/restapi/v2/login_information';
		body = '';  // no request body for the login call

		if (!Test.isRunningTest()) {
			res = InitializeRequest(url, 'GET', body, authenticationHeader);
			status = res.getStatusCode();
			resBody = res.getBody();

			if (status != 200) { // 200 = OK
				data.put('Docusing Embedded Signing URL', 'Failure at 200');
				return data;
			}
		}

		// obtain baseUrl and accountId values from response body 
		baseURL = parseXMLBody(resBody, 'baseUrl');
		accountId = parseXMLBody(resBody, 'accountId');

		//============================================================================
		// STEP 2 - Signature Request from Document API Call
		//============================================================================

		url = baseURL + '/envelopes';   // append '/envelopes' to baseUrl for signature request call
		String tempArray = '';
		String bodyEncoded = '';
		Integer n = 0; //number of documents
		List<String> tIdList = new List<String>();
		List<TF4SF__Disclosure__c> newdiscList = new List<TF4SF__Disclosure__c>();

		for (Integer i = 0; i < ddn.size(); i++) {
			//System.debug('the value of i ' + i);
			//if (fieldsToDisplay.contains(ddn[i].Name + '__c')) {
				//System.debug('the disclosure Name is ' + ddn[i].TF4SF__Disclosure_Label__c + ' - DS');
				//TF4SF__Disclosure__c disclosure = [SELECT Id, Name, Template_ID__c, Joint1_Template_ID__c, Joint2_Template_ID__c, Joint3_Template_ID__c FROM TF4SF__Disclosure__c WHERE Name = :(ddn[i].TF4SF__Disclosure_Label__c + ' - DS')];
				newdiscList = [SELECT Id, Name, Template_ID__c, Joint1_Template_ID__c, Joint2_Template_ID__c, Joint3_Template_ID__c, Document_Order__c FROM TF4SF__Disclosure__c WHERE Template_ID__c != NULL ORDER BY Document_Order__c ASC];
				//newdiscList.add(disclosure);
			//}
		}

		System.debug('the size of the Disclosure ' + newdiscList.size());
		if (app.Is_Existing_Member__c == true) {
			if (newdiscList.size() > 1) {
				newdiscList.remove(1);
				System.debug('removed disclosure '+ newdiscList);	
			}
			
		}
		for (TF4SF__Disclosure__c disc : newdiscList) {
			if (noOfApplicants == 1) {
				tIdList.add(disc.Template_ID__c);
			} else if (noOfApplicants == 2) {
				if (String.isNotBlank(disc.Joint1_Template_ID__c)) {
					tIdList.add(disc.Joint1_Template_ID__c);	
				} 
			} else if (noOfApplicants == 3) {
				if (String.isNotBlank(disc.Joint2_Template_ID__c)) {
					tIdList.add(disc.Joint2_Template_ID__c);
				}
			} else if (noOfApplicants == 4) {
				if (String.isNotBlank(disc.Joint3_Template_ID__c)) {
					tIdList.add(disc.Joint3_Template_ID__c);
				}
			}
		}

		System.debug('the size of the Template Id\'s ' + tIdList.size());
		String recipients = '';


		for (Integer h = 1; h <= noOfApplicants; h++) {
			if (h == 1) {
				recipients += '<signer>';
				recipients += '<email>' + app.TF4SF__Email_Address__c + '</email>';
				recipients += '<name>' + app.TF4SF__First_Name__c + ' ' + app.TF4SF__Last_Name__c + '</name>';
				recipients += '<recipientId>' + h + '</recipientId>';
				recipients += '<roleName>' + roleName + ' ' + h + '</roleName>';
				recipients += '<clientUserId>' + '100' + h + '</clientUserId>';

				if (!dpf.isEmpty()) {
					recipients += '<tabs xmlns=\'https://www.docusign.com/restapi\'>';	
					for (Docusign_Prefill_Fields__c dd : dpf) {
						if (dd.Type__c == 'Checkbox') {
							checkboxdpf.add(dd);
						} else {
							textdpf.add(dd);
						}
					}
					if (!checkboxdpf.isEmpty()) {
						recipients += '<checkboxTabs>';
						for (Docusign_Prefill_Fields__c dd : checkboxdpf) {
							if (dd.Type__c == 'Checkbox') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (dd.Value__c == String.valueOf(app.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (dd.Value__c == String.valueOf(app2.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (dd.Value__c == String.valueOf(acc.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (dd.Value__c == String.valueOf(emp.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (dd.Value__c == String.valueOf(idn.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} 
							}
						}
						recipients += '</checkboxTabs>';
					}

					if (!textdpf.isEmpty()) {
						recipients += '<textTabs>';
						for (Docusign_Prefill_Fields__c dd : textdpf) {
							if (dd.Type__c == 'Text') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(app.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(app2.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(acc.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(emp.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(idn.get(dd.Field_Name__c)));
								}
							} else if (dd.Type__c == 'Date') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (app.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(app.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (app2.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(app2.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (acc.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(acc.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);	
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (emp.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(emp.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);	
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (idn.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(idn.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								}
							} else if (dd.Type__c == 'Currency') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (app.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(app.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);

										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);

											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (app2.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(app2.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (acc.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(acc.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (emp.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(emp.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (idn.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(idn.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								}
							}
						}
						recipients += '</textTabs>';
					}
					recipients += '</tabs>';
				}
				recipients += '</signer>';
			} else if (h == 2) {
				recipients += '<signer>';
				recipients += '<email>' + app.TF4SF__Email_Address_J__c + '</email>';
				recipients += '<name>' + app.TF4SF__First_Name_J__c + ' ' + app.TF4SF__Last_Name_J__c + '</name>';
				recipients += '<recipientId>' + h + '</recipientId>';
				recipients += '<roleName>' + roleName + ' ' + h + '</roleName>';
				recipients += '<clientUserId>' + '100' + h + '</clientUserId>';
				if (!dpf.isEmpty()) {
					recipients += '<tabs xmlns=\'https://www.docusign.com/restapi\'>';	
					for (Docusign_Prefill_Fields__c dd : dpf) {
						if (dd.Type__c == 'Checkbox') {
							checkboxdpf.add(dd);
						} else {
							textdpf.add(dd);
						}
					}
					if (!checkboxdpf.isEmpty()) {
						recipients += '<checkboxTabs>';
						for (Docusign_Prefill_Fields__c dd : checkboxdpf) {
							if (dd.Type__c == 'Checkbox') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (dd.Value__c == String.valueOf(app.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (dd.Value__c == String.valueOf(app2.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (dd.Value__c == String.valueOf(acc.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (dd.Value__c == String.valueOf(emp.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (dd.Value__c == String.valueOf(idn.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} 
							}
						}
						recipients += '</checkboxTabs>';
					}

					if (!textdpf.isEmpty()) {
						recipients += '<textTabs>';
						for (Docusign_Prefill_Fields__c dd : textdpf) {
							if (dd.Type__c == 'Text') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(app.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(app2.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(acc.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(emp.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(idn.get(dd.Field_Name__c)));
								}
							} else if (dd.Type__c == 'Date') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (app.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(app.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (app2.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(app2.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (acc.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(acc.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);	
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (emp.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(emp.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);	
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (idn.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(idn.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								}
							} else if (dd.Type__c == 'Currency') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (app.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(app.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);

										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);

											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (app2.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(app2.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (acc.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(acc.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (emp.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(emp.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (idn.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(idn.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								}
							}
						}
						recipients += '</textTabs>';
					}
					recipients += '</tabs>';
				}
				recipients += '</signer>';
			} else if (h == 3) {
				recipients += '<signer>';
				recipients += '<email>' + app.TF4SF__Email_Address_J2__c + '</email>';
				recipients += '<name>' + app.TF4SF__First_Name_J2__c + ' ' + app.TF4SF__Last_Name_J2__c + '</name>';
				recipients += '<recipientId>' + h + '</recipientId>';
				recipients += '<roleName>' + roleName + ' ' + h + '</roleName>';
				recipients += '<clientUserId>' + '100' + h + '</clientUserId>';
				if (!dpf.isEmpty()) {
					recipients += '<tabs xmlns=\'https://www.docusign.com/restapi\'>';	
					for (Docusign_Prefill_Fields__c dd : dpf) {
						if (dd.Type__c == 'Checkbox') {
							checkboxdpf.add(dd);
						} else {
							textdpf.add(dd);
						}
					}
					if (!checkboxdpf.isEmpty()) {
						recipients += '<checkboxTabs>';
						for (Docusign_Prefill_Fields__c dd : checkboxdpf) {
							if (dd.Type__c == 'Checkbox') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (dd.Value__c == String.valueOf(app.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (dd.Value__c == String.valueOf(app2.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (dd.Value__c == String.valueOf(acc.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (dd.Value__c == String.valueOf(emp.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (dd.Value__c == String.valueOf(idn.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} 
							}
						}
						recipients += '</checkboxTabs>';
					}

					if (!textdpf.isEmpty()) {
						recipients += '<textTabs>';
						for (Docusign_Prefill_Fields__c dd : textdpf) {
							if (dd.Type__c == 'Text') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(app.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(app2.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(acc.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(emp.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(idn.get(dd.Field_Name__c)));
								}
							} else if (dd.Type__c == 'Date') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (app.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(app.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (app2.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(app2.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (acc.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(acc.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);	
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (emp.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(emp.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);	
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (idn.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(idn.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								}
							} else if (dd.Type__c == 'Currency') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (app.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(app.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);

										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);

											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (app2.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(app2.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (acc.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(acc.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (emp.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(emp.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (idn.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(idn.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								}
							}
						}
						recipients += '</textTabs>';
					}
					recipients += '</tabs>';
				}
				recipients += '</signer>';

			} else if (h == 4) {
				recipients += '<signer>';
				recipients += '<email>' + app.TF4SF__Email_Address_J3__c + '</email>';
				recipients += '<name>' + app.TF4SF__First_Name_J3__c + ' ' + app.TF4SF__Last_Name_J3__c + '</name>';
				recipients += '<recipientId>' + h + '</recipientId>';
				recipients += '<roleName>' + roleName + ' ' + h + '</roleName>';
				recipients += '<clientUserId>' + '100' + h + '</clientUserId>';
				if (!dpf.isEmpty()) {
					recipients += '<tabs xmlns=\'https://www.docusign.com/restapi\'>';	
					for (Docusign_Prefill_Fields__c dd : dpf) {
						if (dd.Type__c == 'Checkbox') {
							checkboxdpf.add(dd);
						} else {
							textdpf.add(dd);
						}
					}
					if (!checkboxdpf.isEmpty()) {
						recipients += '<checkboxTabs>';
						for (Docusign_Prefill_Fields__c dd : checkboxdpf) {
							if (dd.Type__c == 'Checkbox') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (dd.Value__c == String.valueOf(app.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (dd.Value__c == String.valueOf(app2.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (dd.Value__c == String.valueOf(acc.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (dd.Value__c == String.valueOf(emp.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (dd.Value__c == String.valueOf(idn.get(dd.Field_Name__c))) {
										//System.debug('inside the if clouse');
										recipients += updateDocusignTabCheckbox(dd.Name, 'X');
									} else {
										recipients += updateDocusignTabCheckbox(dd.Name, '');
									}
								} 
							}
						}
						recipients += '</checkboxTabs>';
					}

					if (!textdpf.isEmpty()) {
						recipients += '<textTabs>';
						for (Docusign_Prefill_Fields__c dd : textdpf) {
							if (dd.Type__c == 'Text') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(app.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(app2.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(acc.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(emp.get(dd.Field_Name__c)));
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									recipients += updateDocusignTab(dd.Name, String.valueOf(idn.get(dd.Field_Name__c)));
								}
							} else if (dd.Type__c == 'Date') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (app.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(app.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (app2.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(app2.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (acc.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(acc.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);	
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (emp.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(emp.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);	
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (idn.get(dd.Field_Name__c) != null) {
										Date DateFr = Date.valueOf(idn.get(dd.Field_Name__c));
										String DateFormated = DateTime.newInstance(DateFr.year(),DateFr.month(),DateFr.day()).format('MMMMM dd, yyyy');
										System.debug('The Date is ' + DateFormated);
										recipients += updateDocusignTab(dd.Name, DateFormated);
									}
								}
							} else if (dd.Type__c == 'Currency') {
								if (dd.Object__c == 'TF4SF__Application__c') {
									if (app.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(app.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);

										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);

											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Application2__c') {
									if (app2.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(app2.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__About_Account__c') {
									if (acc.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(acc.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Employment_Information__c') {
									if (emp.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(emp.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								} else if (dd.Object__c == 'TF4SF__Identity_Information__c') {
									if (idn.get(dd.Field_Name__c) != null) {
										String fValue = String.valueOf(idn.get(dd.Field_Name__c));
										Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
										Matcher pMatcher = alphaPattern.matcher(fValue);
										if (pMatcher.matches() == false) {
											Decimal decValue = Decimal.valueOf(fValue);
											List<String> args = new String[]{'0','number','###,###,##0.00'};
											fValue = String.format(decValue.format(), args);
											if (fValue.contains('.')) {
												List<String> sList = fValue.split('\\.');
												//System.debug('sList ' + sList);
												if (sList.size() > 1) {
													if (sList[1].length() == 1) {
														fValue = fValue + '0';
														System.debug('fValue with a point = ' + fValue);
													}
												}
											} else {
												fValue =  fValue + '.' + '00';
											}
										}
										if (fValue != null) {
											recipients += updateDocusignTab(dd.Name, fValue);
										}
									}
								}
							}
						}
						recipients += '</textTabs>';
					}
					recipients += '</tabs>';
				}
				recipients += '</signer>';
			}
		}

		System.debug('The recipients body is ' + recipients);
		if (tIdList.size() > 0) {
			for (Integer j = 0; j < tIdList.size(); j++) {
				tempArray = tempArray + '<compositeTemplates>' +
				'<compositeTemplate>' +
				'<serverTemplates>' +
				'<serverTemplate>' +
				'<sequence>1</sequence>' +
				'<templateId>' + tIdList.get(j) + '</templateId>' +
				'</serverTemplate>' +
				'</serverTemplates>' +
				'<inlineTemplates>' +
				'<inlineTemplate>' +
				'<sequence>2</sequence>' +
				'<recipients>' +
				'<signers>' + recipients + '</signers>' +
				'</recipients>' +
				'</inlineTemplate>' +
				'</inlineTemplates>' +
				'</compositeTemplate>' +
				'</compositeTemplates>';
			}
		}

		System.debug('the array of templateid is ' + tempArray);

		//Single template id example callout REST API
		/* templateId ='1673B9A2-8079-425D-84FB-EC40A1454092';

		body =  '<envelopeDefinition xmlns=\'https://www.docusign.com/restapi\'>' +
		'<status>sent</status>' + 
		'<accountId>' + accountId + '</accountId>' +
		'<emailSubject>Please sign the Disclosures below</emailSubject>' +
		'<templateId>' +  templateId  + '</templateId>' + 
		'<templateRoles>' +
		'<templateRole>' +
		'<email>' + recipientEmail + '</email>' +
		'<name>' + recipientName + '</name>' +
		'<roleName>' + roleName + '</roleName>' +
		'<clientUserId>1001</clientUserId>' +
		'</templateRole>' +
		'</templateRoles>' +
		'</envelopeDefinition>';*/

		body = '<envelopeDefinition xmlns=\'https://www.docusign.com/restapi\'>' +
		'<status>sent</status>' +
		'<accountId>' + accountId + '</accountId>' +
		'<emailSubject>Please sign the Disclosures below</emailSubject>' +
		'<emailBlurb>Test Email Body</emailBlurb>' +
		tempArray +
		'</envelopeDefinition>';

		System.debug('The Body Build is ' + body);

		if (!Test.isRunningTest()) {
			res = InitializeRequest(url,'POST', body, authenticationHeader);
			status = res.getStatusCode();
			resBody = res.getBody();
			if (status != 201) {// 201 = Created
				data.put('Docusign Embedded Signing URL', '201 Failure');
				return data;
			}
		}

		// obtain envelope uri from response body
		String uri = parseXMLBody(resBody, 'uri');

		System.debug('uri is: ' + uri + '/spaces');
		String envelope = uri.replace('/envelopes/', '');
		System.debug('token is ' + uri.replace('/envelopes/', ''));
		System.debug('url for envelopes is ' + baseURL + uri);
		//============================================================================
		// STEP 3 - Get the Embedded Signing View
		//============================================================================
		TF4SF__SiteUrl__c siteurl = TF4SF__SiteUrl__c.getOrgDefaults();
		String destination = '';
		if (noOfApplicants == 1) {
			destination = 'https://kpcu.com/';
		} else if (noOfApplicants >= 2) {
			destination = siteurl.TF4SF__Url__c+'DocusignRedirectPage?appId='+appId;
			destination += ':2';
		//} else if (noOfApplicants == 3) {
		//	destination = siteurl.TF4SF__Url__c+'DocusignRedirectPage?appId='+appId;
		//	destination += ':3';
		//} else if (noOfApplicants == 4) {
		//	destination = siteurl.TF4SF__Url__c+'DocusignRedirectPage?appId='+appId;
		//	destination += ':4';
		}
		System.debug('The destination is '+destination);
		url = baseURL + uri + '/views/recipient';   // append envelope uri + 'views/recipient' to url

		body = '<recipientViewRequest xmlns=\'https://www.docusign.com/restapi\'>'  +
		'<authenticationMethod>email</authenticationMethod>' +
		'<email>' + recipientEmail + '</email>' +
		'<returnUrl>' + destination + '</returnUrl>' +
		'<userName>' + recipientName + '</userName>' +
		'<clientUserId>1001</clientUserId>' +
		'</recipientViewRequest>';
		System.debug('The Body is '+body);
		if (!Test.isRunningTest()) {
			res = InitializeRequest(url, 'POST', body, authenticationHeader);
			status = res.getStatusCode();
			if (status != 201)  {// 201 = Created
				data.put('Docusign Embedded Signing URL', 'Failure at 201');
				return data;
			}

			resBody = res.getBody();
			String urlToken = parseXMLBody(resBody, 'url');
			System.debug('URL TOKEN '  + urlToken);

			app.Docusign_EnvelopeID__c = uri.replace('/envelopes/','');
			update app;
			data.put('Docusign Embedded Signing URL', urlToken);
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'DocusignTemplateSigning - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DocusignTemplateSigning - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	} //end main()

	public String updateDocusignTab(String tabName, String prefillValue) {
		if (prefillValue == null) {
			prefillValue = '';
		}
		String TextXML = '';
				//TextXML += '<textTabs>';
				TextXML += '<text>';
				TextXML += '<name>' + tabName + '</name>';
				TextXML += '<tabLabel>' + tabName + '</tabLabel>';
				TextXML += '<value>' + prefillValue.escapeXml() + '</value>';
				TextXML += '</text>';
				//TextXML += '</textTabs>';
		return TextXML;
	}
	
	public String updateDocusignTabCheckbox(String tabName, String prefillValue) {
		String checkboxXML = '';
				//checkboxXML += '<checkboxTabs>';
				checkboxXML += '<checkbox>';
				checkboxXML += '<name>' + tabName + '</name>';
				checkboxXML += '<tabLabel>' + tabName + '</tabLabel>';
				if (String.isNotBlank(prefillValue)) {
					checkboxXML += '<selected>true</selected>';
				} else {
					checkboxXML += '<selected>false</selected>';
				}
				checkboxXML += '<value>' + prefillValue + '</value>';
				checkboxXML += '</checkbox>';
				//checkboxXML += '</checkboxTabs>';
		return checkboxXML;
	}

	// --- HELPER FUNCTIONS ---
	global static HttpResponse InitializeRequest(String url, String method, String body, String httpAuthHeader) {
		HttpResponse res = null;

		try {
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint(url);
			req.setHeader('X-DocuSign-Authentication', httpAuthHeader);
			req.setHeader('Content-Type', 'application/xml');
			req.setHeader('Accept', 'application/xml');
			req.setMethod(method);

			if (method == 'POST') {
				req.setHeader('Content-Length', String.valueOf(body.length()));
				req.setbody(body);
			}

			res = http.send(req);
			System.debug('the response is:' + res);
			System.debug('the body of the response is:' + res.getBody());
		} catch (Exception e) {
			System.debug(e); // simple exception handling, please review it
		}

		return res;
	}

	global static String parseXMLBody(String body, String searchToken) {
		System.debug('Body : ' + body + 'Token : ' + searchToken);
		String value = '';

		if (body!= '' && body!= NULL) {
			Dom.Document doc1 = new Dom.Document();
			doc1.load(body);
			Dom.XMLNode xroot1 = doc1.getrootelement();
			Dom.XMLNode[] xrec1 = xroot1.getchildelements(); //Get all Record Elements

			for (Dom.XMLNode firstInnerChild : xrec1) { //Loop Through Records
				if (firstInnerChild.getname() == searchToken) {
					value = firstInnerChild.gettext();
					break;
				} else {
					Dom.XMLNode[] xrec2 = NULL;
					xrec2 = firstInnerChild.getchildelements();

					if (xrec2 != NULL) {
						for (Dom.XMLNode secondInnerChild : xrec2) {
							if (secondInnerChild.getname() == 'loginAccount') {
								for (Dom.XMLNode thirdInnerChild : secondInnerChild.getchildren()) {
									if (thirdInnerChild.getname() == searchToken) {
										System.debug('values is: ' +  thirdInnerChild.gettext());
										value = thirdInnerChild.gettext();
									}

									if (value != '') { break; }
								}
							}

							if (value != '') { break; }
						}
					}
				}

				if (value != '') { break; }
			}
		}

		return value;
	}
} // End Class