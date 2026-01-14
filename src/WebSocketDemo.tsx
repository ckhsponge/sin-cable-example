import React, {useState, useCallback, useEffect} from 'react';
import useWebSocket, {ReadyState} from 'react-use-websocket';

export const WebSocketDemo = () => {
  const [socketUrl, setSocketUrl] = useState(
    // 'wss://echo.websocket.org'
    // 'ws://localhost:9292/cable'
    'wss://vmb0rz6ay3.execute-api.us-east-1.amazonaws.com/prod'
  );
  const [messageHistory, setMessageHistory] = useState<MessageEvent<any>[]>([]);

  const {sendMessage, lastMessage, readyState} = useWebSocket(socketUrl);

  useEffect(() => {
    if (lastMessage !== null) {
      setMessageHistory((prev) => prev.concat(lastMessage));
    }
  }, [lastMessage]);

  // const nextUrl = 'wss://demos.kaazing.com/echo';
  // const nextUrl = 'wss://n7jmbnjma9.execute-api.us-east-1.amazonaws.com/prod';
  const nextUrl = 'ws://localhost:9292/cable';


  const handleClickChangeSocketUrl = useCallback(
    () => setSocketUrl(nextUrl),
    []
  );

  const handleClickSendMessage = useCallback(() => sendMessage('Hello'), [sendMessage]);

  const handleClickSubscribe = useCallback(
    () => sendMessage(
      JSON.stringify(
        // {"action":"sendmessage", "data":`hello world ${new Date().toISOString()}`}
        {
          "command": "subscribe",
          "data": JSON.stringify({
            "action": "speak",
            "user": "ckh",
            "message": "bye",
            "sid": "1768344014639"
          }),
          "identifier": '{"channel":"chat","id":"a"}'
        }
      )
    ), [sendMessage]
  );

  const handleClickSendJson = useCallback(
    () => sendMessage(
      JSON.stringify(
        {"action":"sendmessage", "data":`hello world ${new Date().toISOString()}`}
        // {
        //   "command": "message",
        //   "data": JSON.stringify({
        //     "action": "speak",
        //     "user": "ckh",
        //     "message": "bye",
        //     "sid": "1768344014639"
        //   }),
        //   "identifier": '{"channel":"chat","id":"a"}'
        // }
      )
    ), [sendMessage]
  );

  const connectionStatus = {
    [ReadyState.CONNECTING]: 'Connecting',
    [ReadyState.OPEN]: 'Open',
    [ReadyState.CLOSING]: 'Closing',
    [ReadyState.CLOSED]: 'Closed',
    [ReadyState.UNINSTANTIATED]: 'Uninstantiated',
  }[readyState];

  return (
    <div>
      <p>
        <button onClick={handleClickChangeSocketUrl}>
          Click Me to change Socket Url
        </button>
      </p>
      <p>
        <button
          onClick={handleClickSendMessage}
          disabled={readyState !== ReadyState.OPEN}
        >
          Click Me to send 'Hello'
        </button>
      </p>
      <p>
        <button
          onClick={handleClickSubscribe}
          disabled={readyState !== ReadyState.OPEN}
        >
          Subscribe
        </button>
      </p>
      <p>
        <button
          onClick={handleClickSendJson}
          disabled={readyState !== ReadyState.OPEN}
        >
          Send JSON Message
        </button>
      </p>
      <p>The WebSocket is currently {connectionStatus}</p>
      {lastMessage ? <p>Last message: {lastMessage.data}</p> : null}
      <ul>
        {messageHistory.map((message, idx) => (
          <>
            <span key={idx}>{message ? message.data : null}</span><br/>
          </>
        ))}
      </ul>
    </div>
  );
};
