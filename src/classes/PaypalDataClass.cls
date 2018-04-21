global class PaypalDataClass implements TF4SF.DSP_Interface {

	global Map<String, String> main(Map<String, String> tdata) {
		Map<String, String> data = new Map<String, String>();

		try {
			//data = tdata.clone();
			PayPal_Settings__c paypalSettingObject = PayPal_Settings__c.getInstance();
			data.put('Client_Id' , paypalSettingObject.Client_Id__c);
			data.put('env' , paypalSettingObject.Environment__c);
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in PaypalDataClass class: ' + e.getMessage());
			System.debug('server-errors: ' + e.getMessage());
		}

		return data;
	}
}