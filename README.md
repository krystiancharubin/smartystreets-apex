[![Build Status](https://travis-ci.org/krystiancharubin/smartystreets-apex.svg?branch=master)](https://travis-ci.org/krystiancharubin/smartystreets-apex)

# SmartyStreets
SmartyStreets API Wrapper for Apex

Wraps the Street Address API

http://smartystreets.com/  
http://smartystreets.com/kb/liveaddress-api/

## Usage

You must have a valid auth-id and auth-token from SmartyStreets.

```apex
SmartyStreets ss = new SmartyStreets('AUTH_ID', 'AUTH_TOKEN');

SmartyStreets.AddressRequest address1 = new SmartyStreets.AddressRequest();
address1.street = '1 Santa Claus';
address1.city = 'North Pole';
address1.state = 'AK';
address1.zipcode = '99705';

SmartyStreets.AddressRequest address2 = new SmartyStreets.AddressRequest();
address2.street = '1600 Pennsylvania Ave NW';
address2.city = 'Washington Pole';
address2.state = 'DC';
address2.zipcode = '20500';

// single class
SmartyStreets.AddressResponse addressResponse = ss.street_address(address1);

List<SmartyStreets.AddressRequest> addressRequests = new List<SmartyStreets.AddressRequest>();
addressRequests.add(address1);
addressRequests.add(address2);

// batch call;
List<SmartyStreets.AddressResponse> addressResponses = ss.street_address(addressRequests);
```

## Authors

Krystian Charubin  
krystian.charubin@gmail.com  
http://github.com/krystiancharubin

## License

MIT
