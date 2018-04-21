global class PayPalTransactionSave implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = (tdata.get('infoDebug') == 'true');
		Map<String, String> data = new Map<String, String>();
		System.debug(tdata);

		try {
			if (tdata != null && tdata.containsKey('appid')) {
				String appId = tdata.get('appid');
				List<TF4SF__About_Account__c> aboutAccountObj = [SELECT Id, Transaction_ID__c, Transaction_Status__c, Transaction_Message__c FROM TF4SF__About_Account__c WHERE Id = :appId LIMIT 1];

				if (aboutAccountObj != null && !aboutAccountObj.isEmpty()) {
					TF4SF__About_Account__c abAcc = aboutAccountObj.get(0);
					abAcc.Transaction_ID__c = tdata.get('Transaction_ID__c');
					abAcc.Transaction_Status__c = tdata.get('Transaction_Status__c');
					abAcc.Transaction_Message__c = tdata.get('Transaction_Message__c');
					update abAcc;
				}
			}
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in PayPalTransactionSave class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in PayPalTransactionSave class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'PayPalTransactionSave - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PayPalTransactionSave - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}
}