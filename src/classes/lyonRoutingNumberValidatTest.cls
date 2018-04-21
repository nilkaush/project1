// Test class for lyonRoutingNumberValidator
@isTest 
private class lyonRoutingNumberValidatTest {
	public static void unit() {
		Lyon_Routing_Number__c lyonRouting = new Lyon_Routing_Number__c();
		lyonRouting.Enable_Production__c = false;
		lyonRouting.Production_Password__c = '';
		lyonRouting.Production_URL__c = '';
		lyonRouting.Production_Username__c = '';
		lyonRouting.Sandbox_Password__c = 'V2Pr7yj6';
		lyonRouting.Sandbox_URL__c = 'https://demo.lyonsreg.com/WebServices/aba/ABAServiceWCF.svc    ';
		lyonRouting.Sandbox_Username__c  = 'TerafinaSB';
		lyonRouting.Token__c = '528248cf-e7ff-4bac-a501-81a5e98e018b ';
		insert lyonRouting;
	}

	public static void unit3() {
		Lyon_Routing_Number__c lyonRouting = new Lyon_Routing_Number__c();
		lyonRouting.Enable_Production__c = true;
		lyonRouting.Production_Password__c = 'V2Pr7yj6';
		lyonRouting.Production_URL__c = 'https://demo.lyonsreg.com/WebServices/aba/ABAServiceWCF.svc';
		lyonRouting.Production_Username__c = 'TerafinaSB';
		lyonRouting.Sandbox_Password__c = 'V2Pr7yj6';
		lyonRouting.Sandbox_URL__c = 'https://demo.lyonsreg.com/WebServices/aba/ABAServiceWCF.svc    ';
		lyonRouting.Sandbox_Username__c  = 'TerafinaSB';
		lyonRouting.Token__c = '528248cf-e7ff-4bac-a501-81a5e98e018b ';
		insert lyonRouting;
	}

	static testMethod void lyonTestMethod1 () {
		unit();
		Map<String, String> data1 = new Map<String, String>();
		data1.put('RoutingNumber','031201360');
		Test.startTest();
		Test.setMock (HttpCalloutMock.class, new MockHttpResponseToken());
		lyonRoutingNumberValidator validObj = new lyonRoutingNumberValidator();
		validObj.main(data1);
		Test.stopTest();
	}

	static testMethod void lyonTestMethod2 () {
		unit3();
		Map<String, String> data1 = new Map<String, String>();
		data1.put('RoutingNumber','031201360');
		Test.startTest();
		Test.setMock (HttpCalloutMock.class, new MockHttpResponseValidation());
		lyonRoutingNumberValidator validObj = new lyonRoutingNumberValidator();
		validObj.main(data1);
		Test.stopTest();
	}

	static testMethod void lyonTestMethod3 () {
		unit3();
		Map<String, String> data1 = new Map<String, String>();
		data1.put('RoutingNumber','122332');
		Test.startTest();
		Test.setMock (HttpCalloutMock.class, new MockHttpResponseValidationNegat());
		lyonRoutingNumberValidator validObj = new lyonRoutingNumberValidator();
		validObj.main(data1);
		Test.stopTest();
	}
}