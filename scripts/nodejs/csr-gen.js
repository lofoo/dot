var csrgen = require('csr-gen');
var fs = require('fs');

var domain = 'daigoupt.com';

csrgen(domain, {
    outputDir: __dirname,
    read: true,
    company: 'DaiGouPT, Inc.',
    country: 'CN',
    state: 'FuJian',
    city: 'XiaMen',
    email: 'daigoupt@163.com'
}, function(err, keys){
    console.log('CSR created!');
    console.log('key: '+keys.private);
    console.log('csr: '+keys.csr);
});
