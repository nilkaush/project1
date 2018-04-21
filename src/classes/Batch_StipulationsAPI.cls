//Batch class to execute the StipulationsAPI
global class Batch_StipulationsAPI implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, Name, ProductId__c FROM TF4SF__Application__c WHERE ProductId__c != null LIMIT 1 ';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<TF4SF__Application__c> scope) {
		String productId = '';
		String appId = '';

		for (TF4SF__Application__c a : scope) {
			productId = a.ProductId__c;
			appId = a.id;
		}

		if (productId != '' && appId != '') { StipulationsAPI.callStipulations(productId, appId); }
	}
	
	global void finish(Database.BatchableContext BC) {}
}