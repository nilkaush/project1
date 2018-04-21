@isTest
public class NotesTriggerTest {
	static testMethod void notesTrigggerTestMethod() {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
		String authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
		Map<String,String> headers = new Map<String, String>{'content-type'=>'application/json','Accept'=>'application/json','Authorization' => authorizationHeader};
		String jsonres = '[{"success":true,"value":{"product_app_id":"f293dad61aa8404dbecb2b0ed807969f","messages":["testbody"]},"error_type":null,"error_message":null}]';
		MockAttachmentResponseGenerator fakeResponse = new MockAttachmentResponseGenerator(200, 'success', jsonres, headers);

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		Test.stopTest();  

		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'Notes TestProductId';
		insert appObj;
		
		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Application__c = appObj.id;
		insert prod;

		Note note = new Note();
		note.parentId = prod.Id;
		note.title = 'Notes Trigger Test';
		insert note;
	}
}