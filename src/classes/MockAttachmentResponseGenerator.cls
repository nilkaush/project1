@isTest
public class MockAttachmentResponseGenerator implements HttpCalloutMock {
	protected Integer code;
	protected String status;
	protected String body;
	protected Map<String, String> responseHeaders;

	public MockAttachmentResponseGenerator() {}

	public MockAttachmentResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
		this.code = code;
		this.status = status;
		this.body = body;
		this.responseHeaders = responseHeaders;
	}

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse resp = new HttpResponse();
		resp.setStatusCode(code);
		resp.setStatus(status);
		resp.setBody(body);

		if (responseHeaders != null) {
			for (String key : responseHeaders.keySet()) { resp.setHeader(key, responseHeaders.get(key)); }
		}

		return resp;
	}
}