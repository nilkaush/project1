global class PayPalTransactionSave implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		// Map<String, String> data = new Map<String, String>();
		//  data = tdata.clone();
		System.debug(tdata);

		if (tdata != null && tdata.containsKey('appid')) {
			String appId = tdata.get('appid');
			List<TF4SF__About_Account__c> aboutAccountObj = [SELECT Id, Transaction_ID__c, Transaction_Status__c, Transaction_Message__c FROM TF4SF__About_Account__c WHERE Id = :appId LIMIT 1];

			if (aboutAccountObj != null && !aboutAccountObj.isEmpty()){
				TF4SF__About_Account__c abAcc = aboutAccountObj.get(0);
				abAcc.Transaction_ID__c = tdata.get('Transaction_ID__c');
				abAcc.Transaction_Status__c = tdata.get('Transaction_Status__c');
				abAcc.Transaction_Message__c = tdata.get('Transaction_Message__c');
				update abAcc;
			}
		}

		return new map<String , string>();
	}
}