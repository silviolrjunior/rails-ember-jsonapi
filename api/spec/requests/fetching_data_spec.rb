require "rails_helper"

RSpec.describe "Fetching Data", :type => :request do

  describe "Resources" do
    it "retuns a collection" do
      Article.create(title: "JSON API paints my bikeshed!")
      Article.create(title: "Rails is Omakase")
      response_body = {
        "data": [{
          "type": "articles",
          "id": "1",
          "attributes": {
            "title": "JSON API paints my bikeshed!"
          }
        }, {
          "type": "articles",
          "id": "2",
          "attributes": {
            "title": "Rails is Omakase"
          }
        }],
        "links": {
          "self": "http://example.com/articles"
        }
      }
    
      get "/articles", {}, { Accept: 'application/vnd.api+json' }
      expect(response.body).to eq(response_body.to_json)
    end
  
    it "returns an empty collection" do
      response_body = {
        "data": [],
        "links": {
          "self": "http://example.com/articles"
        }
      }
    
      get "/articles", {}, { Accept: 'application/vnd.api+json' }
      expect(response.body).to eq(response_body.to_json)
    end
    
    it "returns a resource" do
      Article.create(title: "JSON API paints my bikeshed!")
      response_body = {
        "data": {
          "type": "articles",
          "id": "1",
          "attributes": {
            "title": "JSON API paints my bikeshed!"
          },
          "relationships": {
            "author": {
              "links": {
                "related": "http://example.com/articles/1/author"
              }
            }
          }
        },
        "links": {
          "self": "http://example.com/articles/1"
        }
      }
    
      get "/articles/1", {}, { Accept: 'application/vnd.api+json' }
      expect(response.body).to eq(response_body.to_json)
    end
    
    context "returns a resource relationship" do
      it "returns empty resource when relationship object does not exist" do
        Article.create(title: "JSON API paints my bikeshed!")
        response_body = {
          "data": nil,
          "links": {
            "self": "http://example.com/articles/1/author"
          }
        }
        get "/articles/1/author", {}, { Accept: 'application/vnd.api+json' }
        expect(response.body).to eq(response_body.to_json)
      end
      
      it "returns resource when relationship object exist" do
        @author = Author.create(first_name: 'Dan', last_name: 'Gebhardt', twitter: 'dgeb')
        Article.create(title: "JSON API paints my bikeshed!", author: @author)
        
        response_body = {
          "data": {
            "type": "people",
            "id": "1",
            "attributes": {
              "first-name": "Dan",
              "last-name": "Gebhardt",
              "twitter": "dgeb"
            }
          },
          "links": {
            "self": "http://example.com/articles/1/author"
          }
        }
        
        get "/articles/1/author", {}, { Accept: 'application/vnd.api+json' }
        expect(response.body).to eq(response_body.to_json)
      end
    end
  end
  
  describe "Relationships" do
    context "Articles - Tags" do
      context "when has two tags" do
        it "retuns a data with collection" do
          @article = Article.create(title: "JSON API paints my bikeshed!")
          @tag1 = Tag.create(name: 'jsonapi', article: @article)
          @tag2 = Tag.create(name: 'rails', article: @article)
          response_body = {
            "data": [
              { "type": "tags", "id": "#{@tag1.id}" },
              { "type": "tags", "id": "#{@tag2.id}" }
            ],
            "links": {
              "self": "/articles/1/relationships/tags",
              "related": "/articles/1/tags"
            }
          }
    
          get "/articles/#{@article.id}/relationships/tags", {}, { Accept: 'application/vnd.api+json' }
          expect(response.body).to eq(response_body.to_json)
        end
      end
      
      context "when has no tag" do
        it "retuns an empty data collection" do
          @article = Article.create(title: "JSON API paints my bikeshed!")
          response_body = {
            "data": [],
            "links": {
              "self": "/articles/1/relationships/tags",
              "related": "/articles/1/tags"
            }
          }
    
          get "/articles/#{@article.id}/relationships/tags", {}, { Accept: 'application/vnd.api+json' }
          expect(response.body).to eq(response_body.to_json)
        end
      end
    end
    
    context "Articles - Author" do
      context "when has an author" do
        it "retuns a data with resource" do
          @author = Author.create()
          @article = Article.create(title: "JSON API paints my bikeshed!", author: @author)
          response_body = {
            "data": {
              "type": "people",
              "id": "#{@author.id}"
            },
            "links": {
              "self": "/articles/1/relationships/author",
              "related": "/articles/1/author"
            }
          }
    
          get "/articles/#{@article.id}/relationships/author", {}, { Accept: 'application/vnd.api+json' }
          expect(response.body).to eq(response_body.to_json)
        end
      end
      
      context "when has no author" do
        it "retuns a null data" do
          @article = Article.create(title: "JSON API paints my bikeshed!")
          response_body = {
            "data": nil,
            "links": {
              "self": "/articles/1/relationships/author",
              "related": "/articles/1/author"
            }
          }
    
          get "/articles/#{@article.id}/relationships/author", {}, { Accept: 'application/vnd.api+json' }
          expect(response.body).to eq(response_body.to_json)
        end
      end
    end
  end
end
