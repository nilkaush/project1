public class apphandler1 {

	public static void appmethod1(List<TF4SF__Application__c> newList, Map<Id, TF4SF__Application__c> oldMap) {
		List<TF4SF__Application__c> appList = new List<TF4SF__Application__c>();
		for (TF4SF__Application__c app : newList) {
			if (String.isNotBlank(app.TF4SF__Application_Status__c) && app.TF4SF__Application_Status__c == 'Submitted' && !oldMap.get(app.Id).TF4SF__Application_Status__c.equalsIgnoreCase('Submitted')) {
				app.Sub_Status__c = 'Approve';
				//appList.add(app);
			}
		}
	}
}