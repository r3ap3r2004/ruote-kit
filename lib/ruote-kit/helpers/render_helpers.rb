# Helpers for rendering stuff

module RuoteKit
  module Helpers
    module RenderHelpers

      def json( resource, object )
        if respond_to?( "json_#{resource}" )
          object = send( "json_#{resource}", object )
        end

        {
          "links" => links( resource ),
          resource => object
        }.to_json
      end

      def json_processes( processes )
        processes.collect do |process|
          links = {
            'self' => link( "/processes/#{process.wfid}", rel('#process') ),
            'expressions' => link( "/expressions/#{process.wfid}", rel('#expressions') ),
            'workitems' => link( "/workitems/#{process.wfid}", rel('#workitems') )
          }

          process.to_h.merge( 'links' => links )
        end
      end

      def rel( fragment )
        "http://ruote.rubyforge.org/rels.html#{ fragment }"
      end

      def links( resource )
        links = [
          link( '/', rel('#root') ),
          link( '/processes', rel('#processes') ),
          link( '/workitems', rel('#workitems') ),
          link( '/history', rel("#history") ),
          link( request.fullpath, 'self' )
        ]

        links << link("/history/#{params[:wfid]}", rel('#process_history') ) if resource == :process

        links
      end

      def link( href, rel )
        { 'href' => href, 'rel' => rel }
      end

      # Easy 404
      def resource_not_found
        status 404
        respond_to do |format|
          format.html { haml :resource_not_found }
          format.json { { "error" => { "code" => "404", "message" => "Resource not found" } }.to_json }
        end
      end

      # Extract the process tree
      def process_tree( object )
        case object
        when Ruote::Workitem
          process = engine.process( object.fei.wfid )
          process.current_tree.to_json
        when Ruote::ProcessStatus
          object.current_tree.to_json
        end
      end

    end
  end
end