function [M, names, official] = load_stage(T, stageName)
% LOAD_STAGE  Scores (contestants x jurors), names and official averages
% for each one stage. basically the secretary
    S = T(T.stage == stageName, :);
    W = unstack(S(:, ["name", "official_avg", "juror", "original"]), "original", "juror", ...
                "VariableNamingRule", "preserve");
    names = W.name;
    official = W.official_avg;
    M = W{:, 3:end};
end