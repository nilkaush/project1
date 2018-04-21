@isTest
global class DriverLicenseScanMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest request) {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
		resp.setBody('{"ParseImageResult":{"DriverLicense":{"Address1":"40495 CHAPEL WAY APT 20","Address2":"","Birthdate":"1992-10-09","CardRevisionDate":"2010-04-16","City":"FREMONT","ClassificationCode":"C","ComplianceType":" ","Country":"UNITED STATES","CountryCode":"USA","EndorsementCodeDescription":"","EndorsementsCode":"NONE","ExpirationDate":"2017-10-27","EyeColor":"Black","FirstName":"ABHISHEK","FullName":"ABHISHEK MOHAN KAKALIS","Gender":"Male","HAZMATExpDate":null,"HairColor":"Black","Height":"068 IN","IIN":"636014","IssueDate":"2016-06-08","IssuedBy":"CA","JurisdictionCode":"CA","LastName":"KAKALIS","LicenseNumber":"Y3844301","LimitedDurationDocument":"True","MiddleName":"MOHAN","NamePrefix":"","NameSuffix":"","OrganDonor":null,"PostalCode":"94538-0000","Race":"","RestrictionCode":"01","RestrictionCodeDescription":"","VehicleClassCode":"C","VehicleClassCodeDescription":"","Veteran":null,"WeightKG":"62","WeightLBS":"137"},"ErrorMessage":"OK","Reference":"EB3AAAD078FD7969FA2F12863B171BCA49347910","Success":true,"ValidationCode":{"Errors":null,"IsValid":true}}}');
		resp.setStatusCode(200);
		return resp;
	}
}