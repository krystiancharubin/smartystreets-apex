@isTest
public class SmartyStreetsTest {

	@isTest static void street_address(){
		SmartyStreets ss = new SmartyStreets('123', 'abc');

		SmartyStreets.AddressRequest req = new SmartyStreets.AddressRequest();
		req.street = '1600 Pennsylvania Ave NW';
		req.city = 'Washington Pole';
		req.state = 'DC';
		req.zipcode = '20500';

		Test.startTest();
		SmartyStreets.AddressResponse res = ss.street_address(req);
		req.street = '';
		SmartyStreets.AddressResponse resNull = ss.street_address(req);
		Test.stopTest();

		System.assertEquals(null, resNull);

		System.assertEquals(String.join(new List<String>{
			req.city,
			req.state,
			req.zipcode
		}, ' '), res.last_line);
		System.assertEquals(req.city, res.components.city_name);
		System.assertEquals(req.state, res.components.state_abbreviation);
		System.assertEquals(req.zipcode, res.components.zipcode);
	}

}
