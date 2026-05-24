-- =============================================================================
-- ANALYSES FINANCIERES ET COMPORTEMENTALES (REQUETES CLASSIQUES)
-- =============================================================================

-- Analyse de la résiliation des cliens de leurs abonnements
-- 26.54% ont résilié | 67.02% sont restés | 6.45% nouveaux clients
SELECT 
    customer_status,
    COUNT(*) AS nombre_clients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pourcentage
FROM churn
GROUP BY customer_status;


-- La raison principale du départ réside dans l'existence de meilleures 
-- offres chez les compétiteurs
SELECT 
    churn_category,
    churn_reason,
    COUNT(*) AS total_departs
FROM churn
WHERE customer_status = 'Churned'
GROUP BY churn_category, churn_reason
ORDER BY total_departs DESC;
LIMIT 5;

-- D'après ce résultat on remarque que la plupart des gens qui quittent
-- sont ceux qui s'inscrivent avec contrat mensuel alors que les gens avec
-- des contrats annuels (one/two year) préfèrent de rester
SELECT 
    s.contract,
    c.customer_status,
    COUNT(*) AS total_clients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY s.contract), 2) AS pourcentage_dans_ce_contrat
FROM subscriptions s
JOIN churn c ON s.customer_id = c.customer_id
GROUP BY s.contract, c.customer_status
ORDER BY s.contract, pourcentage_dans_ce_contrat DESC;

-- Le chiffre d'affaire (CA) généré vient en grande partie de la part des
-- clients qui choisissent de rester et qui constitue 82.51% du CA total
SELECT 
    c.customer_status,
    ROUND(SUM(b.monthly_charge), 2) AS total_charges_mensuelles,
    ROUND(SUM(b.total_revenue), 2) AS chiffre_affaires_total,
    ROUND(SUM(b.total_revenue) * 100.0/(SELECT SUM(total_revenue) FROM billing), 2) AS pourcentage_chiffre_affaires
FROM billing b
JOIN churn c ON b.customer_id = c.customer_id
GROUP BY c.customer_status
ORDER BY chiffre_affaires_total DESC;


-- La majorité des clients qui résilient sont ceux ayant acheté
-- un abonnement de Fiber Optic (Taux d'attrition critique de 40.72%)
SELECT 
    s.internet_type,
    COUNT(CASE WHEN c.customer_status = 'Churned' THEN 1 END) AS clients_perdus,
    COUNT(*) AS total_clients,
    ROUND(COUNT(CASE WHEN c.customer_status = 'Churned' THEN 1 END) * 100.0 / COUNT(*), 2) AS taux_de_churn
FROM subscriptions s
JOIN churn c ON s.customer_id = c.customer_id
WHERE s.internet_service = 'Yes'
GROUP BY s.internet_type;

-- =============================================================================
-- ANALYSES STATISTIQUES AVANCEES (WINDOW FUNCTIONS)
-- =============================================================================

-- Analyse de sur-facturation : Évalue si les clients qui partent subissent 
-- des tarifs anormalement plus élevés que la moyenne de leur groupe d'ancienneté.
-- Met en lumière un écart allant jusqu'à +39$ chez certains clients fidèles.
SELECT 
    b.customer_id,
    s.tenure_months,
    b.monthly_charge,
    -- Moyenne des charges mensuelles pour tous les clients ayant la même ancienneté
    ROUND(AVG(b.monthly_charge) OVER(PARTITION BY s.tenure_months), 2) AS charge_moyenne_anciennete,
    -- Écart individuel par rapport à cette moyenne
    ROUND(b.monthly_charge - AVG(b.monthly_charge) OVER(PARTITION BY s.tenure_months), 2) AS ecart_a_la_moyenne,
    ch.customer_status
FROM billing b
JOIN subscriptions s ON b.customer_id = s.customer_id
JOIN churn ch ON b.customer_id = ch.customer_id
ORDER BY s.tenure_months DESC, ecart_a_la_moyenne DESC;


-- Top 3 des pires motifs de Churn segmentés par type d'engagement.
-- Révèle que la perte d'abonnés est liée aux terminaux ("better devices") 
-- sur le court terme et aux offres tarifaires ("better offer") sur 
-- les contrats longs d'un ou deux ans.
WITH rang_motifs_churn AS (
    SELECT 
        s.contract,
        ch.churn_reason,
        COUNT(*) AS total_departs,
        -- Classement des motifs à l'intérieur de chaque type de contrat
        DENSE_RANK() OVER(PARTITION BY s.contract ORDER BY COUNT(*) DESC) AS rang_motif
    FROM subscriptions s
    JOIN churn ch ON s.customer_id = ch.customer_id
    WHERE ch.customer_status = 'Churned' AND ch.churn_reason IS NOT NULL
    GROUP BY s.contract, ch.churn_reason
)
SELECT * FROM rang_motifs_churn
WHERE rang_motif <= 3; -- On garde uniquement le Top 3 des raisons de départ par contrat


-- Analyse de la concentration géographique des revenus.
-- Permet d'identifier les zones géographiques clés : Los Angeles 
-- et San Diego soutiennent à elles seules près de 7.5% de l'économie 
-- globale de l'entreprise.
SELECT 
    l.city,
    ROUND(SUM(b.total_revenue), 2) AS revenu_total_ville,
    -- Ratio : Revenu de la ville / Revenu global de l'entreprise
    ROUND(
        SUM(b.total_revenue) * 100.0 / SUM(SUM(b.total_revenue)) OVER(), 
        2
    ) AS pourcentage_du_chiffre_affaires_global
FROM locations l
JOIN billing b ON l.customer_id = b.customer_id
GROUP BY l.city
ORDER BY revenu_total_ville DESC
LIMIT 10;

-- =============================================================================
-- AUTOMATISATION ET INTEGRATION BI (VUES / VIEWS)
-- =============================================================================

-- Création d'une table virtuelle pour analyser le risque de churn par contrat.
-- Cette vue permet de brancher directement un outil de Business Intelligence (Power BI / Looker)
CREATE OR REPLACE VIEW vue_analyse_contrat_churn AS
SELECT 
    s.contract,
    c.customer_status,
    COUNT(*) AS total_clients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY s.contract), 2) AS pourcentage_dans_ce_contrat
FROM subscriptions s
JOIN churn c ON s.customer_id = c.customer_id
GROUP BY s.contract, c.customer_status
ORDER BY s.contract;


SELECT * FROM vue_analyse_contrat_churn;