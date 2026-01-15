import { useEffect, useCallback } from 'react';
import useWebSocket, { ReadyState } from 'react-use-websocket';

export const useLiteRouter = (url: string) => {
  const { sendMessage, lastMessage, readyState } = useWebSocket(url);

  useEffect(() => {
    if (readyState === ReadyState.OPEN) {
      sendMessage(JSON.stringify({
        command: "subscribe",
        identifier: '{"channel":"lite_router","id":"default"}'
      }));
    }
  }, [readyState, sendMessage]);

  const speak = useCallback((message: string) => {
    if (readyState === ReadyState.OPEN) {
      sendMessage(JSON.stringify({
        command: "message",
        data: JSON.stringify({
          action: "speak",
          message: message
        }),
        identifier: '{"channel":"lite_router","id":"default"}'
      }));
    }
  }, [sendMessage, readyState]);

  return {
    speak,
    lastMessage,
    readyState
  };
};