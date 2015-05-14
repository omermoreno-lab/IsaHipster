theory list_return_1
imports Main
begin
  datatype 'a list = nil | cons "'a" "'a list"
  fun return :: "'a => 'a list" where
  "return x = cons x (nil)"
  fun append :: "'a list => 'a list => 'a list" where
  "append (nil) y = y"
  | "append (cons z xs) y = cons z (append xs y)"
  fun bind :: "'a list => ('a => 'b list) => 'b list" where
  "bind (nil) y = nil"
  | "bind (cons z xs) y = append (y z) (bind xs y)"
  theorem x0 :
    "!! (x :: 'a) (f :: ('a => 'b list)) . (bind (return x) f) = (f x)"
    oops
end
