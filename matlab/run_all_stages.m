%the driver of the whole competition
T = readtable("../data/processed/scores.csv", "TextType", "string");
[M1, n1, off1] = load_stage(T, "Stage 1");
[M2, n2, off2] = load_stage(T, "Stage 2");

p1 = simulate_advance(M1, zeros(size(n1)), 1, 40, 3, 10000); %(M, carried, weight, nAdvance, margin, nRuns)

[~, loc] = ismember(n2, n1);       % row of each stage-2 contestant in the stage-1 list
carried2 = 0.3 * off1(loc);
p2 = simulate_advance(M2, carried2, 0.7, 20, 2, 10000);

sortrows(table(n2, p2), "p2", "descend")