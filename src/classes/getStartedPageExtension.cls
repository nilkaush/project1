global class getStartedPageExtension implements TF4SF.DSP_Interface {
	
	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = false;
		Map<String, String> data = new Map<String, String>();

		try {
			String appId = tdata.get('id');
			infoDebug = (tdata.get('infoDebug') == 'true');
			String reqLoanAmount = '';
			String term = '';

			if (data.get('About_Account__c.Term_VehicleLoans__c') != null) {
				term = data.get('About_Account__c.Term_VehicleLoans__c');
			} else {
				term = '';
			}

			if (tdata.get('About_Account__c.Requested_Loan_Amount_VehicleLoans__c') != null) {
				reqLoanAmount = tdata.get('About_Account__c.Requested_Loan_Amount_VehicleLoans__c');
			} else if (tdata.get('About_Account__c.Requested_Loan_Amount_PersonalLoans__c') != null) {
				reqLoanAmount = tdata.get('About_Account__c.Requested_Loan_Amount_PersonalLoans__c');
			} else {
				reqLoanAmount = '';
			}

			TF4SF__Application__c app = [SELECT Id, Name FROM TF4SF__Application__c WHERE Id = :appId];
			createProdApp.JSONGenerator(appId, tdata);
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in getStartedPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in getStartedPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'getStartedPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'getStartedPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}
}