@isTest
public class ApplicationHandlerTest {
	static testMethod void appHandlerTestMethod1() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Vehicle loans';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Vehicle Loans';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'approved';
		update appObj;
	}

	static testMethod void appHandlerTestMethod2() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest2';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc2@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Personal Loan';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Personal Loan';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test2';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'approved';
		update appObj;
	}

	static testMethod void appHandlerTestMethod3() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest3';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc3@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Credit Card';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Credit Card';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test3';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'approved';
		update appObj;
	}

	static testMethod void appHandlerTestMethod4() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest4';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		appObj.TF4SF__Current_Channel__c = 'Branch';
		appObj.TF4SF__Email_Address__c = 'abc4@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Vehicle Loans';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Vehicle Loans';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test4';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'approved';
		update appObj;
	}

	static testMethod void appHandlerTestMethod5() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest5';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		appObj.TF4SF__Current_Channel__c = 'Branch';
		appObj.TF4SF__Email_Address__c = 'abc5@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Personal Loan';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Personal Loan';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test5';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'approved';
		update appObj;
	}

	static testMethod void appHandlerTestMethod6() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest6';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		appObj.TF4SF__Current_Channel__c = 'Branch';
		appObj.TF4SF__Email_Address__c = 'abc6@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Credit Card';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Credit Card';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test6';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'approved';
		update appObj;
	}

	static testMethod void appHandlerTestMethod7() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest7';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		appObj.TF4SF__Current_Channel__c = 'Branch';
		appObj.TF4SF__Email_Address__c = 'abc7@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Checking';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Checking';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test7';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'approved';
		update appObj;
	}

	static testMethod void appHandlerTestMethod8() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest8';
		appObj.TF4SF__Current_Channel__c = 'Branch';
		appObj.TF4SF__Email_Address__c = 'abc8@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Checking';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Checking';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test8';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'Approved';
		update appObj;
	}

	static testMethod void appHandlerTestMethod9() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest9';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc9@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Vehicle Loans';
		appObj.TF4SF__Application_Status__c = 'Submitted';   
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Vehicle Loans';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test9';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'Inquiring';    
		update appObj;
	}

	static testMethod void appHandlerTestMethod10() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest10';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc10@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Personal Loan';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Personal Loan';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test10';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'Inquiring';    
		update appObj;
	}

	static testMethod void appHandlerTestMethod11() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest11';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc11@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Credit Card';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Credit Card';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test11';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'Inquiring';
		update appObj;
	}

	static testMethod void appHandlerTestMethod12() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest12';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc12@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Checking';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Checking';
		prod.TF4SF__Requested_Loan_Amount__c = 10000;
		prod.TF4SF__Term__c = 3;
		prod.TF4SF__Rate__c = 6;
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test12';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'Inquiring';
		update appObj;
	}

	static testMethod void appHandlerTestMethod13() {
		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest13';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc13@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Checking';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Checking';
		prod.TF4SF__Application__c = appObj.Id;
		insert prod;

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test13';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'INSTANT APPROVED';
		update appObj;
	}

	static testMethod void appHandlerTestMethod14() {
		TF4SF__Customer__c cust = new TF4SF__Customer__c();
		cust.TF4SF__Username__c = 'TestingDeclined';
		insert cust;

		TF4SF__Application__c appObj = new TF4SF__Application__c();
		appObj.ProductId__c = 'TestProductIdForAppHandTest14';
		appObj.TF4SF__Current_Channel__c = 'Online';
		appObj.TF4SF__Email_Address__c = 'abc14@gmail.com';
		appObj.TF4SF__Sub_Product__c = 'Checking';
		appObj.TF4SF__Application_Status__c = 'Submitted';
		appObj.TF4SF__Customer__c = cust.Id;
		insert appObj;

		TF4SF__Products__c prod = new TF4SF__Products__c();
		prod.TF4SF__Product_Name__c='Checking';
		prod.TF4SF__Application__c = appObj.Id;
		insert prod; 

		TF4SF__Documentation_Request__c docReq = new TF4SF__Documentation_Request__c();
		docReq.TF4SF__Type__c = 'Type Test for App Hand Test14';
		docReq.TF4SF__Application__c = appObj.Id;
		insert docReq;

		appObj.TF4SF__Primary_Product_Status__c = 'DECLINED';
		update appObj;
	}
}