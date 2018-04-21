global class EmploymentPageExtension implements TF4SF.DSP_Interface {
	
	global Map<String, String> main(Map<String, String> tdata) {
		Map<String, String> data = tdata.clone();

		try {
			String appId = data.get('id');
			SubmitToCore.JSONGenerator(data);
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in EmploymentPageExtension class: ' + e.getMessage());
			System.debug('server-errors: ' + e.getMessage());
		}

		return null;
	}
}