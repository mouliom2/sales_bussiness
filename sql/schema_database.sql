-- SALES & BUSINESS PERFORMANCE CAMEROON
-- Schéma en étoile simplifié (SQLite)

PRAGMA foreign_keys = ON;

CREATE TABLE dim_store (
    store_id TEXT PRIMARY KEY,
    ville TEXT NOT NULL,
    region TEXT NOT NULL,
    indice_activite REAL
);

CREATE TABLE dim_product (
    product_id TEXT PRIMARY KEY,
    categorie TEXT NOT NULL,
    produit TEXT NOT NULL,
    prix_base_fcfa INTEGER NOT NULL,
    cout_unitaire_base_fcfa INTEGER NOT NULL
);

CREATE TABLE dim_customer (
    customer_id TEXT PRIMARY KEY,
    nom_client TEXT NOT NULL,
    segment_client TEXT NOT NULL,
    ville_client TEXT,
    region_client TEXT
);

CREATE TABLE dim_salesperson (
    salesperson_id TEXT PRIMARY KEY,
    commercial TEXT NOT NULL,
    store_id TEXT NOT NULL,
    ville TEXT NOT NULL
);

CREATE TABLE fact_sales (
    transaction_id TEXT PRIMARY KEY,
    date_vente TEXT NOT NULL,
    store_id TEXT NOT NULL,
    customer_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    salesperson_id TEXT NOT NULL,
    canal TEXT NOT NULL,
    mode_paiement TEXT NOT NULL,
    quantite INTEGER NOT NULL,
    prix_unitaire_fcfa INTEGER NOT NULL,
    taux_remise REAL NOT NULL,
    cout_unitaire_fcfa INTEGER NOT NULL,
    ventes_brutes_fcfa REAL NOT NULL,
    montant_remise_fcfa REAL NOT NULL,
    ca_net_fcfa REAL NOT NULL,
    cout_total_fcfa REAL NOT NULL,
    marge_brute_fcfa REAL NOT NULL,
    taux_marge REAL NOT NULL
);