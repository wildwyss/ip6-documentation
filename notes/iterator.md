# Iterator

## Decorator Approach

Inspired from: https://rxjs.dev/api/index/function/pipe
- In the beginning, we had trouble with how we can implement copy functionality
- Functions like map or filter are no longer on the iterator object
- Each iterator yields objects containing a next and copy attribute
- Follows strictly the open close principle
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
    - Verbindung von pipe zu anderen sprachen (java builder pattern) erläutern & Pipe in Terminal

## Iterator Collection
- Added different Iterators (empty, Array, Tuple)
- Array and Tuple Iterator use the map function to iterate over the elements
- The implementation of TupleIterator uses a function to grab the tuple length
- Added StackIterator using pop and stackEquals

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
- drop and takes must copy the iterator coming from propagated functions dropWhile and takeWhile
		- since take and drop have a state, it is not possible to return takeWhile and dropWhile directly
		- because the copy of take and drop has to copy the state as well
- uncons returns a pair including the first element of the iterator and the rest of iterator itself
		- uncons can not be used in a pipe, use drop instead
    
## Testing iterator operation
- test the functionality
- each iterator operation needs to operate on a copy (test purity). This is tested now.
- the copy of each operation works correctly => is tested now
- test cases are organized in a table, this is a preferred way to achieve high test quality and coverage
		- consider the interpreter pattern



## Monoid/mconcat
`mconcat` is a function in many functional programming languages, 
including Haskell and Scala, that combines a list of monoids. 
A monoid is an algebraic structure that defines a set and a 
binary operation on that set that is associative and has a neutral element.

- implement mconcat based on ConcatIterator
- mconcat reduces a List of iterators to a single iterator
- mconcat implemented in Haskell: `mconcat as = foldr (<>) mempty as`

- implement cycle, it copies the iterator every iteration

## Iterator builder
- performance optimized way to build iterators
- no copy is made during the build process
- build phases: 
		- 1 -> collect all elements, 2 -> build the iterator, no elements can be added
		- first approach was to return an empty iterator
		- changed to throw an error when building the iterator twice or adding elements
		- elements are processed in a lazy manner, therefore next will only be called by processing the elements
- iterators and elements can be passed to the builder 
- before iterators are processed, they will be copied
- performance test: extremely better performance than building iterators with multiple cons
