# representational drift

Method for confirming same neuron across multiple ephys sessions based on paper "representational drift in primary olfactory cortex" by Schoonover (https://pubmed.ncbi.nlm.nih.gov/34108681/).

This program looks at correlations between waveforms on different channels in order to create a distribution of correlation coefficients. Then it picks a high percentile in that distribution (in the original paper, 99th percentile) as the threshold for what counts as the same neuron on the same channel. This was one of three methods used in the above paper to confirm the same neuron was present across multiple ephys recordings.

![image](https://user-images.githubusercontent.com/92355713/142922922-42c3dddd-43fa-464a-9d86-c90d13fa6723.png)

Citations:
Schoonover, Carl E et al. “Representational drift in primary olfactory cortex.” Nature vol. 594,7864 (2021): 541-546. doi:10.1038/s41586-021-03628-7
