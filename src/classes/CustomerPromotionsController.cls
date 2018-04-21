public with sharing class CustomerPromotionsController {
	Id userId;

	public CustomerPromotionsController(apexPages.StandardController controller) {
		userId = UserInfo.getUserId();
	}

	@remoteAction
	public static List<Promotion> getPromotions(){
		List<Promotion> promotions = new List<Promotion>();
		List<TF4SF__Promotion__c> promos = [
			SELECT Id, CreatedDate, TF4SF__CampaignID__c, TF4SF__Description__c, TF4SF__Keywords__c, TF4SF__RichTextArea1__c, TF4SF__Sub_Product_Code__c, TF4SF__TextArea1__c, TF4SF__URL__c 
			FROM TF4SF__Promotion__c 
			LIMIT 1000];
		for (TF4SF__Promotion__c promo : promos) { promotions.add(new Promotion(promo)); }
		return promotions;
	}

	public class Promotion {
		String applyUrl { get; set; }
		String code { get; set; }
		String description { get; set; }
		String endDate { get; set; }
		String html { get; set; }
		String keywords { get; set; }
		String kind { get; set; }
		String text { get; set; }

		public Promotion(TF4SF__Promotion__c promo) {
			this.applyUrl = promo.TF4SF__URL__c;
			this.code = promo.TF4SF__Sub_Product_Code__c;
			this.description = promo.TF4SF__Description__c;
			this.endDate = promo.CreatedDate.addDays(30).format('MM/dd/yyyy');
			this.html = promo.TF4SF__RichTextArea1__c;
			this.keywords = promo.TF4SF__Keywords__c;
			this.kind = promo.TF4SF__CampaignID__c;
			this.text = promo.TF4SF__TextArea1__c;
		}
	}
}