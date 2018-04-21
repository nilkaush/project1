//Attachment trigger on attachment save in the document request 
//Calls API
public class attachmentTriggerHandler {
	public void documentAPIHandler(Set<Id> idSet) {
		Set<Id> docId =  new Set<Id>();
		Map<Id, String> mapProd = new Map<Id, String>();
		List<Attachment> lstAttch = [SELECT Id, Name, ParentId, Body FROM Attachment WHERE Id IN :idSet];

		for (Attachment att : lstAttch) {
			if (String.valueOf(att.parentId).startsWith(ObjectPrefix.GetObjPrefix('TF4SF__Documentation_Request__c'))) { docId.add(att.ParentId); }
		}

		List<TF4SF__Documentation_Request__c> lstDoc  = [SELECT Id, TF4SF__Application__r.ProductId__c, TF4SF__Products__r.ProductId__c, TF4SF__Application__c FROM TF4SF__Documentation_Request__c WHERE Id IN :docId];
		for (TF4SF__Documentation_Request__c lDoc : lstDoc) {
			if (lDoc.TF4SF__Products__c != null && String.isNotBlank(lDoc.TF4SF__Products__r.ProductId__c)) { mapProd.put(lDoc.id, lDoc.TF4SF__Products__r.ProductId__c); }
		}

		String msgTemp = '';
		String str = null;
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartArray();
		msgTemp += '[';

		// Write data to the JSON string.
		for (Attachment att : lstAttch) {
			Integer i = 0;
			String bodyAttachment = EncodingUtil.base64Encode(att.body);

			if (mapProd.ContainsKey(att.ParentId)) {
				gen.writeStartObject();
				if (String.isNotEmpty(mapProd.get(att.ParentId))) { gen.writeStringField('product_app_id', mapProd.get(att.ParentId)); }
				gen.writeStringField('type', att.Name);
				gen.writeStringField('name', att.Name);
				gen.writeStringField('content_base_64', bodyAttachment);
				gen.writeEndObject();

				msgTemp +=   '{';
				msgTemp +=    '"product_app_id": "' + mapProd.get(att.ParentId) + '",';
				msgTemp +=    '"messages": ["';
				msgTemp +=      'Applicant has uploaded a document' + '"';
				msgTemp +=    ']';

				if (i == lstAttch.size() - 1) {
					msgTemp +=  '}';
				} else {
					msgTemp +=  '},';
				}

				i++;
			}
		}

		msgTemp += ']';
		gen.writeEndArray();
		// Get the JSON string.
		String pretty = gen.getAsString();
		System.debug('pretty' + pretty);
		//Invokes the future method 
		http_postMethod(pretty );
		notesTriggerHandler.http_postMethod(msgTemp);
	}

	@Future(callout=true)
	public static void http_postMethod(String jsonBody) {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		String authorizationHeader;
		req.setHeader('content-type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setMethod('POST');
		req.setTimeout(120000);

		if (aPack.Enable_Production__c == false) {
			req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/documents/');
			authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
		} else {
			req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/documents/');
			authorizationHeader = 'JWT ' + aPack.Production_Token__c;
		}

		req.setHeader('Authorization', authorizationHeader);
		req.setBody(jsonBody);
		System.debug('jsonbodu: ' + jsonbody);
		System.debug('request: ' + req.getbody());
		HttpResponse res = http.send(req);
		System.debug('response: ' + res.getbody());

		if (res.getStatusCode() == 200) { 
			List<Object> k1 = (List<Object>)JSON.deserializeUntyped(res.getbody());
			String stat = '';

			for (Integer u = 0; u < k1.size(); u++) {
				Map<String, Object> k = (Map<String, Object>)k1[u]; 
				if (k.containskey('success')) { stat = String.valueOf(k.get('success')); }
			}

			System.debug('stat ::' + stat);
		}
	}
}