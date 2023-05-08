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


