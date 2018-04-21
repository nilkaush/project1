@isTest
global class MockHttpResponseValidationNegat implements HttpCalloutMock {
	// Implement this interface method
	global HTTPResponse respond(HTTPRequest req) {
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'text/json');
		res.setBody('<s:Envelope xmlns:s="http://schemass.xmlsoap.org/soap/envelope/"> <s:Body> <ValidateABAResponse xmlns="http://tempuri.org/"> <ValidateABAResult xmlns:a="http://schemas.datacontract.org/2004/07/Autoscribe.Lyons.GeneralService" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <a:errorMessage i:nil="true"/> <a:value>false</a:value> </ValidateABAResult> </ValidateABAResponse> </s:Body> </s:Envelope>');
		res.setStatusCode(200);
		return res;
	}
}