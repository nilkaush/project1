/*****************************************************************************************************
****** Helper Class created for SubmitToCore to support 1 million character limit for an Apex Class
****** This class build the JSON request for SubmitToCore class
******************************************************************************************************/
public with sharing class SubmitToCoreHelper {
	public String buildJSONRequest(Map<String, String> data, Map<String,String> prodMap, Map<String, String> empMap, Map<String, String> occStatusMap, Map<String, String> immStatusMap, Map<String, String> appTypeMap, Map<String, String> idenDocMap, TF4SF__Application__c app, TF4SF__Identity_Information__c iden, TF4SF__About_Account__c abtAcc, TF4SF__Employment_Information__c empInfo, KYC_OOW__c kycInfo) {

		String template = '';
		if (data.size() > 0 && app != null && iden != null && abtAcc != null && empInfo != null) {
			try {
				template = '[';
				Integer i = 0;
				for (String prd : prodMap.keySet()) {
					System.debug('data map in the for loop ===== ' + data);
					template +=    '{';
					if ( String.isNotBlank(prodMap.get(prd))) {
						template +=        '"id": "' + prodMap.get(prd) + '",';
					}

					SubmitToCoreLoanHelper.buildLoanJSONRequest(data, prodMap, empMap, occStatusMap, immStatusMap, appTypeMap, idenDocMap, app, iden, abtAcc, empInfo, kycInfo, template, prd);
					

					if (String.isNotBlank(prd)) {
						template +=        '"product_name": "' + prd + '",';
					}

					if (String.isNotBlank(app.TF4SF__Membership_Qualification_Type__c)) {
						template +=        '"membership_eligibility": {';
						if (String.isNotBlank(app.TF4SF__Membership_Qualification_Type__c)) {
							template +=            '"question": "' + app.TF4SF__Membership_Qualification_Type__c.toUpperCase() + '",';
						} else {
							template +=                     '"question": null,';
						}

						if (String.isNotBlank(app.TF4SF__Membership_Qualification_Value__c)) {
							template +=             '"answer": "' + app.TF4SF__Membership_Qualification_Value__c.toUpperCase() + '"';
						} else {
							template +=             '"answer": "false"';
						}

						template +=        '},';
					}

					//Adding this section to send Abount Account Page Additional Servies Information:
					if(app.TF4SF__Sub_Product__c.Contains('Checking') || app.TF4SF__Sub_Product__c.Contains('Saving') || app.TF4SF__Sub_Product__c.Contains('Certificate')) {
						String values = '';
						template += '"question_answers": [';
						template +=            '{';
						template +=                 '"question_name": "Services",';
						template +=                 '"answer": [';
						
						if((String.isNotBlank(data.get('Application__c.ATM_Card__c')) && data.get('Application__c.ATM_Card__c') == 'true') || app.TF4SF__ATM_Card__c == true) {
							//template +=                 '';
							values = '"ATM Card (Savings Only)"';
						}
						if((String.isNotBlank(data.get('Application__c.Custom_Checkbox4__c')) && data.get('Application__c.Custom_Checkbox4__c') == 'true') || app.TF4SF__Custom_Checkbox4__c == true) {
							//template +=                 '';
							values = '"VISA Debit Card"';
						}
						if ((String.isNotBlank(data.get('Application__c.Check_Order__c')) && data.get('Application__c.Check_Order__c') == 'true') || app.TF4SF__Check_Order__c == true) {
							if (String.isNotBlank(values)) {
								values += ',"Checks"';
							} else {
								values = '"Checks"';
							}
						}
						if ((String.isNotBlank(data.get('Application__c.Online_Banking_Enrollment__c')) && data.get('Application__c.Online_Banking_Enrollment__c') == 'true') || app.TF4SF__Online_Banking_Enrollment__c == true) {
							if (String.isNotBlank(values)) {
								values += ',"Online Banking"';
							} else {
								values = '"Online Banking"';
							}
						}
						if ((String.isNotBlank(data.get('Application__c.Overdraft_Protection__c')) && data.get('Application__c.Overdraft_Protection__c') == 'true') || app.TF4SF__Overdraft_Protection__c == true) {
							if (String.isNotBlank(values)) {
								values += ',"Overdraft Protection"';
							} else {
								values = '"Overdraft Protection"';
							}
						}
						if ((String.isNotBlank(data.get('Application__c.Custom_Checkbox5__c')) && data.get('Application__c.Custom_Checkbox5__c') == 'true') || app.TF4SF__Custom_Checkbox5__c == true) {
							if (String.isNotBlank(values)) {
								values += ',"Access365 TouchTone Banking"';
							} else {
								values = '"Access365 TouchTone Banking"';
							}
						}
						if ((String.isNotBlank(data.get('Application__c.Custom_Checkbox3__c')) && data.get('Application__c.Custom_Checkbox3__c') == 'true') || app.TF4SF__Custom_Checkbox3__c == true) {
							if (String.isNotBlank(values)) {
								values += ',"Courtesy Pay"';
							} else {
								values = '"Courtesy Pay"';
							}
						}
						if ((String.isNotBlank(data.get('Application__c.Custom_Checkbox8__c')) && data.get('Application__c.Custom_Checkbox8__c') == 'true') || app.Custom_Checkbox8__c == true) {
							if (String.isNotBlank(values)) {
								values += ',"Electronic Statements"';
							} else {
								values = '"Electronic Statements"';
							}
						}
						System.debug('values for Additional Services ::::: ' + values);
						if (String.isNotBlank(values)) {
							template += values + ']';
						} else {
							template += ']';
						}
						template +=            '}';

						if ((String.isNotBlank(data.get('Application__c.Custom_Picklist13__c')) && data.get('Application__c.Custom_Picklist13__c') == 'Yes') || app.Custom_Picklist13__c == 'Yes') {
							template += ',{';
							template += 	'"question_name": "Member Referral",';
							template +=		'"answer": "Yes"';
							template += '}';
						}

						if (String.isNotBlank(data.get('Application__c.Custom_Text17__c')) && String.isNotBlank(data.get('Application__c.Custom_Text42__c'))) {
							template += ',{';
							template += 	'"question_name": "Referral Name",';
							template +=		'"answer": "' + data.get('Application__c.Custom_Text17__c').trim().toUpperCase() + ' ' + data.get('Application__c.Custom_Text42__c').trim().toUpperCase() + '"';
							template += '}';
						} else if (String.isNotBlank(app.Custom_Text17__c) && String.isNotBlank(app.Custom_Text42__c)) {
							template += ',{';
							template += 	'"question_name": "Referral Name",';
							template +=		'"answer": "' + app.Custom_Text17__c.trim().toUpperCase() + ' ' + app.Custom_Text42__c.trim().toUpperCase() + '"';
							template += '}';
						}

						
						//template +=            '}';
						template += '],';
					}
					System.debug('template before Applicants ==== ' + template);
					System.debug('data before Applicants ==== ' + data);


					template +=        '"applicants": [';
					template +=            '{';

					if (String.isNotBlank(data.get('Application__c.First_Name__c'))) {
						template +=                '"first_name": "' + data.get('Application__c.First_Name__c').toUpperCase() + '",';
					} else if (String.isNotBlank(app.TF4SF__First_Name__c)) {
						template +=                '"first_name": "' + app.TF4SF__First_Name__c.toUpperCase() + '",';
					} else {
						template +=                '"first_name": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Middle_Name__c'))) {
						template +=                '"middle_name": "' + data.get('Application__c.Middle_Name__c').toUpperCase() + '",';
					} else if (String.isNotBlank(app.TF4SF__Middle_Name__c)) {
						template +=                '"middle_name": "' + app.TF4SF__Middle_Name__c.toUpperCase() + '",';
					} else {
						template +=                '"middle_name": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Last_Name__c'))) {
						template +=                '"last_name": "' + data.get('Application__c.Last_Name__c').toUpperCase() + '",';
					} else if (String.isNotBlank(app.TF4SF__Last_Name__c)) {
						template +=                '"last_name": "' + app.TF4SF__Last_Name__c.toUpperCase() + '",';
					} else {
						template +=                '"last_name": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Suffix__c'))) {
						template +=                '"suffix": "' + data.get('Application__c.Suffix__c').toUpperCase() + '",';
					} else if (String.isNotBlank(app.TF4SF__Suffix__c)) {
						template +=                '"suffix": "' + app.TF4SF__Suffix__c.toUpperCase() + '",';
					} else {
						template +=                '"suffix": null,';
					}

					template +=                '"applicant_type": "P",';
					if (String.isNotBlank(data.get('Identity_Information__c.SSN_Prime__c'))) {
						System.debug('entered ssnprime: ' + data.get('Identity_Information__c.SSN_Prime__c'));
						template +=                '"federal_id": "' + data.get('Identity_Information__c.SSN_Prime__c') + '",';
					} else if (String.isNotBlank(iden.TF4SF__SSN_Prime__c)) {
						template +=                '"federal_id": "' + iden.TF4SF__SSN_Prime__c + '",';
					} else {
						template +=                '"federal_id": "",';
					}

					if (String.isNotBlank(data.get('Application__c.Marital_Status__c'))) {
						template +=                '"marital_status": "' + data.get('Application__c.Marital_Status__c').toUpperCase() + '",';
					} else if (String.isNotBlank(app.TF4SF__Marital_Status__c)) {
						template +=                '"marital_status": "' + app.TF4SF__Marital_Status__c.toUpperCase() + '",';
					} else {
						template +=                '"marital_status": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Email_Address__c'))) {
						template +=                '"email_address": "' + data.get('Application__c.Email_Address__c').toUpperCase() + '",';
					} else {
						template +=                '"email_address": "' + app.TF4SF__Email_Address__c.toUpperCase() + '",';
					}

					if (String.isNotBlank(data.get('Application__c.Primary_Phone_Number__c'))) {
						template +=                '"home_phone_number": "' + data.get('Application__c.Primary_Phone_Number__c') + '",';
					} else if (String.isNotBlank(app.TF4SF__Primary_Phone_Number__c)) {
						template +=                '"home_phone_number": "' + app.TF4SF__Primary_Phone_Number__c + '",';
					} else {
						template +=                '"home_phone_number": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Secondary_Phone_Number__c'))) {
						template +=                '"work_phone_number": "' + data.get('Application__c.Secondary_Phone_Number__c') + '",';
					} else if (String.isNotBlank(app.TF4SF__Secondary_Phone_Number__c)) {
						template +=                '"work_phone_number": "' + app.TF4SF__Secondary_Phone_Number__c + '",';
					} else {
						template +=                '"work_phone_number": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Tertiary_Phone_Number__c'))) {
						template +=                '"mobile_phone_number": "' + data.get('Application__c.Tertiary_Phone_Number__c') + '",';
					} else if (String.isNotBlank(app.TF4SF__Tertiary_Phone_Number__c)) {
						template +=                '"mobile_phone_number": "' + app.TF4SF__Tertiary_Phone_Number__c + '",';
					} else {
						template +=                '"mobile_phone_number": null,';
					}

					if (String.isNotBlank(data.get('Identity_Information__c.Date_of_Birth__c'))) {
						List<String> dob = data.get('Identity_Information__c.Date_of_Birth__c').split('/');
						template +=                '"birth_date": "' + dob[2] + '-' + dob[0] + '-' + dob[1] + '",';
					} else if (String.isNotBlank(iden.TF4SF__Date_of_Birth__c)) {
							List<String> dobpa = iden.TF4SF__Date_of_Birth__c.split('/');
							template +=                '"birth_date": "' + dobpa[2] + '-' + dobpa[0] + '-' + dobpa[1] + '",';
					} else {
						template +=                '"birth_date": null,';
					}

					if (String.isNotBlank(data.get('Identity_Information__c.Citizenship__c'))) {
						template +=                '"immigration_status": "' + immStatusMap.get(data.get('Identity_Information__c.Citizenship__c')) + '",';
					} else if (String.isNotBlank(iden.TF4SF__Citizenship__c)) {
						template +=                '"immigration_status": "' + immStatusMap.get(iden.TF4SF__Citizenship__c) + '",';
					} else {
						template +=                '"immigration_status": null,';
					}

					if (String.isBlank(data.get('Application__c.Member__c'))) {
						template +=                '"member": true,';
					} else {
						template +=                '"member": false,';
					}

					if (String.isNotBlank(data.get('Application__c.Person_Number__c'))) {
						template +=                '"member_id": "' + data.get('Application__c.Person_Number__c') + '",';
					} else {
						template +=                '"member_id": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Housing_Status__c'))) {
						template +=                '"occupancy_status": "' + occStatusMap.get(data.get('Application__c.Housing_Status__c')) + '",';
					} else if (String.isNotBlank(app.TF4SF__Housing_Status__c)) {
						template +=                '"occupancy_status": "' + occStatusMap.get(app.TF4SF__Housing_Status__c) + '",';
					} else {
						template +=                '"occupancy_status": null,';
					}

					template +=                '"occupancy_address": {';
					template +=                    '"address_lines": [';

					if (String.isNotBlank(data.get('Application__c.Street_Address_1__c'))) {
						template +=                        '"' + data.get('Application__c.Street_Address_1__c').toUpperCase() + '"';
					} else if (String.isNotBlank(app.TF4SF__Street_Address_1__c)) {
						template +=                        '"' + app.TF4SF__Street_Address_1__c.toUpperCase() + '"';
					} else {
						template +=                        'null';
					}

					template +=                    '],';
					if (String.isNotBlank(data.get('Application__c.City__c'))) {
						template +=                    '"township": "' + data.get('Application__c.City__c').toUpperCase() + '",';
					} else if (String.isNotBlank(app.TF4SF__City__c)) {
						template +=                    '"township": "' + app.TF4SF__City__c.toUpperCase() + '",';
					} else {
						template +=                '"township": null,';
					}

					if (String.isNotBlank(data.get('Application__c.State__c'))) {
						template +=                    '"state_code": "' + data.get('Application__c.State__c').toUpperCase() + '",';
					} else if (String.isNotBlank(app.TF4SF__State__c)) {
						template +=                    '"state_code": "' + app.TF4SF__State__c.toUpperCase() + '",';
					} else {
						template +=                '"state_code": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Country__c'))) {
						template +=                    '"country_code": "' + data.get('Application__c.Country__c').toUpperCase() + '",';
					} else if (String.isNotBlank(app.TF4SF__Country__c)) {
						template +=                    '"country_code": "' + app.TF4SF__Country__c.toUpperCase() + '",';
					} else {
						template +=                '"country_code": "USA",';
					}

					if (String.isNotBlank(data.get('Application__c.Zip_Code__c'))) {
						template +=                    '"zip_code": "' + data.get('Application__c.Zip_Code__c') + '",';
					} else if (String.isNotBlank(app.TF4SF__Zip_Code__c)) {
						template +=                    '"zip_code": "' + app.TF4SF__Zip_Code__c + '",';
					} else {
						template +=                '"zip_code": null,';
					}

					if (String.isNotBlank(data.get('Application__c.Years__c'))) {
						Integer mts = (Integer.ValueOf(data.get('Application__c.Years__c'))*12) + Integer.ValueOf(data.get('Application__c.Months__c'));
						template +=                    '"occupancy_duration_months": '+mts;
					} else if (app.TF4SF__Years__c != null) {
						Integer m = (String.isNotBlank(app.TF4SF__Months__c))?Integer.valueOf(app.TF4SF__Months__c) : 0;
						Integer mts = (Integer.valueOf(app.TF4SF__Years__c*12)) + m;
						template +=                    '"occupancy_duration_months": '+mts;
					} else {
						template +=                '"occupancy_duration_months": null';
					}

					template +=                '},';
					if (String.isNotBlank(data.get('Application__c.Street_Address_1_Prev__c'))) {//previous address is null
						template +=                '"previous_occupancy_addresses": [';
						template +=                    '{';
						template +=                        '"address_lines": [';

						if (String.isNotBlank(data.get('Application__c.Street_Address_1_Prev__c'))) {
							template +=                               '"' + data.get('Application__c.Street_Address_1_Prev__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Street_Address_1_Prev__c)) {
							template +=                        '"' + app.TF4SF__Street_Address_1_Prev__c.toUpperCase() + '"';
						} else {
							template +=                        'null';
						}

						template +=                        '],';
						if (String.isNotBlank(data.get('Application__c.City_Prev__c'))) {
							template +=                        '"township": "' + data.get('Application__c.City_Prev__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__City_Prev__c)) {
							template +=                    '"township": "' + app.TF4SF__City_Prev__c.toUpperCase() + '",';
						} else {
							template +=                '"township": null,';
						}

						if (String.isNotBlank(data.get('Application__c.State_Prev__c'))) {
							template +=                        '"state_code": "' + data.get('Application__c.State_Prev__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__State_Prev__c)) {
							template +=                    '"state_code": "' + app.TF4SF__State_Prev__c.toUpperCase() + '",';
						} else {
							template +=                '"state_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Country_Prev__c'))) {
							template +=                        '"country_code": "' + data.get('Application__c.Country_Prev__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Country_Prev__c)) {
							template +=                    '"country_code": "' + app.TF4SF__Country_Prev__c.toUpperCase() + '",';
						} else {
							template +=                '"country_code": "USA",';
						}

						if (String.isNotBlank(data.get('Application__c.Zip_Code_Prev__c'))) {
							template +=                        '"zip_code": "' + data.get('Application__c.Zip_Code_Prev__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Zip_Code__c)) {
							template +=                    '"zip_code": "' + app.TF4SF__Zip_Code__c.toUpperCase() + '"';
						} else {
							template +=                '"zip_code": null';
						}

						template +=                    '}';
						template +=                '],';
					}//previous address is null

					if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1__c')) || String.isNotBlank(app.TF4SF__Mailing_Street_Address_1__c) || 
						String.isNotBlank(data.get('Application__c.Custom_Picklist1__c')) || String.isNotBlank(app.TF4SF__Custom_Picklist1__c)) {
						template +=                '"mailing_address": {';
						template +=                    '"address_lines": [';

						if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1__c'))) {
							template +=                        '"' + data.get('Application__c.Mailing_Street_Address_1__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Mailing_Street_Address_1__c)) {
							template +=                        '"' + app.TF4SF__Mailing_Street_Address_1__c.toUpperCase() + '"';
						} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist1__c')) && data.get('Application__c.Custom_Picklist1__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Street_Address_1__c'))) {
							template +=                        '"' + data.get('Application__c.Street_Address_1__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Custom_Picklist1__c) && app.TF4SF__Custom_Picklist1__c == 'Yes' && String.isNotBlank(app.TF4SF__Street_Address_1__c)) {
							template +=                        '"' + app.TF4SF__Street_Address_1__c.toUpperCase() + '"';
						} else {
							template +=                        'null';
						}

						template +=                    '],';
						if (String.isNotBlank(data.get('Application__c.Mailing_City__c'))) {
							template +=                    '"township": "' + data.get('Application__c.Mailing_City__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Mailing_City__c)) {
							template +=                    '"township": "' + app.TF4SF__Mailing_City__c.toUpperCase() + '",';
						} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist1__c')) && data.get('Application__c.Custom_Picklist1__c') == 'Yes' && String.isNotBlank(data.get('Application__c.City__c'))) {
							template +=                    '"township": "' + data.get('Application__c.City__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Custom_Picklist1__c) && app.TF4SF__Custom_Picklist1__c == 'Yes' && String.isNotBlank(app.TF4SF__City__c)) {
							template +=                    '"township": "' + app.TF4SF__City__c.toUpperCase() + '",';
						} else {
							template +=                '"township": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Mailing_State__c'))) {
							template +=                    '"state_code": "' + data.get('Application__c.Mailing_State__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Mailing_State__c)) {
							template +=                    '"state_code": "' + app.TF4SF__Mailing_State__c.toUpperCase() + '",';
						} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist1__c')) && data.get('Application__c.Custom_Picklist1__c') == 'Yes' && String.isNotBlank(data.get('Application__c.State__c'))) {
							template +=                    '"state_code": "' + data.get('Application__c.State__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Custom_Picklist1__c) && app.TF4SF__Custom_Picklist1__c == 'Yes' && String.isNotBlank(app.TF4SF__State__c)) {
							template +=                    '"state_code": "' + app.TF4SF__State__c.toUpperCase() + '",';
						} else {
							template +=                '"state_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Mailing_Country__c'))) {
							template +=                    '"country_code": "' + data.get('Application__c.Mailing_Country__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Mailing_Country__c)) {
							template +=                    '"country_code": "' + app.TF4SF__Mailing_Country__c.toUpperCase() + '",';
						} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist1__c')) && data.get('Application__c.Custom_Picklist1__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Country__c'))) {
							template +=                    '"country_code": "' + data.get('Application__c.Country__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Custom_Picklist1__c) && app.TF4SF__Custom_Picklist1__c == 'Yes' && String.isNotBlank(app.TF4SF__Country__c)) {
							template +=                    '"country_code": "' + app.TF4SF__Country__c.toUpperCase() + '",';
						} else {
							template +=                '"country_code": "USA",';
						}

						if (String.isNotBlank(data.get('Application__c.Mailing_Zip_Code__c'))) {
							template +=                    '"zip_code": "' + data.get('Application__c.Mailing_Zip_Code__c') + '"';
						} else if (String.isNotBlank(app.TF4SF__Mailing_Zip_Code__c)) {
							template +=                    '"zip_code": "' + app.TF4SF__Mailing_Zip_Code__c.toUpperCase() + '"';
						} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist1__c')) && data.get('Application__c.Custom_Picklist1__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Zip_Code__c'))) {
							template +=                    '"zip_code": "' + data.get('Application__c.Zip_Code__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Custom_Picklist1__c) && app.TF4SF__Custom_Picklist1__c == 'Yes' && String.isNotBlank(app.TF4SF__Zip_Code__c)) {
							template +=                    '"zip_code": "' + app.TF4SF__Zip_Code__c.toUpperCase() + '"';
						} else {
							template +=                '"zip_code": null';
						}

						template +=                '},';
					}//mailing address is null

					System.debug('Before Identification check');
					if (String.isNotBlank(iden.TF4SF__Identity_Number_Primary__c) || String.isNotBlank(data.get('Identity_Information__c.Identity_Number_Primary__c'))) {//Identification is not null
						template +=                '"identification_documents": [';
						template +=                    '{';

						if (String.isNotBlank(data.get('Identity_Information__c.ID_Type__c'))) {
							template +=                        '"type": "' + idenDocMap.get(data.get('Identity_Information__c.ID_Type__c')).toUpperCase() + '",';
						} else if (String.isNotBlank(iden.TF4SF__ID_Type__c)) {
							template +=                        '"type": "' + idenDocMap.get(iden.TF4SF__ID_Type__c).toUpperCase() + '",';
						} else {
							template +=                        '"type": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_Primary__c'))) {
							template +=                        '"id": "' + data.get('Identity_Information__c.Identity_Number_Primary__c').toUpperCase() + '",';
						} else if (String.isNotBlank(iden.TF4SF__Identity_Number_Primary__c)) {
							template +=                        '"id": "' + iden.TF4SF__Identity_Number_Primary__c.toUpperCase() + '",';
						} else {
							template +=                        '"id": "null",';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.State_Issued__c'))) {
							template +=                        '"state_code": "' + data.get('Identity_Information__c.State_Issued__c').toUpperCase() + '",';
						} else if (String.isNotBlank(iden.TF4SF__State_Issued__c)) {
							template +=                        '"state_code": "' + iden.TF4SF__State_Issued__c.toUpperCase() + '",';
						} else {
							template +=                        '"state_code": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Country_Issued__c')) || String.isNotBlank(iden.TF4SF__Country_Issued__c)) {
							if (String.isNotBlank(data.get('Identity_Information__c.ID_Type__c')) && data.get('Identity_Information__c.ID_Type__c').trim().equalsIgnoreCase('PASSPORT')) {
								template +=                        '"country_code": "' + data.get('Identity_Information__c.Country_Issued__c') + '",';
							} else if (String.isNotBlank(iden.TF4SF__Country_Issued__c) && iden.TF4SF__Country_Issued__c.trim().equalsIgnoreCase('Passport')) {
								template +=                        '"country_code": "' + iden.TF4SF__Country_Issued__c + '",';
							} else {
								template +=                        '"country_code": null,';
							}
						} else {
							template +=                        '"country_code": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Expiry_Date__c'))) {
							List<String> dt = data.get('Identity_Information__c.Expiry_Date__c').split('/');
							template +=                        '"expiration_date": "' + dt[2] + '-' + dt[0] + '-' + dt[1] + '",';
						} else if (String.isNotBlank(iden.TF4SF__Expiry_Date__c)) {
							List<String> dt = iden.TF4SF__Expiry_Date__c.split('/');
							template +=                        '"expiration_date": "' + dt[2] + '-' + dt[0] + '-' + dt[1] + '",';
						} else {
							template +=                        '"expiration_date": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Issue_Date__c'))) {
							List<String> dt = data.get('Identity_Information__c.Issue_Date__c').split('/');
							template +=                        '"issue_date": "' + dt[2] + '-' + dt[0] + '-' + dt[1] + '"';
						} else if (String.isNotBlank(iden.TF4SF__Issue_Date__c)) {
							List<String> dt = iden.TF4SF__Issue_Date__c.split('/');
							template +=                        '"issue_date": "' + dt[2] + '-' + dt[0] + '-' + dt[1] + '"';
						} else {
							template +=                        '"issue_date": null';   
						}

						template +=                    '}';
						template +=                '],';
					}//Identification is not null

					//if (kycinfo != null) {
						// if (String.isNotBlank(kycInfo.Question_1_Response__c)) {
							System.debug('Before kyc check data :::::::: ' + data);
							template +=                '"question_answers": [';

							if (app.TF4SF__Sub_Product__c.Contains('Checking') || app.TF4SF__Sub_Product__c.Contains('Saving') || app.TF4SF__Sub_Product__c.Contains('Certificate')) {
								//Applicant Question: Are you subject to backup withholding?
								if (String.isNotBlank(data.get('Application__c.Custom_Picklist6__c'))) {
									template +=                    '{';
									template +=                        '"question_name": "Withholding",';
									template +=                        '"answer": "' + data.get('Application__c.Custom_Picklist6__c').toUpperCase() + '"';
									template +=                    '},';
								} else if (String.isNotBlank(app.TF4SF__Custom_Picklist6__c)) {
									template +=                    '{';
									template +=                        '"question_name": "Withholding",';
									template +=                        '"answer": "' + app.TF4SF__Custom_Picklist6__c.toUpperCase() + '"';
									template +=                    '},';
								} else {
									template +=                    '{';
									template +=                        '"question_name": "Withholding",';
									template +=                        '"answer": null';
									template +=                    '},';
								}

								//Applicant Question: Are you a current employee, contract employee, or retiree of Apple Inc?
								if (String.isNotBlank(data.get('Application__c.Custom_Picklist24__c'))) {
									template +=                    '{';
									template +=                        '"question_name": "Apple Employee/Contractor/Retiree - XA",';
									template +=                        '"answer": "' + data.get('Application__c.Custom_Picklist24__c').toUpperCase() + '"';
									template +=                    '}';
								} else if (String.isNotBlank(app.Custom_Picklist24__c)) {
									template +=                    '{';
									template +=                        '"question_name": "Apple Employee/Contractor/Retiree - XA",';
									template +=                        '"answer": "' + app.Custom_Picklist24__c.toUpperCase() + '"';
									template +=                    '}';
								} else {
									template +=                    '{';
									template +=                        '"question_name": "Apple Employee/Contractor/Retiree - XA",';
									template +=                        '"answer": null';
									template +=                    '}';
								}
							}

							if (kycinfo != null) {
								if (String.isNotBlank(data.get('Application__c.Custom_Picklist24__c'))) {
									template +=                    ',{';
								} else {
									template +=                     ',{';
								}

								if (String.isNotBlank(kycInfo.Question_1_Text__c)) {
									template +=                        '"question_name": "' + kycInfo.Question_1_Text__c.toUpperCase() + '",';
								} else {
									template +=                         '"question_name": null,';
								}

								if (String.isNotBlank(kycInfo.Question_1_Response__c)) {
									template +=                        '"answer": "' + kycInfo.Question_1_Response__c.toUpperCase() + '"';
								} else {
									template +=                        '"answer": "null"';
								}

								template +=                    '},';
								template +=                    '{';

								if (String.isNotBlank(kycInfo.Question_2_Text__c)) {
									template +=                        '"question_name": "' + kycInfo.Question_2_Text__c.toUpperCase() + '",';
								} else {
									template +=                         '"question_name": "null",';
								}

								if (String.isNotBlank(kycInfo.Question_2_Response__c)) {
									template +=                        '"answer": "' + kycInfo.Question_2_Response__c.toUpperCase() + '"';
								} else {
									template +=                        '"answer": "null"';
								}

								template +=                    '},';
								template +=                    '{';

								if (String.isNotBlank(kycInfo.Question_3_Text__c)) {
									template +=                        '"question_name": "' + kycInfo.Question_3_Text__c.toUpperCase() + '",';
								} else {
									template +=                         '"question_name": null,';
								}

								if (String.isNotBlank(kycInfo.Question_3_Response__c)) {
									template +=                        '"answer": "' + kycInfo.Question_3_Response__c.toUpperCase() + '"';
								} else {
									template +=                        '"answer": "null"';
								}

								template +=                    '},';
								template +=                    '{';

								if (String.isNotBlank(kycInfo.Question_4_Text__c)) {
									template +=                        '"question_name": "' + kycInfo.Question_4_Text__c.toUpperCase() + '",';
								} else {
									template +=                         '"question_name": null,';
								}

								if (String.isNotBlank(kycInfo.Question_4_Response__c)) {
									template +=                        '"answer": "' + kycInfo.Question_4_Response__c.toUpperCase() + '"';
								} else {
									template +=                        '"answer": "null"';
								}

								template +=                    '}';
							}
							template +=                  '],';
						// }
					//}

					System.debug('Before financials check');
					template +=                '"financials": {';

					if (String.isNotBlank(data.get('Employment_Information__c.Custom_Currency1__c'))) {
						Decimal aInc = Decimal.valueOf(data.get('Employment_Information__c.Custom_Currency1__c'));
						template +=                    '"monthly_income": ' + aInc + ',';
					} else if (empInfo.TF4SF__Custom_Currency1__c != null) {
						Decimal aInc = empInfo.TF4SF__Custom_Currency1__c;
						template +=                    '"monthly_income": ' + aInc + ',';
					} else {
						template +=                    '"monthly_income": null,';
					}

					//Adding Other Income Details for Loans products
					template += '"monthly_other_incomes": [';
					if (String.isNotBlank(data.get('Employment_Information__c.Other_Income__c'))) {
						template +=                        '{';
						template +=                    '"amount": ' + data.get('Employment_Information__c.Other_Income__c');
						if (String.isNotBlank(data.get('Employment_Information__c.Custom_Text12__c'))) {
							template +=                    ',"description": "' + data.get('Employment_Information__c.Custom_Text12__c').toUpperCase() + '"';
						} else {
							template +=                    ',"description": null'; 
						}
						template +=                        '}';
					} else if (String.isNotBlank(String.valueOf(empInfo.TF4SF__Other_Income__c))) {
						template +=                        '{';
						template +=                    '"amount": ' + empInfo.TF4SF__Other_Income__c;
						if (String.isNotBlank(empInfo.TF4SF__Custom_Text12__c)) {
							template +=                    ',"description": "' + empInfo.TF4SF__Custom_Text12__c.toUpperCase() + '"';
						} else {
							template +=                    ',"description": null'; 
						}
						template +=                        '}';
					}
					System.debug('Before Other Income second block check');
					if (String.isNotBlank(data.get('Employment_Information__c.Other_Income2__c'))) {
						if (String.isNotBlank(data.get('Employment_Information__c.Other_Income__c')) || String.isNotBlank(String.valueOf(empInfo.TF4SF__Other_Income__c))) {
							System.debug('Inside if block of other income');
							template +=                        ',{';
						} else {
							System.debug('Else block of other Income ::::::: ' + data.get('Employment_Information__c.Other_Income__c') + ' &&&&&& ' + empInfo.TF4SF__Other_Income__c);
							template +=                        '{';
						}
						template +=                    '"amount": ' + data.get('Employment_Information__c.Other_Income2__c');
						if (String.isNotBlank(data.get('Employment_Information__c.Custom_Text13__c'))) {
							template +=                    ',"description": "' + data.get('Employment_Information__c.Custom_Text13__c').toUpperCase() + '"';
						} else {
							template +=                    ',"description": null'; 
						}
						template +=                        '}';
					} else if (String.isNotBlank(String.valueOf(empInfo.TF4SF__Other_Income2__c))) {
						if (String.isNotBlank(data.get('Employment_Information__c.Other_Income__c')) || String.isNotBlank(String.valueOf(empInfo.TF4SF__Other_Income__c))) {
							template +=                        ',{';
						} else {
							template +=                        '{';
						}
						template +=                    '"amount": ' + empInfo.TF4SF__Other_Income2__c;
						if (String.isNotBlank(empInfo.TF4SF__Custom_Text13__c)) {
							template +=                    ',"description": "' + empInfo.TF4SF__Custom_Text13__c.toUpperCase() + '"';
						} else {
							template +=                    ',"description": null'; 
						}
						template +=                        '}';
					}
					template += '],';
					//End of Other Income

					if (String.isNotBlank(data.get('Application__c.Monthly_Payment__c'))) {
						template +=                    '"monthly_housing_cost": ' + data.get('Application__c.Monthly_Payment__c') + ',';
					} else if (app.TF4SF__Monthly_Payment__c != null) {
						template +=                    '"monthly_housing_cost": ' + app.TF4SF__Monthly_Payment__c + ',';
					} else {
						template +=                    '"monthly_housing_cost": null,';
					}

					System.debug('data.get(Employment_Information__c.Years_Emp__c) ===== ' + data.get('Employment_Information__c.Years_Emp__c'));
					if (String.isNotBlank(data.get('Employment_Information__c.Years_Emp__c'))) {
						Integer mon = (Integer.ValueOf(data.get('Employment_Information__c.Years_Emp__c')) * 12) + Integer.ValueOf(data.get('Employment_Information__c.Months_Emp__c'));
						template +=                    '"profession_duration_months": ' + mon + ',';
					} else if (empinfo.TF4SF__Years_Emp__c != null) {
						Integer mon = Integer.ValueOf(empInfo.TF4SF__Years_Emp__c * 12) + Integer.ValueOf(empInfo.TF4SF__Months_Emp__c);
						template +=                    '"profession_duration_months": ' + mon + ',';
					} else {
						template +=                    '"profession_duration_months": null,';
					}

					if (String.isNotBlank(data.get('Employment_Information__c.Employment_Status__c'))) {
						template +=                    '"employment_status": "' + empMap.get(data.get('Employment_Information__c.Employment_Status__c')) + '"';
					} else if (empInfo.TF4SF__Employment_Status__c != null) {
						template +=                    '"employment_status": "' + empMap.get(empInfo.TF4SF__Employment_Status__c) + '"';
					} else {
						template +=                    '"employment_status": "EM"';
					}

					//if (String.isNotBlank(data.get('Employment_Information__c.Occupation__c')) || String.isNotBlank(empInfo.TF4SF__Occupation__c)) {
						template +=                    ',"employment": [';
						template +=                        '{';

						if (String.isNotBlank(data.get('Employment_Information__c.Occupation__c'))) {
							template +=                            '"title": "' + data.get('Employment_Information__c.Occupation__c').toUpperCase() + '",';
						} else if (String.isNotBlank(empinfo.TF4SF__Occupation__c)) {
							template +=                            '"title": "' + empInfo.TF4SF__Occupation__c.toUpperCase() + '",';
						
						} else if (String.isNotBlank(data.get('Employment_Information__c.Prior_Occupation__c'))) { //For "Retired" Employment Status
							template +=                            '"title": "' + data.get('Employment_Information__c.Prior_Occupation__c').toUpperCase() + '",';
						} else if (String.isNotBlank(empinfo.TF4SF__Prior_Occupation__c)) { //For "Retired" Employment Status
							template +=                            '"title": "' + empInfo.TF4SF__Prior_Occupation__c.toUpperCase() + '",';
						} else {
							template +=                    '"title": null,';
						}

						System.debug('data.get(Employment_Information__c.Years_Emp__) ======= ' + data.get('Employment_Information__c.Years_Emp__c'));
						if (String.isNotBlank(data.get('Employment_Information__c.Years_Emp__c'))) {
							Integer mon = (Integer.ValueOf(data.get('Employment_Information__c.Years_Emp__c')) * 12) + Integer.ValueOf(data.get('Employment_Information__c.Months_Emp__c'));
							System.debug('mon inside data map ====== ' + mon);
							template +=                    '"duration_months": ' + mon + ',';
						} else if (empinfo.TF4SF__Years_Emp__c != null) {
							Integer mon = Integer.ValueOf(empInfo.TF4SF__Years_Emp__c * 12) + Integer.ValueOf(empInfo.TF4SF__Months_Emp__c);
							System.debug('mon outside data map ====== ' + mon);
							template +=                    '"duration_months": ' + mon + ',';
						} else {
							template +=                    '"duration_months": null,';
						}

						if ((String.isNotBlank(data.get('Employment_Information__c.Employment_Status__c')) && data.get('Employment_Information__c.Employment_Status__c').contains('Military')) || 
							(String.isNotBlank(empinfo.TF4SF__Employment_Status__c) && empinfo.TF4SF__Employment_Status__c.contains('Military'))) { 
							if (String.isNotBlank(data.get('Employment_Information__c.Custom_Picklist7__c'))) {
								template +=                            '"employer": "' + data.get('Employment_Information__c.Custom_Picklist7__c').toUpperCase() + '"';
							} else if (empinfo.TF4SF__Custom_Picklist7__c != null) {
								template +=                            '"employer": "' + empInfo.TF4SF__Custom_Picklist7__c.toUpperCase() + '"';
							} else {
								template +=                            '"employer": null';
							}
						} else {
							if (String.isNotBlank(data.get('Employment_Information__c.Employer__c'))) {
								template +=                            '"employer": "' + data.get('Employment_Information__c.Employer__c').toUpperCase() + '"';
							} else if (String.isNotBlank(empinfo.TF4SF__Employer__c)) {
								template +=                            '"employer": "' + empInfo.TF4SF__Employer__c.toUpperCase() + '"';
							} else {
								template +=                            '"employer": null';
							}
						}
						
						template +=                            '}';
						template +=                    ']';
					//}
					//Previous Employment Details for Primary applicant for Loans Products.
					if (String.isNotBlank(data.get('Employment_Information__c.Employer_P__c')) || String.isNotBlank(empInfo.TF4SF__Employer_P__c)) {
						template +=                    ',"previous_employment": [';
						template +=                        '{';

						if (String.isNotBlank(data.get('Employment_Information__c.Occupation_P__c'))) {
							template +=                            '"title": "' + data.get('Employment_Information__c.Occupation_P__c').toUpperCase() + '",';
						} else if (String.isNotBlank(empinfo.TF4SF__Occupation_P__c)) {
							template +=                            '"title": "' + empInfo.TF4SF__Occupation_P__c.toUpperCase() + '",';
						} else {
							template +=                    '"title": null,';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Employer_P__c'))) {
							template +=                            '"employer": "' + data.get('Employment_Information__c.Employer_P__c').toUpperCase() + '"';
						} else if (String.isNotBlank(empinfo.TF4SF__Employer_P__c)) {
							template +=                            '"employer": "' + empInfo.TF4SF__Employer_P__c.toUpperCase() + '"';
						} else {
							template +=                            '"employer": null';
						}

						template +=                            '}';
						template +=                    ']';
					}
					//End of Previous Employment details

					template +=                '},';
					//Added By offshore
					template +=                '"kyc_information": {';


					if (data.get('Appication__c.Primary_Product_Status__c')=='Pending Review' && String.isNotBlank(data.get('Appication__c.Reason__c'))) {
						template +=                    '"qualifile_decision": "OVERRIDDEN",';
						template +=                    '"qualifile_override_reason_text": "' + data.get('Appication__c.Reason__c') + '"';
					} else if (String.isNotBlank(app.Reason__c) && app.TF4SF__Primary_Product_Status__c=='Pending Review') {
						template +=                    '"qualifile_decision": "OVERRIDDEN",';
						template +=                    '"qualifile_override_reason_text": "' + app.Reason__c + '"';
					} else {
						template +=                    '"qualifile_decision": null,';
						template +=                    '"qualifile_override_reason_text": null';
					}


					template +=                '}';
					if (String.isNotBlank(data.get('Identity_Information__c.SSN_J1__c')) || String.isNotBlank(iden.TF4SF__SSN_J1__c)) {
						template +=            '},';
					} else {
						template += '}';
					}

					// template +=            '},';
					//applicant2 start Aug 6
					if (String.isNotBlank(data.get('Identity_Information__c.SSN_J1__c')) || String.isNotBlank(iden.TF4SF__SSN_J1__c)) {//japp1 is null
						template +=            '{';
						if (String.isNotBlank(data.get('Application__c.First_Name_J__c'))) {
							template +=                '"first_name": "' + data.get('Application__c.First_Name_J__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__First_Name_J__c)) {
							template +=                '"first_name": "' + app.TF4SF__First_Name_J__c.toUpperCase() + '",';
						} else {
							template +=                '"first_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Middle_Name_J__c'))) {
							template +=                '"middle_name": "' + data.get('Application__c.Middle_Name_J__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Middle_Name_J__c)) {
							template +=                '"middle_name": "' + app.TF4SF__Middle_Name_J__c.toUpperCase() + '",';
						} else {
							template +=                '"middle_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Last_Name_J__c'))) {
							template +=                '"last_name": "' + data.get('Application__c.Last_Name_J__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Last_Name_J__c)) {
							template +=                '"last_name": "' + app.TF4SF__Last_Name_J__c.toUpperCase() + '",';
						} else {
							template +=                '"last_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Suffix_J__c'))) {
							template +=                '"suffix": "' + data.get('Application__c.Suffix_J__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Suffix_J__c)) {
							template +=                '"suffix": "' + app.TF4SF__Suffix_J__c.toUpperCase() + '",';
						} else {
							template +=                '"suffix": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Custom_Picklist29__c'))) {
							System.debug('applicanttypej1: '+data.get('Application__c.Custom_Picklist29__c')+'---'+apptypemap);
							template +=                '"applicant_type": "' + apptypemap.get(data.get('Application__c.Custom_Picklist29__c')) + '",';
						} else if (String.isNotBlank(app.Custom_Picklist29__c)) {
							template +=                '"applicant_type": "' + appTypeMap.get(app.Custom_Picklist29__c) + '",';
						} else {
							template +=                '"applicant_type": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.SSN_J1__c'))) {
							template +=                '"federal_id": "' + data.get('Identity_Information__c.SSN_J1__c') + '",';
						} else if (String.isNotBlank(iden.TF4SF__SSN_J1__c)) {
							template +=                '"federal_id": "' + iden.TF4SF__SSN_J1__c + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Marital_Status_J__c'))) {
							template +=                '"marital_status": "' + data.get('Application__c.Marital_Status_J__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Marital_Status_J__c)) {
							template +=                '"marital_status": "' + app.TF4SF__Marital_Status_J__c.toUpperCase() + '",';
						} else {
							template +=                '"marital_status": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Relationship_to_Primary_Applicant_J1__c'))) {
							template +=                '"relation_to_primary_applicant": "' + data.get('Application__c.Relationship_to_Primary_Applicant_J1__c').toUpperCase() + '",';
						} else if (app.TF4SF__Relationship_to_Primary_Applicant_J1__c != null) {
							template +=                '"relation_to_primary_applicant": "' + app.TF4SF__Relationship_to_Primary_Applicant_J1__c.toUpperCase() + '",';
						} else {
							template +=                '"relation_to_primary_applicant": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Email_Address_J__c'))) {
							template +=                '"email_address": "' + data.get('Application__c.Email_Address_J__c').toUpperCase() + '",';
						} else {
							template +=                '"email_address": "' + app.TF4SF__Email_Address_J__c.toUpperCase() + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Primary_Phone_Number_J__c'))) {
							template +=                '"home_phone_number": "' + data.get('Application__c.Primary_Phone_Number_J__c') + '",';
						} else if (app.TF4SF__Primary_Phone_Number_J__c != null) {
							template +=                '"home_phone_number": "' + app.TF4SF__Primary_Phone_Number_J__c + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Secondary_Phone_Number_J__c'))) {
							template +=                '"work_phone_number": "' + data.get('Application__c.Secondary_Phone_Number_J__c') + '",';
						} else if (app.TF4SF__Secondary_Phone_Number_J__c != null) {
							template +=                '"work_phone_number": "' + app.TF4SF__Secondary_Phone_Number_J__c + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Tertiary_Phone_Number_J1__c'))) {
							template +=                '"mobile_phone_number": "' + data.get('Application__c.Tertiary_Phone_Number_J1__c') + '",';
						} else if (app.TF4SF__Tertiary_Phone_Number_J1__c != null) {
							template +=                '"mobile_phone_number": "' + app.TF4SF__Tertiary_Phone_Number_J1__c + '",';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Date_of_Birth_J1__c'))) {
							List<String> dob1 = data.get('Identity_Information__c.Date_of_Birth_J1__c').split('/');
							template +=                '"birth_date": "' + dob1[2] + '-' + dob1[0] + '-' + dob1[1] + '",';
						} else if (String.isNotBlank(iden.TF4SF__Date_of_Birth_J1__c)) {
							List<String> dobj1 = iden.TF4SF__Date_of_Birth_J1__c.split('/');
							template +=                '"birth_date": "' + dobj1[2] + '-' + dobj1[0] + '-' + dobj1[1] + '",';
							//date template +=                '"birth_date": "0000-00-00",';
						} else {
							template +=                '"birth_date": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Citizenship_J1__c'))) {
							template +=                '"immigration_status": "' + immStatusMap.get(data.get('Identity_Information__c.Citizenship_J1__c')) + '",';
						} else if (String.isNotBlank(iden.TF4SF__Citizenship_J1__c)) {
							template +=                '"immigration_status": "' + immStatusMap.get(iden.TF4SF__Citizenship_J1__c) + '",';
						} else {
							template +=                '"immigration_status": null,';
						}

						if (String.isBlank(data.get('Application__c.Member__c'))) {
							template +=                '"member": true,';
						} else {
							template +=                '"member": false,';
						}

						if (String.isNotBlank(data.get('Application__c.Person_Number__c'))) {
							template +=                '"member_id": "' + data.get('Application__c.Person_Number__c') + '",';
						} else {
							template +=                '"member_id": null,';
						}

						//template +=                '"gender": "' + app.TF4SF__Sub_Product__c + '",';
						if (String.isNotBlank(data.get('Application__c.Housing_Status_J__c'))) {
							template +=                '"occupancy_status": "' + occStatusMap.get(data.get('Application__c.Housing_Status_J__c')) + '",';
						} else if (String.isNotBlank(app.TF4SF__Housing_Status_J__c)) {
							template +=                '"occupancy_status": "' + occStatusMap.get(app.TF4SF__Housing_Status_J__c) + '",';
						} else {
							template +=                '"occupancy_status": null,';
						}

						template +=                '"occupancy_address": {';
						template +=                    '"address_lines": [';

						if (String.isNotBlank(data.get('Application__c.Street_Address_J__c'))) {
							template +=                        '"' + data.get('Application__c.Street_Address_J__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Street_Address_J__c)) {
							template +=                        '"' + app.TF4SF__Street_Address_J__c.toUpperCase() + '"';
						} else {
							template +=                        'null';
						}

						template +=                    '],';
						if (String.isNotBlank(data.get('Application__c.City_J__c'))) {
							template +=                    '"township": "' + data.get('Application__c.City_J__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__City_J__c)) {
							template +=                '"township": "' + app.TF4SF__City_J__c.toUpperCase() + '",';
						} else {
							template +=                '"township": null,';
						}

						if (String.isNotBlank(data.get('Application__c.State_J__c'))) {
							template +=                    '"state_code": "' + data.get('Application__c.State_J__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__State_J__c)) {
							template +=                '"state_code": "' + app.TF4SF__State_J__c.toUpperCase() + '",';
						} else {
							template +=                '"state_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Country_J1__c'))) {
							template +=                    '"country_code": "' + data.get('Application__c.Country_J1__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Country_J1__c)) {
							template +=                '"country_code": "' + app.TF4SF__Country_J1__c.toUpperCase() + '",';
						} else {
							template +=                '"country_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Zip_Code_J__c'))) {
							template +=                    '"zip_code": "' + data.get('Application__c.Zip_Code_J__c') + '",';
						} else if (String.isNotBlank(app.TF4SF__Zip_Code_J__c)) {
							template +=                '"zip_code": "' + app.TF4SF__Zip_Code_J__c + '",';
						} else {
							template +=                '"zip_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Years_J__c'))) {
							Integer mts = (Integer.ValueOf(data.get('Application__c.Years_J__c'))*12) + Integer.ValueOf(data.get('Application__c.Months_J__c'));
							template +=                    '"occupancy_duration_months": '+mts;
						} else if (app.TF4SF__Years_J__c != null) {
							Integer m = (String.isNotBlank(app.TF4SF__Months_J__c))?Integer.valueOf(app.TF4SF__Months_J__c) : 0;
							Integer mts = (Integer.valueOf(app.TF4SF__Years_J__c*12)) + m;
							template +=                    '"occupancy_duration_months": '+mts;
						} else {
							template +=                '"occupancy_duration_months": null';
						}

						template +=                '},';
						if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP__c'))) {//previous address is null
							template +=                '"previous_occupancy_addresses": [';
							template +=                    '{';
							template +=                        '"address_lines": [';

							if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP__c'))) {
								template +=                            '"' + data.get('Application__c.Street_Address_1_JP__c').toUpperCase() + '"';
							} else if (String.isNotBlank(app.TF4SF__Street_Address_1_JP__c)) {
								template +=                        '"' + app.TF4SF__Street_Address_1_JP__c.toUpperCase() + '"';
							} else {
								template +=                        'null';
							}

							template +=                        '],';
							if (String.isNotBlank(data.get('Application__c.City_JP__c'))) {
								template +=                        '"township": "' + data.get('Application__c.City_JP__c').toUpperCase() + '",'; 
							} else if (String.isNotBlank(app.TF4SF__City_JP__c)) {
								template +=                '"township": "' + app.TF4SF__City_JP__c.toUpperCase() + '",';
							} else {
								template +=                '"township": null,';
							}

							if (String.isNotBlank(data.get('Application__c.State_JP__c'))) {
								template +=                        '"state_code": "' + data.get('Application__c.State_JP__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__State_JP__c)) {
								template +=                '"state_code": "' + app.TF4SF__State_JP__c.toUpperCase() + '",';
							} else {
								template +=                '"state_code": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Country_JP1__c'))) {
								template +=                        '"country_code": "' + data.get('Application__c.Country_JP1__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Country_JP1__c)) {
								template +=                '"country_code": "' + app.TF4SF__Country_JP1__c.toUpperCase() + '",';
							} else {
								template +=                '"country_code": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Zip_Code_JP__c'))) {
								template +=                        '"zip_code": "' + data.get('Application__c.Zip_Code_JP__c') + '"'; 
							} else if (String.isNotBlank(app.TF4SF__Zip_Code_JP__c)) {
								template +=                '"zip_code": "' + app.TF4SF__Zip_Code_JP__c + '"';
							} else {
								template +=                '"zip_code": null';
							}

							template +=                    '}';
							template +=                '],';
						} //previous address is null

						if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1_J1__c')) || String.isNotBlank(app.TF4SF__Mailing_Street_Address_1_J1__c) || 
							String.isNotBlank(data.get('Application__c.Custom_Picklist2__c')) || String.isNotBlank(app.TF4SF__Custom_Picklist2__c)) {//Mailing address is null
							template +=                '"mailing_address": {';
							template +=                    '"address_lines": [';

							if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1_J1__c'))) {
								template +=                            '"' + data.get('Application__c.Mailing_Street_Address_1_J1__c').toUpperCase() + '"';
							} else if (String.isNotBlank(app.TF4SF__Mailing_Street_Address_1_J1__c)) {
								template +=                        '"' + app.TF4SF__Mailing_Street_Address_1_J1__c.toUpperCase() + '"';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist2__c')) && data.get('Application__c.Custom_Picklist2__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Street_Address_J__c'))) {
								template +=                        '"' + data.get('Application__c.Street_Address_J__c').toUpperCase() + '"';
							} else if (String.isNotBlank(app.TF4SF__Custom_Picklist2__c) && app.TF4SF__Custom_Picklist2__c == 'Yes' && String.isNotBlank(app.TF4SF__Street_Address_J__c)) {
								template +=                        '"' + app.TF4SF__Street_Address_J__c.toUpperCase() + '"';
							} else {
								template +=                        'null';
							}

							template +=                    '],';
							if (String.isNotBlank(data.get('Application__c.Mailing_City_J1__c'))) {
								template +=                    '"township": "' + data.get('Application__c.Mailing_City_J1__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Mailing_City_J1__c)) {
								template +=                '"township": "' + app.TF4SF__Mailing_City_J1__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist2__c')) && data.get('Application__c.Custom_Picklist2__c') == 'Yes' && String.isNotBlank(data.get('Application__c.City_J__c'))) {
				              	template +=                    '"township": "' + data.get('Application__c.City_J__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist2__c) && app.TF4SF__Custom_Picklist2__c == 'Yes' && String.isNotBlank(app.TF4SF__City_J__c)) {
				              	template +=                    '"township": "' + app.TF4SF__City_J__c.toUpperCase() + '",';
				            } else {
								template +=                '"township": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_State_J1__c'))) {
								template +=                    '"state_code": "' + data.get('Application__c.Mailing_State_J1__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Mailing_State_J1__c)) {
								template +=                '"state_code": "' + app.TF4SF__Mailing_State_J1__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist2__c')) && data.get('Application__c.Custom_Picklist2__c') == 'Yes' && String.isNotBlank(data.get('Application__c.State_J__c'))) {
				              	template +=                    '"state_code": "' + data.get('Application__c.State_J__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist2__c) && app.TF4SF__Custom_Picklist2__c == 'Yes' && String.isNotBlank(app.TF4SF__State_J__c)) {
				              	template +=                    '"state_code": "' + app.TF4SF__State_J__c.toUpperCase() + '",';
				            } else {
								template +=                '"state_code": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_Country_J1__c'))) {
								template +=                    '"country_code": "' + data.get('Application__c.Mailing_Country_J1__c').toUpperCase() + '",';
							} /*else if (String.isNotBlank(app.TF4SF__Mailing_Country_J1__c)) {
								template +=                '"country_code": "' + app.TF4SF__Mailing_Country_J1__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist2__c')) && data.get('Application__c.Custom_Picklist2__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Country_J1__c'))) {
				              	template +=                    '"country_code": "' + data.get('Application__c.Country_J1__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist2__c) && app.TF4SF__Custom_Picklist2__c == 'Yes' && String.isNotBlank(app.TF4SF__Country_J1__c)) {
				              	template +=                    '"country_code": "' + app.TF4SF__Country_J1__c.toUpperCase() + '",';
				            } */else {
								template +=                '"country_code": "USA",';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_Zip_Code_J1__c'))) {
								template +=                    '"zip_code": "' + data.get('Application__c.Mailing_Zip_Code_J1__c') + '"';
							} else if (String.isNotBlank(app.TF4SF__Mailing_Zip_Code_J1__c)) {
								template +=                '"zip_code": "' + app.TF4SF__Mailing_Zip_Code_J1__c + '"';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist2__c')) && data.get('Application__c.Custom_Picklist2__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Zip_Code_J__c'))) {
				              	template +=                    '"zip_code": "' + data.get('Application__c.Zip_Code_J__c').toUpperCase() + '"';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist2__c) && app.TF4SF__Custom_Picklist2__c == 'Yes' && String.isNotBlank(app.TF4SF__Zip_Code_J__c)) {
				              	template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_J__c.toUpperCase() + '"';
				            } else {
								template +=                '"zip_code": null';
							}

							template +=                '},';
						}//Mailing address is null

						System.debug('Actual data map ===== ' +data );
						String expDate = data.get('Identity_Information__c.Identity_Number_J1__c');
						System.debug('data.get expDate for Joint1 =====  ' + expDate);

						if (String.isNotBlank(iden.TF4SF__Identity_Number_J1__c) || String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J1__c'))) {//Identification Information is null
							template +=                '"identification_documents": [';
							template +=                    '{';

							if (String.isNotBlank(data.get('Identity_Information__c.ID_Type_J1__c'))) {
								template +=                        '"type": "' + idenDocMap.get(data.get('Identity_Information__c.ID_Type_J1__c')).toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__ID_Type_J1__c)) {
								template +=                        '"type": "' + idenDocMap.get(iden.TF4SF__ID_Type_J1__c).toUpperCase() + '",';
							} else {
								template +=                        '"type": "null",';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J1__c'))) {
								template +=                        '"id": "' + data.get('Identity_Information__c.Identity_Number_J1__c').toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__Identity_Number_J1__c)) {
								template +=                        '"id": "' + iden.TF4SF__Identity_Number_J1__c.toUpperCase() + '",';
							} else {
								template +=                        '"id": "null",';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.State_Issued_J1__c'))) {
								template +=                        '"state_code": "' + data.get('Identity_Information__c.State_Issued_J1__c').toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__State_Issued_J1__c)) {
								template +=                        '"state_code": "' + iden.TF4SF__State_Issued_J1__c.toUpperCase() + '",';
							} else {
								template +=                        '"state_code": null,';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Country_Issued_J1__c')) || String.isNotBlank(iden.TF4SF__Country_Issued_J1__c)) {
								if (String.isNotBlank(data.get('Identity_Information__c.ID_Type_J1__c')) && data.get('Identity_Information__c.ID_Type_J1__c').trim().equalsIgnoreCase('Passport')) {
									template +=                        '"country_code": "' + data.get('Identity_Information__c.Country_Issued_J1__c') + '",';
								} else if (String.isNotBlank(iden.TF4SF__Country_Issued_J1__c) && iden.TF4SF__Country_Issued_J1__c.trim().equalsIgnoreCase('Passport')) {
									template +=                        '"country_code": "' + iden.TF4SF__Country_Issued_J1__c + '",';
								} else {
									template +=                        '"country_code": null,';
								}
							} else {
								template +=                        '"country_code": null,';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Expiry_Date_J1__c'))) {
								List<String> dt = data.get('Identity_Information__c.Expiry_Date_J1__c').split('/');
								template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
							} else if (String.isNotBlank(iden.TF4SF__Expiry_Date_J1__c)) {
								List<String> dt = iden.TF4SF__Expiry_Date_J1__c.split('/');
								template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
							} else {
								template +=                        '"expiration_date": null,';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Issue_Date_J1__c'))) {
								List<String> dt = data.get('Identity_Information__c.Issue_Date_J1__c').split('/');
								template +=                        '"issue_date": "' + dt[2] + '-' + dt[0] + '-' + dt[1] + '"';
							} else if (String.isNotBlank(iden.TF4SF__Issue_Date_J1__c)) {
								List<String> dt = iden.TF4SF__Issue_Date_J1__c.split('/');
								template +=                        '"issue_date": "' + dt[2] + '-' + dt[0] + '-' + dt[1] + '"';
							} else {
								template +=                        '"issue_date": null';   
							}

							

							template +=                    '}';
							template +=                '],';
						}//Identification Information is null

						//questions for joint applicant1
						template +=                '"question_answers": [';
						if (app.TF4SF__Sub_Product__c.Contains('Checking') || app.TF4SF__Sub_Product__c.Contains('Saving') || app.TF4SF__Sub_Product__c.Contains('Certificate')) {
							//Applicant Question: Are you subject to backup withholding?
							if (String.isNotBlank(data.get('Application__c.Custom_Picklist8__c'))) {
								template +=                    '{';
								 template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": "' + data.get('Application__c.Custom_Picklist8__c').toUpperCase() + '"';
								template +=                    '}';
							} else if (String.isNotBlank(app.TF4SF__Custom_Picklist8__c)) {
								template +=                    '{';
								template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": "' + app.TF4SF__Custom_Picklist8__c.toUpperCase() + '"';
								template +=                    '}';
							} else {
								template +=                    '{';
								template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": null';
								template +=                    '}';
							}   
							
						}
						template +=                  '],';
						template +=                '"financials": {';

						if (data.get('Employment_Information__c.Custom_Currency2__c') != null) {
							Decimal aInc = Decimal.valueOf(data.get('Employment_Information__c.Custom_Currency2__c'));
							template +=                    '"monthly_income": ' + aInc + ',';
						} else if (empInfo.TF4SF__Custom_Currency2__c != null) {
							Decimal aInc = empInfo.TF4SF__Custom_Currency2__c;
							template +=                    '"monthly_income": ' + aInc + ',';
						} else {
							template +=                    '"monthly_income": null,';
						}

						//Adding Other Income Details for Loans products for Joint-1
						template += '"monthly_other_incomes": [';
						if (String.isNotBlank(data.get('Employment_Information__c.Other_Income_J1__c'))) {
						   template +=                        '{';
						   template +=                    '"amount": ' + data.get('Employment_Information__c.Other_Income_J1__c');
						   if (String.isNotBlank(data.get('Employment_Information__c.Custom_Text14__c'))) {
						      template +=                    ',"description": "' + data.get('Employment_Information__c.Custom_Text14__c').toUpperCase() + '"';
						   } else {
						      template +=                    ',"description": null'; 
						   }
						   template +=                        '}';
						} else if (String.isNotBlank(String.valueOf(empInfo.TF4SF__Other_Income_J1__c))) {
						   template +=                        '{';
						   template +=                    '"amount": ' + empInfo.TF4SF__Other_Income_J1__c;
						   if (String.isNotBlank(empInfo.TF4SF__Custom_Text14__c)) {
						      template +=                    ',"description": "' + empInfo.TF4SF__Custom_Text14__c.toUpperCase()+ '"';
						   } else {
						      template +=                    ',"description": null'; 
						   }
						   template +=                        '}';
						}
						if (String.isNotBlank(data.get('Employment_Information__c.Other_Income2_J1__c'))) {
						   if (String.isNotBlank(data.get('Employment_Information__c.Other_Income_J1__c')) || String.isNotBlank(String.valueOf(empInfo.TF4SF__Other_Income_J1__c))) {
						      template +=                        ',{';
						   } else {
						      template +=                        '{';
						   }
						   template +=                    '"amount": ' + data.get('Employment_Information__c.Other_Income2_J1__c');
						   if (String.isNotBlank(data.get('Employment_Information__c.Custom_Text15__c'))) {
						      template +=                    ',"description": "' + data.get('Employment_Information__c.Custom_Text15__c').toUpperCase() + '"';
						   } else {
						      template +=                    ',"description": null'; 
						   }
						   template +=                        '}';
						} else if (String.isNotBlank(String.valueOf(empInfo.TF4SF__Other_Income2_J1__c))) {
						   template +=                        '{';
						   template +=                    '"amount": ' + empInfo.TF4SF__Other_Income2_J1__c;
						   if (String.isNotBlank(empInfo.TF4SF__Custom_Text15__c)) {
						      template +=                    ',"description": "' + empInfo.TF4SF__Custom_Text15__c.toUpperCase() + '"';
						   } else {
						      template +=                    ',"description": null'; 
						   }
						   template +=                        '}';
						}
						template += '],';
						//End of Other Income

						if (String.isNotBlank(data.get('Application__c.Monthly_Payment_J__c'))) {
							template +=                    '"monthly_housing_cost": ' + data.get('Application__c.Monthly_Payment_J__c') + ',';
						} else if (app.TF4SF__Monthly_Payment_J__c != null) {
							template +=                    '"monthly_housing_cost": ' + app.TF4SF__Monthly_Payment_J__c + ',';
						} else {
							template +=                    '"monthly_housing_cost": null,';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Years_EmpJ1__c'))) {
							Integer mon = (Integer.ValueOf(data.get('Employment_Information__c.Years_EmpJ1__c')) * 12) + Integer.ValueOf(data.get('Employment_Information__c.Months_EmpJ1__c'));
							template +=                    '"profession_duration_months": ' + mon + ',';
						} else if (empinfo.TF4SF__Years_EmpJ1__c != null) {
							Integer mon = Integer.ValueOf(empInfo.TF4SF__Years_EmpJ1__c * 12) + Integer.ValueOf(empInfo.TF4SF__Months_EmpJ1__c);
							template +=                    '"profession_duration_months": ' + mon + ',';
						} else {
							template +=                    '"profession_duration_months": null,';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J1__c'))) {
							//template +=                    '"employment_status": "' + data.get('Employment_Information__c.Employment_Status_J1__c').toUpperCase() + '",';
							template +=                    '"employment_status": "' + empMap.get(data.get('Employment_Information__c.Employment_Status_J1__c')) + '"';
							//template +=                    '"employment_status": "EM"';
						} else if (empInfo.TF4SF__Employment_Status_J1__c != null) {
							template +=                    '"employment_status": "' + empMap.get(empInfo.TF4SF__Employment_Status_J1__c) + '"';
						} else {
							template +=                    '"employment_status": "EM"';
						}

						/*if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J1__c')) || String.isNotBlank(empInfo.TF4SF__Occupation_J1__c) || 
							(String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J1__c')) && data.get('Employment_Information__c.Employment_Status_J1__c').contains('Military')) || 
							(String.isNotBlank(empinfo.TF4SF__Employment_Status_J1__c) && empinfo.TF4SF__Employment_Status_J1__c.contains('Military'))) {*/
							template +=                    ',"employment": [';
							template +=                        '{';

							if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J1__c'))) {
								template +=                            '"title": "' + data.get('Employment_Information__c.Occupation_J1__c').toUpperCase() + '",';
							} else if (String.isNotBlank(empinfo.TF4SF__Occupation_J1__c)) {
								template +=                            '"title": "' + empInfo.TF4SF__Occupation_J1__c.toUpperCase() + '",';
							
							} else if (String.isNotBlank(data.get('Employment_Information__c.Prior_Occupation_J1__c'))) { //For "Retired" Employment Status
								template +=                            '"title": "' + data.get('Employment_Information__c.Prior_Occupation_J1__c').toUpperCase() + '",';
							} else if (String.isNotBlank(empinfo.TF4SF__Prior_Occupation_J1__c)) { //For "Retired" Employment Status
								template +=                            '"title": "' + empInfo.TF4SF__Prior_Occupation_J1__c.toUpperCase() + '",';
							} else {
								template +=                            '"title": null,';
							}

							if (String.isNotBlank(data.get('Employment_Information__c.Years_EmpJ1__c'))) {
								Integer mon = (Integer.ValueOf(data.get('Employment_Information__c.Years_EmpJ1__c')) * 12) + Integer.ValueOf(data.get('Employment_Information__c.Months_EmpJ1__c'));
								template +=                    '"duration_months": ' + mon + ',';
							} else if (empinfo.TF4SF__Years_EmpJ1__c != null) {
								Integer mon = Integer.ValueOf(empInfo.TF4SF__Years_EmpJ1__c * 12) + Integer.ValueOf(empInfo.TF4SF__Months_EmpJ1__c);
								template +=                    '"duration_months": ' + mon + ',';
							} else {
								template +=                    '"duration_months": null,';
							}

							if ((String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J1__c')) && data.get('Employment_Information__c.Employment_Status_J1__c').contains('Military')) || 
								(String.isNotBlank(empinfo.TF4SF__Employment_Status_J1__c) && empinfo.TF4SF__Employment_Status_J1__c.contains('Military'))) { 
								if (String.isNotBlank(data.get('Employment_Information__c.Custom_Picklist8__c'))) {
									template +=                            '"employer": "' + data.get('Employment_Information__c.Custom_Picklist8__c').toUpperCase() + '"';
								} else if (empinfo.TF4SF__Custom_Picklist8__c != null) {
									template +=                            '"employer": "' + empInfo.TF4SF__Custom_Picklist8__c.toUpperCase() + '"';
								} else {
									template +=                            '"employer": null';
								}
							} else {
								if (String.isNotBlank(data.get('Employment_Information__c.Employer_J1__c'))) {
									template +=                            '"employer": "' + data.get('Employment_Information__c.Employer_J1__c').toUpperCase() + '"';
								} else if (String.isNotBlank(empinfo.TF4SF__Employer_J1__c)) {
									template +=                            '"employer": "' + empInfo.TF4SF__Employer_J1__c.toUpperCase() + '"';
								} else {
									template +=                            '"employer": null';
								}
							}

							template +=                            '}';
							template +=                    ']';
						//}

						//Previous Employment Details for Primary applicant for Loans Products.
						if (String.isNotBlank(data.get('Employment_Information__c.Employer_JP1__c')) || String.isNotBlank(empInfo.TF4SF__Employer_JP1__c)) {
							template +=                    ',"previous_employment": [';
							template +=                        '{';

							if (String.isNotBlank(data.get('Employment_Information__c.Occupation_JP1__c'))) {
								template +=                            '"title": "' + data.get('Employment_Information__c.Occupation_JP1__c').toUpperCase() + '",';
							} else if (String.isNotBlank(empinfo.TF4SF__Occupation_JP1__c)) {
								template +=                            '"title": "' + empInfo.TF4SF__Occupation_JP1__c.toUpperCase() + '",';
							} else {
								template +=                    '"title": null,';
							}

							if (String.isNotBlank(data.get('Employment_Information__c.Employer_JP1__c'))) {
								template +=                            '"employer": "' + data.get('Employment_Information__c.Employer_JP1__c').toUpperCase() + '"';
							} else if (String.isNotBlank(empinfo.TF4SF__Employer_JP1__c)) {
								template +=                            '"employer": "' + empInfo.TF4SF__Employer_JP1__c.toUpperCase() + '"';
							} else {
								template +=                            '"employer": null';
							}

							template +=                            '}';
							template +=                    ']';
						}
						//End of Previous Employment details

						template +=                '}';
						if (String.isNotBlank(data.get('Identity_Information__c.SSN_J2__c')) || String.isNotBlank(iden.TF4SF__SSN_J2__c)) {
							template +=            '},';
						} else {
							template += '}';
						}
					}//japp1 is null ends

					//applicant2 end aug 6
					//applicant3 start aug6
					if (String.isNotBlank(data.get('Identity_Information__c.SSN_J2__c')) || String.isNotBlank(iden.TF4SF__SSN_J2__c)) {//japp2 is not null
						template +=            '{';
						if (String.isNotBlank(data.get('Application__c.First_Name_J2__c'))) {
							template +=                '"first_name": "' + data.get('Application__c.First_Name_J2__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__First_Name_J2__c)) {
							template +=                '"first_name": "' + app.TF4SF__First_Name_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"first_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Middle_Name_J2__c'))) {
							template +=                ',"middle_name": "' + data.get('Application__c.Middle_Name_J2__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Middle_Name_J2__c)) {
							template +=                '"middle_name": "' + app.TF4SF__Middle_Name_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"middle_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Last_Name_J2__c'))) {
							template +=                '"last_name": "' + data.get('Application__c.Last_Name_J2__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Last_Name_J2__c)) {
							template +=                '"last_name": "' + app.TF4SF__Last_Name_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"last_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Suffix_J2__c'))) {
							template +=                '"suffix": "' + data.get('Application__c.Suffix_J2__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Suffix_J2__c)) {
							template +=                '"suffix": "' + app.TF4SF__Suffix_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"suffix": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Custom_Picklist28__c'))) {
							template +=                '"applicant_type": "' + apptypemap.get(data.get('Application__c.Custom_Picklist28__c')) + '",';
						} else if (String.isNotBlank(app.Custom_Picklist28__c)) {
							template +=                '"applicant_type": "' + appTypeMap.get(app.Custom_Picklist28__c) + '",';
						} else {
							template +=                '"applicant_type": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.SSN_J2__c'))) {
							template +=                '"federal_id": "' + data.get('Identity_Information__c.SSN_J2__c') + '",';
						} else if (String.isNotBlank(iden.TF4SF__SSN_J2__c)) {
							//System.debug('entered ssnprime: ' + data.get('Identity_Information__c.SSN_Prime__c'));
							template +=                '"federal_id": "' + iden.TF4SF__SSN_J2__c + '",';
						} else {
							template +=                '"federal_id": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Marital_Status_J2__c'))) {
							template +=                '"marital_status": "' + data.get('Application__c.Marital_Status_J2__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Marital_Status_J2__c)) {
							template +=                '"marital_status": "' + app.TF4SF__Marital_Status_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"marital_status": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Relationship_to_Primary_Applicant_J2__c'))) {
							template +=                '"relation_to_primary_applicant": "' + data.get('Application__c.Relationship_to_Primary_Applicant_J2__c').toUpperCase() + '",';
						} else if (app.TF4SF__Relationship_to_Primary_Applicant_J2__c != null) {
							template +=                '"relation_to_primary_applicant": "' + app.TF4SF__Relationship_to_Primary_Applicant_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"relation_to_primary_applicant": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Email_Address_J2__c'))) {
							template +=                '"email_address": "' + data.get('Application__c.Email_Address_J2__c').toUpperCase() + '",';
						} else {
							template +=                '"email_address": "' + app.TF4SF__Email_Address_J2__c.toUpperCase() + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Primary_Phone_Number_J2__c'))) {
							template +=                '"home_phone_number": "' + data.get('Application__c.Primary_Phone_Number_J2__c') + '",';
						} else if (app.TF4SF__Primary_Phone_Number_J2__c != null) {
							template +=                '"home_phone_number": "' + app.TF4SF__Primary_Phone_Number_J2__c + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Secondary_Phone_Number_J2__c'))) {
							template +=                '"work_phone_number": "' + data.get('Application__c.Secondary_Phone_Number_J2__c') + '",';
						} else if (app.TF4SF__Secondary_Phone_Number_J2__c != null) {
							template +=                '"work_phone_number": "' + app.TF4SF__Secondary_Phone_Number_J2__c + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Tertiary_Phone_Number_J2__c'))) {
							template +=                '"mobile_phone_number": "' + data.get('Application__c.Tertiary_Phone_Number_J2__c') + '",';
						} else if (app.TF4SF__Tertiary_Phone_Number_J2__c != null) {
							template +=                '"mobile_phone_number": "' + app.TF4SF__Tertiary_Phone_Number_J2__c + '",';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Date_of_Birth_J2__c'))) {
							List<String> dob2 = data.get('Identity_Information__c.Date_of_Birth_J2__c').split('/');
							template +=                '"birth_date": "' + dob2[2] + '-' + dob2[1] + '-' + dob2[0] + '",';
						} else if (String.isNotBlank(iden.TF4SF__Date_of_Birth_J2__c)) {
							List<String> dobj2 = iden.TF4SF__Date_of_Birth_J2__c.split('/');
							template +=                '"birth_date": "' + dobj2[2] + '-' + dobj2[0] + '-' + dobj2[1] + '",';
							//date template +=                '"birth_date": "0000-00-00",';
						} else {
							template +=                '"birth_date": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Citizenship_J2__c'))) {
							template +=                '"immigration_status": "' + immStatusMap.get(data.get('Identity_Information__c.Citizenship_J2__c')) + '",';
						} else if (String.isNotBlank(iden.TF4SF__Citizenship_J2__c)) {
							template +=                '"immigration_status": "' + immStatusMap.get(iden.TF4SF__Citizenship_J2__c) + '",';
						} else {
							template +=                '"immigration_status": null,';
						}

						if (String.isBlank(data.get('Application__c.Member__c'))) {
							template +=                '"member": true,';
						} else {
							template +=                '"member": false,';
						}

						if (String.isNotBlank(data.get('Application__c.Person_Number__c'))) {
							template +=                '"member_id": "' + data.get('Application__c.Person_Number__c') + '",';
						} else {
							template +=                '"member_id": null,';
						}

						//template +=                '"gender": "' + app.TF4SF__Sub_Product__c + '",';
						if (String.isNotBlank(data.get('Application__c.Housing_Status_J2__c'))) {
							template +=                '"occupancy_status": "' + occStatusMap.get(data.get('Application__c.Housing_Status_J2__c')) + '",';
						} else if (String.isNotBlank(app.TF4SF__Housing_Status_J2__c)) {
							template +=                '"occupancy_status": "' + occStatusMap.get(app.TF4SF__Housing_Status_J2__c) + '",';
						} else {
							template +=                '"occupancy_status": null,';
						}

						template +=                '"occupancy_address": {';
						template +=                    '"address_lines": [';

						if (String.isNotBlank(data.get('Application__c.Street_Address_1_J2__c'))) {
							template +=                        '"' + data.get('Application__c.Street_Address_1_J2__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Street_Address_1_J2__c)) {
							template +=                        '"' + app.TF4SF__Street_Address_1_J2__c.toUpperCase() + '"';
						} else {
							template +=                        'null';
						}

						template +=                    '],';
						if (String.isNotBlank(data.get('Application__c.City_J2__c'))) {
							template +=                    '"township": "' + data.get('Application__c.City_J2__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__City_J2__c)) {
							template +=                    '"township": "' + app.TF4SF__City_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"township": null,';
						}

						if (String.isNotBlank(data.get('Application__c.State_J2__c'))) {
							template +=                    '"state_code": "' + data.get('Application__c.State_J2__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__State_J2__c)) {
							template +=                    '"state_code": "' + app.TF4SF__State_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"state_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Country_J2__c'))) {
							template +=                    '"country_code": "' + data.get('Application__c.Country_J2__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Country_J2__c)) {
							template +=                    '"country_code": "' + app.TF4SF__Country_J2__c.toUpperCase() + '",';
						} else {
							template +=                '"country_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Zip_Code_J2__c'))) {
							template +=                    '"zip_code": "' + data.get('Application__c.Zip_Code_J2__c') + '",';
						} else if (String.isNotBlank(app.TF4SF__Zip_Code_J2__c)) {
							template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_J2__c + '",';
						} else {
							template +=                '"zip_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Years_J2__c'))) {
							Integer mts = (Integer.ValueOf(data.get('Application__c.Years_J2__c'))*12) + Integer.ValueOf(data.get('Application__c.Months_J2__c'));
							template +=                    '"occupancy_duration_months": '+mts;
						} else if (app.TF4SF__Years_J2__c != null) {
							Integer m = (String.isNotBlank(app.TF4SF__Months_J2__c))?Integer.valueOf(app.TF4SF__Months_J2__c) : 0;
							Integer mts = (Integer.valueOf(app.TF4SF__Years_J2__c*12)) + m;
							template +=                    '"occupancy_duration_months": '+mts;
						} else {
							template +=                '"occupancy_duration_months": null';
						}

						template +=                '},';
						if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP2__c'))) {//previous address is null
							template +=                '"previous_occupancy_addresses": [';
							template +=                    '{';
							template +=                        '"address_lines": [';

							if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP2__c'))) {
								template +=                            '"' + data.get('Application__c.Street_Address_1_JP2__c').toUpperCase() + '"';
							} else if (String.isNotBlank(app.TF4SF__Street_Address_1_JP2__c)) {
								template +=                        '"' + app.TF4SF__Street_Address_1_JP2__c.toUpperCase() + '"';
							} else {
								template +=                        'null';
							}

							template +=                        '],';
							if (String.isNotBlank(data.get('Application__c.City_JP2__c'))) {
								template +=                        '"township": "' + data.get('Application__c.City_JP2__c').toUpperCase() + '",'; 
							} else if (String.isNotBlank(app.TF4SF__City_JP2__c)) {
								template +=                    '"township": "' + app.TF4SF__City_JP2__c.toUpperCase() + '",';
							} else {
								template +=                '"township": null,';
							}

							if (String.isNotBlank(data.get('Application__c.State_JP2__c'))) {
								template +=                        '"state_code": "' + data.get('Application__c.State_JP2__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__State_JP2__c)) {
								template +=                    '"state_code": "' + app.TF4SF__State_JP2__c.toUpperCase() + '",';
							} else {
								template +=                '"state_code": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Zip_Code_JP2__c'))) {
								template +=                        '"country_code": "' + data.get('Application__c.Country_JP2__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Country_JP2__c)) {
								template +=                    '"country_code": "' + app.TF4SF__Country_JP2__c.toUpperCase() + '",';
							} else {
								template +=                '"country_code": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Zip_Code_JP2__c'))) {
								template +=                        '"zip_code": "' + data.get('Application__c.Zip_Code_JP2__c') + '"'; 
							} else if (String.isNotBlank(app.TF4SF__Zip_Code_JP2__c)) {
								template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_JP2__c + '"';
							} else {
								template +=                '"zip_code": null';
							}

							template +=                    '}';
							template +=                '],';
						}//previous address is null
						if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1_J2__c'))) {//mailing address is null
							template +=                '"mailing_address": {';
							template +=                    '"address_lines": [';
							if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1_J2__c'))) {
								template +=                        '"' + data.get('Application__c.Mailing_Street_Address_1_J2__c').toUpperCase() + '"';
							} else if (String.isNotBlank(app.TF4SF__Mailing_Street_Address_1_J2__c)) {
								template +=                        '"' + app.TF4SF__Mailing_Street_Address_1_J2__c.toUpperCase() + '"';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist3__c')) && data.get('Application__c.Custom_Picklist3__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Street_Address_1_J2__c'))) {
				              template +=                        '"' + data.get('Application__c.Street_Address_1_J2__c').toUpperCase() + '"';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist3__c) && app.TF4SF__Custom_Picklist3__c == 'Yes' && String.isNotBlank(app.TF4SF__Street_Address_1_J2__c)) {
				              template +=                        '"' + app.TF4SF__Street_Address_1_J2__c.toUpperCase() + '"';
				            } else {
								template +=                        'null';
							}

							template +=                    '],';
							if (String.isNotBlank(data.get('Application__c.Mailing_City_J2__c'))) {
								template +=                    '"township": "' + data.get('Application__c.Mailing_City_J2__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Mailing_City_J2__c)) {
								template +=                    '"township": "' + app.TF4SF__Mailing_City_J2__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist3__c')) && data.get('Application__c.Custom_Picklist3__c') == 'Yes' && String.isNotBlank(data.get('Application__c.City_J2__c'))) {
				                template +=                    '"township": "' + data.get('Application__c.City_J2__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist3__c) && app.TF4SF__Custom_Picklist3__c == 'Yes' && String.isNotBlank(app.TF4SF__City_J2__c)) {
				                template +=                    '"township": "' + app.TF4SF__City_J2__c.toUpperCase() + '",';
				            } else {
								template +=                '"township": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_State_J2__c'))) {
								template +=                    '"state_code": "' + data.get('Application__c.Mailing_State_J2__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Mailing_State_J2__c)) {
								template +=                    '"state_code": "' + app.TF4SF__Mailing_State_J2__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist3__c')) && data.get('Application__c.Custom_Picklist3__c') == 'Yes' && String.isNotBlank(data.get('Application__c.State_J2__c'))) {
				                template +=                    '"state_code": "' + data.get('Application__c.State_J2__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist3__c) && app.TF4SF__Custom_Picklist3__c == 'Yes' && String.isNotBlank(app.TF4SF__State_J2__c)) {
				                template +=                    '"state_code": "' + app.TF4SF__State_J2__c.toUpperCase() + '",';
				            } else {
								template +=                '"state_code": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_Country_J2__c'))) {
								template +=                    '"country_code": "' + data.get('Application__c.Mailing_Country_J2__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Mailing_Country_J2__c)) {
								template +=                    '"country_code": "' + app.TF4SF__Mailing_Country_J2__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist3__c')) && data.get('Application__c.Custom_Picklist3__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Country_J2__c'))) {
				                template +=                    '"country_code": "' + data.get('Application__c.Country_J2__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist3__c) && app.TF4SF__Custom_Picklist3__c == 'Yes' && String.isNotBlank(app.TF4SF__Country_J2__c)) {
				                template +=                    '"country_code": "' + app.TF4SF__Country_J2__c.toUpperCase() + '",';
				            } else {
								template +=                '"country_code": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_Zip_Code_J2__c'))) {
								template +=                    '"zip_code": "' + data.get('Application__c.Mailing_Zip_Code_J2__c') + '"';
							} else if (String.isNotBlank(app.TF4SF__Mailing_Zip_Code_J2__c)) {
								template +=                    '"zip_code": "' + app.TF4SF__Mailing_Zip_Code_J2__c + '"';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist3__c')) && data.get('Application__c.Custom_Picklist3__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Zip_Code_J2__c'))) {
				                template +=                    '"zip_code": "' + data.get('Application__c.Zip_Code_J2__c').toUpperCase() + '"';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist3__c) && app.TF4SF__Custom_Picklist3__c == 'Yes' && String.isNotBlank(app.TF4SF__Zip_Code_J2__c)) {
				                template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_J2__c.toUpperCase() + '"';
				            } else {
								template +=                '"zip_code": null';
							}

							template +=                '},';
						}//mailing address is null

						if (String.isNotBlank(iden.TF4SF__Identity_Number_J2__c) || String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J2__c'))) {//Identification Documents is null
							template +=                '"identification_documents": [';
							template +=                    '{';

							if (String.isNotBlank(data.get('Identity_Information__c.ID_Type_J2__c'))) {
								template +=                        '"type": "' + idenDocMap.get(data.get('Identity_Information__c.ID_Type_J2__c')).toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__ID_Type_J2__c)) {
								template +=                        '"type": "' + idenDocMap.get(iden.TF4SF__ID_Type_J2__c).toUpperCase() + '",';
							} else {
								template +=                        '"type": "null",';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J2__c'))) {
								template +=                        '"id": "' + data.get('Identity_Information__c.Identity_Number_J2__c').toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__Identity_Number_J2__c)) {
								template +=                        '"id": "' + iden.TF4SF__Identity_Number_J2__c.toUpperCase() + '",';
							} else {
								template +=                        '"id": "null",';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.State_Issued_J2__c'))) {
								template +=                        '"state_code": "' + data.get('Identity_Information__c.State_Issued_J2__c').toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__State_Issued_J2__c)) {
								template +=                        '"state_code": "' + iden.TF4SF__State_Issued_J2__c.toUpperCase() + '",';
							} else {
								template +=                        '"state_code": null,';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Country_Issued_J2__c')) || String.isNotBlank(iden.TF4SF__Country_Issued_J2__c)) {
								if (String.isNotBlank(data.get('Identity_Information__c.ID_Type_J2__c')) && data.get('Identity_Information__c.ID_Type_J2__c').trim().equalsIgnoreCase('Passport')) {
									template +=                        '"country_code": "' + data.get('Identity_Information__c.Country_Issued_J2__c') + '",';
								} else if (String.isNotBlank(iden.TF4SF__Country_Issued_J2__c) && iden.TF4SF__Country_Issued_J2__c.trim().equalsIgnoreCase('Passport')) {
									template +=                        '"country_code": "' + iden.TF4SF__Country_Issued_J2__c + '",';
								} else {
									template +=                        '"country_code": null,';
								}
							} else {
								template +=                        '"country_code": null,';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Expiry_Date_J2__c'))) {
								List<String> dt = data.get('Identity_Information__c.Expiry_Date_J2__c').split('/');
								template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
							} else if (String.isNotBlank(iden.TF4SF__Expiry_Date_J2__c)) {
								List<String> dt = iden.TF4SF__Expiry_Date_J2__c.split('/');
								template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
							} else {
								template +=                        '"expiration_date": null,';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Issue_Date_J2__c'))) {
								List<String> dt = data.get('Identity_Information__c.Issue_Date_J2__c').split('/');
								template +=                        '"issue_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '"';
							} else if (String.isNotBlank(iden.TF4SF__Issue_Date_J2__c)) {
								List<String> dt = iden.TF4SF__Issue_Date_J2__c.split('/');
								template +=                        '"issue_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '"';
							} else {
								template +=                        '"issue_date": null';   
							}

							template +=                    '}';
							template +=                '],';
						}//Identification documents is null

						//questions for joint applicant2
						template +=                '"question_answers": [';
						if (app.TF4SF__Sub_Product__c.Contains('Checking') || app.TF4SF__Sub_Product__c.Contains('Saving') || app.TF4SF__Sub_Product__c.Contains('Certificate')) {
							//Applicant Question: Are you subject to backup withholding?
							if (String.isNotBlank(data.get('Application__c.Custom_Picklist10__c'))) {
								template +=                    '{';
								 template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": "' + data.get('Application__c.Custom_Picklist10__c').toUpperCase() + '"';
								template +=                    '}';
							} else if (String.isNotBlank(app.Custom_Picklist10__c)) {
								template +=                    '{';
								template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": "' + app.Custom_Picklist10__c.toUpperCase() + '"';
								template +=                    '}';
							} else {
								template +=                    '{';
								template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": null';
								template +=                    '}';
							}
						}

						template +=                  '],';
						template +=                '"financials": {';

						if (data.get('Employment_Information__c.Custom_Currency3__c') != null) {
							Decimal aInc = Decimal.valueOf(data.get('Employment_Information__c.Custom_Currency3__c'));
							template +=                    '"monthly_income": ' + aInc + ',';
						} else if (empInfo.TF4SF__Custom_Currency3__c != null) {
							Decimal aInc = empInfo.TF4SF__Custom_Currency3__c;
							template +=                    '"monthly_income": ' + aInc + ',';
						} else {
							template +=                    '"monthly_income": null,';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Years_EmpJ2__c'))) {
							Integer mon = (Integer.ValueOf(data.get('Employment_Information__c.Years_EmpJ2__c')) * 12) + Integer.ValueOf(data.get('Employment_Information__c.Months_EmpJ2__c'));
							template +=                    '"profession_duration_months": ' + mon + ',';
						} else if (empinfo.TF4SF__Years_EmpJ2__c != null) {
							Integer mon = Integer.ValueOf(empInfo.TF4SF__Years_EmpJ2__c * 12) + Integer.ValueOf(empInfo.TF4SF__Months_EmpJ2__c);
							template +=                    '"profession_duration_months": ' + mon + ',';
						} else {
							template +=                    '"profession_duration_months": null,';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J2__c'))) {
							template +=                    '"employment_status": "' + empMap.get(data.get('Employment_Information__c.Employment_Status_J2__c')) + '"';
						} else if (empInfo.TF4SF__Employment_Status_J2__c != null) {
							template +=                    '"employment_status": "' + empMap.get(empInfo.TF4SF__Employment_Status_J2__c) + '"';
						} else {
							template +=                    '"employment_status": "EM"';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J2__c')) || String.isNotBlank(empInfo.TF4SF__Occupation_J2__c) ||
							(String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J2__c')) && data.get('Employment_Information__c.Employment_Status_J2__c').contains('Military')) || 
							(String.isNotBlank(empinfo.TF4SF__Employment_Status_J2__c) && empinfo.TF4SF__Employment_Status_J2__c.contains('Military'))) {
							template +=                    ',"employment": [';
							template +=                        '{';

							if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J2__c'))) {
								template +=                            '"title": "' + data.get('Employment_Information__c.Occupation_J2__c').toUpperCase() + '",';
							} else if (String.isNotBlank(empinfo.TF4SF__Occupation_J2__c)) {
								template +=                            '"title": "' + empInfo.TF4SF__Occupation_J2__c.toUpperCase() + '",';
							} else {
								template +=                    '"title": null,';
							}

							if (String.isNotBlank(data.get('Employment_Information__c.Years_EmpJ2__c'))) {
								Integer mon = (Integer.ValueOf(data.get('Employment_Information__c.Years_EmpJ2__c')) * 12) + Integer.ValueOf(data.get('Employment_Information__c.Months_EmpJ2__c'));
								template +=                    '"duration_months": ' + mon + ',';
							} else if (empinfo.TF4SF__Years_EmpJ2__c != null) {
								Integer mon = Integer.ValueOf(empInfo.TF4SF__Years_EmpJ2__c * 12) + Integer.ValueOf(empInfo.TF4SF__Months_EmpJ2__c);
								template +=                    '"duration_months": ' + mon + ',';
							} else {
								template +=                    '"duration_months": null,';
							}

							if ((String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J2__c')) && data.get('Employment_Information__c.Employment_Status_J2__c').contains('Military')) || 
								(String.isNotBlank(empinfo.TF4SF__Employment_Status_J2__c) && empinfo.TF4SF__Employment_Status_J2__c.contains('Military'))) { 
								if (String.isNotBlank(data.get('Employment_Information__c.Custom_Picklist9__c'))) {
									template +=                            '"employer": "' + data.get('Employment_Information__c.Custom_Picklist9__c').toUpperCase() + '"';
								} else if (empinfo.TF4SF__Custom_Picklist9__c != null) {
									template +=                            '"employer": "' + empInfo.TF4SF__Custom_Picklist9__c.toUpperCase() + '"';
								} else {
									template +=                            '"employer": null';
								}
							} else {
								if (String.isNotBlank(data.get('Employment_Information__c.Employer_J2__c'))) {
									template +=                            '"employer": "' + data.get('Employment_Information__c.Employer_J2__c').toUpperCase() + '"';
								} else if (String.isNotBlank(empinfo.TF4SF__Employer_J2__c)) {
									template +=                            '"employer": "' + empInfo.TF4SF__Employer_J2__c.toUpperCase() + '"';
								} else {
									template +=                            '"employer": null';
								}
							}

							template +=                            '}';
							template +=                    ']';
						}

						template +=                '}';
						if (String.isNotBlank(data.get('Identity_Information__c.SSN_J3__c')) || String.isNotBlank(iden.TF4SF__SSN_J3__c)) {
							template +=            '},';
						} else {
							template += '}';
						}
					}//japp2 is not null ends

					 //applicant3 end aug6
					//japplicant4 start
					if (String.isNotBlank(data.get('Identity_Information__c.SSN_J3__c')) || String.isNotBlank(iden.TF4SF__SSN_J3__c)) {//japp3 is not null
						template +=            '{';
						if (String.isNotBlank(data.get('Application__c.First_Name_J3__c'))) {
							template +=                '"first_name": "' + data.get('Application__c.First_Name_J3__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__First_Name_J3__c)) {
							template +=                '"first_name": "' + app.TF4SF__First_Name_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"first_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Middle_Name_J3__c'))) {
							template +=                ',"middle_name": "' + data.get('Application__c.Middle_Name_J3__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Middle_Name_J3__c)) {
							template +=                '"middle_name": "' + app.TF4SF__Middle_Name_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"middle_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Last_Name_J3__c'))) {
							template +=                '"last_name": "' + data.get('Application__c.Last_Name_J3__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Last_Name_J3__c)) {
							template +=                '"last_name": "' + app.TF4SF__Last_Name_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"last_name": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Suffix_J3__c'))) {
							template +=                '"suffix": "' + data.get('Application__c.Suffix_J3__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Suffix_J3__c)) {
							template +=                '"suffix": "' + app.TF4SF__Suffix_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"suffix": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Custom_Picklist30__c'))) {
							template +=                '"applicant_type": "' + apptypemap.get(data.get('Application__c.Custom_Picklist30__c')) + '",';
						} else if (String.isNotBlank(app.Custom_Picklist30__c)) {
							template +=                '"applicant_type": "' + appTypeMap.get(app.Custom_Picklist30__c) + '",';
						} else {
							template +=                '"applicant_type": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.SSN_J3__c'))) {
							template +=                '"federal_id": "' + data.get('Identity_Information__c.SSN_J3__c') + '",';
						} else if (String.isNotBlank(iden.TF4SF__SSN_J3__c)) {
							template +=                '"federal_id": "' + iden.TF4SF__SSN_J3__c + '",';
						} else {
							template +=                '"federal_id": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Marital_Status_J3__c'))) {
							template +=                '"marital_status": "' + data.get('Application__c.Marital_Status_J3__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Marital_Status_J3__c)) {
							template +=                '"marital_status": "' + app.TF4SF__Marital_Status_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"marital_status": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Relationship_to_Primary_Applicant_J3__c'))) {
							template +=                '"relation_to_primary_applicant": "' + data.get('Application__c.Relationship_to_Primary_Applicant_J3__c').toUpperCase() + '",';
						} else if (app.TF4SF__Relationship_to_Primary_Applicant_J3__c != null) {
							template +=                '"relation_to_primary_applicant": "' + app.TF4SF__Relationship_to_Primary_Applicant_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"relation_to_primary_applicant": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Email_Address_J3__c'))) {
							template +=                '"email_address": "' + data.get('Application__c.Email_Address_J3__c').toUpperCase() + '",';
						} else {
							template +=                '"email_address": "' + app.TF4SF__Email_Address_J3__c.toUpperCase() + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Primary_Phone_Number_J3__c'))) {
							template +=                '"home_phone_number": "' + data.get('Application__c.Primary_Phone_Number_J3__c') + '",';
						} else if (app.TF4SF__Primary_Phone_Number_J3__c != null) {
							template +=                '"home_phone_number": "' + app.TF4SF__Primary_Phone_Number_J3__c + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Secondary_Phone_Number_JP3__c'))) {
							template +=                '"work_phone_number": "' + data.get('Application__c.Secondary_Phone_Number_JP3__c') + '",';
						} else if (app.TF4SF__Secondary_Phone_Number_JP3__c != null) {
							template +=                '"work_phone_number": "' + app.TF4SF__Secondary_Phone_Number_JP3__c + '",';
						}

						if (String.isNotBlank(data.get('Application__c.Tertiary_Phone_Number_J3__c'))) {
							template +=                '"mobile_phone_number": "' + data.get('Application__c.Tertiary_Phone_Number_J3__c') + '",';
						} else if (app.TF4SF__Tertiary_Phone_Number_J3__c != null) {
							template +=                '"mobile_phone_number": "' + app.TF4SF__Tertiary_Phone_Number_J3__c + '",';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Date_of_Birth_J3__c'))) {
							List<String> dob3 = data.get('Identity_Information__c.Date_of_Birth_J3__c').split('/');
							template +=                '"birth_date": "' + dob3[2] + '-' + dob3[1] + '-' + dob3[0] + '",';
						} else if (String.isNotBlank(iden.TF4SF__Date_of_Birth_J3__c)) {
							List<String> dob3 = iden.TF4SF__Date_of_Birth_J3__c.split('/');
							template +=                '"birth_date": "' + dob3[2] + '-' + dob3[1] + '-' + dob3[0] + '",';
						} else {
							template +=                '"birth_date": null,';
						}

						if (String.isNotBlank(data.get('Identity_Information__c.Citizenship_J3__c'))) {
							template +=                '"immigration_status": "' + immStatusMap.get(data.get('Identity_Information__c.Citizenship_J3__c')) + '",';
						} else if (String.isNotBlank(iden.TF4SF__Citizenship_J3__c)) {
							template +=                '"immigration_status": "' + immStatusMap.get(iden.TF4SF__Citizenship_J3__c) + '",';
						} else {
							template +=                '"immigration_status": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Member__c'))) {
							template +=                '"member": true,';
						} else {
							template +=                '"member": false,';
						}

						if (String.isNotBlank(data.get('Application__c.Person_Number__c'))) {
							template +=                '"member_id": "' + data.get('Application__c.Person_Number__c') + '",';
						} else {
							template +=                '"member_id": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Housing_Status_J3__c'))) {
							template +=                '"occupancy_status": "' + occStatusMap.get(data.get('Application__c.Housing_Status_J3__c')) + '",';
						} else if (String.isNotBlank(app.TF4SF__Housing_Status_J3__c)) {
							template +=                '"occupancy_status": "' + occStatusMap.get(app.TF4SF__Housing_Status_J3__c) + '",';
						} else {
							template +=                '"occupancy_status": null,';
						}

						template +=                '"occupancy_address": {';
						template +=                    '"address_lines": [';

						if (String.isNotBlank(data.get('Application__c.Street_Address_1_J3__c'))) {
							template +=                        '"' + data.get('Application__c.Street_Address_1_J3__c').toUpperCase() + '"';
						} else if (String.isNotBlank(app.TF4SF__Street_Address_1_J3__c)) {
							template +=                        '"' + app.TF4SF__Street_Address_1_J3__c.toUpperCase() + '"';
						} else {
							template +=                        'null';
						}

						template +=                    '],';
						if (String.isNotBlank(data.get('Application__c.City_J3__c'))) {
							template +=                    '"township": "' + data.get('Application__c.City_J3__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__City_J3__c)) {
							template +=                    '"township": "' + app.TF4SF__City_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"township": null,';
						}

						if (String.isNotBlank(data.get('Application__c.State_J3__c'))) {
							template +=                    '"state_code": "' + data.get('Application__c.State_J3__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__State_J3__c)) {
							template +=                    '"state_code": "' + app.TF4SF__State_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"state_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Country_J3__c'))) {
							template +=                    '"country_code": "' + data.get('Application__c.Country_J3__c').toUpperCase() + '",';
						} else if (String.isNotBlank(app.TF4SF__Country_J3__c)) {
							template +=                    '"country_code": "' + app.TF4SF__Country_J3__c.toUpperCase() + '",';
						} else {
							template +=                '"country_code": null,';
						}

						if (String.isNotblank(data.get('Application__c.Zip_Code_J3__c'))) {
							template +=                    '"zip_code": "' + data.get('Application__c.Zip_Code_J3__c') + '",';
						} else if (String.isNotBlank(app.TF4SF__Zip_Code_J3__c)) {
							template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_J3__c + '",';
						} else {
							template +=                '"zip_code": null,';
						}

						if (String.isNotBlank(data.get('Application__c.Years_J3__c'))) {
							Integer mts = (Integer.ValueOf(data.get('Application__c.Years_J3__c'))*12) + Integer.ValueOf(data.get('Application__c.Months_J3__c'));
							template +=                    '"occupancy_duration_months": '+mts;
						} else if (app.TF4SF__Years_J3__c != null) {
							Integer m = (String.isNotBlank(app.TF4SF__Months_J3__c))?Integer.valueOf(app.TF4SF__Months_J3__c) : 0;
							Integer mts = (Integer.valueOf(app.TF4SF__Years_J3__c*12)) + m;
							template +=                    '"occupancy_duration_months": '+mts;
						} else {
							template +=                '"occupancy_duration_months": null';
						}

						template +=                '},';
						if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP3__c'))) {//previous address is null
							template +=                '"previous_occupancy_addresses": [';
							template +=                    '{';
							template +=                        '"address_lines": [';

							if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP3__c'))) {
								template +=                            '"' + data.get('Application__c.Street_Address_1_JP3__c').toUpperCase() + '"';
							} else if (String.isNotBlank(app.TF4SF__Street_Address_1_JP3__c)) {
								template +=                        '"' + app.TF4SF__Street_Address_1_JP3__c.toUpperCase() + '"';
							} else {
								template +=                        'null';
							}

							template +=                        '],';
							if (String.isNotBlank(app.TF4SF__City_JP3__c)) {
								template +=                        '"township": "' + data.get('Application__c.City_JP3__c').toUpperCase() + '",'; 
							} else if (String.isNotBlank(app.TF4SF__City_JP3__c)) {
								template +=                    '"township": "' + app.TF4SF__City_JP3__c.toUpperCase() + '",';
							} else {
								template +=                '"township": null,';
							}

							if (String.isNotBlank(app.TF4SF__State_JP3__c)) {
								template +=                        '"state_code": "' + data.get('Application__c.State_JP3__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__State_JP3__c)) {
								template +=                    '"state_code": "' + app.TF4SF__State_JP3__c.toUpperCase() + '",';
							} else {
								template +=                '"state_code": null,';
							}

							if (String.isNotBlank(app.TF4SF__Zip_Code_JP3__c)) {
								template +=                        '"country_code": "' + data.get('Application__c.Country_JP3__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Country_JP3__c)) {
								template +=                    '"country_code": "' + app.TF4SF__Country_JP3__c.toUpperCase() + '",';
							} else {
								template +=                '"country_code": null,';
							}

							if (String.isNotBlank(app.TF4SF__Zip_Code_JP3__c)) {
								template +=                        '"zip_code": "' + data.get('Application__c.Zip_Code_JP3__c') + '"'; 
							} else if (String.isNotBlank(app.TF4SF__Zip_Code_JP3__c)) {
								template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_JP3__c + '"';
							} else {
								template +=                '"zip_code": null';
							}

							template +=                    '}';
							template +=                '],';
						}//previous address is null

						if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1_J3__c'))) {//mailing address is null
							template +=                '"mailing_address": {';
							template +=                    '"address_lines": [';

							if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1_J3__c'))) {
								template +=                            '"' + data.get('Application__c.Mailing_Street_Address_1_J3__c').toUpperCase() + '"';
							} else if (String.isNotBlank(app.TF4SF__Mailing_Street_Address_1_J3__c)) {
								template +=                        '"' + app.TF4SF__Mailing_Street_Address_1_J3__c.toUpperCase() + '"';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist4__c')) && data.get('Application__c.Custom_Picklist4__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Street_Address_1_J3__c'))) {
				                template +=                        '"' + data.get('Application__c.Street_Address_1_J3__c').toUpperCase() + '"';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist4__c) && app.TF4SF__Custom_Picklist4__c == 'Yes' && String.isNotBlank(app.TF4SF__Street_Address_1_J3__c)) {
				                template +=                        '"' + app.TF4SF__Street_Address_1_J3__c.toUpperCase() + '"';
				            } else {
								template +=                        'null';
							}

							template +=                    '],';
							if (String.isNotBlank(data.get('Application__c.Mailing_City_J3__c'))) {
								template +=                    '"township": "' + data.get('Application__c.Mailing_City_J3__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Mailing_City_J3__c)) {
								template +=                    '"township": "' + app.TF4SF__Mailing_City_J3__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist4__c')) && data.get('Application__c.Custom_Picklist4__c') == 'Yes' && String.isNotBlank(data.get('Application__c.City_J3__c'))) {
				                template +=                    '"township": "' + data.get('Application__c.City_J3__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist4__c) && app.TF4SF__Custom_Picklist4__c == 'Yes' && String.isNotBlank(app.TF4SF__City_J3__c)) {
				                template +=                    '"township": "' + app.TF4SF__City_J3__c.toUpperCase() + '",';
				            } else {
								template +=                '"township": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_State_J3__c'))) {
								template +=                    '"state_code": "' + data.get('Application__c.Mailing_State_J3__c').toUpperCase() + '",';
							} else if (String.isNotBlank(app.TF4SF__Mailing_State_J3__c)) {
								template +=                    '"state_code": "' + app.TF4SF__Mailing_State_J3__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist4__c')) && data.get('Application__c.Custom_Picklist4__c') == 'Yes' && String.isNotBlank(data.get('Application__c.State_J3__c'))) {
				                template +=                    '"state_code": "' + data.get('Application__c.State_J3__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist4__c) && app.TF4SF__Custom_Picklist4__c == 'Yes' && String.isNotBlank(app.TF4SF__State_J3__c)) {
				                template +=                    '"state_code": "' + app.TF4SF__State_J3__c.toUpperCase() + '",';
				            } else {
								template +=                '"state_code": null,';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_Country_J3__c'))) {
								template +=                    '"country_code": "' + data.get('Application__c.Mailing_Country_J3__c').toUpperCase() + '",';
							} /*else if (String.isNotBlank(app.TF4SF__Mailing_Country_J3__c)) {
								template +=                    '"country_code": "' + app.TF4SF__Mailing_Country_J3__c.toUpperCase() + '",';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist4__c')) && data.get('Application__c.Custom_Picklist4__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Country_J3__c'))) {
				                template +=                    '"country_code": "' + data.get('Application__c.Country_J3__c').toUpperCase() + '",';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist4__c) && app.TF4SF__Custom_Picklist4__c == 'Yes' && String.isNotBlank(app.TF4SF__Country_J3__c)) {
				                template +=                    '"country_code": "' + app.TF4SF__Country_J3__c.toUpperCase() + '",';
				            }*/ else {
								template +=                '"country_code": "USA",';
							}

							if (String.isNotBlank(data.get('Application__c.Mailing_Zip_Code_J3__c'))) {
								template +=                    '"zip_code": "' + data.get('Application__c.Mailing_Zip_Code_J3__c') + '"';
							} else if (String.isNotBlank(app.TF4SF__Mailing_Zip_Code_J3__c)) {
								template +=                    '"zip_code": "' + app.TF4SF__Mailing_Zip_Code_J3__c + '"';
							} else if (String.isNotBlank(data.get('Application__c.Custom_Picklist4__c')) && data.get('Application__c.Custom_Picklist4__c') == 'Yes' && String.isNotBlank(data.get('Application__c.Zip_Code_J3__c'))) {
				                template +=                    '"zip_code": "' + data.get('Application__c.Zip_Code_J3__c').toUpperCase() + '"';
				            } else if (String.isNotBlank(app.TF4SF__Custom_Picklist4__c) && app.TF4SF__Custom_Picklist4__c == 'Yes' && String.isNotBlank(app.TF4SF__Zip_Code_J3__c)) {
				                template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_J3__c.toUpperCase() + '"';
				            } else {
								template +=                '"zip_code": null';
							}

							template +=                '},';
						}//mailing address is null

						if (String.isNotBlank(iden.TF4SF__Identity_Number_J3__c) || String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J3__c'))) {//Identification Documents is null
							template +=                '"identification_documents": [';
							template +=                    '{';

							if (String.isNotBlank(data.get('Identity_Information__c.ID_Type_J3__c'))) {
								template +=                        '"type": "' + idenDocMap.get(data.get('Identity_Information__c.ID_Type_J3__c')).toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__ID_Type_J3__c)) {
								template +=                        '"type": "' + idenDocMap.get(iden.TF4SF__ID_Type_J3__c).toUpperCase() + '",';
							} else {
								template +=                        '"type": "null",';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J3__c'))) {
								template +=                        '"id": "' + data.get('Identity_Information__c.Identity_Number_J3__c').toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__Identity_Number_J3__c)) {
								template +=                        '"id": "' + iden.TF4SF__Identity_Number_J3__c.toUpperCase() + '",';
							} else {
								template +=                        '"id": "null",';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.State_Issued_J3__c'))) {
								template +=                        '"state_code": "' + data.get('Identity_Information__c.State_Issued_J3__c').toUpperCase() + '",';
							} else if (String.isNotBlank(iden.TF4SF__State_Issued_J3__c)) {
								template +=                        '"state_code": "' + iden.TF4SF__State_Issued_J3__c.toUpperCase() + '",';
							} else {
								template +=                        '"state_code": null,';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Country_Issued_J3__c')) || String.isNotBlank(iden.TF4SF__Country_Issued_J3__c)) {
								if (String.isNotBlank(data.get('Identity_Information__c.ID_Type_J3__c')) && data.get('Identity_Information__c.ID_Type_J3__c').trim().equalsIgnoreCase('Passport')) {
									template +=                        '"country_code": "' + data.get('Identity_Information__c.Country_Issued_J3__c') + '",';
								} else if (String.isNotBlank(iden.TF4SF__Country_Issued_J3__c) && iden.TF4SF__Country_Issued_J3__c.trim().equalsIgnoreCase('Passport')) {
									template +=                        '"country_code": "' + iden.TF4SF__Country_Issued_J3__c + '",';
								} else {
									template +=                        '"country_code": null,';
								}
							} else {
								template +=                        '"country_code": null,';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Expiry_Date_J3__c'))) {
								List<String> dt = data.get('Identity_Information__c.Expiry_Date_J3__c').split('/');
								template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
							} else if (String.isNotBlank(iden.TF4SF__Expiry_Date_J3__c)) {
								List<String> dt = iden.TF4SF__Expiry_Date_J3__c.split('/');
								template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
							} else {
								template +=                        '"expiration_date": "null",';
							}

							if (String.isNotBlank(data.get('Identity_Information__c.Issue_Date_J3__c'))) {
								List<String> dt = data.get('Identity_Information__c.Issue_Date_J3__c').split('/');
								template +=                        '"issue_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '"';
							} else if (String.isNotBlank(iden.TF4SF__Issue_Date_J3__c)) {
								List<String> dt = iden.TF4SF__Issue_Date_J3__c.split('/');
								template +=                        '"issue_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '"';
							} else {
								template +=                        '"issue_date": "null",';
							}

							template +=                    '}';
							template +=                '],';
						}//Identification Documents is null

						//questions for joint applicant2
						template +=                '"question_answers": [';
						if (app.TF4SF__Sub_Product__c.Contains('Checking') || app.TF4SF__Sub_Product__c.Contains('Saving') || app.TF4SF__Sub_Product__c.Contains('Certificate')) {
							//Applicant Question: Are you subject to backup withholding?
							if (String.isNotBlank(data.get('Application__c.Custom_Picklist12__c'))) {
								template +=                    '{';
								 template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": "' + data.get('Application__c.Custom_Picklist12__c').toUpperCase() + '"';
								template +=                    '}';
							} else if (String.isNotBlank(app.Custom_Picklist12__c)) {
								template +=                    '{';
								template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": "' + app.Custom_Picklist12__c.toUpperCase() + '"';
								template +=                    '}';
							} else {
								template +=                    '{';
								template +=                        '"question_name": "Withholding",';
								template +=                        '"answer": null';
								template +=                    '}';
							}
						}

						template +=                  '],';
						template +=                '"financials": {';

						if (data.get('Employment_Information__c.Custom_Currency4__c') != null) {
							Decimal aInc = Decimal.valueOf(data.get('Employment_Information__c.Custom_Currency4__c'));
							template +=                    '"monthly_income": ' + aInc + ',';
						} else if (empInfo.TF4SF__Custom_Currency4__c != null) {
							Decimal aInc = empInfo.TF4SF__Custom_Currency4__c;
							template +=                    '"monthly_income": ' + aInc + ',';
						} else {
							template +=                    '"monthly_income": null,';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Years_EmpJ3__c'))) {
							Integer mon = (Integer.ValueOf(data.get('Employment_Information__c.Years_EmpJ3__c')) * 12) + Integer.ValueOf(data.get('Employment_Information__c.Months_EmpJ3__c'));
							template +=                    '"profession_duration_months": ' + mon + ',';
						} else if (empinfo.TF4SF__Years_EmpJ3__c != null) {
							Integer mon = Integer.ValueOf(empInfo.TF4SF__Years_EmpJ3__c * 12) + Integer.ValueOf(empInfo.TF4SF__Months_EmpJ3__c);
							template +=                    '"profession_duration_months": ' + mon + ',';
						} else {
							template +=                    '"profession_duration_months": null,';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J3__c'))) {
							template +=                    '"employment_status": "' + empMap.get(data.get('Employment_Information__c.Employment_Status_J3__c')).toUpperCase() + '"';
						} else if (empInfo.TF4SF__Employment_Status_J3__c != null) {
							template +=                    '"employment_status": "' + empMap.get(empInfo.TF4SF__Employment_Status_J3__c) + '"';
						} else {
							template +=                    '"employment_status": "EM"';
						}

						if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J3__c')) || String.isNotBlank(empInfo.TF4SF__Occupation_J3__c) || 
							(String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J3__c')) && data.get('Employment_Information__c.Employment_Status_J3__c').contains('Military')) || 
							(String.isNotBlank(empinfo.TF4SF__Employment_Status_J3__c) && empinfo.TF4SF__Employment_Status_J3__c.contains('Military'))) {
							template +=                    ',"employment": [';
							template +=                        '{';

							if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J3__c'))) {
								template +=                            '"title": "' + data.get('Employment_Information__c.Occupation_J3__c').toUpperCase() + '",';
							} else if (String.isNotBlank(empinfo.TF4SF__Occupation_J3__c)) {
								template +=                            '"title": "' + empInfo.TF4SF__Occupation_J3__c.toUpperCase() + '",';
							} else {
								template +=                            '"title": null,';
							}

							if (String.isNotBlank(data.get('Employment_Information__c.Years_EmpJ3__c'))) {
								Integer mon = (Integer.ValueOf(data.get('Employment_Information__c.Years_EmpJ3__c')) * 12) + Integer.ValueOf(data.get('Employment_Information__c.Months_EmpJ3__c'));
								template +=                    '"duration_months": ' + mon + ',';
							} else if (empinfo.TF4SF__Years_EmpJ3__c != null) {
								Integer mon = Integer.ValueOf(empInfo.TF4SF__Years_EmpJ3__c * 12) + Integer.ValueOf(empInfo.TF4SF__Months_EmpJ3__c);
								template +=                    '"duration_months": ' + mon + ',';
							} else {
								template +=                    '"duration_months": null,';
							}

							if ((String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J3__c')) && data.get('Employment_Information__c.Employment_Status_J3__c').contains('Military')) || 
								(String.isNotBlank(empinfo.TF4SF__Employment_Status_J3__c) && empinfo.TF4SF__Employment_Status_J3__c.contains('Military'))) { 
								if (String.isNotBlank(data.get('Employment_Information__c.Custom_Picklist10__c'))) {
									template +=                            '"employer": "' + data.get('Employment_Information__c.Custom_Picklist10__c').toUpperCase() + '"';
								} else if (empinfo.TF4SF__Custom_Picklist10__c != null) {
									template +=                            '"employer": "' + empInfo.TF4SF__Custom_Picklist10__c.toUpperCase() + '"';
								} else {
									template +=                            '"employer": null';
								}
							} else {
								if (String.isNotBlank(data.get('Employment_Information__c.Employer_J3__c'))) {
									template +=                            '"employer": "' + data.get('Employment_Information__c.Employer_J3__c').toUpperCase() + '"';
								} else if (String.isNotBlank(empinfo.TF4SF__Employer_J3__c)) {
									template +=                            '"employer": "' + empInfo.TF4SF__Employer_J3__c.toUpperCase() + '"';
								} else {
									template +=                            '"employer": null';
								}
							}

							template +=                            '}';
							template +=                    ']';
						}

						template +=            '}';
						//japplicant4 end
						//j2applicant start
						template +=            '}';
					}//japp3 is not null

					//j3applicant end
					template +=        ']';
					if (prd.contains('Checking') || prd.contains('Saving') || prd.contains('Certificates')) {
						template +=        ',"beneficiaries": [';
						template +=             '{';

						if (String.isNotBlank(data.get('About_Account__c.Custom_Text1__c'))) {
							template +=                 '"first_name": "'+data.get('About_Account__c.Custom_Text1__c')+'",';
						} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text1__c)) {
							template +=                 '"first_name": "'+abtAcc.TF4SF__Custom_Text1__c+'",';
						} else {
							template +=                 '"first_name": null,';
						}

						//template +=                   '"middle_name": "'+data.get('About_Account__c.Custom_Text1__c')+'",';
						if (String.isNotBlank(data.get('About_Account__c.Custom_Text2__c'))) {
							template +=                 '"last_name": "'+data.get('About_Account__c.Custom_Text2__c')+'",';
						} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text2__c)) {
							template +=                 '"last_name": "'+abtAcc.TF4SF__Custom_Text2__c+'",';
						} else {
							template +=                 '"last_name": null,';
						}

						if (String.isNotBlank(data.get('About_Account__c.Custom_Encrypted_Text1__c'))) {
							template +=                 '"federal_id": "'+data.get('About_Account__c.Custom_Encrypted_Text1__c')+'",';
						} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Encrypted_Text1__c)) {
							template +=                 '"federal_id": "'+abtAcc.TF4SF__Custom_Encrypted_Text1__c+'",';
						} else {
							template +=                 '"federal_id": null,';
						}

						if (String.isNotBlank(data.get('About_Account__c.Custom_Text24__c')) || String.isNotBlank(abtAcc.Custom_Text24__c)) {//previous address is null
							template +=                '"address": ';
							template +=                    '{';
							template +=                        '"address_lines": [';

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text24__c'))) {
								template +=                            '"' + data.get('About_Account__c.Custom_Text24__c').toUpperCase() + '"';
							} else if (String.isNotBlank(abtAcc.Custom_Text24__c)) {
								template +=                        '"' + abtAcc.Custom_Text24__c.toUpperCase() + '"';
							} else {
								template +=                        'null';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text25__c'))) {
								template +=                            ',"' + data.get('About_Account__c.Custom_Text25__c').toUpperCase() + '"';
							} else if (String.isNotBlank(abtAcc.Custom_Text25__c)) {
								template +=                        ',"' + abtAcc.Custom_Text25__c.toUpperCase() + '"';
							}

							template +=                        '],';
							if (String.isNotBlank(data.get('About_Account__c.Custom_Text26__c'))) {
								template +=                        '"township": "' + data.get('About_Account__c.Custom_Text26__c').toUpperCase() + '",'; 
							} else if (String.isNotBlank(abtAcc.Custom_Text26__c)) {
								template +=                    '"township": "' + abtAcc.Custom_Text26__c.toUpperCase() + '",';
							} else {
								template +=                '"township": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Picklist7__c'))) {
								template +=                        '"state_code": "' + data.get('About_Account__c.Custom_Picklist7__c').toUpperCase() + '",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Picklist7__c)) {
								template +=                    '"state_code": "' + abtAcc.TF4SF__Custom_Picklist7__c.toUpperCase() + '",';
							} else {
								template +=                '"state_code": null,';
							}

							template +=                '"country_code": "USA",';
							if (String.isNotBlank(data.get('About_Account__c.Custom_Text27__c'))) {
								template +=                        '"zip_code": "' + data.get('About_Account__c.Custom_Text27__c') + '"'; 
							} else if (String.isNotBlank(abtAcc.Custom_Text27__c)) {
								template +=                    '"zip_code": "' + abtAcc.Custom_Text27__c + '"';
							} else {
								template +=                '"zip_code": null';
							}

							template +=                    '},';
						}

						if (String.isNotBlank(data.get('About_Account__c.Custom_Text4__c'))) {
							template +=                 '"share_percent": '+data.get('About_Account__c.Custom_Text4__c');
						} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text4__c)) {
							template +=                    '"share_percent": ' + abtAcc.TF4SF__Custom_Text4__c;
						} else {
							template +=                '"share_percent": null';
						}

						template +=            '}';
						if (String.isNotBlank(data.get('About_Account__c.Custom_Text5__c')) || String.isNotBlank(abtAcc.TF4SF__Custom_Text5__c)) {
							template +=             ',{';
							if (String.isNotBlank(data.get('About_Account__c.Custom_Text5__c'))) {
								template +=                 '"first_name": "'+data.get('About_Account__c.Custom_Text5__c')+'",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text1__c)) {
								template +=                 '"first_name": "'+abtAcc.TF4SF__Custom_Text5__c+'",';
							} else {
								template +=                 '"first_name": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text6__c'))) {
								template +=                 '"last_name": "'+data.get('About_Account__c.Custom_Text6__c')+'",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text6__c)) {
								template +=                 '"last_name": "'+abtAcc.TF4SF__Custom_Text6__c+'",';
							} else {
								template +=                 '"last_name": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Encrypted_Text2__c'))) {
								template +=                 '"federal_id": "'+data.get('About_Account__c.Custom_Encrypted_Text2__c')+'",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Encrypted_Text2__c)) {
								template +=                 '"federal_id": "'+abtAcc.TF4SF__Custom_Encrypted_Text2__c+'",';
							} else {
								template +=                 '"federal_id": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text28__c'))) {//previous address is null
								template +=                '"address": ';
								template +=                    '{';
								template +=                        '"address_lines": [';

								if (String.isNotBlank(data.get('About_Account__c.Custom_Text28__c')) || String.isNotBlank(abtAcc.Custom_Text28__c)) {
									template +=                            '"' + data.get('About_Account__c.Custom_Text28__c').toUpperCase() + '"';
								} else if (String.isNotBlank(abtAcc.Custom_Text28__c)) {
									template +=                        '"' + abtAcc.Custom_Text28__c.toUpperCase() + '"';
								} else {
									template +=                        'null';
								}

								if (String.isNotBlank(data.get('About_Account__c.Custom_Text31__c'))) {
									template +=                            ',"' + data.get('About_Account__c.Custom_Text31__c').toUpperCase() + '"';
								} else if (String.isNotBlank(abtAcc.Custom_Text31__c)) {
									template +=                        ',"' + abtAcc.Custom_Text31__c.toUpperCase() + '"';
								}

								template +=                        '],';
								if (String.isNotBlank(data.get('About_Account__c.Custom_Text37__c'))) {
									template +=                        '"township": "' + data.get('About_Account__c.Custom_Text37__c').toUpperCase() + '",'; 
								} else if (String.isNotBlank(abtAcc.Custom_Text37__c)) {
									template +=                    '"township": "' + abtAcc.Custom_Text37__c.toUpperCase() + '",';
								} else {
									template +=                '"township": null,';
								}

								if (String.isNotBlank(data.get('About_Account__c.Custom_Picklist8__c'))) {
									template +=                        '"state_code": "' + data.get('About_Account__c.Custom_Picklist8__c').toUpperCase() + '",';
								} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Picklist8__c)) {
									template +=                    '"state_code": "' + abtAcc.TF4SF__Custom_Picklist8__c.toUpperCase() + '",';
								} else {
									template +=                '"state_code": null,';
								}

								template +=                '"country_code": "USA",';
								if (String.isNotBlank(data.get('About_Account__c.Custom_Text34__c'))) {
									template +=                        '"zip_code": "' + data.get('About_Account__c.Custom_Text34__c') + '"'; 
								} else if (String.isNotBlank(abtAcc.Custom_Text34__c)) {
									template +=                    '"zip_code": "' + abtAcc.Custom_Text34__c + '"';
								} else {
									template +=                '"zip_code": null';
								}

								template +=                    '},';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text4__c'))) {
								template +=                 '"share_percent": '+data.get('About_Account__c.Custom_Text4__c');
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text4__c)) {
								template +=                    '"share_percent": ' + abtAcc.TF4SF__Custom_Text4__c;
							} else {
								template +=                '"share_percent": null';
							}

							template +=            '}';
						}

						if (String.isNotBlank(data.get('About_Account__c.Custom_Text9__c')) || String.isNotBlank(abtAcc.TF4SF__Custom_Text9__c)) {
							template +=             ',{';
							if (String.isNotBlank(data.get('About_Account__c.Custom_Text9__c'))) {
								template +=                 '"first_name": "'+data.get('About_Account__c.Custom_Text9__c')+'",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text9__c)) {
								template +=                 '"first_name": "'+abtAcc.TF4SF__Custom_Text9__c+'",';
							} else {
								template +=                 '"first_name": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text10__c'))) {
								template +=                 '"last_name": "'+data.get('About_Account__c.Custom_Text10__c')+'",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text10__c)) {
								template +=                 '"last_name": "'+abtAcc.TF4SF__Custom_Text10__c+'",';
							} else {
								template +=                 '"last_name": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Encrypted_Text3__c'))) {
								template +=                 '"federal_id": "'+data.get('About_Account__c.Custom_Encrypted_Text3__c')+'",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Encrypted_Text3__c)) {
								template +=                 '"federal_id": "'+abtAcc.TF4SF__Custom_Encrypted_Text3__c+'",';
							} else {
								template +=                 '"federal_id": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text29__c')) || String.isNotBlank(abtAcc.Custom_Text29__c)) {//previous address is null
								template +=                '"address": ';
								template +=                    '{';
								template +=                        '"address_lines": [';

								if (String.isNotBlank(data.get('About_Account__c.Custom_Text29__c'))) {
									template +=                            '"' + data.get('About_Account__c.Custom_Text29__c').toUpperCase() + '"';
								} else if (String.isNotBlank(abtAcc.Custom_Text29__c)) {
									template +=                        '"' + abtAcc.Custom_Text29__c.toUpperCase() + '"';
								} else {
									template +=                        'null';
								}

								if (String.isNotBlank(data.get('About_Account__c.Custom_Text32__c'))) {
									template +=                            ',"' + data.get('About_Account__c.Custom_Text32__c').toUpperCase() + '"';
								} else if (String.isNotBlank(abtAcc.Custom_Text32__c)) {
									template +=                        ',"' + abtAcc.Custom_Text32__c.toUpperCase() + '"';
								}

								template +=                        '],';
								if (String.isNotBlank(data.get('About_Account__c.Custom_Text38__c'))) {
									template +=                        '"township": "' + data.get('About_Account__c.Custom_Text38__c').toUpperCase() + '",'; 
								} else if (String.isNotBlank(abtAcc.Custom_Text38__c)) {
									template +=                    '"township": "' + abtAcc.Custom_Text38__c.toUpperCase() + '",';
								} else {
									template +=                '"township": null,';
								}

								if (String.isNotBlank(data.get('About_Account__c.Custom_Picklist9__c'))) {
									template +=                        '"state_code": "' + data.get('About_Account__c.Custom_Picklist9__c').toUpperCase() + '",';
								} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Picklist9__c)) {
									template +=                    '"state_code": "' + abtAcc.TF4SF__Custom_Picklist9__c.toUpperCase() + '",';
								} else {
									template +=                '"state_code": null,';
								}

								template +=                '"country_code": "USA",';
								if (String.isNotBlank(data.get('About_Account__c.Custom_Text35__c'))) {
									template +=                        '"zip_code": "' + data.get('About_Account__c.Custom_Text35__c') + '"'; 
								} else if (String.isNotBlank(abtAcc.Custom_Text35__c)) {
									template +=                    '"zip_code": "' + abtAcc.Custom_Text35__c + '"';
								} else {
									template +=                '"zip_code": null';
								}

								template +=                    '},';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text12__c'))) {
								template +=                 '"share_percent": '+data.get('About_Account__c.Custom_Text12__c');
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text12__c)) {
								template +=                    '"share_percent": ' + abtAcc.TF4SF__Custom_Text12__c;
							} else {
								template +=                '"share_percent": null';
							}

							template +=            '}';
						}

						if (String.isNotBlank(data.get('About_Account__c.Custom_Text13__c')) || String.isNotBlank(abtAcc.TF4SF__Custom_Text13__c)) {
							template +=             ',{';
							if (String.isNotBlank(data.get('About_Account__c.Custom_Text13__c'))) {
								template +=                 '"first_name": "'+data.get('About_Account__c.Custom_Text13__c')+'",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text13__c)) {
								template +=                 '"first_name": "'+abtAcc.TF4SF__Custom_Text13__c+'",';
							} else {
								template +=                 '"first_name": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text14__c'))) {
								template +=                 '"last_name": "'+data.get('About_Account__c.Custom_Text14__c')+'",';
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text14__c)) {
								template +=                 '"last_name": "'+abtAcc.TF4SF__Custom_Text14__c+'",';
							} else {
								template +=                 '"last_name": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Encrypted_Text4__c'))) {
								template +=                 '"federal_id": "'+data.get('About_Account__c.Custom_Encrypted_Text4__c')+'",';
							} else if (String.isNotBlank(abtAcc.Custom_Encrypted_Text4__c)) {
								template +=                 '"federal_id": "'+abtAcc.Custom_Encrypted_Text4__c+'",';
							} else {
								template +=                 '"federal_id": null,';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text30__c')) || String.isNotBlank(abtAcc.Custom_Text30__c)) {//previous address is null
								template +=                '"address": ';
								template +=                    '{';
								template +=                        '"address_lines": [';

								if (String.isNotBlank(data.get('About_Account__c.Custom_Text30__c'))) {
									template +=                            '"' + data.get('About_Account__c.Custom_Text30__c').toUpperCase() + '"';
								} else if (String.isNotBlank(abtAcc.Custom_Text30__c)) {
									template +=                        '"' + abtAcc.Custom_Text30__c.toUpperCase() + '"';
								} else {
									template +=                        'null';
								}

								if (String.isNotBlank(data.get('About_Account__c.Custom_Text33__c'))) {
									template +=                            ',"' + data.get('About_Account__c.Custom_Text33__c').toUpperCase() + '"';
								} else if (String.isNotBlank(abtAcc.Custom_Text33__c)) {
									template +=                        ',"' + abtAcc.Custom_Text33__c.toUpperCase() + '"';
								}

								template +=                        '],';
								if (String.isNotBlank(data.get('About_Account__c.Custom_Text39__c'))) {
									template +=                        '"township": "' + data.get('About_Account__c.Custom_Text39__c').toUpperCase() + '",'; 
								} else if (String.isNotBlank(abtAcc.Custom_Text39__c)) {
									template +=                    '"township": "' + abtAcc.Custom_Text39__c.toUpperCase() + '",';
								} else {
									template +=                '"township": null,';
								}

								if (String.isNotBlank(data.get('About_Account__c.Custom_Picklist10__c'))) {
									template +=                        '"state_code": "' + data.get('About_Account__c.Custom_Picklist10__c').toUpperCase() + '",';
								} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Picklist10__c)) {
									template +=                    '"state_code": "' + abtAcc.TF4SF__Custom_Picklist10__c.toUpperCase() + '",';
								} else {
									template +=                '"state_code": null,';
								}

								template +=                '"country_code": "USA",';
								if (String.isNotBlank(data.get('About_Account__c.Custom_Text36__c'))) {
									template +=                        '"zip_code": "' + data.get('About_Account__c.Custom_Text36__c') + '"'; 
								} else if (String.isNotBlank(abtAcc.Custom_Text36__c)) {
									template +=                    '"zip_code": "' + abtAcc.Custom_Text36__c + '"';
								} else {
									template +=                '"zip_code": null';
								}

								template +=                    '},';
							}

							if (String.isNotBlank(data.get('About_Account__c.Custom_Text16__c'))) {
								template +=                 '"share_percent": '+data.get('About_Account__c.Custom_Text16__c');
							} else if (String.isNotBlank(abtAcc.TF4SF__Custom_Text16__c)) {
								template +=                    '"share_percent": ' + abtAcc.TF4SF__Custom_Text16__c;
							} else {
								template +=                '"share_percent": null';
							}

							template +=            '}';
						}

						template +=         ']';
						//template +=        ',"funding": {';
						System.debug('template before fundingInfo method call ::::::: ' + template);
						System.debug('prd before fundingInfo method call ::::::: ' + prd);
						SubmitToCoreHelperForFundingInfo stchf = new SubmitToCoreHelperForFundingInfo();
						template += stchf.buildFundingInfoJSONRequest(prd, data, app, iden, abtAcc, empInfo);
						System.debug('template after fundingInfo method call ::::::: ' + template);                     
					}

					//if (prd.contains('Vehicle Loans') && String.isNotBlank(data.get('About_Account__c.Custom_Picklist11__c'))) {
					if (prd.contains('Vehicle Loans')) {
						template += ',"purchases": [';
						template +=   '{';
						template +=     '"type": "VEHICLE"';

						if (String.isNotBlank(data.get('About_Account__c.Custom_Picklist11__c'))) {
							template +=     ',"vehicle_type": "' + data.get('About_Account__c.Custom_Picklist11__c').toUpperCase() + '"';
						} else if (String.isNotBlank(abtAcc.Custom_Picklist11__c)) {
							template +=     ',"vehicle_type": "' + abtAcc.Custom_Picklist11__c.toUpperCase() + '"';
						} else {
							template +=     ',"vehicle_type": "CAR"';
						}

						if (String.isNotBlank(data.get('About_Account__c.VehicleMake__c'))) {
							template +=     ',"vehicle_make": "' + data.get('About_Account__c.VehicleMake__c').toUpperCase() + '"';
						} else if (String.isNotBlank(abtAcc.TF4SF__VehicleMake__c)) {
							template +=     ',"vehicle_make": "' + abtAcc.TF4SF__VehicleMake__c.toUpperCase() + '"';
						} else {
							template +=     ',"vehicle_make": null';
						}

						if (String.isNotBlank(data.get('About_Account__c.Non_Auto_Vehicle_Model__c'))) {
							template +=     ',"vehicle_model": "' + data.get('About_Account__c.Non_Auto_Vehicle_Model__c').toUpperCase() + '"';
						} else if (String.isNotBlank(abtAcc.TF4SF__Non_Auto_Vehicle_Model__c)) {
							template +=     ',"vehicle_model": "' + abtAcc.TF4SF__Non_Auto_Vehicle_Model__c.toUpperCase() + '"';
						} else {
							template +=     ',"vehicle_model": null';
						}

						if (String.isNotBlank(data.get('About_Account__c.Non_Auto_Vehicle_Year__c'))) {
							template +=     ',"vehicle_year": "' + data.get('About_Account__c.Non_Auto_Vehicle_Year__c').toUpperCase() + '"';
						} else if (String.isNotBlank(abtAcc.TF4SF__Non_Auto_Vehicle_Year__c)) {
							template +=     ',"vehicle_year": "' + abtAcc.TF4SF__Non_Auto_Vehicle_Year__c.toUpperCase() + '"';
						} else {
							template +=     ',"vehicle_year": null';
						}

						template +=   '}';
						template += ']';
					}

					if (String.isNotBlank(data.get('Application__c.Promo_Code__c'))) {
						template +=            ',"promo_code": "' + data.get('Application__c.Promo_Code__c').toUpperCase() + '"';
					} else if (String.isNotBlank(app.TF4SF__Promo_Code__c)) {
						template +=            ',"promo_code": "' + app.TF4SF__Promo_Code__c.toUpperCase() + '"';
					}

					template +=    '}';
					if (i < prodMap.size()-1) { template += ','; }
					i++;
				}

				template +=']';
			
			} catch (Exception e) {
				System.debug('Exception occured in SubmitToCoreHelper class with error :::::::: ' + e.getMessage() + ' &&&& at Line ####### ' + e.getLineNumber());
			}
		}
		
		System.debug('template befoer method return::::' + template);
		
		return template;
	}
}