//trigger on Note to post the note to the core
trigger NoteTrigger on Note (after insert) {
	Set<Id> NoteIds = new Set<Id>();
	for (Note noteObj : trigger.New) {
		if (noteObj.ParentId.getSobjectType() == TF4SF__Products__c.SobjectType) { NoteIds.add(noteObj.id); }
	}

	//invoke trigger handler
	notesTriggerHandler noteHandler = new notesTriggerHandler();
	noteHandler.ImplementNotes(NoteIds);
}