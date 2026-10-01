-- =========================================================
-- PROJET DATA ANALYST
-- SALES & BUSINESS PERFORMANCE CAMEROON
-- ETAPE 2 : ANALYSE SQL
-- Base : SQLite
-- =========================================================

-- ---------------------------------------------------------
-- NIVEAU 1 — Comprendre la base
-- ---------------------------------------------------------

-- Q1. Combien de transactions avons-nous ?
SELECT COUNT(*) AS nombre_transactions
FROM fact_sales;

-- Q2. Quelle période couvre la base ?
SELECT
    MIN(date_vente) AS premiere_date,
    MAX(date_vente) AS derniere_date
FROM fact_sales;

-- Q3. Quel est le chiffre d'affaires total ?
SELECT
    ROUND(SUM(ca_net_fcfa), 0) AS chiffre_affaires_fcfa
FROM fact_sales;

-- Q4. Quelle est la marge brute totale et le taux de marge global ?
SELECT
    ROUND(SUM(marge_brute_fcfa), 0) AS marge_brute_fcfa,
    ROUND(100.0 * SUM(marge_brute_fcfa) / SUM(ca_net_fcfa), 2) AS taux_marge_pct
FROM fact_sales;

-- Q5. Quel est le panier moyen par transaction ?
SELECT
    ROUND(AVG(ca_net_fcfa), 0) AS panier_moyen_fcfa
FROM fact_sales;


-- ---------------------------------------------------------
-- NIVEAU 2 — Performance des agences
-- ---------------------------------------------------------

-- Q6. Classement des agences par chiffre d'affaires
SELECT
    s.ville,
    COUNT(*) AS transactions,
    ROUND(SUM(f.ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(SUM(f.marge_brute_fcfa), 0) AS marge_fcfa,
    ROUND(100.0 * SUM(f.marge_brute_fcfa) / SUM(f.ca_net_fcfa), 2) AS taux_marge_pct
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.ville
ORDER BY ca_fcfa DESC;

-- Q7. Quelle agence a le meilleur panier moyen ?
SELECT
    s.ville,
    ROUND(AVG(f.ca_net_fcfa), 0) AS panier_moyen_fcfa
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.ville
ORDER BY panier_moyen_fcfa DESC;

-- Q8. Evolution mensuelle du chiffre d'affaires par ville
SELECT
    SUBSTR(f.date_vente, 1, 7) AS mois,
    s.ville,
    ROUND(SUM(f.ca_net_fcfa), 0) AS ca_fcfa
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY mois, s.ville
ORDER BY mois, ca_fcfa DESC;


-- ---------------------------------------------------------
-- NIVEAU 3 — Produits et catégories
-- ---------------------------------------------------------

-- Q9. Catégories générant le plus de chiffre d'affaires
SELECT
    p.categorie,
    ROUND(SUM(f.ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(SUM(f.marge_brute_fcfa), 0) AS marge_fcfa,
    SUM(f.quantite) AS unites_vendues
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.categorie
ORDER BY ca_fcfa DESC;

-- Q10. Top 10 produits par chiffre d'affaires
SELECT
    p.produit,
    p.categorie,
    ROUND(SUM(f.ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(SUM(f.marge_brute_fcfa), 0) AS marge_fcfa,
    SUM(f.quantite) AS unites
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id, p.produit, p.categorie
ORDER BY ca_fcfa DESC
LIMIT 10;

-- Q11. Produits à forte vente mais faible taux de marge
SELECT
    p.produit,
    ROUND(SUM(f.ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(100.0 * SUM(f.marge_brute_fcfa) / SUM(f.ca_net_fcfa), 2) AS taux_marge_pct
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id, p.produit
HAVING SUM(f.ca_net_fcfa) > (
    SELECT AVG(ca_produit)
    FROM (
        SELECT SUM(ca_net_fcfa) AS ca_produit
        FROM fact_sales
        GROUP BY product_id
    )
)
ORDER BY taux_marge_pct ASC;


-- ---------------------------------------------------------
-- NIVEAU 4 — Clients
-- ---------------------------------------------------------

-- Q12. Performance par segment client
SELECT
    c.segment_client,
    COUNT(*) AS transactions,
    ROUND(SUM(f.ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(AVG(f.ca_net_fcfa), 0) AS panier_moyen_fcfa,
    ROUND(SUM(f.marge_brute_fcfa), 0) AS marge_fcfa
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.segment_client
ORDER BY ca_fcfa DESC;

-- Q13. Top 20 clients par chiffre d'affaires
SELECT
    c.customer_id,
    c.nom_client,
    c.segment_client,
    COUNT(*) AS transactions,
    ROUND(SUM(f.ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(SUM(f.marge_brute_fcfa), 0) AS marge_fcfa
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.nom_client, c.segment_client
ORDER BY ca_fcfa DESC
LIMIT 20;

-- Q14. Clients inactifs depuis plus de 180 jours par rapport à la dernière date disponible
WITH derniere_date AS (
    SELECT MAX(date_vente) AS max_date FROM fact_sales
),
derniere_vente_client AS (
    SELECT customer_id, MAX(date_vente) AS derniere_vente
    FROM fact_sales
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.segment_client,
    d.derniere_vente
FROM derniere_vente_client d
JOIN dim_customer c ON d.customer_id = c.customer_id
CROSS JOIN derniere_date x
WHERE julianday(x.max_date) - julianday(d.derniere_vente) > 180
ORDER BY d.derniere_vente;


-- ---------------------------------------------------------
-- NIVEAU 5 — Canaux et paiements
-- ---------------------------------------------------------

-- Q15. Performance par canal de vente
SELECT
    canal,
    COUNT(*) AS transactions,
    ROUND(SUM(ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(AVG(ca_net_fcfa), 0) AS panier_moyen_fcfa
FROM fact_sales
GROUP BY canal
ORDER BY ca_fcfa DESC;

-- Q16. Part du chiffre d'affaires par mode de paiement
SELECT
    mode_paiement,
    ROUND(SUM(ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(
        100.0 * SUM(ca_net_fcfa) / (SELECT SUM(ca_net_fcfa) FROM fact_sales),
        2
    ) AS part_ca_pct
FROM fact_sales
GROUP BY mode_paiement
ORDER BY ca_fcfa DESC;

-- Q17. Part combinée MTN MoMo + Orange Money
SELECT
    ROUND(SUM(CASE
        WHEN mode_paiement IN ('MTN MoMo', 'Orange Money')
        THEN ca_net_fcfa ELSE 0 END), 0) AS ca_mobile_money,
    ROUND(
        100.0 * SUM(CASE
            WHEN mode_paiement IN ('MTN MoMo', 'Orange Money')
            THEN ca_net_fcfa ELSE 0 END)
        / SUM(ca_net_fcfa), 2
    ) AS part_mobile_money_pct
FROM fact_sales;


-- ---------------------------------------------------------
-- NIVEAU 6 — Commerciaux et remises
-- ---------------------------------------------------------

-- Q18. Top 10 commerciaux
SELECT
    sp.commercial,
    sp.ville,
    COUNT(*) AS transactions,
    ROUND(SUM(f.ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(SUM(f.marge_brute_fcfa), 0) AS marge_fcfa
FROM fact_sales f
JOIN dim_salesperson sp ON f.salesperson_id = sp.salesperson_id
GROUP BY sp.salesperson_id, sp.commercial, sp.ville
ORDER BY ca_fcfa DESC
LIMIT 10;

-- Q19. Les remises sont-elles associées à un panier moyen plus élevé ?
SELECT
    CASE WHEN taux_remise > 0 THEN 'Avec remise' ELSE 'Sans remise' END AS groupe,
    COUNT(*) AS transactions,
    ROUND(AVG(ca_net_fcfa), 0) AS panier_moyen_fcfa,
    ROUND(AVG(quantite), 2) AS quantite_moyenne,
    ROUND(100.0 * SUM(marge_brute_fcfa) / SUM(ca_net_fcfa), 2) AS taux_marge_pct
FROM fact_sales
GROUP BY groupe;


-- ---------------------------------------------------------
-- NIVEAU 7 — Tendances temporelles / SQL analytique
-- ---------------------------------------------------------

-- Q20. CA par mois
SELECT
    SUBSTR(date_vente, 1, 7) AS mois,
    ROUND(SUM(ca_net_fcfa), 0) AS ca_fcfa
FROM fact_sales
GROUP BY mois
ORDER BY mois;

-- Q21. Croissance MoM du chiffre d'affaires
WITH ca_mensuel AS (
    SELECT
        SUBSTR(date_vente, 1, 7) AS mois,
        SUM(ca_net_fcfa) AS ca
    FROM fact_sales
    GROUP BY mois
),
evolution AS (
    SELECT
        mois,
        ca,
        LAG(ca) OVER (ORDER BY mois) AS ca_mois_precedent
    FROM ca_mensuel
)
SELECT
    mois,
    ROUND(ca, 0) AS ca_fcfa,
    ROUND(100.0 * (ca - ca_mois_precedent) / ca_mois_precedent, 2) AS croissance_mom_pct
FROM evolution
ORDER BY mois;

-- Q22. Chiffre d'affaires et marge par année
SELECT
    SUBSTR(date_vente, 1, 4) AS annee,
    ROUND(SUM(ca_net_fcfa), 0) AS ca_fcfa,
    ROUND(SUM(marge_brute_fcfa), 0) AS marge_fcfa,
    ROUND(100.0 * SUM(marge_brute_fcfa) / SUM(ca_net_fcfa), 2) AS taux_marge_pct
FROM fact_sales
GROUP BY annee
ORDER BY annee;

-- Q23. Contribution cumulée des clients (analyse Pareto)
WITH client_ca AS (
    SELECT
        customer_id,
        SUM(ca_net_fcfa) AS ca
    FROM fact_sales
    GROUP BY customer_id
),
classement AS (
    SELECT
        customer_id,
        ca,
        SUM(ca) OVER (ORDER BY ca DESC) AS ca_cumule,
        SUM(ca) OVER () AS ca_total
    FROM client_ca
)
SELECT
    customer_id,
    ROUND(ca, 0) AS ca_client,
    ROUND(100.0 * ca_cumule / ca_total, 2) AS part_cumulee_pct
FROM classement
ORDER BY ca DESC
LIMIT 50;

-- Q24. Saisonnalité : mois de l'année les plus performants
SELECT
    STRFTIME('%m', date_vente) AS mois_num,
    CASE STRFTIME('%m', date_vente)
        WHEN '01' THEN 'Janvier'
        WHEN '02' THEN 'Février'
        WHEN '03' THEN 'Mars'
        WHEN '04' THEN 'Avril'
        WHEN '05' THEN 'Mai'
        WHEN '06' THEN 'Juin'
        WHEN '07' THEN 'Juillet'
        WHEN '08' THEN 'Août'
        WHEN '09' THEN 'Septembre'
        WHEN '10' THEN 'Octobre'
        WHEN '11' THEN 'Novembre'
        WHEN '12' THEN 'Décembre'
    END AS mois,
    ROUND(SUM(ca_net_fcfa), 0) AS ca_fcfa
FROM fact_sales
GROUP BY mois_num
ORDER BY ca_fcfa DESC;

-- Q25. Tableau final pour Power BI : vue analytique dénormalisée
CREATE VIEW IF NOT EXISTS vw_sales_analysis AS
SELECT
    f.transaction_id,
    f.date_vente,
    SUBSTR(f.date_vente,1,4) AS annee,
    SUBSTR(f.date_vente,1,7) AS annee_mois,
    s.ville,
    s.region,
    c.segment_client,
    p.categorie,
    p.produit,
    sp.commercial,
    f.canal,
    f.mode_paiement,
    f.quantite,
    f.prix_unitaire_fcfa,
    f.taux_remise,
    f.ca_net_fcfa,
    f.marge_brute_fcfa,
    f.taux_marge
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_salesperson sp ON f.salesperson_id = sp.salesperson_id;

SELECT * FROM vw_sales_analysis LIMIT 20;