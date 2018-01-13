import { loadContextNodes } from 'actions/data.actions';
import { trackDataDownloadFormLoaded, trackDownload } from 'analytics/analytics.actions';
import { connect } from 'react-redux';
import DataPortalPage from 'react-components/data/data-portal-page.component';

const mapStateToProps = state => ({
  contexts: state.data.contexts,
  exporters: state.data.exporters,
  consumptionCountries: state.data.consumptionCountries,
  indicators: state.data.indicators
});

const mapDispatchToProps = dispatch => ({
  onContextSelected: (contextId) => {
    dispatch(loadContextNodes(contextId));
  },
  onDownloadTriggered: (params) => {
    dispatch(trackDownload(params));
  },
  onDataDownloadFormLoaded: () => {
    dispatch(trackDataDownloadFormLoaded());
  }
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(DataPortalPage);
