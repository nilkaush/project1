public class SubmitApplicationController {

	public TF4SF__Application__c app{get; set;}
	public String newApplicationId{get; set;}
	public User loggedInUser{get; set;}
	public String usr{get; set;}
	public String id{get; set;}
	public String ut{get; set;}
	public String singlePageName{get; set;}

	public SubmitApplicationController(ApexPages.StandardController controller) {
		this.app = (TF4SF__Application__c)controller.getrecord();
		newApplicationId = ApexPages.currentPage().getParameters().get('id'); 
		usr = ApexPages.currentPage().getParameters().get('usr');
		System.debug('The user is' + usr);
		app = [SELECT Id, TF4SF__Application_Status__c, TF4SF__Application_page__c, TF4SF__Current_Channel__c, TF4SF__Current_timestamp__c, TF4SF__Current_Person__c, TF4SF__Current_Branch_Name__c, TF4SF__Current_User_Email_Address__c, TF4SF__User_Token__c, TF4SF__User_Token_Expires__c, TF4SF__Application_Version__c FROM TF4SF__Application__c WHERE Id = :newApplicationId AND CreatedDate != NULL];
		if (usr != null) { loggedInUser = [SELECT Id, Email, TF4SF__Channel__c, TF4SF__Location__c, Name FROM User WHERE Id = :usr AND CreatedDate != NULL]; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_timestamp__c.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_timestamp__c.isUpdateable()) { app.TF4SF__Current_timestamp__c = System.now(); }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Person__c.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Person__c.isUpdateable()) { app.TF4SF__Current_Person__c = loggedInUser.Id; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Branch_Name__c.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Branch_Name__c.isUpdateable()) { app.TF4SF__Current_Branch_Name__c = loggedInUser.TF4SF__Location__c; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_User_Email_Address__c.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_User_Email_Address__c.isUpdateable()) { app.TF4SF__Current_User_Email_Address__c = loggedInUser.Email; }

		if (loggedInUser != null && loggedInUser.TF4SF__Channel__c != null) {
			if (Schema.sObjectType.TF4SF__Application__c.fields.Ownerid.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.Ownerid.isUpdateable()) { app.Ownerid = loggedInUser.Id; }
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Channel__c.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Channel__c.isUpdateable()) { app.TF4SF__Current_Channel__c = loggedInUser.TF4SF__Channel__c; }
		} else {
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Channel__c.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_Channel__c.isUpdateable()) { app.TF4SF__Current_Channel__c = 'Online'; }
		}
	}

	public PageReference SubmitApp() {
		System.debug('Application Status ');
		TF4SF.Logger.inputSource('SubimtApplication - Submitapp', newApplicationId);
		Map<String, String> tdata = new Map<String, String>();
		tdata.put('id', newApplicationId);
		updateProdApp.JSONGenerator(newApplicationId);
		//  TIPIntegration tip = new TIPIntegration();
		Map<String, String> result = new Map<String, String>();
		// result = TIPIntegration.main(tdata);
		System.debug('result submitapp: ' + result);

		System.debug('Application Status ' + app.TF4SF__Application_Status__c);
		// if (app.TF4SF__Application_Status__c != 'Submitted') { 
		//   System.debug('Application is Submitted');
		//   if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Application_Status__c.isCreateable() && Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Application_Status__c.isUpdateable()) { app.TF4SF__Application_Status__c = 'Submitted'; }
		//   System.debug('Application is Status Submitted'); 
		// }
		//  if (TF4SF__Application__c.SObjectType.getDescribe().isUpdateable()) { update app; }
		System.debug('app = ' + app);

		TF4SF__Application_Activity__c appact = new TF4SF__Application_Activity__c ();
		if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Application__c.isCreateable()) { appact.TF4SF__Application__c = app.Id; }
		if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Branch__c.isCreateable()) { appact.TF4SF__Branch__c = app.TF4SF__Current_Branch_Name__c; }
		if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Channel__c.isCreateable()) { appact.TF4SF__Channel__c = app.TF4SF__Current_Channel__c; }
		if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Name__c.isCreateable()) { appact.TF4SF__Name__c = app.TF4SF__Current_Person__c; }
		if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Action__c.isCreateable()) { appact.TF4SF__Action__c = 'Re - Submitted the Application'; }
		if (Schema.sObjectType.TF4SF__Application_Activity__c.fields.TF4SF__Activity_Time__c.isCreateable()) { appact.TF4SF__Activity_Time__c = System.now(); }
		if (TF4SF__Application_Activity__c.SObjectType.getDescribe().isCreateable()) { insert appact; }

		TF4SF.Logger.addMessage('Redirecting to same page', System.now().format());
		PageReference p = null;
		p = new PageReference(TF4SF__Application_Configuration__c.getOrgDefaults().Lightening_URL__c + '/' + newApplicationId); 
		//p = new PageReference('https://amerisbank-dev-ed-dev-ed.lightning.force.com/'+newApplicationId);
		p.setRedirect(false);
		TF4SF.Logger.writeAllLogs();

		return p;
	}
}