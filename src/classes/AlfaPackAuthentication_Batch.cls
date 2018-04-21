global class AlfaPackAuthentication_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Enable_Production__c, Sandbox_Username__c, Production_Username__c, Sandbox_Password__c, Production_Password__c, Sandbox_URL__c, Production_URL__c, Sandbox_Token__c, Production_Token__c FROM Alpha_Pack__c';  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Alpha_Pack__c> scope) {
        system.debug('scope:::'+scope);
        Alpha_Pack__c ap = scope[0];
        String Username;
        String Password;
        String URL;
        String authBody;
        system.debug('ap: '+ap);
        if(ap.Enable_Production__c == true) {
            
            Username = ap.Production_Username__c;
            Password = ap.Production_Password__c;
            URL = ap.Production_URL__c + 'api/authentication/';
        } else {
            
            Username = ap.Sandbox_Username__c;
            Password = ap.Sandbox_Password__c;
            URL = ap.Sandbox_URL__c + 'api/authentication/';
        }
        authBody = '{"username":"' + Username + '","password":"' + Password + '"}';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(URL);
        req.setBody(authBody);
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        HttpResponse res = http.send(req);
        String token;
        Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(res.getbody());
        Map<String, Object> permission = (Map<String, Object>)resp.get('permissions');
        String access = String.ValueOf(permission.get('api_access'));

        if (access == 'true') {
            token = String.ValueOf(resp.get('token'));
            Alpha_Pack__c updateAlfa = new Alpha_Pack__c();
            updateAlfa.Id = ap.Id;

            if (ap.Enable_Production__c == true) {
                updateAlfa.Production_Token__c = String.ValueOf(resp.get('token'));
            } else {
                updateAlfa.Sandbox_Token__c = String.ValueOf(resp.get('token'));
            }

            update updateAlfa;
        }
    }
           
        
    
    global void finish(Database.BatchableContext BC) {
    
    }
    
}