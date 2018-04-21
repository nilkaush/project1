public class SendStatusFromCreditReport {
	public static String CallUpdateApiToSendStatus(TF4SF__Application__c app, String prodStatus, String pageName) {
		Map<String, String> responseJson = new Map<String, String>();
		String template = '';
		template = '[';

		if (String.isNotBlank(app.ProductId__c)) {
			template +=    '{';
			template +=        '"id": "' + app.productId__c + '",';
			template +=        '"product_name": "' + app.TF4SF__Sub_Product__c + '",';
			template +=        '"status": "' + prodStatus + '"';
			template +=    '}';
		}

		if (String.isNotBlank(app.ProductIdCS1__c)) {
			template +=    ',{';
			template +=        '"id": "' + app.productIdCS1__c + '",';
			template +=        '"product_name": "' + app.TF4SF__Primary_Offer__c + '",';
			template +=        '"status": "' + prodStatus + '"';
			template +=    '}';
		}

		if (String.isNotBlank(app.ProductIdCS2__c)) {
			template +=    ',{';
			template +=        '"id": "' + app.productIdCS2__c + '",';
			template +=        '"product_name": "' + app.TF4SF__Second_Offer__c + '",';
			template +=        '"status": "' + prodStatus + '"';
			template +=    '}';
		}

		if (String.isNotBlank(app.ProductIdCS3__c)) {
			template +=    ',{';
			template +=        '"id": "' + app.productIdCS3__c + '",';
			template +=        '"product_name": "' + app.TF4SF__Third_Offer__c + '",';
			template +=        '"status": "' + prodStatus + '"';
			template +=    '}';
		}

		template += ']';

		try {
			responseJson = SubmitToCore.http_postMethod(template, app.Id, pageName);
			System.debug('responseJson credit report: ' + responseJson);
		} catch (Exception e) {
			System.debug('Error in SendStatusFromCreditReport Class: ' + e.getmessage());
		}

		return responseJson.get('coreRes');
	}
}
/*
[
  {
	"id": "prodapp-0",
	"status": "Cancelled"
  }
]
*/