import React, {useState, useCallback, useEffect} from 'react';
import { useLiteRouter } from './LiteRouter';
import { ReadyState } from 'react-use-websocket';

export const WebSocketDemo = () => {
  const [socketUrl, setSocketUrl] = useState(
    // 'wss://echo.websocket.org'
    'ws://localhost:9292/cable'
    // 'wss://vmb0rz6ay3.execute-api.us-east-1.amazonaws.com/prod'
  );
  const [messageHistory, setMessageHistory] = useState<any[]>([]);
  
  const { speak, lastMessage, readyState } = useLiteRouter(socketUrl);

  useEffect(() => {
    if (lastMessage) {
      try {
        const data = JSON.parse(lastMessage.data);
        setMessageHistory((prev) => [...prev, data]);
      } catch (e) {
        setMessageHistory((prev) => [...prev, lastMessage.data]);
      }
    }
  }, [lastMessage]);

  // const nextUrl = 'wss://demos.kaazing.com/echo';
  // const nextUrl = 'wss://n7jmbnjma9.execute-api.us-east-1.amazonaws.com/prod';
  const nextUrl = 'ws://localhost:9292/cable';

  const handleClickChangeSocketUrl = useCallback(
    () => setSocketUrl(nextUrl),
    []
  );

  const handleClickSendMessage = useCallback(() => {
    speak('Hello');
  }, [speak]);

  return (
    <div>
      <p>
        <button onClick={handleClickChangeSocketUrl}>
          Click Me to change Socket Url
        </button>
      </p>
      <p>
        <button onClick={handleClickSendMessage}>
          Click Me to send 'Hello'
        </button>
      </p>
      <p>The WebSocket is using LiteRouter - Status: {{
        [ReadyState.CONNECTING]: 'Connecting',
        [ReadyState.OPEN]: 'Open',
        [ReadyState.CLOSING]: 'Closing',
        [ReadyState.CLOSED]: 'Closed',
        [ReadyState.UNINSTANTIATED]: 'Uninstantiated',
      }[readyState]}</p>
      <ul>
        {messageHistory.map((message, idx) => (
          <li key={idx}>{JSON.stringify(message)}</li>
        ))}
      </ul>
    </div>
  );
};
