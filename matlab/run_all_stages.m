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
p4 = simulate_advance(M4, carried4, 0.35, 6,2, 10000)

sortrows(table(n4, p4), "p4", "descend")