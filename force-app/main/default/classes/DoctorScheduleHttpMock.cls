@isTest
global class DoctorScheduleHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().contains('/oauth2/token')) {
            res.setStatusCode(200);
            res.setBody('{"access_token":"fakeToken"}');
        } else {
            res.setBody('[{"Schedule": {"Sunday": {"EndTime": "13:00","StartTime": "8:00"},"Saturday": {"EndTime": "17:00","StartTime": "10:00"},"Wednesday": {"EndTime":"14:00","StartTime": "9:00"},"Tuesday": {"EndTime": "14:00","StartTime": "10:00"},"Monday": {"EndTime": "14:00","StartTime": "9:00"}},"DoctorId":"D0000011"}]');
            res.setStatusCode(200);
        }
        return res;
    }
}