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
- zipped alle gefundenen Primzahlen in einen Iterator 
  => bsp nach 3 werden iteratoren [Nothing, Just(2), ...] & [Nothing, Nothing, Just(3), ...] gezippt zu [Nothing, Just(2), Just(3), ...] 
- bei jedem Aufruf von next wird der gezippte Primahl-Iterator ebenfalls nach vorne bewegt. ist Nothing drin, haben wir eine neue Primzahl, ist Just drin ist es keine

=> Dieser Ansatz führt weg vom operational reasoning zum equational reasoning

#### Probleme
1. states des unendlichen Zahleniterator muss mit dem State des Primenumber Iterator übereinstimmen.
2. Bei einer Kopie muss der aktuelle State mitkopiert werden, deshalb wird die zuletzt returnte Primzahl ebenfalls gemerkt.

#### andere ausprobierte Ansätze
- Modulo: Einfachster, logischer Ansatz, Haben wir verworfen, da wir auf unseren Abstraktionen möchten => Deshalb Sieb des eratosthenes
- Iterator über Iteratoren
  - Statt die Iteratoren zu zippen, haben wir uns alle Primzahlen Iteratoren gemerkt in einem Iterator und haben in jede Iteration auf alle Iteratoren, next aufgerufen. Mit Catmaybes haben wir dann alle Nothings rausgeworfen. 
    War die Liste leer, haben wir eine neue Primzahl gefunden.
- Iterator der für jede gefundene Primzahl folgendes Tupel beinhaltet: 1. Primzahl, 2. wann sie das nächste Mal auftreten wird (zB für Zahl 3, wenn wir momentan an Position 4 sind wäre es, (3,6))
  - in jeder Iteration wird jede Primzahl überprüft, ob sie die aktuelle Zahl teilt. Falls es eine gibt, ist es keine Primzahl. 
  - Alle Tupel die getroffen oder überschritten wurden, werden auf den nächsten Wert erhöht. (=> es werden also nicht immer alle Tupel aktualisiert).

### AngleIterator
Generiert eine bestimmte Anzahl gleichmässig verteilter Winkel zwischen 0 & 360 grad. Wird er gecycled, kann man so endlos viele Winkel generieren
### PureIterator
=> Lifts a value.

### replicate

## Testing iterator operation
- test the functionality
- each iterator operation needs to operate on a copy (test purity). This is tested now.
- the copy of each operation works correctly => is tested now
- test cases are organized in a table, this is a preferred way to achieve high test quality and coverage
		- consider the interpreter pattern

WICHTIG: Test table in den Bericht
=> Unsere Testsuite dokumentieren, vor allem auch `assertThrows`


### using the closure scope in the testing table
* braucht eine Iteratorconfig einen State kann dieser einfach in closure scope einer IIFE gehalten werden
```javascript
const eq$Config = (() => {
  // eq$ takes two iterators which both shouldn't be modified when eq runs.
  // To keep this we keep two iterators in our closure scope, to ensure that neither is modified by pure.
  const firstIterator = newIterator(UPPER_ITERATOR_BOUNDARY);
  const secondIterator = newIterator(UPPER_ITERATOR_BOUNDARY);
  return createTestConfig({
    name:      "eq$",
    iterator:  () => firstIterator,
    operation: eq$,
    param:     secondIterator,
    evalFn:    expected => actual => expected === actual,
    expected:  true
  });
})();

```

## mconcat
`mconcat` is a function in many functional programming languages, 
including Haskell and Scala, that combines a list of monoids. 
A monoid is an algebraic structure that defines a set and a 
binary operation on that set that is associative and has a neutral element.

- mconcat nimmt einen "Iterator of Iterators". 
- sowohl die äusseren wie auch die inneren Iteratoren können unedlich lange sein. Gerade beim äussern passiert das relativ schnell mal:
  ```javascript 
  const r = map(x => Range(x))(Range(Number.MAX_VALUE)); // r enthält unendliche viele Ranges 
  const values = [...take(100)(mconcat(r))];
  ```
  - da aber der äussere Itrerator unendlich viele Iteratoren beinhaltet, können nicht vorgängig alle inneren Iteratoren kopiert werden.
  - das führt dazu, dass innere Iteratoren auf die eine Referenz gehalten wird, aufgebraucht werden können bevor sie von mconcat kopiert werden.
    Konkret ist folgendes Verhalten denkbar:
    ```javascript 
    const ranges = [Range(5), Range(5), Range(5)];
    const r = mconcat(ArrayIterator(ranges)];
    console.log(...ranges[0]); // braucht den 1. Iterator auf 
    const values = [...mconcat(r)]; // erst jetzt wird mconcat konsumiert und somit erst jetzt auch die Subiteratoren kopiert.
    ```

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

## Iterator of Iterators
### laziness
- Da Iteratoren jedes Element lazy kosumieren/berechnen, kann das zu unerwartetem Verhalten führen wenn man einen Iterator über Iteratoren hat
- Wenn die Subiteratoren kopiert werden (zB innerhalb eines maps()), geschieht das ebenfalls lazy.
  - Wird also der ursprüngliche Iterator prozessiert, bevor die Kopie prozessiert wird, wird bei einem copy() zu einem späteren Zeitpunkt der fertige Subiterator kopiert
  Das folgende Beispiel veranschaulicht das gut:

```javascript
iteratorSuite.add("map problems", assert => {
  const createSimpleIti = nr => Iterator(1, i => i + 1, i => i > nr);
  const iti1 = createSimpleIti(2);
  const iti2 = createSimpleIti(3);

  const arr = ArrayIterator([iti1,iti2]);
  // create a lazy copy of the subiterators
  const copy = map(i => {
    console.log("lazy");
    return i.copy(); // this copy will be made as soon as the outer iterator is being processed
  })(arr);

  let i = 0;
  // first consume the original iterator
  for (const a of arr){ console.log("orig", "Iteration: ", i++, ...a); }
  // then consume the copy. The subiterators will be copied now. Since the origin iterator has already been processed, the finished Iterators are copied
  for (const a of copy){ console.log("copy", "Iteration: ", i++, ...a); }
});

```
### PrimeNumberIterator


## Module Organisation
- Ziel: 
		- verhindern von cycling dependencies 
		- gute Code organisation / strukturierung
- Lösung:
		- Alle Code Files in Folders, benannt nach dem Inhalt (Ctor, opertators, terminalOperator, etc.)
		- Jede Funktion oder Konstruktor ist in einem eigenen File, welches gleichnamig zur beinhaltenden Funktion ist 
		- Jeder Ordner hat ein File, welches alle Funktionen in diesem Ordner exportiert (single point of export)
		- Die ganze Code Basis wird auch über ein einziges File exportiert. Alle "export"-files aus den 
				verschiedenen Unterordnern werden in diesem File gemeinsam exportiert (single point of export)
		- Ein File, welches alles exportiert hat einige Vorteile:
				- siehe Abschnitt "The Power of the Dot"
				- interne Umstrukturierungen haben keinen Einfluss auf die public API



## Algebraische Strukturen 
### Typsystem am Beispiel der Monade
- Wir probierten sie über verschiedene Wege im Typsystem abzubilden
- Der erste Ansatz war die Verwendung von Intersectiontypes:
```javascript
  /**
   * @template _T_
   * @typedef { IteratorType<_T_> & MonadType<_T_> } IteratorMonadType
   */
  
   /**
    * Defines a Monad.
    * @typedef   MonadType
    * @template  _T_
    * @property  { <_U_>
    *                 (bindFn: (_T_) => MonadType<_U_>)
    *              => MonadType<_U_>
    *            } and
    */
  ```
  - das Problem an diesen Ansatz war, dass unsere `and` Methode "nur" einen Monadentypen zurückgibt. Vorher bekannte Typinformationen gingen somit verloren
    - Die Info, dass ein Objekt ein Iterator ist, ist somit nicht mehr vorhanden
  - Durch Typecasts nach Aufrufen von `and` würde dieses Problem beheben
- der nächste Ansatz sollte das vorherige Probelme beheben und basiert auf [Template Constraints](https://github.com/microsoft/TypeScript/issues/41768)
  - In java könnte das folgendermassen gelöst werden
  ```javascript
  /**
   * @template _T_
   * @typedef { IteratorType<_T_> & MonadType<IteratorType, _T_> } IteratorMonadType
   */
  
  /**
   * Defines a Monad.
   * @typedef   MonadType
   * @template  { MonadType } _M_
   * @template  _T_
   * @property  { <_U_>
   *                 (bindFn: (_T_) => _M_<_U_>)
   *              => _M_<_U_>
   *            } and
   */
  ```
  - Der ursprüngliche Typ wird an den Monadentyp übergeben und dort mit einem Template constraint durch den Monadentypen selbst ergänzt
  - In java könnte das mit dem folgenden Ansatz gelöst werden:
    ```
    public interface Monad<T extends Monad<T>> {
      public T and();
    }

    class Iterator implements Monad<Iterator> {
      public int next() {
        return 5;
      }
    
      @Override
      public Iterator and() {
        return null;
      }
    }
    public class Main {
      public static void main(String[] args) {
        var iti = new Iterator();
    
        iti.and().and().and().next();
        System.out.println("Hello world!");
      }
    }
    ```
    - Das Problem hierbei war jedoch, dass das Typsystem von IntelliJ diesen Ansatz zu wenig unterstützte. Der Hover hat zwar den richtigen Typ (Monad inkl iteratorentyp) angezeigt, aber der Punkt gab keine Vorschläge
  - der dritte und in unseren Augen beste Ansatz ist, dass man die Funktionen die Monaden oder Funktoren zur Verfügung stellen ebenfalls direkt an den Typ hängt
  ```javascript
  /**
   *
   * @typedef IteratorType
   * @template _T_
   * @property { () => { next: () => IteratorResult<_T_, _T_> } } [Symbol.iterator] - returns the iterator for this object.
   * @property { () => IteratorType<_T_> }                        copy - creates a copy of this {@link IteratorType}
   * @property { <_U_>(bindFn: (_T_) => IteratorType<_U_>) => IteratorType<_U_> } and
   */
  ```
    - der Nachteil an dieser Variante ist allerdings, dass die Typen der Funktion die der Monad bereitstellt immer wieder neu definiert werden müssen.
    - Diesen Typ auszulagern, hat wegen der Templates leider nicht geklappt
      ```javascript
      // klappt leider nicht, da _M_ nicht richtig erkannt wird
      /**
       * @callback AndCallback
       * @template _M_, _T_, _U_
       * @param {(_T_) => _M_<_U_>} bindFn
       * @returns { _M_<_U_> }
       */
      ```
    - Auch in dieser Variante lassen sich Funktionen definieren, die Monaden als Typen erwarten. Dies geschieht über die strukturelle Typisierung, die das JS Typesystem zur Verfügung stellt:
      man muss also bloss eine Funktion definieren, die als Parameter etwas dass die Struktur von MonadType einhält.
    ```javascript
    /**
     * Defines a Monad.
     * @typedef   MonadType
     * @template  _T_
     * @property  { <_U_>
     *                 (bindFn: (_T_) => MonadType<_U_>)
     *              => MonadType<_U_>
     *            } and
     */

    /**
     * Funktion die eine Monade entgegen nimmt:
     * @template _T_
     * @param { MonadType<_T_> }  monad -
     * @param { <_U_>(_T_) => MonadType<_U_> } f -
     */
    const runOnMonad = monad => f => monad.and(f);

    const iterator = Range(3)
    runOnMonad(range, Range); // Erstellt Range mit Werten: [0,0,1,0,1,2,0,1,2,3]
    ```
