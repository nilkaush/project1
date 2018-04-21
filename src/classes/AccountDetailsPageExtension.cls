global with sharing class AccountDetailsPageExtension implements TF4SF.DSP_Interface {

	global Map<String, String> main(Map<String, String> tdata) {
		Map<String, String> data = new Map<String, String>();

		try {
			//data = tdata.clone();
			String appId = tdata.get('id');
			//String method = tdata.get('method');
			Boolean debug = (tdata.get('debug') == 'true');
			Boolean infoDebug = (tdata.get('infoDebug') == 'true');
			//System.debug('method: ' + method);
			TF4SF__Application__c app = [SELECT Id, Name, ProductId__c, TF4SF__Primary_Product_Status__c, TF4SF__Sub_Product__c FROM TF4SF__Application__c WHERE Id = :appId];

			/*if (String.isNotBlank(method)) {
				System.debug('String is not blank.');
				if (method == 'CancelApplication') {
					System.debug('method == CancelApplication');
					String res = SendStatusFromCreditReport.CallUpdateApiToSendStatus(appId, app.ProductId__c, app.TF4SF__Sub_Product__c, 'Cancelled');
					data.put('CancelApplication', 'true');
				}
			} else {*/
				System.debug('app.ProductId__c: ' + app.ProductId__c);
				if (infoDebug == true) { data.put('ProductId__c' , app.ProductId__c); }

				//updateProdApp.JSONGenerator(appId);
				SubmitToCore.JSONGenerator(tdata);
				PayPal_Settings__c paypalSettingObject = PayPal_Settings__c.getInstance();
				data.put('Client_Id' , paypalSettingObject.Client_Id__c);
				data.put('Client_Secret' , paypalSettingObject.Client_Id__c);
			//}
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in AccountDetailsPageExtension class: ' + e.getMessage());
			System.debug('server-errors: ' + e.getMessage());
		}

		return data;
	}
}