public class AccountVerifierCls {
	public String appId {get; set;}
	public  TF4SF__Application__c appObj {get; set;}

	public AccountVerifierCls() {
		appId = ApexPages.currentPage().getParameters().get('id');
	}

	public void infogetData() {
		TF4SF__Application__c appObj = [SELECT Id, Custom_Text44__c, Name FROM TF4SF__Application__c WHERE Id = :appId]; 
	}

	public void getData() {
		TF4SF__Application__c appObj = [SELECT Id, Custom_Text44__c FROM TF4SF__Application__c WHERE Id = :appId]; 
	}
}