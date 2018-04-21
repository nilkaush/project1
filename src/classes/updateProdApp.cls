global class updateProdApp {
	public static String JSONGenerator(String applicationId) {
		TF4SF__Application__c app;
		TF4SF__Identity_Information__c iden;
		TF4SF__About_Account__c abtAcc;
		TF4SF__Employment_Information__c empInfo;
		KYC_OOW__c kycInfo;

		if (applicationid != null && applicationId != '') {
			String appquery = selectStar('TF4SF__Application__c') + 'WHERE ID = \'' + applicationId + '\'';
			app = Database.query(appquery);
			String idenQuery = selectStar('TF4SF__Identity_Information__c') + 'WHERE TF4SF__Application__c = \'' + applicationId + '\'';
			iden = Database.query(idenQuery);
			String abtAccQuery = selectStar('TF4SF__About_Account__c') + 'WHERE TF4SF__Application__c = \'' + applicationId + '\'';
			abtAcc = Database.query(abtAccQuery);
			String empQuery = selectStar('TF4SF__Employment_Information__c') + 'WHERE TF4SF__Application__c = \'' + applicationId + '\'';
			empInfo = Database.query(empQuery);
			String kycQuery = selectStar('KYC_OOW__c') + 'WHERE Application_Id__c = \'' + applicationId + '\'';
			if (Database.query(kycQuery).size() > 0) { kycInfo = (KYC_OOW__c)Database.query(kycQuery); }
		}

		System.debug('identity: ' + iden);
		//http_postMethod(jsonString);
		String template = '';
		template  ='[';
		template +=    '{';
		//template +=        '"id": "5d4178b8-0925-49e8-bd43-f693edf2881f",';
		template +=        '"id": "' + app.productId__c + '",';
		//if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c != '') {

		if (String.isNotBlank(app.TF4SF__Sub_Product__c)) {
			template +=        '"product_name": "' + app.TF4SF__Sub_Product__c + '",';
		}

		template +=        '"membership_eligibility": {';
		if (String.isNotBlank(app.TF4SF__Membership_Qualification_Type__c)) {
			template +=            '"question": "' + app.TF4SF__Membership_Qualification_Type__c + '",';
		} else {
			template +=                     '"question": null,';
		}

		if (String.isNotBlank(app.TF4SF__Membership_Qualification_Value__c)) {
			template +=             '"answer": "' + app.TF4SF__Membership_Qualification_Value__c + '"';
		} else {
			template +=             '"answer": "false"';
		}

		template +=        '},';
		template +=        '"applicants": [';
		template +=            '{';

		if (String.isNotBlank(app.TF4SF__First_Name__c)) {
			template +=                '"first_name": "' + app.TF4SF__First_Name__c + '",';
		} else {
			template +=                '"first_name": null,';
		}

		if (String.isNotBlank(app.TF4SF__Middle_Name__c)) {
			template +=                ',"middle_name": "' + app.TF4SF__Middle_Name__c + '",';
		} else {
			template +=                '"middle_name": null,';
		}

		if (String.isNotBlank(app.TF4SF__Last_Name__c)) {
			template +=                '"last_name": "' + app.TF4SF__Last_Name__c + '",';
		} else {
			template +=                '"last_name": null,';
		}

		if (String.isNotBlank(app.TF4SF__Suffix_J__c)) {
			template +=                '"suffix": "' + app.TF4SF__Suffix_J__c + '",';
		} else {
			template +=                '"suffix": null,';
		}

		System.debug('SSN Prime: '+iden.TF4SF__SSN_Prime__c);
		if (String.isNotBlank(iden.TF4SF__SSN_Prime__c)) {
			System.debug('entered ssnprime: ' + iden.TF4SF__SSN_Prime__c);
			template +=                '"federal_id": "' + iden.TF4SF__SSN_Prime__c + '",';
		} else {
			template +=                '"federal_id": null,';
		}

		if (String.isNotBlank(app.TF4SF__Email_Address__c)) {
			template +=                '"email_address": "' + app.TF4SF__Email_Address__c + '",';
		} else {
			template +=                '"email_address": null,';
		}

		if (String.isNotBlank(app.TF4SF__Tertiary_Phone_Number__c)) {
			template +=                '"home_phone_number": "' + app.TF4SF__Tertiary_Phone_Number__c + '",';
		} else {
			template +=                '"home_phone_number": null,';
		}

		if (String.isNotBlank(app.TF4SF__Secondary_Phone_Number__c)) {
			template +=                '"work_phone_number": "' + app.TF4SF__Secondary_Phone_Number__c + '",';
		} else {
			template +=                '"work_phone_number": null,';
		}

		if (String.isNotBlank(app.TF4SF__Primary_Phone_Number__c)) {
			template +=                '"mobile_phone_number": "' + app.TF4SF__Primary_Phone_Number__c + '",';
		} else {
			template +=                '"mobile_phone_number": null,';
		}

		if (String.isNotBlank(iden.TF4SF__Date_of_Birth__c)) {
			List<String> dob = iden.TF4SF__Date_of_Birth__c.split('/');
			template +=                '"birth_date": "' + dob[2] + '-' + dob[1] + '-' + dob[0] + '",';
		} else {
			template +=                '"birth_date": null,';
		}

		//template +=                '"immigration_status": "' + app.TF4SF__Sub_Product__c + '",';
		if (String.isBlank(app.TF4SF__Member__c)) {
			template +=                '"member": true,';
		} else {
			template +=                '"member": false,';
		}

		if (String.isNotBlank(app.TF4SF__Person_Number__c)) {
			template +=                '"member_id": "' + app.TF4SF__Person_Number__c + '",';
		} else {
			template +=                '"member_id": null,';
		}

		//template +=                '"gender": "' + app.TF4SF__Sub_Product__c + '",';
		//template +=                '"occupancy_status": "' + app.TF4SF__Sub_Product__c + '",';
		template +=                '"occupancy_address": {';
		template +=                    '"address_lines": [';
		template +=                        '"595 East 4th St unit 3"';
		template +=                    '],';

		if (app.TF4SF__City__c != null && app.TF4SF__City__c != null) {
			template +=                    '"township": "' + app.TF4SF__City__c + '",';
		} else {
			template +=                    '"township": null,';
		}

		if (app.TF4SF__State__c != null && app.TF4SF__State__c != null) {
			template +=                    '"state_code": "' + app.TF4SF__State__c + '",';
		} else {
			template +=                    '"state_code": null,';
		}

		if (app.TF4SF__Country__c != null && app.TF4SF__Country__c != null) {
			template +=                    '"country_code": "' + app.TF4SF__Country__c + '",';
		} else {
			template +=                    '"country_code": null,';
		}

		if (app.TF4SF__Zip_Code__c != null && app.TF4SF__Zip_Code__c != null) {
			template +=                    '"zip_code": "' + app.TF4SF__Zip_Code__c + '"';
		} else {
			template +=                    '"zip_code": null';
		}

		template +=                '},';
		template +=                '"previous_occupancy_addresses": [';
		template +=                    '{';
		template +=                        '"address_lines": [';
		template +=                            '"59 East 10th St unit 1"';
		template +=                        '],';

		if (String.isNotBlank(app.TF4SF__City_Prev__c)) {
			template +=                        '"township": "' + app.TF4SF__City_Prev__c + '",';
		} else {
			template +=                        '"township": null,';
		}

		if (String.isNotBlank(app.TF4SF__State_Prev__c)){
			template +=                        '"state_code": "' + app.TF4SF__State_Prev__c + '",';
		} else {
			template +=                         '"state_code": null,';
		}

		if (String.isNotBlank(app.TF4SF__Zip_Code_Prev__c)){
			template +=                        '"country_code": "' + app.TF4SF__Country_Prev__c + '",';
		} else {
			template +=                        '"country_code": null,'; 
		}

		if (String.isNotBlank(app.TF4SF__Zip_Code_Prev__c)) {
			template +=                        '"zip_code": "' + app.TF4SF__Zip_Code_Prev__c + '"';
		} else {
			template +=                        '"zip_code": null';
		}

		template +=                    '}';
		template +=                '],';
		template +=                '"mailing_address": {';
		template +=                    '"address_lines": [';
		template +=                        '"595 East 4th St unit 4"';
		template +=                    '],';

		if (String.isNotBlank(app.TF4SF__Mailing_City__c)) {
			template +=                    '"township": "' + app.TF4SF__Mailing_City__c + '",';
		} else {
			template +=                    '"township": null,';
		}

		if (String.isNotBlank(app.TF4SF__Mailing_State__c)) {
			template +=                    '"state_code": "' + app.TF4SF__Mailing_State__c + '",';
		} else {
			template +=                    '"state_code": null,';
		}

		if (String.isNotBlank(app.TF4SF__Mailing_Country__c)) {
			template +=                    '"country_code": "' + app.TF4SF__Mailing_Country__c + '",';
		} else {
			template +=                    '"country_code": null,';
		}

		if (String.isNotBlank(app.TF4SF__Mailing_Zip_Code__c)) {
			template +=                    '"zip_code": "' + app.TF4SF__Mailing_Zip_Code__c + '"';
		} else {
			template +=                    '"zip_code": null';
		}

		template +=                '},';
		// if (String.isNotBlank(iden.TF4SF__Identity_Number_Primary__c)) {//Identification is not null
			template +=                '"identification_documents": [';
			template +=                    '{';
			if (String.isNotBlank(iden.TF4SF__ID_Type__c)) {
				template +=                        '"type": "' + iden.TF4SF__ID_Type__c + '",';
			} else {
				template +=                        '"type": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Identity_Number_Primary__c)) {
				template +=                        '"id": "' + iden.TF4SF__Identity_Number_Primary__c + '",';
			} else {
				template +=                        '"id": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__State_Issued__c)) {
				template +=                        '"state_code": "' + iden.TF4SF__State_Issued__c + '",';
			} else {
				template +=                        '"state_code": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Expiry_Date__c)) {
				List<String> dt = iden.TF4SF__Expiry_Date__c.split('/');
				template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
			} else {
				template +=                        '"expiration_date": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Issue_Date__c)) {
				List<String> dt = iden.TF4SF__Issue_Date__c.split('/');
				template +=                        '"issue_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '"';
			} else {
				template +=                        '"issue_date": null';   
			}

			template +=                    '}';
			template +=                '],';
		//}//Identification is not null

		if (kycinfo != null) {
			template +=                '"question_answers": [';
			template +=                    '{';
			if (String.isNotBlank(kycInfo.Question_1_Text__c)) {
				template +=                        '"question_name": "' + kycInfo.Question_1_Text__c + '",';
			} else {
				template +=                         '"question_name": null,';
			}

			if (String.isNotBlank(kycInfo.Question_1_Response__c)) {
				template +=                        '"answer": "' + kycInfo.Question_1_Response__c + '"';
			} else {
				template +=                        '"answer": null';
			}

			template +=                    '},';
			template +=                    '{';
			if (String.isNotBlank(kycInfo.Question_2_Text__c)) {
				template +=                        '"question_name": "' + kycInfo.Question_2_Text__c + '",';
			} else {
				template +=                         '"question_name": null,';
			}

			if (String.isNotBlank(kycInfo.Question_2_Response__c)) {
				template +=                        '"answer": "' + kycInfo.Question_2_Response__c + '"';
			} else {
				template +=                        '"answer": null';
			}

			template +=                    '},';
			template +=                    '{';
			if (String.isNotBlank(kycInfo.Question_3_Text__c)) {
				template +=                        '"question_name": "' + kycInfo.Question_3_Text__c + '",';
			} else {
				template +=                         '"question_name": null,';
			}

			if (String.isNotBlank(kycInfo.Question_3_Response__c)) {
				template +=                        '"answer": "' + kycInfo.Question_3_Response__c + '"';
			} else {
				template +=                        '"answer": null';
			}

			template +=                    '}';
			template +=                  '],';
		}

		template +=                '"financials": {';
		if (empInfo.TF4SF__Annual_Income__c != null) {
			String aInc = String.valueOf(empInfo.TF4SF__Annual_Income__c / 12);
			template +=                    '"monthly_income": "' + aInc + '",';
		} else {
			template +=                    '"monthly_income": null,';
		}

		//  if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
		//    template +=                    '"monthly_liability": "' + app.TF4SF__Sub_Product__c + '",';
		if (String.isNotBlank(empInfo.TF4SF__Employment_Status__c)) {
			template +=                    '"employment_status": "' + empInfo.TF4SF__Employment_Status__c + '",';
		} else {
			template +=                    '"employment_status": null';
		}

		if (String.isNotBlank(empInfo.TF4SF__Occupation__c)) {
			template +=                    ',"employment": [';
			template +=                        '{';
			if (String.isNotBlank(empInfo.TF4SF__Occupation__c)) {
				template +=                            '"title": "' + empInfo.TF4SF__Occupation__c + '",';
			}
			// else {
			//    template +=                            '"title": null,';
			// }

			if (String.isNotBlank(empInfo.TF4SF__Employer__c)) {
				template +=                            '"employer": "' + empInfo.TF4SF__Employer__c + '",';
			}
			//else {
			//  template +=                            '"employer": null,';
			//}
			/* template +=                '"address": {';
			template +=                    '"address_lines": [';
			template +=                        '"null"';
			template +=                    '],';
			template +=                    '"township": null,';
			template +=                    '"state_code": null,';
			template +=                    '"country_code": null,';
			template +=                    '"zip_code": null';
			template +=                   '},';
			template += '"start_date": "0000-00-00"';*/
			template +=                            '}';
			// template +=                        '}';

			template +=                    ']';
		}

		template +=                '}';
		if (String.isNotBlank(iden.TF4SF__SSN_J1__c)) {
			template +=            '},';
		} else {
			template += '}';
		}

		// template +=            '},';
		//applicant2 start Aug 6
		if (String.isNotBlank(iden.TF4SF__SSN_J1__c)){//japp1 is null
			template +=            '{';
			if (String.isNotBlank(app.TF4SF__First_Name_J__c)) {
				template +=                '"first_name": "' + app.TF4SF__First_Name_J__c + '",';
			} else {
				template +=                '"first_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Middle_Name_J__c)) {
				template +=                ',"middle_name": "' + app.TF4SF__Middle_Name_J__c + '",';
			} else {
				template +=                '"middle_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Last_Name_J__c)) {
				template +=                '"last_name": "' + app.TF4SF__Last_Name_J__c + '",';
			} else {
				template +=                '"last_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Suffix_J__c)) {
				template +=                '"suffix": "' + app.TF4SF__Suffix_J__c + '",';
			} else {
				template +=                '"suffix": null,';
			}

			if (String.isNotBlank(iden.TF4SF__SSN_J1__c)) {
				template +=                '"federal_id": "' + iden.TF4SF__SSN_J1__c + '",';
			} else {
				template +=                '"federal_id": null,';
			}

			if (String.isNotBlank(app.TF4SF__Email_Address_J__c)) {
				template +=                '"email_address": "' + app.TF4SF__Email_Address_J__c + '",';
			} else {
				template +=                '"email_address": null,';
			}

			if (String.isNotBlank(app.TF4SF__Tertiary_Phone_Number_J1__c)) {
				template +=                '"home_phone_number": "' + app.TF4SF__Tertiary_Phone_Number_J1__c + '",';
			} else {
				template +=                '"home_phone_number": null,';
			}

			if (String.isNotBlank(app.TF4SF__Secondary_Phone_Number_J__c)) {
				template +=                '"work_phone_number": "' + app.TF4SF__Secondary_Phone_Number_J__c + '",';
			} else {
				template +=                '"work_phone_number": null,';
			}

			if (String.isNotBlank(app.TF4SF__Primary_Phone_Number_J__c)) {
				template +=                '"mobile_phone_number": "' + app.TF4SF__Primary_Phone_Number_J__c + '",';
			} else {
				template +=                '"mobile_phone_number": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Date_of_Birth_J1__c)) {
				List<String> dob1 = iden.TF4SF__Date_of_Birth_J1__c.split('/');
				template +=                '"birth_date": "' + dob1[2] + '-' + dob1[1] + '-' + dob1[0] + '",';
			} else {
				template +=                '"birth_date": "0000-00-00",';
			}

			//template +=                '"immigration_status": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isBlank(app.TF4SF__Member__c)) {
				template +=                '"member": true,';
			} else {
				template +=                '"member": false,';
			}

			if (String.isNotBlank(app.TF4SF__Person_Number__c)) {
				template +=                '"member_id": "' + app.TF4SF__Person_Number__c + '",';
			} else {
				template +=                '"member_id": null,';
			}
	
			//template +=                '"gender": "' + app.TF4SF__Sub_Product__c + '",';
			//template +=                '"occupancy_status": "' + app.TF4SF__Sub_Product__c + '",';
			template +=                '"occupancy_address": {';
			template +=                    '"address_lines": [';
			template +=                        '"595 East 4th St unit 3"';
			template +=                    '],';

			if (String.isNotBlank(app.TF4SF__City_J__c)) {
				template +=                    '"township": "' + app.TF4SF__City_J__c + '",';
			} else {
				template +=                    '"township": null,';
			}

			if (String.isNotBlank(app.TF4SF__State_J__c)) {
				template +=                    '"state_code": "' + app.TF4SF__State_J__c + '",';
			} else {
				template +=                    '"state_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Country_J1__c)) {
				template +=                    '"country_code": "' + app.TF4SF__Country_J1__c + '",';
			} else {
				template +=                    '"country_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Zip_Code_J__c)) {
				template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_J__c + '"';
			} else {
				template +=                    '"zip_code": null';
			}

			template +=                '},';
			template +=                '"previous_occupancy_addresses": [';
			template +=                    '{';
			template +=                        '"address_lines": [';
			template +=                            '"59 East 10th St unit 1"';
			template +=                        '],';

			if (String.isNotBlank(app.TF4SF__City_JP__c)) {
				template +=                        '"township": "' + app.TF4SF__City_JP__c + '",';
			} else {
				template +=                        '"township": null,';
			}

			if (String.isNotBlank(app.TF4SF__State_JP__c)){
				template +=                        '"state_code": "' + app.TF4SF__State_JP__c + '",';
			} else {
				template +=                         '"state_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Country_JP1__c)){
				template +=                        '"country_code": "' + app.TF4SF__Country_JP1__c + '",';
			} else {
				template +=                        '"country_code": null,'; 
			}

			if (String.isNotBlank(app.TF4SF__Zip_Code_JP__c)) {
				template +=                        '"zip_code": "' + app.TF4SF__Zip_Code_JP__c + '"';
			} else {
				template +=                        '"zip_code": null';
			}

			template +=                    '}';
			template +=                '],';
			template +=                '"mailing_address": {';
			template +=                    '"address_lines": [';
			template +=                        '"595 East 4th St unit 4"';
			template +=                    '],';

			if (String.isNotBlank(app.TF4SF__Mailing_City_J1__c)) {
				template +=                    '"township": "' + app.TF4SF__Mailing_City_J1__c + '",';
			} else {
				template +=                    '"township": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_State_J1__c)) {
				template +=                    '"state_code": "' + app.TF4SF__Mailing_State_J1__c + '",';
			} else {
				template +=                    '"state_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_Country_J1__c)) {
				template +=                    '"country_code": "' + app.TF4SF__Mailing_Country_J1__c + '",';
			} else {
				template +=                    '"country_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_Zip_Code_J1__c)) {
				template +=                    '"zip_code": "' + app.TF4SF__Mailing_Zip_Code_J1__c + '"';
			} else {
				template +=                    '"zip_code": null';
			}

			template +=                '},';
			template +=                '"identification_documents": [';
			template +=                    '{';

			if (String.isNotBlank(iden.TF4SF__ID_Type_J1__c)) {
				template +=                        '"type": "' + iden.TF4SF__ID_Type_J1__c + '",';
			} else {
				template +=                        '"type": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__Identity_Number_J1__c)) {
				template +=                        '"id": "' + iden.TF4SF__Identity_Number_J1__c + '",';
			} else {
				template +=                        '"id": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__State_Issued_J1__c)) {
				template +=                        '"state_code": "' + iden.TF4SF__State_Issued_J1__c + '",';
			} else {
				template +=                        '"state_code": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Expiry_Date_J1__c)) {
				List<String> dt = iden.TF4SF__Expiry_Date_J1__c.split('/');
				template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
			} else {
				template +=                        '"expiration_date": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Issue_Date_J1__c)) {
				template +=                        '"issue_date": "' + iden.TF4SF__Issue_Date_J1__c + '"';
			} else {
				template +=                        '"issue_date": null';   
			}

			template +=                    '}';
			template +=                '],';
			template +=                '"question_answers": [';
			template +=                    '{';
			template +=                        '"question_name": "6",';
			template +=                        '"answer": "San Jose"';
			template +=                    '},';
			template +=                    '{';
			template +=                        '"question_name": "Foreign Political",';
			template +=                        '"answer": "Yes"';
			template +=                    '},';
			template +=                    '{';
			template +=                        '"question_name": "Withholding",';
			template +=                        '"answer": "No"';
			template +=                    '}';
			template +=                  '],';
			template +=                '"financials": {';

			if (empInfo.TF4SF__Annual_Income_J1__c != null) {
				String aInc = String.valueOf(empInfo.TF4SF__Annual_Income_J1__c / 12);
				template +=                    '"monthly_income": "' + aInc + '",';
			} else {
				template +=                    '"monthly_income": null,';
			}

			//  if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
			//    template +=                    '"monthly_liability": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isNotBlank(empInfo.TF4SF__Employment_Status_J1__c)) {
				template +=                    '"employment_status": "' + empInfo.TF4SF__Employment_Status_J1__c + '",';
			} else {
				template +=                    '"employment_status": null,';
			}

			template +=                    '"employment": [';
			template +=                        '{';
			if (String.isNotBlank(empInfo.TF4SF__Occupation_J1__c)) {
				template +=                            '"title": "' + empInfo.TF4SF__Occupation_J1__c + '",';
			} else {
				template +=                            '"title": "null",';
			}

			// if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
			//    template +=                            '"start_date": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isNotBlank(empInfo.TF4SF__Employer_J1__c)) {
				template +=                            '"employer": "' + empInfo.TF4SF__Employer_J1__c + '",';
			} else {
				template +=                            '"employer": "null",';
			}

			template +=                '"address": {';
			template +=                    '"address_lines": [';
			template +=                        '"null"';
			template +=                    '],';
			template +=                    '"township": null,';
			template +=                    '"state_code": null,';
			template +=                    '"country_code": null,';
			template +=                    '"zip_code": null';
			template +=                   '},';
			template += '"start_date": "0000-00-00"';
			template +=                            '}';
			 // template +=                        '}';
			template +=                    ']';
			template +=                '}';

			if (String.isNotBlank(iden.TF4SF__SSN_J2__c)) {
				template +=            '},';
			} else {
				template += '}';
			}
		}//japp1 is null ends

		//applicant2 end aug 6
		//applicant3 start aug6
		if (String.isNotBlank(iden.TF4SF__SSN_J2__c)) {//japp2 is not null
			template +=            '{';
			if (String.isNotBlank(app.TF4SF__First_Name_J2__c)) {
				template +=                '"first_name": "' + app.TF4SF__First_Name_J2__c + '",';
			} else {
				template +=                '"first_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Middle_Name_J2__c)) {
				template +=                ',"middle_name": "' + app.TF4SF__Middle_Name_J2__c + '",';
			} else {
				template +=                '"middle_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Last_Name_J2__c)) {
				template +=                '"last_name": "' + app.TF4SF__Last_Name_J2__c + '",';
			} else {
				template +=                '"last_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Suffix_J2__c)) {
				template +=                '"suffix": "' + app.TF4SF__Suffix_J2__c + '",';
			} else {
				template +=                '"suffix": null,';
			}

			if (String.isNotBlank(iden.TF4SF__SSN_J2__c)) {
				template +=                '"federal_id": "' + iden.TF4SF__SSN_J2__c + '",';
			} else {
				template +=                '"federal_id": null,';
			}

			if (String.isNotBlank(app.TF4SF__Email_Address_J2__c)) {
				template +=                '"email_address": "' + app.TF4SF__Email_Address_J2__c + '",';
			} else {
				template +=                '"email_address": null,';
			}

			if (String.isNotBlank(app.TF4SF__Tertiary_Phone_Number_J2__c)) {
				template +=                '"home_phone_number": "' + app.TF4SF__Tertiary_Phone_Number_J2__c + '",';
			} else {
				template +=                '"home_phone_number": null,';
			}

			if (String.isNotBlank(app.TF4SF__Secondary_Phone_Number_J2__c)) {
				template +=                '"work_phone_number": "' + app.TF4SF__Secondary_Phone_Number_J2__c + '",';
			} else {
				template +=                '"work_phone_number": null,';
			}

			if (String.isNotBlank(app.TF4SF__Primary_Phone_Number_J2__c)) {
				template +=                '"mobile_phone_number": "' + app.TF4SF__Primary_Phone_Number_J2__c + '",';
			} else {
				template +=                '"mobile_phone_number": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Date_of_Birth_J2__c)) {
				List<String> dob2 = iden.TF4SF__Date_of_Birth_J2__c.split('/');
				template +=                '"birth_date": "' + dob2[2] + '-' + dob2[1] + '-' + dob2[0] + '",';
			} else {
				template +=                '"birth_date": null,';
			}
			
			//template +=                '"immigration_status": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isBlank(app.TF4SF__Member__c)) {
				template +=                '"member": true,';
			} else {
				template +=                '"member": false,';
			}

			if (String.isNotBlank(app.TF4SF__Person_Number__c)) {
				template +=                '"member_id": "' + app.TF4SF__Person_Number__c + '",';
			} else {
				template +=                '"member_id": null,';
			}
			
			//template +=                '"gender": "' + app.TF4SF__Sub_Product__c + '",';
			//template +=                '"occupancy_status": "' + app.TF4SF__Sub_Product__c + '",';
			template +=                '"occupancy_address": {';
			template +=                    '"address_lines": [';
			template +=                        '"595 East 4th St unit 3"';
			template +=                    ']';

			if (String.isNotBlank(app.TF4SF__City_J2__c)) {
				template +=                    ',"township": "' + app.TF4SF__City_J2__c + '"';
			} else {
				template +=                    ',"township": null';
			}

			if (String.isNotBlank(app.TF4SF__State_J2__c)) {
				template +=                    ',"state_code": "' + app.TF4SF__State_J2__c + '"';
			} else {
				template +=                    ',"state_code": null';
			}

			if (String.isNotBlank(app.TF4SF__Country_J2__c)) {
				template +=                    ',"country_code": "' + app.TF4SF__Country_J2__c + '"';
			} else {
				template +=                    ',"country_code": null';
			}

			if (String.isNotBlank(app.TF4SF__Zip_Code_J2__c)) {
				template +=                    ',"zip_code": "' + app.TF4SF__Zip_Code_J2__c + '"';
			} else {
				template +=                    ',"zip_code": null';
			}

			template +=                '},';
			template +=                '"previous_occupancy_addresses": [';
			template +=                    '{';
			template +=                        '"address_lines": [';
			template +=                            '"59 East 10th St unit 1"';
			template +=                        '],';

			if (String.isNotBlank(app.TF4SF__City_JP2__c)) {
				template +=                        '"township": "' + app.TF4SF__City_JP2__c + '",';
			} else {
				template +=                        '"township": null,';
			}

			if (String.isNotBlank(app.TF4SF__State_JP2__c)){
				template +=                        '"state_code": "' + app.TF4SF__State_JP2__c + '",';
			} else {
				template +=                         '"state_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Zip_Code_JP2__c)){
				template +=                        '"country_code": "' + app.TF4SF__Country_JP2__c + '",';
			} else {
				template +=                        '"country_code": null,'; 
			}

			if (String.isNotBlank(app.TF4SF__Zip_Code_JP2__c)) {
				template +=                        '"zip_code": "' + app.TF4SF__Zip_Code_JP2__c + '"';
			} else {
				template +=                        '"zip_code": null';
			}

			template +=                    '}';
			template +=                '],';
			template +=                '"mailing_address": {';
			template +=                    '"address_lines": [';
			template +=                        '"595 East 4th St unit 4"';
			template +=                    '],';

			if (String.isNotBlank(app.TF4SF__Mailing_City_J2__c)) {
				template +=                    '"township": "' + app.TF4SF__Mailing_City_J2__c + '",';
			} else {
				template +=                    '"township": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_State_J2__c)) {
				template +=                    '"state_code": "' + app.TF4SF__Mailing_State_J2__c + '",';
			} else {
				template +=                    '"state_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_Country_J2__c)) {
				template +=                    '"country_code": "' + app.TF4SF__Mailing_Country_J2__c + '",';
			} else {
				template +=                    '"country_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_Zip_Code_J2__c)) {
				template +=                    '"zip_code": "' + app.TF4SF__Mailing_Zip_Code_J2__c + '"';
			} else {
				template +=                    '"zip_code": null';
			}

			template +=                '},';
			template +=                '"identification_documents": [';
			template +=                    '{';

			if (String.isNotBlank(iden.TF4SF__ID_Type_J2__c)) {
				template +=                        '"type": "' + iden.TF4SF__ID_Type_J2__c + '",';
			} else {
				template +=                        '"type": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__Identity_Number_J2__c)) {
				template +=                        '"id": "' + iden.TF4SF__Identity_Number_J2__c + '",';
			} else {
				template +=                        '"id": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__State_Issued_J2__c)) {
				template +=                        '"state_code": "' + iden.TF4SF__State_Issued_J2__c + '",';
			} else {
				template +=                        '"state_code": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__Expiry_Date_J2__c)) {
				List<String> dt = iden.TF4SF__Expiry_Date_J2__c.split('/');
				template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
			} else {
				template +=                        '"expiration_date": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Issue_Date_J2__c)) {
				List<String> dt = iden.TF4SF__Issue_Date_J2__c.split('/');
				template +=                        '"issue_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '"';
			} else {
				template +=                        '"issue_date": null';   
			}

			template +=                    '}';
			template +=                '],';
			template +=                '"question_answers": [';
			template +=                    '{';
			template +=                        '"question_name": "6",';
			template +=                        '"answer": "San Jose"';
			template +=                    '},';
			template +=                    '{';
			template +=                        '"question_name": "Foreign Political",';
			template +=                        '"answer": "Yes"';
			template +=                    '},';
			template +=                    '{';
			template +=                        '"question_name": "Withholding",';
			template +=                        '"answer": "No"';
			template +=                    '}';
			template +=                  '],';
			template +=                '"financials": {';

			if (empInfo.TF4SF__Annual_Income_J2__c != null) {
				String aInc = String.valueOf(empInfo.TF4SF__Annual_Income_J2__c / 12);
				template +=                    '"monthly_income": "' + aInc + '",';
			} else {
				template +=                    '"monthly_income": 100.0,';
			}

			//  if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
			//    template +=                    '"monthly_liability": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isNotBlank(empInfo.TF4SF__Employment_Status_J2__c)) {
				template +=                    '"employment_status": "' + empInfo.TF4SF__Employment_Status_J2__c + '",';
			} else {
				template +=                    '"employment_status": "null",';
			}

			template +=                    '"employment": [';
			template +=                        '{';
			if (String.isNotBlank(empInfo.TF4SF__Occupation_J2__c)) {
				template +=                            '"title": "' + empInfo.TF4SF__Occupation_J2__c + '",';
			} else {
				template +=                            '"title": "null",';
			}

			// if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
			//    template +=                            '"start_date": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isNotBlank(empInfo.TF4SF__Employer_J2__c)) {
				template +=                            '"employer": "' + empInfo.TF4SF__Employer_J2__c + '",';
			} else {
				template +=                            '"employer": "null",';
			}

			template +=                '"address": {';
			template +=                    '"address_lines": [';
			template +=                        '"null"';
			template +=                    '],';
			template +=                    '"township": null,';
			template +=                    '"state_code": null,';
			template +=                    '"country_code": null,';
			template +=                    '"zip_code": null';
			template +=                   '},';
			template += '"start_date": "0000-00-00"';
			template +=                            '}';
			// template +=                        '}';
			template +=                    ']';
			template +=                '}';

			if (String.isNotBlank(iden.TF4SF__SSN_J3__c)) {
				template +=            '},';
			} else {
				template += '}';
			}
		}//japp2 is not null ends

		//applicant3 end aug6
		//japplicant4 start
		if (String.isNotBlank(iden.TF4SF__SSN_J3__c)) {//japp3 is not null
			template +=            '{';
			if (String.isNotBlank(app.TF4SF__First_Name_J3__c)) {
				template +=                '"first_name": "' + app.TF4SF__First_Name_J3__c + '",';
			} else {
				template +=                '"first_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Middle_Name_J3__c)) {
				template +=                ',"middle_name": "' + app.TF4SF__Middle_Name_J3__c + '",';
			} else {
				template +=                '"middle_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Last_Name_J3__c)) {
				template +=                '"last_name": "' + app.TF4SF__Last_Name_J3__c + '",';
			} else {
				template +=                '"last_name": null,';
			}

			if (String.isNotBlank(app.TF4SF__Suffix_J3__c)) {
				template +=                '"suffix": "' + app.TF4SF__Suffix_J3__c + '",';
			} else {
				template +=                '"suffix": null,';
			}

			if (String.isNotBlank(iden.TF4SF__SSN_J3__c)) {
				template +=                '"federal_id": "' + iden.TF4SF__SSN_J3__c + '",';
			} else {
				template +=                '"federal_id": null,';
			}

			if (String.isNotBlank(app.TF4SF__Email_Address_J3__c)) {
				template +=                '"email_address": "' + app.TF4SF__Email_Address_J3__c + '",';
			} else {
				template +=                '"email_address": null,';
			}

			if (String.isNotBlank(app.TF4SF__Tertiary_Phone_Number_J3__c)) {
				template +=                '"home_phone_number": "' + app.TF4SF__Tertiary_Phone_Number_J3__c + '",';
			} else {
				template +=                '"home_phone_number": null,';
			}

			if (String.isNotBlank(app.TF4SF__Secondary_Phone_Number_JP3__c)) {
				template +=                '"work_phone_number": "' + app.TF4SF__Secondary_Phone_Number_JP3__c + '",';
			} else {
				template +=                '"work_phone_number": null,';
			}

			if (String.isNotBlank(app.TF4SF__Primary_Phone_Number_J3__c)) {
				template +=                '"mobile_phone_number": "' + app.TF4SF__Primary_Phone_Number_J3__c + '",';
			} else {
				template +=                '"mobile_phone_number": null,';
			}

			if (String.isNotBlank(iden.TF4SF__Date_of_Birth_J3__c)) {
				List<String> dob3 = iden.TF4SF__Date_of_Birth_J3__c.split('/');
				template +=                '"birth_date": "' + dob3[2] + '-' + dob3[1] + '-' + dob3[0] + '",';
			} else {
				template +=                '"birth_date": "0000-00-00",';
			}

			//template +=                '"immigration_status": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isBlank(app.TF4SF__Member__c)) {
				template +=                '"member": true,';
			} else {
				template +=                '"member": false,';
			}

			if (String.isNotBlank(app.TF4SF__Person_Number__c)) {
				template +=                '"member_id": "' + app.TF4SF__Person_Number__c + '",';
			} else {
				template +=                '"member_id": null,';
			}

			//template +=                '"gender": "' + app.TF4SF__Sub_Product__c + '",';
			//template +=                '"occupancy_status": "' + app.TF4SF__Sub_Product__c + '",';
			template +=                '"occupancy_address": {';
			template +=                    '"address_lines": [';
			template +=                        '"595 East 4th St unit 3"';
			template +=                    '],';

			if (String.isNotBlank(app.TF4SF__City_J3__c)) {
				template +=                    '"township": "' + app.TF4SF__City_J3__c + '",';
			} else {
				template +=                    '"township": null,';
			}

			if (String.isNotBlank(app.TF4SF__State_J3__c)) {
				template +=                    '"state_code": "' + app.TF4SF__State_J3__c + '",';
			} else {
				template +=                    '"state_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Country_J3__c)) {
				template +=                    '"country_code": "' + app.TF4SF__Country_J3__c + '",';
			} else {
				template +=                    '"country_code": null,';
			}

			if (String.isNotblank(app.TF4SF__Zip_Code_J3__c)) {
				template +=                    '"zip_code": "' + app.TF4SF__Zip_Code_J3__c + '",';
			} else {
				template +=                    '"zip_code": null';
			}

			template +=                '},';
			template +=                '"previous_occupancy_addresses": [';
			template +=                    '{';
			template +=                        '"address_lines": [';
			template +=                            '"59 East 10th St unit 1"';
			template +=                        '],';

			if (String.isNotBlank(app.TF4SF__City_JP3__c)) {
				template +=                        '"township": "' + app.TF4SF__City_JP3__c + '",';
			} else {
				template +=                        '"township": null,';
			}

			if (String.isNotBlank(app.TF4SF__State_JP3__c)){
				template +=                        '"state_code": "' + app.TF4SF__State_JP3__c + '",';
			} else {
				template +=                         '"state_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Zip_Code_JP3__c)){
				template +=                        '"country_code": "' + app.TF4SF__Country_JP3__c + '",';
			} else {
				template +=                        '"country_code": null,'; 
			}

			if (String.isNotBlank(app.TF4SF__Zip_Code_JP3__c)) {
				template +=                        '"zip_code": "' + app.TF4SF__Zip_Code_JP3__c + '"';
			} else {
				template +=                        '"zip_code": null';
			}

			template +=                    '}';
			template +=                '],';
			template +=                '"mailing_address": {';
			template +=                    '"address_lines": [';
			template +=                        '"595 East 4th St unit 4"';
			template +=                    '],';

			if (String.isNotBlank(app.TF4SF__Mailing_City_J3__c)) {
				template +=                    '"township": "' + app.TF4SF__Mailing_City_J3__c + '",';
			} else {
				template +=                    '"township": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_State_J3__c)) {
				template +=                    '"state_code": "' + app.TF4SF__Mailing_State_J3__c + '",';
			} else {
				template +=                    '"state_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_Country_J3__c)) {
				template +=                    '"country_code": "' + app.TF4SF__Mailing_Country_J3__c + '",';
			} else {
				template +=                    '"country_code": null,';
			}

			if (String.isNotBlank(app.TF4SF__Mailing_Zip_Code_J3__c)) {
				template +=                    '"zip_code": "' + app.TF4SF__Mailing_Zip_Code_J3__c + '"';
			} else {
				template +=                    '"zip_code": null';
			}

			template +=                '},';
			template +=                '"identification_documents": [';
			template +=                    '{';

			if (String.isNotBlank(iden.TF4SF__ID_Type_J3__c)) {
				template +=                        '"type": "' + iden.TF4SF__ID_Type_J3__c + '",';
			} else {
				template +=                        '"type": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__Identity_Number_J3__c)) {
				template +=                        '"id": "' + iden.TF4SF__Identity_Number_J3__c + '",';
			} else {
				template +=                        '"id": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__State_Issued_J3__c)) {
				template +=                        '"state_code": "' + iden.TF4SF__State_Issued_J3__c + '",';
			} else {
				template +=                        '"state_code": "null",';
			}

			if (String.isNotBlank(iden.TF4SF__Expiry_Date_J3__c)) {
				List<String> dt = iden.TF4SF__Expiry_Date_J3__c.split('/');
				template +=                        '"expiration_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '",';
			} else {
				template +=                        '"expiration_date": "0000-00-00",';
			}

			if (String.isNotBlank(iden.TF4SF__Issue_Date_J3__c)) {
				List<String> dt = iden.TF4SF__Issue_Date_J3__c.split('/');
				template +=                        '"issue_date": "' + dt[2] + '-' + dt[1] + '-' + dt[0] + '"';
			} else {
				template +=                        '"issue_date": "0000-00-00"';   
			}

			template +=                    '}';
			template +=                '],';
			template +=                '"question_answers": [';
			template +=                    '{';
			template +=                        '"question_name": "6",';
			template +=                        '"answer": "San Jose"';
			template +=                    '},';
			template +=                    '{';
			template +=                        '"question_name": "Foreign Political",';
			template +=                        '"answer": "Yes"';
			template +=                    '},';
			template +=                    '{';
			template +=                        '"question_name": "Withholding",';
			template +=                        '"answer": "No"';
			template +=                    '}';
			template +=                  '],';
			template +=                '"financials": {';

			if (empInfo.TF4SF__Annual_Income_J3__c != null) {
				String aInc = String.valueOf(empInfo.TF4SF__Annual_Income_J3__c / 12);
				template +=                    '"monthly_income": "' + aInc + '",';
			} else {
				template +=                    '"monthly_income": 100.0,';
			}

			//  if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
			//    template +=                    '"monthly_liability": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isNotBlank(empInfo.TF4SF__Employment_Status_J3__c)) {
				template +=                    '"employment_status": "' + empInfo.TF4SF__Employment_Status_J3__c + '",';
			} else {
				template +=                    '"employment_status": "null",';
			}

			template +=                    '"employment": [';
			template +=                        '{';
			if (String.isNotBlank(empInfo.TF4SF__Occupation_J3__c)) {
				template +=                            '"title": "' + empInfo.TF4SF__Occupation_J3__c + '",';
			} else {
				template +=                            '"title": "null",';
			}

			// if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
			//    template +=                            '"start_date": "' + app.TF4SF__Sub_Product__c + '",';
			if (String.isNotBlank(empInfo.TF4SF__Employer_J3__c)) {
				template +=                            '"employer": "' + empInfo.TF4SF__Employer_J3__c + '",';
			} else {
				template +=                            '"employer": "null",';
			}

			template +=                '"address": {';
			template +=                    '"address_lines": [';
			template +=                        '"null"';
			template +=                    '],';
			template +=                    '"township": null,';
			template +=                    '"state_code": null,';
			template +=                    '"country_code": null,';
			template +=                    '"zip_code": null';
			template +=                   '},';
			template += '"start_date": "0000-00-00"';
			template +=                            '}';
			 // template +=                        '}';
			template +=                    ']';
			//template +=                '}';
			template +=            '}';
			//japplicant4 end
			//j2applicant start
			template +=            '}';
		}//japp3 is not null

		//j3applicant end
		template +=        '],';
		template +=        '"funding": {';
		template +=            '"type": "BANK",';

		if (app.TF4SF__Sub_Product__c.contains('Checking')) {
			if (String.isNotBlank(abtAcc.TF4SF__Account_type_FI_CHK__c)) {
				template +=            '"source_bank_account_type": "' + abtAcc.TF4SF__Account_type_FI_CHK__c + '",';
			} else {
				template +=            '"source_bank_account_type": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Account_Holder_Name_CHK__c)) {
				template +=            '"source_name_on_card": "' + abtAcc.TF4SF__Account_Holder_Name_CHK__c + '",';
			} else {
				template +=            '"source_name_on_card": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__CHK_Account_Number__c)) {
				template +=            '"source_bank_account_number": "' + abtAcc.TF4SF__CHK_Account_Number__c + '",';
			} else {
				template +=            '"source_bank_account_number": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Routing_Number_CHK__c)) {
				template +=            '"source_bank_routing_number": "' + abtAcc.TF4SF__Routing_Number_CHK__c + '",';
			} else {
				template +=            '"source_bank_routing_number": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Financial_Institution_CHK__c)) {
				template +=            '"source_bank_name": "' + abtAcc.TF4SF__Financial_Institution_CHK__c + '",';
			} else {
				template +=            '"source_bank_name": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__State__c)) {
				template +=            '"source_bank_state_code": "' + abtAcc.TF4SF__State__c + '",';
			} else {
				template +=            '"source_bank_state_code": null,';
			}
		}

		if (app.TF4SF__Sub_Product__c.contains('Saving')) {
			if (String.isNotBlank(abtAcc.TF4SF__Account_Type_FI_Sav__c)) {
				template +=            '"source_bank_account_type": "' + abtAcc.TF4SF__Account_Type_FI_Sav__c + '",';
			} else {
				template +=            '"source_bank_account_type": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Account_Holder_Name_SAV__c)) {
				template +=            '"source_name_on_card": "' + abtAcc.TF4SF__Account_Holder_Name_SAV__c + '",';
			} else {
				template +=            '"source_name_on_card": "'+ ''+'avsd",';
			}

			if (String.isNotBlank(abtAcc.TF4SF__SAV_Account_Number__c)) {
				template +=            '"source_bank_account_number": "' + abtAcc.TF4SF__SAV_Account_Number__c + '",';
			} else {
				template +=            '"source_bank_account_number": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Routing_Number_Sav__c)) {
				template +=            '"source_bank_routing_number": "' + abtAcc.TF4SF__Routing_Number_Sav__c + '",';
			} else {
				template +=            '"source_bank_routing_number": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Financial_Institution_SAV__c)) {
				template +=            '"source_bank_name": "' + abtAcc.TF4SF__Financial_Institution_SAV__c + '",';
			} else {
				template +=            '"source_bank_name": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__State__c)) {
				template +=            '"source_bank_state_code": "' + abtAcc.TF4SF__State__c + '",';
			} else {
				template +=            '"source_bank_state_code": null,';
			}
		}

		if (app.TF4SF__Sub_Product__c.contains('Time Deposits')) {
			if (String.isNotBlank(abtAcc.TF4SF__Account_Type_FI_Cert__c)) {
				template +=            '"source_bank_account_type": "' + abtAcc.TF4SF__Account_Type_FI_Cert__c + '",';
			} else {
				template +=            '"source_bank_account_type": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Account_Holder_Name_CERT__c)) {
				template +=            '"source_name_on_card": "' + abtAcc.TF4SF__Account_Holder_Name_CERT__c + '",';
			} else {
				template +=            '"source_name_on_card": "'+ ''+'fawerw",';
			}

			if (String.isNotBlank(abtAcc.TF4SF__CERT_Account_Number__c)) {
				template +=            '"source_bank_account_number": "' + abtAcc.TF4SF__CERT_Account_Number__c + '",';
			} else {
				template +=            '"source_bank_account_number": "'+ 't456",';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Routing_Number_Cert__c)) {
				template +=            '"source_bank_routing_number": "' + abtAcc.TF4SF__Routing_Number_Cert__c + '",';
			} else {
				template +=            '"source_bank_routing_number": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__Financial_Institution_CERT__c)) {
				template +=            '"source_bank_name": "' + abtAcc.TF4SF__Financial_Institution_CERT__c + '",';
			} else {
				template +=            '"source_bank_name": null,';
			}

			if (String.isNotBlank(abtAcc.TF4SF__State__c)) {
				template +=            '"source_bank_state_code": "' + abtAcc.TF4SF__State__c + '",';
			} else {
				template +=            '"source_bank_state_code": null,';
			}
		}

		if (abtAcc.TF4SF__Total_Loan_Amount__c != null) {
			template +=            '"amount": "' + abtAcc.TF4SF__Total_Loan_Amount__c + '"';
		} else {
			template +=            '"amount": null';
		}
		
		template +=        '}';
		template +=    '}';
		template +=']';
		System.debug('template::::' + template);
		String resJson = http_postMethod(template, applicationId, app.TF4SF__application_page__c);
		return resJson;
	}

	public static String http_postMethod(String jsonBody, String appId, String page) {
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setHeader('content-type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setMethod('PUT');
		req.setTimeout(120000);
		req.setEndpoint('https://dev.sandboxbanking.com/api/product-applications/');
		req.setHeader('Authorization', 'Token c1cb7333444e8a890882fd459c945692c9f4a47f');      
		req.setBody(jsonBody);
		System.debug('jsonbodu: ' + jsonbody);
		System.debug('request: ' + req.getbody());
		HttpResponse res = http.send(req);
		System.debug('response: ' + res.getbody());
		if (res.getStatusCode() == 200) { System.debug('success'); }
		String responseJSON = res.getBody();
		System.debug('responseJSON: ' + responseJSON);
		List<Object> k1 = (List<Object>)JSON.deserializeUntyped(responseJSON); 
		Map<String, Object> k = (Map<String, Object>)k1[0];

		if (Page != 'IdentityPage') {
			TF4SF__application__c a = new TF4SF__application__c();
			List<TF4SF__application__c> aList = new List<TF4SF__application__c>();

			if (k.get('success') == true) {
				a.Id = appId;
				a.App_Submitted_to_Alfa__c = true;
				aList.add(a);
			} else {
				a.Id = appId;
				a.App_Submitted_to_Alfa__c = false;
				aList.add(a);
			}

			if (aList.size() > 0) { update aList; }
			InsertDebugLog(appId, jsonBody, 'UpdateCoreAPP Request');
			InsertDebugLog(appId, responseJSON, 'UpdateCoreApp Response');
		}

		//Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
		// System.debug('m: '+m);
		return responseJson;
	}

	@future
	public static void InsertDebugLog (String appId, String json, String Callout) {
		List<TF4SF__Debug_Logs__c> debugList = new List<TF4SF__Debug_Logs__c>();
		TF4SF__Debug_Logs__c debug = new TF4SF__Debug_Logs__c();
		debug.TF4SF__Application__c = appId;
		debug.TF4SF__Debug_Message__c = json;
		debug.TF4SF__Source__c = Callout;
		debug.TF4SF__Timestamp__c = String.valueOf(System.now());
		debugList.add(debug);

		insert debugList;
	}

	global static string selectStar(String objectName) {
		SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
		DescribeSObjectResult objDef = objToken.getDescribe();
		Map<String, SObjectField> fields = objDef.fields.getMap(); 
		Set<String> fieldSet = fields.keySet();
		List<String> fieldsToQuery = new List<String>{};

		for (String fieldName : fieldSet) {
			SObjectField fieldToken = fields.get(fieldName);
			DescribeFieldResult selectedField = fieldToken.getDescribe();

			if (selectedField.isAccessible()) { //respect CRUD/FLS
				fieldsToQuery.add(selectedField.getName());
			} else {
				//System.debug('not accessible: ' + selectedField.getName());
			}
		}

		String queryString = 'SELECT ';
		queryString += String.join(fieldsToQuery, ', ');
		queryString += ' FROM ' + objectName + ' ';

		return querystring;
	}
}