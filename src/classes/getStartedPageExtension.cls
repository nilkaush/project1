global class getStartedPageExtension implements TF4SF.DSP_Interface {
	
	global Map<String, String> main(Map<String, String> tdata) {
		Map<String, String> data = tdata.clone();

		try {
			String appId = data.get('id');
			String term = '';
			if (data.get('About_Account__c.Term_VehicleLoans__c') != null) {
				term = data.get('About_Account__c.Term_VehicleLoans__c');
			} else {
				term = '';
			}

			String reqLoanAmount = '';
			if (data.get('About_Account__c.Requested_Loan_Amount_VehicleLoans__c') != null) {
				reqLoanAmount = data.get('About_Account__c.Requested_Loan_Amount_VehicleLoans__c');
			} else if (data.get('About_Account__c.Requested_Loan_Amount_PersonalLoans__c') != null) {
				reqLoanAmount = data.get('About_Account__c.Requested_Loan_Amount_PersonalLoans__c');
			} else {
				reqLoanAmount = '';
			}

			TF4SF__Application__c app = [SELECT Id, Name FROM TF4SF__Application__c WHERE Id = :appId];
			createProdApp.JSONGenerator(appId);
			/*TF4SF__Products__c prod = new TF4SF__Products__c();
			prod.TF4SF__Product_Name__c = app.TF4SF__Sub_Product__c;
			prod.TF4SF__Application__c = appId;
			prod.TF4SF__Term__c = Decimal.ValueOf(term);
			prod.TF4SF__Requested_Loan_Amount__c = Decimal.ValueOf(reqLoanAmount);
			insert prod;*/
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in getStartedPageExtension class: ' + e.getMessage());
			System.debug('server-errors: ' + e.getMessage());
		}

		return null;
	}
}