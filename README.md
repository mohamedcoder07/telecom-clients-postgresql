# 📊 Projet d'Architecture & d'Analyse SQL : Telecom Churn

## 📝 Présentation du Projet
L'idée du projet est de partir d'un fichier CSV unique et volumineux (7 043 lignes contenant toutes les infos des clients d'une entreprise télécom) pour le transformer en une base de données relationnelle propre, performante et bien structurée sous **PostgreSQL (pgAdmin)**.

Une fois cette restructuration (normalisation) effectuée, plusieurs analyses de haut niveau ont été menées à l'aide de requêtes complexes et de fonctions de fenêtrage afin d'isoler des insights business stratégiques liés à l'attrition des clients (le *Churn*).

---

## 🛠️ Phase 1 : Ingestion et Normalisation des Données

### 1. La Table de Stockage ("Staging")
Avant de segmenter le dataset, il était nécessaire de l'importer sans blocage technique. La table temporaire `raw_import` a été configurée en reprenant scrupuleusement l'ordre et le type des colonnes du fichier CSV d'origine. Cette méthode a garanti le chargement de l'intégralité des 7 043 lignes en une seule opération, évitant ainsi les erreurs de conversion de types.

### 2. Découpage en Sous-Tables (Modèle Relationnel)
Afin de respecter les principes de normalisation et de garantir la cohérence des informations, le fichier d'origine a été éclaté en **6 sous-tables thématiques**. Elles sont toutes reliées entre elles par l'identifiant unique du client (`customer_id`) via des contraintes de clés primaires et de clés étrangères :

* **`customers`** : Profil démographique de base (genre, âge, situation familiale).
* **`locations`** : Données géographiques précises (villes, codes postaux, coordonnées GPS).
* **`subscriptions`** : Détails contractuels et d'engagement (type de contrat, ancienneté, services principaux).
* **`service_features`** : Options additionnelles activées (sécurité internet, support technique, streaming).
* **`billing`** : Indicateurs financiers individuels (charges mensuelles, revenus totaux, méthodes de paiement).
* **`churn`** : Statut d'activité du client et motifs détaillés des départs.

### 3. La Migration des Données (Processus ETL)
L'alimentation des tables finales s'est faite via un processus d'insertion strict (`INSERT INTO ... SELECT`). Les identifiants techniques (`location_id`, `subscription_id`, etc.) ont été configurés via le type `SERIAL` de PostgreSQL pour s'auto-incrémenter de manière transparente.

---

## 🔍 Phase 2 : Analyses Business & Requêtes SQL Avancées

La séparation des données en sous-tables a permis de valider la puissance des **jointures (`JOIN`)** pour croiser les dimensions et faire parler les données. Les requêtes se sont concentrées sur l'utilisation des fonctions de fenêtrage (**Window Functions**) et des expressions de table communes (**CTE**).

### 💡 Constats Majeurs Identifiés (Insights) :

La séparation des données en sous-tables a permis de valider la puissance des jointures (`JOIN`) pour croiser les dimensions et faire parler les données. En exécutant les requêtes de statistiques, plusieurs constats majeurs ont été identifiés pour l'entreprise :

1. **Un taux de Churn critique (26.54%)** : Plus d'un quart de la base client a quitté l'entreprise. Financièrement, cela représente un manque à gagner direct de **137 086,65 $ de pertes mensuelles**, alors que les clients qui restent soutiennent 82.51% du chiffre d'affaires.
2. **Le danger du contrat mensuel** : L'analyse montre que **45.84%** des clients ayant un contrat "Mois par mois" (*Month-to-month*) partent rapidement. À l'inverse, l'engagement est redoutablement efficace : le taux de départ tombe à seulement **2.55%** pour les contrats sur 2 ans.
3. **Le problème de la Fibre Optique** : C'est la surprise des données : les clients équipés de la fibre affichent un taux de fuite massif de **40.72%**. C'est un signal d'alarme critique sur la qualité du réseau ou les tarifs de ce service spécifique.
4. **La fuite vers la concurrence** : Le classement des motifs montre que la concurrence directe récupère nos clients principalement grâce à des terminaux plus modernes (*Better devices*) sur le court terme, et de meilleures offres de prix sur les contrats à long terme. Géographiquement, la ville de **Los Angeles** représente le plus grand marché mais aussi la plus forte zone de risque en concentrant près de **4% du chiffre d'affaires global**.

---

## 📁 Organisation des Fichiers dans ce Repository

* 📄 `README.md` : Description de la démarche et conclusions analytiques.
* 📂 `scripts_sql/`
  * 📜 `create_raw_staging.sql` : Création de la table d'ingestion brute.
  * 📜 `sub_tables_creation.sql` : Script d'architecture des 6 sous-tables avec clés primaires/étrangères.
  * 📜 `data_migration.sql` : Requêtes de répartition et d'insertion des données.
  * 📜 `analytical_queries.sql` : Pack complet des requêtes d'analyses et des vues.
