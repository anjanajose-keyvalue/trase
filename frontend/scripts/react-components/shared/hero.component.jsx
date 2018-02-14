import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import TwitterFeed from 'react-components/home/twitter-feed.component';
import AnimatedFlows from 'react-components/animated-flows/animated-flows.component';
import HomeVideo from 'react-components/home/home-video.component';

// old school name: https://en.wikipedia.org/wiki/Hero_image
class Hero extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      showStory: true
    };

    this.videoEventHandlers = {
      exitfullscreen: this.onExitFullScreen,
      ended: this.onEnded
    };

    this.onClickPlay = this.onClickPlay.bind(this);
    this.getVideoRef = this.getVideoRef.bind(this);
    this.closeStoryBox = this.closeStoryBox.bind(this);
  }

  onExitFullScreen(plyr) {
    plyr.pause();
  }

  onEnded(plyr) {
    plyr.toggleFullscreen();
    plyr.restart();
  }

  onClickPlay() {
    const { plyr } = this.video;
    if (plyr.isFullscreen() === false) {
      plyr.play();
      plyr.toggleFullscreen();
    }
  }

  getVideoRef(ref) {
    this.video = ref;
  }

  closeStoryBox() {
    this.setState({ showStory: false });
  }

  render() {
    const { showStory } = this.state;
    const { className, visitStory, story, tweets } = this.props;
    const StoryBox = storyObj => (
      <div className="story-box">
        <button className="story-box-close" onClick={this.closeStoryBox} />
        <figure
          className="story-box-image"
          style={{ backgroundImage: `url(${storyObj.imageUrl})` }}
        />
        <figcaption className="story-box-content">
          <p className="story-box-title">{storyObj.title}</p>
          <button className="subtitle story-box-link" onClick={() => visitStory(storyObj)}>
            See It Here
          </button>
        </figcaption>
      </div>
    );

    return (
      <div className={cx('c-hero', className)}>
        <div className="hero-content row align-middle">
          <div className="column small-12">
            <div className="hero-logo-container">
              <img src="/images/logos/new-logo-trase.svg" alt="TRASE" />
            </div>
            <h1 className="hero-title">Transparent supply chains for sustainable economies</h1>
            <div className="hero-play-container">
              <HomeVideo
                ref={this.getVideoRef}
                videoId={HOME_VIDEO_ID}
                events={this.videoEventHandlers}
              />
              <button className="hero-play-button" onClick={this.onClickPlay} />
              TRASE in 2’
            </div>
          </div>
          {showStory &&
            story && (
              <div className="layover">
                <StoryBox {...story} />
              </div>
            )}
          {(!showStory || !story) &&
            tweets && (
              <div className="layover">
                <TwitterFeed tweets={tweets} />
              </div>
            )}
        </div>
        <AnimatedFlows />
      </div>
    );
  }
}

Hero.propTypes = {
  className: PropTypes.string,
  visitStory: PropTypes.func,
  story: PropTypes.object,
  tweets: PropTypes.array,
  onClickPlay: PropTypes.func
};

Hero.defaultProps = {
  visitStory: () => {}
};

export default Hero;
