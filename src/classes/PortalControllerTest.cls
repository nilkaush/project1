@IsTest(SeeAllData=true)
public class PortalControllerTest {
	public static testMethod void TestConstructor() {
		TF4SF__Application__c ap = new TF4SF__Application__c();
		ap.TF4SF__Last_Name__c = 'Smith';
		ap.TF4SF__Email_Address__c = 'test@email.com';
		ap.TF4SF__Application_Status__c = 'Submitted';
		ap.TF4SF__Submitted_Timestamp__c = System.now();
		ap.TF4SF__Created_Timestamp__c = System.now();
		insert ap;

		TF4SF__Customer__c tfc = new TF4SF__Customer__c(TF4SF__Username__c = 'testuser', TF4SF__Password__c = 'Logmein', TF4SF__Email_Address__c = 'test@email.com', TF4SF__Last_Name__c = 'Smith', TF4SF__First_Name__c = 'John', TF4SF__SSN__c = '111-22-3333', TF4SF__Date_Of_Birth__c = '2000-10-10', TF4SF__Person_Identifier__c = '');
		insert tfc;

		TF4SF__Identity_Information__c idenList = New TF4SF__Identity_Information__c(TF4SF__SSN_Prime__c = '111-22-3333', TF4SF__Date_of_Birth__c = '2000-10-10', TF4SF__Application__c = ap.Id, TF4SF__SSN_Last_Four_PA__c = '3333');
		insert idenList;

		TF4SF__Products__c p = new TF4SF__Products__c();
		p.tf4sf__Application__c = ap.Id;
		insert p;

		List<Note> ntList = new List<Note>();        
		ntList.add(new note(title = 'Test Note', Body = 'Email test', ParentId = p.Id));
		ntList.add(new note(title = 'Test Note1', Body = 'Email test1', ParentId = p.Id));
		insert ntList;

		List<TF4SF__Documentation_Request__c> drList = new List<TF4SF__Documentation_Request__c>();
		drList.add(new TF4SF__Documentation_Request__c(TF4SF__Application__c = ap.Id, TF4SF__Type__c = 'Test Request', TF4SF__Products__c = p.Id));
		drList.add(new TF4SF__Documentation_Request__c(TF4SF__Application__c = ap.Id, TF4SF__Type__c = 'Test Request1', TF4SF__Products__c = p.Id));
		insert drList;

		List<Attachment> attList = new List<Attachment>();    
		attList.add(new attachment(Name = 'Task Creation Attachment Test', Body = Blob.valueOf('Task Creation Test Attachment Body'), ParentId = drList.get(0).Id));
		attList.add(new attachment(Name = 'Task Creation Attachment Test1', Body = Blob.valueOf('Task1 Creation Test Attachment Body'), ParentId = drList.get(1).Id));
		insert attList;

		Map<String, sObject> appData = new Map<String, sObject>();
		Map<String, String> tdata = new Map<String, String>();
		tdata.put('Application__c.Login__c', 'testuser');
		tdata.put('Application__c.Password__c', 'Logmein');
		tdata.put('debug', 'true');
		tdata.put('Identity_Information__c.SSN_Prime__c', '111-22-3333');
		tdata.put('Application__c.Last_Name__c', 'Smith');
		tdata.put('Application__c.Email_Address__c', 'test@email.com');
		tdata.put('Identity_Information__c.Date_of_Birth__c', '2000-10-10');
		String pagename = TF4SF.DSPController.STATUS_PORTAL_PAGE;

		PortalController pc = new PortalController();
		PortalController.setAppErrors(appData, True);
		PageReference pageRef = new PageReference(TF4SF.DSPController.STATUS_PORTAL_PAGE);
		Test.setCurrentPage(pageRef);
		PortalController.getAppFields(tdata, pagename);
		PortalController.postData(tdata, pagename);

		try {
			TF4SF__Application_Configuration__c appConfig = TF4SF__Application_Configuration__c.getOrgDefaults();
			String origIntClass = appConfig.TF4SF__IntegrationClass_ML__c;
			appConfig.TF4SF__IntegrationClass_ML__c = null;
			update appConfig;

			PortalController.userLogin(tdata);
			appConfig.TF4SF__IntegrationClass_ML__c = origIntClass;
			update appConfig;
			PortalController.userLogin(tdata);
		} catch (Exception e) {
			System.debug('Exception encountered calling userLogin: ' + e);
		}
	}

	public static testMethod void TestDiffAppStatus() {
		TF4SF__Application__c ap = new TF4SF__Application__c();
		ap.TF4SF__First_Name__c = 'Sayali';
		ap.TF4SF__Last_Name__c = 'Kute';
		ap.TF4SF__Email_Address__c = 'test@email.com';
		ap.TF4SF__Application_Status__c = 'Save for Later';
		ap.TF4SF__Submitted_Timestamp__c = System.now();
		ap.TF4SF__Created_Timestamp__c = System.now();
		ap.TF4SF__Sub_Product__c = 'Test Product';
		insert ap;

		TF4SF__Customer__c tfc = new TF4SF__Customer__c(TF4SF__Username__c = 'testuser', TF4SF__Password__c = 'Logmein', TF4SF__Email_Address__c = 'test@email.com', TF4SF__Last_Name__c = 'Smith', TF4SF__First_Name__c = 'John', TF4SF__SSN__c = '111-22-3333', TF4SF__Date_Of_Birth__c = '2000-10-10', TF4SF__Person_Identifier__c = '');
		insert tfc;

		TF4SF__Identity_Information__c idenList = New TF4SF__Identity_Information__c(TF4SF__SSN_Prime__c = '111-22-3333', TF4SF__Date_of_Birth__c = '2000-10-10' , TF4SF__Application__c = ap.Id, TF4SF__SSN_Last_Four_PA__c = '3333');
		insert idenList;

		TF4SF__Products__c p = new TF4SF__Products__c();
		p.tf4sf__Application__c = ap.id;
		insert p;

		List<Note> ntList = new List<Note>();        
		ntList.add(new note(title = 'Test Note', Body = 'Email test', ParentId = p.Id));
		ntList.add(new note(title = 'Test Note1', Body = 'Email test1', ParentId = p.Id));
		insert ntList;

		List<TF4SF__Documentation_Request__c> drList = new List<TF4SF__Documentation_Request__c>();
		drList.add(new TF4SF__Documentation_Request__c(TF4SF__Application__c = ap.Id, TF4SF__Type__c = 'Test Request', TF4SF__Products__c = p.Id));
		drList.add(new TF4SF__Documentation_Request__c(TF4SF__Application__c = ap.Id, TF4SF__Type__c = 'Test Request1', TF4SF__Products__c = p.Id));
		insert drList;

		List<Attachment> attList = new List<Attachment>();    
		attList.add(new attachment(Name = 'Task Creation Attachment Test', Body = Blob.valueOf('Task Creation Test Attachment Body'), ParentId = drList.get(0).Id));
		attList.add(new attachment(Name = 'Task Creation Attachment Test1', Body = Blob.valueOf('Task1 Creation Test Attachment Body'), ParentId = drList.get(1).Id));
		insert attList;

		Map<String, sObject> appData = new Map<String, sObject>();
		Map<String, String> tdata = new Map<String, String>();
		tdata.put('Application__c.Login__c', 'testuser');
		tdata.put('Application__c.Password__c', 'Logmein');
		tdata.put('debug', 'true');
		tdata.put('Identity_Information__c.SSN_Prime__c', '111-22-3333');
		tdata.put('Application__c.Last_Name__c', 'Smith');
		tdata.put('Application__c.Email_Address__c', 'test@email.com');
		tdata.put('Identity_Information__c.Date_of_Birth__c', '2000-10-10');
		String pagename = TF4SF.DSPController.STATUS_PORTAL_PAGE;
		PortalController pc = new PortalController();
		PortalController.setAppErrors(appData, True);
		PageReference pageRef = new PageReference(TF4SF.DSPController.STATUS_PORTAL_PAGE);
		Test.setCurrentPage(pageRef);
		PortalController.getAppFields(tdata, pagename);
	}

	public static testMethod void TestLoginFailure() {
		TF4SF__Customer__c tfc = new TF4SF__Customer__c(TF4SF__Username__c = 'testuser', TF4SF__Password__c = 'Logmein', TF4SF__Email_Address__c = 'test@email.com', TF4SF__Last_Name__c = 'Smith', TF4SF__First_Name__c = 'John', TF4SF__SSN__c = '111-22-3333', TF4SF__Date_Of_Birth__c = '2000-10-10', TF4SF__Person_Identifier__c = '');
		insert tfc; 
		Map<String, sObject> appData = new Map<String, sObject>();
		Map<String, String> tdata = new Map<String, String>();
		tdata.put('Application__c.Login__c', 'testuserError');
		tdata.put('Application__c.Password__c', 'Logmein');
		tdata.put('debug', 'true');
		String pagename = TF4SF.DSPController.STATUS_PORTAL_PAGE;

		PortalController pc = new PortalController();
		PortalController.setAppErrors(appData, True);

		PageReference pageRef = new PageReference(TF4SF.DSPController.STATUS_PORTAL_PAGE);
		Test.setCurrentPage(pageRef);
		PortalController.getAppFields(tdata, pagename);

		tdata.put('Application__c.Login__c', 'testuser');
		tdata.put('Application__c.Password__c', 'LogmeinIncorrect');
		PortalController.getAppFields(tdata, pagename);
	}

	public static testMethod void TestWrongApplication() {
		TF4SF__Application__c ap = new TF4SF__Application__c();
		ap.TF4SF__Last_Name__c = 'Smith';
		ap.TF4SF__Email_Address__c = 'test@email.com';
		ap.TF4SF__Application_Status__c = 'Open';
		insert ap;

		TF4SF__Customer__c tfc = new TF4SF__Customer__c(TF4SF__Username__c = 'testuser', TF4SF__Password__c = 'Logmein', TF4SF__Email_Address__c = 'test@email.com', TF4SF__Last_Name__c = 'Smith', TF4SF__First_Name__c = 'John', TF4SF__SSN__c = '111-22-3333', TF4SF__Date_Of_Birth__c = '2000-10-10', TF4SF__Person_Identifier__c = '');
		insert tfc;

		TF4SF__Identity_Information__c idenList = New TF4SF__Identity_Information__c(TF4SF__SSN_Prime__c = '111-22-3333', TF4SF__Date_of_Birth__c = '2000-10-10', TF4SF__Application__c = ap.Id, TF4SF__SSN_Last_Four_PA__c = '3333');
		insert idenList;

		TF4SF__Products__c p = new TF4SF__Products__c();
		p.tf4sf__Application__c = ap.Id;
		insert p;

		List<Note> ntList = new List<Note>();        
		ntList.add(new note(title = 'Test Note', Body = 'Email test', ParentId = p.Id));
		ntList.add(new note(title = 'Test Note1', Body = 'Email test1', ParentId = p.Id));
		insert ntList;

		List<TF4SF__Documentation_Request__c> drList = new List<TF4SF__Documentation_Request__c>();
		drList.add(new TF4SF__Documentation_Request__c(TF4SF__Application__c = ap.Id, TF4SF__Type__c = 'Test Request', TF4SF__Products__c = p.Id));
		drList.add(new TF4SF__Documentation_Request__c(TF4SF__Application__c = ap.Id, TF4SF__Type__c = 'Test Request1', TF4SF__Products__c = p.Id));
		insert drList;

		List<Attachment> attList = new List<Attachment>();    
		attList.add(new attachment(Name = 'Task Creation Attachment Test', Body = Blob.valueOf('Task Creation Test Attachment Body'), ParentId = drList.get(0).Id));
		attList.add(new attachment(Name = 'Task Creation Attachment Test1', Body = Blob.valueOf('Task1 Creation Test Attachment Body'), ParentId = drList.get(1).Id));
		insert attList;

		Map<String, sObject> appData = new Map<String, sObject>();
		Map<String, String> tdata = new Map<String, String>();
		tdata.put('Application__c.Login__c', 'testuser');
		tdata.put('Application__c.Password__c', 'Logmein');
		tdata.put('debug', 'true');
		tdata.put('Identity_Information__c.SSN_Prime__c', '111-22-3333');
		tdata.put('Application__c.Last_Name__c', 'Smith');
		tdata.put('Application__c.Email_Address__c', 'test@email.com');
		tdata.put('Identity_Information__c.Date_of_Birth__c', '2000-10-10');
		String pagename = TF4SF.DSPController.STATUS_PORTAL_PAGE;

		PortalController pc = new PortalController();
		PortalController.setAppErrors(appData, True);
		PageReference pageRef = new PageReference(TF4SF.DSPController.STATUS_PORTAL_PAGE);
		Test.setCurrentPage(pageRef);
		PortalController.getAppFields(tdata, pagename);
	}

	public static testMethod void TestAddMessage() {
		TF4SF__Application__c ap = new TF4SF__Application__c();
		ap.TF4SF__Last_Name__c = 'Smith';
		ap.TF4SF__Email_Address__c = 'test@email.com';
		ap.TF4SF__Application_Status__c = 'Submitted';
		ap.TF4SF__Submitted_Timestamp__c = System.now();
		ap.TF4SF__Created_Timestamp__c = System.now();
		insert ap;

		TF4SF__Products__c p = new TF4SF__Products__c();
		p.tf4sf__Application__c = ap.Id;
		insert p;

		Map<String, String> tdata = new Map<String, String>();
		tdata.put('debug', 'true');
		tdata.put('prodId', p.Id);
		tdata.put('msgText', 'Sample message from the customer');
		String pagename = TF4SF.DSPController.STATUS_PORTAL_PAGE;
		PortalController pc = new PortalController();
		PageReference pageRef = new PageReference(TF4SF.DSPController.STATUS_PORTAL_PAGE);
		Test.setCurrentPage(pageRef);
		PortalController.addMessage(tdata);
	}
}