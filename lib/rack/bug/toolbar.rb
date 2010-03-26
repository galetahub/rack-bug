module Rack
  class Bug    
    class Toolbar
      include Render
      
      MIME_TYPES = ["text/html", "application/xhtml+xml"]
      
      def initialize(app)
        @app = app
      end
      
      def call(env)
        @env = env
        @env["rack-bug.panels"] = []
        
        Rack::Bug.enable
        status, headers, body = builder.call(@env)
        Rack::Bug.disable
        
        @response = Rack::Response.new(body, status, headers)
        
        inject_toolbar if valid_type_to_modify?
        
        return @response.to_a
      end

      def valid_type_to_modify?
        @response.ok? &&
        @env["HTTP_X_REQUESTED_WITH"] != "XMLHttpRequest" &&
        MIME_TYPES.include?(@response.content_type.split(";").first)
      end
      
      def builder
        builder = Rack::Builder.new
        
        @env["rack-bug.panel_classes"].each do |panel_class|
          builder.use panel_class
        end
        
        builder.run @app
        
        return builder
      end
      
      def inject_toolbar
        full_body = @response.body.join
        full_body.sub! /<\/body>/, render + "</body>"
        
        @response["Content-Length"] = full_body.size.to_s
        @response.body = [full_body]
      end
      
      def render
        render_template("toolbar", :panels => @env["rack-bug.panels"].reverse)
      end
      
    end
    
  end
end