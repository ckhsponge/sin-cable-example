import React, {useState, useCallback, useEffect} from 'react';
import { useLiteRouter } from './LiteRouter';
import { ReadyState } from 'react-use-websocket';
import {useRouter} from "./Router";

export const WebSocketDemo = () => {
  const localUrl = 'ws://localhost:9292/cable';
  const apiGatewayUrl = 'wss://d36x6e07hge8hx.cloudfront.net/prod';
      // 'wss://vmb0rz6ay3.execute-api.us-east-1.amazonaws.com/prod';

  const [messageHistory, setMessageHistory] = useState<any[]>([]);
  const [roomId, setRoomId] = useState('aaa');
  const [message, setMessage] = useState('Hello');
  const [user, setUser] = useState('Bob');
  const [useLite, setUseLite] = useState(false);

  const liteRouter = useLiteRouter(localUrl);
  const router = useRouter(apiGatewayUrl);
  
  const { perform, subscribe, unsubscribe, lastMessage, readyState } = useLite ? liteRouter : router;
  const socketUrl = useLite ? localUrl : apiGatewayUrl;

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
      <p>
        <label>
          <input 
            type="checkbox" 
            checked={useLite} 
            onChange={(e) => setUseLite(e.target.checked)} 
          />
          Use LiteRouter
        </label>
      </p>
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
      <p>The WebSocket is using {useLite ? 'LiteRouter' : 'Router'} - Status: {{
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
