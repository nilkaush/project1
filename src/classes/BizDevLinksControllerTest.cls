@isTest
public class BizDevLinksControllerTest{

	@isTest static void test_method_one() {
		Map<String,ID> profiles = new Map<String,ID>();
		List<Profile> ps = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User' OR Name = 'System Administrator'];

		for (Profile p : ps) { profiles.put(p.name, p.id); }
		
		User standard = new User(Alias = 'standt', Email = 'testingBizDevLinks@testorg.com',
			EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US', ProfileId = profiles.get('Standard User'),
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'testingBizDevLinks@testorg.com', TF4SF__Location__c = 'Milpitas'
		);
		insert standard;

		System.runas(standard) {
			PageReference pageRef = Page.BizDevLinks;
			test.setCurrentPageReference(pageRef);
			pageRef.getParameters().put('PromoCode', 'TESTPRMOCODE');
			BizDevLinksController bdlc = new BizDevLinksController();

			TF4SF__Product_Codes__c pc = new TF4SF__Product_Codes__c();
			pc.TF4SF__Sub_Product__c = 'Credit Cards - Classic Credit Card';
			pc.TF4SF__Product__c = 'Credit Cards';
			pc.ML_Code__c = 'CC_CC03';
			pc.Order__c = 20;
			pc.Product_Order__c = 5;
			pc.name = 'CCC';
			insert pc;

			bdlc.selectedProduct = 'CCC';
			bdlc.ProdSub();
		}
	}
}