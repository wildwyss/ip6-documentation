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
    - first we impletended pipe as property on the iterator type. Afte some weeks we figured out, that it would be more consistent to have it as a global funciton which takes an iterator and all transformations
      - this also brings the advantage, that pipe does not need to be tested on every iterator operations
      - and less code of course

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
    
### SquareNumberIterator
- Nutzt die Idee aus, dass durch aufsummieren der ungeraden Zahlen, Quadrahtzahlen entstehen.
- Er iteriert über alle ungeraden Zahlen und gibt mit jeder Iteration die bisherige Summe + die nächste ungerade Zahl aus.

### PrimeNumberIterator
Baut auf der Idee des "sieb des eratosthenes" auf.
Er startete mit der Zahl 2 und machte sich einen Stock mit der Länge zwei. dann Strich er jede Zahl durch, die er durch aneinanderreihung der Stöcke erreichen kann. 
Dann nahm er die nächste nicht durchgestrichtene Zahl und machte sich wiederum einen Stock dieser länge und strich alle Vielfachen davon durch. -> usw
- itertiert über unendlichen Range der bei 2 startet
- consed alle gefundenen Primzahlen in einen Iterator 
- bei jedem Aufruf von next wird überprüft ob die  momentane Zahl durch mindestens eine gefundene Primzahl geteilt wird.
  - Falls ja: keine Primzahl, es wird mit der nächsten Zahl weiter gemacht
  - Falls nein: die nächste Primzahl wurde gefunden, wird geconsed und zurückgegeben
### AngleIterator
Generiert eine bestimmte Anzahl gleichmässig verteilter Winkel zwischen 0 & 360 grad. Wird er gecycled, kann man so endlos viele Winkel generieren

## Testing iterator operation
- test the functionality
- each iterator operation needs to operate on a copy (test purity). This is tested now.
- the copy of each operation works correctly => is tested now
- test cases are organized in a table, this is a preferred way to achieve high test quality and coverage
		- consider the interpreter pattern

WICHTIG: Test table in den Bericht
=> Unsere Testsuite dokumentieren, vor allem auch `assertThrows`


## Monoid/mconcat
`mconcat` is a function in many functional programming languages, 
including Haskell and Scala, that combines a list of monoids. 
A monoid is an algebraic structure that defines a set and a 
binary operation on that set that is associative and has a neutral element.

- implement mconcat based on ConcatIterator
- mconcat reduces a List of iterators to a single iterator
- mconcat implemented in Haskell: `mconcat as = foldr (<>) mempty as`

- implement cycle, it copies the iterator every iteration

## performance of multiple operations
- copy is very expensive
  - each time copy is called, the whole subiterators are copied
    - this leads to massive performance problems
    - with 2000 times cons, performance problems are occuring
    - with around 7000 times cons, a stack overflow exception occurs at copy()


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
- Komplexitätsklassen angeben: IteratorBilder O(n), cons eher O(n^2)
- Tests: der perfomancetest macht schon sinn, da man auch sieht, wenn sich etwas an der Umgebung ändert.
  - Übrigens heisst das Pattern eine Funktion an eine andere zu geben damit sie in einem bestimmten Kontext ausgeführt wird, heisst "Method around". (in unserem Fall measure mit workload) => auch unbedingt im Bericht erwähnen
    - Measure ist eine Implementaiton eines Protokolls: zuerst wird gemessen, dann wird der workload ausgeführt, dann wird wieder gemessen
      
recursive calls in Javascript:
- Zuerst haben wir eine Version implementiert mit einem rekursiven Call. => Dieser bricht, wenn viele Iteratoren drin sind (call stack exceeded).
  - Danach haben wir es gerefactored zu einer Tailrecursion, welche einfach durch einen Loop ersetzt werden kann.
=> Da sie nicht optimiert werden können (tail recursive optimization), machen Loops oft mehr Sinn
   Das ist eetwas, dass nicht direkt aus der funktionalen Programmierung in Sprachen wie Javascript übernommen werden kann

## The power of the dot
- Umgesetzt über modul imports. Verweise auf das Gitbook von Herrn König
- Zusätzlich kann man auch selbst
- Alternative: Neues Pattern NamespaceObject => Unbedingt in Doku
  - Abhängig von der Art wie javascript arbeitet
  - man exportiert ein Objekt, das alle Funktionen enthält. Das Objekt hält ein Interface ein.
- Dritte Alternative Konstruktorfunktionen
=> See Notion Task : https://www.notion.so/andriwild/The-Power-of-the-Dot-eac0856341414e248b10cb6031d4effb?pvs=4

## copy of iterators that are partially used 
e.g.: 
```javascript
  const it = take(5)(Range(100);
  for (const _ of it) break;
  const copy = it.copy(); //<--- take, drop, cycle, cons hatten alle innere States die hier probleme machen
  ...it; // 1,2,3,4,5
  ...copy; // 1,2,3,4,5
```
### take, drop
take und drop funktionierten gleich:
- drop wrappt dropWhile und returnten jeweils next von dropWhile.
  - dropWhile legte eine Kopie des inneren Iterators an, auf dieser Kopie wurde next aufgerufen
  - Wurde nun drop kopiert, nachdem next schon einmal aufgerufen wurde, wurde der ursprüngliche Iterator als inner kopiert (und nicht der von dropWhile)
    - Nur dropWhile zu returnen würde aber ebenfalls nicht gehen, da dann mehrere Iteratoren auf den gleichen Counter verweisen würden.

### cons
- Hatte einen Boolean returned, der sagte, ob das Element schon returned wurde. dieser wurde beim koieren jedoch nicht mitkopiert.
- Die Lösung war hier, das mit cons hinzugefügte Element auf undefined zu setzen, sobald es zurückgegeben wurde. 
  Bei einer Kopie, wird das sowieso mitübergeben. Statt auf einen Boolean zu prüfen, wird jetzt geprüft, ob das Element undefined ist. 

### cycle 
- wird bei einem Cycle ein einzelnes Element prozessiert und nachher der cycle Iterator kopiert, 
  muss diese Kopie dort beginnen, wo der letzte aufgehört hat, man muss also den momentanen Stand mitkopieren.
  - Zusätzlich ist die Kopie ebenfalls auf den ursprüngliche Iterator angewiesen. Denn wird der momentane Stand fertig iteriert,
    muss cylce wieder mit den ursprünglichen Iterator prozssieren

=> Diese Dinge haben wir per Zufall bei take bemerkt, als wir den endlosen Fibonacci-Iterator bauten. 
  Den Test dazu haben wir dann in die Table eingebaut und fanden dadurch dasselbe verhalten durch Testtable gefunden


