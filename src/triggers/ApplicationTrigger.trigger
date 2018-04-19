trigger ApplicationTrigger on TF4SF__Application__c (after update, before update) {
	if (trigger.isAfter && trigger.isUpdate) {
		ApplicationHandler. sendEmailProdStatus(trigger.new, trigger.oldMap);
	}

	if (trigger.isBefore && trigger.isUpdate) {
		apphandler1.appmethod1(trigger.New, trigger.oldMap);
	}
}