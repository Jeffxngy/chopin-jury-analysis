T = readtable("../data/processed/scores.csv", "TextType", "string");

S1 = T(T.stage == "Stage 1", :);              % keep only stage 1 rows

W = unstack(S1(:, ["name", "juror", "original"]), "original", "juror", ...
            "VariableNamingRule", "preserve"); % long -> wide

M = W{:, 2:end};                               % just the numbers, as a matrix
names = W.name;

size(M)

%montecarlo: 

nJurors = size(M, 2);

nRuns = 10000;
counts = zeros(size(M, 1), 1);        % one counter per contestant, all starting at 0

for run = 1:nRuns
    idx = randi(nJurors, 1, nJurors);
    Msim = M(:, idx);
    avg = mean(Msim, 2, "omitnan");
    [~, order] = sort(avg, "descend");
    advanced = order(1:40);
    counts(advanced) = counts(advanced)+ 1;

end
prob = counts/nRuns;

result = table(names, prob);
result = sortrows(result, "prob", "descend")