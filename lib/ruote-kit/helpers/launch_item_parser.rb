class RuoteKit::Application

  helpers do

    # Extract the launch item parameters from a posted form or a JSON request body
    def launch_item_from_post
      case env["CONTENT_TYPE"]

      when "application/json" then
        data = JSON.parse( env["rack.input"].read )
        launch_item = Ruote::Launchitem.new( data["uri"] || data["definition"] )
        launch_item.fields = data["fields"]
        return launch_item

      when "application/x-www-form-urlencoded"
        pdef = params[:process_uri].nil? || params[:process_uri].empty? ? params[:process_definition] : params[:process_uri]
        launch_item = Ruote::Launchitem.new( pdef )
        fields = params[:process_fields] || ""
        fields = "{}" if fields.empty?
        launch_item.fields = JSON.parse( fields )
        return launch_item

      else
        raise "#{env['CONTENT_TYPE']} not supported as a launch mechanism yet"
      end
    end

  end

end