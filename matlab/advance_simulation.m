T = readtable("../data/processed/scores.csv", "TextType", "string");

S1 = T(T.stage == "Stage 1", :);              % keep only stage 1 rows

W = unstack(S1(:, ["name", "juror", "original"]), "original", "juror", ...
            "VariableNamingRule", "preserve"); % long -> wide

M = W{:, 2:end};                               % skip the first ("name of contestant") just the numbers, as a matrix
names = W.name;                                %table.columnname

size(M)

% correction rule on the real scores, as a check
m = mean(M, 2, "omitnan");          % raw average per contestant, 2 for going sideways along the columns
Mc = min(max(M, m - 3), m + 3);     % push every score into [m-3, m+3]
Mc(isnan(M)) = NaN;                 % keep missing scores missing
corrAvg = mean(Mc, 2, "omitnan");

check = table(names, corrAvg);
check(names == "Ziye Tao", :)

%montecarlo: sampling with replacement core of bootstrapping

nJurors = size(M, 2);

nRuns = 10000;
counts = zeros(size(M, 1), 1);        % one counter per contestant, all starting at 0

for run = 1:nRuns
    idx = randi(nJurors, 1, nJurors);
    Msim = M(:, idx);
    m = mean(Msim, 2, "omitnan");          % raw average per contestant
    Msimc = min(max(Msim, m - 3), m + 3);  % move outliers to the edge
    Msimc(isnan(Msim)) = NaN;              % missing scores stay missing
    avg = mean(Msimc, 2, "omitnan");       % corrected average
    [~, order] = sort(avg, "descend");
    advanced = order(1:40);
    counts(advanced) = counts(advanced)+ 1;

end
prob = counts/nRuns;

result = table(names, prob);
result = sortrows(result, "prob", "descend")