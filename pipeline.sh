

#!/bin/bash

# ========================================
# 0. Rename taxa in NEXUS file
# ========================================
echo "Renaming taxa in NEXUS file..."

cp alignment_mafft2.nex alignment_renamed.nex

while read acc name; do
    sed -i "s/${acc}/${name}/g" alignment_renamed.nex
done < name_map.txt

# ========================================
# 1. Maximum Likelihood (IQ-TREE)
# ========================================
echo "Running IQ-TREE ML analysis..."
iqtree3 -s alignment_renamed.nex -m GTR+G -bb 1000 -nt AUTO -pre mafft_ML

# ========================================
# 2. Bayesian Inference (MrBayes)
# ========================================
echo "Running MrBayes analysis..."
# Run MrBayes non-interactively using the NEXUS file
mb << EOF
execute alignment_renamed.nex;
set autoclose=yes nowarn=yes;
lset nst=6 rates=gamma;
mcmc ngen=1000000 printfreq=100 samplefreq=100 nchains=4 savebrlens=yes;
sumt burnin=2500;
quit;
EOF

# ========================================
# 3. Compare & visualize trees in PAUP
# ========================================
echo "Running PAUP for tree comparison..."
paup << EOF
execute mafft_ML.treefile;
gettrees file=alignment_renamed.nex.con.tre;
showtrees;
treedist all;
describetrees all/plot=phylogram brlens=yes label=yes;
savetrees file='ML_Bayes_Whales.tre' brlens=yes replace;
quit;
EOF

echo "Pipeline complete!"


