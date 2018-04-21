public without sharing class CryptoHelper {

	private static final String RANDOM_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

	private static Blob key {
		private get{
			return EncodingUtil.base64Decode(TF4SF__Application_Configuration__c.getOrgDefaults().TF4SF__key__c);
		}
		private set;
	}

	private static Decimal timeoutSeconds {
		private get{
			TF4SF__Application_Configuration__c ac = TF4SF__Application_Configuration__c.getOrgDefaults();
			return ac.TF4SF__Timeout_Seconds__c;
		}
		private set;
	}

	private static Decimal popupSeconds {
		private get{
			TF4SF__Application_Configuration__c ac = TF4SF__Application_Configuration__c.getOrgDefaults();
			return ac.TF4SF__Popup_Seconds__c;
		}
		private set;
	}

	private static Integer timeoutMinutes {
		get{
			return Integer.valueOf(timeoutSeconds / 60);
		}
		private set;
	}

	public static void genMasterKey() {
		String newKey = EncodingUtil.base64Encode(crypto.generateAesKey(128));
		if (Schema.sObjectType.TF4SF__Application_Configuration__c.fields.TF4SF__key__c.isCreateable() && Schema.sObjectType.TF4SF__Application_Configuration__c.fields.TF4SF__key__c.isUpdateable()) {
			TF4SF__Application_Configuration__c settings = TF4SF__Application_Configuration__c.getOrgDefaults();
			settings.TF4SF__key__c = newKey;
			upsert settings;
		}
	}

	public static String encrypt(String clearText) {
		return EncodingUtil.base64Encode(crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(clearText)));
	}

	public static String decrypt(String cipherText) {
		return crypto.decryptWithManagedIV('AES128', key, EncodingUtil.base64Decode(cipherText)).toString();
	}

	public static String genUserToken() {
		return getRandomString(25);
	}

	public static void setAppToken(TF4SF__Application__c app) {
		String userToken = genUserToken();
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__User_Token__c.isUpdateable()) { app.TF4SF__User_Token__c = encrypt(userToken); }
		if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__User_Token_Expires__c.isUpdateable()) { app.TF4SF__User_Token_Expires__c = System.now().addMinutes(timeoutMinutes); }
		//return userToken;
	}

	public static void refreshToken(TF4SF__Application__c app) {
		List<TF4SF__Application__c> appList = new List<TF4SF__Application__c>();
		appList.add(app);
		refreshTokens(appList);
	}

	public static void expireToken(TF4SF__Application__c app) {
		List<TF4SF__Application__c> appList = new List<TF4SF__Application__c>();
		appList.add(app);
		expireTokens(appList);
	}

	public static void refreshTokens(List<TF4SF__Application__c> appList) {
		List<TF4SF__Application__c> newAppList;                
		for (TF4SF__Application__c app : appList) {        
			newAppList = new List<TF4SF__Application__c>();
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__User_Token_Expires__c.isUpdateable()) { app.TF4SF__User_Token_Expires__c = System.now().addMinutes(timeoutMinutes); }
			newAppList.add(app);
		}

		if (TF4SF__Application__c.SObjectType.getDescribe().isUpdateable()) { update newAppList; }
	}

	public static void expireTokens(List<TF4SF__Application__c> appList) {
		List<TF4SF__Application__c> newAppList;
		for (TF4SF__Application__c app : appList) {
			newAppList = new List<TF4SF__Application__c>();
			if (Schema.sObjectType.TF4SF__Application__c.fields.TF4SF__User_Token_Expires__c.isUpdateable()) { app.TF4SF__User_Token_Expires__c = System.now().addMinutes(-1); }
			newAppList.add(app);
		}

		if (TF4SF__Application__c.SObjectType.getDescribe().isUpdateable()) { update newAppList; }
	}


	public static boolean userTokenIsValid(String appId, String unencryptedUserToken) {
		TF4SF__Application__c app = [SELECT Id, TF4SF__User_Token__c, TF4SF__User_Token_Expires__c FROM TF4SF__Application__c WHERE Id = :appId];
		System.debug('Security token of app record is ' + app.TF4SF__User_Token__c);
		String storedToken = decrypt(app.TF4SF__User_Token__c);
		System.debug('Stored token is ' + storedToken);
		System.debug('Sending token is ' + unencryptedUserToken);
		Datetime now = System.now();
		
		if (unencryptedUserToken.equals(storedToken)) {
			if (now <= app.TF4SF__User_Token_Expires__c ) {
				return true;
			} else {
				System.debug('token expired');
				return false;
			}

			return true;
		} else {
			System.debug('token incorrect');
			return false;
		}
	}

	private static String getRandomString(Integer len) {
		String mode = String.valueOf(RANDOM_CHARS.length() - 1);
		String retVal = '';

		if (len != null && len >= 1) {
			Integer chars = 0;
			Integer random;
			do {
				random = Math.round(Math.random() * Integer.valueOf(mode));
				retVal += RANDOM_CHARS.subString(random, random + 1);
				chars++;
			} while (chars < len);
		}

		return retVal;
	}

	//returns null if user authenticates 
	//or returns to expired page if they do not
}