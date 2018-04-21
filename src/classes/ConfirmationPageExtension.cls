global class ConfirmationPageExtension implements TF4SF.DSP_Interface {
	public TF4SF__Application_Configuration__c appConfig = TF4SF__Application_Configuration__c.getOrgDefaults();
	public String nameSpace { get; set; }

	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = false;
		Map<String, String> data = new Map<String, String>();

		try {
			String appId = tdata.get('id');
			infoDebug = (tdata.get('infoDebug') == 'true');
			TF4SF__Application__c app = [SELECT Id, Name, ProductId__c, TF4SF__Last_Name__c, TF4SF__Sub_Product__c, TF4SF__Primary_Product_Status__c FROM TF4SF__Application__c WHERE Id = :appId];
			TF4SF__Identity_Information__c iden = [SELECT Id, Name, TF4SF__SSN_Prime__c FROM TF4SF__Identity_Information__c WHERE TF4SF__Application__c = :appId];
			System.debug('primary product status: '+app.TF4SF__Primary_Product_Status__c);
			String newAppId;
			String method = tdata.get('method');
			//String ProductId = '863c298d-a27d-4b2f-bb37-e0bd66cd2cfe'; //data.get('productId');
			//String ProductId = 'fa4910148cc4c9a9206bfdac9d413bd';
			String ProductId = app.ProductId__c;
			String preQualifiedresponse;
			String postCrossSellResponse;
			String SSN = iden.TF4SF__SSN_Prime__c;
			this.nameSpace = (String.isEmpty(appConfig.TF4SF__Namespace__c)) ? '' : appConfig.TF4SF__Namespace__c;
			String lastName = app.TF4SF__Last_Name__c;

			if (String.isNotBlank(method)) {
				if (method == 'PreQualifiedCrossSell' && app.TF4SF__Primary_Product_Status__c == 'Approved' && (app.TF4SF__Sub_Product__c.contains('Credit Cards') || app.TF4SF__Sub_Product__c.contains('Personal Loans') || app.TF4SF__Sub_Product__c.contains('Vehicle Loans'))) { 
					// preQualifiedresponse = PreQualifiedCrossSell(SSN, lastName); 
					postCrossSellResponse = PostCrossSell(ProductId);
				}

				//if (preQualifiedresponse != null) { data.put('preQualifiedCrossSell', preQualifiedresponse); }
				if (postCrossSellResponse != null) {
					data.put('postCrossSell', postCrossSellResponse);
				} else {
					data.put('postCrossSell', '');
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ConfirmationPageExtension - postCrossSellResponse is null!'));
				}
			} else {
				if (appId != null) {
					Boolean preQualifiedOffer1 = (tdata.get('PreQualifiedOffer1') == 'true');
					Boolean preQualifiedOffer2 = (tdata.get('PreQualifiedOffer2') == 'true');
					Boolean preQualifiedOffer3 = (tdata.get('PreQualifiedOffer3') == 'true');
					Boolean preQualifiedOffer4 = (tdata.get('PreQualifiedOffer4') == 'true');
					String preQualifiedValue1 = tdata.get('PreQualifiedValue1');
					String preQualifiedValue2 = tdata.get('PreQualifiedValue2');
					String preQualifiedValue3 = tdata.get('PreQualifiedValue3');
					String preQualifiedValue4 = tdata.get('PreQualifiedValue4');
					Boolean crossQualifiedOffer1 = (tdata.get('CrossQualifiedOffer1') == 'true');
					Boolean crossQualifiedOffer2 = (tdata.get('CrossQualifiedOffer2') == 'true');
					Boolean crossQualifiedOffer3 = (tdata.get('CrossQualifiedOffer3') == 'true');
					Boolean crossQualifiedOffer4 = (tdata.get('CrossQualifiedOffer4') == 'true');
					String crossQualifiedValue1 = tdata.get('CrossQualifiedValue1');
					String crossQualifiedValue2 = tdata.get('CrossQualifiedValue2');
					String crossQualifiedValue3 = tdata.get('CrossQualifiedValue3');
					String crossQualifiedValue4 = tdata.get('CrossQualifiedValue4');
					List<String> products = new List<String>();
					List<TF4SF__Product_Codes__c> productCodes = TF4SF__Product_Codes__c.getall().values();
					Map<String, String> pcMap = new Map<String, String>();
					for (TF4SF__Product_Codes__c pc : productCodes) { if (pc.ML_Code__c != null) { pcMap.put(pc.ML_Code__c, pc.Name); } }

					//data.put('debug-server-errors', 'ConfirmationPageExtension - preQualifiedOffer1: ' + preQualifiedOffer1 + '; preQualifiedValue1: ' + preQualifiedValue1);
					//data.put('debug-server-errors', 'ConfirmationPageExtension - preQualifiedOffer2: ' + preQualifiedOffer2 + '; preQualifiedValue2: ' + preQualifiedValue2);
					//data.put('debug-server-errors', 'ConfirmationPageExtension - preQualifiedOffer3: ' + preQualifiedOffer3 + '; preQualifiedValue3: ' + preQualifiedValue3);
					//data.put('debug-server-errors', 'ConfirmationPageExtension - preQualifiedOffer4: ' + preQualifiedOffer4 + '; preQualifiedValue4: ' + preQualifiedValue4);
					if (preQualifiedOffer1 == true && String.isNotBlank(preQualifiedValue1)) { products.add(preQualifiedValue1); }
					if (preQualifiedOffer2 == true && String.isNotBlank(preQualifiedValue2)) { products.add(preQualifiedValue2); }
					if (preQualifiedOffer3 == true && String.isNotBlank(preQualifiedValue3)) { products.add(preQualifiedValue3); }
					if (preQualifiedOffer4 == true && String.isNotBlank(preQualifiedValue4)) { products.add(preQualifiedValue4); }
					if (crossQualifiedOffer1 == true && String.isNotBlank(crossQualifiedValue1)) { products.add(pcMap.get(crossQualifiedValue1)); }
					if (crossQualifiedOffer2 == true && String.isNotBlank(crossQualifiedValue2)) { products.add(pcMap.get(crossQualifiedValue2)); }
					if (crossQualifiedOffer3 == true && String.isNotBlank(crossQualifiedValue3)) { products.add(pcMap.get(crossQualifiedValue3)); }
					if (crossQualifiedOffer4 == true && String.isNotBlank(crossQualifiedValue4)) { products.add(pcMap.get(crossQualifiedValue4)); }

					if (products != null && products.size() > 0) {
						data.put('debug-server-errors', 'ConfirmationPageExtension - before cloneApp: crossQualifiedOffer1: ' + crossQualifiedOffer1 + '; crossQualifiedValue1: ' + crossQualifiedValue1);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ConfirmationPageExtension - before cloneApp: crossQualifiedOffer1: ' +  crossQualifiedOffer1 + '; crossQualifiedValue1: ' + crossQualifiedValue1));

						try {
							newAppId = cloneApp(appId, products);
							data.put('newAppId', newAppId);
						} catch (Exception e) {
							data.put('server-errors', 'Error encountered in ConfirmationPageExtension class - cloneApp: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in ConfirmationPageExtension class - cloneApp: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
						}

						setAppErrors(data);
					}
				}

				/* TODO: RMM - comment out for now
				String JsonResponsePost = PostCrossSell(ProductId); 
				System.debug('the PostCrossSell response is ' + JsonResponsePost);
				*/
				//String JsonResponsePre = PreQualifiedCrossSell(SSN); 
				//System.debug('the PreCrossSell response is '+JsonResponsePre);
			}
		} catch (Exception e) {
			data.put('server-errors', 'Error encountered in ConfirmationPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered in ConfirmationPageExtension class: ' + e.getMessage() + '; line: ' + e.getLineNumber() + '; type: ' + e.getTypeName() + '; stack trace: ' + e.getStackTraceString()));
			System.debug('server-errors: ' + e.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'ConfirmationPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ConfirmationPageExtension - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}

	global sObject getObjectFields(String objectName, String appId, Set<String> fieldSet) {
		sObject obj;

		try {
			String idQuery = (objectName == 'TF4SF__Application__c') ? ' WHERE Id = \'' + String.escapeSingleQuotes(appId) + '\' ' :
				' WHERE TF4SF__Application__c = \'' + String.escapeSingleQuotes(appId) + '\' ';
			Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
			for (String fn : objectFields.keySet()) { fieldSet.add(String.valueOf(objectFields.get(fn))); }
			String query = 'SELECT ' + String.join(new List<String>(fieldSet), ', ') + ' FROM ' + objectName + idQuery + ' LIMIT 1';
			obj = database.query(query);
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage() + '; ' + e.getLineNumber()));      
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Stack Trace: getObjectFields() line 112:' + e.getStackTraceString()));      
		}
		
		return obj;
	}

	global static void setAppErrors(Map<String, String> appData) {
		List<Apexpages.Message> msgsList = ApexPages.getMessages();
		String errorMsgs = '';
		String warningMsgs = '';
		String infoMsgs = '';

		for (Apexpages.Message m : msgsList) {
			if (m.getSeverity() == ApexPages.Severity.WARNING) {
				warningMsgs += m.getDetail() + '\n';
			} else if (m.getSeverity() == ApexPages.Severity.INFO) {
				infoMsgs += m.getDetail() + '\n';
			} else {
				errorMsgs += m.getDetail() + '\n';
			}
		}

		if (String.isNotEmpty(infoMsgs)) { appData.put('debug-server-errors', infoMsgs); }
		if (String.isNotEmpty(warningMsgs)) { appData.put('server-errors-stack-trace', warningMsgs); }
		if (String.isNotEmpty(errorMsgs)) { appData.put('server-errors', errorMsgs); }
	}

	global static TF4SF__Application__c setAppValues(TF4SF__Application__c app, List<String> products) {
		String subProductCode = products[0];
		TF4SF__Product_Codes__c pc = new TF4SF__Product_Codes__c(); // Instantiating the custom settings for the product codes
		TF4SF__Application_Configuration__c appConfig = TF4SF__Application_Configuration__c.getOrgDefaults();
		pc = (subProductCode == null) ? null : TF4SF__Product_Codes__c.getValues(subProductCode);

		if (pc != null) {
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Product__c.isCreateable()) { app.TF4SF__Product__c = pc.TF4SF__Product__c; }
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Sub_Product__c.isCreateable()) { app.TF4SF__Sub_Product__c = pc.TF4SF__Sub_Product__c; }
			if (String.isNotBlank(pc.TF4SF__Product_Theme__c)) {
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Theme_URL__c.isCreateable()) { app.TF4SF__Theme_URL__c = pc.TF4SF__Product_Theme__c; }
			}

			if (products.size() > 1) {
				String primaryOfferCode = products[1];
				pc = (primaryOfferCode == null) ? null : TF4SF__Product_Codes__c.getValues(primaryOfferCode);
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Primary_Offer__c.isCreateable()) { app.TF4SF__Primary_Offer__c = pc.TF4SF__Sub_Product__c; }

				if (products.size() > 2) {
					String secondOfferCode = products[2];
					pc = (secondOfferCode == null) ? null : TF4SF__Product_Codes__c.getValues(secondOfferCode);
					if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Second_Offer__c.isCreateable()) { app.TF4SF__Second_Offer__c = pc.TF4SF__Sub_Product__c; }

					if (products.size() > 3) {
						String thirdOfferCode = products[3];
						pc = (thirdOfferCode == null) ? null : TF4SF__Product_Codes__c.getValues(thirdOfferCode);
						if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Third_Offer__c.isCreateable()) { app.TF4SF__Third_Offer__c = pc.TF4SF__Sub_Product__c; }
					}
				}
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Product Code: ' + subProductCode + ' is invalid.'));
		}

		//CryptoHelperV2.setAppToken(app);
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Created_timestamp__c.isCreateable()) { app.TF4SF__Created_timestamp__c = System.now(); }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Current_timestamp__c.isCreateable()) { app.TF4SF__Current_timestamp__c = System.now(); }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Application_Page__c.isCreateable()) { app.TF4SF__Application_Page__c = 'AccountDetailsPage'; }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Application_Status__c.isCreateable()) { app.TF4SF__Application_Status__c = 'Open'; }

		Integer i = 0;
		String prodName;
		String productMappingName;

		if (app.TF4SF__Product__c.contains(TF4SF__Product_Names_Mapping__c.getValues('Business').TF4SF__Product_Name__c)) {
			// To update type of BusinessChecking product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessChecking').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Checking__c.isCreateable()) { app.TF4SF__Type_Of_Business_Checking__c = prodName; }
			if (app.TF4SF__Type_Of_Business_Checking__c != null) { i = i + 1; }

			// To update Type of BusinessSavings Product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessSavings').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Savings__c.isCreateable()) { app.TF4SF__Type_Of_Business_Savings__c = prodName; }
			if (app.TF4SF__Type_Of_Business_Savings__c != null) { i = i + 1; }

			// To update type of BusinessCDs product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessCDs').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_CDs__c.isCreateable()) { app.TF4SF__Type_Of_Business_CDs__c = prodName; }
			if (app.TF4SF__Type_Of_Business_CDs__c != null) { i = i + 1; }

			// To update type of BusinessCreditCards selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessCreditCards').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Credit_Cards__c.isCreateable()) { app.TF4SF__Type_Of_Business_Credit_Cards__c = prodName; }
			if (app.TF4SF__Type_Of_Business_Credit_Cards__c != null) { i = i + 1; }

			// To update type of BusinessLoans selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('BusinessLoans').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Business_Loans__c.isCreateable()) { app.TF4SF__Type_Of_Business_Loans__c = prodName; }
			if (app.TF4SF__Type_Of_Business_Loans__c != null) { i = i + 1; }
		} else {
			// to update type of Checking Product Selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('Checking').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Checking__c.isCreateable()) { app.TF4SF__Type_of_Checking__c = prodName; }
			if (app.TF4SF__Type_of_Checking__c != null) { i = i + 1; }

			// To update Type of Savings Product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('Savings').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Savings__c.isCreateable()) { app.TF4SF__Type_of_Savings__c = prodName; }
			if (app.TF4SF__Type_of_Savings__c != null) { i = i + 1; }

			// To update type of Certificates product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('Certificates').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Certificates__c.isCreateable()) { app.TF4SF__Type_of_Certificates__c = prodName; }
			if (app.TF4SF__Type_of_Certificates__c != null) { i = i + 1; }

			// To update type of Credit Cards selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('CreditCards').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Credit_Cards__c.isCreateable()) { app.TF4SF__Type_of_Credit_Cards__c = prodName; }
			if (app.TF4SF__Type_of_Credit_Cards__c != null) { i = i + 1; }

			// To update type of Vehicle Loans selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('VehicleLoans').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Vehicle_Loans__c.isCreateable()) { app.TF4SF__Type_of_Vehicle_Loans__c = prodName; }
			if (app.TF4SF__Type_of_Vehicle_Loans__c != null) { i = i + 1; }

			// To update type of Personal Loan selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('PersonalLoans').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Personal_Loans__c.isCreateable()) { app.TF4SF__Type_of_Personal_Loans__c = prodName; }
			if (app.TF4SF__Type_of_Personal_Loans__c != null) { i = i + 1; }

			// To update type of Mortgage Loan product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('HomeLoan').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_of_Mortgage_Loan__c.isCreateable()) { app.TF4SF__Type_of_Mortgage_Loan__c = prodName; }
			if (app.TF4SF__Type_of_Mortgage_Loan__c != null) { i = i + 1; }
						
			// To update type of Home Equity product selected
			productMappingName = TF4SF__Product_Names_Mapping__c.getValues('HomeEquity').TF4SF__Product_Name__c;
			if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c.contains(productMappingName)) {
				prodName = app.TF4SF__Sub_Product__c;
			} else if (app.TF4SF__Primary_Offer__c != null && app.TF4SF__Primary_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Primary_Offer__c;
			} else if (app.TF4SF__Second_Offer__c != null && app.TF4SF__Second_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Second_Offer__c;
			} else if (app.TF4SF__Third_Offer__c != null && app.TF4SF__Third_Offer__c.contains(productMappingName)) {
				prodName = app.TF4SF__Third_Offer__c;
			} else {
				prodName = null;
			}

			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Type_Of_Home_Equity__c.isCreateable()) { app.TF4SF__Type_Of_Home_Equity__c = prodName; }
			if (app.TF4SF__Type_Of_Home_Equity__c != null) { i = i + 1; }
		}

		if (app.TF4SF__Primary_Offer__c != null) {
			List<String> l1 = app.TF4SF__Primary_Offer__c.split('-', 10);
			if (l1[0] != null) {
				prodName = l1[0].trim();
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Cross_Sell_1_Product__c.isCreateable()) { app.TF4SF__Cross_Sell_1_Product__c = prodName; }
			}
		}

		if (app.TF4SF__Second_Offer__c != null) {
			List<String> l2 = app.TF4SF__Second_Offer__c.split('-', 10);
			if (l2[0] != null) {
				prodName = l2[0].trim();
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Cross_Sell_2_Product__c.isCreateable()) { app.TF4SF__Cross_Sell_2_Product__c = prodName; }
			}
		}

		if (app.TF4SF__Third_Offer__c != null) {
			List<String> l3 = app.TF4SF__Third_Offer__c.split('-', 10);
			if (l3[0] != null) {
				prodName = l3[0].trim();
				if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Cross_Sell_3_Product__c.isCreateable()) { app.TF4SF__Cross_Sell_3_Product__c = prodName; }
			}
		}

		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__Number_of_Products__c.isCreateable()) { app.TF4SF__Number_of_Products__c = i; }
		System.debug('after number of products is' + app.TF4SF__Number_of_Products__c); 
		return app;
	}

	global String cloneApp(String appId, List<String> products) {
		String newAppId = null;

		try { // Instantiate all of the required Objects
			TF4SF__Application__c app = new TF4SF__Application__c();
			TF4SF__Application2__c app2 = new TF4SF__Application2__c();
			TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
			TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
			TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
			TF4SF__Application_Activity__c appAct = new TF4SF__Application_Activity__c();
			Set<String> appFieldsSet = new Set<String>();
			Set<String> app2FieldsSet = new Set<String>();
			Set<String> empFieldsSet = new Set<String>();
			Set<String> idenFieldsSet = new Set<String>();
			Set<String> accFieldsSet = new Set<String>();

			if (appId != null) {
				try {
					TF4SF__Application__c tmpApp = (TF4SF__Application__c)getObjectFields('TF4SF__Application__c', appId, appFieldsSet);
					TF4SF__Application2__c tmpApp2 = (TF4SF__Application2__c)getObjectFields('TF4SF__Application2__c', appId, app2FieldsSet);
					TF4SF__Employment_Information__c tmpEmp = (TF4SF__Employment_Information__c)getObjectFields('TF4SF__Employment_Information__c', appId, empFieldsSet);
					TF4SF__Identity_Information__c tmpIden = (TF4SF__Identity_Information__c)getObjectFields('TF4SF__Identity_Information__c', appId, idenFieldsSet);
					TF4SF__About_Account__c tmpAcc = (TF4SF__About_Account__c)getObjectFields('TF4SF__About_Account__c', appId, accFieldsSet);

					for (String fn : appFieldsSet) { try { if (fn.contains('__c')) { app.put(fn, tmpApp.get(fn)); } } catch (Exception e2) {} }
					for (String fn2 : app2FieldsSet) { try { if (fn2.contains('__c')) { app2.put(fn2, tmpApp2.get(fn2)); } } catch (Exception e2) {} }
					for (String fn3 : empFieldsSet) { try { if (fn3.contains('__c')) { emp.put(fn3, tmpEmp.get(fn3)); } } catch (Exception e2) {} }
					for (String fn4 : idenFieldsSet) { try { if (fn4.contains('__c')) { iden.put(fn4, tmpIden.get(fn4)); } } catch (Exception e2) {} }
					//for (String fn5 : accFieldsSet) { try { if (fn5.contains('__c')) { acc.put(fn5, tmpAcc.get(fn5)); } } catch (Exception e2) {} }

					if (Schema.sObjectType.TF4SF__About_Account__c.fields.TF4SF__Account_Holder_Name_CERT__c.isUpdateable()) { acc.TF4SF__Account_Holder_Name_CERT__c = app.TF4SF__First_Name__c + ' ' + app.TF4SF__Last_Name__c; }
					if (Schema.sObjectType.TF4SF__About_Account__c.fields.TF4SF__Account_Holder_Name_CHK__c.isUpdateable()) { acc.TF4SF__Account_Holder_Name_CHK__c = app.TF4SF__First_Name__c + ' ' + app.TF4SF__Last_Name__c; }
					if (Schema.sObjectType.TF4SF__About_Account__c.fields.TF4SF__Account_Holder_Name_SAV__c.isUpdateable()) { acc.TF4SF__Account_Holder_Name_SAV__c = app.TF4SF__First_Name__c + ' ' + app.TF4SF__Last_Name__c; }

					//System.debug('app: ' + app);
					//System.debug('app2: ' + app2);
					//System.debug('emp: ' + emp);
					//System.debug('iden: ' + iden);
					//System.debug('acc: ' + acc);
					//for (String fn : appData.keySet()) {setFieldData(appData, obj, fn, fieldMap, debug); }
				} catch (Exception e) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage() + '; ' + e.getLineNumber()));      
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Stack Trace: ConfirmationPageExtension: cloneApp() line 467:' + e.getStackTraceString()));      
				}
			}

			//for (String fn : appData.keySet()) {setFieldData(appData, obj, fn, fieldMap, debug); }
			//for (String appFn : appFieldsSet) {
			//    if (app.get(appFn) != null) { System.debug('appFn: ' + appFn + '; value: ' + app.get(appFn)); }
			//}

			//TF4SF__Application__c.TF4SF__Application_Status__c = 'Open';
			app = setAppValues(app, products);
			if (TF4SF__Application__c.SObjectType.getDescribe().isCreateable()) { insert app; }
			newAppId = app.Id;

			System.debug('app.Id: ' + app.Id);
			if (Schema.sObjectType.TF4SF__Application2__c.fields.TF4SF__Application__c.isCreateable()) { app2.TF4SF__Application__c = app.Id; }
			if (Schema.sObjectType.TF4SF__Employment_Information__c.fields.TF4SF__Application__c.isCreateable()) { emp.TF4SF__Application__c = app.Id; }
			if (Schema.sObjectType.TF4SF__Identity_Information__c.fields.TF4SF__Application__c.isCreateable()) { iden.TF4SF__Application__c = app.Id; }
			if (Schema.sObjectType.TF4SF__About_Account__c.fields.TF4SF__Application__c.isCreateable()) { acc.TF4SF__Application__c = app.Id; }

			if (TF4SF__Application2__c.SObjectType.getDescribe().isCreateable()) { insert app2; }
			if (TF4SF__Employment_Information__c.SObjectType.getDescribe().isCreateable()) { insert emp; }
			if (TF4SF__Identity_Information__c.SObjectType.getDescribe().isCreateable()) { insert iden; }
			if (TF4SF__About_Account__c.SObjectType.getDescribe().isCreateable()) { insert acc; }
			if (TF4SF__Application_Activity__c.SObjectType.getDescribe().isCreateable()) { insert appact; }

			//String userToken = CryptoHelperV2.decrypt(app.TF4SF__User_Token__c);
			//System.debug('userToken: ' + userToken);
			String dspUrl = nameSpace + 'dsp';
			System.debug('dspUrl: ' + dspUrl);
/*
			PageReference p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + dspUrl + '?id=' + app.Id + '#account-details');
			System.debug('p: ' + p);
			Cookie id = ApexPages.currentPage().getCookies().get('id');
			Cookie ut = ApexPages.currentPage().getCookies().get('ut');
			id = new Cookie('id', app.Id, null, -1, true);
			ut = new Cookie('ut', userToken, null, -1, true);

			System.debug('id: ' + id + '; ut: ' + ut);
			// Set the new cookie for the page
			ApexPages.currentPage().setCookies(new Cookie[]{id, ut});
			p.setRedirect(false);
*/
		} catch (Exception e) {
			System.debug('Error was encountered in the ConfirmationPageExtension - cloneApp method: ' + e.getStackTraceString());
		}

		return newAppId;
	}

	global String PostCrossSell(String ProductId) {
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String url = '';
		String header = '';
		ProductId = 'bfa4910148cc4c9a9206bfdac9d413bd';

		if (alpha.Enable_Production__c == true) {
			url = alpha.Production_URL__c;
			header = 'JWT ' + alpha.Production_Token__c;      
		} else {
			url = alpha.Sandbox_URL__c;
			header = 'JWT ' + alpha.Sandbox_Token__c;
		}

		String responseJson = '';
		HttpRequest req = new HttpRequest();
		String body = '';
		req.setTimeout(120 * 1000);  //120 seconds
		//req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
		url += 'api/product-applications/cross-qualifications/?prodappids=' + ProductId;
		req.setEndpoint(url);
		req.setHeader('authorization', header);
		req.setMethod('GET'); 
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 

		if (response.getStatusCode() != 200) {
			String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
			//System.debug(errorMsg);
		}

		responseJson = response.getBody();
		System.debug('Response: ' + responseJson);
		//InsertDebugLog(appId, json, 'TIPIntegraion Request');
		//InsertDebugLog(appId, responseJSON, 'TIPIntegraion Response');
		return responseJson;
	}

	global String PreQualifiedCrossSell(String SSN, String lastName) {
		Alpha_Pack__c alpha = Alpha_Pack__c.getOrgDefaults();
		String url = '';
		String header = '';

		if (alpha.Enable_Production__c == true) {
			url = alpha.Production_URL__c;
			header = 'JWT ' + alpha.Production_Token__c;      
		} else {
			url = alpha.Sandbox_URL__c;
			header = 'JWT ' + alpha.Sandbox_Token__c;
		}

		String responseJson = '';
		HttpRequest req = new HttpRequest();
		String body = '';
		req.setTimeout(120 * 1000);  //120 seconds
		//req.setEndpoint('callout:Ameris_Test_Named_Credential/AmerisIPService/tfapi/application');
		url += 'api/product-applications/prequalifications/?federalid=' + SSN + '&lastname=' + lastName;
		req.setEndpoint(url);
		req.setHeader('authorization', header);
		req.setMethod('GET'); 
		req.setHeader('content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		Http http = new Http();
		HttpResponse response;
		response = http.send(req); 

		if (response.getStatusCode() != 200) {
			String errorMsg = 'bad http status:' + response.getStatusCode() + ' ' + response.getStatus();
			//System.debug(errorMsg);
		}

		responseJson = response.getBody();
		System.debug('Response: ' + responseJson);
		//InsertDebugLog(appId, json, 'TIPIntegraion Request');
		//InsertDebugLog(appId, responseJSON, 'TIPIntegraion Response');

		return responseJson;
	}
}