function [] = evaluate_relevant_functions()
%
% Evaluate_relevant_functions(); looks at OPT.functions and evaluates the
% relevant functions for this problem based on the current OPT.dv
%

global OPT


OPT.functions.n_func =  numel(OPT.functions.f);

for i = 1:OPT.functions.n_func
    [value,grad] = feval(OPT.functions.f{i}.function);
    OPT.functions.f{i}.value = value;
    OPT.functions.f{i}.grad = grad;
end
