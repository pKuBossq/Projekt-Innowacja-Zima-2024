@isTest
global class MedicalFacilitiesHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().contains('/oauth2/token')) {
            res.setStatusCode(200);
            res.setBody('{"access_token":"fakeToken"}');
        } else {
            res.setBody('[{"Phone": "+48 123 456 780","OpeningHours": {"Niedziela": "9:00 - 19:00","Sobota": "9:00 - 19:00","Piątek": "8:00 - 16:00","Czwartek": "9:00 - 17:00","Środa": "10:00 - 19:00","Wtorek": "10:00 - 16:00","Poniedziałek": "10:00 - 16:00"},"Name": "Jeż Medyczny","Id": "AB123456","Email": "kontakt0@placowka.com","Address": {"Street": "Puławska 45","PostalCode": "02-508","City": "Warszawa"}}]');
            res.setStatusCode(200);
        }
        return res;
    }
}