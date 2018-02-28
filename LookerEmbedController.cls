public with sharing class LookerEmbedController {
    public String strURL {get;set;}
    
    public LookerEmbedController() {
        strURL = createURL('12345');
        system.debug(strURL);
        system.debug(EncodingUtil.urlDecode(strURL, 'UTF-8'));
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public String createURL(String strclientID) {
	    //List of input variables 
        String strHost = 'company.looker.com';
        String strEmbedUrl = '/embed/dashboards/2';
        String strExternalUserID = json.serialize('Testing');
        String strFirstName = json.serialize('Test');
        String strLastName = json.serialize('User');
        String strPermissions = json.serialize(new list<String>{'access_data', 'see_looks', 'see_user_dashboards','see_drill_overlay'});
        String strModels = json.serialize(new list<String>{'Dashboard'});
        String strGroupID = json.serialize(new list<Integer>{56});
        String strSessionLength = '3600';
        String strForceLogoutLogin = 'true';
        String strNonce = json.serialize(generateRandomString(16));
        DateTime dtCurrentTime = DateTime.now();
        String iUNIXTime = String.valueOf(dtCurrentTime.getTime()/1000);
        String strExtenalGroupID = json.serialize('none');
        String strUserAttribute = jsonInnerString('client_nid', strclientID);
        Object objUserAttrribute = json.deserializeUntyped(strUserAttribute);
        strUserAttribute = json.serialize(objUserAttrribute);
        String strEmbedPath =  '/login/embed/'+ EncodingUtil.urlEncode(strEmbedUrl, 'UTF-8');
        String strAccessFiltter = '{}';
        Object objUserAttrribute1 = json.deserializeUntyped(strAccessFiltter);
        strAccessFiltter = json.serialize(objUserAttrribute1);

        //Signature URL generation - Order should be same order
        String strSignatureURL = '';
        strSignatureURL += strHost + '\n';
        strSignatureURL += strEmbedPath + '\n';
        strSignatureURL += strNonce + '\n';
        strSignatureURL += iUNIXTime + '\n';
        strSignatureURL += strSessionLength + '\n';
        strSignatureURL += strExternalUserID + '\n';
        strSignatureURL += strPermissions + '\n';
        strSignatureURL += strModels + '\n';
        strSignatureURL += strGroupID + '\n';
        strSignatureURL += strExtenalGroupID + '\n';
        strSignatureURL += strUserAttribute + '\n';
        strSignatureURL += strAccessFiltter;
		
		//Signature URL is encrypted with secrete key
        String strFinalSignature = generateSignature(strSignatureURL);
		
		//URL parameters
        String strParameter = 'nonce='+EncodingUtil.urlEncode(strNonce, 'UTF-8') + 
                              '&time='+EncodingUtil.urlEncode(iUNIXTime, 'UTF-8') + 
                              '&session_length='+EncodingUtil.urlEncode(String.valueOf(strSessionLength), 'UTF-8') + 
                              '&external_user_id='+EncodingUtil.urlEncode(strExternalUserID, 'UTF-8') +
                              '&permissions='+EncodingUtil.urlEncode(strPermissions, 'UTF-8') +
                              '&models='+EncodingUtil.urlEncode(strModels, 'UTF-8') +
                              '&signature='+strFinalSignature +
                              '&first_name='+EncodingUtil.urlEncode(strFirstName, 'UTF-8') +
                              '&last_name='+EncodingUtil.urlEncode(strLastName, 'UTF-8') +
                              '&group_ids='+EncodingUtil.urlEncode(strGroupID, 'UTF-8') +
                              '&external_group_id='+EncodingUtil.urlEncode(strExtenalGroupID, 'UTF-8') +
                              '&user_attributes='+EncodingUtil.urlEncode(strUserAttribute, 'UTF-8') +
                              '&force_logout_login='+EncodingUtil.urlEncode('true', 'UTF-8') +
                              '&access_filters='+EncodingUtil.urlEncode(strAccessFiltter, 'UTF-8') ;
							  
        return 'https://'+strHost + strEmbedPath + '?' + strParameter;
    }

    private String generateSignature(String strInputValue) {
        String strSecretKey = 'your secrete key'; // Secret key will generated from looker.
        String strSignature = generateHMACSignature(strInputValue, strSecretKey);
        return strSignature;
    }
	

    private String generateHMACSignature(String strInputValue, String strSecretKey) {
        String strAlgorithmName = 'HmacSHA1';
        Blob blobHMACData = Crypto.generateMac(strAlgorithmName, Blob.valueOf(strInputValue), Blob.valueOf(strSecretKey));
        return EncodingUtil.base64Encode(blobHMACData);
    }

    private String jsonString(String strValue) {
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeString(strValue);
        return jsonGen.getAsString();
    }

    private String jsonArrayNumber(list<Integer> lstValue) {
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeObject(lstValue);
        return jsonGen.getAsString();
    }

    private String jsonArrayString(list<String> lstValue) {
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeObject(lstValue);
        return jsonGen.getAsString();
    }

    private String jsonInnerString(String strKey, String strValue) {
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeStringField(strKey, strValue);
        jsonGen.writeEndObject();
        return jsonGen.getAsString();
    }

    private String jsonInnerString() {
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeEndObject();
        return jsonGen.getAsString();
    }
}