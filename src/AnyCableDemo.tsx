import React, { useState, useEffect } from 'react';
import { createCable } from '@anycable/web';

export const AnyCableDemo = () => {
  const [messageHistory, setMessageHistory] = useState<string[]>([]);
  const [subscription, setSubscription] = useState<any>(null);
  const [cable, setCable] = useState<any>(null);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const cableInstance = createCable(
        // 'ws://localhost:9292/cable'
    'wss://vmb0rz6ay3.execute-api.us-east-1.amazonaws.com/prod'
    );

    setCable(cableInstance);

    cableInstance.on('connect', () => {
      setIsConnected(true);
      console.log('Connected to AnyCable');
    });

    cableInstance.on('disconnect', () => {
      setIsConnected(false);
      console.log('Disconnected from AnyCable');
    });

    cableInstance.on('info', (info: any) => {
      console.log('Cable info:', info);
    });

    const sub = cableInstance.subscribeTo('chat', { id: 'a' });

    sub.on('message', (msg: any) => {
      setMessageHistory((prev) => [...prev, JSON.stringify(msg)]);
    });

    setSubscription(sub);

    return () => {
      sub.disconnect();
      cableInstance.disconnect();
    };
  }, []);

  const handleSpeak = () => {
    if (subscription) {
      subscription.perform('speak', { message: `Hello ${new Date().toISOString()}` });
    }
  };

  const handlePing = () => {
    if (cable) {
      cable.send({ action: 'ping' });
    }
  };

  return (
    <div>
      <p>Connection Status: {isConnected ? 'Connected' : 'Disconnected'}</p>
      <p>
        <button onClick={handleSpeak} disabled={!isConnected}>
          Send Message
        </button>
        <button onClick={handlePing} >
          Ping
        </button>
      </p>
      <p>Message History:</p>
      <ul>
        {messageHistory.map((message, idx) => (
          <li key={idx}>{message}</li>
        ))}
      </ul>
    </div>
  );
};
