# Création des Ressources Azure pour PostgreSQL

Ce projet permet de créer des ressources Azure, y compris un serveur PostgreSQL flexible, via le script `create_postgres.sh`.

## Prérequis

Avant de lancer le script, assurez-vous d'avoir installé les outils suivants :

- [Azure CLI](https://docs.microsoft.com/fr-fr/cli/azure/install-azure-cli)
- [Scrapy](https://docs.scrapy.org/en/latest/intro/install.html)
- [Python 3.x](https://www.python.org/downloads/)
- Un compte Azure avec les permissions nécessaires pour créer des ressources

## Étapes pour Créer les Ressources et lancer le scrapping manuellement

1. Clonez ce dépôt sur votre machine locale.

   ```bash
   git clone https://github.com/hesolean/Scrapping_automatis-.git
   cd weeklymoviesscraper

2. Connectez-vous à votre compte Azure.

    az login

3. Exécutez le script create_postgres.sh pour créer les ressources sur Azure.

    chmod +x 1_create_postgres.sh
    ./1_create_postgres.sh

4. Lancer le scrapping directement

    pour lancer le scraping manuellement et stocker les données dans la base de données azure, aller dans le fichier settings.py et décommenter la ligne 68 :    # "weeklymoviesscraper.pipelines.DatabasePipeline": 300,

5. Lancer la commande de scraping

    pour lancer uniquement le scraping vers la bdd :
    scrapy crawl allomovies

    pour avoir en plus une copie en csv local :
    scrapy crawl allomovies -O allomovies.csv

## Étapes pour automatiser le scrapping

1. Faire les étapes 1 à 3

2. Lancer l'application de fonction

    chmod +x 2_function.sh
    ./2_function.sh

3. Récupération de la clé de l'application de fonction

    récupérer la clé de l'application de fonction directement sur l'interface web et la coller dans le fichier function_properties.json

4. Créer un batch et un pool

    chmod +x 3_batch_pool.sh
    ./3_batch_pool.sh

5. Lancer la suite

    chmod +x 4_datafactory.sh
    ./4_datafactory.sh