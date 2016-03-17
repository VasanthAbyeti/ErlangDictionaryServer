%A iterator has some state with 3 operations:
% has_next: Iterator -> Bool.
% get_next: Iterator -> Value (for some Value).  
%           Returns current value.  Assumes has_next returns true.
% advance: Iterator -> Iterator.  Advances iterator.
-record(iterator, { has_next, get_next, advance, state }).