# POWER BI — SALES & BUSINESS PERFORMANCE CAMEROON

## Workflow
Base Excel → Modèle en étoile → DateTable → Mesures DAX → 4 pages de rapport → Interprétation métier.

## Import
Power BI Desktop → Accueil → Obtenir des données → Excel → charger SalesTable, StoresTable, ProductsTable, CustomersTable.

## Modèle
Relations actives, sens simple, cardinalité 1:* :
- DateTable[Date] → SalesTable[Date]
- StoresTable[Store_ID] → SalesTable[Store_ID]
- ProductsTable[Product_ID] → SalesTable[Product_ID]
- CustomersTable[Customer_ID] → SalesTable[Customer_ID]

## Page 1 — Executive Overview
Slicers : Année, Ville, Catégorie, Segment client.
Cartes : CA Total, Marge Brute, Taux de Marge, Transactions, Panier Moyen, Unités Vendues.
Visuels : évolution mensuelle du CA, CA par ville, CA par catégorie, modes de paiement, Part Mobile Money.

## Page 2 — Products & Profitability
KPI : CA, Marge, Taux de Marge, Unités.
Visuels : Top 10 produits, scatter CA vs Marge, combo CA + taux de marge par catégorie, matrice Catégorie > Produit.

## Page 3 — Customers & Channels
KPI : Clients Actifs, CA/Client, Panier Moyen, Part Mobile Money, Part B2B.
Visuels : CA par segment, CA par canal, modes de paiement, Top 15 clients, analyse des remises.

## Page 4 — Sales Force & Geography
KPI : CA, Marge, Variation CA YoY %, Variation Marge YoY %.
Visuels : Top commerciaux, CA et marge par ville, CA actuel vs année précédente, matrice Ville > Commercial.

## Format
- Page 16:9
- FCFA sans décimales pour CA/Marge/Panier
- Pourcentages à 1 décimale
- Slicers synchronisés si nécessaire
- Trier les barres par CA décroissant
- Utiliser des tooltips avec CA, Marge, Taux de Marge et Panier Moyen

## Ordre de construction
1. Importer les tables
2. Vérifier les types
3. Créer les relations
4. Créer DateTable
5. Marquer DateTable comme table de dates
6. Créer les mesures de base
7. Construire Page 1
8. Créer les mesures temporelles
9. Construire Pages 2 à 4
10. Importer le thème JSON
11. Vérifier les interactions et formats
12. Enregistrer sous Sales_Business_Performance_Cameroon.pbix
