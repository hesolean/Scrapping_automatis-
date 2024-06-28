# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class WeeklymoviesscraperItem(scrapy.Item):
    title  = scrapy.Field()
    original_title = scrapy.Field()
    presse_score = scrapy.Field()
    viewer_score = scrapy.Field()
    sessions = scrapy.Field()
    gender = scrapy.Field()
    exit_date = scrapy.Field()
    duration = scrapy.Field()
    synopsis = scrapy.Field()
    actors = scrapy.Field()
    director = scrapy.Field()
    public = scrapy.Field()
    country = scrapy.Field()
    language = scrapy.Field()
    distributor = scrapy.Field()
    product_year = scrapy.Field()
    movie_type = scrapy.Field()
