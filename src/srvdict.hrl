%A dictionary is an ADT with some data representation supporting the following
%operations:
% get: Dict x AtomKey -> Value (for some Value).
% update: Dict x AtomKey x (Value -> Value) -> Dict
% iterator: Dict -> iterator
-record(srvdict, { get, insert, iterator, pid, data }).
