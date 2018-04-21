@isTest
public class apphand1Test {
	static testMethod void method1() {
		TF4SF__Application__c app = new TF4SF__Application__c();
		app.TF4SF__Application_Status__c = 'Open';
		insert app;

		app.TF4SF__Application_Status__c = 'Submitted';
		update app;

		TF4SF__Application__c a = [SELECT Id, Sub_Status__c FROM TF4SF__Application__c WHERE Id = :app.Id];
		System.assertEquals('Approve', a.sub_Status__c , 'method test failed');
	}
}