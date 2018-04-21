global class CrossSellPageExtension implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = (tdata.get('infoDebug') == 'true');
		Map<String, String> data = new Map<String, String>();

		try {
			String method = tdata.get('method');
			Boolean next = (tdata.get('next') == 'true');

			if (String.isNotBlank(method) && method == 'getAllProductCodes') {
				List<TF4SF__Product_Codes__c> productCodesList = TF4SF__Product_Codes__c.getAll().values();
				System.debug('productCodesList: ' + productCodesList);
			} else if (next == true) {
				String appId = tdata.get('id');
				System.debug('appId: ' + appId);
				TF4SF__Application__c app = [SELECT Id, Name FROM TF4SF__Application__c WHERE Id = :appId];
				System.debug('application: ' + app);
				createProdApp.JSONGenerator(appId, tdata);
				data.put('debug-server-errors', 'After call to createProdApp.JSONGenerator()');
			}
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in CrossSellPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in CrossSellPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'CrossSellPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'CrossSellPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}
}