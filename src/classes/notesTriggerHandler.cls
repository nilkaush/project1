public class notesTriggerHandler {

	public void ImplementNotes(Set<Id> ListNoteIds) {
		List<String> intlist = new List<String>();
		Set<Id> prodId = new Set<Id>();
		Map<Id, Note> prodNoteMap = new Map<Id, Note>();
		Map<Id, String> mapApp = new Map<Id, String>();
		List<Note> lstNote = [SELECT Id, ParentId, Title, Body FROM Note WHERE Id = :ListNoteIds];

		for (Note nt : lstNote ) {
			if (String.valueOf(nt.ParentId).startswith(ObjectPrefix.GetObjPrefix('TF4SF__Products__c'))) {
				prodId.add(nt.ParentId);
				prodNoteMap.put(nt.Id, nt);
			}
		}

		System.debug('prodnotemap: ' + prodNoteMap);
		//List<TF4SF__Application__c> lstApp = [SELECT ProductId__c, Id FROM TF4SF__Application__c where id in : appId];
		List< TF4SF__Products__c> lstApp = [SELECT TF4SF__Application__r.ProductId__c, Id FROM TF4SF__Products__c WHERE Id IN :prodId];
		for (TF4SF__Products__c app : lstApp ) { mapApp.put(app.id, app.TF4SF__Application__r.ProductId__c); }
		System.debug('mapApp: ' + mapApp);
		String template = '';
		//JSONGenerator gen = JSON.createGenerator(true);
		//gen.writeStartArray();

		for (Note nt : prodNoteMap.values() ) {
			if (mapApp.ContainsKey(nt.ParentId) && String.isNotBlank(nt.Title)) {
				System.debug('entered: ');
				/*gen.writeStartObject();
				if (mapApp.get(nt.ParentId) != null) {
					gen.writeStringField('product_app_id', mapApp.get(nt.ParentId) );
				} else {
					gen.writeStringField('product_app_id','' );
				}

				if (nt.Body != null) {
					gen.writeObjectField('messages', nt.Body);
				} else {
					gen.writeObjectField('messages', '');
				}
				gen.writeEndObject();*/
				template += '[';
				template +=   '{';
				template +=    '"product_app_id": "' + mapApp.get(nt.ParentId) + '",';
				template +=    '"messages": ["';
				template +=      nt.Body + '"';
				template +=    ']';
				template +=  '}';
				template += ']';
			}
		}

		System.debug('---str---' + template);
		http_postMethod(template);
	}

	@Future(callout=true)
	public static void http_postMethod(String jsonBody) {
		Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();

		try {
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			String authorizationHeader;
			req.setHeader('content-type', 'application/json');
			req.setHeader('Accept', 'application/json');
			req.setMethod('POST');
			req.setTimeout(120000);

			if (aPack.Enable_Production__c == false) {
				req.setEndpoint(aPack.Sandbox_URL__c + 'api/product-applications/messages/');
				authorizationHeader = 'JWT ' + aPack.Sandbox_Token__c;
			} else {
				req.setEndpoint(aPack.Production_URL__c + 'api/product-applications/messages/');
				authorizationHeader = 'JWT ' + aPack.Production_Token__c;
			}

			req.setHeader('Authorization', authorizationHeader);
			req.setBody(jsonBody);
			System.debug('jsonbodu: ' + jsonbody);
			System.debug('request: ' + req.getbody());
			HttpResponse res = http.send(req);
			System.debug('response: ' + res.getbody());
			if (res.getStatusCode() == 200) { System.debug('success'); }
		} catch (Exception e) {
			System.debug('error occoured in notestriggerHandler: ' + e.getMessage());
		}
	}
}