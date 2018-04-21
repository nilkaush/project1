public class ApplicationQueueHandler {
	public static void assignQueue (List<TF4SF__Application__c> appList) {
		try {
			Set<ID> setAppId = new Set<ID>();
			for (TF4SF__Application__c app : appList) {
				System.debug('---setAppId---' + app.TF4SF__Application_Status__c);
				System.debug('---setAppId---' + app.TF4SF__Current_Channel__c );
				if ( app.TF4SF__Application_Status__c == 'Submitted' && app.TF4SF__Current_Channel__c == 'Online Banking') {
					setAppId.add(app.id);
				}
			}

			System.debug('---setAppId---' + setAppId);
			Set<ID> appSet =  new Set<ID> ();
			List<TF4SF__Identity_Information__c > lstIdent = [SELECT Id, TF4SF__Issue_Date__c, TF4SF__Expiry_Date__c, TF4SF__Application__c FROM TF4SF__Identity_Information__c WHERE TF4SF__Application__c IN :setAppId];

			if (lstIdent.size () > 0 ) {
				for (TF4SF__Identity_Information__c  idn : lstIdent) {
					if (idn.TF4SF__Expiry_Date__c != null ) {
						Date expdate = setStringToDateFormat(idn.TF4SF__Expiry_Date__c);
						if (expdate  < System.Today()) { appSet.add(idn.TF4SF__Application__c ); }
					}
				}
			}

			System.debug('---appSet---' + appSet);
			List<TF4SF__Application__c> lstApp = [SELECT Id, OwnerId, Name FROM TF4SF__Application__c WHERE Id IN :appSet];
			System.debug('---lstApp ---' + lstApp );
			Group  gp = [SELECT Id, Name, type FROM Group WHERE type = 'Queue' AND Name = 'OLB Applications Existing Member'];
			System.debug('---gp ---' + gp );
			List<TF4SF__Application__c> lstAppUpdate = new  List<TF4SF__Application__c>();

			for (TF4SF__Application__c  ap : lstApp ) {
				if (gp != null) {
					System.debug('---ap.OwnerId---' + ap.OwnerId);
					ap.OwnerId = gp.Id;
					System.debug('---ap.OwnerId---' + ap.OwnerId);
					lstAppUpdate.add(ap);
				}
			}

			System.debug('---lstApp---' + lstApp);
			if (lstAppUpdate.size () > 0 ) {
				System.debug('---lstApp---' + lstAppUpdate);
				RecursiveCheck.runOnce = false;
				update lstAppUpdate;
			}
		} catch (Exception e) {}
	}

	private static  Date setStringToDateFormat(String myDate) {
		String[] myDateOnly = myDate.split(' ');
		String[] strDate = myDateOnly[0].split('/');
		Integer myIntDate = Integer.valueOf(strDate[1]);
		Integer myIntMonth = Integer.valueOf(strDate[0]);
		Integer myIntYear = Integer.valueOf(strDate[2]);
		Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
		return d;
	}
}