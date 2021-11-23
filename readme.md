# representational drift

Method for confirming consistent neurons across multiple ephys recordings based on paper "Representational Drift in Primary Olfactory Cortex" by Carl Schoonover, available here: https://tinyurl.com/yt64khzm.

This method looks at Pearson correlations between waveforms on different channels in order to create a distribution of correlation coefficients that we would expect between different neurons. Then it picks a high percentile in that distribution (in the original paper, 99th percentile) as the threshold for what counts as the same neuron on the same channel. This is used to confirm consistent neurons across multiple ephys recordings. 

![image](https://user-images.githubusercontent.com/92355713/142922922-42c3dddd-43fa-464a-9d86-c90d13fa6723.png)

citations:

Schoonover, Carl E et al. “Representational drift in primary olfactory cortex.” Nature vol. 594,7864 (2021): 541-546. doi:10.1038/s41586-021-03628-7
