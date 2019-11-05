function [vars, id]=regex_table_vars(t, r)
% t - input table with defined variable names
% r - regula exspression
% Returns cell array of matched variable names and corresponding indeces

names = t.Properties.VariableNames;

n = size(t, 2);
idx=false(1, n);
match = regexp(names, r, 'start');

for i=1:n
    idx(i) = ~isempty(match{i});
end

vars = names(idx);
id = find(idx);