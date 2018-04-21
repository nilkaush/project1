public class ApplicationHandler {
	
	public static void sendEmailProdStatus(List<TF4SF__Application__c> newList, Map<Id, TF4SF__Application__c> oldMap) {
		Map<String, EmailTemplate> etMap = new Map<String, EmailTemplate>();
		Boolean emailAddress = false;
		List<Id> prodId = new List<Id>();
		Map<Id, List<TF4SF__Products__c>> appProdMap = new Map<Id, List<TF4SF__Products__c>>();

		Map<String,String> emailMap;
		emailMap= new Map<String, String>();
		List<OrgWideEmailAddress> emailList = [SELECT Id, Address FROM OrgWideEmailAddress];
		for (OrgWideEmailAddress o : emailList) { emailMap.put(o.Address, o.id); }
		System.debug(emailMap);

		for (EmailTemplate et : [SELECT Id, DeveloperName, HTMLValue FROM EmailTemplate]) { etMap.put(et.DeveloperName, et); }
		System.debug('etMap: ' + etMap);
		List<String> appList = new List<String>();
		for (TF4SF__Application__c app : newList) { appList.add(app.Id); }
		EmailTemplate templateId;
		Map<Id, TF4SF__Products__c> prodMap = new Map<Id, TF4SF__Products__c>([SELECT Id, Name, TF4SF__Product_Name__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Primary_Product_Status__c, TF4SF__Requested_Loan_Amount__c, TF4SF__Term__c, TF4SF__Rate__c, (SELECT Id, Name, TF4SF__Type__c, TF4SF__Products__c FROM TF4SF__Documentation_Requests__r) FROM TF4SF__Products__c WHERE TF4SF__Application__c IN :appList]);
		List<TF4SF__About_Account__c> lstAccount = [SELECT Id, Name, CERT_Account_Number_External__c, TF4SF__CERT_Account_Number__c, SAV_Account_Number_External__c, TF4SF__SAV_Account_Number__c, CHK_Account_Number_External__c, TF4SF__CHK_Account_Number__c FROM TF4SF__About_Account__c WHERE TF4SF__Application__c IN :appList];

		for (TF4SF__Products__c p : prodMap.values()) {
			if (appProdMap.containskey(p.TF4SF__Application__c)) {
				appProdMap.get(p.TF4SF__Application__c).add(p);
			} else {
				appProdMap.put(p.TF4SF__Application__c, new List<TF4SF__Products__c>{p});
			}
		}

		System.debug('------' + appProdMap.size());
		List<Messaging.SingleEmailMessage> mailsList =  new List<Messaging.SingleEmailMessage>();
		List<String> stipulations = new List<String>();

		try {
			for (TF4SF__Application__c app : newList) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String emailBody;
				System.debug('------' + oldMap.get(app.Id).TF4SF__Primary_Product_Status__c);
				System.debug('-------' + app.TF4SF__Primary_Product_Status__c);

				if (app.TF4SF__Primary_Product_Status__c == 'approved' && app.TF4SF__Application_Status__c == 'Submitted' && ((oldMap.get(app.Id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) || (oldMap.get(app.Id).TF4SF__Application_Status__c != app.TF4SF__Application_Status__c))) {
					if (appProdMap.size() > 0) {
						for (TF4SF__Products__c prd : appProdMap.get(app.Id)) {
							if (prd.TF4SF__Product_Name__c == app.TF4SF__Sub_Product__c) {// && String.isNotBlank(String.ValueOf(prd.TF4SF__Term__c)) && String.isNotBlank(String.ValueOf(prd.TF4SF__Rate__c)) && String.isNotBlank(String.ValueOf(prd.TF4SF__Requested_Loan_Amount__c))) {
								if (prd.TF4SF__Product_Name__c.contains('Vehicle Loans') && app.TF4SF__Current_Channel__c == 'Online') {
									templateId = etMap.get('Online_Application_Approved_Auto_Loan');
									System.debug('templateId: ' + templateId);
									stipulations.add('Current Photo Identification');
									stipulations.add('Proof of Current Auto Insurance');
									System.debug('stipulations: ' + stipulations);
									for (TF4SF__Documentation_Request__c dr : prodMap.get(prd.Id).TF4SF__Documentation_Requests__r) { stipulations.add(dr.TF4SF__Type__c); }
									System.debug('prod stipulations: ' + stipulations);
									String stipulation = '<ul>';
									for (String stip : stipulations) { stipulation += '<li>' + stip + '</li>'; }
									stipulation += '</ul>';
									System.debug('stipulationnnnn: ' + stipulation);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__First_Name__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace('{!Stipulations}', stipulation);

									if (prd.TF4SF__Requested_Loan_Amount__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', String.ValueOf(prd.TF4SF__Requested_Loan_Amount__c));
									}

									if ((prd.TF4SF__Term__c != null)) {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', String.ValueOf(prd.TF4SF__Term__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', '');
									}

									if (prd.TF4SF__Rate__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', String.ValueOf(prd.TF4SF__Rate__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', '');
									}

									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Online Application Approved - Auto Loan');
									String orgIds = '';
									if (emailMap.containsKey('sukesh.gurmekodi@terafinainc.com')) { orgIds = emailMap.get('sukesh.gurmekodi@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								if (prd.TF4SF__Product_Name__c.contains('Personal Loan') && app.TF4SF__Current_Channel__c == 'Online') {
									templateId = etMap.get('Online_Application_Approved_Personal_Loans');
									System.debug('templateId: ' + templateId);
									stipulations.add('Current Photo Identification');
									System.debug('stipulations: ' + stipulations);
									for (TF4SF__Documentation_Request__c dr : prodMap.get(prd.Id).TF4SF__Documentation_Requests__r) { stipulations.add(dr.TF4SF__Type__c); }
									System.debug('prod stipulations: ' + stipulations);
									String stipulation = '<ul>';
									for (String stip : stipulations) { stipulation += '<li>' + stip + '</li>'; }
									stipulation += '</ul>';
									System.debug('stipulationnnnn: ' + stipulation);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__First_Name__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace('{!Stipulations}', stipulation);

									if (prd.TF4SF__Requested_Loan_Amount__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', String.ValueOf(prd.TF4SF__Requested_Loan_Amount__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', '');
									}

									if (prd.TF4SF__Term__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', String.ValueOf(prd.TF4SF__Term__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', '');
									}

									if (prd.TF4SF__Rate__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', String.ValueOf(prd.TF4SF__Rate__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', '');
									}

									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Online Application Approved - Personal Loan');
									String orgIds = '';
									if (emailMap.containsKey('sukesh.gurmekodi@terafinainc.com')) { orgIds = emailMap.get('sukesh.gurmekodi@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								if (prd.TF4SF__Product_Name__c.contains('Credit Card') && app.TF4SF__Current_Channel__c == 'Online') {
									templateId = etMap.get('Online_Application_Approved_Credit_Card');
									System.debug('templateId: ' + templateId);
									stipulations.add('Current Photo Identification');
									System.debug('stipulations: ' + stipulations);
									for (TF4SF__Documentation_Request__c dr : prodMap.get(prd.Id).TF4SF__Documentation_Requests__r) { stipulations.add(dr.TF4SF__Type__c); }
									System.debug('prod stipulations: ' + stipulations);
									String stipulation = '<ul>';
									for (String stip : stipulations) { stipulation += '<li>' + stip + '</li>'; }
									stipulation += '</ul>';
									System.debug('stipulationnnnn: ' + stipulation);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__First_Name__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace('{!Stipulations}', stipulation);
									if (prd.TF4SF__Product_Name__c != null) {
										emailBody = emailBody.Replace('{!TF4SF__Products__c.TF4SF__Product_Name__c}', String.ValueOf(prd.TF4SF__Product_Name__c));
									} 

									if (prd.TF4SF__Requested_Loan_Amount__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', String.ValueOf(prd.TF4SF__Requested_Loan_Amount__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', '');
									}

									if (prd.TF4SF__Term__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', String.ValueOf(prd.TF4SF__Term__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', '');
									}

									if (prd.TF4SF__Rate__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', String.ValueOf(prd.TF4SF__Rate__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', '');
									}

									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Online Application Approved - Credit Card');
									String orgIds = '';
									if (emailMap.containsKey('sukesh.gurmekodi@terafinainc.com')) { orgIds = emailMap.get('sukesh.gurmekodi@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								//****************************************BRANCH CHANNEL EMAILS*********************************************
								if (prd.TF4SF__Product_Name__c.contains('Vehicle Loans') && app.TF4SF__Current_Channel__c == 'Branch') {
									templateId = etMap.get('Branch_Application_Approved_Auto_Loan');
									System.debug('templateId: ' + templateId);
									stipulations.add('Current Photo Identification');
									stipulations.add('Proof of Current Auto Insurance');
									System.debug('stipulations: ' + stipulations);
									for (TF4SF__Documentation_Request__c dr : prodMap.get(prd.Id).TF4SF__Documentation_Requests__r) { stipulations.add(dr.TF4SF__Type__c); }
									System.debug('prod stipulations: ' + stipulations);
									String stipulation = '<ul>';
									for (String stip : stipulations) { stipulation += '<li>' + stip + '</li>'; }
									stipulation += '</ul>';
									System.debug('stipulationnnnn: ' + stipulation);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__First_Name__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace('{!Stipulations}', stipulation);

									if (prd.TF4SF__Requested_Loan_Amount__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', String.ValueOf(prd.TF4SF__Requested_Loan_Amount__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', '');
									}

									if (prd.TF4SF__Term__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', String.ValueOf(prd.TF4SF__Term__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', '');
									}

									if (prd.TF4SF__Rate__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', String.ValueOf(prd.TF4SF__Rate__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', '');
									}

									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Branch Application Approved - Auto Loan');
									String orgIds = '';
									if (emailMap.containsKey('sukeshg@novigosolutions.com')) { orgIds = emailMap.get('sukeshg@novigosolutions.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								if (prd.TF4SF__Product_Name__c.contains('Personal Loan') && app.TF4SF__Current_Channel__c == 'Branch') {
									templateId = etMap.get('Branch_Application_Approved_Personal_Loan');
									System.debug('templateId: ' + templateId);
									stipulations.add('Current Photo Identification');
									System.debug('stipulations: ' + stipulations);
									for (TF4SF__Documentation_Request__c dr : prodMap.get(prd.Id).TF4SF__Documentation_Requests__r) { stipulations.add(dr.TF4SF__Type__c); }
									System.debug('prod stipulations: ' + stipulations);
									String stipulation = '<ul>';
									for (String stip : stipulations) { stipulation += '<li>' + stip + '</li>'; }
									stipulation += '</ul>';
									System.debug('stipulationnnnn: ' + stipulation);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__First_Name__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace('{!Stipulations}', stipulation);

									if (prd.TF4SF__Requested_Loan_Amount__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', String.ValueOf(prd.TF4SF__Requested_Loan_Amount__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', '');
									}

									if (prd.TF4SF__Term__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', String.ValueOf(prd.TF4SF__Term__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', '');
									}

									if (prd.TF4SF__Rate__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', String.ValueOf(prd.TF4SF__Rate__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', '');
									}

									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Branch Application Approved - Personal Loan');
									String orgIds = '';
									if (emailMap.containsKey('sukeshg@novigosolutions.com')) { orgIds = emailMap.get('sukeshg@novigosolutions.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								if (prd.TF4SF__Product_Name__c.contains('Credit Card') && app.TF4SF__Current_Channel__c == 'Branch') {
									templateId = etMap.get('Branch_Application_Approved_Credit_Card');
									System.debug('templateId: ' + templateId);
									stipulations.add('Current Photo Identification');
									System.debug('stipulations: ' + stipulations);
									for (TF4SF__Documentation_Request__c dr : prodMap.get(prd.Id).TF4SF__Documentation_Requests__r) { stipulations.add(dr.TF4SF__Type__c); }
									System.debug('prod stipulations: ' + stipulations);
									String stipulation = '<ul>';
									for (String stip : stipulations) { stipulation += '<li>' + stip + '</li>'; }
									stipulation += '</ul>';
									System.debug('stipulationnnnn: ' + stipulation);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__First_Name__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace('{!Stipulations}', stipulation);

									if (prd.TF4SF__Product_Name__c != null) {
										emailBody = emailBody.Replace('{!TF4SF__Products__c.TF4SF__Product_Name__c}', String.ValueOf(prd.TF4SF__Product_Name__c));
									} else {
										emailBody = emailBody.Replace('{!TF4SF__Products__c.TF4SF__Product_Name__c}', '');
									}

									if (prd.TF4SF__Requested_Loan_Amount__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', String.ValueOf(prd.TF4SF__Requested_Loan_Amount__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', '');
									}

									if (prd.TF4SF__Term__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', String.ValueOf(prd.TF4SF__Term__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', '');
									}

									if (prd.TF4SF__Rate__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', String.ValueOf(prd.TF4SF__Rate__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', '');
									}

									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Branch Application Approved - Credit Card');
									String orgIds = '';
									if (emailMap.containsKey('sukeshg@novigosolutions.com')) { orgIds = emailMap.get('sukeshg@novigosolutions.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								//*****************BRANCH CHANNEL EMAILS END******************
								// Emails for Deposite product and status: Approved
								if (prd.TF4SF__Product_Name__c.contains('Checking') || prd.TF4SF__Product_Name__c.contains('Certificates')  || prd.TF4SF__Product_Name__c.contains('Savings')  ) {
									templateId = etMap.get('Deposit_Approved_and_Instant_Approved');
									//emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									//emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__Sub_Product__c}', app.TF4SF__Sub_Product__c);
									//emailBody = emailBody.Replace(']]>','');
									mail.setTemplateId(templateId.Id);
									mail.setWhatId(app.id);

									//mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									//mail.setSubject('Application Reffered');
									String orgIds = '';
									if (emailMap.containsKey('sandesh.naik@terafinainc.com')) { orgIds = emailMap.get('sandesh.naik@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}
							}
						}
					}
				}

				//****************************************Pending Review EMAILS*********************************************
				if ((app.TF4SF__Primary_Product_Status__c == 'Pending Review' || app.TF4SF__Primary_Product_Status__c == 'Referred' || app.TF4SF__Primary_Product_Status__c == 'Incomplete' || app.TF4SF__Primary_Product_Status__c == 'Pending approval by institution employee' || app.TF4SF__Primary_Product_Status__c == 'Fraud' || app.TF4SF__Primary_Product_Status__c == 'Approved Pending' || app.TF4SF__Primary_Product_Status__c == 'Need More Info' || app.TF4SF__Primary_Product_Status__c == 'Pending'|| app.TF4SF__Primary_Product_Status__c == 'Inquiring' || app.TF4SF__Primary_Product_Status__c == 'Member Waiting' ||  app.TF4SF__Primary_Product_Status__c == 'Review') && app.TF4SF__Application_Status__c == 'Submitted'  && (oldMap.get(app.Id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c || oldMap.get(app.Id).TF4SF__Application_Status__c != app.TF4SF__Application_Status__c)) {
					if (appProdMap.size() > 0) {
						for (TF4SF__Products__c prd : appProdMap.get(app.Id)) {
							if (prd.TF4SF__Product_Name__c == app.TF4SF__Sub_Product__c) {
								if (prd.TF4SF__Product_Name__c.contains('Vehicle Loans') && app.TF4SF__Current_Channel__c == 'Online') {
									templateId = etMap.get('Online_Application_Received_Auto_Loan');
									System.debug('templateId: ' + templateId);
									stipulations.add('Current Photo Identification');
									System.debug('stipulations: ' + stipulations);
									for (TF4SF__Documentation_Request__c dr : prodMap.get(prd.Id).TF4SF__Documentation_Requests__r) { stipulations.add(dr.TF4SF__Type__c); }
									System.debug('prod stipulations: ' + stipulations);
									String stipulation = '<ul>';
									for (String stip : stipulations) { stipulation += '<li>' + stip + '</li>'; }
									stipulation += '</ul>';
									System.debug('stipulationnnnn: ' + stipulation);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__Full_Name_PA__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace('{!Stipulations}', stipulation);

									if (prd.TF4SF__Requested_Loan_Amount__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', String.ValueOf(prd.TF4SF__Requested_Loan_Amount__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Requested_Loan_Amount__c}', '');
									}

									if (prd.TF4SF__Term__c != null) {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', String.ValueOf(prd.TF4SF__Term__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Term__c}', '');
									}

									if (prd.TF4SF__Rate__c!= null) {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', String.ValueOf(prd.TF4SF__Rate__c));
									} else {
										emailBody = emailBody.Replace('{!Products__c.Rate__c}', '');
									}

									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{ app.TF4SF__Email_Address__c };
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Online Application Received – Auto Loan');
									String orgIds = '';
									if (emailMap.containsKey('sukesh.gurmekodi@terafinainc.com')) { orgIds = emailMap.get('sukesh.gurmekodi@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								if (prd.TF4SF__Product_Name__c.contains('Personal Loan') && app.TF4SF__Current_Channel__c == 'Online') {
									templateId = etMap.get('Online_Application_Received_Personal_Loans');
									System.debug('templateId: ' + templateId);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__Full_Name_PA__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Online Application Received – Personal Loan');
									String orgIds = '';
									if (emailMap.containsKey('sukesh.gurmekodi@terafinainc.com')) { orgIds = emailMap.get('sukesh.gurmekodi@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								if (prd.TF4SF__Product_Name__c.contains('Credit Card') && app.TF4SF__Current_Channel__c == 'Online'){
									templateId = etMap.get('Online_Application_Received_Credit_Card');
									System.debug('templateId: ' + templateId);
									emailBody = templateId.HTMLValue;
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									emailBody = emailBody.replace('{!TF4SF__Application__c.TF4SF__Full_Name_PA__c}', app.TF4SF__Full_Name_PA__c);
									emailBody = emailBody.Replace(']]>','');
									mail.setHtmlBody(emailBody);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									mail.setSubject('Online Application Received – Credit Card');
									String orgIds = '';
									if (emailMap.containsKey('sukesh.gurmekodi@terafinainc.com')) { orgIds = emailMap.get('sukesh.gurmekodi@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}

								//Deposit email for : Pending review
								if (prd.TF4SF__Product_Name__c.contains('Checking') || prd.TF4SF__Product_Name__c.contains('Certificates')  || prd.TF4SF__Product_Name__c.contains('Savings')  ) {
									templateId = etMap.get('Deposit_Referred');
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									//mail.setSubject('Application Reffered');
									String orgIds = '';
									if (emailMap.containsKey('sandesh.naik@terafinainc.com')) { orgIds = emailMap.get('sandesh.naik@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}
							}
						}
					}
				}

				//Instant Approved for Deposit 
				if ((app.TF4SF__Primary_Product_Status__c).touppercase() == 'INSTANT APPROVED' && app.TF4SF__Application_Status__c == 'Submitted' && (oldMap.get(app.Id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c  || oldMap.get(app.Id).TF4SF__Application_Status__c != app.TF4SF__Application_Status__c)) {
					if (appProdMap.size() > 0){
						for (TF4SF__Products__c prd : appProdMap.get(app.Id)) {
							if (prd.TF4SF__Product_Name__c == app.TF4SF__Sub_Product__c) {
								if (prd.TF4SF__Product_Name__c.contains('Checking') || prd.TF4SF__Product_Name__c.contains('Certificates') || prd.TF4SF__Product_Name__c.contains('Savings')) {
									templateId = etMap.get('Deposit_Instant_Approved');
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									mail.setWhatId(app.id);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									String orgIds = '';
									if (emailMap.containsKey('sandesh.naik@terafinainc.com')) { orgIds = emailMap.get('sandesh.naik@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}
							}
						}
					}
				}

				//Declined Email
				 if ((app.TF4SF__Primary_Product_Status__c).touppercase() == 'DECLINED' && app.TF4SF__Application_Status__c == 'Submitted' && (oldMap.get(app.Id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c || oldMap.get(app.Id).TF4SF__Application_Status__c != app.TF4SF__Application_Status__c) && app.TF4SF__Customer__c != null) {
					if (appProdMap.size() > 0) {
						for (TF4SF__Products__c prd : appProdMap.get(app.Id)) {
							if (prd.TF4SF__Product_Name__c == app.TF4SF__Sub_Product__c) {
								if (prd.TF4SF__Product_Name__c.contains('Checking') || prd.TF4SF__Product_Name__c.contains('Certificates') || prd.TF4SF__Product_Name__c.contains('Savings')) {
									templateId = etMap.get('Deposit_Application_Declined');
									System.debug('emailBody: ' + emailBody);
									mail.setTemplateId(templateId.Id);
									mail.setWhatId(app.id);
									if (app.TF4SF__Email_Address__c != null || app.TF4SF__Email_Address__c != '') {
										mail.toAddresses = new String[]{app.TF4SF__Email_Address__c} ;
										emailAddress = true;
									}

									mail.setUseSignature(false);
									mail.setSaveAsActivity(false);
									mail.setTargetObjectId(UserInfo.getUserId());
									mail.setTreatTargetObjectAsRecipient(false);
									String orgIds = '';
									if (emailMap.containsKey('sandesh.naik@terafinainc.com')) { orgIds = emailMap.get('sandesh.naik@terafinainc.com'); }
									mail.setOrgWideEmailAddressId(orgIds);
									mailsList.add(mail);
								}
							}
						}
					}
				}
			}

			if (mailsList.size() > 0 && emailAddress) { Messaging.sendEmail(mailsList); }
		} catch (Exception e) {
			System.debug(e.GetMessage());
		}
	}
}