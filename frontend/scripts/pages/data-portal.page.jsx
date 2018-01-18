/* eslint-disable no-new */
import DataMarkup from 'html/data-portal.ejs';
import NavMarkup from 'html/includes/_nav.ejs';
import FeedbackMarkup from 'html/includes/_feedback.ejs';

import 'styles/data.scss';
import 'styles/components/shared/veil.scss';
import 'styles/components/shared/modal.scss';

import { render, unmountComponentAtNode } from 'react-dom';
import React from 'react';
import { Provider } from 'react-redux';
import Footer from 'react-components/shared/footer.component';

import NavContainer from 'containers/shared/nav.container';
import DataPortalPage from 'react-components/data-portal/data-portal-page.container';

export const mount = (root, store) => {
  root.innerHTML = DataMarkup({
    nav: NavMarkup({ page: 'data' }),
    feedback: FeedbackMarkup()
  });

  render(
    <Provider store={store}>
      <DataPortalPage />
    </Provider>,
    document.querySelector('.c-container')
  );

  render(
    <Provider store={store}>
      <Footer />
    </Provider>,
    document.getElementById('footer')
  );

  new NavContainer(store);
};

export const unmount = () => {
  unmountComponentAtNode(document.querySelector('.c-container'));
  unmountComponentAtNode(document.getElementById('footer'));
};
