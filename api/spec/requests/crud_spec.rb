require "rails_helper"

RSpec.describe "CRUD", :type => :request do

  describe "Create" do
    it "retuns the created object" do
      @photographer = Photographer.create(name: "Picturer")
      request_body = {
        "data": {
          "type": "photos",
          "attributes": {
            "title": "Ember Hamster",
            "src": "http://example.com/images/productivity.png"
          },
          "relationships": {
            "photographer": {
              "data": { "type": "people", "id": "#{@photographer.id}" }
            }
          }
        }
      }
      post "/photos", request_body, { Accept: 'application/vnd.api+json' }
      @photo = Photo.last
      response_body = {
        "data": {
          "type": "photos",
          "id": "#{@photo.id}",
          "attributes": {
            "title": "Ember Hamster",
            "src": "http://example.com/images/productivity.png"
          },
          "links": {
            "self": "http://example.com/photos/1"
          }
        }
      }
      expect(response.status).to eq(201)
      expect(response.headers["Location"]).to eq("http://example.com/photos/1")
      expect(response.body).to eq(response_body.to_json)
      # expect(JSON.parse(response.body)).to eq(response_body)
    end
    
    context "Relationship" do
      context "is updated with a single object" do
        it "successfully" do
          @comment_old = Comment.create(body: 'Yeah, I like it!')
          @comment_new = Comment.create(body: 'Me too!!!')
          @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
          @article.comments << @comment_old
          @article.save!
          request_body = {
            "data": { "type": "comments", "id": "#{@comment_new.id}" }
          }
          post "/articles/#{@article.id}/relationships/comments", request_body, { Accept: 'application/vnd.api+json' }
          expect(response.status).to eq(204)
          expect(response.body).to be_empty
          @article.reload
          expect(@article.comments.size).to eq(2)
        end
      end
      
      context "is updated with a collection of objects" do
        it "successfully" do
          @comment1 = Comment.create(body: 'Yeah, I like it!')
          @comment2 = Comment.create(body: 'Me too!!!')
          @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
          @article.save!
          request_body = {
            "data": [
              { "type": "comments", "id": "#{@comment1.id}" },
              { "type": "comments", "id": "#{@comment2.id}" }
            ]
          }
          post "/articles/#{@article.id}/relationships/comments", request_body, { Accept: 'application/vnd.api+json' }
          expect(response.status).to eq(204)
          expect(response.body).to be_empty
          @article.reload
          expect(@article.comments.size).to eq(2)
        end
      end
    end
  end
  describe "Update" do
    describe "Resource" do
      describe "some attributes" do
        it "retuns the updated object" do
          @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
          request_body = {
            "data": {
              "type": "articles",
              "id": "#{@article.id}",
              "attributes": {
                "title": "To TDD or Not"
              }
            }
          }
          response_body = {
            "data": {
              "type": "articles",
              "id": "#{@article.id}",
              "attributes": {
                "title": "To TDD or Not",
                "text": "JSON API for, you know, Rails"
              },
              "links": {
                "self": "http://example.com/articles/#{@article.id}"
              }
            }
          }
  
          patch "/articles/#{@article.id}", request_body, { Accept: 'application/vnd.api+json' }
          expect(response.status).to eq(201)
          expect(response.body).to eq(response_body.to_json)
          # expect(JSON.parse(response.body)).to eq(response_body)
        end
      end
    
      describe "all attributes" do
        it "retuns the updated object" do
          @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
          request_body = {
            "data": {
              "type": "articles",
              "id": "#{@article.id}",
              "attributes": {
                "title": "To TDD or Not",
                "text": "TLDR; It's complicated... but check your test coverage regardless."
              }
            }
          }
          response_body = {
            "data": {
              "type": "articles",
              "id": "#{@article.id}",
              "attributes": {
                "title": "To TDD or Not",
                "text": "TLDR; It's complicated... but check your test coverage regardless."
              },
              "links": {
                "self": "http://example.com/articles/#{@article.id}"
              }
            }
          }
  
          patch "/articles/#{@article.id}", request_body, { Accept: 'application/vnd.api+json' }
          expect(response.status).to eq(201)
          expect(response.body).to eq(response_body.to_json)
          # expect(JSON.parse(response.body)).to eq(response_body)
        end
      end
    
      describe "has one relationship" do
        it "retuns the updated object" do
          @author = Author.create(first_name: "Celso", last_name: "Fernandes", twitter: "celsovjf")
          @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
          request_body = {
            "data": {
              "type": "articles",
              "id": "1",
              "relationships": {
                "author": {
                  "data": { "type": "people", "id": "1" }
                }
              }
            }
          }
          response_body = {
            "data": {
              "type": "articles",
              "id": "#{@article.id}",
              "attributes": {
                "title": "Rails + JSON API",
                "text": "JSON API for, you know, Rails"
              },
              "links": {
                "self": "http://example.com/articles/#{@article.id}"
              },
              "relationships": {
                "author": {
                  "data": { "type": "people", "id": "#{@author.id}" }
                }
              }
            }
          }
  
          patch "/articles/#{@article.id}", request_body, { Accept: 'application/vnd.api+json' }
          expect(response.status).to eq(201)
          expect(response.body).to eq(response_body.to_json)
          # expect(JSON.parse(response.body)).to eq(response_body)
        end
      
        describe "has many relationship" do
          it "retuns the updated object" do
            @tag1 = Tag.create(name: "rails")
            @tag2 = Tag.create(name: "jsonapi")
            @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
            request_body = {
              "data": {
                "type": "articles",
                "id": "1",
                "relationships": {
                  "tags": {
                    "data": [
                      { "type": "tags", "id": "#{@tag1.id}" },
                      { "type": "tags", "id": "#{@tag2.id}" }
                    ]
                  }
                }
              }
            }
            response_body = {
              "data": {
                "type": "articles",
                "id": "#{@article.id}",
                "attributes": {
                  "title": "Rails + JSON API",
                  "text": "JSON API for, you know, Rails"
                },
                "links": {
                  "self": "http://example.com/articles/#{@article.id}"
                },
                "relationships": {
                  "tags": {
                    "data": [
                      { "type": "tags", "id": "#{@tag1.id}" },
                      { "type": "tags", "id": "#{@tag2.id}" }
                    ]
                  }
                }
              }
            }
  
            patch "/articles/#{@article.id}", request_body, { Accept: 'application/vnd.api+json' }
            expect(response.status).to eq(201)
            expect(response.body).to eq(response_body.to_json)
            # expect(JSON.parse(response.body)).to eq(response_body)
          end
        end
      end
    end
    
    describe "Relationships" do
      context "belongs to" do
        context "is updated" do
          it "successfully" do
            @author = Author.create(first_name: 'Celso', last_name: 'Fernandes', twitter: 'celsovjf')
            @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
            request_body = {
              "data": { "type": "people", "id": "#{@author.id}" }
            }
            patch "/articles/#{@article.id}/relationships/author", request_body, { Accept: 'application/vnd.api+json' }
            expect(response.status).to eq(204)
            expect(response.body).to be_empty
            @article.reload
            expect(@article.author).to eq(@author)
          end
        end
        
        context "is removed" do
          it "successfully" do
            @author = Author.create(first_name: 'Celso', last_name: 'Fernandes', twitter: 'celsovjf')
            @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
            @article.author = @author
            @article.save!
            request_body = {
              "data": nil
            }
            patch "/articles/#{@article.id}/relationships/author", request_body, { Accept: 'application/vnd.api+json' }
            expect(response.status).to eq(204)
            expect(response.body).to be_empty
            @article.reload
            expect(@article.author).to eq(nil)
          end
        end
      end
      
      context "has many" do
        context "is updated" do
          it "successfully" do
            @tag1 = Tag.create(name: 'jsonapi')
            @tag2 = Tag.create(name: 'rails')
            @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
            request_body = {
              "data": [
                { "type": "tags", "id": "#{@tag1.id}" },
                { "type": "tags", "id": "#{@tag2.id}" }
              ]
            }
            patch "/articles/#{@article.id}/relationships/tags", request_body, { Accept: 'application/vnd.api+json' }
            expect(response.status).to eq(204)
            expect(response.body).to be_empty
            @article.reload
            expect(@article.tags.size).to eq(2)
          end
        end
        
        context "is removed" do
          it "successfully" do
            @tag1 = Tag.create(name: 'jsonapi')
            @tag2 = Tag.create(name: 'rails')
            @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
            @article.tags = [@tag1, @tag2]
            @article.save!
            request_body = {
              "data": []
            }
            patch "/articles/#{@article.id}/relationships/tags", request_body, { Accept: 'application/vnd.api+json' }
            expect(response.status).to eq(204)
            expect(response.body).to be_empty
            @article.reload
            expect(@article.tags.size).to eq(0)
          end
        end
      end
    end
  end
  
  describe "Delete" do
    it "the object" do
      @photo = Photo.create(title: 'JSON API Logo', src: 'http://example.com/jsonapi.png')
      delete "/photos/#{@photo.id}", nil, { Accept: 'application/vnd.api+json' }
      expect(response.status).to eq(204)
      expect(response.body).to be_empty
    end
    
    context "Relationship" do
      context "is updated with a single object" do
        it "successfully" do
          @comment1 = Comment.create(body: 'Yeah, I like it!')
          @comment2 = Comment.create(body: 'Me too!!!')
          @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
          @article.comments = [@comment1, @comment2]
          @article.save!
          request_body = {
            "data": { "type": "comments", "id": "#{@comment1.id}" }
          }
          delete "/articles/#{@article.id}/relationships/comments", request_body, { Accept: 'application/vnd.api+json' }
          expect(response.status).to eq(204)
          expect(response.body).to be_empty
          @article.reload
          expect(@article.comments.size).to eq(1)
          expect(@article.comments.first).to eq(@comment2)
        end
      end
      
      context "is updated with a collection of objects" do
        it "successfully" do
          @comment1 = Comment.create(body: 'Yeah, I like it!')
          @comment2 = Comment.create(body: 'Me too!!!')
          @article = Article.create(title: 'Rails + JSON API', text: "JSON API for, you know, Rails")
          @article.comments = [@comment1, @comment2]
          @article.save!
          request_body = {
            "data": [
              { "type": "comments", "id": "#{@comment1.id}" },
              { "type": "comments", "id": "#{@comment2.id}" }
            ]
          }
          delete "/articles/#{@article.id}/relationships/comments", request_body, { Accept: 'application/vnd.api+json' }
          expect(response.status).to eq(204)
          expect(response.body).to be_empty
          @article.reload
          expect(@article.comments.size).to eq(0)
        end
      end
    end
  end
end
