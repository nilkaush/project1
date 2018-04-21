public with sharing class OnlineBankingCryptoClass {
	// Key provided by FT.
	static Blob KEY = Blob.valueOf('nKQzvTOpWZcksaN6blkh2zxS6tMzfFNVge05u3eju6E=');
	// Construct 16byte [0x00] byte array for our initialization vector.
	static Blob IV = EncodingUtil.base64Decode('CfcJBEY8dT3HT3YNpsEUpQ==');
	static String ALGORITHM = 'AES256';
	
	// Set initial values, can be overwritten by constructor
	Blob myIv = IV;
	Blob myKey = KEY;
	String myAlgorithm = ALGORITHM;

	public OnlineBankingCryptoClass() {}
	
	public OnlineBankingCryptoClass(String pKey) {
		this.myKey = Blob.valueOf(pKey);
		this.myAlgorithm = (pKey.length() == 16) ? 'AES128' : ALGORITHM;
	}
	
	public OnlineBankingCryptoClass(String pKey, String pIv) {
		this.myIv = Blob.valueOf(pIv);
		this.myKey = Blob.valueOf(pKey);
		this.myAlgorithm = (pKey.length() == 16) ? 'AES128' : ALGORITHM;
	}

	public String encrypt(String srcData) {
		if (String.isBlank(srcData)) { return null; }
		//Blob encryptedData = Crypto.encrypt(this.myAlgorithm, this.myKey, this.myIv, Blob.valueOf(srcData));
		//return EncodingUtil.base64Encode(encryptedData);
		//String Key = 'nKQzvTOpWZcksaN6blkh2zxS6tMzfFNVge05u3eju6E=';
		//blob cryptoKey = EncodingUtil.base64Decode(key);
		//Blob cryptoKey = Crypto.generateAesKey(256);
		//System.debug('key is '+EncodingUtil.base64Encode(cryptoKey));
		//Blob data = Blob.valueOf('<?xml version="1.0" encoding="utf-8"?><AccountVerificationRequest><User><LoginName>appltest</LoginName><Password>Welcome@1</Password></User></AccountVerificationRequest>');
		//Blob data = Blob.valueOf('{"FirstName":"JOSEPH","MiddleName":"J","LastName":"PHILLIPS","FullName":"JOSEPH J PHILLIPS","Address1":"21 E FOREST AVE","Address2":"","City":"PITTSBURGH","State":"PA","Zip":"15202","ZipPlusFour":"1253","PrimaryPhone":"(412) 766-6657","WorkPhone":"(412) 766-6657","TaxIdentifier":"666632067","PersNumber":"3145243","DOB":"09/17/1946","EmailAddress":"Darron.Haworth@firsttechfed.com","IDType":"State Driver License","IDNumber":"C2536369","IDStateIssued":"CA","IDIssueDate":"09/09/2013","IDExpirationDate":"09/08/2017","IsEmployee":false,"isOrgAccount":false}');
		Blob encrypted = Crypto.encryptWithManagedIV('AES256', KEY, Blob.valueOf(srcdata));
		System.debug('the data is '+EncodingUtil.base64Encode(encrypted));
		return EncodingUtil.base64Encode(encrypted);
	}
	
	public String decrypt(String encData) {
		try {
			if (String.isBlank(encData)) { return null; }
			Blob decryptedData = Crypto.decryptWithManagedIV('AES256', KEY, EncodingUtil.base64Decode(encData));
			return decryptedData.toString();
		} catch (Exception e) {
			System.debug('############ exception is: ' + e);
		}

		return null;
	}
	
	// Use default values.   Skip instantiation if defaults work for you.
	public static String sEncrypt(String srcData) {
		if (String.isBlank(srcData)) { return null; }
		Blob encryptedData = Crypto.encryptWithManagedIV(ALGORITHM, KEY, Blob.valueOf(srcData));
		return EncodingUtil.base64Encode(encryptedData);
	}
	
	public static String sDecrypt(String encData) {
		if (String.isBlank(encData)) { return null; }
		Blob data = EncodingUtil.base64Decode(encData);
		Blob decryptedData = Crypto.decrypt(ALGORITHM, KEY, IV, data);
		return decryptedData.toString();
	}
}