/*
 * Block comments with details of changes
 */
global class DriverLicenseScan implements TF4SF.DSP_Interface {
	global Map<String, String> main(Map<String, String> tdata) {
		Long time1 = DateTime.now().getTime();
		Boolean infoDebug = (tdata.get('infoDebug') == 'true');
		Map<String, String> data = new Map<String, String>();
		data = tdata.clone();
		String backImage = '';
		String appId = data.get('id');
		Blob imageBack;
		Blob imageFront;

		try {
			String attachmentId = data.get('attachmentId');
			data.remove('attachmentId');
			data.remove('extensionClass');
			Attachment a;

			if (attachmentId != null) {
				a = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Id = :attachmentId];
				imageBack = a.Body;
			}

			List<TF4SF__Application_Configuration__c> lstCustSetting = [SELECT Id, DL_API_Key__c, DL_Endpoint_URL__c FROM TF4SF__Application_Configuration__c];
			System.debug('----a.Paremt----' + a.parentId);
			String authKey;
			String Endpoint;

			if (lstCustSetting.size() > 0) {
				authKey = lstCustSetting[0].DL_API_Key__c;
				Endpoint = lstCustSetting[0].DL_Endpoint_URL__c;
			}

			backImage = EncodingUtil.base64Encode(imageBack);
			Http h = new Http();
			HttpRequest req = new HttpRequest();
			String body = '{"authKey":"' + authKey + '", "data" : "' + backImage + '"}';

			req.setBody(body);
			req.setHeader('Content-Type', 'text/json');
			req.setHeader('Cache-Control','no-cache');
			req.setEndpoint(Endpoint);
			req.setMethod('POST');

			HttpResponse resp = h.send(req);
			String JsonResp = resp.getBody();
			String JsonStatusCode = String.valueOf(resp.getStatusCode());

			// Parsing Image Json to Application and Identity Information Object for the Applicant.
			Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JsonResp);
			System.debug('the resultMap is ' + m);
			Map<String, Object> k = (Map<String, Object>)m.get('ParseImageResult');
			System.debug('the ParseImageResult is ' + k);
			Map<String, Object> l = (Map<String, Object>)k.get('DriverLicense');
			System.debug('the DriverLicense is ' + l);
			String Address1 = String.valueOf(l.get('Address1'));
			System.debug('the Address1 is ' + Address1);
			String Address2 = String.valueOf(l.get('Address2'));
			System.debug('the Address2 is ' + Address2);
			String Birthdate = String.valueOf(l.get('Birthdate'));
			System.debug('the Birthdate is ' + Birthdate);
			String CardRevisionDate = String.valueOf(l.get('CardRevisionDate'));
			System.debug('the CardRevisionDate is ' + CardRevisionDate);
			String City = String.valueOf(l.get('City'));
			System.debug('the City is ' + City);
			String ClassificationCode = String.valueOf(l.get('ClassificationCode'));
			System.debug('the ClassificationCode is ' + ClassificationCode);
			String ComplianceType = String.valueOf(l.get('ComplianceType'));
			System.debug('the ComplianceType is ' + ComplianceType);
			String Country = String.valueOf(l.get('Country'));
			System.debug('the Country is ' + Country);
			String CountryCode = String.valueOf(l.get('CountryCode'));
			System.debug('the CountryCode is ' + CountryCode);
			String EndorsementCodeDescription = String.valueOf(l.get('EndorsementCodeDescription'));
			System.debug('the EndorsementCodeDescription is ' + EndorsementCodeDescription);
			String EndorsementsCode = String.valueOf(l.get('EndorsementsCode'));
			System.debug('the EndorsementsCode is ' + EndorsementsCode);
			String ExpirationDate = String.valueOf(l.get('ExpirationDate'));
			System.debug('the ExpirationDate is ' + ExpirationDate);
			String EyeColor = String.valueOf(l.get('EyeColor'));
			System.debug('the EyeColor is ' + EyeColor);
			String FirstName = String.valueOf(l.get('FirstName'));
			System.debug('the FirstName is ' + FirstName);
			String FullName = String.valueOf(l.get('FullName'));
			System.debug('the FullName is ' + FullName);
			String Gender = String.valueOf(l.get('Gender'));
			System.debug('the Gender is ' + Gender);
			String HAZMATExpDate = String.valueOf(l.get('HAZMATExpDate'));
			System.debug('the HAZMATExpDate is ' + HAZMATExpDate);
			String HairColor = String.valueOf(l.get('HairColor'));
			System.debug('the HairColor is ' + HairColor);
			String Height = String.valueOf(l.get('Height'));
			System.debug('the Height is ' + Height);
			String IIN = String.valueOf(l.get('IIN'));
			System.debug('the IIN is ' + IIN);
			String IssueDate = String.valueOf(l.get('IssueDate'));
			System.debug('the IssueDate is ' + IssueDate);
			String IssuedBy = String.valueOf(l.get('IssuedBy'));
			System.debug('the IssuedBy is ' + IssuedBy);
			String JurisdictionCode = String.valueOf(l.get('JurisdictionCode'));
			System.debug('the JurisdictionCode is ' + JurisdictionCode);
			String LastName = String.valueOf(l.get('LastName'));
			System.debug('the LastName is ' + LastName);

			String LicenseNumber = String.valueOf(l.get('LicenseNumber'));
			System.debug('the LicenseNumber is ' + LicenseNumber);
			String LimitedDurationDocument = String.valueOf(l.get('LimitedDurationDocument'));
			System.debug('the LimitedDurationDocument is ' + LimitedDurationDocument);
			String MiddleName = String.valueOf(l.get('MiddleName'));
			System.debug('the MiddleName is ' + MiddleName);
			String NamePrefix = String.valueOf(l.get('NamePrefix'));
			System.debug('the NamePrefix is ' + NamePrefix);
			String NameSuffix = String.valueOf(l.get('NameSuffix'));
			System.debug('the NameSuffix is ' + NameSuffix);
			String OrganDonor = String.valueOf(l.get('OrganDonor'));
			System.debug('the OrganDonor is ' + OrganDonor);

			String PostalCode = String.valueOf(l.get('PostalCode'));
			System.debug('the PostalCode is ' + PostalCode);
			String Race = String.valueOf(l.get('Race'));
			System.debug('the Race is ' + Race);
			String RestrictionCode = String.valueOf(l.get('RestrictionCode'));
			System.debug('the RestrictionCode is ' + RestrictionCode);
			String RestrictionCodeDescription = String.valueOf(l.get('RestrictionCodeDescription'));
			System.debug('the RestrictionCodeDescription is ' + RestrictionCodeDescription);
			String VehicleClassCode = String.valueOf(l.get('VehicleClassCode'));
			System.debug('the VehicleClassCode is ' + VehicleClassCode);
			String VehicleClassCodeDescription = String.valueOf(l.get('VehicleClassCodeDescription'));
			System.debug('the VehicleClassCodeDescription is ' + VehicleClassCodeDescription);
			String Veteran = String.valueOf(l.get('Veteran'));
			System.debug('the Veteran is ' + Veteran);
			String WeightKG = String.valueOf(l.get('WeightKG'));
			System.debug('the WeightKG is ' + WeightKG);
			String WeightLBS = String.valueOf(l.get('WeightLBS'));
			System.debug('the WeightLBS is ' + WeightLBS);

			String ErrorMessage = String.valueOf(k.get('ErrorMessage'));
			System.debug('the ErrorMessage is ' + ErrorMessage);
			String Reference = String.valueOf(k.get('Reference'));
			System.debug('the Reference is ' + Reference);
			String Success = String.valueOf(k.get('Success'));
			System.debug('the Success is ' + Success);
			Map<String, Object> q = (Map<String, Object>)k.get('ValidationCode');
			System.debug('the ValidationCode is ' + q);
			String Errors = String.valueOf(q.get('Errors'));
			System.debug('the Errors is ' + Errors);
			String IsValid = String.valueOf(q.get('IsValid'));
			System.debug('the IsValid is ' + IsValid);

			data.put('Application__c.First_Name__c', FirstName);
			data.put('Application__c.Last_Name__c', LastName);
			data.put('Application__c.Street_Address_1__c', Address1);
			data.put('Application__c.Street_Address_2__c', Address2);
			data.put('Application__c.City__c', City);
			data.put('Application__c.State__c', IssuedBy);
			data.put('Application__c.Zip_Code__c', PostalCode);
			data.put('Application__c.Suffix__c', NameSuffix);
			data.put('Application__c.Middle_Name__c', MiddleName);
			data.put('Identity_Information__c.Date_of_Birth__c', formatDateString(Birthdate));
			data.put('Identity_Information__c.Issue_Date__c', formatDateString(IssueDate));
			data.put('Identity_Information__c.Expiry_Date__c', formatDateString(ExpirationDate));
			data.put('Identity_Information__c.ID_Type__c', 'Driver License');
			data.put('Identity_Information__c.Identity_Number_Primary__c', LicenseNumber);
			data.put('Identity_Information__c.Country_Issued__c', Country);
			data.put('Identity_Information__c.State_Issued__c', IssuedBy);

			String CurrentDate = date.today().format();
			Date CurrentDate_DateFormat = date.parse(CurrentDate);
			Date ExpirationDate_DateFormat = date.parse(formatDateString(ExpirationDate));
			String DLStat = '';

			if (ExpirationDate_DateFormat < CurrentDate_DateFormat) {
				DLStat = 'Expired';
				data.clear(); 
				data.put('Identity_Information__c.ID_Type__c', DLStat);
			}

			if (CountryCode != 'USA') { data.clear(); }
		} catch (Exception ex) {
			List<TF4SF__Field_Logic_New__c> listFieldLogic = [SELECT Id, TF4SF__Value__c FROM TF4SF__Field_Logic_New__c WHERE TF4SF__RecType__c = 'Page Labels' AND TF4SF__Page_Type__c = 'GetStartedPage' AND TF4SF__Label_Name__c = 'DL_Scan_Error_Message'];
			data.clear();

			if (listFieldLogic != null && (!listFieldLogic.isEmpty()) ) {
				data.put('Exception', listFieldLogic[0].TF4SF__Value__c );
			} else {
				data.put('Exception', ex.getMessage());
			}

			System.debug('Exception : ' + ex.getMessage());
		}

		Long time2 = DateTime.now().getTime();
		if (infoDebug == true ) { data.put('debug-server-errors', 'DriverLicenseScan - Elapsed Call Time: ' + (time2 - time1) + 'ms'); }
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DriverLicenseScan - Elapsed Call Time: ' + (time2 - time1) + 'ms'));

		return data;
	}

	public String formatDateString(String oldDate) {
		String newDate = '';
		List<String> DateList = oldDate.split('-');
		newDate = DateList[1] + '/' + DateList[2] + '/' + DateList[0]; // change date in MM/DD/YYYY format.
		return newDate;
	}
}