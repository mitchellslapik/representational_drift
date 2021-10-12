# representational drift

Method for confirming same neuron across multiple ephys recordings based on paper "Representational drift in primary olfactory cortex." 

This program looks at correlations between waveforms on different channels in order to create a distribution of correlation coefficients. Then it picks a percentile in that distribution (in the original paper, 99th percentile) as the threshold for what counts as the as the same neuron on the same channel. This was one of three methods used in the above paper.
