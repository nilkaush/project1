public with sharing class StartApplication {
    public User loggedInUser{get; set;}
    public String userId;
    public String personId{get; set;}
    public TF4SF__Customer__c person{get; set;}
    public String version{get; set;}
    public TF4SF__Application_Configuration__c appConfig = TF4SF__Application_Configuration__c.getOrgDefaults();

    public StartApplication() {
        person = new TF4SF__Customer__c();
        userId = UserInfo.getUserId();
        loggedInUser = [SELECT Id, TF4SF__Channel__c, Name, TF4SF__Location__c, Profile.Name, Email FROM User WHERE Id = :userId];
        version = ApexPages.currentPage().getParameters().get('v');
        personId = ApexPages.currentPage().getParameters().get('id');
        if (personId != null) {
            person = [SELECT Id, TF4SF__First_Name__c, TF4SF__Middle_Name__c, TF4SF__Last_Name__c, TF4SF__Phone_Number__c, TF4SF__Cell_Phone_Number__c, TF4SF__Email_Address__c, TF4SF__Street_Address_1__c, TF4SF__Street_Address_2__c, TF4SF__City__c, TF4SF__State__c, TF4SF__Zip_Code__c, TF4SF__Person_Identifier__c, TF4SF__SSN__c, TF4SF__Date_Of_Birth__c, TF4SF__Company__c FROM TF4SF__Customer__c WHERE Id = :personId];
        }
    }

    public class MemberData {
        public String firstName;
        public String lastName;
        public String emailAddress;
        public String cellPhoneNumber;
        public String customersID;
        public String createdByUserId;
        public String createdByBranch;
        public String createdByChannel;
        public String createdEmailAddress;
        public String currentPerson;
        public String currentBranch;
        public String currentChannel;
        public String currentEmailAddress;
        public String customersStreetAddress1;
        public String customersStreetAddress2;
        public String customersCity;
        public String customersState;
        public String customersZipCode;
        public String ssn;
        public String memberNo;
        public String personId;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////// CRYPTO METHODS TO ENCRYPT THE USERTOKEN FOR OFFLINE APPLICATION//////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    private static final String RANDOM_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    private static blob key {
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

    private static String getRandomString(Integer len) {
        String mode = String.valueOf(RANDOM_CHARS.length() - 1);
        String retVal = '';
        if (len != null && len >= 1) {
            Integer chars = 0;
            Integer random;
            do {
                random = Math.round(Math.random() * Integer.valueOf(mode));
                retVal += RANDOM_CHARS.substring(random, random + 1);
                chars++;
            } while (chars < len);
        }

        return retVal;
    }

    public static string encrypt(String clearText) {
        return EncodingUtil.base64Encode(crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(clearText)));
    }

    public static string decrypt(String cipherText) {
        return crypto.decryptWithManagedIV('AES128',key, EncodingUtil.base64Decode(cipherText)).toString();
    }

    public static void setAppToken(TF4SF__Application__c app) {
        String userToken = getRandomString(25);
        app.TF4SF__User_Token__c = encrypt(userToken);
        app.TF4SF__User_Token_Expires__c = System.now().addMinutes(timeoutMinutes);
    }

    //////////////////////////////END OF CRYPTO CLASS METHODS FOR OFFLIE PAGE/////////////////////////////////
    public PageReference postDetails() {
    String  type='';
    String IsMember = '';
        if(ApexPages.currentPage().getParameters().containsKey('productType') && ApexPages.currentPage().getParameters().get('productType') != '')
        {
              type= apexpages.currentpage().getparameters().get('productType');
        }
        if(ApexPages.currentPage().getParameters().containsKey('IsMember') && ApexPages.currentPage().getParameters().get('IsMember') != '')
        {
              IsMember= apexpages.currentpage().getparameters().get('IsMember');
        }
        PageReference p = null;
        String appId = null;
        String url1 = '&flag=false';
        if(type!=''){
            url1 = url1 + '&productType='+type;
        }
        if(IsMember != ''){
            url1 = url1 + '&IsMember='+IsMember;
        }

        String url = TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'OnlineLinks?';
        /* if (version != null) { url += 'v=' + version + '&'; }*/
        url += 'id=';
        System.debug('the url generated is ' + url);

        // try {
        Map<String,String> personDataMap = new Map<String,String>();
        personDataMap.put('createdByUserId', loggedInUser.Id);
        personDataMap.put('createdByBranch', loggedInUser.TF4SF__Location__c);
        personDataMap.put('createdByChannel', loggedInUser.TF4SF__Channel__c);
        personDataMap.put('createdEmailAddress', loggedInUser.Email);
        personDataMap.put('currentPerson', loggedInUser.Id);
        personDataMap.put('currentBranch', loggedInUser.TF4SF__Location__c);
        personDataMap.put('currentChannel', loggedInUser.TF4SF__Channel__c);
        personDataMap.put('currentEmailAddress', loggedInUser.Email);
        personDataMap.put('applicationVersion', (version == null) ? appConfig.TF4SF__Application_Version__c : version);

        if (personId != null) {
            // Code for the REST Request and Response using JSON
            personDataMap.put('personId', personId);
            personDataMap.put('firstName', person.TF4SF__First_Name__c);
            personDataMap.put('lastName', person.TF4SF__Last_Name__c);
            personDataMap.put('emailAddress', person.TF4SF__Email_Address__c);
            personDataMap.put('cellPhoneNumber', person.TF4SF__Cell_Phone_Number__c);
            personDataMap.put('customersID', personId);
            personDataMap.put('memberNo', person.TF4SF__Person_Identifier__c);
            personDataMap.put('customersStreetAddress1', person.TF4SF__Street_Address_1__c);
            personDataMap.put('customersStreetAddress2', person.TF4SF__Street_Address_2__c);
            personDataMap.put('customersCity', person.TF4SF__City__c);
            personDataMap.put('customersState', person.TF4SF__State__c);
            personDataMap.put('customersZipCode', person.TF4SF__Zip_Code__c);
            personDataMap.put('ssn', person.TF4SF__SSN__c);
            personDataMap.put('dob', String.valueOf(person.TF4SF__Date_Of_Birth__c));
        } else {
            personDataMap.put('personId', '');
        }

        String jsonStr = Json.serialize(personDataMap);
        Blob body = Blob.valueOf(jsonStr);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/onlineLinks';
        req.requestBody = body;
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        appId = onlineLinksController.generateApp();

        if (appId != null) {
            System.debug('appID = ' + appId);
            TF4SF__Application__c app = [SELECT Id, TF4SF__User_Token__c FROM TF4SF__Application__c WHERE Id = :appId];
            setAppToken(app);
            update app;

            String userToken = decrypt(app.TF4SF__User_Token__c);
            Cookie id = ApexPages.currentPage().getCookies().get('id');
            Cookie ut = ApexPages.currentPage().getCookies().get('ut');
            id = new Cookie('id', appId, null, -1, true);
            ut = new Cookie('ut', userToken, null, -1, true);
            System.debug('id:' + id);
            System.debug('ut:' + ut);
            System.debug('userToken:' + userToken);
            System.debug('User_Token__c:' + app.TF4SF__User_Token__c);

            // Set the new cookie for the page
            ApexPages.currentPage().setCookies(new Cookie[]{id, ut});
            p = new PageReference(url + appId + url1);
            p.setRedirect(true);
            System.debug('the url generated is ' + p);
        } else {
            System.debug('App ID returned from REST Callout was NULL');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to Start Offline Application, Please contact the System administrator for more details'));
        }
        //  } catch(Exception e) {
        //   System.debug('The error is ' + e.getMessage() + ' and line number is ' + e.getLineNumber());
        //String s = OfflineApplicationExceptionHandling.createApplication();
        // p = new PageReference(url + s);
        //  }

        return p;
    }
}