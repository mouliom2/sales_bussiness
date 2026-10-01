# Project QA Checklist

This document records the checks performed before publishing the project on GitHub.

## Repository hygiene

- [x] Removed duplicated top-level Power BI project folder from the final repository.
- [x] Power BI local/cache files are excluded through `.gitignore`.
- [x] Dashboard images use descriptive file names.
- [x] README image links point to existing files.
- [x] No `.rar` archive is stored inside the repository.

## Data consistency

- [x] Power BI semantic model contains 5,000 transactions.
- [x] SQLite `fact_sales` contains 5,000 transactions.
- [x] Excel `05_Sales` contains the same 5,000 transactions.
- [x] Product, customer, store and salesperson identifiers map correctly to the relational dimensions.

## Reproducibility

- [x] Notebook uses a repository-relative database path.
- [x] Python dependencies are listed in `requirements.txt`.
- [x] Power BI project is included in PBIP format.
- [x] DAX measures are documented separately.

## Privacy

- [x] Dataset is synthetic.
- [x] No real customer/company data is included.
- [x] Power BI local settings and cache files are not included in the final repository.
