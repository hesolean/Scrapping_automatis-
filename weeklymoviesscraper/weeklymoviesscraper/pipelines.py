# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter
import re

from .database import SessionLocal
from .models import Gender, Language, Media, Person, Serie

class WeeklymoviesscraperPipeline:
    def process_item(self, item, spider):
        item = self.cleaning_director(item)
        item = self.cleaning_duration(item)
        item = self.cleaning_sessions(item)
        item = self.cleaning_exit_date(item)
        item = self.cleaning_presse_score(item)
        item = self.cleaning_viewer_score(item)

        return item
    
    def cleaning_director(self, item):
        adapter = ItemAdapter(item)
        directors = adapter.get('director')

        # je garde les éléments de la liste entre "de" et "par"
        cleaned_director = []
        for director in directors:
            if director != "De":
                if director == "Par":
                    break
                else:
                    cleaned_director.append(director)
        adapter['director'] = cleaned_director
        return item
    
    def cleaning_duration(self, item):
        adapter = ItemAdapter(item)
        duration = adapter.get('duration')

        # je récupère indépendemment les chiffres avant h et ceux avant min
        motif_heures = r'(\d+)h'
        motif_minutes = r'(\d+)m'

        # je rassemble toutes la chaine de caractères en une seule
        value = ''.join(duration).strip()

        # j'initialise les variables
        minutes = 0
        minutes_heure = 0

        # je récupère les heures et les convertis en minutes
        if value and 'h' in value:
            minutes_heure = int(re.search(motif_heures, value).group(1)) * 60

        # je récupère les minutes
        if value and 'm' in value:
            minutes = int(re.search(motif_minutes, value).group(1))

        # j'additionne toutes les minutes
        cleaned_duration = minutes + minutes_heure
        adapter['duration'] = cleaned_duration
        return item
    
    def cleaning_sessions(self, item):
        adapter = ItemAdapter(item)
        sessions = adapter.get('sessions')

        # je garde les éléments dans les parenthèses
        motif = r'\d+'
        numbers = re.findall(motif, sessions)

        # Concaténer les chiffres avec un espace comme séparateur
        cleaned_sessions = ' '.join(numbers)
        adapter['sessions'] = cleaned_sessions
        return item
    
    def cleaning_exit_date(self, item):
        adapter = ItemAdapter(item)
        exit_date = adapter.get('exit_date')

        # je ne garde que le premier élément
        cleaned_exit_date = exit_date[0].strip()
        adapter['exit_date'] = cleaned_exit_date
        return item
    
    def cleaning_presse_score(self, item):
        adapter = ItemAdapter(item)
        presse_score = adapter.get('presse_score')

        # je ne garde que le premier élément
        cleaned_presse_score = presse_score[0]
        adapter['presse_score'] = cleaned_presse_score
        return item
    
    def cleaning_viewer_score(self, item):
        adapter = ItemAdapter(item)
        viewer_score = adapter.get('viewer_score')

        # je ne garde que le premier élément
        cleaned_viewer_score = viewer_score[2]
        adapter['viewer_score'] = cleaned_viewer_score
        return item

class DatabasePipeline:
    def __init__(self):
        self.Session = SessionLocal

    def open_spider(self, spider):
       self.session = self.Session()
    
    def process_item(self, item, spider):
        
        # récupération des médias
        media = Media(
            title=item['title'],
            original_title = item['original_title'],
            presse_score = item['presse_score'],
            viewer_score = item['viewer_score'],
            sessions = item['sessions'],
            exit_date = item['exit_date'],
            duration = item['duration'],
            synopsis = item['synopsis'],
            public = item['public'],
            country = item['country'],
            language = item['language'],
            distributor = item['distributor'],
            product_year = item['product_year'],
            media_type = item['media_type'],
            visa = item['visa']
        )

        # ajout de media pour obtenir son ID
        self.session.add(media)
        self.session.commit()
        
        # récupération des genres
        genders = item['gender']
        for gender in genders:
            existe_gender = self.session.query(Gender).filter_by(gender=gender).first()
            if not existe_gender:
                existe_gender=Gender(gender=gender)
                self.session.add(existe_gender)
            media.genders.append(existe_gender)
        
        # ajout des acteurs
        actors = item['actors']
        for actor in actors:
            self.add_person(actor, role='actor', media=media)

        # ajout des réalisateurs
        directors = item['director']
        for director in directors:
            self.add_person(director, role='director', media=media)

        # mise à jour des ajouts
        self.session.commit()
        return item
    
    # fonction pour l'ajout d'acteurs et directeurs
    def add_person(self, name, role, media):
        name_parts = name.split()

        # je gère les noms composés
        if len(name_parts) == 1:
            first_name = name
            last_name = None
            exist_person = self.session.query(Person).filter_by(first_name=first_name).first()
        elif len(name_parts) == 2:
            first_name, last_name = name.split()
            exist_person = self.session.query(Person).filter_by(first_name=first_name, last_name=last_name).first()
        else:
            first_name = name[0]
            last_name = ' '.join(name_parts[1:])
            exist_person = self.session.query(Person).filter_by(first_name=first_name, last_name=last_name).first()

        if not exist_person:
            exist_person = Person(first_name=first_name, last_name=last_name, role=role)
            self.session.add(exist_person)
        media.persons.append(exist_person)
        
    def close_spider(self, spider):
        self.session.close()