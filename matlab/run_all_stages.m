%the driver of the whole competition
T = readtable("../data/processed/scores.csv", "TextType", "string");
[M1, n1, off1] = load_stage(T, "Stage 1");
[M2, n2, off2] = load_stage(T, "Stage 2");
[M3, n3, off3] = load_stage(T, "Stage 3");          % NEW: load stage 3
[M4, n4, off4] = load_stage(T, "Final");            %csv stage is called Final


p1 = simulate_advance(M1, zeros(size(n1)), 1, 40, 3, 10000); %(M, carried, weight, nAdvance, margin, nRuns)

[~, loc] = ismember(n2, n1);       % row of each stage-2 contestant in the stage-1 list
carried2 = 0.3 * off1(loc);
p2 = simulate_advance(M2, carried2, 0.7, 20, 2, 10000);

% stage 3                                           % NEW from here
[~, loc1] = ismember(n3, n1);
[~, loc2] = ismember(n3, n2);
carried3 = 0.1 * off1(loc1) + 0.2 * off2(loc2); %off1 is a list of stage 1 so 84 condidates while off 2 is a list of 50 contestants
p3 = simulate_advance(M3, carried3, 0.7, 11, 2, 10000);


%stage 4
[~, loc1] = ismember(n4, n1);
[~, loc2] = ismember(n4, n2);
[~, loc3] = ismember(n4, n3);
carried4 = 0.1*off1(loc1)+0.2*off2(loc2) + 0.35*off3(loc3);
p4 = simulate_advance(M4, carried4, 0.35, 1,2, 10000) %1 Winner 


sortrows(table(n4, p4), "p4", "descend")
% final: 6 prize levels, but 8 laureates because some places were shared
p4win   = simulate_advance(M4, carried4, 0.35, 1, 2, 10000);   % chance to win
p4prize = simulate_advance(M4, carried4, 0.35, 8, 2, 10000);   % chance of a prize

finalResult = table(n4, p4win, p4prize);
sortrows(finalResult, "p4win", "descend")

% --- chart: chance of a prize in the final ---
laureates = ["Eric Lu", "Kevin Chen", "Zitong Wang", "Tianyao Lyu", ...
             "Shiori Kuwahara", "Piotr Alexewicz", "Vincent Ong", "William Yang"];

[pSorted, order] = sort(p4prize, "ascend");   % ascending: barh draws the first bar at the bottom
namesSorted = n4(order);
isLaureate = ismember(namesSorted, laureates);

figure;
b = barh(pSorted);
b.FaceColor = "flat";                                  % allow one colour per bar
b.CData(isLaureate, :)  = repmat([0.20 0.45 0.75], sum(isLaureate), 1);   % blue
b.CData(~isLaureate, :) = repmat([0.70 0.70 0.70], sum(~isLaureate), 1);  % grey

yticks(1:numel(namesSorted));
yticklabels(namesSorted);
xlim([0 1]);
xline(0.5, "--");
xlabel("Chance of a prize across 10,000 simulated juries");
title("Final round: how much did the jury's composition matter?");
subtitle("Blue = real laureate, grey = no prize");

if ~exist("../figures", "dir"), mkdir("../figures"); end
exportgraphics(gcf, "../figures/final_prize_probability.png", "Resolution", 200);