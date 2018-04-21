public class LogStorage {
    @future
    public static void InsertDebugLog (String appId, String json, String Callout) {
        List<TF4SF__Debug_Logs__c> debugList = new List<TF4SF__Debug_Logs__c>();
        Schema.DescribeFieldResult F = TF4SF__Debug_Logs__c.TF4SF__Debug_Message__c.getDescribe();
        Integer lengthOfField = F.getLength();
        TF4SF__Debug_Logs__c debug = new TF4SF__Debug_Logs__c();
        debug.TF4SF__Application__c = appId;
        if (json.length() < lengthOfField) {
            debug.TF4SF__Debug_Message__c = json;
        }
        debug.TF4SF__Source__c = Callout;
        debug.TF4SF__Timestamp__c = String.valueOf(System.now());
        debugList.add(debug);
        if (debugList.size() > 0) { insert debugList; }
    }
}