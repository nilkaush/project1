@isTest
public class CustomerPromotionsControllerTest {
	@isTest static void testMethod1() {
		TF4SF__Customer__c cust = new TF4SF__Customer__c();
		insert cust;

		TF4SF__Promotion__c promo = new TF4SF__Promotion__c();
		promo.TF4SF__CampaignID__c = 'CAMP TEST';
		promo.TF4SF__Description__c = 'Platinum Rewards Card';
		promo.TF4SF__Keywords__c = 'KEYWORD TEST';
		promo.TF4SF__RichTextArea1__c = 'Platinum Rewards Card Test';
		promo.TF4SF__Sub_Product_Code__c = 'CC';
		promo.TF4SF__TextArea1__c = 'Platinum Rewards Card Test';
		promo.TF4SF__URL__c = 'https://keypointdev-developer-edition.na50.force.com/StartOffer?Code=CC';
		promo.TF4SF__Customer__c = cust.Id;
		insert promo;

		PageReference pageRef = Page.UX_Customer_Promots;
		test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put('id', cust.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(cust);
		CustomerPromotionsController cpc = new CustomerPromotionsController(sc);
		CustomerPromotionsController.getPromotions(cust.Id);
	}
}