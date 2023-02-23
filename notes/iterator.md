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

