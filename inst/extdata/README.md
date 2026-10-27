# Example property data

These files are compact fixtures derived from the tables in the accompanying
technical memorandum *Regressão Hedônica Imobiliária*.

They are **asking-price observations and project-level ranges**, not verified
transactions. They are intended for parser tests, schema tests, exploratory
examples and demonstrations of the package API. They must not be used to claim
market representativeness or normative compliance.

## Files

- `ipiranga_compact_listings.csv`: compact apartments/studios in the Ipiranga
  area of São Paulo.
- `bortolan_luxury_houses.csv`: houses in gated communities around Represa
  Bortolan, Poços de Caldas/MG.

The fields preserve ranges where the source provides ranges. Empty values mean
that the memorandum did not report the attribute. Monetary values are BRL;
areas are square metres; distances are not supplied in these fixtures.

Source: *Regressão Hedônica Imobiliária*, supplied project attachment,
sections “Painel Amostral de Microdados Observados”.
