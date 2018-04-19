trigger ApplicationTrigger on TF4SF__Application__c (after update, before update) {
	if (trigger.isAfter && trigger.isUpdate) {
<<<<<<< HEAD
		ApplicationHandler. sendEmailProdStatus(trigger.new, trigger.oldMap);
=======
		ApplicationHandler.sendEmailProdStatus(trigger.new, trigger.oldMap);
>>>>>>> parent of 3b60c8c... Commit 3
	}

	if (trigger.isBefore && trigger.isUpdate) {
		apphandler1.appmethod1(trigger.New, trigger.oldMap);
	}
}