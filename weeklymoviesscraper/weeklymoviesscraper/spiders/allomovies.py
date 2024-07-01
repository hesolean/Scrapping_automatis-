import scrapy
from weeklymoviesscraper.items import WeeklymoviesscraperItem


class AllomoviesSpider(scrapy.Spider):
    name = "allomovies"
    allowed_domains = ["allocine.fr"]
    start_urls = ["https://allocine.fr/film/sorties-semaine/"]

    def parse(self, response):
        # liste des éléments à scraper
        movies = response.xpath(".//li[@class='mdl']")

        # je mape sur la liste des films
        for movie in movies:
            movie_url = movie.xpath(".//a[@class='meta-title-link']/@href").get()
            yield response.follow(movie_url, callback=self.parse_movie)

    def parse_movie(self, response):
        item = WeeklymoviesscraperItem()

        # je procède au nettoyage des données scrapées par film
        item['title'] = response.xpath(".//div[@class='titlebar-title titlebar-title-xl']/text()").get()
        item['original_title'] = response.xpath(".//div[@class='card entity-card entity-card-list cf entity-card-player-ovw']//div[@class='meta-body-item']/span[@class='dark-grey']/text()").get()
        item['presse_score'] = response.xpath(".//div[@class='rating-item']/div/div/span/text()").getall()
        item['viewer_score'] = response.xpath(".//div[@class='rating-item']/div/div/span/text()").getall()
        item['sessions'] = response.xpath(".//div[@class='buttons-holder']/span/span/text()").get()
        item['gender'] = response.xpath(".//div[@class='meta-body-item meta-body-info']/span[@class='spacer'][2]/following-sibling::span/text()").getall()
        item['exit_date'] = response.xpath(".//div[@class='meta-body-item meta-body-info']/span/text()").get()
        item['duration'] = response.xpath("//div[@class='meta-body-item meta-body-info']/text()").getall()
        item['synopsis'] = response.xpath(".//section[@id='synopsis-details']/div[@class='content-txt ']/p/text()").get()
        item['actors'] = response.xpath(".//section[@class='section ovw']//div[@class='gd gd-gap-20 gd-xs-2 gd-s-4']//a/text()").getall()
        item['director'] = response.xpath(".//div[@class='meta-body-item meta-body-direction meta-body-oneline']/span/text()").getall()
        item['public'] = response.xpath(".//section[@id='synopsis-details']/div[@class='certificate']/span/text()").get()
        item['country'] = response.xpath(".//section[@class='section ovw ovw-technical']/div[@class='item']//span[@class='that']/span/text()").get()
        item['language'] = response.xpath(".//section[@class='section ovw ovw-technical']//span[@class='what light' and text()='Langues']/following-sibling::span/text()").get()
        item['distributor'] = response.xpath(".//section[@class='section ovw ovw-technical']//span[@class='what light' and text()='Distributeur']/following-sibling::span/text()").get()
        item['product_year'] = response.xpath(".//section[@class='section ovw ovw-technical']//span[@class='what light' and text()='Année de production']/following-sibling::span/text()").get()
        item['media_type'] = response.xpath(".//section[@class='section ovw ovw-technical']//span[@class='what light' and text()='Type de film']/following-sibling::span/text()").get()
        item['visa'] = response.xpath(".//section[@class='section ovw ovw-technical']//span[@class='what light' and text()='N° de Visa']/following-sibling::span/text()").get()

        yield item