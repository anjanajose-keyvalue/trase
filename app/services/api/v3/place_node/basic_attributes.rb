module Api
  module V3
    module PlaceNode
      class BasicAttributes
        attr_reader :column_name, :country_name, :country_geo_id,
                    :municipality_name, :municipality_geo_id,
                    :logistics_hub_name, :logistics_hub_geo_id,
                    :state_name, :state_geo_id,
                    :biome_name, :biome_geo_id,
                    :area, :soy_production, :soy_farmland

        def initialize(context, year, node)
          @context = context
          @year = year
          @node = node
          @place_quals = Dictionary::PlaceQuals.new(@node, @year)
          @place_quants = Dictionary::PlaceQuants.new(@node, @year)
          @place_inds = Dictionary::PlaceInds.new(@node, @year)
          @volume_attribute = Dictionary::Quant.instance.get('Volume')
          @soy_production_attribute = Dictionary::Quant.instance.get('SOY_TN')

          @node_type_name = @node&.node_type&.name
          @column_name = @node_type_name
          @country_name = @context&.country&.name
          @country_geo_id = @context&.country&.iso2

          if municipality? || logistics_hub?
            initialize_municipality_and_logistics_hub_attributes
          end
          initialize_dynamic_attributes
          initialize_top_nodes
        end

        NodeType::PLACES.each do |place_name|
          define_method("#{place_name.split.join('_').downcase}?") do
            @node_type_name == place_name
          end
        end

        def soy_area
          @soy_area_formatted
        end

        def summary
          return nil unless municipality? || logistics_hub?

          result = "In #{@year}, #{@node.name.titleize} produced \
#{@soy_production_formatted} #{@soy_production_unit} of soy occupying a total \
of #{@soy_area_formatted} #{@soy_area_unit} of land."
          result << summary_of_production_ranking
          result << summary_of_top_exporter_and_top_consumer
          result
        end

        private

        def initialize_dynamic_attributes
          @dynamic_attributes = {}
          @dynamic_attributes[
            (@node_type_name.split.join('_').downcase + '_name').to_sym
          ] = @node.name
          @dynamic_attributes[
            (@node_type_name.split.join('_').downcase + '_geo_id').to_sym
          ] = @node.geo_id
          @dynamic_attributes.each do |name, value|
            instance_variable_set("@#{name}", value)
          end
        end

        def initialize_municipality_and_logistics_hub_attributes
          biome_qual = @place_quals.get(NodeTypeName::BIOME)
          @biome_name = biome_qual && biome_qual['value']
          @biome = Api::V3::Node.biomes.find_by_name(biome_name)
          @biome_geo_id = @biome&.geo_id
          state_qual = @place_quals.get(NodeTypeName::STATE)
          @state_name = state_qual && state_qual['value']
          @state = Api::V3::Node.states.find_by_name(state_name)
          @state_geo_id = @state&.geo_id
          initialize_soy_attributes
        end

        def initialize_soy_attributes
          area_quant = @place_quants.get('AREA_KM2')
          @area = area_quant['value'] if area_quant
          soy_production_quant = @place_quants.get('SOY_TN')
          if soy_production_quant
            @soy_production = soy_production_quant['value']
            @soy_production_formatted = helper.number_with_precision(
              @soy_production, delimiter: ',', precision: 0
            )
            @soy_production_unit = soy_production_quant['unit']
          end
          soy_yield_ind = @place_inds.get('SOY_YIELD')
          @soy_yield = soy_yield_ind['value'] if soy_yield_ind
          if @soy_production && @soy_yield
            @soy_area_formatted = helper.number_with_precision(
              @soy_production / @soy_yield,
              delimiter: ',', precision: 0
            )
            @soy_area_unit = 'Ha' # soy prod in Tn, soy yield in Tn/Ha
          end
          soy_farmland_ind = @place_inds.get('SOY_AREAPERC')
          @soy_farmland = soy_farmland_ind['value'] if soy_farmland_ind
        end

        def initialize_top_nodes
          exporter_top_nodes = Api::V3::PlaceNode::TopNodesList.new(
            @context, @year, @node,
            other_node_type_name: NodeTypeName::EXPORTER,
            place_inds: @place_inds,
            place_quants: @place_quants
          )
          consumer_top_nodes = Api::V3::PlaceNode::TopNodesList.new(
            @context, @year, @node,
            other_node_type_name: NodeTypeName::COUNTRY,
            place_inds: @place_inds,
            place_quants: @place_quants
          )
          @top_exporters = exporter_top_nodes.sorted_list(
            @volume_attribute, false, 10
          )
          @total_exports = exporter_top_nodes.total(@volume_attribute, false)
          @top_consumers = consumer_top_nodes.sorted_list(
            @volume_attribute, true, 10
          )
        end

        def summary_of_production_ranking
          total_soy_production = Api::V3::NodeQuant.
            where(quant_id: @soy_production_attribute.id, year: @year).
            sum(:value)

          percentage_total_production =
            if @soy_production
              helper.number_to_percentage(
                (@soy_production / total_soy_production) * 100,
                delimiter: ',', precision: 2
              )
            end
          country_ranking = CountryRanking.new(@context, @year, @node).
            position_for_attribute(@soy_production_attribute)
          if country_ranking.present?
            country_ranking = country_ranking.ordinalize
          end
          if @state.present?
            state_ranking = StateRanking.new(@context, @year, @node, @state.name).
              position_for_attribute(@soy_production_attribute)
          end
          state_ranking = state_ranking.ordinalize if state_ranking.present?
          state_name = @state.name.titleize if @state.present?

          " With #{percentage_total_production} of the total production, it \
ranks #{country_ranking} in Brazil in soy production, and #{state_ranking} in \
the state of #{state_name}."
        end

        def summary_of_top_exporter_and_top_consumer
          top_exporter = @top_exporters.first
          if top_exporter.present?
            top_exporter_name = top_exporter['name']&.titleize
            if @total_exports.present?
              percentage_total_exports = helper.number_to_percentage(
                ((top_exporter[:value] || 0) / @total_exports) * 100,
                delimiter: ',', precision: 1
              )
            end
          end

          top_consumer = @top_consumers.first
          top_consumer_name = top_consumer['name']&.titleize if top_consumer

          if top_exporter && percentage_total_exports && top_consumer
            " The largest exporter of soy in #{@node.name.titleize} \
was #{top_exporter_name}, which accounted for #{percentage_total_exports} of \
the total exports, and the main destination was #{top_consumer_name}."
          else
            ''
          end
        end

        def helper
          @helper ||= Class.new do
            include ActionView::Helpers::NumberHelper
          end.new
        end
      end
    end
  end
end