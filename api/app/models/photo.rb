class Photo < ActiveRecord::Base
  belongs_to :photographer
  
  class Create < Trailblazer::Operation
    # include Model, Representer
    # model Photo
    
    # contract do; end
    # representer do; end
    def process(params)
      # Representable -> Contract (after process_jsonapi)
      # validate(process_jsonapi(params)) do
        @model = Photo.create(process_jsonapi(params))
      # end
    end
    
    # Roar Render
    def to_hash(*)
      resource = create_resource(@model)
      document = Jsonapi::Document.new(data: resource)
      document.to_hash
    end
    
    def create_resource(object)
      Jsonapi::Document::Resource.new(
        id: object.id,
        type: 'photos',
        attributes: {
          title: object.title, src: object.src
        },
        links: { self: 'http://example.com/photos/1' }
      ).to_hash
    end
    
    # Roar Parse -> Representable 
    def process_jsonapi(params)
      document = Jsonapi::Document.new(params)
      photo_hash = document.data.resource.attributes.to_hash.symbolize_keys
      photo_hash.merge!(photographer_id: document.data.resource.relationships.first.data.id)
      photo_hash
    end
  end
end
