# Software/Code Description for Main Text or Methods Section

## 1) Key operations performed by the software/code

The workflow performs two primary analysis streams:

1. **Behavioral/statistical replication**
   - Loads and preprocesses experimental and rating datasets.
   - Computes choice-induced bias (CIB), consistency measures, and rating-change analyses.
   - Produces summary statistics and inferential tests as reported in the notebooks.

2. **Generative model replication and evaluation**
   - Uses Stan-based model definitions and precomputed outputs.
   - Compares model variants using stored LOO metrics.
   - Evaluates qualitative and quantitative predictive performance against observed behavior.

## 2) Fundamental task(s) and overall approach

The software addresses a reproducibility task: re-creating and interrogating behavioral and model-based results for CIB across experiments/domains.

General approach:

- Data are loaded from packaged `.RData` files via helper functions.
- Analysis notebooks apply domain-specific summary functions and grouped statistics.
- Model-related notebooks use saved prediction and fit tables to validate model behavior without requiring expensive full refits.
- Optional full Bayesian refits can be performed with `brms`/Stan when computational resources permit.

## 3) Key characteristics

### Algorithms and analysis logic

- Trial/session-level aggregation of behavioral outcomes.
- Correlation-based consistency analyses (e.g., Spearman correlations for ranking consistency).
- Inferential statistics including t-tests and effect size summaries.
- Bayesian model evaluation using leave-one-out (LOO) criteria on posterior-derived log-likelihood structures.

### Installation and use

- Installation steps and dependencies are documented in `installation.md`.
- A runnable demonstration with expected runtime windows is provided in `demo.Rmd`
- Replication scripts are provided in `replicate_part1.Rmd` and `replicate_part2.Rmd`


### Dependencies

Core dependencies include R packages `tidyverse`, `devtools` and GitHub-hosted packages `cibtools` and `wztools`.
Additional, non-necessary but helpful packages include: `skimr`, `brms`, `loo`, `posterior` and `cmdstanr`


## 4) Dataset description

Datasets required for replicating the results are included in:

- `0.data/all5.RData`
- `0.data/all5m.RData`
- `0.data/rall5.Rdata`
- `0.data/rall5m.Rdata`

These files enable complete demonstration of data loading, behavioral summaries, consistency metrics, and model-output inspection.

Model summary files included:

- `2.models/fits/loo/*.csv`
- `2.models/fits/preds/*.csv`
- `2.models/fits/params/*.csv`
