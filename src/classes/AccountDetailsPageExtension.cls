global with sharing class AccountDetailsPageExtension implements TF4SF.DSP_Interface {

	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = false;
		Map<String, String> data = new Map<String, String>();
		Map<String, String> logs = new Map<String, String>();

		try {
			String appId = tdata.get('id');
			//Boolean debug = (tdata.get('debug') == 'true');
			infoDebug = (tdata.get('infoDebug') == 'true');
			TF4SF__Application__c app = [SELECT Id, Name, ProductId__c, TF4SF__Primary_Product_Status__c, TF4SF__Sub_Product__c FROM TF4SF__Application__c WHERE Id = :appId];

			System.debug('app.ProductId__c: ' + app.ProductId__c);
			if (infoDebug == true) { data.put('ProductId__c', app.ProductId__c); }

			logs = SubmitToCore.JSONGenerator(tdata);
			PayPal_Settings__c paypalSettingObject = PayPal_Settings__c.getInstance();
			data.put('Client_Id' , paypalSettingObject.Client_Id__c);
			data.put('Client_Secret' , paypalSettingObject.Client_Id__c);
			LogStorage.InsertDebugLog(appId, logs.get('coreReq'), 'AccountDetails Request');
			LogStorage.InsertDebugLog(appId, logs.get('coreRes'), 'AccountDetails Response');
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in AccountDetailsPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in AccountDetailsPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'AccountDetailsPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'AccountDetailsPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}
}