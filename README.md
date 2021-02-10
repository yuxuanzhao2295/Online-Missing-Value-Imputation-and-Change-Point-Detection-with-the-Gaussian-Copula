# Organization
The provided codes consist of codes for reproducing all experiments in paper "Online Missing Value Imputation and Dependence Change Detection for Mixed Data by the Gaussian Copula".
All used synthetic and real world datasets are also provided.
To run the codes smoothly, make sure the directory is added into working path. Running each method requires adding additional directory into the working path, detailed below.
The [online KFMC code](https://github.com/jicongfan/Online-high-rank-matrix-completion) and [grouse code](http://web.eecs.umich.edu/~girasole/?p=110) are slightly modified from authors' provided codes. 
Bayesian online change point detection implementattion requires [R package ocp](https://cran.r-project.org/web/packages/ocp/index.html).

## Structure
Algorithm implentation files are under directory Implementation. Experimental files are under directory Evaluation. All datasets are also under the directory Evaluation.

## Setup
The evaluation codes require Python, Matlab and R. To make sure codes run smoothly, make sure you set the following directories are correctly added:
(1) Add Implementation/EM_Methods to your Python path. 
(2) Add Implementation/grouse, Implementation/online_KFMC, Evaluation and Evaluation/helpers to your Matlab path.
(3) Add Evaluation to your R path.