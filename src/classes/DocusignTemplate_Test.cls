@isTest
private class DocusignTemplate_Test {
    
    @isTest static void test_method_one() {
        // Implement test code
        TF4SF__Field_Logic_New__c fl = new TF4SF__Field_Logic_New__c(TF4SF__Field_Name__c = 'Disclosure1__c',TF4SF__IsDisplayed__c = true,TF4SF__IsRequired__c = true,TF4SF__Product__c = 'Checking',TF4SF__Sub_Products__c = 'Checking - Checking');
        insert fl;

        Docusign_Disclosure_Names__c d = new Docusign_Disclosure_Names__c(Name = 'Disclosure1');
        insert d;

        TF4SF__Disclosure__c dl = new TF4SF__Disclosure__c(Name = 'TestDisclosure - DS',Template_ID__c = '1673B9A2-8079-425D-84FB-EC40A1454092',Joint1_Template_ID__c = '1673B9A2-8079-425D-84FB-EC40A1454092');
        insert dl;

        TF4SF__Application__c app = new TF4SF__Application__c(TF4SF__First_Name__c = 'TestFirst',TF4SF__Last_Name__c = 'TestLast', TF4SF__Email_Address__c = 'test@test.com',TF4SF__Product__c = 'Checking',TF4SF__Sub_Product__c = 'Checking - Checking');
        insert app;
        
        Docusign_Config__c doc = new Docusign_Config__c(Name = 'cred', AccountID__c = 'test', Username__c = 'test',Password__c = 'test', IntegratorKey__c = 'test');
        insert doc;

        TF4SF__Application_Configuration__c ac = new TF4SF__Application_Configuration__c(Call_Joint_Docusign__c = false,TF4SF__Application_Code__c = 'static',TF4SF__Theme__c = 'static');
        insert ac;

        Map<String,String> tdata = new Map<String,String>();
        tdata.put('id',app.Id);
        
        DocusignTemplate docu = new DocusignTemplate();
        docu.main(tdata);
    }
}