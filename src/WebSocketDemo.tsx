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
  const [roomId, setRoomId] = useState('aaa');
  const [message, setMessage] = useState('Hello');
  const [user, setUser] = useState('Bob');
  
  const { perform, subscribe, unsubscribe, lastMessage, readyState } = useLiteRouter(socketUrl);

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

  const handleClickSendMessage = useCallback(() => {
    perform(`rooms/${roomId}`, { message, user });
  }, [perform, message, user, roomId]);

  const handleSubscribe = useCallback(() => {
    if (roomId) subscribe(`rooms/${roomId}`, { action: 'subscribe' });
  }, [perform, roomId]);

  const handleUnsubscribe = useCallback(() => {
    if (roomId) unsubscribe(`rooms/${roomId}`, { action: 'unsubscribe' });
  }, [perform, roomId]);

  return (
    <div>
      <p>Socket URL: {socketUrl}</p>
      <p>
        <input 
          type="text" 
          placeholder="Room ID" 
          value={roomId} 
          onChange={(e) => setRoomId(e.target.value)} 
        />
        <button onClick={handleSubscribe}>Subscribe</button>
        <button onClick={handleUnsubscribe}>Unsubscribe</button>
      </p>
      <p>
        <input
            type="text"
            placeholder="User"
            value={user}
            onChange={(e) => setUser(e.target.value)}
        />
        <input
            type="text"
            placeholder="Message"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
        />
        <button onClick={handleClickSendMessage}>
          Send Message
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
