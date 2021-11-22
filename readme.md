# representational drift

Method for confirming same neuron across multiple ephys sessions based on paper "representational drift in primary olfactory cortex" (https://pubmed.ncbi.nlm.nih.gov/34108681/).

This program looks at correlations between waveforms on different channels in order to create a distribution of correlation coefficients. Then it picks a high percentile in that distribution (in the original paper, 99th percentile) as the threshold for what counts as the same neuron on the same channel. This was one of three methods used in the above paper to confirm the same neuron was present across multiple ephys recordings.

![image](https://user-images.githubusercontent.com/92355713/142921946-3e254961-92ca-4bd0-8aa0-64bbfecae10b.png)
