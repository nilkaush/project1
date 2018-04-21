@isTest
private class DriverLicenseScanTest {
	static testMethod void testCallout() {
		Map<String, String> tdata = new Map<String, String>();
		Map<String, String> data = new Map<String, String>();

		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new DriverLicenseScanMock());
		DriverLicenseScan objclass = new DriverLicenseScan();
		objclass.main(tdata);
		System.debug('tdata is' + tdata);
		Test.StopTest();

		TF4SF__Application__c app1 = new TF4SF__Application__c();
		app1.TF4SF__First_Name__c = 'Test Account';
		insert app1;

		TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
		iden.TF4SF__Application__c = app1.Id;
		iden.TF4SF__Date_of_Birth__c = '01-01-1975';
		insert iden;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test';
		docReq.TF4SF__Application__c = app1.Id;
		insert docReq;

		Blob b = Blob.valueOf('Test Data');
		Attachment attachment = new Attachment();
		attachment.ParentId = docReq.id;
		attachment.Name = 'Test Attachment';
		attachment.Body = b;
		insert(attachment);

		tdata.put('id', app1.Id);
		tdata.put('attachmentId', '');
	}

	static testMethod void testCallout1() {
		Map<String, String> tdata = new Map<String, String>();
		Map<String, String> data = new Map<String, String>();
		TF4SF__Application__c app1 = new TF4SF__Application__c();
		app1.TF4SF__First_Name__c = 'Test Account';
		insert app1;

		Blob b = Blob.valueOf('Test Data');
		Attachment attachment = new Attachment();
		attachment.ParentId = app1.Id;
		attachment.Name = 'Test Attachment';
		attachment.Body = b;
		insert(attachment);

		tdata.put('id', app1.Id);
		tdata.put('attachmentId', attachment.Id);
		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new DriverLicenseScanMock());
		DriverLicenseScan objclass = new DriverLicenseScan();
		objclass.main(tdata);
		System.debug('tdata is' + tdata);
		Test.StopTest();
	}
}