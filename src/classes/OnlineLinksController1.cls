@RestResource(urlMapping='/OnlineLinks_Landing/*')
global class OnlineLinksController1 {

    global List<TF4SF__Product_Codes__c> productlist {get; set;}
    global Set<String> prdNameSet{get; set;}
    global List<String> prdNameList{get; set;}
    global Map<String, List<TF4SF__Product_Codes__c>> prdMap{get; set;}
    global Map<Map<Integer,String>,List<TF4SF__Product_Codes__c>> prdMap2 {get; set;}
    global String ipaddress{get; set;}
    global String userAgent{get; set;}
    global String SelectedProduct{get; set;}
    public String Channel{get; set;}
    public String usrId {get; set;}
    public User loggedInUser{get; set;}
    public String defaultImage {get; set;}
    public String appid;
    public TF4SF__Application__c app = new TF4SF__Application__c ();
    public TF4SF__Application2__c app2 = new TF4SF__Application2__c ();
    public TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
    public TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
    public TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
    public TF4SF__Application_Activity__c appact = new TF4SF__Application_Activity__c();

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    global OnlineLinksController1() {
        prdNameSet = new Set<String>();
        prdNameList = new List<String>(); 
        prdMap = new Map<String, List<TF4SF__Product_Codes__c>>();
        prdMap2 = new Map<Map<Integer,String> ,List<TF4SF__Product_Codes__c>>();
        ipaddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        //productlist = TF4SF__Product_Codes__c.getAll().values();\
        Integer Order = 1;
        List<Integer> Orderlist = new List<Integer>();
        productlist = [Select Id, IsDeleted, Name, SetupOwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, TF4SF__Amount_error_message__c, TF4SF__Description__c, TF4SF__Product_Code__c, TF4SF__Product_Theme__c, TF4SF__Product__c, TF4SF__Sub_Product_Code__c, TF4SF__Sub_Product__c, ML_Code__c, Landing_Page_Description__c, Product_Image__c, TF4SF__Description_TextArea1__c, TF4SF__Description_TextArea2__c, TF4SF__Description_TextArea3__c, TF4SF__Description_TextArea4__c, TF4SF__Description_TextArea5__c, TF4SF__Description_Text__c, Order__c FROM TF4SF__Product_Codes__c ORDER BY Order__c ASC ];
        for (TF4SF__Product_Codes__c pcname : productlist)
        { 
            if(prdNameSet.add(pcname.TF4SF__Product__c))
                prdNameList.add(pcname.TF4SF__Product__c); 
         }
        for (TF4SF__Product_Codes__c porder : productlist)
        { 
            Orderlist.add(Integer.ValueOf(porder.Order__c));     
        }        
        
        System.debug('the product name is : ' + prdNameList);
        System.debug('The product list size is ' + prdNameList.size());
        String urlvalue = Apexpages.currentPage().getUrl();
        System.debug('urlvalue: ' + urlvalue);
        String type = '';
        String productname = '';
        String IsMember = '';
        

        if (ApexPages.currentPage().getParameters().containsKey('prod') && ApexPages.currentPage().getParameters().get('prod') != '') {
            productname = apexpages.currentpage().getparameters().get('prod');
        }

        if (ApexPages.currentPage().getParameters().containsKey('productType') && ApexPages.currentPage().getParameters().get('productType') != '') {
            type = apexpages.currentpage().getparameters().get('productType');
        }
        if (ApexPages.currentPage().getParameters().containsKey('IsMember') && ApexPages.currentPage().getParameters().get('IsMember') != '') {
            IsMember = apexpages.currentpage().getparameters().get('IsMember');
        }

        for (String prdName : prdNameList) {
            System.debug('prdName in loop'+prdName);
            List<TF4SF__Product_Codes__c> pcList = new List<TF4SF__Product_Codes__c>();
            List<TF4SF__Product_Codes__c> pcList1 = new List<TF4SF__Product_Codes__c>();
            List<TF4SF__Product_Codes__c> pcList2 = new List<TF4SF__Product_Codes__c>();
            Map <Integer, String> MapOrder = new Map<Integer,String>();
            pcList = [SELECT Id, Name, TF4SF__Product__c, TF4SF__Sub_Product__c, Product_Image__c, Landing_Page_Description__c,Order__c FROM TF4SF__Product_Codes__c WHERE TF4SF__Product__c = :prdName ORDER BY Order__c ASC];
            
            if (IsMember == 'True'){
                pcList2 = pcList.clone();
                pcList.clear();
                for(Integer i = 0; i < pcList2.size(); i++){
                    if(!(pcList2[i].TF4SF__Sub_Product__c.Contains('Personal Loans - Unsecured Fixed LOC')
                        || pcList2[i].TF4SF__Sub_Product__c.Contains('Personal Loans - Unsecured Variable LOC')))
                        {
                            pcList.add(pcList2[i]);
                        }
                    }
                
                }
                for (Integer lorder :  Orderlist) {
                    MapOrder.put(lorder,prdName);
                }
                prdMap2.put(MapOrder,pcList);
                System.debug('prdMap2'+prdMap2);
            
            if (type == '' && productname == '' ) 
            { 
                prdMap.put (prdName, pcList); 
                System.debug('prdMap put'+prdMap);
            }

            if (( prdName.Contains('Certificates') || prdName.Contains('Checking') || prdName.Contains('Savings')) && type=='Deposit') {
                if (productname.equals('Checking') && prdName.equals('Checking')) { prdMap.put(prdName, pcList); }
                if (productname.equals('SavingsCertificate') && (prdName.equals('Certificates') || prdName.equals('Savings'))) { prdMap.put(prdName, pcList); }
                if (productname == '') { prdMap.put (prdName, pcList); }
            }

            if ((prdName.Contains('Vehicle Loans') || prdName.Contains('Personal Loans') || prdName.Contains('Credit Cards')) && type == 'Lending') {
                if (productname == '') { prdMap.put (prdName, pcList); }
                if (productname.equals('personal') && (prdName.equals('Personal Loans')  )) {
                    for (TF4SF__Product_Codes__c pd : pcList) {
                        if (pd.TF4SF__Sub_Product__c.Contains('Personal Loans - LOC Secured Variable') || pd.TF4SF__Sub_Product__c.equals('Personal Loans - Unsecured Fixed')) { pcList1.add(pd); }
                    }
                }

                if (pcList1.size() > 0) { prdMap.put('Personal Loans and Lines of Credit', pcList1); }
                if (productname.equals('autoLoan') && (prdName.equals('Vehicle Loans')  )) { prdMap.put(prdName, pcList); }
            }
        }

        String userId;
        appId = ApexPages.currentPage().getParameters().get('id');
        usrId = ApexPages.currentPage().getParameters().get('usr');
        userId = (usrId != null) ? usrId : UserInfo.getUserId();
        loggedInUser = [SELECT Id, TF4SF__Channel__c, Name, Email, TF4SF__Location__c, Profile.Name, Active_Directory_Id__c, Teller_Id__c FROM User WHERE Id = :userId];
        //Channel = loggedInUser.TF4SF__Channel__c;
        String flag = ApexPages.currentPage().getParameters().get('flag');
        Channel = (flag == 'false') ? 'Branch' : 'Online';

        if (appId != null) {
            app = [SELECT Id, TF4SF__Custom_Checkbox2__c, TF4SF__Custom_Text1__c, TF4SF__Custom_Text2__c, TF4SF__Custom_Text3__c, TF4SF__Custom_Text4__c, TF4SF__Created_Channel__c, TF4SF__Current_Channel__c, TF4SF__Created_timestamp__c, TF4SF__Created_Branch_Name__c, TF4SF__Created_User_Email_Address__c, TF4SF__Created_Person__c, TF4SF__Current_timestamp__c, TF4SF__Current_Branch_Name__c, TF4SF__Current_Person__c, TF4SF__Application_Page__c, TF4SF__Product__c, TF4SF__Sub_Product__c, TF4SF__Type_of_Checking__c, TF4SF__Type_Of_Business_CDs__c, TF4SF__Type_Of_Business_Credit_Cards__c, TF4SF__Type_Of_Business_Checking__c, TF4SF__Type_Of_Business_Loans__c, TF4SF__Type_Of_Business_Savings__c, TF4SF__Type_of_Certificates__c, TF4SF__Type_of_Credit_Cards__c, TF4SF__Type_Of_Home_Equity__c, TF4SF__Type_of_Investments__c, TF4SF__Type_of_Mortgage_Loan__c, TF4SF__Type_of_Mortgage_Short_Application__c, TF4SF__Type_of_Personal_Loans__c, TF4SF__Type_of_Savings__c, TF4SF__Type_of_Vehicle_Loans__c FROM TF4SF__Application__c WHERE Id = :appId];
        }
    }

    global PageReference prodSub() {
        System.debug('The application id is ##########' + appId);
        PageReference p = null;

        if (appId != null) {
            System.debug('The application id is ' + appId);
            //Logger.inputSource('OfflinePageController - ProSub', appId); 
        }

        List<TF4SF__Product_Codes__c> pcList = TF4SF__Product_Codes__c.getAll().values();
        System.debug('The SelectedProduct is ' + SelectedProduct);

        //for (TF4SF__Product_Codes__c pc : pcList) {
        //    if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c == pc.TF4SF__Sub_Product__c) {
        //        app.TF4SF__Sub_Product_Description__c = pc.TF4SF__Description__c;        
        //    }
        //}
        TF4SF__Product_Codes__c pc = [SELECT Id, Name, TF4SF__Product__c, TF4SF__Sub_Product__c FROM TF4SF__Product_Codes__c WHERE Name = :SelectedProduct LIMIT 1];
        app.TF4SF__Product__c = pc.TF4SF__Product__c;
        app.TF4SF__Sub_Product__c = pc.TF4SF__Sub_Product__c;

        if (pc.TF4SF__Product__c == 'Checking') {
            app.TF4SF__Type_of_Checking__c = pc.TF4SF__Sub_Product__c;
        } else if (pc.TF4SF__Product__c == 'Savings') {
            app.TF4SF__Type_of_Savings__c = pc.TF4SF__Sub_Product__c;
        } else if (pc.TF4SF__Product__c == 'Certificates') {
            app.TF4SF__Type_of_Certificates__c = pc.TF4SF__Sub_Product__c;
        } else if (pc.TF4SF__Product__c == 'Personal Loans') {
            app.TF4SF__Type_of_Personal_Loans__c = pc.TF4SF__Sub_Product__c;
        } else if (pc.TF4SF__Product__c == 'Vehicle Loans') {
            app.TF4SF__Type_of_Vehicle_Loans__c = pc.TF4SF__Sub_Product__c;
        } else if (pc.TF4SF__Product__c == 'Credit Cards') {
            app.TF4SF__Type_of_Credit_Cards__c = pc.TF4SF__Sub_Product__c;
        }

        app.TF4SF__Number_of_Products__c = 1;
        if (ipaddress != null) { app.TF4SF__IP_Address__c = ipaddress; }
        if (userAgent != null) { app.TF4SF__User_Agent__c = userAgent; }
        if (TF4SF__Application__c.SObjectType.getDescribe().isUpdateable() && appId != null) { update app; }
        System.debug('########################## application ID' + app.id);
        //Logger.addMessage('Redirecting to INDEX page', System.now().format());

        p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'tf4sf__dsp#/eligibility'); 
        app = [SELECT Id, TF4SF__User_Token__c FROM TF4SF__Application__c WHERE Id = :app.Id];
        System.debug('Error at app ' + app);
        Cookie id = ApexPages.currentPage().getCookies().get('id');
        Cookie ut = ApexPages.currentPage().getCookies().get('ut');
        Cookie fr = ApexPages.currentPage().getCookies().get('fr');
        id = new Cookie('id', app.Id, null, -1, true);
        ut = new Cookie('ut', StartApplication.decrypt(app.TF4SF__User_Token__c), null, -1, true);
        fr = new Cookie('fr', '0', null, -1, true);
        // Logger.writeAllLogs();
        // Set the new cookie for the page
        ApexPages.currentPage().setCookies(new Cookie[]{id, ut, fr});
        p.setRedirect(false);

        return p;
    }

    @HttpPost
    global static String generateApp() {
        String page = '';
        String appRecId = '';
        TF4SF__Application__c app = new TF4SF__Application__c ();
        TF4SF__Application2__c app2 = new TF4SF__Application2__c ();
        TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
        TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
        TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
        TF4SF__Application_Activity__c appact = new TF4SF__Application_Activity__c();

        //try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            System.debug('requestBody is ' + req);

            if (req != null) {
                String requestPost = req.requestBody.toString();
                System.debug('body from startApplication = ' + requestPost);
                ApplicationData applicationPrefildata = (ApplicationData)JSON.deserializeStrict(requestPost, ApplicationData.class);
                 System.debug('body from startApplication = ' + requestPost);

                if (applicationPrefildata != null) {
                    //if (xmlString != null) {
                    //System.debug('xml exists');
                    //address = xmlData.getRootElement();
                    // prefilling member information
                    if (applicationPrefildata.firstName != null) { app.TF4SF__First_Name__c = applicationPrefildata.firstName; }
                    if (applicationPrefildata.lastName != null) { app.TF4SF__Last_Name__c = applicationPrefildata.lastName; }
                    if (applicationPrefildata.middleName != null) { app.TF4SF__Middle_Name__c = applicationPrefildata.middleName; }
                    if (applicationPrefildata.emailAddress != null) { app.TF4SF__Email_Address__c = applicationPrefildata.emailAddress; }
                    if (applicationPrefildata.cellPhoneNumber != null) { app.TF4SF__Primary_Phone_Number__c = applicationPrefildata.cellPhoneNumber; }

                    if (applicationPrefildata.customersID != null) {
                        app.TF4SF__Customer__c = applicationPrefildata.customersID;
                        app.TF4SF__Application_Page__c = 'PersonalInfoPage';
                    } else {
                        app.TF4SF__Application_Page__c = 'eligibility';
                    }

                    if (applicationPrefildata.ssn != null) { Iden.TF4SF__SSN_Prime__c = applicationPrefildata.ssn; }
                    if (applicationPrefildata.dob != null) { Iden.TF4SF__Date_Of_Birth__c = applicationPrefildata.dob; }
                    if (applicationPrefildata.idType != null) { Iden.TF4SF__ID_Type__c = applicationPrefildata.idType; }

                    //if (applicationPrefildata.idNumber != null) {
                    //    Iden.TF4SF__Identity_Number_Primary__c = applicationPrefildata.idNumber;
                    //}

                    //updating the Address Information for a customer 
                    if (applicationPrefildata.customersStreetAddress1 != null) { app.TF4SF__Street_Address_1__c = applicationPrefildata.customersStreetAddress1; }
                    if (applicationPrefildata.customersStreetAddress2 != null) { app.TF4SF__Street_Address_2__c = applicationPrefildata.customersStreetAddress2; }
                    if (applicationPrefildata.customersCity != null) { app.TF4SF__City__c = applicationPrefildata.customersCity; }
                    if (applicationPrefildata.customersState != null) { app.TF4SF__State__c = applicationPrefildata.customersState; }
                    if (applicationPrefildata.customersZipCode != null) { app.TF4SF__Zip_Code__c = applicationPrefildata.customersZipCode; }

                    //updating the Mailing Address Information for a customer 
                    //if (applicationPrefildata.customersMailingStreetAddress1 != null) {
                    //    app.TF4SF__Mailing_Street_Address_1__c = applicationPrefildata.customersMailingStreetAddress1;
                    //}

                    //if (applicationPrefildata.customersMailingStreetAddress2 != null) {
                    //    app.TF4SF__Mailing_Street_Address_2__c = applicationPrefildata.customersMailingStreetAddress2;
                    //}

                    //if (applicationPrefildata.customersMailingCity != null) {
                    //    app.TF4SF__Mailing_City__c = applicationPrefildata.customersMailingCity;
                    //}

                    //if (applicationPrefildata.customersMailingState != null) {
                    //    app.TF4SF__Mailing_State__c = applicationPrefildata.customersMailingState;
                    //}

                    //if (applicationPrefildata.customersMailingZipCode != null) {
                    //    app.TF4SF__Mailing_Zip_Code__c = applicationPrefildata.customersMailingZipCode;
                    //}

                    //if (applicationPrefildata.customersPreferredContact != null) {
                    //    app.TF4SF__Preferred_Contact_Method__c = applicationPrefildata.customersPreferredContact;   
                    //}
                    
                    //if (applicationPrefildata.customersUseDifferentAddress != null) {
                    //    app.TF4SF__Use_Different_Mailing_Address__c = Boolean.valueOf(applicationPrefildata.customersUseDifferentAddress);
                    //}

                    //if (applicationPrefildata.customersEmployer != null) {
                    //    emp.TF4SF__Employer__c = applicationPrefildata.customersEmployer;
                    //}

                    //if (applicationPrefildata.customersDepartment != null) {
                    //    app.Department__c = applicationPrefildata.customersDepartment;
                    //}

                    // Updating the Created user/type/channel information
                    if (applicationPrefildata.createdByUserId != null) {
                        app.TF4SF__Created_Person__c = applicationPrefildata.createdByUserId;
                        app.Ownerid = applicationPrefildata.createdByUserId;
                    }

                    if (applicationPrefildata.createdByBranch != null) { app.TF4SF__Created_Branch_Name__c  = applicationPrefildata.createdByBranch; }
                    if (applicationPrefildata.createdByChannel != null) { app.TF4SF__Created_Channel__c = applicationPrefildata.createdByChannel; }
                    if (applicationPrefildata.createdEmailAddress != null) { app.TF4SF__Created_User_Email_Address__c = applicationPrefildata.createdEmailAddress; }

                    //if (applicationPrefildata.createdTellerId != null) {
                    //    app.TF4SF__Custom_Text1__c = applicationPrefildata.createdTellerId;
                    //}

                    //if (applicationPrefildata.createdActiveDirectoryId != null) {
                    //    app.TF4SF__Custom_Text2__c = applicationPrefildata.createdActiveDirectoryId;
                    //}

                    // Updating the current user/type/channel information
                    if (applicationPrefildata.currentPerson != null) { app.TF4SF__Current_Person__c = applicationPrefildata.currentPerson; }
                    if (applicationPrefildata.currentBranch != null) { app.TF4SF__Current_Branch_Name__c = applicationPrefildata.currentBranch; }
                    if (applicationPrefildata.currentChannel != null) { app.TF4SF__Current_Channel__c = applicationPrefildata.currentChannel; }
                    if (applicationPrefildata.currentEmailAddress != null) { app.TF4SF__Current_User_Email_Address__c = applicationPrefildata.currentEmailAddress; }

                    //if (applicationPrefildata.currentTellerId != null) {
                    //    app.TF4SF__Custom_Text3__c = applicationPrefildata.currentTellerId;
                    //}

                    //if (applicationPrefildata.currentActiveDirectoryId != null) {
                    //    app.TF4SF__Custom_Text4__c = applicationPrefildata.currentActiveDirectoryId;
                    //}

                    //if (applicationPrefildata.isSensitive != null) {
                    //    app.TF4SF__Custom_Checkbox2__c = Boolean.valueOf(applicationPrefildata.isSensitive);
                    //}

                    app.TF4SF__Current_Timestamp__c = System.now();
                    app.TF4SF__Created_Timestamp__c = System.now();
                    app.TF4SF__Custom_DateTime5__c = System.now(); 
                    app.TF4SF__Application_Status__c = 'Open';
                    //app.TF4SF__Application_Page__c = 'PersonalInfoPage';

                    // Inserting Application and other child records
                    if (TF4SF__Application__c.SObjectType.getDescribe().isCreateable()) { insert app; }
                    app2.TF4SF__Application__c = app.Id;
                    emp.TF4SF__Application__c = app.Id;
                    iden.TF4SF__Application__c = app.Id;

                    //Fix for DL details not showing up in start application from 360 degree view
                    if (applicationPrefildata.identificationNumber != null) { iden.TF4SF__Identity_Number_Primary__c = applicationPrefildata.identificationNumber; }
                    if (applicationPrefildata.idState != null) { iden.TF4SF__State_Issued__c = applicationPrefildata.idState; }
                    if (applicationPrefildata.id_ExpirationDate != null) { iden.TF4SF__Expiry_Date__c = applicationPrefildata.id_ExpirationDate; }
                    if (applicationPrefildata.id_IssueDate != null) { iden.TF4SF__Issue_Date__c = applicationPrefildata.id_IssueDate; }
                    if (applicationPrefildata.countryofCitizenship != null) { iden.TF4SF__Citizenship__c = applicationPrefildata.countryofCitizenship; }
                    
                    acc.TF4SF__Application__c = app.Id;
                    appact.TF4SF__Application__c = app.Id;
                    appact.TF4SF__Action__c = 'Created the Application';
                    appact.TF4SF__Activity_Time__c = System.now();

                    if (TF4SF__Application2__c.SObjectType.getDescribe().isCreateable()) { insert app2; }
                    if (TF4SF__Employment_Information__c.SObjectType.getDescribe().isCreateable()) { insert emp; }
                    if (TF4SF__Identity_Information__c.SObjectType.getDescribe().isCreateable()) { insert iden; }
                    if (TF4SF__About_Account__c.SObjectType.getDescribe().isCreateable()) { insert acc; }
                    if (TF4SF__Application_Activity__c.SObjectType.getDescribe().isCreateable()) { insert appact; }
                    appRecId = app.Id;
                    //Logger.addMessage('Obtained XML with data in it', System.now().format());
                }
            }
    //  } catch (Exception e) {
    //     System.debug('Error in the generateApp method in the OfflinePage class ' + e.getmessage() + ' and the line number is ' + e.getLineNumber()); 
    //  }

        return appRecId;
    }

    global class ApplicationData {
        global String firstName;
        global String lastName;
        global String middleName;
        global String emailAddress;
        global String cellPhoneNumber;
        global String customersID;
        global String personID;
        //global String prospectID;
        global String createdByUserId;
        global String createdByBranch;
        global String createdByChannel;
        global String createdEmailAddress;
        //global String createdTellerId;
        //global String createdActiveDirectoryId;
        global String currentPerson;
        global String currentBranch;
        global String currentChannel;
        global String currentEmailAddress;
        //global String currentTellerId;
        //global String currentActiveDirectoryId;        
        global String customersStreetAddress1;
        global String customersStreetAddress2;
        global String customersCity;
        global String customersState;
        global String customersZipCode;
        //global String customersMailingStreetAddress1;
        //global String customersMailingStreetAddress2;
        //global String customersMailingCity;
        //global String customersMailingState;
        //global String customersMailingZipCode;
        //global String customersPreferredContact;
        //global String customersUseDifferentAddress;
        global String ssn;
        global String dob;
        global String idType;
        //global String idNumber;
        //global String isSensitive;
        //global String customersEmployer;
        //global String customersDepartment;
        global String applicationVersion;
        global String identificationNumber;
        global String idState;
        global String id_ExpirationDate;
        global String id_IssueDate ;
        global String countryofCitizenship ;
    }
}