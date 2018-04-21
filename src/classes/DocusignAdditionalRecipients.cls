global with sharing class DocusignAdditionalRecipients {

	global String envolopeId {get; set;}
	global String recipientId {get; set;}
	global String recipientEmail {get; set;}
	global String recipientName {get; set;}
	global String authenticationHeader {get; set;}
	global String appId {get; set;}
	global TF4SF__Application__c app {get; set;}
	global String destination {get; set;}
	global String AccountId {get; set;}

	global DocusignAdditionalRecipients() {
		appId = ApexPages.currentPage().getParameters().get('appId');
		if (String.isNotBlank(appId)) {
			if (appId.contains(':')) {
				destination = appId.substringAfter(':');
				appId = appId.substringBefore(':');
			}

			app = [SELECT Id, Docusign_EnvelopeID__c, TF4SF__Email_Address_J__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__Email_Address_J3__c, TF4SF__First_Name_J3__c, TF4SF__Last_Name_J3__c, TF4SF__Email_Address_J2__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__First_Joint_Applicant__c, TF4SF__Second_Joint_Applicant__c, TF4SF__Third_Joint_Applicant__c FROM TF4SF__Application__c WHERE Id = :appId];
			envolopeId = app.Docusign_EnvelopeID__c;
		}
		Docusign_Config__c cred = [SELECT Id, Name, AccountID__c, Username__c, Password__c, IntegratorKey__c FROM Docusign_Config__c WHERE Name = 'cred'];
		AccountId = cred.AccountID__c;

		authenticationHeader = '<DocuSignCredentials><Username>'+cred.Username__c+'</Username><Password>'+cred.Password__c+'</Password><IntegratorKey>'+cred.IntegratorKey__c+'</IntegratorKey></DocuSignCredentials>';
		System.debug('the destination is '+destination);
	}

	global PageReference redirect() {
		PageReference p = null;
		HttpResponse res = null;
		Integer status = null;
		String resBody = '';
		TF4SF__SiteUrl__c siteurl = TF4SF__SiteUrl__c.getOrgDefaults();

		if (destination == '2') {
			if (app != null) {
				if (app.TF4SF__First_Joint_Applicant__c == true) {
					recipientEmail = app.TF4SF__Email_Address_J__c;
					recipientName = app.TF4SF__First_Name_J__c + ' ' + app.TF4SF__Last_Name_J__c;
					envolopeId = app.Docusign_EnvelopeID__c;
					recipientId = '1002';

					if (app.TF4SF__Second_Joint_Applicant__c == true) {
						destination = siteurl.TF4SF__Url__c + 'DocusignRedirectPage?appId=' + appId + ':3';
					} else {
						destination = 'https://kpcu.com/';
					}
				} else {
					destination = 'https://kpcu.com/';
				}
			}
		} else if (destination == '3') {
			if (app != null) {
				if (app.TF4SF__Second_Joint_Applicant__c == true) {
					recipientEmail = app.TF4SF__Email_Address_J2__c;
					recipientName = app.TF4SF__First_Name_J2__c + ' ' + app.TF4SF__Last_Name_J2__c;
					envolopeId = app.Docusign_EnvelopeID__c;
					recipientId = '1003';

					if (app.TF4SF__Third_Joint_Applicant__c == true) {
						destination = siteurl.TF4SF__Url__c + 'DocusignRedirectPage?appId=' + appId + ':4';
					} else {
						destination = 'https://kpcu.com/';
					}
				} else {
					destination = 'https://kpcu.com/';
				}
			}
		} else if (destination == '4') {
			if (app != null) {
				recipientEmail = app.TF4SF__Email_Address_J3__c;
				recipientName = app.TF4SF__First_Name_J3__c + ' ' + app.TF4SF__Last_Name_J3__c;
				envolopeId = app.Docusign_EnvelopeID__c;
				recipientId = '1004';
				destination = 'https://kpcu.com/';
			}
		} else if (destination == '1') {
			destination = 'https://kpcu.com/';
		}

		if (String.isNotBlank(envolopeId)) {
			String url = 'https://demo.docusign.net/restapi/v2/accounts/'+ AccountId +'/envelopes/' + envolopeId + '/views/recipient'; // append envelope uri + 'views/recipient' to url
			String body = '<recipientViewRequest xmlns=\'https://www.docusign.com/restapi\'>'  +
			'<authenticationMethod>email</authenticationMethod>' +
			'<email>' + recipientEmail + '</email>' +
			'<returnUrl>' + destination + '</returnUrl>' +
			'<userName>' + recipientName + '</userName>' +
			'<clientUserId>' + recipientId + '</clientUserId>' +
			'</recipientViewRequest>';

			System.debug('the body is ' + body + ' and url is ' + url);
			if (!Test.isRunningTest()) {
				res = DocusignTemplateSigning.InitializeRequest(url, 'POST', body, authenticationHeader);
				status = res.getStatusCode();

				if (status != 201)  {// 201 = Created
					//data.put('Docusign Embedded Signing URL', 'Failure at 201');
					//return data;
				}

				resBody = res.getBody();
				String urlToken = DocusignTemplateSigning.parseXMLBody(resBody, 'url');
				System.debug('URL TOKEN '  + urlToken);

				//app.Docusign_EnvelopeID__c = uri.replace('/envelopes/','');
				//update app;
				//data.put('Docusign Embedded Signing URL', urlToken);
				p = new PageReference(urlToken);
			}
		} else {
			destination = siteurl.TF4SF__Url__c + 'DocusignComplete';
			System.debug('the destination is ' + destination);
			p = new PageReference(destination);
		}

		return p;
	}
}