trigger AttachmentTrigger on Attachment (after insert) {
	
	Set<Id> attchIds = new Set<Id>();
	for (Attachment attObj : trigger.New) {
		if (attObj.ParentId.getSobjectType() == TF4SF__Documentation_Request__c.SobjectType) { attchIds.add(attObj.id); }
	}

	//invoke trigger handler
	attachmentTriggerHandler attHandler = new attachmentTriggerHandler();
	attHandler.documentAPIHandler(attchIds);
}