global class PersonalInfoPageExtension implements TF4SF.DSP_Interface {
	
	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = false;
		Map<String, String> data = new Map<String, String>();
		Map<String, String> logs = new Map<String, String>();

		try {
			String appId = tdata.get('id');
			infoDebug = (tdata.get('infoDebug') == 'true');
			//updateProdApp.JSONGenerator(appId);
			logs = SubmitToCore.JSONGenerator(tdata);
			//SubmitToCoreMulti.JSONGenerator(tdata);
			LogStorage.InsertDebugLog(appId, logs.get('coreReq'), 'PersonalInfoPage Request');
			LogStorage.InsertDebugLog(appId, logs.get('coreRes'), 'PersonalInfoPage Response');
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in PersonalInfoPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in PersonalInfoPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'PersonalInfoPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PersonalInfoPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}
}