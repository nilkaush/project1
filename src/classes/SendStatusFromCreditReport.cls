public class SendStatusFromCreditReport {
	public static String CallUpdateApiToSendStatus(String appId, String productId, String subProduct, String prodStatus, String pageName) {
		String responseJson;
		String template = '';
		template = '[';
		template +=    '{';
		template +=        '"id": "' + productId + '",';
		template +=        '"product_name": "' + subProduct + '",';
		template +=        '"status": "' + prodStatus + '"';
		template +=    '}';
		template += ']';

		try {
			responseJson = SubmitToCore.http_postMethod(template, appId, pageName);
			System.debug('responseJson credit report: ' + responseJson);
		} catch (Exception e) {
			System.debug('Error in SendStatusFromCreditReport Class: ' + e.getmessage());
		}

		return responseJson;
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