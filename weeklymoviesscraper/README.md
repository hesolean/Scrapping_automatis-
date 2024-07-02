# Création des Ressources Azure pour PostgreSQL

Ce projet permet de créer des ressources Azure, y compris un serveur PostgreSQL flexible, via le script `create_postgres.sh`.

## Prérequis

Avant de lancer le script, assurez-vous d'avoir installé les outils suivants :

- [Azure CLI](https://docs.microsoft.com/fr-fr/cli/azure/install-azure-cli)
- [Scrapy](https://docs.scrapy.org/en/latest/intro/install.html)
- [Python 3.x](https://www.python.org/downloads/)
- Un compte Azure avec les permissions nécessaires pour créer des ressources

## Étapes pour Créer les Ressources

1. Clonez ce dépôt sur votre machine locale.

   ```bash
   git clone https://github.com/hesolean/Scrapping_automatis-.git
   cd weeklymoviesscraper

2. Connectez-vous à votre compte Azure.

    az login

3. Exécutez le script create_postgres.sh pour créer les ressources sur Azure.

    ./create_postgres.sh

4. Lancez la commande scrapy pour stocker les données dans la base de données Azure et obtenir un ficchier de sauvegarde csv en local.

    scrapy crawl allomovies -O allomovies.csv