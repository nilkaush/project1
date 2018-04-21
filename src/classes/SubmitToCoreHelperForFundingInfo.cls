/*****************************************************************************************************
****** Helper Class created for SubmitToCore to support 1 million character limit for an Apex Class
****** This class build the FundingInfo section in the JSON request for SubmitToCore class
******************************************************************************************************/
public with sharing class SubmitToCoreHelperForFundingInfo {
	
	public String buildFundingInfoJSONRequest(String prd, Map<String, String> data, TF4SF__Application__c app, TF4SF__Identity_Information__c iden, TF4SF__About_Account__c abtAcc, TF4SF__Employment_Information__c empInfo) {
	
		String template = ''; 
		if (String.isNotBlank(prd) && data.size() > 0 && app != null && iden != null && abtAcc != null && empInfo != null) {
			try {
				System.debug('Before building funding info in SubmitToCoreHelperForFundingInfo: ');
				template =        ',"funding": {';
				if((String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && prd.Contains('Checking') && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Transfer from KeyPoint Credit Union Account')) || 
					(String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && prd.Contains('Saving') && (data.get('About_Account__c.Funding_Type_SAV__c') == 'Transfer from KeyPoint Credit Union Account')) || 
					(String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && prd.Contains('Certificates') && (data.get('About_Account__c.Funding_Type_CERT__c') == 'Transfer from KeyPoint Credit Union Account'))){
					template +=            '"type": "INTERNALTRANSFER",';
				} else if((String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && prd.Contains('Checking') && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Credit Card / Debit Card')) ||
						 (String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && prd.Contains('Saving') && data.get('About_Account__c.Funding_Type_SAV__c') == 'Credit Card / Debit Card') || 
						 (String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && prd.Contains('Certificates') && data.get('About_Account__c.Funding_Type_CERT__c') == 'Credit Card / Debit Card')){
					template +=        '"type": "CREDITCARD",';
				} else if((String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && prd.Contains('Checking') && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Mail a Check')) ||
						 (String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && prd.Contains('Saving') && data.get('About_Account__c.Funding_Type_SAV__c') == 'Mail a Check') || 
						 (String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && prd.Contains('Certificates') && data.get('About_Account__c.Funding_Type_CERT__c') == 'Mail a Check')){
						 template +=        '"type": "MAIL",';
				} else if((String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && prd.Contains('Checking') && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Transfer Funds From Other Financial Institution')) ||
						 (String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && prd.Contains('Saving') && data.get('About_Account__c.Funding_Type_SAV__c') == 'Transfer Funds From Other Financial Institution') || 
						 (String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && prd.Contains('Certificates') && data.get('About_Account__c.Funding_Type_CERT__c') == 'Transfer Funds From Other Financial Institution')){
						 template +=        '"type": "BANK",';
				} else {
						 template +=        '"type": "BANK",';
				}

				if(prd.contains('Checking')){
					if(String.isNotBlank(data.get('About_Account__c.Account_type_FI_CHK__c'))){
						template +=            '"source_bank_account_type": "' + data.get('About_Account__c.Account_type_FI_CHK__c').touppercase() + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Account_type_FI_CHK__c)){
						template +=            '"source_bank_account_type": "' + abtAcc.TF4SF__Account_type_FI_CHK__c.touppercase() + '",';
					} else {
						template +=            '"source_bank_account_type": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Account_Holder_Name_CHK__c'))){
						template +=            '"source_name_on_card": "' + data.get('About_Account__c.Account_Holder_Name_CHK__c').toUpperCase() + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Account_Holder_Name_CHK__c)){
						template +=            '"source_name_on_card": "' + abtAcc.TF4SF__Account_Holder_Name_CHK__c.toUpperCase() + '",';
					} else {
						template +=            '"source_name_on_card": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.CHK_Account_Number_External__c'))){
						template +=            '"source_bank_account_number": "' + data.get('About_Account__c.CHK_Account_Number_External__c') + '",';
					} else if(String.isNotBlank(abtAcc.CHK_Account_Number_External__c)){
						template +=            '"source_bank_account_number": "' + abtAcc.CHK_Account_Number_External__c + '",';
					} else {
						template +=            '"source_bank_account_number": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Routing_Number_CHK__c'))){
						template +=            '"source_bank_routing_number": "' + data.get('About_Account__c.Routing_Number_CHK__c') + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Routing_Number_CHK__c)){
						template +=            '"source_bank_routing_number": "' + abtAcc.TF4SF__Routing_Number_CHK__c + '",';
					} else {
						template +=            '"source_bank_routing_number": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Financial_Institution_CHK__c'))){
						template +=            '"source_bank_name": "' + data.get('About_Account__c.Financial_Institution_CHK__c').toUpperCase() + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Financial_Institution_CHK__c)){
						template +=            '"source_bank_name": "' + abtAcc.TF4SF__Financial_Institution_CHK__c.toUpperCase() + '",';
					} else {
						template +=            '"source_bank_name": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Custom_Picklist3__c'))){
						template +=            '"source_bank_state_code": "' + data.get('About_Account__c.Custom_Picklist3__c').toUpperCase() + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Custom_Picklist3__c)){
						template +=            '"source_bank_state_code": "' + abtAcc.TF4SF__Custom_Picklist3__c.toUpperCase() + '",';
					} else {
						template +=            '"source_bank_state_code": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.card_number_chk__c'))){
						template +=            '"credit_card_last_4_digits": "' + data.get('About_Account__c.card_number_chk__c').right(4)+'",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_CHK__c) && abtAcc.TF4SF__Funding_Type_CHK__c == 'Credit Card / Debit Card' && String.isNotBlank(abtAcc.card_number_chk__c)){
						template +=            '"credit_card_last_4_digits": "' + abtAcc.card_number_chk__c.right(4)+'",';
					} else {
						template +=            '"credit_card_last_4_digits": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.name_on_card_chk__c'))){
						template +=            '"source_name_on_card": "' + data.get('About_Account__c.name_on_card_chk__c')+'",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_CHK__c) && abtAcc.TF4SF__Funding_Type_CHK__c == 'Credit Card / Debit Card' && String.isNotBlank(abtAcc.name_on_card_chk__c)){
						template +=            '"source_name_on_card": "' + abtAcc.name_on_card_chk__c +'",';
					} else {
						template +=            '"source_name_on_card": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.card_expiredate_chk__c'))){
						String expDt = data.get('About_Account__c.card_expiredate_chk__c');
						template +=            '"credit_card_expiration_date": "' +expDt.right(4)+'-'+expDt.left(2)+'-'+'01'+'",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_CHK__c) && (abtAcc.TF4SF__Funding_Type_CHK__c == 'Credit Card / Debit Card') && String.isNotBlank(abtAcc.card_expiredate_chk__c)){
						String expDt = abtAcc.card_expiredate_chk__c;
						template +=            '"credit_card_expiration_date": "' +expDt.right(4)+'-'+expDt.left(2)+'-'+'01'+'",';
					} else {
						template +=            '"credit_card_expiration_date": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Credit Card / Debit Card')){
						template +=            '"billing_address": {';
						template +=                    '"address_lines": [';
						if(String.isNotBlank(data.get('About_Account__c.biiling_address_chk__c'))){
							template +=                        '"' + data.get('About_Account__c.biiling_address_chk__c').toUpperCase() + '"';
						}
						template +=                    '],';
						if(String.isNotBlank(data.get('About_Account__c.biiling_city_chk__c'))){
							template +=                    '"township": "' + data.get('About_Account__c.biiling_city_chk__c').toUpperCase() + '",';
						}
						if(String.isNotBlank(data.get('About_Account__c.biiling_state_chk__c'))){
							template +=                    '"state_code": "' + data.get('About_Account__c.biiling_state_chk__c').toUpperCase() + '",';
						}
						if(String.isNotBlank(data.get('About_Account__c.biiling_state_chk__c'))){
							template +=                    '"country_code": "USA",';
						}
						if(String.isNotBlank(data.get('About_Account__c.billing_zipcode_chk__c'))){
							template +=                    '"zip_code": "' + data.get('About_Account__c.billing_zipcode_chk__c').toUpperCase() + '"';
						}
						template +=            '},';
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_CHK__c) && abtAcc.TF4SF__Funding_Type_CHK__c == 'Credit Card / Debit Card'){
						template +=            '"billing_address": {';
						template +=                    '"address_lines": [';
						if(String.isNotBlank(abtAcc.biiling_address_chk__c)){
							template +=                        '"' + abtAcc.biiling_address_chk__c.toUpperCase() + '"';
						}
						template +=                    '],';
						if(String.isNotBlank(abtAcc.biiling_city_chk__c)){
							template +=                    '"township": "' + abtAcc.biiling_city_chk__c.toUpperCase() + '",';
						}
						if(String.isNotBlank(abtAcc.biiling_state_chk__c)){
							template +=                    '"state_code": "' + abtAcc.biiling_state_chk__c.toUpperCase() + '",';
						}
						if(String.isNotBlank(abtAcc.biiling_state_chk__c)){
							template +=                    '"country_code": "USA",';
						}
						if(String.isNotBlank(abtAcc.billing_zipcode_chk__c)){
							template +=                    '"zip_code": "' + abtAcc.billing_zipcode_chk__c.toUpperCase() + '"';
						}
						template +=            '},';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Mail a Check') && String.isNotBlank(data.get('About_Account__c.Dollar_Amount_CHK_Check__c'))){
						template +=            '"amount": ' + data.get('About_Account__c.Dollar_Amount_CHK_Check__c');
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_CHK__c) && (abtAcc.TF4SF__Funding_Type_CHK__c == 'Mail a Check') && (abtAcc.TF4SF__Dollar_Amount_CHK_Check__c != null)){
						template +=            '"amount": ' + abtAcc.TF4SF__Dollar_Amount_CHK_Check__c;
					} else if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.Custom_Currency4__c'))){
						template +=            '"amount": '  + data.get('About_Account__c.Custom_Currency4__c');
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_CHK__c) && (abtAcc.TF4SF__Funding_Type_CHK__c == 'Credit Card / Debit Card') && (abtAcc.TF4SF__Custom_Currency4__c != null)){
						template +=            '"amount": '  + abtAcc.TF4SF__Custom_Currency4__c;
					} else if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CHK__c')) && (data.get('About_Account__c.Funding_Type_CHK__c') == 'Transfer Funds From Other Financial Institution') && String.isNotBlank(data.get('About_Account__c.Dollar_Amount_External_CHK__c'))){
						template +=            '"amount": '   + data.get('About_Account__c.Dollar_Amount_External_CHK__c');
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_CHK__c) && (abtAcc.TF4SF__Funding_Type_CHK__c == 'Transfer Funds From Other Financial Institution') && (abtAcc.TF4SF__Dollar_Amount_External_CHK__c != null)){
						template +=            '"amount": '   + abtAcc.TF4SF__Dollar_Amount_External_CHK__c;
					} else {
						template +=            '"amount": null';
					}
				}
				if(prd.contains('Saving')){
					if(String.isNotBlank(data.get('About_Account__c.Account_Type_FI_Sav__c'))){
						template +=            '"source_bank_account_type": "' + data.get('About_Account__c.Account_Type_FI_Sav__c').toUpperCase() + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Account_Type_FI_Sav__c)){
						template +=            '"source_bank_account_type": "' + abtAcc.TF4SF__Account_Type_FI_Sav__c.toUpperCase() + '",';
					} else {
						template +=            '"source_bank_account_type": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Account_Holder_Name_SAV__c'))){
						template +=            '"source_name_on_card": "' + data.get('About_Account__c.Account_Holder_Name_SAV__c').toUpperCase() + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Account_Holder_Name_SAV__c)){
						template +=            '"source_name_on_card": "' + abtAcc.TF4SF__Account_Holder_Name_SAV__c.toUpperCase() + '",';
					} else {
						template +=            '"source_name_on_card": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.SAV_Account_Number_External__c'))){
						template +=            '"source_bank_account_number": "' + data.get('About_Account__c.SAV_Account_Number_External__c') + '",';
					} else if(String.isNotBlank(abtAcc.SAV_Account_Number_External__c)){
						template +=            '"source_bank_account_number": "' + abtAcc.SAV_Account_Number_External__c + '",';
					} else {
						template +=            '"source_bank_account_number": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Routing_Number_Sav__c'))){
						template +=            '"source_bank_routing_number": "' + data.get('About_Account__c.Routing_Number_Sav__c') + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Routing_Number_Sav__c)){
						template +=            '"source_bank_routing_number": "' + abtAcc.TF4SF__Routing_Number_Sav__c + '",';
					} else {
						template +=            '"source_bank_routing_number": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Financial_Institution_SAV__c'))){
						template +=            '"source_bank_name": "' + data.get('About_Account__c.Financial_Institution_SAV__c') + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Financial_Institution_SAV__c)){
						template +=            '"source_bank_name": "' + abtAcc.TF4SF__Financial_Institution_SAV__c + '",';
					} else {
						template +=            '"source_bank_name": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Custom_Picklist1__c'))){
						template +=            '"source_bank_state_code": "' + data.get('About_Account__c.Custom_Picklist1__c') + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Custom_Picklist1__c)){
						template +=            '"source_bank_state_code": "' + abtAcc.TF4SF__Custom_Picklist1__c + '",';
					} else {
						template +=            '"source_bank_state_code": null,';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && (data.get('About_Account__c.Funding_Type_SAV__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.card_number_sav__c'))){
						template +=            '"credit_card_last_4_digits": "' + data.get('About_Account__c.card_number_sav__c').right(4)+'",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_SAV__c) && (abtAcc.TF4SF__Funding_Type_SAV__c == 'Credit Card / Debit Card') && String.isNotBlank(abtAcc.card_number_sav__c)){
						template +=            '"credit_card_last_4_digits": "' + abtAcc.card_number_sav__c.right(4)+'",';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && (data.get('About_Account__c.Funding_Type_SAV__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.name_on_card_sav__c'))){
						template +=            '"source_name_on_card": "' + data.get('About_Account__c.name_on_card_sav__c')+'",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_SAV__c) && (abtAcc.TF4SF__Funding_Type_SAV__c == 'Credit Card / Debit Card') && String.isNotBlank(abtAcc.name_on_card_sav__c)){
						template +=            '"source_name_on_card": "' + abtAcc.name_on_card_sav__c +'",';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && (data.get('About_Account__c.Funding_Type_SAV__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.card_expiredate_sav__c'))){
						String expDt = data.get('About_Account__c.card_expiredate_sav__c');
						template +=            '"credit_card_expiration_date": "' +expDt.right(4)+'-'+expDt.left(2)+'-'+'01'+'",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Funding_Type_SAV__c) && (abtAcc.TF4SF__Funding_Type_SAV__c == 'Credit Card / Debit Card') && String.isNotBlank(abtAcc.card_expiredate_sav__c)){
						String expDt = abtAcc.card_expiredate_sav__c;
						template +=            '"credit_card_expiration_date": "' +expDt.right(4)+'-'+expDt.left(2)+'-'+'01'+'",';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && (data.get('About_Account__c.Funding_Type_SAV__c') == 'Credit Card / Debit Card')){
						template +=            '"billing_address": {';
						template +=                    '"address_lines": [';
						if(String.isNotBlank(data.get('About_Account__c.biiling_address_sav__c'))){
							template +=                        '"' + data.get('About_Account__c.biiling_address_sav__c').toUpperCase() + '"';
						}
						template +=                    '],';
						if(String.isNotBlank(data.get('About_Account__c.biiling_city_sav__c'))){
							template +=                    '"township": "' + data.get('About_Account__c.biiling_city_sav__c').toUpperCase() + '",';
						}
						if(String.isNotBlank(data.get('About_Account__c.biiling_state_sav__c'))){
							template +=                    '"state_code": "' + data.get('About_Account__c.biiling_state_sav__c').toUpperCase() + '",';
						}
						if(String.isNotBlank(data.get('About_Account__c.biiling_state_sav__c'))){
							template +=                    '"country_code": "USA",';
						}
						if(String.isNotBlank(data.get('About_Account__c.billing_zipcode_sav__c'))){
							template +=                    '"zip_code": "' + data.get('About_Account__c.billing_zipcode_sav__c').toUpperCase() + '"';
						}
						template +=            '},';
					}
					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && (data.get('About_Account__c.Funding_Type_SAV__c') == 'Mail a Check') && String.isNotBlank(data.get('About_Account__c.Dollar_Amount_SAV_Check__c'))){
						template +=            '"amount": ' + data.get('About_Account__c.Dollar_Amount_SAV_Check__c');
					} else if(String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && (data.get('About_Account__c.Funding_Type_SAV__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.Custom_Currency2__c'))){
						template +=            '"amount": ' + data.get('About_Account__c.Custom_Currency2__c');
					} else if(String.isNotBlank(data.get('About_Account__c.Funding_Type_SAV__c')) && (data.get('About_Account__c.Funding_Type_SAV__c') == 'Transfer Funds From Other Financial Institution') && String.isNotBlank(data.get('About_Account__c.Dollar_Amount_External_SAV__c'))){
						template +=            '"amount": ' + data.get('About_Account__c.Dollar_Amount_External_SAV__c');
					} else {
						template +=            '"amount": null';
					}
				}
				if(prd.contains('Certificates')){
					if(String.isNotBlank(data.get('About_Account__c.Account_Type_FI_Cert__c'))){
						template +=            '"source_bank_account_type": "' + data.get('About_Account__c.Account_Type_FI_Cert__c').toUpperCase() + '",';
					} else {
						template +=            '"source_bank_account_type": null,';
					}

					if(String.isNotBlank(data.get('About_Account__c.Account_Holder_Name_CERT__c'))){
						template +=            '"source_name_on_card": "' + data.get('About_Account__c.Account_Holder_Name_CERT__c').toUpperCase() + '",';
					} else {
						template +=            '"source_name_on_card": null,';
					}

					if(String.isNotBlank(data.get('About_Account__c.CERT_Account_Number_External__c'))){
						template +=            '"source_bank_account_number": "' + data.get('About_Account__c.CERT_Account_Number_External__c') + '",';
					} else {
						template +=            '"source_bank_account_number": null,';
					}

					if(String.isNotBlank(data.get('About_Account__c.Routing_Number_Cert__c'))){
						template +=            '"source_bank_routing_number": "' + data.get('About_Account__c.Routing_Number_Cert__c') + '",';
					} else {
						template +=            '"source_bank_routing_number": null,';
					}

					if(String.isNotBlank(data.get('About_Account__c.Financial_Institution_CERT__c'))){
						template +=            '"source_bank_name": "' + data.get('About_Account__c.Financial_Institution_CERT__c').toUpperCase() + '",';
					} else {
						template +=            '"source_bank_name": null,';
					}

					if(String.isNotBlank(data.get('About_Account__c.Custom_Picklist5__c'))){
						template +=            '"source_bank_state_code": "' + data.get('About_Account__c.Custom_Picklist5__c').toUpperCase() + '",';
					} else if(String.isNotBlank(abtAcc.TF4SF__Custom_Picklist5__c)){
						template +=            '"source_bank_state_code": "' + abtAcc.TF4SF__Custom_Picklist5__c.toUpperCase() + '",';
					} else {
						template +=            '"source_bank_state_code": null,';
					}

					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && (data.get('About_Account__c.Funding_Type_CERT__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.card_number_cert__c'))){
						template +=            '"credit_card_last_4_digits": "' + data.get('About_Account__c.card_number_cert__c').right(4)+'",';
					}

					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && (data.get('About_Account__c.Funding_Type_CERT__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.name_on_card_cert__c'))){
						template +=            '"source_name_on_card": "' + data.get('About_Account__c.name_on_card_cert__c')+'",';
					}

					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && (data.get('About_Account__c.Funding_Type_CERT__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.card_expiredate_cert__c'))){
						String expDt = data.get('About_Account__c.card_expiredate_cert__c');
						template +=            '"credit_card_expiration_date": "' +expDt.right(4)+'-'+expDt.left(2)+'-'+'01'+'",';
					}

					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && (data.get('About_Account__c.Funding_Type_CERT__c') == 'Credit Card / Debit Card')){
						template +=            '"billing_address": {';
						template +=                    '"address_lines": [';

						if(String.isNotBlank(data.get('About_Account__c.biiling_address_cert__c'))){
							template +=                        '"' + data.get('About_Account__c.biiling_address_cert__c').toUpperCase() + '"';
						}

						template +=                    '],';
						if(String.isNotBlank(data.get('About_Account__c.biiling_city_cert__c'))){
							template +=                    '"township": "' + data.get('About_Account__c.biiling_city_cert__c').toUpperCase() + '",';
						}

						if(String.isNotBlank(data.get('About_Account__c.biiling_state_cert__c'))){
							template +=                    '"state_code": "' + data.get('About_Account__c.biiling_state_cert__c').toUpperCase() + '",';
						}

						if(String.isNotBlank(data.get('About_Account__c.biiling_state_cert__c'))){
							template +=                    '"country_code": "USA",';
						}

						if(String.isNotBlank(data.get('About_Account__c.billing_zipcode_cert__c'))){
							template +=                    '"zip_code": "' + data.get('About_Account__c.billing_zipcode_cert__c').toUpperCase() + '"';
						}

						template +=            '},';
					}

					if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && (data.get('About_Account__c.Funding_Type_CERT__c') == 'Mail a Check') && String.isNotBlank(data.get('About_Account__c.Dollar_Amount_CERT_Check__c'))){
						template +=            '"amount": ' + data.get('About_Account__c.Dollar_Amount_CERT_Check__c');
					} else if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && (data.get('About_Account__c.Funding_Type_CERT__c') == 'Credit Card / Debit Card') && String.isNotBlank(data.get('About_Account__c.Custom_Currency6__c'))){
						template +=            '"amount": ' + data.get('About_Account__c.Custom_Currency6__c');
					} else if(String.isNotBlank(data.get('About_Account__c.Funding_Type_CERT__c')) && (data.get('About_Account__c.Funding_Type_CERT__c') == 'Transfer Funds From Other Financial Institution') && String.isNotBlank(data.get('About_Account__c.Dollar_Amount_External_CERT__c'))){
						template +=            '"amount": ' + data.get('About_Account__c.Dollar_Amount_External_CERT__c');
					} else {
						template +=            '"amount": null';
					}
				}

				template +=        '}';

			} catch(Exception e) {
				System.debug('Exception occured in SubmitToCoreHelperForFundingInfo class with error ::::: ' + e.getMessage() + ' &&&&& at Line ######## ' + e.getLineNumber());
			}
		}

		System.debug('template before SubmitToCoreHelperForFundingInfo method return: ' + template);
		return template;
	}
}