/*
 * Description : to get the API Key from custom setting Application configuration.
 * Author : Sukesh G
 * Date : 09/14/2017
 */
global class getPostalAPIKey implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = (tdata.get('infoDebug') == 'true');
		Map<String, String> data = new Map<String, String>();
		//data = tdata.clone();

		try {
			String apiKey = '';
			String apiUrl = '';
			List<TF4SF__Application_Configuration__c> lstAppConfig = [SELECT Id, Zipcode_API_Key__c, Zipcode_ApiUrl__c FROM TF4SF__Application_Configuration__c];
			if (lstAppConfig.size() > 0) {
				apiKey = lstAppConfig[0].Zipcode_API_Key__c;
				apiUrl = lstAppConfig[0].Zipcode_ApiUrl__c ;
			}

			data.put('Application_Configuration__c.Zipcode_API__c', apiKey);
			data.put('Application_Configuration__c.Zipcode_ApiUrl__c ', apiUrl );
		} catch (Exception ex) {
			data.clear();
			System.debug('Exception : ' + ex.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'getPostalAPIKey - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'getPostalAPIKey - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}
}