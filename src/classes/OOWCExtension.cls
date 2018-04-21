//Extension class for update the OOW
global class OOWCExtension implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = (tdata.get('infoDebug') == 'true');
		Map<String, String> data = tdata.clone();
		List<KYC_OOW__c> oowList = new List<KYC_OOW__c>();
		String appId = data.get('id');
		String Question1Response = data.get('Question1Response');
		String Question2Response = data.get('Question2Response');
		String Question3Response = data.get('Question3Response');
		oowList = [SELECT Id, Question_1_Response__c, Question_2_Response__c, Question_3_Response__c FROM KYC_OOW__c WHERE Application_Id__c = :appId LIMIT 1];

		if (oowList.size() > 0) {
			oowList[0].Question_1_Response__c = Question1Response;
			oowList[0].Question_2_Response__c = Question2Response;
			oowList[0].Question_3_Response__c = Question3Response;
			update oowList;
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'OOWCExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		return data;
	}
}