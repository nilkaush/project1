public with sharing class OLBSimulator {
	public List<TF4SF__Cross_Sell_Logic__c> Getsubproduct{get; set;}
	public String PicklistResult{get; set;}
	public String SubProductResult{get; set;}
	public String currentSiteUrl{get; set;}
	public String orgName{get; set;}

	public OLBSimulator() {
		currentSiteUrl = TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c;
		this.orgName = UserInfo.getUserName().substringAfterLast('.');
	}

	@RemoteAction
	public static String encryptJSON(String json) {
		String encryptedDataString = '';

		try {
			OnlineEncryption__c OBC = OnlineEncryption__c.getOrgDefaults();
			blob cryptoKey = EncodingUtil.base64Decode(OBC.key__c);
			blob vector = EncodingUtil.base64Decode(OBC.Vector__c);
			//blob cryptoKey = EncodingUtil.base64Decode('DBgNImMvjFBmth3tTWEZXrmw1YbSWvT5BJ+QYfpnv7I=');
			//blob vector = EncodingUtil.base64Decode('kUDffr0GPCT8L1ORctecUA==');
			//Blob encrypted = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(json));
			Blob encrypted = Crypto.encrypt('AES256', cryptoKey, vector, Blob.valueOf(json));
			System.debug('the data is '+EncodingUtil.base64Encode(encrypted));
			encryptedDataString = EncodingUtil.base64Encode(encrypted);
			System.debug('length: ' + encryptedDataString.length() + '; encryptedDataString: ' + encryptedDataString);
		} catch (Exception e) {
			System.debug('The error is ' + e.getMessage());
			encryptedDataString = e.getMessage();
		}

		return encryptedDataString;
	}

	@RemoteAction
	public static String decryptData(String data) {
		String decryptedDataString = '';

		try {
			OnlineEncryption__c OBC = OnlineEncryption__c.getOrgDefaults();
			blob cryptoKey = EncodingUtil.base64Decode(OBC.key__c);
			blob vector = EncodingUtil.base64Decode(OBC.Vector__c);
			//blob cryptoKey = EncodingUtil.base64Decode('DBgNImMvjFBmth3tTWEZXrmw1YbSWvT5BJ+QYfpnv7I=');
			//blob vector = EncodingUtil.base64Decode('kUDffr0GPCT8L1ORctecUA==');
			//decryptedDataString = crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.base64Decode(data)).toString();
			decryptedDataString = crypto.decrypt('AES256', cryptoKey, vector, EncodingUtil.base64Decode(data)).toString();
			//decryptedDataString = decryptedDataString.replace('{', '{\n  ');
			//decryptedDataString = decryptedDataString.replace('}', '\n}');
			//decryptedDataString = decryptedDataString.replace(',', ',\n  ');
			System.debug('length: ' + decryptedDataString.length() + '; decryptedDataString: ' + decryptedDataString);
		} catch (Exception e) {
			System.debug('The error is ' + e.getMessage());
			decryptedDataString = e.getMessage();
		}

		return decryptedDataString;
	}

	public List<SelectOption> getProducts() {
		List<TF4SF__Product_Codes__c> products = TF4SF__Product_Codes__c.getall().values();
		List<SelectOption> options = new List<SelectOption>();
		Set<String> productSet = new Set<String>();
		List<String> distinctProducts = new List<String>();

		for (TF4SF__Product_Codes__c prod : products) {
			if (prod.TF4SF__Sub_Product__c != null) {
				productSet.add(prod.TF4SF__Product__c);
				System.debug('Product: ' + prod.TF4SF__Product__c + '; SubProduct: ' + prod.TF4SF__Sub_Product__c);
			}
		}

		for (String s : productSet) { distinctProducts.add(s); }
		distinctProducts.sort();
		for (String prodName : distinctProducts) { options.add(new SelectOption(prodName, prodName)); }

		return options;
	}

	@RemoteAction
	public static Map<String, String> getSubProducts(String selectedProduct) {
		List<TF4SF__Product_Codes__c> products = TF4SF__Product_Codes__c.getall().values();
		Map<String, String> options = new Map<String, String>();
		Set<TF4SF__Product_Codes__c> subProductSet = new Set<TF4SF__Product_Codes__c>();
		List<TF4SF__Product_Codes__c> subProductList = new List<TF4SF__Product_Codes__c>();
		if (selectedProduct == null) { selectedProduct = 'Certificates'; }

		for (TF4SF__Product_Codes__c prod : products) {
			if (prod.TF4SF__Product__c == selectedProduct && prod.TF4SF__Sub_Product__c != null) {
				subProductSet.add(prod);
				System.debug('Product: ' + prod.TF4SF__Product__c + '; SubProduct: ' + prod.TF4SF__Sub_Product__c);
			}
		}

		for (TF4SF__Product_Codes__c s : subProductSet) { subProductList.add(s); }
		subProductList.sort();
		for (TF4SF__Product_Codes__c product : subProductList) { options.put(product.Name, product.TF4SF__Sub_Product__c); }

		return options;
	}
}