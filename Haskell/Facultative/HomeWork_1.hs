-- Returns first element from list
head' :: [a] -> a
head' (x : xs) = x


-- Returns given list without first element
tail' :: [a] -> [a]
tail' (x : xs) = xs