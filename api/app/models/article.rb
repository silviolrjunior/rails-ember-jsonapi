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

  # contract do; end
  # representer do; end
  class Update < Trailblazer::Operation
    def process(params);
      # Representable -> Contract (after process_jsonapi)
      # validate(process_jsonapi(params)) do
      process_jsonapi(params)
      # end
    end
    def model!(params)
      Article.find(params[:id])
    end
    
    # Roar Parse -> Representable 
    # def process_jsonapi(params)
    #   document = Jsonapi::Document.new(params)
    #   article_hash = document.data.resource.attributes.to_hash.symbolize_keys
    #   article_hash
    # end
    # Roar Parse -> Representable 
    def process_jsonapi(params)
      document = Jsonapi::Document.new(params)
      # we update the object
      if document.data.resource.is_a?(Jsonapi::Document::Resource)
        article_hash = document.data.resource.attributes.to_hash.symbolize_keys
        @model.update_attributes(article_hash)
      # we update relationships
      elsif document.data.resource.is_a?(Jsonapi::Document::ResourceIdentifier)
        set_relationships(document.data.resource.relationships)
      end
    end
    
    def set_relationships(params)
      params.each do |relationship|
        if relationship.data.is_a?(Array)
          ids = []
          relationship.data.each do |item|
            ids << item.id
          end
          set_relationship("#{relationship.type.singularize}_ids", ids)
        else
          set_relationship("#{relationship.type}_id", relationship.data.id)
        end
      end
      @model.save!
    end
    
    def set_relationship(relationship_name, item)
      @model.send("#{relationship_name}=", item)
    end
    
    def to_hash(*)
      resource = create_resource(@model)
      # TODO: generate link on representer
      document = Jsonapi::Document.new(data: resource)
      document.to_hash
    end
    
    def create_resource(object)
      # TODO: type comes from representer
      resource_hash = {
        id: object.id,
        type: 'articles',
        # TODO: discover which attributes, we have on representer
        attributes: {
          title: object.title,
          text: object.text
        },
        links: { self: "http://example.com/articles/#{object.id}" }
      }

      resource_hash.merge!(set_relationships_hash)
      resource_hash
    end
    
    def set_relationships_hash
      rel_hash = {}
      rel_hash.merge!(has_one_relationship_hash("author", @model.author))
      rel_hash.merge!(has_many_relationship_hash("tags", @model.tags))
      return {} if rel_hash.empty?
      {relationships: rel_hash}
    end
    
    def has_one_relationship_hash(type, relationship)
      return {} if relationship.nil?
      {
        "#{type}": {
          "data": {
            "type": "people",
            "id": relationship.id.to_s
          }
        }
      }
    end
    
    def has_many_relationship_hash(type, relationship)
      return {} if relationship.empty?
      data_array = []
      relationship.each do |item|
        data_array << {type: "tags", id: item.id.to_s}
      end
      {
        "#{type}": {
          "data": data_array
        }
      }
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
      document = Jsonapi::Document.new(links: {self: "http://example.com/articles/#{@model.id}"}, data: resource)
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

    class Create < Relationships
      def model!(params)
        @model = Article.find(params[:article_id])
        if params["data"].is_a?(Array)
          create_multiple_relationship(@model, params)
        else
          create_one_relationship(@model, params, params["data"]["id"])
        end
        @model.save!
        @model
      end

      def create_multiple_relationship(object, params)
        params["data"].each do |item|
          create_one_relationship(object, params, item["id"])
        end
      end

      def create_one_relationship(object, params, id)
        ids = object.send("#{params[:relationship].to_s.singularize}_ids")
        ids << id
        object.send("#{params[:relationship].to_s.singularize}_ids=", ids)
      end
    end

    class Update < Relationships
      def model!(params)
        @model = Article.find(params[:article_id])
        if params["data"].nil? or params["data"].empty?
          remove_relationship(@model, params)
        elsif params["data"].is_a?(Array)
          update_has_many_relationship(@model, params)
        else
          update_has_one_relationship(@model, params)
        end
        @model.save!
        @model
      end
      
      def remove_relationship(object, params)
        relationship = params[:relationship].to_s
        object.send("#{relationship.singularize}_ids=", nil) if object.respond_to?("#{relationship.singularize}_ids=")
        object.send("#{relationship}_id=", nil) if object.respond_to?("#{relationship.singularize}_id=")
      end

      def update_has_many_relationship(object, params)
        ids = []
        params["data"].each do |item|
          ids << item["id"]
        end
        object.send("#{params[:relationship].to_s.singularize}_ids=", ids)
      end

      def update_has_one_relationship(object, params)
        if params["data"].nil?
          object.send("#{params[:relationship]}_id=", nil)
        else
          object.send("#{params[:relationship]}_id=", params["data"]["id"])
        end
      end
    end
    
    class Delete < Relationships
      def model!(params)
        @model = Article.find(params[:article_id])
        if params["data"].is_a?(Array)
          delete_multiple_relationship(@model, params)
        else
          delete_one_relationship(@model, params, params["data"]["id"])
        end
        @model.save!
        @model
      end

      def delete_multiple_relationship(object, params)
        params["data"].each do |item|
          delete_one_relationship(object, params, item["id"])
        end
      end

      def delete_one_relationship(object, params, id)
        ids = object.send("#{params[:relationship].to_s.singularize}_ids")
        ids.delete(id.to_i)
        object.send("#{params[:relationship].to_s.singularize}_ids=", ids)
      end
    end
  end
end
