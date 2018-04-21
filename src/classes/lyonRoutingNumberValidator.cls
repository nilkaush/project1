global class lyonRoutingNumberValidator implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		Map<String, String> data = new Map<String, String>();

		try {
			data = tdata.clone();
			string RoutingNumber = data.get('RoutingNumber');
			//System.debug('RoutingNumber ==>' + RoutingNumber);
			Lyon_Routing_Number__c lyonRouting = Lyon_Routing_Number__c.getOrgDefaults();
			//Validate Routing Number 
			String token = 'null';
			Map<String, String> tokenGeneratorResult = new Map<String, String>();
			Map<String, String> routingNumberResult = new Map<String, String>();
			Map<String, String> instituteDetail = new Map<String, String>();
			String res;  
			String bankState;
			String bankName;
			routingNumberResult = validateRoutingNumber(lyonRouting, token, RoutingNumber);

			if (routingNumberResult.ContainsKey('Routing Number')) {
				res = routingNumberResult.get('Routing Number');
				data.put('ValidRoutingNumber', res); 

				if (res == 'true') {
					instituteDetail = primaryInstituteDetails(lyonRouting, token, RoutingNumber); 
					if (instituteDetail.ContainsKey('name')) {
						bankName = instituteDetail.get('name');
						data.put('name', bankName); 
					}

					if (instituteDetail.ContainsKey('state')) {
						bankState = instituteDetail.get('state');
						data.put('state', bankState); 
					}
				}
			} else {
				//Return exception to front end
				data.put('ValidRoutingNumber', 'Request Failed'); 
			}
			

			if (res == null || res == '') {
				//Since the token has expired, create a new token
				//Generate Token
				tokenGeneratorResult = generateToken(lyonRouting);

				if (!tokenGeneratorResult.ContainsKey('Get New Token Failed')) { 
					token = tokenGeneratorResult.get('New Token');
					//Validate the routing number with the new token
					routingNumberResult = validateRoutingNumber(lyonRouting, token, RoutingNumber); 
					res = routingNumberResult.get('Routing Number');
					System.debug('---res----' + res);

					if (res == 'true') {
						instituteDetail = primaryInstituteDetails(lyonRouting, token, RoutingNumber); 
						if (instituteDetail.ContainsKey('name')) {
							bankName = instituteDetail.get('name');
							data.put('name', bankName); 
						}

						if (instituteDetail.ContainsKey('state')) {
							bankState = instituteDetail.get('state');
							data.put('state', bankState); 
						}
					}

					data.put('ValidRoutingNumber', res);
					lyonRouting.Token__c = token;
					update lyonRouting;
				} else {
					//Return exception to front end
					data.put('ValidRoutingNumber', 'Request Failed' ); 
				}
			}
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in lyonRoutingNumberValidator class: ' + e.getMessage());
			System.debug('server-errors: ' + e.getMessage());
		}

		return data;
	}
	
	public String walkThrough(DOM.XMLNode node, String field) {
		String result = '\n';
		if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
			if (node.getName().trim() == field) { result += node.getText().trim(); }
			for (DOM.XMLNode child : node.getChildElements()) { result += walkThrough(child, field); }

			return result;
		}

		return 'ERROR';
	}
	
	public Map<String, String> generateToken(Lyon_Routing_Number__c lyonRouting) {
		try {
			String reqBody = '';
			String userName = '' ;
			String password = '' ;
			String commpanyId = '';
			Map<String, String> tokenGeneratorResult = new Map<String, String>();

			// Create a new http object to send the request object
			HttpRequest req = new HttpRequest();
			req.setTimeout(120 * 1000);  //120 seconds
			req.setHeader('Content-Type', 'text/xml');
			req.setHeader('SOAPAction', 'http://tempuri.org/IGeneralServiceContract/Logon');
			req.setMethod('POST');

			if (lyonRouting.Enable_Production__c == false) {
				req.setEndpoint(lyonRouting.Sandbox_URL__c);
				userName = lyonRouting.Sandbox_Username__c;
				password = lyonRouting.Sandbox_Password__c; 
				commpanyId = lyonRouting.Sandbox_Company_Id__c;
				
			} else {
				req.setEndpoint(lyonRouting.Production_URL__c);
				userName = lyonRouting.Production_Username__c;
				password = lyonRouting.Production_Password__c;
				commpanyId = lyonRouting.Production_Company_Id__c; 
			}

			reqBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/"><soapenv:Header/><soapenv:Body><tem:Logon><tem:companyId>' + commpanyId + '</tem:companyId><tem:userName>' + userName + '</tem:userName><tem:password>' + password + '</tem:password></tem:Logon></soapenv:Body></soapenv:Envelope>';
			req.setBody(reqBody);
			// A response object is generated as a result of the request  
			Http http = new Http();
			HTTPResponse res = http.send(req);
			
			if (res.getStatusCode() != 200) {
				String errorMsg = 'bad http status:' + res.getStatusCode() + ' ' + res.getStatus();
				tokenGeneratorResult.put('Get New Token Failed', 'New Token Failed');
				return tokenGeneratorResult;
			}

			// Parse the response  
			Dom.Document doc = new Dom.Document();
			doc.load(res.getBody());
			Dom.XMLNode root = doc.getRootElement();
			String token = walkthrough(root, 'token').trim();
			//System.debug('returned token ==> ' + token);
			tokenGeneratorResult.put('New Token', token );

			return tokenGeneratorResult;
		} catch (Exception ex) {
			System.debug('Exception in generateToken' + ex.getMessage());
			return null;
		}
	}

	public Map<String, String> validateRoutingNumber(Lyon_Routing_Number__c lyonRouting, String lyonToken, String routingNumber) {
		try {
			Map<String, String> routingNumberResult = new Map<String, String>();
			// Create a new http object to send the request object
			HttpRequest req = new HttpRequest();
			req.setTimeout(120 * 1000);  //120 seconds
			req.setHeader('Content-Type', 'text/xml');
			req.setHeader('SOAPAction', 'http://tempuri.org/IABAExpressService/ValidateABA');
			req.setMethod('POST');

			if (lyonRouting.Enable_Production__c == false) {
				req.setEndpoint(lyonRouting.Sandbox_URL__c);
			} else {
				req.setEndpoint(lyonRouting.Production_URL__c);
			}

			String token = (lyonToken.contains('null') ?  lyonRouting.Token__c : lyonToken);
			String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/"><soapenv:Header/><soapenv:Body><tem:ValidateABA><tem:token>' + token + '</tem:token><tem:aba>' + routingNumber + '</tem:aba></tem:ValidateABA></soapenv:Body></soapenv:Envelope>';
			req.setBody(body);
			// System.debug ('Body ==> ' + body);
			// A response object is generated as a result of the request  
			Http http = new Http();
			HTTPResponse res = http.send(req);

			if (res.getStatusCode() != 200) {
				routingNumberResult.put('Routing Number Validation failed', 'Validation Failed');            
				return routingNumberResult;
			}

			// Parse the response    
			Dom.Document doc = new Dom.Document();
			doc.load(res.getBody());
			//System.debug('Valid Routing Number Body ==> ' + res.getBody());
			Dom.XMLNode root = doc.getRootElement();
			String valid = walkthrough(root, 'value').trim();
			//System.debug('Valid Ruting Number ? ==> ' + valid);
			routingNumberResult.put('Routing Number', valid);

			return routingNumberResult;
		} catch (Exception ex) {
			System.debug('Exception in validateRoutingNumer' + ex.getMessage());
			return null;
		}
	}

	public Map<String, String> primaryInstituteDetails(Lyon_Routing_Number__c lyonRouting, String lyonToken, String routingNumber) {
		try {
			System.debug('Enterd');
			Map<String, String> routingNumberResult = new Map<String, String>();
			// Create a new http object to send the request object
			HttpRequest req = new HttpRequest();
			req.setTimeout(120 * 1000);  //120 seconds
			req.setHeader('Content-Type', 'text/xml');
			req.setHeader('SOAPAction', 'http://tempuri.org/IABAService/GetPrimaryInstitutionDetails');
			req.setMethod('POST');

			if (lyonRouting.Enable_Production__c == false) {
				req.setEndpoint(lyonRouting.Sandbox_URL__c);
			} else {
				req.setEndpoint(lyonRouting.Production_URL__c);
			}

			String token = (lyonToken.contains('null') ?  lyonRouting.Token__c : lyonToken);
		 
			
			 String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/"><soapenv:Header/><soapenv:Body><tem:GetPrimaryInstitutionDetails><tem:token>' + token + '</tem:token><tem:aba>' + routingNumber + '</tem:aba></tem:GetPrimaryInstitutionDetails></soapenv:Body></soapenv:Envelope>';
			System.debug('--body --'+body );
			req.setBody(body);
			
			Http http = new Http();
			HTTPResponse res = http.send(req);

			if (res.getStatusCode() != 200) {
				routingNumberResult.put('Retrievefailed', 'Details Unavailable');            
				return routingNumberResult;
			}

			// Parse the response    
			Dom.Document doc = new Dom.Document();
			doc.load(res.getBody());
			System.debug('Valid Routing Number Body ==> ' + res.getBody());
			Dom.XMLNode root = doc.getRootElement();
			
			string name= walkthrough(root, 'name').trim();
			string state= walkthrough(root, 'state').trim();
			routingNumberResult.put('name',name);
			routingNumberResult.put('state',state);

			return routingNumberResult;
		} catch (Exception ex) {
			System.debug('Exception in validateRoutingNumer' + ex.getMessage());
			return null;
		}
	}
}