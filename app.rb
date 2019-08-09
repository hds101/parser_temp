require 'bundler/setup'
Bundler.require :default
Dir["./lib/*.rb"].each { |file| require file }

GustSpider.crawl!
