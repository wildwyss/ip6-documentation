import Data.Tree (Tree(rootLabel))
import Prelude hiding (repeat)
main :: IO ()
main = do
  print "helo"

  return ()

-- Tree
labels :: TreeOf a -> [a]
labels = foldTree (:) (<>) []

sumTree :: TreeOf Int -> Int
sumTree = foldTree (+) (+) 0

myTree :: TreeOf Int
myTree = Node 1 [
  Node 2 [],
  Node 3 [
    Node 4 []
        ]
  ]

cons = (:)

append = (<>)
nil = []

lTree = cons 1
        (append (cons 2 nil)
                (append (cons 3
                        (append (cons 4 nil) nil))
                       nil))


data TreeOf a = Node a [TreeOf a] deriving (Show)

myFoldTree :: TreeOf a -> (a -> b -> b) -> b -> b
myFoldTree (Node a []) f acc = f a acc
myFoldTree (Node a (x:xs)) f acc = myFoldTree x f (f a (foldr (`myFoldTree` f) acc xs))

mapTree :: (label -> x) -> TreeOf label -> TreeOf x
mapTree f = foldTree (Node . f) cons nil

foldTree :: (label -> acc -> result) -> (result -> acc -> acc) -> acc -> TreeOf label -> result
foldTree f g acc (Node label subtrees) = f label (foldTree' subtrees) where
  foldTree' (subtree:rest) = g (foldTree f g acc subtree) (foldTree' rest)
  foldTree' [] = acc

-- square root
next :: Double -> Double -> Double
next n x = (x + n/x)/2

repeat :: (a -> a) -> a -> [a]
repeat f a = cons a (repeat f (f a))

within :: Double -> [Double] -> Double
within eps (a:b:cs) | abs (a-b) <= eps = b
                    | otherwise       = within eps (b:cs)

sqrt :: Double -> Double -> Double -> Double
sqrt a0 eps n = within eps (repeat (next n) a0)

-- differentiation

easydiff :: Fractional a => (a -> a) -> a -> a -> a
easydiff f x h = (f (x + h) - f x)/h

halve :: Fractional a => a -> a
halve x = x/2

differentiate :: Fractional a => a -> (a -> a) -> a -> [a]
differentiate h0 f x = map (easydiff f x) (repeat halve h0)

easyintegrate :: Fractional a => (a -> a) -> a -> a -> a
easyintegrate f a b = (f a + f b) * (b - a)/2

integrate :: Fractional a => (a -> a) -> a -> a -> [a]
integrate f a b = cons (easyintegrate f a b)
                       (zipWith (+) (integrate f a mid) (integrate f mid b))
                        where mid = (a + b)/2
