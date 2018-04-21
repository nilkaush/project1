global class CancelExt implements TF4SF.DSP_Interface {

	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = (tdata.get('infoDebug') == 'true');
		Map<String, String> data = new Map<String, String>();
		String method = tdata.get('method');
		String appId = tdata.get('id');

		try {
			if (String.isNotBlank(method) && method == 'CancelApplication') {
				List<TF4SF__Application__c> app = [SELECT Id, Name, TF4SF__Primary_Product_Status__c, TF4SF__Application_Status__c FROM TF4SF__Application__c WHERE Id = :appId];
				app[0].TF4SF__Primary_Product_Status__c = 'CANCELLED';
				app[0].TF4SF__Application_Status__c = 'Abandoned';
				update app[0];
			}
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in cancelExt class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in cancelExt class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'CancelExt - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'CancelExt - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}
}