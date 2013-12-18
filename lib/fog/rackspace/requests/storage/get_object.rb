module Fog
  module Storage
    class Rackspace

      class Real

        # Get details for object
        #
        # ==== Parameters
        # * container<~String> - Name of container to look in
        # * object<~String> - Name of object to look for
        # @raise [Fog::Storage::Rackspace::NotFound] - HTTP 404
        # @raise [Fog::Storage::Rackspace::BadRequest] - HTTP 400
        # @raise [Fog::Storage::Rackspace::InternalServerError] - HTTP 500
        # @raise [Fog::Storage::Rackspace::ServiceError]
        def get_object(container, object, &block)
          params = {
            :expects  => 200,
            :method   => 'GET',
            :path     => "#{Fog::Rackspace.escape(container)}/#{Fog::Rackspace.escape(object)}"
          }

          if block_given?
            params[:response_block] = block
          end

          request(params, false)
        end

      end

      class Mock
        def get_object(container, object, &block)
          escaped_container = Fog::Rackspace.escape(container)
          escaped_object = Fog::Rackspace.escape(object)

          c = self.data[escaped_container]
          raise Fog::Storage::Rackspace::NotFound.new if c.nil?

          o = c.objects[escaped_object]
          raise Fog::Storage::Rackspace::NotFound.new if o.nil?

          if block_given?
            # Just send it all in one chunk.
            block.call(o.body, 0, o.bytes)
          end

          # TODO set headers
          response = Excon::Response.new
          response.body = o.body
          response
        end
      end

    end
  end
end
