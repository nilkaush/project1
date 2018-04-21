global with sharing class ProductInformationController implements TF4SF.DSP_Interface {

	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = false;
		Map<String, String> data = new Map<String, String>();

		try {
			infoDebug = (tdata.get('infoDebug') == 'true');
			data.put('Called ProductInformationController', 'true');
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in ProductInformationController class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in ProductInformationController class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'ProductInformationController - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ProductInformationController - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}
}