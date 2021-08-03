## ReSySeVR: VF Extension

### Data Preparation Steps

1. `SySeVR-temp-data-operation.ipynb`: merge and pack separate raw files.
2. (optional) `SySeVR-KHop-Graph-Inlining.ipynb`: extend the prgram dependency graph to k-hop inter procedural call.
3. `SySeVR-NewMakeLabel.ipynb`: make labels. Note that the results are further re-used by `SySeVR-tokenize-relabel.ipynb` and replaced.
4. `SySeVR-temp-data-operation.ipynb`: merge and pack separate files.
5. (deprecated) `SySeVR-Create-Dataset.ipynb`: create data for graph network.
6. (deprecated) `SySeVR-temp-data-operation.ipynb`: merge and pack separate ready pkl files.
7. `SySeVR-tokenize-relabel.ipynb`: tokenize, make labels and create data for graph network.
8. (deprecated) `SySeVR-GNN-test.ipynb`: baseline graph network.
9. `SySeVR-train-with-embedding.ipynb`: graph network with embedding

