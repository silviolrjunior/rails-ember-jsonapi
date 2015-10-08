require "rails_helper"

RSpec.describe "CRUD", :type => :request do

  describe "Create" do
    it "retuns a collection" do
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
      response_body = {
        "data": {
          "type": "photos",
          "id": "1",
          "attributes": {
            "title": "Ember Hamster",
            "src": "http://example.com/images/productivity.png"
          },
          "links": {
            "self": "http://example.com/photos/1"
          }
        }
      }
    
      post "/photos", request_body, { Accept: 'application/vnd.api+json' }
      expect(response.status).to eq(201)
      expect(response.headers["Location"]).to eq("http://example.com/photos/1")
      expect(response.body).to eq(response_body.to_json)
      # expect(JSON.parse(response.body)).to eq(response_body)
    end
  end
end
