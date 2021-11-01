import React from 'react';
import { Header } from './components/Header';
import { Container } from '@material-ui/core';
import { DAppProvider, ChainId } from '@usedapp/core';
import { Main } from './components/Main';

function App() {
  return (
    <DAppProvider config={{
      supportedChains: [ChainId.Kovan],
      notifications: {
        expirationPeriod: 1000, // 1 second
        checkInterval: 1000 // 1 second
      }
    }}>

      <Header />
      <Container maxWidth="md">
        <Main />
      </Container>
    </DAppProvider >
  );
}

export default App;
