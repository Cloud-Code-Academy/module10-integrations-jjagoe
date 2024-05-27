public with sharing class CalloutExample {
   
// Callout to dummyjson.com user endpoint
//Create a method that sends a request to that dummy JSON endpoint.
public static void getDummyJsonSingleUser(String userId){ HttpRequest request = new HttpRequest(); // Build the infomation we want to send out.

    //request.setEndpoint('https://dummyjson.com/users/' + userId);
    request.setEndpoint('callout:DummyJsonUser' + '/' + userId);
    request.setMethod('GET');

    Http http = new Http();  //Does the sending of the request we have.
    HttpResponse response = http.send(request); // To actually do the callout we want to use the http object that we instantiaed and call the dot send method passing in the request that we have 
                                                //and we will get back a bunch of infomation from the respone object.
                                                // This does the sending of the request that we have
    System.debug(response.getBody());
    System.debug(response.getStatusCode());
    System.debug(response.getStatus());
    if (response.getStatusCode() == 200){
        //Create contact from js
        Contact cont = createContactFromJson(response.getBody());
        System.debug(cont);
    }

}

   //Create another method that will take in the body response which is a string and return a contact to us.
   // We need to convert our JSON to something we can work with using a Map object
   // Prefered method is to deserialize the JSON the we back into a key value pair which is the string and the object json map  that we have just created.
   private static Contact createContactFromJson(String jsonResponse){
    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
    System.debug(jsonMap);
    System.debug(jsonMap.get('firstName')); //Now ere able to pull information out using the get method.
    System.debug(jsonMap.get('lastName'));

    Contact cont = new Contact();
    cont.FirstName = (String) jsonMap.get('firstName');
    cont.LastName = (String) jsonMap.get('lastName');
    cont.Email = (String) jsonMap.get('email');
    cont.Phone = (String) jsonMap.get('phone');
    cont.BirthDate = Date.valueOf((String) jsonMap.get('birthDate'));

    Map<String, Object> addressMap = (Map<String, Object>) jsonMap.get('address');
    System.debug(addressMap);
    cont.MailingStreet = (String) addressMap.get('address');
    cont.MailingCity = (String) addressMap.get('city');
    cont.MailingState = (String) addressMap.get('state');
    cont.MailingPostalCode = (String) addressMap.get('postalCode');
    cont.MailingCountry = (String) addressMap.get('country');


    insert cont;
    return cont;

   }

  

  //POST information to dummyjson.com user endpoint
  public static void postDummyJsonSingleUser(String contactId){
     HttpRequest request = new HttpRequest();
    // request.setEndpoint('https://dummyjson.com/users/add');
     request.setEndpoint('callout:DummyJsonUser' + '/add' ); //Named Credential - https://dummyjson.com/users
     request.setMethod('POST');
     //request.setHeader('Content-Type', 'application/json'); //This is telling the oter system what type of information we are sending.
                                                            // Here is what the payload is going to have inside of it.

     //request.setBody('{"firstName": "Tester", "lastName": "McTesterson", "email": "test@email.com"}'); //Were sending json information out - key value pair - firstName is the key and Tester is the value.                                                         ;
     request.setBody(generateDummyJsonUserPayload(contactId));

     Http http = new Http();
     HttpResponse response = http.send(request);
     System.debug(response.getBody());
     System.debug(response.getStatusCode());
     System.debug(response.getStatus());

     if (response.getStatusCode() >= 200 || response.getStatusCode() <= 299){
        //Create contact from js
        //Contact cont = createContactFromJson(response.getBody());
        System.debug('Success: contact created in other system');
        System.debug(response.getBody());
    }
}
  

  // Create a payload using a Map, instead of manually adding new fields to the body - payload.
  // Using best practices let's use a method that returns a String payload that we generate
  private static String generateDummyJsonUserPayload(String contactId){
    // Let's select a contact from our database using the contactId and use that to when send that information over to the endpointto create the other user.
    Contact cont = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = : contactId];
    // We want to create a json Map that will hold the payload information
    // The keys will be the information that the other system is looking for and the values are the information from our contact object.
    Map<String, Object> jsonMap = new Map<String, Object>();
    jsonMap.put('firstName', cont.FirstName);
    jsonMap.put('lastName', cont.LastName);
    jsonMap.put('email', cont.Email);
    jsonMap.put('phone', cont.Phone);
    String jsonPayload = JSON.serialize(jsonMap); //Our map gets converted down to a json string and then that payload string can be sent back to into the generateDummyJsonUserPayload request
    System.debug('Payload being sent to url" ' + jsonPayload);
    return jsonPayload;
  }
}

