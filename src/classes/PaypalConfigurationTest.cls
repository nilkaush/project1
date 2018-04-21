@isTest
private class PaypalConfigurationTest  {
	static testMethod void PaypalConfiguration(){
		Map<String, String> data = new Map<String, String>();
		TF4SF__Application__c app1 = new TF4SF__Application__c();
		app1.TF4SF__First_Name__c='Test Account';
		insert app1;
		PayPal_Settings__c paypalSettingObject = new PayPal_Settings__c();
		paypalSettingObject.Client_Id__c ='test';
		paypalSettingObject.Client_Secret__c ='test1';
		insert paypalSettingObject;
		//  SubmitToCore.JSONGenerator(data);
		Test.startTest();

		 // data.put('Client_Id' ,'AZDxjDScFpQtjWTOUtWKbyN_bDt4OgqaF4eYXlewfBP4-8aqX3PiV8e1GWU6liB2CUXlkA59kJXE7M6R' );
		// data.put('Client_Secret' ,'test');
		PaypalConfiguration obj = new PaypalConfiguration();
		obj.main(data);

		Test.stopTest();
	}
}