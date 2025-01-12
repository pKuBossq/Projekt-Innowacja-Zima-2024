@isTest
global class MedicalFacilitiesHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().contains('/oauth2/token')) {
            res.setStatusCode(200);
            res.setBody('{"access_token":"fakeToken"}');
        } else {
            res.setBody('[{"Phone":"+48 123 456 780","Name":"Centrum Zdrowia Hipopotam","Address":{"Street":"Wyszyńskiego 7","PostalCode":"75-620","City":"Koszalin"}},{"Phone":"+48 123 456 781","Name":"Centrum Zdrowia Hipopotam 2","Address":{"Street":"Wyszyńskiego 8","PostalCode":"75-621","City":"Koszalin"}}]');
            res.setStatusCode(200);
        }
        return res;
    }
}