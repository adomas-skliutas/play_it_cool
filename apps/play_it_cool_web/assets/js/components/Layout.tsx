import React from 'react';
import { makeStyles } from '@material-ui/styles';
import clsx from 'clsx';
import { useLocation, Link } from 'react-router-dom';
import { ITheme } from '../shared/theme';
import IconAnimation from './IconAnimation';
import Helper from './Helper';

const useStyle = makeStyles((theme: ITheme) => ({
  container: {
    width: `calc(100% - ${theme.sizes.contentBackgroundSpacing * 2})`,
    minHeight: '100vh',
    backgroundColor: theme.palette.secondary,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    padding: `0 ${theme.sizes.contentBackgroundSpacing}px`,
    position: 'relative',
    zIndex: 1,
  },
  childrenWrapper: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    padding: theme.sizes.contentBackgroundSpacing,
    height: '100%',
    width: '100%',
  },
  childrenContainer: {
    maxWidth: 1096,
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    minHeight: `calc(100vh - (${theme.sizes.footerHeight}px + ${
      theme.sizes.contentBackgroundSpacing * 4
    }px))`,
    borderRadius: 4,
    padding: theme.sizes.contentBackgroundSpacing,
    position: 'relative',
    zIndex: 5,
  },
  introBackground: {
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',
  },
  gameBackground: {
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',
  },
  logo: {
    width: '100%',
  },
}));

interface ILayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<ILayoutProps> = ({ children }) => {
  const classes = useStyle();
  const location = useLocation();

  const isIntroScreen = ['/lobby', '/'].includes(location.pathname);

  const containerClassName = clsx({
    [classes.container]: true,
    [classes.introBackground]: isIntroScreen,
    [classes.gameBackground]: !isIntroScreen,
  });

  return (
    <div style={{ position: 'relative' }}>
      <div className={containerClassName}>
        <IconAnimation />
        <div className={classes.childrenContainer}>
          <Link to="/">
            <img src="/images/logo.svg" className={classes.logo} />
          </Link>
          <div className={classes.childrenWrapper}>{children}</div>
        </div>
      </div>
      <Helper />
    </div>
  );
};

export default Layout;
