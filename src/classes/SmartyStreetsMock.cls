@isTest
global class SmartyStreetsMock implements HttpCalloutMock{

	global HttpResponse respond(HttpRequest req){
		String basePath = 'https://api.smartystreets.com/'; //SmartyStreets.getURLEndpoint('').substringBefore('?');

		String path = req.getEndpoint().substringAfter(basePath);

		if(path.startsWithIgnoreCase('street-address')) return street_address(req, path);

		return null;
	}

	private HttpResponse street_address(HttpRequest req, String path){
		HttpResponse res = new HttpResponse();

		List<SmartyStreets.AddressRequest> addrReqs = (List<SmartyStreets.AddressRequest>)
			JSON.deserialize(req.getBody(), List<SmartyStreets.AddressRequest>.class);

		Integer i = -1;
		List<SmartyStreets.AddressResponse> addrRess = new List<SmartyStreets.AddressResponse>();
		for(SmartyStreets.AddressRequest addrReq :addrReqs){
			i++;
			if(String.isEmpty(addrReq.street)) continue;
			SmartyStreets.AddressResponse addrRes = new SmartyStreets.AddressResponse();
			addrRes.input_index = i;
			addrRes.delivery_line_1 = addrReq.street;
			addrRes.last_line = String.join(new List<String>{
				addrReq.city,
				addrReq.state,
				addrReq.zipcode
			}, ' ');
			addrRes.components.city_name = addrReq.city;
			addrRes.components.state_abbreviation = addrReq.state;
			addrRes.components.zipcode = addrReq.zipcode;

			addrRess.add(addrRes);
		}

		res.setStatusCode(200);
		res.setBody(JSON.serialize(addrRess));
		return res;
	}

}
