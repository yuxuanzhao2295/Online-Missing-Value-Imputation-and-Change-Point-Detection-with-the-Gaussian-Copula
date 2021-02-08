# Organization
The provided codes consist of python codes for all EM methods, Matlab codes for GROUSE and online KFMC, including both algorithm implementation files and experimental files at selected tuning parameters and R codes for reproducing the plots.
All used synthetic and real world datasets are also provided.
To run the codes smoothly, make sure the directory is added into working path. Running each method requires adding additional directory into the working path, detailed below.

## EM methods

To run EM methods, add supplement5766/EM_methods into path. All the experiments files appear under supplement5766/EM_methods/evaluation: EM_sim_offline.py for reproducing results in Table 1; EM_sim_online.py for reproducing results in Figure 2; EM_movielens.py for reproducing results in Table 2; EM_stocks.py for reproducing results in Figure 3.

The codes for conducting resampling test (see supplement section 2) are also provided in supplement5766/EM_methods/evaluation/EM_sim_online_resampling_test.py.

## GROUSE
To run GROUSE, add supplement5766/GROUSE, supplement5766/data_sim_offline, supplement5766/data_sim_onine and supplement5766/data_movielens1m_masked into path. We modify upon the author's provided Matlab codes so that it can return the fitted subspace residuals and avoid numerical instability due to vanishing gradient step. Specifically, when an update step returns inf value  in GROUSE, we skip that step. Under supplement5766/GROUSE, the implementation file (grouse.m) as well as all the experiments files can be found.

## Online KFMC
To run online KFMC, add supplement5766/OnlineKFMC, supplement5766/data_sim_offline, supplement5766/data_sim_onine and supplement5766/data_movielens1m_masked into path. We use the author's provided Matlab codes. Under supplement5766/OnlineKFMC, the implementation file (KFMC_online.m) as well as all the experiments files can be found.

## Reproduce plots
We provided our R codes for plotting Figure 2 and Figure 3 with stored results. Notice Figure 3 is corrected in the supplement (see section 4.1). To reproduce the plots, use plot_figure2.R and plot_figure3.R (make sure you add the corresponding directories into R, detailed in the files).
