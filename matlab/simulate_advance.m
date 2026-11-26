function prob = simulate_advance(M, carried, weight, nAdvance, margin, nRuns)

% SIMULATE_ADVANCE  Bootstrap the jury and estimate each contestant's
% chance to advance. - doesnt know which stage it is just to do
% calculations
%   M         contestants x jurors score matrix (NaN = no score)
%   nAdvance  how many contestants advance (40, 20, 11)
%   margin    correction margin (3 in stage 1, 2 in later stages)
%   nRuns     number of simulated juries

    % your loop goes here, with 40 -> nAdvance and 3 -> margin
    nJurors = size(M, 2);
    counts = zeros(size(M, 1), 1);
    for run = 1:nRuns
        % drawing the jury, apply the correction rule with "margin", get avg
        idx = randi(nJurors, 1, nJurors);
        Msim = M(:, idx);
        m = mean(Msim, 2, "omitnan");
        Msimc = min(max(Msim, m - margin), m + margin);
        Msimc(isnan(Msim)) = NaN;
        avg = mean(Msimc, 2, "omitnan");
        total = carried + weight * avg;


        % rank by total, take the top nAdvance, count them
        [~, order] = sort(total, "descend");
        advanced = order(1:nAdvance);
        counts(advanced) = counts(advanced) + 1;
    end
    prob = counts / nRuns;
end