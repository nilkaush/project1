/*public class Search_Member{
    public Date dat {get;set;}
    public Search_Member() {

    }
}*/

public with sharing class Search_Member1 {
    public String firstnameQuery {get; set;}
    public String lastnameQuery {get; set;}
    public String ssnLast4Query {get; set;}
    public String MemberQuery {get;set;}
    public String EmailQuery {get;set;}
    
    public List<Account> accounts = new List<Account>();
    public Boolean searchMsg {get; set;}
    public Boolean appsearchMsg {get; set;}
    public Boolean searchMsgDetails {get; set;}
    public String imageURL{get; set;}
    public List<Product__c> accDetails = new List<Product__c>();
    public Boolean ShowMemberNo {get; set;}
    public Boolean ShowApplicantNo {get; set;}
    public Boolean ShowappMemberNo {get; set;}
    public Boolean ShowPersonNo {get; set;}
    public Boolean ShowStartApplication {get; set;}
    // Declaring variables to paginate search results
    public ApexPages.StandardSetController ssc {get; set;}
    public ApexPages.StandardSetController assc {get; set;}
    public List<AccountWrapper> accWrapper{get; set;}

    public Integer counter = 0;
    public Integer appcounter = 0;
    // Declaring variables to maintain member search result limitations
    public Integer maxSearchResults{get; set;}
    public Integer recordsPerPage {get;set;}
    
    // Application Search Criteria

    public String phoneNumberQuery{get; set;}
    public String appfirstnameQuery {get; set;}
    public String applastnameQuery {get; set;}
    public String appssnLast4Query {get; set;}
    public String appEmailQuery {get; set;}
    public String ApplicationQuery {get; set;}
    public String appMemberQuery {get; set;}
    public String FromDate {get; set;}
    public String ToDate {get; set;}
    public String dat {get; set;}
    public List<TF4SF__Application__c> applications = new List<TF4SF__Application__c>();
    public List<TF4SF__Identity_Information__c> identity = new List<TF4SF__Identity_Information__c>();
    public List<String> IdenList = new List<String>();
    public List<ApplicationWrapper> appWrapper{get; set;}
    
    // Constructor
    public Search_Member1() {
   // ToDate = String.ValueOf(Date.Today());
          Date d = date.today();
          Date d1 = d.addMonths(-3);

        ToDate  = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM/dd/YYYY');
        FromDate =DateTime.newInstance(d1.year(),d1.month(),d1.day()).format('MM/dd/YYYY');
       
        imageURL='/servlet/servlet.FileDownload?file=';
        List< document > documentList = [SELECT Name FROM Document WHERE Name = 'Golden One Logo'];
       
        // fetching Search limitation from Service Configuration custom settings
        if (Service_Configuration__c.getOrgDefaults().Search_Member_Limit__c != null) {
            maxSearchResults = Integer.valueOf(Service_Configuration__c.getOrgDefaults().Search_Member_Limit__c);
        } else {
            maxSearchResults = 100;
        }
        
        if (Service_Configuration__c.getOrgDefaults().Search_Member_Result_Per_Page__c != null) {
            recordsPerPage = Integer.valueOf(Service_Configuration__c.getOrgDefaults().Search_Member_Result_Per_Page__c);
        } else {
            recordsPerPage = 25;
        }

        if (documentList.size() > 0) { imageURL=imageURL+documentList[0].id; }
    }


    public PageReference startApplication() {
        
        Pagereference p = null;
        String usr = UserInfo.getUserId();
        User u = [SELECT Id, Email, TF4SF__Location__c, TF4SF__Channel__c, Active_Directory_Id__c, Teller_Id__c FROM User WHERE Id = :usr];
        
        TF4SF__Application__c app = new TF4SF__Application__c ();
        TF4SF__Application2__c app2 = new TF4SF__Application2__c ();
        TF4SF__Employment_Information__c emp = new TF4SF__Employment_Information__c();
        TF4SF__Identity_Information__c iden = new TF4SF__Identity_Information__c();
        TF4SF__About_Account__c acc = new TF4SF__About_Account__c();
        TF4SF__Application_Activity__c appact = new TF4SF__Application_Activity__c();
        
        app.TF4SF__Created_Person__c = u.Id;
        app.Ownerid = u.Id;
        app.TF4SF__Created_Branch_Name__c  = u.TF4SF__Location__c;
        app.TF4SF__Created_Channel__c = u.TF4SF__Channel__c;
        app.TF4SF__Created_User_Email_Address__c = u.Email;
        app.TF4SF__Custom_Text1__c = u.Teller_Id__c;
        app.TF4SF__Custom_Text2__c = u.Active_Directory_Id__c;
        // Updating the current user/type/channel information
        app.TF4SF__Current_Person__c = u.Id;
        app.TF4SF__Current_Branch_Name__c = u.TF4SF__Location__c;
        app.TF4SF__Current_Channel__c = u.TF4SF__Channel__c;
        app.TF4SF__Current_User_Email_Address__c = u.Email;
        app.TF4SF__Custom_Text3__c = u.Teller_Id__c;
        app.TF4SF__Custom_Text4__c = u.Active_Directory_Id__c;
        app.TF4SF__Current_Timestamp__c = System.now();
        app.TF4SF__Created_Timestamp__c = System.now(); 
        app.TF4SF__Application_Page__c = 'GetStartedPage';
        
        if (TF4SF__Application__c.SObjectType.getDescribe().isCreateable()) { insert app; }
        app2.TF4SF__Application__c= app.Id;
        emp.TF4SF__Application__c= app.Id;
        iden.TF4SF__Application__c= app.Id;
        acc.TF4SF__Application__c= app.Id;
        
        appact.TF4SF__Application__c= app.Id;
        appact.TF4SF__Action__c = 'Created the Application';
        appact.TF4SF__Activity_Time__c = system.now();
        
        if (TF4SF__Application2__c.SObjectType.getDescribe().isCreateable()) { insert app2; }
        if (TF4SF__Employment_Information__c.SObjectType.getDescribe().isCreateable()) { insert emp; }
        if (TF4SF__Identity_Information__c.SObjectType.getDescribe().isCreateable()) { insert iden; }
        if (TF4SF__About_Account__c.SObjectType.getDescribe().isCreateable()) { insert acc; }
        if (TF4SF__Application_Activity__c.SObjectType.getDescribe().isCreateable()) { insert appact; }
        String appId = app.Id;
        if (appId != null) {
            System.debug('appID = ' + appId);
            app = [SELECT Id, TF4SF__User_Token__c FROM TF4SF__Application__c WHERE Id = :appId];
            StartApplication.setAppToken(app);
            update app;
            String userToken = StartApplication.decrypt(app.TF4SF__User_Token__c);
            
            Cookie id = ApexPages.currentPage().getCookies().get('id');
            Cookie ut = ApexPages.currentPage().getCookies().get('ut');
            id = new Cookie('id', appId, null, -1, true);
            ut = new Cookie('ut', userToken, null, -1, true);
            System.debug('ut:' + ut);
            System.debug('userToken:' + userToken);
            System.debug('User_Token__c:' + app.TF4SF__User_Token__c);
            
            // Set the new cookie for the page
            ApexPages.currentPage().setCookies(new Cookie[]{id,ut});
            p = new PageReference(TF4SF__SiteUrl__c.getOrgDefaults().TF4SF__Url__c + 'TF4SF__OfflinePage?id=' + appId);
            p.setRedirect(true);
        }
        return p;
    }
    
    // Method executed when "Search" button om the SearchMember page is clicked
    public void executeSearch() {
          try {
            accounts = new List<Account>();
            // Trimming all the variable to get rid of empty spaces
            System.debug('ssnLast4Query in executeSearch= ' + ssnLast4Query);
            firstnameQuery = firstnameQuery.trim();
            lastnameQuery = lastnameQuery.trim();
            ssnLast4Query = ssnLast4Query.trim();
            EmailQuery = null != EmailQuery ?EmailQuery.trim() :'';

            System.debug('the First_Name__c is  ' + firstnameQuery);
            System.debug('the Last_Name__c is ' + lastnameQuery);
            System.debug('the ssnlast4 is ' + ssnLast4Query);
            System.debug('the email is ' + EmailQuery);

            // for query optimization wirting quesries based on the information provided by the User
            if(firstnameQuery != '' && lastnameQuery != '' && ssnLast4Query == '' && EmailQuery == ''){
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (First_Name__c = :firstnameQuery AND Last_Name__c = :lastnameQuery) LIMIT :maxSearchResults];
            } else if(firstnameQuery != '' && lastnameQuery != '' && ssnLast4Query == '' && EmailQuery != ''){
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (First_Name__c = :firstnameQuery AND Last_Name__c = :lastnameQuery AND Email_Address__c = :EmailQuery) LIMIT :maxSearchResults];
            } else if (firstnameQuery != '' && lastnameQuery != '' && ssnLast4Query !='' && EmailQuery == '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (First_Name__c = :firstnameQuery AND Last_Name__c = :lastnameQuery AND SSNLast4__c = :ssnLast4Query) LIMIT :maxSearchResults];
            } else if (firstnameQuery != '' && lastnameQuery != '' && ssnLast4Query !='' && EmailQuery != '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (First_Name__c = :firstnameQuery AND Last_Name__c = :lastnameQuery AND SSNLast4__c = :ssnLast4Query AND Email_Address__c = :EmailQuery) LIMIT :maxSearchResults];
            } else if (firstnameQuery != ''&& ssnLast4Query !='' && lastnameQuery=='' && EmailQuery == '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (First_Name__c = :firstnameQuery AND SSNLast4__c = :ssnLast4Query) LIMIT :maxSearchResults];   
            } else if (firstnameQuery != ''&& ssnLast4Query !='' && lastnameQuery=='' && EmailQuery != '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (First_Name__c = :firstnameQuery AND SSNLast4__c = :ssnLast4Query AND Email_Address__c = :EmailQuery) LIMIT :maxSearchResults];   
            } else if (lastnameQuery != ''&& ssnLast4Query !='' && firstnameQuery=='' && EmailQuery == '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (Last_Name__c = :lastnameQuery AND SSNLast4__c = :ssnLast4Query) LIMIT :maxSearchResults];
            } else if (lastnameQuery != ''&& ssnLast4Query !='' && firstnameQuery=='' && EmailQuery != '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (Last_Name__c = :lastnameQuery AND SSNLast4__c = :ssnLast4Query AND Email_Address__c = :EmailQuery) LIMIT :maxSearchResults];
            } else if (firstnameQuery != '' && lastnameQuery == '' && ssnLast4Query == '' && EmailQuery == '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (First_Name__c = :firstnameQuery) LIMIT :maxSearchResults];
            } else if (firstnameQuery != '' && lastnameQuery == '' && ssnLast4Query == '' && EmailQuery != '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (First_Name__c = :firstnameQuery AND Email_Address__c = :EmailQuery) LIMIT :maxSearchResults];
            } else if (firstnameQuery == '' && lastnameQuery != '' && ssnLast4Query == '' && EmailQuery == '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (Last_Name__c = :lastnameQuery) LIMIT :maxSearchResults];
            } else if (firstnameQuery == '' && lastnameQuery != '' && ssnLast4Query == '' && EmailQuery != '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (Last_Name__c = :lastnameQuery AND Email_Address__c = :EmailQuery) LIMIT :maxSearchResults];
            } else if (firstnameQuery == '' && lastnameQuery == '' && ssnLast4Query != '' && EmailQuery == '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (SSNLast4__c = :ssnLast4Query) LIMIT :maxSearchResults];
            } else if (firstnameQuery == '' && lastnameQuery == '' && ssnLast4Query != '' && EmailQuery != '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (SSNLast4__c = :ssnLast4Query AND Email_Address__c = :EmailQuery) LIMIT :maxSearchResults];
            } else if (firstnameQuery == '' && lastnameQuery == '' && ssnLast4Query == '' && EmailQuery != '') {
                ShowPersonNo = true;
                accounts = [SELECT Id, Name, IsEmployee__c, SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c, (SELECT Id, Account_Number__c, Product_type__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                FROM Account WHERE (Email_Address__c = :EmailQuery) LIMIT :maxSearchResults];
            } else {
                ShowPersonNo = false;
            }             

            accDetails = new List<Product__c>(); 
            Set<Id> personIdSet = new Set<Id>();

            if (MemberQuery != null && MemberQuery != '') {
                MemberQuery = MemberQuery.trim();
                ShowMemberNo = true;

                accDetails = [SELECT Id, Name, (SELECT Id, Account_Number__c, Unique_Account_Number__c, Person_ID__c, Name FROM Person_Products__r)
                                FROM Product__c 
                                WHERE Name = :MemberQuery AND Product_type__c = 'Membership' LIMIT :maxSearchResults];
                
                for (Product__c p : accDetails) {
                    List<Person_Product__c> ppList = p.Person_Products__r;
                    //System.debug('the pplist is '+ppList[0].Person_ID__c);
                    for (Person_Product__c pp: ppList) {
                        String personId = pp.Person_ID__c;
                        personIdSet.add(personId);
                        //Commenting the code that calls out to accountBalances method under GetAccountBalances class
                        /*try {
                            GetAccountBalances.accountBalances(Integer.valueOf(pp.Unique_Account_Number__c));
                        } catch (Exception e) {
                            System.debug('An error was encountered in the SearchMemberController ######## '+e);
                        }*/
                    }
                }

                if (personIdSet.size() > 0) {
                    accounts = [SELECT Id, Name, IsEmployee__c,SSN__c, Email_Address__c, SSNLast4__c, First_Name__c, Last_Name__c, Date_Of_Birth__c, Password__c, Password_Indicator__c, Street_Address_1__c, City__c, State__c, Zip_Code__c, Cell_Phone__c, Work_Phone__c, Home_Phone__c, Maiden_Name__c
                                FROM Account 
                                WHERE Id IN :personIdSet];
                } else {
                    ShowMemberNo = false;
                }
            } else {
                ShowMemberNo = false;
            }

            if (accounts == null || accounts.size() == 0) {
                searchMsg = true;
                ssc = null;
                if (firstnameQuery == '' && lastnameQuery == '' && ssnLast4Query == '' && MemberQuery == '' && EmailQuery == '') {
                    system.debug('the error msg is ');
                    ShowStartApplication = false;    
                } else {
                    system.debug('the error ' + firstnameQuery + ', ' + lastnameQuery + ', ' + ssnLast4Query + ', ' + MemberQuery + ', ' + EmailQuery);
                    ShowStartApplication = true;    
                }

            } else {
                searchMsg = false;
                ShowStartApplication = false; 
                // Adding StandardSetController to paginate the search results
                ssc = new ApexPages.StandardSetController(accounts);
                ssc.setPageSize(recordsPerPage);  
            }
                
        } catch(Exception e) {
            System.debug('An error was encountered in the Execute method under SearchMember class '+e.getLineNumber());
        } 
    }

    
        
    

    public List<Account> getAccountDetails() {
        System.debug('accounts in getAccountDetails = ' + accounts);
        return accounts;
    }

    // New method to enable pagination on the MemberSearch page
    public List<Account> getAccountList() {
        if (ssc != null) {
            return (List<Account>)ssc.getRecords();
        } else {
            return null;    
        }
        
    }

    public List<AccountWrapper> getaccWrapperList() {
        accWrapper = new List<AccountWrapper>();

        if (ssc != null) {
            Integer currentPageNumber = ssc.getPageNumber();
            if (currentPageNumber != null) {
                counter = (ssc.getPageSize()) * (currentPageNumber - 1);   
            }
            
            for (Account a : (List<Account>)ssc.getRecords()) {
                List<Person_Product__c> ppList = a.Person_Products__r;
                if (ppList != null && ppList.size() > 0) {
                    Boolean hasMemberShip = false;
                    for (Person_Product__c pp : ppList) {
                        Boolean updatedCounter = false;
                        if (pp.Product_type__c.toLowerCase() == 'membership') {
                            if (hasMemberShip == false) {
                                counter++;
                                updatedCounter = true;    
                            }

                            hasMemberShip = true;
                            if (updatedCounter == true) {
                                accWrapper.add(new AccountWrapper(a, pp.Unique_Account_Number__c, counter));
                            } else {
                                accWrapper.add(new AccountWrapper(a, pp.Unique_Account_Number__c, null));
                            }
                            
                        }
                    }
                    if (hasMemberShip == false) {
                        counter++;
                        accWrapper.add(new AccountWrapper(a, null, counter));
                    }
                } else {
                    if (MemberQuery != null) {
                        counter++;
                        accWrapper.add(new AccountWrapper(a, MemberQuery, counter));

                    }
                }
            }
        }

        return accWrapper;
    }

    class AccountWrapper {
        public Integer count{get; set;}
        public String memberShipNumber{get; set;}
        public Account acc {get; set;}

        public AccountWrapper(Account a, String memNumber, Integer c) {
            this.count = c;
            this.memberShipNumber = memNumber;
            this.acc = a;
        }
    }
    
    public void firstPage() {
        ssc.first();
    }

    public void previousPage() {
        ssc.previous();
    }

    public void nextPage() {
        ssc.next();
    }

    public void lastPage() {
        ssc.last();
    }

    public Boolean gethasPrevious() {
        if (ssc != null) {
            return ssc.getHasPrevious();
        } else {
            return false;
        }
        
    }

    public Boolean gethasNext() {
        if (ssc != null) {
            return ssc.getHasNext();
        } else {
            return false;
        }
        
    }

    public Integer getPageNumber(){
        if (ssc != null) {
            return ssc.getPageNumber();
        } else {
            return null;
        }
    }

    public Integer getTotalPages(){
        if (ssc != null) {
            Decimal totalSize = ssc.getResultSize();
            Decimal pageSize = ssc.getPageSize();
            
            Decimal pages = totalSize/pageSize;
            
            return (Integer)pages.round(System.RoundingMode.CEILING);
        } else {
            return null;
        }

    }

    public Integer getTotalResults() {
        if (ssc != null) {
            return ssc.getResultSize();    
        } else {
            return null;
        }

    }
    // End of pagination updates to Member Search functionality
    
    // Method executed when "Search" button om the SearchMember page is clicked
    public void executeAppSearch() {/*
        try {
            applications = new List<TF4SF__Application__c>();
            IdenList = new List<String>();
            // Trimming all the variable to get rid of empty spaces
            System.debug('appssnLast4Query in executeAppSearch= ' + appssnLast4Query);
            //appfirstnameQuery = appfirstnameQuery.trim();
           // applastnameQuery = applastnameQuery.trim();
           // appssnLast4Query = appssnLast4Query.trim();
           // appEmailQuery = appEmailQuery.trim();
           // ApplicationQuery = ApplicationQuery.trim();
           // appMemberQuery = appMemberQuery.trim();

            System.debug('the First_Name__c is ' + appfirstnameQuery);
            System.debug('the Last_Name__c is ' + applastnameQuery);
            System.debug('the ssnlast4 is ' + appssnLast4Query);
            System.debug('the email is ' + appEmailQuery);
            System.debug('the App Number is ' + ApplicationQuery);
            System.debug('the Member Number is ' + appMemberQuery);

            System.debug('the fromDate '+FromDate);
            System.debug('the ToDate '+ToDate);
            System.debug('the Date '+dat);
            date fromDay = date.parse(FromDate);
            date toDay = date.parse(ToDate);
            System.debug('the fromDate '+fromDay);
            System.debug('the toDate '+toDay);
            if( FromDate == ToDate){
                date sameDay = date.parse(ToDate);
            }
            
            //List<TF4SF__Application__c> app = [SELECT Id, TF4SF__Created_TimeStamp__c, LastModifiedDate FROM TF4SF__Application__c WHERE TF4SF__Created_Timestamp__c >: fromDay AND TF4SF__Created_Timestamp__c <: toDay ORDER by LastModifiedDate];
            // for query optimization wirting quesries based on the information provided by the User
            if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query == '' ) {
                ShowApplicantNo = true;
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE (((TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Last_Name__c = :applastnameQuery) OR (TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Last_Name_J__c = :applastnameQuery) OR (TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Last_Name_J2__c = :applastnameQuery)) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER by LastModifiedDate LIMIT :maxSearchResults];
            } else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query == '' ) {
                ShowApplicantNo = true;
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE (((TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Last_Name__c = :applastnameQuery ) OR (TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Last_Name_J__c = :applastnameQuery ) OR (TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Last_Name_J2__c = :applastnameQuery )) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER by LastModifiedDate LIMIT :maxSearchResults];
            } else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query !='') {
                ShowApplicantNo = true;
                identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query ) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query ) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, App_Number__c, TF4SF__Number_of_Products__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c,  TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery != '' && applastnameQuery != '' && appssnLast4Query !='' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, App_Number__c, TF4SF__Number_of_Products__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c,  TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery != ''&& appssnLast4Query !='' && applastnameQuery=='' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >=: fromDay AND TF4SF__Application__r.CreatedDate__c <=: toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery != ''&& appssnLast4Query !='' && applastnameQuery=='' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, Name, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query ) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query ) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (applastnameQuery != ''&& appssnLast4Query !='' && appfirstnameQuery=='' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (applastnameQuery != ''&& appssnLast4Query !='' && appfirstnameQuery=='' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery AND TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query ) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query ) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery AND TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery != '' && applastnameQuery == '' && appssnLast4Query == '' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
                    system.debug('the cretedDate is '+applications[0].CreatedDate__c);
            } else if (appfirstnameQuery != '' && applastnameQuery == '' && appssnLast4Query == '' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__First_Name__c = :appfirstnameQuery ) OR (TF4SF__Application__r.TF4SF__First_Name_J__c = :appfirstnameQuery ) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c = :appfirstnameQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery == '' && applastnameQuery != '' && appssnLast4Query == '' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery == '' && applastnameQuery != '' && appssnLast4Query == '' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__Application__r.TF4SF__Last_Name__c = :applastnameQuery ) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c = :applastnameQuery ) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c = :applastnameQuery)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query != '' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query) OR (TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query) OR (TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query != '' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (((TF4SF__SSN_Last_Four_PA__c = :appssnLast4Query ) OR (TF4SF__SSN_Last_Four_J1__c = :appssnLast4Query ) OR (TF4SF__SSN_Last_Four_J2__c = :appssnLast4Query)) AND (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query == '' ) {
                ShowApplicantNo = true;
                identity = [SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate
                    FROM TF4SF__Identity_Information__c WHERE (  (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)) ORDER by TF4SF__Application__r.LastModifiedDate LIMIT :maxSearchResults];
                for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE Id IN :IdenList];
            } else if (appfirstnameQuery == '' && applastnameQuery == '' && appssnLast4Query == '' &&   appMemberQuery == '' && ApplicationQuery == '') {
                ShowApplicantNo = false;
                
            } else {
                ShowApplicantNo = false;
            }             
System.debug('---applications .size----'+applications.size() );
            accDetails = new List<Product__c>(); 
            Set<Id> personIdSet = new Set<Id>();

            if (appMemberQuery != '') {
                ShowappMemberNo = true;
                accDetails = [SELECT Id,Name,Product_type__c, (SELECT Id, Name FROM Applications__r)
                                FROM Product__c 
                                WHERE Name = :appMemberQuery AND Product_type__c = 'Membership' LIMIT :maxSearchResults];
                
                for (Product__c p : accDetails) {
                    List<TF4SF__Application__c> ppList = p.Applications__r;
                    System.debug('the pplist is '+ppList[0].Id);
                    for (TF4SF__Application__c pp: ppList) {
                        String personId = pp.Id;
                        personIdSet.add(personId);
                    }
                }

                if (personIdSet.size() > 0) {
                    applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                        FROM TF4SF__Application__c WHERE Id IN :personIdSet AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay) ORDER by LastModifiedDate];
                } else {
                    ShowappMemberNo = false;
                }

            } else if (appMemberQuery != '' && ApplicationQuery != '') {
                ShowappMemberNo = true;
                accDetails = [SELECT Id,Name,Product_type__c, (SELECT Id, Name FROM Applications__r)
                                FROM Product__c 
                                WHERE Name = :appMemberQuery AND Product_type__c = 'Membership' LIMIT :maxSearchResults];
                
                for (Product__c p : accDetails) {
                    List<TF4SF__Application__c> ppList = p.Applications__r;
                    System.debug('the pplist is ' + ppList[0].Id);
                    for (TF4SF__Application__c pp: ppList) {
                        String personId = pp.Id;
                        personIdSet.add(personId);
                    }
                }

                if (personIdSet.size() > 0) {
                    applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                        FROM TF4SF__Application__c WHERE Id IN :personIdSet AND App_Number__c = :ApplicationQuery AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay) ORDER by LastModifiedDate];
                } else {
                    ShowappMemberNo = false;
                }                
            } else {
                ShowappMemberNo = false;
            }

            if (ApplicationQuery != '') {
                ShowappMemberNo = true;
                applications = [SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate
                    FROM TF4SF__Application__c WHERE ((App_Number__c = :ApplicationQuery OR TF4SF__External_App_ID__c = :ApplicationQuery) AND (CreatedDate__c >= :fromDay AND CreatedDate__c <= :toDay)) ORDER by LastModifiedDate LIMIT :maxSearchResults];
            }

            if (applications == null || applications.size() == 0) {
                appsearchMsg = true;
                assc = null;
                ShowStartApplication = true;
            } else {
                appsearchMsg = false;
                ShowStartApplication = true; 
                // Adding StandardSetController to paginate the search results
                assc = new ApexPages.StandardSetController(applications);
                assc.setPageSize(recordsPerPage);  
            }
                
        } catch (Exception e) {
            System.debug('An error was encountered in the Execute method under SearchMember class ' + e);
        } */
    }
    
    public List<TF4SF__Application__c> getApplicationDetails() {
        return applications;
    }

    // New method to enable pagination on the MemberSearch page
    public List<TF4SF__Application__c> getApplicationList() {
        if (assc != null) {
            return (List<TF4SF__Application__c>)assc.getRecords();
        } else {
            return null;    
        }
    }
    
    public List<ApplicationWrapper> getappWrapperList() {
        appWrapper = new List<ApplicationWrapper>();
        //List<TF4SF__Application__c> appList = new List<TF4SF__Application__c>();
        if (assc != null) {
            Integer currentPageNumber = assc.getPageNumber();
            if (currentPageNumber != null) { appcounter = (assc.getPageSize()) * (currentPageNumber - 1); }
            
            for (TF4SF__Application__c a : (List<TF4SF__Application__c>)assc.getRecords()) {
                if (a.TF4SF__Number_of_Products__c != NULL) {
                    Boolean hasMultipleProducts = false;
                    appcounter++;

                    for (Integer m = 1; m <= a.TF4SF__Number_of_Products__c; m++) {
                        System.debug('the product no is '+m);
                        if (m == 1) {
                            appWrapper.add(new ApplicationWrapper(a, a.TF4SF__Sub_Product__c, a.TF4SF__Primary_Product_Status__c, appcounter));
                        } 

                        if (m == 2) {
                            appWrapper.add(new ApplicationWrapper(a, a.TF4SF__Primary_Offer__c, a.TF4SF__Primary_Offer_Status__c, null));
                        } 

                        if (m == 3) {
                            appWrapper.add(new ApplicationWrapper(a, a.TF4SF__Second_Offer__c, a.TF4SF__Second_Offer_Status__c, null));
                        }

                        if (m == 4) {
                            appWrapper.add(new ApplicationWrapper(a, a.TF4SF__Third_Offer__c, a.TF4SF__Third_Offer_Status__c, null));
                        } 
                    }
                }
                
            }
        }

        return appWrapper;
    }

    class ApplicationWrapper {
        public Integer count {get; set;}
        public String productName {get; set;}
        public String decision {get;set;}
        public TF4SF__Application__c app {get; set;}

        public ApplicationWrapper(TF4SF__Application__c a, String productName, String decision, Integer c) {
            this.count = c;
            this.productName = productName;
            this.decision = decision;
            this.app = a;
        }
    }

    public void appfirstPage() {
        assc.first();
    }

    public void apppreviousPage() {
        assc.previous();
    }

    public void appnextPage() {
        assc.next();
    }

    public void applastPage() {
        assc.last();
    }

    public Boolean getapphasPrevious() {
        if (assc != null) {
            return assc.getHasPrevious();
        } else {
            return false;
        }
        
    }

    public Boolean getapphasNext() {
        if (assc != null) {
            return assc.getHasNext();
        } else {
            return false;
        }
        
    }

    public Integer getappPageNumber(){
        if (assc != null) {
            return assc.getPageNumber();
        } else {
            return null;
        }
    }

    public Integer getappTotalPages(){
        if (assc != null) {
            Decimal apptotalSize = assc.getResultSize();
            Decimal apppageSize = assc.getPageSize();
            Decimal apppages = apptotalSize/apppageSize;
            
            return (Integer)apppages.round(System.RoundingMode.CEILING);
        } else {
            return null;
        }
    }

    public Integer getappTotalResults() {
        if (assc != null) {
            return assc.getResultSize();    
        } else {
            return null;
        }
    }
    
    public void clearAll() {
        firstnameQuery = '';
        lastnameQuery = '';
        ssnLast4Query = '';
        MemberQuery = '';
        EmailQuery = '';
        accounts.clear();
        //accDetails.clear();
        searchMsg = false;
        searchMsgDetails = false;
        ShowStartApplication = false;
        accWrapper = null; 
    }
    

    //Method to return all the account details records based on user input

    public void appclearAll() {
    
    phoneNumberQuery='';
        appfirstnameQuery = '';
        applastnameQuery = '';
        appssnLast4Query = '';
        appMemberQuery = '';
        ApplicationQuery = '';
        appEmailQuery = '';
        applications.clear();
        //accDetails.clear();
        appsearchMsg = false;
        search_Application3();
        //searchMsgDetails = false;
        //ShowStartApplication = false;
          Date d = date.today();
          Date d1 = d.addMonths(-3);

        ToDate  = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM/dd/YYYY');
        FromDate =DateTime.newInstance(d1.year(),d1.month(),d1.day()).format('MM/dd/YYYY');
       
          System.debug('the fromDate '+FromDate);
            System.debug('the ToDate '+ToDate);
            System.debug('the Date '+dat);
          
    }
    public void search_Application3(){
    phoneNumberQuery='';
    if (applications == null || applications.size() == 0) {
               // appsearchMsg = true;
                assc = null;
               // ShowStartApplication = true;
            } else {
                appsearchMsg = false;
                ShowStartApplication = false; 
                // Adding StandardSetController to paginate the search results
                assc = new ApexPages.StandardSetController(applications);
                assc.setPageSize(recordsPerPage);  
            }
}
    /*Author : Sukesh
    To search the Application (dynamic query)*/
    public void search_Application2(){
    phoneNumberQuery='';
applications = new List<TF4SF__Application__c>();
IdenList = new List<String>();
String QueryAppWhere;

 String QueryIdent = 'SELECT Id, TF4SF__SSN_Last_Four_PA__c, TF4SF__SSN_Last_Four_J1__c, TF4SF__SSN_Last_Four_J2__c, TF4SF__SSN_Prime__c, TF4SF__Application__c, TF4SF__Application__r.TF4SF__First_Name__c, TF4SF__Application__r.TF4SF__Last_Name__c, TF4SF__Application__r.TF4SF__First_Name_J__c, TF4SF__Application__r.TF4SF__Last_Name_J__c, TF4SF__Application__r.TF4SF__First_Name_J2__c, TF4SF__Application__r.TF4SF__Last_Name_J2__c, TF4SF__Application__r.TF4SF__Email_Address__c, TF4SF__Application__r.TF4SF__Current_Channel__c, TF4SF__Application__r.TF4SF__Current_Branch_Name__c, TF4SF__Application__r.TF4SF__Application_Status__c, TF4SF__Application__r.TF4SF__Created_Timestamp__c, TF4SF__Application__r.CreatedDate__c, TF4SF__Application__r.TF4SF__Submitted_Timestamp__c, TF4SF__Application__r.LastModifiedDate FROM TF4SF__Identity_Information__c';
 
 String QueryApplication ='SELECT Id, Name, CreatedDate__c, category__c, TF4SF__Custom_DateTime1__c, TF4SF__Primary_Offer__c, TF4SF__Second_Offer__c, TF4SF__Third_Offer__c, TF4SF__Number_of_Products__c, App_Number__c, Membership_Number__c, TF4SF__Sub_Product__c, TF4SF__Email_Address__c, TF4SF__First_Name__c, TF4SF__Last_Name__c, TF4SF__First_Name_J__c, TF4SF__Last_Name_J__c, TF4SF__First_Name_J2__c, TF4SF__Last_Name_J2__c, TF4SF__Current_Channel__c, TF4SF__Current_Branch_Name__c, TF4SF__Application_Status__c, TF4SF__Created_Timestamp__c, TF4SF__Submitted_Timestamp__c, TF4SF__External_App_ID__c, TF4SF__External_AppID_CrossSell1__c, TF4SF__External_AppID_CrossSell2__c, TF4SF__External_AppID_CrossSell3__c, TF4SF__Primary_Product_Status__c, TF4SF__Primary_Offer_Status__c, TF4SF__Second_Offer_Status__c, TF4SF__Third_Offer_Status__c, LastModifiedDate FROM TF4SF__Application__c';
String dateCond = '';
String whereCon = ''; 
if(FromDate!='' && toDate!=''){
 System.debug('the fromDate '+FromDate);
            System.debug('the ToDate '+ToDate);
            System.debug('the Date '+dat);
            date fromDay = date.parse(FromDate);
            date toDay = date.parse(ToDate);
System.debug('---1'+QueryIdent );
}
if(FromDate!='' && toDate!=''){
dateCond = ' where (TF4SF__Application__r.CreatedDate__c >= :fromDay AND TF4SF__Application__r.CreatedDate__c <= :toDay)';
QueryIdent +=dateCond ;

}
System.debug('---2'+QueryIdent );
if(appfirstnameQuery!='')
{     appfirstnameQuery='%'+appfirstnameQuery+'%';
     QueryAppWhere=' AND ((TF4SF__Application__r.TF4SF__First_Name__c like :appfirstnameQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J__c like :appfirstnameQuery) OR (TF4SF__Application__r.TF4SF__First_Name_J2__c like :appfirstnameQuery) )';
     
      QueryIdent +=QueryAppWhere;
}
System.debug('---3'+QueryIdent );

 if(applastnameQuery!='')
{   applastnameQuery='%'+applastnameQuery+'%';
     QueryAppWhere=' AND ((TF4SF__Application__r.TF4SF__Last_Name__c like :applastnameQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J__c like :applastnameQuery) OR (TF4SF__Application__r.TF4SF__Last_Name_J2__c like :applastnameQuery) )';
   
    
     QueryIdent +=QueryAppWhere;
}
 if(appssnLast4Query!='')
{    appssnLast4Query='%'+appssnLast4Query+'%';
    QueryAppWhere=' AND ((TF4SF__SSN_Last_Four_PA__c like :appssnLast4Query)  OR (TF4SF__SSN_Last_Four_J1__c like :appssnLast4Query) OR (TF4SF__SSN_Last_Four_J2__c like :appssnLast4Query)) ';
    
     QueryIdent +=QueryAppWhere;
}
if(ApplicationQuery!='')
{    ApplicationQuery='%'+ApplicationQuery+'%';
    QueryAppWhere=' AND (TF4SF__Application__r.App_Number__c like :ApplicationQuery)';
    
     QueryIdent +=QueryAppWhere;
}
 if(phoneNumberQuery!='')
{    phoneNumberQuery='%'+phoneNumberQuery+'%';
    QueryAppWhere=' AND (TF4SF__Application__r.TF4SF__Primary_Phone_Number__c like :phoneNumberQuery)';
    
     QueryIdent +=QueryAppWhere;
     System.debug('---3.1----'+QueryIdent );
}



System.debug('---4'+QueryIdent );
 
identity = Database.query(QueryIdent);

 for (TF4SF__Identity_Information__c d : identity) { IdenList.add(d.TF4SF__Application__c); }
 if(IdenList.size() > 0){

 QueryApplication = QueryApplication+' WHERE Id IN :IdenList ';
 
 applications = Database.query(QueryApplication);
 System.debug('---applications -----'+applications );
 }
   if (applications == null || applications.size() == 0) {
                appsearchMsg = true;
                assc = null;
                ShowStartApplication = false;
            } else {
                appsearchMsg = false;
                ShowStartApplication = false; 
                // Adding StandardSetController to paginate the search results
                assc = new ApexPages.StandardSetController(applications);
                assc.setPageSize(recordsPerPage);  
            }
}

} //End Class