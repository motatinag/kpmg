var assert = require('assert');
var getIn = require('../index.js');

console.log(getIn);
var object = { 
  a :{
  b:{
    c:"d"
  }
  }
};

describe('Index', function() {
  describe('#getIn', function() {
  
    it('Should give the  object.a.b.c', function () {
      console.log('value', object.a.b.c);
          assert.equal(getIn(object,[ "a", "b", "c"]), object.a.b.c);
    });
    
  });
});