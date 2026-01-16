import { useEffect, useCallback } from 'react';
import useWebSocket, { ReadyState } from 'react-use-websocket';

export const useRouter = (url: string) => {
  const { sendMessage: sendToWebSocket, lastMessage, readyState } = useWebSocket(url);

  useEffect(() => {
    if (readyState === ReadyState.OPEN) {
      // sendToWebSocket(JSON.stringify({
      //   command: "subscribe",
      //   identifier: `{"channel":"lite_router","id":"${LITE_ROUTER_ID}"}`
      // }));
    }
  }, [readyState, sendToWebSocket]);

  function sendMessage(action: string, path: string, input: any = {}) {
    sendToWebSocket(JSON.stringify(
      {"action":action, "data":{path: path, input: input}}
    ));
    return
    if (readyState === ReadyState.OPEN) {
      sendToWebSocket(JSON.stringify({
        action: action,
        data: {
          path: path,
          input: input,
        }
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