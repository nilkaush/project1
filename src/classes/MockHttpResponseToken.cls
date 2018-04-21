@isTest
global class MockHttpResponseToken implements HttpCalloutMock {
	// Implement this interface method
	global HTTPResponse respond(HTTPRequest req) {
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'text/json');
		res.setBody('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"> <s:Body> <LogonResponse xmlns="http://tempuri.org/"> <LogonResult xmlns:a="http://schemas.datacontract.org/2004/07/Autoscribe.Lyons.GeneralService" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <a:errorMessage i:nil="true"/> <a:token>a587c1f6-a3e9-4594-a214-8abdc653fed2</a:token> </LogonResult> </LogonResponse> </s:Body> </s:Envelope>');
		res.setStatusCode(200);
		return res;
	}
}