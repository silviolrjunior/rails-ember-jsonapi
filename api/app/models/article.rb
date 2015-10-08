class Article < ActiveRecord::Base
  belongs_to :author
  has_many :comments
  has_many :tags

  class Create < Trailblazer::Operation
    # include Model, Representer
    # model Article
    
    # contract do; end
    # representer do; end
    def process(params)
      puts params
    end
  end
  
  class Show < Trailblazer::Operation
    def process(params); end
    def model!(params)
      Article.find(params[:id])
    end
    
    def to_hash(*)
      resource = create_resource(@model)
      # TODO: generate link on representer
      document = Jsonapi::Document.new(links: {self: 'http://example.com/articles/1'}, data: resource)
      document.to_hash
    end
    
    def create_resource(object)
      # TODO: type comes from representer
      Jsonapi::Document::Resource.new(
        id: object.id,
        type: 'articles',
        # TODO: discover which attributes, we have on representer
        attributes: {
          title: object.title, text: object.text
        },
        # TODO: create DSL on representer for belongs_to
        # TODO: is there any way to get has_one and has_many on representer?
        relationships: {
          author: {
            # TODO: generate link dinamically
            links: {
              related: "http://example.com/articles/#{object.id}/author"
            }
          }
        }
      ).to_hash
    end
  end
  
  class Index < Trailblazer::Operation
    # include Representer, Collection

    def model!(params)
      Article.all
    end
    def process(params); end
    
    
    # Roar Render
    def to_hash(*)
      resources = []
      @model.each do |object|
        resources << create_resource(object)
      end
      document = Jsonapi::Document.new(links: {self: 'http://example.com/articles'}, data: resources)
      document.to_hash
    end
    
    def create_resource(object)
      Jsonapi::Document::Resource.new(id: object.id, type: 'articles', attributes: {title: object.title, text: object.text}).to_hash
    end
  end
  
  # This is 
  class Relationship < Trailblazer::Operation
    def process(params); end
    
    def to_hash(*)
      resource = create_resource(@model)
      if resource.nil?
        document = Jsonapi::Document.new(links: {self: 'http://example.com/articles/1/author'}, data: nil)
      else
        document = Jsonapi::Document.new(links: {self: 'http://example.com/articles/1/author'}, data: resource)
      end
      document.to_hash
    end
    
    def create_resource(object)
      return nil if object.nil?
      Jsonapi::Document::Resource.new(
        id: object.id.to_s,
        type: 'people',
        attributes: {
          'first-name': object.first_name, 'last-name': object.last_name, twitter: object.twitter
        }
      ).to_hash
    end

    def model!(params)
      @params = params
      @article = Article.find(params[:article_id])
      @model = @article.send(params[:relationship])
      @model
    end
  end
  
  # This is a operation for:
  # http://jsonapi.org/format/1.0/#fetching-relationships
  # TODO: how we make a representer for each relation ship (DSL on representer?)
  class Relationships < Relationship
    # Roar Render
    def to_hash(*)
      if @model.is_a?(ActiveRecord::Associations::CollectionProxy)
        resource = collection_hash(@model)
      else
        resource = resource_hash(@model)
      end
      
      links = create_links

      # Create Resource
      if resource.nil?
        document = Jsonapi::Document.new(links: links, data: nil)
      else
        document = Jsonapi::Document.new(links: links, data: resource)
      end
      document.to_hash
    end
    
    # TODO: representer generate these links
    def create_links
      {
        self: "/articles/1/relationships/#{@params[:relationship]}",
        related: "/articles/1/#{@params[:relationship]}"
      }
      
    end

    def collection_hash(collection)
      return [] if collection.empty?
      resources = []
      collection.each do |object|
        resources << resource_hash(object)
      end
      resources
    end
    
    def resource_hash(object)
      return nil if object.nil?
      type = @params[:relationship]
      type = object.jsonapi_type if object.respond_to?(:jsonapi_type)
      Jsonapi::Document::ResourceIdentifier.new(
        id: object.id.to_s,
        type: type
      ).to_hash
    end
  end
end
