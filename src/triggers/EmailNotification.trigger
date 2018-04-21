trigger EmailNotification on TF4SF__Application__c (after update) {
	List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
	for (TF4SF__Application__c app : trigger.New) {
		//Online Application Received – Auto Loan
		if (app.TF4SF__Product__c == 'Vehicle Loans' && app.TF4SF__Primary_Product_Status__c == 'Pending Review' && app.TF4SF__Created_Channel__c == 'Online' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) {
			System.debug('');
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			EmailTemplate templateId = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Online Application Received – Auto Loan'];
			System.debug('----Template Id ' + templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailTOAddress ' + mail.toaddresses);
			mails.add(mail);
		}

		//Online Application Received – Personal Loans
		if (app.TF4SF__Product__c == 'Personal Loans' && app.TF4SF__Primary_Product_Status__c == 'Pending Review' && app.TF4SF__Created_Channel__c == 'Online' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) {
			System.debug('----Application Id ' + app.Id);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			//EmailTemplate templateId = [SELECT Id,Name FROM EmailTemplate where Name ='Online Application Received – Personal Loans'];
			EmailTemplate templateId = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Test2'];
			System.debug('----Template Id ' + templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailToAddress ' + mail.toaddresses);
			mails.add(mail);
		}

		//Online Application Received – Credit Card
		if (app.TF4SF__Product__c == 'Credit Cards' && app.TF4SF__Primary_Product_Status__c == 'Pending Review' && app.TF4SF__Created_Channel__c == 'Online' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) {
			System.debug('----Application Id ' + app.Id);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			EmailTemplate templateId = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Online Application Received – Credit Card'];
			System.debug('----Template Id '+templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailToAddress ' + mail.toaddresses);
			mails.add(mail);
		}

		//Online Application Approved – Auto Loan
		if (app.TF4SF__Product__c == 'Vehicle Loans' && app.TF4SF__Primary_Product_Status__c == 'Approved' && app.TF4SF__Created_Channel__c == 'Online' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) {
			System.debug('----Application Id ' + app.Id);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			EmailTemplate templateId = [SELECT Id,Name FROM EmailTemplate WHERE Name = 'Online Application Approved – Auto Loan'];
			System.debug('----Template Id ' + templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailToAddress ' + mail.toaddresses);
			mails.add(mail);
		}

		//Online Application Approved – Personal Loans
		if(app.TF4SF__Product__c == 'Personal Loans' && app.TF4SF__Primary_Product_Status__c == 'Approved' && app.TF4SF__Created_Channel__c == 'Online' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) {
			System.debug('----Application Id ' + app.Id);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			EmailTemplate templateId = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Online Application Approved – Personal Loans'];
			System.debug('----Template Id ' + templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailToAddress ' + mail.toaddresses);
			mails.add(mail);
		}

		//Online Application Approved – Credit Card
		if (app.TF4SF__Product__c == 'Credit Cards' && app.TF4SF__Primary_Product_Status__c == 'Approved' && app.TF4SF__Created_Channel__c == 'Online' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) {
			System.debug('----Application Id ' + app.Id);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			EmailTemplate templateId = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Online Application Approved – Credit Card'];
			System.debug('----Template Id ' + templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailToAddress ' + mail.toaddresses);
			mails.add(mail);
		}

		//Branch Application Approved – Auto Loan
		if (app.TF4SF__Product__c == 'Vehicle Loans' && app.TF4SF__Primary_Product_Status__c == 'Approved' && app.TF4SF__Created_Channel__c == 'Branch' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) {
			System.debug('----Application Id ' + app.Id);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			EmailTemplate templateId = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Branch Application Approved – Auto Loan'];
			System.debug('----Template Id ' + templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailToAddress ' + mail.toaddresses);
			mails.add(mail);
		}

		//Branch Application Approved – Personal Loans
		if (app.TF4SF__Product__c == 'Personal Loans' && app.TF4SF__Primary_Product_Status__c == 'Approved' && app.TF4SF__Created_Channel__c == 'Online' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c) {
			System.debug('----Application Id ' + app.Id);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			EmailTemplate templateId = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Branch Application Approved – Personal Loans'];
			System.debug('----Template Id ' + templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailToAddress ' + mail.toaddresses);
			mails.add(mail);
		}

		//Branch Application Approved – Credit Card
		if (app.TF4SF__Product__c == 'Credit Cards' && app.TF4SF__Primary_Product_Status__c == 'Approved' && app.TF4SF__Created_Channel__c == 'Online' && 
				app.TF4SF__Email_Address__c != null && Trigger.oldMap.get(app.id).TF4SF__Primary_Product_Status__c != app.TF4SF__Primary_Product_Status__c ) {
			System.debug('----Application Id ' + app.Id);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			EmailTemplate templateId = [SELECT Id, Name FROM EmailTemplate where Name = 'Branch Application Approved – Credit Card'];
			System.debug('----Template Id ' + templateId.Id);
			mail.setTreatTargetObjectAsRecipient(false);
			mail.settargetObjectId(UserInfo.getUserId());
			mail.setTemplateID(templateId.Id); 
			List<String> email = new List<String>();
			email.add(app.TF4SF__Email_Address__c);
			System.debug('----Email List ' + email);
			mail.toAddresses = email;
			System.debug('----MailToAddress ' + mail.toaddresses);
			mails.add(mail);
		}
	}

	if (mails.size() > 0) { Messaging.SendEmail(mails); }
}