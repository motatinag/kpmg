We have a nested object, we would like a function that you pass in the object and a key and get back the value. How this is implemented is up to you.
Example Inputs
object = {“a”:{“b”:{“c”:”d”}}}
key = a/b/c
object = {“x”:{“y”:{“z”:”a”}}}
key = x/y/z
value = a

commnads:
npm install 
npm test

output:
> mocha

[Function: getIn]


  Index
    #getIn
value d
      ✔ Should give the  object.a.b.c


  1 passing (17ms)
