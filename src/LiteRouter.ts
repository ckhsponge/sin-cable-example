import { useEffect, useCallback } from 'react';
import useWebSocket, { ReadyState } from 'react-use-websocket';

const LITE_ROUTER_ID = Math.random().toString(36).substring(2, 18);

export const useLiteRouter = (url: string) => {
  const { sendMessage: sendToWebSocket, lastMessage, readyState } = useWebSocket(url);

  useEffect(() => {
    if (readyState === ReadyState.OPEN) {
      sendToWebSocket(JSON.stringify({
        command: "subscribe",
        identifier: `{"channel":"lite_router","id":"${LITE_ROUTER_ID}"}`
      }));
    }
  }, [readyState, sendToWebSocket]);

  function sendMessage(action: string, path: string, input: any = {}) {
    if (readyState === ReadyState.OPEN) {
      sendToWebSocket(JSON.stringify({
        command: "message",
        data: JSON.stringify({
          action: action,
          path: path,
          input: input,
          connection_id: LITE_ROUTER_ID
        }),
        identifier: `{"channel":"lite_router","id":"${LITE_ROUTER_ID}"}`
      }));
    }
  }

  const perform = useCallback((path: string, input: any) => {
    sendMessage("perform", path, input);
  }, [sendMessage, readyState]);

  const subscribe = useCallback((path: string) => {
    sendMessage("subscribe", path);
  }, [sendMessage, readyState]);

  const unsubscribe = useCallback((path: string) => {
    sendMessage("unsubscribe", path);
  }, [sendMessage, readyState]);

  return {
    perform,
    subscribe,
    unsubscribe,
    lastMessage,
    readyState
  };
};