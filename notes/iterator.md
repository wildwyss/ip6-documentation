# Iterator

## Decorator Approach

Inspired from: https://rxjs.dev/api/index/function/pipe
- In the beginning, we had trouble with how we can implement copy functionality
- Functions like map or filter are no longer on the iterator object
- Each iterator yields objects containing a next and copy attribute
 - copy is only a copy of the inner iterator and that copy is wrapped by the functionality of the particular function
- Steps to our solution:
		1. We need an inner iterator 
		2. The function doesn't live on the iterator anymore
		3. Iterator copy is one of the biggest challenges
		4. Each function can copy itself => advantages: easier to read, to extend, leaner
		5. We need an additional function like a pipe to concat multiple functions
- Pipe implemented to concat several functions on the iterator
		- each function returns a copy of the iterator
		- each function takes alongside its parameters an iterator

## Iterator Collection
- Added different Iterators (empty, Array, Tuple)
- Array and Tuple Iterator use the map function to iterate over the elements
- The implementation of TupleIterator uses a function to grab the tuple length

This is how the tuple works:
```javascript
let t = TupleCtor(3)([]);
// returns: value => TupleCtor(2)(...[],values)
t = t(1);
// returns: value => TupleCtor(1)([...[], 1, value])
t = t(2);
// returns: value => TupleCtor(0)([...[], 1, 2, values])
t = t(3);
// returns: selector => selector([...[], 1, 2])

const one = values => values[0];
const element = t(one);
// returns: 1
```
