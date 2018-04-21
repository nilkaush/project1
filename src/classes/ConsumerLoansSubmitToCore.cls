global class ConsumerLoansSubmitToCore {
    public static String JSONGenerator(Map<String, String> data) {
        TF4SF__Application__c app;
        TF4SF__Identity_Information__c iden;
        TF4SF__About_Account__c abtAcc;
        TF4SF__Employment_Information__c empInfo;
        KYC_OOW__c kycInfo;
        String applicationId = data.get('id');
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
            if (Database.query(kycQuery).size() > 0) {
                kycInfo = (KYC_OOW__c)Database.query(kycQuery);
            }
        }
        system.debug('identity: '+iden);
        //http_postMethod(jsonString);
        String template = '';
        template  ='[';
        template +=    '{';
        //template +=        '"id": "5d4178b8-0925-49e8-bd43-f693edf2881f",';
        template +=        '"id": "'+app.productId__c+'",';
        //if (app.TF4SF__Sub_Product__c != null && app.TF4SF__Sub_Product__c != '') {
        if (String.isNotBlank(app.TF4SF__Sub_Product__c)) {
            template +=        '"product_name": "' + app.TF4SF__Sub_Product__c + '",';
        }

        template +=        '"membership_eligibility": {';
        if (String.isNotBlank(app.TF4SF__Membership_Qualification_Type__c)) {
            template +=            '"question": "'+app.TF4SF__Membership_Qualification_Type__c+'",';
        }
        else {
            template +=                     '"question": null,';
        }
        if (String.isNotBlank(app.TF4SF__Membership_Qualification_Value__c)) {
            template +=             '"answer": "'+app.TF4SF__Membership_Qualification_Value__c+'"';
        }
        else {
            template +=             '"answer": "false"';
        }
        template +=        '},';
        template +=        '"applicants": [';
        template +=            '{';
        if (String.isNotBlank(data.get('Application__c.First_Name__c'))) {
            template +=                '"first_name": "'+ data.get('Application__c.First_Name__c')+'",';
        }
        else {
            template +=                '"first_name": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Middle_Name__c'))) {
            template +=                ',"middle_name": "'+ data.get('Application__c.Middle_Name__c')+'",';
        }
        else {
            template +=                '"middle_name": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Last_Name__c'))) {
            template +=                '"last_name": "'+ data.get('Application__c.Last_Name__c')+'",';
        }
        else {
            template +=                '"last_name": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Suffix_J__c'))) {
            template +=                '"suffix": "'+ data.get('Application__c.Suffix_J__c')+'",';
        }
        else {
            template +=                '"suffix": null,';
        }
        system.debug('SSN Prime: '+iden.TF4SF__SSN_Prime__c);
        if (String.isNotBlank(data.get('Identity_Information__c.SSN_Prime__c'))) {
            system.debug('entered ssnprime: '+data.get('Identity_Information__c.SSN_Prime__c'));
            template +=                '"federal_id": "'+ data.get('Identity_Information__c.SSN_Prime__c')+'",';
        }
        else if (String.isNotBlank(iden.TF4SF__SSN_Prime__c)) {
            //system.debug('entered ssnprime: '+data.get('Identity_Information__c.SSN_Prime__c'));
            template +=                '"federal_id": "'+ iden.TF4SF__SSN_Prime__c+'",';
        }
        else {
            template +=                '"federal_id": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Email_Address__c'))) {
            template +=                '"email_address": "'+ data.get('Application__c.Email_Address__c')+'",';
        }
        else {
            template +=                '"email_address": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Tertiary_Phone_Number__c'))) {
            template +=                '"home_phone_number": "'+ data.get('Application__c.Tertiary_Phone_Number__c')+'",';
        }
        else {
            template +=                '"home_phone_number": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Secondary_Phone_Number__c'))) {
            template +=                '"work_phone_number": "'+ data.get('Application__c.Secondary_Phone_Number__c')+'",';
        }
        else {
            template +=                '"work_phone_number": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Primary_Phone_Number__c'))) {
            template +=                '"mobile_phone_number": "'+ data.get('Application__c.Primary_Phone_Number__c')+'",';
        }
        else {
            template +=                '"mobile_phone_number": null,';
        }
        if (String.isNotBlank(data.get('Identity_Information__c.Date_of_Birth__c'))) {
            List<String> dob = data.get('Identity_Information__c.Date_of_Birth__c').split('/');
            template +=                '"birth_date": "'+ dob[2]+'-'+dob[1]+'-'+dob[0]+'",';
        }
        else {
            template +=                '"birth_date": null,';
        }
        
        //template +=                '"immigration_status": "'+ app.TF4SF__Sub_Product__c+'",';
        if (String.isBlank(data.get('Application__c.Member__c'))) {
            template +=                '"member": true,';
        }
        else {
            template +=                '"member": false,';
        }
        if (String.isNotBlank(data.get('Application__c.Person_Number__c'))) {
            template +=                '"member_id": "'+ data.get('Application__c.Person_Number__c')+'",';
        }
        else {
            template +=                '"member_id": null,';
        }
        
        //template +=                '"gender": "'+ app.TF4SF__Sub_Product__c+'",';
        //template +=                '"occupancy_status": "'+ app.TF4SF__Sub_Product__c+'",';
        template +=                '"occupancy_address": {';
        template +=                    '"address_lines": [';
        if (String.isNotBlank(data.get('Application__c.Street_Address_1__c'))) {
        //template +=                        '"595 East 4th St unit 3"';
            template +=                        '"'+data.get('Application__c.Street_Address_1__c')+'"';
        }
        else {
            template +=                        '"'+app.TF4SF__Street_Address_1__c+'"';
        }
        template +=                    '],';
        if (String.isNotBlank(data.get('Application__c.City__c'))) {
            template +=                    '"township": "'+ data.get('Application__c.City__c')+'",';
        }
        else {
            template +=                    '"township": null,';
        }
        if (String.isNotBlank(data.get('Application__c.State__c'))) {
            template +=                    '"state_code": "'+ data.get('Application__c.State__c')+'",';
        }
        else {
            template +=                    '"state_code": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Country__c'))) {
            template +=                    '"country_code": "'+ data.get('Application__c.Country__c')+'",';
        }
        else {
            template +=                    '"country_code": null,';
        }
        if (String.isNotBlank(data.get('Application__c.Zip_Code__c'))) {
            template +=                    '"zip_code": "'+ data.get('Application__c.Zip_Code__c')+'"';
        }
        else {
            template +=                    '"zip_code": null';
        }
        template +=                '},';
        if (String.isNotBlank(data.get('Application__c.Street_Address_1_Prev__c'))) {//previous address is null
            template +=                '"previous_occupancy_addresses": [';
            template +=                    '{';
            template +=                        '"address_lines": [';
            if (String.isNotBlank(data.get('Application__c.Street_Address_1_Prev__c'))) {
                //template +=                            '"59 East 10th St unit 1"';
                template +=                               '"'+data.get('Application__c.Street_Address_1_Prev__c')+'"';
            }

            else {
                template +=                               null;
            }
            if (String.isNotBlank(data.get('Application__c.Street_Address_1_Prev__c'))) {
                template +=                                '"'+data.get('Application__c.Street_Address_2_Prev__c')+'"';
            }
            template +=                        '],';
            if (String.isNotBlank(data.get('Application__c.City_Prev__c')))
                template +=                        '"township": "'+ data.get('Application__c.City_Prev__c')+'",';
            else {
                template +=                        '"township": null,';
            }
            if (String.isNotBlank(data.get('Application__c.State_Prev__c'))){
                template +=                        '"state_code": "'+ data.get('Application__c.State_Prev__c')+'",';
            }
            else {
                template +=                         '"state_code": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Zip_Code_Prev__c'))){
                template +=                        '"country_code": "'+ data.get('Application__c.Country_Prev__c')+'",';
            }
            else {
                template +=                        '"country_code": null,'; 
            }
            if (String.isNotBlank(data.get('Application__c.Zip_Code_Prev__c')))
                template +=                        '"zip_code": "'+ data.get('Application__c.Zip_Code_Prev__c')+'"';
            else {
                template +=                        '"zip_code": null';
            }
            template +=                    '}';
            template +=                '],';
        }//previous address is null
        if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1__c'))) {
            template +=                '"mailing_address": {';
            template +=                    '"address_lines": [';
            template +=                        '"'+data.get('Application__c.Mailing_Street_Address_1__c')+'"';
            template +=                    '],';
            if (String.isNotBlank(data.get('Application__c.Mailing_City__c'))) {
                template +=                    '"township": "'+ data.get('Application__c.Mailing_City__c')+'",';
            }
            else {
                template +=                    '"township": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Mailing_State__c'))) {
                template +=                    '"state_code": "'+ data.get('Application__c.Mailing_State__c')+'",';
            }
            else {
                template +=                    '"state_code": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Mailing_Country__c'))) {
                template +=                    '"country_code": "'+ data.get('Application__c.Mailing_Country__c')+'",';
            }
            else {
                template +=                    '"country_code": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Mailing_Zip_Code__c'))) {
                template +=                    '"zip_code": "'+ data.get('Application__c.Mailing_Zip_Code__c')+'"';
            }
            else {
                template +=                    '"zip_code": null';
            }
            template +=                '},';
        }//mailing address is null
        if(String.isNotBlank(data.get('Identity_Information__c.Identity_Number_Primary__c'))) {//Identification is not null
            template +=                '"identification_documents": [';
            template +=                    '{';
            if (String.isNotBlank(data.get('Identity_Information__c.ID_Type__c'))) {
                template +=                        '"type": "'+ data.get('Identity_Information__c.ID_Type__c')+'",';
            }
            else {
                template +=                        '"type": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_Primary__c'))) {
                template +=                        '"id": "'+ data.get('Identity_Information__c.Identity_Number_Primary__c')+'",';
            }
            else {
                template +=                        '"id": "null",';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.State_Issued__c'))) {
                template +=                        '"state_code": "'+ data.get('Identity_Information__c.State_Issued__c')+'",';
            }
            else {
                template +=                        '"state_code": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.Expiry_Date__c'))) {
                List<String> dt = data.get('Identity_Information__c.Expiry_Date__c').split('/');
                template +=                        '"expiration_date": "'+ dt[2]+'-'+dt[1]+'-'+dt[0]+'",';
            }
            else {
                template +=                        '"expiration_date": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.Issue_Date__c'))) {
                List<String> dt = data.get('Identity_Information__c.Issue_Date__c').split('/');
                template +=                        '"issue_date": "'+ dt[2]+'-'+dt[1]+'-'+dt[0]+'"';
            }
            else {
                template +=                        '"issue_date": null';   
            }
            template +=                    '}';
            template +=                '],';
        }//Identification is not null
        if (kycinfo != null) {
           // if (String.isNotBlank(kycInfo.Question_1_Response__c)) {
                template +=                '"question_answers": [';
                template +=                    '{';
                if (String.isNotBlank(kycInfo.Question_1_Text__c)) {
                    template +=                        '"question_name": "'+kycInfo.Question_1_Text__c+'",';
                }
                else {
                    template +=                         '"question_name": null,';
                }
                if (String.isNotBlank(kycInfo.Question_1_Response__c)) {
                    template +=                        '"answer": "'+kycInfo.Question_1_Response__c+'"';
                }
                else {
                    template +=                        '"answer": "null"';
                }
                template +=                    '},';
                template +=                    '{';
                if (String.isNotBlank(kycInfo.Question_2_Text__c)) {
                    template +=                        '"question_name": "'+kycInfo.Question_2_Text__c+'",';
                }
                else {
                    template +=                         '"question_name": "null",';
                }
                if (String.isNotBlank(kycInfo.Question_2_Response__c)) {
                    template +=                        '"answer": "'+kycInfo.Question_2_Response__c+'"';
                }
                else {
                    template +=                        '"answer": "null"';
                }
                template +=                    '},';
                template +=                    '{';
                if (String.isNotBlank(kycInfo.Question_3_Text__c)) {
                    template +=                        '"question_name": "'+kycInfo.Question_3_Text__c+'",';
                }
                else {
                    template +=                         '"question_name": null,';
                }
                if (String.isNotBlank(kycInfo.Question_3_Response__c)) {
                    template +=                        '"answer": "'+kycInfo.Question_3_Response__c+'"';
                }
                else {
                    template +=                        '"answer": "null"';
                }
                template +=                    '}';
                template +=                  '],';
           // }
        }
        template +=                '"financials": {';
        if (data.get('Employment_Information__c.Annual_Income__c') != null) {
            String aInc = String.valueOf(Integer.valueOf(data.get('Employment_Information__c.Annual_Income__c'))/12);
            template +=                    '"monthly_income": "'+ aInc+'",';
        }
        else {
            template +=                    '"monthly_income": null,';
        }
        //  if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
        //    template +=                    '"monthly_liability": "'+ app.TF4SF__Sub_Product__c+'",';
        if (String.isNotBlank(data.get('Employment_Information__c.Employment_Status__c'))) {
            template +=                    '"employment_status": "'+ data.get('Employment_Information__c.Employment_Status__c')+'",';
        }
        else {
            template +=                    '"employment_status": null';
        }
        if (String.isNotBlank(data.get('Employment_Information__c.Occupation__c'))) {
            template +=                    ',"employment": [';
            template +=                        '{';
            if (String.isNotBlank(data.get('Employment_Information__c.Occupation__c'))) {
                template +=                            '"title": "'+ data.get('Employment_Information__c.Occupation__c')+'",';
            }
           // else {
            //    template +=                            '"title": null,';
           // }
             
            if (String.isNotBlank(data.get('Application__c.Custom_Text4__c'))) {
                template +=                            '"employer": "'+ data.get('Application__c.Custom_Text4__c')+'",';
            }
            //else {
              //  template +=                            '"employer": null,';
            //}
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
        }
        template +=                '}';
        if(String.isNotBlank(data.get('Identity_Information__c.SSN_J1__c'))) {
            template +=            '},';
        }
        else {
            template += '}';
        }
         // template +=            '},';
         //applicant2 start Aug 6
         if(String.isNotBlank(data.get('Identity_Information__c.SSN_J1__c'))){//japp1 is null
            template +=            '{';
            if (String.isNotBlank(data.get('Application__c.First_Name_J__c'))) {
                template +=                '"first_name": "'+ data.get('Application__c.First_Name_J__c')+'",';
            }
            else {
                template +=                '"first_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Middle_Name_J__c'))) {
                template +=                ',"middle_name": "'+ data.get('Application__c.Middle_Name_J__c')+'",';
            }
            else {
                template +=                '"middle_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Last_Name_J__c'))) {
                template +=                '"last_name": "'+ data.get('Application__c.Last_Name_J__c')+'",';
            }
            else {
                template +=                '"last_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Suffix_J__c'))) {
                template +=                '"suffix": "'+ data.get('Application__c.Suffix_J__c')+'",';
            }
            else {
                template +=                '"suffix": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.SSN_J1__c'))) {
                template +=                '"federal_id": "'+ data.get('Identity_Information__c.SSN_J1__c')+'",';
            }
            else {
                template +=                '"federal_id": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Email_Address_J__c'))) {
                template +=                '"email_address": "'+ data.get('Application__c.Email_Address_J__c')+'",';
            }
            else {
                template +=                '"email_address": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Tertiary_Phone_Number_J1__c'))) {
                template +=                '"home_phone_number": "'+ data.get('Application__c.Tertiary_Phone_Number_J1__c')+'",';
            }
            else {
                template +=                '"home_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Secondary_Phone_Number_J__c'))) {
                template +=                '"work_phone_number": "'+ data.get('Application__c.Secondary_Phone_Number_J__c')+'",';
            }
            else {
                template +=                '"work_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Primary_Phone_Number_J__c'))) {
                template +=                '"mobile_phone_number": "'+ data.get('Application__c.Primary_Phone_Number_J__c')+'",';
            }
            else {
                template +=                '"mobile_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.Date_of_Birth_J1__c'))) {
                List<String> dob1 = data.get('Identity_Information__c.Date_of_Birth_J1__c').split('/');
                template +=                '"birth_date": "'+ dob1[2]+'-'+dob1[1]+'-'+dob1[0]+'",';
            }
            else {
                template +=                '"birth_date": "0000-00-00",';
            }
            
            //template +=                '"immigration_status": "'+ app.TF4SF__Sub_Product__c+'",';
            if (String.isBlank(data.get('Application__c.Member__c'))) {
                template +=                '"member": true,';
            }
            else {
                template +=                '"member": false,';
            }
            if (String.isNotBlank(data.get('Application__c.Person_Number__c'))) {
                template +=                '"member_id": "'+ data.get('Application__c.Person_Number__c')+'",';
            }
            else {
                template +=                '"member_id": null,';
            }
            
            //template +=                '"gender": "'+ app.TF4SF__Sub_Product__c+'",';
            //template +=                '"occupancy_status": "'+ app.TF4SF__Sub_Product__c+'",';
            template +=                '"occupancy_address": {';
            template +=                    '"address_lines": [';
            template +=                        '"'+data.get('Application__c.Street_Address_J__c')+'"';
            template +=                    '],';
            if (String.isNotBlank(data.get('Application__c.City_J__c'))) {
                template +=                    '"township": "'+ data.get('Application__c.City_J__c')+'",';
            }
            else {
                template +=                    '"township": null,';
            }
            if (String.isNotBlank(data.get('Application__c.State_J__c'))) {
                template +=                    '"state_code": "'+ data.get('Application__c.State_J__c')+'",';
            }
            else {
                template +=                    '"state_code": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Country_J1__c'))) {
                template +=                    '"country_code": "'+ data.get('Application__c.Country_J1__c')+'",';
            }
            else {
                template +=                    '"country_code": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Zip_Code_J__c'))) {
                template +=                    '"zip_code": "'+ data.get('Application__c.Zip_Code_J__c')+'"';
            }
            else {
                template +=                    '"zip_code": null';
            }
            template +=                '},';
            if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP__c'))) {//previous address is null
                template +=                '"previous_occupancy_addresses": [';
                template +=                    '{';
                template +=                        '"address_lines": [';
                template +=                            '"'+data.get('Application__c.Street_Address_1_JP__c')+'"';
                template +=                        '],';
                if (String.isNotBlank(data.get('Application__c.City_JP__c')))
                    template +=                        '"township": "'+ data.get('Application__c.City_JP__c')+'",';
                else {
                    template +=                        '"township": null,';
                }
                if (String.isNotBlank(data.get('Application__c.State_JP__c'))){
                    template +=                        '"state_code": "'+ data.get('Application__c.State_JP__c')+'",';
                }
                else {
                    template +=                         '"state_code": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Country_JP1__c'))){
                    template +=                        '"country_code": "'+ data.get('Application__c.Country_JP1__c')+'",';
                }
                else {
                    template +=                        '"country_code": null,'; 
                }
                if (String.isNotBlank(data.get('Application__c.Zip_Code_JP__c')))
                    template +=                        '"zip_code": "'+ data.get('Application__c.Zip_Code_JP__c')+'"';
                else {
                    template +=                        '"zip_code": null';
                }
                template +=                    '}';
                template +=                '],';
            } //previous address is null
            if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP__c'))) {//Mailing address is null
                template +=                '"mailing_address": {';
                template +=                    '"address_lines": [';
                template +=                        '"'+data.get('Application__c.Street_Address_1_JP__c')+'"';
                template +=                    '],';
                if (String.isNotBlank(data.get('Application__c.Mailing_City_J1__c'))) {
                    template +=                    '"township": "'+ data.get('Application__c.Mailing_City_J1__c')+'",';
                }
                else {
                    template +=                    '"township": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_State_J1__c'))) {
                    template +=                    '"state_code": "'+ data.get('Application__c.Mailing_State_J1__c')+'",';
                }
                else {
                    template +=                    '"state_code": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_Country_J1__c'))) {
                    template +=                    '"country_code": "'+ data.get('Application__c.Mailing_Country_J1__c')+'",';
                }
                else {
                    template +=                    '"country_code": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_Zip_Code_J1__c'))) {
                    template +=                    '"zip_code": "'+ data.get('Application__c.Mailing_Zip_Code_J1__c')+'"';
                }
                else {
                    template +=                    '"zip_code": null';
                }
                template +=                '},';
            }//Mailing address is null
            if (String.isNotBlank(data.get('Identification_Information__c.Identity_Number_J1__c'))) {//Identification Information is null
                template +=                '"identification_documents": [';
                template +=                    '{';
                if (String.isNotBlank(data.get('Identification_Information__c.ID_Type_J1__c'))) {
                    template +=                        '"type": "'+ data.get('Identification_Information__c.ID_Type_J1__c')+'",';
                }
                else {
                    template +=                        '"type": "null",';
                }
                if (String.isNotBlank(data.get('Identification_Information__c.Identity_Number_J1__c'))) {
                    template +=                        '"id": "'+ data.get('Identification_Information__c.Identity_Number_J1__c')+'",';
                }
                else {
                    template +=                        '"id": "null",';
                }
                if (String.isNotBlank(data.get('Identification_Information__c.State_Issued_J1__c'))) {
                    template +=                        '"state_code": "'+ data.get('Identification_Information__c.State_Issued_J1__c')+'",';
                }
                else {
                    template +=                        '"state_code": null,';
                }
                if (String.isNotBlank(data.get('Identification_Information__c.Expiry_Date_J1__c'))) {
                    List<String> dt = data.get('Identification_Information__c.Expiry_Date_J1__c').split('/');
                    template +=                        '"expiration_date": "'+ dt[2]+'-'+dt[1]+'-'+dt[0]+'",';
                }
                else {
                    template +=                        '"expiration_date": null,';
                }
                if (String.isNotBlank(data.get('Identification_Information__c.Issue_Date_J1__c'))) {
                    template +=                        '"issue_date": "'+ data.get('Identification_Information__c.Issue_Date_J1__c')+'"';
                }
                else {
                    template +=                        '"issue_date": null';   
                }
                template +=                    '}';
                template +=                '],';
            }//Identification Information is null
           /* template +=                '"question_answers": [';
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
            template +=                  '],';*/
            template +=                '"financials": {';
            if (data.get('Employment_Information__c.Annual_Income_J1__c') != null) {
                String aInc = String.valueOf(Integer.valueOf(data.get('Employment_Information__c.Annual_Income_J1__c'))/12);
                template +=                    '"monthly_income": "'+ aInc+'",';
            }
            else {
                template +=                    '"monthly_income": null,';
            }
            //  if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
            //    template +=                    '"monthly_liability": "'+ app.TF4SF__Sub_Product__c+'",';
            if (String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J1__c'))) {
                template +=                    '"employment_status": "'+ data.get('Employment_Information__c.Employment_Status_J1__c')+'",';
            }
            else {
                template +=                    '"employment_status": null';
            }
            if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J1__c'))) {
                template +=                    '"employment": [';
                template +=                        '{';
                if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J1__c'))) {
                    template +=                            '"title": "'+ data.get('Employment_Information__c.Occupation_J1__c')+'",';
                }
                
                 // if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
                //    template +=                            '"start_date": "'+ app.TF4SF__Sub_Product__c+'",';
                if (String.isNotBlank(data.get('Employment_Information__c.Employer_J1__c'))) {
                    template +=                            '"employer": "'+ data.get('Employment_Information__c.Employer_J1__c')+'",';
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
            }  
            template +=                '}';
            if(String.isNotBlank(data.get('Identity_Information__c.SSN_J2__c'))) {
                template +=            '},';
            }
            else {
                template += '}';
            }
        }//japp1 is null ends
         //applicant2 end aug 6
         //applicant3 start aug6
        if(String.isNotBlank(data.get('Identity_Information__c.SSN_J2__c'))) {//japp2 is not null
            template +=            '{';
            if (String.isNotBlank(data.get('Application__c.First_Name_J2__c'))) {
                template +=                '"first_name": "'+ data.get('Application__c.First_Name_J2__c')+'",';
            }
            else {
                template +=                '"first_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Middle_Name_J2__c'))) {
                template +=                ',"middle_name": "'+ data.get('Application__c.Middle_Name_J2__c')+'",';
            }
            else {
                template +=                '"middle_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Last_Name_J2__c'))) {
                template +=                '"last_name": "'+ data.get('Application__c.Last_Name_J2__c')+'",';
            }
            else {
                template +=                '"last_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Suffix_J2__c'))) {
                template +=                '"suffix": "'+ data.get('Application__c.Suffix_J2__c')+'",';
            }
            else {
                template +=                '"suffix": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.SSN_J2__c'))) {
                template +=                '"federal_id": "'+ data.get('Identity_Information__c.SSN_J2__c')+'",';
            }
            else {
                template +=                '"federal_id": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Email_Address_J2__c'))) {
                template +=                '"email_address": "'+ data.get('Application__c.Email_Address_J2__c')+'",';
            }
            else {
                template +=                '"email_address": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Tertiary_Phone_Number_J2__c'))) {
                template +=                '"home_phone_number": "'+ data.get('Application__c.Tertiary_Phone_Number_J2__c')+'",';
            }
            else {
                template +=                '"home_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Secondary_Phone_Number_J2__c'))) {
                template +=                '"work_phone_number": "'+ data.get('Application__c.Secondary_Phone_Number_J2__c')+'",';
            }
            else {
                template +=                '"work_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Primary_Phone_Number_J2__c'))) {
                template +=                '"mobile_phone_number": "'+ data.get('Application__c.Primary_Phone_Number_J2__c')+'",';
            }
            else {
                template +=                '"mobile_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.TF4SF__Date_of_Birth_J2__c'))) {
                List<String> dob2 = data.get('Identity_Information__c.Date_of_Birth_J2__c').split('/');
                template +=                '"birth_date": "'+ dob2[2]+'-'+dob2[1]+'-'+dob2[0]+'",';
            }
            else {
                template +=                '"birth_date": null,';
            }
            
            //template +=                '"immigration_status": "'+ app.TF4SF__Sub_Product__c')+'",';
            if (String.isBlank(data.get('Application__c.Member__c'))) {
                template +=                '"member": true,';
            }
            else {
                template +=                '"member": false,';
            }
            if (String.isNotBlank(data.get('Application__c.Person_Number__c'))) {
                template +=                '"member_id": "'+ data.get('Application__c.Person_Number__c')+'",';
            }
            else {
                template +=                '"member_id": null,';
            }
            
            //template +=                '"gender": "'+ app.TF4SF__Sub_Product__c+'",';
            //template +=                '"occupancy_status": "'+ app.TF4SF__Sub_Product__c+'",';
            template +=                '"occupancy_address": {';
            template +=                    '"address_lines": [';
            template +=                        '"'+data.get('Application__c.Street_Address_1_JP2__c')+'"';
            template +=                    ']';
            if (String.isNotBlank(data.get('Application__c.City_J2__c'))) {
                template +=                    ',"township": "'+ data.get('Application__c.City_J2__c')+'"';
            }
            else {
                template +=                    ',"township": null';
            }
            if (String.isNotBlank(data.get('Application__c.State_J2__c'))) {
                template +=                    ',"state_code": "'+ data.get('Application__c.State_J2__c')+'"';
            }
            else {
                template +=                    ',"state_code": null';
            }
            if (String.isNotBlank(data.get('Application__c.Country_J2__c'))) {
                template +=                    ',"country_code": "'+ data.get('Application__c.Country_J2__c')+'"';
            }
            else {
                template +=                    ',"country_code": null';
            }
            if (String.isNotBlank(data.get('Application__c.Zip_Code_J2__c'))) {
                template +=                    ',"zip_code": "'+ data.get('Application__c.Zip_Code_J2__c')+'"';
            }
            else {
                template +=                    ',"zip_code": null';
            }
            template +=                '},';
            if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP2__c'))) {//previous address is null
                template +=                '"previous_occupancy_addresses": [';
                template +=                    '{';
                template +=                        '"address_lines": [';
                template +=                            '"'+data.get('Application__c.Street_Address_1_JP2__c')+'"';
                template +=                        '],';
                if (String.isNotBlank(data.get('Application__c.City_JP2__c')))
                    template +=                        '"township": "'+ data.get('Application__c.City_JP2__c')+'",';
                else {
                    template +=                        '"township": null,';
                }
                if (String.isNotBlank(data.get('Application__c.State_JP2__c'))){
                    template +=                        '"state_code": "'+ data.get('Application__c.State_JP2__c')+'",';
                }
                else {
                    template +=                         '"state_code": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Zip_Code_JP2__c'))){
                    template +=                        '"country_code": "'+ data.get('Application__c.Country_JP2__c')+'",';
                }
                else {
                    template +=                        '"country_code": null,'; 
                }
                if (String.isNotBlank(data.get('Application__c.Zip_Code_JP2__c')))
                    template +=                        '"zip_code": "'+ data.get('Application__c.Zip_Code_JP2__c')+'"';
                else {
                    template +=                        '"zip_code": null';
                }
                template +=                    '}';
                template +=                '],';
            }//previous address is null
            if (String.isNotBlank(data.get('Application__c.Mailing_Street_Address_1_J2__c'))) {//mailing address is null
                template +=                '"mailing_address": {';
                template +=                    '"address_lines": [';
                template +=                        '"'+data.get('Application__c.Mailing_Street_Address_1_J2__c')+'"';
                template +=                    '],';
                if (String.isNotBlank(data.get('Application__c.Mailing_City_J2__c'))) {
                    template +=                    '"township": "'+ data.get('Application__c.Mailing_City_J2__c')+'",';
                }
                else {
                    template +=                    '"township": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_State_J2__c'))) {
                    template +=                    '"state_code": "'+ data.get('Application__c.Mailing_State_J2__c')+'",';
                }
                else {
                    template +=                    '"state_code": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_Country_J2__c'))) {
                    template +=                    '"country_code": "'+ data.get('Application__c.Mailing_Country_J2__c')+'",';
                }
                else {
                    template +=                    '"country_code": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_Zip_Code_J2__c'))) {
                    template +=                    '"zip_code": "'+ data.get('Application__c.Mailing_Zip_Code_J2__c')+'"';
                }
                else {
                    template +=                    '"zip_code": null';
                }
                template +=                '},';
            }//mailing address is null
            if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J2__c'))) {//Identification Documents is null
                template +=                '"identification_documents": [';
                template +=                    '{';
                if (String.isNotBlank(data.get('Identity_Information__c.ID_Type_J2__c'))) {
                    template +=                        '"type": "'+ data.get('Identity_Information__c.ID_Type_J2__c')+'",';
                }
                else {
                    template +=                        '"type": "null",';
                }
                if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J2__c'))) {
                    template +=                        '"id": "'+ data.get('Identity_Information__c.Identity_Number_J2__c')+'",';
                }
                else {
                    template +=                        '"id": "null",';
                }
                if (String.isNotBlank(data.get('Identity_Information__c.State_Issued_J2__c'))) {
                    template +=                        '"state_code": "'+ data.get('Identity_Information__c.State_Issued_J2__c')+'",';
                }
                else {
                    template +=                        '"state_code": "null",';
                }
                if (String.isNotBlank(data.get('Identity_Information__c.Expiry_Date_J2__c'))) {
                    List<String> dt = data.get('Identity_Information__c.Expiry_Date_J2__c').split('/');
                    template +=                        '"expiration_date": "'+ dt[2]+'-'+dt[1]+'-'+dt[0]+'",';
                }
                else {
                    template +=                        '"expiration_date": null,';
                }
                if (String.isNotBlank(data.get('Identity_Information__c.Issue_Date_J2__c'))) {
                    List<String> dt = data.get('Identity_Information__c.Issue_Date_J2__c').split('/');
                    template +=                        '"issue_date": "'+ dt[2]+'-'+dt[1]+'-'+dt[0]+'"';
                }
                else {
                    template +=                        '"issue_date": null';   
                }
                template +=                    '}';
                template +=                '],';
            }//Identification documents is null
           /* template +=                '"question_answers": [';
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
            template +=                  '],';*/
            template +=                '"financials": {';
            if (data.get('Employment_Information__c.Annual_Income_J2__c') != null) {
                String aInc = String.valueOf(Integer.valueOf(data.get('Employment_Information__c.Annual_Income_J2__c'))/12);
                template +=                    '"monthly_income": "'+ aInc+'",';
            }
            else {
                template +=                    '"monthly_income": 100.0,';
            }
            //  if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
            //    template +=                    '"monthly_liability": "'+ app.TF4SF__Sub_Product__c+'",';
            if (String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J2__c'))) {
                template +=                    '"employment_status": "'+ data.get('Employment_Information__c.Employment_Status_J2__c')+'",';
            }
            else {
                template +=                    '"employment_status": null';
            }
            if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J2__c'))) {
                template +=                    '"employment": [';
                template +=                        '{';
                if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J2__c'))) {
                    template +=                            '"title": "'+ data.get('Employment_Information__c.Occupation_J2__c')+'",';
                }
                
                 // if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
                //    template +=                            '"start_date": "'+ app.TF4SF__Sub_Product__c+'",';
                if (String.isNotBlank(data.get('Employment_Information__c.Employer_J2__c'))) {
                    template +=                            '"employer": "'+ data.get('Employment_Information__c.Employer_J2__c')+'",';
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
            }
            template +=                '}';
            if(String.isNotBlank(data.get('Identity_Information__c.SSN_J3__c'))) {
                template +=            '},';
            }
            else {
                template += '}';
            }
        }//japp2 is not null ends
         //applicant3 end aug6
        //japplicant4 start
        if(String.isNotBlank(data.get('Identity_Information__c.SSN_J3__c'))) {//japp3 is not null
            template +=            '{';
            if (String.isNotBlank(data.get('Application__c.First_Name_J3__c'))) {
                template +=                '"first_name": "'+ data.get('Application__c.First_Name_J3__c')+'",';
            }
            else {
                template +=                '"first_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Middle_Name_J3__c'))) {
                template +=                ',"middle_name": "'+ data.get('Application__c.Middle_Name_J3__c')+'",';
            }
            else {
                template +=                '"middle_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Last_Name_J3__c'))) {
                template +=                '"last_name": "'+ data.get('Application__c.Last_Name_J3__c')+'",';
            }
            else {
                template +=                '"last_name": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Suffix_J3__c'))) {
                template +=                '"suffix": "'+ data.get('Application__c.Suffix_J3__c')+'",';
            }
            else {
                template +=                '"suffix": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.SSN_J3__c'))) {
                template +=                '"federal_id": "'+ data.get('Identity_Information__c.SSN_J3__c')+'",';
            }
            else {
                template +=                '"federal_id": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Email_Address_J3__c'))) {
                template +=                '"email_address": "'+ data.get('Application__c.Email_Address_J3__c')+'",';
            }
            else {
                template +=                '"email_address": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Tertiary_Phone_Number_J3__c'))) {
                template +=                '"home_phone_number": "'+ data.get('Application__c.Tertiary_Phone_Number_J3__c')+'",';
            }
            else {
                template +=                '"home_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Secondary_Phone_Number_JP3__c'))) {
                template +=                '"work_phone_number": "'+ data.get('Application__c.Secondary_Phone_Number_JP3__c')+'",';
            }
            else {
                template +=                '"work_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Primary_Phone_Number_J3__c'))) {
                template +=                '"mobile_phone_number": "'+ data.get('Application__c.Primary_Phone_Number_J3__c')+'",';
            }
            else {
                template +=                '"mobile_phone_number": null,';
            }
            if (String.isNotBlank(data.get('Identity_Information__c.Date_of_Birth_J3__c'))) {
                List<String> dob3 = data.get('Identity_Information__c.Date_of_Birth_J3__c').split('/');
                template +=                '"birth_date": "'+ dob3[2]+'-'+dob3[1]+'-'+dob3[0]+'",';
            }
            else {
                template +=                '"birth_date": "0000-00-00",';
            }
            
            //template +=                '"immigration_status": "'+ app.TF4SF__Sub_Product__c+'",';
            if (String.isNotBlank(data.get('Application__c.Member__c'))) {
                template +=                '"member": true,';
            }
            else {
                template +=                '"member": false,';
            }
            if (String.isNotBlank(data.get('Application__c.Person_Number__c'))) {
                template +=                '"member_id": "'+ data.get('Application__c.Person_Number__c')+'",';
            }
            else {
                template +=                '"member_id": null,';
            }
            
            //template +=                '"gender": "'+ app.TF4SF__Sub_Product__c+'",';
            //template +=                '"occupancy_status": "'+ app.TF4SF__Sub_Product__c+'",';
            template +=                '"occupancy_address": {';
            template +=                    '"address_lines": [';
            template +=                        '"'+data.get('Application__c.Street_Address_1_J3__c')+'"';
            template +=                    '],';
            if (String.isNotBlank(data.get('Application__c.City_J3__c'))) {
                template +=                    '"township": "'+ data.get('Application__c.City_J3__c')+'",';
            }
            else {
                template +=                    '"township": null,';
            }
            if (String.isNotBlank(data.get('Application__c.State_J3__c'))) {
                template +=                    '"state_code": "'+ data.get('Application__c.State_J3__c')+'",';
            }
            else {
                template +=                    '"state_code": null,';
            }
            if (String.isNotBlank(data.get('Application__c.Country_J3__c'))) {
                template +=                    '"country_code": "'+ data.get('Application__c.Country_J3__c')+'",';
            }
            else {
                template +=                    '"country_code": null,';
            }
            if (String.isNotblank(data.get('Application__c.Zip_Code_J3__c'))) {
                template +=                    '"zip_code": "'+ data.get('Application__c.Zip_Code_J3__c')+'",';
            }
            else {
                template +=                    '"zip_code": null';
            }
            template +=                '},';
            if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP3__c'))) {//previous address is null
                template +=                '"previous_occupancy_addresses": [';
                template +=                    '{';
                template +=                        '"address_lines": [';
                template +=                            '"'+data.get('Application__c.Street_Address_1_JP3__c')+'"';
                template +=                        '],';
                if (String.isNotBlank(app.TF4SF__City_JP3__c))
                    template +=                        '"township": "'+ data.get('Application__c.City_JP3__c')+'",';
                else {
                    template +=                        '"township": null,';
                }
                if (String.isNotBlank(app.TF4SF__State_JP3__c)){
                    template +=                        '"state_code": "'+ data.get('Application__c.State_JP3__c')+'",';
                }
                else {
                    template +=                         '"state_code": null,';
                }
                if (String.isNotBlank(app.TF4SF__Zip_Code_JP3__c)){
                    template +=                        '"country_code": "'+ data.get('Application__c.Country_JP3__c')+'",';
                }
                else {
                    template +=                        '"country_code": null,'; 
                }
                if (String.isNotBlank(app.TF4SF__Zip_Code_JP3__c))
                    template +=                        '"zip_code": "'+ data.get('Application__c.Zip_Code_JP3__c')+'"';
                else {
                    template +=                        '"zip_code": null';
                }
                template +=                    '}';
                template +=                '],';
            }//previous address is null
            if (String.isNotBlank(data.get('Application__c.Street_Address_1_JP3__c'))) {//mailing address is null
                template +=                '"mailing_address": {';
                template +=                    '"address_lines": [';
                template +=                        '"595 East 4th St unit 4"';
                template +=                    '],';
                if (String.isNotBlank(data.get('Application__c.Mailing_City_J3__c'))) {
                    template +=                    '"township": "'+ data.get('Application__c.Mailing_City_J3__c')+'",';
                }
                else {
                    template +=                    '"township": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_State_J3__c'))) {
                    template +=                    '"state_code": "'+ data.get('Application__c.Mailing_State_J3__c')+'",';
                }
                else {
                    template +=                    '"state_code": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_Country_J3__c'))) {
                    template +=                    '"country_code": "'+ data.get('Application__c.Mailing_Country_J3__c')+'",';
                }
                else {
                    template +=                    '"country_code": null,';
                }
                if (String.isNotBlank(data.get('Application__c.Mailing_Zip_Code_J3__c'))) {
                    template +=                    '"zip_code": "'+ data.get('Application__c.Mailing_Zip_Code_J3__c')+'"';
                }
                else {
                    template +=                    '"zip_code": null';
                }
                template +=                '},';
            }//mailing address is null
            if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J3__c'))) {//Identification Documents is null
                template +=                '"identification_documents": [';
                template +=                    '{';
                if (String.isNotBlank(data.get('Identity_Information__c.ID_Type_J3__c'))) {
                    template +=                        '"type": "'+ data.get('Identity_Information__c.ID_Type_J3__c')+'",';
                }
                else {
                    template +=                        '"type": "null",';
                }
                if (String.isNotBlank(data.get('Identity_Information__c.Identity_Number_J3__c'))) {
                    template +=                        '"id": "'+ data.get('Identity_Information__c.Identity_Number_J3__c')+'",';
                }
                else {
                    template +=                        '"id": "null",';
                }
                if (String.isNotBlank(data.get('Identity_Information__c.State_Issued_J3__c'))) {
                    template +=                        '"state_code": "'+ data.get('Identity_Information__c.State_Issued_J3__c')+'",';
                }
                else {
                    template +=                        '"state_code": "null",';
                }
                if (String.isNotBlank(data.get('Identity_Information__c.Expiry_Date_J3__c'))) {
                    List<String> dt = data.get('Identity_Information__c.Expiry_Date_J3__c').split('/');
                    template +=                        '"expiration_date": "'+ dt[2]+'-'+dt[1]+'-'+dt[0]+'",';
                }
                
                if (String.isNotBlank(data.get('Identity_Information__c.Issue_Date_J3__c'))) {
                    List<String> dt = data.get('Identity_Information__c.Issue_Date_J3__c').split('/');
                    template +=                        '"issue_date": "'+ dt[2]+'-'+dt[1]+'-'+dt[0]+'"';
                }
                
                template +=                    '}';
                template +=                '],';
            }//Identification Documents is null
           /* template +=                '"question_answers": [';
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
            template +=                  '],';*/
            template +=                '"financials": {';
            if (data.get('Employment_Information__c.Annual_Income_J3__c') != null) {
                String aInc = String.valueOf(Integer.valueOf(data.get('Employment_Information__c.Annual_Income_J3__c'))/12);
                template +=                    '"monthly_income": "'+ aInc+'",';
            }
            else {
                template +=                    '"monthly_income": 100.0,';
            }
            //  if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
            //    template +=                    '"monthly_liability": "'+ app.TF4SF__Sub_Product__c+'",';
            if (String.isNotBlank(data.get('Employment_Information__c.Employment_Status_J3__c'))) {
                template +=                    '"employment_status": "'+ data.get('Employment_Information__c.Employment_Status_J3__c')+'",';
            }
            else {
                template +=                    '"employment_status": null';
            }
            if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J3__c'))) {
                template +=                    '"employment": [';
                template +=                        '{';
                if (String.isNotBlank(data.get('Employment_Information__c.Occupation_J3__c'))) {
                    template +=                            '"title": "'+ data.get('Employment_Information__c.Occupation_J3__c')+'",';
                }
                

                 // if (app.TF4SF__First_Name__c != null && app.TF4SF__First_Name__c != null)
                //    template +=                            '"start_date": "'+ app.TF4SF__Sub_Product__c+'",';
                if (String.isNotBlank(data.get('Employment_Information__c.Employer_J3__c'))) {
                    template +=                            '"employer": "'+ data.get('Employment_Information__c.Employer_J3__c')+'",';
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
            }
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
            if (String.isNotBlank(data.get('About_Account__c.Account_type_FI_CHK__c'))) {
                template +=            '"source_bank_account_type": "'+ data.get('About_Account__c.Account_type_FI_CHK__c')+'",';
            }
            else {
                template +=            '"source_bank_account_type": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.Account_Holder_Name_CHK__c'))) {
                template +=            '"source_name_on_card": "'+ data.get('About_Account__c.Account_Holder_Name_CHK__c')+'",';
            }
            else {
                template +=            '"source_name_on_card": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.CHK_Account_Number__c'))) {
                template +=            '"source_bank_account_number": "'+ data.get('About_Account__c.CHK_Account_Number__c')+'",';
            }
            else {
                template +=            '"source_bank_account_number": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.Routing_Number_CHK__c'))) {
                template +=            '"source_bank_routing_number": "'+ data.get('About_Account__c.Routing_Number_CHK__c')+'",';
            }
            else {
                template +=            '"source_bank_routing_number": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.Financial_Institution_CHK__c'))) {
                template +=            '"source_bank_name": "'+ data.get('About_Account__c.Financial_Institution_CHK__c')+'",';
            }
            else {
                template +=            '"source_bank_name": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.State__c'))) {
                template +=            '"source_bank_state_code": "'+ data.get('About_Account__c.State__c')+'",';
            }
            else {
                template +=            '"source_bank_state_code": null,';
            }
        }
        if (app.TF4SF__Sub_Product__c.contains('Saving')) {
            if (String.isNotBlank(data.get('About_Account__c.Account_Type_FI_Sav__c'))) {
                template +=            '"source_bank_account_type": "'+ data.get('About_Account__c.Account_Type_FI_Sav__c')+'",';
            }
            else {
                template +=            '"source_bank_account_type": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.TF4SF__Account_Holder_Name_SAV__c'))) {
                template +=            '"source_name_on_card": "'+ data.get('About_Account__c.TF4SF__Account_Holder_Name_SAV__c')+'",';
            }
            else {
                template +=            '"source_name_on_card": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.TF4SF__SAV_Account_Number__c'))) {
                template +=            '"source_bank_account_number": "'+ data.get('About_Account__c.TF4SF__SAV_Account_Number__c')+'",';
            }
            else {
                template +=            '"source_bank_account_number": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.TF4SF__Routing_Number_Sav__c'))) {
                template +=            '"source_bank_routing_number": "'+ data.get('About_Account__c.TF4SF__Routing_Number_Sav__c')+'",';
            }
            else {
                template +=            '"source_bank_routing_number": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.TF4SF__Financial_Institution_SAV__c'))) {
                template +=            '"source_bank_name": "'+ data.get('About_Account__c.TF4SF__Financial_Institution_SAV__c')+'",';
            }
            else {
                template +=            '"source_bank_name": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.TF4SF__State__c'))) {
                template +=            '"source_bank_state_code": "'+ data.get('About_Account__c.TF4SF__State__c')+'",';
            }
            else {
                template +=            '"source_bank_state_code": null,';
            }
        }
        if (app.TF4SF__Sub_Product__c.contains('Time Deposits')) {
            if (String.isNotBlank(data.get('About_Account__c.TF4SF__Account_Type_FI_Cert__c'))) {
                template +=            '"source_bank_account_type": "'+ data.get('About_Account__c.TF4SF__Account_Type_FI_Cert__c')+'",';
            }
            else {
                template +=            '"source_bank_account_type": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.TF4SF__Account_Holder_Name_CERT__c'))) {
                template +=            '"source_name_on_card": "'+ data.get('About_Account__c.TF4SF__Account_Holder_Name_CERT__c')+'",';
            }
            else {
                template +=            '"source_name_on_card": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.CERT_Account_Number__c'))) {
                template +=            '"source_bank_account_number": "'+ data.get('About_Account__c.CERT_Account_Number__c')+'",';
            }
            else {
                template +=            '"source_bank_account_number": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.Routing_Number_Cert__c'))) {
                template +=            '"source_bank_routing_number": "'+ data.get('About_Account__c.Routing_Number_Cert__c')+'",';
            }
            else {
                template +=            '"source_bank_routing_number": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.Financial_Institution_CERT__c'))) {
                template +=            '"source_bank_name": "'+ data.get('About_Account__c.Financial_Institution_CERT__c')+'",';
            }
            else {
                template +=            '"source_bank_name": null,';
            }
            if (String.isNotBlank(data.get('About_Account__c.State__c'))) {
                template +=            '"source_bank_state_code": "'+ data.get('About_Account__c.State__c')+'",';
            }
            else {
                template +=            '"source_bank_state_code": null,';
            }
        }
        if (data.get('About_Account__c.Total_Loan_Amount__c') != null) {
            template +=            '"amount": "'+ data.get('About_Account__c.Total_Loan_Amount__c')+'"';
        }
        else {
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
        Alpha_Pack__c aPack = Alpha_Pack__c.getOrgDefaults();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        //req.setEndpoint('https://dev.sandboxbanking.com/api/product-applications/');
        
        if (aPack.Enable_Production__c == false) {
            
            req.setEndpoint(aPack.Consumer_Loans_Sandbox_URL__c+'api/product-applications/');
            
        }
        else {
            req.setEndpoint(aPack.Consumer_Loans_Production_URL__c+'api/product-applications/'); 
        }
        
        if (aPack.Enable_Production__c == false) {
            
            req.setHeader('Authorization', aPack.Sandbox_Token__c);      
        }
        else {
            req.setHeader('Authorization', aPack.Production_Token__c);      
        }
        //req.setHeader('Authorization', 'Token c1cb7333444e8a890882fd459c945692c9f4a47f');      
        req.setBody(jsonBody);
        System.debug('jsonbodu: ' + jsonbody);
        System.debug('request: ' + req.getbody());
        HttpResponse res = http.send(req);
        System.debug('response: ' + res.getbody());
        if (res.getStatusCode() == 200) {
            System.debug('success');
        }
        String responseJSON = res.getBody();
        system.debug('responseJSON: '+responseJSON);
        List<Object> k1 = (List<Object>)JSON.deserializeUntyped(responseJSON); 
        Map<String, Object> k = (Map<String, Object>)k1[0];
        System.debug(Page );
        
        if (Page != 'IdentityPage') {
            TF4SF__Application__c a = new TF4SF__Application__c();
            List<TF4SF__Application__c> aList = new List<TF4SF__Application__c>();
            
            /*
            if (k.get('success') == true) {
                a.Id = appId;
                a.App_Submitted_to_Alfa__c = true;
                aList.add(a);
            }
            else {
                a.Id = appId;
                a.App_Submitted_to_Alfa__c = false;
                aList.add(a);
            }
            if (aList.size() > 0) {
                update aList;
            }
            */
            if (k.get('success') == true) {
               updateApplication(appId,true);
               
            }
            else {
                a.Id = appId;
                a.App_Submitted_to_Alfa__c = false;
                updateApplication(appId,false);
            }
           
            
            InsertDebugLog(appId, jsonBody, 'UpdateCoreAPP Request');
            InsertDebugLog(appId, responseJSON, 'UpdateCoreApp Response');
        }
     //  Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
         // System.debug('m: '+m);
        
        return responseJson;
    }
    
    @future(callout=true)
    public static void updateApplication (String appId, Boolean submittedAlfa) {
        List<TF4SF__Application__c> aList = new List<TF4SF__Application__c>();
         TF4SF__Application__c a = new TF4SF__Application__c();
          a.Id = appId;
          a.App_Submitted_to_Alfa__c = submittedAlfa;
          aList.add(a);
        if (aList.size() > 0) {
                update aList;
            }
    
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

        for (String fieldName:fieldSet) {
             SObjectField fieldToken = fields.get(fieldName);
             DescribeFieldResult selectedField = fieldToken.getDescribe();

             //respect CRUD/FLS
            if (selectedField.isAccessible()) {
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