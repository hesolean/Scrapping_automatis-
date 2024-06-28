# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter
import re

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