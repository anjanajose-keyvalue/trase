shared_context 'brazil soy nodes' do
  include_context 'node types'
  include_context 'quals'
  include_context 'brazil context nodes'

  let!(:state_node){
    FactoryGirl.create(:node, name: 'MATO GROSSO', node_type: state_node_type, geo_id: 'BR51')
  }
  let!(:biome_node){
    FactoryGirl.create(:node, name: 'AMAZONIA', node_type: biome_node_type, geo_id: 'BR1')
  }
  let!(:logistics_hub_node){
    FactoryGirl.create(:node, name: 'CUIABA', node_type: logistics_hub_node_type)
  }
  let!(:municipality_node){
    FactoryGirl.create(:node, name: 'NOVA UBIRATA', node_type: municipality_node_type, geo_id: 'BR5106240')
  }
  let!(:exporter1_node){
    FactoryGirl.create(:node, name: 'AFG BRASIL', node_type: exporter_node_type)
  }
  let!(:port1_node){
    FactoryGirl.create(:node, name: 'IMBITUBA', node_type: port_node_type)
  }
  let!(:importer1_node){
    FactoryGirl.create(:node, name: 'UNKNOWN CUSTOMER', node_type: importer_node_type)
  }
  let!(:country_of_destination1_node){
    FactoryGirl.create(:node, name: 'RUSSIAN FEDERATION', node_type: country_node_type, geo_id: 'CN')
  }
end