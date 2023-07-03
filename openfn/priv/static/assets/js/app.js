import {
  createStore,
  require_client
} from "../chunk-WCGBZ45P.js";
import {
  __commonJS,
  __toESM,
  require_react
} from "../chunk-PV4GFR55.js";

// vendor/topbar.js
var require_topbar = __commonJS({
  "vendor/topbar.js"(exports, module) {
    "use strict";
    (function(window2, document2) {
      "use strict";
      (function() {
        var lastTime = 0;
        var vendors = ["ms", "moz", "webkit", "o"];
        for (var x = 0; x < vendors.length && !window2.requestAnimationFrame; ++x) {
          window2.requestAnimationFrame = window2[vendors[x] + "RequestAnimationFrame"];
          window2.cancelAnimationFrame = window2[vendors[x] + "CancelAnimationFrame"] || window2[vendors[x] + "CancelRequestAnimationFrame"];
        }
        if (!window2.requestAnimationFrame)
          window2.requestAnimationFrame = function(callback, element) {
            var currTime = (/* @__PURE__ */ new Date()).getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window2.setTimeout(function() {
              callback(currTime + timeToCall);
            }, timeToCall);
            lastTime = currTime + timeToCall;
            return id;
          };
        if (!window2.cancelAnimationFrame)
          window2.cancelAnimationFrame = function(id) {
            clearTimeout(id);
          };
      })();
      var canvas, progressTimerId, fadeTimerId, currentProgress, showing, addEvent = function(elem, type, handler) {
        if (elem.addEventListener)
          elem.addEventListener(type, handler, false);
        else if (elem.attachEvent)
          elem.attachEvent("on" + type, handler);
        else
          elem["on" + type] = handler;
      }, options = {
        autoRun: true,
        barThickness: 3,
        barColors: {
          0: "rgba(26,  188, 156, .9)",
          ".25": "rgba(52,  152, 219, .9)",
          ".50": "rgba(241, 196, 15,  .9)",
          ".75": "rgba(230, 126, 34,  .9)",
          "1.0": "rgba(211, 84,  0,   .9)"
        },
        shadowBlur: 10,
        shadowColor: "rgba(0,   0,   0,   .6)",
        className: null
      }, repaint = function() {
        canvas.width = window2.innerWidth;
        canvas.height = options.barThickness * 5;
        var ctx = canvas.getContext("2d");
        ctx.shadowBlur = options.shadowBlur;
        ctx.shadowColor = options.shadowColor;
        var lineGradient = ctx.createLinearGradient(0, 0, canvas.width, 0);
        for (var stop in options.barColors)
          lineGradient.addColorStop(stop, options.barColors[stop]);
        ctx.lineWidth = options.barThickness;
        ctx.beginPath();
        ctx.moveTo(0, options.barThickness / 2);
        ctx.lineTo(
          Math.ceil(currentProgress * canvas.width),
          options.barThickness / 2
        );
        ctx.strokeStyle = lineGradient;
        ctx.stroke();
      }, createCanvas = function() {
        canvas = document2.createElement("canvas");
        var style = canvas.style;
        style.position = "fixed";
        style.top = style.left = style.right = style.margin = style.padding = 0;
        style.zIndex = 100001;
        style.display = "none";
        if (options.className)
          canvas.classList.add(options.className);
        document2.body.appendChild(canvas);
        addEvent(window2, "resize", repaint);
      }, topbar2 = {
        config: function(opts) {
          for (var key in opts)
            if (options.hasOwnProperty(key))
              options[key] = opts[key];
        },
        show: function() {
          if (showing)
            return;
          showing = true;
          if (fadeTimerId !== null)
            window2.cancelAnimationFrame(fadeTimerId);
          if (!canvas)
            createCanvas();
          canvas.style.opacity = 1;
          canvas.style.display = "block";
          topbar2.progress(0);
          if (options.autoRun) {
            (function loop() {
              progressTimerId = window2.requestAnimationFrame(loop);
              topbar2.progress(
                "+" + 0.05 * Math.pow(1 - Math.sqrt(currentProgress), 2)
              );
            })();
          }
        },
        progress: function(to) {
          if (typeof to === "undefined")
            return currentProgress;
          if (typeof to === "string") {
            to = (to.indexOf("+") >= 0 || to.indexOf("-") >= 0 ? currentProgress : 0) + parseFloat(to);
          }
          currentProgress = to > 1 ? 1 : to;
          repaint();
          return currentProgress;
        },
        hide: function() {
          if (!showing)
            return;
          showing = false;
          if (progressTimerId != null) {
            window2.cancelAnimationFrame(progressTimerId);
            progressTimerId = null;
          }
          (function loop() {
            if (topbar2.progress("+.1") >= 1) {
              canvas.style.opacity -= 0.05;
              if (canvas.style.opacity <= 0.05) {
                canvas.style.display = "none";
                fadeTimerId = null;
                return;
              }
            }
            fadeTimerId = window2.requestAnimationFrame(loop);
          })();
        }
      };
      if (typeof module === "object" && typeof module.exports === "object") {
        module.exports = topbar2;
      } else if (typeof define === "function" && define.amd) {
        define(function() {
          return topbar2;
        });
      } else {
        this.topbar = topbar2;
      }
    }).call(exports, window, document);
  }
});

// ../deps/phoenix_html/priv/static/phoenix_html.js
(function() {
  var PolyfillEvent = eventConstructor();
  function eventConstructor() {
    if (typeof window.CustomEvent === "function")
      return window.CustomEvent;
    function CustomEvent2(event, params) {
      params = params || { bubbles: false, cancelable: false, detail: void 0 };
      var evt = document.createEvent("CustomEvent");
      evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
      return evt;
    }
    CustomEvent2.prototype = window.Event.prototype;
    return CustomEvent2;
  }
  function buildHiddenInput(name, value) {
    var input = document.createElement("input");
    input.type = "hidden";
    input.name = name;
    input.value = value;
    return input;
  }
  function handleClick(element, targetModifierKey) {
    var to = element.getAttribute("data-to"), method = buildHiddenInput("_method", element.getAttribute("data-method")), csrf = buildHiddenInput("_csrf_token", element.getAttribute("data-csrf")), form = document.createElement("form"), submit = document.createElement("input"), target = element.getAttribute("target");
    form.method = element.getAttribute("data-method") === "get" ? "get" : "post";
    form.action = to;
    form.style.display = "none";
    if (target)
      form.target = target;
    else if (targetModifierKey)
      form.target = "_blank";
    form.appendChild(csrf);
    form.appendChild(method);
    document.body.appendChild(form);
    submit.type = "submit";
    form.appendChild(submit);
    submit.click();
  }
  window.addEventListener("click", function(e) {
    var element = e.target;
    if (e.defaultPrevented)
      return;
    while (element && element.getAttribute) {
      var phoenixLinkEvent = new PolyfillEvent("phoenix.link.click", {
        "bubbles": true,
        "cancelable": true
      });
      if (!element.dispatchEvent(phoenixLinkEvent)) {
        e.preventDefault();
        e.stopImmediatePropagation();
        return false;
      }
      if (element.getAttribute("data-method")) {
        handleClick(element, e.metaKey || e.shiftKey);
        e.preventDefault();
        return false;
      } else {
        element = element.parentNode;
      }
    }
  }, false);
  window.addEventListener("phoenix.link.click", function(e) {
    var message = e.target.getAttribute("data-confirm");
    if (message && !window.confirm(message)) {
      e.preventDefault();
    }
  }, false);
})();

// ../deps/phoenix/priv/static/phoenix.mjs
var closure = (value) => {
  if (typeof value === "function") {
    return value;
  } else {
    let closure22 = function() {
      return value;
    };
    return closure22;
  }
};
var globalSelf = typeof self !== "undefined" ? self : null;
var phxWindow = typeof window !== "undefined" ? window : null;
var global = globalSelf || phxWindow || global;
var DEFAULT_VSN = "2.0.0";
var SOCKET_STATES = { connecting: 0, open: 1, closing: 2, closed: 3 };
var DEFAULT_TIMEOUT = 1e4;
var WS_CLOSE_NORMAL = 1e3;
var CHANNEL_STATES = {
  closed: "closed",
  errored: "errored",
  joined: "joined",
  joining: "joining",
  leaving: "leaving"
};
var CHANNEL_EVENTS = {
  close: "phx_close",
  error: "phx_error",
  join: "phx_join",
  reply: "phx_reply",
  leave: "phx_leave"
};
var TRANSPORTS = {
  longpoll: "longpoll",
  websocket: "websocket"
};
var XHR_STATES = {
  complete: 4
};
var Push = class {
  constructor(channel, event, payload, timeout) {
    this.channel = channel;
    this.event = event;
    this.payload = payload || function() {
      return {};
    };
    this.receivedResp = null;
    this.timeout = timeout;
    this.timeoutTimer = null;
    this.recHooks = [];
    this.sent = false;
  }
  resend(timeout) {
    this.timeout = timeout;
    this.reset();
    this.send();
  }
  send() {
    if (this.hasReceived("timeout")) {
      return;
    }
    this.startTimeout();
    this.sent = true;
    this.channel.socket.push({
      topic: this.channel.topic,
      event: this.event,
      payload: this.payload(),
      ref: this.ref,
      join_ref: this.channel.joinRef()
    });
  }
  receive(status, callback) {
    if (this.hasReceived(status)) {
      callback(this.receivedResp.response);
    }
    this.recHooks.push({ status, callback });
    return this;
  }
  reset() {
    this.cancelRefEvent();
    this.ref = null;
    this.refEvent = null;
    this.receivedResp = null;
    this.sent = false;
  }
  matchReceive({ status, response, _ref }) {
    this.recHooks.filter((h) => h.status === status).forEach((h) => h.callback(response));
  }
  cancelRefEvent() {
    if (!this.refEvent) {
      return;
    }
    this.channel.off(this.refEvent);
  }
  cancelTimeout() {
    clearTimeout(this.timeoutTimer);
    this.timeoutTimer = null;
  }
  startTimeout() {
    if (this.timeoutTimer) {
      this.cancelTimeout();
    }
    this.ref = this.channel.socket.makeRef();
    this.refEvent = this.channel.replyEventName(this.ref);
    this.channel.on(this.refEvent, (payload) => {
      this.cancelRefEvent();
      this.cancelTimeout();
      this.receivedResp = payload;
      this.matchReceive(payload);
    });
    this.timeoutTimer = setTimeout(() => {
      this.trigger("timeout", {});
    }, this.timeout);
  }
  hasReceived(status) {
    return this.receivedResp && this.receivedResp.status === status;
  }
  trigger(status, response) {
    this.channel.trigger(this.refEvent, { status, response });
  }
};
var Timer = class {
  constructor(callback, timerCalc) {
    this.callback = callback;
    this.timerCalc = timerCalc;
    this.timer = null;
    this.tries = 0;
  }
  reset() {
    this.tries = 0;
    clearTimeout(this.timer);
  }
  scheduleTimeout() {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      this.tries = this.tries + 1;
      this.callback();
    }, this.timerCalc(this.tries + 1));
  }
};
var Channel = class {
  constructor(topic, params, socket) {
    this.state = CHANNEL_STATES.closed;
    this.topic = topic;
    this.params = closure(params || {});
    this.socket = socket;
    this.bindings = [];
    this.bindingRef = 0;
    this.timeout = this.socket.timeout;
    this.joinedOnce = false;
    this.joinPush = new Push(this, CHANNEL_EVENTS.join, this.params, this.timeout);
    this.pushBuffer = [];
    this.stateChangeRefs = [];
    this.rejoinTimer = new Timer(() => {
      if (this.socket.isConnected()) {
        this.rejoin();
      }
    }, this.socket.rejoinAfterMs);
    this.stateChangeRefs.push(this.socket.onError(() => this.rejoinTimer.reset()));
    this.stateChangeRefs.push(this.socket.onOpen(() => {
      this.rejoinTimer.reset();
      if (this.isErrored()) {
        this.rejoin();
      }
    }));
    this.joinPush.receive("ok", () => {
      this.state = CHANNEL_STATES.joined;
      this.rejoinTimer.reset();
      this.pushBuffer.forEach((pushEvent) => pushEvent.send());
      this.pushBuffer = [];
    });
    this.joinPush.receive("error", () => {
      this.state = CHANNEL_STATES.errored;
      if (this.socket.isConnected()) {
        this.rejoinTimer.scheduleTimeout();
      }
    });
    this.onClose(() => {
      this.rejoinTimer.reset();
      if (this.socket.hasLogger())
        this.socket.log("channel", `close ${this.topic} ${this.joinRef()}`);
      this.state = CHANNEL_STATES.closed;
      this.socket.remove(this);
    });
    this.onError((reason) => {
      if (this.socket.hasLogger())
        this.socket.log("channel", `error ${this.topic}`, reason);
      if (this.isJoining()) {
        this.joinPush.reset();
      }
      this.state = CHANNEL_STATES.errored;
      if (this.socket.isConnected()) {
        this.rejoinTimer.scheduleTimeout();
      }
    });
    this.joinPush.receive("timeout", () => {
      if (this.socket.hasLogger())
        this.socket.log("channel", `timeout ${this.topic} (${this.joinRef()})`, this.joinPush.timeout);
      let leavePush = new Push(this, CHANNEL_EVENTS.leave, closure({}), this.timeout);
      leavePush.send();
      this.state = CHANNEL_STATES.errored;
      this.joinPush.reset();
      if (this.socket.isConnected()) {
        this.rejoinTimer.scheduleTimeout();
      }
    });
    this.on(CHANNEL_EVENTS.reply, (payload, ref) => {
      this.trigger(this.replyEventName(ref), payload);
    });
  }
  join(timeout = this.timeout) {
    if (this.joinedOnce) {
      throw new Error("tried to join multiple times. 'join' can only be called a single time per channel instance");
    } else {
      this.timeout = timeout;
      this.joinedOnce = true;
      this.rejoin();
      return this.joinPush;
    }
  }
  onClose(callback) {
    this.on(CHANNEL_EVENTS.close, callback);
  }
  onError(callback) {
    return this.on(CHANNEL_EVENTS.error, (reason) => callback(reason));
  }
  on(event, callback) {
    let ref = this.bindingRef++;
    this.bindings.push({ event, ref, callback });
    return ref;
  }
  off(event, ref) {
    this.bindings = this.bindings.filter((bind) => {
      return !(bind.event === event && (typeof ref === "undefined" || ref === bind.ref));
    });
  }
  canPush() {
    return this.socket.isConnected() && this.isJoined();
  }
  push(event, payload, timeout = this.timeout) {
    payload = payload || {};
    if (!this.joinedOnce) {
      throw new Error(`tried to push '${event}' to '${this.topic}' before joining. Use channel.join() before pushing events`);
    }
    let pushEvent = new Push(this, event, function() {
      return payload;
    }, timeout);
    if (this.canPush()) {
      pushEvent.send();
    } else {
      pushEvent.startTimeout();
      this.pushBuffer.push(pushEvent);
    }
    return pushEvent;
  }
  leave(timeout = this.timeout) {
    this.rejoinTimer.reset();
    this.joinPush.cancelTimeout();
    this.state = CHANNEL_STATES.leaving;
    let onClose = () => {
      if (this.socket.hasLogger())
        this.socket.log("channel", `leave ${this.topic}`);
      this.trigger(CHANNEL_EVENTS.close, "leave");
    };
    let leavePush = new Push(this, CHANNEL_EVENTS.leave, closure({}), timeout);
    leavePush.receive("ok", () => onClose()).receive("timeout", () => onClose());
    leavePush.send();
    if (!this.canPush()) {
      leavePush.trigger("ok", {});
    }
    return leavePush;
  }
  onMessage(_event, payload, _ref) {
    return payload;
  }
  isMember(topic, event, payload, joinRef) {
    if (this.topic !== topic) {
      return false;
    }
    if (joinRef && joinRef !== this.joinRef()) {
      if (this.socket.hasLogger())
        this.socket.log("channel", "dropping outdated message", { topic, event, payload, joinRef });
      return false;
    } else {
      return true;
    }
  }
  joinRef() {
    return this.joinPush.ref;
  }
  rejoin(timeout = this.timeout) {
    if (this.isLeaving()) {
      return;
    }
    this.socket.leaveOpenTopic(this.topic);
    this.state = CHANNEL_STATES.joining;
    this.joinPush.resend(timeout);
  }
  trigger(event, payload, ref, joinRef) {
    let handledPayload = this.onMessage(event, payload, ref, joinRef);
    if (payload && !handledPayload) {
      throw new Error("channel onMessage callbacks must return the payload, modified or unmodified");
    }
    let eventBindings = this.bindings.filter((bind) => bind.event === event);
    for (let i = 0; i < eventBindings.length; i++) {
      let bind = eventBindings[i];
      bind.callback(handledPayload, ref, joinRef || this.joinRef());
    }
  }
  replyEventName(ref) {
    return `chan_reply_${ref}`;
  }
  isClosed() {
    return this.state === CHANNEL_STATES.closed;
  }
  isErrored() {
    return this.state === CHANNEL_STATES.errored;
  }
  isJoined() {
    return this.state === CHANNEL_STATES.joined;
  }
  isJoining() {
    return this.state === CHANNEL_STATES.joining;
  }
  isLeaving() {
    return this.state === CHANNEL_STATES.leaving;
  }
};
var Ajax = class {
  static request(method, endPoint, accept, body, timeout, ontimeout, callback) {
    if (global.XDomainRequest) {
      let req = new global.XDomainRequest();
      return this.xdomainRequest(req, method, endPoint, body, timeout, ontimeout, callback);
    } else {
      let req = new global.XMLHttpRequest();
      return this.xhrRequest(req, method, endPoint, accept, body, timeout, ontimeout, callback);
    }
  }
  static xdomainRequest(req, method, endPoint, body, timeout, ontimeout, callback) {
    req.timeout = timeout;
    req.open(method, endPoint);
    req.onload = () => {
      let response = this.parseJSON(req.responseText);
      callback && callback(response);
    };
    if (ontimeout) {
      req.ontimeout = ontimeout;
    }
    req.onprogress = () => {
    };
    req.send(body);
    return req;
  }
  static xhrRequest(req, method, endPoint, accept, body, timeout, ontimeout, callback) {
    req.open(method, endPoint, true);
    req.timeout = timeout;
    req.setRequestHeader("Content-Type", accept);
    req.onerror = () => callback && callback(null);
    req.onreadystatechange = () => {
      if (req.readyState === XHR_STATES.complete && callback) {
        let response = this.parseJSON(req.responseText);
        callback(response);
      }
    };
    if (ontimeout) {
      req.ontimeout = ontimeout;
    }
    req.send(body);
    return req;
  }
  static parseJSON(resp) {
    if (!resp || resp === "") {
      return null;
    }
    try {
      return JSON.parse(resp);
    } catch (e) {
      console && console.log("failed to parse JSON response", resp);
      return null;
    }
  }
  static serialize(obj, parentKey) {
    let queryStr = [];
    for (var key in obj) {
      if (!Object.prototype.hasOwnProperty.call(obj, key)) {
        continue;
      }
      let paramKey = parentKey ? `${parentKey}[${key}]` : key;
      let paramVal = obj[key];
      if (typeof paramVal === "object") {
        queryStr.push(this.serialize(paramVal, paramKey));
      } else {
        queryStr.push(encodeURIComponent(paramKey) + "=" + encodeURIComponent(paramVal));
      }
    }
    return queryStr.join("&");
  }
  static appendParams(url, params) {
    if (Object.keys(params).length === 0) {
      return url;
    }
    let prefix = url.match(/\?/) ? "&" : "?";
    return `${url}${prefix}${this.serialize(params)}`;
  }
};
var LongPoll = class {
  constructor(endPoint) {
    this.endPoint = null;
    this.token = null;
    this.skipHeartbeat = true;
    this.reqs = /* @__PURE__ */ new Set();
    this.awaitingBatchAck = false;
    this.currentBatch = null;
    this.currentBatchTimer = null;
    this.batchBuffer = [];
    this.onopen = function() {
    };
    this.onerror = function() {
    };
    this.onmessage = function() {
    };
    this.onclose = function() {
    };
    this.pollEndpoint = this.normalizeEndpoint(endPoint);
    this.readyState = SOCKET_STATES.connecting;
    this.poll();
  }
  normalizeEndpoint(endPoint) {
    return endPoint.replace("ws://", "http://").replace("wss://", "https://").replace(new RegExp("(.*)/" + TRANSPORTS.websocket), "$1/" + TRANSPORTS.longpoll);
  }
  endpointURL() {
    return Ajax.appendParams(this.pollEndpoint, { token: this.token });
  }
  closeAndRetry(code, reason, wasClean) {
    this.close(code, reason, wasClean);
    this.readyState = SOCKET_STATES.connecting;
  }
  ontimeout() {
    this.onerror("timeout");
    this.closeAndRetry(1005, "timeout", false);
  }
  isActive() {
    return this.readyState === SOCKET_STATES.open || this.readyState === SOCKET_STATES.connecting;
  }
  poll() {
    this.ajax("GET", "application/json", null, () => this.ontimeout(), (resp) => {
      if (resp) {
        var { status, token, messages } = resp;
        this.token = token;
      } else {
        status = 0;
      }
      switch (status) {
        case 200:
          messages.forEach((msg) => {
            setTimeout(() => this.onmessage({ data: msg }), 0);
          });
          this.poll();
          break;
        case 204:
          this.poll();
          break;
        case 410:
          this.readyState = SOCKET_STATES.open;
          this.onopen({});
          this.poll();
          break;
        case 403:
          this.onerror(403);
          this.close(1008, "forbidden", false);
          break;
        case 0:
        case 500:
          this.onerror(500);
          this.closeAndRetry(1011, "internal server error", 500);
          break;
        default:
          throw new Error(`unhandled poll status ${status}`);
      }
    });
  }
  send(body) {
    if (this.currentBatch) {
      this.currentBatch.push(body);
    } else if (this.awaitingBatchAck) {
      this.batchBuffer.push(body);
    } else {
      this.currentBatch = [body];
      this.currentBatchTimer = setTimeout(() => {
        this.batchSend(this.currentBatch);
        this.currentBatch = null;
      }, 0);
    }
  }
  batchSend(messages) {
    this.awaitingBatchAck = true;
    this.ajax("POST", "application/x-ndjson", messages.join("\n"), () => this.onerror("timeout"), (resp) => {
      this.awaitingBatchAck = false;
      if (!resp || resp.status !== 200) {
        this.onerror(resp && resp.status);
        this.closeAndRetry(1011, "internal server error", false);
      } else if (this.batchBuffer.length > 0) {
        this.batchSend(this.batchBuffer);
        this.batchBuffer = [];
      }
    });
  }
  close(code, reason, wasClean) {
    for (let req of this.reqs) {
      req.abort();
    }
    this.readyState = SOCKET_STATES.closed;
    let opts = Object.assign({ code: 1e3, reason: void 0, wasClean: true }, { code, reason, wasClean });
    this.batchBuffer = [];
    clearTimeout(this.currentBatchTimer);
    this.currentBatchTimer = null;
    if (typeof CloseEvent !== "undefined") {
      this.onclose(new CloseEvent("close", opts));
    } else {
      this.onclose(opts);
    }
  }
  ajax(method, contentType, body, onCallerTimeout, callback) {
    let req;
    let ontimeout = () => {
      this.reqs.delete(req);
      onCallerTimeout();
    };
    req = Ajax.request(method, this.endpointURL(), contentType, body, this.timeout, ontimeout, (resp) => {
      this.reqs.delete(req);
      if (this.isActive()) {
        callback(resp);
      }
    });
    this.reqs.add(req);
  }
};
var serializer_default = {
  HEADER_LENGTH: 1,
  META_LENGTH: 4,
  KINDS: { push: 0, reply: 1, broadcast: 2 },
  encode(msg, callback) {
    if (msg.payload.constructor === ArrayBuffer) {
      return callback(this.binaryEncode(msg));
    } else {
      let payload = [msg.join_ref, msg.ref, msg.topic, msg.event, msg.payload];
      return callback(JSON.stringify(payload));
    }
  },
  decode(rawPayload, callback) {
    if (rawPayload.constructor === ArrayBuffer) {
      return callback(this.binaryDecode(rawPayload));
    } else {
      let [join_ref, ref, topic, event, payload] = JSON.parse(rawPayload);
      return callback({ join_ref, ref, topic, event, payload });
    }
  },
  binaryEncode(message) {
    let { join_ref, ref, event, topic, payload } = message;
    let metaLength = this.META_LENGTH + join_ref.length + ref.length + topic.length + event.length;
    let header = new ArrayBuffer(this.HEADER_LENGTH + metaLength);
    let view = new DataView(header);
    let offset = 0;
    view.setUint8(offset++, this.KINDS.push);
    view.setUint8(offset++, join_ref.length);
    view.setUint8(offset++, ref.length);
    view.setUint8(offset++, topic.length);
    view.setUint8(offset++, event.length);
    Array.from(join_ref, (char) => view.setUint8(offset++, char.charCodeAt(0)));
    Array.from(ref, (char) => view.setUint8(offset++, char.charCodeAt(0)));
    Array.from(topic, (char) => view.setUint8(offset++, char.charCodeAt(0)));
    Array.from(event, (char) => view.setUint8(offset++, char.charCodeAt(0)));
    var combined = new Uint8Array(header.byteLength + payload.byteLength);
    combined.set(new Uint8Array(header), 0);
    combined.set(new Uint8Array(payload), header.byteLength);
    return combined.buffer;
  },
  binaryDecode(buffer) {
    let view = new DataView(buffer);
    let kind = view.getUint8(0);
    let decoder = new TextDecoder();
    switch (kind) {
      case this.KINDS.push:
        return this.decodePush(buffer, view, decoder);
      case this.KINDS.reply:
        return this.decodeReply(buffer, view, decoder);
      case this.KINDS.broadcast:
        return this.decodeBroadcast(buffer, view, decoder);
    }
  },
  decodePush(buffer, view, decoder) {
    let joinRefSize = view.getUint8(1);
    let topicSize = view.getUint8(2);
    let eventSize = view.getUint8(3);
    let offset = this.HEADER_LENGTH + this.META_LENGTH - 1;
    let joinRef = decoder.decode(buffer.slice(offset, offset + joinRefSize));
    offset = offset + joinRefSize;
    let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
    offset = offset + topicSize;
    let event = decoder.decode(buffer.slice(offset, offset + eventSize));
    offset = offset + eventSize;
    let data = buffer.slice(offset, buffer.byteLength);
    return { join_ref: joinRef, ref: null, topic, event, payload: data };
  },
  decodeReply(buffer, view, decoder) {
    let joinRefSize = view.getUint8(1);
    let refSize = view.getUint8(2);
    let topicSize = view.getUint8(3);
    let eventSize = view.getUint8(4);
    let offset = this.HEADER_LENGTH + this.META_LENGTH;
    let joinRef = decoder.decode(buffer.slice(offset, offset + joinRefSize));
    offset = offset + joinRefSize;
    let ref = decoder.decode(buffer.slice(offset, offset + refSize));
    offset = offset + refSize;
    let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
    offset = offset + topicSize;
    let event = decoder.decode(buffer.slice(offset, offset + eventSize));
    offset = offset + eventSize;
    let data = buffer.slice(offset, buffer.byteLength);
    let payload = { status: event, response: data };
    return { join_ref: joinRef, ref, topic, event: CHANNEL_EVENTS.reply, payload };
  },
  decodeBroadcast(buffer, view, decoder) {
    let topicSize = view.getUint8(1);
    let eventSize = view.getUint8(2);
    let offset = this.HEADER_LENGTH + 2;
    let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
    offset = offset + topicSize;
    let event = decoder.decode(buffer.slice(offset, offset + eventSize));
    offset = offset + eventSize;
    let data = buffer.slice(offset, buffer.byteLength);
    return { join_ref: null, ref: null, topic, event, payload: data };
  }
};
var Socket = class {
  constructor(endPoint, opts = {}) {
    this.stateChangeCallbacks = { open: [], close: [], error: [], message: [] };
    this.channels = [];
    this.sendBuffer = [];
    this.ref = 0;
    this.timeout = opts.timeout || DEFAULT_TIMEOUT;
    this.transport = opts.transport || global.WebSocket || LongPoll;
    this.establishedConnections = 0;
    this.defaultEncoder = serializer_default.encode.bind(serializer_default);
    this.defaultDecoder = serializer_default.decode.bind(serializer_default);
    this.closeWasClean = false;
    this.binaryType = opts.binaryType || "arraybuffer";
    this.connectClock = 1;
    if (this.transport !== LongPoll) {
      this.encode = opts.encode || this.defaultEncoder;
      this.decode = opts.decode || this.defaultDecoder;
    } else {
      this.encode = this.defaultEncoder;
      this.decode = this.defaultDecoder;
    }
    let awaitingConnectionOnPageShow = null;
    if (phxWindow && phxWindow.addEventListener) {
      phxWindow.addEventListener("pagehide", (_e) => {
        if (this.conn) {
          this.disconnect();
          awaitingConnectionOnPageShow = this.connectClock;
        }
      });
      phxWindow.addEventListener("pageshow", (_e) => {
        if (awaitingConnectionOnPageShow === this.connectClock) {
          awaitingConnectionOnPageShow = null;
          this.connect();
        }
      });
    }
    this.heartbeatIntervalMs = opts.heartbeatIntervalMs || 3e4;
    this.rejoinAfterMs = (tries) => {
      if (opts.rejoinAfterMs) {
        return opts.rejoinAfterMs(tries);
      } else {
        return [1e3, 2e3, 5e3][tries - 1] || 1e4;
      }
    };
    this.reconnectAfterMs = (tries) => {
      if (opts.reconnectAfterMs) {
        return opts.reconnectAfterMs(tries);
      } else {
        return [10, 50, 100, 150, 200, 250, 500, 1e3, 2e3][tries - 1] || 5e3;
      }
    };
    this.logger = opts.logger || null;
    this.longpollerTimeout = opts.longpollerTimeout || 2e4;
    this.params = closure(opts.params || {});
    this.endPoint = `${endPoint}/${TRANSPORTS.websocket}`;
    this.vsn = opts.vsn || DEFAULT_VSN;
    this.heartbeatTimeoutTimer = null;
    this.heartbeatTimer = null;
    this.pendingHeartbeatRef = null;
    this.reconnectTimer = new Timer(() => {
      this.teardown(() => this.connect());
    }, this.reconnectAfterMs);
  }
  getLongPollTransport() {
    return LongPoll;
  }
  replaceTransport(newTransport) {
    this.connectClock++;
    this.closeWasClean = true;
    this.reconnectTimer.reset();
    this.sendBuffer = [];
    if (this.conn) {
      this.conn.close();
      this.conn = null;
    }
    this.transport = newTransport;
  }
  protocol() {
    return location.protocol.match(/^https/) ? "wss" : "ws";
  }
  endPointURL() {
    let uri = Ajax.appendParams(Ajax.appendParams(this.endPoint, this.params()), { vsn: this.vsn });
    if (uri.charAt(0) !== "/") {
      return uri;
    }
    if (uri.charAt(1) === "/") {
      return `${this.protocol()}:${uri}`;
    }
    return `${this.protocol()}://${location.host}${uri}`;
  }
  disconnect(callback, code, reason) {
    this.connectClock++;
    this.closeWasClean = true;
    this.reconnectTimer.reset();
    this.teardown(callback, code, reason);
  }
  connect(params) {
    if (params) {
      console && console.log("passing params to connect is deprecated. Instead pass :params to the Socket constructor");
      this.params = closure(params);
    }
    if (this.conn) {
      return;
    }
    this.connectClock++;
    this.closeWasClean = false;
    this.conn = new this.transport(this.endPointURL());
    this.conn.binaryType = this.binaryType;
    this.conn.timeout = this.longpollerTimeout;
    this.conn.onopen = () => this.onConnOpen();
    this.conn.onerror = (error) => this.onConnError(error);
    this.conn.onmessage = (event) => this.onConnMessage(event);
    this.conn.onclose = (event) => this.onConnClose(event);
  }
  log(kind, msg, data) {
    this.logger(kind, msg, data);
  }
  hasLogger() {
    return this.logger !== null;
  }
  onOpen(callback) {
    let ref = this.makeRef();
    this.stateChangeCallbacks.open.push([ref, callback]);
    return ref;
  }
  onClose(callback) {
    let ref = this.makeRef();
    this.stateChangeCallbacks.close.push([ref, callback]);
    return ref;
  }
  onError(callback) {
    let ref = this.makeRef();
    this.stateChangeCallbacks.error.push([ref, callback]);
    return ref;
  }
  onMessage(callback) {
    let ref = this.makeRef();
    this.stateChangeCallbacks.message.push([ref, callback]);
    return ref;
  }
  ping(callback) {
    if (!this.isConnected()) {
      return false;
    }
    let ref = this.makeRef();
    let startTime = Date.now();
    this.push({ topic: "phoenix", event: "heartbeat", payload: {}, ref });
    let onMsgRef = this.onMessage((msg) => {
      if (msg.ref === ref) {
        this.off([onMsgRef]);
        callback(Date.now() - startTime);
      }
    });
    return true;
  }
  clearHeartbeats() {
    clearTimeout(this.heartbeatTimer);
    clearTimeout(this.heartbeatTimeoutTimer);
  }
  onConnOpen() {
    if (this.hasLogger())
      this.log("transport", `connected to ${this.endPointURL()}`);
    this.closeWasClean = false;
    this.establishedConnections++;
    this.flushSendBuffer();
    this.reconnectTimer.reset();
    this.resetHeartbeat();
    this.stateChangeCallbacks.open.forEach(([, callback]) => callback());
  }
  heartbeatTimeout() {
    if (this.pendingHeartbeatRef) {
      this.pendingHeartbeatRef = null;
      if (this.hasLogger()) {
        this.log("transport", "heartbeat timeout. Attempting to re-establish connection");
      }
      this.triggerChanError();
      this.closeWasClean = false;
      this.teardown(() => this.reconnectTimer.scheduleTimeout(), WS_CLOSE_NORMAL, "heartbeat timeout");
    }
  }
  resetHeartbeat() {
    if (this.conn && this.conn.skipHeartbeat) {
      return;
    }
    this.pendingHeartbeatRef = null;
    this.clearHeartbeats();
    this.heartbeatTimer = setTimeout(() => this.sendHeartbeat(), this.heartbeatIntervalMs);
  }
  teardown(callback, code, reason) {
    if (!this.conn) {
      return callback && callback();
    }
    this.waitForBufferDone(() => {
      if (this.conn) {
        if (code) {
          this.conn.close(code, reason || "");
        } else {
          this.conn.close();
        }
      }
      this.waitForSocketClosed(() => {
        if (this.conn) {
          this.conn.onopen = function() {
          };
          this.conn.onerror = function() {
          };
          this.conn.onmessage = function() {
          };
          this.conn.onclose = function() {
          };
          this.conn = null;
        }
        callback && callback();
      });
    });
  }
  waitForBufferDone(callback, tries = 1) {
    if (tries === 5 || !this.conn || !this.conn.bufferedAmount) {
      callback();
      return;
    }
    setTimeout(() => {
      this.waitForBufferDone(callback, tries + 1);
    }, 150 * tries);
  }
  waitForSocketClosed(callback, tries = 1) {
    if (tries === 5 || !this.conn || this.conn.readyState === SOCKET_STATES.closed) {
      callback();
      return;
    }
    setTimeout(() => {
      this.waitForSocketClosed(callback, tries + 1);
    }, 150 * tries);
  }
  onConnClose(event) {
    let closeCode = event && event.code;
    if (this.hasLogger())
      this.log("transport", "close", event);
    this.triggerChanError();
    this.clearHeartbeats();
    if (!this.closeWasClean && closeCode !== 1e3) {
      this.reconnectTimer.scheduleTimeout();
    }
    this.stateChangeCallbacks.close.forEach(([, callback]) => callback(event));
  }
  onConnError(error) {
    if (this.hasLogger())
      this.log("transport", error);
    let transportBefore = this.transport;
    let establishedBefore = this.establishedConnections;
    this.stateChangeCallbacks.error.forEach(([, callback]) => {
      callback(error, transportBefore, establishedBefore);
    });
    if (transportBefore === this.transport || establishedBefore > 0) {
      this.triggerChanError();
    }
  }
  triggerChanError() {
    this.channels.forEach((channel) => {
      if (!(channel.isErrored() || channel.isLeaving() || channel.isClosed())) {
        channel.trigger(CHANNEL_EVENTS.error);
      }
    });
  }
  connectionState() {
    switch (this.conn && this.conn.readyState) {
      case SOCKET_STATES.connecting:
        return "connecting";
      case SOCKET_STATES.open:
        return "open";
      case SOCKET_STATES.closing:
        return "closing";
      default:
        return "closed";
    }
  }
  isConnected() {
    return this.connectionState() === "open";
  }
  remove(channel) {
    this.off(channel.stateChangeRefs);
    this.channels = this.channels.filter((c) => c.joinRef() !== channel.joinRef());
  }
  off(refs) {
    for (let key in this.stateChangeCallbacks) {
      this.stateChangeCallbacks[key] = this.stateChangeCallbacks[key].filter(([ref]) => {
        return refs.indexOf(ref) === -1;
      });
    }
  }
  channel(topic, chanParams = {}) {
    let chan = new Channel(topic, chanParams, this);
    this.channels.push(chan);
    return chan;
  }
  push(data) {
    if (this.hasLogger()) {
      let { topic, event, payload, ref, join_ref } = data;
      this.log("push", `${topic} ${event} (${join_ref}, ${ref})`, payload);
    }
    if (this.isConnected()) {
      this.encode(data, (result) => this.conn.send(result));
    } else {
      this.sendBuffer.push(() => this.encode(data, (result) => this.conn.send(result)));
    }
  }
  makeRef() {
    let newRef = this.ref + 1;
    if (newRef === this.ref) {
      this.ref = 0;
    } else {
      this.ref = newRef;
    }
    return this.ref.toString();
  }
  sendHeartbeat() {
    if (this.pendingHeartbeatRef && !this.isConnected()) {
      return;
    }
    this.pendingHeartbeatRef = this.makeRef();
    this.push({ topic: "phoenix", event: "heartbeat", payload: {}, ref: this.pendingHeartbeatRef });
    this.heartbeatTimeoutTimer = setTimeout(() => this.heartbeatTimeout(), this.heartbeatIntervalMs);
  }
  flushSendBuffer() {
    if (this.isConnected() && this.sendBuffer.length > 0) {
      this.sendBuffer.forEach((callback) => callback());
      this.sendBuffer = [];
    }
  }
  onConnMessage(rawMessage) {
    this.decode(rawMessage.data, (msg) => {
      let { topic, event, payload, ref, join_ref } = msg;
      if (ref && ref === this.pendingHeartbeatRef) {
        this.clearHeartbeats();
        this.pendingHeartbeatRef = null;
        this.heartbeatTimer = setTimeout(() => this.sendHeartbeat(), this.heartbeatIntervalMs);
      }
      if (this.hasLogger())
        this.log("receive", `${payload.status || ""} ${topic} ${event} ${ref && "(" + ref + ")" || ""}`, payload);
      for (let i = 0; i < this.channels.length; i++) {
        const channel = this.channels[i];
        if (!channel.isMember(topic, event, payload, join_ref)) {
          continue;
        }
        channel.trigger(event, payload, ref, join_ref);
      }
      for (let i = 0; i < this.stateChangeCallbacks.message.length; i++) {
        let [, callback] = this.stateChangeCallbacks.message[i];
        callback(msg);
      }
    });
  }
  leaveOpenTopic(topic) {
    let dupChannel = this.channels.find((c) => c.topic === topic && (c.isJoined() || c.isJoining()));
    if (dupChannel) {
      if (this.hasLogger())
        this.log("transport", `leaving duplicate topic "${topic}"`);
      dupChannel.leave();
    }
  }
};

// ../deps/phoenix_live_view/priv/static/phoenix_live_view.esm.js
var CONSECUTIVE_RELOADS = "consecutive-reloads";
var MAX_RELOADS = 10;
var RELOAD_JITTER_MIN = 5e3;
var RELOAD_JITTER_MAX = 1e4;
var FAILSAFE_JITTER = 3e4;
var PHX_EVENT_CLASSES = [
  "phx-click-loading",
  "phx-change-loading",
  "phx-submit-loading",
  "phx-keydown-loading",
  "phx-keyup-loading",
  "phx-blur-loading",
  "phx-focus-loading"
];
var PHX_COMPONENT = "data-phx-component";
var PHX_LIVE_LINK = "data-phx-link";
var PHX_TRACK_STATIC = "track-static";
var PHX_LINK_STATE = "data-phx-link-state";
var PHX_REF = "data-phx-ref";
var PHX_REF_SRC = "data-phx-ref-src";
var PHX_TRACK_UPLOADS = "track-uploads";
var PHX_UPLOAD_REF = "data-phx-upload-ref";
var PHX_PREFLIGHTED_REFS = "data-phx-preflighted-refs";
var PHX_DONE_REFS = "data-phx-done-refs";
var PHX_DROP_TARGET = "drop-target";
var PHX_ACTIVE_ENTRY_REFS = "data-phx-active-refs";
var PHX_LIVE_FILE_UPDATED = "phx:live-file:updated";
var PHX_SKIP = "data-phx-skip";
var PHX_PRUNE = "data-phx-prune";
var PHX_PAGE_LOADING = "page-loading";
var PHX_CONNECTED_CLASS = "phx-connected";
var PHX_DISCONNECTED_CLASS = "phx-loading";
var PHX_NO_FEEDBACK_CLASS = "phx-no-feedback";
var PHX_ERROR_CLASS = "phx-error";
var PHX_PARENT_ID = "data-phx-parent-id";
var PHX_MAIN = "data-phx-main";
var PHX_ROOT_ID = "data-phx-root-id";
var PHX_TRIGGER_ACTION = "trigger-action";
var PHX_FEEDBACK_FOR = "feedback-for";
var PHX_HAS_FOCUSED = "phx-has-focused";
var FOCUSABLE_INPUTS = ["text", "textarea", "number", "email", "password", "search", "tel", "url", "date", "time", "datetime-local", "color", "range"];
var CHECKABLE_INPUTS = ["checkbox", "radio"];
var PHX_HAS_SUBMITTED = "phx-has-submitted";
var PHX_SESSION = "data-phx-session";
var PHX_VIEW_SELECTOR = `[${PHX_SESSION}]`;
var PHX_STICKY = "data-phx-sticky";
var PHX_STATIC = "data-phx-static";
var PHX_READONLY = "data-phx-readonly";
var PHX_DISABLED = "data-phx-disabled";
var PHX_DISABLE_WITH = "disable-with";
var PHX_DISABLE_WITH_RESTORE = "data-phx-disable-with-restore";
var PHX_HOOK = "hook";
var PHX_DEBOUNCE = "debounce";
var PHX_THROTTLE = "throttle";
var PHX_UPDATE = "update";
var PHX_STREAM = "stream";
var PHX_KEY = "key";
var PHX_PRIVATE = "phxPrivate";
var PHX_AUTO_RECOVER = "auto-recover";
var PHX_LV_DEBUG = "phx:live-socket:debug";
var PHX_LV_PROFILE = "phx:live-socket:profiling";
var PHX_LV_LATENCY_SIM = "phx:live-socket:latency-sim";
var PHX_PROGRESS = "progress";
var PHX_MOUNTED = "mounted";
var LOADER_TIMEOUT = 1;
var BEFORE_UNLOAD_LOADER_TIMEOUT = 200;
var BINDING_PREFIX = "phx-";
var PUSH_TIMEOUT = 3e4;
var DEBOUNCE_TRIGGER = "debounce-trigger";
var THROTTLED = "throttled";
var DEBOUNCE_PREV_KEY = "debounce-prev-key";
var DEFAULTS = {
  debounce: 300,
  throttle: 300
};
var DYNAMICS = "d";
var STATIC = "s";
var COMPONENTS = "c";
var EVENTS = "e";
var REPLY = "r";
var TITLE = "t";
var TEMPLATES = "p";
var STREAM = "stream";
var EntryUploader = class {
  constructor(entry, chunkSize, liveSocket2) {
    this.liveSocket = liveSocket2;
    this.entry = entry;
    this.offset = 0;
    this.chunkSize = chunkSize;
    this.chunkTimer = null;
    this.uploadChannel = liveSocket2.channel(`lvu:${entry.ref}`, { token: entry.metadata() });
  }
  error(reason) {
    clearTimeout(this.chunkTimer);
    this.uploadChannel.leave();
    this.entry.error(reason);
  }
  upload() {
    this.uploadChannel.onError((reason) => this.error(reason));
    this.uploadChannel.join().receive("ok", (_data) => this.readNextChunk()).receive("error", (reason) => this.error(reason));
  }
  isDone() {
    return this.offset >= this.entry.file.size;
  }
  readNextChunk() {
    let reader = new window.FileReader();
    let blob = this.entry.file.slice(this.offset, this.chunkSize + this.offset);
    reader.onload = (e) => {
      if (e.target.error === null) {
        this.offset += e.target.result.byteLength;
        this.pushChunk(e.target.result);
      } else {
        return logError("Read error: " + e.target.error);
      }
    };
    reader.readAsArrayBuffer(blob);
  }
  pushChunk(chunk) {
    if (!this.uploadChannel.isJoined()) {
      return;
    }
    this.uploadChannel.push("chunk", chunk).receive("ok", () => {
      this.entry.progress(this.offset / this.entry.file.size * 100);
      if (!this.isDone()) {
        this.chunkTimer = setTimeout(() => this.readNextChunk(), this.liveSocket.getLatencySim() || 0);
      }
    });
  }
};
var logError = (msg, obj) => console.error && console.error(msg, obj);
var isCid = (cid) => {
  let type = typeof cid;
  return type === "number" || type === "string" && /^(0|[1-9]\d*)$/.test(cid);
};
function detectDuplicateIds() {
  let ids = /* @__PURE__ */ new Set();
  let elems = document.querySelectorAll("*[id]");
  for (let i = 0, len = elems.length; i < len; i++) {
    if (ids.has(elems[i].id)) {
      console.error(`Multiple IDs detected: ${elems[i].id}. Ensure unique element ids.`);
    } else {
      ids.add(elems[i].id);
    }
  }
}
var debug = (view, kind, msg, obj) => {
  if (view.liveSocket.isDebugEnabled()) {
    console.log(`${view.id} ${kind}: ${msg} - `, obj);
  }
};
var closure2 = (val) => typeof val === "function" ? val : function() {
  return val;
};
var clone = (obj) => {
  return JSON.parse(JSON.stringify(obj));
};
var closestPhxBinding = (el, binding, borderEl) => {
  do {
    if (el.matches(`[${binding}]`) && !el.disabled) {
      return el;
    }
    el = el.parentElement || el.parentNode;
  } while (el !== null && el.nodeType === 1 && !(borderEl && borderEl.isSameNode(el) || el.matches(PHX_VIEW_SELECTOR)));
  return null;
};
var isObject = (obj) => {
  return obj !== null && typeof obj === "object" && !(obj instanceof Array);
};
var isEqualObj = (obj1, obj2) => JSON.stringify(obj1) === JSON.stringify(obj2);
var isEmpty = (obj) => {
  for (let x in obj) {
    return false;
  }
  return true;
};
var maybe = (el, callback) => el && callback(el);
var channelUploader = function(entries, onError, resp, liveSocket2) {
  entries.forEach((entry) => {
    let entryUploader = new EntryUploader(entry, resp.config.chunk_size, liveSocket2);
    entryUploader.upload();
  });
};
var Browser = {
  canPushState() {
    return typeof history.pushState !== "undefined";
  },
  dropLocal(localStorage2, namespace, subkey) {
    return localStorage2.removeItem(this.localKey(namespace, subkey));
  },
  updateLocal(localStorage2, namespace, subkey, initial, func) {
    let current2 = this.getLocal(localStorage2, namespace, subkey);
    let key = this.localKey(namespace, subkey);
    let newVal = current2 === null ? initial : func(current2);
    localStorage2.setItem(key, JSON.stringify(newVal));
    return newVal;
  },
  getLocal(localStorage2, namespace, subkey) {
    return JSON.parse(localStorage2.getItem(this.localKey(namespace, subkey)));
  },
  updateCurrentState(callback) {
    if (!this.canPushState()) {
      return;
    }
    history.replaceState(callback(history.state || {}), "", window.location.href);
  },
  pushState(kind, meta, to) {
    if (this.canPushState()) {
      if (to !== window.location.href) {
        if (meta.type == "redirect" && meta.scroll) {
          let currentState = history.state || {};
          currentState.scroll = meta.scroll;
          history.replaceState(currentState, "", window.location.href);
        }
        delete meta.scroll;
        history[kind + "State"](meta, "", to || null);
        let hashEl = this.getHashTargetEl(window.location.hash);
        if (hashEl) {
          hashEl.scrollIntoView();
        } else if (meta.type === "redirect") {
          window.scroll(0, 0);
        }
      }
    } else {
      this.redirect(to);
    }
  },
  setCookie(name, value) {
    document.cookie = `${name}=${value}`;
  },
  getCookie(name) {
    return document.cookie.replace(new RegExp(`(?:(?:^|.*;s*)${name}s*=s*([^;]*).*$)|^.*$`), "$1");
  },
  redirect(toURL, flash) {
    if (flash) {
      Browser.setCookie("__phoenix_flash__", flash + "; max-age=60000; path=/");
    }
    window.location = toURL;
  },
  localKey(namespace, subkey) {
    return `${namespace}-${subkey}`;
  },
  getHashTargetEl(maybeHash) {
    let hash = maybeHash.toString().substring(1);
    if (hash === "") {
      return;
    }
    return document.getElementById(hash) || document.querySelector(`a[name="${hash}"]`);
  }
};
var browser_default = Browser;
var DOM = {
  byId(id) {
    return document.getElementById(id) || logError(`no id found for ${id}`);
  },
  removeClass(el, className) {
    el.classList.remove(className);
    if (el.classList.length === 0) {
      el.removeAttribute("class");
    }
  },
  all(node, query, callback) {
    if (!node) {
      return [];
    }
    let array = Array.from(node.querySelectorAll(query));
    return callback ? array.forEach(callback) : array;
  },
  childNodeLength(html) {
    let template = document.createElement("template");
    template.innerHTML = html;
    return template.content.childElementCount;
  },
  isUploadInput(el) {
    return el.type === "file" && el.getAttribute(PHX_UPLOAD_REF) !== null;
  },
  findUploadInputs(node) {
    return this.all(node, `input[type="file"][${PHX_UPLOAD_REF}]`);
  },
  findComponentNodeList(node, cid) {
    return this.filterWithinSameLiveView(this.all(node, `[${PHX_COMPONENT}="${cid}"]`), node);
  },
  isPhxDestroyed(node) {
    return node.id && DOM.private(node, "destroyed") ? true : false;
  },
  wantsNewTab(e) {
    let wantsNewTab = e.ctrlKey || e.shiftKey || e.metaKey || e.button && e.button === 1;
    return wantsNewTab || e.target.getAttribute("target") === "_blank";
  },
  isUnloadableFormSubmit(e) {
    return !e.defaultPrevented && !this.wantsNewTab(e);
  },
  isNewPageHref(href, currentLocation) {
    let url;
    try {
      url = new URL(href);
    } catch (e) {
      try {
        url = new URL(href, currentLocation);
      } catch (e2) {
        return true;
      }
    }
    if (url.host === currentLocation.host && url.protocol === currentLocation.protocol) {
      if (url.pathname === currentLocation.pathname && url.search === currentLocation.search) {
        return url.hash === "" && !url.href.endsWith("#");
      }
    }
    return true;
  },
  markPhxChildDestroyed(el) {
    if (this.isPhxChild(el)) {
      el.setAttribute(PHX_SESSION, "");
    }
    this.putPrivate(el, "destroyed", true);
  },
  findPhxChildrenInFragment(html, parentId) {
    let template = document.createElement("template");
    template.innerHTML = html;
    return this.findPhxChildren(template.content, parentId);
  },
  isIgnored(el, phxUpdate) {
    return (el.getAttribute(phxUpdate) || el.getAttribute("data-phx-update")) === "ignore";
  },
  isPhxUpdate(el, phxUpdate, updateTypes) {
    return el.getAttribute && updateTypes.indexOf(el.getAttribute(phxUpdate)) >= 0;
  },
  findPhxSticky(el) {
    return this.all(el, `[${PHX_STICKY}]`);
  },
  findPhxChildren(el, parentId) {
    return this.all(el, `${PHX_VIEW_SELECTOR}[${PHX_PARENT_ID}="${parentId}"]`);
  },
  findParentCIDs(node, cids) {
    let initial = new Set(cids);
    let parentCids = cids.reduce((acc, cid) => {
      let selector = `[${PHX_COMPONENT}="${cid}"] [${PHX_COMPONENT}]`;
      this.filterWithinSameLiveView(this.all(node, selector), node).map((el) => parseInt(el.getAttribute(PHX_COMPONENT))).forEach((childCID) => acc.delete(childCID));
      return acc;
    }, initial);
    return parentCids.size === 0 ? new Set(cids) : parentCids;
  },
  filterWithinSameLiveView(nodes, parent) {
    if (parent.querySelector(PHX_VIEW_SELECTOR)) {
      return nodes.filter((el) => this.withinSameLiveView(el, parent));
    } else {
      return nodes;
    }
  },
  withinSameLiveView(node, parent) {
    while (node = node.parentNode) {
      if (node.isSameNode(parent)) {
        return true;
      }
      if (node.getAttribute(PHX_SESSION) !== null) {
        return false;
      }
    }
  },
  private(el, key) {
    return el[PHX_PRIVATE] && el[PHX_PRIVATE][key];
  },
  deletePrivate(el, key) {
    el[PHX_PRIVATE] && delete el[PHX_PRIVATE][key];
  },
  putPrivate(el, key, value) {
    if (!el[PHX_PRIVATE]) {
      el[PHX_PRIVATE] = {};
    }
    el[PHX_PRIVATE][key] = value;
  },
  updatePrivate(el, key, defaultVal, updateFunc) {
    let existing = this.private(el, key);
    if (existing === void 0) {
      this.putPrivate(el, key, updateFunc(defaultVal));
    } else {
      this.putPrivate(el, key, updateFunc(existing));
    }
  },
  copyPrivates(target, source) {
    if (source[PHX_PRIVATE]) {
      target[PHX_PRIVATE] = source[PHX_PRIVATE];
    }
  },
  putTitle(str) {
    let titleEl = document.querySelector("title");
    if (titleEl) {
      let { prefix, suffix } = titleEl.dataset;
      document.title = `${prefix || ""}${str}${suffix || ""}`;
    } else {
      document.title = str;
    }
  },
  debounce(el, event, phxDebounce, defaultDebounce, phxThrottle, defaultThrottle, asyncFilter, callback) {
    let debounce = el.getAttribute(phxDebounce);
    let throttle = el.getAttribute(phxThrottle);
    if (debounce === "") {
      debounce = defaultDebounce;
    }
    if (throttle === "") {
      throttle = defaultThrottle;
    }
    let value = debounce || throttle;
    switch (value) {
      case null:
        return callback();
      case "blur":
        if (this.once(el, "debounce-blur")) {
          el.addEventListener("blur", () => callback());
        }
        return;
      default:
        let timeout = parseInt(value);
        let trigger = () => throttle ? this.deletePrivate(el, THROTTLED) : callback();
        let currentCycle = this.incCycle(el, DEBOUNCE_TRIGGER, trigger);
        if (isNaN(timeout)) {
          return logError(`invalid throttle/debounce value: ${value}`);
        }
        if (throttle) {
          let newKeyDown = false;
          if (event.type === "keydown") {
            let prevKey = this.private(el, DEBOUNCE_PREV_KEY);
            this.putPrivate(el, DEBOUNCE_PREV_KEY, event.key);
            newKeyDown = prevKey !== event.key;
          }
          if (!newKeyDown && this.private(el, THROTTLED)) {
            return false;
          } else {
            callback();
            this.putPrivate(el, THROTTLED, true);
            setTimeout(() => {
              if (asyncFilter()) {
                this.triggerCycle(el, DEBOUNCE_TRIGGER);
              }
            }, timeout);
          }
        } else {
          setTimeout(() => {
            if (asyncFilter()) {
              this.triggerCycle(el, DEBOUNCE_TRIGGER, currentCycle);
            }
          }, timeout);
        }
        let form = el.form;
        if (form && this.once(form, "bind-debounce")) {
          form.addEventListener("submit", () => {
            Array.from(new FormData(form).entries(), ([name]) => {
              let input = form.querySelector(`[name="${name}"]`);
              this.incCycle(input, DEBOUNCE_TRIGGER);
              this.deletePrivate(input, THROTTLED);
            });
          });
        }
        if (this.once(el, "bind-debounce")) {
          el.addEventListener("blur", () => this.triggerCycle(el, DEBOUNCE_TRIGGER));
        }
    }
  },
  triggerCycle(el, key, currentCycle) {
    let [cycle, trigger] = this.private(el, key);
    if (!currentCycle) {
      currentCycle = cycle;
    }
    if (currentCycle === cycle) {
      this.incCycle(el, key);
      trigger();
    }
  },
  once(el, key) {
    if (this.private(el, key) === true) {
      return false;
    }
    this.putPrivate(el, key, true);
    return true;
  },
  incCycle(el, key, trigger = function() {
  }) {
    let [currentCycle] = this.private(el, key) || [0, trigger];
    currentCycle++;
    this.putPrivate(el, key, [currentCycle, trigger]);
    return currentCycle;
  },
  discardError(container, el, phxFeedbackFor) {
    let field = el.getAttribute && el.getAttribute(phxFeedbackFor);
    let input = field && container.querySelector(`[id="${field}"], [name="${field}"], [name="${field}[]"]`);
    if (!input) {
      return;
    }
    if (!(this.private(input, PHX_HAS_FOCUSED) || this.private(input, PHX_HAS_SUBMITTED))) {
      el.classList.add(PHX_NO_FEEDBACK_CLASS);
    }
  },
  resetForm(form, phxFeedbackFor) {
    Array.from(form.elements).forEach((input) => {
      let query = `[${phxFeedbackFor}="${input.id}"],
                   [${phxFeedbackFor}="${input.name}"],
                   [${phxFeedbackFor}="${input.name.replace(/\[\]$/, "")}"]`;
      this.deletePrivate(input, PHX_HAS_FOCUSED);
      this.deletePrivate(input, PHX_HAS_SUBMITTED);
      this.all(document, query, (feedbackEl) => {
        feedbackEl.classList.add(PHX_NO_FEEDBACK_CLASS);
      });
    });
  },
  showError(inputEl, phxFeedbackFor) {
    if (inputEl.id || inputEl.name) {
      this.all(inputEl.form, `[${phxFeedbackFor}="${inputEl.id}"], [${phxFeedbackFor}="${inputEl.name}"]`, (el) => {
        this.removeClass(el, PHX_NO_FEEDBACK_CLASS);
      });
    }
  },
  isPhxChild(node) {
    return node.getAttribute && node.getAttribute(PHX_PARENT_ID);
  },
  isPhxSticky(node) {
    return node.getAttribute && node.getAttribute(PHX_STICKY) !== null;
  },
  firstPhxChild(el) {
    return this.isPhxChild(el) ? el : this.all(el, `[${PHX_PARENT_ID}]`)[0];
  },
  dispatchEvent(target, name, opts = {}) {
    let bubbles = opts.bubbles === void 0 ? true : !!opts.bubbles;
    let eventOpts = { bubbles, cancelable: true, detail: opts.detail || {} };
    let event = name === "click" ? new MouseEvent("click", eventOpts) : new CustomEvent(name, eventOpts);
    target.dispatchEvent(event);
  },
  cloneNode(node, html) {
    if (typeof html === "undefined") {
      return node.cloneNode(true);
    } else {
      let cloned = node.cloneNode(false);
      cloned.innerHTML = html;
      return cloned;
    }
  },
  mergeAttrs(target, source, opts = {}) {
    let exclude = opts.exclude || [];
    let isIgnored = opts.isIgnored;
    let sourceAttrs = source.attributes;
    for (let i = sourceAttrs.length - 1; i >= 0; i--) {
      let name = sourceAttrs[i].name;
      if (exclude.indexOf(name) < 0) {
        target.setAttribute(name, source.getAttribute(name));
      }
    }
    let targetAttrs = target.attributes;
    for (let i = targetAttrs.length - 1; i >= 0; i--) {
      let name = targetAttrs[i].name;
      if (isIgnored) {
        if (name.startsWith("data-") && !source.hasAttribute(name)) {
          target.removeAttribute(name);
        }
      } else {
        if (!source.hasAttribute(name)) {
          target.removeAttribute(name);
        }
      }
    }
  },
  mergeFocusedInput(target, source) {
    if (!(target instanceof HTMLSelectElement)) {
      DOM.mergeAttrs(target, source, { exclude: ["value"] });
    }
    if (source.readOnly) {
      target.setAttribute("readonly", true);
    } else {
      target.removeAttribute("readonly");
    }
  },
  hasSelectionRange(el) {
    return el.setSelectionRange && (el.type === "text" || el.type === "textarea");
  },
  restoreFocus(focused, selectionStart, selectionEnd) {
    if (!DOM.isTextualInput(focused)) {
      return;
    }
    let wasFocused = focused.matches(":focus");
    if (focused.readOnly) {
      focused.blur();
    }
    if (!wasFocused) {
      focused.focus();
    }
    if (this.hasSelectionRange(focused)) {
      focused.setSelectionRange(selectionStart, selectionEnd);
    }
  },
  isFormInput(el) {
    return /^(?:input|select|textarea)$/i.test(el.tagName) && el.type !== "button";
  },
  syncAttrsToProps(el) {
    if (el instanceof HTMLInputElement && CHECKABLE_INPUTS.indexOf(el.type.toLocaleLowerCase()) >= 0) {
      el.checked = el.getAttribute("checked") !== null;
    }
  },
  isTextualInput(el) {
    return FOCUSABLE_INPUTS.indexOf(el.type) >= 0;
  },
  isNowTriggerFormExternal(el, phxTriggerExternal) {
    return el.getAttribute && el.getAttribute(phxTriggerExternal) !== null;
  },
  syncPendingRef(fromEl, toEl, disableWith) {
    let ref = fromEl.getAttribute(PHX_REF);
    if (ref === null) {
      return true;
    }
    let refSrc = fromEl.getAttribute(PHX_REF_SRC);
    if (DOM.isFormInput(fromEl) || fromEl.getAttribute(disableWith) !== null) {
      if (DOM.isUploadInput(fromEl)) {
        DOM.mergeAttrs(fromEl, toEl, { isIgnored: true });
      }
      DOM.putPrivate(fromEl, PHX_REF, toEl);
      return false;
    } else {
      PHX_EVENT_CLASSES.forEach((className) => {
        fromEl.classList.contains(className) && toEl.classList.add(className);
      });
      toEl.setAttribute(PHX_REF, ref);
      toEl.setAttribute(PHX_REF_SRC, refSrc);
      return true;
    }
  },
  cleanChildNodes(container, phxUpdate) {
    if (DOM.isPhxUpdate(container, phxUpdate, ["append", "prepend"])) {
      let toRemove = [];
      container.childNodes.forEach((childNode) => {
        if (!childNode.id) {
          let isEmptyTextNode = childNode.nodeType === Node.TEXT_NODE && childNode.nodeValue.trim() === "";
          if (!isEmptyTextNode) {
            logError(`only HTML element tags with an id are allowed inside containers with phx-update.

removing illegal node: "${(childNode.outerHTML || childNode.nodeValue).trim()}"

`);
          }
          toRemove.push(childNode);
        }
      });
      toRemove.forEach((childNode) => childNode.remove());
    }
  },
  replaceRootContainer(container, tagName, attrs) {
    let retainedAttrs = /* @__PURE__ */ new Set(["id", PHX_SESSION, PHX_STATIC, PHX_MAIN, PHX_ROOT_ID]);
    if (container.tagName.toLowerCase() === tagName.toLowerCase()) {
      Array.from(container.attributes).filter((attr) => !retainedAttrs.has(attr.name.toLowerCase())).forEach((attr) => container.removeAttribute(attr.name));
      Object.keys(attrs).filter((name) => !retainedAttrs.has(name.toLowerCase())).forEach((attr) => container.setAttribute(attr, attrs[attr]));
      return container;
    } else {
      let newContainer = document.createElement(tagName);
      Object.keys(attrs).forEach((attr) => newContainer.setAttribute(attr, attrs[attr]));
      retainedAttrs.forEach((attr) => newContainer.setAttribute(attr, container.getAttribute(attr)));
      newContainer.innerHTML = container.innerHTML;
      container.replaceWith(newContainer);
      return newContainer;
    }
  },
  getSticky(el, name, defaultVal) {
    let op = (DOM.private(el, "sticky") || []).find(([existingName]) => name === existingName);
    if (op) {
      let [_name, _op, stashedResult] = op;
      return stashedResult;
    } else {
      return typeof defaultVal === "function" ? defaultVal() : defaultVal;
    }
  },
  deleteSticky(el, name) {
    this.updatePrivate(el, "sticky", [], (ops) => {
      return ops.filter(([existingName, _]) => existingName !== name);
    });
  },
  putSticky(el, name, op) {
    let stashedResult = op(el);
    this.updatePrivate(el, "sticky", [], (ops) => {
      let existingIndex = ops.findIndex(([existingName]) => name === existingName);
      if (existingIndex >= 0) {
        ops[existingIndex] = [name, op, stashedResult];
      } else {
        ops.push([name, op, stashedResult]);
      }
      return ops;
    });
  },
  applyStickyOperations(el) {
    let ops = DOM.private(el, "sticky");
    if (!ops) {
      return;
    }
    ops.forEach(([name, op, _stashed]) => this.putSticky(el, name, op));
  }
};
var dom_default = DOM;
var UploadEntry = class {
  static isActive(fileEl, file) {
    let isNew = file._phxRef === void 0;
    let activeRefs = fileEl.getAttribute(PHX_ACTIVE_ENTRY_REFS).split(",");
    let isActive = activeRefs.indexOf(LiveUploader.genFileRef(file)) >= 0;
    return file.size > 0 && (isNew || isActive);
  }
  static isPreflighted(fileEl, file) {
    let preflightedRefs = fileEl.getAttribute(PHX_PREFLIGHTED_REFS).split(",");
    let isPreflighted = preflightedRefs.indexOf(LiveUploader.genFileRef(file)) >= 0;
    return isPreflighted && this.isActive(fileEl, file);
  }
  constructor(fileEl, file, view) {
    this.ref = LiveUploader.genFileRef(file);
    this.fileEl = fileEl;
    this.file = file;
    this.view = view;
    this.meta = null;
    this._isCancelled = false;
    this._isDone = false;
    this._progress = 0;
    this._lastProgressSent = -1;
    this._onDone = function() {
    };
    this._onElUpdated = this.onElUpdated.bind(this);
    this.fileEl.addEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
  }
  metadata() {
    return this.meta;
  }
  progress(progress) {
    this._progress = Math.floor(progress);
    if (this._progress > this._lastProgressSent) {
      if (this._progress >= 100) {
        this._progress = 100;
        this._lastProgressSent = 100;
        this._isDone = true;
        this.view.pushFileProgress(this.fileEl, this.ref, 100, () => {
          LiveUploader.untrackFile(this.fileEl, this.file);
          this._onDone();
        });
      } else {
        this._lastProgressSent = this._progress;
        this.view.pushFileProgress(this.fileEl, this.ref, this._progress);
      }
    }
  }
  cancel() {
    this._isCancelled = true;
    this._isDone = true;
    this._onDone();
  }
  isDone() {
    return this._isDone;
  }
  error(reason = "failed") {
    this.fileEl.removeEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
    this.view.pushFileProgress(this.fileEl, this.ref, { error: reason });
    LiveUploader.clearFiles(this.fileEl);
  }
  onDone(callback) {
    this._onDone = () => {
      this.fileEl.removeEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
      callback();
    };
  }
  onElUpdated() {
    let activeRefs = this.fileEl.getAttribute(PHX_ACTIVE_ENTRY_REFS).split(",");
    if (activeRefs.indexOf(this.ref) === -1) {
      this.cancel();
    }
  }
  toPreflightPayload() {
    return {
      last_modified: this.file.lastModified,
      name: this.file.name,
      relative_path: this.file.webkitRelativePath,
      size: this.file.size,
      type: this.file.type,
      ref: this.ref
    };
  }
  uploader(uploaders) {
    if (this.meta.uploader) {
      let callback = uploaders[this.meta.uploader] || logError(`no uploader configured for ${this.meta.uploader}`);
      return { name: this.meta.uploader, callback };
    } else {
      return { name: "channel", callback: channelUploader };
    }
  }
  zipPostFlight(resp) {
    this.meta = resp.entries[this.ref];
    if (!this.meta) {
      logError(`no preflight upload response returned with ref ${this.ref}`, { input: this.fileEl, response: resp });
    }
  }
};
var liveUploaderFileRef = 0;
var LiveUploader = class {
  static genFileRef(file) {
    let ref = file._phxRef;
    if (ref !== void 0) {
      return ref;
    } else {
      file._phxRef = (liveUploaderFileRef++).toString();
      return file._phxRef;
    }
  }
  static getEntryDataURL(inputEl, ref, callback) {
    let file = this.activeFiles(inputEl).find((file2) => this.genFileRef(file2) === ref);
    callback(URL.createObjectURL(file));
  }
  static hasUploadsInProgress(formEl) {
    let active = 0;
    dom_default.findUploadInputs(formEl).forEach((input) => {
      if (input.getAttribute(PHX_PREFLIGHTED_REFS) !== input.getAttribute(PHX_DONE_REFS)) {
        active++;
      }
    });
    return active > 0;
  }
  static serializeUploads(inputEl) {
    let files = this.activeFiles(inputEl);
    let fileData = {};
    files.forEach((file) => {
      let entry = { path: inputEl.name };
      let uploadRef = inputEl.getAttribute(PHX_UPLOAD_REF);
      fileData[uploadRef] = fileData[uploadRef] || [];
      entry.ref = this.genFileRef(file);
      entry.last_modified = file.lastModified;
      entry.name = file.name || entry.ref;
      entry.relative_path = file.webkitRelativePath;
      entry.type = file.type;
      entry.size = file.size;
      fileData[uploadRef].push(entry);
    });
    return fileData;
  }
  static clearFiles(inputEl) {
    inputEl.value = null;
    inputEl.removeAttribute(PHX_UPLOAD_REF);
    dom_default.putPrivate(inputEl, "files", []);
  }
  static untrackFile(inputEl, file) {
    dom_default.putPrivate(inputEl, "files", dom_default.private(inputEl, "files").filter((f) => !Object.is(f, file)));
  }
  static trackFiles(inputEl, files, dataTransfer) {
    if (inputEl.getAttribute("multiple") !== null) {
      let newFiles = files.filter((file) => !this.activeFiles(inputEl).find((f) => Object.is(f, file)));
      dom_default.putPrivate(inputEl, "files", this.activeFiles(inputEl).concat(newFiles));
      inputEl.value = null;
    } else {
      if (dataTransfer && dataTransfer.files.length > 0) {
        inputEl.files = dataTransfer.files;
      }
      dom_default.putPrivate(inputEl, "files", files);
    }
  }
  static activeFileInputs(formEl) {
    let fileInputs = dom_default.findUploadInputs(formEl);
    return Array.from(fileInputs).filter((el) => el.files && this.activeFiles(el).length > 0);
  }
  static activeFiles(input) {
    return (dom_default.private(input, "files") || []).filter((f) => UploadEntry.isActive(input, f));
  }
  static inputsAwaitingPreflight(formEl) {
    let fileInputs = dom_default.findUploadInputs(formEl);
    return Array.from(fileInputs).filter((input) => this.filesAwaitingPreflight(input).length > 0);
  }
  static filesAwaitingPreflight(input) {
    return this.activeFiles(input).filter((f) => !UploadEntry.isPreflighted(input, f));
  }
  constructor(inputEl, view, onComplete) {
    this.view = view;
    this.onComplete = onComplete;
    this._entries = Array.from(LiveUploader.filesAwaitingPreflight(inputEl) || []).map((file) => new UploadEntry(inputEl, file, view));
    this.numEntriesInProgress = this._entries.length;
  }
  entries() {
    return this._entries;
  }
  initAdapterUpload(resp, onError, liveSocket2) {
    this._entries = this._entries.map((entry) => {
      entry.zipPostFlight(resp);
      entry.onDone(() => {
        this.numEntriesInProgress--;
        if (this.numEntriesInProgress === 0) {
          this.onComplete();
        }
      });
      return entry;
    });
    let groupedEntries = this._entries.reduce((acc, entry) => {
      let { name, callback } = entry.uploader(liveSocket2.uploaders);
      acc[name] = acc[name] || { callback, entries: [] };
      acc[name].entries.push(entry);
      return acc;
    }, {});
    for (let name in groupedEntries) {
      let { callback, entries } = groupedEntries[name];
      callback(entries, onError, resp, liveSocket2);
    }
  }
};
var ARIA = {
  focusMain() {
    let target = document.querySelector("main h1, main, h1");
    if (target) {
      let origTabIndex = target.tabIndex;
      target.tabIndex = -1;
      target.focus();
      target.tabIndex = origTabIndex;
    }
  },
  anyOf(instance, classes) {
    return classes.find((name) => instance instanceof name);
  },
  isFocusable(el, interactiveOnly) {
    return el instanceof HTMLAnchorElement && el.rel !== "ignore" || el instanceof HTMLAreaElement && el.href !== void 0 || !el.disabled && this.anyOf(el, [HTMLInputElement, HTMLSelectElement, HTMLTextAreaElement, HTMLButtonElement]) || el instanceof HTMLIFrameElement || (el.tabIndex > 0 || !interactiveOnly && el.tabIndex === 0 && el.getAttribute("tabindex") !== null && el.getAttribute("aria-hidden") !== "true");
  },
  attemptFocus(el, interactiveOnly) {
    if (this.isFocusable(el, interactiveOnly)) {
      try {
        el.focus();
      } catch (e) {
      }
    }
    return !!document.activeElement && document.activeElement.isSameNode(el);
  },
  focusFirstInteractive(el) {
    let child = el.firstElementChild;
    while (child) {
      if (this.attemptFocus(child, true) || this.focusFirstInteractive(child, true)) {
        return true;
      }
      child = child.nextElementSibling;
    }
  },
  focusFirst(el) {
    let child = el.firstElementChild;
    while (child) {
      if (this.attemptFocus(child) || this.focusFirst(child)) {
        return true;
      }
      child = child.nextElementSibling;
    }
  },
  focusLast(el) {
    let child = el.lastElementChild;
    while (child) {
      if (this.attemptFocus(child) || this.focusLast(child)) {
        return true;
      }
      child = child.previousElementSibling;
    }
  }
};
var aria_default = ARIA;
var Hooks = {
  LiveFileUpload: {
    activeRefs() {
      return this.el.getAttribute(PHX_ACTIVE_ENTRY_REFS);
    },
    preflightedRefs() {
      return this.el.getAttribute(PHX_PREFLIGHTED_REFS);
    },
    mounted() {
      this.preflightedWas = this.preflightedRefs();
    },
    updated() {
      let newPreflights = this.preflightedRefs();
      if (this.preflightedWas !== newPreflights) {
        this.preflightedWas = newPreflights;
        if (newPreflights === "") {
          this.__view.cancelSubmit(this.el.form);
        }
      }
      if (this.activeRefs() === "") {
        this.el.value = null;
      }
      this.el.dispatchEvent(new CustomEvent(PHX_LIVE_FILE_UPDATED));
    }
  },
  LiveImgPreview: {
    mounted() {
      this.ref = this.el.getAttribute("data-phx-entry-ref");
      this.inputEl = document.getElementById(this.el.getAttribute(PHX_UPLOAD_REF));
      LiveUploader.getEntryDataURL(this.inputEl, this.ref, (url) => {
        this.url = url;
        this.el.src = url;
      });
    },
    destroyed() {
      URL.revokeObjectURL(this.url);
    }
  },
  FocusWrap: {
    mounted() {
      this.focusStart = this.el.firstElementChild;
      this.focusEnd = this.el.lastElementChild;
      this.focusStart.addEventListener("focus", () => aria_default.focusLast(this.el));
      this.focusEnd.addEventListener("focus", () => aria_default.focusFirst(this.el));
      this.el.addEventListener("phx:show-end", () => this.el.focus());
      if (window.getComputedStyle(this.el).display !== "none") {
        aria_default.focusFirst(this.el);
      }
    }
  }
};
var hooks_default = Hooks;
var DOMPostMorphRestorer = class {
  constructor(containerBefore, containerAfter, updateType) {
    let idsBefore = /* @__PURE__ */ new Set();
    let idsAfter = new Set([...containerAfter.children].map((child) => child.id));
    let elementsToModify = [];
    Array.from(containerBefore.children).forEach((child) => {
      if (child.id) {
        idsBefore.add(child.id);
        if (idsAfter.has(child.id)) {
          let previousElementId = child.previousElementSibling && child.previousElementSibling.id;
          elementsToModify.push({ elementId: child.id, previousElementId });
        }
      }
    });
    this.containerId = containerAfter.id;
    this.updateType = updateType;
    this.elementsToModify = elementsToModify;
    this.elementIdsToAdd = [...idsAfter].filter((id) => !idsBefore.has(id));
  }
  perform() {
    let container = dom_default.byId(this.containerId);
    this.elementsToModify.forEach((elementToModify) => {
      if (elementToModify.previousElementId) {
        maybe(document.getElementById(elementToModify.previousElementId), (previousElem) => {
          maybe(document.getElementById(elementToModify.elementId), (elem) => {
            let isInRightPlace = elem.previousElementSibling && elem.previousElementSibling.id == previousElem.id;
            if (!isInRightPlace) {
              previousElem.insertAdjacentElement("afterend", elem);
            }
          });
        });
      } else {
        maybe(document.getElementById(elementToModify.elementId), (elem) => {
          let isInRightPlace = elem.previousElementSibling == null;
          if (!isInRightPlace) {
            container.insertAdjacentElement("afterbegin", elem);
          }
        });
      }
    });
    if (this.updateType == "prepend") {
      this.elementIdsToAdd.reverse().forEach((elemId) => {
        maybe(document.getElementById(elemId), (elem) => container.insertAdjacentElement("afterbegin", elem));
      });
    }
  }
};
var DOCUMENT_FRAGMENT_NODE = 11;
function morphAttrs(fromNode, toNode) {
  var toNodeAttrs = toNode.attributes;
  var attr;
  var attrName;
  var attrNamespaceURI;
  var attrValue;
  var fromValue;
  if (toNode.nodeType === DOCUMENT_FRAGMENT_NODE || fromNode.nodeType === DOCUMENT_FRAGMENT_NODE) {
    return;
  }
  for (var i = toNodeAttrs.length - 1; i >= 0; i--) {
    attr = toNodeAttrs[i];
    attrName = attr.name;
    attrNamespaceURI = attr.namespaceURI;
    attrValue = attr.value;
    if (attrNamespaceURI) {
      attrName = attr.localName || attrName;
      fromValue = fromNode.getAttributeNS(attrNamespaceURI, attrName);
      if (fromValue !== attrValue) {
        if (attr.prefix === "xmlns") {
          attrName = attr.name;
        }
        fromNode.setAttributeNS(attrNamespaceURI, attrName, attrValue);
      }
    } else {
      fromValue = fromNode.getAttribute(attrName);
      if (fromValue !== attrValue) {
        fromNode.setAttribute(attrName, attrValue);
      }
    }
  }
  var fromNodeAttrs = fromNode.attributes;
  for (var d = fromNodeAttrs.length - 1; d >= 0; d--) {
    attr = fromNodeAttrs[d];
    attrName = attr.name;
    attrNamespaceURI = attr.namespaceURI;
    if (attrNamespaceURI) {
      attrName = attr.localName || attrName;
      if (!toNode.hasAttributeNS(attrNamespaceURI, attrName)) {
        fromNode.removeAttributeNS(attrNamespaceURI, attrName);
      }
    } else {
      if (!toNode.hasAttribute(attrName)) {
        fromNode.removeAttribute(attrName);
      }
    }
  }
}
var range;
var NS_XHTML = "http://www.w3.org/1999/xhtml";
var doc = typeof document === "undefined" ? void 0 : document;
var HAS_TEMPLATE_SUPPORT = !!doc && "content" in doc.createElement("template");
var HAS_RANGE_SUPPORT = !!doc && doc.createRange && "createContextualFragment" in doc.createRange();
function createFragmentFromTemplate(str) {
  var template = doc.createElement("template");
  template.innerHTML = str;
  return template.content.childNodes[0];
}
function createFragmentFromRange(str) {
  if (!range) {
    range = doc.createRange();
    range.selectNode(doc.body);
  }
  var fragment = range.createContextualFragment(str);
  return fragment.childNodes[0];
}
function createFragmentFromWrap(str) {
  var fragment = doc.createElement("body");
  fragment.innerHTML = str;
  return fragment.childNodes[0];
}
function toElement(str) {
  str = str.trim();
  if (HAS_TEMPLATE_SUPPORT) {
    return createFragmentFromTemplate(str);
  } else if (HAS_RANGE_SUPPORT) {
    return createFragmentFromRange(str);
  }
  return createFragmentFromWrap(str);
}
function compareNodeNames(fromEl, toEl) {
  var fromNodeName = fromEl.nodeName;
  var toNodeName = toEl.nodeName;
  var fromCodeStart, toCodeStart;
  if (fromNodeName === toNodeName) {
    return true;
  }
  fromCodeStart = fromNodeName.charCodeAt(0);
  toCodeStart = toNodeName.charCodeAt(0);
  if (fromCodeStart <= 90 && toCodeStart >= 97) {
    return fromNodeName === toNodeName.toUpperCase();
  } else if (toCodeStart <= 90 && fromCodeStart >= 97) {
    return toNodeName === fromNodeName.toUpperCase();
  } else {
    return false;
  }
}
function createElementNS(name, namespaceURI) {
  return !namespaceURI || namespaceURI === NS_XHTML ? doc.createElement(name) : doc.createElementNS(namespaceURI, name);
}
function moveChildren(fromEl, toEl) {
  var curChild = fromEl.firstChild;
  while (curChild) {
    var nextChild = curChild.nextSibling;
    toEl.appendChild(curChild);
    curChild = nextChild;
  }
  return toEl;
}
function syncBooleanAttrProp(fromEl, toEl, name) {
  if (fromEl[name] !== toEl[name]) {
    fromEl[name] = toEl[name];
    if (fromEl[name]) {
      fromEl.setAttribute(name, "");
    } else {
      fromEl.removeAttribute(name);
    }
  }
}
var specialElHandlers = {
  OPTION: function(fromEl, toEl) {
    var parentNode = fromEl.parentNode;
    if (parentNode) {
      var parentName = parentNode.nodeName.toUpperCase();
      if (parentName === "OPTGROUP") {
        parentNode = parentNode.parentNode;
        parentName = parentNode && parentNode.nodeName.toUpperCase();
      }
      if (parentName === "SELECT" && !parentNode.hasAttribute("multiple")) {
        if (fromEl.hasAttribute("selected") && !toEl.selected) {
          fromEl.setAttribute("selected", "selected");
          fromEl.removeAttribute("selected");
        }
        parentNode.selectedIndex = -1;
      }
    }
    syncBooleanAttrProp(fromEl, toEl, "selected");
  },
  INPUT: function(fromEl, toEl) {
    syncBooleanAttrProp(fromEl, toEl, "checked");
    syncBooleanAttrProp(fromEl, toEl, "disabled");
    if (fromEl.value !== toEl.value) {
      fromEl.value = toEl.value;
    }
    if (!toEl.hasAttribute("value")) {
      fromEl.removeAttribute("value");
    }
  },
  TEXTAREA: function(fromEl, toEl) {
    var newValue = toEl.value;
    if (fromEl.value !== newValue) {
      fromEl.value = newValue;
    }
    var firstChild = fromEl.firstChild;
    if (firstChild) {
      var oldValue = firstChild.nodeValue;
      if (oldValue == newValue || !newValue && oldValue == fromEl.placeholder) {
        return;
      }
      firstChild.nodeValue = newValue;
    }
  },
  SELECT: function(fromEl, toEl) {
    if (!toEl.hasAttribute("multiple")) {
      var selectedIndex = -1;
      var i = 0;
      var curChild = fromEl.firstChild;
      var optgroup;
      var nodeName;
      while (curChild) {
        nodeName = curChild.nodeName && curChild.nodeName.toUpperCase();
        if (nodeName === "OPTGROUP") {
          optgroup = curChild;
          curChild = optgroup.firstChild;
        } else {
          if (nodeName === "OPTION") {
            if (curChild.hasAttribute("selected")) {
              selectedIndex = i;
              break;
            }
            i++;
          }
          curChild = curChild.nextSibling;
          if (!curChild && optgroup) {
            curChild = optgroup.nextSibling;
            optgroup = null;
          }
        }
      }
      fromEl.selectedIndex = selectedIndex;
    }
  }
};
var ELEMENT_NODE = 1;
var DOCUMENT_FRAGMENT_NODE$1 = 11;
var TEXT_NODE = 3;
var COMMENT_NODE = 8;
function noop() {
}
function defaultGetNodeKey(node) {
  if (node) {
    return node.getAttribute && node.getAttribute("id") || node.id;
  }
}
function morphdomFactory(morphAttrs2) {
  return function morphdom2(fromNode, toNode, options) {
    if (!options) {
      options = {};
    }
    if (typeof toNode === "string") {
      if (fromNode.nodeName === "#document" || fromNode.nodeName === "HTML" || fromNode.nodeName === "BODY") {
        var toNodeHtml = toNode;
        toNode = doc.createElement("html");
        toNode.innerHTML = toNodeHtml;
      } else {
        toNode = toElement(toNode);
      }
    } else if (toNode.nodeType === DOCUMENT_FRAGMENT_NODE$1) {
      toNode = toNode.firstElementChild;
    }
    var getNodeKey = options.getNodeKey || defaultGetNodeKey;
    var onBeforeNodeAdded = options.onBeforeNodeAdded || noop;
    var onNodeAdded = options.onNodeAdded || noop;
    var onBeforeElUpdated = options.onBeforeElUpdated || noop;
    var onElUpdated = options.onElUpdated || noop;
    var onBeforeNodeDiscarded = options.onBeforeNodeDiscarded || noop;
    var onNodeDiscarded = options.onNodeDiscarded || noop;
    var onBeforeElChildrenUpdated = options.onBeforeElChildrenUpdated || noop;
    var skipFromChildren = options.skipFromChildren || noop;
    var addChild = options.addChild || function(parent, child) {
      return parent.appendChild(child);
    };
    var childrenOnly = options.childrenOnly === true;
    var fromNodesLookup = /* @__PURE__ */ Object.create(null);
    var keyedRemovalList = [];
    function addKeyedRemoval(key) {
      keyedRemovalList.push(key);
    }
    function walkDiscardedChildNodes(node, skipKeyedNodes) {
      if (node.nodeType === ELEMENT_NODE) {
        var curChild = node.firstChild;
        while (curChild) {
          var key = void 0;
          if (skipKeyedNodes && (key = getNodeKey(curChild))) {
            addKeyedRemoval(key);
          } else {
            onNodeDiscarded(curChild);
            if (curChild.firstChild) {
              walkDiscardedChildNodes(curChild, skipKeyedNodes);
            }
          }
          curChild = curChild.nextSibling;
        }
      }
    }
    function removeNode(node, parentNode, skipKeyedNodes) {
      if (onBeforeNodeDiscarded(node) === false) {
        return;
      }
      if (parentNode) {
        parentNode.removeChild(node);
      }
      onNodeDiscarded(node);
      walkDiscardedChildNodes(node, skipKeyedNodes);
    }
    function indexTree(node) {
      if (node.nodeType === ELEMENT_NODE || node.nodeType === DOCUMENT_FRAGMENT_NODE$1) {
        var curChild = node.firstChild;
        while (curChild) {
          var key = getNodeKey(curChild);
          if (key) {
            fromNodesLookup[key] = curChild;
          }
          indexTree(curChild);
          curChild = curChild.nextSibling;
        }
      }
    }
    indexTree(fromNode);
    function handleNodeAdded(el) {
      onNodeAdded(el);
      var curChild = el.firstChild;
      while (curChild) {
        var nextSibling = curChild.nextSibling;
        var key = getNodeKey(curChild);
        if (key) {
          var unmatchedFromEl = fromNodesLookup[key];
          if (unmatchedFromEl && compareNodeNames(curChild, unmatchedFromEl)) {
            curChild.parentNode.replaceChild(unmatchedFromEl, curChild);
            morphEl(unmatchedFromEl, curChild);
          } else {
            handleNodeAdded(curChild);
          }
        } else {
          handleNodeAdded(curChild);
        }
        curChild = nextSibling;
      }
    }
    function cleanupFromEl(fromEl, curFromNodeChild, curFromNodeKey) {
      while (curFromNodeChild) {
        var fromNextSibling = curFromNodeChild.nextSibling;
        if (curFromNodeKey = getNodeKey(curFromNodeChild)) {
          addKeyedRemoval(curFromNodeKey);
        } else {
          removeNode(curFromNodeChild, fromEl, true);
        }
        curFromNodeChild = fromNextSibling;
      }
    }
    function morphEl(fromEl, toEl, childrenOnly2) {
      var toElKey = getNodeKey(toEl);
      if (toElKey) {
        delete fromNodesLookup[toElKey];
      }
      if (!childrenOnly2) {
        if (onBeforeElUpdated(fromEl, toEl) === false) {
          return;
        }
        morphAttrs2(fromEl, toEl);
        onElUpdated(fromEl);
        if (onBeforeElChildrenUpdated(fromEl, toEl) === false) {
          return;
        }
      }
      if (fromEl.nodeName !== "TEXTAREA") {
        morphChildren(fromEl, toEl);
      } else {
        specialElHandlers.TEXTAREA(fromEl, toEl);
      }
    }
    function morphChildren(fromEl, toEl) {
      var skipFrom = skipFromChildren(fromEl);
      var curToNodeChild = toEl.firstChild;
      var curFromNodeChild = fromEl.firstChild;
      var curToNodeKey;
      var curFromNodeKey;
      var fromNextSibling;
      var toNextSibling;
      var matchingFromEl;
      outer:
        while (curToNodeChild) {
          toNextSibling = curToNodeChild.nextSibling;
          curToNodeKey = getNodeKey(curToNodeChild);
          while (!skipFrom && curFromNodeChild) {
            fromNextSibling = curFromNodeChild.nextSibling;
            if (curToNodeChild.isSameNode && curToNodeChild.isSameNode(curFromNodeChild)) {
              curToNodeChild = toNextSibling;
              curFromNodeChild = fromNextSibling;
              continue outer;
            }
            curFromNodeKey = getNodeKey(curFromNodeChild);
            var curFromNodeType = curFromNodeChild.nodeType;
            var isCompatible = void 0;
            if (curFromNodeType === curToNodeChild.nodeType) {
              if (curFromNodeType === ELEMENT_NODE) {
                if (curToNodeKey) {
                  if (curToNodeKey !== curFromNodeKey) {
                    if (matchingFromEl = fromNodesLookup[curToNodeKey]) {
                      if (fromNextSibling === matchingFromEl) {
                        isCompatible = false;
                      } else {
                        fromEl.insertBefore(matchingFromEl, curFromNodeChild);
                        if (curFromNodeKey) {
                          addKeyedRemoval(curFromNodeKey);
                        } else {
                          removeNode(curFromNodeChild, fromEl, true);
                        }
                        curFromNodeChild = matchingFromEl;
                      }
                    } else {
                      isCompatible = false;
                    }
                  }
                } else if (curFromNodeKey) {
                  isCompatible = false;
                }
                isCompatible = isCompatible !== false && compareNodeNames(curFromNodeChild, curToNodeChild);
                if (isCompatible) {
                  morphEl(curFromNodeChild, curToNodeChild);
                }
              } else if (curFromNodeType === TEXT_NODE || curFromNodeType == COMMENT_NODE) {
                isCompatible = true;
                if (curFromNodeChild.nodeValue !== curToNodeChild.nodeValue) {
                  curFromNodeChild.nodeValue = curToNodeChild.nodeValue;
                }
              }
            }
            if (isCompatible) {
              curToNodeChild = toNextSibling;
              curFromNodeChild = fromNextSibling;
              continue outer;
            }
            if (curFromNodeKey) {
              addKeyedRemoval(curFromNodeKey);
            } else {
              removeNode(curFromNodeChild, fromEl, true);
            }
            curFromNodeChild = fromNextSibling;
          }
          if (curToNodeKey && (matchingFromEl = fromNodesLookup[curToNodeKey]) && compareNodeNames(matchingFromEl, curToNodeChild)) {
            if (!skipFrom) {
              addChild(fromEl, matchingFromEl);
            }
            morphEl(matchingFromEl, curToNodeChild);
          } else {
            var onBeforeNodeAddedResult = onBeforeNodeAdded(curToNodeChild);
            if (onBeforeNodeAddedResult !== false) {
              if (onBeforeNodeAddedResult) {
                curToNodeChild = onBeforeNodeAddedResult;
              }
              if (curToNodeChild.actualize) {
                curToNodeChild = curToNodeChild.actualize(fromEl.ownerDocument || doc);
              }
              addChild(fromEl, curToNodeChild);
              handleNodeAdded(curToNodeChild);
            }
          }
          curToNodeChild = toNextSibling;
          curFromNodeChild = fromNextSibling;
        }
      cleanupFromEl(fromEl, curFromNodeChild, curFromNodeKey);
      var specialElHandler = specialElHandlers[fromEl.nodeName];
      if (specialElHandler) {
        specialElHandler(fromEl, toEl);
      }
    }
    var morphedNode = fromNode;
    var morphedNodeType = morphedNode.nodeType;
    var toNodeType = toNode.nodeType;
    if (!childrenOnly) {
      if (morphedNodeType === ELEMENT_NODE) {
        if (toNodeType === ELEMENT_NODE) {
          if (!compareNodeNames(fromNode, toNode)) {
            onNodeDiscarded(fromNode);
            morphedNode = moveChildren(fromNode, createElementNS(toNode.nodeName, toNode.namespaceURI));
          }
        } else {
          morphedNode = toNode;
        }
      } else if (morphedNodeType === TEXT_NODE || morphedNodeType === COMMENT_NODE) {
        if (toNodeType === morphedNodeType) {
          if (morphedNode.nodeValue !== toNode.nodeValue) {
            morphedNode.nodeValue = toNode.nodeValue;
          }
          return morphedNode;
        } else {
          morphedNode = toNode;
        }
      }
    }
    if (morphedNode === toNode) {
      onNodeDiscarded(fromNode);
    } else {
      if (toNode.isSameNode && toNode.isSameNode(morphedNode)) {
        return;
      }
      morphEl(morphedNode, toNode, childrenOnly);
      if (keyedRemovalList) {
        for (var i = 0, len = keyedRemovalList.length; i < len; i++) {
          var elToRemove = fromNodesLookup[keyedRemovalList[i]];
          if (elToRemove) {
            removeNode(elToRemove, elToRemove.parentNode, false);
          }
        }
      }
    }
    if (!childrenOnly && morphedNode !== fromNode && fromNode.parentNode) {
      if (morphedNode.actualize) {
        morphedNode = morphedNode.actualize(fromNode.ownerDocument || doc);
      }
      fromNode.parentNode.replaceChild(morphedNode, fromNode);
    }
    return morphedNode;
  };
}
var morphdom = morphdomFactory(morphAttrs);
var morphdom_esm_default = morphdom;
var DOMPatch = class {
  static patchEl(fromEl, toEl, activeElement) {
    morphdom_esm_default(fromEl, toEl, {
      childrenOnly: false,
      onBeforeElUpdated: (fromEl2, toEl2) => {
        if (activeElement && activeElement.isSameNode(fromEl2) && dom_default.isFormInput(fromEl2)) {
          dom_default.mergeFocusedInput(fromEl2, toEl2);
          return false;
        }
      }
    });
  }
  constructor(view, container, id, html, streams, targetCID) {
    this.view = view;
    this.liveSocket = view.liveSocket;
    this.container = container;
    this.id = id;
    this.rootID = view.root.id;
    this.html = html;
    this.streams = streams;
    this.streamInserts = {};
    this.targetCID = targetCID;
    this.cidPatch = isCid(this.targetCID);
    this.pendingRemoves = [];
    this.phxRemove = this.liveSocket.binding("remove");
    this.callbacks = {
      beforeadded: [],
      beforeupdated: [],
      beforephxChildAdded: [],
      afteradded: [],
      afterupdated: [],
      afterdiscarded: [],
      afterphxChildAdded: [],
      aftertransitionsDiscarded: []
    };
  }
  before(kind, callback) {
    this.callbacks[`before${kind}`].push(callback);
  }
  after(kind, callback) {
    this.callbacks[`after${kind}`].push(callback);
  }
  trackBefore(kind, ...args) {
    this.callbacks[`before${kind}`].forEach((callback) => callback(...args));
  }
  trackAfter(kind, ...args) {
    this.callbacks[`after${kind}`].forEach((callback) => callback(...args));
  }
  markPrunableContentForRemoval() {
    let phxUpdate = this.liveSocket.binding(PHX_UPDATE);
    dom_default.all(this.container, `[${phxUpdate}=${PHX_STREAM}]`, (el) => el.innerHTML = "");
    dom_default.all(this.container, `[${phxUpdate}=append] > *, [${phxUpdate}=prepend] > *`, (el) => {
      el.setAttribute(PHX_PRUNE, "");
    });
  }
  perform() {
    let { view, liveSocket: liveSocket2, container, html } = this;
    let targetContainer = this.isCIDPatch() ? this.targetCIDContainer(html) : container;
    if (this.isCIDPatch() && !targetContainer) {
      return;
    }
    let focused = liveSocket2.getActiveElement();
    let { selectionStart, selectionEnd } = focused && dom_default.hasSelectionRange(focused) ? focused : {};
    let phxUpdate = liveSocket2.binding(PHX_UPDATE);
    let phxFeedbackFor = liveSocket2.binding(PHX_FEEDBACK_FOR);
    let disableWith = liveSocket2.binding(PHX_DISABLE_WITH);
    let phxTriggerExternal = liveSocket2.binding(PHX_TRIGGER_ACTION);
    let added = [];
    let updates = [];
    let appendPrependUpdates = [];
    let externalFormTriggered = null;
    let diffHTML = liveSocket2.time("premorph container prep", () => {
      return this.buildDiffHTML(container, html, phxUpdate, targetContainer);
    });
    this.trackBefore("added", container);
    this.trackBefore("updated", container, container);
    liveSocket2.time("morphdom", () => {
      this.streams.forEach(([inserts, deleteIds]) => {
        this.streamInserts = Object.assign(this.streamInserts, inserts);
        deleteIds.forEach((id) => {
          let child = container.querySelector(`[id="${id}"]`);
          if (child) {
            if (!this.maybePendingRemove(child)) {
              child.remove();
              this.onNodeDiscarded(child);
            }
          }
        });
      });
      morphdom_esm_default(targetContainer, diffHTML, {
        childrenOnly: targetContainer.getAttribute(PHX_COMPONENT) === null,
        getNodeKey: (node) => {
          return dom_default.isPhxDestroyed(node) ? null : node.id;
        },
        skipFromChildren: (from) => {
          return from.getAttribute(phxUpdate) === PHX_STREAM;
        },
        addChild: (parent, child) => {
          let streamAt = child.id ? this.streamInserts[child.id] : void 0;
          if (streamAt === void 0) {
            return parent.appendChild(child);
          }
          if (streamAt === 0) {
            parent.insertAdjacentElement("afterbegin", child);
          } else if (streamAt === -1) {
            parent.appendChild(child);
          } else if (streamAt > 0) {
            let sibling = Array.from(parent.children)[streamAt];
            parent.insertBefore(child, sibling);
          }
        },
        onBeforeNodeAdded: (el) => {
          this.trackBefore("added", el);
          return el;
        },
        onNodeAdded: (el) => {
          if (el instanceof HTMLImageElement && el.srcset) {
            el.srcset = el.srcset;
          } else if (el instanceof HTMLVideoElement && el.autoplay) {
            el.play();
          }
          if (dom_default.isNowTriggerFormExternal(el, phxTriggerExternal)) {
            externalFormTriggered = el;
          }
          dom_default.discardError(targetContainer, el, phxFeedbackFor);
          if (dom_default.isPhxChild(el) && view.ownsElement(el) || dom_default.isPhxSticky(el) && view.ownsElement(el.parentNode)) {
            this.trackAfter("phxChildAdded", el);
          }
          added.push(el);
        },
        onNodeDiscarded: (el) => this.onNodeDiscarded(el),
        onBeforeNodeDiscarded: (el) => {
          if (el.getAttribute && el.getAttribute(PHX_PRUNE) !== null) {
            return true;
          }
          if (el.parentElement !== null && el.id && dom_default.isPhxUpdate(el.parentElement, phxUpdate, [PHX_STREAM, "append", "prepend"])) {
            return false;
          }
          if (this.maybePendingRemove(el)) {
            return false;
          }
          if (this.skipCIDSibling(el)) {
            return false;
          }
          return true;
        },
        onElUpdated: (el) => {
          if (dom_default.isNowTriggerFormExternal(el, phxTriggerExternal)) {
            externalFormTriggered = el;
          }
          updates.push(el);
          this.maybeReOrderStream(el);
        },
        onBeforeElUpdated: (fromEl, toEl) => {
          dom_default.cleanChildNodes(toEl, phxUpdate);
          if (this.skipCIDSibling(toEl)) {
            return false;
          }
          if (dom_default.isPhxSticky(fromEl)) {
            return false;
          }
          if (dom_default.isIgnored(fromEl, phxUpdate) || fromEl.form && fromEl.form.isSameNode(externalFormTriggered)) {
            this.trackBefore("updated", fromEl, toEl);
            dom_default.mergeAttrs(fromEl, toEl, { isIgnored: true });
            updates.push(fromEl);
            dom_default.applyStickyOperations(fromEl);
            return false;
          }
          if (fromEl.type === "number" && (fromEl.validity && fromEl.validity.badInput)) {
            return false;
          }
          if (!dom_default.syncPendingRef(fromEl, toEl, disableWith)) {
            if (dom_default.isUploadInput(fromEl)) {
              this.trackBefore("updated", fromEl, toEl);
              updates.push(fromEl);
            }
            dom_default.applyStickyOperations(fromEl);
            return false;
          }
          if (dom_default.isPhxChild(toEl)) {
            let prevSession = fromEl.getAttribute(PHX_SESSION);
            dom_default.mergeAttrs(fromEl, toEl, { exclude: [PHX_STATIC] });
            if (prevSession !== "") {
              fromEl.setAttribute(PHX_SESSION, prevSession);
            }
            fromEl.setAttribute(PHX_ROOT_ID, this.rootID);
            dom_default.applyStickyOperations(fromEl);
            return false;
          }
          dom_default.copyPrivates(toEl, fromEl);
          dom_default.discardError(targetContainer, toEl, phxFeedbackFor);
          let isFocusedFormEl = focused && fromEl.isSameNode(focused) && dom_default.isFormInput(fromEl);
          if (isFocusedFormEl && fromEl.type !== "hidden") {
            this.trackBefore("updated", fromEl, toEl);
            dom_default.mergeFocusedInput(fromEl, toEl);
            dom_default.syncAttrsToProps(fromEl);
            updates.push(fromEl);
            dom_default.applyStickyOperations(fromEl);
            return false;
          } else {
            if (dom_default.isPhxUpdate(toEl, phxUpdate, ["append", "prepend"])) {
              appendPrependUpdates.push(new DOMPostMorphRestorer(fromEl, toEl, toEl.getAttribute(phxUpdate)));
            }
            dom_default.syncAttrsToProps(toEl);
            dom_default.applyStickyOperations(toEl);
            this.trackBefore("updated", fromEl, toEl);
            return true;
          }
        }
      });
    });
    if (liveSocket2.isDebugEnabled()) {
      detectDuplicateIds();
    }
    if (appendPrependUpdates.length > 0) {
      liveSocket2.time("post-morph append/prepend restoration", () => {
        appendPrependUpdates.forEach((update) => update.perform());
      });
    }
    liveSocket2.silenceEvents(() => dom_default.restoreFocus(focused, selectionStart, selectionEnd));
    dom_default.dispatchEvent(document, "phx:update");
    added.forEach((el) => this.trackAfter("added", el));
    updates.forEach((el) => this.trackAfter("updated", el));
    this.transitionPendingRemoves();
    if (externalFormTriggered) {
      liveSocket2.unload();
      externalFormTriggered.submit();
    }
    return true;
  }
  onNodeDiscarded(el) {
    if (dom_default.isPhxChild(el) || dom_default.isPhxSticky(el)) {
      this.liveSocket.destroyViewByEl(el);
    }
    this.trackAfter("discarded", el);
  }
  maybePendingRemove(node) {
    if (node.getAttribute && node.getAttribute(this.phxRemove) !== null) {
      this.pendingRemoves.push(node);
      return true;
    } else {
      return false;
    }
  }
  maybeReOrderStream(el) {
    let streamAt = el.id ? this.streamInserts[el.id] : void 0;
    if (streamAt === void 0) {
      return;
    }
    if (streamAt === 0) {
      el.parentElement.insertBefore(el, el.parentElement.firstElementChild);
    } else if (streamAt > 0) {
      let children = Array.from(el.parentElement.children);
      let oldIndex = children.indexOf(el);
      if (streamAt >= children.length - 1) {
        el.parentElement.appendChild(el);
      } else {
        let sibling = children[streamAt];
        if (oldIndex > streamAt) {
          el.parentElement.insertBefore(el, sibling);
        } else {
          el.parentElement.insertBefore(el, sibling.nextElementSibling);
        }
      }
    }
  }
  transitionPendingRemoves() {
    let { pendingRemoves, liveSocket: liveSocket2 } = this;
    if (pendingRemoves.length > 0) {
      liveSocket2.transitionRemoves(pendingRemoves);
      liveSocket2.requestDOMUpdate(() => {
        pendingRemoves.forEach((el) => {
          let child = dom_default.firstPhxChild(el);
          if (child) {
            liveSocket2.destroyViewByEl(child);
          }
          el.remove();
        });
        this.trackAfter("transitionsDiscarded", pendingRemoves);
      });
    }
  }
  isCIDPatch() {
    return this.cidPatch;
  }
  skipCIDSibling(el) {
    return el.nodeType === Node.ELEMENT_NODE && el.getAttribute(PHX_SKIP) !== null;
  }
  targetCIDContainer(html) {
    if (!this.isCIDPatch()) {
      return;
    }
    let [first, ...rest] = dom_default.findComponentNodeList(this.container, this.targetCID);
    if (rest.length === 0 && dom_default.childNodeLength(html) === 1) {
      return first;
    } else {
      return first && first.parentNode;
    }
  }
  buildDiffHTML(container, html, phxUpdate, targetContainer) {
    let isCIDPatch = this.isCIDPatch();
    let isCIDWithSingleRoot = isCIDPatch && targetContainer.getAttribute(PHX_COMPONENT) === this.targetCID.toString();
    if (!isCIDPatch || isCIDWithSingleRoot) {
      return html;
    } else {
      let diffContainer = null;
      let template = document.createElement("template");
      diffContainer = dom_default.cloneNode(targetContainer);
      let [firstComponent, ...rest] = dom_default.findComponentNodeList(diffContainer, this.targetCID);
      template.innerHTML = html;
      rest.forEach((el) => el.remove());
      Array.from(diffContainer.childNodes).forEach((child) => {
        if (child.id && child.nodeType === Node.ELEMENT_NODE && child.getAttribute(PHX_COMPONENT) !== this.targetCID.toString()) {
          child.setAttribute(PHX_SKIP, "");
          child.innerHTML = "";
        }
      });
      Array.from(template.content.childNodes).forEach((el) => diffContainer.insertBefore(el, firstComponent));
      firstComponent.remove();
      return diffContainer.outerHTML;
    }
  }
  indexOf(parent, child) {
    return Array.from(parent.children).indexOf(child);
  }
};
var Rendered = class {
  static extract(diff) {
    let { [REPLY]: reply, [EVENTS]: events, [TITLE]: title } = diff;
    delete diff[REPLY];
    delete diff[EVENTS];
    delete diff[TITLE];
    return { diff, title, reply: reply || null, events: events || [] };
  }
  constructor(viewId, rendered) {
    this.viewId = viewId;
    this.rendered = {};
    this.mergeDiff(rendered);
  }
  parentViewId() {
    return this.viewId;
  }
  toString(onlyCids) {
    let [str, streams] = this.recursiveToString(this.rendered, this.rendered[COMPONENTS], onlyCids);
    return [str, streams];
  }
  recursiveToString(rendered, components = rendered[COMPONENTS], onlyCids) {
    onlyCids = onlyCids ? new Set(onlyCids) : null;
    let output = { buffer: "", components, onlyCids, streams: /* @__PURE__ */ new Set() };
    this.toOutputBuffer(rendered, null, output);
    return [output.buffer, output.streams];
  }
  componentCIDs(diff) {
    return Object.keys(diff[COMPONENTS] || {}).map((i) => parseInt(i));
  }
  isComponentOnlyDiff(diff) {
    if (!diff[COMPONENTS]) {
      return false;
    }
    return Object.keys(diff).length === 1;
  }
  getComponent(diff, cid) {
    return diff[COMPONENTS][cid];
  }
  mergeDiff(diff) {
    let newc = diff[COMPONENTS];
    let cache = {};
    delete diff[COMPONENTS];
    this.rendered = this.mutableMerge(this.rendered, diff);
    this.rendered[COMPONENTS] = this.rendered[COMPONENTS] || {};
    if (newc) {
      let oldc = this.rendered[COMPONENTS];
      for (let cid in newc) {
        newc[cid] = this.cachedFindComponent(cid, newc[cid], oldc, newc, cache);
      }
      for (let cid in newc) {
        oldc[cid] = newc[cid];
      }
      diff[COMPONENTS] = newc;
    }
  }
  cachedFindComponent(cid, cdiff, oldc, newc, cache) {
    if (cache[cid]) {
      return cache[cid];
    } else {
      let ndiff, stat, scid = cdiff[STATIC];
      if (isCid(scid)) {
        let tdiff;
        if (scid > 0) {
          tdiff = this.cachedFindComponent(scid, newc[scid], oldc, newc, cache);
        } else {
          tdiff = oldc[-scid];
        }
        stat = tdiff[STATIC];
        ndiff = this.cloneMerge(tdiff, cdiff);
        ndiff[STATIC] = stat;
      } else {
        ndiff = cdiff[STATIC] !== void 0 ? cdiff : this.cloneMerge(oldc[cid] || {}, cdiff);
      }
      cache[cid] = ndiff;
      return ndiff;
    }
  }
  mutableMerge(target, source) {
    if (source[STATIC] !== void 0) {
      return source;
    } else {
      this.doMutableMerge(target, source);
      return target;
    }
  }
  doMutableMerge(target, source) {
    for (let key in source) {
      let val = source[key];
      let targetVal = target[key];
      let isObjVal = isObject(val);
      if (isObjVal && val[STATIC] === void 0 && isObject(targetVal)) {
        this.doMutableMerge(targetVal, val);
      } else {
        target[key] = val;
      }
    }
  }
  cloneMerge(target, source) {
    let merged = { ...target, ...source };
    for (let key in merged) {
      let val = source[key];
      let targetVal = target[key];
      if (isObject(val) && val[STATIC] === void 0 && isObject(targetVal)) {
        merged[key] = this.cloneMerge(targetVal, val);
      }
    }
    return merged;
  }
  componentToString(cid) {
    let [str, streams] = this.recursiveCIDToString(this.rendered[COMPONENTS], cid);
    return [str, streams];
  }
  pruneCIDs(cids) {
    cids.forEach((cid) => delete this.rendered[COMPONENTS][cid]);
  }
  get() {
    return this.rendered;
  }
  isNewFingerprint(diff = {}) {
    return !!diff[STATIC];
  }
  templateStatic(part, templates) {
    if (typeof part === "number") {
      return templates[part];
    } else {
      return part;
    }
  }
  toOutputBuffer(rendered, templates, output) {
    if (rendered[DYNAMICS]) {
      return this.comprehensionToBuffer(rendered, templates, output);
    }
    let { [STATIC]: statics } = rendered;
    statics = this.templateStatic(statics, templates);
    output.buffer += statics[0];
    for (let i = 1; i < statics.length; i++) {
      this.dynamicToBuffer(rendered[i - 1], templates, output);
      output.buffer += statics[i];
    }
  }
  comprehensionToBuffer(rendered, templates, output) {
    let { [DYNAMICS]: dynamics, [STATIC]: statics, [STREAM]: stream } = rendered;
    let [_inserts, deleteIds] = stream || [{}, []];
    statics = this.templateStatic(statics, templates);
    let compTemplates = templates || rendered[TEMPLATES];
    for (let d = 0; d < dynamics.length; d++) {
      let dynamic = dynamics[d];
      output.buffer += statics[0];
      for (let i = 1; i < statics.length; i++) {
        this.dynamicToBuffer(dynamic[i - 1], compTemplates, output);
        output.buffer += statics[i];
      }
    }
    if (stream !== void 0 && (rendered[DYNAMICS].length > 0 || deleteIds.length > 0)) {
      rendered[DYNAMICS] = [];
      output.streams.add(stream);
    }
  }
  dynamicToBuffer(rendered, templates, output) {
    if (typeof rendered === "number") {
      let [str, streams] = this.recursiveCIDToString(output.components, rendered, output.onlyCids);
      output.buffer += str;
      output.streams = /* @__PURE__ */ new Set([...output.streams, ...streams]);
    } else if (isObject(rendered)) {
      this.toOutputBuffer(rendered, templates, output);
    } else {
      output.buffer += rendered;
    }
  }
  recursiveCIDToString(components, cid, onlyCids) {
    let component = components[cid] || logError(`no component for CID ${cid}`, components);
    let template = document.createElement("template");
    let [html, streams] = this.recursiveToString(component, components, onlyCids);
    template.innerHTML = html;
    let container = template.content;
    let skip = onlyCids && !onlyCids.has(cid);
    let [hasChildNodes, hasChildComponents] = Array.from(container.childNodes).reduce(([hasNodes, hasComponents], child, i) => {
      if (child.nodeType === Node.ELEMENT_NODE) {
        if (child.getAttribute(PHX_COMPONENT)) {
          return [hasNodes, true];
        }
        child.setAttribute(PHX_COMPONENT, cid);
        if (!child.id) {
          child.id = `${this.parentViewId()}-${cid}-${i}`;
        }
        if (skip) {
          child.setAttribute(PHX_SKIP, "");
          child.innerHTML = "";
        }
        return [true, hasComponents];
      } else {
        if (child.nodeValue.trim() !== "") {
          logError(`only HTML element tags are allowed at the root of components.

got: "${child.nodeValue.trim()}"

within:
`, template.innerHTML.trim());
          child.replaceWith(this.createSpan(child.nodeValue, cid));
          return [true, hasComponents];
        } else {
          child.remove();
          return [hasNodes, hasComponents];
        }
      }
    }, [false, false]);
    if (!hasChildNodes && !hasChildComponents) {
      logError("expected at least one HTML element tag inside a component, but the component is empty:\n", template.innerHTML.trim());
      return [this.createSpan("", cid).outerHTML, streams];
    } else if (!hasChildNodes && hasChildComponents) {
      logError("expected at least one HTML element tag directly inside a component, but only subcomponents were found. A component must render at least one HTML tag directly inside itself.", template.innerHTML.trim());
      return [template.innerHTML, streams];
    } else {
      return [template.innerHTML, streams];
    }
  }
  createSpan(text, cid) {
    let span = document.createElement("span");
    span.innerText = text;
    span.setAttribute(PHX_COMPONENT, cid);
    return span;
  }
};
var viewHookID = 1;
var ViewHook = class {
  static makeID() {
    return viewHookID++;
  }
  static elementID(el) {
    return el.phxHookId;
  }
  constructor(view, el, callbacks) {
    this.__view = view;
    this.liveSocket = view.liveSocket;
    this.__callbacks = callbacks;
    this.__listeners = /* @__PURE__ */ new Set();
    this.__isDisconnected = false;
    this.el = el;
    this.el.phxHookId = this.constructor.makeID();
    for (let key in this.__callbacks) {
      this[key] = this.__callbacks[key];
    }
  }
  __mounted() {
    this.mounted && this.mounted();
  }
  __updated() {
    this.updated && this.updated();
  }
  __beforeUpdate() {
    this.beforeUpdate && this.beforeUpdate();
  }
  __destroyed() {
    this.destroyed && this.destroyed();
  }
  __reconnected() {
    if (this.__isDisconnected) {
      this.__isDisconnected = false;
      this.reconnected && this.reconnected();
    }
  }
  __disconnected() {
    this.__isDisconnected = true;
    this.disconnected && this.disconnected();
  }
  pushEvent(event, payload = {}, onReply = function() {
  }) {
    return this.__view.pushHookEvent(null, event, payload, onReply);
  }
  pushEventTo(phxTarget, event, payload = {}, onReply = function() {
  }) {
    return this.__view.withinTargets(phxTarget, (view, targetCtx) => {
      return view.pushHookEvent(targetCtx, event, payload, onReply);
    });
  }
  handleEvent(event, callback) {
    let callbackRef = (customEvent, bypass) => bypass ? event : callback(customEvent.detail);
    window.addEventListener(`phx:${event}`, callbackRef);
    this.__listeners.add(callbackRef);
    return callbackRef;
  }
  removeHandleEvent(callbackRef) {
    let event = callbackRef(null, true);
    window.removeEventListener(`phx:${event}`, callbackRef);
    this.__listeners.delete(callbackRef);
  }
  upload(name, files) {
    return this.__view.dispatchUploads(name, files);
  }
  uploadTo(phxTarget, name, files) {
    return this.__view.withinTargets(phxTarget, (view) => view.dispatchUploads(name, files));
  }
  __cleanup__() {
    this.__listeners.forEach((callbackRef) => this.removeHandleEvent(callbackRef));
  }
};
var focusStack = null;
var JS = {
  exec(eventType, phxEvent, view, sourceEl, defaults) {
    let [defaultKind, defaultArgs] = defaults || [null, {}];
    let commands = phxEvent.charAt(0) === "[" ? JSON.parse(phxEvent) : [[defaultKind, defaultArgs]];
    commands.forEach(([kind, args]) => {
      if (kind === defaultKind && defaultArgs.data) {
        args.data = Object.assign(args.data || {}, defaultArgs.data);
      }
      this.filterToEls(sourceEl, args).forEach((el) => {
        this[`exec_${kind}`](eventType, phxEvent, view, sourceEl, el, args);
      });
    });
  },
  isVisible(el) {
    return !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length > 0);
  },
  exec_exec(eventType, phxEvent, view, sourceEl, el, [attr, to]) {
    let nodes = to ? dom_default.all(document, to) : [sourceEl];
    nodes.forEach((node) => {
      let encodedJS = node.getAttribute(attr);
      if (!encodedJS) {
        throw new Error(`expected ${attr} to contain JS command on "${to}"`);
      }
      view.liveSocket.execJS(node, encodedJS, eventType);
    });
  },
  exec_dispatch(eventType, phxEvent, view, sourceEl, el, { to, event, detail, bubbles }) {
    detail = detail || {};
    detail.dispatcher = sourceEl;
    dom_default.dispatchEvent(el, event, { detail, bubbles });
  },
  exec_push(eventType, phxEvent, view, sourceEl, el, args) {
    if (!view.isConnected()) {
      return;
    }
    let { event, data, target, page_loading, loading, value, dispatcher } = args;
    let pushOpts = { loading, value, target, page_loading: !!page_loading };
    let targetSrc = eventType === "change" && dispatcher ? dispatcher : sourceEl;
    let phxTarget = target || targetSrc.getAttribute(view.binding("target")) || targetSrc;
    view.withinTargets(phxTarget, (targetView, targetCtx) => {
      if (eventType === "change") {
        let { newCid, _target, callback } = args;
        _target = _target || (dom_default.isFormInput(sourceEl) ? sourceEl.name : void 0);
        if (_target) {
          pushOpts._target = _target;
        }
        targetView.pushInput(sourceEl, targetCtx, newCid, event || phxEvent, pushOpts, callback);
      } else if (eventType === "submit") {
        let { submitter } = args;
        targetView.submitForm(sourceEl, targetCtx, event || phxEvent, submitter, pushOpts);
      } else {
        targetView.pushEvent(eventType, sourceEl, targetCtx, event || phxEvent, data, pushOpts);
      }
    });
  },
  exec_navigate(eventType, phxEvent, view, sourceEl, el, { href, replace }) {
    view.liveSocket.historyRedirect(href, replace ? "replace" : "push");
  },
  exec_patch(eventType, phxEvent, view, sourceEl, el, { href, replace }) {
    view.liveSocket.pushHistoryPatch(href, replace ? "replace" : "push", sourceEl);
  },
  exec_focus(eventType, phxEvent, view, sourceEl, el) {
    window.requestAnimationFrame(() => aria_default.attemptFocus(el));
  },
  exec_focus_first(eventType, phxEvent, view, sourceEl, el) {
    window.requestAnimationFrame(() => aria_default.focusFirstInteractive(el) || aria_default.focusFirst(el));
  },
  exec_push_focus(eventType, phxEvent, view, sourceEl, el) {
    window.requestAnimationFrame(() => focusStack = el || sourceEl);
  },
  exec_pop_focus(eventType, phxEvent, view, sourceEl, el) {
    window.requestAnimationFrame(() => {
      if (focusStack) {
        focusStack.focus();
      }
      focusStack = null;
    });
  },
  exec_add_class(eventType, phxEvent, view, sourceEl, el, { names, transition, time }) {
    this.addOrRemoveClasses(el, names, [], transition, time, view);
  },
  exec_remove_class(eventType, phxEvent, view, sourceEl, el, { names, transition, time }) {
    this.addOrRemoveClasses(el, [], names, transition, time, view);
  },
  exec_transition(eventType, phxEvent, view, sourceEl, el, { time, transition }) {
    this.addOrRemoveClasses(el, [], [], transition, time, view);
  },
  exec_toggle(eventType, phxEvent, view, sourceEl, el, { display, ins, outs, time }) {
    this.toggle(eventType, view, el, display, ins, outs, time);
  },
  exec_show(eventType, phxEvent, view, sourceEl, el, { display, transition, time }) {
    this.show(eventType, view, el, display, transition, time);
  },
  exec_hide(eventType, phxEvent, view, sourceEl, el, { display, transition, time }) {
    this.hide(eventType, view, el, display, transition, time);
  },
  exec_set_attr(eventType, phxEvent, view, sourceEl, el, { attr: [attr, val] }) {
    this.setOrRemoveAttrs(el, [[attr, val]], []);
  },
  exec_remove_attr(eventType, phxEvent, view, sourceEl, el, { attr }) {
    this.setOrRemoveAttrs(el, [], [attr]);
  },
  show(eventType, view, el, display, transition, time) {
    if (!this.isVisible(el)) {
      this.toggle(eventType, view, el, display, transition, null, time);
    }
  },
  hide(eventType, view, el, display, transition, time) {
    if (this.isVisible(el)) {
      this.toggle(eventType, view, el, display, null, transition, time);
    }
  },
  toggle(eventType, view, el, display, ins, outs, time) {
    let [inClasses, inStartClasses, inEndClasses] = ins || [[], [], []];
    let [outClasses, outStartClasses, outEndClasses] = outs || [[], [], []];
    if (inClasses.length > 0 || outClasses.length > 0) {
      if (this.isVisible(el)) {
        let onStart = () => {
          this.addOrRemoveClasses(el, outStartClasses, inClasses.concat(inStartClasses).concat(inEndClasses));
          window.requestAnimationFrame(() => {
            this.addOrRemoveClasses(el, outClasses, []);
            window.requestAnimationFrame(() => this.addOrRemoveClasses(el, outEndClasses, outStartClasses));
          });
        };
        el.dispatchEvent(new Event("phx:hide-start"));
        view.transition(time, onStart, () => {
          this.addOrRemoveClasses(el, [], outClasses.concat(outEndClasses));
          dom_default.putSticky(el, "toggle", (currentEl) => currentEl.style.display = "none");
          el.dispatchEvent(new Event("phx:hide-end"));
        });
      } else {
        if (eventType === "remove") {
          return;
        }
        let onStart = () => {
          this.addOrRemoveClasses(el, inStartClasses, outClasses.concat(outStartClasses).concat(outEndClasses));
          let stickyDisplay = display || this.defaultDisplay(el);
          dom_default.putSticky(el, "toggle", (currentEl) => currentEl.style.display = stickyDisplay);
          window.requestAnimationFrame(() => {
            this.addOrRemoveClasses(el, inClasses, []);
            window.requestAnimationFrame(() => this.addOrRemoveClasses(el, inEndClasses, inStartClasses));
          });
        };
        el.dispatchEvent(new Event("phx:show-start"));
        view.transition(time, onStart, () => {
          this.addOrRemoveClasses(el, [], inClasses.concat(inEndClasses));
          el.dispatchEvent(new Event("phx:show-end"));
        });
      }
    } else {
      if (this.isVisible(el)) {
        window.requestAnimationFrame(() => {
          el.dispatchEvent(new Event("phx:hide-start"));
          dom_default.putSticky(el, "toggle", (currentEl) => currentEl.style.display = "none");
          el.dispatchEvent(new Event("phx:hide-end"));
        });
      } else {
        window.requestAnimationFrame(() => {
          el.dispatchEvent(new Event("phx:show-start"));
          let stickyDisplay = display || this.defaultDisplay(el);
          dom_default.putSticky(el, "toggle", (currentEl) => currentEl.style.display = stickyDisplay);
          el.dispatchEvent(new Event("phx:show-end"));
        });
      }
    }
  },
  addOrRemoveClasses(el, adds, removes, transition, time, view) {
    let [transition_run, transition_start, transition_end] = transition || [[], [], []];
    if (transition_run.length > 0) {
      let onStart = () => this.addOrRemoveClasses(el, transition_start.concat(transition_run), []);
      let onDone = () => this.addOrRemoveClasses(el, adds.concat(transition_end), removes.concat(transition_run).concat(transition_start));
      return view.transition(time, onStart, onDone);
    }
    window.requestAnimationFrame(() => {
      let [prevAdds, prevRemoves] = dom_default.getSticky(el, "classes", [[], []]);
      let keepAdds = adds.filter((name) => prevAdds.indexOf(name) < 0 && !el.classList.contains(name));
      let keepRemoves = removes.filter((name) => prevRemoves.indexOf(name) < 0 && el.classList.contains(name));
      let newAdds = prevAdds.filter((name) => removes.indexOf(name) < 0).concat(keepAdds);
      let newRemoves = prevRemoves.filter((name) => adds.indexOf(name) < 0).concat(keepRemoves);
      dom_default.putSticky(el, "classes", (currentEl) => {
        currentEl.classList.remove(...newRemoves);
        currentEl.classList.add(...newAdds);
        return [newAdds, newRemoves];
      });
    });
  },
  setOrRemoveAttrs(el, sets, removes) {
    let [prevSets, prevRemoves] = dom_default.getSticky(el, "attrs", [[], []]);
    let alteredAttrs = sets.map(([attr, _val]) => attr).concat(removes);
    let newSets = prevSets.filter(([attr, _val]) => !alteredAttrs.includes(attr)).concat(sets);
    let newRemoves = prevRemoves.filter((attr) => !alteredAttrs.includes(attr)).concat(removes);
    dom_default.putSticky(el, "attrs", (currentEl) => {
      newRemoves.forEach((attr) => currentEl.removeAttribute(attr));
      newSets.forEach(([attr, val]) => currentEl.setAttribute(attr, val));
      return [newSets, newRemoves];
    });
  },
  hasAllClasses(el, classes) {
    return classes.every((name) => el.classList.contains(name));
  },
  isToggledOut(el, outClasses) {
    return !this.isVisible(el) || this.hasAllClasses(el, outClasses);
  },
  filterToEls(sourceEl, { to }) {
    return to ? dom_default.all(document, to) : [sourceEl];
  },
  defaultDisplay(el) {
    return { tr: "table-row", td: "table-cell" }[el.tagName.toLowerCase()] || "block";
  }
};
var js_default = JS;
var serializeForm = (form, metadata, onlyNames = []) => {
  let { submitter, ...meta } = metadata;
  let formData = new FormData(form);
  if (submitter && submitter.hasAttribute("name") && submitter.form && submitter.form === form) {
    formData.append(submitter.name, submitter.value);
  }
  let toRemove = [];
  formData.forEach((val, key, _index) => {
    if (val instanceof File) {
      toRemove.push(key);
    }
  });
  toRemove.forEach((key) => formData.delete(key));
  let params = new URLSearchParams();
  for (let [key, val] of formData.entries()) {
    if (onlyNames.length === 0 || onlyNames.indexOf(key) >= 0) {
      params.append(key, val);
    }
  }
  for (let metaKey in meta) {
    params.append(metaKey, meta[metaKey]);
  }
  return params.toString();
};
var View = class {
  constructor(el, liveSocket2, parentView, flash, liveReferer) {
    this.isDead = false;
    this.liveSocket = liveSocket2;
    this.flash = flash;
    this.parent = parentView;
    this.root = parentView ? parentView.root : this;
    this.el = el;
    this.id = this.el.id;
    this.ref = 0;
    this.childJoins = 0;
    this.loaderTimer = null;
    this.pendingDiffs = [];
    this.pruningCIDs = [];
    this.redirect = false;
    this.href = null;
    this.joinCount = this.parent ? this.parent.joinCount - 1 : 0;
    this.joinPending = true;
    this.destroyed = false;
    this.joinCallback = function(onDone) {
      onDone && onDone();
    };
    this.stopCallback = function() {
    };
    this.pendingJoinOps = this.parent ? null : [];
    this.viewHooks = {};
    this.uploaders = {};
    this.formSubmits = [];
    this.children = this.parent ? null : {};
    this.root.children[this.id] = {};
    this.channel = this.liveSocket.channel(`lv:${this.id}`, () => {
      return {
        redirect: this.redirect ? this.href : void 0,
        url: this.redirect ? void 0 : this.href || void 0,
        params: this.connectParams(liveReferer),
        session: this.getSession(),
        static: this.getStatic(),
        flash: this.flash
      };
    });
  }
  setHref(href) {
    this.href = href;
  }
  setRedirect(href) {
    this.redirect = true;
    this.href = href;
  }
  isMain() {
    return this.el.hasAttribute(PHX_MAIN);
  }
  connectParams(liveReferer) {
    let params = this.liveSocket.params(this.el);
    let manifest = dom_default.all(document, `[${this.binding(PHX_TRACK_STATIC)}]`).map((node) => node.src || node.href).filter((url) => typeof url === "string");
    if (manifest.length > 0) {
      params["_track_static"] = manifest;
    }
    params["_mounts"] = this.joinCount;
    params["_live_referer"] = liveReferer;
    return params;
  }
  isConnected() {
    return this.channel.canPush();
  }
  getSession() {
    return this.el.getAttribute(PHX_SESSION);
  }
  getStatic() {
    let val = this.el.getAttribute(PHX_STATIC);
    return val === "" ? null : val;
  }
  destroy(callback = function() {
  }) {
    this.destroyAllChildren();
    this.destroyed = true;
    delete this.root.children[this.id];
    if (this.parent) {
      delete this.root.children[this.parent.id][this.id];
    }
    clearTimeout(this.loaderTimer);
    let onFinished = () => {
      callback();
      for (let id in this.viewHooks) {
        this.destroyHook(this.viewHooks[id]);
      }
    };
    dom_default.markPhxChildDestroyed(this.el);
    this.log("destroyed", () => ["the child has been removed from the parent"]);
    this.channel.leave().receive("ok", onFinished).receive("error", onFinished).receive("timeout", onFinished);
  }
  setContainerClasses(...classes) {
    this.el.classList.remove(PHX_CONNECTED_CLASS, PHX_DISCONNECTED_CLASS, PHX_ERROR_CLASS);
    this.el.classList.add(...classes);
  }
  showLoader(timeout) {
    clearTimeout(this.loaderTimer);
    if (timeout) {
      this.loaderTimer = setTimeout(() => this.showLoader(), timeout);
    } else {
      for (let id in this.viewHooks) {
        this.viewHooks[id].__disconnected();
      }
      this.setContainerClasses(PHX_DISCONNECTED_CLASS);
    }
  }
  execAll(binding) {
    dom_default.all(this.el, `[${binding}]`, (el) => this.liveSocket.execJS(el, el.getAttribute(binding)));
  }
  hideLoader() {
    clearTimeout(this.loaderTimer);
    this.setContainerClasses(PHX_CONNECTED_CLASS);
    this.execAll(this.binding("connected"));
  }
  triggerReconnected() {
    for (let id in this.viewHooks) {
      this.viewHooks[id].__reconnected();
    }
  }
  log(kind, msgCallback) {
    this.liveSocket.log(this, kind, msgCallback);
  }
  transition(time, onStart, onDone = function() {
  }) {
    this.liveSocket.transition(time, onStart, onDone);
  }
  withinTargets(phxTarget, callback) {
    if (phxTarget instanceof HTMLElement || phxTarget instanceof SVGElement) {
      return this.liveSocket.owner(phxTarget, (view) => callback(view, phxTarget));
    }
    if (isCid(phxTarget)) {
      let targets = dom_default.findComponentNodeList(this.el, phxTarget);
      if (targets.length === 0) {
        logError(`no component found matching phx-target of ${phxTarget}`);
      } else {
        callback(this, parseInt(phxTarget));
      }
    } else {
      let targets = Array.from(document.querySelectorAll(phxTarget));
      if (targets.length === 0) {
        logError(`nothing found matching the phx-target selector "${phxTarget}"`);
      }
      targets.forEach((target) => this.liveSocket.owner(target, (view) => callback(view, target)));
    }
  }
  applyDiff(type, rawDiff, callback) {
    this.log(type, () => ["", clone(rawDiff)]);
    let { diff, reply, events, title } = Rendered.extract(rawDiff);
    callback({ diff, reply, events });
    if (title) {
      window.requestAnimationFrame(() => dom_default.putTitle(title));
    }
  }
  onJoin(resp) {
    let { rendered, container } = resp;
    if (container) {
      let [tag, attrs] = container;
      this.el = dom_default.replaceRootContainer(this.el, tag, attrs);
    }
    this.childJoins = 0;
    this.joinPending = true;
    this.flash = null;
    browser_default.dropLocal(this.liveSocket.localStorage, window.location.pathname, CONSECUTIVE_RELOADS);
    this.applyDiff("mount", rendered, ({ diff, events }) => {
      this.rendered = new Rendered(this.id, diff);
      let [html, streams] = this.renderContainer(null, "join");
      this.dropPendingRefs();
      let forms = this.formsForRecovery(html);
      this.joinCount++;
      if (forms.length > 0) {
        forms.forEach(([form, newForm, newCid], i) => {
          this.pushFormRecovery(form, newCid, (resp2) => {
            if (i === forms.length - 1) {
              this.onJoinComplete(resp2, html, streams, events);
            }
          });
        });
      } else {
        this.onJoinComplete(resp, html, streams, events);
      }
    });
  }
  dropPendingRefs() {
    dom_default.all(document, `[${PHX_REF_SRC}="${this.id}"][${PHX_REF}]`, (el) => {
      el.removeAttribute(PHX_REF);
      el.removeAttribute(PHX_REF_SRC);
    });
  }
  onJoinComplete({ live_patch }, html, streams, events) {
    if (this.joinCount > 1 || this.parent && !this.parent.isJoinPending()) {
      return this.applyJoinPatch(live_patch, html, streams, events);
    }
    let newChildren = dom_default.findPhxChildrenInFragment(html, this.id).filter((toEl) => {
      let fromEl = toEl.id && this.el.querySelector(`[id="${toEl.id}"]`);
      let phxStatic = fromEl && fromEl.getAttribute(PHX_STATIC);
      if (phxStatic) {
        toEl.setAttribute(PHX_STATIC, phxStatic);
      }
      return this.joinChild(toEl);
    });
    if (newChildren.length === 0) {
      if (this.parent) {
        this.root.pendingJoinOps.push([this, () => this.applyJoinPatch(live_patch, html, streams, events)]);
        this.parent.ackJoin(this);
      } else {
        this.onAllChildJoinsComplete();
        this.applyJoinPatch(live_patch, html, streams, events);
      }
    } else {
      this.root.pendingJoinOps.push([this, () => this.applyJoinPatch(live_patch, html, streams, events)]);
    }
  }
  attachTrueDocEl() {
    this.el = dom_default.byId(this.id);
    this.el.setAttribute(PHX_ROOT_ID, this.root.id);
  }
  execNewMounted() {
    dom_default.all(this.el, `[${this.binding(PHX_HOOK)}], [data-phx-${PHX_HOOK}]`, (hookEl) => {
      this.maybeAddNewHook(hookEl);
    });
    dom_default.all(this.el, `[${this.binding(PHX_MOUNTED)}]`, (el) => this.maybeMounted(el));
  }
  applyJoinPatch(live_patch, html, streams, events) {
    this.attachTrueDocEl();
    let patch = new DOMPatch(this, this.el, this.id, html, streams, null);
    patch.markPrunableContentForRemoval();
    this.performPatch(patch, false);
    this.joinNewChildren();
    this.execNewMounted();
    this.joinPending = false;
    this.liveSocket.dispatchEvents(events);
    this.applyPendingUpdates();
    if (live_patch) {
      let { kind, to } = live_patch;
      this.liveSocket.historyPatch(to, kind);
    }
    this.hideLoader();
    if (this.joinCount > 1) {
      this.triggerReconnected();
    }
    this.stopCallback();
  }
  triggerBeforeUpdateHook(fromEl, toEl) {
    this.liveSocket.triggerDOM("onBeforeElUpdated", [fromEl, toEl]);
    let hook2 = this.getHook(fromEl);
    let isIgnored = hook2 && dom_default.isIgnored(fromEl, this.binding(PHX_UPDATE));
    if (hook2 && !fromEl.isEqualNode(toEl) && !(isIgnored && isEqualObj(fromEl.dataset, toEl.dataset))) {
      hook2.__beforeUpdate();
      return hook2;
    }
  }
  maybeMounted(el) {
    let phxMounted = el.getAttribute(this.binding(PHX_MOUNTED));
    let hasBeenInvoked = phxMounted && dom_default.private(el, "mounted");
    if (phxMounted && !hasBeenInvoked) {
      this.liveSocket.execJS(el, phxMounted);
      dom_default.putPrivate(el, "mounted", true);
    }
  }
  maybeAddNewHook(el, force) {
    let newHook = this.addHook(el);
    if (newHook) {
      newHook.__mounted();
    }
  }
  performPatch(patch, pruneCids) {
    let removedEls = [];
    let phxChildrenAdded = false;
    let updatedHookIds = /* @__PURE__ */ new Set();
    patch.after("added", (el) => {
      this.liveSocket.triggerDOM("onNodeAdded", [el]);
      this.maybeAddNewHook(el);
      if (el.getAttribute) {
        this.maybeMounted(el);
      }
    });
    patch.after("phxChildAdded", (el) => {
      if (dom_default.isPhxSticky(el)) {
        this.liveSocket.joinRootViews();
      } else {
        phxChildrenAdded = true;
      }
    });
    patch.before("updated", (fromEl, toEl) => {
      let hook2 = this.triggerBeforeUpdateHook(fromEl, toEl);
      if (hook2) {
        updatedHookIds.add(fromEl.id);
      }
    });
    patch.after("updated", (el) => {
      if (updatedHookIds.has(el.id)) {
        this.getHook(el).__updated();
      }
    });
    patch.after("discarded", (el) => {
      if (el.nodeType === Node.ELEMENT_NODE) {
        removedEls.push(el);
      }
    });
    patch.after("transitionsDiscarded", (els) => this.afterElementsRemoved(els, pruneCids));
    patch.perform();
    this.afterElementsRemoved(removedEls, pruneCids);
    return phxChildrenAdded;
  }
  afterElementsRemoved(elements, pruneCids) {
    let destroyedCIDs = [];
    elements.forEach((parent) => {
      let components = dom_default.all(parent, `[${PHX_COMPONENT}]`);
      let hooks = dom_default.all(parent, `[${this.binding(PHX_HOOK)}]`);
      components.concat(parent).forEach((el) => {
        let cid = this.componentID(el);
        if (isCid(cid) && destroyedCIDs.indexOf(cid) === -1) {
          destroyedCIDs.push(cid);
        }
      });
      hooks.concat(parent).forEach((hookEl) => {
        let hook2 = this.getHook(hookEl);
        hook2 && this.destroyHook(hook2);
      });
    });
    if (pruneCids) {
      this.maybePushComponentsDestroyed(destroyedCIDs);
    }
  }
  joinNewChildren() {
    dom_default.findPhxChildren(this.el, this.id).forEach((el) => this.joinChild(el));
  }
  getChildById(id) {
    return this.root.children[this.id][id];
  }
  getDescendentByEl(el) {
    if (el.id === this.id) {
      return this;
    } else {
      return this.children[el.getAttribute(PHX_PARENT_ID)][el.id];
    }
  }
  destroyDescendent(id) {
    for (let parentId in this.root.children) {
      for (let childId in this.root.children[parentId]) {
        if (childId === id) {
          return this.root.children[parentId][childId].destroy();
        }
      }
    }
  }
  joinChild(el) {
    let child = this.getChildById(el.id);
    if (!child) {
      let view = new View(el, this.liveSocket, this);
      this.root.children[this.id][view.id] = view;
      view.join();
      this.childJoins++;
      return true;
    }
  }
  isJoinPending() {
    return this.joinPending;
  }
  ackJoin(_child) {
    this.childJoins--;
    if (this.childJoins === 0) {
      if (this.parent) {
        this.parent.ackJoin(this);
      } else {
        this.onAllChildJoinsComplete();
      }
    }
  }
  onAllChildJoinsComplete() {
    this.joinCallback(() => {
      this.pendingJoinOps.forEach(([view, op]) => {
        if (!view.isDestroyed()) {
          op();
        }
      });
      this.pendingJoinOps = [];
    });
  }
  update(diff, events) {
    if (this.isJoinPending() || this.liveSocket.hasPendingLink() && this.root.isMain()) {
      return this.pendingDiffs.push({ diff, events });
    }
    this.rendered.mergeDiff(diff);
    let phxChildrenAdded = false;
    if (this.rendered.isComponentOnlyDiff(diff)) {
      this.liveSocket.time("component patch complete", () => {
        let parentCids = dom_default.findParentCIDs(this.el, this.rendered.componentCIDs(diff));
        parentCids.forEach((parentCID) => {
          if (this.componentPatch(this.rendered.getComponent(diff, parentCID), parentCID)) {
            phxChildrenAdded = true;
          }
        });
      });
    } else if (!isEmpty(diff)) {
      this.liveSocket.time("full patch complete", () => {
        let [html, streams] = this.renderContainer(diff, "update");
        let patch = new DOMPatch(this, this.el, this.id, html, streams, null);
        phxChildrenAdded = this.performPatch(patch, true);
      });
    }
    this.liveSocket.dispatchEvents(events);
    if (phxChildrenAdded) {
      this.joinNewChildren();
    }
  }
  renderContainer(diff, kind) {
    return this.liveSocket.time(`toString diff (${kind})`, () => {
      let tag = this.el.tagName;
      let cids = diff ? this.rendered.componentCIDs(diff).concat(this.pruningCIDs) : null;
      let [html, streams] = this.rendered.toString(cids);
      return [`<${tag}>${html}</${tag}>`, streams];
    });
  }
  componentPatch(diff, cid) {
    if (isEmpty(diff))
      return false;
    let [html, streams] = this.rendered.componentToString(cid);
    let patch = new DOMPatch(this, this.el, this.id, html, streams, cid);
    let childrenAdded = this.performPatch(patch, true);
    return childrenAdded;
  }
  getHook(el) {
    return this.viewHooks[ViewHook.elementID(el)];
  }
  addHook(el) {
    if (ViewHook.elementID(el) || !el.getAttribute) {
      return;
    }
    let hookName = el.getAttribute(`data-phx-${PHX_HOOK}`) || el.getAttribute(this.binding(PHX_HOOK));
    if (hookName && !this.ownsElement(el)) {
      return;
    }
    let callbacks = this.liveSocket.getHookCallbacks(hookName);
    if (callbacks) {
      if (!el.id) {
        logError(`no DOM ID for hook "${hookName}". Hooks require a unique ID on each element.`, el);
      }
      let hook2 = new ViewHook(this, el, callbacks);
      this.viewHooks[ViewHook.elementID(hook2.el)] = hook2;
      return hook2;
    } else if (hookName !== null) {
      logError(`unknown hook found for "${hookName}"`, el);
    }
  }
  destroyHook(hook2) {
    hook2.__destroyed();
    hook2.__cleanup__();
    delete this.viewHooks[ViewHook.elementID(hook2.el)];
  }
  applyPendingUpdates() {
    this.pendingDiffs.forEach(({ diff, events }) => this.update(diff, events));
    this.pendingDiffs = [];
    this.eachChild((child) => child.applyPendingUpdates());
  }
  eachChild(callback) {
    let children = this.root.children[this.id] || {};
    for (let id in children) {
      callback(this.getChildById(id));
    }
  }
  onChannel(event, cb) {
    this.liveSocket.onChannel(this.channel, event, (resp) => {
      if (this.isJoinPending()) {
        this.root.pendingJoinOps.push([this, () => cb(resp)]);
      } else {
        this.liveSocket.requestDOMUpdate(() => cb(resp));
      }
    });
  }
  bindChannel() {
    this.liveSocket.onChannel(this.channel, "diff", (rawDiff) => {
      this.liveSocket.requestDOMUpdate(() => {
        this.applyDiff("update", rawDiff, ({ diff, events }) => this.update(diff, events));
      });
    });
    this.onChannel("redirect", ({ to, flash }) => this.onRedirect({ to, flash }));
    this.onChannel("live_patch", (redir) => this.onLivePatch(redir));
    this.onChannel("live_redirect", (redir) => this.onLiveRedirect(redir));
    this.channel.onError((reason) => this.onError(reason));
    this.channel.onClose((reason) => this.onClose(reason));
  }
  destroyAllChildren() {
    this.eachChild((child) => child.destroy());
  }
  onLiveRedirect(redir) {
    let { to, kind, flash } = redir;
    let url = this.expandURL(to);
    this.liveSocket.historyRedirect(url, kind, flash);
  }
  onLivePatch(redir) {
    let { to, kind } = redir;
    this.href = this.expandURL(to);
    this.liveSocket.historyPatch(to, kind);
  }
  expandURL(to) {
    return to.startsWith("/") ? `${window.location.protocol}//${window.location.host}${to}` : to;
  }
  onRedirect({ to, flash }) {
    this.liveSocket.redirect(to, flash);
  }
  isDestroyed() {
    return this.destroyed;
  }
  joinDead() {
    this.isDead = true;
  }
  join(callback) {
    this.showLoader(this.liveSocket.loaderTimeout);
    this.bindChannel();
    if (this.isMain()) {
      this.stopCallback = this.liveSocket.withPageLoading({ to: this.href, kind: "initial" });
    }
    this.joinCallback = (onDone) => {
      onDone = onDone || function() {
      };
      callback ? callback(this.joinCount, onDone) : onDone();
    };
    this.liveSocket.wrapPush(this, { timeout: false }, () => {
      return this.channel.join().receive("ok", (data) => {
        if (!this.isDestroyed()) {
          this.liveSocket.requestDOMUpdate(() => this.onJoin(data));
        }
      }).receive("error", (resp) => !this.isDestroyed() && this.onJoinError(resp)).receive("timeout", () => !this.isDestroyed() && this.onJoinError({ reason: "timeout" }));
    });
  }
  onJoinError(resp) {
    if (resp.reason === "reload") {
      this.log("error", () => [`failed mount with ${resp.status}. Falling back to page request`, resp]);
      return this.onRedirect({ to: this.href });
    } else if (resp.reason === "unauthorized" || resp.reason === "stale") {
      this.log("error", () => ["unauthorized live_redirect. Falling back to page request", resp]);
      return this.onRedirect({ to: this.href });
    }
    if (resp.redirect || resp.live_redirect) {
      this.joinPending = false;
      this.channel.leave();
    }
    if (resp.redirect) {
      return this.onRedirect(resp.redirect);
    }
    if (resp.live_redirect) {
      return this.onLiveRedirect(resp.live_redirect);
    }
    this.log("error", () => ["unable to join", resp]);
    if (this.liveSocket.isConnected()) {
      this.liveSocket.reloadWithJitter(this);
    }
  }
  onClose(reason) {
    if (this.isDestroyed()) {
      return;
    }
    if (this.liveSocket.hasPendingLink() && reason !== "leave") {
      return this.liveSocket.reloadWithJitter(this);
    }
    this.destroyAllChildren();
    this.liveSocket.dropActiveElement(this);
    if (document.activeElement) {
      document.activeElement.blur();
    }
    if (this.liveSocket.isUnloaded()) {
      this.showLoader(BEFORE_UNLOAD_LOADER_TIMEOUT);
    }
  }
  onError(reason) {
    this.onClose(reason);
    if (this.liveSocket.isConnected()) {
      this.log("error", () => ["view crashed", reason]);
    }
    if (!this.liveSocket.isUnloaded()) {
      this.displayError();
    }
  }
  displayError() {
    if (this.isMain()) {
      dom_default.dispatchEvent(window, "phx:page-loading-start", { detail: { to: this.href, kind: "error" } });
    }
    this.showLoader();
    this.setContainerClasses(PHX_DISCONNECTED_CLASS, PHX_ERROR_CLASS);
    this.execAll(this.binding("disconnected"));
  }
  pushWithReply(refGenerator, event, payload, onReply = function() {
  }) {
    if (!this.isConnected()) {
      return;
    }
    let [ref, [el], opts] = refGenerator ? refGenerator() : [null, [], {}];
    let onLoadingDone = function() {
    };
    if (opts.page_loading || el && el.getAttribute(this.binding(PHX_PAGE_LOADING)) !== null) {
      onLoadingDone = this.liveSocket.withPageLoading({ kind: "element", target: el });
    }
    if (typeof payload.cid !== "number") {
      delete payload.cid;
    }
    return this.liveSocket.wrapPush(this, { timeout: true }, () => {
      return this.channel.push(event, payload, PUSH_TIMEOUT).receive("ok", (resp) => {
        let finish = (hookReply) => {
          if (resp.redirect) {
            this.onRedirect(resp.redirect);
          }
          if (resp.live_patch) {
            this.onLivePatch(resp.live_patch);
          }
          if (resp.live_redirect) {
            this.onLiveRedirect(resp.live_redirect);
          }
          if (ref !== null) {
            this.undoRefs(ref);
          }
          onLoadingDone();
          onReply(resp, hookReply);
        };
        if (resp.diff) {
          this.liveSocket.requestDOMUpdate(() => {
            this.applyDiff("update", resp.diff, ({ diff, reply, events }) => {
              this.update(diff, events);
              finish(reply);
            });
          });
        } else {
          finish(null);
        }
      });
    });
  }
  undoRefs(ref) {
    if (!this.isConnected()) {
      return;
    }
    dom_default.all(document, `[${PHX_REF_SRC}="${this.id}"][${PHX_REF}="${ref}"]`, (el) => {
      let disabledVal = el.getAttribute(PHX_DISABLED);
      el.removeAttribute(PHX_REF);
      el.removeAttribute(PHX_REF_SRC);
      if (el.getAttribute(PHX_READONLY) !== null) {
        el.readOnly = false;
        el.removeAttribute(PHX_READONLY);
      }
      if (disabledVal !== null) {
        el.disabled = disabledVal === "true" ? true : false;
        el.removeAttribute(PHX_DISABLED);
      }
      PHX_EVENT_CLASSES.forEach((className) => dom_default.removeClass(el, className));
      let disableRestore = el.getAttribute(PHX_DISABLE_WITH_RESTORE);
      if (disableRestore !== null) {
        el.innerText = disableRestore;
        el.removeAttribute(PHX_DISABLE_WITH_RESTORE);
      }
      let toEl = dom_default.private(el, PHX_REF);
      if (toEl) {
        let hook2 = this.triggerBeforeUpdateHook(el, toEl);
        DOMPatch.patchEl(el, toEl, this.liveSocket.getActiveElement());
        if (hook2) {
          hook2.__updated();
        }
        dom_default.deletePrivate(el, PHX_REF);
      }
    });
  }
  putRef(elements, event, opts = {}) {
    let newRef = this.ref++;
    let disableWith = this.binding(PHX_DISABLE_WITH);
    if (opts.loading) {
      elements = elements.concat(dom_default.all(document, opts.loading));
    }
    elements.forEach((el) => {
      el.classList.add(`phx-${event}-loading`);
      el.setAttribute(PHX_REF, newRef);
      el.setAttribute(PHX_REF_SRC, this.el.id);
      let disableText = el.getAttribute(disableWith);
      if (disableText !== null) {
        if (!el.getAttribute(PHX_DISABLE_WITH_RESTORE)) {
          el.setAttribute(PHX_DISABLE_WITH_RESTORE, el.innerText);
        }
        if (disableText !== "") {
          el.innerText = disableText;
        }
        el.setAttribute("disabled", "");
      }
    });
    return [newRef, elements, opts];
  }
  componentID(el) {
    let cid = el.getAttribute && el.getAttribute(PHX_COMPONENT);
    return cid ? parseInt(cid) : null;
  }
  targetComponentID(target, targetCtx, opts = {}) {
    if (isCid(targetCtx)) {
      return targetCtx;
    }
    let cidOrSelector = target.getAttribute(this.binding("target"));
    if (isCid(cidOrSelector)) {
      return parseInt(cidOrSelector);
    } else if (targetCtx && (cidOrSelector !== null || opts.target)) {
      return this.closestComponentID(targetCtx);
    } else {
      return null;
    }
  }
  closestComponentID(targetCtx) {
    if (isCid(targetCtx)) {
      return targetCtx;
    } else if (targetCtx) {
      return maybe(targetCtx.closest(`[${PHX_COMPONENT}]`), (el) => this.ownsElement(el) && this.componentID(el));
    } else {
      return null;
    }
  }
  pushHookEvent(targetCtx, event, payload, onReply) {
    if (!this.isConnected()) {
      this.log("hook", () => ["unable to push hook event. LiveView not connected", event, payload]);
      return false;
    }
    let [ref, els, opts] = this.putRef([], "hook");
    this.pushWithReply(() => [ref, els, opts], "event", {
      type: "hook",
      event,
      value: payload,
      cid: this.closestComponentID(targetCtx)
    }, (resp, reply) => onReply(reply, ref));
    return ref;
  }
  extractMeta(el, meta, value) {
    let prefix = this.binding("value-");
    for (let i = 0; i < el.attributes.length; i++) {
      if (!meta) {
        meta = {};
      }
      let name = el.attributes[i].name;
      if (name.startsWith(prefix)) {
        meta[name.replace(prefix, "")] = el.getAttribute(name);
      }
    }
    if (el.value !== void 0) {
      if (!meta) {
        meta = {};
      }
      meta.value = el.value;
      if (el.tagName === "INPUT" && CHECKABLE_INPUTS.indexOf(el.type) >= 0 && !el.checked) {
        delete meta.value;
      }
    }
    if (value) {
      if (!meta) {
        meta = {};
      }
      for (let key in value) {
        meta[key] = value[key];
      }
    }
    return meta;
  }
  pushEvent(type, el, targetCtx, phxEvent, meta, opts = {}) {
    this.pushWithReply(() => this.putRef([el], type, opts), "event", {
      type,
      event: phxEvent,
      value: this.extractMeta(el, meta, opts.value),
      cid: this.targetComponentID(el, targetCtx, opts)
    });
  }
  pushFileProgress(fileEl, entryRef, progress, onReply = function() {
  }) {
    this.liveSocket.withinOwners(fileEl.form, (view, targetCtx) => {
      view.pushWithReply(null, "progress", {
        event: fileEl.getAttribute(view.binding(PHX_PROGRESS)),
        ref: fileEl.getAttribute(PHX_UPLOAD_REF),
        entry_ref: entryRef,
        progress,
        cid: view.targetComponentID(fileEl.form, targetCtx)
      }, onReply);
    });
  }
  pushInput(inputEl, targetCtx, forceCid, phxEvent, opts, callback) {
    let uploads;
    let cid = isCid(forceCid) ? forceCid : this.targetComponentID(inputEl.form, targetCtx);
    let refGenerator = () => this.putRef([inputEl, inputEl.form], "change", opts);
    let formData;
    if (inputEl.getAttribute(this.binding("change"))) {
      formData = serializeForm(inputEl.form, { _target: opts._target }, [inputEl.name]);
    } else {
      formData = serializeForm(inputEl.form, { _target: opts._target });
    }
    if (dom_default.isUploadInput(inputEl) && inputEl.files && inputEl.files.length > 0) {
      LiveUploader.trackFiles(inputEl, Array.from(inputEl.files));
    }
    uploads = LiveUploader.serializeUploads(inputEl);
    let event = {
      type: "form",
      event: phxEvent,
      value: formData,
      uploads,
      cid
    };
    this.pushWithReply(refGenerator, "event", event, (resp) => {
      dom_default.showError(inputEl, this.liveSocket.binding(PHX_FEEDBACK_FOR));
      if (dom_default.isUploadInput(inputEl) && inputEl.getAttribute("data-phx-auto-upload") !== null) {
        if (LiveUploader.filesAwaitingPreflight(inputEl).length > 0) {
          let [ref, _els] = refGenerator();
          this.uploadFiles(inputEl.form, targetCtx, ref, cid, (_uploads) => {
            callback && callback(resp);
            this.triggerAwaitingSubmit(inputEl.form);
          });
        }
      } else {
        callback && callback(resp);
      }
    });
  }
  triggerAwaitingSubmit(formEl) {
    let awaitingSubmit = this.getScheduledSubmit(formEl);
    if (awaitingSubmit) {
      let [_el, _ref, _opts, callback] = awaitingSubmit;
      this.cancelSubmit(formEl);
      callback();
    }
  }
  getScheduledSubmit(formEl) {
    return this.formSubmits.find(([el, _ref, _opts, _callback]) => el.isSameNode(formEl));
  }
  scheduleSubmit(formEl, ref, opts, callback) {
    if (this.getScheduledSubmit(formEl)) {
      return true;
    }
    this.formSubmits.push([formEl, ref, opts, callback]);
  }
  cancelSubmit(formEl) {
    this.formSubmits = this.formSubmits.filter(([el, ref, _callback]) => {
      if (el.isSameNode(formEl)) {
        this.undoRefs(ref);
        return false;
      } else {
        return true;
      }
    });
  }
  disableForm(formEl, opts = {}) {
    let filterIgnored = (el) => {
      let userIgnored = closestPhxBinding(el, `${this.binding(PHX_UPDATE)}=ignore`, el.form);
      return !(userIgnored || closestPhxBinding(el, "data-phx-update=ignore", el.form));
    };
    let filterDisables = (el) => {
      return el.hasAttribute(this.binding(PHX_DISABLE_WITH));
    };
    let filterButton = (el) => el.tagName == "BUTTON";
    let filterInput = (el) => ["INPUT", "TEXTAREA", "SELECT"].includes(el.tagName);
    let formElements = Array.from(formEl.elements);
    let disables = formElements.filter(filterDisables);
    let buttons = formElements.filter(filterButton).filter(filterIgnored);
    let inputs = formElements.filter(filterInput).filter(filterIgnored);
    buttons.forEach((button) => {
      button.setAttribute(PHX_DISABLED, button.disabled);
      button.disabled = true;
    });
    inputs.forEach((input) => {
      input.setAttribute(PHX_READONLY, input.readOnly);
      input.readOnly = true;
      if (input.files) {
        input.setAttribute(PHX_DISABLED, input.disabled);
        input.disabled = true;
      }
    });
    formEl.setAttribute(this.binding(PHX_PAGE_LOADING), "");
    return this.putRef([formEl].concat(disables).concat(buttons).concat(inputs), "submit", opts);
  }
  pushFormSubmit(formEl, targetCtx, phxEvent, submitter, opts, onReply) {
    let refGenerator = () => this.disableForm(formEl, opts);
    let cid = this.targetComponentID(formEl, targetCtx);
    if (LiveUploader.hasUploadsInProgress(formEl)) {
      let [ref, _els] = refGenerator();
      let push = () => this.pushFormSubmit(formEl, submitter, targetCtx, phxEvent, opts, onReply);
      return this.scheduleSubmit(formEl, ref, opts, push);
    } else if (LiveUploader.inputsAwaitingPreflight(formEl).length > 0) {
      let [ref, els] = refGenerator();
      let proxyRefGen = () => [ref, els, opts];
      this.uploadFiles(formEl, targetCtx, ref, cid, (_uploads) => {
        let formData = serializeForm(formEl, { submitter });
        this.pushWithReply(proxyRefGen, "event", {
          type: "form",
          event: phxEvent,
          value: formData,
          cid
        }, onReply);
      });
    } else {
      let formData = serializeForm(formEl, { submitter });
      this.pushWithReply(refGenerator, "event", {
        type: "form",
        event: phxEvent,
        value: formData,
        cid
      }, onReply);
    }
  }
  uploadFiles(formEl, targetCtx, ref, cid, onComplete) {
    let joinCountAtUpload = this.joinCount;
    let inputEls = LiveUploader.activeFileInputs(formEl);
    let numFileInputsInProgress = inputEls.length;
    inputEls.forEach((inputEl) => {
      let uploader = new LiveUploader(inputEl, this, () => {
        numFileInputsInProgress--;
        if (numFileInputsInProgress === 0) {
          onComplete();
        }
      });
      this.uploaders[inputEl] = uploader;
      let entries = uploader.entries().map((entry) => entry.toPreflightPayload());
      let payload = {
        ref: inputEl.getAttribute(PHX_UPLOAD_REF),
        entries,
        cid: this.targetComponentID(inputEl.form, targetCtx)
      };
      this.log("upload", () => ["sending preflight request", payload]);
      this.pushWithReply(null, "allow_upload", payload, (resp) => {
        this.log("upload", () => ["got preflight response", resp]);
        if (resp.error) {
          this.undoRefs(ref);
          let [entry_ref, reason] = resp.error;
          this.log("upload", () => [`error for entry ${entry_ref}`, reason]);
        } else {
          let onError = (callback) => {
            this.channel.onError(() => {
              if (this.joinCount === joinCountAtUpload) {
                callback();
              }
            });
          };
          uploader.initAdapterUpload(resp, onError, this.liveSocket);
        }
      });
    });
  }
  dispatchUploads(name, filesOrBlobs) {
    let inputs = dom_default.findUploadInputs(this.el).filter((el) => el.name === name);
    if (inputs.length === 0) {
      logError(`no live file inputs found matching the name "${name}"`);
    } else if (inputs.length > 1) {
      logError(`duplicate live file inputs found matching the name "${name}"`);
    } else {
      dom_default.dispatchEvent(inputs[0], PHX_TRACK_UPLOADS, { detail: { files: filesOrBlobs } });
    }
  }
  pushFormRecovery(form, newCid, callback) {
    this.liveSocket.withinOwners(form, (view, targetCtx) => {
      let input = Array.from(form.elements).find((el) => {
        return dom_default.isFormInput(el) && el.type !== "hidden" && !el.hasAttribute(this.binding("change"));
      });
      let phxEvent = form.getAttribute(this.binding(PHX_AUTO_RECOVER)) || form.getAttribute(this.binding("change"));
      js_default.exec("change", phxEvent, view, input, ["push", { _target: input.name, newCid, callback }]);
    });
  }
  pushLinkPatch(href, targetEl, callback) {
    let linkRef = this.liveSocket.setPendingLink(href);
    let refGen = targetEl ? () => this.putRef([targetEl], "click") : null;
    let fallback = () => this.liveSocket.redirect(window.location.href);
    let push = this.pushWithReply(refGen, "live_patch", { url: href }, (resp) => {
      this.liveSocket.requestDOMUpdate(() => {
        if (resp.link_redirect) {
          this.liveSocket.replaceMain(href, null, callback, linkRef);
        } else {
          if (this.liveSocket.commitPendingLink(linkRef)) {
            this.href = href;
          }
          this.applyPendingUpdates();
          callback && callback(linkRef);
        }
      });
    });
    if (push) {
      push.receive("timeout", fallback);
    } else {
      fallback();
    }
  }
  formsForRecovery(html) {
    if (this.joinCount === 0) {
      return [];
    }
    let phxChange = this.binding("change");
    let template = document.createElement("template");
    template.innerHTML = html;
    return dom_default.all(this.el, `form[${phxChange}]`).filter((form) => form.id && this.ownsElement(form)).filter((form) => form.elements.length > 0).filter((form) => form.getAttribute(this.binding(PHX_AUTO_RECOVER)) !== "ignore").map((form) => {
      let newForm = template.content.querySelector(`form[id="${form.id}"][${phxChange}="${form.getAttribute(phxChange)}"]`);
      if (newForm) {
        return [form, newForm, this.targetComponentID(newForm)];
      } else {
        return [form, null, null];
      }
    }).filter(([form, newForm, newCid]) => newForm);
  }
  maybePushComponentsDestroyed(destroyedCIDs) {
    let willDestroyCIDs = destroyedCIDs.filter((cid) => {
      return dom_default.findComponentNodeList(this.el, cid).length === 0;
    });
    if (willDestroyCIDs.length > 0) {
      this.pruningCIDs.push(...willDestroyCIDs);
      this.pushWithReply(null, "cids_will_destroy", { cids: willDestroyCIDs }, () => {
        this.pruningCIDs = this.pruningCIDs.filter((cid) => willDestroyCIDs.indexOf(cid) !== -1);
        let completelyDestroyCIDs = willDestroyCIDs.filter((cid) => {
          return dom_default.findComponentNodeList(this.el, cid).length === 0;
        });
        if (completelyDestroyCIDs.length > 0) {
          this.pushWithReply(null, "cids_destroyed", { cids: completelyDestroyCIDs }, (resp) => {
            this.rendered.pruneCIDs(resp.cids);
          });
        }
      });
    }
  }
  ownsElement(el) {
    let parentViewEl = el.closest(PHX_VIEW_SELECTOR);
    return el.getAttribute(PHX_PARENT_ID) === this.id || parentViewEl && parentViewEl.id === this.id || !parentViewEl && this.isDead;
  }
  submitForm(form, targetCtx, phxEvent, submitter, opts = {}) {
    dom_default.putPrivate(form, PHX_HAS_SUBMITTED, true);
    let phxFeedback = this.liveSocket.binding(PHX_FEEDBACK_FOR);
    let inputs = Array.from(form.elements);
    inputs.forEach((input) => dom_default.putPrivate(input, PHX_HAS_SUBMITTED, true));
    this.liveSocket.blurActiveElement(this);
    this.pushFormSubmit(form, targetCtx, phxEvent, submitter, opts, () => {
      inputs.forEach((input) => dom_default.showError(input, phxFeedback));
      this.liveSocket.restorePreviouslyActiveFocus();
    });
  }
  binding(kind) {
    return this.liveSocket.binding(kind);
  }
};
var LiveSocket = class {
  constructor(url, phxSocket, opts = {}) {
    this.unloaded = false;
    if (!phxSocket || phxSocket.constructor.name === "Object") {
      throw new Error(`
      a phoenix Socket must be provided as the second argument to the LiveSocket constructor. For example:

          import {Socket} from "phoenix"
          import {LiveSocket} from "phoenix_live_view"
          let liveSocket = new LiveSocket("/live", Socket, {...})
      `);
    }
    this.socket = new phxSocket(url, opts);
    this.bindingPrefix = opts.bindingPrefix || BINDING_PREFIX;
    this.opts = opts;
    this.params = closure2(opts.params || {});
    this.viewLogger = opts.viewLogger;
    this.metadataCallbacks = opts.metadata || {};
    this.defaults = Object.assign(clone(DEFAULTS), opts.defaults || {});
    this.activeElement = null;
    this.prevActive = null;
    this.silenced = false;
    this.main = null;
    this.outgoingMainEl = null;
    this.clickStartedAtTarget = null;
    this.linkRef = 1;
    this.roots = {};
    this.href = window.location.href;
    this.pendingLink = null;
    this.currentLocation = clone(window.location);
    this.hooks = opts.hooks || {};
    this.uploaders = opts.uploaders || {};
    this.loaderTimeout = opts.loaderTimeout || LOADER_TIMEOUT;
    this.reloadWithJitterTimer = null;
    this.maxReloads = opts.maxReloads || MAX_RELOADS;
    this.reloadJitterMin = opts.reloadJitterMin || RELOAD_JITTER_MIN;
    this.reloadJitterMax = opts.reloadJitterMax || RELOAD_JITTER_MAX;
    this.failsafeJitter = opts.failsafeJitter || FAILSAFE_JITTER;
    this.localStorage = opts.localStorage || window.localStorage;
    this.sessionStorage = opts.sessionStorage || window.sessionStorage;
    this.boundTopLevelEvents = false;
    this.domCallbacks = Object.assign({ onNodeAdded: closure2(), onBeforeElUpdated: closure2() }, opts.dom || {});
    this.transitions = new TransitionSet();
    window.addEventListener("pagehide", (_e) => {
      this.unloaded = true;
    });
    this.socket.onOpen(() => {
      if (this.isUnloaded()) {
        window.location.reload();
      }
    });
  }
  isProfileEnabled() {
    return this.sessionStorage.getItem(PHX_LV_PROFILE) === "true";
  }
  isDebugEnabled() {
    return this.sessionStorage.getItem(PHX_LV_DEBUG) === "true";
  }
  isDebugDisabled() {
    return this.sessionStorage.getItem(PHX_LV_DEBUG) === "false";
  }
  enableDebug() {
    this.sessionStorage.setItem(PHX_LV_DEBUG, "true");
  }
  enableProfiling() {
    this.sessionStorage.setItem(PHX_LV_PROFILE, "true");
  }
  disableDebug() {
    this.sessionStorage.setItem(PHX_LV_DEBUG, "false");
  }
  disableProfiling() {
    this.sessionStorage.removeItem(PHX_LV_PROFILE);
  }
  enableLatencySim(upperBoundMs) {
    this.enableDebug();
    console.log("latency simulator enabled for the duration of this browser session. Call disableLatencySim() to disable");
    this.sessionStorage.setItem(PHX_LV_LATENCY_SIM, upperBoundMs);
  }
  disableLatencySim() {
    this.sessionStorage.removeItem(PHX_LV_LATENCY_SIM);
  }
  getLatencySim() {
    let str = this.sessionStorage.getItem(PHX_LV_LATENCY_SIM);
    return str ? parseInt(str) : null;
  }
  getSocket() {
    return this.socket;
  }
  connect() {
    if (window.location.hostname === "localhost" && !this.isDebugDisabled()) {
      this.enableDebug();
    }
    let doConnect = () => {
      if (this.joinRootViews()) {
        this.bindTopLevelEvents();
        this.socket.connect();
      } else if (this.main) {
        this.socket.connect();
      } else {
        this.bindTopLevelEvents({ dead: true });
      }
      this.joinDeadView();
    };
    if (["complete", "loaded", "interactive"].indexOf(document.readyState) >= 0) {
      doConnect();
    } else {
      document.addEventListener("DOMContentLoaded", () => doConnect());
    }
  }
  disconnect(callback) {
    clearTimeout(this.reloadWithJitterTimer);
    this.socket.disconnect(callback);
  }
  replaceTransport(transport) {
    clearTimeout(this.reloadWithJitterTimer);
    this.socket.replaceTransport(transport);
    this.connect();
  }
  execJS(el, encodedJS, eventType = null) {
    this.owner(el, (view) => js_default.exec(eventType, encodedJS, view, el));
  }
  unload() {
    if (this.unloaded) {
      return;
    }
    if (this.main && this.isConnected()) {
      this.log(this.main, "socket", () => ["disconnect for page nav"]);
    }
    this.unloaded = true;
    this.destroyAllViews();
    this.disconnect();
  }
  triggerDOM(kind, args) {
    this.domCallbacks[kind](...args);
  }
  time(name, func) {
    if (!this.isProfileEnabled() || !console.time) {
      return func();
    }
    console.time(name);
    let result = func();
    console.timeEnd(name);
    return result;
  }
  log(view, kind, msgCallback) {
    if (this.viewLogger) {
      let [msg, obj] = msgCallback();
      this.viewLogger(view, kind, msg, obj);
    } else if (this.isDebugEnabled()) {
      let [msg, obj] = msgCallback();
      debug(view, kind, msg, obj);
    }
  }
  requestDOMUpdate(callback) {
    this.transitions.after(callback);
  }
  transition(time, onStart, onDone = function() {
  }) {
    this.transitions.addTransition(time, onStart, onDone);
  }
  onChannel(channel, event, cb) {
    channel.on(event, (data) => {
      let latency = this.getLatencySim();
      if (!latency) {
        cb(data);
      } else {
        setTimeout(() => cb(data), latency);
      }
    });
  }
  wrapPush(view, opts, push) {
    let latency = this.getLatencySim();
    let oldJoinCount = view.joinCount;
    if (!latency) {
      if (this.isConnected() && opts.timeout) {
        return push().receive("timeout", () => {
          if (view.joinCount === oldJoinCount && !view.isDestroyed()) {
            this.reloadWithJitter(view, () => {
              this.log(view, "timeout", () => ["received timeout while communicating with server. Falling back to hard refresh for recovery"]);
            });
          }
        });
      } else {
        return push();
      }
    }
    let fakePush = {
      receives: [],
      receive(kind, cb) {
        this.receives.push([kind, cb]);
      }
    };
    setTimeout(() => {
      if (view.isDestroyed()) {
        return;
      }
      fakePush.receives.reduce((acc, [kind, cb]) => acc.receive(kind, cb), push());
    }, latency);
    return fakePush;
  }
  reloadWithJitter(view, log) {
    clearTimeout(this.reloadWithJitterTimer);
    this.disconnect();
    let minMs = this.reloadJitterMin;
    let maxMs = this.reloadJitterMax;
    let afterMs = Math.floor(Math.random() * (maxMs - minMs + 1)) + minMs;
    let tries = browser_default.updateLocal(this.localStorage, window.location.pathname, CONSECUTIVE_RELOADS, 0, (count) => count + 1);
    if (tries > this.maxReloads) {
      afterMs = this.failsafeJitter;
    }
    this.reloadWithJitterTimer = setTimeout(() => {
      if (view.isDestroyed() || view.isConnected()) {
        return;
      }
      view.destroy();
      log ? log() : this.log(view, "join", () => [`encountered ${tries} consecutive reloads`]);
      if (tries > this.maxReloads) {
        this.log(view, "join", () => [`exceeded ${this.maxReloads} consecutive reloads. Entering failsafe mode`]);
      }
      if (this.hasPendingLink()) {
        window.location = this.pendingLink;
      } else {
        window.location.reload();
      }
    }, afterMs);
  }
  getHookCallbacks(name) {
    return name && name.startsWith("Phoenix.") ? hooks_default[name.split(".")[1]] : this.hooks[name];
  }
  isUnloaded() {
    return this.unloaded;
  }
  isConnected() {
    return this.socket.isConnected();
  }
  getBindingPrefix() {
    return this.bindingPrefix;
  }
  binding(kind) {
    return `${this.getBindingPrefix()}${kind}`;
  }
  channel(topic, params) {
    return this.socket.channel(topic, params);
  }
  joinDeadView() {
    let body = document.body;
    if (body && !this.isPhxView(body) && !this.isPhxView(document.firstElementChild)) {
      let view = this.newRootView(body);
      view.setHref(this.getHref());
      view.joinDead();
      if (!this.main) {
        this.main = view;
      }
      window.requestAnimationFrame(() => view.execNewMounted());
    }
  }
  joinRootViews() {
    let rootsFound = false;
    dom_default.all(document, `${PHX_VIEW_SELECTOR}:not([${PHX_PARENT_ID}])`, (rootEl) => {
      if (!this.getRootById(rootEl.id)) {
        let view = this.newRootView(rootEl);
        view.setHref(this.getHref());
        view.join();
        if (rootEl.hasAttribute(PHX_MAIN)) {
          this.main = view;
        }
      }
      rootsFound = true;
    });
    return rootsFound;
  }
  redirect(to, flash) {
    this.unload();
    browser_default.redirect(to, flash);
  }
  replaceMain(href, flash, callback = null, linkRef = this.setPendingLink(href)) {
    let liveReferer = this.currentLocation.href;
    this.outgoingMainEl = this.outgoingMainEl || this.main.el;
    let newMainEl = dom_default.cloneNode(this.outgoingMainEl, "");
    this.main.showLoader(this.loaderTimeout);
    this.main.destroy();
    this.main = this.newRootView(newMainEl, flash, liveReferer);
    this.main.setRedirect(href);
    this.transitionRemoves();
    this.main.join((joinCount, onDone) => {
      if (joinCount === 1 && this.commitPendingLink(linkRef)) {
        this.requestDOMUpdate(() => {
          dom_default.findPhxSticky(document).forEach((el) => newMainEl.appendChild(el));
          this.outgoingMainEl.replaceWith(newMainEl);
          this.outgoingMainEl = null;
          callback && requestAnimationFrame(callback);
          onDone();
        });
      }
    });
  }
  transitionRemoves(elements) {
    let removeAttr = this.binding("remove");
    elements = elements || dom_default.all(document, `[${removeAttr}]`);
    elements.forEach((el) => {
      if (document.body.contains(el)) {
        this.execJS(el, el.getAttribute(removeAttr), "remove");
      }
    });
  }
  isPhxView(el) {
    return el.getAttribute && el.getAttribute(PHX_SESSION) !== null;
  }
  newRootView(el, flash, liveReferer) {
    let view = new View(el, this, null, flash, liveReferer);
    this.roots[view.id] = view;
    return view;
  }
  owner(childEl, callback) {
    let view = maybe(childEl.closest(PHX_VIEW_SELECTOR), (el) => this.getViewByEl(el)) || this.main;
    if (view) {
      callback(view);
    }
  }
  withinOwners(childEl, callback) {
    this.owner(childEl, (view) => callback(view, childEl));
  }
  getViewByEl(el) {
    let rootId = el.getAttribute(PHX_ROOT_ID);
    return maybe(this.getRootById(rootId), (root) => root.getDescendentByEl(el));
  }
  getRootById(id) {
    return this.roots[id];
  }
  destroyAllViews() {
    for (let id in this.roots) {
      this.roots[id].destroy();
      delete this.roots[id];
    }
    this.main = null;
  }
  destroyViewByEl(el) {
    let root = this.getRootById(el.getAttribute(PHX_ROOT_ID));
    if (root && root.id === el.id) {
      root.destroy();
      delete this.roots[root.id];
    } else if (root) {
      root.destroyDescendent(el.id);
    }
  }
  setActiveElement(target) {
    if (this.activeElement === target) {
      return;
    }
    this.activeElement = target;
    let cancel = () => {
      if (target === this.activeElement) {
        this.activeElement = null;
      }
      target.removeEventListener("mouseup", this);
      target.removeEventListener("touchend", this);
    };
    target.addEventListener("mouseup", cancel);
    target.addEventListener("touchend", cancel);
  }
  getActiveElement() {
    if (document.activeElement === document.body) {
      return this.activeElement || document.activeElement;
    } else {
      return document.activeElement || document.body;
    }
  }
  dropActiveElement(view) {
    if (this.prevActive && view.ownsElement(this.prevActive)) {
      this.prevActive = null;
    }
  }
  restorePreviouslyActiveFocus() {
    if (this.prevActive && this.prevActive !== document.body) {
      this.prevActive.focus();
    }
  }
  blurActiveElement() {
    this.prevActive = this.getActiveElement();
    if (this.prevActive !== document.body) {
      this.prevActive.blur();
    }
  }
  bindTopLevelEvents({ dead } = {}) {
    if (this.boundTopLevelEvents) {
      return;
    }
    this.boundTopLevelEvents = true;
    this.socket.onClose((event) => {
      if (event && event.code === 1001) {
        return this.unload();
      }
      if (event && event.code === 1e3 && this.main) {
        return this.reloadWithJitter(this.main);
      }
    });
    document.body.addEventListener("click", function() {
    });
    window.addEventListener("pageshow", (e) => {
      if (e.persisted) {
        this.getSocket().disconnect();
        this.withPageLoading({ to: window.location.href, kind: "redirect" });
        window.location.reload();
      }
    }, true);
    if (!dead) {
      this.bindNav();
    }
    this.bindClicks();
    if (!dead) {
      this.bindForms();
    }
    this.bind({ keyup: "keyup", keydown: "keydown" }, (e, type, view, targetEl, phxEvent, eventTarget) => {
      let matchKey = targetEl.getAttribute(this.binding(PHX_KEY));
      let pressedKey = e.key && e.key.toLowerCase();
      if (matchKey && matchKey.toLowerCase() !== pressedKey) {
        return;
      }
      let data = { key: e.key, ...this.eventMeta(type, e, targetEl) };
      js_default.exec(type, phxEvent, view, targetEl, ["push", { data }]);
    });
    this.bind({ blur: "focusout", focus: "focusin" }, (e, type, view, targetEl, phxEvent, eventTarget) => {
      if (!eventTarget) {
        let data = { key: e.key, ...this.eventMeta(type, e, targetEl) };
        js_default.exec(type, phxEvent, view, targetEl, ["push", { data }]);
      }
    });
    this.bind({ blur: "blur", focus: "focus" }, (e, type, view, targetEl, targetCtx, phxEvent, phxTarget) => {
      if (phxTarget === "window") {
        let data = this.eventMeta(type, e, targetEl);
        js_default.exec(type, phxEvent, view, targetEl, ["push", { data }]);
      }
    });
    window.addEventListener("dragover", (e) => e.preventDefault());
    window.addEventListener("drop", (e) => {
      e.preventDefault();
      let dropTargetId = maybe(closestPhxBinding(e.target, this.binding(PHX_DROP_TARGET)), (trueTarget) => {
        return trueTarget.getAttribute(this.binding(PHX_DROP_TARGET));
      });
      let dropTarget = dropTargetId && document.getElementById(dropTargetId);
      let files = Array.from(e.dataTransfer.files || []);
      if (!dropTarget || dropTarget.disabled || files.length === 0 || !(dropTarget.files instanceof FileList)) {
        return;
      }
      LiveUploader.trackFiles(dropTarget, files, e.dataTransfer);
      dropTarget.dispatchEvent(new Event("input", { bubbles: true }));
    });
    this.on(PHX_TRACK_UPLOADS, (e) => {
      let uploadTarget = e.target;
      if (!dom_default.isUploadInput(uploadTarget)) {
        return;
      }
      let files = Array.from(e.detail.files || []).filter((f) => f instanceof File || f instanceof Blob);
      LiveUploader.trackFiles(uploadTarget, files);
      uploadTarget.dispatchEvent(new Event("input", { bubbles: true }));
    });
  }
  eventMeta(eventName, e, targetEl) {
    let callback = this.metadataCallbacks[eventName];
    return callback ? callback(e, targetEl) : {};
  }
  setPendingLink(href) {
    this.linkRef++;
    this.pendingLink = href;
    return this.linkRef;
  }
  commitPendingLink(linkRef) {
    if (this.linkRef !== linkRef) {
      return false;
    } else {
      this.href = this.pendingLink;
      this.pendingLink = null;
      return true;
    }
  }
  getHref() {
    return this.href;
  }
  hasPendingLink() {
    return !!this.pendingLink;
  }
  bind(events, callback) {
    for (let event in events) {
      let browserEventName = events[event];
      this.on(browserEventName, (e) => {
        let binding = this.binding(event);
        let windowBinding = this.binding(`window-${event}`);
        let targetPhxEvent = e.target.getAttribute && e.target.getAttribute(binding);
        if (targetPhxEvent) {
          this.debounce(e.target, e, browserEventName, () => {
            this.withinOwners(e.target, (view) => {
              callback(e, event, view, e.target, targetPhxEvent, null);
            });
          });
        } else {
          dom_default.all(document, `[${windowBinding}]`, (el) => {
            let phxEvent = el.getAttribute(windowBinding);
            this.debounce(el, e, browserEventName, () => {
              this.withinOwners(el, (view) => {
                callback(e, event, view, el, phxEvent, "window");
              });
            });
          });
        }
      });
    }
  }
  bindClicks() {
    window.addEventListener("click", (e) => this.clickStartedAtTarget = e.target);
    this.bindClick("click", "click", false);
    this.bindClick("mousedown", "capture-click", true);
  }
  bindClick(eventName, bindingName, capture) {
    let click = this.binding(bindingName);
    window.addEventListener(eventName, (e) => {
      let target = null;
      if (capture) {
        target = e.target.matches(`[${click}]`) ? e.target : e.target.querySelector(`[${click}]`);
      } else {
        let clickStartedAtTarget = this.clickStartedAtTarget || e.target;
        target = closestPhxBinding(clickStartedAtTarget, click);
        this.dispatchClickAway(e, clickStartedAtTarget);
        this.clickStartedAtTarget = null;
      }
      let phxEvent = target && target.getAttribute(click);
      if (!phxEvent) {
        let href = e.target instanceof HTMLAnchorElement ? e.target.getAttribute("href") : null;
        if (!capture && href !== null && !dom_default.wantsNewTab(e) && dom_default.isNewPageHref(href, window.location)) {
          this.unload();
        }
        return;
      }
      if (target.getAttribute("href") === "#") {
        e.preventDefault();
      }
      this.debounce(target, e, "click", () => {
        this.withinOwners(target, (view) => {
          js_default.exec("click", phxEvent, view, target, ["push", { data: this.eventMeta("click", e, target) }]);
        });
      });
    }, capture);
  }
  dispatchClickAway(e, clickStartedAt) {
    let phxClickAway = this.binding("click-away");
    dom_default.all(document, `[${phxClickAway}]`, (el) => {
      if (!(el.isSameNode(clickStartedAt) || el.contains(clickStartedAt))) {
        this.withinOwners(e.target, (view) => {
          let phxEvent = el.getAttribute(phxClickAway);
          if (js_default.isVisible(el)) {
            js_default.exec("click", phxEvent, view, el, ["push", { data: this.eventMeta("click", e, e.target) }]);
          }
        });
      }
    });
  }
  bindNav() {
    if (!browser_default.canPushState()) {
      return;
    }
    if (history.scrollRestoration) {
      history.scrollRestoration = "manual";
    }
    let scrollTimer = null;
    window.addEventListener("scroll", (_e) => {
      clearTimeout(scrollTimer);
      scrollTimer = setTimeout(() => {
        browser_default.updateCurrentState((state) => Object.assign(state, { scroll: window.scrollY }));
      }, 100);
    });
    window.addEventListener("popstate", (event) => {
      if (!this.registerNewLocation(window.location)) {
        return;
      }
      let { type, id, root, scroll } = event.state || {};
      let href = window.location.href;
      this.requestDOMUpdate(() => {
        if (this.main.isConnected() && (type === "patch" && id === this.main.id)) {
          this.main.pushLinkPatch(href, null, () => {
            this.maybeScroll(scroll);
          });
        } else {
          this.replaceMain(href, null, () => {
            if (root) {
              this.replaceRootHistory();
            }
            this.maybeScroll(scroll);
          });
        }
      });
    }, false);
    window.addEventListener("click", (e) => {
      let target = closestPhxBinding(e.target, PHX_LIVE_LINK);
      let type = target && target.getAttribute(PHX_LIVE_LINK);
      if (!type || !this.isConnected() || !this.main || dom_default.wantsNewTab(e)) {
        return;
      }
      let href = target.href;
      let linkState = target.getAttribute(PHX_LINK_STATE);
      e.preventDefault();
      e.stopImmediatePropagation();
      if (this.pendingLink === href) {
        return;
      }
      this.requestDOMUpdate(() => {
        if (type === "patch") {
          this.pushHistoryPatch(href, linkState, target);
        } else if (type === "redirect") {
          this.historyRedirect(href, linkState);
        } else {
          throw new Error(`expected ${PHX_LIVE_LINK} to be "patch" or "redirect", got: ${type}`);
        }
        let phxClick = target.getAttribute(this.binding("click"));
        if (phxClick) {
          this.requestDOMUpdate(() => this.execJS(target, phxClick, "click"));
        }
      });
    }, false);
  }
  maybeScroll(scroll) {
    if (typeof scroll === "number") {
      requestAnimationFrame(() => {
        window.scrollTo(0, scroll);
      });
    }
  }
  dispatchEvent(event, payload = {}) {
    dom_default.dispatchEvent(window, `phx:${event}`, { detail: payload });
  }
  dispatchEvents(events) {
    events.forEach(([event, payload]) => this.dispatchEvent(event, payload));
  }
  withPageLoading(info, callback) {
    dom_default.dispatchEvent(window, "phx:page-loading-start", { detail: info });
    let done = () => dom_default.dispatchEvent(window, "phx:page-loading-stop", { detail: info });
    return callback ? callback(done) : done;
  }
  pushHistoryPatch(href, linkState, targetEl) {
    if (!this.isConnected()) {
      return browser_default.redirect(href);
    }
    this.withPageLoading({ to: href, kind: "patch" }, (done) => {
      this.main.pushLinkPatch(href, targetEl, (linkRef) => {
        this.historyPatch(href, linkState, linkRef);
        done();
      });
    });
  }
  historyPatch(href, linkState, linkRef = this.setPendingLink(href)) {
    if (!this.commitPendingLink(linkRef)) {
      return;
    }
    browser_default.pushState(linkState, { type: "patch", id: this.main.id }, href);
    this.registerNewLocation(window.location);
  }
  historyRedirect(href, linkState, flash) {
    if (!this.isConnected()) {
      return browser_default.redirect(href, flash);
    }
    if (/^\/$|^\/[^\/]+.*$/.test(href)) {
      let { protocol, host } = window.location;
      href = `${protocol}//${host}${href}`;
    }
    let scroll = window.scrollY;
    this.withPageLoading({ to: href, kind: "redirect" }, (done) => {
      this.replaceMain(href, flash, () => {
        browser_default.pushState(linkState, { type: "redirect", id: this.main.id, scroll }, href);
        this.registerNewLocation(window.location);
        done();
      });
    });
  }
  replaceRootHistory() {
    browser_default.pushState("replace", { root: true, type: "patch", id: this.main.id });
  }
  registerNewLocation(newLocation) {
    let { pathname, search } = this.currentLocation;
    if (pathname + search === newLocation.pathname + newLocation.search) {
      return false;
    } else {
      this.currentLocation = clone(newLocation);
      return true;
    }
  }
  bindForms() {
    let iterations = 0;
    let externalFormSubmitted = false;
    this.on("submit", (e) => {
      let phxSubmit = e.target.getAttribute(this.binding("submit"));
      let phxChange = e.target.getAttribute(this.binding("change"));
      if (!externalFormSubmitted && phxChange && !phxSubmit) {
        externalFormSubmitted = true;
        e.preventDefault();
        this.withinOwners(e.target, (view) => {
          view.disableForm(e.target);
          window.requestAnimationFrame(() => {
            if (dom_default.isUnloadableFormSubmit(e)) {
              this.unload();
            }
            e.target.submit();
          });
        });
      }
    }, true);
    this.on("submit", (e) => {
      let phxEvent = e.target.getAttribute(this.binding("submit"));
      if (!phxEvent) {
        if (dom_default.isUnloadableFormSubmit(e)) {
          this.unload();
        }
        return;
      }
      e.preventDefault();
      e.target.disabled = true;
      this.withinOwners(e.target, (view) => {
        js_default.exec("submit", phxEvent, view, e.target, ["push", { submitter: e.submitter }]);
      });
    }, false);
    for (let type of ["change", "input"]) {
      this.on(type, (e) => {
        let phxChange = this.binding("change");
        let input = e.target;
        let inputEvent = input.getAttribute(phxChange);
        let formEvent = input.form && input.form.getAttribute(phxChange);
        let phxEvent = inputEvent || formEvent;
        if (!phxEvent) {
          return;
        }
        if (input.type === "number" && input.validity && input.validity.badInput) {
          return;
        }
        let dispatcher = inputEvent ? input : input.form;
        let currentIterations = iterations;
        iterations++;
        let { at, type: lastType } = dom_default.private(input, "prev-iteration") || {};
        if (at === currentIterations - 1 && type !== lastType) {
          return;
        }
        dom_default.putPrivate(input, "prev-iteration", { at: currentIterations, type });
        this.debounce(input, e, type, () => {
          this.withinOwners(dispatcher, (view) => {
            dom_default.putPrivate(input, PHX_HAS_FOCUSED, true);
            if (!dom_default.isTextualInput(input)) {
              this.setActiveElement(input);
            }
            js_default.exec("change", phxEvent, view, input, ["push", { _target: e.target.name, dispatcher }]);
          });
        });
      }, false);
    }
    this.on("reset", (e) => {
      let form = e.target;
      dom_default.resetForm(form, this.binding(PHX_FEEDBACK_FOR));
      let input = Array.from(form.elements).find((el) => el.type === "reset");
      window.requestAnimationFrame(() => {
        input.dispatchEvent(new Event("input", { bubbles: true, cancelable: false }));
      });
    });
  }
  debounce(el, event, eventType, callback) {
    if (eventType === "blur" || eventType === "focusout") {
      return callback();
    }
    let phxDebounce = this.binding(PHX_DEBOUNCE);
    let phxThrottle = this.binding(PHX_THROTTLE);
    let defaultDebounce = this.defaults.debounce.toString();
    let defaultThrottle = this.defaults.throttle.toString();
    this.withinOwners(el, (view) => {
      let asyncFilter = () => !view.isDestroyed() && document.body.contains(el);
      dom_default.debounce(el, event, phxDebounce, defaultDebounce, phxThrottle, defaultThrottle, asyncFilter, () => {
        callback();
      });
    });
  }
  silenceEvents(callback) {
    this.silenced = true;
    callback();
    this.silenced = false;
  }
  on(event, callback) {
    window.addEventListener(event, (e) => {
      if (!this.silenced) {
        callback(e);
      }
    });
  }
};
var TransitionSet = class {
  constructor() {
    this.transitions = /* @__PURE__ */ new Set();
    this.pendingOps = [];
  }
  reset() {
    this.transitions.forEach((timer) => {
      clearTimeout(timer);
      this.transitions.delete(timer);
    });
    this.flushPendingOps();
  }
  after(callback) {
    if (this.size() === 0) {
      callback();
    } else {
      this.pushPendingOp(callback);
    }
  }
  addTransition(time, onStart, onDone) {
    onStart();
    let timer = setTimeout(() => {
      this.transitions.delete(timer);
      onDone();
      this.flushPendingOps();
    }, time);
    this.transitions.add(timer);
  }
  pushPendingOp(op) {
    this.pendingOps.push(op);
  }
  size() {
    return this.transitions.size;
  }
  flushPendingOps() {
    if (this.size() > 0) {
      return;
    }
    let op = this.pendingOps.shift();
    if (op) {
      op();
      this.flushPendingOps();
    }
  }
};

// js/app.js
var import_topbar = __toESM(require_topbar());

// js/job-editor/mount.tsx
var import_react = __toESM(require_react());
var import_client = __toESM(require_client());

// js/metadata-loader/metadata.ts
var sortArr = (arr) => {
  arr.sort((a, b) => {
    const astr = typeof a === "string" ? a : a.name;
    const bstr = typeof b === "string" ? b : b.name;
    if (astr === bstr)
      return 0;
    if (astr > bstr) {
      return 1;
    } else {
      return -1;
    }
  });
  return arr;
};
var sortDeep = (model) => {
  if (model.children) {
    if (Array.isArray(model.children)) {
      model.children = sortArr(model.children.map(sortDeep));
    } else {
      const keys = Object.keys(model.children).sort();
      model.children = keys.reduce((acc, key) => {
        acc[key] = sortArr(model.children[key].map(sortDeep));
        return acc;
      }, {});
    }
  }
  return model;
};

// js/job-editor/mount.tsx
var JobEditorComponent;
var mount_default = {
  mounted() {
    import("../JobEditor-GCUUABJD.js").then((module) => {
      JobEditorComponent = module.default;
      this.componentRoot = (0, import_client.createRoot)(this.el);
      const { changeEvent } = this.el.dataset;
      if (changeEvent) {
        this.changeEvent = changeEvent;
      } else {
        console.warn("Warning: No changeEvent set. Content will not sync.");
      }
      this.setupObserver();
      this.render();
      this.requestMetadata().then(() => this.render());
    });
  },
  handleContentChange(content) {
    this.pushEventTo(this.el, this.changeEvent, { source: content });
  },
  render() {
    const { adaptor, source, disabled } = this.el.dataset;
    if (JobEditorComponent) {
      this.componentRoot?.render(
        /* @__PURE__ */ import_react.default.createElement(
          JobEditorComponent,
          {
            adaptor,
            source,
            metadata: this.metadata,
            disabled: disabled === "true",
            onSourceChanged: (src) => this.handleContentChange(src)
          }
        )
      );
    }
  },
  requestMetadata() {
    this.metadata = true;
    this.render();
    return new Promise((resolve) => {
      const callbackRef = this.handleEvent("metadata_ready", (data) => {
        this.removeHandleEvent(callbackRef);
        const sortedMetadata = sortDeep(data);
        this.metadata = sortedMetadata;
        resolve(sortedMetadata);
      });
      this.pushEventTo(this.el, "request_metadata", {});
    });
  },
  setupObserver() {
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        const { attributeName, oldValue } = mutation;
        const newValue = this.el.getAttribute(attributeName);
        if (oldValue !== newValue) {
          this.render();
        }
      });
    });
    this.observer.observe(this.el, {
      attributeFilter: ["data-adaptor", "data-change-event"],
      attributeOldValue: true
    });
  },
  destroyed() {
    this.componentRoot?.unmount();
    this.observer?.disconnect();
  }
};

// js/job-editor/index.ts
var job_editor_default = mount_default;

// js/workflow-diagram/index.ts
var workflow_diagram_default = {
  mounted() {
    const basePath = this.el.getAttribute("base-path");
    if (!basePath) {
      throw new Error("Workflow Diagram expects a `base-path` attribute.");
    }
    this.baseUrl = new URL(basePath, window.location.origin);
    import("./workflow-diagram/component.js").then(({ mount }) => {
      this.component = mount(this.el);
      this.setupObserver();
      if (!this.component) {
        throw new Error("Component not set.");
      }
      this.updateProjectSpace(this.el.dataset.projectSpace);
      this.setSelectedNode(this.el.dataset.selectedNode);
      this.component.update({
        onJobAddClick: (node) => {
          this.addJob(node.data.id);
        },
        onNodeClick: (event, node) => {
          switch (node.type) {
            case "trigger":
              if (node.data.trigger.type === "webhook") {
                this.copyWebhookUrl(node.data.trigger.webhookUrl);
              }
              break;
            case "job":
              this.selectJob(node.data.id);
              break;
            case "workflow":
              this.selectWorkflow(node.data.id);
              break;
          }
        },
        onPaneClick: (_event) => {
          this.unselectNode();
        }
      });
    });
  },
  destroyed() {
    console.debug("Unmounting WorkflowDiagram component");
    this.observer?.disconnect();
    this.component?.unmount();
  },
  setupObserver() {
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        const { attributeName, oldValue } = mutation;
        const newValue = this.el.getAttribute(attributeName);
        if (oldValue !== newValue) {
          switch (attributeName) {
            case "data-project-space":
              this.updateProjectSpace(newValue);
            case "data-selected-node":
              this.setSelectedNode(newValue);
          }
        }
      });
    });
    this.observer.observe(this.el, {
      attributeFilter: ["data-project-space", "data-selected-node"],
      attributeOldValue: true
    });
  },
  updateProjectSpace(encoded) {
    this.component.setProjectSpace(encoded);
  },
  setSelectedNode(id) {
    this.component.setSelectedNode(id);
  },
  // Add `j/new?upstream_id=<id>` to the URL.
  addJob(upstreamId) {
    const addJobUrl = new URL(this.baseUrl);
    addJobUrl.pathname += "/j/new";
    addJobUrl.search = new URLSearchParams({
      upstream_id: upstreamId
    }).toString();
    this.liveSocket.pushHistoryPatch(addJobUrl.toString(), "push", this.el);
  },
  // Add `j/<id>` to the URL.
  selectJob(id) {
    const selectJobUrl = new URL(this.baseUrl);
    selectJobUrl.pathname += `/j/${id}`;
    this.liveSocket.pushHistoryPatch(selectJobUrl.toString(), "push", this.el);
  },
  // Add `w/<id>` to the URL.
  selectWorkflow(id) {
    const selectWorkflowUrl = new URL(this.baseUrl);
    this.liveSocket.pushHistoryPatch(
      selectWorkflowUrl.toString(),
      "push",
      this.el
    );
  },
  copyWebhookUrl(webhookUrl) {
    navigator.clipboard.writeText(webhookUrl);
    this.pushEvent("copied_to_clipboard", {});
  },
  // Remove `?selected=<id>` from the URL.
  unselectNode() {
    this.liveSocket.pushHistoryPatch(this.baseUrl.toString(), "push", this.el);
  }
};

// node_modules/immer/dist/immer.mjs
var NOTHING = Symbol.for("immer-nothing");
var DRAFTABLE = Symbol.for("immer-draftable");
var DRAFT_STATE = Symbol.for("immer-state");
var errors = true ? [
  // All error codes, starting by 0:
  function(plugin) {
    return `The plugin for '${plugin}' has not been loaded into Immer. To enable the plugin, import and call \`enable${plugin}()\` when initializing your application.`;
  },
  function(thing) {
    return `produce can only be called on things that are draftable: plain objects, arrays, Map, Set or classes that are marked with '[immerable]: true'. Got '${thing}'`;
  },
  "This object has been frozen and should not be mutated",
  function(data) {
    return "Cannot use a proxy that has been revoked. Did you pass an object from inside an immer function to an async process? " + data;
  },
  "An immer producer returned a new value *and* modified its draft. Either return a new value *or* modify the draft.",
  "Immer forbids circular references",
  "The first or second argument to `produce` must be a function",
  "The third argument to `produce` must be a function or undefined",
  "First argument to `createDraft` must be a plain object, an array, or an immerable object",
  "First argument to `finishDraft` must be a draft returned by `createDraft`",
  function(thing) {
    return `'current' expects a draft, got: ${thing}`;
  },
  "Object.defineProperty() cannot be used on an Immer draft",
  "Object.setPrototypeOf() cannot be used on an Immer draft",
  "Immer only supports deleting array indices",
  "Immer only supports setting array indices and the 'length' property",
  function(thing) {
    return `'original' expects a draft, got: ${thing}`;
  }
  // Note: if more errors are added, the errorOffset in Patches.ts should be increased
  // See Patches.ts for additional errors
] : [];
function die(error, ...args) {
  if (true) {
    const e = errors[error];
    const msg = typeof e === "function" ? e.apply(null, args) : e;
    throw new Error(`[Immer] ${msg}`);
  }
  throw new Error(
    `[Immer] minified error nr: ${error}. Full error at: https://bit.ly/3cXEKWf`
  );
}
var getPrototypeOf = Object.getPrototypeOf;
function isDraft(value) {
  return !!value && !!value[DRAFT_STATE];
}
function isDraftable(value) {
  if (!value)
    return false;
  return isPlainObject(value) || Array.isArray(value) || !!value[DRAFTABLE] || !!value.constructor?.[DRAFTABLE] || isMap(value) || isSet(value);
}
var objectCtorString = Object.prototype.constructor.toString();
function isPlainObject(value) {
  if (!value || typeof value !== "object")
    return false;
  const proto = getPrototypeOf(value);
  if (proto === null) {
    return true;
  }
  const Ctor = Object.hasOwnProperty.call(proto, "constructor") && proto.constructor;
  if (Ctor === Object)
    return true;
  return typeof Ctor == "function" && Function.toString.call(Ctor) === objectCtorString;
}
function each(obj, iter) {
  if (getArchtype(obj) === 0) {
    Object.entries(obj).forEach(([key, value]) => {
      iter(key, value, obj);
    });
  } else {
    obj.forEach((entry, index) => iter(index, entry, obj));
  }
}
function getArchtype(thing) {
  const state = thing[DRAFT_STATE];
  return state ? state.type_ : Array.isArray(thing) ? 1 : isMap(thing) ? 2 : isSet(thing) ? 3 : 0;
}
function has(thing, prop) {
  return getArchtype(thing) === 2 ? thing.has(prop) : Object.prototype.hasOwnProperty.call(thing, prop);
}
function get(thing, prop) {
  return getArchtype(thing) === 2 ? thing.get(prop) : thing[prop];
}
function set(thing, propOrOldValue, value) {
  const t = getArchtype(thing);
  if (t === 2)
    thing.set(propOrOldValue, value);
  else if (t === 3) {
    thing.add(value);
  } else
    thing[propOrOldValue] = value;
}
function is(x, y) {
  if (x === y) {
    return x !== 0 || 1 / x === 1 / y;
  } else {
    return x !== x && y !== y;
  }
}
function isMap(target) {
  return target instanceof Map;
}
function isSet(target) {
  return target instanceof Set;
}
function latest(state) {
  return state.copy_ || state.base_;
}
function shallowCopy(base, strict) {
  if (isMap(base)) {
    return new Map(base);
  }
  if (isSet(base)) {
    return new Set(base);
  }
  if (Array.isArray(base))
    return Array.prototype.slice.call(base);
  if (!strict && isPlainObject(base)) {
    if (!getPrototypeOf(base)) {
      const obj = /* @__PURE__ */ Object.create(null);
      return Object.assign(obj, base);
    }
    return { ...base };
  }
  const descriptors = Object.getOwnPropertyDescriptors(base);
  delete descriptors[DRAFT_STATE];
  let keys = Reflect.ownKeys(descriptors);
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    const desc = descriptors[key];
    if (desc.writable === false) {
      desc.writable = true;
      desc.configurable = true;
    }
    if (desc.get || desc.set)
      descriptors[key] = {
        configurable: true,
        writable: true,
        // could live with !!desc.set as well here...
        enumerable: desc.enumerable,
        value: base[key]
      };
  }
  return Object.create(getPrototypeOf(base), descriptors);
}
function freeze(obj, deep = false) {
  if (isFrozen(obj) || isDraft(obj) || !isDraftable(obj))
    return obj;
  if (getArchtype(obj) > 1) {
    obj.set = obj.add = obj.clear = obj.delete = dontMutateFrozenCollections;
  }
  Object.freeze(obj);
  if (deep)
    each(obj, (_key, value) => freeze(value, true), true);
  return obj;
}
function dontMutateFrozenCollections() {
  die(2);
}
function isFrozen(obj) {
  return Object.isFrozen(obj);
}
var plugins = {};
function getPlugin(pluginKey) {
  const plugin = plugins[pluginKey];
  if (!plugin) {
    die(0, pluginKey);
  }
  return plugin;
}
function loadPlugin(pluginKey, implementation) {
  if (!plugins[pluginKey])
    plugins[pluginKey] = implementation;
}
var currentScope;
function getCurrentScope() {
  return currentScope;
}
function createScope(parent_, immer_) {
  return {
    drafts_: [],
    parent_,
    immer_,
    // Whenever the modified draft contains a draft from another scope, we
    // need to prevent auto-freezing so the unowned draft can be finalized.
    canAutoFreeze_: true,
    unfinalizedDrafts_: 0
  };
}
function usePatchesInScope(scope, patchListener) {
  if (patchListener) {
    getPlugin("Patches");
    scope.patches_ = [];
    scope.inversePatches_ = [];
    scope.patchListener_ = patchListener;
  }
}
function revokeScope(scope) {
  leaveScope(scope);
  scope.drafts_.forEach(revokeDraft);
  scope.drafts_ = null;
}
function leaveScope(scope) {
  if (scope === currentScope) {
    currentScope = scope.parent_;
  }
}
function enterScope(immer2) {
  return currentScope = createScope(currentScope, immer2);
}
function revokeDraft(draft) {
  const state = draft[DRAFT_STATE];
  if (state.type_ === 0 || state.type_ === 1)
    state.revoke_();
  else
    state.revoked_ = true;
}
function processResult(result, scope) {
  scope.unfinalizedDrafts_ = scope.drafts_.length;
  const baseDraft = scope.drafts_[0];
  const isReplaced = result !== void 0 && result !== baseDraft;
  if (isReplaced) {
    if (baseDraft[DRAFT_STATE].modified_) {
      revokeScope(scope);
      die(4);
    }
    if (isDraftable(result)) {
      result = finalize(scope, result);
      if (!scope.parent_)
        maybeFreeze(scope, result);
    }
    if (scope.patches_) {
      getPlugin("Patches").generateReplacementPatches_(
        baseDraft[DRAFT_STATE].base_,
        result,
        scope.patches_,
        scope.inversePatches_
      );
    }
  } else {
    result = finalize(scope, baseDraft, []);
  }
  revokeScope(scope);
  if (scope.patches_) {
    scope.patchListener_(scope.patches_, scope.inversePatches_);
  }
  return result !== NOTHING ? result : void 0;
}
function finalize(rootScope, value, path) {
  if (isFrozen(value))
    return value;
  const state = value[DRAFT_STATE];
  if (!state) {
    each(
      value,
      (key, childValue) => finalizeProperty(rootScope, state, value, key, childValue, path),
      true
      // See #590, don't recurse into non-enumerable of non drafted objects
    );
    return value;
  }
  if (state.scope_ !== rootScope)
    return value;
  if (!state.modified_) {
    maybeFreeze(rootScope, state.base_, true);
    return state.base_;
  }
  if (!state.finalized_) {
    state.finalized_ = true;
    state.scope_.unfinalizedDrafts_--;
    const result = state.copy_;
    let resultEach = result;
    let isSet2 = false;
    if (state.type_ === 3) {
      resultEach = new Set(result);
      result.clear();
      isSet2 = true;
    }
    each(
      resultEach,
      (key, childValue) => finalizeProperty(rootScope, state, result, key, childValue, path, isSet2)
    );
    maybeFreeze(rootScope, result, false);
    if (path && rootScope.patches_) {
      getPlugin("Patches").generatePatches_(
        state,
        path,
        rootScope.patches_,
        rootScope.inversePatches_
      );
    }
  }
  return state.copy_;
}
function finalizeProperty(rootScope, parentState, targetObject, prop, childValue, rootPath, targetIsSet) {
  if (childValue === targetObject)
    die(5);
  if (isDraft(childValue)) {
    const path = rootPath && parentState && parentState.type_ !== 3 && // Set objects are atomic since they have no keys.
    !has(parentState.assigned_, prop) ? rootPath.concat(prop) : void 0;
    const res = finalize(rootScope, childValue, path);
    set(targetObject, prop, res);
    if (isDraft(res)) {
      rootScope.canAutoFreeze_ = false;
    } else
      return;
  } else if (targetIsSet) {
    targetObject.add(childValue);
  }
  if (isDraftable(childValue) && !isFrozen(childValue)) {
    if (!rootScope.immer_.autoFreeze_ && rootScope.unfinalizedDrafts_ < 1) {
      return;
    }
    finalize(rootScope, childValue);
    if (!parentState || !parentState.scope_.parent_)
      maybeFreeze(rootScope, childValue);
  }
}
function maybeFreeze(scope, value, deep = false) {
  if (!scope.parent_ && scope.immer_.autoFreeze_ && scope.canAutoFreeze_) {
    freeze(value, deep);
  }
}
function createProxyProxy(base, parent) {
  const isArray = Array.isArray(base);
  const state = {
    type_: isArray ? 1 : 0,
    // Track which produce call this is associated with.
    scope_: parent ? parent.scope_ : getCurrentScope(),
    // True for both shallow and deep changes.
    modified_: false,
    // Used during finalization.
    finalized_: false,
    // Track which properties have been assigned (true) or deleted (false).
    assigned_: {},
    // The parent draft state.
    parent_: parent,
    // The base state.
    base_: base,
    // The base proxy.
    draft_: null,
    // set below
    // The base copy with any updated values.
    copy_: null,
    // Called by the `produce` function.
    revoke_: null,
    isManual_: false
  };
  let target = state;
  let traps = objectTraps;
  if (isArray) {
    target = [state];
    traps = arrayTraps;
  }
  const { revoke, proxy } = Proxy.revocable(target, traps);
  state.draft_ = proxy;
  state.revoke_ = revoke;
  return proxy;
}
var objectTraps = {
  get(state, prop) {
    if (prop === DRAFT_STATE)
      return state;
    const source = latest(state);
    if (!has(source, prop)) {
      return readPropFromProto(state, source, prop);
    }
    const value = source[prop];
    if (state.finalized_ || !isDraftable(value)) {
      return value;
    }
    if (value === peek(state.base_, prop)) {
      prepareCopy(state);
      return state.copy_[prop] = createProxy(value, state);
    }
    return value;
  },
  has(state, prop) {
    return prop in latest(state);
  },
  ownKeys(state) {
    return Reflect.ownKeys(latest(state));
  },
  set(state, prop, value) {
    const desc = getDescriptorFromProto(latest(state), prop);
    if (desc?.set) {
      desc.set.call(state.draft_, value);
      return true;
    }
    if (!state.modified_) {
      const current2 = peek(latest(state), prop);
      const currentState = current2?.[DRAFT_STATE];
      if (currentState && currentState.base_ === value) {
        state.copy_[prop] = value;
        state.assigned_[prop] = false;
        return true;
      }
      if (is(value, current2) && (value !== void 0 || has(state.base_, prop)))
        return true;
      prepareCopy(state);
      markChanged(state);
    }
    if (state.copy_[prop] === value && // special case: handle new props with value 'undefined'
    (value !== void 0 || prop in state.copy_) || // special case: NaN
    Number.isNaN(value) && Number.isNaN(state.copy_[prop]))
      return true;
    state.copy_[prop] = value;
    state.assigned_[prop] = true;
    return true;
  },
  deleteProperty(state, prop) {
    if (peek(state.base_, prop) !== void 0 || prop in state.base_) {
      state.assigned_[prop] = false;
      prepareCopy(state);
      markChanged(state);
    } else {
      delete state.assigned_[prop];
    }
    if (state.copy_) {
      delete state.copy_[prop];
    }
    return true;
  },
  // Note: We never coerce `desc.value` into an Immer draft, because we can't make
  // the same guarantee in ES5 mode.
  getOwnPropertyDescriptor(state, prop) {
    const owner = latest(state);
    const desc = Reflect.getOwnPropertyDescriptor(owner, prop);
    if (!desc)
      return desc;
    return {
      writable: true,
      configurable: state.type_ !== 1 || prop !== "length",
      enumerable: desc.enumerable,
      value: owner[prop]
    };
  },
  defineProperty() {
    die(11);
  },
  getPrototypeOf(state) {
    return getPrototypeOf(state.base_);
  },
  setPrototypeOf() {
    die(12);
  }
};
var arrayTraps = {};
each(objectTraps, (key, fn) => {
  arrayTraps[key] = function() {
    arguments[0] = arguments[0][0];
    return fn.apply(this, arguments);
  };
});
arrayTraps.deleteProperty = function(state, prop) {
  if (isNaN(parseInt(prop)))
    die(13);
  return arrayTraps.set.call(this, state, prop, void 0);
};
arrayTraps.set = function(state, prop, value) {
  if (prop !== "length" && isNaN(parseInt(prop)))
    die(14);
  return objectTraps.set.call(this, state[0], prop, value, state[0]);
};
function peek(draft, prop) {
  const state = draft[DRAFT_STATE];
  const source = state ? latest(state) : draft;
  return source[prop];
}
function readPropFromProto(state, source, prop) {
  const desc = getDescriptorFromProto(source, prop);
  return desc ? `value` in desc ? desc.value : (
    // This is a very special case, if the prop is a getter defined by the
    // prototype, we should invoke it with the draft as context!
    desc.get?.call(state.draft_)
  ) : void 0;
}
function getDescriptorFromProto(source, prop) {
  if (!(prop in source))
    return void 0;
  let proto = getPrototypeOf(source);
  while (proto) {
    const desc = Object.getOwnPropertyDescriptor(proto, prop);
    if (desc)
      return desc;
    proto = getPrototypeOf(proto);
  }
  return void 0;
}
function markChanged(state) {
  if (!state.modified_) {
    state.modified_ = true;
    if (state.parent_) {
      markChanged(state.parent_);
    }
  }
}
function prepareCopy(state) {
  if (!state.copy_) {
    state.copy_ = shallowCopy(
      state.base_,
      state.scope_.immer_.useStrictShallowCopy_
    );
  }
}
var Immer2 = class {
  constructor(config) {
    this.autoFreeze_ = true;
    this.useStrictShallowCopy_ = false;
    this.produce = (base, recipe, patchListener) => {
      if (typeof base === "function" && typeof recipe !== "function") {
        const defaultBase = recipe;
        recipe = base;
        const self2 = this;
        return function curriedProduce(base2 = defaultBase, ...args) {
          return self2.produce(base2, (draft) => recipe.call(this, draft, ...args));
        };
      }
      if (typeof recipe !== "function")
        die(6);
      if (patchListener !== void 0 && typeof patchListener !== "function")
        die(7);
      let result;
      if (isDraftable(base)) {
        const scope = enterScope(this);
        const proxy = createProxy(base, void 0);
        let hasError = true;
        try {
          result = recipe(proxy);
          hasError = false;
        } finally {
          if (hasError)
            revokeScope(scope);
          else
            leaveScope(scope);
        }
        usePatchesInScope(scope, patchListener);
        return processResult(result, scope);
      } else if (!base || typeof base !== "object") {
        result = recipe(base);
        if (result === void 0)
          result = base;
        if (result === NOTHING)
          result = void 0;
        if (this.autoFreeze_)
          freeze(result, true);
        if (patchListener) {
          const p = [];
          const ip = [];
          getPlugin("Patches").generateReplacementPatches_(base, result, p, ip);
          patchListener(p, ip);
        }
        return result;
      } else
        die(1, base);
    };
    this.produceWithPatches = (base, recipe) => {
      if (typeof base === "function") {
        return (state, ...args) => this.produceWithPatches(state, (draft) => base(draft, ...args));
      }
      let patches, inversePatches;
      const result = this.produce(base, recipe, (p, ip) => {
        patches = p;
        inversePatches = ip;
      });
      return [result, patches, inversePatches];
    };
    if (typeof config?.autoFreeze === "boolean")
      this.setAutoFreeze(config.autoFreeze);
    if (typeof config?.useStrictShallowCopy === "boolean")
      this.setUseStrictShallowCopy(config.useStrictShallowCopy);
  }
  createDraft(base) {
    if (!isDraftable(base))
      die(8);
    if (isDraft(base))
      base = current(base);
    const scope = enterScope(this);
    const proxy = createProxy(base, void 0);
    proxy[DRAFT_STATE].isManual_ = true;
    leaveScope(scope);
    return proxy;
  }
  finishDraft(draft, patchListener) {
    const state = draft && draft[DRAFT_STATE];
    if (!state || !state.isManual_)
      die(9);
    const { scope_: scope } = state;
    usePatchesInScope(scope, patchListener);
    return processResult(void 0, scope);
  }
  /**
   * Pass true to automatically freeze all copies created by Immer.
   *
   * By default, auto-freezing is enabled.
   */
  setAutoFreeze(value) {
    this.autoFreeze_ = value;
  }
  /**
   * Pass true to enable strict shallow copy.
   *
   * By default, immer does not copy the object descriptors such as getter, setter and non-enumrable properties.
   */
  setUseStrictShallowCopy(value) {
    this.useStrictShallowCopy_ = value;
  }
  applyPatches(base, patches) {
    let i;
    for (i = patches.length - 1; i >= 0; i--) {
      const patch = patches[i];
      if (patch.path.length === 0 && patch.op === "replace") {
        base = patch.value;
        break;
      }
    }
    if (i > -1) {
      patches = patches.slice(i + 1);
    }
    const applyPatchesImpl = getPlugin("Patches").applyPatches_;
    if (isDraft(base)) {
      return applyPatchesImpl(base, patches);
    }
    return this.produce(
      base,
      (draft) => applyPatchesImpl(draft, patches)
    );
  }
};
function createProxy(value, parent) {
  const draft = isMap(value) ? getPlugin("MapSet").proxyMap_(value, parent) : isSet(value) ? getPlugin("MapSet").proxySet_(value, parent) : createProxyProxy(value, parent);
  const scope = parent ? parent.scope_ : getCurrentScope();
  scope.drafts_.push(draft);
  return draft;
}
function current(value) {
  if (!isDraft(value))
    die(10, value);
  return currentImpl(value);
}
function currentImpl(value) {
  if (!isDraftable(value) || isFrozen(value))
    return value;
  const state = value[DRAFT_STATE];
  let copy;
  if (state) {
    if (!state.modified_)
      return state.base_;
    state.finalized_ = true;
    copy = shallowCopy(value, state.scope_.immer_.useStrictShallowCopy_);
  } else {
    copy = shallowCopy(value, true);
  }
  each(copy, (key, childValue) => {
    set(copy, key, currentImpl(childValue));
  });
  if (state) {
    state.finalized_ = false;
  }
  return copy;
}
function enablePatches() {
  const errorOffset = 16;
  if (true) {
    errors.push(
      'Sets cannot have "replace" patches.',
      function(op) {
        return "Unsupported patch operation: " + op;
      },
      function(path) {
        return "Cannot apply patch, path doesn't resolve: " + path;
      },
      "Patching reserved attributes like __proto__, prototype and constructor is not allowed"
    );
  }
  const REPLACE = "replace";
  const ADD = "add";
  const REMOVE = "remove";
  function generatePatches_(state, basePath, patches, inversePatches) {
    switch (state.type_) {
      case 0:
      case 2:
        return generatePatchesFromAssigned(
          state,
          basePath,
          patches,
          inversePatches
        );
      case 1:
        return generateArrayPatches(state, basePath, patches, inversePatches);
      case 3:
        return generateSetPatches(
          state,
          basePath,
          patches,
          inversePatches
        );
    }
  }
  function generateArrayPatches(state, basePath, patches, inversePatches) {
    let { base_, assigned_ } = state;
    let copy_ = state.copy_;
    if (copy_.length < base_.length) {
      ;
      [base_, copy_] = [copy_, base_];
      [patches, inversePatches] = [inversePatches, patches];
    }
    for (let i = 0; i < base_.length; i++) {
      if (assigned_[i] && copy_[i] !== base_[i]) {
        const path = basePath.concat([i]);
        patches.push({
          op: REPLACE,
          path,
          // Need to maybe clone it, as it can in fact be the original value
          // due to the base/copy inversion at the start of this function
          value: clonePatchValueIfNeeded(copy_[i])
        });
        inversePatches.push({
          op: REPLACE,
          path,
          value: clonePatchValueIfNeeded(base_[i])
        });
      }
    }
    for (let i = base_.length; i < copy_.length; i++) {
      const path = basePath.concat([i]);
      patches.push({
        op: ADD,
        path,
        // Need to maybe clone it, as it can in fact be the original value
        // due to the base/copy inversion at the start of this function
        value: clonePatchValueIfNeeded(copy_[i])
      });
    }
    for (let i = copy_.length - 1; base_.length <= i; --i) {
      const path = basePath.concat([i]);
      inversePatches.push({
        op: REMOVE,
        path
      });
    }
  }
  function generatePatchesFromAssigned(state, basePath, patches, inversePatches) {
    const { base_, copy_ } = state;
    each(state.assigned_, (key, assignedValue) => {
      const origValue = get(base_, key);
      const value = get(copy_, key);
      const op = !assignedValue ? REMOVE : has(base_, key) ? REPLACE : ADD;
      if (origValue === value && op === REPLACE)
        return;
      const path = basePath.concat(key);
      patches.push(op === REMOVE ? { op, path } : { op, path, value });
      inversePatches.push(
        op === ADD ? { op: REMOVE, path } : op === REMOVE ? { op: ADD, path, value: clonePatchValueIfNeeded(origValue) } : { op: REPLACE, path, value: clonePatchValueIfNeeded(origValue) }
      );
    });
  }
  function generateSetPatches(state, basePath, patches, inversePatches) {
    let { base_, copy_ } = state;
    let i = 0;
    base_.forEach((value) => {
      if (!copy_.has(value)) {
        const path = basePath.concat([i]);
        patches.push({
          op: REMOVE,
          path,
          value
        });
        inversePatches.unshift({
          op: ADD,
          path,
          value
        });
      }
      i++;
    });
    i = 0;
    copy_.forEach((value) => {
      if (!base_.has(value)) {
        const path = basePath.concat([i]);
        patches.push({
          op: ADD,
          path,
          value
        });
        inversePatches.unshift({
          op: REMOVE,
          path,
          value
        });
      }
      i++;
    });
  }
  function generateReplacementPatches_(baseValue, replacement, patches, inversePatches) {
    patches.push({
      op: REPLACE,
      path: [],
      value: replacement === NOTHING ? void 0 : replacement
    });
    inversePatches.push({
      op: REPLACE,
      path: [],
      value: baseValue
    });
  }
  function applyPatches_(draft, patches) {
    patches.forEach((patch) => {
      const { path, op } = patch;
      let base = draft;
      for (let i = 0; i < path.length - 1; i++) {
        const parentType = getArchtype(base);
        let p = path[i];
        if (typeof p !== "string" && typeof p !== "number") {
          p = "" + p;
        }
        if ((parentType === 0 || parentType === 1) && (p === "__proto__" || p === "constructor"))
          die(errorOffset + 3);
        if (typeof base === "function" && p === "prototype")
          die(errorOffset + 3);
        base = get(base, p);
        if (typeof base !== "object")
          die(errorOffset + 2, path.join("/"));
      }
      const type = getArchtype(base);
      const value = deepClonePatchValue(patch.value);
      const key = path[path.length - 1];
      switch (op) {
        case REPLACE:
          switch (type) {
            case 2:
              return base.set(key, value);
            case 3:
              die(errorOffset);
            default:
              return base[key] = value;
          }
        case ADD:
          switch (type) {
            case 1:
              return key === "-" ? base.push(value) : base.splice(key, 0, value);
            case 2:
              return base.set(key, value);
            case 3:
              return base.add(value);
            default:
              return base[key] = value;
          }
        case REMOVE:
          switch (type) {
            case 1:
              return base.splice(key, 1);
            case 2:
              return base.delete(key);
            case 3:
              return base.delete(patch.value);
            default:
              return delete base[key];
          }
        default:
          die(errorOffset + 1, op);
      }
    });
    return draft;
  }
  function deepClonePatchValue(obj) {
    if (!isDraftable(obj))
      return obj;
    if (Array.isArray(obj))
      return obj.map(deepClonePatchValue);
    if (isMap(obj))
      return new Map(
        Array.from(obj.entries()).map(([k, v]) => [k, deepClonePatchValue(v)])
      );
    if (isSet(obj))
      return new Set(Array.from(obj).map(deepClonePatchValue));
    const cloned = Object.create(getPrototypeOf(obj));
    for (const key in obj)
      cloned[key] = deepClonePatchValue(obj[key]);
    if (has(obj, DRAFTABLE))
      cloned[DRAFTABLE] = obj[DRAFTABLE];
    return cloned;
  }
  function clonePatchValueIfNeeded(obj) {
    if (isDraft(obj)) {
      return deepClonePatchValue(obj);
    } else
      return obj;
  }
  loadPlugin("Patches", {
    applyPatches_,
    generatePatches_,
    generateReplacementPatches_
  });
}
var immer = new Immer2();
var produce = immer.produce;
var produceWithPatches = immer.produceWithPatches.bind(
  immer
);
var setAutoFreeze = immer.setAutoFreeze.bind(immer);
var setUseStrictShallowCopy = immer.setUseStrictShallowCopy.bind(immer);
var applyPatches = immer.applyPatches.bind(immer);
var createDraft = immer.createDraft.bind(immer);
var finishDraft = immer.finishDraft.bind(immer);

// js/workflow-editor/store.ts
enablePatches();
function buildNode() {
  return { id: crypto.randomUUID() };
}
function buildTrigger() {
  return { id: crypto.randomUUID() };
}
function buildEdge() {
  return { id: crypto.randomUUID() };
}
function toRFC6902Patch(patch) {
  return {
    ...patch,
    path: `/${patch.path.join("/")}`
  };
}
var createWorkflowStore = (initProps, onChange) => {
  const DEFAULT_PROPS = {
    triggers: [],
    jobs: [],
    edges: [],
    editJobUrl: ""
  };
  function proposeChanges(state, fn) {
    let patches = [];
    const nextState = produce(
      state,
      (draft) => {
        fn(draft);
      },
      (p, _inverse) => {
        patches = p.map(toRFC6902Patch);
      }
    );
    if (onChange)
      onChange({ id: crypto.randomUUID(), fn, patches });
    return nextState;
  }
  return createStore()((set2) => ({
    ...DEFAULT_PROPS,
    ...initProps,
    addJob: (job) => {
      set2(
        (state) => proposeChanges(state, (draft) => {
          const newJob = buildNode();
          draft.jobs.push(newJob);
        })
      );
    },
    addTrigger: (trigger) => {
      set2(
        (state) => proposeChanges(state, (draft) => {
          const newTrigger = buildTrigger();
          draft.triggers.push(newTrigger);
        })
      );
    },
    addEdge: (edge) => {
      set2(
        (state) => proposeChanges(state, (draft) => {
          const newEdge = buildEdge();
          draft.edges.push(newEdge);
        })
      );
    },
    applyPatches: (patches) => {
      const immerPatches = patches.map((patch) => ({
        ...patch,
        path: patch.path.split("/").filter(Boolean)
      }));
      set2((state) => applyPatches(state, immerPatches));
    },
    onChange: onChange ? onChange : () => {
    }
  }));
};

// js/workflow-editor/index.ts
var workflow_editor_default = {
  mounted() {
    this._pendingWorker = Promise.resolve();
    this.editJobUrl = this.el.dataset.editJobUrl;
    this.pendingChanges = [];
    this.abortController = new AbortController();
    this.componentModule = import("../component-UBVNHTW6.js");
    this.handleEvent("patches-applied", (response) => {
      console.debug("patches-applied", response.patches);
      this.workflowStore.getState().applyPatches(response.patches);
    });
    this.pushEventTo(this.el, "get-initial-state", {}, (payload) => {
      this.workflowStore = createWorkflowStore(
        { ...payload, editJobUrl: this.editJobUrl },
        (pendingChange) => {
          this.pendingChanges.push(pendingChange);
          this.processPendingChanges();
        }
      );
      this.componentModule.then(({ mount }) => {
        this.component = mount(this.el, this.workflowStore);
      });
    });
  },
  destroyed() {
    if (this.component) {
      this.component.unmount();
    }
    if (this.abortController) {
      this.abortController.abort();
    }
  },
  processPendingChanges() {
    this._pendingWorker = this._pendingWorker.then(
      async () => {
        while (this.pendingChanges.length > 0 && !this.abortController.signal.aborted) {
          const pendingChange = this.pendingChanges.shift();
          await this.pushPendingChange(pendingChange, this.abortController);
        }
      }
    );
  },
  pushPendingChange(pendingChange, abortController) {
    return new Promise((resolve, reject) => {
      console.debug("pushing change", pendingChange);
      this.pushEventTo(
        this.el,
        "push-change",
        pendingChange,
        (response) => {
          abortController?.signal.addEventListener(
            "abort",
            () => reject(false)
          );
          this.workflowStore.getState().applyPatches(response.patches);
          resolve(true);
        }
      );
    });
  }
};

// js/tab-selector/index.ts
var tab_selector_default = {
  mounted() {
    this.tabItems = this.el.querySelectorAll("[id^=tab-item]");
    this.contentItems = document.querySelectorAll("[data-panel-hash]");
    const { activeClasses, inactiveClasses, defaultHash } = this.el.dataset;
    if (!activeClasses || !inactiveClasses || !defaultHash) {
      throw new Error(
        "TabSelector tab_bar component missing data-active-classes, data-inactive-classes or data-default-hash."
      );
    }
    this.handleEvent("push-hash", ({ hash }) => {
      window.location.hash = hash;
    });
    this._onHashChange = (_evt) => {
      const hash = window.location.hash.replace("#", "");
      this.hashChanged(hash);
    };
    this.activeClasses = activeClasses.split(" ");
    this.inactiveClasses = inactiveClasses.split(" ");
    this.defaultHash = defaultHash;
    window.addEventListener("hashchange", this._onHashChange);
    this.hashChanged(window.location.hash.replace("#", "") || this.defaultHash);
  },
  hashChanged(newHash) {
    this.tabItems.forEach((elem) => {
      const { hash } = elem.dataset;
      const panel = document.querySelector(
        `[data-panel-hash=${hash}]`
      );
      if (newHash == hash) {
        panel.style.display = "block";
        elem.classList.remove(...this.inactiveClasses);
        elem.classList.add(...this.activeClasses);
      } else {
        panel.style.display = "none";
        elem.classList.remove(...this.activeClasses);
        elem.classList.add(...this.inactiveClasses);
      }
    });
  },
  destroyed() {
    window.removeEventListener("hashchange", this._onHashChange);
  }
};

// js/job-editor-resizer/mount.ts
var addDragMask = () => {
  const dragMask = document.createElement("div");
  dragMask.id = "drag-mask";
  dragMask.style.position = "absolute";
  dragMask.style.left = "0";
  dragMask.style.right = "0";
  dragMask.style.top = "0";
  dragMask.style.bottom = "0";
  dragMask.style.userSelect = "none";
  dragMask.style.zIndex = "999";
  dragMask.style.cursor = "ew-resize";
  document.body.appendChild(dragMask);
};
var hook = {
  onPointerDown(e) {
    this.containerBounds = this.container.getBoundingClientRect();
    addDragMask();
    const onMove = (e2) => this.onPointerMove(e2);
    document.addEventListener("pointermove", onMove);
    document.addEventListener(
      "pointerup",
      () => {
        document.removeEventListener("pointermove", onMove);
        this.onPointerUp();
      },
      {
        once: true
      }
    );
  },
  onPointerUp() {
    const mask = document.getElementById("drag-mask");
    if (mask) {
      mask.parentNode.removeChild(mask);
      if (this.width) {
        localStorage.setItem("lightning.job-editor.width", `${this.width}`);
      }
      document.dispatchEvent(new Event("update-layout"));
    }
  },
  onPointerMove(e) {
    const parent = this.el.parentNode;
    const { width: containerWidth, left: containerLeft } = this.containerBounds;
    if (e.screenX !== 0) {
      const relativePosition = Math.max(
        0,
        Math.min((e.clientX - containerLeft) / containerWidth)
      );
      this.width = (1 - relativePosition) * 100;
      parent.style.width = `${this.width}%`;
    }
  },
  mounted() {
    const parent = this.el.parentNode;
    let container = parent;
    while (container && !container.className.match("h-full")) {
      container = container.parentNode;
    }
    this.container = container;
    const savedWidth = localStorage.getItem("lightning.job-editor.width");
    if (parent) {
      if (savedWidth) {
        parent.style.width = `${savedWidth}%`;
      }
    }
    this.el.addEventListener("pointerdown", (e) => this.onPointerDown(e));
  }
};
var mount_default2 = hook;

// js/app.js
var Hooks2 = {
  WorkflowDiagram: workflow_diagram_default,
  TabSelector: tab_selector_default,
  JobEditor: job_editor_default,
  JobEditorResizer: mount_default2,
  WorkflowEditor: workflow_editor_default
};
Hooks2.Flash = {
  mounted() {
    let hide = () => liveSocket.execJS(this.el, this.el.getAttribute("phx-click"));
    this.timer = setTimeout(() => hide(), 5e3);
    this.el.addEventListener("phx:hide-start", () => clearTimeout(this.timer));
    this.el.addEventListener("mouseover", () => {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => hide(), 5e3);
    });
  },
  destroyed() {
    clearTimeout(this.timer);
  }
};
Hooks2.AssocListChange = {
  mounted() {
    this.el.addEventListener("change", (_event) => {
      this.pushEventTo(this.el, "select_item", { id: this.el.value });
    });
  }
};
Hooks2.Copy = {
  mounted() {
    let { to } = this.el.dataset;
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      let text = document.querySelector(to).value;
      navigator.clipboard.writeText(text).then(() => {
        console.log("Copied!");
      });
    });
  }
};
Hooks2.CheckboxIndeterminate = {
  mounted() {
    this.el.indeterminate = this.el.classList.contains("indeterminate");
  },
  updated() {
    this.el.indeterminate = this.el.classList.contains("indeterminate");
  }
};
var csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
var liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks2,
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.attributes["lv-keep-style"]) {
        to.setAttribute("style", from.attributes.style.value);
      }
      if (from.attributes["lv-keep-class"]) {
        to.setAttribute("class", from.attributes.class.value);
      }
    }
  }
});
import_topbar.default.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
var topBarScheduled = void 0;
window.addEventListener("phx:page-loading-start", () => {
  if (!topBarScheduled) {
    topBarScheduled = setTimeout(() => import_topbar.default.show(), 120);
  }
});
window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = void 0;
  import_topbar.default.hide();
});
window.addEventListener("keydown", (event) => {
  const currentURL = window.location.pathname;
  const edit_job_url = /\/projects\/(.+)\/w\/(.+)\/j\/(.+)/;
  if ((event.ctrlKey || event.metaKey) && event.key === "s") {
    if (edit_job_url.test(currentURL)) {
      event.preventDefault();
      console.log("Saving the job");
      let form = document.querySelector("button[form='job-form']");
      form.click();
    }
  }
});
liveSocket.connect();
window.liveSocket = liveSocket;
/**
 * @license MIT
 * topbar 1.0.0, 2021-01-06
 * https://buunguyen.github.io/topbar
 * Copyright (c) 2021 Buu Nguyen
 */
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsiLi4vLi4vLi4vLi4vYXNzZXRzL3ZlbmRvci90b3BiYXIuanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4X2h0bWwvcHJpdi9zdGF0aWMvcGhvZW5peF9odG1sLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peC9hc3NldHMvanMvcGhvZW5peC91dGlscy5qcyIsICIuLi8uLi8uLi8uLi9kZXBzL3Bob2VuaXgvYXNzZXRzL2pzL3Bob2VuaXgvY29uc3RhbnRzLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peC9hc3NldHMvanMvcGhvZW5peC9wdXNoLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peC9hc3NldHMvanMvcGhvZW5peC90aW1lci5qcyIsICIuLi8uLi8uLi8uLi9kZXBzL3Bob2VuaXgvYXNzZXRzL2pzL3Bob2VuaXgvY2hhbm5lbC5qcyIsICIuLi8uLi8uLi8uLi9kZXBzL3Bob2VuaXgvYXNzZXRzL2pzL3Bob2VuaXgvYWpheC5qcyIsICIuLi8uLi8uLi8uLi9kZXBzL3Bob2VuaXgvYXNzZXRzL2pzL3Bob2VuaXgvbG9uZ3BvbGwuanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4L2Fzc2V0cy9qcy9waG9lbml4L3ByZXNlbmNlLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peC9hc3NldHMvanMvcGhvZW5peC9zZXJpYWxpemVyLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peC9hc3NldHMvanMvcGhvZW5peC9zb2NrZXQuanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4X2xpdmVfdmlldy9hc3NldHMvanMvcGhvZW5peF9saXZlX3ZpZXcvY29uc3RhbnRzLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peF9saXZlX3ZpZXcvYXNzZXRzL2pzL3Bob2VuaXhfbGl2ZV92aWV3L2VudHJ5X3VwbG9hZGVyLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peF9saXZlX3ZpZXcvYXNzZXRzL2pzL3Bob2VuaXhfbGl2ZV92aWV3L3V0aWxzLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peF9saXZlX3ZpZXcvYXNzZXRzL2pzL3Bob2VuaXhfbGl2ZV92aWV3L2Jyb3dzZXIuanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4X2xpdmVfdmlldy9hc3NldHMvanMvcGhvZW5peF9saXZlX3ZpZXcvZG9tLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peF9saXZlX3ZpZXcvYXNzZXRzL2pzL3Bob2VuaXhfbGl2ZV92aWV3L3VwbG9hZF9lbnRyeS5qcyIsICIuLi8uLi8uLi8uLi9kZXBzL3Bob2VuaXhfbGl2ZV92aWV3L2Fzc2V0cy9qcy9waG9lbml4X2xpdmVfdmlldy9saXZlX3VwbG9hZGVyLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peF9saXZlX3ZpZXcvYXNzZXRzL2pzL3Bob2VuaXhfbGl2ZV92aWV3L2FyaWEuanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4X2xpdmVfdmlldy9hc3NldHMvanMvcGhvZW5peF9saXZlX3ZpZXcvaG9va3MuanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4X2xpdmVfdmlldy9hc3NldHMvanMvcGhvZW5peF9saXZlX3ZpZXcvZG9tX3Bvc3RfbW9ycGhfcmVzdG9yZXIuanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4X2xpdmVfdmlldy9hc3NldHMvbm9kZV9tb2R1bGVzL21vcnBoZG9tL2Rpc3QvbW9ycGhkb20tZXNtLmpzIiwgIi4uLy4uLy4uLy4uL2RlcHMvcGhvZW5peF9saXZlX3ZpZXcvYXNzZXRzL2pzL3Bob2VuaXhfbGl2ZV92aWV3L2RvbV9wYXRjaC5qcyIsICIuLi8uLi8uLi8uLi9kZXBzL3Bob2VuaXhfbGl2ZV92aWV3L2Fzc2V0cy9qcy9waG9lbml4X2xpdmVfdmlldy9yZW5kZXJlZC5qcyIsICIuLi8uLi8uLi8uLi9kZXBzL3Bob2VuaXhfbGl2ZV92aWV3L2Fzc2V0cy9qcy9waG9lbml4X2xpdmVfdmlldy92aWV3X2hvb2suanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4X2xpdmVfdmlldy9hc3NldHMvanMvcGhvZW5peF9saXZlX3ZpZXcvanMuanMiLCAiLi4vLi4vLi4vLi4vZGVwcy9waG9lbml4X2xpdmVfdmlldy9hc3NldHMvanMvcGhvZW5peF9saXZlX3ZpZXcvdmlldy5qcyIsICIuLi8uLi8uLi8uLi9kZXBzL3Bob2VuaXhfbGl2ZV92aWV3L2Fzc2V0cy9qcy9waG9lbml4X2xpdmVfdmlldy9saXZlX3NvY2tldC5qcyIsICIuLi8uLi8uLi8uLi9hc3NldHMvanMvYXBwLmpzIiwgIi4uLy4uLy4uLy4uL2Fzc2V0cy9qcy9qb2ItZWRpdG9yL21vdW50LnRzeCIsICIuLi8uLi8uLi8uLi9hc3NldHMvanMvbWV0YWRhdGEtbG9hZGVyL21ldGFkYXRhLnRzIiwgIi4uLy4uLy4uLy4uL2Fzc2V0cy9qcy9qb2ItZWRpdG9yL2luZGV4LnRzIiwgIi4uLy4uLy4uLy4uL2Fzc2V0cy9qcy93b3JrZmxvdy1kaWFncmFtL2luZGV4LnRzIiwgIi4uLy4uLy4uLy4uL2Fzc2V0cy9ub2RlX21vZHVsZXMvaW1tZXIvc3JjL3V0aWxzL2Vudi50cyIsICIuLi8uLi8uLi8uLi9hc3NldHMvbm9kZV9tb2R1bGVzL2ltbWVyL3NyYy91dGlscy9lcnJvcnMudHMiLCAiLi4vLi4vLi4vLi4vYXNzZXRzL25vZGVfbW9kdWxlcy9pbW1lci9zcmMvdXRpbHMvY29tbW9uLnRzIiwgIi4uLy4uLy4uLy4uL2Fzc2V0cy9ub2RlX21vZHVsZXMvaW1tZXIvc3JjL3V0aWxzL3BsdWdpbnMudHMiLCAiLi4vLi4vLi4vLi4vYXNzZXRzL25vZGVfbW9kdWxlcy9pbW1lci9zcmMvY29yZS9zY29wZS50cyIsICIuLi8uLi8uLi8uLi9hc3NldHMvbm9kZV9tb2R1bGVzL2ltbWVyL3NyYy9jb3JlL2ZpbmFsaXplLnRzIiwgIi4uLy4uLy4uLy4uL2Fzc2V0cy9ub2RlX21vZHVsZXMvaW1tZXIvc3JjL2NvcmUvcHJveHkudHMiLCAiLi4vLi4vLi4vLi4vYXNzZXRzL25vZGVfbW9kdWxlcy9pbW1lci9zcmMvY29yZS9pbW1lckNsYXNzLnRzIiwgIi4uLy4uLy4uLy4uL2Fzc2V0cy9ub2RlX21vZHVsZXMvaW1tZXIvc3JjL2NvcmUvY3VycmVudC50cyIsICIuLi8uLi8uLi8uLi9hc3NldHMvbm9kZV9tb2R1bGVzL2ltbWVyL3NyYy9wbHVnaW5zL3BhdGNoZXMudHMiLCAiLi4vLi4vLi4vLi4vYXNzZXRzL25vZGVfbW9kdWxlcy9pbW1lci9zcmMvcGx1Z2lucy9tYXBzZXQudHMiLCAiLi4vLi4vLi4vLi4vYXNzZXRzL25vZGVfbW9kdWxlcy9pbW1lci9zcmMvaW1tZXIudHMiLCAiLi4vLi4vLi4vLi4vYXNzZXRzL2pzL3dvcmtmbG93LWVkaXRvci9zdG9yZS50cyIsICIuLi8uLi8uLi8uLi9hc3NldHMvanMvd29ya2Zsb3ctZWRpdG9yL2luZGV4LnRzIiwgIi4uLy4uLy4uLy4uL2Fzc2V0cy9qcy90YWItc2VsZWN0b3IvaW5kZXgudHMiLCAiLi4vLi4vLi4vLi4vYXNzZXRzL2pzL2pvYi1lZGl0b3ItcmVzaXplci9tb3VudC50cyJdLAogICJzb3VyY2VzQ29udGVudCI6IFsiLyoqXG4gKiBAbGljZW5zZSBNSVRcbiAqIHRvcGJhciAxLjAuMCwgMjAyMS0wMS0wNlxuICogaHR0cHM6Ly9idXVuZ3V5ZW4uZ2l0aHViLmlvL3RvcGJhclxuICogQ29weXJpZ2h0IChjKSAyMDIxIEJ1dSBOZ3V5ZW5cbiAqL1xuKGZ1bmN0aW9uICh3aW5kb3csIGRvY3VtZW50KSB7XG4gIFwidXNlIHN0cmljdFwiO1xuXG4gIC8vIGh0dHBzOi8vZ2lzdC5naXRodWIuY29tL3BhdWxpcmlzaC8xNTc5NjcxXG4gIChmdW5jdGlvbiAoKSB7XG4gICAgdmFyIGxhc3RUaW1lID0gMDtcbiAgICB2YXIgdmVuZG9ycyA9IFtcIm1zXCIsIFwibW96XCIsIFwid2Via2l0XCIsIFwib1wiXTtcbiAgICBmb3IgKHZhciB4ID0gMDsgeCA8IHZlbmRvcnMubGVuZ3RoICYmICF3aW5kb3cucmVxdWVzdEFuaW1hdGlvbkZyYW1lOyArK3gpIHtcbiAgICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUgPVxuICAgICAgICB3aW5kb3dbdmVuZG9yc1t4XSArIFwiUmVxdWVzdEFuaW1hdGlvbkZyYW1lXCJdO1xuICAgICAgd2luZG93LmNhbmNlbEFuaW1hdGlvbkZyYW1lID1cbiAgICAgICAgd2luZG93W3ZlbmRvcnNbeF0gKyBcIkNhbmNlbEFuaW1hdGlvbkZyYW1lXCJdIHx8XG4gICAgICAgIHdpbmRvd1t2ZW5kb3JzW3hdICsgXCJDYW5jZWxSZXF1ZXN0QW5pbWF0aW9uRnJhbWVcIl07XG4gICAgfVxuICAgIGlmICghd2luZG93LnJlcXVlc3RBbmltYXRpb25GcmFtZSlcbiAgICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUgPSBmdW5jdGlvbiAoY2FsbGJhY2ssIGVsZW1lbnQpIHtcbiAgICAgICAgdmFyIGN1cnJUaW1lID0gbmV3IERhdGUoKS5nZXRUaW1lKCk7XG4gICAgICAgIHZhciB0aW1lVG9DYWxsID0gTWF0aC5tYXgoMCwgMTYgLSAoY3VyclRpbWUgLSBsYXN0VGltZSkpO1xuICAgICAgICB2YXIgaWQgPSB3aW5kb3cuc2V0VGltZW91dChmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgY2FsbGJhY2soY3VyclRpbWUgKyB0aW1lVG9DYWxsKTtcbiAgICAgICAgfSwgdGltZVRvQ2FsbCk7XG4gICAgICAgIGxhc3RUaW1lID0gY3VyclRpbWUgKyB0aW1lVG9DYWxsO1xuICAgICAgICByZXR1cm4gaWQ7XG4gICAgICB9O1xuICAgIGlmICghd2luZG93LmNhbmNlbEFuaW1hdGlvbkZyYW1lKVxuICAgICAgd2luZG93LmNhbmNlbEFuaW1hdGlvbkZyYW1lID0gZnVuY3Rpb24gKGlkKSB7XG4gICAgICAgIGNsZWFyVGltZW91dChpZCk7XG4gICAgICB9O1xuICB9KSgpO1xuXG4gIHZhciBjYW52YXMsXG4gICAgcHJvZ3Jlc3NUaW1lcklkLFxuICAgIGZhZGVUaW1lcklkLFxuICAgIGN1cnJlbnRQcm9ncmVzcyxcbiAgICBzaG93aW5nLFxuICAgIGFkZEV2ZW50ID0gZnVuY3Rpb24gKGVsZW0sIHR5cGUsIGhhbmRsZXIpIHtcbiAgICAgIGlmIChlbGVtLmFkZEV2ZW50TGlzdGVuZXIpIGVsZW0uYWRkRXZlbnRMaXN0ZW5lcih0eXBlLCBoYW5kbGVyLCBmYWxzZSk7XG4gICAgICBlbHNlIGlmIChlbGVtLmF0dGFjaEV2ZW50KSBlbGVtLmF0dGFjaEV2ZW50KFwib25cIiArIHR5cGUsIGhhbmRsZXIpO1xuICAgICAgZWxzZSBlbGVtW1wib25cIiArIHR5cGVdID0gaGFuZGxlcjtcbiAgICB9LFxuICAgIG9wdGlvbnMgPSB7XG4gICAgICBhdXRvUnVuOiB0cnVlLFxuICAgICAgYmFyVGhpY2tuZXNzOiAzLFxuICAgICAgYmFyQ29sb3JzOiB7XG4gICAgICAgIDA6IFwicmdiYSgyNiwgIDE4OCwgMTU2LCAuOSlcIixcbiAgICAgICAgXCIuMjVcIjogXCJyZ2JhKDUyLCAgMTUyLCAyMTksIC45KVwiLFxuICAgICAgICBcIi41MFwiOiBcInJnYmEoMjQxLCAxOTYsIDE1LCAgLjkpXCIsXG4gICAgICAgIFwiLjc1XCI6IFwicmdiYSgyMzAsIDEyNiwgMzQsICAuOSlcIixcbiAgICAgICAgXCIxLjBcIjogXCJyZ2JhKDIxMSwgODQsICAwLCAgIC45KVwiLFxuICAgICAgfSxcbiAgICAgIHNoYWRvd0JsdXI6IDEwLFxuICAgICAgc2hhZG93Q29sb3I6IFwicmdiYSgwLCAgIDAsICAgMCwgICAuNilcIixcbiAgICAgIGNsYXNzTmFtZTogbnVsbCxcbiAgICB9LFxuICAgIHJlcGFpbnQgPSBmdW5jdGlvbiAoKSB7XG4gICAgICBjYW52YXMud2lkdGggPSB3aW5kb3cuaW5uZXJXaWR0aDtcbiAgICAgIGNhbnZhcy5oZWlnaHQgPSBvcHRpb25zLmJhclRoaWNrbmVzcyAqIDU7IC8vIG5lZWQgc3BhY2UgZm9yIHNoYWRvd1xuXG4gICAgICB2YXIgY3R4ID0gY2FudmFzLmdldENvbnRleHQoXCIyZFwiKTtcbiAgICAgIGN0eC5zaGFkb3dCbHVyID0gb3B0aW9ucy5zaGFkb3dCbHVyO1xuICAgICAgY3R4LnNoYWRvd0NvbG9yID0gb3B0aW9ucy5zaGFkb3dDb2xvcjtcblxuICAgICAgdmFyIGxpbmVHcmFkaWVudCA9IGN0eC5jcmVhdGVMaW5lYXJHcmFkaWVudCgwLCAwLCBjYW52YXMud2lkdGgsIDApO1xuICAgICAgZm9yICh2YXIgc3RvcCBpbiBvcHRpb25zLmJhckNvbG9ycylcbiAgICAgICAgbGluZUdyYWRpZW50LmFkZENvbG9yU3RvcChzdG9wLCBvcHRpb25zLmJhckNvbG9yc1tzdG9wXSk7XG4gICAgICBjdHgubGluZVdpZHRoID0gb3B0aW9ucy5iYXJUaGlja25lc3M7XG4gICAgICBjdHguYmVnaW5QYXRoKCk7XG4gICAgICBjdHgubW92ZVRvKDAsIG9wdGlvbnMuYmFyVGhpY2tuZXNzIC8gMik7XG4gICAgICBjdHgubGluZVRvKFxuICAgICAgICBNYXRoLmNlaWwoY3VycmVudFByb2dyZXNzICogY2FudmFzLndpZHRoKSxcbiAgICAgICAgb3B0aW9ucy5iYXJUaGlja25lc3MgLyAyXG4gICAgICApO1xuICAgICAgY3R4LnN0cm9rZVN0eWxlID0gbGluZUdyYWRpZW50O1xuICAgICAgY3R4LnN0cm9rZSgpO1xuICAgIH0sXG4gICAgY3JlYXRlQ2FudmFzID0gZnVuY3Rpb24gKCkge1xuICAgICAgY2FudmFzID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudChcImNhbnZhc1wiKTtcbiAgICAgIHZhciBzdHlsZSA9IGNhbnZhcy5zdHlsZTtcbiAgICAgIHN0eWxlLnBvc2l0aW9uID0gXCJmaXhlZFwiO1xuICAgICAgc3R5bGUudG9wID0gc3R5bGUubGVmdCA9IHN0eWxlLnJpZ2h0ID0gc3R5bGUubWFyZ2luID0gc3R5bGUucGFkZGluZyA9IDA7XG4gICAgICBzdHlsZS56SW5kZXggPSAxMDAwMDE7XG4gICAgICBzdHlsZS5kaXNwbGF5ID0gXCJub25lXCI7XG4gICAgICBpZiAob3B0aW9ucy5jbGFzc05hbWUpIGNhbnZhcy5jbGFzc0xpc3QuYWRkKG9wdGlvbnMuY2xhc3NOYW1lKTtcbiAgICAgIGRvY3VtZW50LmJvZHkuYXBwZW5kQ2hpbGQoY2FudmFzKTtcbiAgICAgIGFkZEV2ZW50KHdpbmRvdywgXCJyZXNpemVcIiwgcmVwYWludCk7XG4gICAgfSxcbiAgICB0b3BiYXIgPSB7XG4gICAgICBjb25maWc6IGZ1bmN0aW9uIChvcHRzKSB7XG4gICAgICAgIGZvciAodmFyIGtleSBpbiBvcHRzKVxuICAgICAgICAgIGlmIChvcHRpb25zLmhhc093blByb3BlcnR5KGtleSkpIG9wdGlvbnNba2V5XSA9IG9wdHNba2V5XTtcbiAgICAgIH0sXG4gICAgICBzaG93OiBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGlmIChzaG93aW5nKSByZXR1cm47XG4gICAgICAgIHNob3dpbmcgPSB0cnVlO1xuICAgICAgICBpZiAoZmFkZVRpbWVySWQgIT09IG51bGwpIHdpbmRvdy5jYW5jZWxBbmltYXRpb25GcmFtZShmYWRlVGltZXJJZCk7XG4gICAgICAgIGlmICghY2FudmFzKSBjcmVhdGVDYW52YXMoKTtcbiAgICAgICAgY2FudmFzLnN0eWxlLm9wYWNpdHkgPSAxO1xuICAgICAgICBjYW52YXMuc3R5bGUuZGlzcGxheSA9IFwiYmxvY2tcIjtcbiAgICAgICAgdG9wYmFyLnByb2dyZXNzKDApO1xuICAgICAgICBpZiAob3B0aW9ucy5hdXRvUnVuKSB7XG4gICAgICAgICAgKGZ1bmN0aW9uIGxvb3AoKSB7XG4gICAgICAgICAgICBwcm9ncmVzc1RpbWVySWQgPSB3aW5kb3cucmVxdWVzdEFuaW1hdGlvbkZyYW1lKGxvb3ApO1xuICAgICAgICAgICAgdG9wYmFyLnByb2dyZXNzKFxuICAgICAgICAgICAgICBcIitcIiArIDAuMDUgKiBNYXRoLnBvdygxIC0gTWF0aC5zcXJ0KGN1cnJlbnRQcm9ncmVzcyksIDIpXG4gICAgICAgICAgICApO1xuICAgICAgICAgIH0pKCk7XG4gICAgICAgIH1cbiAgICAgIH0sXG4gICAgICBwcm9ncmVzczogZnVuY3Rpb24gKHRvKSB7XG4gICAgICAgIGlmICh0eXBlb2YgdG8gPT09IFwidW5kZWZpbmVkXCIpIHJldHVybiBjdXJyZW50UHJvZ3Jlc3M7XG4gICAgICAgIGlmICh0eXBlb2YgdG8gPT09IFwic3RyaW5nXCIpIHtcbiAgICAgICAgICB0byA9XG4gICAgICAgICAgICAodG8uaW5kZXhPZihcIitcIikgPj0gMCB8fCB0by5pbmRleE9mKFwiLVwiKSA+PSAwXG4gICAgICAgICAgICAgID8gY3VycmVudFByb2dyZXNzXG4gICAgICAgICAgICAgIDogMCkgKyBwYXJzZUZsb2F0KHRvKTtcbiAgICAgICAgfVxuICAgICAgICBjdXJyZW50UHJvZ3Jlc3MgPSB0byA+IDEgPyAxIDogdG87XG4gICAgICAgIHJlcGFpbnQoKTtcbiAgICAgICAgcmV0dXJuIGN1cnJlbnRQcm9ncmVzcztcbiAgICAgIH0sXG4gICAgICBoaWRlOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGlmICghc2hvd2luZykgcmV0dXJuO1xuICAgICAgICBzaG93aW5nID0gZmFsc2U7XG4gICAgICAgIGlmIChwcm9ncmVzc1RpbWVySWQgIT0gbnVsbCkge1xuICAgICAgICAgIHdpbmRvdy5jYW5jZWxBbmltYXRpb25GcmFtZShwcm9ncmVzc1RpbWVySWQpO1xuICAgICAgICAgIHByb2dyZXNzVGltZXJJZCA9IG51bGw7XG4gICAgICAgIH1cbiAgICAgICAgKGZ1bmN0aW9uIGxvb3AoKSB7XG4gICAgICAgICAgaWYgKHRvcGJhci5wcm9ncmVzcyhcIisuMVwiKSA+PSAxKSB7XG4gICAgICAgICAgICBjYW52YXMuc3R5bGUub3BhY2l0eSAtPSAwLjA1O1xuICAgICAgICAgICAgaWYgKGNhbnZhcy5zdHlsZS5vcGFjaXR5IDw9IDAuMDUpIHtcbiAgICAgICAgICAgICAgY2FudmFzLnN0eWxlLmRpc3BsYXkgPSBcIm5vbmVcIjtcbiAgICAgICAgICAgICAgZmFkZVRpbWVySWQgPSBudWxsO1xuICAgICAgICAgICAgICByZXR1cm47XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfVxuICAgICAgICAgIGZhZGVUaW1lcklkID0gd2luZG93LnJlcXVlc3RBbmltYXRpb25GcmFtZShsb29wKTtcbiAgICAgICAgfSkoKTtcbiAgICAgIH0sXG4gICAgfTtcblxuICBpZiAodHlwZW9mIG1vZHVsZSA9PT0gXCJvYmplY3RcIiAmJiB0eXBlb2YgbW9kdWxlLmV4cG9ydHMgPT09IFwib2JqZWN0XCIpIHtcbiAgICBtb2R1bGUuZXhwb3J0cyA9IHRvcGJhcjtcbiAgfSBlbHNlIGlmICh0eXBlb2YgZGVmaW5lID09PSBcImZ1bmN0aW9uXCIgJiYgZGVmaW5lLmFtZCkge1xuICAgIGRlZmluZShmdW5jdGlvbiAoKSB7XG4gICAgICByZXR1cm4gdG9wYmFyO1xuICAgIH0pO1xuICB9IGVsc2Uge1xuICAgIHRoaXMudG9wYmFyID0gdG9wYmFyO1xuICB9XG59LmNhbGwodGhpcywgd2luZG93LCBkb2N1bWVudCkpO1xuIiwgIlwidXNlIHN0cmljdFwiO1xuXG4oZnVuY3Rpb24oKSB7XG4gIHZhciBQb2x5ZmlsbEV2ZW50ID0gZXZlbnRDb25zdHJ1Y3RvcigpO1xuXG4gIGZ1bmN0aW9uIGV2ZW50Q29uc3RydWN0b3IoKSB7XG4gICAgaWYgKHR5cGVvZiB3aW5kb3cuQ3VzdG9tRXZlbnQgPT09IFwiZnVuY3Rpb25cIikgcmV0dXJuIHdpbmRvdy5DdXN0b21FdmVudDtcbiAgICAvLyBJRTw9OSBTdXBwb3J0XG4gICAgZnVuY3Rpb24gQ3VzdG9tRXZlbnQoZXZlbnQsIHBhcmFtcykge1xuICAgICAgcGFyYW1zID0gcGFyYW1zIHx8IHtidWJibGVzOiBmYWxzZSwgY2FuY2VsYWJsZTogZmFsc2UsIGRldGFpbDogdW5kZWZpbmVkfTtcbiAgICAgIHZhciBldnQgPSBkb2N1bWVudC5jcmVhdGVFdmVudCgnQ3VzdG9tRXZlbnQnKTtcbiAgICAgIGV2dC5pbml0Q3VzdG9tRXZlbnQoZXZlbnQsIHBhcmFtcy5idWJibGVzLCBwYXJhbXMuY2FuY2VsYWJsZSwgcGFyYW1zLmRldGFpbCk7XG4gICAgICByZXR1cm4gZXZ0O1xuICAgIH1cbiAgICBDdXN0b21FdmVudC5wcm90b3R5cGUgPSB3aW5kb3cuRXZlbnQucHJvdG90eXBlO1xuICAgIHJldHVybiBDdXN0b21FdmVudDtcbiAgfVxuXG4gIGZ1bmN0aW9uIGJ1aWxkSGlkZGVuSW5wdXQobmFtZSwgdmFsdWUpIHtcbiAgICB2YXIgaW5wdXQgPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KFwiaW5wdXRcIik7XG4gICAgaW5wdXQudHlwZSA9IFwiaGlkZGVuXCI7XG4gICAgaW5wdXQubmFtZSA9IG5hbWU7XG4gICAgaW5wdXQudmFsdWUgPSB2YWx1ZTtcbiAgICByZXR1cm4gaW5wdXQ7XG4gIH1cblxuICBmdW5jdGlvbiBoYW5kbGVDbGljayhlbGVtZW50LCB0YXJnZXRNb2RpZmllcktleSkge1xuICAgIHZhciB0byA9IGVsZW1lbnQuZ2V0QXR0cmlidXRlKFwiZGF0YS10b1wiKSxcbiAgICAgICAgbWV0aG9kID0gYnVpbGRIaWRkZW5JbnB1dChcIl9tZXRob2RcIiwgZWxlbWVudC5nZXRBdHRyaWJ1dGUoXCJkYXRhLW1ldGhvZFwiKSksXG4gICAgICAgIGNzcmYgPSBidWlsZEhpZGRlbklucHV0KFwiX2NzcmZfdG9rZW5cIiwgZWxlbWVudC5nZXRBdHRyaWJ1dGUoXCJkYXRhLWNzcmZcIikpLFxuICAgICAgICBmb3JtID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudChcImZvcm1cIiksXG4gICAgICAgIHN1Ym1pdCA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoXCJpbnB1dFwiKSxcbiAgICAgICAgdGFyZ2V0ID0gZWxlbWVudC5nZXRBdHRyaWJ1dGUoXCJ0YXJnZXRcIik7XG5cbiAgICBmb3JtLm1ldGhvZCA9IChlbGVtZW50LmdldEF0dHJpYnV0ZShcImRhdGEtbWV0aG9kXCIpID09PSBcImdldFwiKSA/IFwiZ2V0XCIgOiBcInBvc3RcIjtcbiAgICBmb3JtLmFjdGlvbiA9IHRvO1xuICAgIGZvcm0uc3R5bGUuZGlzcGxheSA9IFwibm9uZVwiO1xuXG4gICAgaWYgKHRhcmdldCkgZm9ybS50YXJnZXQgPSB0YXJnZXQ7XG4gICAgZWxzZSBpZiAodGFyZ2V0TW9kaWZpZXJLZXkpIGZvcm0udGFyZ2V0ID0gXCJfYmxhbmtcIjtcblxuICAgIGZvcm0uYXBwZW5kQ2hpbGQoY3NyZik7XG4gICAgZm9ybS5hcHBlbmRDaGlsZChtZXRob2QpO1xuICAgIGRvY3VtZW50LmJvZHkuYXBwZW5kQ2hpbGQoZm9ybSk7XG5cbiAgICAvLyBJbnNlcnQgYSBidXR0b24gYW5kIGNsaWNrIGl0IGluc3RlYWQgb2YgdXNpbmcgYGZvcm0uc3VibWl0YFxuICAgIC8vIGJlY2F1c2UgdGhlIGBzdWJtaXRgIGZ1bmN0aW9uIGRvZXMgbm90IGVtaXQgYSBgc3VibWl0YCBldmVudC5cbiAgICBzdWJtaXQudHlwZSA9IFwic3VibWl0XCI7XG4gICAgZm9ybS5hcHBlbmRDaGlsZChzdWJtaXQpO1xuICAgIHN1Ym1pdC5jbGljaygpO1xuICB9XG5cbiAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoXCJjbGlja1wiLCBmdW5jdGlvbihlKSB7XG4gICAgdmFyIGVsZW1lbnQgPSBlLnRhcmdldDtcbiAgICBpZiAoZS5kZWZhdWx0UHJldmVudGVkKSByZXR1cm47XG5cbiAgICB3aGlsZSAoZWxlbWVudCAmJiBlbGVtZW50LmdldEF0dHJpYnV0ZSkge1xuICAgICAgdmFyIHBob2VuaXhMaW5rRXZlbnQgPSBuZXcgUG9seWZpbGxFdmVudCgncGhvZW5peC5saW5rLmNsaWNrJywge1xuICAgICAgICBcImJ1YmJsZXNcIjogdHJ1ZSwgXCJjYW5jZWxhYmxlXCI6IHRydWVcbiAgICAgIH0pO1xuXG4gICAgICBpZiAoIWVsZW1lbnQuZGlzcGF0Y2hFdmVudChwaG9lbml4TGlua0V2ZW50KSkge1xuICAgICAgICBlLnByZXZlbnREZWZhdWx0KCk7XG4gICAgICAgIGUuc3RvcEltbWVkaWF0ZVByb3BhZ2F0aW9uKCk7XG4gICAgICAgIHJldHVybiBmYWxzZTtcbiAgICAgIH1cblxuICAgICAgaWYgKGVsZW1lbnQuZ2V0QXR0cmlidXRlKFwiZGF0YS1tZXRob2RcIikpIHtcbiAgICAgICAgaGFuZGxlQ2xpY2soZWxlbWVudCwgZS5tZXRhS2V5IHx8IGUuc2hpZnRLZXkpO1xuICAgICAgICBlLnByZXZlbnREZWZhdWx0KCk7XG4gICAgICAgIHJldHVybiBmYWxzZTtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGVsZW1lbnQgPSBlbGVtZW50LnBhcmVudE5vZGU7XG4gICAgICB9XG4gICAgfVxuICB9LCBmYWxzZSk7XG5cbiAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoJ3Bob2VuaXgubGluay5jbGljaycsIGZ1bmN0aW9uIChlKSB7XG4gICAgdmFyIG1lc3NhZ2UgPSBlLnRhcmdldC5nZXRBdHRyaWJ1dGUoXCJkYXRhLWNvbmZpcm1cIik7XG4gICAgaWYobWVzc2FnZSAmJiAhd2luZG93LmNvbmZpcm0obWVzc2FnZSkpIHtcbiAgICAgIGUucHJldmVudERlZmF1bHQoKTtcbiAgICB9XG4gIH0sIGZhbHNlKTtcbn0pKCk7XG4iLCAiLy8gd3JhcHMgdmFsdWUgaW4gY2xvc3VyZSBvciByZXR1cm5zIGNsb3N1cmVcbmV4cG9ydCBsZXQgY2xvc3VyZSA9ICh2YWx1ZSkgPT4ge1xuICBpZih0eXBlb2YgdmFsdWUgPT09IFwiZnVuY3Rpb25cIil7XG4gICAgcmV0dXJuIHZhbHVlXG4gIH0gZWxzZSB7XG4gICAgbGV0IGNsb3N1cmUgPSBmdW5jdGlvbiAoKXsgcmV0dXJuIHZhbHVlIH1cbiAgICByZXR1cm4gY2xvc3VyZVxuICB9XG59XG4iLCAiZXhwb3J0IGNvbnN0IGdsb2JhbFNlbGYgPSB0eXBlb2Ygc2VsZiAhPT0gXCJ1bmRlZmluZWRcIiA/IHNlbGYgOiBudWxsXG5leHBvcnQgY29uc3QgcGh4V2luZG93ID0gdHlwZW9mIHdpbmRvdyAhPT0gXCJ1bmRlZmluZWRcIiA/IHdpbmRvdyA6IG51bGxcbmV4cG9ydCBjb25zdCBnbG9iYWwgPSBnbG9iYWxTZWxmIHx8IHBoeFdpbmRvdyB8fCBnbG9iYWxcbmV4cG9ydCBjb25zdCBERUZBVUxUX1ZTTiA9IFwiMi4wLjBcIlxuZXhwb3J0IGNvbnN0IFNPQ0tFVF9TVEFURVMgPSB7Y29ubmVjdGluZzogMCwgb3BlbjogMSwgY2xvc2luZzogMiwgY2xvc2VkOiAzfVxuZXhwb3J0IGNvbnN0IERFRkFVTFRfVElNRU9VVCA9IDEwMDAwXG5leHBvcnQgY29uc3QgV1NfQ0xPU0VfTk9STUFMID0gMTAwMFxuZXhwb3J0IGNvbnN0IENIQU5ORUxfU1RBVEVTID0ge1xuICBjbG9zZWQ6IFwiY2xvc2VkXCIsXG4gIGVycm9yZWQ6IFwiZXJyb3JlZFwiLFxuICBqb2luZWQ6IFwiam9pbmVkXCIsXG4gIGpvaW5pbmc6IFwiam9pbmluZ1wiLFxuICBsZWF2aW5nOiBcImxlYXZpbmdcIixcbn1cbmV4cG9ydCBjb25zdCBDSEFOTkVMX0VWRU5UUyA9IHtcbiAgY2xvc2U6IFwicGh4X2Nsb3NlXCIsXG4gIGVycm9yOiBcInBoeF9lcnJvclwiLFxuICBqb2luOiBcInBoeF9qb2luXCIsXG4gIHJlcGx5OiBcInBoeF9yZXBseVwiLFxuICBsZWF2ZTogXCJwaHhfbGVhdmVcIlxufVxuXG5leHBvcnQgY29uc3QgVFJBTlNQT1JUUyA9IHtcbiAgbG9uZ3BvbGw6IFwibG9uZ3BvbGxcIixcbiAgd2Vic29ja2V0OiBcIndlYnNvY2tldFwiXG59XG5leHBvcnQgY29uc3QgWEhSX1NUQVRFUyA9IHtcbiAgY29tcGxldGU6IDRcbn1cbiIsICIvKipcbiAqIEluaXRpYWxpemVzIHRoZSBQdXNoXG4gKiBAcGFyYW0ge0NoYW5uZWx9IGNoYW5uZWwgLSBUaGUgQ2hhbm5lbFxuICogQHBhcmFtIHtzdHJpbmd9IGV2ZW50IC0gVGhlIGV2ZW50LCBmb3IgZXhhbXBsZSBgXCJwaHhfam9pblwiYFxuICogQHBhcmFtIHtPYmplY3R9IHBheWxvYWQgLSBUaGUgcGF5bG9hZCwgZm9yIGV4YW1wbGUgYHt1c2VyX2lkOiAxMjN9YFxuICogQHBhcmFtIHtudW1iZXJ9IHRpbWVvdXQgLSBUaGUgcHVzaCB0aW1lb3V0IGluIG1pbGxpc2Vjb25kc1xuICovXG5leHBvcnQgZGVmYXVsdCBjbGFzcyBQdXNoIHtcbiAgY29uc3RydWN0b3IoY2hhbm5lbCwgZXZlbnQsIHBheWxvYWQsIHRpbWVvdXQpe1xuICAgIHRoaXMuY2hhbm5lbCA9IGNoYW5uZWxcbiAgICB0aGlzLmV2ZW50ID0gZXZlbnRcbiAgICB0aGlzLnBheWxvYWQgPSBwYXlsb2FkIHx8IGZ1bmN0aW9uICgpeyByZXR1cm4ge30gfVxuICAgIHRoaXMucmVjZWl2ZWRSZXNwID0gbnVsbFxuICAgIHRoaXMudGltZW91dCA9IHRpbWVvdXRcbiAgICB0aGlzLnRpbWVvdXRUaW1lciA9IG51bGxcbiAgICB0aGlzLnJlY0hvb2tzID0gW11cbiAgICB0aGlzLnNlbnQgPSBmYWxzZVxuICB9XG5cbiAgLyoqXG4gICAqXG4gICAqIEBwYXJhbSB7bnVtYmVyfSB0aW1lb3V0XG4gICAqL1xuICByZXNlbmQodGltZW91dCl7XG4gICAgdGhpcy50aW1lb3V0ID0gdGltZW91dFxuICAgIHRoaXMucmVzZXQoKVxuICAgIHRoaXMuc2VuZCgpXG4gIH1cblxuICAvKipcbiAgICpcbiAgICovXG4gIHNlbmQoKXtcbiAgICBpZih0aGlzLmhhc1JlY2VpdmVkKFwidGltZW91dFwiKSl7IHJldHVybiB9XG4gICAgdGhpcy5zdGFydFRpbWVvdXQoKVxuICAgIHRoaXMuc2VudCA9IHRydWVcbiAgICB0aGlzLmNoYW5uZWwuc29ja2V0LnB1c2goe1xuICAgICAgdG9waWM6IHRoaXMuY2hhbm5lbC50b3BpYyxcbiAgICAgIGV2ZW50OiB0aGlzLmV2ZW50LFxuICAgICAgcGF5bG9hZDogdGhpcy5wYXlsb2FkKCksXG4gICAgICByZWY6IHRoaXMucmVmLFxuICAgICAgam9pbl9yZWY6IHRoaXMuY2hhbm5lbC5qb2luUmVmKClcbiAgICB9KVxuICB9XG5cbiAgLyoqXG4gICAqXG4gICAqIEBwYXJhbSB7Kn0gc3RhdHVzXG4gICAqIEBwYXJhbSB7Kn0gY2FsbGJhY2tcbiAgICovXG4gIHJlY2VpdmUoc3RhdHVzLCBjYWxsYmFjayl7XG4gICAgaWYodGhpcy5oYXNSZWNlaXZlZChzdGF0dXMpKXtcbiAgICAgIGNhbGxiYWNrKHRoaXMucmVjZWl2ZWRSZXNwLnJlc3BvbnNlKVxuICAgIH1cblxuICAgIHRoaXMucmVjSG9va3MucHVzaCh7c3RhdHVzLCBjYWxsYmFja30pXG4gICAgcmV0dXJuIHRoaXNcbiAgfVxuXG4gIC8qKlxuICAgKiBAcHJpdmF0ZVxuICAgKi9cbiAgcmVzZXQoKXtcbiAgICB0aGlzLmNhbmNlbFJlZkV2ZW50KClcbiAgICB0aGlzLnJlZiA9IG51bGxcbiAgICB0aGlzLnJlZkV2ZW50ID0gbnVsbFxuICAgIHRoaXMucmVjZWl2ZWRSZXNwID0gbnVsbFxuICAgIHRoaXMuc2VudCA9IGZhbHNlXG4gIH1cblxuICAvKipcbiAgICogQHByaXZhdGVcbiAgICovXG4gIG1hdGNoUmVjZWl2ZSh7c3RhdHVzLCByZXNwb25zZSwgX3JlZn0pe1xuICAgIHRoaXMucmVjSG9va3MuZmlsdGVyKGggPT4gaC5zdGF0dXMgPT09IHN0YXR1cylcbiAgICAgIC5mb3JFYWNoKGggPT4gaC5jYWxsYmFjayhyZXNwb25zZSkpXG4gIH1cblxuICAvKipcbiAgICogQHByaXZhdGVcbiAgICovXG4gIGNhbmNlbFJlZkV2ZW50KCl7XG4gICAgaWYoIXRoaXMucmVmRXZlbnQpeyByZXR1cm4gfVxuICAgIHRoaXMuY2hhbm5lbC5vZmYodGhpcy5yZWZFdmVudClcbiAgfVxuXG4gIC8qKlxuICAgKiBAcHJpdmF0ZVxuICAgKi9cbiAgY2FuY2VsVGltZW91dCgpe1xuICAgIGNsZWFyVGltZW91dCh0aGlzLnRpbWVvdXRUaW1lcilcbiAgICB0aGlzLnRpbWVvdXRUaW1lciA9IG51bGxcbiAgfVxuXG4gIC8qKlxuICAgKiBAcHJpdmF0ZVxuICAgKi9cbiAgc3RhcnRUaW1lb3V0KCl7XG4gICAgaWYodGhpcy50aW1lb3V0VGltZXIpeyB0aGlzLmNhbmNlbFRpbWVvdXQoKSB9XG4gICAgdGhpcy5yZWYgPSB0aGlzLmNoYW5uZWwuc29ja2V0Lm1ha2VSZWYoKVxuICAgIHRoaXMucmVmRXZlbnQgPSB0aGlzLmNoYW5uZWwucmVwbHlFdmVudE5hbWUodGhpcy5yZWYpXG5cbiAgICB0aGlzLmNoYW5uZWwub24odGhpcy5yZWZFdmVudCwgcGF5bG9hZCA9PiB7XG4gICAgICB0aGlzLmNhbmNlbFJlZkV2ZW50KClcbiAgICAgIHRoaXMuY2FuY2VsVGltZW91dCgpXG4gICAgICB0aGlzLnJlY2VpdmVkUmVzcCA9IHBheWxvYWRcbiAgICAgIHRoaXMubWF0Y2hSZWNlaXZlKHBheWxvYWQpXG4gICAgfSlcblxuICAgIHRoaXMudGltZW91dFRpbWVyID0gc2V0VGltZW91dCgoKSA9PiB7XG4gICAgICB0aGlzLnRyaWdnZXIoXCJ0aW1lb3V0XCIsIHt9KVxuICAgIH0sIHRoaXMudGltZW91dClcbiAgfVxuXG4gIC8qKlxuICAgKiBAcHJpdmF0ZVxuICAgKi9cbiAgaGFzUmVjZWl2ZWQoc3RhdHVzKXtcbiAgICByZXR1cm4gdGhpcy5yZWNlaXZlZFJlc3AgJiYgdGhpcy5yZWNlaXZlZFJlc3Auc3RhdHVzID09PSBzdGF0dXNcbiAgfVxuXG4gIC8qKlxuICAgKiBAcHJpdmF0ZVxuICAgKi9cbiAgdHJpZ2dlcihzdGF0dXMsIHJlc3BvbnNlKXtcbiAgICB0aGlzLmNoYW5uZWwudHJpZ2dlcih0aGlzLnJlZkV2ZW50LCB7c3RhdHVzLCByZXNwb25zZX0pXG4gIH1cbn1cbiIsICIvKipcbiAqXG4gKiBDcmVhdGVzIGEgdGltZXIgdGhhdCBhY2NlcHRzIGEgYHRpbWVyQ2FsY2AgZnVuY3Rpb24gdG8gcGVyZm9ybVxuICogY2FsY3VsYXRlZCB0aW1lb3V0IHJldHJpZXMsIHN1Y2ggYXMgZXhwb25lbnRpYWwgYmFja29mZi5cbiAqXG4gKiBAZXhhbXBsZVxuICogbGV0IHJlY29ubmVjdFRpbWVyID0gbmV3IFRpbWVyKCgpID0+IHRoaXMuY29ubmVjdCgpLCBmdW5jdGlvbih0cmllcyl7XG4gKiAgIHJldHVybiBbMTAwMCwgNTAwMCwgMTAwMDBdW3RyaWVzIC0gMV0gfHwgMTAwMDBcbiAqIH0pXG4gKiByZWNvbm5lY3RUaW1lci5zY2hlZHVsZVRpbWVvdXQoKSAvLyBmaXJlcyBhZnRlciAxMDAwXG4gKiByZWNvbm5lY3RUaW1lci5zY2hlZHVsZVRpbWVvdXQoKSAvLyBmaXJlcyBhZnRlciA1MDAwXG4gKiByZWNvbm5lY3RUaW1lci5yZXNldCgpXG4gKiByZWNvbm5lY3RUaW1lci5zY2hlZHVsZVRpbWVvdXQoKSAvLyBmaXJlcyBhZnRlciAxMDAwXG4gKlxuICogQHBhcmFtIHtGdW5jdGlvbn0gY2FsbGJhY2tcbiAqIEBwYXJhbSB7RnVuY3Rpb259IHRpbWVyQ2FsY1xuICovXG5leHBvcnQgZGVmYXVsdCBjbGFzcyBUaW1lciB7XG4gIGNvbnN0cnVjdG9yKGNhbGxiYWNrLCB0aW1lckNhbGMpe1xuICAgIHRoaXMuY2FsbGJhY2sgPSBjYWxsYmFja1xuICAgIHRoaXMudGltZXJDYWxjID0gdGltZXJDYWxjXG4gICAgdGhpcy50aW1lciA9IG51bGxcbiAgICB0aGlzLnRyaWVzID0gMFxuICB9XG5cbiAgcmVzZXQoKXtcbiAgICB0aGlzLnRyaWVzID0gMFxuICAgIGNsZWFyVGltZW91dCh0aGlzLnRpbWVyKVxuICB9XG5cbiAgLyoqXG4gICAqIENhbmNlbHMgYW55IHByZXZpb3VzIHNjaGVkdWxlVGltZW91dCBhbmQgc2NoZWR1bGVzIGNhbGxiYWNrXG4gICAqL1xuICBzY2hlZHVsZVRpbWVvdXQoKXtcbiAgICBjbGVhclRpbWVvdXQodGhpcy50aW1lcilcblxuICAgIHRoaXMudGltZXIgPSBzZXRUaW1lb3V0KCgpID0+IHtcbiAgICAgIHRoaXMudHJpZXMgPSB0aGlzLnRyaWVzICsgMVxuICAgICAgdGhpcy5jYWxsYmFjaygpXG4gICAgfSwgdGhpcy50aW1lckNhbGModGhpcy50cmllcyArIDEpKVxuICB9XG59XG4iLCAiaW1wb3J0IHtjbG9zdXJlfSBmcm9tIFwiLi91dGlsc1wiXG5pbXBvcnQge1xuICBDSEFOTkVMX0VWRU5UUyxcbiAgQ0hBTk5FTF9TVEFURVMsXG59IGZyb20gXCIuL2NvbnN0YW50c1wiXG5cbmltcG9ydCBQdXNoIGZyb20gXCIuL3B1c2hcIlxuaW1wb3J0IFRpbWVyIGZyb20gXCIuL3RpbWVyXCJcblxuLyoqXG4gKlxuICogQHBhcmFtIHtzdHJpbmd9IHRvcGljXG4gKiBAcGFyYW0geyhPYmplY3R8ZnVuY3Rpb24pfSBwYXJhbXNcbiAqIEBwYXJhbSB7U29ja2V0fSBzb2NrZXRcbiAqL1xuZXhwb3J0IGRlZmF1bHQgY2xhc3MgQ2hhbm5lbCB7XG4gIGNvbnN0cnVjdG9yKHRvcGljLCBwYXJhbXMsIHNvY2tldCl7XG4gICAgdGhpcy5zdGF0ZSA9IENIQU5ORUxfU1RBVEVTLmNsb3NlZFxuICAgIHRoaXMudG9waWMgPSB0b3BpY1xuICAgIHRoaXMucGFyYW1zID0gY2xvc3VyZShwYXJhbXMgfHwge30pXG4gICAgdGhpcy5zb2NrZXQgPSBzb2NrZXRcbiAgICB0aGlzLmJpbmRpbmdzID0gW11cbiAgICB0aGlzLmJpbmRpbmdSZWYgPSAwXG4gICAgdGhpcy50aW1lb3V0ID0gdGhpcy5zb2NrZXQudGltZW91dFxuICAgIHRoaXMuam9pbmVkT25jZSA9IGZhbHNlXG4gICAgdGhpcy5qb2luUHVzaCA9IG5ldyBQdXNoKHRoaXMsIENIQU5ORUxfRVZFTlRTLmpvaW4sIHRoaXMucGFyYW1zLCB0aGlzLnRpbWVvdXQpXG4gICAgdGhpcy5wdXNoQnVmZmVyID0gW11cbiAgICB0aGlzLnN0YXRlQ2hhbmdlUmVmcyA9IFtdXG5cbiAgICB0aGlzLnJlam9pblRpbWVyID0gbmV3IFRpbWVyKCgpID0+IHtcbiAgICAgIGlmKHRoaXMuc29ja2V0LmlzQ29ubmVjdGVkKCkpeyB0aGlzLnJlam9pbigpIH1cbiAgICB9LCB0aGlzLnNvY2tldC5yZWpvaW5BZnRlck1zKVxuICAgIHRoaXMuc3RhdGVDaGFuZ2VSZWZzLnB1c2godGhpcy5zb2NrZXQub25FcnJvcigoKSA9PiB0aGlzLnJlam9pblRpbWVyLnJlc2V0KCkpKVxuICAgIHRoaXMuc3RhdGVDaGFuZ2VSZWZzLnB1c2godGhpcy5zb2NrZXQub25PcGVuKCgpID0+IHtcbiAgICAgIHRoaXMucmVqb2luVGltZXIucmVzZXQoKVxuICAgICAgaWYodGhpcy5pc0Vycm9yZWQoKSl7IHRoaXMucmVqb2luKCkgfVxuICAgIH0pXG4gICAgKVxuICAgIHRoaXMuam9pblB1c2gucmVjZWl2ZShcIm9rXCIsICgpID0+IHtcbiAgICAgIHRoaXMuc3RhdGUgPSBDSEFOTkVMX1NUQVRFUy5qb2luZWRcbiAgICAgIHRoaXMucmVqb2luVGltZXIucmVzZXQoKVxuICAgICAgdGhpcy5wdXNoQnVmZmVyLmZvckVhY2gocHVzaEV2ZW50ID0+IHB1c2hFdmVudC5zZW5kKCkpXG4gICAgICB0aGlzLnB1c2hCdWZmZXIgPSBbXVxuICAgIH0pXG4gICAgdGhpcy5qb2luUHVzaC5yZWNlaXZlKFwiZXJyb3JcIiwgKCkgPT4ge1xuICAgICAgdGhpcy5zdGF0ZSA9IENIQU5ORUxfU1RBVEVTLmVycm9yZWRcbiAgICAgIGlmKHRoaXMuc29ja2V0LmlzQ29ubmVjdGVkKCkpeyB0aGlzLnJlam9pblRpbWVyLnNjaGVkdWxlVGltZW91dCgpIH1cbiAgICB9KVxuICAgIHRoaXMub25DbG9zZSgoKSA9PiB7XG4gICAgICB0aGlzLnJlam9pblRpbWVyLnJlc2V0KClcbiAgICAgIGlmKHRoaXMuc29ja2V0Lmhhc0xvZ2dlcigpKSB0aGlzLnNvY2tldC5sb2coXCJjaGFubmVsXCIsIGBjbG9zZSAke3RoaXMudG9waWN9ICR7dGhpcy5qb2luUmVmKCl9YClcbiAgICAgIHRoaXMuc3RhdGUgPSBDSEFOTkVMX1NUQVRFUy5jbG9zZWRcbiAgICAgIHRoaXMuc29ja2V0LnJlbW92ZSh0aGlzKVxuICAgIH0pXG4gICAgdGhpcy5vbkVycm9yKHJlYXNvbiA9PiB7XG4gICAgICBpZih0aGlzLnNvY2tldC5oYXNMb2dnZXIoKSkgdGhpcy5zb2NrZXQubG9nKFwiY2hhbm5lbFwiLCBgZXJyb3IgJHt0aGlzLnRvcGljfWAsIHJlYXNvbilcbiAgICAgIGlmKHRoaXMuaXNKb2luaW5nKCkpeyB0aGlzLmpvaW5QdXNoLnJlc2V0KCkgfVxuICAgICAgdGhpcy5zdGF0ZSA9IENIQU5ORUxfU1RBVEVTLmVycm9yZWRcbiAgICAgIGlmKHRoaXMuc29ja2V0LmlzQ29ubmVjdGVkKCkpeyB0aGlzLnJlam9pblRpbWVyLnNjaGVkdWxlVGltZW91dCgpIH1cbiAgICB9KVxuICAgIHRoaXMuam9pblB1c2gucmVjZWl2ZShcInRpbWVvdXRcIiwgKCkgPT4ge1xuICAgICAgaWYodGhpcy5zb2NrZXQuaGFzTG9nZ2VyKCkpIHRoaXMuc29ja2V0LmxvZyhcImNoYW5uZWxcIiwgYHRpbWVvdXQgJHt0aGlzLnRvcGljfSAoJHt0aGlzLmpvaW5SZWYoKX0pYCwgdGhpcy5qb2luUHVzaC50aW1lb3V0KVxuICAgICAgbGV0IGxlYXZlUHVzaCA9IG5ldyBQdXNoKHRoaXMsIENIQU5ORUxfRVZFTlRTLmxlYXZlLCBjbG9zdXJlKHt9KSwgdGhpcy50aW1lb3V0KVxuICAgICAgbGVhdmVQdXNoLnNlbmQoKVxuICAgICAgdGhpcy5zdGF0ZSA9IENIQU5ORUxfU1RBVEVTLmVycm9yZWRcbiAgICAgIHRoaXMuam9pblB1c2gucmVzZXQoKVxuICAgICAgaWYodGhpcy5zb2NrZXQuaXNDb25uZWN0ZWQoKSl7IHRoaXMucmVqb2luVGltZXIuc2NoZWR1bGVUaW1lb3V0KCkgfVxuICAgIH0pXG4gICAgdGhpcy5vbihDSEFOTkVMX0VWRU5UUy5yZXBseSwgKHBheWxvYWQsIHJlZikgPT4ge1xuICAgICAgdGhpcy50cmlnZ2VyKHRoaXMucmVwbHlFdmVudE5hbWUocmVmKSwgcGF5bG9hZClcbiAgICB9KVxuICB9XG5cbiAgLyoqXG4gICAqIEpvaW4gdGhlIGNoYW5uZWxcbiAgICogQHBhcmFtIHtpbnRlZ2VyfSB0aW1lb3V0XG4gICAqIEByZXR1cm5zIHtQdXNofVxuICAgKi9cbiAgam9pbih0aW1lb3V0ID0gdGhpcy50aW1lb3V0KXtcbiAgICBpZih0aGlzLmpvaW5lZE9uY2Upe1xuICAgICAgdGhyb3cgbmV3IEVycm9yKFwidHJpZWQgdG8gam9pbiBtdWx0aXBsZSB0aW1lcy4gJ2pvaW4nIGNhbiBvbmx5IGJlIGNhbGxlZCBhIHNpbmdsZSB0aW1lIHBlciBjaGFubmVsIGluc3RhbmNlXCIpXG4gICAgfSBlbHNlIHtcbiAgICAgIHRoaXMudGltZW91dCA9IHRpbWVvdXRcbiAgICAgIHRoaXMuam9pbmVkT25jZSA9IHRydWVcbiAgICAgIHRoaXMucmVqb2luKClcbiAgICAgIHJldHVybiB0aGlzLmpvaW5QdXNoXG4gICAgfVxuICB9XG5cbiAgLyoqXG4gICAqIEhvb2sgaW50byBjaGFubmVsIGNsb3NlXG4gICAqIEBwYXJhbSB7RnVuY3Rpb259IGNhbGxiYWNrXG4gICAqL1xuICBvbkNsb3NlKGNhbGxiYWNrKXtcbiAgICB0aGlzLm9uKENIQU5ORUxfRVZFTlRTLmNsb3NlLCBjYWxsYmFjaylcbiAgfVxuXG4gIC8qKlxuICAgKiBIb29rIGludG8gY2hhbm5lbCBlcnJvcnNcbiAgICogQHBhcmFtIHtGdW5jdGlvbn0gY2FsbGJhY2tcbiAgICovXG4gIG9uRXJyb3IoY2FsbGJhY2spe1xuICAgIHJldHVybiB0aGlzLm9uKENIQU5ORUxfRVZFTlRTLmVycm9yLCByZWFzb24gPT4gY2FsbGJhY2socmVhc29uKSlcbiAgfVxuXG4gIC8qKlxuICAgKiBTdWJzY3JpYmVzIG9uIGNoYW5uZWwgZXZlbnRzXG4gICAqXG4gICAqIFN1YnNjcmlwdGlvbiByZXR1cm5zIGEgcmVmIGNvdW50ZXIsIHdoaWNoIGNhbiBiZSB1c2VkIGxhdGVyIHRvXG4gICAqIHVuc3Vic2NyaWJlIHRoZSBleGFjdCBldmVudCBsaXN0ZW5lclxuICAgKlxuICAgKiBAZXhhbXBsZVxuICAgKiBjb25zdCByZWYxID0gY2hhbm5lbC5vbihcImV2ZW50XCIsIGRvX3N0dWZmKVxuICAgKiBjb25zdCByZWYyID0gY2hhbm5lbC5vbihcImV2ZW50XCIsIGRvX290aGVyX3N0dWZmKVxuICAgKiBjaGFubmVsLm9mZihcImV2ZW50XCIsIHJlZjEpXG4gICAqIC8vIFNpbmNlIHVuc3Vic2NyaXB0aW9uLCBkb19zdHVmZiB3b24ndCBmaXJlLFxuICAgKiAvLyB3aGlsZSBkb19vdGhlcl9zdHVmZiB3aWxsIGtlZXAgZmlyaW5nIG9uIHRoZSBcImV2ZW50XCJcbiAgICpcbiAgICogQHBhcmFtIHtzdHJpbmd9IGV2ZW50XG4gICAqIEBwYXJhbSB7RnVuY3Rpb259IGNhbGxiYWNrXG4gICAqIEByZXR1cm5zIHtpbnRlZ2VyfSByZWZcbiAgICovXG4gIG9uKGV2ZW50LCBjYWxsYmFjayl7XG4gICAgbGV0IHJlZiA9IHRoaXMuYmluZGluZ1JlZisrXG4gICAgdGhpcy5iaW5kaW5ncy5wdXNoKHtldmVudCwgcmVmLCBjYWxsYmFja30pXG4gICAgcmV0dXJuIHJlZlxuICB9XG5cbiAgLyoqXG4gICAqIFVuc3Vic2NyaWJlcyBvZmYgb2YgY2hhbm5lbCBldmVudHNcbiAgICpcbiAgICogVXNlIHRoZSByZWYgcmV0dXJuZWQgZnJvbSBhIGNoYW5uZWwub24oKSB0byB1bnN1YnNjcmliZSBvbmVcbiAgICogaGFuZGxlciwgb3IgcGFzcyBub3RoaW5nIGZvciB0aGUgcmVmIHRvIHVuc3Vic2NyaWJlIGFsbFxuICAgKiBoYW5kbGVycyBmb3IgdGhlIGdpdmVuIGV2ZW50LlxuICAgKlxuICAgKiBAZXhhbXBsZVxuICAgKiAvLyBVbnN1YnNjcmliZSB0aGUgZG9fc3R1ZmYgaGFuZGxlclxuICAgKiBjb25zdCByZWYxID0gY2hhbm5lbC5vbihcImV2ZW50XCIsIGRvX3N0dWZmKVxuICAgKiBjaGFubmVsLm9mZihcImV2ZW50XCIsIHJlZjEpXG4gICAqXG4gICAqIC8vIFVuc3Vic2NyaWJlIGFsbCBoYW5kbGVycyBmcm9tIGV2ZW50XG4gICAqIGNoYW5uZWwub2ZmKFwiZXZlbnRcIilcbiAgICpcbiAgICogQHBhcmFtIHtzdHJpbmd9IGV2ZW50XG4gICAqIEBwYXJhbSB7aW50ZWdlcn0gcmVmXG4gICAqL1xuICBvZmYoZXZlbnQsIHJlZil7XG4gICAgdGhpcy5iaW5kaW5ncyA9IHRoaXMuYmluZGluZ3MuZmlsdGVyKChiaW5kKSA9PiB7XG4gICAgICByZXR1cm4gIShiaW5kLmV2ZW50ID09PSBldmVudCAmJiAodHlwZW9mIHJlZiA9PT0gXCJ1bmRlZmluZWRcIiB8fCByZWYgPT09IGJpbmQucmVmKSlcbiAgICB9KVxuICB9XG5cbiAgLyoqXG4gICAqIEBwcml2YXRlXG4gICAqL1xuICBjYW5QdXNoKCl7IHJldHVybiB0aGlzLnNvY2tldC5pc0Nvbm5lY3RlZCgpICYmIHRoaXMuaXNKb2luZWQoKSB9XG5cbiAgLyoqXG4gICAqIFNlbmRzIGEgbWVzc2FnZSBgZXZlbnRgIHRvIHBob2VuaXggd2l0aCB0aGUgcGF5bG9hZCBgcGF5bG9hZGAuXG4gICAqIFBob2VuaXggcmVjZWl2ZXMgdGhpcyBpbiB0aGUgYGhhbmRsZV9pbihldmVudCwgcGF5bG9hZCwgc29ja2V0KWBcbiAgICogZnVuY3Rpb24uIGlmIHBob2VuaXggcmVwbGllcyBvciBpdCB0aW1lcyBvdXQgKGRlZmF1bHQgMTAwMDBtcyksXG4gICAqIHRoZW4gb3B0aW9uYWxseSB0aGUgcmVwbHkgY2FuIGJlIHJlY2VpdmVkLlxuICAgKlxuICAgKiBAZXhhbXBsZVxuICAgKiBjaGFubmVsLnB1c2goXCJldmVudFwiKVxuICAgKiAgIC5yZWNlaXZlKFwib2tcIiwgcGF5bG9hZCA9PiBjb25zb2xlLmxvZyhcInBob2VuaXggcmVwbGllZDpcIiwgcGF5bG9hZCkpXG4gICAqICAgLnJlY2VpdmUoXCJlcnJvclwiLCBlcnIgPT4gY29uc29sZS5sb2coXCJwaG9lbml4IGVycm9yZWRcIiwgZXJyKSlcbiAgICogICAucmVjZWl2ZShcInRpbWVvdXRcIiwgKCkgPT4gY29uc29sZS5sb2coXCJ0aW1lZCBvdXQgcHVzaGluZ1wiKSlcbiAgICogQHBhcmFtIHtzdHJpbmd9IGV2ZW50XG4gICAqIEBwYXJhbSB7T2JqZWN0fSBwYXlsb2FkXG4gICAqIEBwYXJhbSB7bnVtYmVyfSBbdGltZW91dF1cbiAgICogQHJldHVybnMge1B1c2h9XG4gICAqL1xuICBwdXNoKGV2ZW50LCBwYXlsb2FkLCB0aW1lb3V0ID0gdGhpcy50aW1lb3V0KXtcbiAgICBwYXlsb2FkID0gcGF5bG9hZCB8fCB7fVxuICAgIGlmKCF0aGlzLmpvaW5lZE9uY2Upe1xuICAgICAgdGhyb3cgbmV3IEVycm9yKGB0cmllZCB0byBwdXNoICcke2V2ZW50fScgdG8gJyR7dGhpcy50b3BpY30nIGJlZm9yZSBqb2luaW5nLiBVc2UgY2hhbm5lbC5qb2luKCkgYmVmb3JlIHB1c2hpbmcgZXZlbnRzYClcbiAgICB9XG4gICAgbGV0IHB1c2hFdmVudCA9IG5ldyBQdXNoKHRoaXMsIGV2ZW50LCBmdW5jdGlvbiAoKXsgcmV0dXJuIHBheWxvYWQgfSwgdGltZW91dClcbiAgICBpZih0aGlzLmNhblB1c2goKSl7XG4gICAgICBwdXNoRXZlbnQuc2VuZCgpXG4gICAgfSBlbHNlIHtcbiAgICAgIHB1c2hFdmVudC5zdGFydFRpbWVvdXQoKVxuICAgICAgdGhpcy5wdXNoQnVmZmVyLnB1c2gocHVzaEV2ZW50KVxuICAgIH1cblxuICAgIHJldHVybiBwdXNoRXZlbnRcbiAgfVxuXG4gIC8qKiBMZWF2ZXMgdGhlIGNoYW5uZWxcbiAgICpcbiAgICogVW5zdWJzY3JpYmVzIGZyb20gc2VydmVyIGV2ZW50cywgYW5kXG4gICAqIGluc3RydWN0cyBjaGFubmVsIHRvIHRlcm1pbmF0ZSBvbiBzZXJ2ZXJcbiAgICpcbiAgICogVHJpZ2dlcnMgb25DbG9zZSgpIGhvb2tzXG4gICAqXG4gICAqIFRvIHJlY2VpdmUgbGVhdmUgYWNrbm93bGVkZ2VtZW50cywgdXNlIHRoZSBgcmVjZWl2ZWBcbiAgICogaG9vayB0byBiaW5kIHRvIHRoZSBzZXJ2ZXIgYWNrLCBpZTpcbiAgICpcbiAgICogQGV4YW1wbGVcbiAgICogY2hhbm5lbC5sZWF2ZSgpLnJlY2VpdmUoXCJva1wiLCAoKSA9PiBhbGVydChcImxlZnQhXCIpIClcbiAgICpcbiAgICogQHBhcmFtIHtpbnRlZ2VyfSB0aW1lb3V0XG4gICAqIEByZXR1cm5zIHtQdXNofVxuICAgKi9cbiAgbGVhdmUodGltZW91dCA9IHRoaXMudGltZW91dCl7XG4gICAgdGhpcy5yZWpvaW5UaW1lci5yZXNldCgpXG4gICAgdGhpcy5qb2luUHVzaC5jYW5jZWxUaW1lb3V0KClcblxuICAgIHRoaXMuc3RhdGUgPSBDSEFOTkVMX1NUQVRFUy5sZWF2aW5nXG4gICAgbGV0IG9uQ2xvc2UgPSAoKSA9PiB7XG4gICAgICBpZih0aGlzLnNvY2tldC5oYXNMb2dnZXIoKSkgdGhpcy5zb2NrZXQubG9nKFwiY2hhbm5lbFwiLCBgbGVhdmUgJHt0aGlzLnRvcGljfWApXG4gICAgICB0aGlzLnRyaWdnZXIoQ0hBTk5FTF9FVkVOVFMuY2xvc2UsIFwibGVhdmVcIilcbiAgICB9XG4gICAgbGV0IGxlYXZlUHVzaCA9IG5ldyBQdXNoKHRoaXMsIENIQU5ORUxfRVZFTlRTLmxlYXZlLCBjbG9zdXJlKHt9KSwgdGltZW91dClcbiAgICBsZWF2ZVB1c2gucmVjZWl2ZShcIm9rXCIsICgpID0+IG9uQ2xvc2UoKSlcbiAgICAgIC5yZWNlaXZlKFwidGltZW91dFwiLCAoKSA9PiBvbkNsb3NlKCkpXG4gICAgbGVhdmVQdXNoLnNlbmQoKVxuICAgIGlmKCF0aGlzLmNhblB1c2goKSl7IGxlYXZlUHVzaC50cmlnZ2VyKFwib2tcIiwge30pIH1cblxuICAgIHJldHVybiBsZWF2ZVB1c2hcbiAgfVxuXG4gIC8qKlxuICAgKiBPdmVycmlkYWJsZSBtZXNzYWdlIGhvb2tcbiAgICpcbiAgICogUmVjZWl2ZXMgYWxsIGV2ZW50cyBmb3Igc3BlY2lhbGl6ZWQgbWVzc2FnZSBoYW5kbGluZ1xuICAgKiBiZWZvcmUgZGlzcGF0Y2hpbmcgdG8gdGhlIGNoYW5uZWwgY2FsbGJhY2tzLlxuICAgKlxuICAgKiBNdXN0IHJldHVybiB0aGUgcGF5bG9hZCwgbW9kaWZpZWQgb3IgdW5tb2RpZmllZFxuICAgKiBAcGFyYW0ge3N0cmluZ30gZXZlbnRcbiAgICogQHBhcmFtIHtPYmplY3R9IHBheWxvYWRcbiAgICogQHBhcmFtIHtpbnRlZ2VyfSByZWZcbiAgICogQHJldHVybnMge09iamVjdH1cbiAgICovXG4gIG9uTWVzc2FnZShfZXZlbnQsIHBheWxvYWQsIF9yZWYpeyByZXR1cm4gcGF5bG9hZCB9XG5cbiAgLyoqXG4gICAqIEBwcml2YXRlXG4gICAqL1xuICBpc01lbWJlcih0b3BpYywgZXZlbnQsIHBheWxvYWQsIGpvaW5SZWYpe1xuICAgIGlmKHRoaXMudG9waWMgIT09IHRvcGljKXsgcmV0dXJuIGZhbHNlIH1cblxuICAgIGlmKGpvaW5SZWYgJiYgam9pblJlZiAhPT0gdGhpcy5qb2luUmVmKCkpe1xuICAgICAgaWYodGhpcy5zb2NrZXQuaGFzTG9nZ2VyKCkpIHRoaXMuc29ja2V0LmxvZyhcImNoYW5uZWxcIiwgXCJkcm9wcGluZyBvdXRkYXRlZCBtZXNzYWdlXCIsIHt0b3BpYywgZXZlbnQsIHBheWxvYWQsIGpvaW5SZWZ9KVxuICAgICAgcmV0dXJuIGZhbHNlXG4gICAgfSBlbHNlIHtcbiAgICAgIHJldHVybiB0cnVlXG4gICAgfVxuICB9XG5cbiAgLyoqXG4gICAqIEBwcml2YXRlXG4gICAqL1xuICBqb2luUmVmKCl7IHJldHVybiB0aGlzLmpvaW5QdXNoLnJlZiB9XG5cbiAgLyoqXG4gICAqIEBwcml2YXRlXG4gICAqL1xuICByZWpvaW4odGltZW91dCA9IHRoaXMudGltZW91dCl7XG4gICAgaWYodGhpcy5pc0xlYXZpbmcoKSl7IHJldHVybiB9XG4gICAgdGhpcy5zb2NrZXQubGVhdmVPcGVuVG9waWModGhpcy50b3BpYylcbiAgICB0aGlzLnN0YXRlID0gQ0hBTk5FTF9TVEFURVMuam9pbmluZ1xuICAgIHRoaXMuam9pblB1c2gucmVzZW5kKHRpbWVvdXQpXG4gIH1cblxuICAvKipcbiAgICogQHByaXZhdGVcbiAgICovXG4gIHRyaWdnZXIoZXZlbnQsIHBheWxvYWQsIHJlZiwgam9pblJlZil7XG4gICAgbGV0IGhhbmRsZWRQYXlsb2FkID0gdGhpcy5vbk1lc3NhZ2UoZXZlbnQsIHBheWxvYWQsIHJlZiwgam9pblJlZilcbiAgICBpZihwYXlsb2FkICYmICFoYW5kbGVkUGF5bG9hZCl7IHRocm93IG5ldyBFcnJvcihcImNoYW5uZWwgb25NZXNzYWdlIGNhbGxiYWNrcyBtdXN0IHJldHVybiB0aGUgcGF5bG9hZCwgbW9kaWZpZWQgb3IgdW5tb2RpZmllZFwiKSB9XG5cbiAgICBsZXQgZXZlbnRCaW5kaW5ncyA9IHRoaXMuYmluZGluZ3MuZmlsdGVyKGJpbmQgPT4gYmluZC5ldmVudCA9PT0gZXZlbnQpXG5cbiAgICBmb3IobGV0IGkgPSAwOyBpIDwgZXZlbnRCaW5kaW5ncy5sZW5ndGg7IGkrKyl7XG4gICAgICBsZXQgYmluZCA9IGV2ZW50QmluZGluZ3NbaV1cbiAgICAgIGJpbmQuY2FsbGJhY2soaGFuZGxlZFBheWxvYWQsIHJlZiwgam9pblJlZiB8fCB0aGlzLmpvaW5SZWYoKSlcbiAgICB9XG4gIH1cblxuICAvKipcbiAgICogQHByaXZhdGVcbiAgICovXG4gIHJlcGx5RXZlbnROYW1lKHJlZil7IHJldHVybiBgY2hhbl9yZXBseV8ke3JlZn1gIH1cblxuICAvKipcbiAgICogQHByaXZhdGVcbiAgICovXG4gIGlzQ2xvc2VkKCl7IHJldHVybiB0aGlzLnN0YXRlID09PSBDSEFOTkVMX1NUQVRFUy5jbG9zZWQgfVxuXG4gIC8qKlxuICAgKiBAcHJpdmF0ZVxuICAgKi9cbiAgaXNFcnJvcmVkKCl7IHJldHVybiB0aGlzLnN0YXRlID09PSBDSEFOTkVMX1NUQVRFUy5lcnJvcmVkIH1cblxuICAvKipcbiAgICogQHByaXZhdGVcbiAgICovXG4gIGlzSm9pbmVkKCl7IHJldHVybiB0aGlzLnN0YXRlID09PSBDSEFOTkVMX1NUQVRFUy5qb2luZWQgfVxuXG4gIC8qKlxuICAgKiBAcHJpdmF0ZVxuICAgKi9cbiAgaXNKb2luaW5nKCl7IHJldHVybiB0aGlzLnN0YXRlID09PSBDSEFOTkVMX1NUQVRFUy5qb2luaW5nIH1cblxuICAvKipcbiAgICogQHByaXZhdGVcbiAgICovXG4gIGlzTGVhdmluZygpeyByZXR1cm4gdGhpcy5zdGF0ZSA9PT0gQ0hBTk5FTF9TVEFURVMubGVhdmluZyB9XG59XG4iLCAiaW1wb3J0IHtcbiAgZ2xvYmFsLFxuICBYSFJfU1RBVEVTXG59IGZyb20gXCIuL2NvbnN0YW50c1wiXG5cbmV4cG9ydCBkZWZhdWx0IGNsYXNzIEFqYXgge1xuXG4gIHN0YXRpYyByZXF1ZXN0KG1ldGhvZCwgZW5kUG9pbnQsIGFjY2VwdCwgYm9keSwgdGltZW91dCwgb250aW1lb3V0LCBjYWxsYmFjayl7XG4gICAgaWYoZ2xvYmFsLlhEb21haW5SZXF1ZXN0KXtcbiAgICAgIGxldCByZXEgPSBuZXcgZ2xvYmFsLlhEb21haW5SZXF1ZXN0KCkgLy8gSUU4LCBJRTlcbiAgICAgIHJldHVybiB0aGlzLnhkb21haW5SZXF1ZXN0KHJlcSwgbWV0aG9kLCBlbmRQb2ludCwgYm9keSwgdGltZW91dCwgb250aW1lb3V0LCBjYWxsYmFjaylcbiAgICB9IGVsc2Uge1xuICAgICAgbGV0IHJlcSA9IG5ldyBnbG9iYWwuWE1MSHR0cFJlcXVlc3QoKSAvLyBJRTcrLCBGaXJlZm94LCBDaHJvbWUsIE9wZXJhLCBTYWZhcmlcbiAgICAgIHJldHVybiB0aGlzLnhoclJlcXVlc3QocmVxLCBtZXRob2QsIGVuZFBvaW50LCBhY2NlcHQsIGJvZHksIHRpbWVvdXQsIG9udGltZW91dCwgY2FsbGJhY2spXG4gICAgfVxuICB9XG5cbiAgc3RhdGljIHhkb21haW5SZXF1ZXN0KHJlcSwgbWV0aG9kLCBlbmRQb2ludCwgYm9keSwgdGltZW91dCwgb250aW1lb3V0LCBjYWxsYmFjayl7XG4gICAgcmVxLnRpbWVvdXQgPSB0aW1lb3V0XG4gICAgcmVxLm9wZW4obWV0aG9kLCBlbmRQb2ludClcbiAgICByZXEub25sb2FkID0gKCkgPT4ge1xuICAgICAgbGV0IHJlc3BvbnNlID0gdGhpcy5wYXJzZUpTT04ocmVxLnJlc3BvbnNlVGV4dClcbiAgICAgIGNhbGxiYWNrICYmIGNhbGxiYWNrKHJlc3BvbnNlKVxuICAgIH1cbiAgICBpZihvbnRpbWVvdXQpeyByZXEub250aW1lb3V0ID0gb250aW1lb3V0IH1cblxuICAgIC8vIFdvcmsgYXJvdW5kIGJ1ZyBpbiBJRTkgdGhhdCByZXF1aXJlcyBhbiBhdHRhY2hlZCBvbnByb2dyZXNzIGhhbmRsZXJcbiAgICByZXEub25wcm9ncmVzcyA9ICgpID0+IHsgfVxuXG4gICAgcmVxLnNlbmQoYm9keSlcbiAgICByZXR1cm4gcmVxXG4gIH1cblxuICBzdGF0aWMgeGhyUmVxdWVzdChyZXEsIG1ldGhvZCwgZW5kUG9pbnQsIGFjY2VwdCwgYm9keSwgdGltZW91dCwgb250aW1lb3V0LCBjYWxsYmFjayl7XG4gICAgcmVxLm9wZW4obWV0aG9kLCBlbmRQb2ludCwgdHJ1ZSlcbiAgICByZXEudGltZW91dCA9IHRpbWVvdXRcbiAgICByZXEuc2V0UmVxdWVzdEhlYWRlcihcIkNvbnRlbnQtVHlwZVwiLCBhY2NlcHQpXG4gICAgcmVxLm9uZXJyb3IgPSAoKSA9PiBjYWxsYmFjayAmJiBjYWxsYmFjayhudWxsKVxuICAgIHJlcS5vbnJlYWR5c3RhdGVjaGFuZ2UgPSAoKSA9PiB7XG4gICAgICBpZihyZXEucmVhZHlTdGF0ZSA9PT0gWEhSX1NUQVRFUy5jb21wbGV0ZSAmJiBjYWxsYmFjayl7XG4gICAgICAgIGxldCByZXNwb25zZSA9IHRoaXMucGFyc2VKU09OKHJlcS5yZXNwb25zZVRleHQpXG4gICAgICAgIGNhbGxiYWNrKHJlc3BvbnNlKVxuICAgICAgfVxuICAgIH1cbiAgICBpZihvbnRpbWVvdXQpeyByZXEub250aW1lb3V0ID0gb250aW1lb3V0IH1cblxuICAgIHJlcS5zZW5kKGJvZHkpXG4gICAgcmV0dXJuIHJlcVxuICB9XG5cbiAgc3RhdGljIHBhcnNlSlNPTihyZXNwKXtcbiAgICBpZighcmVzcCB8fCByZXNwID09PSBcIlwiKXsgcmV0dXJuIG51bGwgfVxuXG4gICAgdHJ5IHtcbiAgICAgIHJldHVybiBKU09OLnBhcnNlKHJlc3ApXG4gICAgfSBjYXRjaCAoZSl7XG4gICAgICBjb25zb2xlICYmIGNvbnNvbGUubG9nKFwiZmFpbGVkIHRvIHBhcnNlIEpTT04gcmVzcG9uc2VcIiwgcmVzcClcbiAgICAgIHJldHVybiBudWxsXG4gICAgfVxuICB9XG5cbiAgc3RhdGljIHNlcmlhbGl6ZShvYmosIHBhcmVudEtleSl7XG4gICAgbGV0IHF1ZXJ5U3RyID0gW11cbiAgICBmb3IodmFyIGtleSBpbiBvYmope1xuICAgICAgaWYoIU9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChvYmosIGtleSkpeyBjb250aW51ZSB9XG4gICAgICBsZXQgcGFyYW1LZXkgPSBwYXJlbnRLZXkgPyBgJHtwYXJlbnRLZXl9WyR7a2V5fV1gIDoga2V5XG4gICAgICBsZXQgcGFyYW1WYWwgPSBvYmpba2V5XVxuICAgICAgaWYodHlwZW9mIHBhcmFtVmFsID09PSBcIm9iamVjdFwiKXtcbiAgICAgICAgcXVlcnlTdHIucHVzaCh0aGlzLnNlcmlhbGl6ZShwYXJhbVZhbCwgcGFyYW1LZXkpKVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgcXVlcnlTdHIucHVzaChlbmNvZGVVUklDb21wb25lbnQocGFyYW1LZXkpICsgXCI9XCIgKyBlbmNvZGVVUklDb21wb25lbnQocGFyYW1WYWwpKVxuICAgICAgfVxuICAgIH1cbiAgICByZXR1cm4gcXVlcnlTdHIuam9pbihcIiZcIilcbiAgfVxuXG4gIHN0YXRpYyBhcHBlbmRQYXJhbXModXJsLCBwYXJhbXMpe1xuICAgIGlmKE9iamVjdC5rZXlzKHBhcmFtcykubGVuZ3RoID09PSAwKXsgcmV0dXJuIHVybCB9XG5cbiAgICBsZXQgcHJlZml4ID0gdXJsLm1hdGNoKC9cXD8vKSA/IFwiJlwiIDogXCI/XCJcbiAgICByZXR1cm4gYCR7dXJsfSR7cHJlZml4fSR7dGhpcy5zZXJpYWxpemUocGFyYW1zKX1gXG4gIH1cbn1cbiIsICJpbXBvcnQge1xuICBTT0NLRVRfU1RBVEVTLFxuICBUUkFOU1BPUlRTXG59IGZyb20gXCIuL2NvbnN0YW50c1wiXG5cbmltcG9ydCBBamF4IGZyb20gXCIuL2FqYXhcIlxuXG5leHBvcnQgZGVmYXVsdCBjbGFzcyBMb25nUG9sbCB7XG5cbiAgY29uc3RydWN0b3IoZW5kUG9pbnQpe1xuICAgIHRoaXMuZW5kUG9pbnQgPSBudWxsXG4gICAgdGhpcy50b2tlbiA9IG51bGxcbiAgICB0aGlzLnNraXBIZWFydGJlYXQgPSB0cnVlXG4gICAgdGhpcy5yZXFzID0gbmV3IFNldCgpXG4gICAgdGhpcy5hd2FpdGluZ0JhdGNoQWNrID0gZmFsc2VcbiAgICB0aGlzLmN1cnJlbnRCYXRjaCA9IG51bGxcbiAgICB0aGlzLmN1cnJlbnRCYXRjaFRpbWVyID0gbnVsbFxuICAgIHRoaXMuYmF0Y2hCdWZmZXIgPSBbXVxuICAgIHRoaXMub25vcGVuID0gZnVuY3Rpb24gKCl7IH0gLy8gbm9vcFxuICAgIHRoaXMub25lcnJvciA9IGZ1bmN0aW9uICgpeyB9IC8vIG5vb3BcbiAgICB0aGlzLm9ubWVzc2FnZSA9IGZ1bmN0aW9uICgpeyB9IC8vIG5vb3BcbiAgICB0aGlzLm9uY2xvc2UgPSBmdW5jdGlvbiAoKXsgfSAvLyBub29wXG4gICAgdGhpcy5wb2xsRW5kcG9pbnQgPSB0aGlzLm5vcm1hbGl6ZUVuZHBvaW50KGVuZFBvaW50KVxuICAgIHRoaXMucmVhZHlTdGF0ZSA9IFNPQ0tFVF9TVEFURVMuY29ubmVjdGluZ1xuICAgIHRoaXMucG9sbCgpXG4gIH1cblxuICBub3JtYWxpemVFbmRwb2ludChlbmRQb2ludCl7XG4gICAgcmV0dXJuIChlbmRQb2ludFxuICAgICAgLnJlcGxhY2UoXCJ3czovL1wiLCBcImh0dHA6Ly9cIilcbiAgICAgIC5yZXBsYWNlKFwid3NzOi8vXCIsIFwiaHR0cHM6Ly9cIilcbiAgICAgIC5yZXBsYWNlKG5ldyBSZWdFeHAoXCIoLiopXFwvXCIgKyBUUkFOU1BPUlRTLndlYnNvY2tldCksIFwiJDEvXCIgKyBUUkFOU1BPUlRTLmxvbmdwb2xsKSlcbiAgfVxuXG4gIGVuZHBvaW50VVJMKCl7XG4gICAgcmV0dXJuIEFqYXguYXBwZW5kUGFyYW1zKHRoaXMucG9sbEVuZHBvaW50LCB7dG9rZW46IHRoaXMudG9rZW59KVxuICB9XG5cbiAgY2xvc2VBbmRSZXRyeShjb2RlLCByZWFzb24sIHdhc0NsZWFuKXtcbiAgICB0aGlzLmNsb3NlKGNvZGUsIHJlYXNvbiwgd2FzQ2xlYW4pXG4gICAgdGhpcy5yZWFkeVN0YXRlID0gU09DS0VUX1NUQVRFUy5jb25uZWN0aW5nXG4gIH1cblxuICBvbnRpbWVvdXQoKXtcbiAgICB0aGlzLm9uZXJyb3IoXCJ0aW1lb3V0XCIpXG4gICAgdGhpcy5jbG9zZUFuZFJldHJ5KDEwMDUsIFwidGltZW91dFwiLCBmYWxzZSlcbiAgfVxuXG4gIGlzQWN0aXZlKCl7IHJldHVybiB0aGlzLnJlYWR5U3RhdGUgPT09IFNPQ0tFVF9TVEFURVMub3BlbiB8fCB0aGlzLnJlYWR5U3RhdGUgPT09IFNPQ0tFVF9TVEFURVMuY29ubmVjdGluZyB9XG5cbiAgcG9sbCgpe1xuICAgIHRoaXMuYWpheChcIkdFVFwiLCBcImFwcGxpY2F0aW9uL2pzb25cIiwgbnVsbCwgKCkgPT4gdGhpcy5vbnRpbWVvdXQoKSwgcmVzcCA9PiB7XG4gICAgICBpZihyZXNwKXtcbiAgICAgICAgdmFyIHtzdGF0dXMsIHRva2VuLCBtZXNzYWdlc30gPSByZXNwXG4gICAgICAgIHRoaXMudG9rZW4gPSB0b2tlblxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgc3RhdHVzID0gMFxuICAgICAgfVxuXG4gICAgICBzd2l0Y2goc3RhdHVzKXtcbiAgICAgICAgY2FzZSAyMDA6XG4gICAgICAgICAgbWVzc2FnZXMuZm9yRWFjaChtc2cgPT4ge1xuICAgICAgICAgICAgLy8gVGFza3MgYXJlIHdoYXQgdGhpbmdzIGxpa2UgZXZlbnQgaGFuZGxlcnMsIHNldFRpbWVvdXQgY2FsbGJhY2tzLFxuICAgICAgICAgICAgLy8gcHJvbWlzZSByZXNvbHZlcyBhbmQgbW9yZSBhcmUgcnVuIHdpdGhpbi5cbiAgICAgICAgICAgIC8vIEluIG1vZGVybiBicm93c2VycywgdGhlcmUgYXJlIHR3byBkaWZmZXJlbnQga2luZHMgb2YgdGFza3MsXG4gICAgICAgICAgICAvLyBtaWNyb3Rhc2tzIGFuZCBtYWNyb3Rhc2tzLlxuICAgICAgICAgICAgLy8gTWljcm90YXNrcyBhcmUgbWFpbmx5IHVzZWQgZm9yIFByb21pc2VzLCB3aGlsZSBtYWNyb3Rhc2tzIGFyZVxuICAgICAgICAgICAgLy8gdXNlZCBmb3IgZXZlcnl0aGluZyBlbHNlLlxuICAgICAgICAgICAgLy8gTWljcm90YXNrcyBhbHdheXMgaGF2ZSBwcmlvcml0eSBvdmVyIG1hY3JvdGFza3MuIElmIHRoZSBKUyBlbmdpbmVcbiAgICAgICAgICAgIC8vIGlzIGxvb2tpbmcgZm9yIGEgdGFzayB0byBydW4sIGl0IHdpbGwgYWx3YXlzIHRyeSB0byBlbXB0eSB0aGVcbiAgICAgICAgICAgIC8vIG1pY3JvdGFzayBxdWV1ZSBiZWZvcmUgYXR0ZW1wdGluZyB0byBydW4gYW55dGhpbmcgZnJvbSB0aGVcbiAgICAgICAgICAgIC8vIG1hY3JvdGFzayBxdWV1ZS5cbiAgICAgICAgICAgIC8vXG4gICAgICAgICAgICAvLyBGb3IgdGhlIFdlYlNvY2tldCB0cmFuc3BvcnQsIG1lc3NhZ2VzIGFsd2F5cyBhcnJpdmUgaW4gdGhlaXIgb3duXG4gICAgICAgICAgICAvLyBldmVudC4gVGhpcyBtZWFucyB0aGF0IGlmIGFueSBwcm9taXNlcyBhcmUgcmVzb2x2ZWQgZnJvbSB3aXRoaW4sXG4gICAgICAgICAgICAvLyB0aGVpciBjYWxsYmFja3Mgd2lsbCBhbHdheXMgZmluaXNoIGV4ZWN1dGlvbiBieSB0aGUgdGltZSB0aGVcbiAgICAgICAgICAgIC8vIG5leHQgbWVzc2FnZSBldmVudCBoYW5kbGVyIGlzIHJ1bi5cbiAgICAgICAgICAgIC8vXG4gICAgICAgICAgICAvLyBJbiBvcmRlciB0byBlbXVsYXRlIHRoaXMgYmVoYXZpb3VyLCB3ZSBuZWVkIHRvIG1ha2Ugc3VyZSBlYWNoXG4gICAgICAgICAgICAvLyBvbm1lc3NhZ2UgaGFuZGxlciBpcyBydW4gd2l0aGluIGl0cyBvd24gbWFjcm90YXNrLlxuICAgICAgICAgICAgc2V0VGltZW91dCgoKSA9PiB0aGlzLm9ubWVzc2FnZSh7ZGF0YTogbXNnfSksIDApXG4gICAgICAgICAgfSlcbiAgICAgICAgICB0aGlzLnBvbGwoKVxuICAgICAgICAgIGJyZWFrXG4gICAgICAgIGNhc2UgMjA0OlxuICAgICAgICAgIHRoaXMucG9sbCgpXG4gICAgICAgICAgYnJlYWtcbiAgICAgICAgY2FzZSA0MTA6XG4gICAgICAgICAgdGhpcy5yZWFkeVN0YXRlID0gU09DS0VUX1NUQVRFUy5vcGVuXG4gICAgICAgICAgdGhpcy5vbm9wZW4oe30pXG4gICAgICAgICAgdGhpcy5wb2xsKClcbiAgICAgICAgICBicmVha1xuICAgICAgICBjYXNlIDQwMzpcbiAgICAgICAgICB0aGlzLm9uZXJyb3IoNDAzKVxuICAgICAgICAgIHRoaXMuY2xvc2UoMTAwOCwgXCJmb3JiaWRkZW5cIiwgZmFsc2UpXG4gICAgICAgICAgYnJlYWtcbiAgICAgICAgY2FzZSAwOlxuICAgICAgICBjYXNlIDUwMDpcbiAgICAgICAgICB0aGlzLm9uZXJyb3IoNTAwKVxuICAgICAgICAgIHRoaXMuY2xvc2VBbmRSZXRyeSgxMDExLCBcImludGVybmFsIHNlcnZlciBlcnJvclwiLCA1MDApXG4gICAgICAgICAgYnJlYWtcbiAgICAgICAgZGVmYXVsdDogdGhyb3cgbmV3IEVycm9yKGB1bmhhbmRsZWQgcG9sbCBzdGF0dXMgJHtzdGF0dXN9YClcbiAgICAgIH1cbiAgICB9KVxuICB9XG5cbiAgLy8gd2UgY29sbGVjdCBhbGwgcHVzaGVzIHdpdGhpbiB0aGUgY3VycmVudCBldmVudCBsb29wIGJ5XG4gIC8vIHNldFRpbWVvdXQgMCwgd2hpY2ggb3B0aW1pemVzIGJhY2stdG8tYmFjayBwcm9jZWR1cmFsXG4gIC8vIHB1c2hlcyBhZ2FpbnN0IGFuIGVtcHR5IGJ1ZmZlclxuICBzZW5kKGJvZHkpe1xuICAgIGlmKHRoaXMuY3VycmVudEJhdGNoKXtcbiAgICAgIHRoaXMuY3VycmVudEJhdGNoLnB1c2goYm9keSlcbiAgICB9IGVsc2UgaWYodGhpcy5hd2FpdGluZ0JhdGNoQWNrKXtcbiAgICAgIHRoaXMuYmF0Y2hCdWZmZXIucHVzaChib2R5KVxuICAgIH0gZWxzZSB7XG4gICAgICB0aGlzLmN1cnJlbnRCYXRjaCA9IFtib2R5XVxuICAgICAgdGhpcy5jdXJyZW50QmF0Y2hUaW1lciA9IHNldFRpbWVvdXQoKCkgPT4ge1xuICAgICAgICB0aGlzLmJhdGNoU2VuZCh0aGlzLmN1cnJlbnRCYXRjaClcbiAgICAgICAgdGhpcy5jdXJyZW50QmF0Y2ggPSBudWxsXG4gICAgICB9LCAwKVxuICAgIH1cbiAgfVxuXG4gIGJhdGNoU2VuZChtZXNzYWdlcyl7XG4gICAgdGhpcy5hd2FpdGluZ0JhdGNoQWNrID0gdHJ1ZVxuICAgIHRoaXMuYWpheChcIlBPU1RcIiwgXCJhcHBsaWNhdGlvbi94LW5kanNvblwiLCBtZXNzYWdlcy5qb2luKFwiXFxuXCIpLCAoKSA9PiB0aGlzLm9uZXJyb3IoXCJ0aW1lb3V0XCIpLCByZXNwID0+IHtcbiAgICAgIHRoaXMuYXdhaXRpbmdCYXRjaEFjayA9IGZhbHNlXG4gICAgICBpZighcmVzcCB8fCByZXNwLnN0YXR1cyAhPT0gMjAwKXtcbiAgICAgICAgdGhpcy5vbmVycm9yKHJlc3AgJiYgcmVzcC5zdGF0dXMpXG4gICAgICAgIHRoaXMuY2xvc2VBbmRSZXRyeSgxMDExLCBcImludGVybmFsIHNlcnZlciBlcnJvclwiLCBmYWxzZSlcbiAgICAgIH0gZWxzZSBpZih0aGlzLmJhdGNoQnVmZmVyLmxlbmd0aCA+IDApe1xuICAgICAgICB0aGlzLmJhdGNoU2VuZCh0aGlzLmJhdGNoQnVmZmVyKVxuICAgICAgICB0aGlzLmJhdGNoQnVmZmVyID0gW11cbiAgICAgIH1cbiAgICB9KVxuICB9XG5cbiAgY2xvc2UoY29kZSwgcmVhc29uLCB3YXNDbGVhbil7XG4gICAgZm9yKGxldCByZXEgb2YgdGhpcy5yZXFzKXsgcmVxLmFib3J0KCkgfVxuICAgIHRoaXMucmVhZHlTdGF0ZSA9IFNPQ0tFVF9TVEFURVMuY2xvc2VkXG4gICAgbGV0IG9wdHMgPSBPYmplY3QuYXNzaWduKHtjb2RlOiAxMDAwLCByZWFzb246IHVuZGVmaW5lZCwgd2FzQ2xlYW46IHRydWV9LCB7Y29kZSwgcmVhc29uLCB3YXNDbGVhbn0pXG4gICAgdGhpcy5iYXRjaEJ1ZmZlciA9IFtdXG4gICAgY2xlYXJUaW1lb3V0KHRoaXMuY3VycmVudEJhdGNoVGltZXIpXG4gICAgdGhpcy5jdXJyZW50QmF0Y2hUaW1lciA9IG51bGxcbiAgICBpZih0eXBlb2YoQ2xvc2VFdmVudCkgIT09IFwidW5kZWZpbmVkXCIpe1xuICAgICAgdGhpcy5vbmNsb3NlKG5ldyBDbG9zZUV2ZW50KFwiY2xvc2VcIiwgb3B0cykpXG4gICAgfSBlbHNlIHtcbiAgICAgIHRoaXMub25jbG9zZShvcHRzKVxuICAgIH1cbiAgfVxuXG4gIGFqYXgobWV0aG9kLCBjb250ZW50VHlwZSwgYm9keSwgb25DYWxsZXJUaW1lb3V0LCBjYWxsYmFjayl7XG4gICAgbGV0IHJlcVxuICAgIGxldCBvbnRpbWVvdXQgPSAoKSA9PiB7XG4gICAgICB0aGlzLnJlcXMuZGVsZXRlKHJlcSlcbiAgICAgIG9uQ2FsbGVyVGltZW91dCgpXG4gICAgfVxuICAgIHJlcSA9IEFqYXgucmVxdWVzdChtZXRob2QsIHRoaXMuZW5kcG9pbnRVUkwoKSwgY29udGVudFR5cGUsIGJvZHksIHRoaXMudGltZW91dCwgb250aW1lb3V0LCByZXNwID0+IHtcbiAgICAgIHRoaXMucmVxcy5kZWxldGUocmVxKVxuICAgICAgaWYodGhpcy5pc0FjdGl2ZSgpKXsgY2FsbGJhY2socmVzcCkgfVxuICAgIH0pXG4gICAgdGhpcy5yZXFzLmFkZChyZXEpXG4gIH1cbn1cbiIsICIvKipcbiAqIEluaXRpYWxpemVzIHRoZSBQcmVzZW5jZVxuICogQHBhcmFtIHtDaGFubmVsfSBjaGFubmVsIC0gVGhlIENoYW5uZWxcbiAqIEBwYXJhbSB7T2JqZWN0fSBvcHRzIC0gVGhlIG9wdGlvbnMsXG4gKiAgICAgICAgZm9yIGV4YW1wbGUgYHtldmVudHM6IHtzdGF0ZTogXCJzdGF0ZVwiLCBkaWZmOiBcImRpZmZcIn19YFxuICovXG5leHBvcnQgZGVmYXVsdCBjbGFzcyBQcmVzZW5jZSB7XG5cbiAgY29uc3RydWN0b3IoY2hhbm5lbCwgb3B0cyA9IHt9KXtcbiAgICBsZXQgZXZlbnRzID0gb3B0cy5ldmVudHMgfHwge3N0YXRlOiBcInByZXNlbmNlX3N0YXRlXCIsIGRpZmY6IFwicHJlc2VuY2VfZGlmZlwifVxuICAgIHRoaXMuc3RhdGUgPSB7fVxuICAgIHRoaXMucGVuZGluZ0RpZmZzID0gW11cbiAgICB0aGlzLmNoYW5uZWwgPSBjaGFubmVsXG4gICAgdGhpcy5qb2luUmVmID0gbnVsbFxuICAgIHRoaXMuY2FsbGVyID0ge1xuICAgICAgb25Kb2luOiBmdW5jdGlvbiAoKXsgfSxcbiAgICAgIG9uTGVhdmU6IGZ1bmN0aW9uICgpeyB9LFxuICAgICAgb25TeW5jOiBmdW5jdGlvbiAoKXsgfVxuICAgIH1cblxuICAgIHRoaXMuY2hhbm5lbC5vbihldmVudHMuc3RhdGUsIG5ld1N0YXRlID0+IHtcbiAgICAgIGxldCB7b25Kb2luLCBvbkxlYXZlLCBvblN5bmN9ID0gdGhpcy5jYWxsZXJcblxuICAgICAgdGhpcy5qb2luUmVmID0gdGhpcy5jaGFubmVsLmpvaW5SZWYoKVxuICAgICAgdGhpcy5zdGF0ZSA9IFByZXNlbmNlLnN5bmNTdGF0ZSh0aGlzLnN0YXRlLCBuZXdTdGF0ZSwgb25Kb2luLCBvbkxlYXZlKVxuXG4gICAgICB0aGlzLnBlbmRpbmdEaWZmcy5mb3JFYWNoKGRpZmYgPT4ge1xuICAgICAgICB0aGlzLnN0YXRlID0gUHJlc2VuY2Uuc3luY0RpZmYodGhpcy5zdGF0ZSwgZGlmZiwgb25Kb2luLCBvbkxlYXZlKVxuICAgICAgfSlcbiAgICAgIHRoaXMucGVuZGluZ0RpZmZzID0gW11cbiAgICAgIG9uU3luYygpXG4gICAgfSlcblxuICAgIHRoaXMuY2hhbm5lbC5vbihldmVudHMuZGlmZiwgZGlmZiA9PiB7XG4gICAgICBsZXQge29uSm9pbiwgb25MZWF2ZSwgb25TeW5jfSA9IHRoaXMuY2FsbGVyXG5cbiAgICAgIGlmKHRoaXMuaW5QZW5kaW5nU3luY1N0YXRlKCkpe1xuICAgICAgICB0aGlzLnBlbmRpbmdEaWZmcy5wdXNoKGRpZmYpXG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLnN0YXRlID0gUHJlc2VuY2Uuc3luY0RpZmYodGhpcy5zdGF0ZSwgZGlmZiwgb25Kb2luLCBvbkxlYXZlKVxuICAgICAgICBvblN5bmMoKVxuICAgICAgfVxuICAgIH0pXG4gIH1cblxuICBvbkpvaW4oY2FsbGJhY2speyB0aGlzLmNhbGxlci5vbkpvaW4gPSBjYWxsYmFjayB9XG5cbiAgb25MZWF2ZShjYWxsYmFjayl7IHRoaXMuY2FsbGVyLm9uTGVhdmUgPSBjYWxsYmFjayB9XG5cbiAgb25TeW5jKGNhbGxiYWNrKXsgdGhpcy5jYWxsZXIub25TeW5jID0gY2FsbGJhY2sgfVxuXG4gIGxpc3QoYnkpeyByZXR1cm4gUHJlc2VuY2UubGlzdCh0aGlzLnN0YXRlLCBieSkgfVxuXG4gIGluUGVuZGluZ1N5bmNTdGF0ZSgpe1xuICAgIHJldHVybiAhdGhpcy5qb2luUmVmIHx8ICh0aGlzLmpvaW5SZWYgIT09IHRoaXMuY2hhbm5lbC5qb2luUmVmKCkpXG4gIH1cblxuICAvLyBsb3dlci1sZXZlbCBwdWJsaWMgc3RhdGljIEFQSVxuXG4gIC8qKlxuICAgKiBVc2VkIHRvIHN5bmMgdGhlIGxpc3Qgb2YgcHJlc2VuY2VzIG9uIHRoZSBzZXJ2ZXJcbiAgICogd2l0aCB0aGUgY2xpZW50J3Mgc3RhdGUuIEFuIG9wdGlvbmFsIGBvbkpvaW5gIGFuZCBgb25MZWF2ZWAgY2FsbGJhY2sgY2FuXG4gICAqIGJlIHByb3ZpZGVkIHRvIHJlYWN0IHRvIGNoYW5nZXMgaW4gdGhlIGNsaWVudCdzIGxvY2FsIHByZXNlbmNlcyBhY3Jvc3NcbiAgICogZGlzY29ubmVjdHMgYW5kIHJlY29ubmVjdHMgd2l0aCB0aGUgc2VydmVyLlxuICAgKlxuICAgKiBAcmV0dXJucyB7UHJlc2VuY2V9XG4gICAqL1xuICBzdGF0aWMgc3luY1N0YXRlKGN1cnJlbnRTdGF0ZSwgbmV3U3RhdGUsIG9uSm9pbiwgb25MZWF2ZSl7XG4gICAgbGV0IHN0YXRlID0gdGhpcy5jbG9uZShjdXJyZW50U3RhdGUpXG4gICAgbGV0IGpvaW5zID0ge31cbiAgICBsZXQgbGVhdmVzID0ge31cblxuICAgIHRoaXMubWFwKHN0YXRlLCAoa2V5LCBwcmVzZW5jZSkgPT4ge1xuICAgICAgaWYoIW5ld1N0YXRlW2tleV0pe1xuICAgICAgICBsZWF2ZXNba2V5XSA9IHByZXNlbmNlXG4gICAgICB9XG4gICAgfSlcbiAgICB0aGlzLm1hcChuZXdTdGF0ZSwgKGtleSwgbmV3UHJlc2VuY2UpID0+IHtcbiAgICAgIGxldCBjdXJyZW50UHJlc2VuY2UgPSBzdGF0ZVtrZXldXG4gICAgICBpZihjdXJyZW50UHJlc2VuY2Upe1xuICAgICAgICBsZXQgbmV3UmVmcyA9IG5ld1ByZXNlbmNlLm1ldGFzLm1hcChtID0+IG0ucGh4X3JlZilcbiAgICAgICAgbGV0IGN1clJlZnMgPSBjdXJyZW50UHJlc2VuY2UubWV0YXMubWFwKG0gPT4gbS5waHhfcmVmKVxuICAgICAgICBsZXQgam9pbmVkTWV0YXMgPSBuZXdQcmVzZW5jZS5tZXRhcy5maWx0ZXIobSA9PiBjdXJSZWZzLmluZGV4T2YobS5waHhfcmVmKSA8IDApXG4gICAgICAgIGxldCBsZWZ0TWV0YXMgPSBjdXJyZW50UHJlc2VuY2UubWV0YXMuZmlsdGVyKG0gPT4gbmV3UmVmcy5pbmRleE9mKG0ucGh4X3JlZikgPCAwKVxuICAgICAgICBpZihqb2luZWRNZXRhcy5sZW5ndGggPiAwKXtcbiAgICAgICAgICBqb2luc1trZXldID0gbmV3UHJlc2VuY2VcbiAgICAgICAgICBqb2luc1trZXldLm1ldGFzID0gam9pbmVkTWV0YXNcbiAgICAgICAgfVxuICAgICAgICBpZihsZWZ0TWV0YXMubGVuZ3RoID4gMCl7XG4gICAgICAgICAgbGVhdmVzW2tleV0gPSB0aGlzLmNsb25lKGN1cnJlbnRQcmVzZW5jZSlcbiAgICAgICAgICBsZWF2ZXNba2V5XS5tZXRhcyA9IGxlZnRNZXRhc1xuICAgICAgICB9XG4gICAgICB9IGVsc2Uge1xuICAgICAgICBqb2luc1trZXldID0gbmV3UHJlc2VuY2VcbiAgICAgIH1cbiAgICB9KVxuICAgIHJldHVybiB0aGlzLnN5bmNEaWZmKHN0YXRlLCB7am9pbnM6IGpvaW5zLCBsZWF2ZXM6IGxlYXZlc30sIG9uSm9pbiwgb25MZWF2ZSlcbiAgfVxuXG4gIC8qKlxuICAgKlxuICAgKiBVc2VkIHRvIHN5bmMgYSBkaWZmIG9mIHByZXNlbmNlIGpvaW4gYW5kIGxlYXZlXG4gICAqIGV2ZW50cyBmcm9tIHRoZSBzZXJ2ZXIsIGFzIHRoZXkgaGFwcGVuLiBMaWtlIGBzeW5jU3RhdGVgLCBgc3luY0RpZmZgXG4gICAqIGFjY2VwdHMgb3B0aW9uYWwgYG9uSm9pbmAgYW5kIGBvbkxlYXZlYCBjYWxsYmFja3MgdG8gcmVhY3QgdG8gYSB1c2VyXG4gICAqIGpvaW5pbmcgb3IgbGVhdmluZyBmcm9tIGEgZGV2aWNlLlxuICAgKlxuICAgKiBAcmV0dXJucyB7UHJlc2VuY2V9XG4gICAqL1xuICBzdGF0aWMgc3luY0RpZmYoc3RhdGUsIGRpZmYsIG9uSm9pbiwgb25MZWF2ZSl7XG4gICAgbGV0IHtqb2lucywgbGVhdmVzfSA9IHRoaXMuY2xvbmUoZGlmZilcbiAgICBpZighb25Kb2luKXsgb25Kb2luID0gZnVuY3Rpb24gKCl7IH0gfVxuICAgIGlmKCFvbkxlYXZlKXsgb25MZWF2ZSA9IGZ1bmN0aW9uICgpeyB9IH1cblxuICAgIHRoaXMubWFwKGpvaW5zLCAoa2V5LCBuZXdQcmVzZW5jZSkgPT4ge1xuICAgICAgbGV0IGN1cnJlbnRQcmVzZW5jZSA9IHN0YXRlW2tleV1cbiAgICAgIHN0YXRlW2tleV0gPSB0aGlzLmNsb25lKG5ld1ByZXNlbmNlKVxuICAgICAgaWYoY3VycmVudFByZXNlbmNlKXtcbiAgICAgICAgbGV0IGpvaW5lZFJlZnMgPSBzdGF0ZVtrZXldLm1ldGFzLm1hcChtID0+IG0ucGh4X3JlZilcbiAgICAgICAgbGV0IGN1ck1ldGFzID0gY3VycmVudFByZXNlbmNlLm1ldGFzLmZpbHRlcihtID0+IGpvaW5lZFJlZnMuaW5kZXhPZihtLnBoeF9yZWYpIDwgMClcbiAgICAgICAgc3RhdGVba2V5XS5tZXRhcy51bnNoaWZ0KC4uLmN1ck1ldGFzKVxuICAgICAgfVxuICAgICAgb25Kb2luKGtleSwgY3VycmVudFByZXNlbmNlLCBuZXdQcmVzZW5jZSlcbiAgICB9KVxuICAgIHRoaXMubWFwKGxlYXZlcywgKGtleSwgbGVmdFByZXNlbmNlKSA9PiB7XG4gICAgICBsZXQgY3VycmVudFByZXNlbmNlID0gc3RhdGVba2V5XVxuICAgICAgaWYoIWN1cnJlbnRQcmVzZW5jZSl7IHJldHVybiB9XG4gICAgICBsZXQgcmVmc1RvUmVtb3ZlID0gbGVmdFByZXNlbmNlLm1ldGFzLm1hcChtID0+IG0ucGh4X3JlZilcbiAgICAgIGN1cnJlbnRQcmVzZW5jZS5tZXRhcyA9IGN1cnJlbnRQcmVzZW5jZS5tZXRhcy5maWx0ZXIocCA9PiB7XG4gICAgICAgIHJldHVybiByZWZzVG9SZW1vdmUuaW5kZXhPZihwLnBoeF9yZWYpIDwgMFxuICAgICAgfSlcbiAgICAgIG9uTGVhdmUoa2V5LCBjdXJyZW50UHJlc2VuY2UsIGxlZnRQcmVzZW5jZSlcbiAgICAgIGlmKGN1cnJlbnRQcmVzZW5jZS5tZXRhcy5sZW5ndGggPT09IDApe1xuICAgICAgICBkZWxldGUgc3RhdGVba2V5XVxuICAgICAgfVxuICAgIH0pXG4gICAgcmV0dXJuIHN0YXRlXG4gIH1cblxuICAvKipcbiAgICogUmV0dXJucyB0aGUgYXJyYXkgb2YgcHJlc2VuY2VzLCB3aXRoIHNlbGVjdGVkIG1ldGFkYXRhLlxuICAgKlxuICAgKiBAcGFyYW0ge09iamVjdH0gcHJlc2VuY2VzXG4gICAqIEBwYXJhbSB7RnVuY3Rpb259IGNob29zZXJcbiAgICpcbiAgICogQHJldHVybnMge1ByZXNlbmNlfVxuICAgKi9cbiAgc3RhdGljIGxpc3QocHJlc2VuY2VzLCBjaG9vc2VyKXtcbiAgICBpZighY2hvb3Nlcil7IGNob29zZXIgPSBmdW5jdGlvbiAoa2V5LCBwcmVzKXsgcmV0dXJuIHByZXMgfSB9XG5cbiAgICByZXR1cm4gdGhpcy5tYXAocHJlc2VuY2VzLCAoa2V5LCBwcmVzZW5jZSkgPT4ge1xuICAgICAgcmV0dXJuIGNob29zZXIoa2V5LCBwcmVzZW5jZSlcbiAgICB9KVxuICB9XG5cbiAgLy8gcHJpdmF0ZVxuXG4gIHN0YXRpYyBtYXAob2JqLCBmdW5jKXtcbiAgICByZXR1cm4gT2JqZWN0LmdldE93blByb3BlcnR5TmFtZXMob2JqKS5tYXAoa2V5ID0+IGZ1bmMoa2V5LCBvYmpba2V5XSkpXG4gIH1cblxuICBzdGF0aWMgY2xvbmUob2JqKXsgcmV0dXJuIEpTT04ucGFyc2UoSlNPTi5zdHJpbmdpZnkob2JqKSkgfVxufVxuIiwgIi8qIFRoZSBkZWZhdWx0IHNlcmlhbGl6ZXIgZm9yIGVuY29kaW5nIGFuZCBkZWNvZGluZyBtZXNzYWdlcyAqL1xuaW1wb3J0IHtcbiAgQ0hBTk5FTF9FVkVOVFNcbn0gZnJvbSBcIi4vY29uc3RhbnRzXCJcblxuZXhwb3J0IGRlZmF1bHQge1xuICBIRUFERVJfTEVOR1RIOiAxLFxuICBNRVRBX0xFTkdUSDogNCxcbiAgS0lORFM6IHtwdXNoOiAwLCByZXBseTogMSwgYnJvYWRjYXN0OiAyfSxcblxuICBlbmNvZGUobXNnLCBjYWxsYmFjayl7XG4gICAgaWYobXNnLnBheWxvYWQuY29uc3RydWN0b3IgPT09IEFycmF5QnVmZmVyKXtcbiAgICAgIHJldHVybiBjYWxsYmFjayh0aGlzLmJpbmFyeUVuY29kZShtc2cpKVxuICAgIH0gZWxzZSB7XG4gICAgICBsZXQgcGF5bG9hZCA9IFttc2cuam9pbl9yZWYsIG1zZy5yZWYsIG1zZy50b3BpYywgbXNnLmV2ZW50LCBtc2cucGF5bG9hZF1cbiAgICAgIHJldHVybiBjYWxsYmFjayhKU09OLnN0cmluZ2lmeShwYXlsb2FkKSlcbiAgICB9XG4gIH0sXG5cbiAgZGVjb2RlKHJhd1BheWxvYWQsIGNhbGxiYWNrKXtcbiAgICBpZihyYXdQYXlsb2FkLmNvbnN0cnVjdG9yID09PSBBcnJheUJ1ZmZlcil7XG4gICAgICByZXR1cm4gY2FsbGJhY2sodGhpcy5iaW5hcnlEZWNvZGUocmF3UGF5bG9hZCkpXG4gICAgfSBlbHNlIHtcbiAgICAgIGxldCBbam9pbl9yZWYsIHJlZiwgdG9waWMsIGV2ZW50LCBwYXlsb2FkXSA9IEpTT04ucGFyc2UocmF3UGF5bG9hZClcbiAgICAgIHJldHVybiBjYWxsYmFjayh7am9pbl9yZWYsIHJlZiwgdG9waWMsIGV2ZW50LCBwYXlsb2FkfSlcbiAgICB9XG4gIH0sXG5cbiAgLy8gcHJpdmF0ZVxuXG4gIGJpbmFyeUVuY29kZShtZXNzYWdlKXtcbiAgICBsZXQge2pvaW5fcmVmLCByZWYsIGV2ZW50LCB0b3BpYywgcGF5bG9hZH0gPSBtZXNzYWdlXG4gICAgbGV0IG1ldGFMZW5ndGggPSB0aGlzLk1FVEFfTEVOR1RIICsgam9pbl9yZWYubGVuZ3RoICsgcmVmLmxlbmd0aCArIHRvcGljLmxlbmd0aCArIGV2ZW50Lmxlbmd0aFxuICAgIGxldCBoZWFkZXIgPSBuZXcgQXJyYXlCdWZmZXIodGhpcy5IRUFERVJfTEVOR1RIICsgbWV0YUxlbmd0aClcbiAgICBsZXQgdmlldyA9IG5ldyBEYXRhVmlldyhoZWFkZXIpXG4gICAgbGV0IG9mZnNldCA9IDBcblxuICAgIHZpZXcuc2V0VWludDgob2Zmc2V0KyssIHRoaXMuS0lORFMucHVzaCkgLy8ga2luZFxuICAgIHZpZXcuc2V0VWludDgob2Zmc2V0KyssIGpvaW5fcmVmLmxlbmd0aClcbiAgICB2aWV3LnNldFVpbnQ4KG9mZnNldCsrLCByZWYubGVuZ3RoKVxuICAgIHZpZXcuc2V0VWludDgob2Zmc2V0KyssIHRvcGljLmxlbmd0aClcbiAgICB2aWV3LnNldFVpbnQ4KG9mZnNldCsrLCBldmVudC5sZW5ndGgpXG4gICAgQXJyYXkuZnJvbShqb2luX3JlZiwgY2hhciA9PiB2aWV3LnNldFVpbnQ4KG9mZnNldCsrLCBjaGFyLmNoYXJDb2RlQXQoMCkpKVxuICAgIEFycmF5LmZyb20ocmVmLCBjaGFyID0+IHZpZXcuc2V0VWludDgob2Zmc2V0KyssIGNoYXIuY2hhckNvZGVBdCgwKSkpXG4gICAgQXJyYXkuZnJvbSh0b3BpYywgY2hhciA9PiB2aWV3LnNldFVpbnQ4KG9mZnNldCsrLCBjaGFyLmNoYXJDb2RlQXQoMCkpKVxuICAgIEFycmF5LmZyb20oZXZlbnQsIGNoYXIgPT4gdmlldy5zZXRVaW50OChvZmZzZXQrKywgY2hhci5jaGFyQ29kZUF0KDApKSlcblxuICAgIHZhciBjb21iaW5lZCA9IG5ldyBVaW50OEFycmF5KGhlYWRlci5ieXRlTGVuZ3RoICsgcGF5bG9hZC5ieXRlTGVuZ3RoKVxuICAgIGNvbWJpbmVkLnNldChuZXcgVWludDhBcnJheShoZWFkZXIpLCAwKVxuICAgIGNvbWJpbmVkLnNldChuZXcgVWludDhBcnJheShwYXlsb2FkKSwgaGVhZGVyLmJ5dGVMZW5ndGgpXG5cbiAgICByZXR1cm4gY29tYmluZWQuYnVmZmVyXG4gIH0sXG5cbiAgYmluYXJ5RGVjb2RlKGJ1ZmZlcil7XG4gICAgbGV0IHZpZXcgPSBuZXcgRGF0YVZpZXcoYnVmZmVyKVxuICAgIGxldCBraW5kID0gdmlldy5nZXRVaW50OCgwKVxuICAgIGxldCBkZWNvZGVyID0gbmV3IFRleHREZWNvZGVyKClcbiAgICBzd2l0Y2goa2luZCl7XG4gICAgICBjYXNlIHRoaXMuS0lORFMucHVzaDogcmV0dXJuIHRoaXMuZGVjb2RlUHVzaChidWZmZXIsIHZpZXcsIGRlY29kZXIpXG4gICAgICBjYXNlIHRoaXMuS0lORFMucmVwbHk6IHJldHVybiB0aGlzLmRlY29kZVJlcGx5KGJ1ZmZlciwgdmlldywgZGVjb2RlcilcbiAgICAgIGNhc2UgdGhpcy5LSU5EUy5icm9hZGNhc3Q6IHJldHVybiB0aGlzLmRlY29kZUJyb2FkY2FzdChidWZmZXIsIHZpZXcsIGRlY29kZXIpXG4gICAgfVxuICB9LFxuXG4gIGRlY29kZVB1c2goYnVmZmVyLCB2aWV3LCBkZWNvZGVyKXtcbiAgICBsZXQgam9pblJlZlNpemUgPSB2aWV3LmdldFVpbnQ4KDEpXG4gICAgbGV0IHRvcGljU2l6ZSA9IHZpZXcuZ2V0VWludDgoMilcbiAgICBsZXQgZXZlbnRTaXplID0gdmlldy5nZXRVaW50OCgzKVxuICAgIGxldCBvZmZzZXQgPSB0aGlzLkhFQURFUl9MRU5HVEggKyB0aGlzLk1FVEFfTEVOR1RIIC0gMSAvLyBwdXNoZXMgaGF2ZSBubyByZWZcbiAgICBsZXQgam9pblJlZiA9IGRlY29kZXIuZGVjb2RlKGJ1ZmZlci5zbGljZShvZmZzZXQsIG9mZnNldCArIGpvaW5SZWZTaXplKSlcbiAgICBvZmZzZXQgPSBvZmZzZXQgKyBqb2luUmVmU2l6ZVxuICAgIGxldCB0b3BpYyA9IGRlY29kZXIuZGVjb2RlKGJ1ZmZlci5zbGljZShvZmZzZXQsIG9mZnNldCArIHRvcGljU2l6ZSkpXG4gICAgb2Zmc2V0ID0gb2Zmc2V0ICsgdG9waWNTaXplXG4gICAgbGV0IGV2ZW50ID0gZGVjb2Rlci5kZWNvZGUoYnVmZmVyLnNsaWNlKG9mZnNldCwgb2Zmc2V0ICsgZXZlbnRTaXplKSlcbiAgICBvZmZzZXQgPSBvZmZzZXQgKyBldmVudFNpemVcbiAgICBsZXQgZGF0YSA9IGJ1ZmZlci5zbGljZShvZmZzZXQsIGJ1ZmZlci5ieXRlTGVuZ3RoKVxuICAgIHJldHVybiB7am9pbl9yZWY6IGpvaW5SZWYsIHJlZjogbnVsbCwgdG9waWM6IHRvcGljLCBldmVudDogZXZlbnQsIHBheWxvYWQ6IGRhdGF9XG4gIH0sXG5cbiAgZGVjb2RlUmVwbHkoYnVmZmVyLCB2aWV3LCBkZWNvZGVyKXtcbiAgICBsZXQgam9pblJlZlNpemUgPSB2aWV3LmdldFVpbnQ4KDEpXG4gICAgbGV0IHJlZlNpemUgPSB2aWV3LmdldFVpbnQ4KDIpXG4gICAgbGV0IHRvcGljU2l6ZSA9IHZpZXcuZ2V0VWludDgoMylcbiAgICBsZXQgZXZlbnRTaXplID0gdmlldy5nZXRVaW50OCg0KVxuICAgIGxldCBvZmZzZXQgPSB0aGlzLkhFQURFUl9MRU5HVEggKyB0aGlzLk1FVEFfTEVOR1RIXG4gICAgbGV0IGpvaW5SZWYgPSBkZWNvZGVyLmRlY29kZShidWZmZXIuc2xpY2Uob2Zmc2V0LCBvZmZzZXQgKyBqb2luUmVmU2l6ZSkpXG4gICAgb2Zmc2V0ID0gb2Zmc2V0ICsgam9pblJlZlNpemVcbiAgICBsZXQgcmVmID0gZGVjb2Rlci5kZWNvZGUoYnVmZmVyLnNsaWNlKG9mZnNldCwgb2Zmc2V0ICsgcmVmU2l6ZSkpXG4gICAgb2Zmc2V0ID0gb2Zmc2V0ICsgcmVmU2l6ZVxuICAgIGxldCB0b3BpYyA9IGRlY29kZXIuZGVjb2RlKGJ1ZmZlci5zbGljZShvZmZzZXQsIG9mZnNldCArIHRvcGljU2l6ZSkpXG4gICAgb2Zmc2V0ID0gb2Zmc2V0ICsgdG9waWNTaXplXG4gICAgbGV0IGV2ZW50ID0gZGVjb2Rlci5kZWNvZGUoYnVmZmVyLnNsaWNlKG9mZnNldCwgb2Zmc2V0ICsgZXZlbnRTaXplKSlcbiAgICBvZmZzZXQgPSBvZmZzZXQgKyBldmVudFNpemVcbiAgICBsZXQgZGF0YSA9IGJ1ZmZlci5zbGljZShvZmZzZXQsIGJ1ZmZlci5ieXRlTGVuZ3RoKVxuICAgIGxldCBwYXlsb2FkID0ge3N0YXR1czogZXZlbnQsIHJlc3BvbnNlOiBkYXRhfVxuICAgIHJldHVybiB7am9pbl9yZWY6IGpvaW5SZWYsIHJlZjogcmVmLCB0b3BpYzogdG9waWMsIGV2ZW50OiBDSEFOTkVMX0VWRU5UUy5yZXBseSwgcGF5bG9hZDogcGF5bG9hZH1cbiAgfSxcblxuICBkZWNvZGVCcm9hZGNhc3QoYnVmZmVyLCB2aWV3LCBkZWNvZGVyKXtcbiAgICBsZXQgdG9waWNTaXplID0gdmlldy5nZXRVaW50OCgxKVxuICAgIGxldCBldmVudFNpemUgPSB2aWV3LmdldFVpbnQ4KDIpXG4gICAgbGV0IG9mZnNldCA9IHRoaXMuSEVBREVSX0xFTkdUSCArIDJcbiAgICBsZXQgdG9waWMgPSBkZWNvZGVyLmRlY29kZShidWZmZXIuc2xpY2Uob2Zmc2V0LCBvZmZzZXQgKyB0b3BpY1NpemUpKVxuICAgIG9mZnNldCA9IG9mZnNldCArIHRvcGljU2l6ZVxuICAgIGxldCBldmVudCA9IGRlY29kZXIuZGVjb2RlKGJ1ZmZlci5zbGljZShvZmZzZXQsIG9mZnNldCArIGV2ZW50U2l6ZSkpXG4gICAgb2Zmc2V0ID0gb2Zmc2V0ICsgZXZlbnRTaXplXG4gICAgbGV0IGRhdGEgPSBidWZmZXIuc2xpY2Uob2Zmc2V0LCBidWZmZXIuYnl0ZUxlbmd0aClcblxuICAgIHJldHVybiB7am9pbl9yZWY6IG51bGwsIHJlZjogbnVsbCwgdG9waWM6IHRvcGljLCBldmVudDogZXZlbnQsIHBheWxvYWQ6IGRhdGF9XG4gIH1cbn1cbiIsICJpbXBvcnQge1xuICBnbG9iYWwsXG4gIHBoeFdpbmRvdyxcbiAgQ0hBTk5FTF9FVkVOVFMsXG4gIERFRkFVTFRfVElNRU9VVCxcbiAgREVGQVVMVF9WU04sXG4gIFNPQ0tFVF9TVEFURVMsXG4gIFRSQU5TUE9SVFMsXG4gIFdTX0NMT1NFX05PUk1BTFxufSBmcm9tIFwiLi9jb25zdGFudHNcIlxuXG5pbXBvcnQge1xuICBjbG9zdXJlXG59IGZyb20gXCIuL3V0aWxzXCJcblxuaW1wb3J0IEFqYXggZnJvbSBcIi4vYWpheFwiXG5pbXBvcnQgQ2hhbm5lbCBmcm9tIFwiLi9jaGFubmVsXCJcbmltcG9ydCBMb25nUG9sbCBmcm9tIFwiLi9sb25ncG9sbFwiXG5pbXBvcnQgU2VyaWFsaXplciBmcm9tIFwiLi9zZXJpYWxpemVyXCJcbmltcG9ydCBUaW1lciBmcm9tIFwiLi90aW1lclwiXG5cbi8qKiBJbml0aWFsaXplcyB0aGUgU29ja2V0ICpcbiAqXG4gKiBGb3IgSUU4IHN1cHBvcnQgdXNlIGFuIEVTNS1zaGltIChodHRwczovL2dpdGh1Yi5jb20vZXMtc2hpbXMvZXM1LXNoaW0pXG4gKlxuICogQHBhcmFtIHtzdHJpbmd9IGVuZFBvaW50IC0gVGhlIHN0cmluZyBXZWJTb2NrZXQgZW5kcG9pbnQsIGllLCBgXCJ3czovL2V4YW1wbGUuY29tL3NvY2tldFwiYCxcbiAqICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBgXCJ3c3M6Ly9leGFtcGxlLmNvbVwiYFxuICogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGBcIi9zb2NrZXRcImAgKGluaGVyaXRlZCBob3N0ICYgcHJvdG9jb2wpXG4gKiBAcGFyYW0ge09iamVjdH0gW29wdHNdIC0gT3B0aW9uYWwgY29uZmlndXJhdGlvblxuICogQHBhcmFtIHtGdW5jdGlvbn0gW29wdHMudHJhbnNwb3J0XSAtIFRoZSBXZWJzb2NrZXQgVHJhbnNwb3J0LCBmb3IgZXhhbXBsZSBXZWJTb2NrZXQgb3IgUGhvZW5peC5Mb25nUG9sbC5cbiAqXG4gKiBEZWZhdWx0cyB0byBXZWJTb2NrZXQgd2l0aCBhdXRvbWF0aWMgTG9uZ1BvbGwgZmFsbGJhY2suXG4gKiBAcGFyYW0ge0Z1bmN0aW9ufSBbb3B0cy5lbmNvZGVdIC0gVGhlIGZ1bmN0aW9uIHRvIGVuY29kZSBvdXRnb2luZyBtZXNzYWdlcy5cbiAqXG4gKiBEZWZhdWx0cyB0byBKU09OIGVuY29kZXIuXG4gKlxuICogQHBhcmFtIHtGdW5jdGlvbn0gW29wdHMuZGVjb2RlXSAtIFRoZSBmdW5jdGlvbiB0byBkZWNvZGUgaW5jb21pbmcgbWVzc2FnZXMuXG4gKlxuICogRGVmYXVsdHMgdG8gSlNPTjpcbiAqXG4gKiBgYGBqYXZhc2NyaXB0XG4gKiAocGF5bG9hZCwgY2FsbGJhY2spID0+IGNhbGxiYWNrKEpTT04ucGFyc2UocGF5bG9hZCkpXG4gKiBgYGBcbiAqXG4gKiBAcGFyYW0ge251bWJlcn0gW29wdHMudGltZW91dF0gLSBUaGUgZGVmYXVsdCB0aW1lb3V0IGluIG1pbGxpc2Vjb25kcyB0byB0cmlnZ2VyIHB1c2ggdGltZW91dHMuXG4gKlxuICogRGVmYXVsdHMgYERFRkFVTFRfVElNRU9VVGBcbiAqIEBwYXJhbSB7bnVtYmVyfSBbb3B0cy5oZWFydGJlYXRJbnRlcnZhbE1zXSAtIFRoZSBtaWxsaXNlYyBpbnRlcnZhbCB0byBzZW5kIGEgaGVhcnRiZWF0IG1lc3NhZ2VcbiAqIEBwYXJhbSB7bnVtYmVyfSBbb3B0cy5yZWNvbm5lY3RBZnRlck1zXSAtIFRoZSBvcHRpb25hbCBmdW5jdGlvbiB0aGF0IHJldHVybnMgdGhlIG1pbGxpc2VjXG4gKiBzb2NrZXQgcmVjb25uZWN0IGludGVydmFsLlxuICpcbiAqIERlZmF1bHRzIHRvIHN0ZXBwZWQgYmFja29mZiBvZjpcbiAqXG4gKiBgYGBqYXZhc2NyaXB0XG4gKiBmdW5jdGlvbih0cmllcyl7XG4gKiAgIHJldHVybiBbMTAsIDUwLCAxMDAsIDE1MCwgMjAwLCAyNTAsIDUwMCwgMTAwMCwgMjAwMF1bdHJpZXMgLSAxXSB8fCA1MDAwXG4gKiB9XG4gKiBgYGBgXG4gKlxuICogQHBhcmFtIHtudW1iZXJ9IFtvcHRzLnJlam9pbkFmdGVyTXNdIC0gVGhlIG9wdGlvbmFsIGZ1bmN0aW9uIHRoYXQgcmV0dXJucyB0aGUgbWlsbGlzZWNcbiAqIHJlam9pbiBpbnRlcnZhbCBmb3IgaW5kaXZpZHVhbCBjaGFubmVscy5cbiAqXG4gKiBgYGBqYXZhc2NyaXB0XG4gKiBmdW5jdGlvbih0cmllcyl7XG4gKiAgIHJldHVybiBbMTAwMCwgMjAwMCwgNTAwMF1bdHJpZXMgLSAxXSB8fCAxMDAwMFxuICogfVxuICogYGBgYFxuICpcbiAqIEBwYXJhbSB7RnVuY3Rpb259IFtvcHRzLmxvZ2dlcl0gLSBUaGUgb3B0aW9uYWwgZnVuY3Rpb24gZm9yIHNwZWNpYWxpemVkIGxvZ2dpbmcsIGllOlxuICpcbiAqIGBgYGphdmFzY3JpcHRcbiAqIGZ1bmN0aW9uKGtpbmQsIG1zZywgZGF0YSkge1xuICogICBjb25zb2xlLmxvZyhgJHtraW5kfTogJHttc2d9YCwgZGF0YSlcbiAqIH1cbiAqIGBgYFxuICpcbiAqIEBwYXJhbSB7bnVtYmVyfSBbb3B0cy5sb25ncG9sbGVyVGltZW91dF0gLSBUaGUgbWF4aW11bSB0aW1lb3V0IG9mIGEgbG9uZyBwb2xsIEFKQVggcmVxdWVzdC5cbiAqXG4gKiBEZWZhdWx0cyB0byAyMHMgKGRvdWJsZSB0aGUgc2VydmVyIGxvbmcgcG9sbCB0aW1lcikuXG4gKlxuICogQHBhcmFtIHsoT2JqZWN0fGZ1bmN0aW9uKX0gW29wdHMucGFyYW1zXSAtIFRoZSBvcHRpb25hbCBwYXJhbXMgdG8gcGFzcyB3aGVuIGNvbm5lY3RpbmdcbiAqIEBwYXJhbSB7c3RyaW5nfSBbb3B0cy5iaW5hcnlUeXBlXSAtIFRoZSBiaW5hcnkgdHlwZSB0byB1c2UgZm9yIGJpbmFyeSBXZWJTb2NrZXQgZnJhbWVzLlxuICpcbiAqIERlZmF1bHRzIHRvIFwiYXJyYXlidWZmZXJcIlxuICpcbiAqIEBwYXJhbSB7dnNufSBbb3B0cy52c25dIC0gVGhlIHNlcmlhbGl6ZXIncyBwcm90b2NvbCB2ZXJzaW9uIHRvIHNlbmQgb24gY29ubmVjdC5cbiAqXG4gKiBEZWZhdWx0cyB0byBERUZBVUxUX1ZTTi5cbiovXG5leHBvcnQgZGVmYXVsdCBjbGFzcyBTb2NrZXQge1xuICBjb25zdHJ1Y3RvcihlbmRQb2ludCwgb3B0cyA9IHt9KXtcbiAgICB0aGlzLnN0YXRlQ2hhbmdlQ2FsbGJhY2tzID0ge29wZW46IFtdLCBjbG9zZTogW10sIGVycm9yOiBbXSwgbWVzc2FnZTogW119XG4gICAgdGhpcy5jaGFubmVscyA9IFtdXG4gICAgdGhpcy5zZW5kQnVmZmVyID0gW11cbiAgICB0aGlzLnJlZiA9IDBcbiAgICB0aGlzLnRpbWVvdXQgPSBvcHRzLnRpbWVvdXQgfHwgREVGQVVMVF9USU1FT1VUXG4gICAgdGhpcy50cmFuc3BvcnQgPSBvcHRzLnRyYW5zcG9ydCB8fCBnbG9iYWwuV2ViU29ja2V0IHx8IExvbmdQb2xsXG4gICAgdGhpcy5lc3RhYmxpc2hlZENvbm5lY3Rpb25zID0gMFxuICAgIHRoaXMuZGVmYXVsdEVuY29kZXIgPSBTZXJpYWxpemVyLmVuY29kZS5iaW5kKFNlcmlhbGl6ZXIpXG4gICAgdGhpcy5kZWZhdWx0RGVjb2RlciA9IFNlcmlhbGl6ZXIuZGVjb2RlLmJpbmQoU2VyaWFsaXplcilcbiAgICB0aGlzLmNsb3NlV2FzQ2xlYW4gPSBmYWxzZVxuICAgIHRoaXMuYmluYXJ5VHlwZSA9IG9wdHMuYmluYXJ5VHlwZSB8fCBcImFycmF5YnVmZmVyXCJcbiAgICB0aGlzLmNvbm5lY3RDbG9jayA9IDFcbiAgICBpZih0aGlzLnRyYW5zcG9ydCAhPT0gTG9uZ1BvbGwpe1xuICAgICAgdGhpcy5lbmNvZGUgPSBvcHRzLmVuY29kZSB8fCB0aGlzLmRlZmF1bHRFbmNvZGVyXG4gICAgICB0aGlzLmRlY29kZSA9IG9wdHMuZGVjb2RlIHx8IHRoaXMuZGVmYXVsdERlY29kZXJcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5lbmNvZGUgPSB0aGlzLmRlZmF1bHRFbmNvZGVyXG4gICAgICB0aGlzLmRlY29kZSA9IHRoaXMuZGVmYXVsdERlY29kZXJcbiAgICB9XG4gICAgbGV0IGF3YWl0aW5nQ29ubmVjdGlvbk9uUGFnZVNob3cgPSBudWxsXG4gICAgaWYocGh4V2luZG93ICYmIHBoeFdpbmRvdy5hZGRFdmVudExpc3RlbmVyKXtcbiAgICAgIHBoeFdpbmRvdy5hZGRFdmVudExpc3RlbmVyKFwicGFnZWhpZGVcIiwgX2UgPT4ge1xuICAgICAgICBpZih0aGlzLmNvbm4pe1xuICAgICAgICAgIHRoaXMuZGlzY29ubmVjdCgpXG4gICAgICAgICAgYXdhaXRpbmdDb25uZWN0aW9uT25QYWdlU2hvdyA9IHRoaXMuY29ubmVjdENsb2NrXG4gICAgICAgIH1cbiAgICAgIH0pXG4gICAgICBwaHhXaW5kb3cuYWRkRXZlbnRMaXN0ZW5lcihcInBhZ2VzaG93XCIsIF9lID0+IHtcbiAgICAgICAgaWYoYXdhaXRpbmdDb25uZWN0aW9uT25QYWdlU2hvdyA9PT0gdGhpcy5jb25uZWN0Q2xvY2spe1xuICAgICAgICAgIGF3YWl0aW5nQ29ubmVjdGlvbk9uUGFnZVNob3cgPSBudWxsXG4gICAgICAgICAgdGhpcy5jb25uZWN0KClcbiAgICAgICAgfVxuICAgICAgfSlcbiAgICB9XG4gICAgdGhpcy5oZWFydGJlYXRJbnRlcnZhbE1zID0gb3B0cy5oZWFydGJlYXRJbnRlcnZhbE1zIHx8IDMwMDAwXG4gICAgdGhpcy5yZWpvaW5BZnRlck1zID0gKHRyaWVzKSA9PiB7XG4gICAgICBpZihvcHRzLnJlam9pbkFmdGVyTXMpe1xuICAgICAgICByZXR1cm4gb3B0cy5yZWpvaW5BZnRlck1zKHRyaWVzKVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgcmV0dXJuIFsxMDAwLCAyMDAwLCA1MDAwXVt0cmllcyAtIDFdIHx8IDEwMDAwXG4gICAgICB9XG4gICAgfVxuICAgIHRoaXMucmVjb25uZWN0QWZ0ZXJNcyA9ICh0cmllcykgPT4ge1xuICAgICAgaWYob3B0cy5yZWNvbm5lY3RBZnRlck1zKXtcbiAgICAgICAgcmV0dXJuIG9wdHMucmVjb25uZWN0QWZ0ZXJNcyh0cmllcylcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHJldHVybiBbMTAsIDUwLCAxMDAsIDE1MCwgMjAwLCAyNTAsIDUwMCwgMTAwMCwgMjAwMF1bdHJpZXMgLSAxXSB8fCA1MDAwXG4gICAgICB9XG4gICAgfVxuICAgIHRoaXMubG9nZ2VyID0gb3B0cy5sb2dnZXIgfHwgbnVsbFxuICAgIHRoaXMubG9uZ3BvbGxlclRpbWVvdXQgPSBvcHRzLmxvbmdwb2xsZXJUaW1lb3V0IHx8IDIwMDAwXG4gICAgdGhpcy5wYXJhbXMgPSBjbG9zdXJlKG9wdHMucGFyYW1zIHx8IHt9KVxuICAgIHRoaXMuZW5kUG9pbnQgPSBgJHtlbmRQb2ludH0vJHtUUkFOU1BPUlRTLndlYnNvY2tldH1gXG4gICAgdGhpcy52c24gPSBvcHRzLnZzbiB8fCBERUZBVUxUX1ZTTlxuICAgIHRoaXMuaGVhcnRiZWF0VGltZW91dFRpbWVyID0gbnVsbFxuICAgIHRoaXMuaGVhcnRiZWF0VGltZXIgPSBudWxsXG4gICAgdGhpcy5wZW5kaW5nSGVhcnRiZWF0UmVmID0gbnVsbFxuICAgIHRoaXMucmVjb25uZWN0VGltZXIgPSBuZXcgVGltZXIoKCkgPT4ge1xuICAgICAgdGhpcy50ZWFyZG93bigoKSA9PiB0aGlzLmNvbm5lY3QoKSlcbiAgICB9LCB0aGlzLnJlY29ubmVjdEFmdGVyTXMpXG4gIH1cblxuICAvKipcbiAgICogUmV0dXJucyB0aGUgTG9uZ1BvbGwgdHJhbnNwb3J0IHJlZmVyZW5jZVxuICAgKi9cbiAgZ2V0TG9uZ1BvbGxUcmFuc3BvcnQoKXsgcmV0dXJuIExvbmdQb2xsIH1cblxuICAvKipcbiAgICogRGlzY29ubmVjdHMgYW5kIHJlcGxhY2VzIHRoZSBhY3RpdmUgdHJhbnNwb3J0XG4gICAqXG4gICAqIEBwYXJhbSB7RnVuY3Rpb259IG5ld1RyYW5zcG9ydCAtIFRoZSBuZXcgdHJhbnNwb3J0IGNsYXNzIHRvIGluc3RhbnRpYXRlXG4gICAqXG4gICAqL1xuICByZXBsYWNlVHJhbnNwb3J0KG5ld1RyYW5zcG9ydCl7XG4gICAgdGhpcy5jb25uZWN0Q2xvY2srK1xuICAgIHRoaXMuY2xvc2VXYXNDbGVhbiA9IHRydWVcbiAgICB0aGlzLnJlY29ubmVjdFRpbWVyLnJlc2V0KClcbiAgICB0aGlzLnNlbmRCdWZmZXIgPSBbXVxuICAgIGlmKHRoaXMuY29ubil7XG4gICAgICB0aGlzLmNvbm4uY2xvc2UoKVxuICAgICAgdGhpcy5jb25uID0gbnVsbFxuICAgIH1cbiAgICB0aGlzLnRyYW5zcG9ydCA9IG5ld1RyYW5zcG9ydFxuICB9XG5cbiAgLyoqXG4gICAqIFJldHVybnMgdGhlIHNvY2tldCBwcm90b2NvbFxuICAgKlxuICAgKiBAcmV0dXJucyB7c3RyaW5nfVxuICAgKi9cbiAgcHJvdG9jb2woKXsgcmV0dXJuIGxvY2F0aW9uLnByb3RvY29sLm1hdGNoKC9eaHR0cHMvKSA/IFwid3NzXCIgOiBcIndzXCIgfVxuXG4gIC8qKlxuICAgKiBUaGUgZnVsbHkgcXVhbGlmaWVkIHNvY2tldCB1cmxcbiAgICpcbiAgICogQHJldHVybnMge3N0cmluZ31cbiAgICovXG4gIGVuZFBvaW50VVJMKCl7XG4gICAgbGV0IHVyaSA9IEFqYXguYXBwZW5kUGFyYW1zKFxuICAgICAgQWpheC5hcHBlbmRQYXJhbXModGhpcy5lbmRQb2ludCwgdGhpcy5wYXJhbXMoKSksIHt2c246IHRoaXMudnNufSlcbiAgICBpZih1cmkuY2hhckF0KDApICE9PSBcIi9cIil7IHJldHVybiB1cmkgfVxuICAgIGlmKHVyaS5jaGFyQXQoMSkgPT09IFwiL1wiKXsgcmV0dXJuIGAke3RoaXMucHJvdG9jb2woKX06JHt1cml9YCB9XG5cbiAgICByZXR1cm4gYCR7dGhpcy5wcm90b2NvbCgpfTovLyR7bG9jYXRpb24uaG9zdH0ke3VyaX1gXG4gIH1cblxuICAvKipcbiAgICogRGlzY29ubmVjdHMgdGhlIHNvY2tldFxuICAgKlxuICAgKiBTZWUgaHR0cHM6Ly9kZXZlbG9wZXIubW96aWxsYS5vcmcvZW4tVVMvZG9jcy9XZWIvQVBJL0Nsb3NlRXZlbnQjU3RhdHVzX2NvZGVzIGZvciB2YWxpZCBzdGF0dXMgY29kZXMuXG4gICAqXG4gICAqIEBwYXJhbSB7RnVuY3Rpb259IGNhbGxiYWNrIC0gT3B0aW9uYWwgY2FsbGJhY2sgd2hpY2ggaXMgY2FsbGVkIGFmdGVyIHNvY2tldCBpcyBkaXNjb25uZWN0ZWQuXG4gICAqIEBwYXJhbSB7aW50ZWdlcn0gY29kZSAtIEEgc3RhdHVzIGNvZGUgZm9yIGRpc2Nvbm5lY3Rpb24gKE9wdGlvbmFsKS5cbiAgICogQHBhcmFtIHtzdHJpbmd9IHJlYXNvbiAtIEEgdGV4dHVhbCBkZXNjcmlwdGlvbiBvZiB0aGUgcmVhc29uIHRvIGRpc2Nvbm5lY3QuIChPcHRpb25hbClcbiAgICovXG4gIGRpc2Nvbm5lY3QoY2FsbGJhY2ssIGNvZGUsIHJlYXNvbil7XG4gICAgdGhpcy5jb25uZWN0Q2xvY2srK1xuICAgIHRoaXMuY2xvc2VXYXNDbGVhbiA9IHRydWVcbiAgICB0aGlzLnJlY29ubmVjdFRpbWVyLnJlc2V0KClcbiAgICB0aGlzLnRlYXJkb3duKGNhbGxiYWNrLCBjb2RlLCByZWFzb24pXG4gIH1cblxuICAvKipcbiAgICpcbiAgICogQHBhcmFtIHtPYmplY3R9IHBhcmFtcyAtIFRoZSBwYXJhbXMgdG8gc2VuZCB3aGVuIGNvbm5lY3RpbmcsIGZvciBleGFtcGxlIGB7dXNlcl9pZDogdXNlclRva2VufWBcbiAgICpcbiAgICogUGFzc2luZyBwYXJhbXMgdG8gY29ubmVjdCBpcyBkZXByZWNhdGVkOyBwYXNzIHRoZW0gaW4gdGhlIFNvY2tldCBjb25zdHJ1Y3RvciBpbnN0ZWFkOlxuICAgKiBgbmV3IFNvY2tldChcIi9zb2NrZXRcIiwge3BhcmFtczoge3VzZXJfaWQ6IHVzZXJUb2tlbn19KWAuXG4gICAqL1xuICBjb25uZWN0KHBhcmFtcyl7XG4gICAgaWYocGFyYW1zKXtcbiAgICAgIGNvbnNvbGUgJiYgY29uc29sZS5sb2coXCJwYXNzaW5nIHBhcmFtcyB0byBjb25uZWN0IGlzIGRlcHJlY2F0ZWQuIEluc3RlYWQgcGFzcyA6cGFyYW1zIHRvIHRoZSBTb2NrZXQgY29uc3RydWN0b3JcIilcbiAgICAgIHRoaXMucGFyYW1zID0gY2xvc3VyZShwYXJhbXMpXG4gICAgfVxuICAgIGlmKHRoaXMuY29ubil7IHJldHVybiB9XG5cbiAgICB0aGlzLmNvbm5lY3RDbG9jaysrXG4gICAgdGhpcy5jbG9zZVdhc0NsZWFuID0gZmFsc2VcbiAgICB0aGlzLmNvbm4gPSBuZXcgdGhpcy50cmFuc3BvcnQodGhpcy5lbmRQb2ludFVSTCgpKVxuICAgIHRoaXMuY29ubi5iaW5hcnlUeXBlID0gdGhpcy5iaW5hcnlUeXBlXG4gICAgdGhpcy5jb25uLnRpbWVvdXQgPSB0aGlzLmxvbmdwb2xsZXJUaW1lb3V0XG4gICAgdGhpcy5jb25uLm9ub3BlbiA9ICgpID0+IHRoaXMub25Db25uT3BlbigpXG4gICAgdGhpcy5jb25uLm9uZXJyb3IgPSBlcnJvciA9PiB0aGlzLm9uQ29ubkVycm9yKGVycm9yKVxuICAgIHRoaXMuY29ubi5vbm1lc3NhZ2UgPSBldmVudCA9PiB0aGlzLm9uQ29ubk1lc3NhZ2UoZXZlbnQpXG4gICAgdGhpcy5jb25uLm9uY2xvc2UgPSBldmVudCA9PiB0aGlzLm9uQ29ubkNsb3NlKGV2ZW50KVxuICB9XG5cbiAgLyoqXG4gICAqIExvZ3MgdGhlIG1lc3NhZ2UuIE92ZXJyaWRlIGB0aGlzLmxvZ2dlcmAgZm9yIHNwZWNpYWxpemVkIGxvZ2dpbmcuIG5vb3BzIGJ5IGRlZmF1bHRcbiAgICogQHBhcmFtIHtzdHJpbmd9IGtpbmRcbiAgICogQHBhcmFtIHtzdHJpbmd9IG1zZ1xuICAgKiBAcGFyYW0ge09iamVjdH0gZGF0YVxuICAgKi9cbiAgbG9nKGtpbmQsIG1zZywgZGF0YSl7IHRoaXMubG9nZ2VyKGtpbmQsIG1zZywgZGF0YSkgfVxuXG4gIC8qKlxuICAgKiBSZXR1cm5zIHRydWUgaWYgYSBsb2dnZXIgaGFzIGJlZW4gc2V0IG9uIHRoaXMgc29ja2V0LlxuICAgKi9cbiAgaGFzTG9nZ2VyKCl7IHJldHVybiB0aGlzLmxvZ2dlciAhPT0gbnVsbCB9XG5cbiAgLyoqXG4gICAqIFJlZ2lzdGVycyBjYWxsYmFja3MgZm9yIGNvbm5lY3Rpb24gb3BlbiBldmVudHNcbiAgICpcbiAgICogQGV4YW1wbGUgc29ja2V0Lm9uT3BlbihmdW5jdGlvbigpeyBjb25zb2xlLmluZm8oXCJ0aGUgc29ja2V0IHdhcyBvcGVuZWRcIikgfSlcbiAgICpcbiAgICogQHBhcmFtIHtGdW5jdGlvbn0gY2FsbGJhY2tcbiAgICovXG4gIG9uT3BlbihjYWxsYmFjayl7XG4gICAgbGV0IHJlZiA9IHRoaXMubWFrZVJlZigpXG4gICAgdGhpcy5zdGF0ZUNoYW5nZUNhbGxiYWNrcy5vcGVuLnB1c2goW3JlZiwgY2FsbGJhY2tdKVxuICAgIHJldHVybiByZWZcbiAgfVxuXG4gIC8qKlxuICAgKiBSZWdpc3RlcnMgY2FsbGJhY2tzIGZvciBjb25uZWN0aW9uIGNsb3NlIGV2ZW50c1xuICAgKiBAcGFyYW0ge0Z1bmN0aW9ufSBjYWxsYmFja1xuICAgKi9cbiAgb25DbG9zZShjYWxsYmFjayl7XG4gICAgbGV0IHJlZiA9IHRoaXMubWFrZVJlZigpXG4gICAgdGhpcy5zdGF0ZUNoYW5nZUNhbGxiYWNrcy5jbG9zZS5wdXNoKFtyZWYsIGNhbGxiYWNrXSlcbiAgICByZXR1cm4gcmVmXG4gIH1cblxuICAvKipcbiAgICogUmVnaXN0ZXJzIGNhbGxiYWNrcyBmb3IgY29ubmVjdGlvbiBlcnJvciBldmVudHNcbiAgICpcbiAgICogQGV4YW1wbGUgc29ja2V0Lm9uRXJyb3IoZnVuY3Rpb24oZXJyb3IpeyBhbGVydChcIkFuIGVycm9yIG9jY3VycmVkXCIpIH0pXG4gICAqXG4gICAqIEBwYXJhbSB7RnVuY3Rpb259IGNhbGxiYWNrXG4gICAqL1xuICBvbkVycm9yKGNhbGxiYWNrKXtcbiAgICBsZXQgcmVmID0gdGhpcy5tYWtlUmVmKClcbiAgICB0aGlzLnN0YXRlQ2hhbmdlQ2FsbGJhY2tzLmVycm9yLnB1c2goW3JlZiwgY2FsbGJhY2tdKVxuICAgIHJldHVybiByZWZcbiAgfVxuXG4gIC8qKlxuICAgKiBSZWdpc3RlcnMgY2FsbGJhY2tzIGZvciBjb25uZWN0aW9uIG1lc3NhZ2UgZXZlbnRzXG4gICAqIEBwYXJhbSB7RnVuY3Rpb259IGNhbGxiYWNrXG4gICAqL1xuICBvbk1lc3NhZ2UoY2FsbGJhY2spe1xuICAgIGxldCByZWYgPSB0aGlzLm1ha2VSZWYoKVxuICAgIHRoaXMuc3RhdGVDaGFuZ2VDYWxsYmFja3MubWVzc2FnZS5wdXNoKFtyZWYsIGNhbGxiYWNrXSlcbiAgICByZXR1cm4gcmVmXG4gIH1cblxuICAvKipcbiAgICogUGluZ3MgdGhlIHNlcnZlciBhbmQgaW52b2tlcyB0aGUgY2FsbGJhY2sgd2l0aCB0aGUgUlRUIGluIG1pbGxpc2Vjb25kc1xuICAgKiBAcGFyYW0ge0Z1bmN0aW9ufSBjYWxsYmFja1xuICAgKlxuICAgKiBSZXR1cm5zIHRydWUgaWYgdGhlIHBpbmcgd2FzIHB1c2hlZCBvciBmYWxzZSBpZiB1bmFibGUgdG8gYmUgcHVzaGVkLlxuICAgKi9cbiAgcGluZyhjYWxsYmFjayl7XG4gICAgaWYoIXRoaXMuaXNDb25uZWN0ZWQoKSl7IHJldHVybiBmYWxzZSB9XG4gICAgbGV0IHJlZiA9IHRoaXMubWFrZVJlZigpXG4gICAgbGV0IHN0YXJ0VGltZSA9IERhdGUubm93KClcbiAgICB0aGlzLnB1c2goe3RvcGljOiBcInBob2VuaXhcIiwgZXZlbnQ6IFwiaGVhcnRiZWF0XCIsIHBheWxvYWQ6IHt9LCByZWY6IHJlZn0pXG4gICAgbGV0IG9uTXNnUmVmID0gdGhpcy5vbk1lc3NhZ2UobXNnID0+IHtcbiAgICAgIGlmKG1zZy5yZWYgPT09IHJlZil7XG4gICAgICAgIHRoaXMub2ZmKFtvbk1zZ1JlZl0pXG4gICAgICAgIGNhbGxiYWNrKERhdGUubm93KCkgLSBzdGFydFRpbWUpXG4gICAgICB9XG4gICAgfSlcbiAgICByZXR1cm4gdHJ1ZVxuICB9XG5cbiAgLyoqXG4gICAqIEBwcml2YXRlXG4gICAqL1xuXG4gIGNsZWFySGVhcnRiZWF0cygpe1xuICAgIGNsZWFyVGltZW91dCh0aGlzLmhlYXJ0YmVhdFRpbWVyKVxuICAgIGNsZWFyVGltZW91dCh0aGlzLmhlYXJ0YmVhdFRpbWVvdXRUaW1lcilcbiAgfVxuXG4gIG9uQ29ubk9wZW4oKXtcbiAgICBpZih0aGlzLmhhc0xvZ2dlcigpKSB0aGlzLmxvZyhcInRyYW5zcG9ydFwiLCBgY29ubmVjdGVkIHRvICR7dGhpcy5lbmRQb2ludFVSTCgpfWApXG4gICAgdGhpcy5jbG9zZVdhc0NsZWFuID0gZmFsc2VcbiAgICB0aGlzLmVzdGFibGlzaGVkQ29ubmVjdGlvbnMrK1xuICAgIHRoaXMuZmx1c2hTZW5kQnVmZmVyKClcbiAgICB0aGlzLnJlY29ubmVjdFRpbWVyLnJlc2V0KClcbiAgICB0aGlzLnJlc2V0SGVhcnRiZWF0KClcbiAgICB0aGlzLnN0YXRlQ2hhbmdlQ2FsbGJhY2tzLm9wZW4uZm9yRWFjaCgoWywgY2FsbGJhY2tdKSA9PiBjYWxsYmFjaygpKVxuICB9XG5cbiAgLyoqXG4gICAqIEBwcml2YXRlXG4gICAqL1xuXG4gIGhlYXJ0YmVhdFRpbWVvdXQoKXtcbiAgICBpZih0aGlzLnBlbmRpbmdIZWFydGJlYXRSZWYpe1xuICAgICAgdGhpcy5wZW5kaW5nSGVhcnRiZWF0UmVmID0gbnVsbFxuICAgICAgaWYodGhpcy5oYXNMb2dnZXIoKSl7IHRoaXMubG9nKFwidHJhbnNwb3J0XCIsIFwiaGVhcnRiZWF0IHRpbWVvdXQuIEF0dGVtcHRpbmcgdG8gcmUtZXN0YWJsaXNoIGNvbm5lY3Rpb25cIikgfVxuICAgICAgdGhpcy50cmlnZ2VyQ2hhbkVycm9yKClcbiAgICAgIHRoaXMuY2xvc2VXYXNDbGVhbiA9IGZhbHNlXG4gICAgICB0aGlzLnRlYXJkb3duKCgpID0+IHRoaXMucmVjb25uZWN0VGltZXIuc2NoZWR1bGVUaW1lb3V0KCksIFdTX0NMT1NFX05PUk1BTCwgXCJoZWFydGJlYXQgdGltZW91dFwiKVxuICAgIH1cbiAgfVxuXG4gIHJlc2V0SGVhcnRiZWF0KCl7XG4gICAgaWYodGhpcy5jb25uICYmIHRoaXMuY29ubi5za2lwSGVhcnRiZWF0KXsgcmV0dXJuIH1cbiAgICB0aGlzLnBlbmRpbmdIZWFydGJlYXRSZWYgPSBudWxsXG4gICAgdGhpcy5jbGVhckhlYXJ0YmVhdHMoKVxuICAgIHRoaXMuaGVhcnRiZWF0VGltZXIgPSBzZXRUaW1lb3V0KCgpID0+IHRoaXMuc2VuZEhlYXJ0YmVhdCgpLCB0aGlzLmhlYXJ0YmVhdEludGVydmFsTXMpXG4gIH1cblxuICB0ZWFyZG93bihjYWxsYmFjaywgY29kZSwgcmVhc29uKXtcbiAgICBpZighdGhpcy5jb25uKXtcbiAgICAgIHJldHVybiBjYWxsYmFjayAmJiBjYWxsYmFjaygpXG4gICAgfVxuXG4gICAgdGhpcy53YWl0Rm9yQnVmZmVyRG9uZSgoKSA9PiB7XG4gICAgICBpZih0aGlzLmNvbm4pe1xuICAgICAgICBpZihjb2RlKXsgdGhpcy5jb25uLmNsb3NlKGNvZGUsIHJlYXNvbiB8fCBcIlwiKSB9IGVsc2UgeyB0aGlzLmNvbm4uY2xvc2UoKSB9XG4gICAgICB9XG5cbiAgICAgIHRoaXMud2FpdEZvclNvY2tldENsb3NlZCgoKSA9PiB7XG4gICAgICAgIGlmKHRoaXMuY29ubil7XG4gICAgICAgICAgdGhpcy5jb25uLm9ub3BlbiA9IGZ1bmN0aW9uICgpeyB9IC8vIG5vb3BcbiAgICAgICAgICB0aGlzLmNvbm4ub25lcnJvciA9IGZ1bmN0aW9uICgpeyB9IC8vIG5vb3BcbiAgICAgICAgICB0aGlzLmNvbm4ub25tZXNzYWdlID0gZnVuY3Rpb24gKCl7IH0gLy8gbm9vcFxuICAgICAgICAgIHRoaXMuY29ubi5vbmNsb3NlID0gZnVuY3Rpb24gKCl7IH0gLy8gbm9vcFxuICAgICAgICAgIHRoaXMuY29ubiA9IG51bGxcbiAgICAgICAgfVxuXG4gICAgICAgIGNhbGxiYWNrICYmIGNhbGxiYWNrKClcbiAgICAgIH0pXG4gICAgfSlcbiAgfVxuXG4gIHdhaXRGb3JCdWZmZXJEb25lKGNhbGxiYWNrLCB0cmllcyA9IDEpe1xuICAgIGlmKHRyaWVzID09PSA1IHx8ICF0aGlzLmNvbm4gfHwgIXRoaXMuY29ubi5idWZmZXJlZEFtb3VudCl7XG4gICAgICBjYWxsYmFjaygpXG4gICAgICByZXR1cm5cbiAgICB9XG5cbiAgICBzZXRUaW1lb3V0KCgpID0+IHtcbiAgICAgIHRoaXMud2FpdEZvckJ1ZmZlckRvbmUoY2FsbGJhY2ssIHRyaWVzICsgMSlcbiAgICB9LCAxNTAgKiB0cmllcylcbiAgfVxuXG4gIHdhaXRGb3JTb2NrZXRDbG9zZWQoY2FsbGJhY2ssIHRyaWVzID0gMSl7XG4gICAgaWYodHJpZXMgPT09IDUgfHwgIXRoaXMuY29ubiB8fCB0aGlzLmNvbm4ucmVhZHlTdGF0ZSA9PT0gU09DS0VUX1NUQVRFUy5jbG9zZWQpe1xuICAgICAgY2FsbGJhY2soKVxuICAgICAgcmV0dXJuXG4gICAgfVxuXG4gICAgc2V0VGltZW91dCgoKSA9PiB7XG4gICAgICB0aGlzLndhaXRGb3JTb2NrZXRDbG9zZWQoY2FsbGJhY2ssIHRyaWVzICsgMSlcbiAgICB9LCAxNTAgKiB0cmllcylcbiAgfVxuXG4gIG9uQ29ubkNsb3NlKGV2ZW50KXtcbiAgICBsZXQgY2xvc2VDb2RlID0gZXZlbnQgJiYgZXZlbnQuY29kZVxuICAgIGlmKHRoaXMuaGFzTG9nZ2VyKCkpIHRoaXMubG9nKFwidHJhbnNwb3J0XCIsIFwiY2xvc2VcIiwgZXZlbnQpXG4gICAgdGhpcy50cmlnZ2VyQ2hhbkVycm9yKClcbiAgICB0aGlzLmNsZWFySGVhcnRiZWF0cygpXG4gICAgaWYoIXRoaXMuY2xvc2VXYXNDbGVhbiAmJiBjbG9zZUNvZGUgIT09IDEwMDApe1xuICAgICAgdGhpcy5yZWNvbm5lY3RUaW1lci5zY2hlZHVsZVRpbWVvdXQoKVxuICAgIH1cbiAgICB0aGlzLnN0YXRlQ2hhbmdlQ2FsbGJhY2tzLmNsb3NlLmZvckVhY2goKFssIGNhbGxiYWNrXSkgPT4gY2FsbGJhY2soZXZlbnQpKVxuICB9XG5cbiAgLyoqXG4gICAqIEBwcml2YXRlXG4gICAqL1xuICBvbkNvbm5FcnJvcihlcnJvcil7XG4gICAgaWYodGhpcy5oYXNMb2dnZXIoKSkgdGhpcy5sb2coXCJ0cmFuc3BvcnRcIiwgZXJyb3IpXG4gICAgbGV0IHRyYW5zcG9ydEJlZm9yZSA9IHRoaXMudHJhbnNwb3J0XG4gICAgbGV0IGVzdGFibGlzaGVkQmVmb3JlID0gdGhpcy5lc3RhYmxpc2hlZENvbm5lY3Rpb25zXG4gICAgdGhpcy5zdGF0ZUNoYW5nZUNhbGxiYWNrcy5lcnJvci5mb3JFYWNoKChbLCBjYWxsYmFja10pID0+IHtcbiAgICAgIGNhbGxiYWNrKGVycm9yLCB0cmFuc3BvcnRCZWZvcmUsIGVzdGFibGlzaGVkQmVmb3JlKVxuICAgIH0pXG4gICAgaWYodHJhbnNwb3J0QmVmb3JlID09PSB0aGlzLnRyYW5zcG9ydCB8fCBlc3RhYmxpc2hlZEJlZm9yZSA+IDApe1xuICAgICAgdGhpcy50cmlnZ2VyQ2hhbkVycm9yKClcbiAgICB9XG4gIH1cblxuICAvKipcbiAgICogQHByaXZhdGVcbiAgICovXG4gIHRyaWdnZXJDaGFuRXJyb3IoKXtcbiAgICB0aGlzLmNoYW5uZWxzLmZvckVhY2goY2hhbm5lbCA9PiB7XG4gICAgICBpZighKGNoYW5uZWwuaXNFcnJvcmVkKCkgfHwgY2hhbm5lbC5pc0xlYXZpbmcoKSB8fCBjaGFubmVsLmlzQ2xvc2VkKCkpKXtcbiAgICAgICAgY2hhbm5lbC50cmlnZ2VyKENIQU5ORUxfRVZFTlRTLmVycm9yKVxuICAgICAgfVxuICAgIH0pXG4gIH1cblxuICAvKipcbiAgICogQHJldHVybnMge3N0cmluZ31cbiAgICovXG4gIGNvbm5lY3Rpb25TdGF0ZSgpe1xuICAgIHN3aXRjaCh0aGlzLmNvbm4gJiYgdGhpcy5jb25uLnJlYWR5U3RhdGUpe1xuICAgICAgY2FzZSBTT0NLRVRfU1RBVEVTLmNvbm5lY3Rpbmc6IHJldHVybiBcImNvbm5lY3RpbmdcIlxuICAgICAgY2FzZSBTT0NLRVRfU1RBVEVTLm9wZW46IHJldHVybiBcIm9wZW5cIlxuICAgICAgY2FzZSBTT0NLRVRfU1RBVEVTLmNsb3Npbmc6IHJldHVybiBcImNsb3NpbmdcIlxuICAgICAgZGVmYXVsdDogcmV0dXJuIFwiY2xvc2VkXCJcbiAgICB9XG4gIH1cblxuICAvKipcbiAgICogQHJldHVybnMge2Jvb2xlYW59XG4gICAqL1xuICBpc0Nvbm5lY3RlZCgpeyByZXR1cm4gdGhpcy5jb25uZWN0aW9uU3RhdGUoKSA9PT0gXCJvcGVuXCIgfVxuXG4gIC8qKlxuICAgKiBAcHJpdmF0ZVxuICAgKlxuICAgKiBAcGFyYW0ge0NoYW5uZWx9XG4gICAqL1xuICByZW1vdmUoY2hhbm5lbCl7XG4gICAgdGhpcy5vZmYoY2hhbm5lbC5zdGF0ZUNoYW5nZVJlZnMpXG4gICAgdGhpcy5jaGFubmVscyA9IHRoaXMuY2hhbm5lbHMuZmlsdGVyKGMgPT4gYy5qb2luUmVmKCkgIT09IGNoYW5uZWwuam9pblJlZigpKVxuICB9XG5cbiAgLyoqXG4gICAqIFJlbW92ZXMgYG9uT3BlbmAsIGBvbkNsb3NlYCwgYG9uRXJyb3IsYCBhbmQgYG9uTWVzc2FnZWAgcmVnaXN0cmF0aW9ucy5cbiAgICpcbiAgICogQHBhcmFtIHtyZWZzfSAtIGxpc3Qgb2YgcmVmcyByZXR1cm5lZCBieSBjYWxscyB0b1xuICAgKiAgICAgICAgICAgICAgICAgYG9uT3BlbmAsIGBvbkNsb3NlYCwgYG9uRXJyb3IsYCBhbmQgYG9uTWVzc2FnZWBcbiAgICovXG4gIG9mZihyZWZzKXtcbiAgICBmb3IobGV0IGtleSBpbiB0aGlzLnN0YXRlQ2hhbmdlQ2FsbGJhY2tzKXtcbiAgICAgIHRoaXMuc3RhdGVDaGFuZ2VDYWxsYmFja3Nba2V5XSA9IHRoaXMuc3RhdGVDaGFuZ2VDYWxsYmFja3Nba2V5XS5maWx0ZXIoKFtyZWZdKSA9PiB7XG4gICAgICAgIHJldHVybiByZWZzLmluZGV4T2YocmVmKSA9PT0gLTFcbiAgICAgIH0pXG4gICAgfVxuICB9XG5cbiAgLyoqXG4gICAqIEluaXRpYXRlcyBhIG5ldyBjaGFubmVsIGZvciB0aGUgZ2l2ZW4gdG9waWNcbiAgICpcbiAgICogQHBhcmFtIHtzdHJpbmd9IHRvcGljXG4gICAqIEBwYXJhbSB7T2JqZWN0fSBjaGFuUGFyYW1zIC0gUGFyYW1ldGVycyBmb3IgdGhlIGNoYW5uZWxcbiAgICogQHJldHVybnMge0NoYW5uZWx9XG4gICAqL1xuICBjaGFubmVsKHRvcGljLCBjaGFuUGFyYW1zID0ge30pe1xuICAgIGxldCBjaGFuID0gbmV3IENoYW5uZWwodG9waWMsIGNoYW5QYXJhbXMsIHRoaXMpXG4gICAgdGhpcy5jaGFubmVscy5wdXNoKGNoYW4pXG4gICAgcmV0dXJuIGNoYW5cbiAgfVxuXG4gIC8qKlxuICAgKiBAcGFyYW0ge09iamVjdH0gZGF0YVxuICAgKi9cbiAgcHVzaChkYXRhKXtcbiAgICBpZih0aGlzLmhhc0xvZ2dlcigpKXtcbiAgICAgIGxldCB7dG9waWMsIGV2ZW50LCBwYXlsb2FkLCByZWYsIGpvaW5fcmVmfSA9IGRhdGFcbiAgICAgIHRoaXMubG9nKFwicHVzaFwiLCBgJHt0b3BpY30gJHtldmVudH0gKCR7am9pbl9yZWZ9LCAke3JlZn0pYCwgcGF5bG9hZClcbiAgICB9XG5cbiAgICBpZih0aGlzLmlzQ29ubmVjdGVkKCkpe1xuICAgICAgdGhpcy5lbmNvZGUoZGF0YSwgcmVzdWx0ID0+IHRoaXMuY29ubi5zZW5kKHJlc3VsdCkpXG4gICAgfSBlbHNlIHtcbiAgICAgIHRoaXMuc2VuZEJ1ZmZlci5wdXNoKCgpID0+IHRoaXMuZW5jb2RlKGRhdGEsIHJlc3VsdCA9PiB0aGlzLmNvbm4uc2VuZChyZXN1bHQpKSlcbiAgICB9XG4gIH1cblxuICAvKipcbiAgICogUmV0dXJuIHRoZSBuZXh0IG1lc3NhZ2UgcmVmLCBhY2NvdW50aW5nIGZvciBvdmVyZmxvd3NcbiAgICogQHJldHVybnMge3N0cmluZ31cbiAgICovXG4gIG1ha2VSZWYoKXtcbiAgICBsZXQgbmV3UmVmID0gdGhpcy5yZWYgKyAxXG4gICAgaWYobmV3UmVmID09PSB0aGlzLnJlZil7IHRoaXMucmVmID0gMCB9IGVsc2UgeyB0aGlzLnJlZiA9IG5ld1JlZiB9XG5cbiAgICByZXR1cm4gdGhpcy5yZWYudG9TdHJpbmcoKVxuICB9XG5cbiAgc2VuZEhlYXJ0YmVhdCgpe1xuICAgIGlmKHRoaXMucGVuZGluZ0hlYXJ0YmVhdFJlZiAmJiAhdGhpcy5pc0Nvbm5lY3RlZCgpKXsgcmV0dXJuIH1cbiAgICB0aGlzLnBlbmRpbmdIZWFydGJlYXRSZWYgPSB0aGlzLm1ha2VSZWYoKVxuICAgIHRoaXMucHVzaCh7dG9waWM6IFwicGhvZW5peFwiLCBldmVudDogXCJoZWFydGJlYXRcIiwgcGF5bG9hZDoge30sIHJlZjogdGhpcy5wZW5kaW5nSGVhcnRiZWF0UmVmfSlcbiAgICB0aGlzLmhlYXJ0YmVhdFRpbWVvdXRUaW1lciA9IHNldFRpbWVvdXQoKCkgPT4gdGhpcy5oZWFydGJlYXRUaW1lb3V0KCksIHRoaXMuaGVhcnRiZWF0SW50ZXJ2YWxNcylcbiAgfVxuXG4gIGZsdXNoU2VuZEJ1ZmZlcigpe1xuICAgIGlmKHRoaXMuaXNDb25uZWN0ZWQoKSAmJiB0aGlzLnNlbmRCdWZmZXIubGVuZ3RoID4gMCl7XG4gICAgICB0aGlzLnNlbmRCdWZmZXIuZm9yRWFjaChjYWxsYmFjayA9PiBjYWxsYmFjaygpKVxuICAgICAgdGhpcy5zZW5kQnVmZmVyID0gW11cbiAgICB9XG4gIH1cblxuICBvbkNvbm5NZXNzYWdlKHJhd01lc3NhZ2Upe1xuICAgIHRoaXMuZGVjb2RlKHJhd01lc3NhZ2UuZGF0YSwgbXNnID0+IHtcbiAgICAgIGxldCB7dG9waWMsIGV2ZW50LCBwYXlsb2FkLCByZWYsIGpvaW5fcmVmfSA9IG1zZ1xuICAgICAgaWYocmVmICYmIHJlZiA9PT0gdGhpcy5wZW5kaW5nSGVhcnRiZWF0UmVmKXtcbiAgICAgICAgdGhpcy5jbGVhckhlYXJ0YmVhdHMoKVxuICAgICAgICB0aGlzLnBlbmRpbmdIZWFydGJlYXRSZWYgPSBudWxsXG4gICAgICAgIHRoaXMuaGVhcnRiZWF0VGltZXIgPSBzZXRUaW1lb3V0KCgpID0+IHRoaXMuc2VuZEhlYXJ0YmVhdCgpLCB0aGlzLmhlYXJ0YmVhdEludGVydmFsTXMpXG4gICAgICB9XG5cbiAgICAgIGlmKHRoaXMuaGFzTG9nZ2VyKCkpIHRoaXMubG9nKFwicmVjZWl2ZVwiLCBgJHtwYXlsb2FkLnN0YXR1cyB8fCBcIlwifSAke3RvcGljfSAke2V2ZW50fSAke3JlZiAmJiBcIihcIiArIHJlZiArIFwiKVwiIHx8IFwiXCJ9YCwgcGF5bG9hZClcblxuICAgICAgZm9yKGxldCBpID0gMDsgaSA8IHRoaXMuY2hhbm5lbHMubGVuZ3RoOyBpKyspe1xuICAgICAgICBjb25zdCBjaGFubmVsID0gdGhpcy5jaGFubmVsc1tpXVxuICAgICAgICBpZighY2hhbm5lbC5pc01lbWJlcih0b3BpYywgZXZlbnQsIHBheWxvYWQsIGpvaW5fcmVmKSl7IGNvbnRpbnVlIH1cbiAgICAgICAgY2hhbm5lbC50cmlnZ2VyKGV2ZW50LCBwYXlsb2FkLCByZWYsIGpvaW5fcmVmKVxuICAgICAgfVxuXG4gICAgICBmb3IobGV0IGkgPSAwOyBpIDwgdGhpcy5zdGF0ZUNoYW5nZUNhbGxiYWNrcy5tZXNzYWdlLmxlbmd0aDsgaSsrKXtcbiAgICAgICAgbGV0IFssIGNhbGxiYWNrXSA9IHRoaXMuc3RhdGVDaGFuZ2VDYWxsYmFja3MubWVzc2FnZVtpXVxuICAgICAgICBjYWxsYmFjayhtc2cpXG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIGxlYXZlT3BlblRvcGljKHRvcGljKXtcbiAgICBsZXQgZHVwQ2hhbm5lbCA9IHRoaXMuY2hhbm5lbHMuZmluZChjID0+IGMudG9waWMgPT09IHRvcGljICYmIChjLmlzSm9pbmVkKCkgfHwgYy5pc0pvaW5pbmcoKSkpXG4gICAgaWYoZHVwQ2hhbm5lbCl7XG4gICAgICBpZih0aGlzLmhhc0xvZ2dlcigpKSB0aGlzLmxvZyhcInRyYW5zcG9ydFwiLCBgbGVhdmluZyBkdXBsaWNhdGUgdG9waWMgXCIke3RvcGljfVwiYClcbiAgICAgIGR1cENoYW5uZWwubGVhdmUoKVxuICAgIH1cbiAgfVxufVxuIiwgImV4cG9ydCBjb25zdCBDT05TRUNVVElWRV9SRUxPQURTID0gXCJjb25zZWN1dGl2ZS1yZWxvYWRzXCJcbmV4cG9ydCBjb25zdCBNQVhfUkVMT0FEUyA9IDEwXG5leHBvcnQgY29uc3QgUkVMT0FEX0pJVFRFUl9NSU4gPSA1MDAwXG5leHBvcnQgY29uc3QgUkVMT0FEX0pJVFRFUl9NQVggPSAxMDAwMFxuZXhwb3J0IGNvbnN0IEZBSUxTQUZFX0pJVFRFUiA9IDMwMDAwXG5leHBvcnQgY29uc3QgUEhYX0VWRU5UX0NMQVNTRVMgPSBbXG4gIFwicGh4LWNsaWNrLWxvYWRpbmdcIiwgXCJwaHgtY2hhbmdlLWxvYWRpbmdcIiwgXCJwaHgtc3VibWl0LWxvYWRpbmdcIixcbiAgXCJwaHgta2V5ZG93bi1sb2FkaW5nXCIsIFwicGh4LWtleXVwLWxvYWRpbmdcIiwgXCJwaHgtYmx1ci1sb2FkaW5nXCIsIFwicGh4LWZvY3VzLWxvYWRpbmdcIlxuXVxuZXhwb3J0IGNvbnN0IFBIWF9DT01QT05FTlQgPSBcImRhdGEtcGh4LWNvbXBvbmVudFwiXG5leHBvcnQgY29uc3QgUEhYX0xJVkVfTElOSyA9IFwiZGF0YS1waHgtbGlua1wiXG5leHBvcnQgY29uc3QgUEhYX1RSQUNLX1NUQVRJQyA9IFwidHJhY2stc3RhdGljXCJcbmV4cG9ydCBjb25zdCBQSFhfTElOS19TVEFURSA9IFwiZGF0YS1waHgtbGluay1zdGF0ZVwiXG5leHBvcnQgY29uc3QgUEhYX1JFRiA9IFwiZGF0YS1waHgtcmVmXCJcbmV4cG9ydCBjb25zdCBQSFhfUkVGX1NSQyA9IFwiZGF0YS1waHgtcmVmLXNyY1wiXG5leHBvcnQgY29uc3QgUEhYX1RSQUNLX1VQTE9BRFMgPSBcInRyYWNrLXVwbG9hZHNcIlxuZXhwb3J0IGNvbnN0IFBIWF9VUExPQURfUkVGID0gXCJkYXRhLXBoeC11cGxvYWQtcmVmXCJcbmV4cG9ydCBjb25zdCBQSFhfUFJFRkxJR0hURURfUkVGUyA9IFwiZGF0YS1waHgtcHJlZmxpZ2h0ZWQtcmVmc1wiXG5leHBvcnQgY29uc3QgUEhYX0RPTkVfUkVGUyA9IFwiZGF0YS1waHgtZG9uZS1yZWZzXCJcbmV4cG9ydCBjb25zdCBQSFhfRFJPUF9UQVJHRVQgPSBcImRyb3AtdGFyZ2V0XCJcbmV4cG9ydCBjb25zdCBQSFhfQUNUSVZFX0VOVFJZX1JFRlMgPSBcImRhdGEtcGh4LWFjdGl2ZS1yZWZzXCJcbmV4cG9ydCBjb25zdCBQSFhfTElWRV9GSUxFX1VQREFURUQgPSBcInBoeDpsaXZlLWZpbGU6dXBkYXRlZFwiXG5leHBvcnQgY29uc3QgUEhYX1NLSVAgPSBcImRhdGEtcGh4LXNraXBcIlxuZXhwb3J0IGNvbnN0IFBIWF9QUlVORSA9IFwiZGF0YS1waHgtcHJ1bmVcIlxuZXhwb3J0IGNvbnN0IFBIWF9QQUdFX0xPQURJTkcgPSBcInBhZ2UtbG9hZGluZ1wiXG5leHBvcnQgY29uc3QgUEhYX0NPTk5FQ1RFRF9DTEFTUyA9IFwicGh4LWNvbm5lY3RlZFwiXG5leHBvcnQgY29uc3QgUEhYX0RJU0NPTk5FQ1RFRF9DTEFTUyA9IFwicGh4LWxvYWRpbmdcIlxuZXhwb3J0IGNvbnN0IFBIWF9OT19GRUVEQkFDS19DTEFTUyA9IFwicGh4LW5vLWZlZWRiYWNrXCJcbmV4cG9ydCBjb25zdCBQSFhfRVJST1JfQ0xBU1MgPSBcInBoeC1lcnJvclwiXG5leHBvcnQgY29uc3QgUEhYX1BBUkVOVF9JRCA9IFwiZGF0YS1waHgtcGFyZW50LWlkXCJcbmV4cG9ydCBjb25zdCBQSFhfTUFJTiA9IFwiZGF0YS1waHgtbWFpblwiXG5leHBvcnQgY29uc3QgUEhYX1JPT1RfSUQgPSBcImRhdGEtcGh4LXJvb3QtaWRcIlxuZXhwb3J0IGNvbnN0IFBIWF9UUklHR0VSX0FDVElPTiA9IFwidHJpZ2dlci1hY3Rpb25cIlxuZXhwb3J0IGNvbnN0IFBIWF9GRUVEQkFDS19GT1IgPSBcImZlZWRiYWNrLWZvclwiXG5leHBvcnQgY29uc3QgUEhYX0hBU19GT0NVU0VEID0gXCJwaHgtaGFzLWZvY3VzZWRcIlxuZXhwb3J0IGNvbnN0IEZPQ1VTQUJMRV9JTlBVVFMgPSBbXCJ0ZXh0XCIsIFwidGV4dGFyZWFcIiwgXCJudW1iZXJcIiwgXCJlbWFpbFwiLCBcInBhc3N3b3JkXCIsIFwic2VhcmNoXCIsIFwidGVsXCIsIFwidXJsXCIsIFwiZGF0ZVwiLCBcInRpbWVcIiwgXCJkYXRldGltZS1sb2NhbFwiLCBcImNvbG9yXCIsIFwicmFuZ2VcIl1cbmV4cG9ydCBjb25zdCBDSEVDS0FCTEVfSU5QVVRTID0gW1wiY2hlY2tib3hcIiwgXCJyYWRpb1wiXVxuZXhwb3J0IGNvbnN0IFBIWF9IQVNfU1VCTUlUVEVEID0gXCJwaHgtaGFzLXN1Ym1pdHRlZFwiXG5leHBvcnQgY29uc3QgUEhYX1NFU1NJT04gPSBcImRhdGEtcGh4LXNlc3Npb25cIlxuZXhwb3J0IGNvbnN0IFBIWF9WSUVXX1NFTEVDVE9SID0gYFske1BIWF9TRVNTSU9OfV1gXG5leHBvcnQgY29uc3QgUEhYX1NUSUNLWSA9IFwiZGF0YS1waHgtc3RpY2t5XCJcbmV4cG9ydCBjb25zdCBQSFhfU1RBVElDID0gXCJkYXRhLXBoeC1zdGF0aWNcIlxuZXhwb3J0IGNvbnN0IFBIWF9SRUFET05MWSA9IFwiZGF0YS1waHgtcmVhZG9ubHlcIlxuZXhwb3J0IGNvbnN0IFBIWF9ESVNBQkxFRCA9IFwiZGF0YS1waHgtZGlzYWJsZWRcIlxuZXhwb3J0IGNvbnN0IFBIWF9ESVNBQkxFX1dJVEggPSBcImRpc2FibGUtd2l0aFwiXG5leHBvcnQgY29uc3QgUEhYX0RJU0FCTEVfV0lUSF9SRVNUT1JFID0gXCJkYXRhLXBoeC1kaXNhYmxlLXdpdGgtcmVzdG9yZVwiXG5leHBvcnQgY29uc3QgUEhYX0hPT0sgPSBcImhvb2tcIlxuZXhwb3J0IGNvbnN0IFBIWF9ERUJPVU5DRSA9IFwiZGVib3VuY2VcIlxuZXhwb3J0IGNvbnN0IFBIWF9USFJPVFRMRSA9IFwidGhyb3R0bGVcIlxuZXhwb3J0IGNvbnN0IFBIWF9VUERBVEUgPSBcInVwZGF0ZVwiXG5leHBvcnQgY29uc3QgUEhYX1NUUkVBTSA9IFwic3RyZWFtXCJcbmV4cG9ydCBjb25zdCBQSFhfS0VZID0gXCJrZXlcIlxuZXhwb3J0IGNvbnN0IFBIWF9QUklWQVRFID0gXCJwaHhQcml2YXRlXCJcbmV4cG9ydCBjb25zdCBQSFhfQVVUT19SRUNPVkVSID0gXCJhdXRvLXJlY292ZXJcIlxuZXhwb3J0IGNvbnN0IFBIWF9MVl9ERUJVRyA9IFwicGh4OmxpdmUtc29ja2V0OmRlYnVnXCJcbmV4cG9ydCBjb25zdCBQSFhfTFZfUFJPRklMRSA9IFwicGh4OmxpdmUtc29ja2V0OnByb2ZpbGluZ1wiXG5leHBvcnQgY29uc3QgUEhYX0xWX0xBVEVOQ1lfU0lNID0gXCJwaHg6bGl2ZS1zb2NrZXQ6bGF0ZW5jeS1zaW1cIlxuZXhwb3J0IGNvbnN0IFBIWF9QUk9HUkVTUyA9IFwicHJvZ3Jlc3NcIlxuZXhwb3J0IGNvbnN0IFBIWF9NT1VOVEVEID0gXCJtb3VudGVkXCJcbmV4cG9ydCBjb25zdCBMT0FERVJfVElNRU9VVCA9IDFcbmV4cG9ydCBjb25zdCBCRUZPUkVfVU5MT0FEX0xPQURFUl9USU1FT1VUID0gMjAwXG5leHBvcnQgY29uc3QgQklORElOR19QUkVGSVggPSBcInBoeC1cIlxuZXhwb3J0IGNvbnN0IFBVU0hfVElNRU9VVCA9IDMwMDAwXG5leHBvcnQgY29uc3QgTElOS19IRUFERVIgPSBcIngtcmVxdWVzdGVkLXdpdGhcIlxuZXhwb3J0IGNvbnN0IFJFU1BPTlNFX1VSTF9IRUFERVIgPSBcIngtcmVzcG9uc2UtdXJsXCJcbmV4cG9ydCBjb25zdCBERUJPVU5DRV9UUklHR0VSID0gXCJkZWJvdW5jZS10cmlnZ2VyXCJcbmV4cG9ydCBjb25zdCBUSFJPVFRMRUQgPSBcInRocm90dGxlZFwiXG5leHBvcnQgY29uc3QgREVCT1VOQ0VfUFJFVl9LRVkgPSBcImRlYm91bmNlLXByZXYta2V5XCJcbmV4cG9ydCBjb25zdCBERUZBVUxUUyA9IHtcbiAgZGVib3VuY2U6IDMwMCxcbiAgdGhyb3R0bGU6IDMwMFxufVxuXG4vLyBSZW5kZXJlZFxuZXhwb3J0IGNvbnN0IERZTkFNSUNTID0gXCJkXCJcbmV4cG9ydCBjb25zdCBTVEFUSUMgPSBcInNcIlxuZXhwb3J0IGNvbnN0IENPTVBPTkVOVFMgPSBcImNcIlxuZXhwb3J0IGNvbnN0IEVWRU5UUyA9IFwiZVwiXG5leHBvcnQgY29uc3QgUkVQTFkgPSBcInJcIlxuZXhwb3J0IGNvbnN0IFRJVExFID0gXCJ0XCJcbmV4cG9ydCBjb25zdCBURU1QTEFURVMgPSBcInBcIlxuZXhwb3J0IGNvbnN0IFNUUkVBTSA9IFwic3RyZWFtXCJcbiIsICJpbXBvcnQge1xuICBsb2dFcnJvclxufSBmcm9tIFwiLi91dGlsc1wiXG5cbmV4cG9ydCBkZWZhdWx0IGNsYXNzIEVudHJ5VXBsb2FkZXIge1xuICBjb25zdHJ1Y3RvcihlbnRyeSwgY2h1bmtTaXplLCBsaXZlU29ja2V0KXtcbiAgICB0aGlzLmxpdmVTb2NrZXQgPSBsaXZlU29ja2V0XG4gICAgdGhpcy5lbnRyeSA9IGVudHJ5XG4gICAgdGhpcy5vZmZzZXQgPSAwXG4gICAgdGhpcy5jaHVua1NpemUgPSBjaHVua1NpemVcbiAgICB0aGlzLmNodW5rVGltZXIgPSBudWxsXG4gICAgdGhpcy51cGxvYWRDaGFubmVsID0gbGl2ZVNvY2tldC5jaGFubmVsKGBsdnU6JHtlbnRyeS5yZWZ9YCwge3Rva2VuOiBlbnRyeS5tZXRhZGF0YSgpfSlcbiAgfVxuXG4gIGVycm9yKHJlYXNvbil7XG4gICAgY2xlYXJUaW1lb3V0KHRoaXMuY2h1bmtUaW1lcilcbiAgICB0aGlzLnVwbG9hZENoYW5uZWwubGVhdmUoKVxuICAgIHRoaXMuZW50cnkuZXJyb3IocmVhc29uKVxuICB9XG5cbiAgdXBsb2FkKCl7XG4gICAgdGhpcy51cGxvYWRDaGFubmVsLm9uRXJyb3IocmVhc29uID0+IHRoaXMuZXJyb3IocmVhc29uKSlcbiAgICB0aGlzLnVwbG9hZENoYW5uZWwuam9pbigpXG4gICAgICAucmVjZWl2ZShcIm9rXCIsIF9kYXRhID0+IHRoaXMucmVhZE5leHRDaHVuaygpKVxuICAgICAgLnJlY2VpdmUoXCJlcnJvclwiLCByZWFzb24gPT4gdGhpcy5lcnJvcihyZWFzb24pKVxuICB9XG5cbiAgaXNEb25lKCl7IHJldHVybiB0aGlzLm9mZnNldCA+PSB0aGlzLmVudHJ5LmZpbGUuc2l6ZSB9XG5cbiAgcmVhZE5leHRDaHVuaygpe1xuICAgIGxldCByZWFkZXIgPSBuZXcgd2luZG93LkZpbGVSZWFkZXIoKVxuICAgIGxldCBibG9iID0gdGhpcy5lbnRyeS5maWxlLnNsaWNlKHRoaXMub2Zmc2V0LCB0aGlzLmNodW5rU2l6ZSArIHRoaXMub2Zmc2V0KVxuICAgIHJlYWRlci5vbmxvYWQgPSAoZSkgPT4ge1xuICAgICAgaWYoZS50YXJnZXQuZXJyb3IgPT09IG51bGwpe1xuICAgICAgICB0aGlzLm9mZnNldCArPSBlLnRhcmdldC5yZXN1bHQuYnl0ZUxlbmd0aFxuICAgICAgICB0aGlzLnB1c2hDaHVuayhlLnRhcmdldC5yZXN1bHQpXG4gICAgICB9IGVsc2Uge1xuICAgICAgICByZXR1cm4gbG9nRXJyb3IoXCJSZWFkIGVycm9yOiBcIiArIGUudGFyZ2V0LmVycm9yKVxuICAgICAgfVxuICAgIH1cbiAgICByZWFkZXIucmVhZEFzQXJyYXlCdWZmZXIoYmxvYilcbiAgfVxuXG4gIHB1c2hDaHVuayhjaHVuayl7XG4gICAgaWYoIXRoaXMudXBsb2FkQ2hhbm5lbC5pc0pvaW5lZCgpKXsgcmV0dXJuIH1cbiAgICB0aGlzLnVwbG9hZENoYW5uZWwucHVzaChcImNodW5rXCIsIGNodW5rKVxuICAgICAgLnJlY2VpdmUoXCJva1wiLCAoKSA9PiB7XG4gICAgICAgIHRoaXMuZW50cnkucHJvZ3Jlc3MoKHRoaXMub2Zmc2V0IC8gdGhpcy5lbnRyeS5maWxlLnNpemUpICogMTAwKVxuICAgICAgICBpZighdGhpcy5pc0RvbmUoKSl7XG4gICAgICAgICAgdGhpcy5jaHVua1RpbWVyID0gc2V0VGltZW91dCgoKSA9PiB0aGlzLnJlYWROZXh0Q2h1bmsoKSwgdGhpcy5saXZlU29ja2V0LmdldExhdGVuY3lTaW0oKSB8fCAwKVxuICAgICAgICB9XG4gICAgICB9KVxuICB9XG59XG4iLCAiaW1wb3J0IHtcbiAgUEhYX1ZJRVdfU0VMRUNUT1Jcbn0gZnJvbSBcIi4vY29uc3RhbnRzXCJcblxuaW1wb3J0IEVudHJ5VXBsb2FkZXIgZnJvbSBcIi4vZW50cnlfdXBsb2FkZXJcIlxuXG5leHBvcnQgbGV0IGxvZ0Vycm9yID0gKG1zZywgb2JqKSA9PiBjb25zb2xlLmVycm9yICYmIGNvbnNvbGUuZXJyb3IobXNnLCBvYmopXG5cbmV4cG9ydCBsZXQgaXNDaWQgPSAoY2lkKSA9PiB7XG4gIGxldCB0eXBlID0gdHlwZW9mKGNpZClcbiAgcmV0dXJuIHR5cGUgPT09IFwibnVtYmVyXCIgfHwgKHR5cGUgPT09IFwic3RyaW5nXCIgJiYgL14oMHxbMS05XVxcZCopJC8udGVzdChjaWQpKVxufVxuXG5leHBvcnQgZnVuY3Rpb24gZGV0ZWN0RHVwbGljYXRlSWRzKCl7XG4gIGxldCBpZHMgPSBuZXcgU2V0KClcbiAgbGV0IGVsZW1zID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbChcIipbaWRdXCIpXG4gIGZvcihsZXQgaSA9IDAsIGxlbiA9IGVsZW1zLmxlbmd0aDsgaSA8IGxlbjsgaSsrKXtcbiAgICBpZihpZHMuaGFzKGVsZW1zW2ldLmlkKSl7XG4gICAgICBjb25zb2xlLmVycm9yKGBNdWx0aXBsZSBJRHMgZGV0ZWN0ZWQ6ICR7ZWxlbXNbaV0uaWR9LiBFbnN1cmUgdW5pcXVlIGVsZW1lbnQgaWRzLmApXG4gICAgfSBlbHNlIHtcbiAgICAgIGlkcy5hZGQoZWxlbXNbaV0uaWQpXG4gICAgfVxuICB9XG59XG5cbmV4cG9ydCBsZXQgZGVidWcgPSAodmlldywga2luZCwgbXNnLCBvYmopID0+IHtcbiAgaWYodmlldy5saXZlU29ja2V0LmlzRGVidWdFbmFibGVkKCkpe1xuICAgIGNvbnNvbGUubG9nKGAke3ZpZXcuaWR9ICR7a2luZH06ICR7bXNnfSAtIGAsIG9iailcbiAgfVxufVxuXG4vLyB3cmFwcyB2YWx1ZSBpbiBjbG9zdXJlIG9yIHJldHVybnMgY2xvc3VyZVxuZXhwb3J0IGxldCBjbG9zdXJlID0gKHZhbCkgPT4gdHlwZW9mIHZhbCA9PT0gXCJmdW5jdGlvblwiID8gdmFsIDogZnVuY3Rpb24gKCl7IHJldHVybiB2YWwgfVxuXG5leHBvcnQgbGV0IGNsb25lID0gKG9iaikgPT4geyByZXR1cm4gSlNPTi5wYXJzZShKU09OLnN0cmluZ2lmeShvYmopKSB9XG5cbmV4cG9ydCBsZXQgY2xvc2VzdFBoeEJpbmRpbmcgPSAoZWwsIGJpbmRpbmcsIGJvcmRlckVsKSA9PiB7XG4gIGRvIHtcbiAgICBpZihlbC5tYXRjaGVzKGBbJHtiaW5kaW5nfV1gKSAmJiAhZWwuZGlzYWJsZWQpeyByZXR1cm4gZWwgfVxuICAgIGVsID0gZWwucGFyZW50RWxlbWVudCB8fCBlbC5wYXJlbnROb2RlXG4gIH0gd2hpbGUoZWwgIT09IG51bGwgJiYgZWwubm9kZVR5cGUgPT09IDEgJiYgISgoYm9yZGVyRWwgJiYgYm9yZGVyRWwuaXNTYW1lTm9kZShlbCkpIHx8IGVsLm1hdGNoZXMoUEhYX1ZJRVdfU0VMRUNUT1IpKSlcbiAgcmV0dXJuIG51bGxcbn1cblxuZXhwb3J0IGxldCBpc09iamVjdCA9IChvYmopID0+IHtcbiAgcmV0dXJuIG9iaiAhPT0gbnVsbCAmJiB0eXBlb2Ygb2JqID09PSBcIm9iamVjdFwiICYmICEob2JqIGluc3RhbmNlb2YgQXJyYXkpXG59XG5cbmV4cG9ydCBsZXQgaXNFcXVhbE9iaiA9IChvYmoxLCBvYmoyKSA9PiBKU09OLnN0cmluZ2lmeShvYmoxKSA9PT0gSlNPTi5zdHJpbmdpZnkob2JqMilcblxuZXhwb3J0IGxldCBpc0VtcHR5ID0gKG9iaikgPT4ge1xuICBmb3IobGV0IHggaW4gb2JqKXsgcmV0dXJuIGZhbHNlIH1cbiAgcmV0dXJuIHRydWVcbn1cblxuZXhwb3J0IGxldCBtYXliZSA9IChlbCwgY2FsbGJhY2spID0+IGVsICYmIGNhbGxiYWNrKGVsKVxuXG5leHBvcnQgbGV0IGNoYW5uZWxVcGxvYWRlciA9IGZ1bmN0aW9uIChlbnRyaWVzLCBvbkVycm9yLCByZXNwLCBsaXZlU29ja2V0KXtcbiAgZW50cmllcy5mb3JFYWNoKGVudHJ5ID0+IHtcbiAgICBsZXQgZW50cnlVcGxvYWRlciA9IG5ldyBFbnRyeVVwbG9hZGVyKGVudHJ5LCByZXNwLmNvbmZpZy5jaHVua19zaXplLCBsaXZlU29ja2V0KVxuICAgIGVudHJ5VXBsb2FkZXIudXBsb2FkKClcbiAgfSlcbn1cbiIsICJsZXQgQnJvd3NlciA9IHtcbiAgY2FuUHVzaFN0YXRlKCl7IHJldHVybiAodHlwZW9mIChoaXN0b3J5LnB1c2hTdGF0ZSkgIT09IFwidW5kZWZpbmVkXCIpIH0sXG5cbiAgZHJvcExvY2FsKGxvY2FsU3RvcmFnZSwgbmFtZXNwYWNlLCBzdWJrZXkpe1xuICAgIHJldHVybiBsb2NhbFN0b3JhZ2UucmVtb3ZlSXRlbSh0aGlzLmxvY2FsS2V5KG5hbWVzcGFjZSwgc3Via2V5KSlcbiAgfSxcblxuICB1cGRhdGVMb2NhbChsb2NhbFN0b3JhZ2UsIG5hbWVzcGFjZSwgc3Via2V5LCBpbml0aWFsLCBmdW5jKXtcbiAgICBsZXQgY3VycmVudCA9IHRoaXMuZ2V0TG9jYWwobG9jYWxTdG9yYWdlLCBuYW1lc3BhY2UsIHN1YmtleSlcbiAgICBsZXQga2V5ID0gdGhpcy5sb2NhbEtleShuYW1lc3BhY2UsIHN1YmtleSlcbiAgICBsZXQgbmV3VmFsID0gY3VycmVudCA9PT0gbnVsbCA/IGluaXRpYWwgOiBmdW5jKGN1cnJlbnQpXG4gICAgbG9jYWxTdG9yYWdlLnNldEl0ZW0oa2V5LCBKU09OLnN0cmluZ2lmeShuZXdWYWwpKVxuICAgIHJldHVybiBuZXdWYWxcbiAgfSxcblxuICBnZXRMb2NhbChsb2NhbFN0b3JhZ2UsIG5hbWVzcGFjZSwgc3Via2V5KXtcbiAgICByZXR1cm4gSlNPTi5wYXJzZShsb2NhbFN0b3JhZ2UuZ2V0SXRlbSh0aGlzLmxvY2FsS2V5KG5hbWVzcGFjZSwgc3Via2V5KSkpXG4gIH0sXG5cbiAgdXBkYXRlQ3VycmVudFN0YXRlKGNhbGxiYWNrKXtcbiAgICBpZighdGhpcy5jYW5QdXNoU3RhdGUoKSl7IHJldHVybiB9XG4gICAgaGlzdG9yeS5yZXBsYWNlU3RhdGUoY2FsbGJhY2soaGlzdG9yeS5zdGF0ZSB8fCB7fSksIFwiXCIsIHdpbmRvdy5sb2NhdGlvbi5ocmVmKVxuICB9LFxuXG4gIHB1c2hTdGF0ZShraW5kLCBtZXRhLCB0byl7XG4gICAgaWYodGhpcy5jYW5QdXNoU3RhdGUoKSl7XG4gICAgICBpZih0byAhPT0gd2luZG93LmxvY2F0aW9uLmhyZWYpe1xuICAgICAgICBpZihtZXRhLnR5cGUgPT0gXCJyZWRpcmVjdFwiICYmIG1ldGEuc2Nyb2xsKXtcbiAgICAgICAgICAvLyBJZiB3ZSdyZSByZWRpcmVjdGluZyBzdG9yZSB0aGUgY3VycmVudCBzY3JvbGxZIGZvciB0aGUgY3VycmVudCBoaXN0b3J5IHN0YXRlLlxuICAgICAgICAgIGxldCBjdXJyZW50U3RhdGUgPSBoaXN0b3J5LnN0YXRlIHx8IHt9XG4gICAgICAgICAgY3VycmVudFN0YXRlLnNjcm9sbCA9IG1ldGEuc2Nyb2xsXG4gICAgICAgICAgaGlzdG9yeS5yZXBsYWNlU3RhdGUoY3VycmVudFN0YXRlLCBcIlwiLCB3aW5kb3cubG9jYXRpb24uaHJlZilcbiAgICAgICAgfVxuXG4gICAgICAgIGRlbGV0ZSBtZXRhLnNjcm9sbCAvLyBPbmx5IHN0b3JlIHRoZSBzY3JvbGwgaW4gdGhlIHJlZGlyZWN0IGNhc2UuXG4gICAgICAgIGhpc3Rvcnlba2luZCArIFwiU3RhdGVcIl0obWV0YSwgXCJcIiwgdG8gfHwgbnVsbCkgLy8gSUUgd2lsbCBjb2VyY2UgdW5kZWZpbmVkIHRvIHN0cmluZ1xuICAgICAgICBsZXQgaGFzaEVsID0gdGhpcy5nZXRIYXNoVGFyZ2V0RWwod2luZG93LmxvY2F0aW9uLmhhc2gpXG5cbiAgICAgICAgaWYoaGFzaEVsKXtcbiAgICAgICAgICBoYXNoRWwuc2Nyb2xsSW50b1ZpZXcoKVxuICAgICAgICB9IGVsc2UgaWYobWV0YS50eXBlID09PSBcInJlZGlyZWN0XCIpe1xuICAgICAgICAgIHdpbmRvdy5zY3JvbGwoMCwgMClcbiAgICAgICAgfVxuICAgICAgfVxuICAgIH0gZWxzZSB7XG4gICAgICB0aGlzLnJlZGlyZWN0KHRvKVxuICAgIH1cbiAgfSxcblxuICBzZXRDb29raWUobmFtZSwgdmFsdWUpe1xuICAgIGRvY3VtZW50LmNvb2tpZSA9IGAke25hbWV9PSR7dmFsdWV9YFxuICB9LFxuXG4gIGdldENvb2tpZShuYW1lKXtcbiAgICByZXR1cm4gZG9jdW1lbnQuY29va2llLnJlcGxhY2UobmV3IFJlZ0V4cChgKD86KD86XnwuKjtcXHMqKSR7bmFtZX1cXHMqXFw9XFxzKihbXjtdKikuKiQpfF4uKiRgKSwgXCIkMVwiKVxuICB9LFxuXG4gIHJlZGlyZWN0KHRvVVJMLCBmbGFzaCl7XG4gICAgaWYoZmxhc2gpeyBCcm93c2VyLnNldENvb2tpZShcIl9fcGhvZW5peF9mbGFzaF9fXCIsIGZsYXNoICsgXCI7IG1heC1hZ2U9NjAwMDA7IHBhdGg9L1wiKSB9XG4gICAgd2luZG93LmxvY2F0aW9uID0gdG9VUkxcbiAgfSxcblxuICBsb2NhbEtleShuYW1lc3BhY2UsIHN1YmtleSl7IHJldHVybiBgJHtuYW1lc3BhY2V9LSR7c3Via2V5fWAgfSxcblxuICBnZXRIYXNoVGFyZ2V0RWwobWF5YmVIYXNoKXtcbiAgICBsZXQgaGFzaCA9IG1heWJlSGFzaC50b1N0cmluZygpLnN1YnN0cmluZygxKVxuICAgIGlmKGhhc2ggPT09IFwiXCIpeyByZXR1cm4gfVxuICAgIHJldHVybiBkb2N1bWVudC5nZXRFbGVtZW50QnlJZChoYXNoKSB8fCBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKGBhW25hbWU9XCIke2hhc2h9XCJdYClcbiAgfVxufVxuXG5leHBvcnQgZGVmYXVsdCBCcm93c2VyXG4iLCAiaW1wb3J0IHtcbiAgQ0hFQ0tBQkxFX0lOUFVUUyxcbiAgREVCT1VOQ0VfUFJFVl9LRVksXG4gIERFQk9VTkNFX1RSSUdHRVIsXG4gIEZPQ1VTQUJMRV9JTlBVVFMsXG4gIFBIWF9DT01QT05FTlQsXG4gIFBIWF9FVkVOVF9DTEFTU0VTLFxuICBQSFhfSEFTX0ZPQ1VTRUQsXG4gIFBIWF9IQVNfU1VCTUlUVEVELFxuICBQSFhfTUFJTixcbiAgUEhYX05PX0ZFRURCQUNLX0NMQVNTLFxuICBQSFhfUEFSRU5UX0lELFxuICBQSFhfUFJJVkFURSxcbiAgUEhYX1JFRixcbiAgUEhYX1JFRl9TUkMsXG4gIFBIWF9ST09UX0lELFxuICBQSFhfU0VTU0lPTixcbiAgUEhYX1NUQVRJQyxcbiAgUEhYX1VQTE9BRF9SRUYsXG4gIFBIWF9WSUVXX1NFTEVDVE9SLFxuICBQSFhfU1RJQ0tZLFxuICBUSFJPVFRMRURcbn0gZnJvbSBcIi4vY29uc3RhbnRzXCJcblxuaW1wb3J0IHtcbiAgbG9nRXJyb3Jcbn0gZnJvbSBcIi4vdXRpbHNcIlxuXG5sZXQgRE9NID0ge1xuICBieUlkKGlkKXsgcmV0dXJuIGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKGlkKSB8fCBsb2dFcnJvcihgbm8gaWQgZm91bmQgZm9yICR7aWR9YCkgfSxcblxuICByZW1vdmVDbGFzcyhlbCwgY2xhc3NOYW1lKXtcbiAgICBlbC5jbGFzc0xpc3QucmVtb3ZlKGNsYXNzTmFtZSlcbiAgICBpZihlbC5jbGFzc0xpc3QubGVuZ3RoID09PSAwKXsgZWwucmVtb3ZlQXR0cmlidXRlKFwiY2xhc3NcIikgfVxuICB9LFxuXG4gIGFsbChub2RlLCBxdWVyeSwgY2FsbGJhY2spe1xuICAgIGlmKCFub2RlKXsgcmV0dXJuIFtdIH1cbiAgICBsZXQgYXJyYXkgPSBBcnJheS5mcm9tKG5vZGUucXVlcnlTZWxlY3RvckFsbChxdWVyeSkpXG4gICAgcmV0dXJuIGNhbGxiYWNrID8gYXJyYXkuZm9yRWFjaChjYWxsYmFjaykgOiBhcnJheVxuICB9LFxuXG4gIGNoaWxkTm9kZUxlbmd0aChodG1sKXtcbiAgICBsZXQgdGVtcGxhdGUgPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KFwidGVtcGxhdGVcIilcbiAgICB0ZW1wbGF0ZS5pbm5lckhUTUwgPSBodG1sXG4gICAgcmV0dXJuIHRlbXBsYXRlLmNvbnRlbnQuY2hpbGRFbGVtZW50Q291bnRcbiAgfSxcblxuICBpc1VwbG9hZElucHV0KGVsKXsgcmV0dXJuIGVsLnR5cGUgPT09IFwiZmlsZVwiICYmIGVsLmdldEF0dHJpYnV0ZShQSFhfVVBMT0FEX1JFRikgIT09IG51bGwgfSxcblxuICBmaW5kVXBsb2FkSW5wdXRzKG5vZGUpeyByZXR1cm4gdGhpcy5hbGwobm9kZSwgYGlucHV0W3R5cGU9XCJmaWxlXCJdWyR7UEhYX1VQTE9BRF9SRUZ9XWApIH0sXG5cbiAgZmluZENvbXBvbmVudE5vZGVMaXN0KG5vZGUsIGNpZCl7XG4gICAgcmV0dXJuIHRoaXMuZmlsdGVyV2l0aGluU2FtZUxpdmVWaWV3KHRoaXMuYWxsKG5vZGUsIGBbJHtQSFhfQ09NUE9ORU5UfT1cIiR7Y2lkfVwiXWApLCBub2RlKVxuICB9LFxuXG4gIGlzUGh4RGVzdHJveWVkKG5vZGUpe1xuICAgIHJldHVybiBub2RlLmlkICYmIERPTS5wcml2YXRlKG5vZGUsIFwiZGVzdHJveWVkXCIpID8gdHJ1ZSA6IGZhbHNlXG4gIH0sXG5cbiAgd2FudHNOZXdUYWIoZSl7XG4gICAgbGV0IHdhbnRzTmV3VGFiID0gZS5jdHJsS2V5IHx8IGUuc2hpZnRLZXkgfHwgZS5tZXRhS2V5IHx8IChlLmJ1dHRvbiAmJiBlLmJ1dHRvbiA9PT0gMSlcbiAgICByZXR1cm4gd2FudHNOZXdUYWIgfHwgZS50YXJnZXQuZ2V0QXR0cmlidXRlKFwidGFyZ2V0XCIpID09PSBcIl9ibGFua1wiXG4gIH0sXG5cbiAgaXNVbmxvYWRhYmxlRm9ybVN1Ym1pdChlKXtcbiAgICByZXR1cm4gIWUuZGVmYXVsdFByZXZlbnRlZCAmJiAhdGhpcy53YW50c05ld1RhYihlKVxuICB9LFxuXG4gIGlzTmV3UGFnZUhyZWYoaHJlZiwgY3VycmVudExvY2F0aW9uKXtcbiAgICBsZXQgdXJsXG4gICAgdHJ5IHtcbiAgICAgIHVybCA9IG5ldyBVUkwoaHJlZilcbiAgICB9IGNhdGNoKGUpIHtcbiAgICAgIHRyeSB7XG4gICAgICAgIHVybCA9IG5ldyBVUkwoaHJlZiwgY3VycmVudExvY2F0aW9uKVxuICAgICAgfSBjYXRjaChlKSB7XG4gICAgICAgIC8vIGJhZCBVUkwsIGZhbGxiYWNrIHRvIGxldCBicm93c2VyIHRyeSBpdCBhcyBleHRlcm5hbFxuICAgICAgICByZXR1cm4gdHJ1ZVxuICAgICAgfVxuICAgIH1cblxuICAgIGlmKHVybC5ob3N0ID09PSBjdXJyZW50TG9jYXRpb24uaG9zdCAmJiB1cmwucHJvdG9jb2wgPT09IGN1cnJlbnRMb2NhdGlvbi5wcm90b2NvbCl7XG4gICAgICBpZih1cmwucGF0aG5hbWUgPT09IGN1cnJlbnRMb2NhdGlvbi5wYXRobmFtZSAmJiB1cmwuc2VhcmNoID09PSBjdXJyZW50TG9jYXRpb24uc2VhcmNoKXtcbiAgICAgICAgcmV0dXJuIHVybC5oYXNoID09PSBcIlwiICYmICF1cmwuaHJlZi5lbmRzV2l0aChcIiNcIilcbiAgICAgIH1cbiAgICB9XG4gICAgcmV0dXJuIHRydWVcbiAgfSxcblxuICBtYXJrUGh4Q2hpbGREZXN0cm95ZWQoZWwpe1xuICAgIGlmKHRoaXMuaXNQaHhDaGlsZChlbCkpeyBlbC5zZXRBdHRyaWJ1dGUoUEhYX1NFU1NJT04sIFwiXCIpIH1cbiAgICB0aGlzLnB1dFByaXZhdGUoZWwsIFwiZGVzdHJveWVkXCIsIHRydWUpXG4gIH0sXG5cbiAgZmluZFBoeENoaWxkcmVuSW5GcmFnbWVudChodG1sLCBwYXJlbnRJZCl7XG4gICAgbGV0IHRlbXBsYXRlID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudChcInRlbXBsYXRlXCIpXG4gICAgdGVtcGxhdGUuaW5uZXJIVE1MID0gaHRtbFxuICAgIHJldHVybiB0aGlzLmZpbmRQaHhDaGlsZHJlbih0ZW1wbGF0ZS5jb250ZW50LCBwYXJlbnRJZClcbiAgfSxcblxuICBpc0lnbm9yZWQoZWwsIHBoeFVwZGF0ZSl7XG4gICAgcmV0dXJuIChlbC5nZXRBdHRyaWJ1dGUocGh4VXBkYXRlKSB8fCBlbC5nZXRBdHRyaWJ1dGUoXCJkYXRhLXBoeC11cGRhdGVcIikpID09PSBcImlnbm9yZVwiXG4gIH0sXG5cbiAgaXNQaHhVcGRhdGUoZWwsIHBoeFVwZGF0ZSwgdXBkYXRlVHlwZXMpe1xuICAgIHJldHVybiBlbC5nZXRBdHRyaWJ1dGUgJiYgdXBkYXRlVHlwZXMuaW5kZXhPZihlbC5nZXRBdHRyaWJ1dGUocGh4VXBkYXRlKSkgPj0gMFxuICB9LFxuXG4gIGZpbmRQaHhTdGlja3koZWwpeyByZXR1cm4gdGhpcy5hbGwoZWwsIGBbJHtQSFhfU1RJQ0tZfV1gKSB9LFxuXG4gIGZpbmRQaHhDaGlsZHJlbihlbCwgcGFyZW50SWQpe1xuICAgIHJldHVybiB0aGlzLmFsbChlbCwgYCR7UEhYX1ZJRVdfU0VMRUNUT1J9WyR7UEhYX1BBUkVOVF9JRH09XCIke3BhcmVudElkfVwiXWApXG4gIH0sXG5cbiAgZmluZFBhcmVudENJRHMobm9kZSwgY2lkcyl7XG4gICAgbGV0IGluaXRpYWwgPSBuZXcgU2V0KGNpZHMpXG4gICAgbGV0IHBhcmVudENpZHMgPVxuICAgICAgY2lkcy5yZWR1Y2UoKGFjYywgY2lkKSA9PiB7XG4gICAgICAgIGxldCBzZWxlY3RvciA9IGBbJHtQSFhfQ09NUE9ORU5UfT1cIiR7Y2lkfVwiXSBbJHtQSFhfQ09NUE9ORU5UfV1gXG5cbiAgICAgICAgdGhpcy5maWx0ZXJXaXRoaW5TYW1lTGl2ZVZpZXcodGhpcy5hbGwobm9kZSwgc2VsZWN0b3IpLCBub2RlKVxuICAgICAgICAgIC5tYXAoZWwgPT4gcGFyc2VJbnQoZWwuZ2V0QXR0cmlidXRlKFBIWF9DT01QT05FTlQpKSlcbiAgICAgICAgICAuZm9yRWFjaChjaGlsZENJRCA9PiBhY2MuZGVsZXRlKGNoaWxkQ0lEKSlcblxuICAgICAgICByZXR1cm4gYWNjXG4gICAgICB9LCBpbml0aWFsKVxuXG4gICAgcmV0dXJuIHBhcmVudENpZHMuc2l6ZSA9PT0gMCA/IG5ldyBTZXQoY2lkcykgOiBwYXJlbnRDaWRzXG4gIH0sXG5cbiAgZmlsdGVyV2l0aGluU2FtZUxpdmVWaWV3KG5vZGVzLCBwYXJlbnQpe1xuICAgIGlmKHBhcmVudC5xdWVyeVNlbGVjdG9yKFBIWF9WSUVXX1NFTEVDVE9SKSl7XG4gICAgICByZXR1cm4gbm9kZXMuZmlsdGVyKGVsID0+IHRoaXMud2l0aGluU2FtZUxpdmVWaWV3KGVsLCBwYXJlbnQpKVxuICAgIH0gZWxzZSB7XG4gICAgICByZXR1cm4gbm9kZXNcbiAgICB9XG4gIH0sXG5cbiAgd2l0aGluU2FtZUxpdmVWaWV3KG5vZGUsIHBhcmVudCl7XG4gICAgd2hpbGUobm9kZSA9IG5vZGUucGFyZW50Tm9kZSl7XG4gICAgICBpZihub2RlLmlzU2FtZU5vZGUocGFyZW50KSl7IHJldHVybiB0cnVlIH1cbiAgICAgIGlmKG5vZGUuZ2V0QXR0cmlidXRlKFBIWF9TRVNTSU9OKSAhPT0gbnVsbCl7IHJldHVybiBmYWxzZSB9XG4gICAgfVxuICB9LFxuXG4gIHByaXZhdGUoZWwsIGtleSl7IHJldHVybiBlbFtQSFhfUFJJVkFURV0gJiYgZWxbUEhYX1BSSVZBVEVdW2tleV0gfSxcblxuICBkZWxldGVQcml2YXRlKGVsLCBrZXkpeyBlbFtQSFhfUFJJVkFURV0gJiYgZGVsZXRlIChlbFtQSFhfUFJJVkFURV1ba2V5XSkgfSxcblxuICBwdXRQcml2YXRlKGVsLCBrZXksIHZhbHVlKXtcbiAgICBpZighZWxbUEhYX1BSSVZBVEVdKXsgZWxbUEhYX1BSSVZBVEVdID0ge30gfVxuICAgIGVsW1BIWF9QUklWQVRFXVtrZXldID0gdmFsdWVcbiAgfSxcblxuICB1cGRhdGVQcml2YXRlKGVsLCBrZXksIGRlZmF1bHRWYWwsIHVwZGF0ZUZ1bmMpe1xuICAgIGxldCBleGlzdGluZyA9IHRoaXMucHJpdmF0ZShlbCwga2V5KVxuICAgIGlmKGV4aXN0aW5nID09PSB1bmRlZmluZWQpe1xuICAgICAgdGhpcy5wdXRQcml2YXRlKGVsLCBrZXksIHVwZGF0ZUZ1bmMoZGVmYXVsdFZhbCkpXG4gICAgfSBlbHNlIHtcbiAgICAgIHRoaXMucHV0UHJpdmF0ZShlbCwga2V5LCB1cGRhdGVGdW5jKGV4aXN0aW5nKSlcbiAgICB9XG4gIH0sXG5cbiAgY29weVByaXZhdGVzKHRhcmdldCwgc291cmNlKXtcbiAgICBpZihzb3VyY2VbUEhYX1BSSVZBVEVdKXtcbiAgICAgIHRhcmdldFtQSFhfUFJJVkFURV0gPSBzb3VyY2VbUEhYX1BSSVZBVEVdXG4gICAgfVxuICB9LFxuXG4gIHB1dFRpdGxlKHN0cil7XG4gICAgbGV0IHRpdGxlRWwgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKFwidGl0bGVcIilcbiAgICBpZih0aXRsZUVsKXtcbiAgICAgIGxldCB7cHJlZml4LCBzdWZmaXh9ID0gdGl0bGVFbC5kYXRhc2V0XG4gICAgICBkb2N1bWVudC50aXRsZSA9IGAke3ByZWZpeCB8fCBcIlwifSR7c3RyfSR7c3VmZml4IHx8IFwiXCJ9YFxuICAgIH0gZWxzZSB7XG4gICAgICBkb2N1bWVudC50aXRsZSA9IHN0clxuICAgIH1cbiAgfSxcblxuICBkZWJvdW5jZShlbCwgZXZlbnQsIHBoeERlYm91bmNlLCBkZWZhdWx0RGVib3VuY2UsIHBoeFRocm90dGxlLCBkZWZhdWx0VGhyb3R0bGUsIGFzeW5jRmlsdGVyLCBjYWxsYmFjayl7XG4gICAgbGV0IGRlYm91bmNlID0gZWwuZ2V0QXR0cmlidXRlKHBoeERlYm91bmNlKVxuICAgIGxldCB0aHJvdHRsZSA9IGVsLmdldEF0dHJpYnV0ZShwaHhUaHJvdHRsZSlcbiAgICBpZihkZWJvdW5jZSA9PT0gXCJcIil7IGRlYm91bmNlID0gZGVmYXVsdERlYm91bmNlIH1cbiAgICBpZih0aHJvdHRsZSA9PT0gXCJcIil7IHRocm90dGxlID0gZGVmYXVsdFRocm90dGxlIH1cbiAgICBsZXQgdmFsdWUgPSBkZWJvdW5jZSB8fCB0aHJvdHRsZVxuICAgIHN3aXRjaCh2YWx1ZSl7XG4gICAgICBjYXNlIG51bGw6IHJldHVybiBjYWxsYmFjaygpXG5cbiAgICAgIGNhc2UgXCJibHVyXCI6XG4gICAgICAgIGlmKHRoaXMub25jZShlbCwgXCJkZWJvdW5jZS1ibHVyXCIpKXtcbiAgICAgICAgICBlbC5hZGRFdmVudExpc3RlbmVyKFwiYmx1clwiLCAoKSA9PiBjYWxsYmFjaygpKVxuICAgICAgICB9XG4gICAgICAgIHJldHVyblxuXG4gICAgICBkZWZhdWx0OlxuICAgICAgICBsZXQgdGltZW91dCA9IHBhcnNlSW50KHZhbHVlKVxuICAgICAgICBsZXQgdHJpZ2dlciA9ICgpID0+IHRocm90dGxlID8gdGhpcy5kZWxldGVQcml2YXRlKGVsLCBUSFJPVFRMRUQpIDogY2FsbGJhY2soKVxuICAgICAgICBsZXQgY3VycmVudEN5Y2xlID0gdGhpcy5pbmNDeWNsZShlbCwgREVCT1VOQ0VfVFJJR0dFUiwgdHJpZ2dlcilcbiAgICAgICAgaWYoaXNOYU4odGltZW91dCkpeyByZXR1cm4gbG9nRXJyb3IoYGludmFsaWQgdGhyb3R0bGUvZGVib3VuY2UgdmFsdWU6ICR7dmFsdWV9YCkgfVxuICAgICAgICBpZih0aHJvdHRsZSl7XG4gICAgICAgICAgbGV0IG5ld0tleURvd24gPSBmYWxzZVxuICAgICAgICAgIGlmKGV2ZW50LnR5cGUgPT09IFwia2V5ZG93blwiKXtcbiAgICAgICAgICAgIGxldCBwcmV2S2V5ID0gdGhpcy5wcml2YXRlKGVsLCBERUJPVU5DRV9QUkVWX0tFWSlcbiAgICAgICAgICAgIHRoaXMucHV0UHJpdmF0ZShlbCwgREVCT1VOQ0VfUFJFVl9LRVksIGV2ZW50LmtleSlcbiAgICAgICAgICAgIG5ld0tleURvd24gPSBwcmV2S2V5ICE9PSBldmVudC5rZXlcbiAgICAgICAgICB9XG5cbiAgICAgICAgICBpZighbmV3S2V5RG93biAmJiB0aGlzLnByaXZhdGUoZWwsIFRIUk9UVExFRCkpe1xuICAgICAgICAgICAgcmV0dXJuIGZhbHNlXG4gICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgIGNhbGxiYWNrKClcbiAgICAgICAgICAgIHRoaXMucHV0UHJpdmF0ZShlbCwgVEhST1RUTEVELCB0cnVlKVxuICAgICAgICAgICAgc2V0VGltZW91dCgoKSA9PiB7XG4gICAgICAgICAgICAgIGlmKGFzeW5jRmlsdGVyKCkpeyB0aGlzLnRyaWdnZXJDeWNsZShlbCwgREVCT1VOQ0VfVFJJR0dFUikgfVxuICAgICAgICAgICAgfSwgdGltZW91dClcbiAgICAgICAgICB9XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgc2V0VGltZW91dCgoKSA9PiB7XG4gICAgICAgICAgICBpZihhc3luY0ZpbHRlcigpKXsgdGhpcy50cmlnZ2VyQ3ljbGUoZWwsIERFQk9VTkNFX1RSSUdHRVIsIGN1cnJlbnRDeWNsZSkgfVxuICAgICAgICAgIH0sIHRpbWVvdXQpXG4gICAgICAgIH1cblxuICAgICAgICBsZXQgZm9ybSA9IGVsLmZvcm1cbiAgICAgICAgaWYoZm9ybSAmJiB0aGlzLm9uY2UoZm9ybSwgXCJiaW5kLWRlYm91bmNlXCIpKXtcbiAgICAgICAgICBmb3JtLmFkZEV2ZW50TGlzdGVuZXIoXCJzdWJtaXRcIiwgKCkgPT4ge1xuICAgICAgICAgICAgQXJyYXkuZnJvbSgobmV3IEZvcm1EYXRhKGZvcm0pKS5lbnRyaWVzKCksIChbbmFtZV0pID0+IHtcbiAgICAgICAgICAgICAgbGV0IGlucHV0ID0gZm9ybS5xdWVyeVNlbGVjdG9yKGBbbmFtZT1cIiR7bmFtZX1cIl1gKVxuICAgICAgICAgICAgICB0aGlzLmluY0N5Y2xlKGlucHV0LCBERUJPVU5DRV9UUklHR0VSKVxuICAgICAgICAgICAgICB0aGlzLmRlbGV0ZVByaXZhdGUoaW5wdXQsIFRIUk9UVExFRClcbiAgICAgICAgICAgIH0pXG4gICAgICAgICAgfSlcbiAgICAgICAgfVxuICAgICAgICBpZih0aGlzLm9uY2UoZWwsIFwiYmluZC1kZWJvdW5jZVwiKSl7XG4gICAgICAgICAgZWwuYWRkRXZlbnRMaXN0ZW5lcihcImJsdXJcIiwgKCkgPT4gdGhpcy50cmlnZ2VyQ3ljbGUoZWwsIERFQk9VTkNFX1RSSUdHRVIpKVxuICAgICAgICB9XG4gICAgfVxuICB9LFxuXG4gIHRyaWdnZXJDeWNsZShlbCwga2V5LCBjdXJyZW50Q3ljbGUpe1xuICAgIGxldCBbY3ljbGUsIHRyaWdnZXJdID0gdGhpcy5wcml2YXRlKGVsLCBrZXkpXG4gICAgaWYoIWN1cnJlbnRDeWNsZSl7IGN1cnJlbnRDeWNsZSA9IGN5Y2xlIH1cbiAgICBpZihjdXJyZW50Q3ljbGUgPT09IGN5Y2xlKXtcbiAgICAgIHRoaXMuaW5jQ3ljbGUoZWwsIGtleSlcbiAgICAgIHRyaWdnZXIoKVxuICAgIH1cbiAgfSxcblxuICBvbmNlKGVsLCBrZXkpe1xuICAgIGlmKHRoaXMucHJpdmF0ZShlbCwga2V5KSA9PT0gdHJ1ZSl7IHJldHVybiBmYWxzZSB9XG4gICAgdGhpcy5wdXRQcml2YXRlKGVsLCBrZXksIHRydWUpXG4gICAgcmV0dXJuIHRydWVcbiAgfSxcblxuICBpbmNDeWNsZShlbCwga2V5LCB0cmlnZ2VyID0gZnVuY3Rpb24gKCl7IH0pe1xuICAgIGxldCBbY3VycmVudEN5Y2xlXSA9IHRoaXMucHJpdmF0ZShlbCwga2V5KSB8fCBbMCwgdHJpZ2dlcl1cbiAgICBjdXJyZW50Q3ljbGUrK1xuICAgIHRoaXMucHV0UHJpdmF0ZShlbCwga2V5LCBbY3VycmVudEN5Y2xlLCB0cmlnZ2VyXSlcbiAgICByZXR1cm4gY3VycmVudEN5Y2xlXG4gIH0sXG5cbiAgZGlzY2FyZEVycm9yKGNvbnRhaW5lciwgZWwsIHBoeEZlZWRiYWNrRm9yKXtcbiAgICBsZXQgZmllbGQgPSBlbC5nZXRBdHRyaWJ1dGUgJiYgZWwuZ2V0QXR0cmlidXRlKHBoeEZlZWRiYWNrRm9yKVxuICAgIC8vIFRPRE86IFJlbW92ZSBpZCBsb29rdXAgYWZ0ZXIgd2UgdXBkYXRlIFBob2VuaXggdG8gdXNlIGlucHV0X25hbWUgaW5zdGVhZCBvZiBpbnB1dF9pZFxuICAgIGxldCBpbnB1dCA9IGZpZWxkICYmIGNvbnRhaW5lci5xdWVyeVNlbGVjdG9yKGBbaWQ9XCIke2ZpZWxkfVwiXSwgW25hbWU9XCIke2ZpZWxkfVwiXSwgW25hbWU9XCIke2ZpZWxkfVtdXCJdYClcbiAgICBpZighaW5wdXQpeyByZXR1cm4gfVxuXG4gICAgaWYoISh0aGlzLnByaXZhdGUoaW5wdXQsIFBIWF9IQVNfRk9DVVNFRCkgfHwgdGhpcy5wcml2YXRlKGlucHV0LCBQSFhfSEFTX1NVQk1JVFRFRCkpKXtcbiAgICAgIGVsLmNsYXNzTGlzdC5hZGQoUEhYX05PX0ZFRURCQUNLX0NMQVNTKVxuICAgIH1cbiAgfSxcblxuICByZXNldEZvcm0oZm9ybSwgcGh4RmVlZGJhY2tGb3Ipe1xuICAgIEFycmF5LmZyb20oZm9ybS5lbGVtZW50cykuZm9yRWFjaChpbnB1dCA9PiB7XG4gICAgICBsZXQgcXVlcnkgPSBgWyR7cGh4RmVlZGJhY2tGb3J9PVwiJHtpbnB1dC5pZH1cIl0sXG4gICAgICAgICAgICAgICAgICAgWyR7cGh4RmVlZGJhY2tGb3J9PVwiJHtpbnB1dC5uYW1lfVwiXSxcbiAgICAgICAgICAgICAgICAgICBbJHtwaHhGZWVkYmFja0Zvcn09XCIke2lucHV0Lm5hbWUucmVwbGFjZSgvXFxbXFxdJC8sIFwiXCIpfVwiXWBcblxuICAgICAgdGhpcy5kZWxldGVQcml2YXRlKGlucHV0LCBQSFhfSEFTX0ZPQ1VTRUQpXG4gICAgICB0aGlzLmRlbGV0ZVByaXZhdGUoaW5wdXQsIFBIWF9IQVNfU1VCTUlUVEVEKVxuICAgICAgdGhpcy5hbGwoZG9jdW1lbnQsIHF1ZXJ5LCBmZWVkYmFja0VsID0+IHtcbiAgICAgICAgZmVlZGJhY2tFbC5jbGFzc0xpc3QuYWRkKFBIWF9OT19GRUVEQkFDS19DTEFTUylcbiAgICAgIH0pXG4gICAgfSlcbiAgfSxcblxuICBzaG93RXJyb3IoaW5wdXRFbCwgcGh4RmVlZGJhY2tGb3Ipe1xuICAgIGlmKGlucHV0RWwuaWQgfHwgaW5wdXRFbC5uYW1lKXtcbiAgICAgIHRoaXMuYWxsKGlucHV0RWwuZm9ybSwgYFske3BoeEZlZWRiYWNrRm9yfT1cIiR7aW5wdXRFbC5pZH1cIl0sIFske3BoeEZlZWRiYWNrRm9yfT1cIiR7aW5wdXRFbC5uYW1lfVwiXWAsIChlbCkgPT4ge1xuICAgICAgICB0aGlzLnJlbW92ZUNsYXNzKGVsLCBQSFhfTk9fRkVFREJBQ0tfQ0xBU1MpXG4gICAgICB9KVxuICAgIH1cbiAgfSxcblxuICBpc1BoeENoaWxkKG5vZGUpe1xuICAgIHJldHVybiBub2RlLmdldEF0dHJpYnV0ZSAmJiBub2RlLmdldEF0dHJpYnV0ZShQSFhfUEFSRU5UX0lEKVxuICB9LFxuXG4gIGlzUGh4U3RpY2t5KG5vZGUpe1xuICAgIHJldHVybiBub2RlLmdldEF0dHJpYnV0ZSAmJiBub2RlLmdldEF0dHJpYnV0ZShQSFhfU1RJQ0tZKSAhPT0gbnVsbFxuICB9LFxuXG4gIGZpcnN0UGh4Q2hpbGQoZWwpe1xuICAgIHJldHVybiB0aGlzLmlzUGh4Q2hpbGQoZWwpID8gZWwgOiB0aGlzLmFsbChlbCwgYFske1BIWF9QQVJFTlRfSUR9XWApWzBdXG4gIH0sXG5cbiAgZGlzcGF0Y2hFdmVudCh0YXJnZXQsIG5hbWUsIG9wdHMgPSB7fSl7XG4gICAgbGV0IGJ1YmJsZXMgPSBvcHRzLmJ1YmJsZXMgPT09IHVuZGVmaW5lZCA/IHRydWUgOiAhIW9wdHMuYnViYmxlc1xuICAgIGxldCBldmVudE9wdHMgPSB7YnViYmxlczogYnViYmxlcywgY2FuY2VsYWJsZTogdHJ1ZSwgZGV0YWlsOiBvcHRzLmRldGFpbCB8fCB7fX1cbiAgICBsZXQgZXZlbnQgPSBuYW1lID09PSBcImNsaWNrXCIgPyBuZXcgTW91c2VFdmVudChcImNsaWNrXCIsIGV2ZW50T3B0cykgOiBuZXcgQ3VzdG9tRXZlbnQobmFtZSwgZXZlbnRPcHRzKVxuICAgIHRhcmdldC5kaXNwYXRjaEV2ZW50KGV2ZW50KVxuICB9LFxuXG4gIGNsb25lTm9kZShub2RlLCBodG1sKXtcbiAgICBpZih0eXBlb2YgKGh0bWwpID09PSBcInVuZGVmaW5lZFwiKXtcbiAgICAgIHJldHVybiBub2RlLmNsb25lTm9kZSh0cnVlKVxuICAgIH0gZWxzZSB7XG4gICAgICBsZXQgY2xvbmVkID0gbm9kZS5jbG9uZU5vZGUoZmFsc2UpXG4gICAgICBjbG9uZWQuaW5uZXJIVE1MID0gaHRtbFxuICAgICAgcmV0dXJuIGNsb25lZFxuICAgIH1cbiAgfSxcblxuICBtZXJnZUF0dHJzKHRhcmdldCwgc291cmNlLCBvcHRzID0ge30pe1xuICAgIGxldCBleGNsdWRlID0gb3B0cy5leGNsdWRlIHx8IFtdXG4gICAgbGV0IGlzSWdub3JlZCA9IG9wdHMuaXNJZ25vcmVkXG4gICAgbGV0IHNvdXJjZUF0dHJzID0gc291cmNlLmF0dHJpYnV0ZXNcbiAgICBmb3IobGV0IGkgPSBzb3VyY2VBdHRycy5sZW5ndGggLSAxOyBpID49IDA7IGktLSl7XG4gICAgICBsZXQgbmFtZSA9IHNvdXJjZUF0dHJzW2ldLm5hbWVcbiAgICAgIGlmKGV4Y2x1ZGUuaW5kZXhPZihuYW1lKSA8IDApeyB0YXJnZXQuc2V0QXR0cmlidXRlKG5hbWUsIHNvdXJjZS5nZXRBdHRyaWJ1dGUobmFtZSkpIH1cbiAgICB9XG5cbiAgICBsZXQgdGFyZ2V0QXR0cnMgPSB0YXJnZXQuYXR0cmlidXRlc1xuICAgIGZvcihsZXQgaSA9IHRhcmdldEF0dHJzLmxlbmd0aCAtIDE7IGkgPj0gMDsgaS0tKXtcbiAgICAgIGxldCBuYW1lID0gdGFyZ2V0QXR0cnNbaV0ubmFtZVxuICAgICAgaWYoaXNJZ25vcmVkKXtcbiAgICAgICAgaWYobmFtZS5zdGFydHNXaXRoKFwiZGF0YS1cIikgJiYgIXNvdXJjZS5oYXNBdHRyaWJ1dGUobmFtZSkpeyB0YXJnZXQucmVtb3ZlQXR0cmlidXRlKG5hbWUpIH1cbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGlmKCFzb3VyY2UuaGFzQXR0cmlidXRlKG5hbWUpKXsgdGFyZ2V0LnJlbW92ZUF0dHJpYnV0ZShuYW1lKSB9XG4gICAgICB9XG4gICAgfVxuICB9LFxuXG4gIG1lcmdlRm9jdXNlZElucHV0KHRhcmdldCwgc291cmNlKXtcbiAgICAvLyBza2lwIHNlbGVjdHMgYmVjYXVzZSBGRiB3aWxsIHJlc2V0IGhpZ2hsaWdodGVkIGluZGV4IGZvciBhbnkgc2V0QXR0cmlidXRlXG4gICAgaWYoISh0YXJnZXQgaW5zdGFuY2VvZiBIVE1MU2VsZWN0RWxlbWVudCkpeyBET00ubWVyZ2VBdHRycyh0YXJnZXQsIHNvdXJjZSwge2V4Y2x1ZGU6IFtcInZhbHVlXCJdfSkgfVxuICAgIGlmKHNvdXJjZS5yZWFkT25seSl7XG4gICAgICB0YXJnZXQuc2V0QXR0cmlidXRlKFwicmVhZG9ubHlcIiwgdHJ1ZSlcbiAgICB9IGVsc2Uge1xuICAgICAgdGFyZ2V0LnJlbW92ZUF0dHJpYnV0ZShcInJlYWRvbmx5XCIpXG4gICAgfVxuICB9LFxuXG4gIGhhc1NlbGVjdGlvblJhbmdlKGVsKXtcbiAgICByZXR1cm4gZWwuc2V0U2VsZWN0aW9uUmFuZ2UgJiYgKGVsLnR5cGUgPT09IFwidGV4dFwiIHx8IGVsLnR5cGUgPT09IFwidGV4dGFyZWFcIilcbiAgfSxcblxuICByZXN0b3JlRm9jdXMoZm9jdXNlZCwgc2VsZWN0aW9uU3RhcnQsIHNlbGVjdGlvbkVuZCl7XG4gICAgaWYoIURPTS5pc1RleHR1YWxJbnB1dChmb2N1c2VkKSl7IHJldHVybiB9XG4gICAgbGV0IHdhc0ZvY3VzZWQgPSBmb2N1c2VkLm1hdGNoZXMoXCI6Zm9jdXNcIilcbiAgICBpZihmb2N1c2VkLnJlYWRPbmx5KXsgZm9jdXNlZC5ibHVyKCkgfVxuICAgIGlmKCF3YXNGb2N1c2VkKXsgZm9jdXNlZC5mb2N1cygpIH1cbiAgICBpZih0aGlzLmhhc1NlbGVjdGlvblJhbmdlKGZvY3VzZWQpKXtcbiAgICAgIGZvY3VzZWQuc2V0U2VsZWN0aW9uUmFuZ2Uoc2VsZWN0aW9uU3RhcnQsIHNlbGVjdGlvbkVuZClcbiAgICB9XG4gIH0sXG5cbiAgaXNGb3JtSW5wdXQoZWwpeyByZXR1cm4gL14oPzppbnB1dHxzZWxlY3R8dGV4dGFyZWEpJC9pLnRlc3QoZWwudGFnTmFtZSkgJiYgZWwudHlwZSAhPT0gXCJidXR0b25cIiB9LFxuXG4gIHN5bmNBdHRyc1RvUHJvcHMoZWwpe1xuICAgIGlmKGVsIGluc3RhbmNlb2YgSFRNTElucHV0RWxlbWVudCAmJiBDSEVDS0FCTEVfSU5QVVRTLmluZGV4T2YoZWwudHlwZS50b0xvY2FsZUxvd2VyQ2FzZSgpKSA+PSAwKXtcbiAgICAgIGVsLmNoZWNrZWQgPSBlbC5nZXRBdHRyaWJ1dGUoXCJjaGVja2VkXCIpICE9PSBudWxsXG4gICAgfVxuICB9LFxuXG4gIGlzVGV4dHVhbElucHV0KGVsKXsgcmV0dXJuIEZPQ1VTQUJMRV9JTlBVVFMuaW5kZXhPZihlbC50eXBlKSA+PSAwIH0sXG5cbiAgaXNOb3dUcmlnZ2VyRm9ybUV4dGVybmFsKGVsLCBwaHhUcmlnZ2VyRXh0ZXJuYWwpe1xuICAgIHJldHVybiBlbC5nZXRBdHRyaWJ1dGUgJiYgZWwuZ2V0QXR0cmlidXRlKHBoeFRyaWdnZXJFeHRlcm5hbCkgIT09IG51bGxcbiAgfSxcblxuICBzeW5jUGVuZGluZ1JlZihmcm9tRWwsIHRvRWwsIGRpc2FibGVXaXRoKXtcbiAgICBsZXQgcmVmID0gZnJvbUVsLmdldEF0dHJpYnV0ZShQSFhfUkVGKVxuICAgIGlmKHJlZiA9PT0gbnVsbCl7IHJldHVybiB0cnVlIH1cbiAgICBsZXQgcmVmU3JjID0gZnJvbUVsLmdldEF0dHJpYnV0ZShQSFhfUkVGX1NSQylcblxuICAgIGlmKERPTS5pc0Zvcm1JbnB1dChmcm9tRWwpIHx8IGZyb21FbC5nZXRBdHRyaWJ1dGUoZGlzYWJsZVdpdGgpICE9PSBudWxsKXtcbiAgICAgIGlmKERPTS5pc1VwbG9hZElucHV0KGZyb21FbCkpeyBET00ubWVyZ2VBdHRycyhmcm9tRWwsIHRvRWwsIHtpc0lnbm9yZWQ6IHRydWV9KSB9XG4gICAgICBET00ucHV0UHJpdmF0ZShmcm9tRWwsIFBIWF9SRUYsIHRvRWwpXG4gICAgICByZXR1cm4gZmFsc2VcbiAgICB9IGVsc2Uge1xuICAgICAgUEhYX0VWRU5UX0NMQVNTRVMuZm9yRWFjaChjbGFzc05hbWUgPT4ge1xuICAgICAgICBmcm9tRWwuY2xhc3NMaXN0LmNvbnRhaW5zKGNsYXNzTmFtZSkgJiYgdG9FbC5jbGFzc0xpc3QuYWRkKGNsYXNzTmFtZSlcbiAgICAgIH0pXG4gICAgICB0b0VsLnNldEF0dHJpYnV0ZShQSFhfUkVGLCByZWYpXG4gICAgICB0b0VsLnNldEF0dHJpYnV0ZShQSFhfUkVGX1NSQywgcmVmU3JjKVxuICAgICAgcmV0dXJuIHRydWVcbiAgICB9XG4gIH0sXG5cbiAgY2xlYW5DaGlsZE5vZGVzKGNvbnRhaW5lciwgcGh4VXBkYXRlKXtcbiAgICBpZihET00uaXNQaHhVcGRhdGUoY29udGFpbmVyLCBwaHhVcGRhdGUsIFtcImFwcGVuZFwiLCBcInByZXBlbmRcIl0pKXtcbiAgICAgIGxldCB0b1JlbW92ZSA9IFtdXG4gICAgICBjb250YWluZXIuY2hpbGROb2Rlcy5mb3JFYWNoKGNoaWxkTm9kZSA9PiB7XG4gICAgICAgIGlmKCFjaGlsZE5vZGUuaWQpe1xuICAgICAgICAgIC8vIFNraXAgd2FybmluZyBpZiBpdCdzIGFuIGVtcHR5IHRleHQgbm9kZSAoZS5nLiBhIG5ldy1saW5lKVxuICAgICAgICAgIGxldCBpc0VtcHR5VGV4dE5vZGUgPSBjaGlsZE5vZGUubm9kZVR5cGUgPT09IE5vZGUuVEVYVF9OT0RFICYmIGNoaWxkTm9kZS5ub2RlVmFsdWUudHJpbSgpID09PSBcIlwiXG4gICAgICAgICAgaWYoIWlzRW1wdHlUZXh0Tm9kZSl7XG4gICAgICAgICAgICBsb2dFcnJvcihcIm9ubHkgSFRNTCBlbGVtZW50IHRhZ3Mgd2l0aCBhbiBpZCBhcmUgYWxsb3dlZCBpbnNpZGUgY29udGFpbmVycyB3aXRoIHBoeC11cGRhdGUuXFxuXFxuXCIgK1xuICAgICAgICAgICAgICBgcmVtb3ZpbmcgaWxsZWdhbCBub2RlOiBcIiR7KGNoaWxkTm9kZS5vdXRlckhUTUwgfHwgY2hpbGROb2RlLm5vZGVWYWx1ZSkudHJpbSgpfVwiXFxuXFxuYClcbiAgICAgICAgICB9XG4gICAgICAgICAgdG9SZW1vdmUucHVzaChjaGlsZE5vZGUpXG4gICAgICAgIH1cbiAgICAgIH0pXG4gICAgICB0b1JlbW92ZS5mb3JFYWNoKGNoaWxkTm9kZSA9PiBjaGlsZE5vZGUucmVtb3ZlKCkpXG4gICAgfVxuICB9LFxuXG4gIHJlcGxhY2VSb290Q29udGFpbmVyKGNvbnRhaW5lciwgdGFnTmFtZSwgYXR0cnMpe1xuICAgIGxldCByZXRhaW5lZEF0dHJzID0gbmV3IFNldChbXCJpZFwiLCBQSFhfU0VTU0lPTiwgUEhYX1NUQVRJQywgUEhYX01BSU4sIFBIWF9ST09UX0lEXSlcbiAgICBpZihjb250YWluZXIudGFnTmFtZS50b0xvd2VyQ2FzZSgpID09PSB0YWdOYW1lLnRvTG93ZXJDYXNlKCkpe1xuICAgICAgQXJyYXkuZnJvbShjb250YWluZXIuYXR0cmlidXRlcylcbiAgICAgICAgLmZpbHRlcihhdHRyID0+ICFyZXRhaW5lZEF0dHJzLmhhcyhhdHRyLm5hbWUudG9Mb3dlckNhc2UoKSkpXG4gICAgICAgIC5mb3JFYWNoKGF0dHIgPT4gY29udGFpbmVyLnJlbW92ZUF0dHJpYnV0ZShhdHRyLm5hbWUpKVxuXG4gICAgICBPYmplY3Qua2V5cyhhdHRycylcbiAgICAgICAgLmZpbHRlcihuYW1lID0+ICFyZXRhaW5lZEF0dHJzLmhhcyhuYW1lLnRvTG93ZXJDYXNlKCkpKVxuICAgICAgICAuZm9yRWFjaChhdHRyID0+IGNvbnRhaW5lci5zZXRBdHRyaWJ1dGUoYXR0ciwgYXR0cnNbYXR0cl0pKVxuXG4gICAgICByZXR1cm4gY29udGFpbmVyXG5cbiAgICB9IGVsc2Uge1xuICAgICAgbGV0IG5ld0NvbnRhaW5lciA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQodGFnTmFtZSlcbiAgICAgIE9iamVjdC5rZXlzKGF0dHJzKS5mb3JFYWNoKGF0dHIgPT4gbmV3Q29udGFpbmVyLnNldEF0dHJpYnV0ZShhdHRyLCBhdHRyc1thdHRyXSkpXG4gICAgICByZXRhaW5lZEF0dHJzLmZvckVhY2goYXR0ciA9PiBuZXdDb250YWluZXIuc2V0QXR0cmlidXRlKGF0dHIsIGNvbnRhaW5lci5nZXRBdHRyaWJ1dGUoYXR0cikpKVxuICAgICAgbmV3Q29udGFpbmVyLmlubmVySFRNTCA9IGNvbnRhaW5lci5pbm5lckhUTUxcbiAgICAgIGNvbnRhaW5lci5yZXBsYWNlV2l0aChuZXdDb250YWluZXIpXG4gICAgICByZXR1cm4gbmV3Q29udGFpbmVyXG4gICAgfVxuICB9LFxuXG4gIGdldFN0aWNreShlbCwgbmFtZSwgZGVmYXVsdFZhbCl7XG4gICAgbGV0IG9wID0gKERPTS5wcml2YXRlKGVsLCBcInN0aWNreVwiKSB8fCBbXSkuZmluZCgoW2V4aXN0aW5nTmFtZSwgXSkgPT4gbmFtZSA9PT0gZXhpc3RpbmdOYW1lKVxuICAgIGlmKG9wKXtcbiAgICAgIGxldCBbX25hbWUsIF9vcCwgc3Rhc2hlZFJlc3VsdF0gPSBvcFxuICAgICAgcmV0dXJuIHN0YXNoZWRSZXN1bHRcbiAgICB9IGVsc2Uge1xuICAgICAgcmV0dXJuIHR5cGVvZihkZWZhdWx0VmFsKSA9PT0gXCJmdW5jdGlvblwiID8gZGVmYXVsdFZhbCgpIDogZGVmYXVsdFZhbFxuICAgIH1cbiAgfSxcblxuICBkZWxldGVTdGlja3koZWwsIG5hbWUpe1xuICAgIHRoaXMudXBkYXRlUHJpdmF0ZShlbCwgXCJzdGlja3lcIiwgW10sIG9wcyA9PiB7XG4gICAgICByZXR1cm4gb3BzLmZpbHRlcigoW2V4aXN0aW5nTmFtZSwgX10pID0+IGV4aXN0aW5nTmFtZSAhPT0gbmFtZSlcbiAgICB9KVxuICB9LFxuXG4gIHB1dFN0aWNreShlbCwgbmFtZSwgb3Ape1xuICAgIGxldCBzdGFzaGVkUmVzdWx0ID0gb3AoZWwpXG4gICAgdGhpcy51cGRhdGVQcml2YXRlKGVsLCBcInN0aWNreVwiLCBbXSwgb3BzID0+IHtcbiAgICAgIGxldCBleGlzdGluZ0luZGV4ID0gb3BzLmZpbmRJbmRleCgoW2V4aXN0aW5nTmFtZSwgXSkgPT4gbmFtZSA9PT0gZXhpc3RpbmdOYW1lKVxuICAgICAgaWYoZXhpc3RpbmdJbmRleCA+PSAwKXtcbiAgICAgICAgb3BzW2V4aXN0aW5nSW5kZXhdID0gW25hbWUsIG9wLCBzdGFzaGVkUmVzdWx0XVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgb3BzLnB1c2goW25hbWUsIG9wLCBzdGFzaGVkUmVzdWx0XSlcbiAgICAgIH1cbiAgICAgIHJldHVybiBvcHNcbiAgICB9KVxuICB9LFxuXG4gIGFwcGx5U3RpY2t5T3BlcmF0aW9ucyhlbCl7XG4gICAgbGV0IG9wcyA9IERPTS5wcml2YXRlKGVsLCBcInN0aWNreVwiKVxuICAgIGlmKCFvcHMpeyByZXR1cm4gfVxuXG4gICAgb3BzLmZvckVhY2goKFtuYW1lLCBvcCwgX3N0YXNoZWRdKSA9PiB0aGlzLnB1dFN0aWNreShlbCwgbmFtZSwgb3ApKVxuICB9XG59XG5cbmV4cG9ydCBkZWZhdWx0IERPTSIsICJpbXBvcnQge1xuICBQSFhfQUNUSVZFX0VOVFJZX1JFRlMsXG4gIFBIWF9MSVZFX0ZJTEVfVVBEQVRFRCxcbiAgUEhYX1BSRUZMSUdIVEVEX1JFRlNcbn0gZnJvbSBcIi4vY29uc3RhbnRzXCJcblxuaW1wb3J0IHtcbiAgY2hhbm5lbFVwbG9hZGVyLFxuICBsb2dFcnJvclxufSBmcm9tIFwiLi91dGlsc1wiXG5cbmltcG9ydCBMaXZlVXBsb2FkZXIgZnJvbSBcIi4vbGl2ZV91cGxvYWRlclwiXG5cbmV4cG9ydCBkZWZhdWx0IGNsYXNzIFVwbG9hZEVudHJ5IHtcbiAgc3RhdGljIGlzQWN0aXZlKGZpbGVFbCwgZmlsZSl7XG4gICAgbGV0IGlzTmV3ID0gZmlsZS5fcGh4UmVmID09PSB1bmRlZmluZWRcbiAgICBsZXQgYWN0aXZlUmVmcyA9IGZpbGVFbC5nZXRBdHRyaWJ1dGUoUEhYX0FDVElWRV9FTlRSWV9SRUZTKS5zcGxpdChcIixcIilcbiAgICBsZXQgaXNBY3RpdmUgPSBhY3RpdmVSZWZzLmluZGV4T2YoTGl2ZVVwbG9hZGVyLmdlbkZpbGVSZWYoZmlsZSkpID49IDBcbiAgICByZXR1cm4gZmlsZS5zaXplID4gMCAmJiAoaXNOZXcgfHwgaXNBY3RpdmUpXG4gIH1cblxuICBzdGF0aWMgaXNQcmVmbGlnaHRlZChmaWxlRWwsIGZpbGUpe1xuICAgIGxldCBwcmVmbGlnaHRlZFJlZnMgPSBmaWxlRWwuZ2V0QXR0cmlidXRlKFBIWF9QUkVGTElHSFRFRF9SRUZTKS5zcGxpdChcIixcIilcbiAgICBsZXQgaXNQcmVmbGlnaHRlZCA9IHByZWZsaWdodGVkUmVmcy5pbmRleE9mKExpdmVVcGxvYWRlci5nZW5GaWxlUmVmKGZpbGUpKSA+PSAwXG4gICAgcmV0dXJuIGlzUHJlZmxpZ2h0ZWQgJiYgdGhpcy5pc0FjdGl2ZShmaWxlRWwsIGZpbGUpXG4gIH1cblxuICBjb25zdHJ1Y3RvcihmaWxlRWwsIGZpbGUsIHZpZXcpe1xuICAgIHRoaXMucmVmID0gTGl2ZVVwbG9hZGVyLmdlbkZpbGVSZWYoZmlsZSlcbiAgICB0aGlzLmZpbGVFbCA9IGZpbGVFbFxuICAgIHRoaXMuZmlsZSA9IGZpbGVcbiAgICB0aGlzLnZpZXcgPSB2aWV3XG4gICAgdGhpcy5tZXRhID0gbnVsbFxuICAgIHRoaXMuX2lzQ2FuY2VsbGVkID0gZmFsc2VcbiAgICB0aGlzLl9pc0RvbmUgPSBmYWxzZVxuICAgIHRoaXMuX3Byb2dyZXNzID0gMFxuICAgIHRoaXMuX2xhc3RQcm9ncmVzc1NlbnQgPSAtMVxuICAgIHRoaXMuX29uRG9uZSA9IGZ1bmN0aW9uICgpeyB9XG4gICAgdGhpcy5fb25FbFVwZGF0ZWQgPSB0aGlzLm9uRWxVcGRhdGVkLmJpbmQodGhpcylcbiAgICB0aGlzLmZpbGVFbC5hZGRFdmVudExpc3RlbmVyKFBIWF9MSVZFX0ZJTEVfVVBEQVRFRCwgdGhpcy5fb25FbFVwZGF0ZWQpXG4gIH1cblxuICBtZXRhZGF0YSgpeyByZXR1cm4gdGhpcy5tZXRhIH1cblxuICBwcm9ncmVzcyhwcm9ncmVzcyl7XG4gICAgdGhpcy5fcHJvZ3Jlc3MgPSBNYXRoLmZsb29yKHByb2dyZXNzKVxuICAgIGlmKHRoaXMuX3Byb2dyZXNzID4gdGhpcy5fbGFzdFByb2dyZXNzU2VudCl7XG4gICAgICBpZih0aGlzLl9wcm9ncmVzcyA+PSAxMDApe1xuICAgICAgICB0aGlzLl9wcm9ncmVzcyA9IDEwMFxuICAgICAgICB0aGlzLl9sYXN0UHJvZ3Jlc3NTZW50ID0gMTAwXG4gICAgICAgIHRoaXMuX2lzRG9uZSA9IHRydWVcbiAgICAgICAgdGhpcy52aWV3LnB1c2hGaWxlUHJvZ3Jlc3ModGhpcy5maWxlRWwsIHRoaXMucmVmLCAxMDAsICgpID0+IHtcbiAgICAgICAgICBMaXZlVXBsb2FkZXIudW50cmFja0ZpbGUodGhpcy5maWxlRWwsIHRoaXMuZmlsZSlcbiAgICAgICAgICB0aGlzLl9vbkRvbmUoKVxuICAgICAgICB9KVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5fbGFzdFByb2dyZXNzU2VudCA9IHRoaXMuX3Byb2dyZXNzXG4gICAgICAgIHRoaXMudmlldy5wdXNoRmlsZVByb2dyZXNzKHRoaXMuZmlsZUVsLCB0aGlzLnJlZiwgdGhpcy5fcHJvZ3Jlc3MpXG4gICAgICB9XG4gICAgfVxuICB9XG5cbiAgY2FuY2VsKCl7XG4gICAgdGhpcy5faXNDYW5jZWxsZWQgPSB0cnVlXG4gICAgdGhpcy5faXNEb25lID0gdHJ1ZVxuICAgIHRoaXMuX29uRG9uZSgpXG4gIH1cblxuICBpc0RvbmUoKXsgcmV0dXJuIHRoaXMuX2lzRG9uZSB9XG5cbiAgZXJyb3IocmVhc29uID0gXCJmYWlsZWRcIil7XG4gICAgdGhpcy5maWxlRWwucmVtb3ZlRXZlbnRMaXN0ZW5lcihQSFhfTElWRV9GSUxFX1VQREFURUQsIHRoaXMuX29uRWxVcGRhdGVkKVxuICAgIHRoaXMudmlldy5wdXNoRmlsZVByb2dyZXNzKHRoaXMuZmlsZUVsLCB0aGlzLnJlZiwge2Vycm9yOiByZWFzb259KVxuICAgIExpdmVVcGxvYWRlci5jbGVhckZpbGVzKHRoaXMuZmlsZUVsKVxuICB9XG5cbiAgLy9wcml2YXRlXG5cbiAgb25Eb25lKGNhbGxiYWNrKXtcbiAgICB0aGlzLl9vbkRvbmUgPSAoKSA9PiB7XG4gICAgICB0aGlzLmZpbGVFbC5yZW1vdmVFdmVudExpc3RlbmVyKFBIWF9MSVZFX0ZJTEVfVVBEQVRFRCwgdGhpcy5fb25FbFVwZGF0ZWQpXG4gICAgICBjYWxsYmFjaygpXG4gICAgfVxuICB9XG5cbiAgb25FbFVwZGF0ZWQoKXtcbiAgICBsZXQgYWN0aXZlUmVmcyA9IHRoaXMuZmlsZUVsLmdldEF0dHJpYnV0ZShQSFhfQUNUSVZFX0VOVFJZX1JFRlMpLnNwbGl0KFwiLFwiKVxuICAgIGlmKGFjdGl2ZVJlZnMuaW5kZXhPZih0aGlzLnJlZikgPT09IC0xKXsgdGhpcy5jYW5jZWwoKSB9XG4gIH1cblxuICB0b1ByZWZsaWdodFBheWxvYWQoKXtcbiAgICByZXR1cm4ge1xuICAgICAgbGFzdF9tb2RpZmllZDogdGhpcy5maWxlLmxhc3RNb2RpZmllZCxcbiAgICAgIG5hbWU6IHRoaXMuZmlsZS5uYW1lLFxuICAgICAgcmVsYXRpdmVfcGF0aDogdGhpcy5maWxlLndlYmtpdFJlbGF0aXZlUGF0aCxcbiAgICAgIHNpemU6IHRoaXMuZmlsZS5zaXplLFxuICAgICAgdHlwZTogdGhpcy5maWxlLnR5cGUsXG4gICAgICByZWY6IHRoaXMucmVmXG4gICAgfVxuICB9XG5cbiAgdXBsb2FkZXIodXBsb2FkZXJzKXtcbiAgICBpZih0aGlzLm1ldGEudXBsb2FkZXIpe1xuICAgICAgbGV0IGNhbGxiYWNrID0gdXBsb2FkZXJzW3RoaXMubWV0YS51cGxvYWRlcl0gfHwgbG9nRXJyb3IoYG5vIHVwbG9hZGVyIGNvbmZpZ3VyZWQgZm9yICR7dGhpcy5tZXRhLnVwbG9hZGVyfWApXG4gICAgICByZXR1cm4ge25hbWU6IHRoaXMubWV0YS51cGxvYWRlciwgY2FsbGJhY2s6IGNhbGxiYWNrfVxuICAgIH0gZWxzZSB7XG4gICAgICByZXR1cm4ge25hbWU6IFwiY2hhbm5lbFwiLCBjYWxsYmFjazogY2hhbm5lbFVwbG9hZGVyfVxuICAgIH1cbiAgfVxuXG4gIHppcFBvc3RGbGlnaHQocmVzcCl7XG4gICAgdGhpcy5tZXRhID0gcmVzcC5lbnRyaWVzW3RoaXMucmVmXVxuICAgIGlmKCF0aGlzLm1ldGEpeyBsb2dFcnJvcihgbm8gcHJlZmxpZ2h0IHVwbG9hZCByZXNwb25zZSByZXR1cm5lZCB3aXRoIHJlZiAke3RoaXMucmVmfWAsIHtpbnB1dDogdGhpcy5maWxlRWwsIHJlc3BvbnNlOiByZXNwfSkgfVxuICB9XG59XG4iLCAiaW1wb3J0IHtcbiAgUEhYX0RPTkVfUkVGUyxcbiAgUEhYX1BSRUZMSUdIVEVEX1JFRlMsXG4gIFBIWF9VUExPQURfUkVGXG59IGZyb20gXCIuL2NvbnN0YW50c1wiXG5cbmltcG9ydCB7XG59IGZyb20gXCIuL3V0aWxzXCJcblxuaW1wb3J0IERPTSBmcm9tIFwiLi9kb21cIlxuaW1wb3J0IFVwbG9hZEVudHJ5IGZyb20gXCIuL3VwbG9hZF9lbnRyeVwiXG5cbmxldCBsaXZlVXBsb2FkZXJGaWxlUmVmID0gMFxuXG5leHBvcnQgZGVmYXVsdCBjbGFzcyBMaXZlVXBsb2FkZXIge1xuICBzdGF0aWMgZ2VuRmlsZVJlZihmaWxlKXtcbiAgICBsZXQgcmVmID0gZmlsZS5fcGh4UmVmXG4gICAgaWYocmVmICE9PSB1bmRlZmluZWQpe1xuICAgICAgcmV0dXJuIHJlZlxuICAgIH0gZWxzZSB7XG4gICAgICBmaWxlLl9waHhSZWYgPSAobGl2ZVVwbG9hZGVyRmlsZVJlZisrKS50b1N0cmluZygpXG4gICAgICByZXR1cm4gZmlsZS5fcGh4UmVmXG4gICAgfVxuICB9XG5cbiAgc3RhdGljIGdldEVudHJ5RGF0YVVSTChpbnB1dEVsLCByZWYsIGNhbGxiYWNrKXtcbiAgICBsZXQgZmlsZSA9IHRoaXMuYWN0aXZlRmlsZXMoaW5wdXRFbCkuZmluZChmaWxlID0+IHRoaXMuZ2VuRmlsZVJlZihmaWxlKSA9PT0gcmVmKVxuICAgIGNhbGxiYWNrKFVSTC5jcmVhdGVPYmplY3RVUkwoZmlsZSkpXG4gIH1cblxuICBzdGF0aWMgaGFzVXBsb2Fkc0luUHJvZ3Jlc3MoZm9ybUVsKXtcbiAgICBsZXQgYWN0aXZlID0gMFxuICAgIERPTS5maW5kVXBsb2FkSW5wdXRzKGZvcm1FbCkuZm9yRWFjaChpbnB1dCA9PiB7XG4gICAgICBpZihpbnB1dC5nZXRBdHRyaWJ1dGUoUEhYX1BSRUZMSUdIVEVEX1JFRlMpICE9PSBpbnB1dC5nZXRBdHRyaWJ1dGUoUEhYX0RPTkVfUkVGUykpe1xuICAgICAgICBhY3RpdmUrK1xuICAgICAgfVxuICAgIH0pXG4gICAgcmV0dXJuIGFjdGl2ZSA+IDBcbiAgfVxuXG4gIHN0YXRpYyBzZXJpYWxpemVVcGxvYWRzKGlucHV0RWwpe1xuICAgIGxldCBmaWxlcyA9IHRoaXMuYWN0aXZlRmlsZXMoaW5wdXRFbClcbiAgICBsZXQgZmlsZURhdGEgPSB7fVxuICAgIGZpbGVzLmZvckVhY2goZmlsZSA9PiB7XG4gICAgICBsZXQgZW50cnkgPSB7cGF0aDogaW5wdXRFbC5uYW1lfVxuICAgICAgbGV0IHVwbG9hZFJlZiA9IGlucHV0RWwuZ2V0QXR0cmlidXRlKFBIWF9VUExPQURfUkVGKVxuICAgICAgZmlsZURhdGFbdXBsb2FkUmVmXSA9IGZpbGVEYXRhW3VwbG9hZFJlZl0gfHwgW11cbiAgICAgIGVudHJ5LnJlZiA9IHRoaXMuZ2VuRmlsZVJlZihmaWxlKVxuICAgICAgZW50cnkubGFzdF9tb2RpZmllZCA9IGZpbGUubGFzdE1vZGlmaWVkXG4gICAgICBlbnRyeS5uYW1lID0gZmlsZS5uYW1lIHx8IGVudHJ5LnJlZlxuICAgICAgZW50cnkucmVsYXRpdmVfcGF0aCA9IGZpbGUud2Via2l0UmVsYXRpdmVQYXRoXG4gICAgICBlbnRyeS50eXBlID0gZmlsZS50eXBlXG4gICAgICBlbnRyeS5zaXplID0gZmlsZS5zaXplXG4gICAgICBmaWxlRGF0YVt1cGxvYWRSZWZdLnB1c2goZW50cnkpXG4gICAgfSlcbiAgICByZXR1cm4gZmlsZURhdGFcbiAgfVxuXG4gIHN0YXRpYyBjbGVhckZpbGVzKGlucHV0RWwpe1xuICAgIGlucHV0RWwudmFsdWUgPSBudWxsXG4gICAgaW5wdXRFbC5yZW1vdmVBdHRyaWJ1dGUoUEhYX1VQTE9BRF9SRUYpXG4gICAgRE9NLnB1dFByaXZhdGUoaW5wdXRFbCwgXCJmaWxlc1wiLCBbXSlcbiAgfVxuXG4gIHN0YXRpYyB1bnRyYWNrRmlsZShpbnB1dEVsLCBmaWxlKXtcbiAgICBET00ucHV0UHJpdmF0ZShpbnB1dEVsLCBcImZpbGVzXCIsIERPTS5wcml2YXRlKGlucHV0RWwsIFwiZmlsZXNcIikuZmlsdGVyKGYgPT4gIU9iamVjdC5pcyhmLCBmaWxlKSkpXG4gIH1cblxuICBzdGF0aWMgdHJhY2tGaWxlcyhpbnB1dEVsLCBmaWxlcywgZGF0YVRyYW5zZmVyKXtcbiAgICBpZihpbnB1dEVsLmdldEF0dHJpYnV0ZShcIm11bHRpcGxlXCIpICE9PSBudWxsKXtcbiAgICAgIGxldCBuZXdGaWxlcyA9IGZpbGVzLmZpbHRlcihmaWxlID0+ICF0aGlzLmFjdGl2ZUZpbGVzKGlucHV0RWwpLmZpbmQoZiA9PiBPYmplY3QuaXMoZiwgZmlsZSkpKVxuICAgICAgRE9NLnB1dFByaXZhdGUoaW5wdXRFbCwgXCJmaWxlc1wiLCB0aGlzLmFjdGl2ZUZpbGVzKGlucHV0RWwpLmNvbmNhdChuZXdGaWxlcykpXG4gICAgICBpbnB1dEVsLnZhbHVlID0gbnVsbFxuICAgIH0gZWxzZSB7XG4gICAgICAvLyBSZXNldCBpbnB1dEVsIGZpbGVzIHRvIGFsaWduIG91dHB1dCB3aXRoIHByb2dyYW1tYXRpYyBjaGFuZ2VzIChpLmUuIGRyYWcgYW5kIGRyb3ApXG4gICAgICBpZihkYXRhVHJhbnNmZXIgJiYgZGF0YVRyYW5zZmVyLmZpbGVzLmxlbmd0aCA+IDApeyBpbnB1dEVsLmZpbGVzID0gZGF0YVRyYW5zZmVyLmZpbGVzIH1cbiAgICAgIERPTS5wdXRQcml2YXRlKGlucHV0RWwsIFwiZmlsZXNcIiwgZmlsZXMpXG4gICAgfVxuICB9XG5cbiAgc3RhdGljIGFjdGl2ZUZpbGVJbnB1dHMoZm9ybUVsKXtcbiAgICBsZXQgZmlsZUlucHV0cyA9IERPTS5maW5kVXBsb2FkSW5wdXRzKGZvcm1FbClcbiAgICByZXR1cm4gQXJyYXkuZnJvbShmaWxlSW5wdXRzKS5maWx0ZXIoZWwgPT4gZWwuZmlsZXMgJiYgdGhpcy5hY3RpdmVGaWxlcyhlbCkubGVuZ3RoID4gMClcbiAgfVxuXG4gIHN0YXRpYyBhY3RpdmVGaWxlcyhpbnB1dCl7XG4gICAgcmV0dXJuIChET00ucHJpdmF0ZShpbnB1dCwgXCJmaWxlc1wiKSB8fCBbXSkuZmlsdGVyKGYgPT4gVXBsb2FkRW50cnkuaXNBY3RpdmUoaW5wdXQsIGYpKVxuICB9XG5cbiAgc3RhdGljIGlucHV0c0F3YWl0aW5nUHJlZmxpZ2h0KGZvcm1FbCl7XG4gICAgbGV0IGZpbGVJbnB1dHMgPSBET00uZmluZFVwbG9hZElucHV0cyhmb3JtRWwpXG4gICAgcmV0dXJuIEFycmF5LmZyb20oZmlsZUlucHV0cykuZmlsdGVyKGlucHV0ID0+IHRoaXMuZmlsZXNBd2FpdGluZ1ByZWZsaWdodChpbnB1dCkubGVuZ3RoID4gMClcbiAgfVxuXG4gIHN0YXRpYyBmaWxlc0F3YWl0aW5nUHJlZmxpZ2h0KGlucHV0KXtcbiAgICByZXR1cm4gdGhpcy5hY3RpdmVGaWxlcyhpbnB1dCkuZmlsdGVyKGYgPT4gIVVwbG9hZEVudHJ5LmlzUHJlZmxpZ2h0ZWQoaW5wdXQsIGYpKVxuICB9XG5cbiAgY29uc3RydWN0b3IoaW5wdXRFbCwgdmlldywgb25Db21wbGV0ZSl7XG4gICAgdGhpcy52aWV3ID0gdmlld1xuICAgIHRoaXMub25Db21wbGV0ZSA9IG9uQ29tcGxldGVcbiAgICB0aGlzLl9lbnRyaWVzID1cbiAgICAgIEFycmF5LmZyb20oTGl2ZVVwbG9hZGVyLmZpbGVzQXdhaXRpbmdQcmVmbGlnaHQoaW5wdXRFbCkgfHwgW10pXG4gICAgICAgIC5tYXAoZmlsZSA9PiBuZXcgVXBsb2FkRW50cnkoaW5wdXRFbCwgZmlsZSwgdmlldykpXG5cbiAgICB0aGlzLm51bUVudHJpZXNJblByb2dyZXNzID0gdGhpcy5fZW50cmllcy5sZW5ndGhcbiAgfVxuXG4gIGVudHJpZXMoKXsgcmV0dXJuIHRoaXMuX2VudHJpZXMgfVxuXG4gIGluaXRBZGFwdGVyVXBsb2FkKHJlc3AsIG9uRXJyb3IsIGxpdmVTb2NrZXQpe1xuICAgIHRoaXMuX2VudHJpZXMgPVxuICAgICAgdGhpcy5fZW50cmllcy5tYXAoZW50cnkgPT4ge1xuICAgICAgICBlbnRyeS56aXBQb3N0RmxpZ2h0KHJlc3ApXG4gICAgICAgIGVudHJ5Lm9uRG9uZSgoKSA9PiB7XG4gICAgICAgICAgdGhpcy5udW1FbnRyaWVzSW5Qcm9ncmVzcy0tXG4gICAgICAgICAgaWYodGhpcy5udW1FbnRyaWVzSW5Qcm9ncmVzcyA9PT0gMCl7IHRoaXMub25Db21wbGV0ZSgpIH1cbiAgICAgICAgfSlcbiAgICAgICAgcmV0dXJuIGVudHJ5XG4gICAgICB9KVxuXG4gICAgbGV0IGdyb3VwZWRFbnRyaWVzID0gdGhpcy5fZW50cmllcy5yZWR1Y2UoKGFjYywgZW50cnkpID0+IHtcbiAgICAgIGxldCB7bmFtZSwgY2FsbGJhY2t9ID0gZW50cnkudXBsb2FkZXIobGl2ZVNvY2tldC51cGxvYWRlcnMpXG4gICAgICBhY2NbbmFtZV0gPSBhY2NbbmFtZV0gfHwge2NhbGxiYWNrOiBjYWxsYmFjaywgZW50cmllczogW119XG4gICAgICBhY2NbbmFtZV0uZW50cmllcy5wdXNoKGVudHJ5KVxuICAgICAgcmV0dXJuIGFjY1xuICAgIH0sIHt9KVxuXG4gICAgZm9yKGxldCBuYW1lIGluIGdyb3VwZWRFbnRyaWVzKXtcbiAgICAgIGxldCB7Y2FsbGJhY2ssIGVudHJpZXN9ID0gZ3JvdXBlZEVudHJpZXNbbmFtZV1cbiAgICAgIGNhbGxiYWNrKGVudHJpZXMsIG9uRXJyb3IsIHJlc3AsIGxpdmVTb2NrZXQpXG4gICAgfVxuICB9XG59XG4iLCAibGV0IEFSSUEgPSB7XG4gIGZvY3VzTWFpbigpe1xuICAgIGxldCB0YXJnZXQgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKFwibWFpbiBoMSwgbWFpbiwgaDFcIilcbiAgICBpZih0YXJnZXQpe1xuICAgICAgbGV0IG9yaWdUYWJJbmRleCA9IHRhcmdldC50YWJJbmRleFxuICAgICAgdGFyZ2V0LnRhYkluZGV4ID0gLTFcbiAgICAgIHRhcmdldC5mb2N1cygpXG4gICAgICB0YXJnZXQudGFiSW5kZXggPSBvcmlnVGFiSW5kZXhcbiAgICB9XG4gIH0sXG5cbiAgYW55T2YoaW5zdGFuY2UsIGNsYXNzZXMpeyByZXR1cm4gY2xhc3Nlcy5maW5kKG5hbWUgPT4gaW5zdGFuY2UgaW5zdGFuY2VvZiBuYW1lKSB9LFxuXG4gIGlzRm9jdXNhYmxlKGVsLCBpbnRlcmFjdGl2ZU9ubHkpe1xuICAgIHJldHVybihcbiAgICAgIChlbCBpbnN0YW5jZW9mIEhUTUxBbmNob3JFbGVtZW50ICYmIGVsLnJlbCAhPT0gXCJpZ25vcmVcIikgfHxcbiAgICAgIChlbCBpbnN0YW5jZW9mIEhUTUxBcmVhRWxlbWVudCAmJiBlbC5ocmVmICE9PSB1bmRlZmluZWQpIHx8XG4gICAgICAoIWVsLmRpc2FibGVkICYmICh0aGlzLmFueU9mKGVsLCBbSFRNTElucHV0RWxlbWVudCwgSFRNTFNlbGVjdEVsZW1lbnQsIEhUTUxUZXh0QXJlYUVsZW1lbnQsIEhUTUxCdXR0b25FbGVtZW50XSkpKSB8fFxuICAgICAgKGVsIGluc3RhbmNlb2YgSFRNTElGcmFtZUVsZW1lbnQpIHx8XG4gICAgICAoZWwudGFiSW5kZXggPiAwIHx8ICghaW50ZXJhY3RpdmVPbmx5ICYmIGVsLnRhYkluZGV4ID09PSAwICYmIGVsLmdldEF0dHJpYnV0ZShcInRhYmluZGV4XCIpICE9PSBudWxsICYmIGVsLmdldEF0dHJpYnV0ZShcImFyaWEtaGlkZGVuXCIpICE9PSBcInRydWVcIikpXG4gICAgKVxuICB9LFxuXG4gIGF0dGVtcHRGb2N1cyhlbCwgaW50ZXJhY3RpdmVPbmx5KXtcbiAgICBpZih0aGlzLmlzRm9jdXNhYmxlKGVsLCBpbnRlcmFjdGl2ZU9ubHkpKXsgdHJ5eyBlbC5mb2N1cygpIH0gY2F0Y2goZSl7fSB9XG4gICAgcmV0dXJuICEhZG9jdW1lbnQuYWN0aXZlRWxlbWVudCAmJiBkb2N1bWVudC5hY3RpdmVFbGVtZW50LmlzU2FtZU5vZGUoZWwpXG4gIH0sXG5cbiAgZm9jdXNGaXJzdEludGVyYWN0aXZlKGVsKXtcbiAgICBsZXQgY2hpbGQgPSBlbC5maXJzdEVsZW1lbnRDaGlsZFxuICAgIHdoaWxlKGNoaWxkKXtcbiAgICAgIGlmKHRoaXMuYXR0ZW1wdEZvY3VzKGNoaWxkLCB0cnVlKSB8fCB0aGlzLmZvY3VzRmlyc3RJbnRlcmFjdGl2ZShjaGlsZCwgdHJ1ZSkpe1xuICAgICAgICByZXR1cm4gdHJ1ZVxuICAgICAgfVxuICAgICAgY2hpbGQgPSBjaGlsZC5uZXh0RWxlbWVudFNpYmxpbmdcbiAgICB9XG4gIH0sXG5cbiAgZm9jdXNGaXJzdChlbCl7XG4gICAgbGV0IGNoaWxkID0gZWwuZmlyc3RFbGVtZW50Q2hpbGRcbiAgICB3aGlsZShjaGlsZCl7XG4gICAgICBpZih0aGlzLmF0dGVtcHRGb2N1cyhjaGlsZCkgfHwgdGhpcy5mb2N1c0ZpcnN0KGNoaWxkKSl7XG4gICAgICAgIHJldHVybiB0cnVlXG4gICAgICB9XG4gICAgICBjaGlsZCA9IGNoaWxkLm5leHRFbGVtZW50U2libGluZ1xuICAgIH1cbiAgfSxcblxuICBmb2N1c0xhc3QoZWwpe1xuICAgIGxldCBjaGlsZCA9IGVsLmxhc3RFbGVtZW50Q2hpbGRcbiAgICB3aGlsZShjaGlsZCl7XG4gICAgICBpZih0aGlzLmF0dGVtcHRGb2N1cyhjaGlsZCkgfHwgdGhpcy5mb2N1c0xhc3QoY2hpbGQpKXtcbiAgICAgICAgcmV0dXJuIHRydWVcbiAgICAgIH1cbiAgICAgIGNoaWxkID0gY2hpbGQucHJldmlvdXNFbGVtZW50U2libGluZ1xuICAgIH1cbiAgfVxufVxuZXhwb3J0IGRlZmF1bHQgQVJJQSIsICJpbXBvcnQge1xuICBQSFhfQUNUSVZFX0VOVFJZX1JFRlMsXG4gIFBIWF9MSVZFX0ZJTEVfVVBEQVRFRCxcbiAgUEhYX1BSRUZMSUdIVEVEX1JFRlMsXG4gIFBIWF9VUExPQURfUkVGXG59IGZyb20gXCIuL2NvbnN0YW50c1wiXG5cbmltcG9ydCBMaXZlVXBsb2FkZXIgZnJvbSBcIi4vbGl2ZV91cGxvYWRlclwiXG5pbXBvcnQgQVJJQSBmcm9tIFwiLi9hcmlhXCJcblxubGV0IEhvb2tzID0ge1xuICBMaXZlRmlsZVVwbG9hZDoge1xuICAgIGFjdGl2ZVJlZnMoKXsgcmV0dXJuIHRoaXMuZWwuZ2V0QXR0cmlidXRlKFBIWF9BQ1RJVkVfRU5UUllfUkVGUykgfSxcblxuICAgIHByZWZsaWdodGVkUmVmcygpeyByZXR1cm4gdGhpcy5lbC5nZXRBdHRyaWJ1dGUoUEhYX1BSRUZMSUdIVEVEX1JFRlMpIH0sXG5cbiAgICBtb3VudGVkKCl7IHRoaXMucHJlZmxpZ2h0ZWRXYXMgPSB0aGlzLnByZWZsaWdodGVkUmVmcygpIH0sXG5cbiAgICB1cGRhdGVkKCl7XG4gICAgICBsZXQgbmV3UHJlZmxpZ2h0cyA9IHRoaXMucHJlZmxpZ2h0ZWRSZWZzKClcbiAgICAgIGlmKHRoaXMucHJlZmxpZ2h0ZWRXYXMgIT09IG5ld1ByZWZsaWdodHMpe1xuICAgICAgICB0aGlzLnByZWZsaWdodGVkV2FzID0gbmV3UHJlZmxpZ2h0c1xuICAgICAgICBpZihuZXdQcmVmbGlnaHRzID09PSBcIlwiKXtcbiAgICAgICAgICB0aGlzLl9fdmlldy5jYW5jZWxTdWJtaXQodGhpcy5lbC5mb3JtKVxuICAgICAgICB9XG4gICAgICB9XG5cbiAgICAgIGlmKHRoaXMuYWN0aXZlUmVmcygpID09PSBcIlwiKXsgdGhpcy5lbC52YWx1ZSA9IG51bGwgfVxuICAgICAgdGhpcy5lbC5kaXNwYXRjaEV2ZW50KG5ldyBDdXN0b21FdmVudChQSFhfTElWRV9GSUxFX1VQREFURUQpKVxuICAgIH1cbiAgfSxcblxuICBMaXZlSW1nUHJldmlldzoge1xuICAgIG1vdW50ZWQoKXtcbiAgICAgIHRoaXMucmVmID0gdGhpcy5lbC5nZXRBdHRyaWJ1dGUoXCJkYXRhLXBoeC1lbnRyeS1yZWZcIilcbiAgICAgIHRoaXMuaW5wdXRFbCA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKHRoaXMuZWwuZ2V0QXR0cmlidXRlKFBIWF9VUExPQURfUkVGKSlcbiAgICAgIExpdmVVcGxvYWRlci5nZXRFbnRyeURhdGFVUkwodGhpcy5pbnB1dEVsLCB0aGlzLnJlZiwgdXJsID0+IHtcbiAgICAgICAgdGhpcy51cmwgPSB1cmxcbiAgICAgICAgdGhpcy5lbC5zcmMgPSB1cmxcbiAgICAgIH0pXG4gICAgfSxcbiAgICBkZXN0cm95ZWQoKXtcbiAgICAgIFVSTC5yZXZva2VPYmplY3RVUkwodGhpcy51cmwpXG4gICAgfVxuICB9LFxuICBGb2N1c1dyYXA6IHtcbiAgICBtb3VudGVkKCl7XG4gICAgICB0aGlzLmZvY3VzU3RhcnQgPSB0aGlzLmVsLmZpcnN0RWxlbWVudENoaWxkXG4gICAgICB0aGlzLmZvY3VzRW5kID0gdGhpcy5lbC5sYXN0RWxlbWVudENoaWxkXG4gICAgICB0aGlzLmZvY3VzU3RhcnQuYWRkRXZlbnRMaXN0ZW5lcihcImZvY3VzXCIsICgpID0+IEFSSUEuZm9jdXNMYXN0KHRoaXMuZWwpKVxuICAgICAgdGhpcy5mb2N1c0VuZC5hZGRFdmVudExpc3RlbmVyKFwiZm9jdXNcIiwgKCkgPT4gQVJJQS5mb2N1c0ZpcnN0KHRoaXMuZWwpKVxuICAgICAgdGhpcy5lbC5hZGRFdmVudExpc3RlbmVyKFwicGh4OnNob3ctZW5kXCIsICgpID0+IHRoaXMuZWwuZm9jdXMoKSlcbiAgICAgIGlmKHdpbmRvdy5nZXRDb21wdXRlZFN0eWxlKHRoaXMuZWwpLmRpc3BsYXkgIT09IFwibm9uZVwiKXtcbiAgICAgICAgQVJJQS5mb2N1c0ZpcnN0KHRoaXMuZWwpXG4gICAgICB9XG4gICAgfVxuICB9XG59XG5cbmV4cG9ydCBkZWZhdWx0IEhvb2tzXG4iLCAiaW1wb3J0IHtcbiAgbWF5YmVcbn0gZnJvbSBcIi4vdXRpbHNcIlxuXG5pbXBvcnQgRE9NIGZyb20gXCIuL2RvbVwiXG5cbmV4cG9ydCBkZWZhdWx0IGNsYXNzIERPTVBvc3RNb3JwaFJlc3RvcmVyIHtcbiAgY29uc3RydWN0b3IoY29udGFpbmVyQmVmb3JlLCBjb250YWluZXJBZnRlciwgdXBkYXRlVHlwZSl7XG4gICAgbGV0IGlkc0JlZm9yZSA9IG5ldyBTZXQoKVxuICAgIGxldCBpZHNBZnRlciA9IG5ldyBTZXQoWy4uLmNvbnRhaW5lckFmdGVyLmNoaWxkcmVuXS5tYXAoY2hpbGQgPT4gY2hpbGQuaWQpKVxuXG4gICAgbGV0IGVsZW1lbnRzVG9Nb2RpZnkgPSBbXVxuXG4gICAgQXJyYXkuZnJvbShjb250YWluZXJCZWZvcmUuY2hpbGRyZW4pLmZvckVhY2goY2hpbGQgPT4ge1xuICAgICAgaWYoY2hpbGQuaWQpeyAvLyBhbGwgb2Ygb3VyIGNoaWxkcmVuIHNob3VsZCBiZSBlbGVtZW50cyB3aXRoIGlkc1xuICAgICAgICBpZHNCZWZvcmUuYWRkKGNoaWxkLmlkKVxuICAgICAgICBpZihpZHNBZnRlci5oYXMoY2hpbGQuaWQpKXtcbiAgICAgICAgICBsZXQgcHJldmlvdXNFbGVtZW50SWQgPSBjaGlsZC5wcmV2aW91c0VsZW1lbnRTaWJsaW5nICYmIGNoaWxkLnByZXZpb3VzRWxlbWVudFNpYmxpbmcuaWRcbiAgICAgICAgICBlbGVtZW50c1RvTW9kaWZ5LnB1c2goe2VsZW1lbnRJZDogY2hpbGQuaWQsIHByZXZpb3VzRWxlbWVudElkOiBwcmV2aW91c0VsZW1lbnRJZH0pXG4gICAgICAgIH1cbiAgICAgIH1cbiAgICB9KVxuXG4gICAgdGhpcy5jb250YWluZXJJZCA9IGNvbnRhaW5lckFmdGVyLmlkXG4gICAgdGhpcy51cGRhdGVUeXBlID0gdXBkYXRlVHlwZVxuICAgIHRoaXMuZWxlbWVudHNUb01vZGlmeSA9IGVsZW1lbnRzVG9Nb2RpZnlcbiAgICB0aGlzLmVsZW1lbnRJZHNUb0FkZCA9IFsuLi5pZHNBZnRlcl0uZmlsdGVyKGlkID0+ICFpZHNCZWZvcmUuaGFzKGlkKSlcbiAgfVxuXG4gIC8vIFdlIGRvIHRoZSBmb2xsb3dpbmcgdG8gb3B0aW1pemUgYXBwZW5kL3ByZXBlbmQgb3BlcmF0aW9uczpcbiAgLy8gICAxKSBUcmFjayBpZHMgb2YgbW9kaWZpZWQgZWxlbWVudHMgJiBvZiBuZXcgZWxlbWVudHNcbiAgLy8gICAyKSBBbGwgdGhlIG1vZGlmaWVkIGVsZW1lbnRzIGFyZSBwdXQgYmFjayBpbiB0aGUgY29ycmVjdCBwb3NpdGlvbiBpbiB0aGUgRE9NIHRyZWVcbiAgLy8gICAgICBieSBzdG9yaW5nIHRoZSBpZCBvZiB0aGVpciBwcmV2aW91cyBzaWJsaW5nXG4gIC8vICAgMykgTmV3IGVsZW1lbnRzIGFyZSBnb2luZyB0byBiZSBwdXQgaW4gdGhlIHJpZ2h0IHBsYWNlIGJ5IG1vcnBoZG9tIGR1cmluZyBhcHBlbmQuXG4gIC8vICAgICAgRm9yIHByZXBlbmQsIHdlIG1vdmUgdGhlbSB0byB0aGUgZmlyc3QgcG9zaXRpb24gaW4gdGhlIGNvbnRhaW5lclxuICBwZXJmb3JtKCl7XG4gICAgbGV0IGNvbnRhaW5lciA9IERPTS5ieUlkKHRoaXMuY29udGFpbmVySWQpXG4gICAgdGhpcy5lbGVtZW50c1RvTW9kaWZ5LmZvckVhY2goZWxlbWVudFRvTW9kaWZ5ID0+IHtcbiAgICAgIGlmKGVsZW1lbnRUb01vZGlmeS5wcmV2aW91c0VsZW1lbnRJZCl7XG4gICAgICAgIG1heWJlKGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKGVsZW1lbnRUb01vZGlmeS5wcmV2aW91c0VsZW1lbnRJZCksIHByZXZpb3VzRWxlbSA9PiB7XG4gICAgICAgICAgbWF5YmUoZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoZWxlbWVudFRvTW9kaWZ5LmVsZW1lbnRJZCksIGVsZW0gPT4ge1xuICAgICAgICAgICAgbGV0IGlzSW5SaWdodFBsYWNlID0gZWxlbS5wcmV2aW91c0VsZW1lbnRTaWJsaW5nICYmIGVsZW0ucHJldmlvdXNFbGVtZW50U2libGluZy5pZCA9PSBwcmV2aW91c0VsZW0uaWRcbiAgICAgICAgICAgIGlmKCFpc0luUmlnaHRQbGFjZSl7XG4gICAgICAgICAgICAgIHByZXZpb3VzRWxlbS5pbnNlcnRBZGphY2VudEVsZW1lbnQoXCJhZnRlcmVuZFwiLCBlbGVtKVxuICAgICAgICAgICAgfVxuICAgICAgICAgIH0pXG4gICAgICAgIH0pXG4gICAgICB9IGVsc2Uge1xuICAgICAgICAvLyBUaGlzIGlzIHRoZSBmaXJzdCBlbGVtZW50IGluIHRoZSBjb250YWluZXJcbiAgICAgICAgbWF5YmUoZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoZWxlbWVudFRvTW9kaWZ5LmVsZW1lbnRJZCksIGVsZW0gPT4ge1xuICAgICAgICAgIGxldCBpc0luUmlnaHRQbGFjZSA9IGVsZW0ucHJldmlvdXNFbGVtZW50U2libGluZyA9PSBudWxsXG4gICAgICAgICAgaWYoIWlzSW5SaWdodFBsYWNlKXtcbiAgICAgICAgICAgIGNvbnRhaW5lci5pbnNlcnRBZGphY2VudEVsZW1lbnQoXCJhZnRlcmJlZ2luXCIsIGVsZW0pXG4gICAgICAgICAgfVxuICAgICAgICB9KVxuICAgICAgfVxuICAgIH0pXG5cbiAgICBpZih0aGlzLnVwZGF0ZVR5cGUgPT0gXCJwcmVwZW5kXCIpe1xuICAgICAgdGhpcy5lbGVtZW50SWRzVG9BZGQucmV2ZXJzZSgpLmZvckVhY2goZWxlbUlkID0+IHtcbiAgICAgICAgbWF5YmUoZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoZWxlbUlkKSwgZWxlbSA9PiBjb250YWluZXIuaW5zZXJ0QWRqYWNlbnRFbGVtZW50KFwiYWZ0ZXJiZWdpblwiLCBlbGVtKSlcbiAgICAgIH0pXG4gICAgfVxuICB9XG59XG4iLCAidmFyIERPQ1VNRU5UX0ZSQUdNRU5UX05PREUgPSAxMTtcblxuZnVuY3Rpb24gbW9ycGhBdHRycyhmcm9tTm9kZSwgdG9Ob2RlKSB7XG4gICAgdmFyIHRvTm9kZUF0dHJzID0gdG9Ob2RlLmF0dHJpYnV0ZXM7XG4gICAgdmFyIGF0dHI7XG4gICAgdmFyIGF0dHJOYW1lO1xuICAgIHZhciBhdHRyTmFtZXNwYWNlVVJJO1xuICAgIHZhciBhdHRyVmFsdWU7XG4gICAgdmFyIGZyb21WYWx1ZTtcblxuICAgIC8vIGRvY3VtZW50LWZyYWdtZW50cyBkb250IGhhdmUgYXR0cmlidXRlcyBzbyBsZXRzIG5vdCBkbyBhbnl0aGluZ1xuICAgIGlmICh0b05vZGUubm9kZVR5cGUgPT09IERPQ1VNRU5UX0ZSQUdNRU5UX05PREUgfHwgZnJvbU5vZGUubm9kZVR5cGUgPT09IERPQ1VNRU5UX0ZSQUdNRU5UX05PREUpIHtcbiAgICAgIHJldHVybjtcbiAgICB9XG5cbiAgICAvLyB1cGRhdGUgYXR0cmlidXRlcyBvbiBvcmlnaW5hbCBET00gZWxlbWVudFxuICAgIGZvciAodmFyIGkgPSB0b05vZGVBdHRycy5sZW5ndGggLSAxOyBpID49IDA7IGktLSkge1xuICAgICAgICBhdHRyID0gdG9Ob2RlQXR0cnNbaV07XG4gICAgICAgIGF0dHJOYW1lID0gYXR0ci5uYW1lO1xuICAgICAgICBhdHRyTmFtZXNwYWNlVVJJID0gYXR0ci5uYW1lc3BhY2VVUkk7XG4gICAgICAgIGF0dHJWYWx1ZSA9IGF0dHIudmFsdWU7XG5cbiAgICAgICAgaWYgKGF0dHJOYW1lc3BhY2VVUkkpIHtcbiAgICAgICAgICAgIGF0dHJOYW1lID0gYXR0ci5sb2NhbE5hbWUgfHwgYXR0ck5hbWU7XG4gICAgICAgICAgICBmcm9tVmFsdWUgPSBmcm9tTm9kZS5nZXRBdHRyaWJ1dGVOUyhhdHRyTmFtZXNwYWNlVVJJLCBhdHRyTmFtZSk7XG5cbiAgICAgICAgICAgIGlmIChmcm9tVmFsdWUgIT09IGF0dHJWYWx1ZSkge1xuICAgICAgICAgICAgICAgIGlmIChhdHRyLnByZWZpeCA9PT0gJ3htbG5zJyl7XG4gICAgICAgICAgICAgICAgICAgIGF0dHJOYW1lID0gYXR0ci5uYW1lOyAvLyBJdCdzIG5vdCBhbGxvd2VkIHRvIHNldCBhbiBhdHRyaWJ1dGUgd2l0aCB0aGUgWE1MTlMgbmFtZXNwYWNlIHdpdGhvdXQgc3BlY2lmeWluZyB0aGUgYHhtbG5zYCBwcmVmaXhcbiAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgZnJvbU5vZGUuc2V0QXR0cmlidXRlTlMoYXR0ck5hbWVzcGFjZVVSSSwgYXR0ck5hbWUsIGF0dHJWYWx1ZSk7XG4gICAgICAgICAgICB9XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICBmcm9tVmFsdWUgPSBmcm9tTm9kZS5nZXRBdHRyaWJ1dGUoYXR0ck5hbWUpO1xuXG4gICAgICAgICAgICBpZiAoZnJvbVZhbHVlICE9PSBhdHRyVmFsdWUpIHtcbiAgICAgICAgICAgICAgICBmcm9tTm9kZS5zZXRBdHRyaWJ1dGUoYXR0ck5hbWUsIGF0dHJWYWx1ZSk7XG4gICAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICB9XG5cbiAgICAvLyBSZW1vdmUgYW55IGV4dHJhIGF0dHJpYnV0ZXMgZm91bmQgb24gdGhlIG9yaWdpbmFsIERPTSBlbGVtZW50IHRoYXRcbiAgICAvLyB3ZXJlbid0IGZvdW5kIG9uIHRoZSB0YXJnZXQgZWxlbWVudC5cbiAgICB2YXIgZnJvbU5vZGVBdHRycyA9IGZyb21Ob2RlLmF0dHJpYnV0ZXM7XG5cbiAgICBmb3IgKHZhciBkID0gZnJvbU5vZGVBdHRycy5sZW5ndGggLSAxOyBkID49IDA7IGQtLSkge1xuICAgICAgICBhdHRyID0gZnJvbU5vZGVBdHRyc1tkXTtcbiAgICAgICAgYXR0ck5hbWUgPSBhdHRyLm5hbWU7XG4gICAgICAgIGF0dHJOYW1lc3BhY2VVUkkgPSBhdHRyLm5hbWVzcGFjZVVSSTtcblxuICAgICAgICBpZiAoYXR0ck5hbWVzcGFjZVVSSSkge1xuICAgICAgICAgICAgYXR0ck5hbWUgPSBhdHRyLmxvY2FsTmFtZSB8fCBhdHRyTmFtZTtcblxuICAgICAgICAgICAgaWYgKCF0b05vZGUuaGFzQXR0cmlidXRlTlMoYXR0ck5hbWVzcGFjZVVSSSwgYXR0ck5hbWUpKSB7XG4gICAgICAgICAgICAgICAgZnJvbU5vZGUucmVtb3ZlQXR0cmlidXRlTlMoYXR0ck5hbWVzcGFjZVVSSSwgYXR0ck5hbWUpO1xuICAgICAgICAgICAgfVxuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgaWYgKCF0b05vZGUuaGFzQXR0cmlidXRlKGF0dHJOYW1lKSkge1xuICAgICAgICAgICAgICAgIGZyb21Ob2RlLnJlbW92ZUF0dHJpYnV0ZShhdHRyTmFtZSk7XG4gICAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICB9XG59XG5cbnZhciByYW5nZTsgLy8gQ3JlYXRlIGEgcmFuZ2Ugb2JqZWN0IGZvciBlZmZpY2VudGx5IHJlbmRlcmluZyBzdHJpbmdzIHRvIGVsZW1lbnRzLlxudmFyIE5TX1hIVE1MID0gJ2h0dHA6Ly93d3cudzMub3JnLzE5OTkveGh0bWwnO1xuXG52YXIgZG9jID0gdHlwZW9mIGRvY3VtZW50ID09PSAndW5kZWZpbmVkJyA/IHVuZGVmaW5lZCA6IGRvY3VtZW50O1xudmFyIEhBU19URU1QTEFURV9TVVBQT1JUID0gISFkb2MgJiYgJ2NvbnRlbnQnIGluIGRvYy5jcmVhdGVFbGVtZW50KCd0ZW1wbGF0ZScpO1xudmFyIEhBU19SQU5HRV9TVVBQT1JUID0gISFkb2MgJiYgZG9jLmNyZWF0ZVJhbmdlICYmICdjcmVhdGVDb250ZXh0dWFsRnJhZ21lbnQnIGluIGRvYy5jcmVhdGVSYW5nZSgpO1xuXG5mdW5jdGlvbiBjcmVhdGVGcmFnbWVudEZyb21UZW1wbGF0ZShzdHIpIHtcbiAgICB2YXIgdGVtcGxhdGUgPSBkb2MuY3JlYXRlRWxlbWVudCgndGVtcGxhdGUnKTtcbiAgICB0ZW1wbGF0ZS5pbm5lckhUTUwgPSBzdHI7XG4gICAgcmV0dXJuIHRlbXBsYXRlLmNvbnRlbnQuY2hpbGROb2Rlc1swXTtcbn1cblxuZnVuY3Rpb24gY3JlYXRlRnJhZ21lbnRGcm9tUmFuZ2Uoc3RyKSB7XG4gICAgaWYgKCFyYW5nZSkge1xuICAgICAgICByYW5nZSA9IGRvYy5jcmVhdGVSYW5nZSgpO1xuICAgICAgICByYW5nZS5zZWxlY3ROb2RlKGRvYy5ib2R5KTtcbiAgICB9XG5cbiAgICB2YXIgZnJhZ21lbnQgPSByYW5nZS5jcmVhdGVDb250ZXh0dWFsRnJhZ21lbnQoc3RyKTtcbiAgICByZXR1cm4gZnJhZ21lbnQuY2hpbGROb2Rlc1swXTtcbn1cblxuZnVuY3Rpb24gY3JlYXRlRnJhZ21lbnRGcm9tV3JhcChzdHIpIHtcbiAgICB2YXIgZnJhZ21lbnQgPSBkb2MuY3JlYXRlRWxlbWVudCgnYm9keScpO1xuICAgIGZyYWdtZW50LmlubmVySFRNTCA9IHN0cjtcbiAgICByZXR1cm4gZnJhZ21lbnQuY2hpbGROb2Rlc1swXTtcbn1cblxuLyoqXG4gKiBUaGlzIGlzIGFib3V0IHRoZSBzYW1lXG4gKiB2YXIgaHRtbCA9IG5ldyBET01QYXJzZXIoKS5wYXJzZUZyb21TdHJpbmcoc3RyLCAndGV4dC9odG1sJyk7XG4gKiByZXR1cm4gaHRtbC5ib2R5LmZpcnN0Q2hpbGQ7XG4gKlxuICogQG1ldGhvZCB0b0VsZW1lbnRcbiAqIEBwYXJhbSB7U3RyaW5nfSBzdHJcbiAqL1xuZnVuY3Rpb24gdG9FbGVtZW50KHN0cikge1xuICAgIHN0ciA9IHN0ci50cmltKCk7XG4gICAgaWYgKEhBU19URU1QTEFURV9TVVBQT1JUKSB7XG4gICAgICAvLyBhdm9pZCByZXN0cmljdGlvbnMgb24gY29udGVudCBmb3IgdGhpbmdzIGxpa2UgYDx0cj48dGg+SGk8L3RoPjwvdHI+YCB3aGljaFxuICAgICAgLy8gY3JlYXRlQ29udGV4dHVhbEZyYWdtZW50IGRvZXNuJ3Qgc3VwcG9ydFxuICAgICAgLy8gPHRlbXBsYXRlPiBzdXBwb3J0IG5vdCBhdmFpbGFibGUgaW4gSUVcbiAgICAgIHJldHVybiBjcmVhdGVGcmFnbWVudEZyb21UZW1wbGF0ZShzdHIpO1xuICAgIH0gZWxzZSBpZiAoSEFTX1JBTkdFX1NVUFBPUlQpIHtcbiAgICAgIHJldHVybiBjcmVhdGVGcmFnbWVudEZyb21SYW5nZShzdHIpO1xuICAgIH1cblxuICAgIHJldHVybiBjcmVhdGVGcmFnbWVudEZyb21XcmFwKHN0cik7XG59XG5cbi8qKlxuICogUmV0dXJucyB0cnVlIGlmIHR3byBub2RlJ3MgbmFtZXMgYXJlIHRoZSBzYW1lLlxuICpcbiAqIE5PVEU6IFdlIGRvbid0IGJvdGhlciBjaGVja2luZyBgbmFtZXNwYWNlVVJJYCBiZWNhdXNlIHlvdSB3aWxsIG5ldmVyIGZpbmQgdHdvIEhUTUwgZWxlbWVudHMgd2l0aCB0aGUgc2FtZVxuICogICAgICAgbm9kZU5hbWUgYW5kIGRpZmZlcmVudCBuYW1lc3BhY2UgVVJJcy5cbiAqXG4gKiBAcGFyYW0ge0VsZW1lbnR9IGFcbiAqIEBwYXJhbSB7RWxlbWVudH0gYiBUaGUgdGFyZ2V0IGVsZW1lbnRcbiAqIEByZXR1cm4ge2Jvb2xlYW59XG4gKi9cbmZ1bmN0aW9uIGNvbXBhcmVOb2RlTmFtZXMoZnJvbUVsLCB0b0VsKSB7XG4gICAgdmFyIGZyb21Ob2RlTmFtZSA9IGZyb21FbC5ub2RlTmFtZTtcbiAgICB2YXIgdG9Ob2RlTmFtZSA9IHRvRWwubm9kZU5hbWU7XG4gICAgdmFyIGZyb21Db2RlU3RhcnQsIHRvQ29kZVN0YXJ0O1xuXG4gICAgaWYgKGZyb21Ob2RlTmFtZSA9PT0gdG9Ob2RlTmFtZSkge1xuICAgICAgICByZXR1cm4gdHJ1ZTtcbiAgICB9XG5cbiAgICBmcm9tQ29kZVN0YXJ0ID0gZnJvbU5vZGVOYW1lLmNoYXJDb2RlQXQoMCk7XG4gICAgdG9Db2RlU3RhcnQgPSB0b05vZGVOYW1lLmNoYXJDb2RlQXQoMCk7XG5cbiAgICAvLyBJZiB0aGUgdGFyZ2V0IGVsZW1lbnQgaXMgYSB2aXJ0dWFsIERPTSBub2RlIG9yIFNWRyBub2RlIHRoZW4gd2UgbWF5XG4gICAgLy8gbmVlZCB0byBub3JtYWxpemUgdGhlIHRhZyBuYW1lIGJlZm9yZSBjb21wYXJpbmcuIE5vcm1hbCBIVE1MIGVsZW1lbnRzIHRoYXQgYXJlXG4gICAgLy8gaW4gdGhlIFwiaHR0cDovL3d3dy53My5vcmcvMTk5OS94aHRtbFwiXG4gICAgLy8gYXJlIGNvbnZlcnRlZCB0byB1cHBlciBjYXNlXG4gICAgaWYgKGZyb21Db2RlU3RhcnQgPD0gOTAgJiYgdG9Db2RlU3RhcnQgPj0gOTcpIHsgLy8gZnJvbSBpcyB1cHBlciBhbmQgdG8gaXMgbG93ZXJcbiAgICAgICAgcmV0dXJuIGZyb21Ob2RlTmFtZSA9PT0gdG9Ob2RlTmFtZS50b1VwcGVyQ2FzZSgpO1xuICAgIH0gZWxzZSBpZiAodG9Db2RlU3RhcnQgPD0gOTAgJiYgZnJvbUNvZGVTdGFydCA+PSA5NykgeyAvLyB0byBpcyB1cHBlciBhbmQgZnJvbSBpcyBsb3dlclxuICAgICAgICByZXR1cm4gdG9Ob2RlTmFtZSA9PT0gZnJvbU5vZGVOYW1lLnRvVXBwZXJDYXNlKCk7XG4gICAgfSBlbHNlIHtcbiAgICAgICAgcmV0dXJuIGZhbHNlO1xuICAgIH1cbn1cblxuLyoqXG4gKiBDcmVhdGUgYW4gZWxlbWVudCwgb3B0aW9uYWxseSB3aXRoIGEga25vd24gbmFtZXNwYWNlIFVSSS5cbiAqXG4gKiBAcGFyYW0ge3N0cmluZ30gbmFtZSB0aGUgZWxlbWVudCBuYW1lLCBlLmcuICdkaXYnIG9yICdzdmcnXG4gKiBAcGFyYW0ge3N0cmluZ30gW25hbWVzcGFjZVVSSV0gdGhlIGVsZW1lbnQncyBuYW1lc3BhY2UgVVJJLCBpLmUuIHRoZSB2YWx1ZSBvZlxuICogaXRzIGB4bWxuc2AgYXR0cmlidXRlIG9yIGl0cyBpbmZlcnJlZCBuYW1lc3BhY2UuXG4gKlxuICogQHJldHVybiB7RWxlbWVudH1cbiAqL1xuZnVuY3Rpb24gY3JlYXRlRWxlbWVudE5TKG5hbWUsIG5hbWVzcGFjZVVSSSkge1xuICAgIHJldHVybiAhbmFtZXNwYWNlVVJJIHx8IG5hbWVzcGFjZVVSSSA9PT0gTlNfWEhUTUwgP1xuICAgICAgICBkb2MuY3JlYXRlRWxlbWVudChuYW1lKSA6XG4gICAgICAgIGRvYy5jcmVhdGVFbGVtZW50TlMobmFtZXNwYWNlVVJJLCBuYW1lKTtcbn1cblxuLyoqXG4gKiBDb3BpZXMgdGhlIGNoaWxkcmVuIG9mIG9uZSBET00gZWxlbWVudCB0byBhbm90aGVyIERPTSBlbGVtZW50XG4gKi9cbmZ1bmN0aW9uIG1vdmVDaGlsZHJlbihmcm9tRWwsIHRvRWwpIHtcbiAgICB2YXIgY3VyQ2hpbGQgPSBmcm9tRWwuZmlyc3RDaGlsZDtcbiAgICB3aGlsZSAoY3VyQ2hpbGQpIHtcbiAgICAgICAgdmFyIG5leHRDaGlsZCA9IGN1ckNoaWxkLm5leHRTaWJsaW5nO1xuICAgICAgICB0b0VsLmFwcGVuZENoaWxkKGN1ckNoaWxkKTtcbiAgICAgICAgY3VyQ2hpbGQgPSBuZXh0Q2hpbGQ7XG4gICAgfVxuICAgIHJldHVybiB0b0VsO1xufVxuXG5mdW5jdGlvbiBzeW5jQm9vbGVhbkF0dHJQcm9wKGZyb21FbCwgdG9FbCwgbmFtZSkge1xuICAgIGlmIChmcm9tRWxbbmFtZV0gIT09IHRvRWxbbmFtZV0pIHtcbiAgICAgICAgZnJvbUVsW25hbWVdID0gdG9FbFtuYW1lXTtcbiAgICAgICAgaWYgKGZyb21FbFtuYW1lXSkge1xuICAgICAgICAgICAgZnJvbUVsLnNldEF0dHJpYnV0ZShuYW1lLCAnJyk7XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICBmcm9tRWwucmVtb3ZlQXR0cmlidXRlKG5hbWUpO1xuICAgICAgICB9XG4gICAgfVxufVxuXG52YXIgc3BlY2lhbEVsSGFuZGxlcnMgPSB7XG4gICAgT1BUSU9OOiBmdW5jdGlvbihmcm9tRWwsIHRvRWwpIHtcbiAgICAgICAgdmFyIHBhcmVudE5vZGUgPSBmcm9tRWwucGFyZW50Tm9kZTtcbiAgICAgICAgaWYgKHBhcmVudE5vZGUpIHtcbiAgICAgICAgICAgIHZhciBwYXJlbnROYW1lID0gcGFyZW50Tm9kZS5ub2RlTmFtZS50b1VwcGVyQ2FzZSgpO1xuICAgICAgICAgICAgaWYgKHBhcmVudE5hbWUgPT09ICdPUFRHUk9VUCcpIHtcbiAgICAgICAgICAgICAgICBwYXJlbnROb2RlID0gcGFyZW50Tm9kZS5wYXJlbnROb2RlO1xuICAgICAgICAgICAgICAgIHBhcmVudE5hbWUgPSBwYXJlbnROb2RlICYmIHBhcmVudE5vZGUubm9kZU5hbWUudG9VcHBlckNhc2UoKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGlmIChwYXJlbnROYW1lID09PSAnU0VMRUNUJyAmJiAhcGFyZW50Tm9kZS5oYXNBdHRyaWJ1dGUoJ211bHRpcGxlJykpIHtcbiAgICAgICAgICAgICAgICBpZiAoZnJvbUVsLmhhc0F0dHJpYnV0ZSgnc2VsZWN0ZWQnKSAmJiAhdG9FbC5zZWxlY3RlZCkge1xuICAgICAgICAgICAgICAgICAgICAvLyBXb3JrYXJvdW5kIGZvciBNUyBFZGdlIGJ1ZyB3aGVyZSB0aGUgJ3NlbGVjdGVkJyBhdHRyaWJ1dGUgY2FuIG9ubHkgYmVcbiAgICAgICAgICAgICAgICAgICAgLy8gcmVtb3ZlZCBpZiBzZXQgdG8gYSBub24tZW1wdHkgdmFsdWU6XG4gICAgICAgICAgICAgICAgICAgIC8vIGh0dHBzOi8vZGV2ZWxvcGVyLm1pY3Jvc29mdC5jb20vZW4tdXMvbWljcm9zb2Z0LWVkZ2UvcGxhdGZvcm0vaXNzdWVzLzEyMDg3Njc5L1xuICAgICAgICAgICAgICAgICAgICBmcm9tRWwuc2V0QXR0cmlidXRlKCdzZWxlY3RlZCcsICdzZWxlY3RlZCcpO1xuICAgICAgICAgICAgICAgICAgICBmcm9tRWwucmVtb3ZlQXR0cmlidXRlKCdzZWxlY3RlZCcpO1xuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAvLyBXZSBoYXZlIHRvIHJlc2V0IHNlbGVjdCBlbGVtZW50J3Mgc2VsZWN0ZWRJbmRleCB0byAtMSwgb3RoZXJ3aXNlIHNldHRpbmdcbiAgICAgICAgICAgICAgICAvLyBmcm9tRWwuc2VsZWN0ZWQgdXNpbmcgdGhlIHN5bmNCb29sZWFuQXR0clByb3AgYmVsb3cgaGFzIG5vIGVmZmVjdC5cbiAgICAgICAgICAgICAgICAvLyBUaGUgY29ycmVjdCBzZWxlY3RlZEluZGV4IHdpbGwgYmUgc2V0IGluIHRoZSBTRUxFQ1Qgc3BlY2lhbCBoYW5kbGVyIGJlbG93LlxuICAgICAgICAgICAgICAgIHBhcmVudE5vZGUuc2VsZWN0ZWRJbmRleCA9IC0xO1xuICAgICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICAgIHN5bmNCb29sZWFuQXR0clByb3AoZnJvbUVsLCB0b0VsLCAnc2VsZWN0ZWQnKTtcbiAgICB9LFxuICAgIC8qKlxuICAgICAqIFRoZSBcInZhbHVlXCIgYXR0cmlidXRlIGlzIHNwZWNpYWwgZm9yIHRoZSA8aW5wdXQ+IGVsZW1lbnQgc2luY2UgaXQgc2V0c1xuICAgICAqIHRoZSBpbml0aWFsIHZhbHVlLiBDaGFuZ2luZyB0aGUgXCJ2YWx1ZVwiIGF0dHJpYnV0ZSB3aXRob3V0IGNoYW5naW5nIHRoZVxuICAgICAqIFwidmFsdWVcIiBwcm9wZXJ0eSB3aWxsIGhhdmUgbm8gZWZmZWN0IHNpbmNlIGl0IGlzIG9ubHkgdXNlZCB0byB0aGUgc2V0IHRoZVxuICAgICAqIGluaXRpYWwgdmFsdWUuICBTaW1pbGFyIGZvciB0aGUgXCJjaGVja2VkXCIgYXR0cmlidXRlLCBhbmQgXCJkaXNhYmxlZFwiLlxuICAgICAqL1xuICAgIElOUFVUOiBmdW5jdGlvbihmcm9tRWwsIHRvRWwpIHtcbiAgICAgICAgc3luY0Jvb2xlYW5BdHRyUHJvcChmcm9tRWwsIHRvRWwsICdjaGVja2VkJyk7XG4gICAgICAgIHN5bmNCb29sZWFuQXR0clByb3AoZnJvbUVsLCB0b0VsLCAnZGlzYWJsZWQnKTtcblxuICAgICAgICBpZiAoZnJvbUVsLnZhbHVlICE9PSB0b0VsLnZhbHVlKSB7XG4gICAgICAgICAgICBmcm9tRWwudmFsdWUgPSB0b0VsLnZhbHVlO1xuICAgICAgICB9XG5cbiAgICAgICAgaWYgKCF0b0VsLmhhc0F0dHJpYnV0ZSgndmFsdWUnKSkge1xuICAgICAgICAgICAgZnJvbUVsLnJlbW92ZUF0dHJpYnV0ZSgndmFsdWUnKTtcbiAgICAgICAgfVxuICAgIH0sXG5cbiAgICBURVhUQVJFQTogZnVuY3Rpb24oZnJvbUVsLCB0b0VsKSB7XG4gICAgICAgIHZhciBuZXdWYWx1ZSA9IHRvRWwudmFsdWU7XG4gICAgICAgIGlmIChmcm9tRWwudmFsdWUgIT09IG5ld1ZhbHVlKSB7XG4gICAgICAgICAgICBmcm9tRWwudmFsdWUgPSBuZXdWYWx1ZTtcbiAgICAgICAgfVxuXG4gICAgICAgIHZhciBmaXJzdENoaWxkID0gZnJvbUVsLmZpcnN0Q2hpbGQ7XG4gICAgICAgIGlmIChmaXJzdENoaWxkKSB7XG4gICAgICAgICAgICAvLyBOZWVkZWQgZm9yIElFLiBBcHBhcmVudGx5IElFIHNldHMgdGhlIHBsYWNlaG9sZGVyIGFzIHRoZVxuICAgICAgICAgICAgLy8gbm9kZSB2YWx1ZSBhbmQgdmlzZSB2ZXJzYS4gVGhpcyBpZ25vcmVzIGFuIGVtcHR5IHVwZGF0ZS5cbiAgICAgICAgICAgIHZhciBvbGRWYWx1ZSA9IGZpcnN0Q2hpbGQubm9kZVZhbHVlO1xuXG4gICAgICAgICAgICBpZiAob2xkVmFsdWUgPT0gbmV3VmFsdWUgfHwgKCFuZXdWYWx1ZSAmJiBvbGRWYWx1ZSA9PSBmcm9tRWwucGxhY2Vob2xkZXIpKSB7XG4gICAgICAgICAgICAgICAgcmV0dXJuO1xuICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICBmaXJzdENoaWxkLm5vZGVWYWx1ZSA9IG5ld1ZhbHVlO1xuICAgICAgICB9XG4gICAgfSxcbiAgICBTRUxFQ1Q6IGZ1bmN0aW9uKGZyb21FbCwgdG9FbCkge1xuICAgICAgICBpZiAoIXRvRWwuaGFzQXR0cmlidXRlKCdtdWx0aXBsZScpKSB7XG4gICAgICAgICAgICB2YXIgc2VsZWN0ZWRJbmRleCA9IC0xO1xuICAgICAgICAgICAgdmFyIGkgPSAwO1xuICAgICAgICAgICAgLy8gV2UgaGF2ZSB0byBsb29wIHRocm91Z2ggY2hpbGRyZW4gb2YgZnJvbUVsLCBub3QgdG9FbCBzaW5jZSBub2RlcyBjYW4gYmUgbW92ZWRcbiAgICAgICAgICAgIC8vIGZyb20gdG9FbCB0byBmcm9tRWwgZGlyZWN0bHkgd2hlbiBtb3JwaGluZy5cbiAgICAgICAgICAgIC8vIEF0IHRoZSB0aW1lIHRoaXMgc3BlY2lhbCBoYW5kbGVyIGlzIGludm9rZWQsIGFsbCBjaGlsZHJlbiBoYXZlIGFscmVhZHkgYmVlbiBtb3JwaGVkXG4gICAgICAgICAgICAvLyBhbmQgYXBwZW5kZWQgdG8gLyByZW1vdmVkIGZyb20gZnJvbUVsLCBzbyB1c2luZyBmcm9tRWwgaGVyZSBpcyBzYWZlIGFuZCBjb3JyZWN0LlxuICAgICAgICAgICAgdmFyIGN1ckNoaWxkID0gZnJvbUVsLmZpcnN0Q2hpbGQ7XG4gICAgICAgICAgICB2YXIgb3B0Z3JvdXA7XG4gICAgICAgICAgICB2YXIgbm9kZU5hbWU7XG4gICAgICAgICAgICB3aGlsZShjdXJDaGlsZCkge1xuICAgICAgICAgICAgICAgIG5vZGVOYW1lID0gY3VyQ2hpbGQubm9kZU5hbWUgJiYgY3VyQ2hpbGQubm9kZU5hbWUudG9VcHBlckNhc2UoKTtcbiAgICAgICAgICAgICAgICBpZiAobm9kZU5hbWUgPT09ICdPUFRHUk9VUCcpIHtcbiAgICAgICAgICAgICAgICAgICAgb3B0Z3JvdXAgPSBjdXJDaGlsZDtcbiAgICAgICAgICAgICAgICAgICAgY3VyQ2hpbGQgPSBvcHRncm91cC5maXJzdENoaWxkO1xuICAgICAgICAgICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICAgICAgICAgIGlmIChub2RlTmFtZSA9PT0gJ09QVElPTicpIHtcbiAgICAgICAgICAgICAgICAgICAgICAgIGlmIChjdXJDaGlsZC5oYXNBdHRyaWJ1dGUoJ3NlbGVjdGVkJykpIHtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBzZWxlY3RlZEluZGV4ID0gaTtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBicmVhaztcbiAgICAgICAgICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgICAgICAgICAgIGkrKztcbiAgICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgICAgICBjdXJDaGlsZCA9IGN1ckNoaWxkLm5leHRTaWJsaW5nO1xuICAgICAgICAgICAgICAgICAgICBpZiAoIWN1ckNoaWxkICYmIG9wdGdyb3VwKSB7XG4gICAgICAgICAgICAgICAgICAgICAgICBjdXJDaGlsZCA9IG9wdGdyb3VwLm5leHRTaWJsaW5nO1xuICAgICAgICAgICAgICAgICAgICAgICAgb3B0Z3JvdXAgPSBudWxsO1xuICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICBmcm9tRWwuc2VsZWN0ZWRJbmRleCA9IHNlbGVjdGVkSW5kZXg7XG4gICAgICAgIH1cbiAgICB9XG59O1xuXG52YXIgRUxFTUVOVF9OT0RFID0gMTtcbnZhciBET0NVTUVOVF9GUkFHTUVOVF9OT0RFJDEgPSAxMTtcbnZhciBURVhUX05PREUgPSAzO1xudmFyIENPTU1FTlRfTk9ERSA9IDg7XG5cbmZ1bmN0aW9uIG5vb3AoKSB7fVxuXG5mdW5jdGlvbiBkZWZhdWx0R2V0Tm9kZUtleShub2RlKSB7XG4gIGlmIChub2RlKSB7XG4gICAgcmV0dXJuIChub2RlLmdldEF0dHJpYnV0ZSAmJiBub2RlLmdldEF0dHJpYnV0ZSgnaWQnKSkgfHwgbm9kZS5pZDtcbiAgfVxufVxuXG5mdW5jdGlvbiBtb3JwaGRvbUZhY3RvcnkobW9ycGhBdHRycykge1xuXG4gIHJldHVybiBmdW5jdGlvbiBtb3JwaGRvbShmcm9tTm9kZSwgdG9Ob2RlLCBvcHRpb25zKSB7XG4gICAgaWYgKCFvcHRpb25zKSB7XG4gICAgICBvcHRpb25zID0ge307XG4gICAgfVxuXG4gICAgaWYgKHR5cGVvZiB0b05vZGUgPT09ICdzdHJpbmcnKSB7XG4gICAgICBpZiAoZnJvbU5vZGUubm9kZU5hbWUgPT09ICcjZG9jdW1lbnQnIHx8IGZyb21Ob2RlLm5vZGVOYW1lID09PSAnSFRNTCcgfHwgZnJvbU5vZGUubm9kZU5hbWUgPT09ICdCT0RZJykge1xuICAgICAgICB2YXIgdG9Ob2RlSHRtbCA9IHRvTm9kZTtcbiAgICAgICAgdG9Ob2RlID0gZG9jLmNyZWF0ZUVsZW1lbnQoJ2h0bWwnKTtcbiAgICAgICAgdG9Ob2RlLmlubmVySFRNTCA9IHRvTm9kZUh0bWw7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0b05vZGUgPSB0b0VsZW1lbnQodG9Ob2RlKTtcbiAgICAgIH1cbiAgICB9IGVsc2UgaWYgKHRvTm9kZS5ub2RlVHlwZSA9PT0gRE9DVU1FTlRfRlJBR01FTlRfTk9ERSQxKSB7XG4gICAgICB0b05vZGUgPSB0b05vZGUuZmlyc3RFbGVtZW50Q2hpbGQ7XG4gICAgfVxuXG4gICAgdmFyIGdldE5vZGVLZXkgPSBvcHRpb25zLmdldE5vZGVLZXkgfHwgZGVmYXVsdEdldE5vZGVLZXk7XG4gICAgdmFyIG9uQmVmb3JlTm9kZUFkZGVkID0gb3B0aW9ucy5vbkJlZm9yZU5vZGVBZGRlZCB8fCBub29wO1xuICAgIHZhciBvbk5vZGVBZGRlZCA9IG9wdGlvbnMub25Ob2RlQWRkZWQgfHwgbm9vcDtcbiAgICB2YXIgb25CZWZvcmVFbFVwZGF0ZWQgPSBvcHRpb25zLm9uQmVmb3JlRWxVcGRhdGVkIHx8IG5vb3A7XG4gICAgdmFyIG9uRWxVcGRhdGVkID0gb3B0aW9ucy5vbkVsVXBkYXRlZCB8fCBub29wO1xuICAgIHZhciBvbkJlZm9yZU5vZGVEaXNjYXJkZWQgPSBvcHRpb25zLm9uQmVmb3JlTm9kZURpc2NhcmRlZCB8fCBub29wO1xuICAgIHZhciBvbk5vZGVEaXNjYXJkZWQgPSBvcHRpb25zLm9uTm9kZURpc2NhcmRlZCB8fCBub29wO1xuICAgIHZhciBvbkJlZm9yZUVsQ2hpbGRyZW5VcGRhdGVkID0gb3B0aW9ucy5vbkJlZm9yZUVsQ2hpbGRyZW5VcGRhdGVkIHx8IG5vb3A7XG4gICAgdmFyIHNraXBGcm9tQ2hpbGRyZW4gPSBvcHRpb25zLnNraXBGcm9tQ2hpbGRyZW4gfHwgbm9vcDtcbiAgICB2YXIgYWRkQ2hpbGQgPSBvcHRpb25zLmFkZENoaWxkIHx8IGZ1bmN0aW9uKHBhcmVudCwgY2hpbGQpeyByZXR1cm4gcGFyZW50LmFwcGVuZENoaWxkKGNoaWxkKTsgfTtcbiAgICB2YXIgY2hpbGRyZW5Pbmx5ID0gb3B0aW9ucy5jaGlsZHJlbk9ubHkgPT09IHRydWU7XG5cbiAgICAvLyBUaGlzIG9iamVjdCBpcyB1c2VkIGFzIGEgbG9va3VwIHRvIHF1aWNrbHkgZmluZCBhbGwga2V5ZWQgZWxlbWVudHMgaW4gdGhlIG9yaWdpbmFsIERPTSB0cmVlLlxuICAgIHZhciBmcm9tTm9kZXNMb29rdXAgPSBPYmplY3QuY3JlYXRlKG51bGwpO1xuICAgIHZhciBrZXllZFJlbW92YWxMaXN0ID0gW107XG5cbiAgICBmdW5jdGlvbiBhZGRLZXllZFJlbW92YWwoa2V5KSB7XG4gICAgICBrZXllZFJlbW92YWxMaXN0LnB1c2goa2V5KTtcbiAgICB9XG5cbiAgICBmdW5jdGlvbiB3YWxrRGlzY2FyZGVkQ2hpbGROb2Rlcyhub2RlLCBza2lwS2V5ZWROb2Rlcykge1xuICAgICAgaWYgKG5vZGUubm9kZVR5cGUgPT09IEVMRU1FTlRfTk9ERSkge1xuICAgICAgICB2YXIgY3VyQ2hpbGQgPSBub2RlLmZpcnN0Q2hpbGQ7XG4gICAgICAgIHdoaWxlIChjdXJDaGlsZCkge1xuXG4gICAgICAgICAgdmFyIGtleSA9IHVuZGVmaW5lZDtcblxuICAgICAgICAgIGlmIChza2lwS2V5ZWROb2RlcyAmJiAoa2V5ID0gZ2V0Tm9kZUtleShjdXJDaGlsZCkpKSB7XG4gICAgICAgICAgICAvLyBJZiB3ZSBhcmUgc2tpcHBpbmcga2V5ZWQgbm9kZXMgdGhlbiB3ZSBhZGQgdGhlIGtleVxuICAgICAgICAgICAgLy8gdG8gYSBsaXN0IHNvIHRoYXQgaXQgY2FuIGJlIGhhbmRsZWQgYXQgdGhlIHZlcnkgZW5kLlxuICAgICAgICAgICAgYWRkS2V5ZWRSZW1vdmFsKGtleSk7XG4gICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgIC8vIE9ubHkgcmVwb3J0IHRoZSBub2RlIGFzIGRpc2NhcmRlZCBpZiBpdCBpcyBub3Qga2V5ZWQuIFdlIGRvIHRoaXMgYmVjYXVzZVxuICAgICAgICAgICAgLy8gYXQgdGhlIGVuZCB3ZSBsb29wIHRocm91Z2ggYWxsIGtleWVkIGVsZW1lbnRzIHRoYXQgd2VyZSB1bm1hdGNoZWRcbiAgICAgICAgICAgIC8vIGFuZCB0aGVuIGRpc2NhcmQgdGhlbSBpbiBvbmUgZmluYWwgcGFzcy5cbiAgICAgICAgICAgIG9uTm9kZURpc2NhcmRlZChjdXJDaGlsZCk7XG4gICAgICAgICAgICBpZiAoY3VyQ2hpbGQuZmlyc3RDaGlsZCkge1xuICAgICAgICAgICAgICB3YWxrRGlzY2FyZGVkQ2hpbGROb2RlcyhjdXJDaGlsZCwgc2tpcEtleWVkTm9kZXMpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cblxuICAgICAgICAgIGN1ckNoaWxkID0gY3VyQ2hpbGQubmV4dFNpYmxpbmc7XG4gICAgICAgIH1cbiAgICAgIH1cbiAgICB9XG5cbiAgICAvKipcbiAgICAqIFJlbW92ZXMgYSBET00gbm9kZSBvdXQgb2YgdGhlIG9yaWdpbmFsIERPTVxuICAgICpcbiAgICAqIEBwYXJhbSAge05vZGV9IG5vZGUgVGhlIG5vZGUgdG8gcmVtb3ZlXG4gICAgKiBAcGFyYW0gIHtOb2RlfSBwYXJlbnROb2RlIFRoZSBub2RlcyBwYXJlbnRcbiAgICAqIEBwYXJhbSAge0Jvb2xlYW59IHNraXBLZXllZE5vZGVzIElmIHRydWUgdGhlbiBlbGVtZW50cyB3aXRoIGtleXMgd2lsbCBiZSBza2lwcGVkIGFuZCBub3QgZGlzY2FyZGVkLlxuICAgICogQHJldHVybiB7dW5kZWZpbmVkfVxuICAgICovXG4gICAgZnVuY3Rpb24gcmVtb3ZlTm9kZShub2RlLCBwYXJlbnROb2RlLCBza2lwS2V5ZWROb2Rlcykge1xuICAgICAgaWYgKG9uQmVmb3JlTm9kZURpc2NhcmRlZChub2RlKSA9PT0gZmFsc2UpIHtcbiAgICAgICAgcmV0dXJuO1xuICAgICAgfVxuXG4gICAgICBpZiAocGFyZW50Tm9kZSkge1xuICAgICAgICBwYXJlbnROb2RlLnJlbW92ZUNoaWxkKG5vZGUpO1xuICAgICAgfVxuXG4gICAgICBvbk5vZGVEaXNjYXJkZWQobm9kZSk7XG4gICAgICB3YWxrRGlzY2FyZGVkQ2hpbGROb2Rlcyhub2RlLCBza2lwS2V5ZWROb2Rlcyk7XG4gICAgfVxuXG4gICAgLy8gLy8gVHJlZVdhbGtlciBpbXBsZW1lbnRhdGlvbiBpcyBubyBmYXN0ZXIsIGJ1dCBrZWVwaW5nIHRoaXMgYXJvdW5kIGluIGNhc2UgdGhpcyBjaGFuZ2VzIGluIHRoZSBmdXR1cmVcbiAgICAvLyBmdW5jdGlvbiBpbmRleFRyZWUocm9vdCkge1xuICAgIC8vICAgICB2YXIgdHJlZVdhbGtlciA9IGRvY3VtZW50LmNyZWF0ZVRyZWVXYWxrZXIoXG4gICAgLy8gICAgICAgICByb290LFxuICAgIC8vICAgICAgICAgTm9kZUZpbHRlci5TSE9XX0VMRU1FTlQpO1xuICAgIC8vXG4gICAgLy8gICAgIHZhciBlbDtcbiAgICAvLyAgICAgd2hpbGUoKGVsID0gdHJlZVdhbGtlci5uZXh0Tm9kZSgpKSkge1xuICAgIC8vICAgICAgICAgdmFyIGtleSA9IGdldE5vZGVLZXkoZWwpO1xuICAgIC8vICAgICAgICAgaWYgKGtleSkge1xuICAgIC8vICAgICAgICAgICAgIGZyb21Ob2Rlc0xvb2t1cFtrZXldID0gZWw7XG4gICAgLy8gICAgICAgICB9XG4gICAgLy8gICAgIH1cbiAgICAvLyB9XG5cbiAgICAvLyAvLyBOb2RlSXRlcmF0b3IgaW1wbGVtZW50YXRpb24gaXMgbm8gZmFzdGVyLCBidXQga2VlcGluZyB0aGlzIGFyb3VuZCBpbiBjYXNlIHRoaXMgY2hhbmdlcyBpbiB0aGUgZnV0dXJlXG4gICAgLy9cbiAgICAvLyBmdW5jdGlvbiBpbmRleFRyZWUobm9kZSkge1xuICAgIC8vICAgICB2YXIgbm9kZUl0ZXJhdG9yID0gZG9jdW1lbnQuY3JlYXRlTm9kZUl0ZXJhdG9yKG5vZGUsIE5vZGVGaWx0ZXIuU0hPV19FTEVNRU5UKTtcbiAgICAvLyAgICAgdmFyIGVsO1xuICAgIC8vICAgICB3aGlsZSgoZWwgPSBub2RlSXRlcmF0b3IubmV4dE5vZGUoKSkpIHtcbiAgICAvLyAgICAgICAgIHZhciBrZXkgPSBnZXROb2RlS2V5KGVsKTtcbiAgICAvLyAgICAgICAgIGlmIChrZXkpIHtcbiAgICAvLyAgICAgICAgICAgICBmcm9tTm9kZXNMb29rdXBba2V5XSA9IGVsO1xuICAgIC8vICAgICAgICAgfVxuICAgIC8vICAgICB9XG4gICAgLy8gfVxuXG4gICAgZnVuY3Rpb24gaW5kZXhUcmVlKG5vZGUpIHtcbiAgICAgIGlmIChub2RlLm5vZGVUeXBlID09PSBFTEVNRU5UX05PREUgfHwgbm9kZS5ub2RlVHlwZSA9PT0gRE9DVU1FTlRfRlJBR01FTlRfTk9ERSQxKSB7XG4gICAgICAgIHZhciBjdXJDaGlsZCA9IG5vZGUuZmlyc3RDaGlsZDtcbiAgICAgICAgd2hpbGUgKGN1ckNoaWxkKSB7XG4gICAgICAgICAgdmFyIGtleSA9IGdldE5vZGVLZXkoY3VyQ2hpbGQpO1xuICAgICAgICAgIGlmIChrZXkpIHtcbiAgICAgICAgICAgIGZyb21Ob2Rlc0xvb2t1cFtrZXldID0gY3VyQ2hpbGQ7XG4gICAgICAgICAgfVxuXG4gICAgICAgICAgLy8gV2FsayByZWN1cnNpdmVseVxuICAgICAgICAgIGluZGV4VHJlZShjdXJDaGlsZCk7XG5cbiAgICAgICAgICBjdXJDaGlsZCA9IGN1ckNoaWxkLm5leHRTaWJsaW5nO1xuICAgICAgICB9XG4gICAgICB9XG4gICAgfVxuXG4gICAgaW5kZXhUcmVlKGZyb21Ob2RlKTtcblxuICAgIGZ1bmN0aW9uIGhhbmRsZU5vZGVBZGRlZChlbCkge1xuICAgICAgb25Ob2RlQWRkZWQoZWwpO1xuXG4gICAgICB2YXIgY3VyQ2hpbGQgPSBlbC5maXJzdENoaWxkO1xuICAgICAgd2hpbGUgKGN1ckNoaWxkKSB7XG4gICAgICAgIHZhciBuZXh0U2libGluZyA9IGN1ckNoaWxkLm5leHRTaWJsaW5nO1xuXG4gICAgICAgIHZhciBrZXkgPSBnZXROb2RlS2V5KGN1ckNoaWxkKTtcbiAgICAgICAgaWYgKGtleSkge1xuICAgICAgICAgIHZhciB1bm1hdGNoZWRGcm9tRWwgPSBmcm9tTm9kZXNMb29rdXBba2V5XTtcbiAgICAgICAgICAvLyBpZiB3ZSBmaW5kIGEgZHVwbGljYXRlICNpZCBub2RlIGluIGNhY2hlLCByZXBsYWNlIGBlbGAgd2l0aCBjYWNoZSB2YWx1ZVxuICAgICAgICAgIC8vIGFuZCBtb3JwaCBpdCB0byB0aGUgY2hpbGQgbm9kZS5cbiAgICAgICAgICBpZiAodW5tYXRjaGVkRnJvbUVsICYmIGNvbXBhcmVOb2RlTmFtZXMoY3VyQ2hpbGQsIHVubWF0Y2hlZEZyb21FbCkpIHtcbiAgICAgICAgICAgIGN1ckNoaWxkLnBhcmVudE5vZGUucmVwbGFjZUNoaWxkKHVubWF0Y2hlZEZyb21FbCwgY3VyQ2hpbGQpO1xuICAgICAgICAgICAgbW9ycGhFbCh1bm1hdGNoZWRGcm9tRWwsIGN1ckNoaWxkKTtcbiAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgaGFuZGxlTm9kZUFkZGVkKGN1ckNoaWxkKTtcbiAgICAgICAgICB9XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgLy8gcmVjdXJzaXZlbHkgY2FsbCBmb3IgY3VyQ2hpbGQgYW5kIGl0J3MgY2hpbGRyZW4gdG8gc2VlIGlmIHdlIGZpbmQgc29tZXRoaW5nIGluXG4gICAgICAgICAgLy8gZnJvbU5vZGVzTG9va3VwXG4gICAgICAgICAgaGFuZGxlTm9kZUFkZGVkKGN1ckNoaWxkKTtcbiAgICAgICAgfVxuXG4gICAgICAgIGN1ckNoaWxkID0gbmV4dFNpYmxpbmc7XG4gICAgICB9XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gY2xlYW51cEZyb21FbChmcm9tRWwsIGN1ckZyb21Ob2RlQ2hpbGQsIGN1ckZyb21Ob2RlS2V5KSB7XG4gICAgICAvLyBXZSBoYXZlIHByb2Nlc3NlZCBhbGwgb2YgdGhlIFwidG8gbm9kZXNcIi4gSWYgY3VyRnJvbU5vZGVDaGlsZCBpc1xuICAgICAgLy8gbm9uLW51bGwgdGhlbiB3ZSBzdGlsbCBoYXZlIHNvbWUgZnJvbSBub2RlcyBsZWZ0IG92ZXIgdGhhdCBuZWVkXG4gICAgICAvLyB0byBiZSByZW1vdmVkXG4gICAgICB3aGlsZSAoY3VyRnJvbU5vZGVDaGlsZCkge1xuICAgICAgICB2YXIgZnJvbU5leHRTaWJsaW5nID0gY3VyRnJvbU5vZGVDaGlsZC5uZXh0U2libGluZztcbiAgICAgICAgaWYgKChjdXJGcm9tTm9kZUtleSA9IGdldE5vZGVLZXkoY3VyRnJvbU5vZGVDaGlsZCkpKSB7XG4gICAgICAgICAgLy8gU2luY2UgdGhlIG5vZGUgaXMga2V5ZWQgaXQgbWlnaHQgYmUgbWF0Y2hlZCB1cCBsYXRlciBzbyB3ZSBkZWZlclxuICAgICAgICAgIC8vIHRoZSBhY3R1YWwgcmVtb3ZhbCB0byBsYXRlclxuICAgICAgICAgIGFkZEtleWVkUmVtb3ZhbChjdXJGcm9tTm9kZUtleSk7XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgLy8gTk9URTogd2Ugc2tpcCBuZXN0ZWQga2V5ZWQgbm9kZXMgZnJvbSBiZWluZyByZW1vdmVkIHNpbmNlIHRoZXJlIGlzXG4gICAgICAgICAgLy8gICAgICAgc3RpbGwgYSBjaGFuY2UgdGhleSB3aWxsIGJlIG1hdGNoZWQgdXAgbGF0ZXJcbiAgICAgICAgICByZW1vdmVOb2RlKGN1ckZyb21Ob2RlQ2hpbGQsIGZyb21FbCwgdHJ1ZSAvKiBza2lwIGtleWVkIG5vZGVzICovKTtcbiAgICAgICAgfVxuICAgICAgICBjdXJGcm9tTm9kZUNoaWxkID0gZnJvbU5leHRTaWJsaW5nO1xuICAgICAgfVxuICAgIH1cblxuICAgIGZ1bmN0aW9uIG1vcnBoRWwoZnJvbUVsLCB0b0VsLCBjaGlsZHJlbk9ubHkpIHtcbiAgICAgIHZhciB0b0VsS2V5ID0gZ2V0Tm9kZUtleSh0b0VsKTtcblxuICAgICAgaWYgKHRvRWxLZXkpIHtcbiAgICAgICAgLy8gSWYgYW4gZWxlbWVudCB3aXRoIGFuIElEIGlzIGJlaW5nIG1vcnBoZWQgdGhlbiBpdCB3aWxsIGJlIGluIHRoZSBmaW5hbFxuICAgICAgICAvLyBET00gc28gY2xlYXIgaXQgb3V0IG9mIHRoZSBzYXZlZCBlbGVtZW50cyBjb2xsZWN0aW9uXG4gICAgICAgIGRlbGV0ZSBmcm9tTm9kZXNMb29rdXBbdG9FbEtleV07XG4gICAgICB9XG5cbiAgICAgIGlmICghY2hpbGRyZW5Pbmx5KSB7XG4gICAgICAgIC8vIG9wdGlvbmFsXG4gICAgICAgIGlmIChvbkJlZm9yZUVsVXBkYXRlZChmcm9tRWwsIHRvRWwpID09PSBmYWxzZSkge1xuICAgICAgICAgIHJldHVybjtcbiAgICAgICAgfVxuXG4gICAgICAgIC8vIHVwZGF0ZSBhdHRyaWJ1dGVzIG9uIG9yaWdpbmFsIERPTSBlbGVtZW50IGZpcnN0XG4gICAgICAgIG1vcnBoQXR0cnMoZnJvbUVsLCB0b0VsKTtcbiAgICAgICAgLy8gb3B0aW9uYWxcbiAgICAgICAgb25FbFVwZGF0ZWQoZnJvbUVsKTtcblxuICAgICAgICBpZiAob25CZWZvcmVFbENoaWxkcmVuVXBkYXRlZChmcm9tRWwsIHRvRWwpID09PSBmYWxzZSkge1xuICAgICAgICAgIHJldHVybjtcbiAgICAgICAgfVxuICAgICAgfVxuXG4gICAgICBpZiAoZnJvbUVsLm5vZGVOYW1lICE9PSAnVEVYVEFSRUEnKSB7XG4gICAgICAgIG1vcnBoQ2hpbGRyZW4oZnJvbUVsLCB0b0VsKTtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHNwZWNpYWxFbEhhbmRsZXJzLlRFWFRBUkVBKGZyb21FbCwgdG9FbCk7XG4gICAgICB9XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gbW9ycGhDaGlsZHJlbihmcm9tRWwsIHRvRWwpIHtcbiAgICAgIHZhciBza2lwRnJvbSA9IHNraXBGcm9tQ2hpbGRyZW4oZnJvbUVsKTtcbiAgICAgIHZhciBjdXJUb05vZGVDaGlsZCA9IHRvRWwuZmlyc3RDaGlsZDtcbiAgICAgIHZhciBjdXJGcm9tTm9kZUNoaWxkID0gZnJvbUVsLmZpcnN0Q2hpbGQ7XG4gICAgICB2YXIgY3VyVG9Ob2RlS2V5O1xuICAgICAgdmFyIGN1ckZyb21Ob2RlS2V5O1xuXG4gICAgICB2YXIgZnJvbU5leHRTaWJsaW5nO1xuICAgICAgdmFyIHRvTmV4dFNpYmxpbmc7XG4gICAgICB2YXIgbWF0Y2hpbmdGcm9tRWw7XG5cbiAgICAgIC8vIHdhbGsgdGhlIGNoaWxkcmVuXG4gICAgICBvdXRlcjogd2hpbGUgKGN1clRvTm9kZUNoaWxkKSB7XG4gICAgICAgIHRvTmV4dFNpYmxpbmcgPSBjdXJUb05vZGVDaGlsZC5uZXh0U2libGluZztcbiAgICAgICAgY3VyVG9Ob2RlS2V5ID0gZ2V0Tm9kZUtleShjdXJUb05vZGVDaGlsZCk7XG5cbiAgICAgICAgLy8gd2FsayB0aGUgZnJvbU5vZGUgY2hpbGRyZW4gYWxsIHRoZSB3YXkgdGhyb3VnaFxuICAgICAgICB3aGlsZSAoIXNraXBGcm9tICYmIGN1ckZyb21Ob2RlQ2hpbGQpIHtcbiAgICAgICAgICBmcm9tTmV4dFNpYmxpbmcgPSBjdXJGcm9tTm9kZUNoaWxkLm5leHRTaWJsaW5nO1xuXG4gICAgICAgICAgaWYgKGN1clRvTm9kZUNoaWxkLmlzU2FtZU5vZGUgJiYgY3VyVG9Ob2RlQ2hpbGQuaXNTYW1lTm9kZShjdXJGcm9tTm9kZUNoaWxkKSkge1xuICAgICAgICAgICAgY3VyVG9Ob2RlQ2hpbGQgPSB0b05leHRTaWJsaW5nO1xuICAgICAgICAgICAgY3VyRnJvbU5vZGVDaGlsZCA9IGZyb21OZXh0U2libGluZztcbiAgICAgICAgICAgIGNvbnRpbnVlIG91dGVyO1xuICAgICAgICAgIH1cblxuICAgICAgICAgIGN1ckZyb21Ob2RlS2V5ID0gZ2V0Tm9kZUtleShjdXJGcm9tTm9kZUNoaWxkKTtcblxuICAgICAgICAgIHZhciBjdXJGcm9tTm9kZVR5cGUgPSBjdXJGcm9tTm9kZUNoaWxkLm5vZGVUeXBlO1xuXG4gICAgICAgICAgLy8gdGhpcyBtZWFucyBpZiB0aGUgY3VyRnJvbU5vZGVDaGlsZCBkb2VzbnQgaGF2ZSBhIG1hdGNoIHdpdGggdGhlIGN1clRvTm9kZUNoaWxkXG4gICAgICAgICAgdmFyIGlzQ29tcGF0aWJsZSA9IHVuZGVmaW5lZDtcblxuICAgICAgICAgIGlmIChjdXJGcm9tTm9kZVR5cGUgPT09IGN1clRvTm9kZUNoaWxkLm5vZGVUeXBlKSB7XG4gICAgICAgICAgICBpZiAoY3VyRnJvbU5vZGVUeXBlID09PSBFTEVNRU5UX05PREUpIHtcbiAgICAgICAgICAgICAgLy8gQm90aCBub2RlcyBiZWluZyBjb21wYXJlZCBhcmUgRWxlbWVudCBub2Rlc1xuXG4gICAgICAgICAgICAgIGlmIChjdXJUb05vZGVLZXkpIHtcbiAgICAgICAgICAgICAgICAvLyBUaGUgdGFyZ2V0IG5vZGUgaGFzIGEga2V5IHNvIHdlIHdhbnQgdG8gbWF0Y2ggaXQgdXAgd2l0aCB0aGUgY29ycmVjdCBlbGVtZW50XG4gICAgICAgICAgICAgICAgLy8gaW4gdGhlIG9yaWdpbmFsIERPTSB0cmVlXG4gICAgICAgICAgICAgICAgaWYgKGN1clRvTm9kZUtleSAhPT0gY3VyRnJvbU5vZGVLZXkpIHtcbiAgICAgICAgICAgICAgICAgIC8vIFRoZSBjdXJyZW50IGVsZW1lbnQgaW4gdGhlIG9yaWdpbmFsIERPTSB0cmVlIGRvZXMgbm90IGhhdmUgYSBtYXRjaGluZyBrZXkgc29cbiAgICAgICAgICAgICAgICAgIC8vIGxldCdzIGNoZWNrIG91ciBsb29rdXAgdG8gc2VlIGlmIHRoZXJlIGlzIGEgbWF0Y2hpbmcgZWxlbWVudCBpbiB0aGUgb3JpZ2luYWxcbiAgICAgICAgICAgICAgICAgIC8vIERPTSB0cmVlXG4gICAgICAgICAgICAgICAgICBpZiAoKG1hdGNoaW5nRnJvbUVsID0gZnJvbU5vZGVzTG9va3VwW2N1clRvTm9kZUtleV0pKSB7XG4gICAgICAgICAgICAgICAgICAgIGlmIChmcm9tTmV4dFNpYmxpbmcgPT09IG1hdGNoaW5nRnJvbUVsKSB7XG4gICAgICAgICAgICAgICAgICAgICAgLy8gU3BlY2lhbCBjYXNlIGZvciBzaW5nbGUgZWxlbWVudCByZW1vdmFscy4gVG8gYXZvaWQgcmVtb3ZpbmcgdGhlIG9yaWdpbmFsXG4gICAgICAgICAgICAgICAgICAgICAgLy8gRE9NIG5vZGUgb3V0IG9mIHRoZSB0cmVlIChzaW5jZSB0aGF0IGNhbiBicmVhayBDU1MgdHJhbnNpdGlvbnMsIGV0Yy4pLFxuICAgICAgICAgICAgICAgICAgICAgIC8vIHdlIHdpbGwgaW5zdGVhZCBkaXNjYXJkIHRoZSBjdXJyZW50IG5vZGUgYW5kIHdhaXQgdW50aWwgdGhlIG5leHRcbiAgICAgICAgICAgICAgICAgICAgICAvLyBpdGVyYXRpb24gdG8gcHJvcGVybHkgbWF0Y2ggdXAgdGhlIGtleWVkIHRhcmdldCBlbGVtZW50IHdpdGggaXRzIG1hdGNoaW5nXG4gICAgICAgICAgICAgICAgICAgICAgLy8gZWxlbWVudCBpbiB0aGUgb3JpZ2luYWwgdHJlZVxuICAgICAgICAgICAgICAgICAgICAgIGlzQ29tcGF0aWJsZSA9IGZhbHNlO1xuICAgICAgICAgICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICAgICAgICAgIC8vIFdlIGZvdW5kIGEgbWF0Y2hpbmcga2V5ZWQgZWxlbWVudCBzb21ld2hlcmUgaW4gdGhlIG9yaWdpbmFsIERPTSB0cmVlLlxuICAgICAgICAgICAgICAgICAgICAgIC8vIExldCdzIG1vdmUgdGhlIG9yaWdpbmFsIERPTSBub2RlIGludG8gdGhlIGN1cnJlbnQgcG9zaXRpb24gYW5kIG1vcnBoXG4gICAgICAgICAgICAgICAgICAgICAgLy8gaXQuXG5cbiAgICAgICAgICAgICAgICAgICAgICAvLyBOT1RFOiBXZSB1c2UgaW5zZXJ0QmVmb3JlIGluc3RlYWQgb2YgcmVwbGFjZUNoaWxkIGJlY2F1c2Ugd2Ugd2FudCB0byBnbyB0aHJvdWdoXG4gICAgICAgICAgICAgICAgICAgICAgLy8gdGhlIGByZW1vdmVOb2RlKClgIGZ1bmN0aW9uIGZvciB0aGUgbm9kZSB0aGF0IGlzIGJlaW5nIGRpc2NhcmRlZCBzbyB0aGF0XG4gICAgICAgICAgICAgICAgICAgICAgLy8gYWxsIGxpZmVjeWNsZSBob29rcyBhcmUgY29ycmVjdGx5IGludm9rZWRcbiAgICAgICAgICAgICAgICAgICAgICBmcm9tRWwuaW5zZXJ0QmVmb3JlKG1hdGNoaW5nRnJvbUVsLCBjdXJGcm9tTm9kZUNoaWxkKTtcblxuICAgICAgICAgICAgICAgICAgICAgIC8vIGZyb21OZXh0U2libGluZyA9IGN1ckZyb21Ob2RlQ2hpbGQubmV4dFNpYmxpbmc7XG5cbiAgICAgICAgICAgICAgICAgICAgICBpZiAoY3VyRnJvbU5vZGVLZXkpIHtcbiAgICAgICAgICAgICAgICAgICAgICAgIC8vIFNpbmNlIHRoZSBub2RlIGlzIGtleWVkIGl0IG1pZ2h0IGJlIG1hdGNoZWQgdXAgbGF0ZXIgc28gd2UgZGVmZXJcbiAgICAgICAgICAgICAgICAgICAgICAgIC8vIHRoZSBhY3R1YWwgcmVtb3ZhbCB0byBsYXRlclxuICAgICAgICAgICAgICAgICAgICAgICAgYWRkS2V5ZWRSZW1vdmFsKGN1ckZyb21Ob2RlS2V5KTtcbiAgICAgICAgICAgICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICAgICAgICAgICAgLy8gTk9URTogd2Ugc2tpcCBuZXN0ZWQga2V5ZWQgbm9kZXMgZnJvbSBiZWluZyByZW1vdmVkIHNpbmNlIHRoZXJlIGlzXG4gICAgICAgICAgICAgICAgICAgICAgICAvLyAgICAgICBzdGlsbCBhIGNoYW5jZSB0aGV5IHdpbGwgYmUgbWF0Y2hlZCB1cCBsYXRlclxuICAgICAgICAgICAgICAgICAgICAgICAgcmVtb3ZlTm9kZShjdXJGcm9tTm9kZUNoaWxkLCBmcm9tRWwsIHRydWUgLyogc2tpcCBrZXllZCBub2RlcyAqLyk7XG4gICAgICAgICAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgICAgICAgICAgY3VyRnJvbU5vZGVDaGlsZCA9IG1hdGNoaW5nRnJvbUVsO1xuICAgICAgICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgICAgICAgICAvLyBUaGUgbm9kZXMgYXJlIG5vdCBjb21wYXRpYmxlIHNpbmNlIHRoZSBcInRvXCIgbm9kZSBoYXMgYSBrZXkgYW5kIHRoZXJlXG4gICAgICAgICAgICAgICAgICAgIC8vIGlzIG5vIG1hdGNoaW5nIGtleWVkIG5vZGUgaW4gdGhlIHNvdXJjZSB0cmVlXG4gICAgICAgICAgICAgICAgICAgIGlzQ29tcGF0aWJsZSA9IGZhbHNlO1xuICAgICAgICAgICAgICAgICAgfVxuICAgICAgICAgICAgICAgIH1cbiAgICAgICAgICAgICAgfSBlbHNlIGlmIChjdXJGcm9tTm9kZUtleSkge1xuICAgICAgICAgICAgICAgIC8vIFRoZSBvcmlnaW5hbCBoYXMgYSBrZXlcbiAgICAgICAgICAgICAgICBpc0NvbXBhdGlibGUgPSBmYWxzZTtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICAgIGlzQ29tcGF0aWJsZSA9IGlzQ29tcGF0aWJsZSAhPT0gZmFsc2UgJiYgY29tcGFyZU5vZGVOYW1lcyhjdXJGcm9tTm9kZUNoaWxkLCBjdXJUb05vZGVDaGlsZCk7XG4gICAgICAgICAgICAgIGlmIChpc0NvbXBhdGlibGUpIHtcbiAgICAgICAgICAgICAgICAvLyBXZSBmb3VuZCBjb21wYXRpYmxlIERPTSBlbGVtZW50cyBzbyB0cmFuc2Zvcm1cbiAgICAgICAgICAgICAgICAvLyB0aGUgY3VycmVudCBcImZyb21cIiBub2RlIHRvIG1hdGNoIHRoZSBjdXJyZW50XG4gICAgICAgICAgICAgICAgLy8gdGFyZ2V0IERPTSBub2RlLlxuICAgICAgICAgICAgICAgIC8vIE1PUlBIXG4gICAgICAgICAgICAgICAgbW9ycGhFbChjdXJGcm9tTm9kZUNoaWxkLCBjdXJUb05vZGVDaGlsZCk7XG4gICAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgfSBlbHNlIGlmIChjdXJGcm9tTm9kZVR5cGUgPT09IFRFWFRfTk9ERSB8fCBjdXJGcm9tTm9kZVR5cGUgPT0gQ09NTUVOVF9OT0RFKSB7XG4gICAgICAgICAgICAgIC8vIEJvdGggbm9kZXMgYmVpbmcgY29tcGFyZWQgYXJlIFRleHQgb3IgQ29tbWVudCBub2Rlc1xuICAgICAgICAgICAgICBpc0NvbXBhdGlibGUgPSB0cnVlO1xuICAgICAgICAgICAgICAvLyBTaW1wbHkgdXBkYXRlIG5vZGVWYWx1ZSBvbiB0aGUgb3JpZ2luYWwgbm9kZSB0b1xuICAgICAgICAgICAgICAvLyBjaGFuZ2UgdGhlIHRleHQgdmFsdWVcbiAgICAgICAgICAgICAgaWYgKGN1ckZyb21Ob2RlQ2hpbGQubm9kZVZhbHVlICE9PSBjdXJUb05vZGVDaGlsZC5ub2RlVmFsdWUpIHtcbiAgICAgICAgICAgICAgICBjdXJGcm9tTm9kZUNoaWxkLm5vZGVWYWx1ZSA9IGN1clRvTm9kZUNoaWxkLm5vZGVWYWx1ZTtcbiAgICAgICAgICAgICAgfVxuXG4gICAgICAgICAgICB9XG4gICAgICAgICAgfVxuXG4gICAgICAgICAgaWYgKGlzQ29tcGF0aWJsZSkge1xuICAgICAgICAgICAgLy8gQWR2YW5jZSBib3RoIHRoZSBcInRvXCIgY2hpbGQgYW5kIHRoZSBcImZyb21cIiBjaGlsZCBzaW5jZSB3ZSBmb3VuZCBhIG1hdGNoXG4gICAgICAgICAgICAvLyBOb3RoaW5nIGVsc2UgdG8gZG8gYXMgd2UgYWxyZWFkeSByZWN1cnNpdmVseSBjYWxsZWQgbW9ycGhDaGlsZHJlbiBhYm92ZVxuICAgICAgICAgICAgY3VyVG9Ob2RlQ2hpbGQgPSB0b05leHRTaWJsaW5nO1xuICAgICAgICAgICAgY3VyRnJvbU5vZGVDaGlsZCA9IGZyb21OZXh0U2libGluZztcbiAgICAgICAgICAgIGNvbnRpbnVlIG91dGVyO1xuICAgICAgICAgIH1cblxuICAgICAgICAgIC8vIE5vIGNvbXBhdGlibGUgbWF0Y2ggc28gcmVtb3ZlIHRoZSBvbGQgbm9kZSBmcm9tIHRoZSBET00gYW5kIGNvbnRpbnVlIHRyeWluZyB0byBmaW5kIGFcbiAgICAgICAgICAvLyBtYXRjaCBpbiB0aGUgb3JpZ2luYWwgRE9NLiBIb3dldmVyLCB3ZSBvbmx5IGRvIHRoaXMgaWYgdGhlIGZyb20gbm9kZSBpcyBub3Qga2V5ZWRcbiAgICAgICAgICAvLyBzaW5jZSBpdCBpcyBwb3NzaWJsZSB0aGF0IGEga2V5ZWQgbm9kZSBtaWdodCBtYXRjaCB1cCB3aXRoIGEgbm9kZSBzb21ld2hlcmUgZWxzZSBpbiB0aGVcbiAgICAgICAgICAvLyB0YXJnZXQgdHJlZSBhbmQgd2UgZG9uJ3Qgd2FudCB0byBkaXNjYXJkIGl0IGp1c3QgeWV0IHNpbmNlIGl0IHN0aWxsIG1pZ2h0IGZpbmQgYVxuICAgICAgICAgIC8vIGhvbWUgaW4gdGhlIGZpbmFsIERPTSB0cmVlLiBBZnRlciBldmVyeXRoaW5nIGlzIGRvbmUgd2Ugd2lsbCByZW1vdmUgYW55IGtleWVkIG5vZGVzXG4gICAgICAgICAgLy8gdGhhdCBkaWRuJ3QgZmluZCBhIGhvbWVcbiAgICAgICAgICBpZiAoY3VyRnJvbU5vZGVLZXkpIHtcbiAgICAgICAgICAgIC8vIFNpbmNlIHRoZSBub2RlIGlzIGtleWVkIGl0IG1pZ2h0IGJlIG1hdGNoZWQgdXAgbGF0ZXIgc28gd2UgZGVmZXJcbiAgICAgICAgICAgIC8vIHRoZSBhY3R1YWwgcmVtb3ZhbCB0byBsYXRlclxuICAgICAgICAgICAgYWRkS2V5ZWRSZW1vdmFsKGN1ckZyb21Ob2RlS2V5KTtcbiAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgLy8gTk9URTogd2Ugc2tpcCBuZXN0ZWQga2V5ZWQgbm9kZXMgZnJvbSBiZWluZyByZW1vdmVkIHNpbmNlIHRoZXJlIGlzXG4gICAgICAgICAgICAvLyAgICAgICBzdGlsbCBhIGNoYW5jZSB0aGV5IHdpbGwgYmUgbWF0Y2hlZCB1cCBsYXRlclxuICAgICAgICAgICAgcmVtb3ZlTm9kZShjdXJGcm9tTm9kZUNoaWxkLCBmcm9tRWwsIHRydWUgLyogc2tpcCBrZXllZCBub2RlcyAqLyk7XG4gICAgICAgICAgfVxuXG4gICAgICAgICAgY3VyRnJvbU5vZGVDaGlsZCA9IGZyb21OZXh0U2libGluZztcbiAgICAgICAgfSAvLyBFTkQ6IHdoaWxlKGN1ckZyb21Ob2RlQ2hpbGQpIHt9XG5cbiAgICAgICAgLy8gSWYgd2UgZ290IHRoaXMgZmFyIHRoZW4gd2UgZGlkIG5vdCBmaW5kIGEgY2FuZGlkYXRlIG1hdGNoIGZvclxuICAgICAgICAvLyBvdXIgXCJ0byBub2RlXCIgYW5kIHdlIGV4aGF1c3RlZCBhbGwgb2YgdGhlIGNoaWxkcmVuIFwiZnJvbVwiXG4gICAgICAgIC8vIG5vZGVzLiBUaGVyZWZvcmUsIHdlIHdpbGwganVzdCBhcHBlbmQgdGhlIGN1cnJlbnQgXCJ0b1wiIG5vZGVcbiAgICAgICAgLy8gdG8gdGhlIGVuZFxuICAgICAgICBpZiAoY3VyVG9Ob2RlS2V5ICYmIChtYXRjaGluZ0Zyb21FbCA9IGZyb21Ob2Rlc0xvb2t1cFtjdXJUb05vZGVLZXldKSAmJiBjb21wYXJlTm9kZU5hbWVzKG1hdGNoaW5nRnJvbUVsLCBjdXJUb05vZGVDaGlsZCkpIHtcbiAgICAgICAgICAvLyBNT1JQSFxuICAgICAgICAgIGlmKCFza2lwRnJvbSl7IGFkZENoaWxkKGZyb21FbCwgbWF0Y2hpbmdGcm9tRWwpOyB9XG4gICAgICAgICAgbW9ycGhFbChtYXRjaGluZ0Zyb21FbCwgY3VyVG9Ob2RlQ2hpbGQpO1xuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIHZhciBvbkJlZm9yZU5vZGVBZGRlZFJlc3VsdCA9IG9uQmVmb3JlTm9kZUFkZGVkKGN1clRvTm9kZUNoaWxkKTtcbiAgICAgICAgICBpZiAob25CZWZvcmVOb2RlQWRkZWRSZXN1bHQgIT09IGZhbHNlKSB7XG4gICAgICAgICAgICBpZiAob25CZWZvcmVOb2RlQWRkZWRSZXN1bHQpIHtcbiAgICAgICAgICAgICAgY3VyVG9Ob2RlQ2hpbGQgPSBvbkJlZm9yZU5vZGVBZGRlZFJlc3VsdDtcbiAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgaWYgKGN1clRvTm9kZUNoaWxkLmFjdHVhbGl6ZSkge1xuICAgICAgICAgICAgICBjdXJUb05vZGVDaGlsZCA9IGN1clRvTm9kZUNoaWxkLmFjdHVhbGl6ZShmcm9tRWwub3duZXJEb2N1bWVudCB8fCBkb2MpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgYWRkQ2hpbGQoZnJvbUVsLCBjdXJUb05vZGVDaGlsZCk7XG4gICAgICAgICAgICBoYW5kbGVOb2RlQWRkZWQoY3VyVG9Ob2RlQ2hpbGQpO1xuICAgICAgICAgIH1cbiAgICAgICAgfVxuXG4gICAgICAgIGN1clRvTm9kZUNoaWxkID0gdG9OZXh0U2libGluZztcbiAgICAgICAgY3VyRnJvbU5vZGVDaGlsZCA9IGZyb21OZXh0U2libGluZztcbiAgICAgIH1cblxuICAgICAgY2xlYW51cEZyb21FbChmcm9tRWwsIGN1ckZyb21Ob2RlQ2hpbGQsIGN1ckZyb21Ob2RlS2V5KTtcblxuICAgICAgdmFyIHNwZWNpYWxFbEhhbmRsZXIgPSBzcGVjaWFsRWxIYW5kbGVyc1tmcm9tRWwubm9kZU5hbWVdO1xuICAgICAgaWYgKHNwZWNpYWxFbEhhbmRsZXIpIHtcbiAgICAgICAgc3BlY2lhbEVsSGFuZGxlcihmcm9tRWwsIHRvRWwpO1xuICAgICAgfVxuICAgIH0gLy8gRU5EOiBtb3JwaENoaWxkcmVuKC4uLilcblxuICAgIHZhciBtb3JwaGVkTm9kZSA9IGZyb21Ob2RlO1xuICAgIHZhciBtb3JwaGVkTm9kZVR5cGUgPSBtb3JwaGVkTm9kZS5ub2RlVHlwZTtcbiAgICB2YXIgdG9Ob2RlVHlwZSA9IHRvTm9kZS5ub2RlVHlwZTtcblxuICAgIGlmICghY2hpbGRyZW5Pbmx5KSB7XG4gICAgICAvLyBIYW5kbGUgdGhlIGNhc2Ugd2hlcmUgd2UgYXJlIGdpdmVuIHR3byBET00gbm9kZXMgdGhhdCBhcmUgbm90XG4gICAgICAvLyBjb21wYXRpYmxlIChlLmcuIDxkaXY+IC0tPiA8c3Bhbj4gb3IgPGRpdj4gLS0+IFRFWFQpXG4gICAgICBpZiAobW9ycGhlZE5vZGVUeXBlID09PSBFTEVNRU5UX05PREUpIHtcbiAgICAgICAgaWYgKHRvTm9kZVR5cGUgPT09IEVMRU1FTlRfTk9ERSkge1xuICAgICAgICAgIGlmICghY29tcGFyZU5vZGVOYW1lcyhmcm9tTm9kZSwgdG9Ob2RlKSkge1xuICAgICAgICAgICAgb25Ob2RlRGlzY2FyZGVkKGZyb21Ob2RlKTtcbiAgICAgICAgICAgIG1vcnBoZWROb2RlID0gbW92ZUNoaWxkcmVuKGZyb21Ob2RlLCBjcmVhdGVFbGVtZW50TlModG9Ob2RlLm5vZGVOYW1lLCB0b05vZGUubmFtZXNwYWNlVVJJKSk7XG4gICAgICAgICAgfVxuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIC8vIEdvaW5nIGZyb20gYW4gZWxlbWVudCBub2RlIHRvIGEgdGV4dCBub2RlXG4gICAgICAgICAgbW9ycGhlZE5vZGUgPSB0b05vZGU7XG4gICAgICAgIH1cbiAgICAgIH0gZWxzZSBpZiAobW9ycGhlZE5vZGVUeXBlID09PSBURVhUX05PREUgfHwgbW9ycGhlZE5vZGVUeXBlID09PSBDT01NRU5UX05PREUpIHsgLy8gVGV4dCBvciBjb21tZW50IG5vZGVcbiAgICAgICAgaWYgKHRvTm9kZVR5cGUgPT09IG1vcnBoZWROb2RlVHlwZSkge1xuICAgICAgICAgIGlmIChtb3JwaGVkTm9kZS5ub2RlVmFsdWUgIT09IHRvTm9kZS5ub2RlVmFsdWUpIHtcbiAgICAgICAgICAgIG1vcnBoZWROb2RlLm5vZGVWYWx1ZSA9IHRvTm9kZS5ub2RlVmFsdWU7XG4gICAgICAgICAgfVxuXG4gICAgICAgICAgcmV0dXJuIG1vcnBoZWROb2RlO1xuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIC8vIFRleHQgbm9kZSB0byBzb21ldGhpbmcgZWxzZVxuICAgICAgICAgIG1vcnBoZWROb2RlID0gdG9Ob2RlO1xuICAgICAgICB9XG4gICAgICB9XG4gICAgfVxuXG4gICAgaWYgKG1vcnBoZWROb2RlID09PSB0b05vZGUpIHtcbiAgICAgIC8vIFRoZSBcInRvIG5vZGVcIiB3YXMgbm90IGNvbXBhdGlibGUgd2l0aCB0aGUgXCJmcm9tIG5vZGVcIiBzbyB3ZSBoYWQgdG9cbiAgICAgIC8vIHRvc3Mgb3V0IHRoZSBcImZyb20gbm9kZVwiIGFuZCB1c2UgdGhlIFwidG8gbm9kZVwiXG4gICAgICBvbk5vZGVEaXNjYXJkZWQoZnJvbU5vZGUpO1xuICAgIH0gZWxzZSB7XG4gICAgICBpZiAodG9Ob2RlLmlzU2FtZU5vZGUgJiYgdG9Ob2RlLmlzU2FtZU5vZGUobW9ycGhlZE5vZGUpKSB7XG4gICAgICAgIHJldHVybjtcbiAgICAgIH1cblxuICAgICAgbW9ycGhFbChtb3JwaGVkTm9kZSwgdG9Ob2RlLCBjaGlsZHJlbk9ubHkpO1xuXG4gICAgICAvLyBXZSBub3cgbmVlZCB0byBsb29wIG92ZXIgYW55IGtleWVkIG5vZGVzIHRoYXQgbWlnaHQgbmVlZCB0byBiZVxuICAgICAgLy8gcmVtb3ZlZC4gV2Ugb25seSBkbyB0aGUgcmVtb3ZhbCBpZiB3ZSBrbm93IHRoYXQgdGhlIGtleWVkIG5vZGVcbiAgICAgIC8vIG5ldmVyIGZvdW5kIGEgbWF0Y2guIFdoZW4gYSBrZXllZCBub2RlIGlzIG1hdGNoZWQgdXAgd2UgcmVtb3ZlXG4gICAgICAvLyBpdCBvdXQgb2YgZnJvbU5vZGVzTG9va3VwIGFuZCB3ZSB1c2UgZnJvbU5vZGVzTG9va3VwIHRvIGRldGVybWluZVxuICAgICAgLy8gaWYgYSBrZXllZCBub2RlIGhhcyBiZWVuIG1hdGNoZWQgdXAgb3Igbm90XG4gICAgICBpZiAoa2V5ZWRSZW1vdmFsTGlzdCkge1xuICAgICAgICBmb3IgKHZhciBpPTAsIGxlbj1rZXllZFJlbW92YWxMaXN0Lmxlbmd0aDsgaTxsZW47IGkrKykge1xuICAgICAgICAgIHZhciBlbFRvUmVtb3ZlID0gZnJvbU5vZGVzTG9va3VwW2tleWVkUmVtb3ZhbExpc3RbaV1dO1xuICAgICAgICAgIGlmIChlbFRvUmVtb3ZlKSB7XG4gICAgICAgICAgICByZW1vdmVOb2RlKGVsVG9SZW1vdmUsIGVsVG9SZW1vdmUucGFyZW50Tm9kZSwgZmFsc2UpO1xuICAgICAgICAgIH1cbiAgICAgICAgfVxuICAgICAgfVxuICAgIH1cblxuICAgIGlmICghY2hpbGRyZW5Pbmx5ICYmIG1vcnBoZWROb2RlICE9PSBmcm9tTm9kZSAmJiBmcm9tTm9kZS5wYXJlbnROb2RlKSB7XG4gICAgICBpZiAobW9ycGhlZE5vZGUuYWN0dWFsaXplKSB7XG4gICAgICAgIG1vcnBoZWROb2RlID0gbW9ycGhlZE5vZGUuYWN0dWFsaXplKGZyb21Ob2RlLm93bmVyRG9jdW1lbnQgfHwgZG9jKTtcbiAgICAgIH1cbiAgICAgIC8vIElmIHdlIGhhZCB0byBzd2FwIG91dCB0aGUgZnJvbSBub2RlIHdpdGggYSBuZXcgbm9kZSBiZWNhdXNlIHRoZSBvbGRcbiAgICAgIC8vIG5vZGUgd2FzIG5vdCBjb21wYXRpYmxlIHdpdGggdGhlIHRhcmdldCBub2RlIHRoZW4gd2UgbmVlZCB0b1xuICAgICAgLy8gcmVwbGFjZSB0aGUgb2xkIERPTSBub2RlIGluIHRoZSBvcmlnaW5hbCBET00gdHJlZS4gVGhpcyBpcyBvbmx5XG4gICAgICAvLyBwb3NzaWJsZSBpZiB0aGUgb3JpZ2luYWwgRE9NIG5vZGUgd2FzIHBhcnQgb2YgYSBET00gdHJlZSB3aGljaFxuICAgICAgLy8gd2Uga25vdyBpcyB0aGUgY2FzZSBpZiBpdCBoYXMgYSBwYXJlbnQgbm9kZS5cbiAgICAgIGZyb21Ob2RlLnBhcmVudE5vZGUucmVwbGFjZUNoaWxkKG1vcnBoZWROb2RlLCBmcm9tTm9kZSk7XG4gICAgfVxuXG4gICAgcmV0dXJuIG1vcnBoZWROb2RlO1xuICB9O1xufVxuXG52YXIgbW9ycGhkb20gPSBtb3JwaGRvbUZhY3RvcnkobW9ycGhBdHRycyk7XG5cbmV4cG9ydCBkZWZhdWx0IG1vcnBoZG9tO1xuIiwgImltcG9ydCB7XG4gIFBIWF9DT01QT05FTlQsXG4gIFBIWF9ESVNBQkxFX1dJVEgsXG4gIFBIWF9GRUVEQkFDS19GT1IsXG4gIFBIWF9QUlVORSxcbiAgUEhYX1JPT1RfSUQsXG4gIFBIWF9TRVNTSU9OLFxuICBQSFhfU0tJUCxcbiAgUEhYX1NUQVRJQyxcbiAgUEhYX1RSSUdHRVJfQUNUSU9OLFxuICBQSFhfVVBEQVRFLFxuICBQSFhfU1RSRUFNLFxufSBmcm9tIFwiLi9jb25zdGFudHNcIlxuXG5pbXBvcnQge1xuICBkZXRlY3REdXBsaWNhdGVJZHMsXG4gIGlzQ2lkXG59IGZyb20gXCIuL3V0aWxzXCJcblxuaW1wb3J0IERPTSBmcm9tIFwiLi9kb21cIlxuaW1wb3J0IERPTVBvc3RNb3JwaFJlc3RvcmVyIGZyb20gXCIuL2RvbV9wb3N0X21vcnBoX3Jlc3RvcmVyXCJcbmltcG9ydCBtb3JwaGRvbSBmcm9tIFwibW9ycGhkb21cIlxuXG5leHBvcnQgZGVmYXVsdCBjbGFzcyBET01QYXRjaCB7XG4gIHN0YXRpYyBwYXRjaEVsKGZyb21FbCwgdG9FbCwgYWN0aXZlRWxlbWVudCl7XG4gICAgbW9ycGhkb20oZnJvbUVsLCB0b0VsLCB7XG4gICAgICBjaGlsZHJlbk9ubHk6IGZhbHNlLFxuICAgICAgb25CZWZvcmVFbFVwZGF0ZWQ6IChmcm9tRWwsIHRvRWwpID0+IHtcbiAgICAgICAgaWYoYWN0aXZlRWxlbWVudCAmJiBhY3RpdmVFbGVtZW50LmlzU2FtZU5vZGUoZnJvbUVsKSAmJiBET00uaXNGb3JtSW5wdXQoZnJvbUVsKSl7XG4gICAgICAgICAgRE9NLm1lcmdlRm9jdXNlZElucHV0KGZyb21FbCwgdG9FbClcbiAgICAgICAgICByZXR1cm4gZmFsc2VcbiAgICAgICAgfVxuICAgICAgfVxuICAgIH0pXG4gIH1cblxuICBjb25zdHJ1Y3Rvcih2aWV3LCBjb250YWluZXIsIGlkLCBodG1sLCBzdHJlYW1zLCB0YXJnZXRDSUQpe1xuICAgIHRoaXMudmlldyA9IHZpZXdcbiAgICB0aGlzLmxpdmVTb2NrZXQgPSB2aWV3LmxpdmVTb2NrZXRcbiAgICB0aGlzLmNvbnRhaW5lciA9IGNvbnRhaW5lclxuICAgIHRoaXMuaWQgPSBpZFxuICAgIHRoaXMucm9vdElEID0gdmlldy5yb290LmlkXG4gICAgdGhpcy5odG1sID0gaHRtbFxuICAgIHRoaXMuc3RyZWFtcyA9IHN0cmVhbXNcbiAgICB0aGlzLnN0cmVhbUluc2VydHMgPSB7fVxuICAgIHRoaXMudGFyZ2V0Q0lEID0gdGFyZ2V0Q0lEXG4gICAgdGhpcy5jaWRQYXRjaCA9IGlzQ2lkKHRoaXMudGFyZ2V0Q0lEKVxuICAgIHRoaXMucGVuZGluZ1JlbW92ZXMgPSBbXVxuICAgIHRoaXMucGh4UmVtb3ZlID0gdGhpcy5saXZlU29ja2V0LmJpbmRpbmcoXCJyZW1vdmVcIilcbiAgICB0aGlzLmNhbGxiYWNrcyA9IHtcbiAgICAgIGJlZm9yZWFkZGVkOiBbXSwgYmVmb3JldXBkYXRlZDogW10sIGJlZm9yZXBoeENoaWxkQWRkZWQ6IFtdLFxuICAgICAgYWZ0ZXJhZGRlZDogW10sIGFmdGVydXBkYXRlZDogW10sIGFmdGVyZGlzY2FyZGVkOiBbXSwgYWZ0ZXJwaHhDaGlsZEFkZGVkOiBbXSxcbiAgICAgIGFmdGVydHJhbnNpdGlvbnNEaXNjYXJkZWQ6IFtdXG4gICAgfVxuICB9XG5cbiAgYmVmb3JlKGtpbmQsIGNhbGxiYWNrKXsgdGhpcy5jYWxsYmFja3NbYGJlZm9yZSR7a2luZH1gXS5wdXNoKGNhbGxiYWNrKSB9XG4gIGFmdGVyKGtpbmQsIGNhbGxiYWNrKXsgdGhpcy5jYWxsYmFja3NbYGFmdGVyJHtraW5kfWBdLnB1c2goY2FsbGJhY2spIH1cblxuICB0cmFja0JlZm9yZShraW5kLCAuLi5hcmdzKXtcbiAgICB0aGlzLmNhbGxiYWNrc1tgYmVmb3JlJHtraW5kfWBdLmZvckVhY2goY2FsbGJhY2sgPT4gY2FsbGJhY2soLi4uYXJncykpXG4gIH1cblxuICB0cmFja0FmdGVyKGtpbmQsIC4uLmFyZ3Mpe1xuICAgIHRoaXMuY2FsbGJhY2tzW2BhZnRlciR7a2luZH1gXS5mb3JFYWNoKGNhbGxiYWNrID0+IGNhbGxiYWNrKC4uLmFyZ3MpKVxuICB9XG5cbiAgbWFya1BydW5hYmxlQ29udGVudEZvclJlbW92YWwoKXtcbiAgICBsZXQgcGh4VXBkYXRlID0gdGhpcy5saXZlU29ja2V0LmJpbmRpbmcoUEhYX1VQREFURSlcbiAgICBET00uYWxsKHRoaXMuY29udGFpbmVyLCBgWyR7cGh4VXBkYXRlfT0ke1BIWF9TVFJFQU19XWAsIGVsID0+IGVsLmlubmVySFRNTCA9IFwiXCIpXG4gICAgRE9NLmFsbCh0aGlzLmNvbnRhaW5lciwgYFske3BoeFVwZGF0ZX09YXBwZW5kXSA+ICosIFske3BoeFVwZGF0ZX09cHJlcGVuZF0gPiAqYCwgZWwgPT4ge1xuICAgICAgZWwuc2V0QXR0cmlidXRlKFBIWF9QUlVORSwgXCJcIilcbiAgICB9KVxuICB9XG5cbiAgcGVyZm9ybSgpe1xuICAgIGxldCB7dmlldywgbGl2ZVNvY2tldCwgY29udGFpbmVyLCBodG1sfSA9IHRoaXNcbiAgICBsZXQgdGFyZ2V0Q29udGFpbmVyID0gdGhpcy5pc0NJRFBhdGNoKCkgPyB0aGlzLnRhcmdldENJRENvbnRhaW5lcihodG1sKSA6IGNvbnRhaW5lclxuICAgIGlmKHRoaXMuaXNDSURQYXRjaCgpICYmICF0YXJnZXRDb250YWluZXIpeyByZXR1cm4gfVxuXG4gICAgbGV0IGZvY3VzZWQgPSBsaXZlU29ja2V0LmdldEFjdGl2ZUVsZW1lbnQoKVxuICAgIGxldCB7c2VsZWN0aW9uU3RhcnQsIHNlbGVjdGlvbkVuZH0gPSBmb2N1c2VkICYmIERPTS5oYXNTZWxlY3Rpb25SYW5nZShmb2N1c2VkKSA/IGZvY3VzZWQgOiB7fVxuICAgIGxldCBwaHhVcGRhdGUgPSBsaXZlU29ja2V0LmJpbmRpbmcoUEhYX1VQREFURSlcbiAgICBsZXQgcGh4RmVlZGJhY2tGb3IgPSBsaXZlU29ja2V0LmJpbmRpbmcoUEhYX0ZFRURCQUNLX0ZPUilcbiAgICBsZXQgZGlzYWJsZVdpdGggPSBsaXZlU29ja2V0LmJpbmRpbmcoUEhYX0RJU0FCTEVfV0lUSClcbiAgICBsZXQgcGh4VHJpZ2dlckV4dGVybmFsID0gbGl2ZVNvY2tldC5iaW5kaW5nKFBIWF9UUklHR0VSX0FDVElPTilcbiAgICBsZXQgYWRkZWQgPSBbXVxuICAgIGxldCB1cGRhdGVzID0gW11cbiAgICBsZXQgYXBwZW5kUHJlcGVuZFVwZGF0ZXMgPSBbXVxuXG4gICAgbGV0IGV4dGVybmFsRm9ybVRyaWdnZXJlZCA9IG51bGxcblxuICAgIGxldCBkaWZmSFRNTCA9IGxpdmVTb2NrZXQudGltZShcInByZW1vcnBoIGNvbnRhaW5lciBwcmVwXCIsICgpID0+IHtcbiAgICAgIHJldHVybiB0aGlzLmJ1aWxkRGlmZkhUTUwoY29udGFpbmVyLCBodG1sLCBwaHhVcGRhdGUsIHRhcmdldENvbnRhaW5lcilcbiAgICB9KVxuXG4gICAgdGhpcy50cmFja0JlZm9yZShcImFkZGVkXCIsIGNvbnRhaW5lcilcbiAgICB0aGlzLnRyYWNrQmVmb3JlKFwidXBkYXRlZFwiLCBjb250YWluZXIsIGNvbnRhaW5lcilcblxuICAgIGxpdmVTb2NrZXQudGltZShcIm1vcnBoZG9tXCIsICgpID0+IHtcbiAgICAgIHRoaXMuc3RyZWFtcy5mb3JFYWNoKChbaW5zZXJ0cywgZGVsZXRlSWRzXSkgPT4ge1xuICAgICAgICB0aGlzLnN0cmVhbUluc2VydHMgPSBPYmplY3QuYXNzaWduKHRoaXMuc3RyZWFtSW5zZXJ0cywgaW5zZXJ0cylcbiAgICAgICAgZGVsZXRlSWRzLmZvckVhY2goaWQgPT4ge1xuICAgICAgICAgIGxldCBjaGlsZCA9IGNvbnRhaW5lci5xdWVyeVNlbGVjdG9yKGBbaWQ9XCIke2lkfVwiXWApXG4gICAgICAgICAgaWYoY2hpbGQpe1xuICAgICAgICAgICAgaWYoIXRoaXMubWF5YmVQZW5kaW5nUmVtb3ZlKGNoaWxkKSl7XG4gICAgICAgICAgICAgIGNoaWxkLnJlbW92ZSgpXG4gICAgICAgICAgICAgIHRoaXMub25Ob2RlRGlzY2FyZGVkKGNoaWxkKVxuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cbiAgICAgICAgfSlcbiAgICAgIH0pXG5cbiAgICAgIG1vcnBoZG9tKHRhcmdldENvbnRhaW5lciwgZGlmZkhUTUwsIHtcbiAgICAgICAgY2hpbGRyZW5Pbmx5OiB0YXJnZXRDb250YWluZXIuZ2V0QXR0cmlidXRlKFBIWF9DT01QT05FTlQpID09PSBudWxsLFxuICAgICAgICBnZXROb2RlS2V5OiAobm9kZSkgPT4ge1xuICAgICAgICAgIHJldHVybiBET00uaXNQaHhEZXN0cm95ZWQobm9kZSkgPyBudWxsIDogbm9kZS5pZFxuICAgICAgICB9LFxuICAgICAgICAvLyBza2lwIGluZGV4aW5nIGZyb20gY2hpbGRyZW4gd2hlbiBjb250YWluZXIgaXMgc3RyZWFtXG4gICAgICAgIHNraXBGcm9tQ2hpbGRyZW46IChmcm9tKSA9PiB7IHJldHVybiBmcm9tLmdldEF0dHJpYnV0ZShwaHhVcGRhdGUpID09PSBQSFhfU1RSRUFNIH0sXG4gICAgICAgIC8vIHRlbGwgbW9ycGhkb20gaG93IHRvIGFkZCBhIGNoaWxkXG4gICAgICAgIGFkZENoaWxkOiAocGFyZW50LCBjaGlsZCkgPT4ge1xuICAgICAgICAgIGxldCBzdHJlYW1BdCA9IGNoaWxkLmlkID8gdGhpcy5zdHJlYW1JbnNlcnRzW2NoaWxkLmlkXSA6IHVuZGVmaW5lZFxuICAgICAgICAgIGlmKHN0cmVhbUF0ID09PSB1bmRlZmluZWQpIHsgcmV0dXJuIHBhcmVudC5hcHBlbmRDaGlsZChjaGlsZCkgfVxuXG4gICAgICAgICAgLy8gc3RyZWFtaW5nXG4gICAgICAgICAgaWYoc3RyZWFtQXQgPT09IDApe1xuICAgICAgICAgICAgcGFyZW50Lmluc2VydEFkamFjZW50RWxlbWVudChcImFmdGVyYmVnaW5cIiwgY2hpbGQpXG4gICAgICAgICAgfSBlbHNlIGlmKHN0cmVhbUF0ID09PSAtMSl7XG4gICAgICAgICAgICBwYXJlbnQuYXBwZW5kQ2hpbGQoY2hpbGQpXG4gICAgICAgICAgfSBlbHNlIGlmKHN0cmVhbUF0ID4gMCl7XG4gICAgICAgICAgICBsZXQgc2libGluZyA9IEFycmF5LmZyb20ocGFyZW50LmNoaWxkcmVuKVtzdHJlYW1BdF1cbiAgICAgICAgICAgIHBhcmVudC5pbnNlcnRCZWZvcmUoY2hpbGQsIHNpYmxpbmcpXG4gICAgICAgICAgfVxuICAgICAgICB9LFxuICAgICAgICBvbkJlZm9yZU5vZGVBZGRlZDogKGVsKSA9PiB7XG4gICAgICAgICAgdGhpcy50cmFja0JlZm9yZShcImFkZGVkXCIsIGVsKVxuICAgICAgICAgIHJldHVybiBlbFxuICAgICAgICB9LFxuICAgICAgICBvbk5vZGVBZGRlZDogKGVsKSA9PiB7XG4gICAgICAgICAgLy8gaGFjayB0byBmaXggU2FmYXJpIGhhbmRsaW5nIG9mIGltZyBzcmNzZXQgYW5kIHZpZGVvIHRhZ3NcbiAgICAgICAgICBpZihlbCBpbnN0YW5jZW9mIEhUTUxJbWFnZUVsZW1lbnQgJiYgZWwuc3Jjc2V0KXtcbiAgICAgICAgICAgIGVsLnNyY3NldCA9IGVsLnNyY3NldFxuICAgICAgICAgIH0gZWxzZSBpZihlbCBpbnN0YW5jZW9mIEhUTUxWaWRlb0VsZW1lbnQgJiYgZWwuYXV0b3BsYXkpe1xuICAgICAgICAgICAgZWwucGxheSgpXG4gICAgICAgICAgfVxuICAgICAgICAgIGlmKERPTS5pc05vd1RyaWdnZXJGb3JtRXh0ZXJuYWwoZWwsIHBoeFRyaWdnZXJFeHRlcm5hbCkpe1xuICAgICAgICAgICAgZXh0ZXJuYWxGb3JtVHJpZ2dlcmVkID0gZWxcbiAgICAgICAgICB9XG4gICAgICAgICAgLy9pbnB1dCBoYW5kbGluZ1xuICAgICAgICAgIERPTS5kaXNjYXJkRXJyb3IodGFyZ2V0Q29udGFpbmVyLCBlbCwgcGh4RmVlZGJhY2tGb3IpXG4gICAgICAgICAgLy8gbmVzdGVkIHZpZXcgaGFuZGxpbmdcbiAgICAgICAgICBpZigoRE9NLmlzUGh4Q2hpbGQoZWwpICYmIHZpZXcub3duc0VsZW1lbnQoZWwpKSB8fCBET00uaXNQaHhTdGlja3koZWwpICYmIHZpZXcub3duc0VsZW1lbnQoZWwucGFyZW50Tm9kZSkpe1xuICAgICAgICAgICAgdGhpcy50cmFja0FmdGVyKFwicGh4Q2hpbGRBZGRlZFwiLCBlbClcbiAgICAgICAgICB9XG4gICAgICAgICAgYWRkZWQucHVzaChlbClcbiAgICAgICAgfSxcbiAgICAgICAgb25Ob2RlRGlzY2FyZGVkOiAoZWwpID0+IHRoaXMub25Ob2RlRGlzY2FyZGVkKGVsKSxcbiAgICAgICAgb25CZWZvcmVOb2RlRGlzY2FyZGVkOiAoZWwpID0+IHtcbiAgICAgICAgICBpZihlbC5nZXRBdHRyaWJ1dGUgJiYgZWwuZ2V0QXR0cmlidXRlKFBIWF9QUlVORSkgIT09IG51bGwpeyByZXR1cm4gdHJ1ZSB9XG4gICAgICAgICAgaWYoZWwucGFyZW50RWxlbWVudCAhPT0gbnVsbCAmJiBlbC5pZCAmJlxuICAgICAgICAgICAgIERPTS5pc1BoeFVwZGF0ZShlbC5wYXJlbnRFbGVtZW50LCBwaHhVcGRhdGUsIFtQSFhfU1RSRUFNLCBcImFwcGVuZFwiLCBcInByZXBlbmRcIl0pKXtcbiAgICAgICAgICAgIHJldHVybiBmYWxzZVxuICAgICAgICAgIH1cbiAgICAgICAgICBpZih0aGlzLm1heWJlUGVuZGluZ1JlbW92ZShlbCkpeyByZXR1cm4gZmFsc2UgfVxuICAgICAgICAgIGlmKHRoaXMuc2tpcENJRFNpYmxpbmcoZWwpKXsgcmV0dXJuIGZhbHNlIH1cblxuICAgICAgICAgIHJldHVybiB0cnVlXG4gICAgICAgIH0sXG4gICAgICAgIG9uRWxVcGRhdGVkOiAoZWwpID0+IHtcbiAgICAgICAgICBpZihET00uaXNOb3dUcmlnZ2VyRm9ybUV4dGVybmFsKGVsLCBwaHhUcmlnZ2VyRXh0ZXJuYWwpKXtcbiAgICAgICAgICAgIGV4dGVybmFsRm9ybVRyaWdnZXJlZCA9IGVsXG4gICAgICAgICAgfVxuICAgICAgICAgIHVwZGF0ZXMucHVzaChlbClcbiAgICAgICAgICB0aGlzLm1heWJlUmVPcmRlclN0cmVhbShlbClcbiAgICAgICAgfSxcbiAgICAgICAgb25CZWZvcmVFbFVwZGF0ZWQ6IChmcm9tRWwsIHRvRWwpID0+IHtcbiAgICAgICAgICBET00uY2xlYW5DaGlsZE5vZGVzKHRvRWwsIHBoeFVwZGF0ZSlcbiAgICAgICAgICBpZih0aGlzLnNraXBDSURTaWJsaW5nKHRvRWwpKXsgcmV0dXJuIGZhbHNlIH1cbiAgICAgICAgICBpZihET00uaXNQaHhTdGlja3koZnJvbUVsKSl7IHJldHVybiBmYWxzZSB9XG4gICAgICAgICAgaWYoRE9NLmlzSWdub3JlZChmcm9tRWwsIHBoeFVwZGF0ZSkgfHwgKGZyb21FbC5mb3JtICYmIGZyb21FbC5mb3JtLmlzU2FtZU5vZGUoZXh0ZXJuYWxGb3JtVHJpZ2dlcmVkKSkpe1xuICAgICAgICAgICAgdGhpcy50cmFja0JlZm9yZShcInVwZGF0ZWRcIiwgZnJvbUVsLCB0b0VsKVxuICAgICAgICAgICAgRE9NLm1lcmdlQXR0cnMoZnJvbUVsLCB0b0VsLCB7aXNJZ25vcmVkOiB0cnVlfSlcbiAgICAgICAgICAgIHVwZGF0ZXMucHVzaChmcm9tRWwpXG4gICAgICAgICAgICBET00uYXBwbHlTdGlja3lPcGVyYXRpb25zKGZyb21FbClcbiAgICAgICAgICAgIHJldHVybiBmYWxzZVxuICAgICAgICAgIH1cbiAgICAgICAgICBpZihmcm9tRWwudHlwZSA9PT0gXCJudW1iZXJcIiAmJiAoZnJvbUVsLnZhbGlkaXR5ICYmIGZyb21FbC52YWxpZGl0eS5iYWRJbnB1dCkpeyByZXR1cm4gZmFsc2UgfVxuICAgICAgICAgIGlmKCFET00uc3luY1BlbmRpbmdSZWYoZnJvbUVsLCB0b0VsLCBkaXNhYmxlV2l0aCkpe1xuICAgICAgICAgICAgaWYoRE9NLmlzVXBsb2FkSW5wdXQoZnJvbUVsKSl7XG4gICAgICAgICAgICAgIHRoaXMudHJhY2tCZWZvcmUoXCJ1cGRhdGVkXCIsIGZyb21FbCwgdG9FbClcbiAgICAgICAgICAgICAgdXBkYXRlcy5wdXNoKGZyb21FbClcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIERPTS5hcHBseVN0aWNreU9wZXJhdGlvbnMoZnJvbUVsKVxuICAgICAgICAgICAgcmV0dXJuIGZhbHNlXG4gICAgICAgICAgfVxuXG4gICAgICAgICAgLy8gbmVzdGVkIHZpZXcgaGFuZGxpbmdcbiAgICAgICAgICBpZihET00uaXNQaHhDaGlsZCh0b0VsKSl7XG4gICAgICAgICAgICBsZXQgcHJldlNlc3Npb24gPSBmcm9tRWwuZ2V0QXR0cmlidXRlKFBIWF9TRVNTSU9OKVxuICAgICAgICAgICAgRE9NLm1lcmdlQXR0cnMoZnJvbUVsLCB0b0VsLCB7ZXhjbHVkZTogW1BIWF9TVEFUSUNdfSlcbiAgICAgICAgICAgIGlmKHByZXZTZXNzaW9uICE9PSBcIlwiKXsgZnJvbUVsLnNldEF0dHJpYnV0ZShQSFhfU0VTU0lPTiwgcHJldlNlc3Npb24pIH1cbiAgICAgICAgICAgIGZyb21FbC5zZXRBdHRyaWJ1dGUoUEhYX1JPT1RfSUQsIHRoaXMucm9vdElEKVxuICAgICAgICAgICAgRE9NLmFwcGx5U3RpY2t5T3BlcmF0aW9ucyhmcm9tRWwpXG4gICAgICAgICAgICByZXR1cm4gZmFsc2VcbiAgICAgICAgICB9XG5cbiAgICAgICAgICAvLyBpbnB1dCBoYW5kbGluZ1xuICAgICAgICAgIERPTS5jb3B5UHJpdmF0ZXModG9FbCwgZnJvbUVsKVxuICAgICAgICAgIERPTS5kaXNjYXJkRXJyb3IodGFyZ2V0Q29udGFpbmVyLCB0b0VsLCBwaHhGZWVkYmFja0ZvcilcblxuICAgICAgICAgIGxldCBpc0ZvY3VzZWRGb3JtRWwgPSBmb2N1c2VkICYmIGZyb21FbC5pc1NhbWVOb2RlKGZvY3VzZWQpICYmIERPTS5pc0Zvcm1JbnB1dChmcm9tRWwpXG4gICAgICAgICAgaWYoaXNGb2N1c2VkRm9ybUVsICYmIGZyb21FbC50eXBlICE9PSBcImhpZGRlblwiKXtcbiAgICAgICAgICAgIHRoaXMudHJhY2tCZWZvcmUoXCJ1cGRhdGVkXCIsIGZyb21FbCwgdG9FbClcbiAgICAgICAgICAgIERPTS5tZXJnZUZvY3VzZWRJbnB1dChmcm9tRWwsIHRvRWwpXG4gICAgICAgICAgICBET00uc3luY0F0dHJzVG9Qcm9wcyhmcm9tRWwpXG4gICAgICAgICAgICB1cGRhdGVzLnB1c2goZnJvbUVsKVxuICAgICAgICAgICAgRE9NLmFwcGx5U3RpY2t5T3BlcmF0aW9ucyhmcm9tRWwpXG4gICAgICAgICAgICByZXR1cm4gZmFsc2VcbiAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgaWYoRE9NLmlzUGh4VXBkYXRlKHRvRWwsIHBoeFVwZGF0ZSwgW1wiYXBwZW5kXCIsIFwicHJlcGVuZFwiXSkpe1xuICAgICAgICAgICAgICBhcHBlbmRQcmVwZW5kVXBkYXRlcy5wdXNoKG5ldyBET01Qb3N0TW9ycGhSZXN0b3Jlcihmcm9tRWwsIHRvRWwsIHRvRWwuZ2V0QXR0cmlidXRlKHBoeFVwZGF0ZSkpKVxuICAgICAgICAgICAgfVxuICAgICAgICAgICAgRE9NLnN5bmNBdHRyc1RvUHJvcHModG9FbClcbiAgICAgICAgICAgIERPTS5hcHBseVN0aWNreU9wZXJhdGlvbnModG9FbClcbiAgICAgICAgICAgIHRoaXMudHJhY2tCZWZvcmUoXCJ1cGRhdGVkXCIsIGZyb21FbCwgdG9FbClcbiAgICAgICAgICAgIHJldHVybiB0cnVlXG4gICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICB9KVxuICAgIH0pXG5cbiAgICBpZihsaXZlU29ja2V0LmlzRGVidWdFbmFibGVkKCkpeyBkZXRlY3REdXBsaWNhdGVJZHMoKSB9XG5cbiAgICBpZihhcHBlbmRQcmVwZW5kVXBkYXRlcy5sZW5ndGggPiAwKXtcbiAgICAgIGxpdmVTb2NrZXQudGltZShcInBvc3QtbW9ycGggYXBwZW5kL3ByZXBlbmQgcmVzdG9yYXRpb25cIiwgKCkgPT4ge1xuICAgICAgICBhcHBlbmRQcmVwZW5kVXBkYXRlcy5mb3JFYWNoKHVwZGF0ZSA9PiB1cGRhdGUucGVyZm9ybSgpKVxuICAgICAgfSlcbiAgICB9XG5cbiAgICBsaXZlU29ja2V0LnNpbGVuY2VFdmVudHMoKCkgPT4gRE9NLnJlc3RvcmVGb2N1cyhmb2N1c2VkLCBzZWxlY3Rpb25TdGFydCwgc2VsZWN0aW9uRW5kKSlcbiAgICBET00uZGlzcGF0Y2hFdmVudChkb2N1bWVudCwgXCJwaHg6dXBkYXRlXCIpXG4gICAgYWRkZWQuZm9yRWFjaChlbCA9PiB0aGlzLnRyYWNrQWZ0ZXIoXCJhZGRlZFwiLCBlbCkpXG4gICAgdXBkYXRlcy5mb3JFYWNoKGVsID0+IHRoaXMudHJhY2tBZnRlcihcInVwZGF0ZWRcIiwgZWwpKVxuXG4gICAgdGhpcy50cmFuc2l0aW9uUGVuZGluZ1JlbW92ZXMoKVxuXG4gICAgaWYoZXh0ZXJuYWxGb3JtVHJpZ2dlcmVkKXtcbiAgICAgIGxpdmVTb2NrZXQudW5sb2FkKClcbiAgICAgIGV4dGVybmFsRm9ybVRyaWdnZXJlZC5zdWJtaXQoKVxuICAgIH1cbiAgICByZXR1cm4gdHJ1ZVxuICB9XG5cbiAgb25Ob2RlRGlzY2FyZGVkKGVsKXtcbiAgICAvLyBuZXN0ZWQgdmlldyBoYW5kbGluZ1xuICAgIGlmKERPTS5pc1BoeENoaWxkKGVsKSB8fCBET00uaXNQaHhTdGlja3koZWwpKXsgdGhpcy5saXZlU29ja2V0LmRlc3Ryb3lWaWV3QnlFbChlbCkgfVxuICAgIHRoaXMudHJhY2tBZnRlcihcImRpc2NhcmRlZFwiLCBlbClcbiAgfVxuXG4gIG1heWJlUGVuZGluZ1JlbW92ZShub2RlKXtcbiAgICBpZihub2RlLmdldEF0dHJpYnV0ZSAmJiBub2RlLmdldEF0dHJpYnV0ZSh0aGlzLnBoeFJlbW92ZSkgIT09IG51bGwpe1xuICAgICAgdGhpcy5wZW5kaW5nUmVtb3Zlcy5wdXNoKG5vZGUpXG4gICAgICByZXR1cm4gdHJ1ZVxuICAgIH0gZWxzZSB7XG4gICAgICByZXR1cm4gZmFsc2VcbiAgICB9XG4gIH1cblxuICBtYXliZVJlT3JkZXJTdHJlYW0oZWwpe1xuICAgIGxldCBzdHJlYW1BdCA9IGVsLmlkID8gdGhpcy5zdHJlYW1JbnNlcnRzW2VsLmlkXSA6IHVuZGVmaW5lZFxuICAgIGlmKHN0cmVhbUF0ID09PSB1bmRlZmluZWQpeyByZXR1cm4gfVxuXG4gICAgaWYoc3RyZWFtQXQgPT09IDApe1xuICAgICAgZWwucGFyZW50RWxlbWVudC5pbnNlcnRCZWZvcmUoZWwsIGVsLnBhcmVudEVsZW1lbnQuZmlyc3RFbGVtZW50Q2hpbGQpXG4gICAgfSBlbHNlIGlmKHN0cmVhbUF0ID4gMCl7XG4gICAgICBsZXQgY2hpbGRyZW4gPSBBcnJheS5mcm9tKGVsLnBhcmVudEVsZW1lbnQuY2hpbGRyZW4pXG4gICAgICBsZXQgb2xkSW5kZXggPSBjaGlsZHJlbi5pbmRleE9mKGVsKVxuICAgICAgaWYoc3RyZWFtQXQgPj0gY2hpbGRyZW4ubGVuZ3RoIC0gMSl7XG4gICAgICAgIGVsLnBhcmVudEVsZW1lbnQuYXBwZW5kQ2hpbGQoZWwpXG4gICAgICB9IGVsc2Uge1xuICAgICAgICBsZXQgc2libGluZyA9IGNoaWxkcmVuW3N0cmVhbUF0XVxuICAgICAgICBpZihvbGRJbmRleCA+IHN0cmVhbUF0KXtcbiAgICAgICAgICBlbC5wYXJlbnRFbGVtZW50Lmluc2VydEJlZm9yZShlbCwgc2libGluZylcbiAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICBlbC5wYXJlbnRFbGVtZW50Lmluc2VydEJlZm9yZShlbCwgc2libGluZy5uZXh0RWxlbWVudFNpYmxpbmcpXG4gICAgICAgIH1cbiAgICAgIH1cbiAgICB9XG4gIH1cblxuICB0cmFuc2l0aW9uUGVuZGluZ1JlbW92ZXMoKXtcbiAgICBsZXQge3BlbmRpbmdSZW1vdmVzLCBsaXZlU29ja2V0fSA9IHRoaXNcbiAgICBpZihwZW5kaW5nUmVtb3Zlcy5sZW5ndGggPiAwKXtcbiAgICAgIGxpdmVTb2NrZXQudHJhbnNpdGlvblJlbW92ZXMocGVuZGluZ1JlbW92ZXMpXG4gICAgICBsaXZlU29ja2V0LnJlcXVlc3RET01VcGRhdGUoKCkgPT4ge1xuICAgICAgICBwZW5kaW5nUmVtb3Zlcy5mb3JFYWNoKGVsID0+IHtcbiAgICAgICAgICBsZXQgY2hpbGQgPSBET00uZmlyc3RQaHhDaGlsZChlbClcbiAgICAgICAgICBpZihjaGlsZCl7IGxpdmVTb2NrZXQuZGVzdHJveVZpZXdCeUVsKGNoaWxkKSB9XG4gICAgICAgICAgZWwucmVtb3ZlKClcbiAgICAgICAgfSlcbiAgICAgICAgdGhpcy50cmFja0FmdGVyKFwidHJhbnNpdGlvbnNEaXNjYXJkZWRcIiwgcGVuZGluZ1JlbW92ZXMpXG4gICAgICB9KVxuICAgIH1cbiAgfVxuXG4gIGlzQ0lEUGF0Y2goKXsgcmV0dXJuIHRoaXMuY2lkUGF0Y2ggfVxuXG4gIHNraXBDSURTaWJsaW5nKGVsKXtcbiAgICByZXR1cm4gZWwubm9kZVR5cGUgPT09IE5vZGUuRUxFTUVOVF9OT0RFICYmIGVsLmdldEF0dHJpYnV0ZShQSFhfU0tJUCkgIT09IG51bGxcbiAgfVxuXG4gIHRhcmdldENJRENvbnRhaW5lcihodG1sKXtcbiAgICBpZighdGhpcy5pc0NJRFBhdGNoKCkpeyByZXR1cm4gfVxuICAgIGxldCBbZmlyc3QsIC4uLnJlc3RdID0gRE9NLmZpbmRDb21wb25lbnROb2RlTGlzdCh0aGlzLmNvbnRhaW5lciwgdGhpcy50YXJnZXRDSUQpXG4gICAgaWYocmVzdC5sZW5ndGggPT09IDAgJiYgRE9NLmNoaWxkTm9kZUxlbmd0aChodG1sKSA9PT0gMSl7XG4gICAgICByZXR1cm4gZmlyc3RcbiAgICB9IGVsc2Uge1xuICAgICAgcmV0dXJuIGZpcnN0ICYmIGZpcnN0LnBhcmVudE5vZGVcbiAgICB9XG4gIH1cblxuICAvLyBidWlsZHMgSFRNTCBmb3IgbW9ycGhkb20gcGF0Y2hcbiAgLy8gLSBmb3IgZnVsbCBwYXRjaGVzIG9mIExpdmVWaWV3IG9yIGEgY29tcG9uZW50IHdpdGggYSBzaW5nbGVcbiAgLy8gICByb290IG5vZGUsIHNpbXBseSByZXR1cm5zIHRoZSBIVE1MXG4gIC8vIC0gZm9yIHBhdGNoZXMgb2YgYSBjb21wb25lbnQgd2l0aCBtdWx0aXBsZSByb290IG5vZGVzLCB0aGVcbiAgLy8gICBwYXJlbnQgbm9kZSBiZWNvbWVzIHRoZSB0YXJnZXQgY29udGFpbmVyIGFuZCBub24tY29tcG9uZW50XG4gIC8vICAgc2libGluZ3MgYXJlIG1hcmtlZCBhcyBza2lwLlxuICBidWlsZERpZmZIVE1MKGNvbnRhaW5lciwgaHRtbCwgcGh4VXBkYXRlLCB0YXJnZXRDb250YWluZXIpe1xuICAgIGxldCBpc0NJRFBhdGNoID0gdGhpcy5pc0NJRFBhdGNoKClcbiAgICBsZXQgaXNDSURXaXRoU2luZ2xlUm9vdCA9IGlzQ0lEUGF0Y2ggJiYgdGFyZ2V0Q29udGFpbmVyLmdldEF0dHJpYnV0ZShQSFhfQ09NUE9ORU5UKSA9PT0gdGhpcy50YXJnZXRDSUQudG9TdHJpbmcoKVxuICAgIGlmKCFpc0NJRFBhdGNoIHx8IGlzQ0lEV2l0aFNpbmdsZVJvb3Qpe1xuICAgICAgcmV0dXJuIGh0bWxcbiAgICB9IGVsc2Uge1xuICAgICAgLy8gY29tcG9uZW50IHBhdGNoIHdpdGggbXVsdGlwbGUgQ0lEIHJvb3RzXG4gICAgICBsZXQgZGlmZkNvbnRhaW5lciA9IG51bGxcbiAgICAgIGxldCB0ZW1wbGF0ZSA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoXCJ0ZW1wbGF0ZVwiKVxuICAgICAgZGlmZkNvbnRhaW5lciA9IERPTS5jbG9uZU5vZGUodGFyZ2V0Q29udGFpbmVyKVxuICAgICAgbGV0IFtmaXJzdENvbXBvbmVudCwgLi4ucmVzdF0gPSBET00uZmluZENvbXBvbmVudE5vZGVMaXN0KGRpZmZDb250YWluZXIsIHRoaXMudGFyZ2V0Q0lEKVxuICAgICAgdGVtcGxhdGUuaW5uZXJIVE1MID0gaHRtbFxuICAgICAgcmVzdC5mb3JFYWNoKGVsID0+IGVsLnJlbW92ZSgpKVxuICAgICAgQXJyYXkuZnJvbShkaWZmQ29udGFpbmVyLmNoaWxkTm9kZXMpLmZvckVhY2goY2hpbGQgPT4ge1xuICAgICAgICAvLyB3ZSBjYW4gb25seSBza2lwIHRyYWNrYWJsZSBub2RlcyB3aXRoIGFuIElEXG4gICAgICAgIGlmKGNoaWxkLmlkICYmIGNoaWxkLm5vZGVUeXBlID09PSBOb2RlLkVMRU1FTlRfTk9ERSAmJiBjaGlsZC5nZXRBdHRyaWJ1dGUoUEhYX0NPTVBPTkVOVCkgIT09IHRoaXMudGFyZ2V0Q0lELnRvU3RyaW5nKCkpe1xuICAgICAgICAgIGNoaWxkLnNldEF0dHJpYnV0ZShQSFhfU0tJUCwgXCJcIilcbiAgICAgICAgICBjaGlsZC5pbm5lckhUTUwgPSBcIlwiXG4gICAgICAgIH1cbiAgICAgIH0pXG4gICAgICBBcnJheS5mcm9tKHRlbXBsYXRlLmNvbnRlbnQuY2hpbGROb2RlcykuZm9yRWFjaChlbCA9PiBkaWZmQ29udGFpbmVyLmluc2VydEJlZm9yZShlbCwgZmlyc3RDb21wb25lbnQpKVxuICAgICAgZmlyc3RDb21wb25lbnQucmVtb3ZlKClcbiAgICAgIHJldHVybiBkaWZmQ29udGFpbmVyLm91dGVySFRNTFxuICAgIH1cbiAgfVxuXG4gIGluZGV4T2YocGFyZW50LCBjaGlsZCl7IHJldHVybiBBcnJheS5mcm9tKHBhcmVudC5jaGlsZHJlbikuaW5kZXhPZihjaGlsZCkgfVxufVxuIiwgImltcG9ydCB7XG4gIENPTVBPTkVOVFMsXG4gIERZTkFNSUNTLFxuICBURU1QTEFURVMsXG4gIEVWRU5UUyxcbiAgUEhYX0NPTVBPTkVOVCxcbiAgUEhYX1NLSVAsXG4gIFJFUExZLFxuICBTVEFUSUMsXG4gIFRJVExFLFxuICBTVFJFQU0sXG59IGZyb20gXCIuL2NvbnN0YW50c1wiXG5cbmltcG9ydCB7XG4gIGlzT2JqZWN0LFxuICBsb2dFcnJvcixcbiAgaXNDaWQsXG59IGZyb20gXCIuL3V0aWxzXCJcblxuZXhwb3J0IGRlZmF1bHQgY2xhc3MgUmVuZGVyZWQge1xuICBzdGF0aWMgZXh0cmFjdChkaWZmKXtcbiAgICBsZXQge1tSRVBMWV06IHJlcGx5LCBbRVZFTlRTXTogZXZlbnRzLCBbVElUTEVdOiB0aXRsZX0gPSBkaWZmXG4gICAgZGVsZXRlIGRpZmZbUkVQTFldXG4gICAgZGVsZXRlIGRpZmZbRVZFTlRTXVxuICAgIGRlbGV0ZSBkaWZmW1RJVExFXVxuICAgIHJldHVybiB7ZGlmZiwgdGl0bGUsIHJlcGx5OiByZXBseSB8fCBudWxsLCBldmVudHM6IGV2ZW50cyB8fCBbXX1cbiAgfVxuXG4gIGNvbnN0cnVjdG9yKHZpZXdJZCwgcmVuZGVyZWQpe1xuICAgIHRoaXMudmlld0lkID0gdmlld0lkXG4gICAgdGhpcy5yZW5kZXJlZCA9IHt9XG4gICAgdGhpcy5tZXJnZURpZmYocmVuZGVyZWQpXG4gIH1cblxuICBwYXJlbnRWaWV3SWQoKXsgcmV0dXJuIHRoaXMudmlld0lkIH1cblxuICB0b1N0cmluZyhvbmx5Q2lkcyl7XG4gICAgbGV0IFtzdHIsIHN0cmVhbXNdID0gdGhpcy5yZWN1cnNpdmVUb1N0cmluZyh0aGlzLnJlbmRlcmVkLCB0aGlzLnJlbmRlcmVkW0NPTVBPTkVOVFNdLCBvbmx5Q2lkcylcbiAgICByZXR1cm4gW3N0ciwgc3RyZWFtc11cbiAgfVxuXG4gIHJlY3Vyc2l2ZVRvU3RyaW5nKHJlbmRlcmVkLCBjb21wb25lbnRzID0gcmVuZGVyZWRbQ09NUE9ORU5UU10sIG9ubHlDaWRzKXtcbiAgICBvbmx5Q2lkcyA9IG9ubHlDaWRzID8gbmV3IFNldChvbmx5Q2lkcykgOiBudWxsXG4gICAgbGV0IG91dHB1dCA9IHtidWZmZXI6IFwiXCIsIGNvbXBvbmVudHM6IGNvbXBvbmVudHMsIG9ubHlDaWRzOiBvbmx5Q2lkcywgc3RyZWFtczogbmV3IFNldCgpfVxuICAgIHRoaXMudG9PdXRwdXRCdWZmZXIocmVuZGVyZWQsIG51bGwsIG91dHB1dClcbiAgICByZXR1cm4gW291dHB1dC5idWZmZXIsIG91dHB1dC5zdHJlYW1zXVxuICB9XG5cbiAgY29tcG9uZW50Q0lEcyhkaWZmKXsgcmV0dXJuIE9iamVjdC5rZXlzKGRpZmZbQ09NUE9ORU5UU10gfHwge30pLm1hcChpID0+IHBhcnNlSW50KGkpKSB9XG5cbiAgaXNDb21wb25lbnRPbmx5RGlmZihkaWZmKXtcbiAgICBpZighZGlmZltDT01QT05FTlRTXSl7IHJldHVybiBmYWxzZSB9XG4gICAgcmV0dXJuIE9iamVjdC5rZXlzKGRpZmYpLmxlbmd0aCA9PT0gMVxuICB9XG5cbiAgZ2V0Q29tcG9uZW50KGRpZmYsIGNpZCl7IHJldHVybiBkaWZmW0NPTVBPTkVOVFNdW2NpZF0gfVxuXG4gIG1lcmdlRGlmZihkaWZmKXtcbiAgICBsZXQgbmV3YyA9IGRpZmZbQ09NUE9ORU5UU11cbiAgICBsZXQgY2FjaGUgPSB7fVxuICAgIGRlbGV0ZSBkaWZmW0NPTVBPTkVOVFNdXG4gICAgdGhpcy5yZW5kZXJlZCA9IHRoaXMubXV0YWJsZU1lcmdlKHRoaXMucmVuZGVyZWQsIGRpZmYpXG4gICAgdGhpcy5yZW5kZXJlZFtDT01QT05FTlRTXSA9IHRoaXMucmVuZGVyZWRbQ09NUE9ORU5UU10gfHwge31cblxuICAgIGlmKG5ld2Mpe1xuICAgICAgbGV0IG9sZGMgPSB0aGlzLnJlbmRlcmVkW0NPTVBPTkVOVFNdXG5cbiAgICAgIGZvcihsZXQgY2lkIGluIG5ld2Mpe1xuICAgICAgICBuZXdjW2NpZF0gPSB0aGlzLmNhY2hlZEZpbmRDb21wb25lbnQoY2lkLCBuZXdjW2NpZF0sIG9sZGMsIG5ld2MsIGNhY2hlKVxuICAgICAgfVxuXG4gICAgICBmb3IobGV0IGNpZCBpbiBuZXdjKXsgb2xkY1tjaWRdID0gbmV3Y1tjaWRdIH1cbiAgICAgIGRpZmZbQ09NUE9ORU5UU10gPSBuZXdjXG4gICAgfVxuICB9XG5cbiAgY2FjaGVkRmluZENvbXBvbmVudChjaWQsIGNkaWZmLCBvbGRjLCBuZXdjLCBjYWNoZSl7XG4gICAgaWYoY2FjaGVbY2lkXSl7XG4gICAgICByZXR1cm4gY2FjaGVbY2lkXVxuICAgIH0gZWxzZSB7XG4gICAgICBsZXQgbmRpZmYsIHN0YXQsIHNjaWQgPSBjZGlmZltTVEFUSUNdXG5cbiAgICAgIGlmKGlzQ2lkKHNjaWQpKXtcbiAgICAgICAgbGV0IHRkaWZmXG5cbiAgICAgICAgaWYoc2NpZCA+IDApe1xuICAgICAgICAgIHRkaWZmID0gdGhpcy5jYWNoZWRGaW5kQ29tcG9uZW50KHNjaWQsIG5ld2Nbc2NpZF0sIG9sZGMsIG5ld2MsIGNhY2hlKVxuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIHRkaWZmID0gb2xkY1stc2NpZF1cbiAgICAgICAgfVxuXG4gICAgICAgIHN0YXQgPSB0ZGlmZltTVEFUSUNdXG4gICAgICAgIG5kaWZmID0gdGhpcy5jbG9uZU1lcmdlKHRkaWZmLCBjZGlmZilcbiAgICAgICAgbmRpZmZbU1RBVElDXSA9IHN0YXRcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIG5kaWZmID0gY2RpZmZbU1RBVElDXSAhPT0gdW5kZWZpbmVkID8gY2RpZmYgOiB0aGlzLmNsb25lTWVyZ2Uob2xkY1tjaWRdIHx8IHt9LCBjZGlmZilcbiAgICAgIH1cblxuICAgICAgY2FjaGVbY2lkXSA9IG5kaWZmXG4gICAgICByZXR1cm4gbmRpZmZcbiAgICB9XG4gIH1cblxuICBtdXRhYmxlTWVyZ2UodGFyZ2V0LCBzb3VyY2Upe1xuICAgIGlmKHNvdXJjZVtTVEFUSUNdICE9PSB1bmRlZmluZWQpe1xuICAgICAgcmV0dXJuIHNvdXJjZVxuICAgIH0gZWxzZSB7XG4gICAgICB0aGlzLmRvTXV0YWJsZU1lcmdlKHRhcmdldCwgc291cmNlKVxuICAgICAgcmV0dXJuIHRhcmdldFxuICAgIH1cbiAgfVxuXG4gIGRvTXV0YWJsZU1lcmdlKHRhcmdldCwgc291cmNlKXtcbiAgICBmb3IobGV0IGtleSBpbiBzb3VyY2Upe1xuICAgICAgbGV0IHZhbCA9IHNvdXJjZVtrZXldXG4gICAgICBsZXQgdGFyZ2V0VmFsID0gdGFyZ2V0W2tleV1cbiAgICAgIGxldCBpc09ialZhbCA9IGlzT2JqZWN0KHZhbClcbiAgICAgIGlmKGlzT2JqVmFsICYmIHZhbFtTVEFUSUNdID09PSB1bmRlZmluZWQgJiYgaXNPYmplY3QodGFyZ2V0VmFsKSl7XG4gICAgICAgIHRoaXMuZG9NdXRhYmxlTWVyZ2UodGFyZ2V0VmFsLCB2YWwpXG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0YXJnZXRba2V5XSA9IHZhbFxuICAgICAgfVxuICAgIH1cbiAgfVxuXG4gIGNsb25lTWVyZ2UodGFyZ2V0LCBzb3VyY2Upe1xuICAgIGxldCBtZXJnZWQgPSB7Li4udGFyZ2V0LCAuLi5zb3VyY2V9XG4gICAgZm9yKGxldCBrZXkgaW4gbWVyZ2VkKXtcbiAgICAgIGxldCB2YWwgPSBzb3VyY2Vba2V5XVxuICAgICAgbGV0IHRhcmdldFZhbCA9IHRhcmdldFtrZXldXG4gICAgICBpZihpc09iamVjdCh2YWwpICYmIHZhbFtTVEFUSUNdID09PSB1bmRlZmluZWQgJiYgaXNPYmplY3QodGFyZ2V0VmFsKSl7XG4gICAgICAgIG1lcmdlZFtrZXldID0gdGhpcy5jbG9uZU1lcmdlKHRhcmdldFZhbCwgdmFsKVxuICAgICAgfVxuICAgIH1cbiAgICByZXR1cm4gbWVyZ2VkXG4gIH1cblxuICBjb21wb25lbnRUb1N0cmluZyhjaWQpe1xuICAgIGxldCBbc3RyLCBzdHJlYW1zXSA9IHRoaXMucmVjdXJzaXZlQ0lEVG9TdHJpbmcodGhpcy5yZW5kZXJlZFtDT01QT05FTlRTXSwgY2lkKVxuICAgIHJldHVybiBbc3RyLCBzdHJlYW1zXVxuICB9XG5cbiAgcHJ1bmVDSURzKGNpZHMpe1xuICAgIGNpZHMuZm9yRWFjaChjaWQgPT4gZGVsZXRlIHRoaXMucmVuZGVyZWRbQ09NUE9ORU5UU11bY2lkXSlcbiAgfVxuXG4gIC8vIHByaXZhdGVcblxuICBnZXQoKXsgcmV0dXJuIHRoaXMucmVuZGVyZWQgfVxuXG4gIGlzTmV3RmluZ2VycHJpbnQoZGlmZiA9IHt9KXsgcmV0dXJuICEhZGlmZltTVEFUSUNdIH1cblxuICB0ZW1wbGF0ZVN0YXRpYyhwYXJ0LCB0ZW1wbGF0ZXMpe1xuICAgIGlmKHR5cGVvZiAocGFydCkgPT09IFwibnVtYmVyXCIpIHtcbiAgICAgIHJldHVybiB0ZW1wbGF0ZXNbcGFydF1cbiAgICB9IGVsc2Uge1xuICAgICAgcmV0dXJuIHBhcnRcbiAgICB9XG4gIH1cblxuICB0b091dHB1dEJ1ZmZlcihyZW5kZXJlZCwgdGVtcGxhdGVzLCBvdXRwdXQpe1xuICAgIGlmKHJlbmRlcmVkW0RZTkFNSUNTXSl7IHJldHVybiB0aGlzLmNvbXByZWhlbnNpb25Ub0J1ZmZlcihyZW5kZXJlZCwgdGVtcGxhdGVzLCBvdXRwdXQpIH1cbiAgICBsZXQge1tTVEFUSUNdOiBzdGF0aWNzfSA9IHJlbmRlcmVkXG4gICAgc3RhdGljcyA9IHRoaXMudGVtcGxhdGVTdGF0aWMoc3RhdGljcywgdGVtcGxhdGVzKVxuXG4gICAgb3V0cHV0LmJ1ZmZlciArPSBzdGF0aWNzWzBdXG4gICAgZm9yKGxldCBpID0gMTsgaSA8IHN0YXRpY3MubGVuZ3RoOyBpKyspe1xuICAgICAgdGhpcy5keW5hbWljVG9CdWZmZXIocmVuZGVyZWRbaSAtIDFdLCB0ZW1wbGF0ZXMsIG91dHB1dClcbiAgICAgIG91dHB1dC5idWZmZXIgKz0gc3RhdGljc1tpXVxuICAgIH1cbiAgfVxuXG4gIGNvbXByZWhlbnNpb25Ub0J1ZmZlcihyZW5kZXJlZCwgdGVtcGxhdGVzLCBvdXRwdXQpe1xuICAgIGxldCB7W0RZTkFNSUNTXTogZHluYW1pY3MsIFtTVEFUSUNdOiBzdGF0aWNzLCBbU1RSRUFNXTogc3RyZWFtfSA9IHJlbmRlcmVkXG4gICAgbGV0IFtfaW5zZXJ0cywgZGVsZXRlSWRzXSA9IHN0cmVhbSB8fCBbe30sIFtdXVxuICAgIHN0YXRpY3MgPSB0aGlzLnRlbXBsYXRlU3RhdGljKHN0YXRpY3MsIHRlbXBsYXRlcylcbiAgICBsZXQgY29tcFRlbXBsYXRlcyA9IHRlbXBsYXRlcyB8fCByZW5kZXJlZFtURU1QTEFURVNdXG4gICAgZm9yKGxldCBkID0gMDsgZCA8IGR5bmFtaWNzLmxlbmd0aDsgZCsrKXtcbiAgICAgIGxldCBkeW5hbWljID0gZHluYW1pY3NbZF1cbiAgICAgIG91dHB1dC5idWZmZXIgKz0gc3RhdGljc1swXVxuICAgICAgZm9yKGxldCBpID0gMTsgaSA8IHN0YXRpY3MubGVuZ3RoOyBpKyspe1xuICAgICAgICB0aGlzLmR5bmFtaWNUb0J1ZmZlcihkeW5hbWljW2kgLSAxXSwgY29tcFRlbXBsYXRlcywgb3V0cHV0KVxuICAgICAgICBvdXRwdXQuYnVmZmVyICs9IHN0YXRpY3NbaV1cbiAgICAgIH1cbiAgICB9XG5cbiAgICBpZihzdHJlYW0gIT09IHVuZGVmaW5lZCAmJiAocmVuZGVyZWRbRFlOQU1JQ1NdLmxlbmd0aCA+IDAgfHwgZGVsZXRlSWRzLmxlbmd0aCA+IDApKXtcbiAgICAgIHJlbmRlcmVkW0RZTkFNSUNTXSA9IFtdXG4gICAgICBvdXRwdXQuc3RyZWFtcy5hZGQoc3RyZWFtKVxuICAgIH1cbiAgfVxuXG4gIGR5bmFtaWNUb0J1ZmZlcihyZW5kZXJlZCwgdGVtcGxhdGVzLCBvdXRwdXQpe1xuICAgIGlmKHR5cGVvZiAocmVuZGVyZWQpID09PSBcIm51bWJlclwiKXtcbiAgICAgIGxldCBbc3RyLCBzdHJlYW1zXSA9IHRoaXMucmVjdXJzaXZlQ0lEVG9TdHJpbmcob3V0cHV0LmNvbXBvbmVudHMsIHJlbmRlcmVkLCBvdXRwdXQub25seUNpZHMpXG4gICAgICBvdXRwdXQuYnVmZmVyICs9IHN0clxuICAgICAgb3V0cHV0LnN0cmVhbXMgPSBuZXcgU2V0KFsuLi5vdXRwdXQuc3RyZWFtcywgLi4uc3RyZWFtc10pXG4gICAgfSBlbHNlIGlmKGlzT2JqZWN0KHJlbmRlcmVkKSl7XG4gICAgICB0aGlzLnRvT3V0cHV0QnVmZmVyKHJlbmRlcmVkLCB0ZW1wbGF0ZXMsIG91dHB1dClcbiAgICB9IGVsc2Uge1xuICAgICAgb3V0cHV0LmJ1ZmZlciArPSByZW5kZXJlZFxuICAgIH1cbiAgfVxuXG4gIHJlY3Vyc2l2ZUNJRFRvU3RyaW5nKGNvbXBvbmVudHMsIGNpZCwgb25seUNpZHMpe1xuICAgIGxldCBjb21wb25lbnQgPSBjb21wb25lbnRzW2NpZF0gfHwgbG9nRXJyb3IoYG5vIGNvbXBvbmVudCBmb3IgQ0lEICR7Y2lkfWAsIGNvbXBvbmVudHMpXG4gICAgbGV0IHRlbXBsYXRlID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudChcInRlbXBsYXRlXCIpXG4gICAgbGV0IFtodG1sLCBzdHJlYW1zXSA9IHRoaXMucmVjdXJzaXZlVG9TdHJpbmcoY29tcG9uZW50LCBjb21wb25lbnRzLCBvbmx5Q2lkcylcbiAgICB0ZW1wbGF0ZS5pbm5lckhUTUwgPSBodG1sXG4gICAgbGV0IGNvbnRhaW5lciA9IHRlbXBsYXRlLmNvbnRlbnRcbiAgICBsZXQgc2tpcCA9IG9ubHlDaWRzICYmICFvbmx5Q2lkcy5oYXMoY2lkKVxuXG4gICAgbGV0IFtoYXNDaGlsZE5vZGVzLCBoYXNDaGlsZENvbXBvbmVudHNdID1cbiAgICAgIEFycmF5LmZyb20oY29udGFpbmVyLmNoaWxkTm9kZXMpLnJlZHVjZSgoW2hhc05vZGVzLCBoYXNDb21wb25lbnRzXSwgY2hpbGQsIGkpID0+IHtcbiAgICAgICAgaWYoY2hpbGQubm9kZVR5cGUgPT09IE5vZGUuRUxFTUVOVF9OT0RFKXtcbiAgICAgICAgICBpZihjaGlsZC5nZXRBdHRyaWJ1dGUoUEhYX0NPTVBPTkVOVCkpe1xuICAgICAgICAgICAgcmV0dXJuIFtoYXNOb2RlcywgdHJ1ZV1cbiAgICAgICAgICB9XG4gICAgICAgICAgY2hpbGQuc2V0QXR0cmlidXRlKFBIWF9DT01QT05FTlQsIGNpZClcbiAgICAgICAgICBpZighY2hpbGQuaWQpeyBjaGlsZC5pZCA9IGAke3RoaXMucGFyZW50Vmlld0lkKCl9LSR7Y2lkfS0ke2l9YCB9XG4gICAgICAgICAgaWYoc2tpcCl7XG4gICAgICAgICAgICBjaGlsZC5zZXRBdHRyaWJ1dGUoUEhYX1NLSVAsIFwiXCIpXG4gICAgICAgICAgICBjaGlsZC5pbm5lckhUTUwgPSBcIlwiXG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiBbdHJ1ZSwgaGFzQ29tcG9uZW50c11cbiAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICBpZihjaGlsZC5ub2RlVmFsdWUudHJpbSgpICE9PSBcIlwiKXtcbiAgICAgICAgICAgIGxvZ0Vycm9yKFwib25seSBIVE1MIGVsZW1lbnQgdGFncyBhcmUgYWxsb3dlZCBhdCB0aGUgcm9vdCBvZiBjb21wb25lbnRzLlxcblxcblwiICtcbiAgICAgICAgICAgICAgYGdvdDogXCIke2NoaWxkLm5vZGVWYWx1ZS50cmltKCl9XCJcXG5cXG5gICtcbiAgICAgICAgICAgICAgXCJ3aXRoaW46XFxuXCIsIHRlbXBsYXRlLmlubmVySFRNTC50cmltKCkpXG4gICAgICAgICAgICBjaGlsZC5yZXBsYWNlV2l0aCh0aGlzLmNyZWF0ZVNwYW4oY2hpbGQubm9kZVZhbHVlLCBjaWQpKVxuICAgICAgICAgICAgcmV0dXJuIFt0cnVlLCBoYXNDb21wb25lbnRzXVxuICAgICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICBjaGlsZC5yZW1vdmUoKVxuICAgICAgICAgICAgcmV0dXJuIFtoYXNOb2RlcywgaGFzQ29tcG9uZW50c11cbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICAgIH0sIFtmYWxzZSwgZmFsc2VdKVxuXG4gICAgaWYoIWhhc0NoaWxkTm9kZXMgJiYgIWhhc0NoaWxkQ29tcG9uZW50cyl7XG4gICAgICBsb2dFcnJvcihcImV4cGVjdGVkIGF0IGxlYXN0IG9uZSBIVE1MIGVsZW1lbnQgdGFnIGluc2lkZSBhIGNvbXBvbmVudCwgYnV0IHRoZSBjb21wb25lbnQgaXMgZW1wdHk6XFxuXCIsXG4gICAgICAgIHRlbXBsYXRlLmlubmVySFRNTC50cmltKCkpXG4gICAgICByZXR1cm4gW3RoaXMuY3JlYXRlU3BhbihcIlwiLCBjaWQpLm91dGVySFRNTCwgc3RyZWFtc11cbiAgICB9IGVsc2UgaWYoIWhhc0NoaWxkTm9kZXMgJiYgaGFzQ2hpbGRDb21wb25lbnRzKXtcbiAgICAgIGxvZ0Vycm9yKFwiZXhwZWN0ZWQgYXQgbGVhc3Qgb25lIEhUTUwgZWxlbWVudCB0YWcgZGlyZWN0bHkgaW5zaWRlIGEgY29tcG9uZW50LCBidXQgb25seSBzdWJjb21wb25lbnRzIHdlcmUgZm91bmQuIEEgY29tcG9uZW50IG11c3QgcmVuZGVyIGF0IGxlYXN0IG9uZSBIVE1MIHRhZyBkaXJlY3RseSBpbnNpZGUgaXRzZWxmLlwiLFxuICAgICAgICB0ZW1wbGF0ZS5pbm5lckhUTUwudHJpbSgpKVxuICAgICAgcmV0dXJuIFt0ZW1wbGF0ZS5pbm5lckhUTUwsIHN0cmVhbXNdXG4gICAgfSBlbHNlIHtcbiAgICAgIHJldHVybiBbdGVtcGxhdGUuaW5uZXJIVE1MLCBzdHJlYW1zXVxuICAgIH1cbiAgfVxuXG4gIGNyZWF0ZVNwYW4odGV4dCwgY2lkKXtcbiAgICBsZXQgc3BhbiA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoXCJzcGFuXCIpXG4gICAgc3Bhbi5pbm5lclRleHQgPSB0ZXh0XG4gICAgc3Bhbi5zZXRBdHRyaWJ1dGUoUEhYX0NPTVBPTkVOVCwgY2lkKVxuICAgIHJldHVybiBzcGFuXG4gIH1cbn1cbiIsICJsZXQgdmlld0hvb2tJRCA9IDFcbmV4cG9ydCBkZWZhdWx0IGNsYXNzIFZpZXdIb29rIHtcbiAgc3RhdGljIG1ha2VJRCgpeyByZXR1cm4gdmlld0hvb2tJRCsrIH1cbiAgc3RhdGljIGVsZW1lbnRJRChlbCl7IHJldHVybiBlbC5waHhIb29rSWQgfVxuXG4gIGNvbnN0cnVjdG9yKHZpZXcsIGVsLCBjYWxsYmFja3Mpe1xuICAgIHRoaXMuX192aWV3ID0gdmlld1xuICAgIHRoaXMubGl2ZVNvY2tldCA9IHZpZXcubGl2ZVNvY2tldFxuICAgIHRoaXMuX19jYWxsYmFja3MgPSBjYWxsYmFja3NcbiAgICB0aGlzLl9fbGlzdGVuZXJzID0gbmV3IFNldCgpXG4gICAgdGhpcy5fX2lzRGlzY29ubmVjdGVkID0gZmFsc2VcbiAgICB0aGlzLmVsID0gZWxcbiAgICB0aGlzLmVsLnBoeEhvb2tJZCA9IHRoaXMuY29uc3RydWN0b3IubWFrZUlEKClcbiAgICBmb3IobGV0IGtleSBpbiB0aGlzLl9fY2FsbGJhY2tzKXsgdGhpc1trZXldID0gdGhpcy5fX2NhbGxiYWNrc1trZXldIH1cbiAgfVxuXG4gIF9fbW91bnRlZCgpeyB0aGlzLm1vdW50ZWQgJiYgdGhpcy5tb3VudGVkKCkgfVxuICBfX3VwZGF0ZWQoKXsgdGhpcy51cGRhdGVkICYmIHRoaXMudXBkYXRlZCgpIH1cbiAgX19iZWZvcmVVcGRhdGUoKXsgdGhpcy5iZWZvcmVVcGRhdGUgJiYgdGhpcy5iZWZvcmVVcGRhdGUoKSB9XG4gIF9fZGVzdHJveWVkKCl7IHRoaXMuZGVzdHJveWVkICYmIHRoaXMuZGVzdHJveWVkKCkgfVxuICBfX3JlY29ubmVjdGVkKCl7XG4gICAgaWYodGhpcy5fX2lzRGlzY29ubmVjdGVkKXtcbiAgICAgIHRoaXMuX19pc0Rpc2Nvbm5lY3RlZCA9IGZhbHNlXG4gICAgICB0aGlzLnJlY29ubmVjdGVkICYmIHRoaXMucmVjb25uZWN0ZWQoKVxuICAgIH1cbiAgfVxuICBfX2Rpc2Nvbm5lY3RlZCgpe1xuICAgIHRoaXMuX19pc0Rpc2Nvbm5lY3RlZCA9IHRydWVcbiAgICB0aGlzLmRpc2Nvbm5lY3RlZCAmJiB0aGlzLmRpc2Nvbm5lY3RlZCgpXG4gIH1cblxuICBwdXNoRXZlbnQoZXZlbnQsIHBheWxvYWQgPSB7fSwgb25SZXBseSA9IGZ1bmN0aW9uICgpeyB9KXtcbiAgICByZXR1cm4gdGhpcy5fX3ZpZXcucHVzaEhvb2tFdmVudChudWxsLCBldmVudCwgcGF5bG9hZCwgb25SZXBseSlcbiAgfVxuXG4gIHB1c2hFdmVudFRvKHBoeFRhcmdldCwgZXZlbnQsIHBheWxvYWQgPSB7fSwgb25SZXBseSA9IGZ1bmN0aW9uICgpeyB9KXtcbiAgICByZXR1cm4gdGhpcy5fX3ZpZXcud2l0aGluVGFyZ2V0cyhwaHhUYXJnZXQsICh2aWV3LCB0YXJnZXRDdHgpID0+IHtcbiAgICAgIHJldHVybiB2aWV3LnB1c2hIb29rRXZlbnQodGFyZ2V0Q3R4LCBldmVudCwgcGF5bG9hZCwgb25SZXBseSlcbiAgICB9KVxuICB9XG5cbiAgaGFuZGxlRXZlbnQoZXZlbnQsIGNhbGxiYWNrKXtcbiAgICBsZXQgY2FsbGJhY2tSZWYgPSAoY3VzdG9tRXZlbnQsIGJ5cGFzcykgPT4gYnlwYXNzID8gZXZlbnQgOiBjYWxsYmFjayhjdXN0b21FdmVudC5kZXRhaWwpXG4gICAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoYHBoeDoke2V2ZW50fWAsIGNhbGxiYWNrUmVmKVxuICAgIHRoaXMuX19saXN0ZW5lcnMuYWRkKGNhbGxiYWNrUmVmKVxuICAgIHJldHVybiBjYWxsYmFja1JlZlxuICB9XG5cbiAgcmVtb3ZlSGFuZGxlRXZlbnQoY2FsbGJhY2tSZWYpe1xuICAgIGxldCBldmVudCA9IGNhbGxiYWNrUmVmKG51bGwsIHRydWUpXG4gICAgd2luZG93LnJlbW92ZUV2ZW50TGlzdGVuZXIoYHBoeDoke2V2ZW50fWAsIGNhbGxiYWNrUmVmKVxuICAgIHRoaXMuX19saXN0ZW5lcnMuZGVsZXRlKGNhbGxiYWNrUmVmKVxuICB9XG5cbiAgdXBsb2FkKG5hbWUsIGZpbGVzKXtcbiAgICByZXR1cm4gdGhpcy5fX3ZpZXcuZGlzcGF0Y2hVcGxvYWRzKG5hbWUsIGZpbGVzKVxuICB9XG5cbiAgdXBsb2FkVG8ocGh4VGFyZ2V0LCBuYW1lLCBmaWxlcyl7XG4gICAgcmV0dXJuIHRoaXMuX192aWV3LndpdGhpblRhcmdldHMocGh4VGFyZ2V0LCB2aWV3ID0+IHZpZXcuZGlzcGF0Y2hVcGxvYWRzKG5hbWUsIGZpbGVzKSlcbiAgfVxuXG4gIF9fY2xlYW51cF9fKCl7XG4gICAgdGhpcy5fX2xpc3RlbmVycy5mb3JFYWNoKGNhbGxiYWNrUmVmID0+IHRoaXMucmVtb3ZlSGFuZGxlRXZlbnQoY2FsbGJhY2tSZWYpKVxuICB9XG59XG4iLCAiaW1wb3J0IERPTSBmcm9tIFwiLi9kb21cIlxuaW1wb3J0IEFSSUEgZnJvbSBcIi4vYXJpYVwiXG5cbmxldCBmb2N1c1N0YWNrID0gbnVsbFxuXG5sZXQgSlMgPSB7XG4gIGV4ZWMoZXZlbnRUeXBlLCBwaHhFdmVudCwgdmlldywgc291cmNlRWwsIGRlZmF1bHRzKXtcbiAgICBsZXQgW2RlZmF1bHRLaW5kLCBkZWZhdWx0QXJnc10gPSBkZWZhdWx0cyB8fCBbbnVsbCwge31dXG4gICAgbGV0IGNvbW1hbmRzID0gcGh4RXZlbnQuY2hhckF0KDApID09PSBcIltcIiA/XG4gICAgICBKU09OLnBhcnNlKHBoeEV2ZW50KSA6IFtbZGVmYXVsdEtpbmQsIGRlZmF1bHRBcmdzXV1cblxuICAgIGNvbW1hbmRzLmZvckVhY2goKFtraW5kLCBhcmdzXSkgPT4ge1xuICAgICAgaWYoa2luZCA9PT0gZGVmYXVsdEtpbmQgJiYgZGVmYXVsdEFyZ3MuZGF0YSl7XG4gICAgICAgIGFyZ3MuZGF0YSA9IE9iamVjdC5hc3NpZ24oYXJncy5kYXRhIHx8IHt9LCBkZWZhdWx0QXJncy5kYXRhKVxuICAgICAgfVxuICAgICAgdGhpcy5maWx0ZXJUb0Vscyhzb3VyY2VFbCwgYXJncykuZm9yRWFjaChlbCA9PiB7XG4gICAgICAgIHRoaXNbYGV4ZWNfJHtraW5kfWBdKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCwgYXJncylcbiAgICAgIH0pXG4gICAgfSlcbiAgfSxcblxuICBpc1Zpc2libGUoZWwpe1xuICAgIHJldHVybiAhIShlbC5vZmZzZXRXaWR0aCB8fCBlbC5vZmZzZXRIZWlnaHQgfHwgZWwuZ2V0Q2xpZW50UmVjdHMoKS5sZW5ndGggPiAwKVxuICB9LFxuXG4gIC8vIHByaXZhdGVcblxuICAvLyBjb21tYW5kc1xuXG4gIGV4ZWNfZXhlYyhldmVudFR5cGUsIHBoeEV2ZW50LCB2aWV3LCBzb3VyY2VFbCwgZWwsIFthdHRyLCB0b10pe1xuICAgIGxldCBub2RlcyA9IHRvID8gRE9NLmFsbChkb2N1bWVudCwgdG8pIDogW3NvdXJjZUVsXVxuICAgIG5vZGVzLmZvckVhY2gobm9kZSA9PiB7XG4gICAgICBsZXQgZW5jb2RlZEpTID0gbm9kZS5nZXRBdHRyaWJ1dGUoYXR0cilcbiAgICAgIGlmKCFlbmNvZGVkSlMpeyB0aHJvdyBuZXcgRXJyb3IoYGV4cGVjdGVkICR7YXR0cn0gdG8gY29udGFpbiBKUyBjb21tYW5kIG9uIFwiJHt0b31cImApIH1cbiAgICAgIHZpZXcubGl2ZVNvY2tldC5leGVjSlMobm9kZSwgZW5jb2RlZEpTLCBldmVudFR5cGUpXG4gICAgfSlcbiAgfSxcblxuICBleGVjX2Rpc3BhdGNoKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCwge3RvLCBldmVudCwgZGV0YWlsLCBidWJibGVzfSl7XG4gICAgZGV0YWlsID0gZGV0YWlsIHx8IHt9XG4gICAgZGV0YWlsLmRpc3BhdGNoZXIgPSBzb3VyY2VFbFxuICAgIERPTS5kaXNwYXRjaEV2ZW50KGVsLCBldmVudCwge2RldGFpbCwgYnViYmxlc30pXG4gIH0sXG5cbiAgZXhlY19wdXNoKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCwgYXJncyl7XG4gICAgaWYoIXZpZXcuaXNDb25uZWN0ZWQoKSl7IHJldHVybiB9XG5cbiAgICBsZXQge2V2ZW50LCBkYXRhLCB0YXJnZXQsIHBhZ2VfbG9hZGluZywgbG9hZGluZywgdmFsdWUsIGRpc3BhdGNoZXJ9ID0gYXJnc1xuICAgIGxldCBwdXNoT3B0cyA9IHtsb2FkaW5nLCB2YWx1ZSwgdGFyZ2V0LCBwYWdlX2xvYWRpbmc6ICEhcGFnZV9sb2FkaW5nfVxuICAgIGxldCB0YXJnZXRTcmMgPSBldmVudFR5cGUgPT09IFwiY2hhbmdlXCIgJiYgZGlzcGF0Y2hlciA/IGRpc3BhdGNoZXIgOiBzb3VyY2VFbFxuICAgIGxldCBwaHhUYXJnZXQgPSB0YXJnZXQgfHwgdGFyZ2V0U3JjLmdldEF0dHJpYnV0ZSh2aWV3LmJpbmRpbmcoXCJ0YXJnZXRcIikpIHx8IHRhcmdldFNyY1xuICAgIHZpZXcud2l0aGluVGFyZ2V0cyhwaHhUYXJnZXQsICh0YXJnZXRWaWV3LCB0YXJnZXRDdHgpID0+IHtcbiAgICAgIGlmKGV2ZW50VHlwZSA9PT0gXCJjaGFuZ2VcIil7XG4gICAgICAgIGxldCB7bmV3Q2lkLCBfdGFyZ2V0LCBjYWxsYmFja30gPSBhcmdzXG4gICAgICAgIF90YXJnZXQgPSBfdGFyZ2V0IHx8IChET00uaXNGb3JtSW5wdXQoc291cmNlRWwpID8gc291cmNlRWwubmFtZSA6IHVuZGVmaW5lZClcbiAgICAgICAgaWYoX3RhcmdldCl7IHB1c2hPcHRzLl90YXJnZXQgPSBfdGFyZ2V0IH1cbiAgICAgICAgdGFyZ2V0Vmlldy5wdXNoSW5wdXQoc291cmNlRWwsIHRhcmdldEN0eCwgbmV3Q2lkLCBldmVudCB8fCBwaHhFdmVudCwgcHVzaE9wdHMsIGNhbGxiYWNrKVxuICAgICAgfSBlbHNlIGlmKGV2ZW50VHlwZSA9PT0gXCJzdWJtaXRcIil7XG4gICAgICAgIGxldCB7c3VibWl0dGVyfSA9IGFyZ3NcbiAgICAgICAgdGFyZ2V0Vmlldy5zdWJtaXRGb3JtKHNvdXJjZUVsLCB0YXJnZXRDdHgsIGV2ZW50IHx8IHBoeEV2ZW50LCBzdWJtaXR0ZXIsIHB1c2hPcHRzKVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGFyZ2V0Vmlldy5wdXNoRXZlbnQoZXZlbnRUeXBlLCBzb3VyY2VFbCwgdGFyZ2V0Q3R4LCBldmVudCB8fCBwaHhFdmVudCwgZGF0YSwgcHVzaE9wdHMpXG4gICAgICB9XG4gICAgfSlcbiAgfSxcblxuICBleGVjX25hdmlnYXRlKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCwge2hyZWYsIHJlcGxhY2V9KXtcbiAgICB2aWV3LmxpdmVTb2NrZXQuaGlzdG9yeVJlZGlyZWN0KGhyZWYsIHJlcGxhY2UgPyBcInJlcGxhY2VcIiA6IFwicHVzaFwiKVxuICB9LFxuXG4gIGV4ZWNfcGF0Y2goZXZlbnRUeXBlLCBwaHhFdmVudCwgdmlldywgc291cmNlRWwsIGVsLCB7aHJlZiwgcmVwbGFjZX0pe1xuICAgIHZpZXcubGl2ZVNvY2tldC5wdXNoSGlzdG9yeVBhdGNoKGhyZWYsIHJlcGxhY2UgPyBcInJlcGxhY2VcIiA6IFwicHVzaFwiLCBzb3VyY2VFbClcbiAgfSxcblxuICBleGVjX2ZvY3VzKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCl7XG4gICAgd2luZG93LnJlcXVlc3RBbmltYXRpb25GcmFtZSgoKSA9PiBBUklBLmF0dGVtcHRGb2N1cyhlbCkpXG4gIH0sXG5cbiAgZXhlY19mb2N1c19maXJzdChldmVudFR5cGUsIHBoeEV2ZW50LCB2aWV3LCBzb3VyY2VFbCwgZWwpe1xuICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUoKCkgPT4gQVJJQS5mb2N1c0ZpcnN0SW50ZXJhY3RpdmUoZWwpIHx8IEFSSUEuZm9jdXNGaXJzdChlbCkpXG4gIH0sXG5cbiAgZXhlY19wdXNoX2ZvY3VzKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCl7XG4gICAgd2luZG93LnJlcXVlc3RBbmltYXRpb25GcmFtZSgoKSA9PiBmb2N1c1N0YWNrID0gZWwgfHwgc291cmNlRWwpXG4gIH0sXG5cbiAgZXhlY19wb3BfZm9jdXMoZXZlbnRUeXBlLCBwaHhFdmVudCwgdmlldywgc291cmNlRWwsIGVsKXtcbiAgICB3aW5kb3cucmVxdWVzdEFuaW1hdGlvbkZyYW1lKCgpID0+IHtcbiAgICAgIGlmKGZvY3VzU3RhY2speyBmb2N1c1N0YWNrLmZvY3VzKCkgfVxuICAgICAgZm9jdXNTdGFjayA9IG51bGxcbiAgICB9KVxuICB9LFxuXG4gIGV4ZWNfYWRkX2NsYXNzKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCwge25hbWVzLCB0cmFuc2l0aW9uLCB0aW1lfSl7XG4gICAgdGhpcy5hZGRPclJlbW92ZUNsYXNzZXMoZWwsIG5hbWVzLCBbXSwgdHJhbnNpdGlvbiwgdGltZSwgdmlldylcbiAgfSxcblxuICBleGVjX3JlbW92ZV9jbGFzcyhldmVudFR5cGUsIHBoeEV2ZW50LCB2aWV3LCBzb3VyY2VFbCwgZWwsIHtuYW1lcywgdHJhbnNpdGlvbiwgdGltZX0pe1xuICAgIHRoaXMuYWRkT3JSZW1vdmVDbGFzc2VzKGVsLCBbXSwgbmFtZXMsIHRyYW5zaXRpb24sIHRpbWUsIHZpZXcpXG4gIH0sXG5cbiAgZXhlY190cmFuc2l0aW9uKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCwge3RpbWUsIHRyYW5zaXRpb259KXtcbiAgICB0aGlzLmFkZE9yUmVtb3ZlQ2xhc3NlcyhlbCwgW10sIFtdLCB0cmFuc2l0aW9uLCB0aW1lLCB2aWV3KVxuICB9LFxuXG4gIGV4ZWNfdG9nZ2xlKGV2ZW50VHlwZSwgcGh4RXZlbnQsIHZpZXcsIHNvdXJjZUVsLCBlbCwge2Rpc3BsYXksIGlucywgb3V0cywgdGltZX0pe1xuICAgIHRoaXMudG9nZ2xlKGV2ZW50VHlwZSwgdmlldywgZWwsIGRpc3BsYXksIGlucywgb3V0cywgdGltZSlcbiAgfSxcblxuICBleGVjX3Nob3coZXZlbnRUeXBlLCBwaHhFdmVudCwgdmlldywgc291cmNlRWwsIGVsLCB7ZGlzcGxheSwgdHJhbnNpdGlvbiwgdGltZX0pe1xuICAgIHRoaXMuc2hvdyhldmVudFR5cGUsIHZpZXcsIGVsLCBkaXNwbGF5LCB0cmFuc2l0aW9uLCB0aW1lKVxuICB9LFxuXG4gIGV4ZWNfaGlkZShldmVudFR5cGUsIHBoeEV2ZW50LCB2aWV3LCBzb3VyY2VFbCwgZWwsIHtkaXNwbGF5LCB0cmFuc2l0aW9uLCB0aW1lfSl7XG4gICAgdGhpcy5oaWRlKGV2ZW50VHlwZSwgdmlldywgZWwsIGRpc3BsYXksIHRyYW5zaXRpb24sIHRpbWUpXG4gIH0sXG5cbiAgZXhlY19zZXRfYXR0cihldmVudFR5cGUsIHBoeEV2ZW50LCB2aWV3LCBzb3VyY2VFbCwgZWwsIHthdHRyOiBbYXR0ciwgdmFsXX0pe1xuICAgIHRoaXMuc2V0T3JSZW1vdmVBdHRycyhlbCwgW1thdHRyLCB2YWxdXSwgW10pXG4gIH0sXG5cbiAgZXhlY19yZW1vdmVfYXR0cihldmVudFR5cGUsIHBoeEV2ZW50LCB2aWV3LCBzb3VyY2VFbCwgZWwsIHthdHRyfSl7XG4gICAgdGhpcy5zZXRPclJlbW92ZUF0dHJzKGVsLCBbXSwgW2F0dHJdKVxuICB9LFxuXG4gIC8vIHV0aWxzIGZvciBjb21tYW5kc1xuXG4gIHNob3coZXZlbnRUeXBlLCB2aWV3LCBlbCwgZGlzcGxheSwgdHJhbnNpdGlvbiwgdGltZSl7XG4gICAgaWYoIXRoaXMuaXNWaXNpYmxlKGVsKSl7XG4gICAgICB0aGlzLnRvZ2dsZShldmVudFR5cGUsIHZpZXcsIGVsLCBkaXNwbGF5LCB0cmFuc2l0aW9uLCBudWxsLCB0aW1lKVxuICAgIH1cbiAgfSxcblxuICBoaWRlKGV2ZW50VHlwZSwgdmlldywgZWwsIGRpc3BsYXksIHRyYW5zaXRpb24sIHRpbWUpe1xuICAgIGlmKHRoaXMuaXNWaXNpYmxlKGVsKSl7XG4gICAgICB0aGlzLnRvZ2dsZShldmVudFR5cGUsIHZpZXcsIGVsLCBkaXNwbGF5LCBudWxsLCB0cmFuc2l0aW9uLCB0aW1lKVxuICAgIH1cbiAgfSxcblxuICB0b2dnbGUoZXZlbnRUeXBlLCB2aWV3LCBlbCwgZGlzcGxheSwgaW5zLCBvdXRzLCB0aW1lKXtcbiAgICBsZXQgW2luQ2xhc3NlcywgaW5TdGFydENsYXNzZXMsIGluRW5kQ2xhc3Nlc10gPSBpbnMgfHwgW1tdLCBbXSwgW11dXG4gICAgbGV0IFtvdXRDbGFzc2VzLCBvdXRTdGFydENsYXNzZXMsIG91dEVuZENsYXNzZXNdID0gb3V0cyB8fCBbW10sIFtdLCBbXV1cbiAgICBpZihpbkNsYXNzZXMubGVuZ3RoID4gMCB8fCBvdXRDbGFzc2VzLmxlbmd0aCA+IDApe1xuICAgICAgaWYodGhpcy5pc1Zpc2libGUoZWwpKXtcbiAgICAgICAgbGV0IG9uU3RhcnQgPSAoKSA9PiB7XG4gICAgICAgICAgdGhpcy5hZGRPclJlbW92ZUNsYXNzZXMoZWwsIG91dFN0YXJ0Q2xhc3NlcywgaW5DbGFzc2VzLmNvbmNhdChpblN0YXJ0Q2xhc3NlcykuY29uY2F0KGluRW5kQ2xhc3NlcykpXG4gICAgICAgICAgd2luZG93LnJlcXVlc3RBbmltYXRpb25GcmFtZSgoKSA9PiB7XG4gICAgICAgICAgICB0aGlzLmFkZE9yUmVtb3ZlQ2xhc3NlcyhlbCwgb3V0Q2xhc3NlcywgW10pXG4gICAgICAgICAgICB3aW5kb3cucmVxdWVzdEFuaW1hdGlvbkZyYW1lKCgpID0+IHRoaXMuYWRkT3JSZW1vdmVDbGFzc2VzKGVsLCBvdXRFbmRDbGFzc2VzLCBvdXRTdGFydENsYXNzZXMpKVxuICAgICAgICAgIH0pXG4gICAgICAgIH1cbiAgICAgICAgZWwuZGlzcGF0Y2hFdmVudChuZXcgRXZlbnQoXCJwaHg6aGlkZS1zdGFydFwiKSlcbiAgICAgICAgdmlldy50cmFuc2l0aW9uKHRpbWUsIG9uU3RhcnQsICgpID0+IHtcbiAgICAgICAgICB0aGlzLmFkZE9yUmVtb3ZlQ2xhc3NlcyhlbCwgW10sIG91dENsYXNzZXMuY29uY2F0KG91dEVuZENsYXNzZXMpKVxuICAgICAgICAgIERPTS5wdXRTdGlja3koZWwsIFwidG9nZ2xlXCIsIGN1cnJlbnRFbCA9PiBjdXJyZW50RWwuc3R5bGUuZGlzcGxheSA9IFwibm9uZVwiKVxuICAgICAgICAgIGVsLmRpc3BhdGNoRXZlbnQobmV3IEV2ZW50KFwicGh4OmhpZGUtZW5kXCIpKVxuICAgICAgICB9KVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgaWYoZXZlbnRUeXBlID09PSBcInJlbW92ZVwiKXsgcmV0dXJuIH1cbiAgICAgICAgbGV0IG9uU3RhcnQgPSAoKSA9PiB7XG4gICAgICAgICAgdGhpcy5hZGRPclJlbW92ZUNsYXNzZXMoZWwsIGluU3RhcnRDbGFzc2VzLCBvdXRDbGFzc2VzLmNvbmNhdChvdXRTdGFydENsYXNzZXMpLmNvbmNhdChvdXRFbmRDbGFzc2VzKSlcbiAgICAgICAgICBsZXQgc3RpY2t5RGlzcGxheSA9IGRpc3BsYXkgfHwgdGhpcy5kZWZhdWx0RGlzcGxheShlbClcbiAgICAgICAgICBET00ucHV0U3RpY2t5KGVsLCBcInRvZ2dsZVwiLCBjdXJyZW50RWwgPT4gY3VycmVudEVsLnN0eWxlLmRpc3BsYXkgPSBzdGlja3lEaXNwbGF5KVxuICAgICAgICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUoKCkgPT4ge1xuICAgICAgICAgICAgdGhpcy5hZGRPclJlbW92ZUNsYXNzZXMoZWwsIGluQ2xhc3NlcywgW10pXG4gICAgICAgICAgICB3aW5kb3cucmVxdWVzdEFuaW1hdGlvbkZyYW1lKCgpID0+IHRoaXMuYWRkT3JSZW1vdmVDbGFzc2VzKGVsLCBpbkVuZENsYXNzZXMsIGluU3RhcnRDbGFzc2VzKSlcbiAgICAgICAgICB9KVxuICAgICAgICB9XG4gICAgICAgIGVsLmRpc3BhdGNoRXZlbnQobmV3IEV2ZW50KFwicGh4OnNob3ctc3RhcnRcIikpXG4gICAgICAgIHZpZXcudHJhbnNpdGlvbih0aW1lLCBvblN0YXJ0LCAoKSA9PiB7XG4gICAgICAgICAgdGhpcy5hZGRPclJlbW92ZUNsYXNzZXMoZWwsIFtdLCBpbkNsYXNzZXMuY29uY2F0KGluRW5kQ2xhc3NlcykpXG4gICAgICAgICAgZWwuZGlzcGF0Y2hFdmVudChuZXcgRXZlbnQoXCJwaHg6c2hvdy1lbmRcIikpXG4gICAgICAgIH0pXG4gICAgICB9XG4gICAgfSBlbHNlIHtcbiAgICAgIGlmKHRoaXMuaXNWaXNpYmxlKGVsKSl7XG4gICAgICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUoKCkgPT4ge1xuICAgICAgICAgIGVsLmRpc3BhdGNoRXZlbnQobmV3IEV2ZW50KFwicGh4OmhpZGUtc3RhcnRcIikpXG4gICAgICAgICAgRE9NLnB1dFN0aWNreShlbCwgXCJ0b2dnbGVcIiwgY3VycmVudEVsID0+IGN1cnJlbnRFbC5zdHlsZS5kaXNwbGF5ID0gXCJub25lXCIpXG4gICAgICAgICAgZWwuZGlzcGF0Y2hFdmVudChuZXcgRXZlbnQoXCJwaHg6aGlkZS1lbmRcIikpXG4gICAgICAgIH0pXG4gICAgICB9IGVsc2Uge1xuICAgICAgICB3aW5kb3cucmVxdWVzdEFuaW1hdGlvbkZyYW1lKCgpID0+IHtcbiAgICAgICAgICBlbC5kaXNwYXRjaEV2ZW50KG5ldyBFdmVudChcInBoeDpzaG93LXN0YXJ0XCIpKVxuICAgICAgICAgIGxldCBzdGlja3lEaXNwbGF5ID0gZGlzcGxheSB8fCB0aGlzLmRlZmF1bHREaXNwbGF5KGVsKVxuICAgICAgICAgIERPTS5wdXRTdGlja3koZWwsIFwidG9nZ2xlXCIsIGN1cnJlbnRFbCA9PiBjdXJyZW50RWwuc3R5bGUuZGlzcGxheSA9IHN0aWNreURpc3BsYXkpXG4gICAgICAgICAgZWwuZGlzcGF0Y2hFdmVudChuZXcgRXZlbnQoXCJwaHg6c2hvdy1lbmRcIikpXG4gICAgICAgIH0pXG4gICAgICB9XG4gICAgfVxuICB9LFxuXG4gIGFkZE9yUmVtb3ZlQ2xhc3NlcyhlbCwgYWRkcywgcmVtb3ZlcywgdHJhbnNpdGlvbiwgdGltZSwgdmlldyl7XG4gICAgbGV0IFt0cmFuc2l0aW9uX3J1biwgdHJhbnNpdGlvbl9zdGFydCwgdHJhbnNpdGlvbl9lbmRdID0gdHJhbnNpdGlvbiB8fCBbW10sIFtdLCBbXV1cbiAgICBpZih0cmFuc2l0aW9uX3J1bi5sZW5ndGggPiAwKXtcbiAgICAgIGxldCBvblN0YXJ0ID0gKCkgPT4gdGhpcy5hZGRPclJlbW92ZUNsYXNzZXMoZWwsIHRyYW5zaXRpb25fc3RhcnQuY29uY2F0KHRyYW5zaXRpb25fcnVuKSwgW10pXG4gICAgICBsZXQgb25Eb25lID0gKCkgPT4gdGhpcy5hZGRPclJlbW92ZUNsYXNzZXMoZWwsIGFkZHMuY29uY2F0KHRyYW5zaXRpb25fZW5kKSwgcmVtb3Zlcy5jb25jYXQodHJhbnNpdGlvbl9ydW4pLmNvbmNhdCh0cmFuc2l0aW9uX3N0YXJ0KSlcbiAgICAgIHJldHVybiB2aWV3LnRyYW5zaXRpb24odGltZSwgb25TdGFydCwgb25Eb25lKVxuICAgIH1cbiAgICB3aW5kb3cucmVxdWVzdEFuaW1hdGlvbkZyYW1lKCgpID0+IHtcbiAgICAgIGxldCBbcHJldkFkZHMsIHByZXZSZW1vdmVzXSA9IERPTS5nZXRTdGlja3koZWwsIFwiY2xhc3Nlc1wiLCBbW10sIFtdXSlcbiAgICAgIGxldCBrZWVwQWRkcyA9IGFkZHMuZmlsdGVyKG5hbWUgPT4gcHJldkFkZHMuaW5kZXhPZihuYW1lKSA8IDAgJiYgIWVsLmNsYXNzTGlzdC5jb250YWlucyhuYW1lKSlcbiAgICAgIGxldCBrZWVwUmVtb3ZlcyA9IHJlbW92ZXMuZmlsdGVyKG5hbWUgPT4gcHJldlJlbW92ZXMuaW5kZXhPZihuYW1lKSA8IDAgJiYgZWwuY2xhc3NMaXN0LmNvbnRhaW5zKG5hbWUpKVxuICAgICAgbGV0IG5ld0FkZHMgPSBwcmV2QWRkcy5maWx0ZXIobmFtZSA9PiByZW1vdmVzLmluZGV4T2YobmFtZSkgPCAwKS5jb25jYXQoa2VlcEFkZHMpXG4gICAgICBsZXQgbmV3UmVtb3ZlcyA9IHByZXZSZW1vdmVzLmZpbHRlcihuYW1lID0+IGFkZHMuaW5kZXhPZihuYW1lKSA8IDApLmNvbmNhdChrZWVwUmVtb3ZlcylcblxuICAgICAgRE9NLnB1dFN0aWNreShlbCwgXCJjbGFzc2VzXCIsIGN1cnJlbnRFbCA9PiB7XG4gICAgICAgIGN1cnJlbnRFbC5jbGFzc0xpc3QucmVtb3ZlKC4uLm5ld1JlbW92ZXMpXG4gICAgICAgIGN1cnJlbnRFbC5jbGFzc0xpc3QuYWRkKC4uLm5ld0FkZHMpXG4gICAgICAgIHJldHVybiBbbmV3QWRkcywgbmV3UmVtb3Zlc11cbiAgICAgIH0pXG4gICAgfSlcbiAgfSxcblxuICBzZXRPclJlbW92ZUF0dHJzKGVsLCBzZXRzLCByZW1vdmVzKXtcbiAgICBsZXQgW3ByZXZTZXRzLCBwcmV2UmVtb3Zlc10gPSBET00uZ2V0U3RpY2t5KGVsLCBcImF0dHJzXCIsIFtbXSwgW11dKVxuXG4gICAgbGV0IGFsdGVyZWRBdHRycyA9IHNldHMubWFwKChbYXR0ciwgX3ZhbF0pID0+IGF0dHIpLmNvbmNhdChyZW1vdmVzKTtcbiAgICBsZXQgbmV3U2V0cyA9IHByZXZTZXRzLmZpbHRlcigoW2F0dHIsIF92YWxdKSA9PiAhYWx0ZXJlZEF0dHJzLmluY2x1ZGVzKGF0dHIpKS5jb25jYXQoc2V0cyk7XG4gICAgbGV0IG5ld1JlbW92ZXMgPSBwcmV2UmVtb3Zlcy5maWx0ZXIoKGF0dHIpID0+ICFhbHRlcmVkQXR0cnMuaW5jbHVkZXMoYXR0cikpLmNvbmNhdChyZW1vdmVzKTtcblxuICAgIERPTS5wdXRTdGlja3koZWwsIFwiYXR0cnNcIiwgY3VycmVudEVsID0+IHtcbiAgICAgIG5ld1JlbW92ZXMuZm9yRWFjaChhdHRyID0+IGN1cnJlbnRFbC5yZW1vdmVBdHRyaWJ1dGUoYXR0cikpXG4gICAgICBuZXdTZXRzLmZvckVhY2goKFthdHRyLCB2YWxdKSA9PiBjdXJyZW50RWwuc2V0QXR0cmlidXRlKGF0dHIsIHZhbCkpXG4gICAgICByZXR1cm4gW25ld1NldHMsIG5ld1JlbW92ZXNdXG4gICAgfSlcbiAgfSxcblxuICBoYXNBbGxDbGFzc2VzKGVsLCBjbGFzc2VzKXsgcmV0dXJuIGNsYXNzZXMuZXZlcnkobmFtZSA9PiBlbC5jbGFzc0xpc3QuY29udGFpbnMobmFtZSkpIH0sXG5cbiAgaXNUb2dnbGVkT3V0KGVsLCBvdXRDbGFzc2VzKXtcbiAgICByZXR1cm4gIXRoaXMuaXNWaXNpYmxlKGVsKSB8fCB0aGlzLmhhc0FsbENsYXNzZXMoZWwsIG91dENsYXNzZXMpXG4gIH0sXG5cbiAgZmlsdGVyVG9FbHMoc291cmNlRWwsIHt0b30pe1xuICAgIHJldHVybiB0byA/IERPTS5hbGwoZG9jdW1lbnQsIHRvKSA6IFtzb3VyY2VFbF1cbiAgfSxcblxuICBkZWZhdWx0RGlzcGxheShlbCl7XG4gICAgcmV0dXJuIHt0cjogXCJ0YWJsZS1yb3dcIiwgdGQ6IFwidGFibGUtY2VsbFwifVtlbC50YWdOYW1lLnRvTG93ZXJDYXNlKCldIHx8IFwiYmxvY2tcIlxuICB9XG59XG5cbmV4cG9ydCBkZWZhdWx0IEpTXG4iLCAiaW1wb3J0IHtcbiAgQkVGT1JFX1VOTE9BRF9MT0FERVJfVElNRU9VVCxcbiAgQ0hFQ0tBQkxFX0lOUFVUUyxcbiAgQ09OU0VDVVRJVkVfUkVMT0FEUyxcbiAgUEhYX0FVVE9fUkVDT1ZFUixcbiAgUEhYX0NPTVBPTkVOVCxcbiAgUEhYX0NPTk5FQ1RFRF9DTEFTUyxcbiAgUEhYX0RJU0FCTEVfV0lUSCxcbiAgUEhYX0RJU0FCTEVfV0lUSF9SRVNUT1JFLFxuICBQSFhfRElTQUJMRUQsXG4gIFBIWF9ESVNDT05ORUNURURfQ0xBU1MsXG4gIFBIWF9FVkVOVF9DTEFTU0VTLFxuICBQSFhfRVJST1JfQ0xBU1MsXG4gIFBIWF9GRUVEQkFDS19GT1IsXG4gIFBIWF9IQVNfU1VCTUlUVEVELFxuICBQSFhfSE9PSyxcbiAgUEhYX1BBR0VfTE9BRElORyxcbiAgUEhYX1BBUkVOVF9JRCxcbiAgUEhYX1BST0dSRVNTLFxuICBQSFhfUkVBRE9OTFksXG4gIFBIWF9SRUYsXG4gIFBIWF9SRUZfU1JDLFxuICBQSFhfUk9PVF9JRCxcbiAgUEhYX1NFU1NJT04sXG4gIFBIWF9TVEFUSUMsXG4gIFBIWF9UUkFDS19TVEFUSUMsXG4gIFBIWF9UUkFDS19VUExPQURTLFxuICBQSFhfVVBEQVRFLFxuICBQSFhfVVBMT0FEX1JFRixcbiAgUEhYX1ZJRVdfU0VMRUNUT1IsXG4gIFBIWF9NQUlOLFxuICBQSFhfTU9VTlRFRCxcbiAgUFVTSF9USU1FT1VULFxufSBmcm9tIFwiLi9jb25zdGFudHNcIlxuXG5pbXBvcnQge1xuICBjbG9uZSxcbiAgY2xvc2VzdFBoeEJpbmRpbmcsXG4gIGlzRW1wdHksXG4gIGlzRXF1YWxPYmosXG4gIGxvZ0Vycm9yLFxuICBtYXliZSxcbiAgaXNDaWQsXG59IGZyb20gXCIuL3V0aWxzXCJcblxuaW1wb3J0IEJyb3dzZXIgZnJvbSBcIi4vYnJvd3NlclwiXG5pbXBvcnQgRE9NIGZyb20gXCIuL2RvbVwiXG5pbXBvcnQgRE9NUGF0Y2ggZnJvbSBcIi4vZG9tX3BhdGNoXCJcbmltcG9ydCBMaXZlVXBsb2FkZXIgZnJvbSBcIi4vbGl2ZV91cGxvYWRlclwiXG5pbXBvcnQgUmVuZGVyZWQgZnJvbSBcIi4vcmVuZGVyZWRcIlxuaW1wb3J0IFZpZXdIb29rIGZyb20gXCIuL3ZpZXdfaG9va1wiXG5pbXBvcnQgSlMgZnJvbSBcIi4vanNcIlxuXG5sZXQgc2VyaWFsaXplRm9ybSA9IChmb3JtLCBtZXRhZGF0YSwgb25seU5hbWVzID0gW10pID0+IHtcbiAgbGV0IHtzdWJtaXR0ZXIsIC4uLm1ldGF9ID0gbWV0YWRhdGFcblxuICAvLyBUT0RPOiBSZXBsYWNlIHdpdGggYG5ldyBGb3JtRGF0YShmb3JtLCBzdWJtaXR0ZXIpYCB3aGVuIHN1cHBvcnRlZCBieSBsYXRlc3QgYnJvd3NlcnMsXG4gIC8vICAgICAgIGFuZCBtZW50aW9uIGBmb3JtZGF0YS1zdWJtaXR0ZXItcG9seWZpbGxgIGluIHRoZSBkb2NzLlxuICBsZXQgZm9ybURhdGEgPSBuZXcgRm9ybURhdGEoZm9ybSlcblxuICAvLyBUT0RPOiBSZW1vdmUgd2hlbiBGb3JtRGF0YSBjb25zdHJ1Y3RvciBzdXBwb3J0cyB0aGUgc3VibWl0dGVyIGFyZ3VtZW50LlxuICBpZiAoc3VibWl0dGVyICYmIHN1Ym1pdHRlci5oYXNBdHRyaWJ1dGUoXCJuYW1lXCIpICYmIHN1Ym1pdHRlci5mb3JtICYmIHN1Ym1pdHRlci5mb3JtID09PSBmb3JtKXtcbiAgICBmb3JtRGF0YS5hcHBlbmQoc3VibWl0dGVyLm5hbWUsIHN1Ym1pdHRlci52YWx1ZSlcbiAgfVxuXG4gIGxldCB0b1JlbW92ZSA9IFtdXG5cbiAgZm9ybURhdGEuZm9yRWFjaCgodmFsLCBrZXksIF9pbmRleCkgPT4ge1xuICAgIGlmKHZhbCBpbnN0YW5jZW9mIEZpbGUpeyB0b1JlbW92ZS5wdXNoKGtleSkgfVxuICB9KVxuXG4gIC8vIENsZWFudXAgYWZ0ZXIgYnVpbGRpbmcgZmlsZURhdGFcbiAgdG9SZW1vdmUuZm9yRWFjaChrZXkgPT4gZm9ybURhdGEuZGVsZXRlKGtleSkpXG5cbiAgbGV0IHBhcmFtcyA9IG5ldyBVUkxTZWFyY2hQYXJhbXMoKVxuICBmb3IobGV0IFtrZXksIHZhbF0gb2YgZm9ybURhdGEuZW50cmllcygpKXtcbiAgICBpZihvbmx5TmFtZXMubGVuZ3RoID09PSAwIHx8IG9ubHlOYW1lcy5pbmRleE9mKGtleSkgPj0gMCl7XG4gICAgICBwYXJhbXMuYXBwZW5kKGtleSwgdmFsKVxuICAgIH1cbiAgfVxuICBmb3IobGV0IG1ldGFLZXkgaW4gbWV0YSl7IHBhcmFtcy5hcHBlbmQobWV0YUtleSwgbWV0YVttZXRhS2V5XSkgfVxuXG4gIHJldHVybiBwYXJhbXMudG9TdHJpbmcoKVxufVxuXG5leHBvcnQgZGVmYXVsdCBjbGFzcyBWaWV3IHtcbiAgY29uc3RydWN0b3IoZWwsIGxpdmVTb2NrZXQsIHBhcmVudFZpZXcsIGZsYXNoLCBsaXZlUmVmZXJlcil7XG4gICAgdGhpcy5pc0RlYWQgPSBmYWxzZVxuICAgIHRoaXMubGl2ZVNvY2tldCA9IGxpdmVTb2NrZXRcbiAgICB0aGlzLmZsYXNoID0gZmxhc2hcbiAgICB0aGlzLnBhcmVudCA9IHBhcmVudFZpZXdcbiAgICB0aGlzLnJvb3QgPSBwYXJlbnRWaWV3ID8gcGFyZW50Vmlldy5yb290IDogdGhpc1xuICAgIHRoaXMuZWwgPSBlbFxuICAgIHRoaXMuaWQgPSB0aGlzLmVsLmlkXG4gICAgdGhpcy5yZWYgPSAwXG4gICAgdGhpcy5jaGlsZEpvaW5zID0gMFxuICAgIHRoaXMubG9hZGVyVGltZXIgPSBudWxsXG4gICAgdGhpcy5wZW5kaW5nRGlmZnMgPSBbXVxuICAgIHRoaXMucHJ1bmluZ0NJRHMgPSBbXVxuICAgIHRoaXMucmVkaXJlY3QgPSBmYWxzZVxuICAgIHRoaXMuaHJlZiA9IG51bGxcbiAgICB0aGlzLmpvaW5Db3VudCA9IHRoaXMucGFyZW50ID8gdGhpcy5wYXJlbnQuam9pbkNvdW50IC0gMSA6IDBcbiAgICB0aGlzLmpvaW5QZW5kaW5nID0gdHJ1ZVxuICAgIHRoaXMuZGVzdHJveWVkID0gZmFsc2VcbiAgICB0aGlzLmpvaW5DYWxsYmFjayA9IGZ1bmN0aW9uKG9uRG9uZSl7IG9uRG9uZSAmJiBvbkRvbmUoKSB9XG4gICAgdGhpcy5zdG9wQ2FsbGJhY2sgPSBmdW5jdGlvbigpeyB9XG4gICAgdGhpcy5wZW5kaW5nSm9pbk9wcyA9IHRoaXMucGFyZW50ID8gbnVsbCA6IFtdXG4gICAgdGhpcy52aWV3SG9va3MgPSB7fVxuICAgIHRoaXMudXBsb2FkZXJzID0ge31cbiAgICB0aGlzLmZvcm1TdWJtaXRzID0gW11cbiAgICB0aGlzLmNoaWxkcmVuID0gdGhpcy5wYXJlbnQgPyBudWxsIDoge31cbiAgICB0aGlzLnJvb3QuY2hpbGRyZW5bdGhpcy5pZF0gPSB7fVxuICAgIHRoaXMuY2hhbm5lbCA9IHRoaXMubGl2ZVNvY2tldC5jaGFubmVsKGBsdjoke3RoaXMuaWR9YCwgKCkgPT4ge1xuICAgICAgcmV0dXJuIHtcbiAgICAgICAgcmVkaXJlY3Q6IHRoaXMucmVkaXJlY3QgPyB0aGlzLmhyZWYgOiB1bmRlZmluZWQsXG4gICAgICAgIHVybDogdGhpcy5yZWRpcmVjdCA/IHVuZGVmaW5lZCA6IHRoaXMuaHJlZiB8fCB1bmRlZmluZWQsXG4gICAgICAgIHBhcmFtczogdGhpcy5jb25uZWN0UGFyYW1zKGxpdmVSZWZlcmVyKSxcbiAgICAgICAgc2Vzc2lvbjogdGhpcy5nZXRTZXNzaW9uKCksXG4gICAgICAgIHN0YXRpYzogdGhpcy5nZXRTdGF0aWMoKSxcbiAgICAgICAgZmxhc2g6IHRoaXMuZmxhc2gsXG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIHNldEhyZWYoaHJlZil7IHRoaXMuaHJlZiA9IGhyZWYgfVxuXG4gIHNldFJlZGlyZWN0KGhyZWYpe1xuICAgIHRoaXMucmVkaXJlY3QgPSB0cnVlXG4gICAgdGhpcy5ocmVmID0gaHJlZlxuICB9XG5cbiAgaXNNYWluKCl7IHJldHVybiB0aGlzLmVsLmhhc0F0dHJpYnV0ZShQSFhfTUFJTikgfVxuXG4gIGNvbm5lY3RQYXJhbXMobGl2ZVJlZmVyZXIpe1xuICAgIGxldCBwYXJhbXMgPSB0aGlzLmxpdmVTb2NrZXQucGFyYW1zKHRoaXMuZWwpXG4gICAgbGV0IG1hbmlmZXN0ID1cbiAgICAgIERPTS5hbGwoZG9jdW1lbnQsIGBbJHt0aGlzLmJpbmRpbmcoUEhYX1RSQUNLX1NUQVRJQyl9XWApXG4gICAgICAgIC5tYXAobm9kZSA9PiBub2RlLnNyYyB8fCBub2RlLmhyZWYpLmZpbHRlcih1cmwgPT4gdHlwZW9mICh1cmwpID09PSBcInN0cmluZ1wiKVxuXG4gICAgaWYobWFuaWZlc3QubGVuZ3RoID4gMCl7IHBhcmFtc1tcIl90cmFja19zdGF0aWNcIl0gPSBtYW5pZmVzdCB9XG4gICAgcGFyYW1zW1wiX21vdW50c1wiXSA9IHRoaXMuam9pbkNvdW50XG4gICAgcGFyYW1zW1wiX2xpdmVfcmVmZXJlclwiXSA9IGxpdmVSZWZlcmVyXG5cbiAgICByZXR1cm4gcGFyYW1zXG4gIH1cblxuICBpc0Nvbm5lY3RlZCgpeyByZXR1cm4gdGhpcy5jaGFubmVsLmNhblB1c2goKSB9XG5cbiAgZ2V0U2Vzc2lvbigpeyByZXR1cm4gdGhpcy5lbC5nZXRBdHRyaWJ1dGUoUEhYX1NFU1NJT04pIH1cblxuICBnZXRTdGF0aWMoKXtcbiAgICBsZXQgdmFsID0gdGhpcy5lbC5nZXRBdHRyaWJ1dGUoUEhYX1NUQVRJQylcbiAgICByZXR1cm4gdmFsID09PSBcIlwiID8gbnVsbCA6IHZhbFxuICB9XG5cbiAgZGVzdHJveShjYWxsYmFjayA9IGZ1bmN0aW9uICgpeyB9KXtcbiAgICB0aGlzLmRlc3Ryb3lBbGxDaGlsZHJlbigpXG4gICAgdGhpcy5kZXN0cm95ZWQgPSB0cnVlXG4gICAgZGVsZXRlIHRoaXMucm9vdC5jaGlsZHJlblt0aGlzLmlkXVxuICAgIGlmKHRoaXMucGFyZW50KXsgZGVsZXRlIHRoaXMucm9vdC5jaGlsZHJlblt0aGlzLnBhcmVudC5pZF1bdGhpcy5pZF0gfVxuICAgIGNsZWFyVGltZW91dCh0aGlzLmxvYWRlclRpbWVyKVxuICAgIGxldCBvbkZpbmlzaGVkID0gKCkgPT4ge1xuICAgICAgY2FsbGJhY2soKVxuICAgICAgZm9yKGxldCBpZCBpbiB0aGlzLnZpZXdIb29rcyl7XG4gICAgICAgIHRoaXMuZGVzdHJveUhvb2sodGhpcy52aWV3SG9va3NbaWRdKVxuICAgICAgfVxuICAgIH1cblxuICAgIERPTS5tYXJrUGh4Q2hpbGREZXN0cm95ZWQodGhpcy5lbClcblxuICAgIHRoaXMubG9nKFwiZGVzdHJveWVkXCIsICgpID0+IFtcInRoZSBjaGlsZCBoYXMgYmVlbiByZW1vdmVkIGZyb20gdGhlIHBhcmVudFwiXSlcbiAgICB0aGlzLmNoYW5uZWwubGVhdmUoKVxuICAgICAgLnJlY2VpdmUoXCJva1wiLCBvbkZpbmlzaGVkKVxuICAgICAgLnJlY2VpdmUoXCJlcnJvclwiLCBvbkZpbmlzaGVkKVxuICAgICAgLnJlY2VpdmUoXCJ0aW1lb3V0XCIsIG9uRmluaXNoZWQpXG4gIH1cblxuICBzZXRDb250YWluZXJDbGFzc2VzKC4uLmNsYXNzZXMpe1xuICAgIHRoaXMuZWwuY2xhc3NMaXN0LnJlbW92ZShcbiAgICAgIFBIWF9DT05ORUNURURfQ0xBU1MsXG4gICAgICBQSFhfRElTQ09OTkVDVEVEX0NMQVNTLFxuICAgICAgUEhYX0VSUk9SX0NMQVNTXG4gICAgKVxuICAgIHRoaXMuZWwuY2xhc3NMaXN0LmFkZCguLi5jbGFzc2VzKVxuICB9XG5cbiAgc2hvd0xvYWRlcih0aW1lb3V0KXtcbiAgICBjbGVhclRpbWVvdXQodGhpcy5sb2FkZXJUaW1lcilcbiAgICBpZih0aW1lb3V0KXtcbiAgICAgIHRoaXMubG9hZGVyVGltZXIgPSBzZXRUaW1lb3V0KCgpID0+IHRoaXMuc2hvd0xvYWRlcigpLCB0aW1lb3V0KVxuICAgIH0gZWxzZSB7XG4gICAgICBmb3IobGV0IGlkIGluIHRoaXMudmlld0hvb2tzKXsgdGhpcy52aWV3SG9va3NbaWRdLl9fZGlzY29ubmVjdGVkKCkgfVxuICAgICAgdGhpcy5zZXRDb250YWluZXJDbGFzc2VzKFBIWF9ESVNDT05ORUNURURfQ0xBU1MpXG4gICAgfVxuICB9XG5cbiAgZXhlY0FsbChiaW5kaW5nKXtcbiAgICBET00uYWxsKHRoaXMuZWwsIGBbJHtiaW5kaW5nfV1gLCBlbCA9PiB0aGlzLmxpdmVTb2NrZXQuZXhlY0pTKGVsLCBlbC5nZXRBdHRyaWJ1dGUoYmluZGluZykpKVxuICB9XG5cbiAgaGlkZUxvYWRlcigpe1xuICAgIGNsZWFyVGltZW91dCh0aGlzLmxvYWRlclRpbWVyKVxuICAgIHRoaXMuc2V0Q29udGFpbmVyQ2xhc3NlcyhQSFhfQ09OTkVDVEVEX0NMQVNTKVxuICAgIHRoaXMuZXhlY0FsbCh0aGlzLmJpbmRpbmcoXCJjb25uZWN0ZWRcIikpXG4gIH1cblxuICB0cmlnZ2VyUmVjb25uZWN0ZWQoKXtcbiAgICBmb3IobGV0IGlkIGluIHRoaXMudmlld0hvb2tzKXsgdGhpcy52aWV3SG9va3NbaWRdLl9fcmVjb25uZWN0ZWQoKSB9XG4gIH1cblxuICBsb2coa2luZCwgbXNnQ2FsbGJhY2spe1xuICAgIHRoaXMubGl2ZVNvY2tldC5sb2codGhpcywga2luZCwgbXNnQ2FsbGJhY2spXG4gIH1cblxuICB0cmFuc2l0aW9uKHRpbWUsIG9uU3RhcnQsIG9uRG9uZSA9IGZ1bmN0aW9uKCl7fSl7XG4gICAgdGhpcy5saXZlU29ja2V0LnRyYW5zaXRpb24odGltZSwgb25TdGFydCwgb25Eb25lKVxuICB9XG5cbiAgd2l0aGluVGFyZ2V0cyhwaHhUYXJnZXQsIGNhbGxiYWNrKXtcbiAgICBpZihwaHhUYXJnZXQgaW5zdGFuY2VvZiBIVE1MRWxlbWVudCB8fCBwaHhUYXJnZXQgaW5zdGFuY2VvZiBTVkdFbGVtZW50KXtcbiAgICAgIHJldHVybiB0aGlzLmxpdmVTb2NrZXQub3duZXIocGh4VGFyZ2V0LCB2aWV3ID0+IGNhbGxiYWNrKHZpZXcsIHBoeFRhcmdldCkpXG4gICAgfVxuXG4gICAgaWYoaXNDaWQocGh4VGFyZ2V0KSl7XG4gICAgICBsZXQgdGFyZ2V0cyA9IERPTS5maW5kQ29tcG9uZW50Tm9kZUxpc3QodGhpcy5lbCwgcGh4VGFyZ2V0KVxuICAgICAgaWYodGFyZ2V0cy5sZW5ndGggPT09IDApe1xuICAgICAgICBsb2dFcnJvcihgbm8gY29tcG9uZW50IGZvdW5kIG1hdGNoaW5nIHBoeC10YXJnZXQgb2YgJHtwaHhUYXJnZXR9YClcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGNhbGxiYWNrKHRoaXMsIHBhcnNlSW50KHBoeFRhcmdldCkpXG4gICAgICB9XG4gICAgfSBlbHNlIHtcbiAgICAgIGxldCB0YXJnZXRzID0gQXJyYXkuZnJvbShkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKHBoeFRhcmdldCkpXG4gICAgICBpZih0YXJnZXRzLmxlbmd0aCA9PT0gMCl7IGxvZ0Vycm9yKGBub3RoaW5nIGZvdW5kIG1hdGNoaW5nIHRoZSBwaHgtdGFyZ2V0IHNlbGVjdG9yIFwiJHtwaHhUYXJnZXR9XCJgKSB9XG4gICAgICB0YXJnZXRzLmZvckVhY2godGFyZ2V0ID0+IHRoaXMubGl2ZVNvY2tldC5vd25lcih0YXJnZXQsIHZpZXcgPT4gY2FsbGJhY2sodmlldywgdGFyZ2V0KSkpXG4gICAgfVxuICB9XG5cbiAgYXBwbHlEaWZmKHR5cGUsIHJhd0RpZmYsIGNhbGxiYWNrKXtcbiAgICB0aGlzLmxvZyh0eXBlLCAoKSA9PiBbXCJcIiwgY2xvbmUocmF3RGlmZildKVxuICAgIGxldCB7ZGlmZiwgcmVwbHksIGV2ZW50cywgdGl0bGV9ID0gUmVuZGVyZWQuZXh0cmFjdChyYXdEaWZmKVxuICAgIGNhbGxiYWNrKHtkaWZmLCByZXBseSwgZXZlbnRzfSlcbiAgICBpZih0aXRsZSl7IHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUoKCkgPT4gRE9NLnB1dFRpdGxlKHRpdGxlKSkgfVxuICB9XG5cbiAgb25Kb2luKHJlc3Ape1xuICAgIGxldCB7cmVuZGVyZWQsIGNvbnRhaW5lcn0gPSByZXNwXG4gICAgaWYoY29udGFpbmVyKXtcbiAgICAgIGxldCBbdGFnLCBhdHRyc10gPSBjb250YWluZXJcbiAgICAgIHRoaXMuZWwgPSBET00ucmVwbGFjZVJvb3RDb250YWluZXIodGhpcy5lbCwgdGFnLCBhdHRycylcbiAgICB9XG4gICAgdGhpcy5jaGlsZEpvaW5zID0gMFxuICAgIHRoaXMuam9pblBlbmRpbmcgPSB0cnVlXG4gICAgdGhpcy5mbGFzaCA9IG51bGxcblxuICAgIEJyb3dzZXIuZHJvcExvY2FsKHRoaXMubGl2ZVNvY2tldC5sb2NhbFN0b3JhZ2UsIHdpbmRvdy5sb2NhdGlvbi5wYXRobmFtZSwgQ09OU0VDVVRJVkVfUkVMT0FEUylcbiAgICB0aGlzLmFwcGx5RGlmZihcIm1vdW50XCIsIHJlbmRlcmVkLCAoe2RpZmYsIGV2ZW50c30pID0+IHtcbiAgICAgIHRoaXMucmVuZGVyZWQgPSBuZXcgUmVuZGVyZWQodGhpcy5pZCwgZGlmZilcbiAgICAgIGxldCBbaHRtbCwgc3RyZWFtc10gPSB0aGlzLnJlbmRlckNvbnRhaW5lcihudWxsLCBcImpvaW5cIilcbiAgICAgIHRoaXMuZHJvcFBlbmRpbmdSZWZzKClcbiAgICAgIGxldCBmb3JtcyA9IHRoaXMuZm9ybXNGb3JSZWNvdmVyeShodG1sKVxuICAgICAgdGhpcy5qb2luQ291bnQrK1xuXG4gICAgICBpZihmb3Jtcy5sZW5ndGggPiAwKXtcbiAgICAgICAgZm9ybXMuZm9yRWFjaCgoW2Zvcm0sIG5ld0Zvcm0sIG5ld0NpZF0sIGkpID0+IHtcbiAgICAgICAgICB0aGlzLnB1c2hGb3JtUmVjb3ZlcnkoZm9ybSwgbmV3Q2lkLCByZXNwID0+IHtcbiAgICAgICAgICAgIGlmKGkgPT09IGZvcm1zLmxlbmd0aCAtIDEpe1xuICAgICAgICAgICAgICB0aGlzLm9uSm9pbkNvbXBsZXRlKHJlc3AsIGh0bWwsIHN0cmVhbXMsIGV2ZW50cylcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9KVxuICAgICAgICB9KVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5vbkpvaW5Db21wbGV0ZShyZXNwLCBodG1sLCBzdHJlYW1zLCBldmVudHMpXG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIGRyb3BQZW5kaW5nUmVmcygpe1xuICAgIERPTS5hbGwoZG9jdW1lbnQsIGBbJHtQSFhfUkVGX1NSQ309XCIke3RoaXMuaWR9XCJdWyR7UEhYX1JFRn1dYCwgZWwgPT4ge1xuICAgICAgZWwucmVtb3ZlQXR0cmlidXRlKFBIWF9SRUYpXG4gICAgICBlbC5yZW1vdmVBdHRyaWJ1dGUoUEhYX1JFRl9TUkMpXG4gICAgfSlcbiAgfVxuXG4gIG9uSm9pbkNvbXBsZXRlKHtsaXZlX3BhdGNofSwgaHRtbCwgc3RyZWFtcywgZXZlbnRzKXtcbiAgICAvLyBJbiBvcmRlciB0byBwcm92aWRlIGEgYmV0dGVyIGV4cGVyaWVuY2UsIHdlIHdhbnQgdG8gam9pblxuICAgIC8vIGFsbCBMaXZlVmlld3MgZmlyc3QgYW5kIG9ubHkgdGhlbiBhcHBseSB0aGVpciBwYXRjaGVzLlxuICAgIGlmKHRoaXMuam9pbkNvdW50ID4gMSB8fCAodGhpcy5wYXJlbnQgJiYgIXRoaXMucGFyZW50LmlzSm9pblBlbmRpbmcoKSkpe1xuICAgICAgcmV0dXJuIHRoaXMuYXBwbHlKb2luUGF0Y2gobGl2ZV9wYXRjaCwgaHRtbCwgc3RyZWFtcywgZXZlbnRzKVxuICAgIH1cblxuICAgIC8vIE9uZSBkb3duc2lkZSBvZiB0aGlzIGFwcHJvYWNoIGlzIHRoYXQgd2UgbmVlZCB0byBmaW5kIHBoeENoaWxkcmVuXG4gICAgLy8gaW4gdGhlIGh0bWwgZnJhZ21lbnQsIGluc3RlYWQgb2YgZGlyZWN0bHkgb24gdGhlIERPTS4gVGhlIGZyYWdtZW50XG4gICAgLy8gYWxzbyBkb2VzIG5vdCBpbmNsdWRlIFBIWF9TVEFUSUMsIHNvIHdlIG5lZWQgdG8gY29weSBpdCBvdmVyIGZyb21cbiAgICAvLyB0aGUgRE9NLlxuICAgIGxldCBuZXdDaGlsZHJlbiA9IERPTS5maW5kUGh4Q2hpbGRyZW5JbkZyYWdtZW50KGh0bWwsIHRoaXMuaWQpLmZpbHRlcih0b0VsID0+IHtcbiAgICAgIGxldCBmcm9tRWwgPSB0b0VsLmlkICYmIHRoaXMuZWwucXVlcnlTZWxlY3RvcihgW2lkPVwiJHt0b0VsLmlkfVwiXWApXG4gICAgICBsZXQgcGh4U3RhdGljID0gZnJvbUVsICYmIGZyb21FbC5nZXRBdHRyaWJ1dGUoUEhYX1NUQVRJQylcbiAgICAgIGlmKHBoeFN0YXRpYyl7IHRvRWwuc2V0QXR0cmlidXRlKFBIWF9TVEFUSUMsIHBoeFN0YXRpYykgfVxuICAgICAgcmV0dXJuIHRoaXMuam9pbkNoaWxkKHRvRWwpXG4gICAgfSlcblxuICAgIGlmKG5ld0NoaWxkcmVuLmxlbmd0aCA9PT0gMCl7XG4gICAgICBpZih0aGlzLnBhcmVudCl7XG4gICAgICAgIHRoaXMucm9vdC5wZW5kaW5nSm9pbk9wcy5wdXNoKFt0aGlzLCAoKSA9PiB0aGlzLmFwcGx5Sm9pblBhdGNoKGxpdmVfcGF0Y2gsIGh0bWwsIHN0cmVhbXMsIGV2ZW50cyldKVxuICAgICAgICB0aGlzLnBhcmVudC5hY2tKb2luKHRoaXMpXG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLm9uQWxsQ2hpbGRKb2luc0NvbXBsZXRlKClcbiAgICAgICAgdGhpcy5hcHBseUpvaW5QYXRjaChsaXZlX3BhdGNoLCBodG1sLCBzdHJlYW1zLCBldmVudHMpXG4gICAgICB9XG4gICAgfSBlbHNlIHtcbiAgICAgIHRoaXMucm9vdC5wZW5kaW5nSm9pbk9wcy5wdXNoKFt0aGlzLCAoKSA9PiB0aGlzLmFwcGx5Sm9pblBhdGNoKGxpdmVfcGF0Y2gsIGh0bWwsIHN0cmVhbXMsIGV2ZW50cyldKVxuICAgIH1cbiAgfVxuXG4gIGF0dGFjaFRydWVEb2NFbCgpe1xuICAgIHRoaXMuZWwgPSBET00uYnlJZCh0aGlzLmlkKVxuICAgIHRoaXMuZWwuc2V0QXR0cmlidXRlKFBIWF9ST09UX0lELCB0aGlzLnJvb3QuaWQpXG4gIH1cblxuICBleGVjTmV3TW91bnRlZCgpe1xuICAgIERPTS5hbGwodGhpcy5lbCwgYFske3RoaXMuYmluZGluZyhQSFhfSE9PSyl9XSwgW2RhdGEtcGh4LSR7UEhYX0hPT0t9XWAsIGhvb2tFbCA9PiB7XG4gICAgICB0aGlzLm1heWJlQWRkTmV3SG9vayhob29rRWwpXG4gICAgfSlcbiAgICBET00uYWxsKHRoaXMuZWwsIGBbJHt0aGlzLmJpbmRpbmcoUEhYX01PVU5URUQpfV1gLCBlbCA9PiB0aGlzLm1heWJlTW91bnRlZChlbCkpXG4gIH1cblxuICBhcHBseUpvaW5QYXRjaChsaXZlX3BhdGNoLCBodG1sLCBzdHJlYW1zLCBldmVudHMpe1xuICAgIHRoaXMuYXR0YWNoVHJ1ZURvY0VsKClcbiAgICBsZXQgcGF0Y2ggPSBuZXcgRE9NUGF0Y2godGhpcywgdGhpcy5lbCwgdGhpcy5pZCwgaHRtbCwgc3RyZWFtcywgbnVsbClcbiAgICBwYXRjaC5tYXJrUHJ1bmFibGVDb250ZW50Rm9yUmVtb3ZhbCgpXG4gICAgdGhpcy5wZXJmb3JtUGF0Y2gocGF0Y2gsIGZhbHNlKVxuICAgIHRoaXMuam9pbk5ld0NoaWxkcmVuKClcbiAgICB0aGlzLmV4ZWNOZXdNb3VudGVkKClcblxuICAgIHRoaXMuam9pblBlbmRpbmcgPSBmYWxzZVxuICAgIHRoaXMubGl2ZVNvY2tldC5kaXNwYXRjaEV2ZW50cyhldmVudHMpXG4gICAgdGhpcy5hcHBseVBlbmRpbmdVcGRhdGVzKClcblxuICAgIGlmKGxpdmVfcGF0Y2gpe1xuICAgICAgbGV0IHtraW5kLCB0b30gPSBsaXZlX3BhdGNoXG4gICAgICB0aGlzLmxpdmVTb2NrZXQuaGlzdG9yeVBhdGNoKHRvLCBraW5kKVxuICAgIH1cbiAgICB0aGlzLmhpZGVMb2FkZXIoKVxuICAgIGlmKHRoaXMuam9pbkNvdW50ID4gMSl7IHRoaXMudHJpZ2dlclJlY29ubmVjdGVkKCkgfVxuICAgIHRoaXMuc3RvcENhbGxiYWNrKClcbiAgfVxuXG4gIHRyaWdnZXJCZWZvcmVVcGRhdGVIb29rKGZyb21FbCwgdG9FbCl7XG4gICAgdGhpcy5saXZlU29ja2V0LnRyaWdnZXJET00oXCJvbkJlZm9yZUVsVXBkYXRlZFwiLCBbZnJvbUVsLCB0b0VsXSlcbiAgICBsZXQgaG9vayA9IHRoaXMuZ2V0SG9vayhmcm9tRWwpXG4gICAgbGV0IGlzSWdub3JlZCA9IGhvb2sgJiYgRE9NLmlzSWdub3JlZChmcm9tRWwsIHRoaXMuYmluZGluZyhQSFhfVVBEQVRFKSlcbiAgICBpZihob29rICYmICFmcm9tRWwuaXNFcXVhbE5vZGUodG9FbCkgJiYgIShpc0lnbm9yZWQgJiYgaXNFcXVhbE9iaihmcm9tRWwuZGF0YXNldCwgdG9FbC5kYXRhc2V0KSkpe1xuICAgICAgaG9vay5fX2JlZm9yZVVwZGF0ZSgpXG4gICAgICByZXR1cm4gaG9va1xuICAgIH1cbiAgfVxuXG4gIG1heWJlTW91bnRlZChlbCl7XG4gICAgbGV0IHBoeE1vdW50ZWQgPSBlbC5nZXRBdHRyaWJ1dGUodGhpcy5iaW5kaW5nKFBIWF9NT1VOVEVEKSlcbiAgICBsZXQgaGFzQmVlbkludm9rZWQgPSBwaHhNb3VudGVkICYmIERPTS5wcml2YXRlKGVsLCBcIm1vdW50ZWRcIilcbiAgICBpZihwaHhNb3VudGVkICYmICFoYXNCZWVuSW52b2tlZCl7XG4gICAgICB0aGlzLmxpdmVTb2NrZXQuZXhlY0pTKGVsLCBwaHhNb3VudGVkKVxuICAgICAgRE9NLnB1dFByaXZhdGUoZWwsIFwibW91bnRlZFwiLCB0cnVlKVxuICAgIH1cbiAgfVxuXG4gIG1heWJlQWRkTmV3SG9vayhlbCwgZm9yY2Upe1xuICAgIGxldCBuZXdIb29rID0gdGhpcy5hZGRIb29rKGVsKVxuICAgIGlmKG5ld0hvb2speyBuZXdIb29rLl9fbW91bnRlZCgpIH1cbiAgfVxuXG4gIHBlcmZvcm1QYXRjaChwYXRjaCwgcHJ1bmVDaWRzKXtcbiAgICBsZXQgcmVtb3ZlZEVscyA9IFtdXG4gICAgbGV0IHBoeENoaWxkcmVuQWRkZWQgPSBmYWxzZVxuICAgIGxldCB1cGRhdGVkSG9va0lkcyA9IG5ldyBTZXQoKVxuXG4gICAgcGF0Y2guYWZ0ZXIoXCJhZGRlZFwiLCBlbCA9PiB7XG4gICAgICB0aGlzLmxpdmVTb2NrZXQudHJpZ2dlckRPTShcIm9uTm9kZUFkZGVkXCIsIFtlbF0pXG4gICAgICB0aGlzLm1heWJlQWRkTmV3SG9vayhlbClcbiAgICAgIGlmKGVsLmdldEF0dHJpYnV0ZSl7IHRoaXMubWF5YmVNb3VudGVkKGVsKSB9XG4gICAgfSlcblxuICAgIHBhdGNoLmFmdGVyKFwicGh4Q2hpbGRBZGRlZFwiLCBlbCA9PiB7XG4gICAgICBpZihET00uaXNQaHhTdGlja3koZWwpKXtcbiAgICAgICAgdGhpcy5saXZlU29ja2V0LmpvaW5Sb290Vmlld3MoKVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgcGh4Q2hpbGRyZW5BZGRlZCA9IHRydWVcbiAgICAgIH1cbiAgICB9KVxuXG4gICAgcGF0Y2guYmVmb3JlKFwidXBkYXRlZFwiLCAoZnJvbUVsLCB0b0VsKSA9PiB7XG4gICAgICBsZXQgaG9vayA9IHRoaXMudHJpZ2dlckJlZm9yZVVwZGF0ZUhvb2soZnJvbUVsLCB0b0VsKVxuICAgICAgaWYoaG9vayl7IHVwZGF0ZWRIb29rSWRzLmFkZChmcm9tRWwuaWQpIH1cbiAgICB9KVxuXG4gICAgcGF0Y2guYWZ0ZXIoXCJ1cGRhdGVkXCIsIGVsID0+IHtcbiAgICAgIGlmKHVwZGF0ZWRIb29rSWRzLmhhcyhlbC5pZCkpeyB0aGlzLmdldEhvb2soZWwpLl9fdXBkYXRlZCgpIH1cbiAgICB9KVxuXG4gICAgcGF0Y2guYWZ0ZXIoXCJkaXNjYXJkZWRcIiwgKGVsKSA9PiB7XG4gICAgICBpZihlbC5ub2RlVHlwZSA9PT0gTm9kZS5FTEVNRU5UX05PREUpeyByZW1vdmVkRWxzLnB1c2goZWwpIH1cbiAgICB9KVxuXG4gICAgcGF0Y2guYWZ0ZXIoXCJ0cmFuc2l0aW9uc0Rpc2NhcmRlZFwiLCBlbHMgPT4gdGhpcy5hZnRlckVsZW1lbnRzUmVtb3ZlZChlbHMsIHBydW5lQ2lkcykpXG4gICAgcGF0Y2gucGVyZm9ybSgpXG4gICAgdGhpcy5hZnRlckVsZW1lbnRzUmVtb3ZlZChyZW1vdmVkRWxzLCBwcnVuZUNpZHMpXG5cbiAgICByZXR1cm4gcGh4Q2hpbGRyZW5BZGRlZFxuICB9XG5cbiAgYWZ0ZXJFbGVtZW50c1JlbW92ZWQoZWxlbWVudHMsIHBydW5lQ2lkcyl7XG4gICAgbGV0IGRlc3Ryb3llZENJRHMgPSBbXVxuICAgIGVsZW1lbnRzLmZvckVhY2gocGFyZW50ID0+IHtcbiAgICAgIGxldCBjb21wb25lbnRzID0gRE9NLmFsbChwYXJlbnQsIGBbJHtQSFhfQ09NUE9ORU5UfV1gKVxuICAgICAgbGV0IGhvb2tzID0gRE9NLmFsbChwYXJlbnQsIGBbJHt0aGlzLmJpbmRpbmcoUEhYX0hPT0spfV1gKVxuICAgICAgY29tcG9uZW50cy5jb25jYXQocGFyZW50KS5mb3JFYWNoKGVsID0+IHtcbiAgICAgICAgbGV0IGNpZCA9IHRoaXMuY29tcG9uZW50SUQoZWwpXG4gICAgICAgIGlmKGlzQ2lkKGNpZCkgJiYgZGVzdHJveWVkQ0lEcy5pbmRleE9mKGNpZCkgPT09IC0xKXsgZGVzdHJveWVkQ0lEcy5wdXNoKGNpZCkgfVxuICAgICAgfSlcbiAgICAgIGhvb2tzLmNvbmNhdChwYXJlbnQpLmZvckVhY2goaG9va0VsID0+IHtcbiAgICAgICAgbGV0IGhvb2sgPSB0aGlzLmdldEhvb2soaG9va0VsKVxuICAgICAgICBob29rICYmIHRoaXMuZGVzdHJveUhvb2soaG9vaylcbiAgICAgIH0pXG4gICAgfSlcbiAgICAvLyBXZSBzaG91bGQgbm90IHBydW5lQ2lkcyBvbiBqb2lucy4gT3RoZXJ3aXNlLCBpbiBjYXNlIG9mXG4gICAgLy8gcmVqb2lucywgd2UgbWF5IG5vdGlmeSBjaWRzIHRoYXQgbm8gbG9uZ2VyIGJlbG9uZyB0byB0aGVcbiAgICAvLyBjdXJyZW50IExpdmVWaWV3IHRvIGJlIHJlbW92ZWQuXG4gICAgaWYocHJ1bmVDaWRzKXtcbiAgICAgIHRoaXMubWF5YmVQdXNoQ29tcG9uZW50c0Rlc3Ryb3llZChkZXN0cm95ZWRDSURzKVxuICAgIH1cbiAgfVxuXG4gIGpvaW5OZXdDaGlsZHJlbigpe1xuICAgIERPTS5maW5kUGh4Q2hpbGRyZW4odGhpcy5lbCwgdGhpcy5pZCkuZm9yRWFjaChlbCA9PiB0aGlzLmpvaW5DaGlsZChlbCkpXG4gIH1cblxuICBnZXRDaGlsZEJ5SWQoaWQpeyByZXR1cm4gdGhpcy5yb290LmNoaWxkcmVuW3RoaXMuaWRdW2lkXSB9XG5cbiAgZ2V0RGVzY2VuZGVudEJ5RWwoZWwpe1xuICAgIGlmKGVsLmlkID09PSB0aGlzLmlkKXtcbiAgICAgIHJldHVybiB0aGlzXG4gICAgfSBlbHNlIHtcbiAgICAgIHJldHVybiB0aGlzLmNoaWxkcmVuW2VsLmdldEF0dHJpYnV0ZShQSFhfUEFSRU5UX0lEKV1bZWwuaWRdXG4gICAgfVxuICB9XG5cbiAgZGVzdHJveURlc2NlbmRlbnQoaWQpe1xuICAgIGZvcihsZXQgcGFyZW50SWQgaW4gdGhpcy5yb290LmNoaWxkcmVuKXtcbiAgICAgIGZvcihsZXQgY2hpbGRJZCBpbiB0aGlzLnJvb3QuY2hpbGRyZW5bcGFyZW50SWRdKXtcbiAgICAgICAgaWYoY2hpbGRJZCA9PT0gaWQpeyByZXR1cm4gdGhpcy5yb290LmNoaWxkcmVuW3BhcmVudElkXVtjaGlsZElkXS5kZXN0cm95KCkgfVxuICAgICAgfVxuICAgIH1cbiAgfVxuXG4gIGpvaW5DaGlsZChlbCl7XG4gICAgbGV0IGNoaWxkID0gdGhpcy5nZXRDaGlsZEJ5SWQoZWwuaWQpXG4gICAgaWYoIWNoaWxkKXtcbiAgICAgIGxldCB2aWV3ID0gbmV3IFZpZXcoZWwsIHRoaXMubGl2ZVNvY2tldCwgdGhpcylcbiAgICAgIHRoaXMucm9vdC5jaGlsZHJlblt0aGlzLmlkXVt2aWV3LmlkXSA9IHZpZXdcbiAgICAgIHZpZXcuam9pbigpXG4gICAgICB0aGlzLmNoaWxkSm9pbnMrK1xuICAgICAgcmV0dXJuIHRydWVcbiAgICB9XG4gIH1cblxuICBpc0pvaW5QZW5kaW5nKCl7IHJldHVybiB0aGlzLmpvaW5QZW5kaW5nIH1cblxuICBhY2tKb2luKF9jaGlsZCl7XG4gICAgdGhpcy5jaGlsZEpvaW5zLS1cblxuICAgIGlmKHRoaXMuY2hpbGRKb2lucyA9PT0gMCl7XG4gICAgICBpZih0aGlzLnBhcmVudCl7XG4gICAgICAgIHRoaXMucGFyZW50LmFja0pvaW4odGhpcylcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHRoaXMub25BbGxDaGlsZEpvaW5zQ29tcGxldGUoKVxuICAgICAgfVxuICAgIH1cbiAgfVxuXG4gIG9uQWxsQ2hpbGRKb2luc0NvbXBsZXRlKCl7XG4gICAgdGhpcy5qb2luQ2FsbGJhY2soKCkgPT4ge1xuICAgICAgdGhpcy5wZW5kaW5nSm9pbk9wcy5mb3JFYWNoKChbdmlldywgb3BdKSA9PiB7XG4gICAgICAgIGlmKCF2aWV3LmlzRGVzdHJveWVkKCkpeyBvcCgpIH1cbiAgICAgIH0pXG4gICAgICB0aGlzLnBlbmRpbmdKb2luT3BzID0gW11cbiAgICB9KVxuICB9XG5cbiAgdXBkYXRlKGRpZmYsIGV2ZW50cyl7XG4gICAgaWYodGhpcy5pc0pvaW5QZW5kaW5nKCkgfHwgKHRoaXMubGl2ZVNvY2tldC5oYXNQZW5kaW5nTGluaygpICYmIHRoaXMucm9vdC5pc01haW4oKSkpe1xuICAgICAgcmV0dXJuIHRoaXMucGVuZGluZ0RpZmZzLnB1c2goe2RpZmYsIGV2ZW50c30pXG4gICAgfVxuXG4gICAgdGhpcy5yZW5kZXJlZC5tZXJnZURpZmYoZGlmZilcbiAgICBsZXQgcGh4Q2hpbGRyZW5BZGRlZCA9IGZhbHNlXG5cbiAgICAvLyBXaGVuIHRoZSBkaWZmIG9ubHkgY29udGFpbnMgY29tcG9uZW50IGRpZmZzLCB0aGVuIHdhbGsgY29tcG9uZW50c1xuICAgIC8vIGFuZCBwYXRjaCBvbmx5IHRoZSBwYXJlbnQgY29tcG9uZW50IGNvbnRhaW5lcnMgZm91bmQgaW4gdGhlIGRpZmYuXG4gICAgLy8gT3RoZXJ3aXNlLCBwYXRjaCBlbnRpcmUgTFYgY29udGFpbmVyLlxuICAgIGlmKHRoaXMucmVuZGVyZWQuaXNDb21wb25lbnRPbmx5RGlmZihkaWZmKSl7XG4gICAgICB0aGlzLmxpdmVTb2NrZXQudGltZShcImNvbXBvbmVudCBwYXRjaCBjb21wbGV0ZVwiLCAoKSA9PiB7XG4gICAgICAgIGxldCBwYXJlbnRDaWRzID0gRE9NLmZpbmRQYXJlbnRDSURzKHRoaXMuZWwsIHRoaXMucmVuZGVyZWQuY29tcG9uZW50Q0lEcyhkaWZmKSlcbiAgICAgICAgcGFyZW50Q2lkcy5mb3JFYWNoKHBhcmVudENJRCA9PiB7XG4gICAgICAgICAgaWYodGhpcy5jb21wb25lbnRQYXRjaCh0aGlzLnJlbmRlcmVkLmdldENvbXBvbmVudChkaWZmLCBwYXJlbnRDSUQpLCBwYXJlbnRDSUQpKXsgcGh4Q2hpbGRyZW5BZGRlZCA9IHRydWUgfVxuICAgICAgICB9KVxuICAgICAgfSlcbiAgICB9IGVsc2UgaWYoIWlzRW1wdHkoZGlmZikpe1xuICAgICAgdGhpcy5saXZlU29ja2V0LnRpbWUoXCJmdWxsIHBhdGNoIGNvbXBsZXRlXCIsICgpID0+IHtcbiAgICAgICAgbGV0IFtodG1sLCBzdHJlYW1zXSA9IHRoaXMucmVuZGVyQ29udGFpbmVyKGRpZmYsIFwidXBkYXRlXCIpXG4gICAgICAgIGxldCBwYXRjaCA9IG5ldyBET01QYXRjaCh0aGlzLCB0aGlzLmVsLCB0aGlzLmlkLCBodG1sLCBzdHJlYW1zLCBudWxsKVxuICAgICAgICBwaHhDaGlsZHJlbkFkZGVkID0gdGhpcy5wZXJmb3JtUGF0Y2gocGF0Y2gsIHRydWUpXG4gICAgICB9KVxuICAgIH1cblxuICAgIHRoaXMubGl2ZVNvY2tldC5kaXNwYXRjaEV2ZW50cyhldmVudHMpXG4gICAgaWYocGh4Q2hpbGRyZW5BZGRlZCl7IHRoaXMuam9pbk5ld0NoaWxkcmVuKCkgfVxuICB9XG5cbiAgcmVuZGVyQ29udGFpbmVyKGRpZmYsIGtpbmQpe1xuICAgIHJldHVybiB0aGlzLmxpdmVTb2NrZXQudGltZShgdG9TdHJpbmcgZGlmZiAoJHtraW5kfSlgLCAoKSA9PiB7XG4gICAgICBsZXQgdGFnID0gdGhpcy5lbC50YWdOYW1lXG4gICAgICAvLyBEb24ndCBza2lwIGFueSBjb21wb25lbnQgaW4gdGhlIGRpZmYgbm9yIGFueSBtYXJrZWQgYXMgcHJ1bmVkXG4gICAgICAvLyAoYXMgdGhleSBtYXkgaGF2ZSBiZWVuIGFkZGVkIGJhY2spXG4gICAgICBsZXQgY2lkcyA9IGRpZmYgPyB0aGlzLnJlbmRlcmVkLmNvbXBvbmVudENJRHMoZGlmZikuY29uY2F0KHRoaXMucHJ1bmluZ0NJRHMpIDogbnVsbFxuICAgICAgbGV0IFtodG1sLCBzdHJlYW1zXSA9IHRoaXMucmVuZGVyZWQudG9TdHJpbmcoY2lkcylcbiAgICAgIHJldHVybiBbYDwke3RhZ30+JHtodG1sfTwvJHt0YWd9PmAsIHN0cmVhbXNdXG4gICAgfSlcbiAgfVxuXG4gIGNvbXBvbmVudFBhdGNoKGRpZmYsIGNpZCl7XG4gICAgaWYoaXNFbXB0eShkaWZmKSkgcmV0dXJuIGZhbHNlXG4gICAgbGV0IFtodG1sLCBzdHJlYW1zXSA9IHRoaXMucmVuZGVyZWQuY29tcG9uZW50VG9TdHJpbmcoY2lkKVxuICAgIGxldCBwYXRjaCA9IG5ldyBET01QYXRjaCh0aGlzLCB0aGlzLmVsLCB0aGlzLmlkLCBodG1sLCBzdHJlYW1zLCBjaWQpXG4gICAgbGV0IGNoaWxkcmVuQWRkZWQgPSB0aGlzLnBlcmZvcm1QYXRjaChwYXRjaCwgdHJ1ZSlcbiAgICByZXR1cm4gY2hpbGRyZW5BZGRlZFxuICB9XG5cbiAgZ2V0SG9vayhlbCl7IHJldHVybiB0aGlzLnZpZXdIb29rc1tWaWV3SG9vay5lbGVtZW50SUQoZWwpXSB9XG5cbiAgYWRkSG9vayhlbCl7XG4gICAgaWYoVmlld0hvb2suZWxlbWVudElEKGVsKSB8fCAhZWwuZ2V0QXR0cmlidXRlKXsgcmV0dXJuIH1cbiAgICBsZXQgaG9va05hbWUgPSBlbC5nZXRBdHRyaWJ1dGUoYGRhdGEtcGh4LSR7UEhYX0hPT0t9YCkgfHwgZWwuZ2V0QXR0cmlidXRlKHRoaXMuYmluZGluZyhQSFhfSE9PSykpXG4gICAgaWYoaG9va05hbWUgJiYgIXRoaXMub3duc0VsZW1lbnQoZWwpKXsgcmV0dXJuIH1cbiAgICBsZXQgY2FsbGJhY2tzID0gdGhpcy5saXZlU29ja2V0LmdldEhvb2tDYWxsYmFja3MoaG9va05hbWUpXG5cbiAgICBpZihjYWxsYmFja3Mpe1xuICAgICAgaWYoIWVsLmlkKXsgbG9nRXJyb3IoYG5vIERPTSBJRCBmb3IgaG9vayBcIiR7aG9va05hbWV9XCIuIEhvb2tzIHJlcXVpcmUgYSB1bmlxdWUgSUQgb24gZWFjaCBlbGVtZW50LmAsIGVsKSB9XG4gICAgICBsZXQgaG9vayA9IG5ldyBWaWV3SG9vayh0aGlzLCBlbCwgY2FsbGJhY2tzKVxuICAgICAgdGhpcy52aWV3SG9va3NbVmlld0hvb2suZWxlbWVudElEKGhvb2suZWwpXSA9IGhvb2tcbiAgICAgIHJldHVybiBob29rXG4gICAgfSBlbHNlIGlmKGhvb2tOYW1lICE9PSBudWxsKXtcbiAgICAgIGxvZ0Vycm9yKGB1bmtub3duIGhvb2sgZm91bmQgZm9yIFwiJHtob29rTmFtZX1cImAsIGVsKVxuICAgIH1cbiAgfVxuXG4gIGRlc3Ryb3lIb29rKGhvb2spe1xuICAgIGhvb2suX19kZXN0cm95ZWQoKVxuICAgIGhvb2suX19jbGVhbnVwX18oKVxuICAgIGRlbGV0ZSB0aGlzLnZpZXdIb29rc1tWaWV3SG9vay5lbGVtZW50SUQoaG9vay5lbCldXG4gIH1cblxuICBhcHBseVBlbmRpbmdVcGRhdGVzKCl7XG4gICAgdGhpcy5wZW5kaW5nRGlmZnMuZm9yRWFjaCgoe2RpZmYsIGV2ZW50c30pID0+IHRoaXMudXBkYXRlKGRpZmYsIGV2ZW50cykpXG4gICAgdGhpcy5wZW5kaW5nRGlmZnMgPSBbXVxuICAgIHRoaXMuZWFjaENoaWxkKGNoaWxkID0+IGNoaWxkLmFwcGx5UGVuZGluZ1VwZGF0ZXMoKSlcbiAgfVxuXG4gIGVhY2hDaGlsZChjYWxsYmFjayl7XG4gICAgbGV0IGNoaWxkcmVuID0gdGhpcy5yb290LmNoaWxkcmVuW3RoaXMuaWRdIHx8IHt9XG4gICAgZm9yKGxldCBpZCBpbiBjaGlsZHJlbil7IGNhbGxiYWNrKHRoaXMuZ2V0Q2hpbGRCeUlkKGlkKSkgfVxuICB9XG5cbiAgb25DaGFubmVsKGV2ZW50LCBjYil7XG4gICAgdGhpcy5saXZlU29ja2V0Lm9uQ2hhbm5lbCh0aGlzLmNoYW5uZWwsIGV2ZW50LCByZXNwID0+IHtcbiAgICAgIGlmKHRoaXMuaXNKb2luUGVuZGluZygpKXtcbiAgICAgICAgdGhpcy5yb290LnBlbmRpbmdKb2luT3BzLnB1c2goW3RoaXMsICgpID0+IGNiKHJlc3ApXSlcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHRoaXMubGl2ZVNvY2tldC5yZXF1ZXN0RE9NVXBkYXRlKCgpID0+IGNiKHJlc3ApKVxuICAgICAgfVxuICAgIH0pXG4gIH1cblxuICBiaW5kQ2hhbm5lbCgpe1xuICAgIC8vIFRoZSBkaWZmIGV2ZW50IHNob3VsZCBiZSBoYW5kbGVkIGJ5IHRoZSByZWd1bGFyIHVwZGF0ZSBvcGVyYXRpb25zLlxuICAgIC8vIEFsbCBvdGhlciBvcGVyYXRpb25zIGFyZSBxdWV1ZWQgdG8gYmUgYXBwbGllZCBvbmx5IGFmdGVyIGpvaW4uXG4gICAgdGhpcy5saXZlU29ja2V0Lm9uQ2hhbm5lbCh0aGlzLmNoYW5uZWwsIFwiZGlmZlwiLCAocmF3RGlmZikgPT4ge1xuICAgICAgdGhpcy5saXZlU29ja2V0LnJlcXVlc3RET01VcGRhdGUoKCkgPT4ge1xuICAgICAgICB0aGlzLmFwcGx5RGlmZihcInVwZGF0ZVwiLCByYXdEaWZmLCAoe2RpZmYsIGV2ZW50c30pID0+IHRoaXMudXBkYXRlKGRpZmYsIGV2ZW50cykpXG4gICAgICB9KVxuICAgIH0pXG4gICAgdGhpcy5vbkNoYW5uZWwoXCJyZWRpcmVjdFwiLCAoe3RvLCBmbGFzaH0pID0+IHRoaXMub25SZWRpcmVjdCh7dG8sIGZsYXNofSkpXG4gICAgdGhpcy5vbkNoYW5uZWwoXCJsaXZlX3BhdGNoXCIsIChyZWRpcikgPT4gdGhpcy5vbkxpdmVQYXRjaChyZWRpcikpXG4gICAgdGhpcy5vbkNoYW5uZWwoXCJsaXZlX3JlZGlyZWN0XCIsIChyZWRpcikgPT4gdGhpcy5vbkxpdmVSZWRpcmVjdChyZWRpcikpXG4gICAgdGhpcy5jaGFubmVsLm9uRXJyb3IocmVhc29uID0+IHRoaXMub25FcnJvcihyZWFzb24pKVxuICAgIHRoaXMuY2hhbm5lbC5vbkNsb3NlKHJlYXNvbiA9PiB0aGlzLm9uQ2xvc2UocmVhc29uKSlcbiAgfVxuXG4gIGRlc3Ryb3lBbGxDaGlsZHJlbigpeyB0aGlzLmVhY2hDaGlsZChjaGlsZCA9PiBjaGlsZC5kZXN0cm95KCkpIH1cblxuICBvbkxpdmVSZWRpcmVjdChyZWRpcil7XG4gICAgbGV0IHt0bywga2luZCwgZmxhc2h9ID0gcmVkaXJcbiAgICBsZXQgdXJsID0gdGhpcy5leHBhbmRVUkwodG8pXG4gICAgdGhpcy5saXZlU29ja2V0Lmhpc3RvcnlSZWRpcmVjdCh1cmwsIGtpbmQsIGZsYXNoKVxuICB9XG5cbiAgb25MaXZlUGF0Y2gocmVkaXIpe1xuICAgIGxldCB7dG8sIGtpbmR9ID0gcmVkaXJcbiAgICB0aGlzLmhyZWYgPSB0aGlzLmV4cGFuZFVSTCh0bylcbiAgICB0aGlzLmxpdmVTb2NrZXQuaGlzdG9yeVBhdGNoKHRvLCBraW5kKVxuICB9XG5cbiAgZXhwYW5kVVJMKHRvKXtcbiAgICByZXR1cm4gdG8uc3RhcnRzV2l0aChcIi9cIikgPyBgJHt3aW5kb3cubG9jYXRpb24ucHJvdG9jb2x9Ly8ke3dpbmRvdy5sb2NhdGlvbi5ob3N0fSR7dG99YCA6IHRvXG4gIH1cblxuICBvblJlZGlyZWN0KHt0bywgZmxhc2h9KXsgdGhpcy5saXZlU29ja2V0LnJlZGlyZWN0KHRvLCBmbGFzaCkgfVxuXG4gIGlzRGVzdHJveWVkKCl7IHJldHVybiB0aGlzLmRlc3Ryb3llZCB9XG5cbiAgam9pbkRlYWQoKXsgdGhpcy5pc0RlYWQgPSB0cnVlIH1cblxuICBqb2luKGNhbGxiYWNrKXtcbiAgICB0aGlzLnNob3dMb2FkZXIodGhpcy5saXZlU29ja2V0LmxvYWRlclRpbWVvdXQpXG4gICAgdGhpcy5iaW5kQ2hhbm5lbCgpXG4gICAgaWYodGhpcy5pc01haW4oKSl7XG4gICAgICB0aGlzLnN0b3BDYWxsYmFjayA9IHRoaXMubGl2ZVNvY2tldC53aXRoUGFnZUxvYWRpbmcoe3RvOiB0aGlzLmhyZWYsIGtpbmQ6IFwiaW5pdGlhbFwifSlcbiAgICB9XG4gICAgdGhpcy5qb2luQ2FsbGJhY2sgPSAob25Eb25lKSA9PiB7XG4gICAgICBvbkRvbmUgPSBvbkRvbmUgfHwgZnVuY3Rpb24oKXt9XG4gICAgICBjYWxsYmFjayA/IGNhbGxiYWNrKHRoaXMuam9pbkNvdW50LCBvbkRvbmUpIDogb25Eb25lKClcbiAgICB9XG4gICAgdGhpcy5saXZlU29ja2V0LndyYXBQdXNoKHRoaXMsIHt0aW1lb3V0OiBmYWxzZX0sICgpID0+IHtcbiAgICAgIHJldHVybiB0aGlzLmNoYW5uZWwuam9pbigpXG4gICAgICAgIC5yZWNlaXZlKFwib2tcIiwgZGF0YSA9PiB7XG4gICAgICAgICAgaWYoIXRoaXMuaXNEZXN0cm95ZWQoKSl7XG4gICAgICAgICAgICB0aGlzLmxpdmVTb2NrZXQucmVxdWVzdERPTVVwZGF0ZSgoKSA9PiB0aGlzLm9uSm9pbihkYXRhKSlcbiAgICAgICAgICB9XG4gICAgICAgIH0pXG4gICAgICAgIC5yZWNlaXZlKFwiZXJyb3JcIiwgcmVzcCA9PiAhdGhpcy5pc0Rlc3Ryb3llZCgpICYmIHRoaXMub25Kb2luRXJyb3IocmVzcCkpXG4gICAgICAgIC5yZWNlaXZlKFwidGltZW91dFwiLCAoKSA9PiAhdGhpcy5pc0Rlc3Ryb3llZCgpICYmIHRoaXMub25Kb2luRXJyb3Ioe3JlYXNvbjogXCJ0aW1lb3V0XCJ9KSlcbiAgICB9KVxuICB9XG5cbiAgb25Kb2luRXJyb3IocmVzcCl7XG4gICAgaWYocmVzcC5yZWFzb24gPT09IFwicmVsb2FkXCIpe1xuICAgICAgdGhpcy5sb2coXCJlcnJvclwiLCAoKSA9PiBbYGZhaWxlZCBtb3VudCB3aXRoICR7cmVzcC5zdGF0dXN9LiBGYWxsaW5nIGJhY2sgdG8gcGFnZSByZXF1ZXN0YCwgcmVzcF0pXG4gICAgICByZXR1cm4gdGhpcy5vblJlZGlyZWN0KHt0bzogdGhpcy5ocmVmfSlcbiAgICB9IGVsc2UgaWYocmVzcC5yZWFzb24gPT09IFwidW5hdXRob3JpemVkXCIgfHwgcmVzcC5yZWFzb24gPT09IFwic3RhbGVcIil7XG4gICAgICB0aGlzLmxvZyhcImVycm9yXCIsICgpID0+IFtcInVuYXV0aG9yaXplZCBsaXZlX3JlZGlyZWN0LiBGYWxsaW5nIGJhY2sgdG8gcGFnZSByZXF1ZXN0XCIsIHJlc3BdKVxuICAgICAgcmV0dXJuIHRoaXMub25SZWRpcmVjdCh7dG86IHRoaXMuaHJlZn0pXG4gICAgfVxuICAgIGlmKHJlc3AucmVkaXJlY3QgfHwgcmVzcC5saXZlX3JlZGlyZWN0KXtcbiAgICAgIHRoaXMuam9pblBlbmRpbmcgPSBmYWxzZVxuICAgICAgdGhpcy5jaGFubmVsLmxlYXZlKClcbiAgICB9XG4gICAgaWYocmVzcC5yZWRpcmVjdCl7IHJldHVybiB0aGlzLm9uUmVkaXJlY3QocmVzcC5yZWRpcmVjdCkgfVxuICAgIGlmKHJlc3AubGl2ZV9yZWRpcmVjdCl7IHJldHVybiB0aGlzLm9uTGl2ZVJlZGlyZWN0KHJlc3AubGl2ZV9yZWRpcmVjdCkgfVxuICAgIHRoaXMubG9nKFwiZXJyb3JcIiwgKCkgPT4gW1widW5hYmxlIHRvIGpvaW5cIiwgcmVzcF0pXG4gICAgaWYodGhpcy5saXZlU29ja2V0LmlzQ29ubmVjdGVkKCkpeyB0aGlzLmxpdmVTb2NrZXQucmVsb2FkV2l0aEppdHRlcih0aGlzKSB9XG4gIH1cblxuICBvbkNsb3NlKHJlYXNvbil7XG4gICAgaWYodGhpcy5pc0Rlc3Ryb3llZCgpKXsgcmV0dXJuIH1cbiAgICBpZih0aGlzLmxpdmVTb2NrZXQuaGFzUGVuZGluZ0xpbmsoKSAmJiByZWFzb24gIT09IFwibGVhdmVcIil7XG4gICAgICByZXR1cm4gdGhpcy5saXZlU29ja2V0LnJlbG9hZFdpdGhKaXR0ZXIodGhpcylcbiAgICB9XG4gICAgdGhpcy5kZXN0cm95QWxsQ2hpbGRyZW4oKVxuICAgIHRoaXMubGl2ZVNvY2tldC5kcm9wQWN0aXZlRWxlbWVudCh0aGlzKVxuICAgIC8vIGRvY3VtZW50LmFjdGl2ZUVsZW1lbnQgY2FuIGJlIG51bGwgaW4gSW50ZXJuZXQgRXhwbG9yZXIgMTFcbiAgICBpZihkb2N1bWVudC5hY3RpdmVFbGVtZW50KXsgZG9jdW1lbnQuYWN0aXZlRWxlbWVudC5ibHVyKCkgfVxuICAgIGlmKHRoaXMubGl2ZVNvY2tldC5pc1VubG9hZGVkKCkpe1xuICAgICAgdGhpcy5zaG93TG9hZGVyKEJFRk9SRV9VTkxPQURfTE9BREVSX1RJTUVPVVQpXG4gICAgfVxuICB9XG5cbiAgb25FcnJvcihyZWFzb24pe1xuICAgIHRoaXMub25DbG9zZShyZWFzb24pXG4gICAgaWYodGhpcy5saXZlU29ja2V0LmlzQ29ubmVjdGVkKCkpeyB0aGlzLmxvZyhcImVycm9yXCIsICgpID0+IFtcInZpZXcgY3Jhc2hlZFwiLCByZWFzb25dKSB9XG4gICAgaWYoIXRoaXMubGl2ZVNvY2tldC5pc1VubG9hZGVkKCkpeyB0aGlzLmRpc3BsYXlFcnJvcigpIH1cbiAgfVxuXG4gIGRpc3BsYXlFcnJvcigpe1xuICAgIGlmKHRoaXMuaXNNYWluKCkpeyBET00uZGlzcGF0Y2hFdmVudCh3aW5kb3csIFwicGh4OnBhZ2UtbG9hZGluZy1zdGFydFwiLCB7ZGV0YWlsOiB7dG86IHRoaXMuaHJlZiwga2luZDogXCJlcnJvclwifX0pIH1cbiAgICB0aGlzLnNob3dMb2FkZXIoKVxuICAgIHRoaXMuc2V0Q29udGFpbmVyQ2xhc3NlcyhQSFhfRElTQ09OTkVDVEVEX0NMQVNTLCBQSFhfRVJST1JfQ0xBU1MpXG4gICAgdGhpcy5leGVjQWxsKHRoaXMuYmluZGluZyhcImRpc2Nvbm5lY3RlZFwiKSlcbiAgfVxuXG4gIHB1c2hXaXRoUmVwbHkocmVmR2VuZXJhdG9yLCBldmVudCwgcGF5bG9hZCwgb25SZXBseSA9IGZ1bmN0aW9uICgpeyB9KXtcbiAgICBpZighdGhpcy5pc0Nvbm5lY3RlZCgpKXsgcmV0dXJuIH1cblxuICAgIGxldCBbcmVmLCBbZWxdLCBvcHRzXSA9IHJlZkdlbmVyYXRvciA/IHJlZkdlbmVyYXRvcigpIDogW251bGwsIFtdLCB7fV1cbiAgICBsZXQgb25Mb2FkaW5nRG9uZSA9IGZ1bmN0aW9uKCl7IH1cbiAgICBpZihvcHRzLnBhZ2VfbG9hZGluZyB8fCAoZWwgJiYgKGVsLmdldEF0dHJpYnV0ZSh0aGlzLmJpbmRpbmcoUEhYX1BBR0VfTE9BRElORykpICE9PSBudWxsKSkpe1xuICAgICAgb25Mb2FkaW5nRG9uZSA9IHRoaXMubGl2ZVNvY2tldC53aXRoUGFnZUxvYWRpbmcoe2tpbmQ6IFwiZWxlbWVudFwiLCB0YXJnZXQ6IGVsfSlcbiAgICB9XG5cbiAgICBpZih0eXBlb2YgKHBheWxvYWQuY2lkKSAhPT0gXCJudW1iZXJcIil7IGRlbGV0ZSBwYXlsb2FkLmNpZCB9XG4gICAgcmV0dXJuIChcbiAgICAgIHRoaXMubGl2ZVNvY2tldC53cmFwUHVzaCh0aGlzLCB7dGltZW91dDogdHJ1ZX0sICgpID0+IHtcbiAgICAgICAgcmV0dXJuIHRoaXMuY2hhbm5lbC5wdXNoKGV2ZW50LCBwYXlsb2FkLCBQVVNIX1RJTUVPVVQpLnJlY2VpdmUoXCJva1wiLCByZXNwID0+IHtcbiAgICAgICAgICBsZXQgZmluaXNoID0gKGhvb2tSZXBseSkgPT4ge1xuICAgICAgICAgICAgaWYocmVzcC5yZWRpcmVjdCl7IHRoaXMub25SZWRpcmVjdChyZXNwLnJlZGlyZWN0KSB9XG4gICAgICAgICAgICBpZihyZXNwLmxpdmVfcGF0Y2gpeyB0aGlzLm9uTGl2ZVBhdGNoKHJlc3AubGl2ZV9wYXRjaCkgfVxuICAgICAgICAgICAgaWYocmVzcC5saXZlX3JlZGlyZWN0KXsgdGhpcy5vbkxpdmVSZWRpcmVjdChyZXNwLmxpdmVfcmVkaXJlY3QpIH1cbiAgICAgICAgICAgIGlmKHJlZiAhPT0gbnVsbCl7IHRoaXMudW5kb1JlZnMocmVmKSB9XG4gICAgICAgICAgICBvbkxvYWRpbmdEb25lKClcbiAgICAgICAgICAgIG9uUmVwbHkocmVzcCwgaG9va1JlcGx5KVxuICAgICAgICAgIH1cbiAgICAgICAgICBpZihyZXNwLmRpZmYpe1xuICAgICAgICAgICAgdGhpcy5saXZlU29ja2V0LnJlcXVlc3RET01VcGRhdGUoKCkgPT4ge1xuICAgICAgICAgICAgICB0aGlzLmFwcGx5RGlmZihcInVwZGF0ZVwiLCByZXNwLmRpZmYsICh7ZGlmZiwgcmVwbHksIGV2ZW50c30pID0+IHtcbiAgICAgICAgICAgICAgICB0aGlzLnVwZGF0ZShkaWZmLCBldmVudHMpXG4gICAgICAgICAgICAgICAgZmluaXNoKHJlcGx5KVxuICAgICAgICAgICAgICB9KVxuICAgICAgICAgICAgfSlcbiAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgZmluaXNoKG51bGwpXG4gICAgICAgICAgfVxuICAgICAgICB9KVxuICAgICAgfSlcbiAgICApXG4gIH1cblxuICB1bmRvUmVmcyhyZWYpe1xuICAgIGlmKCF0aGlzLmlzQ29ubmVjdGVkKCkpeyByZXR1cm4gfSAvLyBleGl0IGlmIGV4dGVybmFsIGZvcm0gdHJpZ2dlcmVkXG5cbiAgICBET00uYWxsKGRvY3VtZW50LCBgWyR7UEhYX1JFRl9TUkN9PVwiJHt0aGlzLmlkfVwiXVske1BIWF9SRUZ9PVwiJHtyZWZ9XCJdYCwgZWwgPT4ge1xuICAgICAgbGV0IGRpc2FibGVkVmFsID0gZWwuZ2V0QXR0cmlidXRlKFBIWF9ESVNBQkxFRClcbiAgICAgIC8vIHJlbW92ZSByZWZzXG4gICAgICBlbC5yZW1vdmVBdHRyaWJ1dGUoUEhYX1JFRilcbiAgICAgIGVsLnJlbW92ZUF0dHJpYnV0ZShQSFhfUkVGX1NSQylcbiAgICAgIC8vIHJlc3RvcmUgaW5wdXRzXG4gICAgICBpZihlbC5nZXRBdHRyaWJ1dGUoUEhYX1JFQURPTkxZKSAhPT0gbnVsbCl7XG4gICAgICAgIGVsLnJlYWRPbmx5ID0gZmFsc2VcbiAgICAgICAgZWwucmVtb3ZlQXR0cmlidXRlKFBIWF9SRUFET05MWSlcbiAgICAgIH1cbiAgICAgIGlmKGRpc2FibGVkVmFsICE9PSBudWxsKXtcbiAgICAgICAgZWwuZGlzYWJsZWQgPSBkaXNhYmxlZFZhbCA9PT0gXCJ0cnVlXCIgPyB0cnVlIDogZmFsc2VcbiAgICAgICAgZWwucmVtb3ZlQXR0cmlidXRlKFBIWF9ESVNBQkxFRClcbiAgICAgIH1cbiAgICAgIC8vIHJlbW92ZSBjbGFzc2VzXG4gICAgICBQSFhfRVZFTlRfQ0xBU1NFUy5mb3JFYWNoKGNsYXNzTmFtZSA9PiBET00ucmVtb3ZlQ2xhc3MoZWwsIGNsYXNzTmFtZSkpXG4gICAgICAvLyByZXN0b3JlIGRpc2FibGVzXG4gICAgICBsZXQgZGlzYWJsZVJlc3RvcmUgPSBlbC5nZXRBdHRyaWJ1dGUoUEhYX0RJU0FCTEVfV0lUSF9SRVNUT1JFKVxuICAgICAgaWYoZGlzYWJsZVJlc3RvcmUgIT09IG51bGwpe1xuICAgICAgICBlbC5pbm5lclRleHQgPSBkaXNhYmxlUmVzdG9yZVxuICAgICAgICBlbC5yZW1vdmVBdHRyaWJ1dGUoUEhYX0RJU0FCTEVfV0lUSF9SRVNUT1JFKVxuICAgICAgfVxuICAgICAgbGV0IHRvRWwgPSBET00ucHJpdmF0ZShlbCwgUEhYX1JFRilcbiAgICAgIGlmKHRvRWwpe1xuICAgICAgICBsZXQgaG9vayA9IHRoaXMudHJpZ2dlckJlZm9yZVVwZGF0ZUhvb2soZWwsIHRvRWwpXG4gICAgICAgIERPTVBhdGNoLnBhdGNoRWwoZWwsIHRvRWwsIHRoaXMubGl2ZVNvY2tldC5nZXRBY3RpdmVFbGVtZW50KCkpXG4gICAgICAgIGlmKGhvb2speyBob29rLl9fdXBkYXRlZCgpIH1cbiAgICAgICAgRE9NLmRlbGV0ZVByaXZhdGUoZWwsIFBIWF9SRUYpXG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIHB1dFJlZihlbGVtZW50cywgZXZlbnQsIG9wdHMgPSB7fSl7XG4gICAgbGV0IG5ld1JlZiA9IHRoaXMucmVmKytcbiAgICBsZXQgZGlzYWJsZVdpdGggPSB0aGlzLmJpbmRpbmcoUEhYX0RJU0FCTEVfV0lUSClcbiAgICBpZihvcHRzLmxvYWRpbmcpeyBlbGVtZW50cyA9IGVsZW1lbnRzLmNvbmNhdChET00uYWxsKGRvY3VtZW50LCBvcHRzLmxvYWRpbmcpKX1cblxuICAgIGVsZW1lbnRzLmZvckVhY2goZWwgPT4ge1xuICAgICAgZWwuY2xhc3NMaXN0LmFkZChgcGh4LSR7ZXZlbnR9LWxvYWRpbmdgKVxuICAgICAgZWwuc2V0QXR0cmlidXRlKFBIWF9SRUYsIG5ld1JlZilcbiAgICAgIGVsLnNldEF0dHJpYnV0ZShQSFhfUkVGX1NSQywgdGhpcy5lbC5pZClcbiAgICAgIGxldCBkaXNhYmxlVGV4dCA9IGVsLmdldEF0dHJpYnV0ZShkaXNhYmxlV2l0aClcbiAgICAgIGlmKGRpc2FibGVUZXh0ICE9PSBudWxsKXtcbiAgICAgICAgaWYoIWVsLmdldEF0dHJpYnV0ZShQSFhfRElTQUJMRV9XSVRIX1JFU1RPUkUpKXtcbiAgICAgICAgICBlbC5zZXRBdHRyaWJ1dGUoUEhYX0RJU0FCTEVfV0lUSF9SRVNUT1JFLCBlbC5pbm5lclRleHQpXG4gICAgICAgIH1cbiAgICAgICAgaWYoZGlzYWJsZVRleHQgIT09IFwiXCIpeyBlbC5pbm5lclRleHQgPSBkaXNhYmxlVGV4dCB9XG4gICAgICAgIGVsLnNldEF0dHJpYnV0ZShcImRpc2FibGVkXCIsIFwiXCIpXG4gICAgICB9XG4gICAgfSlcbiAgICByZXR1cm4gW25ld1JlZiwgZWxlbWVudHMsIG9wdHNdXG4gIH1cblxuICBjb21wb25lbnRJRChlbCl7XG4gICAgbGV0IGNpZCA9IGVsLmdldEF0dHJpYnV0ZSAmJiBlbC5nZXRBdHRyaWJ1dGUoUEhYX0NPTVBPTkVOVClcbiAgICByZXR1cm4gY2lkID8gcGFyc2VJbnQoY2lkKSA6IG51bGxcbiAgfVxuXG4gIHRhcmdldENvbXBvbmVudElEKHRhcmdldCwgdGFyZ2V0Q3R4LCBvcHRzID0ge30pe1xuICAgIGlmKGlzQ2lkKHRhcmdldEN0eCkpeyByZXR1cm4gdGFyZ2V0Q3R4IH1cblxuICAgIGxldCBjaWRPclNlbGVjdG9yID0gdGFyZ2V0LmdldEF0dHJpYnV0ZSh0aGlzLmJpbmRpbmcoXCJ0YXJnZXRcIikpXG4gICAgaWYoaXNDaWQoY2lkT3JTZWxlY3Rvcikpe1xuICAgICAgcmV0dXJuIHBhcnNlSW50KGNpZE9yU2VsZWN0b3IpXG4gICAgfSBlbHNlIGlmKHRhcmdldEN0eCAmJiAoY2lkT3JTZWxlY3RvciAhPT0gbnVsbCB8fCBvcHRzLnRhcmdldCkpe1xuICAgICAgcmV0dXJuIHRoaXMuY2xvc2VzdENvbXBvbmVudElEKHRhcmdldEN0eClcbiAgICB9IGVsc2Uge1xuICAgICAgcmV0dXJuIG51bGxcbiAgICB9XG4gIH1cblxuICBjbG9zZXN0Q29tcG9uZW50SUQodGFyZ2V0Q3R4KXtcbiAgICBpZihpc0NpZCh0YXJnZXRDdHgpKXtcbiAgICAgIHJldHVybiB0YXJnZXRDdHhcbiAgICB9IGVsc2UgaWYodGFyZ2V0Q3R4KXtcbiAgICAgIHJldHVybiBtYXliZSh0YXJnZXRDdHguY2xvc2VzdChgWyR7UEhYX0NPTVBPTkVOVH1dYCksIGVsID0+IHRoaXMub3duc0VsZW1lbnQoZWwpICYmIHRoaXMuY29tcG9uZW50SUQoZWwpKVxuICAgIH0gZWxzZSB7XG4gICAgICByZXR1cm4gbnVsbFxuICAgIH1cbiAgfVxuXG4gIHB1c2hIb29rRXZlbnQodGFyZ2V0Q3R4LCBldmVudCwgcGF5bG9hZCwgb25SZXBseSl7XG4gICAgaWYoIXRoaXMuaXNDb25uZWN0ZWQoKSl7XG4gICAgICB0aGlzLmxvZyhcImhvb2tcIiwgKCkgPT4gW1widW5hYmxlIHRvIHB1c2ggaG9vayBldmVudC4gTGl2ZVZpZXcgbm90IGNvbm5lY3RlZFwiLCBldmVudCwgcGF5bG9hZF0pXG4gICAgICByZXR1cm4gZmFsc2VcbiAgICB9XG4gICAgbGV0IFtyZWYsIGVscywgb3B0c10gPSB0aGlzLnB1dFJlZihbXSwgXCJob29rXCIpXG4gICAgdGhpcy5wdXNoV2l0aFJlcGx5KCgpID0+IFtyZWYsIGVscywgb3B0c10sIFwiZXZlbnRcIiwge1xuICAgICAgdHlwZTogXCJob29rXCIsXG4gICAgICBldmVudDogZXZlbnQsXG4gICAgICB2YWx1ZTogcGF5bG9hZCxcbiAgICAgIGNpZDogdGhpcy5jbG9zZXN0Q29tcG9uZW50SUQodGFyZ2V0Q3R4KVxuICAgIH0sIChyZXNwLCByZXBseSkgPT4gb25SZXBseShyZXBseSwgcmVmKSlcblxuICAgIHJldHVybiByZWZcbiAgfVxuXG4gIGV4dHJhY3RNZXRhKGVsLCBtZXRhLCB2YWx1ZSl7XG4gICAgbGV0IHByZWZpeCA9IHRoaXMuYmluZGluZyhcInZhbHVlLVwiKVxuICAgIGZvcihsZXQgaSA9IDA7IGkgPCBlbC5hdHRyaWJ1dGVzLmxlbmd0aDsgaSsrKXtcbiAgICAgIGlmKCFtZXRhKXsgbWV0YSA9IHt9IH1cbiAgICAgIGxldCBuYW1lID0gZWwuYXR0cmlidXRlc1tpXS5uYW1lXG4gICAgICBpZihuYW1lLnN0YXJ0c1dpdGgocHJlZml4KSl7IG1ldGFbbmFtZS5yZXBsYWNlKHByZWZpeCwgXCJcIildID0gZWwuZ2V0QXR0cmlidXRlKG5hbWUpIH1cbiAgICB9XG4gICAgaWYoZWwudmFsdWUgIT09IHVuZGVmaW5lZCl7XG4gICAgICBpZighbWV0YSl7IG1ldGEgPSB7fSB9XG4gICAgICBtZXRhLnZhbHVlID0gZWwudmFsdWVcblxuICAgICAgaWYoZWwudGFnTmFtZSA9PT0gXCJJTlBVVFwiICYmIENIRUNLQUJMRV9JTlBVVFMuaW5kZXhPZihlbC50eXBlKSA+PSAwICYmICFlbC5jaGVja2VkKXtcbiAgICAgICAgZGVsZXRlIG1ldGEudmFsdWVcbiAgICAgIH1cbiAgICB9XG4gICAgaWYodmFsdWUpe1xuICAgICAgaWYoIW1ldGEpeyBtZXRhID0ge30gfVxuICAgICAgZm9yKGxldCBrZXkgaW4gdmFsdWUpeyBtZXRhW2tleV0gPSB2YWx1ZVtrZXldIH1cbiAgICB9XG4gICAgcmV0dXJuIG1ldGFcbiAgfVxuXG4gIHB1c2hFdmVudCh0eXBlLCBlbCwgdGFyZ2V0Q3R4LCBwaHhFdmVudCwgbWV0YSwgb3B0cyA9IHt9KXtcbiAgICB0aGlzLnB1c2hXaXRoUmVwbHkoKCkgPT4gdGhpcy5wdXRSZWYoW2VsXSwgdHlwZSwgb3B0cyksIFwiZXZlbnRcIiwge1xuICAgICAgdHlwZTogdHlwZSxcbiAgICAgIGV2ZW50OiBwaHhFdmVudCxcbiAgICAgIHZhbHVlOiB0aGlzLmV4dHJhY3RNZXRhKGVsLCBtZXRhLCBvcHRzLnZhbHVlKSxcbiAgICAgIGNpZDogdGhpcy50YXJnZXRDb21wb25lbnRJRChlbCwgdGFyZ2V0Q3R4LCBvcHRzKVxuICAgIH0pXG4gIH1cblxuICBwdXNoRmlsZVByb2dyZXNzKGZpbGVFbCwgZW50cnlSZWYsIHByb2dyZXNzLCBvblJlcGx5ID0gZnVuY3Rpb24gKCl7IH0pe1xuICAgIHRoaXMubGl2ZVNvY2tldC53aXRoaW5Pd25lcnMoZmlsZUVsLmZvcm0sICh2aWV3LCB0YXJnZXRDdHgpID0+IHtcbiAgICAgIHZpZXcucHVzaFdpdGhSZXBseShudWxsLCBcInByb2dyZXNzXCIsIHtcbiAgICAgICAgZXZlbnQ6IGZpbGVFbC5nZXRBdHRyaWJ1dGUodmlldy5iaW5kaW5nKFBIWF9QUk9HUkVTUykpLFxuICAgICAgICByZWY6IGZpbGVFbC5nZXRBdHRyaWJ1dGUoUEhYX1VQTE9BRF9SRUYpLFxuICAgICAgICBlbnRyeV9yZWY6IGVudHJ5UmVmLFxuICAgICAgICBwcm9ncmVzczogcHJvZ3Jlc3MsXG4gICAgICAgIGNpZDogdmlldy50YXJnZXRDb21wb25lbnRJRChmaWxlRWwuZm9ybSwgdGFyZ2V0Q3R4KVxuICAgICAgfSwgb25SZXBseSlcbiAgICB9KVxuICB9XG5cbiAgcHVzaElucHV0KGlucHV0RWwsIHRhcmdldEN0eCwgZm9yY2VDaWQsIHBoeEV2ZW50LCBvcHRzLCBjYWxsYmFjayl7XG4gICAgbGV0IHVwbG9hZHNcbiAgICBsZXQgY2lkID0gaXNDaWQoZm9yY2VDaWQpID8gZm9yY2VDaWQgOiB0aGlzLnRhcmdldENvbXBvbmVudElEKGlucHV0RWwuZm9ybSwgdGFyZ2V0Q3R4KVxuICAgIGxldCByZWZHZW5lcmF0b3IgPSAoKSA9PiB0aGlzLnB1dFJlZihbaW5wdXRFbCwgaW5wdXRFbC5mb3JtXSwgXCJjaGFuZ2VcIiwgb3B0cylcbiAgICBsZXQgZm9ybURhdGFcbiAgICBpZihpbnB1dEVsLmdldEF0dHJpYnV0ZSh0aGlzLmJpbmRpbmcoXCJjaGFuZ2VcIikpKXtcbiAgICAgIGZvcm1EYXRhID0gc2VyaWFsaXplRm9ybShpbnB1dEVsLmZvcm0sIHtfdGFyZ2V0OiBvcHRzLl90YXJnZXR9LCBbaW5wdXRFbC5uYW1lXSlcbiAgICB9IGVsc2Uge1xuICAgICAgZm9ybURhdGEgPSBzZXJpYWxpemVGb3JtKGlucHV0RWwuZm9ybSwge190YXJnZXQ6IG9wdHMuX3RhcmdldH0pXG4gICAgfVxuICAgIGlmKERPTS5pc1VwbG9hZElucHV0KGlucHV0RWwpICYmIGlucHV0RWwuZmlsZXMgJiYgaW5wdXRFbC5maWxlcy5sZW5ndGggPiAwKXtcbiAgICAgIExpdmVVcGxvYWRlci50cmFja0ZpbGVzKGlucHV0RWwsIEFycmF5LmZyb20oaW5wdXRFbC5maWxlcykpXG4gICAgfVxuICAgIHVwbG9hZHMgPSBMaXZlVXBsb2FkZXIuc2VyaWFsaXplVXBsb2FkcyhpbnB1dEVsKVxuICAgIGxldCBldmVudCA9IHtcbiAgICAgIHR5cGU6IFwiZm9ybVwiLFxuICAgICAgZXZlbnQ6IHBoeEV2ZW50LFxuICAgICAgdmFsdWU6IGZvcm1EYXRhLFxuICAgICAgdXBsb2FkczogdXBsb2FkcyxcbiAgICAgIGNpZDogY2lkXG4gICAgfVxuICAgIHRoaXMucHVzaFdpdGhSZXBseShyZWZHZW5lcmF0b3IsIFwiZXZlbnRcIiwgZXZlbnQsIHJlc3AgPT4ge1xuICAgICAgRE9NLnNob3dFcnJvcihpbnB1dEVsLCB0aGlzLmxpdmVTb2NrZXQuYmluZGluZyhQSFhfRkVFREJBQ0tfRk9SKSlcbiAgICAgIGlmKERPTS5pc1VwbG9hZElucHV0KGlucHV0RWwpICYmIGlucHV0RWwuZ2V0QXR0cmlidXRlKFwiZGF0YS1waHgtYXV0by11cGxvYWRcIikgIT09IG51bGwpe1xuICAgICAgICBpZihMaXZlVXBsb2FkZXIuZmlsZXNBd2FpdGluZ1ByZWZsaWdodChpbnB1dEVsKS5sZW5ndGggPiAwKXtcbiAgICAgICAgICBsZXQgW3JlZiwgX2Vsc10gPSByZWZHZW5lcmF0b3IoKVxuICAgICAgICAgIHRoaXMudXBsb2FkRmlsZXMoaW5wdXRFbC5mb3JtLCB0YXJnZXRDdHgsIHJlZiwgY2lkLCAoX3VwbG9hZHMpID0+IHtcbiAgICAgICAgICAgIGNhbGxiYWNrICYmIGNhbGxiYWNrKHJlc3ApXG4gICAgICAgICAgICB0aGlzLnRyaWdnZXJBd2FpdGluZ1N1Ym1pdChpbnB1dEVsLmZvcm0pXG4gICAgICAgICAgfSlcbiAgICAgICAgfVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgY2FsbGJhY2sgJiYgY2FsbGJhY2socmVzcClcbiAgICAgIH1cbiAgICB9KVxuICB9XG5cbiAgdHJpZ2dlckF3YWl0aW5nU3VibWl0KGZvcm1FbCl7XG4gICAgbGV0IGF3YWl0aW5nU3VibWl0ID0gdGhpcy5nZXRTY2hlZHVsZWRTdWJtaXQoZm9ybUVsKVxuICAgIGlmKGF3YWl0aW5nU3VibWl0KXtcbiAgICAgIGxldCBbX2VsLCBfcmVmLCBfb3B0cywgY2FsbGJhY2tdID0gYXdhaXRpbmdTdWJtaXRcbiAgICAgIHRoaXMuY2FuY2VsU3VibWl0KGZvcm1FbClcbiAgICAgIGNhbGxiYWNrKClcbiAgICB9XG4gIH1cblxuICBnZXRTY2hlZHVsZWRTdWJtaXQoZm9ybUVsKXtcbiAgICByZXR1cm4gdGhpcy5mb3JtU3VibWl0cy5maW5kKChbZWwsIF9yZWYsIF9vcHRzLCBfY2FsbGJhY2tdKSA9PiBlbC5pc1NhbWVOb2RlKGZvcm1FbCkpXG4gIH1cblxuICBzY2hlZHVsZVN1Ym1pdChmb3JtRWwsIHJlZiwgb3B0cywgY2FsbGJhY2spe1xuICAgIGlmKHRoaXMuZ2V0U2NoZWR1bGVkU3VibWl0KGZvcm1FbCkpeyByZXR1cm4gdHJ1ZSB9XG4gICAgdGhpcy5mb3JtU3VibWl0cy5wdXNoKFtmb3JtRWwsIHJlZiwgb3B0cywgY2FsbGJhY2tdKVxuICB9XG5cbiAgY2FuY2VsU3VibWl0KGZvcm1FbCl7XG4gICAgdGhpcy5mb3JtU3VibWl0cyA9IHRoaXMuZm9ybVN1Ym1pdHMuZmlsdGVyKChbZWwsIHJlZiwgX2NhbGxiYWNrXSkgPT4ge1xuICAgICAgaWYoZWwuaXNTYW1lTm9kZShmb3JtRWwpKXtcbiAgICAgICAgdGhpcy51bmRvUmVmcyhyZWYpXG4gICAgICAgIHJldHVybiBmYWxzZVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgcmV0dXJuIHRydWVcbiAgICAgIH1cbiAgICB9KVxuICB9XG5cbiAgZGlzYWJsZUZvcm0oZm9ybUVsLCBvcHRzID0ge30pe1xuICAgIGxldCBmaWx0ZXJJZ25vcmVkID0gZWwgPT4ge1xuICAgICAgbGV0IHVzZXJJZ25vcmVkID0gY2xvc2VzdFBoeEJpbmRpbmcoZWwsIGAke3RoaXMuYmluZGluZyhQSFhfVVBEQVRFKX09aWdub3JlYCwgZWwuZm9ybSlcbiAgICAgIHJldHVybiAhKHVzZXJJZ25vcmVkIHx8IGNsb3Nlc3RQaHhCaW5kaW5nKGVsLCBcImRhdGEtcGh4LXVwZGF0ZT1pZ25vcmVcIiwgZWwuZm9ybSkpXG4gICAgfVxuICAgIGxldCBmaWx0ZXJEaXNhYmxlcyA9IGVsID0+IHtcbiAgICAgIHJldHVybiBlbC5oYXNBdHRyaWJ1dGUodGhpcy5iaW5kaW5nKFBIWF9ESVNBQkxFX1dJVEgpKVxuICAgIH1cbiAgICBsZXQgZmlsdGVyQnV0dG9uID0gZWwgPT4gZWwudGFnTmFtZSA9PSBcIkJVVFRPTlwiXG5cbiAgICBsZXQgZmlsdGVySW5wdXQgPSBlbCA9PiBbXCJJTlBVVFwiLCBcIlRFWFRBUkVBXCIsIFwiU0VMRUNUXCJdLmluY2x1ZGVzKGVsLnRhZ05hbWUpXG5cbiAgICBsZXQgZm9ybUVsZW1lbnRzID0gQXJyYXkuZnJvbShmb3JtRWwuZWxlbWVudHMpXG4gICAgbGV0IGRpc2FibGVzID0gZm9ybUVsZW1lbnRzLmZpbHRlcihmaWx0ZXJEaXNhYmxlcylcbiAgICBsZXQgYnV0dG9ucyA9IGZvcm1FbGVtZW50cy5maWx0ZXIoZmlsdGVyQnV0dG9uKS5maWx0ZXIoZmlsdGVySWdub3JlZClcbiAgICBsZXQgaW5wdXRzID0gZm9ybUVsZW1lbnRzLmZpbHRlcihmaWx0ZXJJbnB1dCkuZmlsdGVyKGZpbHRlcklnbm9yZWQpXG5cbiAgICBidXR0b25zLmZvckVhY2goYnV0dG9uID0+IHtcbiAgICAgIGJ1dHRvbi5zZXRBdHRyaWJ1dGUoUEhYX0RJU0FCTEVELCBidXR0b24uZGlzYWJsZWQpXG4gICAgICBidXR0b24uZGlzYWJsZWQgPSB0cnVlXG4gICAgfSlcbiAgICBpbnB1dHMuZm9yRWFjaChpbnB1dCA9PiB7XG4gICAgICBpbnB1dC5zZXRBdHRyaWJ1dGUoUEhYX1JFQURPTkxZLCBpbnB1dC5yZWFkT25seSlcbiAgICAgIGlucHV0LnJlYWRPbmx5ID0gdHJ1ZVxuICAgICAgaWYoaW5wdXQuZmlsZXMpe1xuICAgICAgICBpbnB1dC5zZXRBdHRyaWJ1dGUoUEhYX0RJU0FCTEVELCBpbnB1dC5kaXNhYmxlZClcbiAgICAgICAgaW5wdXQuZGlzYWJsZWQgPSB0cnVlXG4gICAgICB9XG4gICAgfSlcbiAgICBmb3JtRWwuc2V0QXR0cmlidXRlKHRoaXMuYmluZGluZyhQSFhfUEFHRV9MT0FESU5HKSwgXCJcIilcbiAgICByZXR1cm4gdGhpcy5wdXRSZWYoW2Zvcm1FbF0uY29uY2F0KGRpc2FibGVzKS5jb25jYXQoYnV0dG9ucykuY29uY2F0KGlucHV0cyksIFwic3VibWl0XCIsIG9wdHMpXG4gIH1cblxuICBwdXNoRm9ybVN1Ym1pdChmb3JtRWwsIHRhcmdldEN0eCwgcGh4RXZlbnQsIHN1Ym1pdHRlciwgb3B0cywgb25SZXBseSl7XG4gICAgbGV0IHJlZkdlbmVyYXRvciA9ICgpID0+IHRoaXMuZGlzYWJsZUZvcm0oZm9ybUVsLCBvcHRzKVxuICAgIGxldCBjaWQgPSB0aGlzLnRhcmdldENvbXBvbmVudElEKGZvcm1FbCwgdGFyZ2V0Q3R4KVxuICAgIGlmKExpdmVVcGxvYWRlci5oYXNVcGxvYWRzSW5Qcm9ncmVzcyhmb3JtRWwpKXtcbiAgICAgIGxldCBbcmVmLCBfZWxzXSA9IHJlZkdlbmVyYXRvcigpXG4gICAgICBsZXQgcHVzaCA9ICgpID0+IHRoaXMucHVzaEZvcm1TdWJtaXQoZm9ybUVsLCBzdWJtaXR0ZXIsIHRhcmdldEN0eCwgcGh4RXZlbnQsIG9wdHMsIG9uUmVwbHkpXG4gICAgICByZXR1cm4gdGhpcy5zY2hlZHVsZVN1Ym1pdChmb3JtRWwsIHJlZiwgb3B0cywgcHVzaClcbiAgICB9IGVsc2UgaWYoTGl2ZVVwbG9hZGVyLmlucHV0c0F3YWl0aW5nUHJlZmxpZ2h0KGZvcm1FbCkubGVuZ3RoID4gMCl7XG4gICAgICBsZXQgW3JlZiwgZWxzXSA9IHJlZkdlbmVyYXRvcigpXG4gICAgICBsZXQgcHJveHlSZWZHZW4gPSAoKSA9PiBbcmVmLCBlbHMsIG9wdHNdXG4gICAgICB0aGlzLnVwbG9hZEZpbGVzKGZvcm1FbCwgdGFyZ2V0Q3R4LCByZWYsIGNpZCwgKF91cGxvYWRzKSA9PiB7XG4gICAgICAgIGxldCBmb3JtRGF0YSA9IHNlcmlhbGl6ZUZvcm0oZm9ybUVsLCB7c3VibWl0dGVyfSlcbiAgICAgICAgdGhpcy5wdXNoV2l0aFJlcGx5KHByb3h5UmVmR2VuLCBcImV2ZW50XCIsIHtcbiAgICAgICAgICB0eXBlOiBcImZvcm1cIixcbiAgICAgICAgICBldmVudDogcGh4RXZlbnQsXG4gICAgICAgICAgdmFsdWU6IGZvcm1EYXRhLFxuICAgICAgICAgIGNpZDogY2lkXG4gICAgICAgIH0sIG9uUmVwbHkpXG4gICAgICB9KVxuICAgIH0gZWxzZSB7XG4gICAgICBsZXQgZm9ybURhdGEgPSBzZXJpYWxpemVGb3JtKGZvcm1FbCwge3N1Ym1pdHRlcn0pXG4gICAgICB0aGlzLnB1c2hXaXRoUmVwbHkocmVmR2VuZXJhdG9yLCBcImV2ZW50XCIsIHtcbiAgICAgICAgdHlwZTogXCJmb3JtXCIsXG4gICAgICAgIGV2ZW50OiBwaHhFdmVudCxcbiAgICAgICAgdmFsdWU6IGZvcm1EYXRhLFxuICAgICAgICBjaWQ6IGNpZFxuICAgICAgfSwgb25SZXBseSlcbiAgICB9XG4gIH1cblxuICB1cGxvYWRGaWxlcyhmb3JtRWwsIHRhcmdldEN0eCwgcmVmLCBjaWQsIG9uQ29tcGxldGUpe1xuICAgIGxldCBqb2luQ291bnRBdFVwbG9hZCA9IHRoaXMuam9pbkNvdW50XG4gICAgbGV0IGlucHV0RWxzID0gTGl2ZVVwbG9hZGVyLmFjdGl2ZUZpbGVJbnB1dHMoZm9ybUVsKVxuICAgIGxldCBudW1GaWxlSW5wdXRzSW5Qcm9ncmVzcyA9IGlucHV0RWxzLmxlbmd0aFxuXG4gICAgLy8gZ2V0IGVhY2ggZmlsZSBpbnB1dFxuICAgIGlucHV0RWxzLmZvckVhY2goaW5wdXRFbCA9PiB7XG4gICAgICBsZXQgdXBsb2FkZXIgPSBuZXcgTGl2ZVVwbG9hZGVyKGlucHV0RWwsIHRoaXMsICgpID0+IHtcbiAgICAgICAgbnVtRmlsZUlucHV0c0luUHJvZ3Jlc3MtLVxuICAgICAgICBpZihudW1GaWxlSW5wdXRzSW5Qcm9ncmVzcyA9PT0gMCl7IG9uQ29tcGxldGUoKSB9XG4gICAgICB9KTtcblxuICAgICAgdGhpcy51cGxvYWRlcnNbaW5wdXRFbF0gPSB1cGxvYWRlclxuICAgICAgbGV0IGVudHJpZXMgPSB1cGxvYWRlci5lbnRyaWVzKCkubWFwKGVudHJ5ID0+IGVudHJ5LnRvUHJlZmxpZ2h0UGF5bG9hZCgpKVxuXG4gICAgICBsZXQgcGF5bG9hZCA9IHtcbiAgICAgICAgcmVmOiBpbnB1dEVsLmdldEF0dHJpYnV0ZShQSFhfVVBMT0FEX1JFRiksXG4gICAgICAgIGVudHJpZXM6IGVudHJpZXMsXG4gICAgICAgIGNpZDogdGhpcy50YXJnZXRDb21wb25lbnRJRChpbnB1dEVsLmZvcm0sIHRhcmdldEN0eClcbiAgICAgIH1cblxuICAgICAgdGhpcy5sb2coXCJ1cGxvYWRcIiwgKCkgPT4gW1wic2VuZGluZyBwcmVmbGlnaHQgcmVxdWVzdFwiLCBwYXlsb2FkXSlcblxuICAgICAgdGhpcy5wdXNoV2l0aFJlcGx5KG51bGwsIFwiYWxsb3dfdXBsb2FkXCIsIHBheWxvYWQsIHJlc3AgPT4ge1xuICAgICAgICB0aGlzLmxvZyhcInVwbG9hZFwiLCAoKSA9PiBbXCJnb3QgcHJlZmxpZ2h0IHJlc3BvbnNlXCIsIHJlc3BdKVxuICAgICAgICBpZihyZXNwLmVycm9yKXtcbiAgICAgICAgICB0aGlzLnVuZG9SZWZzKHJlZilcbiAgICAgICAgICBsZXQgW2VudHJ5X3JlZiwgcmVhc29uXSA9IHJlc3AuZXJyb3JcbiAgICAgICAgICB0aGlzLmxvZyhcInVwbG9hZFwiLCAoKSA9PiBbYGVycm9yIGZvciBlbnRyeSAke2VudHJ5X3JlZn1gLCByZWFzb25dKVxuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIGxldCBvbkVycm9yID0gKGNhbGxiYWNrKSA9PiB7XG4gICAgICAgICAgICB0aGlzLmNoYW5uZWwub25FcnJvcigoKSA9PiB7XG4gICAgICAgICAgICAgIGlmKHRoaXMuam9pbkNvdW50ID09PSBqb2luQ291bnRBdFVwbG9hZCl7IGNhbGxiYWNrKCkgfVxuICAgICAgICAgICAgfSlcbiAgICAgICAgICB9XG4gICAgICAgICAgdXBsb2FkZXIuaW5pdEFkYXB0ZXJVcGxvYWQocmVzcCwgb25FcnJvciwgdGhpcy5saXZlU29ja2V0KVxuICAgICAgICB9XG4gICAgICB9KVxuICAgIH0pXG4gIH1cblxuICBkaXNwYXRjaFVwbG9hZHMobmFtZSwgZmlsZXNPckJsb2JzKXtcbiAgICBsZXQgaW5wdXRzID0gRE9NLmZpbmRVcGxvYWRJbnB1dHModGhpcy5lbCkuZmlsdGVyKGVsID0+IGVsLm5hbWUgPT09IG5hbWUpXG4gICAgaWYoaW5wdXRzLmxlbmd0aCA9PT0gMCl7IGxvZ0Vycm9yKGBubyBsaXZlIGZpbGUgaW5wdXRzIGZvdW5kIG1hdGNoaW5nIHRoZSBuYW1lIFwiJHtuYW1lfVwiYCkgfVxuICAgIGVsc2UgaWYoaW5wdXRzLmxlbmd0aCA+IDEpeyBsb2dFcnJvcihgZHVwbGljYXRlIGxpdmUgZmlsZSBpbnB1dHMgZm91bmQgbWF0Y2hpbmcgdGhlIG5hbWUgXCIke25hbWV9XCJgKSB9XG4gICAgZWxzZSB7IERPTS5kaXNwYXRjaEV2ZW50KGlucHV0c1swXSwgUEhYX1RSQUNLX1VQTE9BRFMsIHtkZXRhaWw6IHtmaWxlczogZmlsZXNPckJsb2JzfX0pIH1cbiAgfVxuXG4gIHB1c2hGb3JtUmVjb3ZlcnkoZm9ybSwgbmV3Q2lkLCBjYWxsYmFjayl7XG4gICAgdGhpcy5saXZlU29ja2V0LndpdGhpbk93bmVycyhmb3JtLCAodmlldywgdGFyZ2V0Q3R4KSA9PiB7XG4gICAgICBsZXQgaW5wdXQgPSBBcnJheS5mcm9tKGZvcm0uZWxlbWVudHMpLmZpbmQoZWwgPT4ge1xuICAgICAgICByZXR1cm4gRE9NLmlzRm9ybUlucHV0KGVsKSAmJiBlbC50eXBlICE9PSBcImhpZGRlblwiICYmICFlbC5oYXNBdHRyaWJ1dGUodGhpcy5iaW5kaW5nKFwiY2hhbmdlXCIpKVxuICAgICAgfSlcbiAgICAgIGxldCBwaHhFdmVudCA9IGZvcm0uZ2V0QXR0cmlidXRlKHRoaXMuYmluZGluZyhQSFhfQVVUT19SRUNPVkVSKSkgfHwgZm9ybS5nZXRBdHRyaWJ1dGUodGhpcy5iaW5kaW5nKFwiY2hhbmdlXCIpKVxuXG4gICAgICBKUy5leGVjKFwiY2hhbmdlXCIsIHBoeEV2ZW50LCB2aWV3LCBpbnB1dCwgW1wicHVzaFwiLCB7X3RhcmdldDogaW5wdXQubmFtZSwgbmV3Q2lkOiBuZXdDaWQsIGNhbGxiYWNrOiBjYWxsYmFja31dKVxuICAgIH0pXG4gIH1cblxuICBwdXNoTGlua1BhdGNoKGhyZWYsIHRhcmdldEVsLCBjYWxsYmFjayl7XG4gICAgbGV0IGxpbmtSZWYgPSB0aGlzLmxpdmVTb2NrZXQuc2V0UGVuZGluZ0xpbmsoaHJlZilcbiAgICBsZXQgcmVmR2VuID0gdGFyZ2V0RWwgPyAoKSA9PiB0aGlzLnB1dFJlZihbdGFyZ2V0RWxdLCBcImNsaWNrXCIpIDogbnVsbFxuICAgIGxldCBmYWxsYmFjayA9ICgpID0+IHRoaXMubGl2ZVNvY2tldC5yZWRpcmVjdCh3aW5kb3cubG9jYXRpb24uaHJlZilcblxuICAgIGxldCBwdXNoID0gdGhpcy5wdXNoV2l0aFJlcGx5KHJlZkdlbiwgXCJsaXZlX3BhdGNoXCIsIHt1cmw6IGhyZWZ9LCByZXNwID0+IHtcbiAgICAgIHRoaXMubGl2ZVNvY2tldC5yZXF1ZXN0RE9NVXBkYXRlKCgpID0+IHtcbiAgICAgICAgaWYocmVzcC5saW5rX3JlZGlyZWN0KXtcbiAgICAgICAgICB0aGlzLmxpdmVTb2NrZXQucmVwbGFjZU1haW4oaHJlZiwgbnVsbCwgY2FsbGJhY2ssIGxpbmtSZWYpXG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgaWYodGhpcy5saXZlU29ja2V0LmNvbW1pdFBlbmRpbmdMaW5rKGxpbmtSZWYpKXtcbiAgICAgICAgICAgIHRoaXMuaHJlZiA9IGhyZWZcbiAgICAgICAgICB9XG4gICAgICAgICAgdGhpcy5hcHBseVBlbmRpbmdVcGRhdGVzKClcbiAgICAgICAgICBjYWxsYmFjayAmJiBjYWxsYmFjayhsaW5rUmVmKVxuICAgICAgICB9XG4gICAgICB9KVxuICAgIH0pXG5cbiAgICBpZihwdXNoKXtcbiAgICAgIHB1c2gucmVjZWl2ZShcInRpbWVvdXRcIiwgZmFsbGJhY2spXG4gICAgfSBlbHNlIHtcbiAgICAgIGZhbGxiYWNrKClcbiAgICB9XG4gIH1cblxuICBmb3Jtc0ZvclJlY292ZXJ5KGh0bWwpe1xuICAgIGlmKHRoaXMuam9pbkNvdW50ID09PSAwKXsgcmV0dXJuIFtdIH1cblxuICAgIGxldCBwaHhDaGFuZ2UgPSB0aGlzLmJpbmRpbmcoXCJjaGFuZ2VcIilcbiAgICBsZXQgdGVtcGxhdGUgPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KFwidGVtcGxhdGVcIilcbiAgICB0ZW1wbGF0ZS5pbm5lckhUTUwgPSBodG1sXG5cbiAgICByZXR1cm4gKFxuICAgICAgRE9NLmFsbCh0aGlzLmVsLCBgZm9ybVske3BoeENoYW5nZX1dYClcbiAgICAgICAgLmZpbHRlcihmb3JtID0+IGZvcm0uaWQgJiYgdGhpcy5vd25zRWxlbWVudChmb3JtKSlcbiAgICAgICAgLmZpbHRlcihmb3JtID0+IGZvcm0uZWxlbWVudHMubGVuZ3RoID4gMClcbiAgICAgICAgLmZpbHRlcihmb3JtID0+IGZvcm0uZ2V0QXR0cmlidXRlKHRoaXMuYmluZGluZyhQSFhfQVVUT19SRUNPVkVSKSkgIT09IFwiaWdub3JlXCIpXG4gICAgICAgIC5tYXAoZm9ybSA9PiB7XG4gICAgICAgICAgbGV0IG5ld0Zvcm0gPSB0ZW1wbGF0ZS5jb250ZW50LnF1ZXJ5U2VsZWN0b3IoYGZvcm1baWQ9XCIke2Zvcm0uaWR9XCJdWyR7cGh4Q2hhbmdlfT1cIiR7Zm9ybS5nZXRBdHRyaWJ1dGUocGh4Q2hhbmdlKX1cIl1gKVxuICAgICAgICAgIGlmKG5ld0Zvcm0pe1xuICAgICAgICAgICAgcmV0dXJuIFtmb3JtLCBuZXdGb3JtLCB0aGlzLnRhcmdldENvbXBvbmVudElEKG5ld0Zvcm0pXVxuICAgICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICByZXR1cm4gW2Zvcm0sIG51bGwsIG51bGxdXG4gICAgICAgICAgfVxuICAgICAgICB9KVxuICAgICAgICAuZmlsdGVyKChbZm9ybSwgbmV3Rm9ybSwgbmV3Q2lkXSkgPT4gbmV3Rm9ybSlcbiAgICApXG4gIH1cblxuICBtYXliZVB1c2hDb21wb25lbnRzRGVzdHJveWVkKGRlc3Ryb3llZENJRHMpe1xuICAgIGxldCB3aWxsRGVzdHJveUNJRHMgPSBkZXN0cm95ZWRDSURzLmZpbHRlcihjaWQgPT4ge1xuICAgICAgcmV0dXJuIERPTS5maW5kQ29tcG9uZW50Tm9kZUxpc3QodGhpcy5lbCwgY2lkKS5sZW5ndGggPT09IDBcbiAgICB9KVxuICAgIGlmKHdpbGxEZXN0cm95Q0lEcy5sZW5ndGggPiAwKXtcbiAgICAgIHRoaXMucHJ1bmluZ0NJRHMucHVzaCguLi53aWxsRGVzdHJveUNJRHMpXG5cbiAgICAgIHRoaXMucHVzaFdpdGhSZXBseShudWxsLCBcImNpZHNfd2lsbF9kZXN0cm95XCIsIHtjaWRzOiB3aWxsRGVzdHJveUNJRHN9LCAoKSA9PiB7XG4gICAgICAgIC8vIFRoZSBjaWRzIGFyZSBlaXRoZXIgYmFjayBvbiB0aGUgcGFnZSBvciB0aGV5IHdpbGwgYmUgZnVsbHkgcmVtb3ZlZCxcbiAgICAgICAgLy8gc28gd2UgY2FuIHJlbW92ZSB0aGVtIGZyb20gdGhlIHBydW5pbmdDSURzLlxuICAgICAgICB0aGlzLnBydW5pbmdDSURzID0gdGhpcy5wcnVuaW5nQ0lEcy5maWx0ZXIoY2lkID0+IHdpbGxEZXN0cm95Q0lEcy5pbmRleE9mKGNpZCkgIT09IC0xKVxuXG4gICAgICAgIC8vIFNlZSBpZiBhbnkgb2YgdGhlIGNpZHMgd2Ugd2FudGVkIHRvIGRlc3Ryb3kgd2VyZSBhZGRlZCBiYWNrLFxuICAgICAgICAvLyBpZiB0aGV5IHdlcmUgYWRkZWQgYmFjaywgd2UgZG9uJ3QgYWN0dWFsbHkgZGVzdHJveSB0aGVtLlxuICAgICAgICBsZXQgY29tcGxldGVseURlc3Ryb3lDSURzID0gd2lsbERlc3Ryb3lDSURzLmZpbHRlcihjaWQgPT4ge1xuICAgICAgICAgIHJldHVybiBET00uZmluZENvbXBvbmVudE5vZGVMaXN0KHRoaXMuZWwsIGNpZCkubGVuZ3RoID09PSAwXG4gICAgICAgIH0pXG5cbiAgICAgICAgaWYoY29tcGxldGVseURlc3Ryb3lDSURzLmxlbmd0aCA+IDApe1xuICAgICAgICAgIHRoaXMucHVzaFdpdGhSZXBseShudWxsLCBcImNpZHNfZGVzdHJveWVkXCIsIHtjaWRzOiBjb21wbGV0ZWx5RGVzdHJveUNJRHN9LCAocmVzcCkgPT4ge1xuICAgICAgICAgICAgdGhpcy5yZW5kZXJlZC5wcnVuZUNJRHMocmVzcC5jaWRzKVxuICAgICAgICAgIH0pXG4gICAgICAgIH1cbiAgICAgIH0pXG4gICAgfVxuICB9XG5cbiAgb3duc0VsZW1lbnQoZWwpe1xuICAgIGxldCBwYXJlbnRWaWV3RWwgPSBlbC5jbG9zZXN0KFBIWF9WSUVXX1NFTEVDVE9SKVxuICAgIHJldHVybiBlbC5nZXRBdHRyaWJ1dGUoUEhYX1BBUkVOVF9JRCkgPT09IHRoaXMuaWQgfHxcbiAgICAgIChwYXJlbnRWaWV3RWwgJiYgcGFyZW50Vmlld0VsLmlkID09PSB0aGlzLmlkKSB8fFxuICAgICAgKCFwYXJlbnRWaWV3RWwgJiYgdGhpcy5pc0RlYWQpXG4gIH1cblxuICBzdWJtaXRGb3JtKGZvcm0sIHRhcmdldEN0eCwgcGh4RXZlbnQsIHN1Ym1pdHRlciwgb3B0cyA9IHt9KXtcbiAgICBET00ucHV0UHJpdmF0ZShmb3JtLCBQSFhfSEFTX1NVQk1JVFRFRCwgdHJ1ZSlcbiAgICBsZXQgcGh4RmVlZGJhY2sgPSB0aGlzLmxpdmVTb2NrZXQuYmluZGluZyhQSFhfRkVFREJBQ0tfRk9SKVxuICAgIGxldCBpbnB1dHMgPSBBcnJheS5mcm9tKGZvcm0uZWxlbWVudHMpXG4gICAgaW5wdXRzLmZvckVhY2goaW5wdXQgPT4gRE9NLnB1dFByaXZhdGUoaW5wdXQsIFBIWF9IQVNfU1VCTUlUVEVELCB0cnVlKSlcbiAgICB0aGlzLmxpdmVTb2NrZXQuYmx1ckFjdGl2ZUVsZW1lbnQodGhpcylcbiAgICB0aGlzLnB1c2hGb3JtU3VibWl0KGZvcm0sIHRhcmdldEN0eCwgcGh4RXZlbnQsIHN1Ym1pdHRlciwgb3B0cywgKCkgPT4ge1xuICAgICAgaW5wdXRzLmZvckVhY2goaW5wdXQgPT4gRE9NLnNob3dFcnJvcihpbnB1dCwgcGh4RmVlZGJhY2spKVxuICAgICAgdGhpcy5saXZlU29ja2V0LnJlc3RvcmVQcmV2aW91c2x5QWN0aXZlRm9jdXMoKVxuICAgIH0pXG4gIH1cblxuICBiaW5kaW5nKGtpbmQpeyByZXR1cm4gdGhpcy5saXZlU29ja2V0LmJpbmRpbmcoa2luZCkgfVxufVxuIiwgIi8qKiBJbml0aWFsaXplcyB0aGUgTGl2ZVNvY2tldFxuICpcbiAqXG4gKiBAcGFyYW0ge3N0cmluZ30gZW5kUG9pbnQgLSBUaGUgc3RyaW5nIFdlYlNvY2tldCBlbmRwb2ludCwgaWUsIGBcIndzczovL2V4YW1wbGUuY29tL2xpdmVcImAsXG4gKiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYFwiL2xpdmVcImAgKGluaGVyaXRlZCBob3N0ICYgcHJvdG9jb2wpXG4gKiBAcGFyYW0ge1Bob2VuaXguU29ja2V0fSBzb2NrZXQgLSB0aGUgcmVxdWlyZWQgUGhvZW5peCBTb2NrZXQgY2xhc3MgaW1wb3J0ZWQgZnJvbSBcInBob2VuaXhcIi4gRm9yIGV4YW1wbGU6XG4gKlxuICogICAgIGltcG9ydCB7U29ja2V0fSBmcm9tIFwicGhvZW5peFwiXG4gKiAgICAgaW1wb3J0IHtMaXZlU29ja2V0fSBmcm9tIFwicGhvZW5peF9saXZlX3ZpZXdcIlxuICogICAgIGxldCBsaXZlU29ja2V0ID0gbmV3IExpdmVTb2NrZXQoXCIvbGl2ZVwiLCBTb2NrZXQsIHsuLi59KVxuICpcbiAqIEBwYXJhbSB7T2JqZWN0fSBbb3B0c10gLSBPcHRpb25hbCBjb25maWd1cmF0aW9uLiBPdXRzaWRlIG9mIGtleXMgbGlzdGVkIGJlbG93LCBhbGxcbiAqIGNvbmZpZ3VyYXRpb24gaXMgcGFzc2VkIGRpcmVjdGx5IHRvIHRoZSBQaG9lbml4IFNvY2tldCBjb25zdHJ1Y3Rvci5cbiAqIEBwYXJhbSB7T2JqZWN0fSBbb3B0cy5kZWZhdWx0c10gLSBUaGUgb3B0aW9uYWwgZGVmYXVsdHMgdG8gdXNlIGZvciB2YXJpb3VzIGJpbmRpbmdzLFxuICogc3VjaCBhcyBgcGh4LWRlYm91bmNlYC4gU3VwcG9ydHMgdGhlIGZvbGxvd2luZyBrZXlzOlxuICpcbiAqICAgLSBkZWJvdW5jZSAtIHRoZSBtaWxsaXNlY29uZCBwaHgtZGVib3VuY2UgdGltZS4gRGVmYXVsdHMgMzAwXG4gKiAgIC0gdGhyb3R0bGUgLSB0aGUgbWlsbGlzZWNvbmQgcGh4LXRocm90dGxlIHRpbWUuIERlZmF1bHRzIDMwMFxuICpcbiAqIEBwYXJhbSB7RnVuY3Rpb259IFtvcHRzLnBhcmFtc10gLSBUaGUgb3B0aW9uYWwgZnVuY3Rpb24gZm9yIHBhc3NpbmcgY29ubmVjdCBwYXJhbXMuXG4gKiBUaGUgZnVuY3Rpb24gcmVjZWl2ZXMgdGhlIGVsZW1lbnQgYXNzb2NpYXRlZCB3aXRoIGEgZ2l2ZW4gTGl2ZVZpZXcuIEZvciBleGFtcGxlOlxuICpcbiAqICAgICAoZWwpID0+IHt2aWV3OiBlbC5nZXRBdHRyaWJ1dGUoXCJkYXRhLW15LXZpZXctbmFtZVwiLCB0b2tlbjogd2luZG93Lm15VG9rZW59XG4gKlxuICogQHBhcmFtIHtzdHJpbmd9IFtvcHRzLmJpbmRpbmdQcmVmaXhdIC0gVGhlIG9wdGlvbmFsIHByZWZpeCB0byB1c2UgZm9yIGFsbCBwaHggRE9NIGFubm90YXRpb25zLlxuICogRGVmYXVsdHMgdG8gXCJwaHgtXCIuXG4gKiBAcGFyYW0ge09iamVjdH0gW29wdHMuaG9va3NdIC0gVGhlIG9wdGlvbmFsIG9iamVjdCBmb3IgcmVmZXJlbmNpbmcgTGl2ZVZpZXcgaG9vayBjYWxsYmFja3MuXG4gKiBAcGFyYW0ge09iamVjdH0gW29wdHMudXBsb2FkZXJzXSAtIFRoZSBvcHRpb25hbCBvYmplY3QgZm9yIHJlZmVyZW5jaW5nIExpdmVWaWV3IHVwbG9hZGVyIGNhbGxiYWNrcy5cbiAqIEBwYXJhbSB7aW50ZWdlcn0gW29wdHMubG9hZGVyVGltZW91dF0gLSBUaGUgb3B0aW9uYWwgZGVsYXkgaW4gbWlsbGlzZWNvbmRzIHRvIHdhaXQgYmVmb3JlIGFwcGx5XG4gKiBsb2FkaW5nIHN0YXRlcy5cbiAqIEBwYXJhbSB7aW50ZWdlcn0gW29wdHMubWF4UmVsb2Fkc10gLSBUaGUgbWF4aW11bSByZWxvYWRzIGJlZm9yZSBlbnRlcmluZyBmYWlsc2FmZSBtb2RlLlxuICogQHBhcmFtIHtpbnRlZ2VyfSBbb3B0cy5yZWxvYWRKaXR0ZXJNaW5dIC0gVGhlIG1pbmltdW0gdGltZSBiZXR3ZWVuIG5vcm1hbCByZWxvYWQgYXR0ZW1wdHMuXG4gKiBAcGFyYW0ge2ludGVnZXJ9IFtvcHRzLnJlbG9hZEppdHRlck1heF0gLSBUaGUgbWF4aW11bSB0aW1lIGJldHdlZW4gbm9ybWFsIHJlbG9hZCBhdHRlbXB0cy5cbiAqIEBwYXJhbSB7aW50ZWdlcn0gW29wdHMuZmFpbHNhZmVKaXR0ZXJdIC0gVGhlIHRpbWUgYmV0d2VlbiByZWxvYWQgYXR0ZW1wdHMgaW4gZmFpbHNhZmUgbW9kZS5cbiAqIEBwYXJhbSB7RnVuY3Rpb259IFtvcHRzLnZpZXdMb2dnZXJdIC0gVGhlIG9wdGlvbmFsIGZ1bmN0aW9uIHRvIGxvZyBkZWJ1ZyBpbmZvcm1hdGlvbi4gRm9yIGV4YW1wbGU6XG4gKlxuICogICAgICh2aWV3LCBraW5kLCBtc2csIG9iaikgPT4gY29uc29sZS5sb2coYCR7dmlldy5pZH0gJHtraW5kfTogJHttc2d9IC0gYCwgb2JqKVxuICpcbiAqIEBwYXJhbSB7T2JqZWN0fSBbb3B0cy5tZXRhZGF0YV0gLSBUaGUgb3B0aW9uYWwgb2JqZWN0IG1hcHBpbmcgZXZlbnQgbmFtZXMgdG8gZnVuY3Rpb25zIGZvclxuICogcG9wdWxhdGluZyBldmVudCBtZXRhZGF0YS4gRm9yIGV4YW1wbGU6XG4gKlxuICogICAgIG1ldGFkYXRhOiB7XG4gKiAgICAgICBjbGljazogKGUsIGVsKSA9PiB7XG4gKiAgICAgICAgIHJldHVybiB7XG4gKiAgICAgICAgICAgY3RybEtleTogZS5jdHJsS2V5LFxuICogICAgICAgICAgIG1ldGFLZXk6IGUubWV0YUtleSxcbiAqICAgICAgICAgICBkZXRhaWw6IGUuZGV0YWlsIHx8IDEsXG4gKiAgICAgICAgIH1cbiAqICAgICAgIH0sXG4gKiAgICAgICBrZXlkb3duOiAoZSwgZWwpID0+IHtcbiAqICAgICAgICAgcmV0dXJuIHtcbiAqICAgICAgICAgICBrZXk6IGUua2V5LFxuICogICAgICAgICAgIGN0cmxLZXk6IGUuY3RybEtleSxcbiAqICAgICAgICAgICBtZXRhS2V5OiBlLm1ldGFLZXksXG4gKiAgICAgICAgICAgc2hpZnRLZXk6IGUuc2hpZnRLZXlcbiAqICAgICAgICAgfVxuICogICAgICAgfVxuICogICAgIH1cbiAqIEBwYXJhbSB7T2JqZWN0fSBbb3B0cy5zZXNzaW9uU3RvcmFnZV0gLSBBbiBvcHRpb25hbCBTdG9yYWdlIGNvbXBhdGlibGUgb2JqZWN0XG4gKiBVc2VmdWwgd2hlbiBMaXZlVmlldyB3b24ndCBoYXZlIGFjY2VzcyB0byBgc2Vzc2lvblN0b3JhZ2VgLiAgRm9yIGV4YW1wbGUsIFRoaXMgY291bGRcbiAqIGhhcHBlbiBpZiBhIHNpdGUgbG9hZHMgYSBjcm9zcy1kb21haW4gTGl2ZVZpZXcgaW4gYW4gaWZyYW1lLiAgRXhhbXBsZSB1c2FnZTpcbiAqXG4gKiAgICAgY2xhc3MgSW5NZW1vcnlTdG9yYWdlIHtcbiAqICAgICAgIGNvbnN0cnVjdG9yKCkgeyB0aGlzLnN0b3JhZ2UgPSB7fSB9XG4gKiAgICAgICBnZXRJdGVtKGtleU5hbWUpIHsgcmV0dXJuIHRoaXMuc3RvcmFnZVtrZXlOYW1lXSB8fCBudWxsIH1cbiAqICAgICAgIHJlbW92ZUl0ZW0oa2V5TmFtZSkgeyBkZWxldGUgdGhpcy5zdG9yYWdlW2tleU5hbWVdIH1cbiAqICAgICAgIHNldEl0ZW0oa2V5TmFtZSwga2V5VmFsdWUpIHsgdGhpcy5zdG9yYWdlW2tleU5hbWVdID0ga2V5VmFsdWUgfVxuICogICAgIH1cbiAqXG4gKiBAcGFyYW0ge09iamVjdH0gW29wdHMubG9jYWxTdG9yYWdlXSAtIEFuIG9wdGlvbmFsIFN0b3JhZ2UgY29tcGF0aWJsZSBvYmplY3RcbiAqIFVzZWZ1bCBmb3Igd2hlbiBMaXZlVmlldyB3b24ndCBoYXZlIGFjY2VzcyB0byBgbG9jYWxTdG9yYWdlYC5cbiAqIFNlZSBgb3B0cy5zZXNzaW9uU3RvcmFnZWAgZm9yIGV4YW1wbGVzLlxuKi9cblxuaW1wb3J0IHtcbiAgQklORElOR19QUkVGSVgsXG4gIENPTlNFQ1VUSVZFX1JFTE9BRFMsXG4gIERFRkFVTFRTLFxuICBGQUlMU0FGRV9KSVRURVIsXG4gIExPQURFUl9USU1FT1VULFxuICBNQVhfUkVMT0FEUyxcbiAgUEhYX0RFQk9VTkNFLFxuICBQSFhfRFJPUF9UQVJHRVQsXG4gIFBIWF9IQVNfRk9DVVNFRCxcbiAgUEhYX0tFWSxcbiAgUEhYX0xJTktfU1RBVEUsXG4gIFBIWF9MSVZFX0xJTkssXG4gIFBIWF9MVl9ERUJVRyxcbiAgUEhYX0xWX0xBVEVOQ1lfU0lNLFxuICBQSFhfTFZfUFJPRklMRSxcbiAgUEhYX01BSU4sXG4gIFBIWF9QQVJFTlRfSUQsXG4gIFBIWF9WSUVXX1NFTEVDVE9SLFxuICBQSFhfUk9PVF9JRCxcbiAgUEhYX1RIUk9UVExFLFxuICBQSFhfVFJBQ0tfVVBMT0FEUyxcbiAgUEhYX1NFU1NJT04sXG4gIFBIWF9GRUVEQkFDS19GT1IsXG4gIFJFTE9BRF9KSVRURVJfTUlOLFxuICBSRUxPQURfSklUVEVSX01BWCxcbn0gZnJvbSBcIi4vY29uc3RhbnRzXCJcblxuaW1wb3J0IHtcbiAgY2xvbmUsXG4gIGNsb3Nlc3RQaHhCaW5kaW5nLFxuICBjbG9zdXJlLFxuICBkZWJ1ZyxcbiAgaXNPYmplY3QsXG4gIG1heWJlXG59IGZyb20gXCIuL3V0aWxzXCJcblxuaW1wb3J0IEJyb3dzZXIgZnJvbSBcIi4vYnJvd3NlclwiXG5pbXBvcnQgRE9NIGZyb20gXCIuL2RvbVwiXG5pbXBvcnQgSG9va3MgZnJvbSBcIi4vaG9va3NcIlxuaW1wb3J0IExpdmVVcGxvYWRlciBmcm9tIFwiLi9saXZlX3VwbG9hZGVyXCJcbmltcG9ydCBWaWV3IGZyb20gXCIuL3ZpZXdcIlxuaW1wb3J0IEpTIGZyb20gXCIuL2pzXCJcblxuZXhwb3J0IGRlZmF1bHQgY2xhc3MgTGl2ZVNvY2tldCB7XG4gIGNvbnN0cnVjdG9yKHVybCwgcGh4U29ja2V0LCBvcHRzID0ge30pe1xuICAgIHRoaXMudW5sb2FkZWQgPSBmYWxzZVxuICAgIGlmKCFwaHhTb2NrZXQgfHwgcGh4U29ja2V0LmNvbnN0cnVjdG9yLm5hbWUgPT09IFwiT2JqZWN0XCIpe1xuICAgICAgdGhyb3cgbmV3IEVycm9yKGBcbiAgICAgIGEgcGhvZW5peCBTb2NrZXQgbXVzdCBiZSBwcm92aWRlZCBhcyB0aGUgc2Vjb25kIGFyZ3VtZW50IHRvIHRoZSBMaXZlU29ja2V0IGNvbnN0cnVjdG9yLiBGb3IgZXhhbXBsZTpcblxuICAgICAgICAgIGltcG9ydCB7U29ja2V0fSBmcm9tIFwicGhvZW5peFwiXG4gICAgICAgICAgaW1wb3J0IHtMaXZlU29ja2V0fSBmcm9tIFwicGhvZW5peF9saXZlX3ZpZXdcIlxuICAgICAgICAgIGxldCBsaXZlU29ja2V0ID0gbmV3IExpdmVTb2NrZXQoXCIvbGl2ZVwiLCBTb2NrZXQsIHsuLi59KVxuICAgICAgYClcbiAgICB9XG4gICAgdGhpcy5zb2NrZXQgPSBuZXcgcGh4U29ja2V0KHVybCwgb3B0cylcbiAgICB0aGlzLmJpbmRpbmdQcmVmaXggPSBvcHRzLmJpbmRpbmdQcmVmaXggfHwgQklORElOR19QUkVGSVhcbiAgICB0aGlzLm9wdHMgPSBvcHRzXG4gICAgdGhpcy5wYXJhbXMgPSBjbG9zdXJlKG9wdHMucGFyYW1zIHx8IHt9KVxuICAgIHRoaXMudmlld0xvZ2dlciA9IG9wdHMudmlld0xvZ2dlclxuICAgIHRoaXMubWV0YWRhdGFDYWxsYmFja3MgPSBvcHRzLm1ldGFkYXRhIHx8IHt9XG4gICAgdGhpcy5kZWZhdWx0cyA9IE9iamVjdC5hc3NpZ24oY2xvbmUoREVGQVVMVFMpLCBvcHRzLmRlZmF1bHRzIHx8IHt9KVxuICAgIHRoaXMuYWN0aXZlRWxlbWVudCA9IG51bGxcbiAgICB0aGlzLnByZXZBY3RpdmUgPSBudWxsXG4gICAgdGhpcy5zaWxlbmNlZCA9IGZhbHNlXG4gICAgdGhpcy5tYWluID0gbnVsbFxuICAgIHRoaXMub3V0Z29pbmdNYWluRWwgPSBudWxsXG4gICAgdGhpcy5jbGlja1N0YXJ0ZWRBdFRhcmdldCA9IG51bGxcbiAgICB0aGlzLmxpbmtSZWYgPSAxXG4gICAgdGhpcy5yb290cyA9IHt9XG4gICAgdGhpcy5ocmVmID0gd2luZG93LmxvY2F0aW9uLmhyZWZcbiAgICB0aGlzLnBlbmRpbmdMaW5rID0gbnVsbFxuICAgIHRoaXMuY3VycmVudExvY2F0aW9uID0gY2xvbmUod2luZG93LmxvY2F0aW9uKVxuICAgIHRoaXMuaG9va3MgPSBvcHRzLmhvb2tzIHx8IHt9XG4gICAgdGhpcy51cGxvYWRlcnMgPSBvcHRzLnVwbG9hZGVycyB8fCB7fVxuICAgIHRoaXMubG9hZGVyVGltZW91dCA9IG9wdHMubG9hZGVyVGltZW91dCB8fCBMT0FERVJfVElNRU9VVFxuICAgIHRoaXMucmVsb2FkV2l0aEppdHRlclRpbWVyID0gbnVsbFxuICAgIHRoaXMubWF4UmVsb2FkcyA9IG9wdHMubWF4UmVsb2FkcyB8fCBNQVhfUkVMT0FEU1xuICAgIHRoaXMucmVsb2FkSml0dGVyTWluID0gb3B0cy5yZWxvYWRKaXR0ZXJNaW4gfHwgUkVMT0FEX0pJVFRFUl9NSU5cbiAgICB0aGlzLnJlbG9hZEppdHRlck1heCA9IG9wdHMucmVsb2FkSml0dGVyTWF4IHx8IFJFTE9BRF9KSVRURVJfTUFYXG4gICAgdGhpcy5mYWlsc2FmZUppdHRlciA9IG9wdHMuZmFpbHNhZmVKaXR0ZXIgfHwgRkFJTFNBRkVfSklUVEVSXG4gICAgdGhpcy5sb2NhbFN0b3JhZ2UgPSBvcHRzLmxvY2FsU3RvcmFnZSB8fCB3aW5kb3cubG9jYWxTdG9yYWdlXG4gICAgdGhpcy5zZXNzaW9uU3RvcmFnZSA9IG9wdHMuc2Vzc2lvblN0b3JhZ2UgfHwgd2luZG93LnNlc3Npb25TdG9yYWdlXG4gICAgdGhpcy5ib3VuZFRvcExldmVsRXZlbnRzID0gZmFsc2VcbiAgICB0aGlzLmRvbUNhbGxiYWNrcyA9IE9iamVjdC5hc3NpZ24oe29uTm9kZUFkZGVkOiBjbG9zdXJlKCksIG9uQmVmb3JlRWxVcGRhdGVkOiBjbG9zdXJlKCl9LCBvcHRzLmRvbSB8fCB7fSlcbiAgICB0aGlzLnRyYW5zaXRpb25zID0gbmV3IFRyYW5zaXRpb25TZXQoKVxuICAgIHdpbmRvdy5hZGRFdmVudExpc3RlbmVyKFwicGFnZWhpZGVcIiwgX2UgPT4ge1xuICAgICAgdGhpcy51bmxvYWRlZCA9IHRydWVcbiAgICB9KVxuICAgIHRoaXMuc29ja2V0Lm9uT3BlbigoKSA9PiB7XG4gICAgICBpZih0aGlzLmlzVW5sb2FkZWQoKSl7XG4gICAgICAgIC8vIHJlbG9hZCBwYWdlIGlmIGJlaW5nIHJlc3RvcmVkIGZyb20gYmFjay9mb3J3YXJkIGNhY2hlIGFuZCBicm93c2VyIGRvZXMgbm90IGVtaXQgXCJwYWdlc2hvd1wiXG4gICAgICAgIHdpbmRvdy5sb2NhdGlvbi5yZWxvYWQoKVxuICAgICAgfVxuICAgIH0pXG4gIH1cblxuICAvLyBwdWJsaWNcblxuICBpc1Byb2ZpbGVFbmFibGVkKCl7IHJldHVybiB0aGlzLnNlc3Npb25TdG9yYWdlLmdldEl0ZW0oUEhYX0xWX1BST0ZJTEUpID09PSBcInRydWVcIiB9XG5cbiAgaXNEZWJ1Z0VuYWJsZWQoKXsgcmV0dXJuIHRoaXMuc2Vzc2lvblN0b3JhZ2UuZ2V0SXRlbShQSFhfTFZfREVCVUcpID09PSBcInRydWVcIiB9XG5cbiAgaXNEZWJ1Z0Rpc2FibGVkKCl7IHJldHVybiB0aGlzLnNlc3Npb25TdG9yYWdlLmdldEl0ZW0oUEhYX0xWX0RFQlVHKSA9PT0gXCJmYWxzZVwiIH1cblxuICBlbmFibGVEZWJ1ZygpeyB0aGlzLnNlc3Npb25TdG9yYWdlLnNldEl0ZW0oUEhYX0xWX0RFQlVHLCBcInRydWVcIikgfVxuXG4gIGVuYWJsZVByb2ZpbGluZygpeyB0aGlzLnNlc3Npb25TdG9yYWdlLnNldEl0ZW0oUEhYX0xWX1BST0ZJTEUsIFwidHJ1ZVwiKSB9XG5cbiAgZGlzYWJsZURlYnVnKCl7IHRoaXMuc2Vzc2lvblN0b3JhZ2Uuc2V0SXRlbShQSFhfTFZfREVCVUcsIFwiZmFsc2VcIikgfVxuXG4gIGRpc2FibGVQcm9maWxpbmcoKXsgdGhpcy5zZXNzaW9uU3RvcmFnZS5yZW1vdmVJdGVtKFBIWF9MVl9QUk9GSUxFKSB9XG5cbiAgZW5hYmxlTGF0ZW5jeVNpbSh1cHBlckJvdW5kTXMpe1xuICAgIHRoaXMuZW5hYmxlRGVidWcoKVxuICAgIGNvbnNvbGUubG9nKFwibGF0ZW5jeSBzaW11bGF0b3IgZW5hYmxlZCBmb3IgdGhlIGR1cmF0aW9uIG9mIHRoaXMgYnJvd3NlciBzZXNzaW9uLiBDYWxsIGRpc2FibGVMYXRlbmN5U2ltKCkgdG8gZGlzYWJsZVwiKVxuICAgIHRoaXMuc2Vzc2lvblN0b3JhZ2Uuc2V0SXRlbShQSFhfTFZfTEFURU5DWV9TSU0sIHVwcGVyQm91bmRNcylcbiAgfVxuXG4gIGRpc2FibGVMYXRlbmN5U2ltKCl7IHRoaXMuc2Vzc2lvblN0b3JhZ2UucmVtb3ZlSXRlbShQSFhfTFZfTEFURU5DWV9TSU0pIH1cblxuICBnZXRMYXRlbmN5U2ltKCl7XG4gICAgbGV0IHN0ciA9IHRoaXMuc2Vzc2lvblN0b3JhZ2UuZ2V0SXRlbShQSFhfTFZfTEFURU5DWV9TSU0pXG4gICAgcmV0dXJuIHN0ciA/IHBhcnNlSW50KHN0cikgOiBudWxsXG4gIH1cblxuICBnZXRTb2NrZXQoKXsgcmV0dXJuIHRoaXMuc29ja2V0IH1cblxuICBjb25uZWN0KCl7XG4gICAgLy8gZW5hYmxlIGRlYnVnIGJ5IGRlZmF1bHQgaWYgb24gbG9jYWxob3N0IGFuZCBub3QgZXhwbGljaXRseSBkaXNhYmxlZFxuICAgIGlmKHdpbmRvdy5sb2NhdGlvbi5ob3N0bmFtZSA9PT0gXCJsb2NhbGhvc3RcIiAmJiAhdGhpcy5pc0RlYnVnRGlzYWJsZWQoKSl7IHRoaXMuZW5hYmxlRGVidWcoKSB9XG4gICAgbGV0IGRvQ29ubmVjdCA9ICgpID0+IHtcbiAgICAgIGlmKHRoaXMuam9pblJvb3RWaWV3cygpKXtcbiAgICAgICAgdGhpcy5iaW5kVG9wTGV2ZWxFdmVudHMoKVxuICAgICAgICB0aGlzLnNvY2tldC5jb25uZWN0KClcbiAgICAgIH0gZWxzZSBpZih0aGlzLm1haW4pe1xuICAgICAgICB0aGlzLnNvY2tldC5jb25uZWN0KClcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHRoaXMuYmluZFRvcExldmVsRXZlbnRzKHtkZWFkOiB0cnVlfSlcbiAgICAgIH1cbiAgICAgIHRoaXMuam9pbkRlYWRWaWV3KClcbiAgICB9XG4gICAgaWYoW1wiY29tcGxldGVcIiwgXCJsb2FkZWRcIiwgXCJpbnRlcmFjdGl2ZVwiXS5pbmRleE9mKGRvY3VtZW50LnJlYWR5U3RhdGUpID49IDApe1xuICAgICAgZG9Db25uZWN0KClcbiAgICB9IGVsc2Uge1xuICAgICAgZG9jdW1lbnQuYWRkRXZlbnRMaXN0ZW5lcihcIkRPTUNvbnRlbnRMb2FkZWRcIiwgKCkgPT4gZG9Db25uZWN0KCkpXG4gICAgfVxuICB9XG5cbiAgZGlzY29ubmVjdChjYWxsYmFjayl7XG4gICAgY2xlYXJUaW1lb3V0KHRoaXMucmVsb2FkV2l0aEppdHRlclRpbWVyKVxuICAgIHRoaXMuc29ja2V0LmRpc2Nvbm5lY3QoY2FsbGJhY2spXG4gIH1cblxuICByZXBsYWNlVHJhbnNwb3J0KHRyYW5zcG9ydCl7XG4gICAgY2xlYXJUaW1lb3V0KHRoaXMucmVsb2FkV2l0aEppdHRlclRpbWVyKVxuICAgIHRoaXMuc29ja2V0LnJlcGxhY2VUcmFuc3BvcnQodHJhbnNwb3J0KVxuICAgIHRoaXMuY29ubmVjdCgpXG4gIH1cblxuICBleGVjSlMoZWwsIGVuY29kZWRKUywgZXZlbnRUeXBlID0gbnVsbCl7XG4gICAgdGhpcy5vd25lcihlbCwgdmlldyA9PiBKUy5leGVjKGV2ZW50VHlwZSwgZW5jb2RlZEpTLCB2aWV3LCBlbCkpXG4gIH1cblxuICAvLyBwcml2YXRlXG5cbiAgdW5sb2FkKCl7XG4gICAgaWYodGhpcy51bmxvYWRlZCl7IHJldHVybiB9XG4gICAgaWYodGhpcy5tYWluICYmIHRoaXMuaXNDb25uZWN0ZWQoKSl7IHRoaXMubG9nKHRoaXMubWFpbiwgXCJzb2NrZXRcIiwgKCkgPT4gW1wiZGlzY29ubmVjdCBmb3IgcGFnZSBuYXZcIl0pIH1cbiAgICB0aGlzLnVubG9hZGVkID0gdHJ1ZVxuICAgIHRoaXMuZGVzdHJveUFsbFZpZXdzKClcbiAgICB0aGlzLmRpc2Nvbm5lY3QoKVxuICB9XG5cbiAgdHJpZ2dlckRPTShraW5kLCBhcmdzKXsgdGhpcy5kb21DYWxsYmFja3Nba2luZF0oLi4uYXJncykgfVxuXG4gIHRpbWUobmFtZSwgZnVuYyl7XG4gICAgaWYoIXRoaXMuaXNQcm9maWxlRW5hYmxlZCgpIHx8ICFjb25zb2xlLnRpbWUpeyByZXR1cm4gZnVuYygpIH1cbiAgICBjb25zb2xlLnRpbWUobmFtZSlcbiAgICBsZXQgcmVzdWx0ID0gZnVuYygpXG4gICAgY29uc29sZS50aW1lRW5kKG5hbWUpXG4gICAgcmV0dXJuIHJlc3VsdFxuICB9XG5cbiAgbG9nKHZpZXcsIGtpbmQsIG1zZ0NhbGxiYWNrKXtcbiAgICBpZih0aGlzLnZpZXdMb2dnZXIpe1xuICAgICAgbGV0IFttc2csIG9ial0gPSBtc2dDYWxsYmFjaygpXG4gICAgICB0aGlzLnZpZXdMb2dnZXIodmlldywga2luZCwgbXNnLCBvYmopXG4gICAgfSBlbHNlIGlmKHRoaXMuaXNEZWJ1Z0VuYWJsZWQoKSl7XG4gICAgICBsZXQgW21zZywgb2JqXSA9IG1zZ0NhbGxiYWNrKClcbiAgICAgIGRlYnVnKHZpZXcsIGtpbmQsIG1zZywgb2JqKVxuICAgIH1cbiAgfVxuXG4gIHJlcXVlc3RET01VcGRhdGUoY2FsbGJhY2spe1xuICAgIHRoaXMudHJhbnNpdGlvbnMuYWZ0ZXIoY2FsbGJhY2spXG4gIH1cblxuICB0cmFuc2l0aW9uKHRpbWUsIG9uU3RhcnQsIG9uRG9uZSA9IGZ1bmN0aW9uKCl7fSl7XG4gICAgdGhpcy50cmFuc2l0aW9ucy5hZGRUcmFuc2l0aW9uKHRpbWUsIG9uU3RhcnQsIG9uRG9uZSlcbiAgfVxuXG4gIG9uQ2hhbm5lbChjaGFubmVsLCBldmVudCwgY2Ipe1xuICAgIGNoYW5uZWwub24oZXZlbnQsIGRhdGEgPT4ge1xuICAgICAgbGV0IGxhdGVuY3kgPSB0aGlzLmdldExhdGVuY3lTaW0oKVxuICAgICAgaWYoIWxhdGVuY3kpe1xuICAgICAgICBjYihkYXRhKVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgc2V0VGltZW91dCgoKSA9PiBjYihkYXRhKSwgbGF0ZW5jeSlcbiAgICAgIH1cbiAgICB9KVxuICB9XG5cbiAgd3JhcFB1c2godmlldywgb3B0cywgcHVzaCl7XG4gICAgbGV0IGxhdGVuY3kgPSB0aGlzLmdldExhdGVuY3lTaW0oKVxuICAgIGxldCBvbGRKb2luQ291bnQgPSB2aWV3LmpvaW5Db3VudFxuICAgIGlmKCFsYXRlbmN5KXtcbiAgICAgIGlmKHRoaXMuaXNDb25uZWN0ZWQoKSAmJiBvcHRzLnRpbWVvdXQpe1xuICAgICAgICByZXR1cm4gcHVzaCgpLnJlY2VpdmUoXCJ0aW1lb3V0XCIsICgpID0+IHtcbiAgICAgICAgICBpZih2aWV3LmpvaW5Db3VudCA9PT0gb2xkSm9pbkNvdW50ICYmICF2aWV3LmlzRGVzdHJveWVkKCkpe1xuICAgICAgICAgICAgdGhpcy5yZWxvYWRXaXRoSml0dGVyKHZpZXcsICgpID0+IHtcbiAgICAgICAgICAgICAgdGhpcy5sb2codmlldywgXCJ0aW1lb3V0XCIsICgpID0+IFtcInJlY2VpdmVkIHRpbWVvdXQgd2hpbGUgY29tbXVuaWNhdGluZyB3aXRoIHNlcnZlci4gRmFsbGluZyBiYWNrIHRvIGhhcmQgcmVmcmVzaCBmb3IgcmVjb3ZlcnlcIl0pXG4gICAgICAgICAgICB9KVxuICAgICAgICAgIH1cbiAgICAgICAgfSlcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHJldHVybiBwdXNoKClcbiAgICAgIH1cbiAgICB9XG5cbiAgICBsZXQgZmFrZVB1c2ggPSB7XG4gICAgICByZWNlaXZlczogW10sXG4gICAgICByZWNlaXZlKGtpbmQsIGNiKXsgdGhpcy5yZWNlaXZlcy5wdXNoKFtraW5kLCBjYl0pIH1cbiAgICB9XG4gICAgc2V0VGltZW91dCgoKSA9PiB7XG4gICAgICBpZih2aWV3LmlzRGVzdHJveWVkKCkpeyByZXR1cm4gfVxuICAgICAgZmFrZVB1c2gucmVjZWl2ZXMucmVkdWNlKChhY2MsIFtraW5kLCBjYl0pID0+IGFjYy5yZWNlaXZlKGtpbmQsIGNiKSwgcHVzaCgpKVxuICAgIH0sIGxhdGVuY3kpXG4gICAgcmV0dXJuIGZha2VQdXNoXG4gIH1cblxuICByZWxvYWRXaXRoSml0dGVyKHZpZXcsIGxvZyl7XG4gICAgY2xlYXJUaW1lb3V0KHRoaXMucmVsb2FkV2l0aEppdHRlclRpbWVyKVxuICAgIHRoaXMuZGlzY29ubmVjdCgpXG4gICAgbGV0IG1pbk1zID0gdGhpcy5yZWxvYWRKaXR0ZXJNaW5cbiAgICBsZXQgbWF4TXMgPSB0aGlzLnJlbG9hZEppdHRlck1heFxuICAgIGxldCBhZnRlck1zID0gTWF0aC5mbG9vcihNYXRoLnJhbmRvbSgpICogKG1heE1zIC0gbWluTXMgKyAxKSkgKyBtaW5Nc1xuICAgIGxldCB0cmllcyA9IEJyb3dzZXIudXBkYXRlTG9jYWwodGhpcy5sb2NhbFN0b3JhZ2UsIHdpbmRvdy5sb2NhdGlvbi5wYXRobmFtZSwgQ09OU0VDVVRJVkVfUkVMT0FEUywgMCwgY291bnQgPT4gY291bnQgKyAxKVxuICAgIGlmKHRyaWVzID4gdGhpcy5tYXhSZWxvYWRzKXtcbiAgICAgIGFmdGVyTXMgPSB0aGlzLmZhaWxzYWZlSml0dGVyXG4gICAgfVxuICAgIHRoaXMucmVsb2FkV2l0aEppdHRlclRpbWVyID0gc2V0VGltZW91dCgoKSA9PiB7XG4gICAgICAvLyBpZiB2aWV3IGhhcyByZWNvdmVyZWQsIHN1Y2ggYXMgdHJhbnNwb3J0IHJlcGxhY2VkLCB0aGVuIGNhbmNlbFxuICAgICAgaWYodmlldy5pc0Rlc3Ryb3llZCgpIHx8IHZpZXcuaXNDb25uZWN0ZWQoKSl7IHJldHVybiB9XG4gICAgICB2aWV3LmRlc3Ryb3koKVxuICAgICAgbG9nID8gbG9nKCkgOiB0aGlzLmxvZyh2aWV3LCBcImpvaW5cIiwgKCkgPT4gW2BlbmNvdW50ZXJlZCAke3RyaWVzfSBjb25zZWN1dGl2ZSByZWxvYWRzYF0pXG4gICAgICBpZih0cmllcyA+IHRoaXMubWF4UmVsb2Fkcyl7XG4gICAgICAgIHRoaXMubG9nKHZpZXcsIFwiam9pblwiLCAoKSA9PiBbYGV4Y2VlZGVkICR7dGhpcy5tYXhSZWxvYWRzfSBjb25zZWN1dGl2ZSByZWxvYWRzLiBFbnRlcmluZyBmYWlsc2FmZSBtb2RlYF0pXG4gICAgICB9XG4gICAgICBpZih0aGlzLmhhc1BlbmRpbmdMaW5rKCkpe1xuICAgICAgICB3aW5kb3cubG9jYXRpb24gPSB0aGlzLnBlbmRpbmdMaW5rXG4gICAgICB9IGVsc2Uge1xuICAgICAgICB3aW5kb3cubG9jYXRpb24ucmVsb2FkKClcbiAgICAgIH1cbiAgICB9LCBhZnRlck1zKVxuICB9XG5cbiAgZ2V0SG9va0NhbGxiYWNrcyhuYW1lKXtcbiAgICByZXR1cm4gbmFtZSAmJiBuYW1lLnN0YXJ0c1dpdGgoXCJQaG9lbml4LlwiKSA/IEhvb2tzW25hbWUuc3BsaXQoXCIuXCIpWzFdXSA6IHRoaXMuaG9va3NbbmFtZV1cbiAgfVxuXG4gIGlzVW5sb2FkZWQoKXsgcmV0dXJuIHRoaXMudW5sb2FkZWQgfVxuXG4gIGlzQ29ubmVjdGVkKCl7IHJldHVybiB0aGlzLnNvY2tldC5pc0Nvbm5lY3RlZCgpIH1cblxuICBnZXRCaW5kaW5nUHJlZml4KCl7IHJldHVybiB0aGlzLmJpbmRpbmdQcmVmaXggfVxuXG4gIGJpbmRpbmcoa2luZCl7IHJldHVybiBgJHt0aGlzLmdldEJpbmRpbmdQcmVmaXgoKX0ke2tpbmR9YCB9XG5cbiAgY2hhbm5lbCh0b3BpYywgcGFyYW1zKXsgcmV0dXJuIHRoaXMuc29ja2V0LmNoYW5uZWwodG9waWMsIHBhcmFtcykgfVxuXG4gIGpvaW5EZWFkVmlldygpe1xuICAgIGxldCBib2R5ID0gZG9jdW1lbnQuYm9keVxuICAgIGlmKGJvZHkgJiYgIXRoaXMuaXNQaHhWaWV3KGJvZHkpICYmICF0aGlzLmlzUGh4Vmlldyhkb2N1bWVudC5maXJzdEVsZW1lbnRDaGlsZCkpe1xuICAgICAgbGV0IHZpZXcgPSB0aGlzLm5ld1Jvb3RWaWV3KGJvZHkpXG4gICAgICB2aWV3LnNldEhyZWYodGhpcy5nZXRIcmVmKCkpXG4gICAgICB2aWV3LmpvaW5EZWFkKClcbiAgICAgIGlmKCF0aGlzLm1haW4peyB0aGlzLm1haW4gPSB2aWV3IH1cbiAgICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUoKCkgPT4gdmlldy5leGVjTmV3TW91bnRlZCgpKVxuICAgIH1cbiAgfVxuXG4gIGpvaW5Sb290Vmlld3MoKXtcbiAgICBsZXQgcm9vdHNGb3VuZCA9IGZhbHNlXG4gICAgRE9NLmFsbChkb2N1bWVudCwgYCR7UEhYX1ZJRVdfU0VMRUNUT1J9Om5vdChbJHtQSFhfUEFSRU5UX0lEfV0pYCwgcm9vdEVsID0+IHtcbiAgICAgIGlmKCF0aGlzLmdldFJvb3RCeUlkKHJvb3RFbC5pZCkpe1xuICAgICAgICBsZXQgdmlldyA9IHRoaXMubmV3Um9vdFZpZXcocm9vdEVsKVxuICAgICAgICB2aWV3LnNldEhyZWYodGhpcy5nZXRIcmVmKCkpXG4gICAgICAgIHZpZXcuam9pbigpXG4gICAgICAgIGlmKHJvb3RFbC5oYXNBdHRyaWJ1dGUoUEhYX01BSU4pKXsgdGhpcy5tYWluID0gdmlldyB9XG4gICAgICB9XG4gICAgICByb290c0ZvdW5kID0gdHJ1ZVxuICAgIH0pXG4gICAgcmV0dXJuIHJvb3RzRm91bmRcbiAgfVxuXG4gIHJlZGlyZWN0KHRvLCBmbGFzaCl7XG4gICAgdGhpcy51bmxvYWQoKVxuICAgIEJyb3dzZXIucmVkaXJlY3QodG8sIGZsYXNoKVxuICB9XG5cbiAgcmVwbGFjZU1haW4oaHJlZiwgZmxhc2gsIGNhbGxiYWNrID0gbnVsbCwgbGlua1JlZiA9IHRoaXMuc2V0UGVuZGluZ0xpbmsoaHJlZikpe1xuICAgIGxldCBsaXZlUmVmZXJlciA9IHRoaXMuY3VycmVudExvY2F0aW9uLmhyZWZcbiAgICB0aGlzLm91dGdvaW5nTWFpbkVsID0gdGhpcy5vdXRnb2luZ01haW5FbCB8fCB0aGlzLm1haW4uZWxcbiAgICBsZXQgbmV3TWFpbkVsID0gRE9NLmNsb25lTm9kZSh0aGlzLm91dGdvaW5nTWFpbkVsLCBcIlwiKVxuICAgIHRoaXMubWFpbi5zaG93TG9hZGVyKHRoaXMubG9hZGVyVGltZW91dClcbiAgICB0aGlzLm1haW4uZGVzdHJveSgpXG5cbiAgICB0aGlzLm1haW4gPSB0aGlzLm5ld1Jvb3RWaWV3KG5ld01haW5FbCwgZmxhc2gsIGxpdmVSZWZlcmVyKVxuICAgIHRoaXMubWFpbi5zZXRSZWRpcmVjdChocmVmKVxuICAgIHRoaXMudHJhbnNpdGlvblJlbW92ZXMoKVxuICAgIHRoaXMubWFpbi5qb2luKChqb2luQ291bnQsIG9uRG9uZSkgPT4ge1xuICAgICAgaWYoam9pbkNvdW50ID09PSAxICYmIHRoaXMuY29tbWl0UGVuZGluZ0xpbmsobGlua1JlZikpe1xuICAgICAgICB0aGlzLnJlcXVlc3RET01VcGRhdGUoKCkgPT4ge1xuICAgICAgICAgIERPTS5maW5kUGh4U3RpY2t5KGRvY3VtZW50KS5mb3JFYWNoKGVsID0+IG5ld01haW5FbC5hcHBlbmRDaGlsZChlbCkpXG4gICAgICAgICAgdGhpcy5vdXRnb2luZ01haW5FbC5yZXBsYWNlV2l0aChuZXdNYWluRWwpXG4gICAgICAgICAgdGhpcy5vdXRnb2luZ01haW5FbCA9IG51bGxcbiAgICAgICAgICBjYWxsYmFjayAmJiByZXF1ZXN0QW5pbWF0aW9uRnJhbWUoY2FsbGJhY2spXG4gICAgICAgICAgb25Eb25lKClcbiAgICAgICAgfSlcbiAgICAgIH1cbiAgICB9KVxuICB9XG5cbiAgdHJhbnNpdGlvblJlbW92ZXMoZWxlbWVudHMpe1xuICAgIGxldCByZW1vdmVBdHRyID0gdGhpcy5iaW5kaW5nKFwicmVtb3ZlXCIpXG4gICAgZWxlbWVudHMgPSBlbGVtZW50cyB8fCBET00uYWxsKGRvY3VtZW50LCBgWyR7cmVtb3ZlQXR0cn1dYClcbiAgICBlbGVtZW50cy5mb3JFYWNoKGVsID0+IHtcbiAgICAgIGlmKGRvY3VtZW50LmJvZHkuY29udGFpbnMoZWwpKXsgLy8gc2tpcCBjaGlsZHJlbiBhbHJlYWR5IHJlbW92ZWRcbiAgICAgICAgdGhpcy5leGVjSlMoZWwsIGVsLmdldEF0dHJpYnV0ZShyZW1vdmVBdHRyKSwgXCJyZW1vdmVcIilcbiAgICAgIH1cbiAgICB9KVxuICB9XG5cbiAgaXNQaHhWaWV3KGVsKXsgcmV0dXJuIGVsLmdldEF0dHJpYnV0ZSAmJiBlbC5nZXRBdHRyaWJ1dGUoUEhYX1NFU1NJT04pICE9PSBudWxsIH1cblxuICBuZXdSb290VmlldyhlbCwgZmxhc2gsIGxpdmVSZWZlcmVyKXtcbiAgICBsZXQgdmlldyA9IG5ldyBWaWV3KGVsLCB0aGlzLCBudWxsLCBmbGFzaCwgbGl2ZVJlZmVyZXIpXG4gICAgdGhpcy5yb290c1t2aWV3LmlkXSA9IHZpZXdcbiAgICByZXR1cm4gdmlld1xuICB9XG5cbiAgb3duZXIoY2hpbGRFbCwgY2FsbGJhY2spe1xuICAgIGxldCB2aWV3ID0gbWF5YmUoY2hpbGRFbC5jbG9zZXN0KFBIWF9WSUVXX1NFTEVDVE9SKSwgZWwgPT4gdGhpcy5nZXRWaWV3QnlFbChlbCkpIHx8IHRoaXMubWFpblxuICAgIGlmKHZpZXcpeyBjYWxsYmFjayh2aWV3KSB9XG4gIH1cblxuICB3aXRoaW5Pd25lcnMoY2hpbGRFbCwgY2FsbGJhY2spe1xuICAgIHRoaXMub3duZXIoY2hpbGRFbCwgdmlldyA9PiBjYWxsYmFjayh2aWV3LCBjaGlsZEVsKSlcbiAgfVxuXG4gIGdldFZpZXdCeUVsKGVsKXtcbiAgICBsZXQgcm9vdElkID0gZWwuZ2V0QXR0cmlidXRlKFBIWF9ST09UX0lEKVxuICAgIHJldHVybiBtYXliZSh0aGlzLmdldFJvb3RCeUlkKHJvb3RJZCksIHJvb3QgPT4gcm9vdC5nZXREZXNjZW5kZW50QnlFbChlbCkpXG4gIH1cblxuICBnZXRSb290QnlJZChpZCl7IHJldHVybiB0aGlzLnJvb3RzW2lkXSB9XG5cbiAgZGVzdHJveUFsbFZpZXdzKCl7XG4gICAgZm9yKGxldCBpZCBpbiB0aGlzLnJvb3RzKXtcbiAgICAgIHRoaXMucm9vdHNbaWRdLmRlc3Ryb3koKVxuICAgICAgZGVsZXRlIHRoaXMucm9vdHNbaWRdXG4gICAgfVxuICAgIHRoaXMubWFpbiA9IG51bGxcbiAgfVxuXG4gIGRlc3Ryb3lWaWV3QnlFbChlbCl7XG4gICAgbGV0IHJvb3QgPSB0aGlzLmdldFJvb3RCeUlkKGVsLmdldEF0dHJpYnV0ZShQSFhfUk9PVF9JRCkpXG4gICAgaWYocm9vdCAmJiByb290LmlkID09PSBlbC5pZCl7XG4gICAgICByb290LmRlc3Ryb3koKVxuICAgICAgZGVsZXRlIHRoaXMucm9vdHNbcm9vdC5pZF1cbiAgICB9IGVsc2UgaWYocm9vdCl7XG4gICAgICByb290LmRlc3Ryb3lEZXNjZW5kZW50KGVsLmlkKVxuICAgIH1cbiAgfVxuXG4gIHNldEFjdGl2ZUVsZW1lbnQodGFyZ2V0KXtcbiAgICBpZih0aGlzLmFjdGl2ZUVsZW1lbnQgPT09IHRhcmdldCl7IHJldHVybiB9XG4gICAgdGhpcy5hY3RpdmVFbGVtZW50ID0gdGFyZ2V0XG4gICAgbGV0IGNhbmNlbCA9ICgpID0+IHtcbiAgICAgIGlmKHRhcmdldCA9PT0gdGhpcy5hY3RpdmVFbGVtZW50KXsgdGhpcy5hY3RpdmVFbGVtZW50ID0gbnVsbCB9XG4gICAgICB0YXJnZXQucmVtb3ZlRXZlbnRMaXN0ZW5lcihcIm1vdXNldXBcIiwgdGhpcylcbiAgICAgIHRhcmdldC5yZW1vdmVFdmVudExpc3RlbmVyKFwidG91Y2hlbmRcIiwgdGhpcylcbiAgICB9XG4gICAgdGFyZ2V0LmFkZEV2ZW50TGlzdGVuZXIoXCJtb3VzZXVwXCIsIGNhbmNlbClcbiAgICB0YXJnZXQuYWRkRXZlbnRMaXN0ZW5lcihcInRvdWNoZW5kXCIsIGNhbmNlbClcbiAgfVxuXG4gIGdldEFjdGl2ZUVsZW1lbnQoKXtcbiAgICBpZihkb2N1bWVudC5hY3RpdmVFbGVtZW50ID09PSBkb2N1bWVudC5ib2R5KXtcbiAgICAgIHJldHVybiB0aGlzLmFjdGl2ZUVsZW1lbnQgfHwgZG9jdW1lbnQuYWN0aXZlRWxlbWVudFxuICAgIH0gZWxzZSB7XG4gICAgICAvLyBkb2N1bWVudC5hY3RpdmVFbGVtZW50IGNhbiBiZSBudWxsIGluIEludGVybmV0IEV4cGxvcmVyIDExXG4gICAgICByZXR1cm4gZG9jdW1lbnQuYWN0aXZlRWxlbWVudCB8fCBkb2N1bWVudC5ib2R5XG4gICAgfVxuICB9XG5cbiAgZHJvcEFjdGl2ZUVsZW1lbnQodmlldyl7XG4gICAgaWYodGhpcy5wcmV2QWN0aXZlICYmIHZpZXcub3duc0VsZW1lbnQodGhpcy5wcmV2QWN0aXZlKSl7XG4gICAgICB0aGlzLnByZXZBY3RpdmUgPSBudWxsXG4gICAgfVxuICB9XG5cbiAgcmVzdG9yZVByZXZpb3VzbHlBY3RpdmVGb2N1cygpe1xuICAgIGlmKHRoaXMucHJldkFjdGl2ZSAmJiB0aGlzLnByZXZBY3RpdmUgIT09IGRvY3VtZW50LmJvZHkpe1xuICAgICAgdGhpcy5wcmV2QWN0aXZlLmZvY3VzKClcbiAgICB9XG4gIH1cblxuICBibHVyQWN0aXZlRWxlbWVudCgpe1xuICAgIHRoaXMucHJldkFjdGl2ZSA9IHRoaXMuZ2V0QWN0aXZlRWxlbWVudCgpXG4gICAgaWYodGhpcy5wcmV2QWN0aXZlICE9PSBkb2N1bWVudC5ib2R5KXsgdGhpcy5wcmV2QWN0aXZlLmJsdXIoKSB9XG4gIH1cblxuICBiaW5kVG9wTGV2ZWxFdmVudHMoe2RlYWR9ID0ge30pe1xuICAgIGlmKHRoaXMuYm91bmRUb3BMZXZlbEV2ZW50cyl7IHJldHVybiB9XG5cbiAgICB0aGlzLmJvdW5kVG9wTGV2ZWxFdmVudHMgPSB0cnVlXG4gICAgLy8gZW50ZXIgZmFpbHNhZmUgcmVsb2FkIGlmIHNlcnZlciBoYXMgZ29uZSBhd2F5IGludGVudGlvbmFsbHksIHN1Y2ggYXMgXCJkaXNjb25uZWN0XCIgYnJvYWRjYXN0XG4gICAgdGhpcy5zb2NrZXQub25DbG9zZShldmVudCA9PiB7XG4gICAgICAvLyB1bmxvYWQgd2hlbiBuYXZpZ2F0aW5nIGhyZWYgb3IgZm9ybSBzdWJtaXQgKHN1Y2ggYXMgZm9yIGZpcmVmb3gpXG4gICAgICBpZihldmVudCAmJiBldmVudC5jb2RlID09PSAxMDAxKXsgcmV0dXJuIHRoaXMudW5sb2FkKCkgfVxuICAgICAgLy8gZmFpbHNhZmUgcmVsb2FkIGlmIG5vcm1hbCBjbG9zdXJlIGFuZCB3ZSBzdGlsbCBoYXZlIGEgbWFpbiBMVlxuICAgICAgaWYoZXZlbnQgJiYgZXZlbnQuY29kZSA9PT0gMTAwMCAmJiB0aGlzLm1haW4peyByZXR1cm4gdGhpcy5yZWxvYWRXaXRoSml0dGVyKHRoaXMubWFpbikgfVxuICAgIH0pXG4gICAgZG9jdW1lbnQuYm9keS5hZGRFdmVudExpc3RlbmVyKFwiY2xpY2tcIiwgZnVuY3Rpb24gKCl7IH0pIC8vIGVuc3VyZSBhbGwgY2xpY2sgZXZlbnRzIGJ1YmJsZSBmb3IgbW9iaWxlIFNhZmFyaVxuICAgIHdpbmRvdy5hZGRFdmVudExpc3RlbmVyKFwicGFnZXNob3dcIiwgZSA9PiB7XG4gICAgICBpZihlLnBlcnNpc3RlZCl7IC8vIHJlbG9hZCBwYWdlIGlmIGJlaW5nIHJlc3RvcmVkIGZyb20gYmFjay9mb3J3YXJkIGNhY2hlXG4gICAgICAgIHRoaXMuZ2V0U29ja2V0KCkuZGlzY29ubmVjdCgpXG4gICAgICAgIHRoaXMud2l0aFBhZ2VMb2FkaW5nKHt0bzogd2luZG93LmxvY2F0aW9uLmhyZWYsIGtpbmQ6IFwicmVkaXJlY3RcIn0pXG4gICAgICAgIHdpbmRvdy5sb2NhdGlvbi5yZWxvYWQoKVxuICAgICAgfVxuICAgIH0sIHRydWUpXG4gICAgaWYoIWRlYWQpeyB0aGlzLmJpbmROYXYoKSB9XG4gICAgdGhpcy5iaW5kQ2xpY2tzKClcbiAgICBpZighZGVhZCl7IHRoaXMuYmluZEZvcm1zKCkgfVxuICAgIHRoaXMuYmluZCh7a2V5dXA6IFwia2V5dXBcIiwga2V5ZG93bjogXCJrZXlkb3duXCJ9LCAoZSwgdHlwZSwgdmlldywgdGFyZ2V0RWwsIHBoeEV2ZW50LCBldmVudFRhcmdldCkgPT4ge1xuICAgICAgbGV0IG1hdGNoS2V5ID0gdGFyZ2V0RWwuZ2V0QXR0cmlidXRlKHRoaXMuYmluZGluZyhQSFhfS0VZKSlcbiAgICAgIGxldCBwcmVzc2VkS2V5ID0gZS5rZXkgJiYgZS5rZXkudG9Mb3dlckNhc2UoKSAvLyBjaHJvbWUgY2xpY2tlZCBhdXRvY29tcGxldGVzIHNlbmQgYSBrZXlkb3duIHdpdGhvdXQga2V5XG4gICAgICBpZihtYXRjaEtleSAmJiBtYXRjaEtleS50b0xvd2VyQ2FzZSgpICE9PSBwcmVzc2VkS2V5KXsgcmV0dXJuIH1cblxuICAgICAgbGV0IGRhdGEgPSB7a2V5OiBlLmtleSwgLi4udGhpcy5ldmVudE1ldGEodHlwZSwgZSwgdGFyZ2V0RWwpfVxuICAgICAgSlMuZXhlYyh0eXBlLCBwaHhFdmVudCwgdmlldywgdGFyZ2V0RWwsIFtcInB1c2hcIiwge2RhdGF9XSlcbiAgICB9KVxuICAgIHRoaXMuYmluZCh7Ymx1cjogXCJmb2N1c291dFwiLCBmb2N1czogXCJmb2N1c2luXCJ9LCAoZSwgdHlwZSwgdmlldywgdGFyZ2V0RWwsIHBoeEV2ZW50LCBldmVudFRhcmdldCkgPT4ge1xuICAgICAgaWYoIWV2ZW50VGFyZ2V0KXtcbiAgICAgICAgbGV0IGRhdGEgPSB7a2V5OiBlLmtleSwgLi4udGhpcy5ldmVudE1ldGEodHlwZSwgZSwgdGFyZ2V0RWwpfVxuICAgICAgICBKUy5leGVjKHR5cGUsIHBoeEV2ZW50LCB2aWV3LCB0YXJnZXRFbCwgW1wicHVzaFwiLCB7ZGF0YX1dKVxuICAgICAgfVxuICAgIH0pXG4gICAgdGhpcy5iaW5kKHtibHVyOiBcImJsdXJcIiwgZm9jdXM6IFwiZm9jdXNcIn0sIChlLCB0eXBlLCB2aWV3LCB0YXJnZXRFbCwgdGFyZ2V0Q3R4LCBwaHhFdmVudCwgcGh4VGFyZ2V0KSA9PiB7XG4gICAgICAvLyBibHVyIGFuZCBmb2N1cyBhcmUgdHJpZ2dlcmVkIG9uIGRvY3VtZW50IGFuZCB3aW5kb3cuIERpc2NhcmQgb25lIHRvIGF2b2lkIGR1cHNcbiAgICAgIGlmKHBoeFRhcmdldCA9PT0gXCJ3aW5kb3dcIil7XG4gICAgICAgIGxldCBkYXRhID0gdGhpcy5ldmVudE1ldGEodHlwZSwgZSwgdGFyZ2V0RWwpXG4gICAgICAgIEpTLmV4ZWModHlwZSwgcGh4RXZlbnQsIHZpZXcsIHRhcmdldEVsLCBbXCJwdXNoXCIsIHtkYXRhfV0pXG4gICAgICB9XG4gICAgfSlcbiAgICB3aW5kb3cuYWRkRXZlbnRMaXN0ZW5lcihcImRyYWdvdmVyXCIsIGUgPT4gZS5wcmV2ZW50RGVmYXVsdCgpKVxuICAgIHdpbmRvdy5hZGRFdmVudExpc3RlbmVyKFwiZHJvcFwiLCBlID0+IHtcbiAgICAgIGUucHJldmVudERlZmF1bHQoKVxuICAgICAgbGV0IGRyb3BUYXJnZXRJZCA9IG1heWJlKGNsb3Nlc3RQaHhCaW5kaW5nKGUudGFyZ2V0LCB0aGlzLmJpbmRpbmcoUEhYX0RST1BfVEFSR0VUKSksIHRydWVUYXJnZXQgPT4ge1xuICAgICAgICByZXR1cm4gdHJ1ZVRhcmdldC5nZXRBdHRyaWJ1dGUodGhpcy5iaW5kaW5nKFBIWF9EUk9QX1RBUkdFVCkpXG4gICAgICB9KVxuICAgICAgbGV0IGRyb3BUYXJnZXQgPSBkcm9wVGFyZ2V0SWQgJiYgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoZHJvcFRhcmdldElkKVxuICAgICAgbGV0IGZpbGVzID0gQXJyYXkuZnJvbShlLmRhdGFUcmFuc2Zlci5maWxlcyB8fCBbXSlcbiAgICAgIGlmKCFkcm9wVGFyZ2V0IHx8IGRyb3BUYXJnZXQuZGlzYWJsZWQgfHwgZmlsZXMubGVuZ3RoID09PSAwIHx8ICEoZHJvcFRhcmdldC5maWxlcyBpbnN0YW5jZW9mIEZpbGVMaXN0KSl7IHJldHVybiB9XG5cbiAgICAgIExpdmVVcGxvYWRlci50cmFja0ZpbGVzKGRyb3BUYXJnZXQsIGZpbGVzLCBlLmRhdGFUcmFuc2ZlcilcbiAgICAgIGRyb3BUYXJnZXQuZGlzcGF0Y2hFdmVudChuZXcgRXZlbnQoXCJpbnB1dFwiLCB7YnViYmxlczogdHJ1ZX0pKVxuICAgIH0pXG4gICAgdGhpcy5vbihQSFhfVFJBQ0tfVVBMT0FEUywgZSA9PiB7XG4gICAgICBsZXQgdXBsb2FkVGFyZ2V0ID0gZS50YXJnZXRcbiAgICAgIGlmKCFET00uaXNVcGxvYWRJbnB1dCh1cGxvYWRUYXJnZXQpKXsgcmV0dXJuIH1cbiAgICAgIGxldCBmaWxlcyA9IEFycmF5LmZyb20oZS5kZXRhaWwuZmlsZXMgfHwgW10pLmZpbHRlcihmID0+IGYgaW5zdGFuY2VvZiBGaWxlIHx8IGYgaW5zdGFuY2VvZiBCbG9iKVxuICAgICAgTGl2ZVVwbG9hZGVyLnRyYWNrRmlsZXModXBsb2FkVGFyZ2V0LCBmaWxlcylcbiAgICAgIHVwbG9hZFRhcmdldC5kaXNwYXRjaEV2ZW50KG5ldyBFdmVudChcImlucHV0XCIsIHtidWJibGVzOiB0cnVlfSkpXG4gICAgfSlcbiAgfVxuXG4gIGV2ZW50TWV0YShldmVudE5hbWUsIGUsIHRhcmdldEVsKXtcbiAgICBsZXQgY2FsbGJhY2sgPSB0aGlzLm1ldGFkYXRhQ2FsbGJhY2tzW2V2ZW50TmFtZV1cbiAgICByZXR1cm4gY2FsbGJhY2sgPyBjYWxsYmFjayhlLCB0YXJnZXRFbCkgOiB7fVxuICB9XG5cbiAgc2V0UGVuZGluZ0xpbmsoaHJlZil7XG4gICAgdGhpcy5saW5rUmVmKytcbiAgICB0aGlzLnBlbmRpbmdMaW5rID0gaHJlZlxuICAgIHJldHVybiB0aGlzLmxpbmtSZWZcbiAgfVxuXG4gIGNvbW1pdFBlbmRpbmdMaW5rKGxpbmtSZWYpe1xuICAgIGlmKHRoaXMubGlua1JlZiAhPT0gbGlua1JlZil7XG4gICAgICByZXR1cm4gZmFsc2VcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5ocmVmID0gdGhpcy5wZW5kaW5nTGlua1xuICAgICAgdGhpcy5wZW5kaW5nTGluayA9IG51bGxcbiAgICAgIHJldHVybiB0cnVlXG4gICAgfVxuICB9XG5cbiAgZ2V0SHJlZigpeyByZXR1cm4gdGhpcy5ocmVmIH1cblxuICBoYXNQZW5kaW5nTGluaygpeyByZXR1cm4gISF0aGlzLnBlbmRpbmdMaW5rIH1cblxuICBiaW5kKGV2ZW50cywgY2FsbGJhY2spe1xuICAgIGZvcihsZXQgZXZlbnQgaW4gZXZlbnRzKXtcbiAgICAgIGxldCBicm93c2VyRXZlbnROYW1lID0gZXZlbnRzW2V2ZW50XVxuXG4gICAgICB0aGlzLm9uKGJyb3dzZXJFdmVudE5hbWUsIGUgPT4ge1xuICAgICAgICBsZXQgYmluZGluZyA9IHRoaXMuYmluZGluZyhldmVudClcbiAgICAgICAgbGV0IHdpbmRvd0JpbmRpbmcgPSB0aGlzLmJpbmRpbmcoYHdpbmRvdy0ke2V2ZW50fWApXG4gICAgICAgIGxldCB0YXJnZXRQaHhFdmVudCA9IGUudGFyZ2V0LmdldEF0dHJpYnV0ZSAmJiBlLnRhcmdldC5nZXRBdHRyaWJ1dGUoYmluZGluZylcbiAgICAgICAgaWYodGFyZ2V0UGh4RXZlbnQpe1xuICAgICAgICAgIHRoaXMuZGVib3VuY2UoZS50YXJnZXQsIGUsIGJyb3dzZXJFdmVudE5hbWUsICgpID0+IHtcbiAgICAgICAgICAgIHRoaXMud2l0aGluT3duZXJzKGUudGFyZ2V0LCB2aWV3ID0+IHtcbiAgICAgICAgICAgICAgY2FsbGJhY2soZSwgZXZlbnQsIHZpZXcsIGUudGFyZ2V0LCB0YXJnZXRQaHhFdmVudCwgbnVsbClcbiAgICAgICAgICAgIH0pXG4gICAgICAgICAgfSlcbiAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICBET00uYWxsKGRvY3VtZW50LCBgWyR7d2luZG93QmluZGluZ31dYCwgZWwgPT4ge1xuICAgICAgICAgICAgbGV0IHBoeEV2ZW50ID0gZWwuZ2V0QXR0cmlidXRlKHdpbmRvd0JpbmRpbmcpXG4gICAgICAgICAgICB0aGlzLmRlYm91bmNlKGVsLCBlLCBicm93c2VyRXZlbnROYW1lLCAoKSA9PiB7XG4gICAgICAgICAgICAgIHRoaXMud2l0aGluT3duZXJzKGVsLCB2aWV3ID0+IHtcbiAgICAgICAgICAgICAgICBjYWxsYmFjayhlLCBldmVudCwgdmlldywgZWwsIHBoeEV2ZW50LCBcIndpbmRvd1wiKVxuICAgICAgICAgICAgICB9KVxuICAgICAgICAgICAgfSlcbiAgICAgICAgICB9KVxuICAgICAgICB9XG4gICAgICB9KVxuICAgIH1cbiAgfVxuXG4gIGJpbmRDbGlja3MoKXtcbiAgICB3aW5kb3cuYWRkRXZlbnRMaXN0ZW5lcihcImNsaWNrXCIsIGUgPT4gdGhpcy5jbGlja1N0YXJ0ZWRBdFRhcmdldCA9IGUudGFyZ2V0KVxuICAgIHRoaXMuYmluZENsaWNrKFwiY2xpY2tcIiwgXCJjbGlja1wiLCBmYWxzZSlcbiAgICB0aGlzLmJpbmRDbGljayhcIm1vdXNlZG93blwiLCBcImNhcHR1cmUtY2xpY2tcIiwgdHJ1ZSlcbiAgfVxuXG4gIGJpbmRDbGljayhldmVudE5hbWUsIGJpbmRpbmdOYW1lLCBjYXB0dXJlKXtcbiAgICBsZXQgY2xpY2sgPSB0aGlzLmJpbmRpbmcoYmluZGluZ05hbWUpXG4gICAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoZXZlbnROYW1lLCBlID0+IHtcbiAgICAgIGxldCB0YXJnZXQgPSBudWxsXG4gICAgICBpZihjYXB0dXJlKXtcbiAgICAgICAgdGFyZ2V0ID0gZS50YXJnZXQubWF0Y2hlcyhgWyR7Y2xpY2t9XWApID8gZS50YXJnZXQgOiBlLnRhcmdldC5xdWVyeVNlbGVjdG9yKGBbJHtjbGlja31dYClcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGxldCBjbGlja1N0YXJ0ZWRBdFRhcmdldCA9IHRoaXMuY2xpY2tTdGFydGVkQXRUYXJnZXQgfHwgZS50YXJnZXRcbiAgICAgICAgdGFyZ2V0ID0gY2xvc2VzdFBoeEJpbmRpbmcoY2xpY2tTdGFydGVkQXRUYXJnZXQsIGNsaWNrKVxuICAgICAgICB0aGlzLmRpc3BhdGNoQ2xpY2tBd2F5KGUsIGNsaWNrU3RhcnRlZEF0VGFyZ2V0KVxuICAgICAgICB0aGlzLmNsaWNrU3RhcnRlZEF0VGFyZ2V0ID0gbnVsbFxuICAgICAgfVxuICAgICAgbGV0IHBoeEV2ZW50ID0gdGFyZ2V0ICYmIHRhcmdldC5nZXRBdHRyaWJ1dGUoY2xpY2spXG4gICAgICBpZighcGh4RXZlbnQpe1xuICAgICAgICBsZXQgaHJlZiA9IGUudGFyZ2V0IGluc3RhbmNlb2YgSFRNTEFuY2hvckVsZW1lbnQgPyBlLnRhcmdldC5nZXRBdHRyaWJ1dGUoXCJocmVmXCIpIDogbnVsbFxuICAgICAgICBpZighY2FwdHVyZSAmJiBocmVmICE9PSBudWxsICYmICFET00ud2FudHNOZXdUYWIoZSkgJiYgRE9NLmlzTmV3UGFnZUhyZWYoaHJlZiwgd2luZG93LmxvY2F0aW9uKSl7XG4gICAgICAgICAgdGhpcy51bmxvYWQoKVxuICAgICAgICB9XG4gICAgICAgIHJldHVyblxuICAgICAgfVxuICAgICAgaWYodGFyZ2V0LmdldEF0dHJpYnV0ZShcImhyZWZcIikgPT09IFwiI1wiKXsgZS5wcmV2ZW50RGVmYXVsdCgpIH1cblxuICAgICAgdGhpcy5kZWJvdW5jZSh0YXJnZXQsIGUsIFwiY2xpY2tcIiwgKCkgPT4ge1xuICAgICAgICB0aGlzLndpdGhpbk93bmVycyh0YXJnZXQsIHZpZXcgPT4ge1xuICAgICAgICAgIEpTLmV4ZWMoXCJjbGlja1wiLCBwaHhFdmVudCwgdmlldywgdGFyZ2V0LCBbXCJwdXNoXCIsIHtkYXRhOiB0aGlzLmV2ZW50TWV0YShcImNsaWNrXCIsIGUsIHRhcmdldCl9XSlcbiAgICAgICAgfSlcbiAgICAgIH0pXG4gICAgfSwgY2FwdHVyZSlcbiAgfVxuXG4gIGRpc3BhdGNoQ2xpY2tBd2F5KGUsIGNsaWNrU3RhcnRlZEF0KXtcbiAgICBsZXQgcGh4Q2xpY2tBd2F5ID0gdGhpcy5iaW5kaW5nKFwiY2xpY2stYXdheVwiKVxuICAgIERPTS5hbGwoZG9jdW1lbnQsIGBbJHtwaHhDbGlja0F3YXl9XWAsIGVsID0+IHtcbiAgICAgIGlmKCEoZWwuaXNTYW1lTm9kZShjbGlja1N0YXJ0ZWRBdCkgfHwgZWwuY29udGFpbnMoY2xpY2tTdGFydGVkQXQpKSl7XG4gICAgICAgIHRoaXMud2l0aGluT3duZXJzKGUudGFyZ2V0LCB2aWV3ID0+IHtcbiAgICAgICAgICBsZXQgcGh4RXZlbnQgPSBlbC5nZXRBdHRyaWJ1dGUocGh4Q2xpY2tBd2F5KVxuICAgICAgICAgIGlmKEpTLmlzVmlzaWJsZShlbCkpe1xuICAgICAgICAgICAgSlMuZXhlYyhcImNsaWNrXCIsIHBoeEV2ZW50LCB2aWV3LCBlbCwgW1wicHVzaFwiLCB7ZGF0YTogdGhpcy5ldmVudE1ldGEoXCJjbGlja1wiLCBlLCBlLnRhcmdldCl9XSlcbiAgICAgICAgICB9XG4gICAgICAgIH0pXG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIGJpbmROYXYoKXtcbiAgICBpZighQnJvd3Nlci5jYW5QdXNoU3RhdGUoKSl7IHJldHVybiB9XG4gICAgaWYoaGlzdG9yeS5zY3JvbGxSZXN0b3JhdGlvbil7IGhpc3Rvcnkuc2Nyb2xsUmVzdG9yYXRpb24gPSBcIm1hbnVhbFwiIH1cbiAgICBsZXQgc2Nyb2xsVGltZXIgPSBudWxsXG4gICAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoXCJzY3JvbGxcIiwgX2UgPT4ge1xuICAgICAgY2xlYXJUaW1lb3V0KHNjcm9sbFRpbWVyKVxuICAgICAgc2Nyb2xsVGltZXIgPSBzZXRUaW1lb3V0KCgpID0+IHtcbiAgICAgICAgQnJvd3Nlci51cGRhdGVDdXJyZW50U3RhdGUoc3RhdGUgPT4gT2JqZWN0LmFzc2lnbihzdGF0ZSwge3Njcm9sbDogd2luZG93LnNjcm9sbFl9KSlcbiAgICAgIH0sIDEwMClcbiAgICB9KVxuICAgIHdpbmRvdy5hZGRFdmVudExpc3RlbmVyKFwicG9wc3RhdGVcIiwgZXZlbnQgPT4ge1xuICAgICAgaWYoIXRoaXMucmVnaXN0ZXJOZXdMb2NhdGlvbih3aW5kb3cubG9jYXRpb24pKXsgcmV0dXJuIH1cbiAgICAgIGxldCB7dHlwZSwgaWQsIHJvb3QsIHNjcm9sbH0gPSBldmVudC5zdGF0ZSB8fCB7fVxuICAgICAgbGV0IGhyZWYgPSB3aW5kb3cubG9jYXRpb24uaHJlZlxuXG4gICAgICB0aGlzLnJlcXVlc3RET01VcGRhdGUoKCkgPT4ge1xuICAgICAgICBpZih0aGlzLm1haW4uaXNDb25uZWN0ZWQoKSAmJiAodHlwZSA9PT0gXCJwYXRjaFwiICYmIGlkID09PSB0aGlzLm1haW4uaWQpKXtcbiAgICAgICAgICB0aGlzLm1haW4ucHVzaExpbmtQYXRjaChocmVmLCBudWxsLCAoKSA9PiB7XG4gICAgICAgICAgICB0aGlzLm1heWJlU2Nyb2xsKHNjcm9sbClcbiAgICAgICAgICB9KVxuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIHRoaXMucmVwbGFjZU1haW4oaHJlZiwgbnVsbCwgKCkgPT4ge1xuICAgICAgICAgICAgaWYocm9vdCl7IHRoaXMucmVwbGFjZVJvb3RIaXN0b3J5KCkgfVxuICAgICAgICAgICAgdGhpcy5tYXliZVNjcm9sbChzY3JvbGwpXG4gICAgICAgICAgfSlcbiAgICAgICAgfVxuICAgICAgfSlcbiAgICB9LCBmYWxzZSlcbiAgICB3aW5kb3cuYWRkRXZlbnRMaXN0ZW5lcihcImNsaWNrXCIsIGUgPT4ge1xuICAgICAgbGV0IHRhcmdldCA9IGNsb3Nlc3RQaHhCaW5kaW5nKGUudGFyZ2V0LCBQSFhfTElWRV9MSU5LKVxuICAgICAgbGV0IHR5cGUgPSB0YXJnZXQgJiYgdGFyZ2V0LmdldEF0dHJpYnV0ZShQSFhfTElWRV9MSU5LKVxuICAgICAgaWYoIXR5cGUgfHwgIXRoaXMuaXNDb25uZWN0ZWQoKSB8fCAhdGhpcy5tYWluIHx8IERPTS53YW50c05ld1RhYihlKSl7IHJldHVybiB9XG5cbiAgICAgIGxldCBocmVmID0gdGFyZ2V0LmhyZWZcbiAgICAgIGxldCBsaW5rU3RhdGUgPSB0YXJnZXQuZ2V0QXR0cmlidXRlKFBIWF9MSU5LX1NUQVRFKVxuICAgICAgZS5wcmV2ZW50RGVmYXVsdCgpXG4gICAgICBlLnN0b3BJbW1lZGlhdGVQcm9wYWdhdGlvbigpIC8vIGRvIG5vdCBidWJibGUgY2xpY2sgdG8gcmVndWxhciBwaHgtY2xpY2sgYmluZGluZ3NcbiAgICAgIGlmKHRoaXMucGVuZGluZ0xpbmsgPT09IGhyZWYpeyByZXR1cm4gfVxuXG4gICAgICB0aGlzLnJlcXVlc3RET01VcGRhdGUoKCkgPT4ge1xuICAgICAgICBpZih0eXBlID09PSBcInBhdGNoXCIpe1xuICAgICAgICAgIHRoaXMucHVzaEhpc3RvcnlQYXRjaChocmVmLCBsaW5rU3RhdGUsIHRhcmdldClcbiAgICAgICAgfSBlbHNlIGlmKHR5cGUgPT09IFwicmVkaXJlY3RcIil7XG4gICAgICAgICAgdGhpcy5oaXN0b3J5UmVkaXJlY3QoaHJlZiwgbGlua1N0YXRlKVxuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIHRocm93IG5ldyBFcnJvcihgZXhwZWN0ZWQgJHtQSFhfTElWRV9MSU5LfSB0byBiZSBcInBhdGNoXCIgb3IgXCJyZWRpcmVjdFwiLCBnb3Q6ICR7dHlwZX1gKVxuICAgICAgICB9XG4gICAgICAgIGxldCBwaHhDbGljayA9IHRhcmdldC5nZXRBdHRyaWJ1dGUodGhpcy5iaW5kaW5nKFwiY2xpY2tcIikpXG4gICAgICAgIGlmKHBoeENsaWNrKXtcbiAgICAgICAgICB0aGlzLnJlcXVlc3RET01VcGRhdGUoKCkgPT4gdGhpcy5leGVjSlModGFyZ2V0LCBwaHhDbGljaywgXCJjbGlja1wiKSlcbiAgICAgICAgfVxuICAgICAgfSlcbiAgICB9LCBmYWxzZSlcbiAgfVxuXG4gIG1heWJlU2Nyb2xsKHNjcm9sbCkge1xuICAgIGlmKHR5cGVvZihzY3JvbGwpID09PSBcIm51bWJlclwiKXtcbiAgICAgIHJlcXVlc3RBbmltYXRpb25GcmFtZSgoKSA9PiB7XG4gICAgICAgIHdpbmRvdy5zY3JvbGxUbygwLCBzY3JvbGwpXG4gICAgICB9KSAvLyB0aGUgYm9keSBuZWVkcyB0byByZW5kZXIgYmVmb3JlIHdlIHNjcm9sbC5cbiAgICB9XG4gIH1cblxuICBkaXNwYXRjaEV2ZW50KGV2ZW50LCBwYXlsb2FkID0ge30pe1xuICAgIERPTS5kaXNwYXRjaEV2ZW50KHdpbmRvdywgYHBoeDoke2V2ZW50fWAsIHtkZXRhaWw6IHBheWxvYWR9KVxuICB9XG5cbiAgZGlzcGF0Y2hFdmVudHMoZXZlbnRzKXtcbiAgICBldmVudHMuZm9yRWFjaCgoW2V2ZW50LCBwYXlsb2FkXSkgPT4gdGhpcy5kaXNwYXRjaEV2ZW50KGV2ZW50LCBwYXlsb2FkKSlcbiAgfVxuXG4gIHdpdGhQYWdlTG9hZGluZyhpbmZvLCBjYWxsYmFjayl7XG4gICAgRE9NLmRpc3BhdGNoRXZlbnQod2luZG93LCBcInBoeDpwYWdlLWxvYWRpbmctc3RhcnRcIiwge2RldGFpbDogaW5mb30pXG4gICAgbGV0IGRvbmUgPSAoKSA9PiBET00uZGlzcGF0Y2hFdmVudCh3aW5kb3csIFwicGh4OnBhZ2UtbG9hZGluZy1zdG9wXCIsIHtkZXRhaWw6IGluZm99KVxuICAgIHJldHVybiBjYWxsYmFjayA/IGNhbGxiYWNrKGRvbmUpIDogZG9uZVxuICB9XG5cbiAgcHVzaEhpc3RvcnlQYXRjaChocmVmLCBsaW5rU3RhdGUsIHRhcmdldEVsKXtcbiAgICBpZighdGhpcy5pc0Nvbm5lY3RlZCgpKXsgcmV0dXJuIEJyb3dzZXIucmVkaXJlY3QoaHJlZikgfVxuXG4gICAgdGhpcy53aXRoUGFnZUxvYWRpbmcoe3RvOiBocmVmLCBraW5kOiBcInBhdGNoXCJ9LCBkb25lID0+IHtcbiAgICAgIHRoaXMubWFpbi5wdXNoTGlua1BhdGNoKGhyZWYsIHRhcmdldEVsLCBsaW5rUmVmID0+IHtcbiAgICAgICAgdGhpcy5oaXN0b3J5UGF0Y2goaHJlZiwgbGlua1N0YXRlLCBsaW5rUmVmKVxuICAgICAgICBkb25lKClcbiAgICAgIH0pXG4gICAgfSlcbiAgfVxuXG4gIGhpc3RvcnlQYXRjaChocmVmLCBsaW5rU3RhdGUsIGxpbmtSZWYgPSB0aGlzLnNldFBlbmRpbmdMaW5rKGhyZWYpKXtcbiAgICBpZighdGhpcy5jb21taXRQZW5kaW5nTGluayhsaW5rUmVmKSl7IHJldHVybiB9XG5cbiAgICBCcm93c2VyLnB1c2hTdGF0ZShsaW5rU3RhdGUsIHt0eXBlOiBcInBhdGNoXCIsIGlkOiB0aGlzLm1haW4uaWR9LCBocmVmKVxuICAgIHRoaXMucmVnaXN0ZXJOZXdMb2NhdGlvbih3aW5kb3cubG9jYXRpb24pXG4gIH1cblxuICBoaXN0b3J5UmVkaXJlY3QoaHJlZiwgbGlua1N0YXRlLCBmbGFzaCl7XG4gICAgLy8gY29udmVydCB0byBmdWxsIGhyZWYgaWYgb25seSBwYXRoIHByZWZpeFxuICAgIGlmKCF0aGlzLmlzQ29ubmVjdGVkKCkpeyByZXR1cm4gQnJvd3Nlci5yZWRpcmVjdChocmVmLCBmbGFzaCkgfVxuICAgIGlmKC9eXFwvJHxeXFwvW15cXC9dKy4qJC8udGVzdChocmVmKSl7XG4gICAgICBsZXQge3Byb3RvY29sLCBob3N0fSA9IHdpbmRvdy5sb2NhdGlvblxuICAgICAgaHJlZiA9IGAke3Byb3RvY29sfS8vJHtob3N0fSR7aHJlZn1gXG4gICAgfVxuICAgIGxldCBzY3JvbGwgPSB3aW5kb3cuc2Nyb2xsWVxuICAgIHRoaXMud2l0aFBhZ2VMb2FkaW5nKHt0bzogaHJlZiwga2luZDogXCJyZWRpcmVjdFwifSwgZG9uZSA9PiB7XG4gICAgICB0aGlzLnJlcGxhY2VNYWluKGhyZWYsIGZsYXNoLCAoKSA9PiB7XG4gICAgICAgIEJyb3dzZXIucHVzaFN0YXRlKGxpbmtTdGF0ZSwge3R5cGU6IFwicmVkaXJlY3RcIiwgaWQ6IHRoaXMubWFpbi5pZCwgc2Nyb2xsOiBzY3JvbGx9LCBocmVmKVxuICAgICAgICB0aGlzLnJlZ2lzdGVyTmV3TG9jYXRpb24od2luZG93LmxvY2F0aW9uKVxuICAgICAgICBkb25lKClcbiAgICAgIH0pXG4gICAgfSlcbiAgfVxuXG4gIHJlcGxhY2VSb290SGlzdG9yeSgpe1xuICAgIEJyb3dzZXIucHVzaFN0YXRlKFwicmVwbGFjZVwiLCB7cm9vdDogdHJ1ZSwgdHlwZTogXCJwYXRjaFwiLCBpZDogdGhpcy5tYWluLmlkfSlcbiAgfVxuXG4gIHJlZ2lzdGVyTmV3TG9jYXRpb24obmV3TG9jYXRpb24pe1xuICAgIGxldCB7cGF0aG5hbWUsIHNlYXJjaH0gPSB0aGlzLmN1cnJlbnRMb2NhdGlvblxuICAgIGlmKHBhdGhuYW1lICsgc2VhcmNoID09PSBuZXdMb2NhdGlvbi5wYXRobmFtZSArIG5ld0xvY2F0aW9uLnNlYXJjaCl7XG4gICAgICByZXR1cm4gZmFsc2VcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5jdXJyZW50TG9jYXRpb24gPSBjbG9uZShuZXdMb2NhdGlvbilcbiAgICAgIHJldHVybiB0cnVlXG4gICAgfVxuICB9XG5cbiAgYmluZEZvcm1zKCl7XG4gICAgbGV0IGl0ZXJhdGlvbnMgPSAwXG4gICAgbGV0IGV4dGVybmFsRm9ybVN1Ym1pdHRlZCA9IGZhbHNlXG5cbiAgICAvLyBkaXNhYmxlIGZvcm1zIG9uIHN1Ym1pdCB0aGF0IHRyYWNrIHBoeC1jaGFuZ2UgYnV0IHBlcmZvcm0gZXh0ZXJuYWwgc3VibWl0XG4gICAgdGhpcy5vbihcInN1Ym1pdFwiLCBlID0+IHtcbiAgICAgIGxldCBwaHhTdWJtaXQgPSBlLnRhcmdldC5nZXRBdHRyaWJ1dGUodGhpcy5iaW5kaW5nKFwic3VibWl0XCIpKVxuICAgICAgbGV0IHBoeENoYW5nZSA9IGUudGFyZ2V0LmdldEF0dHJpYnV0ZSh0aGlzLmJpbmRpbmcoXCJjaGFuZ2VcIikpXG4gICAgICBpZighZXh0ZXJuYWxGb3JtU3VibWl0dGVkICYmIHBoeENoYW5nZSAmJiAhcGh4U3VibWl0KXtcbiAgICAgICAgZXh0ZXJuYWxGb3JtU3VibWl0dGVkID0gdHJ1ZVxuICAgICAgICBlLnByZXZlbnREZWZhdWx0KClcbiAgICAgICAgdGhpcy53aXRoaW5Pd25lcnMoZS50YXJnZXQsIHZpZXcgPT4ge1xuICAgICAgICAgIHZpZXcuZGlzYWJsZUZvcm0oZS50YXJnZXQpXG4gICAgICAgICAgLy8gc2FmYXJpIG5lZWRzIG5leHQgdGlja1xuICAgICAgICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUoKCkgPT4ge1xuICAgICAgICAgICAgaWYoRE9NLmlzVW5sb2FkYWJsZUZvcm1TdWJtaXQoZSkpeyB0aGlzLnVubG9hZCgpIH1cbiAgICAgICAgICAgIGUudGFyZ2V0LnN1Ym1pdCgpXG4gICAgICAgICAgfSlcbiAgICAgICAgfSlcbiAgICAgIH1cbiAgICB9LCB0cnVlKVxuXG4gICAgdGhpcy5vbihcInN1Ym1pdFwiLCBlID0+IHtcbiAgICAgIGxldCBwaHhFdmVudCA9IGUudGFyZ2V0LmdldEF0dHJpYnV0ZSh0aGlzLmJpbmRpbmcoXCJzdWJtaXRcIikpXG4gICAgICBpZighcGh4RXZlbnQpe1xuICAgICAgICBpZihET00uaXNVbmxvYWRhYmxlRm9ybVN1Ym1pdChlKSl7IHRoaXMudW5sb2FkKCkgfVxuICAgICAgICByZXR1cm5cbiAgICAgIH1cbiAgICAgIGUucHJldmVudERlZmF1bHQoKVxuICAgICAgZS50YXJnZXQuZGlzYWJsZWQgPSB0cnVlXG4gICAgICB0aGlzLndpdGhpbk93bmVycyhlLnRhcmdldCwgdmlldyA9PiB7XG4gICAgICAgIEpTLmV4ZWMoXCJzdWJtaXRcIiwgcGh4RXZlbnQsIHZpZXcsIGUudGFyZ2V0LCBbXCJwdXNoXCIsIHtzdWJtaXR0ZXI6IGUuc3VibWl0dGVyfV0pXG4gICAgICB9KVxuICAgIH0sIGZhbHNlKVxuXG4gICAgZm9yKGxldCB0eXBlIG9mIFtcImNoYW5nZVwiLCBcImlucHV0XCJdKXtcbiAgICAgIHRoaXMub24odHlwZSwgZSA9PiB7XG4gICAgICAgIGxldCBwaHhDaGFuZ2UgPSB0aGlzLmJpbmRpbmcoXCJjaGFuZ2VcIilcbiAgICAgICAgbGV0IGlucHV0ID0gZS50YXJnZXRcbiAgICAgICAgbGV0IGlucHV0RXZlbnQgPSBpbnB1dC5nZXRBdHRyaWJ1dGUocGh4Q2hhbmdlKVxuICAgICAgICBsZXQgZm9ybUV2ZW50ID0gaW5wdXQuZm9ybSAmJiBpbnB1dC5mb3JtLmdldEF0dHJpYnV0ZShwaHhDaGFuZ2UpXG4gICAgICAgIGxldCBwaHhFdmVudCA9IGlucHV0RXZlbnQgfHwgZm9ybUV2ZW50XG4gICAgICAgIGlmKCFwaHhFdmVudCl7IHJldHVybiB9XG4gICAgICAgIGlmKGlucHV0LnR5cGUgPT09IFwibnVtYmVyXCIgJiYgaW5wdXQudmFsaWRpdHkgJiYgaW5wdXQudmFsaWRpdHkuYmFkSW5wdXQpeyByZXR1cm4gfVxuXG4gICAgICAgIGxldCBkaXNwYXRjaGVyID0gaW5wdXRFdmVudCA/IGlucHV0IDogaW5wdXQuZm9ybVxuICAgICAgICBsZXQgY3VycmVudEl0ZXJhdGlvbnMgPSBpdGVyYXRpb25zXG4gICAgICAgIGl0ZXJhdGlvbnMrK1xuICAgICAgICBsZXQge2F0OiBhdCwgdHlwZTogbGFzdFR5cGV9ID0gRE9NLnByaXZhdGUoaW5wdXQsIFwicHJldi1pdGVyYXRpb25cIikgfHwge31cbiAgICAgICAgLy8gZGV0ZWN0IGR1cCBiZWNhdXNlIHNvbWUgYnJvd3NlcnMgZGlzcGF0Y2ggYm90aCBcImlucHV0XCIgYW5kIFwiY2hhbmdlXCJcbiAgICAgICAgaWYoYXQgPT09IGN1cnJlbnRJdGVyYXRpb25zIC0gMSAmJiB0eXBlICE9PSBsYXN0VHlwZSl7IHJldHVybiB9XG5cbiAgICAgICAgRE9NLnB1dFByaXZhdGUoaW5wdXQsIFwicHJldi1pdGVyYXRpb25cIiwge2F0OiBjdXJyZW50SXRlcmF0aW9ucywgdHlwZTogdHlwZX0pXG5cbiAgICAgICAgdGhpcy5kZWJvdW5jZShpbnB1dCwgZSwgdHlwZSwgKCkgPT4ge1xuICAgICAgICAgIHRoaXMud2l0aGluT3duZXJzKGRpc3BhdGNoZXIsIHZpZXcgPT4ge1xuICAgICAgICAgICAgRE9NLnB1dFByaXZhdGUoaW5wdXQsIFBIWF9IQVNfRk9DVVNFRCwgdHJ1ZSlcbiAgICAgICAgICAgIGlmKCFET00uaXNUZXh0dWFsSW5wdXQoaW5wdXQpKXtcbiAgICAgICAgICAgICAgdGhpcy5zZXRBY3RpdmVFbGVtZW50KGlucHV0KVxuICAgICAgICAgICAgfVxuICAgICAgICAgICAgSlMuZXhlYyhcImNoYW5nZVwiLCBwaHhFdmVudCwgdmlldywgaW5wdXQsIFtcInB1c2hcIiwge190YXJnZXQ6IGUudGFyZ2V0Lm5hbWUsIGRpc3BhdGNoZXI6IGRpc3BhdGNoZXJ9XSlcbiAgICAgICAgICB9KVxuICAgICAgICB9KVxuICAgICAgfSwgZmFsc2UpXG4gICAgfVxuICAgIHRoaXMub24oXCJyZXNldFwiLCAoZSkgPT4ge1xuICAgICAgbGV0IGZvcm0gPSBlLnRhcmdldFxuICAgICAgRE9NLnJlc2V0Rm9ybShmb3JtLCB0aGlzLmJpbmRpbmcoUEhYX0ZFRURCQUNLX0ZPUikpXG4gICAgICBsZXQgaW5wdXQgPSBBcnJheS5mcm9tKGZvcm0uZWxlbWVudHMpLmZpbmQoZWwgPT4gZWwudHlwZSA9PT0gXCJyZXNldFwiKVxuICAgICAgLy8gd2FpdCB1bnRpbCBuZXh0IHRpY2sgdG8gZ2V0IHVwZGF0ZWQgaW5wdXQgdmFsdWVcbiAgICAgIHdpbmRvdy5yZXF1ZXN0QW5pbWF0aW9uRnJhbWUoKCkgPT4ge1xuICAgICAgICBpbnB1dC5kaXNwYXRjaEV2ZW50KG5ldyBFdmVudChcImlucHV0XCIsIHtidWJibGVzOiB0cnVlLCBjYW5jZWxhYmxlOiBmYWxzZX0pKVxuICAgICAgfSlcbiAgICB9KVxuICB9XG5cbiAgZGVib3VuY2UoZWwsIGV2ZW50LCBldmVudFR5cGUsIGNhbGxiYWNrKXtcbiAgICBpZihldmVudFR5cGUgPT09IFwiYmx1clwiIHx8IGV2ZW50VHlwZSA9PT0gXCJmb2N1c291dFwiKXsgcmV0dXJuIGNhbGxiYWNrKCkgfVxuXG4gICAgbGV0IHBoeERlYm91bmNlID0gdGhpcy5iaW5kaW5nKFBIWF9ERUJPVU5DRSlcbiAgICBsZXQgcGh4VGhyb3R0bGUgPSB0aGlzLmJpbmRpbmcoUEhYX1RIUk9UVExFKVxuICAgIGxldCBkZWZhdWx0RGVib3VuY2UgPSB0aGlzLmRlZmF1bHRzLmRlYm91bmNlLnRvU3RyaW5nKClcbiAgICBsZXQgZGVmYXVsdFRocm90dGxlID0gdGhpcy5kZWZhdWx0cy50aHJvdHRsZS50b1N0cmluZygpXG5cbiAgICB0aGlzLndpdGhpbk93bmVycyhlbCwgdmlldyA9PiB7XG4gICAgICBsZXQgYXN5bmNGaWx0ZXIgPSAoKSA9PiAhdmlldy5pc0Rlc3Ryb3llZCgpICYmIGRvY3VtZW50LmJvZHkuY29udGFpbnMoZWwpXG4gICAgICBET00uZGVib3VuY2UoZWwsIGV2ZW50LCBwaHhEZWJvdW5jZSwgZGVmYXVsdERlYm91bmNlLCBwaHhUaHJvdHRsZSwgZGVmYXVsdFRocm90dGxlLCBhc3luY0ZpbHRlciwgKCkgPT4ge1xuICAgICAgICBjYWxsYmFjaygpXG4gICAgICB9KVxuICAgIH0pXG4gIH1cblxuICBzaWxlbmNlRXZlbnRzKGNhbGxiYWNrKXtcbiAgICB0aGlzLnNpbGVuY2VkID0gdHJ1ZVxuICAgIGNhbGxiYWNrKClcbiAgICB0aGlzLnNpbGVuY2VkID0gZmFsc2VcbiAgfVxuXG4gIG9uKGV2ZW50LCBjYWxsYmFjayl7XG4gICAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoZXZlbnQsIGUgPT4ge1xuICAgICAgaWYoIXRoaXMuc2lsZW5jZWQpeyBjYWxsYmFjayhlKSB9XG4gICAgfSlcbiAgfVxufVxuXG5jbGFzcyBUcmFuc2l0aW9uU2V0IHtcbiAgY29uc3RydWN0b3IoKXtcbiAgICB0aGlzLnRyYW5zaXRpb25zID0gbmV3IFNldCgpXG4gICAgdGhpcy5wZW5kaW5nT3BzID0gW11cbiAgfVxuXG4gIHJlc2V0KCl7XG4gICAgdGhpcy50cmFuc2l0aW9ucy5mb3JFYWNoKHRpbWVyID0+IHtcbiAgICAgIGNsZWFyVGltZW91dCh0aW1lcilcbiAgICAgIHRoaXMudHJhbnNpdGlvbnMuZGVsZXRlKHRpbWVyKVxuICAgIH0pXG4gICAgdGhpcy5mbHVzaFBlbmRpbmdPcHMoKVxuICB9XG5cbiAgYWZ0ZXIoY2FsbGJhY2spe1xuICAgIGlmKHRoaXMuc2l6ZSgpID09PSAwKXtcbiAgICAgIGNhbGxiYWNrKClcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5wdXNoUGVuZGluZ09wKGNhbGxiYWNrKVxuICAgIH1cbiAgfVxuXG4gIGFkZFRyYW5zaXRpb24odGltZSwgb25TdGFydCwgb25Eb25lKXtcbiAgICBvblN0YXJ0KClcbiAgICBsZXQgdGltZXIgPSBzZXRUaW1lb3V0KCgpID0+IHtcbiAgICAgIHRoaXMudHJhbnNpdGlvbnMuZGVsZXRlKHRpbWVyKVxuICAgICAgb25Eb25lKClcbiAgICAgIHRoaXMuZmx1c2hQZW5kaW5nT3BzKClcbiAgICB9LCB0aW1lKVxuICAgIHRoaXMudHJhbnNpdGlvbnMuYWRkKHRpbWVyKVxuICB9XG5cbiAgcHVzaFBlbmRpbmdPcChvcCl7IHRoaXMucGVuZGluZ09wcy5wdXNoKG9wKSB9XG5cbiAgc2l6ZSgpeyByZXR1cm4gdGhpcy50cmFuc2l0aW9ucy5zaXplIH1cblxuICBmbHVzaFBlbmRpbmdPcHMoKXtcbiAgICBpZih0aGlzLnNpemUoKSA+IDApeyByZXR1cm4gfVxuICAgIGxldCBvcCA9IHRoaXMucGVuZGluZ09wcy5zaGlmdCgpXG4gICAgaWYob3Ape1xuICAgICAgb3AoKVxuICAgICAgdGhpcy5mbHVzaFBlbmRpbmdPcHMoKVxuICAgIH1cbiAgfVxufVxuIiwgIi8vIFdlIGltcG9ydCB0aGUgQ1NTIHdoaWNoIGlzIGV4dHJhY3RlZCB0byBpdHMgb3duIGZpbGUgYnkgZXNidWlsZC5cbi8vIFJlbW92ZSB0aGlzIGxpbmUgaWYgeW91IGFkZCBhIHlvdXIgb3duIENTUyBidWlsZCBwaXBlbGluZSAoZS5nIHBvc3Rjc3MpLlxuXG4vLyBJZiB5b3Ugd2FudCB0byB1c2UgUGhvZW5peCBjaGFubmVscywgcnVuIGBtaXggaGVscCBwaHguZ2VuLmNoYW5uZWxgXG4vLyB0byBnZXQgc3RhcnRlZCBhbmQgdGhlbiB1bmNvbW1lbnQgdGhlIGxpbmUgYmVsb3cuXG4vLyBpbXBvcnQgXCIuL3VzZXJfc29ja2V0LmpzXCJcblxuLy8gWW91IGNhbiBpbmNsdWRlIGRlcGVuZGVuY2llcyBpbiB0d28gd2F5cy5cbi8vXG4vLyBUaGUgc2ltcGxlc3Qgb3B0aW9uIGlzIHRvIHB1dCB0aGVtIGluIGFzc2V0cy92ZW5kb3IgYW5kXG4vLyBpbXBvcnQgdGhlbSB1c2luZyByZWxhdGl2ZSBwYXRoczpcbi8vXG4vLyAgICAgaW1wb3J0IFwiLi4vdmVuZG9yL3NvbWUtcGFja2FnZS5qc1wiXG4vL1xuLy8gQWx0ZXJuYXRpdmVseSwgeW91IGNhbiBgbnBtIGluc3RhbGwgc29tZS1wYWNrYWdlIC0tcHJlZml4IGFzc2V0c2AgYW5kIGltcG9ydFxuLy8gdGhlbSB1c2luZyBhIHBhdGggc3RhcnRpbmcgd2l0aCB0aGUgcGFja2FnZSBuYW1lOlxuLy9cbi8vICAgICBpbXBvcnQgXCJzb21lLXBhY2thZ2VcIlxuLy9cblxuLy8gSW5jbHVkZSBwaG9lbml4X2h0bWwgdG8gaGFuZGxlIG1ldGhvZD1QVVQvREVMRVRFIGluIGZvcm1zIGFuZCBidXR0b25zLlxuaW1wb3J0ICdwaG9lbml4X2h0bWwnO1xuLy8gRXN0YWJsaXNoIFBob2VuaXggU29ja2V0IGFuZCBMaXZlVmlldyBjb25maWd1cmF0aW9uLlxuaW1wb3J0IHsgU29ja2V0IH0gZnJvbSAncGhvZW5peCc7XG5pbXBvcnQgeyBMaXZlU29ja2V0IH0gZnJvbSAncGhvZW5peF9saXZlX3ZpZXcnO1xuXG5pbXBvcnQgdG9wYmFyIGZyb20gJy4uL3ZlbmRvci90b3BiYXInO1xuaW1wb3J0IEpvYkVkaXRvciBmcm9tICcuL2pvYi1lZGl0b3InO1xuaW1wb3J0IFdvcmtmbG93RGlhZ3JhbSBmcm9tICcuL3dvcmtmbG93LWRpYWdyYW0nO1xuaW1wb3J0IFdvcmtmbG93RWRpdG9yIGZyb20gJy4vd29ya2Zsb3ctZWRpdG9yJztcbmltcG9ydCBUYWJTZWxlY3RvciBmcm9tICcuL3RhYi1zZWxlY3Rvcic7XG5pbXBvcnQgSm9iRWRpdG9yUmVzaXplciBmcm9tICcuL2pvYi1lZGl0b3ItcmVzaXplci9tb3VudCc7XG5cbmxldCBIb29rcyA9IHtcbiAgV29ya2Zsb3dEaWFncmFtLFxuICBUYWJTZWxlY3RvcixcbiAgSm9iRWRpdG9yLFxuICBKb2JFZGl0b3JSZXNpemVyLFxuICBXb3JrZmxvd0VkaXRvcixcbn07XG5cbkhvb2tzLkZsYXNoID0ge1xuICBtb3VudGVkKCkge1xuICAgIGxldCBoaWRlID0gKCkgPT5cbiAgICAgIGxpdmVTb2NrZXQuZXhlY0pTKHRoaXMuZWwsIHRoaXMuZWwuZ2V0QXR0cmlidXRlKCdwaHgtY2xpY2snKSk7XG4gICAgdGhpcy50aW1lciA9IHNldFRpbWVvdXQoKCkgPT4gaGlkZSgpLCA1MDAwKTtcbiAgICB0aGlzLmVsLmFkZEV2ZW50TGlzdGVuZXIoJ3BoeDpoaWRlLXN0YXJ0JywgKCkgPT4gY2xlYXJUaW1lb3V0KHRoaXMudGltZXIpKTtcbiAgICB0aGlzLmVsLmFkZEV2ZW50TGlzdGVuZXIoJ21vdXNlb3ZlcicsICgpID0+IHtcbiAgICAgIGNsZWFyVGltZW91dCh0aGlzLnRpbWVyKTtcbiAgICAgIHRoaXMudGltZXIgPSBzZXRUaW1lb3V0KCgpID0+IGhpZGUoKSwgNTAwMCk7XG4gICAgfSk7XG4gIH0sXG4gIGRlc3Ryb3llZCgpIHtcbiAgICBjbGVhclRpbWVvdXQodGhpcy50aW1lcik7XG4gIH0sXG59O1xuSG9va3MuQXNzb2NMaXN0Q2hhbmdlID0ge1xuICBtb3VudGVkKCkge1xuICAgIHRoaXMuZWwuYWRkRXZlbnRMaXN0ZW5lcignY2hhbmdlJywgX2V2ZW50ID0+IHtcbiAgICAgIHRoaXMucHVzaEV2ZW50VG8odGhpcy5lbCwgJ3NlbGVjdF9pdGVtJywgeyBpZDogdGhpcy5lbC52YWx1ZSB9KTtcbiAgICB9KTtcbiAgfSxcbn07XG5cbkhvb2tzLkNvcHkgPSB7XG4gIG1vdW50ZWQoKSB7XG4gICAgbGV0IHsgdG8gfSA9IHRoaXMuZWwuZGF0YXNldDtcbiAgICB0aGlzLmVsLmFkZEV2ZW50TGlzdGVuZXIoJ2NsaWNrJywgZXYgPT4ge1xuICAgICAgZXYucHJldmVudERlZmF1bHQoKTtcbiAgICAgIGxldCB0ZXh0ID0gZG9jdW1lbnQucXVlcnlTZWxlY3Rvcih0bykudmFsdWU7XG4gICAgICBuYXZpZ2F0b3IuY2xpcGJvYXJkLndyaXRlVGV4dCh0ZXh0KS50aGVuKCgpID0+IHtcbiAgICAgICAgY29uc29sZS5sb2coJ0NvcGllZCEnKTtcbiAgICAgIH0pO1xuICAgIH0pO1xuICB9LFxufTtcblxuLy8gU2V0cyB0aGUgY2hlY2tib3ggdG8gaW5kZXRlcm1pbmF0ZSBzdGF0ZSBpZiB0aGUgZWxlbWVudCBoYXMgdGhlXG4vLyBgaW5kZXRlcm1pbmF0ZWAgY2xhc3Ncbkhvb2tzLkNoZWNrYm94SW5kZXRlcm1pbmF0ZSA9IHtcbiAgbW91bnRlZCgpIHtcbiAgICB0aGlzLmVsLmluZGV0ZXJtaW5hdGUgPSB0aGlzLmVsLmNsYXNzTGlzdC5jb250YWlucygnaW5kZXRlcm1pbmF0ZScpO1xuICB9LFxuICB1cGRhdGVkKCkge1xuICAgIHRoaXMuZWwuaW5kZXRlcm1pbmF0ZSA9IHRoaXMuZWwuY2xhc3NMaXN0LmNvbnRhaW5zKCdpbmRldGVybWluYXRlJyk7XG4gIH0sXG59O1xuXG4vLyBAdHMtaWdub3JlXG5sZXQgY3NyZlRva2VuID0gZG9jdW1lbnRcbiAgLnF1ZXJ5U2VsZWN0b3IoXCJtZXRhW25hbWU9J2NzcmYtdG9rZW4nXVwiKVxuICAuZ2V0QXR0cmlidXRlKCdjb250ZW50Jyk7XG5cbmxldCBsaXZlU29ja2V0ID0gbmV3IExpdmVTb2NrZXQoJy9saXZlJywgU29ja2V0LCB7XG4gIHBhcmFtczogeyBfY3NyZl90b2tlbjogY3NyZlRva2VuIH0sXG4gIGhvb2tzOiBIb29rcyxcbiAgZG9tOiB7XG4gICAgb25CZWZvcmVFbFVwZGF0ZWQoZnJvbSwgdG8pIHtcbiAgICAgIC8vIElmIGFuIGVsZW1lbnQgaGFzIGFueSBvZiB0aGUgJ2x2LWtlZXAtKicgYXR0cmlidXRlcywgY29weSBhY3Jvc3NcbiAgICAgIC8vIHRoZSBnaXZlbiBhdHRyaWJ1dGUgdG8gbWFpbnRhaW4gdmFyaW91cyBzdHlsZXMgYW5kIHByb3BlcnRpZXNcbiAgICAgIC8vIHRoYXQgaGF2ZSBoYWQgdGhlaXIgY29udHJvbCBoYW5kZWQtb3ZlciB0byBhIEhvb2sgb3IgSlMgaW1wbGVtZW50YXRpb24uXG4gICAgICBpZiAoZnJvbS5hdHRyaWJ1dGVzWydsdi1rZWVwLXN0eWxlJ10pIHtcbiAgICAgICAgdG8uc2V0QXR0cmlidXRlKCdzdHlsZScsIGZyb20uYXR0cmlidXRlcy5zdHlsZS52YWx1ZSk7XG4gICAgICB9XG5cbiAgICAgIGlmIChmcm9tLmF0dHJpYnV0ZXNbJ2x2LWtlZXAtY2xhc3MnXSkge1xuICAgICAgICB0by5zZXRBdHRyaWJ1dGUoJ2NsYXNzJywgZnJvbS5hdHRyaWJ1dGVzLmNsYXNzLnZhbHVlKTtcbiAgICAgIH1cbiAgICB9LFxuICB9LFxufSk7XG5cbi8vIFNob3cgcHJvZ3Jlc3MgYmFyIG9uIGxpdmUgbmF2aWdhdGlvbiBhbmQgZm9ybSBzdWJtaXRzXG4vLyBJbmNsdWRlIGEgMTIwbXMgdGltZW91dCB0byBhdm9pZCBzbWFsbCBmbGFzaGVzIHdoZW4gdGhpbmdzIGxvYWQgcXVpY2tseS5cbnRvcGJhci5jb25maWcoeyBiYXJDb2xvcnM6IHsgMDogJyMyOWQnIH0sIHNoYWRvd0NvbG9yOiAncmdiYSgwLCAwLCAwLCAuMyknIH0pO1xuXG5sZXQgdG9wQmFyU2NoZWR1bGVkID0gdW5kZWZpbmVkO1xuXG53aW5kb3cuYWRkRXZlbnRMaXN0ZW5lcigncGh4OnBhZ2UtbG9hZGluZy1zdGFydCcsICgpID0+IHtcbiAgaWYgKCF0b3BCYXJTY2hlZHVsZWQpIHtcbiAgICB0b3BCYXJTY2hlZHVsZWQgPSBzZXRUaW1lb3V0KCgpID0+IHRvcGJhci5zaG93KCksIDEyMCk7XG4gIH1cbn0pO1xuXG53aW5kb3cuYWRkRXZlbnRMaXN0ZW5lcigncGh4OnBhZ2UtbG9hZGluZy1zdG9wJywgKCkgPT4ge1xuICBjbGVhclRpbWVvdXQodG9wQmFyU2NoZWR1bGVkKTtcbiAgdG9wQmFyU2NoZWR1bGVkID0gdW5kZWZpbmVkO1xuICB0b3BiYXIuaGlkZSgpO1xufSk7XG5cbndpbmRvdy5hZGRFdmVudExpc3RlbmVyKCdrZXlkb3duJywgZXZlbnQgPT4ge1xuICBjb25zdCBjdXJyZW50VVJMID0gd2luZG93LmxvY2F0aW9uLnBhdGhuYW1lO1xuICBjb25zdCBlZGl0X2pvYl91cmwgPSAvXFwvcHJvamVjdHNcXC8oLispXFwvd1xcLyguKylcXC9qXFwvKC4rKS87XG4gIGlmICgoZXZlbnQuY3RybEtleSB8fCBldmVudC5tZXRhS2V5KSAmJiBldmVudC5rZXkgPT09ICdzJykge1xuICAgIGlmIChlZGl0X2pvYl91cmwudGVzdChjdXJyZW50VVJMKSkge1xuICAgICAgZXZlbnQucHJldmVudERlZmF1bHQoKTtcbiAgICAgIGNvbnNvbGUubG9nKCdTYXZpbmcgdGhlIGpvYicpO1xuICAgICAgbGV0IGZvcm0gPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKFwiYnV0dG9uW2Zvcm09J2pvYi1mb3JtJ11cIik7XG4gICAgICBmb3JtLmNsaWNrKCk7XG4gICAgfVxuICB9XG59KTtcblxuLy8gY29ubmVjdCBpZiB0aGVyZSBhcmUgYW55IExpdmVWaWV3cyBvbiB0aGUgcGFnZVxubGl2ZVNvY2tldC5jb25uZWN0KCk7XG4vLyBleHBvc2UgbGl2ZVNvY2tldCBvbiB3aW5kb3cgZm9yIHdlYiBjb25zb2xlIGRlYnVnIGxvZ3MgYW5kIGxhdGVuY3kgc2ltdWxhdGlvbjpcbi8vID4+IGxpdmVTb2NrZXQuZW5hYmxlRGVidWcoKVxuLy8gPj4gbGl2ZVNvY2tldC5lbmFibGVMYXRlbmN5U2ltKDEwMDApICAvLyBlbmFibGVkIGZvciBkdXJhdGlvbiBvZiBicm93c2VyIHNlc3Npb25cbi8vID4+IGxpdmVTb2NrZXQuZGlzYWJsZUxhdGVuY3lTaW0oKVxud2luZG93LmxpdmVTb2NrZXQgPSBsaXZlU29ja2V0O1xuIiwgImltcG9ydCBSZWFjdCBmcm9tICdyZWFjdCc7XG5pbXBvcnQgeyBjcmVhdGVSb290IH0gZnJvbSAncmVhY3QtZG9tL2NsaWVudCc7XG5pbXBvcnQgdHlwZSBKb2JFZGl0b3IgZnJvbSAnLi9Kb2JFZGl0b3InO1xuaW1wb3J0IHsgc29ydE1ldGFkYXRhIH0gZnJvbSAnLi4vbWV0YWRhdGEtbG9hZGVyL21ldGFkYXRhJztcblxuLy8gVE9ETyBuZWVkcyByZW9yZ2FuaXNpbmdcbmludGVyZmFjZSBWaWV3SG9vayB7XG4gIGRlc3Ryb3llZCgpOiB2b2lkO1xuICBlbDogSFRNTEVsZW1lbnQ7XG4gIHB1c2hFdmVudFRvKFxuICAgIHRhcmdldDogSFRNTEVsZW1lbnQsXG4gICAgZXZlbnQ6IHN0cmluZyxcbiAgICBwYXlsb2FkOiB7fSxcbiAgICBjYWxsYmFjaz86IChyZXBseToge30sIHJlZjogdW5rbm93bikgPT4gdm9pZFxuICApOiB2b2lkO1xuICBoYW5kbGVFdmVudChldmVudDogc3RyaW5nLCBjYWxsYmFjazogKHJlcGx5OiB7fSkgPT4gdm9pZCk6IHVua25vd247XG4gIHJlbW92ZUhhbmRsZUV2ZW50KGNhbGxiYWNrUmVmOiB1bmtub3duKTogdm9pZDtcbiAgbW91bnRlZCgpOiB2b2lkO1xufVxuXG5cbmludGVyZmFjZSBKb2JFZGl0b3JFbnRyeXBvaW50IGV4dGVuZHMgVmlld0hvb2sge1xuICBjb21wb25lbnRSb290OiBSZXR1cm5UeXBlPHR5cGVvZiBjcmVhdGVSb290PiB8IG51bGw7XG4gIGNoYW5nZUV2ZW50OiBzdHJpbmc7XG4gIGZpZWxkPzogSFRNTFRleHRBcmVhRWxlbWVudCB8IG51bGw7XG4gIGhhbmRsZUNvbnRlbnRDaGFuZ2UoY29udGVudDogc3RyaW5nKTogdm9pZDtcbiAgbWV0YWRhdGE/OiB0cnVlIHwgb2JqZWN0O1xuICBvYnNlcnZlcjogTXV0YXRpb25PYnNlcnZlciB8IG51bGw7XG4gIHJlbmRlcigpOiB2b2lkO1xuICByZXF1ZXN0TWV0YWRhdGEoKTogUHJvbWlzZTx7fT47XG4gIHNldHVwT2JzZXJ2ZXIoKTogdm9pZDtcbiAgcmVtb3ZlSGFuZGxlRXZlbnQoY2FsbGJhY2tSZWY6IHVua25vd24pOiB2b2lkO1xufVxuXG50eXBlIEF0dHJpYnV0ZU11dGF0aW9uUmVjb3JkID0gTXV0YXRpb25SZWNvcmQgJiB7XG4gIGF0dHJpYnV0ZU5hbWU6IHN0cmluZztcbiAgb2xkVmFsdWU6IHN0cmluZztcbn07XG5cbmxldCBKb2JFZGl0b3JDb21wb25lbnQ6IHR5cGVvZiBKb2JFZGl0b3IgfCB1bmRlZmluZWQ7XG5cblxuZXhwb3J0IGRlZmF1bHQge1xuXG4gIG1vdW50ZWQodGhpczogSm9iRWRpdG9yRW50cnlwb2ludCkge1xuICAgIGltcG9ydCgnLi9Kb2JFZGl0b3InKS50aGVuKG1vZHVsZSA9PiB7XG4gICAgICBKb2JFZGl0b3JDb21wb25lbnQgPSBtb2R1bGUuZGVmYXVsdCBhcyB0eXBlb2YgSm9iRWRpdG9yO1xuICAgICAgdGhpcy5jb21wb25lbnRSb290ID0gY3JlYXRlUm9vdCh0aGlzLmVsKTtcblxuICAgICAgY29uc3QgeyBjaGFuZ2VFdmVudCB9ID0gdGhpcy5lbC5kYXRhc2V0O1xuICAgICAgaWYgKGNoYW5nZUV2ZW50KSB7XG4gICAgICAgIHRoaXMuY2hhbmdlRXZlbnQgPSBjaGFuZ2VFdmVudDtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGNvbnNvbGUud2FybignV2FybmluZzogTm8gY2hhbmdlRXZlbnQgc2V0LiBDb250ZW50IHdpbGwgbm90IHN5bmMuJyk7XG4gICAgICB9XG4gICAgICB0aGlzLnNldHVwT2JzZXJ2ZXIoKTtcbiAgICAgIHRoaXMucmVuZGVyKCk7XG4gICAgICB0aGlzLnJlcXVlc3RNZXRhZGF0YSgpLnRoZW4oKCkgPT4gdGhpcy5yZW5kZXIoKSlcbiAgICB9KTtcbiAgfSxcbiAgaGFuZGxlQ29udGVudENoYW5nZShjb250ZW50OiBzdHJpbmcpIHtcbiAgICB0aGlzLnB1c2hFdmVudFRvKHRoaXMuZWwsIHRoaXMuY2hhbmdlRXZlbnQsIHsgc291cmNlOiBjb250ZW50IH0pO1xuICB9LFxuICByZW5kZXIoKSB7XG4gICAgY29uc3QgeyBhZGFwdG9yLCBzb3VyY2UsIGRpc2FibGVkIH0gPSB0aGlzLmVsLmRhdGFzZXQ7XG4gICAgaWYgKEpvYkVkaXRvckNvbXBvbmVudCkge1xuICAgICAgdGhpcy5jb21wb25lbnRSb290Py5yZW5kZXIoXG4gICAgICAgIDxKb2JFZGl0b3JDb21wb25lbnRcbiAgICAgICAgICBhZGFwdG9yPXthZGFwdG9yfVxuICAgICAgICAgIHNvdXJjZT17c291cmNlfVxuICAgICAgICAgIG1ldGFkYXRhPXt0aGlzLm1ldGFkYXRhfVxuICAgICAgICAgIGRpc2FibGVkPXtkaXNhYmxlZD09PVwidHJ1ZVwifVxuICAgICAgICAgIG9uU291cmNlQ2hhbmdlZD17c3JjID0+IHRoaXMuaGFuZGxlQ29udGVudENoYW5nZShzcmMpfVxuICAgICAgICAvPlxuICAgICAgKTtcbiAgICB9XG4gIH0sXG4gIHJlcXVlc3RNZXRhZGF0YSgpIHtcbiAgICB0aGlzLm1ldGFkYXRhID0gdHJ1ZTsgLy8gaW5kaWNhdGUgd2UncmUgbG9hZGluZ1xuICAgIHRoaXMucmVuZGVyKClcbiAgICByZXR1cm4gbmV3IFByb21pc2UocmVzb2x2ZSA9PiB7XG4gICAgICBjb25zdCBjYWxsYmFja1JlZiA9IHRoaXMuaGFuZGxlRXZlbnQoXCJtZXRhZGF0YV9yZWFkeVwiLCBkYXRhID0+IHtcbiAgICAgICAgdGhpcy5yZW1vdmVIYW5kbGVFdmVudChjYWxsYmFja1JlZik7XG4gICAgICAgIGNvbnN0IHNvcnRlZE1ldGFkYXRhID0gc29ydE1ldGFkYXRhKGRhdGEpO1xuICAgICAgICB0aGlzLm1ldGFkYXRhID0gc29ydGVkTWV0YWRhdGFcbiAgICAgICAgcmVzb2x2ZShzb3J0ZWRNZXRhZGF0YSk7XG4gICAgICB9KTtcbiAgICAgIFxuICAgICAgdGhpcy5wdXNoRXZlbnRUbyh0aGlzLmVsLCAncmVxdWVzdF9tZXRhZGF0YScsIHt9KTtcbiAgICB9KTtcbiAgfSxcbiAgc2V0dXBPYnNlcnZlcigpIHtcbiAgICB0aGlzLm9ic2VydmVyID0gbmV3IE11dGF0aW9uT2JzZXJ2ZXIobXV0YXRpb25zID0+IHtcbiAgICAgIG11dGF0aW9ucy5mb3JFYWNoKG11dGF0aW9uID0+IHtcbiAgICAgICAgY29uc3QgeyBhdHRyaWJ1dGVOYW1lLCBvbGRWYWx1ZSB9ID0gbXV0YXRpb24gYXMgQXR0cmlidXRlTXV0YXRpb25SZWNvcmQ7XG4gICAgICAgIGNvbnN0IG5ld1ZhbHVlID0gdGhpcy5lbC5nZXRBdHRyaWJ1dGUoYXR0cmlidXRlTmFtZSk7XG4gICAgICAgIGlmIChvbGRWYWx1ZSAhPT0gbmV3VmFsdWUpIHtcbiAgICAgICAgICB0aGlzLnJlbmRlcigpO1xuICAgICAgICB9XG4gICAgICB9KTtcbiAgICB9KTtcblxuICAgIHRoaXMub2JzZXJ2ZXIub2JzZXJ2ZSh0aGlzLmVsLCB7XG4gICAgICBhdHRyaWJ1dGVGaWx0ZXI6IFsnZGF0YS1hZGFwdG9yJywgJ2RhdGEtY2hhbmdlLWV2ZW50J10sXG4gICAgICBhdHRyaWJ1dGVPbGRWYWx1ZTogdHJ1ZSxcbiAgICB9KTtcbiAgfSxcbiAgZGVzdHJveWVkKCkge1xuICAgIHRoaXMuY29tcG9uZW50Um9vdD8udW5tb3VudCgpO1xuICAgIHRoaXMub2JzZXJ2ZXI/LmRpc2Nvbm5lY3QoKTtcbiAgfSxcbn0gYXMgSm9iRWRpdG9yRW50cnlwb2ludDtcbiIsICIvLyBUT0RPIHNob3VkIG1vZGVscyBiZSBwcmUgc29ydGVkP1xuLy8gTWF5YmUhIEJ1dCBJIGRvbid0IGtub3cgaWYgSSB3YW50IHRvIHJlbHkgb24gdGhhdD9cbmNvbnN0IHNvcnRBcnIgPSAoYXJyOiBhbnlbXSkgPT4ge1xuICBhcnIuc29ydCgoYSwgYikgPT4ge1xuICAgIGNvbnN0IGFzdHIgPSB0eXBlb2YgYSA9PT0gJ3N0cmluZycgPyBhIDogYS5uYW1lO1xuICAgIGNvbnN0IGJzdHIgPSB0eXBlb2YgYiA9PT0gJ3N0cmluZycgPyBiIDogYi5uYW1lO1xuXG4gICAgaWYgKGFzdHIgPT09IGJzdHIpIHJldHVybiAwO1xuICAgIGlmIChhc3RyID4gYnN0cikge1xuICAgICAgcmV0dXJuIDE7XG4gICAgfSBlbHNlIHtcbiAgICAgIHJldHVybiAtMTtcbiAgICB9XG4gIH0pO1xuICByZXR1cm4gYXJyO1xufTtcblxuY29uc3Qgc29ydERlZXAgPSAobW9kZWw6IGFueSkgPT4ge1xuICBpZiAobW9kZWwuY2hpbGRyZW4pIHtcbiAgICBpZiAoQXJyYXkuaXNBcnJheShtb2RlbC5jaGlsZHJlbikpIHtcbiAgICAgIG1vZGVsLmNoaWxkcmVuID0gc29ydEFycihtb2RlbC5jaGlsZHJlbi5tYXAoc29ydERlZXApKTtcbiAgICB9IGVsc2Uge1xuICAgICAgY29uc3Qga2V5cyA9IE9iamVjdC5rZXlzKG1vZGVsLmNoaWxkcmVuKS5zb3J0KCk7XG4gICAgICBtb2RlbC5jaGlsZHJlbiA9IGtleXMucmVkdWNlKChhY2MsIGtleSkgPT4ge1xuICAgICAgICBhY2Nba2V5XSA9IHNvcnRBcnIobW9kZWwuY2hpbGRyZW5ba2V5XS5tYXAoc29ydERlZXApKTtcbiAgICAgICAgcmV0dXJuIGFjYztcbiAgICAgIH0sIHt9KTtcbiAgICB9XG4gIH1cbiAgcmV0dXJuIG1vZGVsO1xufTtcblxuZXhwb3J0IHsgc29ydERlZXAgYXMgc29ydE1ldGFkYXRhIH07XG4iLCAiaW1wb3J0IG1vdW50IGZyb20gJy4vbW91bnQnO1xuXG5leHBvcnQgZGVmYXVsdCBtb3VudDtcbiIsICIvLyBIb29rIGZvciBXb3JrZmxvdyBEaWFncmFtIENvbXBvbmVudFxuLy8gYGNvbXBvbmVudC5qc3hgIGlzIGltcG9ydGVkIGR5bmFtaWNhbGx5LCBzYXZpbmcgbG9hZGluZyBSZWFjdFxuLy8gYW5kIGFsbCB0aGUgb3RoZXIgZGVwZW5kZW5jaWVzIHVudGlsIHRoZXkgYXJlIG5lZWRlZC5cbmltcG9ydCB0eXBlIHsgbW91bnQgfSBmcm9tICcuL2NvbXBvbmVudCc7XG5cbmludGVyZmFjZSBXb3JrZmxvd0RpYWdyYW1FbnRyeXBvaW50IHtcbiAgZWw6IEhUTUxFbGVtZW50O1xuICBjb21wb25lbnQ6IFJldHVyblR5cGU8dHlwZW9mIG1vdW50PiB8IG51bGw7XG4gIGJhc2VVcmw6IFVSTDtcbiAgb2JzZXJ2ZXI6IE11dGF0aW9uT2JzZXJ2ZXIgfCBudWxsO1xuICBwcm9qZWN0U3BhY2U6IHt9IHwgbnVsbDtcbiAgbW91bnRlZCgpOiB2b2lkO1xuICBkZXN0cm95ZWQoKTogdm9pZDtcbiAgaGFuZGxlRXZlbnQoXG4gICAgZXZlbnROYW1lOiBzdHJpbmcsXG4gICAgY2FsbGJhY2s6ICgpID0+IChlOiBzdHJpbmcsIGI6IGJvb2xlYW4pID0+IHZvaWRcbiAgKTogYW55O1xuICBzZXR1cE9ic2VydmVyKCk6IHZvaWQ7XG4gIHVwZGF0ZVByb2plY3RTcGFjZShlbmNvZGVkOiBzdHJpbmcpOiB2b2lkO1xuICBhZGRKb2IodXBzdHJlYW1JZDogc3RyaW5nKTogdm9pZDtcbiAgc2VsZWN0Sm9iKGlkOiBzdHJpbmcpOiB2b2lkO1xuICBzZWxlY3RXb3JrZmxvdyhpZDogc3RyaW5nKTogdm9pZDtcbiAgc2V0U2VsZWN0ZWROb2RlKGlkOiBzdHJpbmcpOiB2b2lkO1xuICBjb3B5V2ViaG9va1VybCh3ZWJob29rVXJsOiBzdHJpbmcpOiB2b2lkO1xuICB1bnNlbGVjdE5vZGUoKTogdm9pZDtcbn1cblxudHlwZSBBdHRyaWJ1dGVNdXRhdGlvblJlY29yZCA9IE11dGF0aW9uUmVjb3JkICYge1xuICBhdHRyaWJ1dGVOYW1lOiBzdHJpbmc7XG4gIG9sZFZhbHVlOiBzdHJpbmc7XG59O1xuXG5leHBvcnQgZGVmYXVsdCB7XG4gIG1vdW50ZWQodGhpczogV29ya2Zsb3dEaWFncmFtRW50cnlwb2ludCkge1xuICAgIGNvbnN0IGJhc2VQYXRoID0gdGhpcy5lbC5nZXRBdHRyaWJ1dGUoJ2Jhc2UtcGF0aCcpO1xuICAgIGlmICghYmFzZVBhdGgpIHtcbiAgICAgIHRocm93IG5ldyBFcnJvcignV29ya2Zsb3cgRGlhZ3JhbSBleHBlY3RzIGEgYGJhc2UtcGF0aGAgYXR0cmlidXRlLicpO1xuICAgIH1cbiAgICB0aGlzLmJhc2VVcmwgPSBuZXcgVVJMKGJhc2VQYXRoLCB3aW5kb3cubG9jYXRpb24ub3JpZ2luKTtcblxuICAgIGltcG9ydCgnLi9jb21wb25lbnQnKS50aGVuKCh7IG1vdW50IH0pID0+IHtcbiAgICAgIHRoaXMuY29tcG9uZW50ID0gbW91bnQodGhpcy5lbCk7XG5cbiAgICAgIHRoaXMuc2V0dXBPYnNlcnZlcigpO1xuXG4gICAgICBpZiAoIXRoaXMuY29tcG9uZW50KSB7XG4gICAgICAgIHRocm93IG5ldyBFcnJvcignQ29tcG9uZW50IG5vdCBzZXQuJyk7XG4gICAgICB9XG5cbiAgICAgIHRoaXMudXBkYXRlUHJvamVjdFNwYWNlKHRoaXMuZWwuZGF0YXNldC5wcm9qZWN0U3BhY2UpO1xuICAgICAgdGhpcy5zZXRTZWxlY3RlZE5vZGUodGhpcy5lbC5kYXRhc2V0LnNlbGVjdGVkTm9kZSk7XG5cbiAgICAgIHRoaXMuY29tcG9uZW50LnVwZGF0ZSh7XG4gICAgICAgIG9uSm9iQWRkQ2xpY2s6IG5vZGUgPT4ge1xuICAgICAgICAgIHRoaXMuYWRkSm9iKG5vZGUuZGF0YS5pZCk7XG4gICAgICAgIH0sXG4gICAgICAgIG9uTm9kZUNsaWNrOiAoZXZlbnQsIG5vZGUpID0+IHtcbiAgICAgICAgICBzd2l0Y2ggKG5vZGUudHlwZSkge1xuICAgICAgICAgICAgY2FzZSAndHJpZ2dlcic6XG4gICAgICAgICAgICAgIGlmIChub2RlLmRhdGEudHJpZ2dlci50eXBlID09PSAnd2ViaG9vaycpIHtcbiAgICAgICAgICAgICAgICB0aGlzLmNvcHlXZWJob29rVXJsKG5vZGUuZGF0YS50cmlnZ2VyLndlYmhvb2tVcmwpO1xuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICAgIGJyZWFrO1xuICAgICAgICAgICAgY2FzZSAnam9iJzpcbiAgICAgICAgICAgICAgdGhpcy5zZWxlY3RKb2Iobm9kZS5kYXRhLmlkKTtcbiAgICAgICAgICAgICAgYnJlYWs7XG5cbiAgICAgICAgICAgIGNhc2UgJ3dvcmtmbG93JzpcbiAgICAgICAgICAgICAgdGhpcy5zZWxlY3RXb3JrZmxvdyhub2RlLmRhdGEuaWQpO1xuICAgICAgICAgICAgICBicmVhaztcbiAgICAgICAgICB9XG4gICAgICAgIH0sXG4gICAgICAgIG9uUGFuZUNsaWNrOiBfZXZlbnQgPT4ge1xuICAgICAgICAgIHRoaXMudW5zZWxlY3ROb2RlKCk7XG4gICAgICAgIH0sXG4gICAgICB9KTtcbiAgICB9KTtcbiAgfSxcbiAgZGVzdHJveWVkKCkge1xuICAgIGNvbnNvbGUuZGVidWcoJ1VubW91bnRpbmcgV29ya2Zsb3dEaWFncmFtIGNvbXBvbmVudCcpO1xuXG4gICAgdGhpcy5vYnNlcnZlcj8uZGlzY29ubmVjdCgpO1xuICAgIHRoaXMuY29tcG9uZW50Py51bm1vdW50KCk7XG4gIH0sXG4gIHNldHVwT2JzZXJ2ZXIoKSB7XG4gICAgdGhpcy5vYnNlcnZlciA9IG5ldyBNdXRhdGlvbk9ic2VydmVyKG11dGF0aW9ucyA9PiB7XG4gICAgICBtdXRhdGlvbnMuZm9yRWFjaChtdXRhdGlvbiA9PiB7XG4gICAgICAgIGNvbnN0IHsgYXR0cmlidXRlTmFtZSwgb2xkVmFsdWUgfSA9IG11dGF0aW9uIGFzIEF0dHJpYnV0ZU11dGF0aW9uUmVjb3JkO1xuICAgICAgICBjb25zdCBuZXdWYWx1ZSA9IHRoaXMuZWwuZ2V0QXR0cmlidXRlKGF0dHJpYnV0ZU5hbWUpO1xuICAgICAgICBpZiAob2xkVmFsdWUgIT09IG5ld1ZhbHVlKSB7XG4gICAgICAgICAgc3dpdGNoIChhdHRyaWJ1dGVOYW1lKSB7XG4gICAgICAgICAgICBjYXNlICdkYXRhLXByb2plY3Qtc3BhY2UnOlxuICAgICAgICAgICAgICB0aGlzLnVwZGF0ZVByb2plY3RTcGFjZShuZXdWYWx1ZSk7XG5cbiAgICAgICAgICAgIGNhc2UgJ2RhdGEtc2VsZWN0ZWQtbm9kZSc6XG4gICAgICAgICAgICAgIHRoaXMuc2V0U2VsZWN0ZWROb2RlKG5ld1ZhbHVlKTtcbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICAgIH0pO1xuICAgIH0pO1xuXG4gICAgdGhpcy5vYnNlcnZlci5vYnNlcnZlKHRoaXMuZWwsIHtcbiAgICAgIGF0dHJpYnV0ZUZpbHRlcjogWydkYXRhLXByb2plY3Qtc3BhY2UnLCAnZGF0YS1zZWxlY3RlZC1ub2RlJ10sXG4gICAgICBhdHRyaWJ1dGVPbGRWYWx1ZTogdHJ1ZSxcbiAgICB9KTtcbiAgfSxcbiAgdXBkYXRlUHJvamVjdFNwYWNlKGVuY29kZWQ6IHN0cmluZykge1xuICAgIHRoaXMuY29tcG9uZW50IS5zZXRQcm9qZWN0U3BhY2UoZW5jb2RlZCk7XG4gIH0sXG4gIHNldFNlbGVjdGVkTm9kZShpZDogc3RyaW5nKSB7XG4gICAgdGhpcy5jb21wb25lbnQhLnNldFNlbGVjdGVkTm9kZShpZCk7XG4gIH0sXG4gIC8vIEFkZCBgai9uZXc/dXBzdHJlYW1faWQ9PGlkPmAgdG8gdGhlIFVSTC5cbiAgYWRkSm9iKHVwc3RyZWFtSWQ6IHN0cmluZykge1xuICAgIGNvbnN0IGFkZEpvYlVybCA9IG5ldyBVUkwodGhpcy5iYXNlVXJsKTtcbiAgICBhZGRKb2JVcmwucGF0aG5hbWUgKz0gJy9qL25ldyc7XG4gICAgYWRkSm9iVXJsLnNlYXJjaCA9IG5ldyBVUkxTZWFyY2hQYXJhbXMoe1xuICAgICAgdXBzdHJlYW1faWQ6IHVwc3RyZWFtSWQsXG4gICAgfSkudG9TdHJpbmcoKTtcbiAgICB0aGlzLmxpdmVTb2NrZXQucHVzaEhpc3RvcnlQYXRjaChhZGRKb2JVcmwudG9TdHJpbmcoKSwgJ3B1c2gnLCB0aGlzLmVsKTtcbiAgfSxcbiAgLy8gQWRkIGBqLzxpZD5gIHRvIHRoZSBVUkwuXG4gIHNlbGVjdEpvYihpZDogc3RyaW5nKSB7XG4gICAgY29uc3Qgc2VsZWN0Sm9iVXJsID0gbmV3IFVSTCh0aGlzLmJhc2VVcmwpO1xuICAgIHNlbGVjdEpvYlVybC5wYXRobmFtZSArPSBgL2ovJHtpZH1gO1xuICAgIHRoaXMubGl2ZVNvY2tldC5wdXNoSGlzdG9yeVBhdGNoKHNlbGVjdEpvYlVybC50b1N0cmluZygpLCAncHVzaCcsIHRoaXMuZWwpO1xuICB9LFxuICAvLyBBZGQgYHcvPGlkPmAgdG8gdGhlIFVSTC5cbiAgc2VsZWN0V29ya2Zsb3coaWQ6IHN0cmluZykge1xuICAgIGNvbnN0IHNlbGVjdFdvcmtmbG93VXJsID0gbmV3IFVSTCh0aGlzLmJhc2VVcmwpO1xuICAgIC8vc2VsZWN0V29ya2Zsb3dVcmwucGF0aG5hbWUgPSBgL3cvJHtpZH1gO1xuICAgIHRoaXMubGl2ZVNvY2tldC5wdXNoSGlzdG9yeVBhdGNoKFxuICAgICAgc2VsZWN0V29ya2Zsb3dVcmwudG9TdHJpbmcoKSxcbiAgICAgICdwdXNoJyxcbiAgICAgIHRoaXMuZWxcbiAgICApO1xuICB9LFxuICBjb3B5V2ViaG9va1VybCh3ZWJob29rVXJsOiBzdHJpbmcpIHtcbiAgICBuYXZpZ2F0b3IuY2xpcGJvYXJkLndyaXRlVGV4dCh3ZWJob29rVXJsKTtcbiAgICB0aGlzLnB1c2hFdmVudCgnY29waWVkX3RvX2NsaXBib2FyZCcsIHt9KTtcbiAgfSxcbiAgLy8gUmVtb3ZlIGA/c2VsZWN0ZWQ9PGlkPmAgZnJvbSB0aGUgVVJMLlxuICB1bnNlbGVjdE5vZGUoKSB7XG4gICAgdGhpcy5saXZlU29ja2V0LnB1c2hIaXN0b3J5UGF0Y2godGhpcy5iYXNlVXJsLnRvU3RyaW5nKCksICdwdXNoJywgdGhpcy5lbCk7XG4gIH0sXG59IGFzIFdvcmtmbG93RGlhZ3JhbUVudHJ5cG9pbnQ7XG4iLCAiLy8gU2hvdWxkIGJlIG5vIGltcG9ydHMgaGVyZSFcblxuLyoqXG4gKiBUaGUgc2VudGluZWwgdmFsdWUgcmV0dXJuZWQgYnkgcHJvZHVjZXJzIHRvIHJlcGxhY2UgdGhlIGRyYWZ0IHdpdGggdW5kZWZpbmVkLlxuICovXG5leHBvcnQgY29uc3QgTk9USElORzogdW5pcXVlIHN5bWJvbCA9IFN5bWJvbC5mb3IoXCJpbW1lci1ub3RoaW5nXCIpXG5cbi8qKlxuICogVG8gbGV0IEltbWVyIHRyZWF0IHlvdXIgY2xhc3MgaW5zdGFuY2VzIGFzIHBsYWluIGltbXV0YWJsZSBvYmplY3RzXG4gKiAoYWxiZWl0IHdpdGggYSBjdXN0b20gcHJvdG90eXBlKSwgeW91IG11c3QgZGVmaW5lIGVpdGhlciBhbiBpbnN0YW5jZSBwcm9wZXJ0eVxuICogb3IgYSBzdGF0aWMgcHJvcGVydHkgb24gZWFjaCBvZiB5b3VyIGN1c3RvbSBjbGFzc2VzLlxuICpcbiAqIE90aGVyd2lzZSwgeW91ciBjbGFzcyBpbnN0YW5jZSB3aWxsIG5ldmVyIGJlIGRyYWZ0ZWQsIHdoaWNoIG1lYW5zIGl0IHdvbid0IGJlXG4gKiBzYWZlIHRvIG11dGF0ZSBpbiBhIHByb2R1Y2UgY2FsbGJhY2suXG4gKi9cbmV4cG9ydCBjb25zdCBEUkFGVEFCTEU6IHVuaXF1ZSBzeW1ib2wgPSBTeW1ib2wuZm9yKFwiaW1tZXItZHJhZnRhYmxlXCIpXG5cbmV4cG9ydCBjb25zdCBEUkFGVF9TVEFURTogdW5pcXVlIHN5bWJvbCA9IFN5bWJvbC5mb3IoXCJpbW1lci1zdGF0ZVwiKVxuIiwgImV4cG9ydCBjb25zdCBlcnJvcnMgPVxuXHRwcm9jZXNzLmVudi5OT0RFX0VOViAhPT0gXCJwcm9kdWN0aW9uXCJcblx0XHQ/IFtcblx0XHRcdFx0Ly8gQWxsIGVycm9yIGNvZGVzLCBzdGFydGluZyBieSAwOlxuXHRcdFx0XHRmdW5jdGlvbihwbHVnaW46IHN0cmluZykge1xuXHRcdFx0XHRcdHJldHVybiBgVGhlIHBsdWdpbiBmb3IgJyR7cGx1Z2lufScgaGFzIG5vdCBiZWVuIGxvYWRlZCBpbnRvIEltbWVyLiBUbyBlbmFibGUgdGhlIHBsdWdpbiwgaW1wb3J0IGFuZCBjYWxsIFxcYGVuYWJsZSR7cGx1Z2lufSgpXFxgIHdoZW4gaW5pdGlhbGl6aW5nIHlvdXIgYXBwbGljYXRpb24uYFxuXHRcdFx0XHR9LFxuXHRcdFx0XHRmdW5jdGlvbih0aGluZzogc3RyaW5nKSB7XG5cdFx0XHRcdFx0cmV0dXJuIGBwcm9kdWNlIGNhbiBvbmx5IGJlIGNhbGxlZCBvbiB0aGluZ3MgdGhhdCBhcmUgZHJhZnRhYmxlOiBwbGFpbiBvYmplY3RzLCBhcnJheXMsIE1hcCwgU2V0IG9yIGNsYXNzZXMgdGhhdCBhcmUgbWFya2VkIHdpdGggJ1tpbW1lcmFibGVdOiB0cnVlJy4gR290ICcke3RoaW5nfSdgXG5cdFx0XHRcdH0sXG5cdFx0XHRcdFwiVGhpcyBvYmplY3QgaGFzIGJlZW4gZnJvemVuIGFuZCBzaG91bGQgbm90IGJlIG11dGF0ZWRcIixcblx0XHRcdFx0ZnVuY3Rpb24oZGF0YTogYW55KSB7XG5cdFx0XHRcdFx0cmV0dXJuIChcblx0XHRcdFx0XHRcdFwiQ2Fubm90IHVzZSBhIHByb3h5IHRoYXQgaGFzIGJlZW4gcmV2b2tlZC4gRGlkIHlvdSBwYXNzIGFuIG9iamVjdCBmcm9tIGluc2lkZSBhbiBpbW1lciBmdW5jdGlvbiB0byBhbiBhc3luYyBwcm9jZXNzPyBcIiArXG5cdFx0XHRcdFx0XHRkYXRhXG5cdFx0XHRcdFx0KVxuXHRcdFx0XHR9LFxuXHRcdFx0XHRcIkFuIGltbWVyIHByb2R1Y2VyIHJldHVybmVkIGEgbmV3IHZhbHVlICphbmQqIG1vZGlmaWVkIGl0cyBkcmFmdC4gRWl0aGVyIHJldHVybiBhIG5ldyB2YWx1ZSAqb3IqIG1vZGlmeSB0aGUgZHJhZnQuXCIsXG5cdFx0XHRcdFwiSW1tZXIgZm9yYmlkcyBjaXJjdWxhciByZWZlcmVuY2VzXCIsXG5cdFx0XHRcdFwiVGhlIGZpcnN0IG9yIHNlY29uZCBhcmd1bWVudCB0byBgcHJvZHVjZWAgbXVzdCBiZSBhIGZ1bmN0aW9uXCIsXG5cdFx0XHRcdFwiVGhlIHRoaXJkIGFyZ3VtZW50IHRvIGBwcm9kdWNlYCBtdXN0IGJlIGEgZnVuY3Rpb24gb3IgdW5kZWZpbmVkXCIsXG5cdFx0XHRcdFwiRmlyc3QgYXJndW1lbnQgdG8gYGNyZWF0ZURyYWZ0YCBtdXN0IGJlIGEgcGxhaW4gb2JqZWN0LCBhbiBhcnJheSwgb3IgYW4gaW1tZXJhYmxlIG9iamVjdFwiLFxuXHRcdFx0XHRcIkZpcnN0IGFyZ3VtZW50IHRvIGBmaW5pc2hEcmFmdGAgbXVzdCBiZSBhIGRyYWZ0IHJldHVybmVkIGJ5IGBjcmVhdGVEcmFmdGBcIixcblx0XHRcdFx0ZnVuY3Rpb24odGhpbmc6IHN0cmluZykge1xuXHRcdFx0XHRcdHJldHVybiBgJ2N1cnJlbnQnIGV4cGVjdHMgYSBkcmFmdCwgZ290OiAke3RoaW5nfWBcblx0XHRcdFx0fSxcblx0XHRcdFx0XCJPYmplY3QuZGVmaW5lUHJvcGVydHkoKSBjYW5ub3QgYmUgdXNlZCBvbiBhbiBJbW1lciBkcmFmdFwiLFxuXHRcdFx0XHRcIk9iamVjdC5zZXRQcm90b3R5cGVPZigpIGNhbm5vdCBiZSB1c2VkIG9uIGFuIEltbWVyIGRyYWZ0XCIsXG5cdFx0XHRcdFwiSW1tZXIgb25seSBzdXBwb3J0cyBkZWxldGluZyBhcnJheSBpbmRpY2VzXCIsXG5cdFx0XHRcdFwiSW1tZXIgb25seSBzdXBwb3J0cyBzZXR0aW5nIGFycmF5IGluZGljZXMgYW5kIHRoZSAnbGVuZ3RoJyBwcm9wZXJ0eVwiLFxuXHRcdFx0XHRmdW5jdGlvbih0aGluZzogc3RyaW5nKSB7XG5cdFx0XHRcdFx0cmV0dXJuIGAnb3JpZ2luYWwnIGV4cGVjdHMgYSBkcmFmdCwgZ290OiAke3RoaW5nfWBcblx0XHRcdFx0fVxuXHRcdFx0XHQvLyBOb3RlOiBpZiBtb3JlIGVycm9ycyBhcmUgYWRkZWQsIHRoZSBlcnJvck9mZnNldCBpbiBQYXRjaGVzLnRzIHNob3VsZCBiZSBpbmNyZWFzZWRcblx0XHRcdFx0Ly8gU2VlIFBhdGNoZXMudHMgZm9yIGFkZGl0aW9uYWwgZXJyb3JzXG5cdFx0ICBdXG5cdFx0OiBbXVxuXG5leHBvcnQgZnVuY3Rpb24gZGllKGVycm9yOiBudW1iZXIsIC4uLmFyZ3M6IGFueVtdKTogbmV2ZXIge1xuXHRpZiAocHJvY2Vzcy5lbnYuTk9ERV9FTlYgIT09IFwicHJvZHVjdGlvblwiKSB7XG5cdFx0Y29uc3QgZSA9IGVycm9yc1tlcnJvcl1cblx0XHRjb25zdCBtc2cgPSB0eXBlb2YgZSA9PT0gXCJmdW5jdGlvblwiID8gZS5hcHBseShudWxsLCBhcmdzIGFzIGFueSkgOiBlXG5cdFx0dGhyb3cgbmV3IEVycm9yKGBbSW1tZXJdICR7bXNnfWApXG5cdH1cblx0dGhyb3cgbmV3IEVycm9yKFxuXHRcdGBbSW1tZXJdIG1pbmlmaWVkIGVycm9yIG5yOiAke2Vycm9yfS4gRnVsbCBlcnJvciBhdDogaHR0cHM6Ly9iaXQubHkvM2NYRUtXZmBcblx0KVxufVxuIiwgImltcG9ydCB7XG5cdERSQUZUX1NUQVRFLFxuXHREUkFGVEFCTEUsXG5cdE9iamVjdGlzaCxcblx0RHJhZnRlZCxcblx0QW55T2JqZWN0LFxuXHRBbnlNYXAsXG5cdEFueVNldCxcblx0SW1tZXJTdGF0ZSxcblx0QXJjaFR5cGUsXG5cdGRpZVxufSBmcm9tIFwiLi4vaW50ZXJuYWxcIlxuXG5leHBvcnQgY29uc3QgZ2V0UHJvdG90eXBlT2YgPSBPYmplY3QuZ2V0UHJvdG90eXBlT2ZcblxuLyoqIFJldHVybnMgdHJ1ZSBpZiB0aGUgZ2l2ZW4gdmFsdWUgaXMgYW4gSW1tZXIgZHJhZnQgKi9cbi8qI19fUFVSRV9fKi9cbmV4cG9ydCBmdW5jdGlvbiBpc0RyYWZ0KHZhbHVlOiBhbnkpOiBib29sZWFuIHtcblx0cmV0dXJuICEhdmFsdWUgJiYgISF2YWx1ZVtEUkFGVF9TVEFURV1cbn1cblxuLyoqIFJldHVybnMgdHJ1ZSBpZiB0aGUgZ2l2ZW4gdmFsdWUgY2FuIGJlIGRyYWZ0ZWQgYnkgSW1tZXIgKi9cbi8qI19fUFVSRV9fKi9cbmV4cG9ydCBmdW5jdGlvbiBpc0RyYWZ0YWJsZSh2YWx1ZTogYW55KTogYm9vbGVhbiB7XG5cdGlmICghdmFsdWUpIHJldHVybiBmYWxzZVxuXHRyZXR1cm4gKFxuXHRcdGlzUGxhaW5PYmplY3QodmFsdWUpIHx8XG5cdFx0QXJyYXkuaXNBcnJheSh2YWx1ZSkgfHxcblx0XHQhIXZhbHVlW0RSQUZUQUJMRV0gfHxcblx0XHQhIXZhbHVlLmNvbnN0cnVjdG9yPy5bRFJBRlRBQkxFXSB8fFxuXHRcdGlzTWFwKHZhbHVlKSB8fFxuXHRcdGlzU2V0KHZhbHVlKVxuXHQpXG59XG5cbmNvbnN0IG9iamVjdEN0b3JTdHJpbmcgPSBPYmplY3QucHJvdG90eXBlLmNvbnN0cnVjdG9yLnRvU3RyaW5nKClcbi8qI19fUFVSRV9fKi9cbmV4cG9ydCBmdW5jdGlvbiBpc1BsYWluT2JqZWN0KHZhbHVlOiBhbnkpOiBib29sZWFuIHtcblx0aWYgKCF2YWx1ZSB8fCB0eXBlb2YgdmFsdWUgIT09IFwib2JqZWN0XCIpIHJldHVybiBmYWxzZVxuXHRjb25zdCBwcm90byA9IGdldFByb3RvdHlwZU9mKHZhbHVlKVxuXHRpZiAocHJvdG8gPT09IG51bGwpIHtcblx0XHRyZXR1cm4gdHJ1ZVxuXHR9XG5cdGNvbnN0IEN0b3IgPVxuXHRcdE9iamVjdC5oYXNPd25Qcm9wZXJ0eS5jYWxsKHByb3RvLCBcImNvbnN0cnVjdG9yXCIpICYmIHByb3RvLmNvbnN0cnVjdG9yXG5cblx0aWYgKEN0b3IgPT09IE9iamVjdCkgcmV0dXJuIHRydWVcblxuXHRyZXR1cm4gKFxuXHRcdHR5cGVvZiBDdG9yID09IFwiZnVuY3Rpb25cIiAmJlxuXHRcdEZ1bmN0aW9uLnRvU3RyaW5nLmNhbGwoQ3RvcikgPT09IG9iamVjdEN0b3JTdHJpbmdcblx0KVxufVxuXG4vKiogR2V0IHRoZSB1bmRlcmx5aW5nIG9iamVjdCB0aGF0IGlzIHJlcHJlc2VudGVkIGJ5IHRoZSBnaXZlbiBkcmFmdCAqL1xuLyojX19QVVJFX18qL1xuZXhwb3J0IGZ1bmN0aW9uIG9yaWdpbmFsPFQ+KHZhbHVlOiBUKTogVCB8IHVuZGVmaW5lZFxuZXhwb3J0IGZ1bmN0aW9uIG9yaWdpbmFsKHZhbHVlOiBEcmFmdGVkPGFueT4pOiBhbnkge1xuXHRpZiAoIWlzRHJhZnQodmFsdWUpKSBkaWUoMTUsIHZhbHVlKVxuXHRyZXR1cm4gdmFsdWVbRFJBRlRfU1RBVEVdLmJhc2VfXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBlYWNoPFQgZXh0ZW5kcyBPYmplY3Rpc2g+KFxuXHRvYmo6IFQsXG5cdGl0ZXI6IChrZXk6IHN0cmluZyB8IG51bWJlciwgdmFsdWU6IGFueSwgc291cmNlOiBUKSA9PiB2b2lkLFxuXHRlbnVtZXJhYmxlT25seT86IGJvb2xlYW5cbik6IHZvaWRcbmV4cG9ydCBmdW5jdGlvbiBlYWNoKG9iajogYW55LCBpdGVyOiBhbnkpIHtcblx0aWYgKGdldEFyY2h0eXBlKG9iaikgPT09IEFyY2hUeXBlLk9iamVjdCkge1xuXHRcdE9iamVjdC5lbnRyaWVzKG9iaikuZm9yRWFjaCgoW2tleSwgdmFsdWVdKSA9PiB7XG5cdFx0XHRpdGVyKGtleSwgdmFsdWUsIG9iailcblx0XHR9KVxuXHR9IGVsc2Uge1xuXHRcdG9iai5mb3JFYWNoKChlbnRyeTogYW55LCBpbmRleDogYW55KSA9PiBpdGVyKGluZGV4LCBlbnRyeSwgb2JqKSlcblx0fVxufVxuXG4vKiNfX1BVUkVfXyovXG5leHBvcnQgZnVuY3Rpb24gZ2V0QXJjaHR5cGUodGhpbmc6IGFueSk6IEFyY2hUeXBlIHtcblx0Y29uc3Qgc3RhdGU6IHVuZGVmaW5lZCB8IEltbWVyU3RhdGUgPSB0aGluZ1tEUkFGVF9TVEFURV1cblx0cmV0dXJuIHN0YXRlXG5cdFx0PyBzdGF0ZS50eXBlX1xuXHRcdDogQXJyYXkuaXNBcnJheSh0aGluZylcblx0XHQ/IEFyY2hUeXBlLkFycmF5XG5cdFx0OiBpc01hcCh0aGluZylcblx0XHQ/IEFyY2hUeXBlLk1hcFxuXHRcdDogaXNTZXQodGhpbmcpXG5cdFx0PyBBcmNoVHlwZS5TZXRcblx0XHQ6IEFyY2hUeXBlLk9iamVjdFxufVxuXG4vKiNfX1BVUkVfXyovXG5leHBvcnQgZnVuY3Rpb24gaGFzKHRoaW5nOiBhbnksIHByb3A6IFByb3BlcnR5S2V5KTogYm9vbGVhbiB7XG5cdHJldHVybiBnZXRBcmNodHlwZSh0aGluZykgPT09IEFyY2hUeXBlLk1hcFxuXHRcdD8gdGhpbmcuaGFzKHByb3ApXG5cdFx0OiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwodGhpbmcsIHByb3ApXG59XG5cbi8qI19fUFVSRV9fKi9cbmV4cG9ydCBmdW5jdGlvbiBnZXQodGhpbmc6IEFueU1hcCB8IEFueU9iamVjdCwgcHJvcDogUHJvcGVydHlLZXkpOiBhbnkge1xuXHQvLyBAdHMtaWdub3JlXG5cdHJldHVybiBnZXRBcmNodHlwZSh0aGluZykgPT09IEFyY2hUeXBlLk1hcCA/IHRoaW5nLmdldChwcm9wKSA6IHRoaW5nW3Byb3BdXG59XG5cbi8qI19fUFVSRV9fKi9cbmV4cG9ydCBmdW5jdGlvbiBzZXQodGhpbmc6IGFueSwgcHJvcE9yT2xkVmFsdWU6IFByb3BlcnR5S2V5LCB2YWx1ZTogYW55KSB7XG5cdGNvbnN0IHQgPSBnZXRBcmNodHlwZSh0aGluZylcblx0aWYgKHQgPT09IEFyY2hUeXBlLk1hcCkgdGhpbmcuc2V0KHByb3BPck9sZFZhbHVlLCB2YWx1ZSlcblx0ZWxzZSBpZiAodCA9PT0gQXJjaFR5cGUuU2V0KSB7XG5cdFx0dGhpbmcuYWRkKHZhbHVlKVxuXHR9IGVsc2UgdGhpbmdbcHJvcE9yT2xkVmFsdWVdID0gdmFsdWVcbn1cblxuLyojX19QVVJFX18qL1xuZXhwb3J0IGZ1bmN0aW9uIGlzKHg6IGFueSwgeTogYW55KTogYm9vbGVhbiB7XG5cdC8vIEZyb206IGh0dHBzOi8vZ2l0aHViLmNvbS9mYWNlYm9vay9mYmpzL2Jsb2IvYzY5OTA0YTUxMWI5MDAyNjY5MzUxNjgyMjMwNjNkZDg3NzJkZmM0MC9wYWNrYWdlcy9mYmpzL3NyYy9jb3JlL3NoYWxsb3dFcXVhbC5qc1xuXHRpZiAoeCA9PT0geSkge1xuXHRcdHJldHVybiB4ICE9PSAwIHx8IDEgLyB4ID09PSAxIC8geVxuXHR9IGVsc2Uge1xuXHRcdHJldHVybiB4ICE9PSB4ICYmIHkgIT09IHlcblx0fVxufVxuXG4vKiNfX1BVUkVfXyovXG5leHBvcnQgZnVuY3Rpb24gaXNNYXAodGFyZ2V0OiBhbnkpOiB0YXJnZXQgaXMgQW55TWFwIHtcblx0cmV0dXJuIHRhcmdldCBpbnN0YW5jZW9mIE1hcFxufVxuXG4vKiNfX1BVUkVfXyovXG5leHBvcnQgZnVuY3Rpb24gaXNTZXQodGFyZ2V0OiBhbnkpOiB0YXJnZXQgaXMgQW55U2V0IHtcblx0cmV0dXJuIHRhcmdldCBpbnN0YW5jZW9mIFNldFxufVxuLyojX19QVVJFX18qL1xuZXhwb3J0IGZ1bmN0aW9uIGxhdGVzdChzdGF0ZTogSW1tZXJTdGF0ZSk6IGFueSB7XG5cdHJldHVybiBzdGF0ZS5jb3B5XyB8fCBzdGF0ZS5iYXNlX1xufVxuXG4vKiNfX1BVUkVfXyovXG5leHBvcnQgZnVuY3Rpb24gc2hhbGxvd0NvcHkoYmFzZTogYW55LCBzdHJpY3Q6IGJvb2xlYW4pIHtcblx0aWYgKGlzTWFwKGJhc2UpKSB7XG5cdFx0cmV0dXJuIG5ldyBNYXAoYmFzZSlcblx0fVxuXHRpZiAoaXNTZXQoYmFzZSkpIHtcblx0XHRyZXR1cm4gbmV3IFNldChiYXNlKVxuXHR9XG5cdGlmIChBcnJheS5pc0FycmF5KGJhc2UpKSByZXR1cm4gQXJyYXkucHJvdG90eXBlLnNsaWNlLmNhbGwoYmFzZSlcblxuXHRpZiAoIXN0cmljdCAmJiBpc1BsYWluT2JqZWN0KGJhc2UpKSB7XG5cdFx0aWYgKCFnZXRQcm90b3R5cGVPZihiYXNlKSkge1xuXHRcdFx0Y29uc3Qgb2JqID0gT2JqZWN0LmNyZWF0ZShudWxsKVxuXHRcdFx0cmV0dXJuIE9iamVjdC5hc3NpZ24ob2JqLCBiYXNlKVxuXHRcdH1cblx0XHRyZXR1cm4gey4uLmJhc2V9XG5cdH1cblxuXHRjb25zdCBkZXNjcmlwdG9ycyA9IE9iamVjdC5nZXRPd25Qcm9wZXJ0eURlc2NyaXB0b3JzKGJhc2UpXG5cdGRlbGV0ZSBkZXNjcmlwdG9yc1tEUkFGVF9TVEFURSBhcyBhbnldXG5cdGxldCBrZXlzID0gUmVmbGVjdC5vd25LZXlzKGRlc2NyaXB0b3JzKVxuXHRmb3IgKGxldCBpID0gMDsgaSA8IGtleXMubGVuZ3RoOyBpKyspIHtcblx0XHRjb25zdCBrZXk6IGFueSA9IGtleXNbaV1cblx0XHRjb25zdCBkZXNjID0gZGVzY3JpcHRvcnNba2V5XVxuXHRcdGlmIChkZXNjLndyaXRhYmxlID09PSBmYWxzZSkge1xuXHRcdFx0ZGVzYy53cml0YWJsZSA9IHRydWVcblx0XHRcdGRlc2MuY29uZmlndXJhYmxlID0gdHJ1ZVxuXHRcdH1cblx0XHQvLyBsaWtlIG9iamVjdC5hc3NpZ24sIHdlIHdpbGwgcmVhZCBhbnkgX293bl8sIGdldC9zZXQgYWNjZXNzb3JzLiBUaGlzIGhlbHBzIGluIGRlYWxpbmdcblx0XHQvLyB3aXRoIGxpYnJhcmllcyB0aGF0IHRyYXAgdmFsdWVzLCBsaWtlIG1vYnggb3IgdnVlXG5cdFx0Ly8gdW5saWtlIG9iamVjdC5hc3NpZ24sIG5vbi1lbnVtZXJhYmxlcyB3aWxsIGJlIGNvcGllZCBhcyB3ZWxsXG5cdFx0aWYgKGRlc2MuZ2V0IHx8IGRlc2Muc2V0KVxuXHRcdFx0ZGVzY3JpcHRvcnNba2V5XSA9IHtcblx0XHRcdFx0Y29uZmlndXJhYmxlOiB0cnVlLFxuXHRcdFx0XHR3cml0YWJsZTogdHJ1ZSwgLy8gY291bGQgbGl2ZSB3aXRoICEhZGVzYy5zZXQgYXMgd2VsbCBoZXJlLi4uXG5cdFx0XHRcdGVudW1lcmFibGU6IGRlc2MuZW51bWVyYWJsZSxcblx0XHRcdFx0dmFsdWU6IGJhc2Vba2V5XVxuXHRcdFx0fVxuXHR9XG5cdHJldHVybiBPYmplY3QuY3JlYXRlKGdldFByb3RvdHlwZU9mKGJhc2UpLCBkZXNjcmlwdG9ycylcbn1cblxuLyoqXG4gKiBGcmVlemVzIGRyYWZ0YWJsZSBvYmplY3RzLiBSZXR1cm5zIHRoZSBvcmlnaW5hbCBvYmplY3QuXG4gKiBCeSBkZWZhdWx0IGZyZWV6ZXMgc2hhbGxvd2x5LCBidXQgaWYgdGhlIHNlY29uZCBhcmd1bWVudCBpcyBgdHJ1ZWAgaXQgd2lsbCBmcmVlemUgcmVjdXJzaXZlbHkuXG4gKlxuICogQHBhcmFtIG9ialxuICogQHBhcmFtIGRlZXBcbiAqL1xuZXhwb3J0IGZ1bmN0aW9uIGZyZWV6ZTxUPihvYmo6IFQsIGRlZXA/OiBib29sZWFuKTogVFxuZXhwb3J0IGZ1bmN0aW9uIGZyZWV6ZTxUPihvYmo6IGFueSwgZGVlcDogYm9vbGVhbiA9IGZhbHNlKTogVCB7XG5cdGlmIChpc0Zyb3plbihvYmopIHx8IGlzRHJhZnQob2JqKSB8fCAhaXNEcmFmdGFibGUob2JqKSkgcmV0dXJuIG9ialxuXHRpZiAoZ2V0QXJjaHR5cGUob2JqKSA+IDEgLyogTWFwIG9yIFNldCAqLykge1xuXHRcdG9iai5zZXQgPSBvYmouYWRkID0gb2JqLmNsZWFyID0gb2JqLmRlbGV0ZSA9IGRvbnRNdXRhdGVGcm96ZW5Db2xsZWN0aW9ucyBhcyBhbnlcblx0fVxuXHRPYmplY3QuZnJlZXplKG9iailcblx0aWYgKGRlZXApIGVhY2gob2JqLCAoX2tleSwgdmFsdWUpID0+IGZyZWV6ZSh2YWx1ZSwgdHJ1ZSksIHRydWUpXG5cdHJldHVybiBvYmpcbn1cblxuZnVuY3Rpb24gZG9udE11dGF0ZUZyb3plbkNvbGxlY3Rpb25zKCkge1xuXHRkaWUoMilcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGlzRnJvemVuKG9iajogYW55KTogYm9vbGVhbiB7XG5cdHJldHVybiBPYmplY3QuaXNGcm96ZW4ob2JqKVxufVxuIiwgImltcG9ydCB7XG5cdEltbWVyU3RhdGUsXG5cdFBhdGNoLFxuXHREcmFmdGVkLFxuXHRJbW1lckJhc2VTdGF0ZSxcblx0QW55TWFwLFxuXHRBbnlTZXQsXG5cdEFyY2hUeXBlLFxuXHRkaWVcbn0gZnJvbSBcIi4uL2ludGVybmFsXCJcblxuLyoqIFBsdWdpbiB1dGlsaXRpZXMgKi9cbmNvbnN0IHBsdWdpbnM6IHtcblx0UGF0Y2hlcz86IHtcblx0XHRnZW5lcmF0ZVBhdGNoZXNfKFxuXHRcdFx0c3RhdGU6IEltbWVyU3RhdGUsXG5cdFx0XHRiYXNlUGF0aDogUGF0Y2hQYXRoLFxuXHRcdFx0cGF0Y2hlczogUGF0Y2hbXSxcblx0XHRcdGludmVyc2VQYXRjaGVzOiBQYXRjaFtdXG5cdFx0KTogdm9pZFxuXHRcdGdlbmVyYXRlUmVwbGFjZW1lbnRQYXRjaGVzXyhcblx0XHRcdGJhc2U6IGFueSxcblx0XHRcdHJlcGxhY2VtZW50OiBhbnksXG5cdFx0XHRwYXRjaGVzOiBQYXRjaFtdLFxuXHRcdFx0aW52ZXJzZVBhdGNoZXM6IFBhdGNoW11cblx0XHQpOiB2b2lkXG5cdFx0YXBwbHlQYXRjaGVzXzxUPihkcmFmdDogVCwgcGF0Y2hlczogUGF0Y2hbXSk6IFRcblx0fVxuXHRNYXBTZXQ/OiB7XG5cdFx0cHJveHlNYXBfPFQgZXh0ZW5kcyBBbnlNYXA+KHRhcmdldDogVCwgcGFyZW50PzogSW1tZXJTdGF0ZSk6IFRcblx0XHRwcm94eVNldF88VCBleHRlbmRzIEFueVNldD4odGFyZ2V0OiBULCBwYXJlbnQ/OiBJbW1lclN0YXRlKTogVFxuXHR9XG59ID0ge31cblxudHlwZSBQbHVnaW5zID0gdHlwZW9mIHBsdWdpbnNcblxuZXhwb3J0IGZ1bmN0aW9uIGdldFBsdWdpbjxLIGV4dGVuZHMga2V5b2YgUGx1Z2lucz4oXG5cdHBsdWdpbktleTogS1xuKTogRXhjbHVkZTxQbHVnaW5zW0tdLCB1bmRlZmluZWQ+IHtcblx0Y29uc3QgcGx1Z2luID0gcGx1Z2luc1twbHVnaW5LZXldXG5cdGlmICghcGx1Z2luKSB7XG5cdFx0ZGllKDAsIHBsdWdpbktleSlcblx0fVxuXHQvLyBAdHMtaWdub3JlXG5cdHJldHVybiBwbHVnaW5cbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGxvYWRQbHVnaW48SyBleHRlbmRzIGtleW9mIFBsdWdpbnM+KFxuXHRwbHVnaW5LZXk6IEssXG5cdGltcGxlbWVudGF0aW9uOiBQbHVnaW5zW0tdXG4pOiB2b2lkIHtcblx0aWYgKCFwbHVnaW5zW3BsdWdpbktleV0pIHBsdWdpbnNbcGx1Z2luS2V5XSA9IGltcGxlbWVudGF0aW9uXG59XG4vKiogTWFwIC8gU2V0IHBsdWdpbiAqL1xuXG5leHBvcnQgaW50ZXJmYWNlIE1hcFN0YXRlIGV4dGVuZHMgSW1tZXJCYXNlU3RhdGUge1xuXHR0eXBlXzogQXJjaFR5cGUuTWFwXG5cdGNvcHlfOiBBbnlNYXAgfCB1bmRlZmluZWRcblx0YXNzaWduZWRfOiBNYXA8YW55LCBib29sZWFuPiB8IHVuZGVmaW5lZFxuXHRiYXNlXzogQW55TWFwXG5cdHJldm9rZWRfOiBib29sZWFuXG5cdGRyYWZ0XzogRHJhZnRlZDxBbnlNYXAsIE1hcFN0YXRlPlxufVxuXG5leHBvcnQgaW50ZXJmYWNlIFNldFN0YXRlIGV4dGVuZHMgSW1tZXJCYXNlU3RhdGUge1xuXHR0eXBlXzogQXJjaFR5cGUuU2V0XG5cdGNvcHlfOiBBbnlTZXQgfCB1bmRlZmluZWRcblx0YmFzZV86IEFueVNldFxuXHRkcmFmdHNfOiBNYXA8YW55LCBEcmFmdGVkPiAvLyBtYXBzIHRoZSBvcmlnaW5hbCB2YWx1ZSB0byB0aGUgZHJhZnQgdmFsdWUgaW4gdGhlIG5ldyBzZXRcblx0cmV2b2tlZF86IGJvb2xlYW5cblx0ZHJhZnRfOiBEcmFmdGVkPEFueVNldCwgU2V0U3RhdGU+XG59XG5cbi8qKiBQYXRjaGVzIHBsdWdpbiAqL1xuXG5leHBvcnQgdHlwZSBQYXRjaFBhdGggPSAoc3RyaW5nIHwgbnVtYmVyKVtdXG4iLCAiaW1wb3J0IHtcblx0UGF0Y2gsXG5cdFBhdGNoTGlzdGVuZXIsXG5cdERyYWZ0ZWQsXG5cdEltbWVyLFxuXHREUkFGVF9TVEFURSxcblx0SW1tZXJTdGF0ZSxcblx0QXJjaFR5cGUsXG5cdGdldFBsdWdpblxufSBmcm9tIFwiLi4vaW50ZXJuYWxcIlxuXG4vKiogRWFjaCBzY29wZSByZXByZXNlbnRzIGEgYHByb2R1Y2VgIGNhbGwuICovXG5cbmV4cG9ydCBpbnRlcmZhY2UgSW1tZXJTY29wZSB7XG5cdHBhdGNoZXNfPzogUGF0Y2hbXVxuXHRpbnZlcnNlUGF0Y2hlc18/OiBQYXRjaFtdXG5cdGNhbkF1dG9GcmVlemVfOiBib29sZWFuXG5cdGRyYWZ0c186IGFueVtdXG5cdHBhcmVudF8/OiBJbW1lclNjb3BlXG5cdHBhdGNoTGlzdGVuZXJfPzogUGF0Y2hMaXN0ZW5lclxuXHRpbW1lcl86IEltbWVyXG5cdHVuZmluYWxpemVkRHJhZnRzXzogbnVtYmVyXG59XG5cbmxldCBjdXJyZW50U2NvcGU6IEltbWVyU2NvcGUgfCB1bmRlZmluZWRcblxuZXhwb3J0IGZ1bmN0aW9uIGdldEN1cnJlbnRTY29wZSgpIHtcblx0cmV0dXJuIGN1cnJlbnRTY29wZSFcbn1cblxuZnVuY3Rpb24gY3JlYXRlU2NvcGUoXG5cdHBhcmVudF86IEltbWVyU2NvcGUgfCB1bmRlZmluZWQsXG5cdGltbWVyXzogSW1tZXJcbik6IEltbWVyU2NvcGUge1xuXHRyZXR1cm4ge1xuXHRcdGRyYWZ0c186IFtdLFxuXHRcdHBhcmVudF8sXG5cdFx0aW1tZXJfLFxuXHRcdC8vIFdoZW5ldmVyIHRoZSBtb2RpZmllZCBkcmFmdCBjb250YWlucyBhIGRyYWZ0IGZyb20gYW5vdGhlciBzY29wZSwgd2Vcblx0XHQvLyBuZWVkIHRvIHByZXZlbnQgYXV0by1mcmVlemluZyBzbyB0aGUgdW5vd25lZCBkcmFmdCBjYW4gYmUgZmluYWxpemVkLlxuXHRcdGNhbkF1dG9GcmVlemVfOiB0cnVlLFxuXHRcdHVuZmluYWxpemVkRHJhZnRzXzogMFxuXHR9XG59XG5cbmV4cG9ydCBmdW5jdGlvbiB1c2VQYXRjaGVzSW5TY29wZShcblx0c2NvcGU6IEltbWVyU2NvcGUsXG5cdHBhdGNoTGlzdGVuZXI/OiBQYXRjaExpc3RlbmVyXG4pIHtcblx0aWYgKHBhdGNoTGlzdGVuZXIpIHtcblx0XHRnZXRQbHVnaW4oXCJQYXRjaGVzXCIpIC8vIGFzc2VydCB3ZSBoYXZlIHRoZSBwbHVnaW5cblx0XHRzY29wZS5wYXRjaGVzXyA9IFtdXG5cdFx0c2NvcGUuaW52ZXJzZVBhdGNoZXNfID0gW11cblx0XHRzY29wZS5wYXRjaExpc3RlbmVyXyA9IHBhdGNoTGlzdGVuZXJcblx0fVxufVxuXG5leHBvcnQgZnVuY3Rpb24gcmV2b2tlU2NvcGUoc2NvcGU6IEltbWVyU2NvcGUpIHtcblx0bGVhdmVTY29wZShzY29wZSlcblx0c2NvcGUuZHJhZnRzXy5mb3JFYWNoKHJldm9rZURyYWZ0KVxuXHQvLyBAdHMtaWdub3JlXG5cdHNjb3BlLmRyYWZ0c18gPSBudWxsXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBsZWF2ZVNjb3BlKHNjb3BlOiBJbW1lclNjb3BlKSB7XG5cdGlmIChzY29wZSA9PT0gY3VycmVudFNjb3BlKSB7XG5cdFx0Y3VycmVudFNjb3BlID0gc2NvcGUucGFyZW50X1xuXHR9XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBlbnRlclNjb3BlKGltbWVyOiBJbW1lcikge1xuXHRyZXR1cm4gKGN1cnJlbnRTY29wZSA9IGNyZWF0ZVNjb3BlKGN1cnJlbnRTY29wZSwgaW1tZXIpKVxufVxuXG5mdW5jdGlvbiByZXZva2VEcmFmdChkcmFmdDogRHJhZnRlZCkge1xuXHRjb25zdCBzdGF0ZTogSW1tZXJTdGF0ZSA9IGRyYWZ0W0RSQUZUX1NUQVRFXVxuXHRpZiAoc3RhdGUudHlwZV8gPT09IEFyY2hUeXBlLk9iamVjdCB8fCBzdGF0ZS50eXBlXyA9PT0gQXJjaFR5cGUuQXJyYXkpXG5cdFx0c3RhdGUucmV2b2tlXygpXG5cdGVsc2Ugc3RhdGUucmV2b2tlZF8gPSB0cnVlXG59XG4iLCAiaW1wb3J0IHtcblx0SW1tZXJTY29wZSxcblx0RFJBRlRfU1RBVEUsXG5cdGlzRHJhZnRhYmxlLFxuXHROT1RISU5HLFxuXHRQYXRjaFBhdGgsXG5cdGVhY2gsXG5cdGhhcyxcblx0ZnJlZXplLFxuXHRJbW1lclN0YXRlLFxuXHRpc0RyYWZ0LFxuXHRTZXRTdGF0ZSxcblx0c2V0LFxuXHRBcmNoVHlwZSxcblx0Z2V0UGx1Z2luLFxuXHRkaWUsXG5cdHJldm9rZVNjb3BlLFxuXHRpc0Zyb3plblxufSBmcm9tIFwiLi4vaW50ZXJuYWxcIlxuXG5leHBvcnQgZnVuY3Rpb24gcHJvY2Vzc1Jlc3VsdChyZXN1bHQ6IGFueSwgc2NvcGU6IEltbWVyU2NvcGUpIHtcblx0c2NvcGUudW5maW5hbGl6ZWREcmFmdHNfID0gc2NvcGUuZHJhZnRzXy5sZW5ndGhcblx0Y29uc3QgYmFzZURyYWZ0ID0gc2NvcGUuZHJhZnRzXyFbMF1cblx0Y29uc3QgaXNSZXBsYWNlZCA9IHJlc3VsdCAhPT0gdW5kZWZpbmVkICYmIHJlc3VsdCAhPT0gYmFzZURyYWZ0XG5cdGlmIChpc1JlcGxhY2VkKSB7XG5cdFx0aWYgKGJhc2VEcmFmdFtEUkFGVF9TVEFURV0ubW9kaWZpZWRfKSB7XG5cdFx0XHRyZXZva2VTY29wZShzY29wZSlcblx0XHRcdGRpZSg0KVxuXHRcdH1cblx0XHRpZiAoaXNEcmFmdGFibGUocmVzdWx0KSkge1xuXHRcdFx0Ly8gRmluYWxpemUgdGhlIHJlc3VsdCBpbiBjYXNlIGl0IGNvbnRhaW5zIChvciBpcykgYSBzdWJzZXQgb2YgdGhlIGRyYWZ0LlxuXHRcdFx0cmVzdWx0ID0gZmluYWxpemUoc2NvcGUsIHJlc3VsdClcblx0XHRcdGlmICghc2NvcGUucGFyZW50XykgbWF5YmVGcmVlemUoc2NvcGUsIHJlc3VsdClcblx0XHR9XG5cdFx0aWYgKHNjb3BlLnBhdGNoZXNfKSB7XG5cdFx0XHRnZXRQbHVnaW4oXCJQYXRjaGVzXCIpLmdlbmVyYXRlUmVwbGFjZW1lbnRQYXRjaGVzXyhcblx0XHRcdFx0YmFzZURyYWZ0W0RSQUZUX1NUQVRFXS5iYXNlXyxcblx0XHRcdFx0cmVzdWx0LFxuXHRcdFx0XHRzY29wZS5wYXRjaGVzXyxcblx0XHRcdFx0c2NvcGUuaW52ZXJzZVBhdGNoZXNfIVxuXHRcdFx0KVxuXHRcdH1cblx0fSBlbHNlIHtcblx0XHQvLyBGaW5hbGl6ZSB0aGUgYmFzZSBkcmFmdC5cblx0XHRyZXN1bHQgPSBmaW5hbGl6ZShzY29wZSwgYmFzZURyYWZ0LCBbXSlcblx0fVxuXHRyZXZva2VTY29wZShzY29wZSlcblx0aWYgKHNjb3BlLnBhdGNoZXNfKSB7XG5cdFx0c2NvcGUucGF0Y2hMaXN0ZW5lcl8hKHNjb3BlLnBhdGNoZXNfLCBzY29wZS5pbnZlcnNlUGF0Y2hlc18hKVxuXHR9XG5cdHJldHVybiByZXN1bHQgIT09IE5PVEhJTkcgPyByZXN1bHQgOiB1bmRlZmluZWRcbn1cblxuZnVuY3Rpb24gZmluYWxpemUocm9vdFNjb3BlOiBJbW1lclNjb3BlLCB2YWx1ZTogYW55LCBwYXRoPzogUGF0Y2hQYXRoKSB7XG5cdC8vIERvbid0IHJlY3Vyc2UgaW4gdGhvIHJlY3Vyc2l2ZSBkYXRhIHN0cnVjdHVyZXNcblx0aWYgKGlzRnJvemVuKHZhbHVlKSkgcmV0dXJuIHZhbHVlXG5cblx0Y29uc3Qgc3RhdGU6IEltbWVyU3RhdGUgPSB2YWx1ZVtEUkFGVF9TVEFURV1cblx0Ly8gQSBwbGFpbiBvYmplY3QsIG1pZ2h0IG5lZWQgZnJlZXppbmcsIG1pZ2h0IGNvbnRhaW4gZHJhZnRzXG5cdGlmICghc3RhdGUpIHtcblx0XHRlYWNoKFxuXHRcdFx0dmFsdWUsXG5cdFx0XHQoa2V5LCBjaGlsZFZhbHVlKSA9PlxuXHRcdFx0XHRmaW5hbGl6ZVByb3BlcnR5KHJvb3RTY29wZSwgc3RhdGUsIHZhbHVlLCBrZXksIGNoaWxkVmFsdWUsIHBhdGgpLFxuXHRcdFx0dHJ1ZSAvLyBTZWUgIzU5MCwgZG9uJ3QgcmVjdXJzZSBpbnRvIG5vbi1lbnVtZXJhYmxlIG9mIG5vbiBkcmFmdGVkIG9iamVjdHNcblx0XHQpXG5cdFx0cmV0dXJuIHZhbHVlXG5cdH1cblx0Ly8gTmV2ZXIgZmluYWxpemUgZHJhZnRzIG93bmVkIGJ5IGFub3RoZXIgc2NvcGUuXG5cdGlmIChzdGF0ZS5zY29wZV8gIT09IHJvb3RTY29wZSkgcmV0dXJuIHZhbHVlXG5cdC8vIFVubW9kaWZpZWQgZHJhZnQsIHJldHVybiB0aGUgKGZyb3plbikgb3JpZ2luYWxcblx0aWYgKCFzdGF0ZS5tb2RpZmllZF8pIHtcblx0XHRtYXliZUZyZWV6ZShyb290U2NvcGUsIHN0YXRlLmJhc2VfLCB0cnVlKVxuXHRcdHJldHVybiBzdGF0ZS5iYXNlX1xuXHR9XG5cdC8vIE5vdCBmaW5hbGl6ZWQgeWV0LCBsZXQncyBkbyB0aGF0IG5vd1xuXHRpZiAoIXN0YXRlLmZpbmFsaXplZF8pIHtcblx0XHRzdGF0ZS5maW5hbGl6ZWRfID0gdHJ1ZVxuXHRcdHN0YXRlLnNjb3BlXy51bmZpbmFsaXplZERyYWZ0c18tLVxuXHRcdGNvbnN0IHJlc3VsdCA9IHN0YXRlLmNvcHlfXG5cdFx0Ly8gRmluYWxpemUgYWxsIGNoaWxkcmVuIG9mIHRoZSBjb3B5XG5cdFx0Ly8gRm9yIHNldHMgd2UgY2xvbmUgYmVmb3JlIGl0ZXJhdGluZywgb3RoZXJ3aXNlIHdlIGNhbiBnZXQgaW4gZW5kbGVzcyBsb29wIGR1ZSB0byBtb2RpZnlpbmcgZHVyaW5nIGl0ZXJhdGlvbiwgc2VlICM2Mjhcblx0XHQvLyBUbyBwcmVzZXJ2ZSBpbnNlcnRpb24gb3JkZXIgaW4gYWxsIGNhc2VzIHdlIHRoZW4gY2xlYXIgdGhlIHNldFxuXHRcdC8vIEFuZCB3ZSBsZXQgZmluYWxpemVQcm9wZXJ0eSBrbm93IGl0IG5lZWRzIHRvIHJlLWFkZCBub24tZHJhZnQgY2hpbGRyZW4gYmFjayB0byB0aGUgdGFyZ2V0XG5cdFx0bGV0IHJlc3VsdEVhY2ggPSByZXN1bHRcblx0XHRsZXQgaXNTZXQgPSBmYWxzZVxuXHRcdGlmIChzdGF0ZS50eXBlXyA9PT0gQXJjaFR5cGUuU2V0KSB7XG5cdFx0XHRyZXN1bHRFYWNoID0gbmV3IFNldChyZXN1bHQpXG5cdFx0XHRyZXN1bHQuY2xlYXIoKVxuXHRcdFx0aXNTZXQgPSB0cnVlXG5cdFx0fVxuXHRcdGVhY2gocmVzdWx0RWFjaCwgKGtleSwgY2hpbGRWYWx1ZSkgPT5cblx0XHRcdGZpbmFsaXplUHJvcGVydHkocm9vdFNjb3BlLCBzdGF0ZSwgcmVzdWx0LCBrZXksIGNoaWxkVmFsdWUsIHBhdGgsIGlzU2V0KVxuXHRcdClcblx0XHQvLyBldmVyeXRoaW5nIGluc2lkZSBpcyBmcm96ZW4sIHdlIGNhbiBmcmVlemUgaGVyZVxuXHRcdG1heWJlRnJlZXplKHJvb3RTY29wZSwgcmVzdWx0LCBmYWxzZSlcblx0XHQvLyBmaXJzdCB0aW1lIGZpbmFsaXppbmcsIGxldCdzIGNyZWF0ZSB0aG9zZSBwYXRjaGVzXG5cdFx0aWYgKHBhdGggJiYgcm9vdFNjb3BlLnBhdGNoZXNfKSB7XG5cdFx0XHRnZXRQbHVnaW4oXCJQYXRjaGVzXCIpLmdlbmVyYXRlUGF0Y2hlc18oXG5cdFx0XHRcdHN0YXRlLFxuXHRcdFx0XHRwYXRoLFxuXHRcdFx0XHRyb290U2NvcGUucGF0Y2hlc18sXG5cdFx0XHRcdHJvb3RTY29wZS5pbnZlcnNlUGF0Y2hlc18hXG5cdFx0XHQpXG5cdFx0fVxuXHR9XG5cdHJldHVybiBzdGF0ZS5jb3B5X1xufVxuXG5mdW5jdGlvbiBmaW5hbGl6ZVByb3BlcnR5KFxuXHRyb290U2NvcGU6IEltbWVyU2NvcGUsXG5cdHBhcmVudFN0YXRlOiB1bmRlZmluZWQgfCBJbW1lclN0YXRlLFxuXHR0YXJnZXRPYmplY3Q6IGFueSxcblx0cHJvcDogc3RyaW5nIHwgbnVtYmVyLFxuXHRjaGlsZFZhbHVlOiBhbnksXG5cdHJvb3RQYXRoPzogUGF0Y2hQYXRoLFxuXHR0YXJnZXRJc1NldD86IGJvb2xlYW5cbikge1xuXHRpZiAocHJvY2Vzcy5lbnYuTk9ERV9FTlYgIT09IFwicHJvZHVjdGlvblwiICYmIGNoaWxkVmFsdWUgPT09IHRhcmdldE9iamVjdClcblx0XHRkaWUoNSlcblx0aWYgKGlzRHJhZnQoY2hpbGRWYWx1ZSkpIHtcblx0XHRjb25zdCBwYXRoID1cblx0XHRcdHJvb3RQYXRoICYmXG5cdFx0XHRwYXJlbnRTdGF0ZSAmJlxuXHRcdFx0cGFyZW50U3RhdGUhLnR5cGVfICE9PSBBcmNoVHlwZS5TZXQgJiYgLy8gU2V0IG9iamVjdHMgYXJlIGF0b21pYyBzaW5jZSB0aGV5IGhhdmUgbm8ga2V5cy5cblx0XHRcdCFoYXMoKHBhcmVudFN0YXRlIGFzIEV4Y2x1ZGU8SW1tZXJTdGF0ZSwgU2V0U3RhdGU+KS5hc3NpZ25lZF8hLCBwcm9wKSAvLyBTa2lwIGRlZXAgcGF0Y2hlcyBmb3IgYXNzaWduZWQga2V5cy5cblx0XHRcdFx0PyByb290UGF0aCEuY29uY2F0KHByb3ApXG5cdFx0XHRcdDogdW5kZWZpbmVkXG5cdFx0Ly8gRHJhZnRzIG93bmVkIGJ5IGBzY29wZWAgYXJlIGZpbmFsaXplZCBoZXJlLlxuXHRcdGNvbnN0IHJlcyA9IGZpbmFsaXplKHJvb3RTY29wZSwgY2hpbGRWYWx1ZSwgcGF0aClcblx0XHRzZXQodGFyZ2V0T2JqZWN0LCBwcm9wLCByZXMpXG5cdFx0Ly8gRHJhZnRzIGZyb20gYW5vdGhlciBzY29wZSBtdXN0IHByZXZlbnRlZCB0byBiZSBmcm96ZW5cblx0XHQvLyBpZiB3ZSBnb3QgYSBkcmFmdCBiYWNrIGZyb20gZmluYWxpemUsIHdlJ3JlIGluIGEgbmVzdGVkIHByb2R1Y2UgYW5kIHNob3VsZG4ndCBmcmVlemVcblx0XHRpZiAoaXNEcmFmdChyZXMpKSB7XG5cdFx0XHRyb290U2NvcGUuY2FuQXV0b0ZyZWV6ZV8gPSBmYWxzZVxuXHRcdH0gZWxzZSByZXR1cm5cblx0fSBlbHNlIGlmICh0YXJnZXRJc1NldCkge1xuXHRcdHRhcmdldE9iamVjdC5hZGQoY2hpbGRWYWx1ZSlcblx0fVxuXHQvLyBTZWFyY2ggbmV3IG9iamVjdHMgZm9yIHVuZmluYWxpemVkIGRyYWZ0cy4gRnJvemVuIG9iamVjdHMgc2hvdWxkIG5ldmVyIGNvbnRhaW4gZHJhZnRzLlxuXHRpZiAoaXNEcmFmdGFibGUoY2hpbGRWYWx1ZSkgJiYgIWlzRnJvemVuKGNoaWxkVmFsdWUpKSB7XG5cdFx0aWYgKCFyb290U2NvcGUuaW1tZXJfLmF1dG9GcmVlemVfICYmIHJvb3RTY29wZS51bmZpbmFsaXplZERyYWZ0c18gPCAxKSB7XG5cdFx0XHQvLyBvcHRpbWl6YXRpb246IGlmIGFuIG9iamVjdCBpcyBub3QgYSBkcmFmdCwgYW5kIHdlIGRvbid0IGhhdmUgdG9cblx0XHRcdC8vIGRlZXBmcmVlemUgZXZlcnl0aGluZywgYW5kIHdlIGFyZSBzdXJlIHRoYXQgbm8gZHJhZnRzIGFyZSBsZWZ0IGluIHRoZSByZW1haW5pbmcgb2JqZWN0XG5cdFx0XHQvLyBjYXVzZSB3ZSBzYXcgYW5kIGZpbmFsaXplZCBhbGwgZHJhZnRzIGFscmVhZHk7IHdlIGNhbiBzdG9wIHZpc2l0aW5nIHRoZSByZXN0IG9mIHRoZSB0cmVlLlxuXHRcdFx0Ly8gVGhpcyBiZW5lZml0cyBlc3BlY2lhbGx5IGFkZGluZyBsYXJnZSBkYXRhIHRyZWUncyB3aXRob3V0IGZ1cnRoZXIgcHJvY2Vzc2luZy5cblx0XHRcdC8vIFNlZSBhZGQtZGF0YS5qcyBwZXJmIHRlc3Rcblx0XHRcdHJldHVyblxuXHRcdH1cblx0XHRmaW5hbGl6ZShyb290U2NvcGUsIGNoaWxkVmFsdWUpXG5cdFx0Ly8gaW1tZXIgZGVlcCBmcmVlemVzIHBsYWluIG9iamVjdHMsIHNvIGlmIHRoZXJlIGlzIG5vIHBhcmVudCBzdGF0ZSwgd2UgZnJlZXplIGFzIHdlbGxcblx0XHRpZiAoIXBhcmVudFN0YXRlIHx8ICFwYXJlbnRTdGF0ZS5zY29wZV8ucGFyZW50Xylcblx0XHRcdG1heWJlRnJlZXplKHJvb3RTY29wZSwgY2hpbGRWYWx1ZSlcblx0fVxufVxuXG5mdW5jdGlvbiBtYXliZUZyZWV6ZShzY29wZTogSW1tZXJTY29wZSwgdmFsdWU6IGFueSwgZGVlcCA9IGZhbHNlKSB7XG5cdC8vIHdlIG5ldmVyIGZyZWV6ZSBmb3IgYSBub24tcm9vdCBzY29wZTsgYXMgaXQgd291bGQgcHJldmVudCBwcnVuaW5nIGZvciBkcmFmdHMgaW5zaWRlIHdyYXBwaW5nIG9iamVjdHNcblx0aWYgKCFzY29wZS5wYXJlbnRfICYmIHNjb3BlLmltbWVyXy5hdXRvRnJlZXplXyAmJiBzY29wZS5jYW5BdXRvRnJlZXplXykge1xuXHRcdGZyZWV6ZSh2YWx1ZSwgZGVlcClcblx0fVxufVxuIiwgImltcG9ydCB7XG5cdGVhY2gsXG5cdGhhcyxcblx0aXMsXG5cdGlzRHJhZnRhYmxlLFxuXHRzaGFsbG93Q29weSxcblx0bGF0ZXN0LFxuXHRJbW1lckJhc2VTdGF0ZSxcblx0SW1tZXJTdGF0ZSxcblx0RHJhZnRlZCxcblx0QW55T2JqZWN0LFxuXHRBbnlBcnJheSxcblx0T2JqZWN0aXNoLFxuXHRnZXRDdXJyZW50U2NvcGUsXG5cdGdldFByb3RvdHlwZU9mLFxuXHREUkFGVF9TVEFURSxcblx0ZGllLFxuXHRjcmVhdGVQcm94eSxcblx0QXJjaFR5cGUsXG5cdEltbWVyU2NvcGVcbn0gZnJvbSBcIi4uL2ludGVybmFsXCJcblxuaW50ZXJmYWNlIFByb3h5QmFzZVN0YXRlIGV4dGVuZHMgSW1tZXJCYXNlU3RhdGUge1xuXHRhc3NpZ25lZF86IHtcblx0XHRbcHJvcGVydHk6IHN0cmluZ106IGJvb2xlYW5cblx0fVxuXHRwYXJlbnRfPzogSW1tZXJTdGF0ZVxuXHRyZXZva2VfKCk6IHZvaWRcbn1cblxuZXhwb3J0IGludGVyZmFjZSBQcm94eU9iamVjdFN0YXRlIGV4dGVuZHMgUHJveHlCYXNlU3RhdGUge1xuXHR0eXBlXzogQXJjaFR5cGUuT2JqZWN0XG5cdGJhc2VfOiBhbnlcblx0Y29weV86IGFueVxuXHRkcmFmdF86IERyYWZ0ZWQ8QW55T2JqZWN0LCBQcm94eU9iamVjdFN0YXRlPlxufVxuXG5leHBvcnQgaW50ZXJmYWNlIFByb3h5QXJyYXlTdGF0ZSBleHRlbmRzIFByb3h5QmFzZVN0YXRlIHtcblx0dHlwZV86IEFyY2hUeXBlLkFycmF5XG5cdGJhc2VfOiBBbnlBcnJheVxuXHRjb3B5XzogQW55QXJyYXkgfCBudWxsXG5cdGRyYWZ0XzogRHJhZnRlZDxBbnlBcnJheSwgUHJveHlBcnJheVN0YXRlPlxufVxuXG50eXBlIFByb3h5U3RhdGUgPSBQcm94eU9iamVjdFN0YXRlIHwgUHJveHlBcnJheVN0YXRlXG5cbi8qKlxuICogUmV0dXJucyBhIG5ldyBkcmFmdCBvZiB0aGUgYGJhc2VgIG9iamVjdC5cbiAqXG4gKiBUaGUgc2Vjb25kIGFyZ3VtZW50IGlzIHRoZSBwYXJlbnQgZHJhZnQtc3RhdGUgKHVzZWQgaW50ZXJuYWxseSkuXG4gKi9cbmV4cG9ydCBmdW5jdGlvbiBjcmVhdGVQcm94eVByb3h5PFQgZXh0ZW5kcyBPYmplY3Rpc2g+KFxuXHRiYXNlOiBULFxuXHRwYXJlbnQ/OiBJbW1lclN0YXRlXG4pOiBEcmFmdGVkPFQsIFByb3h5U3RhdGU+IHtcblx0Y29uc3QgaXNBcnJheSA9IEFycmF5LmlzQXJyYXkoYmFzZSlcblx0Y29uc3Qgc3RhdGU6IFByb3h5U3RhdGUgPSB7XG5cdFx0dHlwZV86IGlzQXJyYXkgPyBBcmNoVHlwZS5BcnJheSA6IChBcmNoVHlwZS5PYmplY3QgYXMgYW55KSxcblx0XHQvLyBUcmFjayB3aGljaCBwcm9kdWNlIGNhbGwgdGhpcyBpcyBhc3NvY2lhdGVkIHdpdGguXG5cdFx0c2NvcGVfOiBwYXJlbnQgPyBwYXJlbnQuc2NvcGVfIDogZ2V0Q3VycmVudFNjb3BlKCkhLFxuXHRcdC8vIFRydWUgZm9yIGJvdGggc2hhbGxvdyBhbmQgZGVlcCBjaGFuZ2VzLlxuXHRcdG1vZGlmaWVkXzogZmFsc2UsXG5cdFx0Ly8gVXNlZCBkdXJpbmcgZmluYWxpemF0aW9uLlxuXHRcdGZpbmFsaXplZF86IGZhbHNlLFxuXHRcdC8vIFRyYWNrIHdoaWNoIHByb3BlcnRpZXMgaGF2ZSBiZWVuIGFzc2lnbmVkICh0cnVlKSBvciBkZWxldGVkIChmYWxzZSkuXG5cdFx0YXNzaWduZWRfOiB7fSxcblx0XHQvLyBUaGUgcGFyZW50IGRyYWZ0IHN0YXRlLlxuXHRcdHBhcmVudF86IHBhcmVudCxcblx0XHQvLyBUaGUgYmFzZSBzdGF0ZS5cblx0XHRiYXNlXzogYmFzZSxcblx0XHQvLyBUaGUgYmFzZSBwcm94eS5cblx0XHRkcmFmdF86IG51bGwgYXMgYW55LCAvLyBzZXQgYmVsb3dcblx0XHQvLyBUaGUgYmFzZSBjb3B5IHdpdGggYW55IHVwZGF0ZWQgdmFsdWVzLlxuXHRcdGNvcHlfOiBudWxsLFxuXHRcdC8vIENhbGxlZCBieSB0aGUgYHByb2R1Y2VgIGZ1bmN0aW9uLlxuXHRcdHJldm9rZV86IG51bGwgYXMgYW55LFxuXHRcdGlzTWFudWFsXzogZmFsc2Vcblx0fVxuXG5cdC8vIHRoZSB0cmFwcyBtdXN0IHRhcmdldCBzb21ldGhpbmcsIGEgYml0IGxpa2UgdGhlICdyZWFsJyBiYXNlLlxuXHQvLyBidXQgYWxzbywgd2UgbmVlZCB0byBiZSBhYmxlIHRvIGRldGVybWluZSBmcm9tIHRoZSB0YXJnZXQgd2hhdCB0aGUgcmVsZXZhbnQgc3RhdGUgaXNcblx0Ly8gKHRvIGF2b2lkIGNyZWF0aW5nIHRyYXBzIHBlciBpbnN0YW5jZSB0byBjYXB0dXJlIHRoZSBzdGF0ZSBpbiBjbG9zdXJlLFxuXHQvLyBhbmQgdG8gYXZvaWQgY3JlYXRpbmcgd2VpcmQgaGlkZGVuIHByb3BlcnRpZXMgYXMgd2VsbClcblx0Ly8gU28gdGhlIHRyaWNrIGlzIHRvIHVzZSAnc3RhdGUnIGFzIHRoZSBhY3R1YWwgJ3RhcmdldCchIChhbmQgbWFrZSBzdXJlIHdlIGludGVyY2VwdCBldmVyeXRoaW5nKVxuXHQvLyBOb3RlIHRoYXQgaW4gdGhlIGNhc2Ugb2YgYW4gYXJyYXksIHdlIHB1dCB0aGUgc3RhdGUgaW4gYW4gYXJyYXkgdG8gaGF2ZSBiZXR0ZXIgUmVmbGVjdCBkZWZhdWx0cyBvb3RiXG5cdGxldCB0YXJnZXQ6IFQgPSBzdGF0ZSBhcyBhbnlcblx0bGV0IHRyYXBzOiBQcm94eUhhbmRsZXI8b2JqZWN0IHwgQXJyYXk8YW55Pj4gPSBvYmplY3RUcmFwc1xuXHRpZiAoaXNBcnJheSkge1xuXHRcdHRhcmdldCA9IFtzdGF0ZV0gYXMgYW55XG5cdFx0dHJhcHMgPSBhcnJheVRyYXBzXG5cdH1cblxuXHRjb25zdCB7cmV2b2tlLCBwcm94eX0gPSBQcm94eS5yZXZvY2FibGUodGFyZ2V0LCB0cmFwcylcblx0c3RhdGUuZHJhZnRfID0gcHJveHkgYXMgYW55XG5cdHN0YXRlLnJldm9rZV8gPSByZXZva2Vcblx0cmV0dXJuIHByb3h5IGFzIGFueVxufVxuXG4vKipcbiAqIE9iamVjdCBkcmFmdHNcbiAqL1xuZXhwb3J0IGNvbnN0IG9iamVjdFRyYXBzOiBQcm94eUhhbmRsZXI8UHJveHlTdGF0ZT4gPSB7XG5cdGdldChzdGF0ZSwgcHJvcCkge1xuXHRcdGlmIChwcm9wID09PSBEUkFGVF9TVEFURSkgcmV0dXJuIHN0YXRlXG5cblx0XHRjb25zdCBzb3VyY2UgPSBsYXRlc3Qoc3RhdGUpXG5cdFx0aWYgKCFoYXMoc291cmNlLCBwcm9wKSkge1xuXHRcdFx0Ly8gbm9uLWV4aXN0aW5nIG9yIG5vbi1vd24gcHJvcGVydHkuLi5cblx0XHRcdHJldHVybiByZWFkUHJvcEZyb21Qcm90byhzdGF0ZSwgc291cmNlLCBwcm9wKVxuXHRcdH1cblx0XHRjb25zdCB2YWx1ZSA9IHNvdXJjZVtwcm9wXVxuXHRcdGlmIChzdGF0ZS5maW5hbGl6ZWRfIHx8ICFpc0RyYWZ0YWJsZSh2YWx1ZSkpIHtcblx0XHRcdHJldHVybiB2YWx1ZVxuXHRcdH1cblx0XHQvLyBDaGVjayBmb3IgZXhpc3RpbmcgZHJhZnQgaW4gbW9kaWZpZWQgc3RhdGUuXG5cdFx0Ly8gQXNzaWduZWQgdmFsdWVzIGFyZSBuZXZlciBkcmFmdGVkLiBUaGlzIGNhdGNoZXMgYW55IGRyYWZ0cyB3ZSBjcmVhdGVkLCB0b28uXG5cdFx0aWYgKHZhbHVlID09PSBwZWVrKHN0YXRlLmJhc2VfLCBwcm9wKSkge1xuXHRcdFx0cHJlcGFyZUNvcHkoc3RhdGUpXG5cdFx0XHRyZXR1cm4gKHN0YXRlLmNvcHlfIVtwcm9wIGFzIGFueV0gPSBjcmVhdGVQcm94eSh2YWx1ZSwgc3RhdGUpKVxuXHRcdH1cblx0XHRyZXR1cm4gdmFsdWVcblx0fSxcblx0aGFzKHN0YXRlLCBwcm9wKSB7XG5cdFx0cmV0dXJuIHByb3AgaW4gbGF0ZXN0KHN0YXRlKVxuXHR9LFxuXHRvd25LZXlzKHN0YXRlKSB7XG5cdFx0cmV0dXJuIFJlZmxlY3Qub3duS2V5cyhsYXRlc3Qoc3RhdGUpKVxuXHR9LFxuXHRzZXQoXG5cdFx0c3RhdGU6IFByb3h5T2JqZWN0U3RhdGUsXG5cdFx0cHJvcDogc3RyaW5nIC8qIHN0cmljdGx5IG5vdCwgYnV0IGhlbHBzIFRTICovLFxuXHRcdHZhbHVlXG5cdCkge1xuXHRcdGNvbnN0IGRlc2MgPSBnZXREZXNjcmlwdG9yRnJvbVByb3RvKGxhdGVzdChzdGF0ZSksIHByb3ApXG5cdFx0aWYgKGRlc2M/LnNldCkge1xuXHRcdFx0Ly8gc3BlY2lhbCBjYXNlOiBpZiB0aGlzIHdyaXRlIGlzIGNhcHR1cmVkIGJ5IGEgc2V0dGVyLCB3ZSBoYXZlXG5cdFx0XHQvLyB0byB0cmlnZ2VyIGl0IHdpdGggdGhlIGNvcnJlY3QgY29udGV4dFxuXHRcdFx0ZGVzYy5zZXQuY2FsbChzdGF0ZS5kcmFmdF8sIHZhbHVlKVxuXHRcdFx0cmV0dXJuIHRydWVcblx0XHR9XG5cdFx0aWYgKCFzdGF0ZS5tb2RpZmllZF8pIHtcblx0XHRcdC8vIHRoZSBsYXN0IGNoZWNrIGlzIGJlY2F1c2Ugd2UgbmVlZCB0byBiZSBhYmxlIHRvIGRpc3Rpbmd1aXNoIHNldHRpbmcgYSBub24tZXhpc3RpbmcgdG8gdW5kZWZpbmVkICh3aGljaCBpcyBhIGNoYW5nZSlcblx0XHRcdC8vIGZyb20gc2V0dGluZyBhbiBleGlzdGluZyBwcm9wZXJ0eSB3aXRoIHZhbHVlIHVuZGVmaW5lZCB0byB1bmRlZmluZWQgKHdoaWNoIGlzIG5vdCBhIGNoYW5nZSlcblx0XHRcdGNvbnN0IGN1cnJlbnQgPSBwZWVrKGxhdGVzdChzdGF0ZSksIHByb3ApXG5cdFx0XHQvLyBzcGVjaWFsIGNhc2UsIGlmIHdlIGFzc2lnbmluZyB0aGUgb3JpZ2luYWwgdmFsdWUgdG8gYSBkcmFmdCwgd2UgY2FuIGlnbm9yZSB0aGUgYXNzaWdubWVudFxuXHRcdFx0Y29uc3QgY3VycmVudFN0YXRlOiBQcm94eU9iamVjdFN0YXRlID0gY3VycmVudD8uW0RSQUZUX1NUQVRFXVxuXHRcdFx0aWYgKGN1cnJlbnRTdGF0ZSAmJiBjdXJyZW50U3RhdGUuYmFzZV8gPT09IHZhbHVlKSB7XG5cdFx0XHRcdHN0YXRlLmNvcHlfIVtwcm9wXSA9IHZhbHVlXG5cdFx0XHRcdHN0YXRlLmFzc2lnbmVkX1twcm9wXSA9IGZhbHNlXG5cdFx0XHRcdHJldHVybiB0cnVlXG5cdFx0XHR9XG5cdFx0XHRpZiAoaXModmFsdWUsIGN1cnJlbnQpICYmICh2YWx1ZSAhPT0gdW5kZWZpbmVkIHx8IGhhcyhzdGF0ZS5iYXNlXywgcHJvcCkpKVxuXHRcdFx0XHRyZXR1cm4gdHJ1ZVxuXHRcdFx0cHJlcGFyZUNvcHkoc3RhdGUpXG5cdFx0XHRtYXJrQ2hhbmdlZChzdGF0ZSlcblx0XHR9XG5cblx0XHRpZiAoXG5cdFx0XHQoc3RhdGUuY29weV8hW3Byb3BdID09PSB2YWx1ZSAmJlxuXHRcdFx0XHQvLyBzcGVjaWFsIGNhc2U6IGhhbmRsZSBuZXcgcHJvcHMgd2l0aCB2YWx1ZSAndW5kZWZpbmVkJ1xuXHRcdFx0XHQodmFsdWUgIT09IHVuZGVmaW5lZCB8fCBwcm9wIGluIHN0YXRlLmNvcHlfKSkgfHxcblx0XHRcdC8vIHNwZWNpYWwgY2FzZTogTmFOXG5cdFx0XHQoTnVtYmVyLmlzTmFOKHZhbHVlKSAmJiBOdW1iZXIuaXNOYU4oc3RhdGUuY29weV8hW3Byb3BdKSlcblx0XHQpXG5cdFx0XHRyZXR1cm4gdHJ1ZVxuXG5cdFx0Ly8gQHRzLWlnbm9yZVxuXHRcdHN0YXRlLmNvcHlfIVtwcm9wXSA9IHZhbHVlXG5cdFx0c3RhdGUuYXNzaWduZWRfW3Byb3BdID0gdHJ1ZVxuXHRcdHJldHVybiB0cnVlXG5cdH0sXG5cdGRlbGV0ZVByb3BlcnR5KHN0YXRlLCBwcm9wOiBzdHJpbmcpIHtcblx0XHQvLyBUaGUgYHVuZGVmaW5lZGAgY2hlY2sgaXMgYSBmYXN0IHBhdGggZm9yIHByZS1leGlzdGluZyBrZXlzLlxuXHRcdGlmIChwZWVrKHN0YXRlLmJhc2VfLCBwcm9wKSAhPT0gdW5kZWZpbmVkIHx8IHByb3AgaW4gc3RhdGUuYmFzZV8pIHtcblx0XHRcdHN0YXRlLmFzc2lnbmVkX1twcm9wXSA9IGZhbHNlXG5cdFx0XHRwcmVwYXJlQ29weShzdGF0ZSlcblx0XHRcdG1hcmtDaGFuZ2VkKHN0YXRlKVxuXHRcdH0gZWxzZSB7XG5cdFx0XHQvLyBpZiBhbiBvcmlnaW5hbGx5IG5vdCBhc3NpZ25lZCBwcm9wZXJ0eSB3YXMgZGVsZXRlZFxuXHRcdFx0ZGVsZXRlIHN0YXRlLmFzc2lnbmVkX1twcm9wXVxuXHRcdH1cblx0XHRpZiAoc3RhdGUuY29weV8pIHtcblx0XHRcdGRlbGV0ZSBzdGF0ZS5jb3B5X1twcm9wXVxuXHRcdH1cblx0XHRyZXR1cm4gdHJ1ZVxuXHR9LFxuXHQvLyBOb3RlOiBXZSBuZXZlciBjb2VyY2UgYGRlc2MudmFsdWVgIGludG8gYW4gSW1tZXIgZHJhZnQsIGJlY2F1c2Ugd2UgY2FuJ3QgbWFrZVxuXHQvLyB0aGUgc2FtZSBndWFyYW50ZWUgaW4gRVM1IG1vZGUuXG5cdGdldE93blByb3BlcnR5RGVzY3JpcHRvcihzdGF0ZSwgcHJvcCkge1xuXHRcdGNvbnN0IG93bmVyID0gbGF0ZXN0KHN0YXRlKVxuXHRcdGNvbnN0IGRlc2MgPSBSZWZsZWN0LmdldE93blByb3BlcnR5RGVzY3JpcHRvcihvd25lciwgcHJvcClcblx0XHRpZiAoIWRlc2MpIHJldHVybiBkZXNjXG5cdFx0cmV0dXJuIHtcblx0XHRcdHdyaXRhYmxlOiB0cnVlLFxuXHRcdFx0Y29uZmlndXJhYmxlOiBzdGF0ZS50eXBlXyAhPT0gQXJjaFR5cGUuQXJyYXkgfHwgcHJvcCAhPT0gXCJsZW5ndGhcIixcblx0XHRcdGVudW1lcmFibGU6IGRlc2MuZW51bWVyYWJsZSxcblx0XHRcdHZhbHVlOiBvd25lcltwcm9wXVxuXHRcdH1cblx0fSxcblx0ZGVmaW5lUHJvcGVydHkoKSB7XG5cdFx0ZGllKDExKVxuXHR9LFxuXHRnZXRQcm90b3R5cGVPZihzdGF0ZSkge1xuXHRcdHJldHVybiBnZXRQcm90b3R5cGVPZihzdGF0ZS5iYXNlXylcblx0fSxcblx0c2V0UHJvdG90eXBlT2YoKSB7XG5cdFx0ZGllKDEyKVxuXHR9XG59XG5cbi8qKlxuICogQXJyYXkgZHJhZnRzXG4gKi9cblxuY29uc3QgYXJyYXlUcmFwczogUHJveHlIYW5kbGVyPFtQcm94eUFycmF5U3RhdGVdPiA9IHt9XG5lYWNoKG9iamVjdFRyYXBzLCAoa2V5LCBmbikgPT4ge1xuXHQvLyBAdHMtaWdub3JlXG5cdGFycmF5VHJhcHNba2V5XSA9IGZ1bmN0aW9uKCkge1xuXHRcdGFyZ3VtZW50c1swXSA9IGFyZ3VtZW50c1swXVswXVxuXHRcdHJldHVybiBmbi5hcHBseSh0aGlzLCBhcmd1bWVudHMpXG5cdH1cbn0pXG5hcnJheVRyYXBzLmRlbGV0ZVByb3BlcnR5ID0gZnVuY3Rpb24oc3RhdGUsIHByb3ApIHtcblx0aWYgKHByb2Nlc3MuZW52Lk5PREVfRU5WICE9PSBcInByb2R1Y3Rpb25cIiAmJiBpc05hTihwYXJzZUludChwcm9wIGFzIGFueSkpKVxuXHRcdGRpZSgxMylcblx0Ly8gQHRzLWlnbm9yZVxuXHRyZXR1cm4gYXJyYXlUcmFwcy5zZXQhLmNhbGwodGhpcywgc3RhdGUsIHByb3AsIHVuZGVmaW5lZClcbn1cbmFycmF5VHJhcHMuc2V0ID0gZnVuY3Rpb24oc3RhdGUsIHByb3AsIHZhbHVlKSB7XG5cdGlmIChcblx0XHRwcm9jZXNzLmVudi5OT0RFX0VOViAhPT0gXCJwcm9kdWN0aW9uXCIgJiZcblx0XHRwcm9wICE9PSBcImxlbmd0aFwiICYmXG5cdFx0aXNOYU4ocGFyc2VJbnQocHJvcCBhcyBhbnkpKVxuXHQpXG5cdFx0ZGllKDE0KVxuXHRyZXR1cm4gb2JqZWN0VHJhcHMuc2V0IS5jYWxsKHRoaXMsIHN0YXRlWzBdLCBwcm9wLCB2YWx1ZSwgc3RhdGVbMF0pXG59XG5cbi8vIEFjY2VzcyBhIHByb3BlcnR5IHdpdGhvdXQgY3JlYXRpbmcgYW4gSW1tZXIgZHJhZnQuXG5mdW5jdGlvbiBwZWVrKGRyYWZ0OiBEcmFmdGVkLCBwcm9wOiBQcm9wZXJ0eUtleSkge1xuXHRjb25zdCBzdGF0ZSA9IGRyYWZ0W0RSQUZUX1NUQVRFXVxuXHRjb25zdCBzb3VyY2UgPSBzdGF0ZSA/IGxhdGVzdChzdGF0ZSkgOiBkcmFmdFxuXHRyZXR1cm4gc291cmNlW3Byb3BdXG59XG5cbmZ1bmN0aW9uIHJlYWRQcm9wRnJvbVByb3RvKHN0YXRlOiBJbW1lclN0YXRlLCBzb3VyY2U6IGFueSwgcHJvcDogUHJvcGVydHlLZXkpIHtcblx0Y29uc3QgZGVzYyA9IGdldERlc2NyaXB0b3JGcm9tUHJvdG8oc291cmNlLCBwcm9wKVxuXHRyZXR1cm4gZGVzY1xuXHRcdD8gYHZhbHVlYCBpbiBkZXNjXG5cdFx0XHQ/IGRlc2MudmFsdWVcblx0XHRcdDogLy8gVGhpcyBpcyBhIHZlcnkgc3BlY2lhbCBjYXNlLCBpZiB0aGUgcHJvcCBpcyBhIGdldHRlciBkZWZpbmVkIGJ5IHRoZVxuXHRcdFx0ICAvLyBwcm90b3R5cGUsIHdlIHNob3VsZCBpbnZva2UgaXQgd2l0aCB0aGUgZHJhZnQgYXMgY29udGV4dCFcblx0XHRcdCAgZGVzYy5nZXQ/LmNhbGwoc3RhdGUuZHJhZnRfKVxuXHRcdDogdW5kZWZpbmVkXG59XG5cbmZ1bmN0aW9uIGdldERlc2NyaXB0b3JGcm9tUHJvdG8oXG5cdHNvdXJjZTogYW55LFxuXHRwcm9wOiBQcm9wZXJ0eUtleVxuKTogUHJvcGVydHlEZXNjcmlwdG9yIHwgdW5kZWZpbmVkIHtcblx0Ly8gJ2luJyBjaGVja3MgcHJvdG8hXG5cdGlmICghKHByb3AgaW4gc291cmNlKSkgcmV0dXJuIHVuZGVmaW5lZFxuXHRsZXQgcHJvdG8gPSBnZXRQcm90b3R5cGVPZihzb3VyY2UpXG5cdHdoaWxlIChwcm90bykge1xuXHRcdGNvbnN0IGRlc2MgPSBPYmplY3QuZ2V0T3duUHJvcGVydHlEZXNjcmlwdG9yKHByb3RvLCBwcm9wKVxuXHRcdGlmIChkZXNjKSByZXR1cm4gZGVzY1xuXHRcdHByb3RvID0gZ2V0UHJvdG90eXBlT2YocHJvdG8pXG5cdH1cblx0cmV0dXJuIHVuZGVmaW5lZFxufVxuXG5leHBvcnQgZnVuY3Rpb24gbWFya0NoYW5nZWQoc3RhdGU6IEltbWVyU3RhdGUpIHtcblx0aWYgKCFzdGF0ZS5tb2RpZmllZF8pIHtcblx0XHRzdGF0ZS5tb2RpZmllZF8gPSB0cnVlXG5cdFx0aWYgKHN0YXRlLnBhcmVudF8pIHtcblx0XHRcdG1hcmtDaGFuZ2VkKHN0YXRlLnBhcmVudF8pXG5cdFx0fVxuXHR9XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBwcmVwYXJlQ29weShzdGF0ZToge1xuXHRiYXNlXzogYW55XG5cdGNvcHlfOiBhbnlcblx0c2NvcGVfOiBJbW1lclNjb3BlXG59KSB7XG5cdGlmICghc3RhdGUuY29weV8pIHtcblx0XHRzdGF0ZS5jb3B5XyA9IHNoYWxsb3dDb3B5KFxuXHRcdFx0c3RhdGUuYmFzZV8sXG5cdFx0XHRzdGF0ZS5zY29wZV8uaW1tZXJfLnVzZVN0cmljdFNoYWxsb3dDb3B5X1xuXHRcdClcblx0fVxufVxuIiwgImltcG9ydCB7XG5cdElQcm9kdWNlV2l0aFBhdGNoZXMsXG5cdElQcm9kdWNlLFxuXHRJbW1lclN0YXRlLFxuXHREcmFmdGVkLFxuXHRpc0RyYWZ0YWJsZSxcblx0cHJvY2Vzc1Jlc3VsdCxcblx0UGF0Y2gsXG5cdE9iamVjdGlzaCxcblx0RFJBRlRfU1RBVEUsXG5cdERyYWZ0LFxuXHRQYXRjaExpc3RlbmVyLFxuXHRpc0RyYWZ0LFxuXHRpc01hcCxcblx0aXNTZXQsXG5cdGNyZWF0ZVByb3h5UHJveHksXG5cdGdldFBsdWdpbixcblx0ZGllLFxuXHRlbnRlclNjb3BlLFxuXHRyZXZva2VTY29wZSxcblx0bGVhdmVTY29wZSxcblx0dXNlUGF0Y2hlc0luU2NvcGUsXG5cdGdldEN1cnJlbnRTY29wZSxcblx0Tk9USElORyxcblx0ZnJlZXplLFxuXHRjdXJyZW50XG59IGZyb20gXCIuLi9pbnRlcm5hbFwiXG5cbmludGVyZmFjZSBQcm9kdWNlcnNGbnMge1xuXHRwcm9kdWNlOiBJUHJvZHVjZVxuXHRwcm9kdWNlV2l0aFBhdGNoZXM6IElQcm9kdWNlV2l0aFBhdGNoZXNcbn1cblxuZXhwb3J0IGNsYXNzIEltbWVyIGltcGxlbWVudHMgUHJvZHVjZXJzRm5zIHtcblx0YXV0b0ZyZWV6ZV86IGJvb2xlYW4gPSB0cnVlXG5cdHVzZVN0cmljdFNoYWxsb3dDb3B5XzogYm9vbGVhbiA9IGZhbHNlXG5cblx0Y29uc3RydWN0b3IoY29uZmlnPzoge2F1dG9GcmVlemU/OiBib29sZWFuOyB1c2VTdHJpY3RTaGFsbG93Q29weT86IGJvb2xlYW59KSB7XG5cdFx0aWYgKHR5cGVvZiBjb25maWc/LmF1dG9GcmVlemUgPT09IFwiYm9vbGVhblwiKVxuXHRcdFx0dGhpcy5zZXRBdXRvRnJlZXplKGNvbmZpZyEuYXV0b0ZyZWV6ZSlcblx0XHRpZiAodHlwZW9mIGNvbmZpZz8udXNlU3RyaWN0U2hhbGxvd0NvcHkgPT09IFwiYm9vbGVhblwiKVxuXHRcdFx0dGhpcy5zZXRVc2VTdHJpY3RTaGFsbG93Q29weShjb25maWchLnVzZVN0cmljdFNoYWxsb3dDb3B5KVxuXHR9XG5cblx0LyoqXG5cdCAqIFRoZSBgcHJvZHVjZWAgZnVuY3Rpb24gdGFrZXMgYSB2YWx1ZSBhbmQgYSBcInJlY2lwZSBmdW5jdGlvblwiICh3aG9zZVxuXHQgKiByZXR1cm4gdmFsdWUgb2Z0ZW4gZGVwZW5kcyBvbiB0aGUgYmFzZSBzdGF0ZSkuIFRoZSByZWNpcGUgZnVuY3Rpb24gaXNcblx0ICogZnJlZSB0byBtdXRhdGUgaXRzIGZpcnN0IGFyZ3VtZW50IGhvd2V2ZXIgaXQgd2FudHMuIEFsbCBtdXRhdGlvbnMgYXJlXG5cdCAqIG9ubHkgZXZlciBhcHBsaWVkIHRvIGEgX19jb3B5X18gb2YgdGhlIGJhc2Ugc3RhdGUuXG5cdCAqXG5cdCAqIFBhc3Mgb25seSBhIGZ1bmN0aW9uIHRvIGNyZWF0ZSBhIFwiY3VycmllZCBwcm9kdWNlclwiIHdoaWNoIHJlbGlldmVzIHlvdVxuXHQgKiBmcm9tIHBhc3NpbmcgdGhlIHJlY2lwZSBmdW5jdGlvbiBldmVyeSB0aW1lLlxuXHQgKlxuXHQgKiBPbmx5IHBsYWluIG9iamVjdHMgYW5kIGFycmF5cyBhcmUgbWFkZSBtdXRhYmxlLiBBbGwgb3RoZXIgb2JqZWN0cyBhcmVcblx0ICogY29uc2lkZXJlZCB1bmNvcHlhYmxlLlxuXHQgKlxuXHQgKiBOb3RlOiBUaGlzIGZ1bmN0aW9uIGlzIF9fYm91bmRfXyB0byBpdHMgYEltbWVyYCBpbnN0YW5jZS5cblx0ICpcblx0ICogQHBhcmFtIHthbnl9IGJhc2UgLSB0aGUgaW5pdGlhbCBzdGF0ZVxuXHQgKiBAcGFyYW0ge0Z1bmN0aW9ufSByZWNpcGUgLSBmdW5jdGlvbiB0aGF0IHJlY2VpdmVzIGEgcHJveHkgb2YgdGhlIGJhc2Ugc3RhdGUgYXMgZmlyc3QgYXJndW1lbnQgYW5kIHdoaWNoIGNhbiBiZSBmcmVlbHkgbW9kaWZpZWRcblx0ICogQHBhcmFtIHtGdW5jdGlvbn0gcGF0Y2hMaXN0ZW5lciAtIG9wdGlvbmFsIGZ1bmN0aW9uIHRoYXQgd2lsbCBiZSBjYWxsZWQgd2l0aCBhbGwgdGhlIHBhdGNoZXMgcHJvZHVjZWQgaGVyZVxuXHQgKiBAcmV0dXJucyB7YW55fSBhIG5ldyBzdGF0ZSwgb3IgdGhlIGluaXRpYWwgc3RhdGUgaWYgbm90aGluZyB3YXMgbW9kaWZpZWRcblx0ICovXG5cdHByb2R1Y2U6IElQcm9kdWNlID0gKGJhc2U6IGFueSwgcmVjaXBlPzogYW55LCBwYXRjaExpc3RlbmVyPzogYW55KSA9PiB7XG5cdFx0Ly8gY3VycmllZCBpbnZvY2F0aW9uXG5cdFx0aWYgKHR5cGVvZiBiYXNlID09PSBcImZ1bmN0aW9uXCIgJiYgdHlwZW9mIHJlY2lwZSAhPT0gXCJmdW5jdGlvblwiKSB7XG5cdFx0XHRjb25zdCBkZWZhdWx0QmFzZSA9IHJlY2lwZVxuXHRcdFx0cmVjaXBlID0gYmFzZVxuXG5cdFx0XHRjb25zdCBzZWxmID0gdGhpc1xuXHRcdFx0cmV0dXJuIGZ1bmN0aW9uIGN1cnJpZWRQcm9kdWNlKFxuXHRcdFx0XHR0aGlzOiBhbnksXG5cdFx0XHRcdGJhc2UgPSBkZWZhdWx0QmFzZSxcblx0XHRcdFx0Li4uYXJnczogYW55W11cblx0XHRcdCkge1xuXHRcdFx0XHRyZXR1cm4gc2VsZi5wcm9kdWNlKGJhc2UsIChkcmFmdDogRHJhZnRlZCkgPT4gcmVjaXBlLmNhbGwodGhpcywgZHJhZnQsIC4uLmFyZ3MpKSAvLyBwcmV0dGllci1pZ25vcmVcblx0XHRcdH1cblx0XHR9XG5cblx0XHRpZiAodHlwZW9mIHJlY2lwZSAhPT0gXCJmdW5jdGlvblwiKSBkaWUoNilcblx0XHRpZiAocGF0Y2hMaXN0ZW5lciAhPT0gdW5kZWZpbmVkICYmIHR5cGVvZiBwYXRjaExpc3RlbmVyICE9PSBcImZ1bmN0aW9uXCIpXG5cdFx0XHRkaWUoNylcblxuXHRcdGxldCByZXN1bHRcblxuXHRcdC8vIE9ubHkgcGxhaW4gb2JqZWN0cywgYXJyYXlzLCBhbmQgXCJpbW1lcmFibGUgY2xhc3Nlc1wiIGFyZSBkcmFmdGVkLlxuXHRcdGlmIChpc0RyYWZ0YWJsZShiYXNlKSkge1xuXHRcdFx0Y29uc3Qgc2NvcGUgPSBlbnRlclNjb3BlKHRoaXMpXG5cdFx0XHRjb25zdCBwcm94eSA9IGNyZWF0ZVByb3h5KGJhc2UsIHVuZGVmaW5lZClcblx0XHRcdGxldCBoYXNFcnJvciA9IHRydWVcblx0XHRcdHRyeSB7XG5cdFx0XHRcdHJlc3VsdCA9IHJlY2lwZShwcm94eSlcblx0XHRcdFx0aGFzRXJyb3IgPSBmYWxzZVxuXHRcdFx0fSBmaW5hbGx5IHtcblx0XHRcdFx0Ly8gZmluYWxseSBpbnN0ZWFkIG9mIGNhdGNoICsgcmV0aHJvdyBiZXR0ZXIgcHJlc2VydmVzIG9yaWdpbmFsIHN0YWNrXG5cdFx0XHRcdGlmIChoYXNFcnJvcikgcmV2b2tlU2NvcGUoc2NvcGUpXG5cdFx0XHRcdGVsc2UgbGVhdmVTY29wZShzY29wZSlcblx0XHRcdH1cblx0XHRcdHVzZVBhdGNoZXNJblNjb3BlKHNjb3BlLCBwYXRjaExpc3RlbmVyKVxuXHRcdFx0cmV0dXJuIHByb2Nlc3NSZXN1bHQocmVzdWx0LCBzY29wZSlcblx0XHR9IGVsc2UgaWYgKCFiYXNlIHx8IHR5cGVvZiBiYXNlICE9PSBcIm9iamVjdFwiKSB7XG5cdFx0XHRyZXN1bHQgPSByZWNpcGUoYmFzZSlcblx0XHRcdGlmIChyZXN1bHQgPT09IHVuZGVmaW5lZCkgcmVzdWx0ID0gYmFzZVxuXHRcdFx0aWYgKHJlc3VsdCA9PT0gTk9USElORykgcmVzdWx0ID0gdW5kZWZpbmVkXG5cdFx0XHRpZiAodGhpcy5hdXRvRnJlZXplXykgZnJlZXplKHJlc3VsdCwgdHJ1ZSlcblx0XHRcdGlmIChwYXRjaExpc3RlbmVyKSB7XG5cdFx0XHRcdGNvbnN0IHA6IFBhdGNoW10gPSBbXVxuXHRcdFx0XHRjb25zdCBpcDogUGF0Y2hbXSA9IFtdXG5cdFx0XHRcdGdldFBsdWdpbihcIlBhdGNoZXNcIikuZ2VuZXJhdGVSZXBsYWNlbWVudFBhdGNoZXNfKGJhc2UsIHJlc3VsdCwgcCwgaXApXG5cdFx0XHRcdHBhdGNoTGlzdGVuZXIocCwgaXApXG5cdFx0XHR9XG5cdFx0XHRyZXR1cm4gcmVzdWx0XG5cdFx0fSBlbHNlIGRpZSgxLCBiYXNlKVxuXHR9XG5cblx0cHJvZHVjZVdpdGhQYXRjaGVzOiBJUHJvZHVjZVdpdGhQYXRjaGVzID0gKGJhc2U6IGFueSwgcmVjaXBlPzogYW55KTogYW55ID0+IHtcblx0XHQvLyBjdXJyaWVkIGludm9jYXRpb25cblx0XHRpZiAodHlwZW9mIGJhc2UgPT09IFwiZnVuY3Rpb25cIikge1xuXHRcdFx0cmV0dXJuIChzdGF0ZTogYW55LCAuLi5hcmdzOiBhbnlbXSkgPT5cblx0XHRcdFx0dGhpcy5wcm9kdWNlV2l0aFBhdGNoZXMoc3RhdGUsIChkcmFmdDogYW55KSA9PiBiYXNlKGRyYWZ0LCAuLi5hcmdzKSlcblx0XHR9XG5cblx0XHRsZXQgcGF0Y2hlczogUGF0Y2hbXSwgaW52ZXJzZVBhdGNoZXM6IFBhdGNoW11cblx0XHRjb25zdCByZXN1bHQgPSB0aGlzLnByb2R1Y2UoYmFzZSwgcmVjaXBlLCAocDogUGF0Y2hbXSwgaXA6IFBhdGNoW10pID0+IHtcblx0XHRcdHBhdGNoZXMgPSBwXG5cdFx0XHRpbnZlcnNlUGF0Y2hlcyA9IGlwXG5cdFx0fSlcblx0XHRyZXR1cm4gW3Jlc3VsdCwgcGF0Y2hlcyEsIGludmVyc2VQYXRjaGVzIV1cblx0fVxuXG5cdGNyZWF0ZURyYWZ0PFQgZXh0ZW5kcyBPYmplY3Rpc2g+KGJhc2U6IFQpOiBEcmFmdDxUPiB7XG5cdFx0aWYgKCFpc0RyYWZ0YWJsZShiYXNlKSkgZGllKDgpXG5cdFx0aWYgKGlzRHJhZnQoYmFzZSkpIGJhc2UgPSBjdXJyZW50KGJhc2UpXG5cdFx0Y29uc3Qgc2NvcGUgPSBlbnRlclNjb3BlKHRoaXMpXG5cdFx0Y29uc3QgcHJveHkgPSBjcmVhdGVQcm94eShiYXNlLCB1bmRlZmluZWQpXG5cdFx0cHJveHlbRFJBRlRfU1RBVEVdLmlzTWFudWFsXyA9IHRydWVcblx0XHRsZWF2ZVNjb3BlKHNjb3BlKVxuXHRcdHJldHVybiBwcm94eSBhcyBhbnlcblx0fVxuXG5cdGZpbmlzaERyYWZ0PEQgZXh0ZW5kcyBEcmFmdDxhbnk+Pihcblx0XHRkcmFmdDogRCxcblx0XHRwYXRjaExpc3RlbmVyPzogUGF0Y2hMaXN0ZW5lclxuXHQpOiBEIGV4dGVuZHMgRHJhZnQ8aW5mZXIgVD4gPyBUIDogbmV2ZXIge1xuXHRcdGNvbnN0IHN0YXRlOiBJbW1lclN0YXRlID0gZHJhZnQgJiYgKGRyYWZ0IGFzIGFueSlbRFJBRlRfU1RBVEVdXG5cdFx0aWYgKCFzdGF0ZSB8fCAhc3RhdGUuaXNNYW51YWxfKSBkaWUoOSlcblx0XHRjb25zdCB7c2NvcGVfOiBzY29wZX0gPSBzdGF0ZVxuXHRcdHVzZVBhdGNoZXNJblNjb3BlKHNjb3BlLCBwYXRjaExpc3RlbmVyKVxuXHRcdHJldHVybiBwcm9jZXNzUmVzdWx0KHVuZGVmaW5lZCwgc2NvcGUpXG5cdH1cblxuXHQvKipcblx0ICogUGFzcyB0cnVlIHRvIGF1dG9tYXRpY2FsbHkgZnJlZXplIGFsbCBjb3BpZXMgY3JlYXRlZCBieSBJbW1lci5cblx0ICpcblx0ICogQnkgZGVmYXVsdCwgYXV0by1mcmVlemluZyBpcyBlbmFibGVkLlxuXHQgKi9cblx0c2V0QXV0b0ZyZWV6ZSh2YWx1ZTogYm9vbGVhbikge1xuXHRcdHRoaXMuYXV0b0ZyZWV6ZV8gPSB2YWx1ZVxuXHR9XG5cblx0LyoqXG5cdCAqIFBhc3MgdHJ1ZSB0byBlbmFibGUgc3RyaWN0IHNoYWxsb3cgY29weS5cblx0ICpcblx0ICogQnkgZGVmYXVsdCwgaW1tZXIgZG9lcyBub3QgY29weSB0aGUgb2JqZWN0IGRlc2NyaXB0b3JzIHN1Y2ggYXMgZ2V0dGVyLCBzZXR0ZXIgYW5kIG5vbi1lbnVtcmFibGUgcHJvcGVydGllcy5cblx0ICovXG5cdHNldFVzZVN0cmljdFNoYWxsb3dDb3B5KHZhbHVlOiBib29sZWFuKSB7XG5cdFx0dGhpcy51c2VTdHJpY3RTaGFsbG93Q29weV8gPSB2YWx1ZVxuXHR9XG5cblx0YXBwbHlQYXRjaGVzPFQgZXh0ZW5kcyBPYmplY3Rpc2g+KGJhc2U6IFQsIHBhdGNoZXM6IFBhdGNoW10pOiBUIHtcblx0XHQvLyBJZiBhIHBhdGNoIHJlcGxhY2VzIHRoZSBlbnRpcmUgc3RhdGUsIHRha2UgdGhhdCByZXBsYWNlbWVudCBhcyBiYXNlXG5cdFx0Ly8gYmVmb3JlIGFwcGx5aW5nIHBhdGNoZXNcblx0XHRsZXQgaTogbnVtYmVyXG5cdFx0Zm9yIChpID0gcGF0Y2hlcy5sZW5ndGggLSAxOyBpID49IDA7IGktLSkge1xuXHRcdFx0Y29uc3QgcGF0Y2ggPSBwYXRjaGVzW2ldXG5cdFx0XHRpZiAocGF0Y2gucGF0aC5sZW5ndGggPT09IDAgJiYgcGF0Y2gub3AgPT09IFwicmVwbGFjZVwiKSB7XG5cdFx0XHRcdGJhc2UgPSBwYXRjaC52YWx1ZVxuXHRcdFx0XHRicmVha1xuXHRcdFx0fVxuXHRcdH1cblx0XHQvLyBJZiB0aGVyZSB3YXMgYSBwYXRjaCB0aGF0IHJlcGxhY2VkIHRoZSBlbnRpcmUgc3RhdGUsIHN0YXJ0IGZyb20gdGhlXG5cdFx0Ly8gcGF0Y2ggYWZ0ZXIgdGhhdC5cblx0XHRpZiAoaSA+IC0xKSB7XG5cdFx0XHRwYXRjaGVzID0gcGF0Y2hlcy5zbGljZShpICsgMSlcblx0XHR9XG5cblx0XHRjb25zdCBhcHBseVBhdGNoZXNJbXBsID0gZ2V0UGx1Z2luKFwiUGF0Y2hlc1wiKS5hcHBseVBhdGNoZXNfXG5cdFx0aWYgKGlzRHJhZnQoYmFzZSkpIHtcblx0XHRcdC8vIE4uQjogbmV2ZXIgaGl0cyBpZiBzb21lIHBhdGNoIGEgcmVwbGFjZW1lbnQsIHBhdGNoZXMgYXJlIG5ldmVyIGRyYWZ0c1xuXHRcdFx0cmV0dXJuIGFwcGx5UGF0Y2hlc0ltcGwoYmFzZSwgcGF0Y2hlcylcblx0XHR9XG5cdFx0Ly8gT3RoZXJ3aXNlLCBwcm9kdWNlIGEgY29weSBvZiB0aGUgYmFzZSBzdGF0ZS5cblx0XHRyZXR1cm4gdGhpcy5wcm9kdWNlKGJhc2UsIChkcmFmdDogRHJhZnRlZCkgPT5cblx0XHRcdGFwcGx5UGF0Y2hlc0ltcGwoZHJhZnQsIHBhdGNoZXMpXG5cdFx0KVxuXHR9XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBjcmVhdGVQcm94eTxUIGV4dGVuZHMgT2JqZWN0aXNoPihcblx0dmFsdWU6IFQsXG5cdHBhcmVudD86IEltbWVyU3RhdGVcbik6IERyYWZ0ZWQ8VCwgSW1tZXJTdGF0ZT4ge1xuXHQvLyBwcmVjb25kaXRpb246IGNyZWF0ZVByb3h5IHNob3VsZCBiZSBndWFyZGVkIGJ5IGlzRHJhZnRhYmxlLCBzbyB3ZSBrbm93IHdlIGNhbiBzYWZlbHkgZHJhZnRcblx0Y29uc3QgZHJhZnQ6IERyYWZ0ZWQgPSBpc01hcCh2YWx1ZSlcblx0XHQ/IGdldFBsdWdpbihcIk1hcFNldFwiKS5wcm94eU1hcF8odmFsdWUsIHBhcmVudClcblx0XHQ6IGlzU2V0KHZhbHVlKVxuXHRcdD8gZ2V0UGx1Z2luKFwiTWFwU2V0XCIpLnByb3h5U2V0Xyh2YWx1ZSwgcGFyZW50KVxuXHRcdDogY3JlYXRlUHJveHlQcm94eSh2YWx1ZSwgcGFyZW50KVxuXG5cdGNvbnN0IHNjb3BlID0gcGFyZW50ID8gcGFyZW50LnNjb3BlXyA6IGdldEN1cnJlbnRTY29wZSgpXG5cdHNjb3BlLmRyYWZ0c18ucHVzaChkcmFmdClcblx0cmV0dXJuIGRyYWZ0XG59XG4iLCAiaW1wb3J0IHtcblx0ZGllLFxuXHRpc0RyYWZ0LFxuXHRzaGFsbG93Q29weSxcblx0ZWFjaCxcblx0RFJBRlRfU1RBVEUsXG5cdHNldCxcblx0SW1tZXJTdGF0ZSxcblx0aXNEcmFmdGFibGUsXG5cdGlzRnJvemVuXG59IGZyb20gXCIuLi9pbnRlcm5hbFwiXG5cbi8qKiBUYWtlcyBhIHNuYXBzaG90IG9mIHRoZSBjdXJyZW50IHN0YXRlIG9mIGEgZHJhZnQgYW5kIGZpbmFsaXplcyBpdCAoYnV0IHdpdGhvdXQgZnJlZXppbmcpLiBUaGlzIGlzIGEgZ3JlYXQgdXRpbGl0eSB0byBwcmludCB0aGUgY3VycmVudCBzdGF0ZSBkdXJpbmcgZGVidWdnaW5nIChubyBQcm94aWVzIGluIHRoZSB3YXkpLiBUaGUgb3V0cHV0IG9mIGN1cnJlbnQgY2FuIGFsc28gYmUgc2FmZWx5IGxlYWtlZCBvdXRzaWRlIHRoZSBwcm9kdWNlci4gKi9cbmV4cG9ydCBmdW5jdGlvbiBjdXJyZW50PFQ+KHZhbHVlOiBUKTogVFxuZXhwb3J0IGZ1bmN0aW9uIGN1cnJlbnQodmFsdWU6IGFueSk6IGFueSB7XG5cdGlmICghaXNEcmFmdCh2YWx1ZSkpIGRpZSgxMCwgdmFsdWUpXG5cdHJldHVybiBjdXJyZW50SW1wbCh2YWx1ZSlcbn1cblxuZnVuY3Rpb24gY3VycmVudEltcGwodmFsdWU6IGFueSk6IGFueSB7XG5cdGlmICghaXNEcmFmdGFibGUodmFsdWUpIHx8IGlzRnJvemVuKHZhbHVlKSkgcmV0dXJuIHZhbHVlXG5cdGNvbnN0IHN0YXRlOiBJbW1lclN0YXRlIHwgdW5kZWZpbmVkID0gdmFsdWVbRFJBRlRfU1RBVEVdXG5cdGxldCBjb3B5OiBhbnlcblx0aWYgKHN0YXRlKSB7XG5cdFx0aWYgKCFzdGF0ZS5tb2RpZmllZF8pIHJldHVybiBzdGF0ZS5iYXNlX1xuXHRcdC8vIE9wdGltaXphdGlvbjogYXZvaWQgZ2VuZXJhdGluZyBuZXcgZHJhZnRzIGR1cmluZyBjb3B5aW5nXG5cdFx0c3RhdGUuZmluYWxpemVkXyA9IHRydWVcblx0XHRjb3B5ID0gc2hhbGxvd0NvcHkodmFsdWUsIHN0YXRlLnNjb3BlXy5pbW1lcl8udXNlU3RyaWN0U2hhbGxvd0NvcHlfKVxuXHR9IGVsc2Uge1xuXHRcdGNvcHkgPSBzaGFsbG93Q29weSh2YWx1ZSwgdHJ1ZSlcblx0fVxuXHQvLyByZWN1cnNlXG5cdGVhY2goY29weSwgKGtleSwgY2hpbGRWYWx1ZSkgPT4ge1xuXHRcdHNldChjb3B5LCBrZXksIGN1cnJlbnRJbXBsKGNoaWxkVmFsdWUpKVxuXHR9KVxuXHRpZiAoc3RhdGUpIHtcblx0XHRzdGF0ZS5maW5hbGl6ZWRfID0gZmFsc2Vcblx0fVxuXHRyZXR1cm4gY29weVxufVxuIiwgImltcG9ydCB7aW1tZXJhYmxlfSBmcm9tIFwiLi4vaW1tZXJcIlxuaW1wb3J0IHtcblx0SW1tZXJTdGF0ZSxcblx0UGF0Y2gsXG5cdFNldFN0YXRlLFxuXHRQcm94eUFycmF5U3RhdGUsXG5cdE1hcFN0YXRlLFxuXHRQcm94eU9iamVjdFN0YXRlLFxuXHRQYXRjaFBhdGgsXG5cdGdldCxcblx0ZWFjaCxcblx0aGFzLFxuXHRnZXRBcmNodHlwZSxcblx0Z2V0UHJvdG90eXBlT2YsXG5cdGlzU2V0LFxuXHRpc01hcCxcblx0bG9hZFBsdWdpbixcblx0QXJjaFR5cGUsXG5cdGRpZSxcblx0aXNEcmFmdCxcblx0aXNEcmFmdGFibGUsXG5cdE5PVEhJTkcsXG5cdGVycm9yc1xufSBmcm9tIFwiLi4vaW50ZXJuYWxcIlxuXG5leHBvcnQgZnVuY3Rpb24gZW5hYmxlUGF0Y2hlcygpIHtcblx0Y29uc3QgZXJyb3JPZmZzZXQgPSAxNlxuXHRpZiAocHJvY2Vzcy5lbnYuTk9ERV9FTlYgIT09IFwicHJvZHVjdGlvblwiKSB7XG5cdFx0ZXJyb3JzLnB1c2goXG5cdFx0XHQnU2V0cyBjYW5ub3QgaGF2ZSBcInJlcGxhY2VcIiBwYXRjaGVzLicsXG5cdFx0XHRmdW5jdGlvbihvcDogc3RyaW5nKSB7XG5cdFx0XHRcdHJldHVybiBcIlVuc3VwcG9ydGVkIHBhdGNoIG9wZXJhdGlvbjogXCIgKyBvcFxuXHRcdFx0fSxcblx0XHRcdGZ1bmN0aW9uKHBhdGg6IHN0cmluZykge1xuXHRcdFx0XHRyZXR1cm4gXCJDYW5ub3QgYXBwbHkgcGF0Y2gsIHBhdGggZG9lc24ndCByZXNvbHZlOiBcIiArIHBhdGhcblx0XHRcdH0sXG5cdFx0XHRcIlBhdGNoaW5nIHJlc2VydmVkIGF0dHJpYnV0ZXMgbGlrZSBfX3Byb3RvX18sIHByb3RvdHlwZSBhbmQgY29uc3RydWN0b3IgaXMgbm90IGFsbG93ZWRcIlxuXHRcdClcblx0fVxuXG5cdGNvbnN0IFJFUExBQ0UgPSBcInJlcGxhY2VcIlxuXHRjb25zdCBBREQgPSBcImFkZFwiXG5cdGNvbnN0IFJFTU9WRSA9IFwicmVtb3ZlXCJcblxuXHRmdW5jdGlvbiBnZW5lcmF0ZVBhdGNoZXNfKFxuXHRcdHN0YXRlOiBJbW1lclN0YXRlLFxuXHRcdGJhc2VQYXRoOiBQYXRjaFBhdGgsXG5cdFx0cGF0Y2hlczogUGF0Y2hbXSxcblx0XHRpbnZlcnNlUGF0Y2hlczogUGF0Y2hbXVxuXHQpOiB2b2lkIHtcblx0XHRzd2l0Y2ggKHN0YXRlLnR5cGVfKSB7XG5cdFx0XHRjYXNlIEFyY2hUeXBlLk9iamVjdDpcblx0XHRcdGNhc2UgQXJjaFR5cGUuTWFwOlxuXHRcdFx0XHRyZXR1cm4gZ2VuZXJhdGVQYXRjaGVzRnJvbUFzc2lnbmVkKFxuXHRcdFx0XHRcdHN0YXRlLFxuXHRcdFx0XHRcdGJhc2VQYXRoLFxuXHRcdFx0XHRcdHBhdGNoZXMsXG5cdFx0XHRcdFx0aW52ZXJzZVBhdGNoZXNcblx0XHRcdFx0KVxuXHRcdFx0Y2FzZSBBcmNoVHlwZS5BcnJheTpcblx0XHRcdFx0cmV0dXJuIGdlbmVyYXRlQXJyYXlQYXRjaGVzKHN0YXRlLCBiYXNlUGF0aCwgcGF0Y2hlcywgaW52ZXJzZVBhdGNoZXMpXG5cdFx0XHRjYXNlIEFyY2hUeXBlLlNldDpcblx0XHRcdFx0cmV0dXJuIGdlbmVyYXRlU2V0UGF0Y2hlcyhcblx0XHRcdFx0XHQoc3RhdGUgYXMgYW55KSBhcyBTZXRTdGF0ZSxcblx0XHRcdFx0XHRiYXNlUGF0aCxcblx0XHRcdFx0XHRwYXRjaGVzLFxuXHRcdFx0XHRcdGludmVyc2VQYXRjaGVzXG5cdFx0XHRcdClcblx0XHR9XG5cdH1cblxuXHRmdW5jdGlvbiBnZW5lcmF0ZUFycmF5UGF0Y2hlcyhcblx0XHRzdGF0ZTogUHJveHlBcnJheVN0YXRlLFxuXHRcdGJhc2VQYXRoOiBQYXRjaFBhdGgsXG5cdFx0cGF0Y2hlczogUGF0Y2hbXSxcblx0XHRpbnZlcnNlUGF0Y2hlczogUGF0Y2hbXVxuXHQpIHtcblx0XHRsZXQge2Jhc2VfLCBhc3NpZ25lZF99ID0gc3RhdGVcblx0XHRsZXQgY29weV8gPSBzdGF0ZS5jb3B5XyFcblxuXHRcdC8vIFJlZHVjZSBjb21wbGV4aXR5IGJ5IGVuc3VyaW5nIGBiYXNlYCBpcyBuZXZlciBsb25nZXIuXG5cdFx0aWYgKGNvcHlfLmxlbmd0aCA8IGJhc2VfLmxlbmd0aCkge1xuXHRcdFx0Ly8gQHRzLWlnbm9yZVxuXHRcdFx0O1tiYXNlXywgY29weV9dID0gW2NvcHlfLCBiYXNlX11cblx0XHRcdDtbcGF0Y2hlcywgaW52ZXJzZVBhdGNoZXNdID0gW2ludmVyc2VQYXRjaGVzLCBwYXRjaGVzXVxuXHRcdH1cblxuXHRcdC8vIFByb2Nlc3MgcmVwbGFjZWQgaW5kaWNlcy5cblx0XHRmb3IgKGxldCBpID0gMDsgaSA8IGJhc2VfLmxlbmd0aDsgaSsrKSB7XG5cdFx0XHRpZiAoYXNzaWduZWRfW2ldICYmIGNvcHlfW2ldICE9PSBiYXNlX1tpXSkge1xuXHRcdFx0XHRjb25zdCBwYXRoID0gYmFzZVBhdGguY29uY2F0KFtpXSlcblx0XHRcdFx0cGF0Y2hlcy5wdXNoKHtcblx0XHRcdFx0XHRvcDogUkVQTEFDRSxcblx0XHRcdFx0XHRwYXRoLFxuXHRcdFx0XHRcdC8vIE5lZWQgdG8gbWF5YmUgY2xvbmUgaXQsIGFzIGl0IGNhbiBpbiBmYWN0IGJlIHRoZSBvcmlnaW5hbCB2YWx1ZVxuXHRcdFx0XHRcdC8vIGR1ZSB0byB0aGUgYmFzZS9jb3B5IGludmVyc2lvbiBhdCB0aGUgc3RhcnQgb2YgdGhpcyBmdW5jdGlvblxuXHRcdFx0XHRcdHZhbHVlOiBjbG9uZVBhdGNoVmFsdWVJZk5lZWRlZChjb3B5X1tpXSlcblx0XHRcdFx0fSlcblx0XHRcdFx0aW52ZXJzZVBhdGNoZXMucHVzaCh7XG5cdFx0XHRcdFx0b3A6IFJFUExBQ0UsXG5cdFx0XHRcdFx0cGF0aCxcblx0XHRcdFx0XHR2YWx1ZTogY2xvbmVQYXRjaFZhbHVlSWZOZWVkZWQoYmFzZV9baV0pXG5cdFx0XHRcdH0pXG5cdFx0XHR9XG5cdFx0fVxuXG5cdFx0Ly8gUHJvY2VzcyBhZGRlZCBpbmRpY2VzLlxuXHRcdGZvciAobGV0IGkgPSBiYXNlXy5sZW5ndGg7IGkgPCBjb3B5Xy5sZW5ndGg7IGkrKykge1xuXHRcdFx0Y29uc3QgcGF0aCA9IGJhc2VQYXRoLmNvbmNhdChbaV0pXG5cdFx0XHRwYXRjaGVzLnB1c2goe1xuXHRcdFx0XHRvcDogQURELFxuXHRcdFx0XHRwYXRoLFxuXHRcdFx0XHQvLyBOZWVkIHRvIG1heWJlIGNsb25lIGl0LCBhcyBpdCBjYW4gaW4gZmFjdCBiZSB0aGUgb3JpZ2luYWwgdmFsdWVcblx0XHRcdFx0Ly8gZHVlIHRvIHRoZSBiYXNlL2NvcHkgaW52ZXJzaW9uIGF0IHRoZSBzdGFydCBvZiB0aGlzIGZ1bmN0aW9uXG5cdFx0XHRcdHZhbHVlOiBjbG9uZVBhdGNoVmFsdWVJZk5lZWRlZChjb3B5X1tpXSlcblx0XHRcdH0pXG5cdFx0fVxuXHRcdGZvciAobGV0IGkgPSBjb3B5Xy5sZW5ndGggLSAxOyBiYXNlXy5sZW5ndGggPD0gaTsgLS1pKSB7XG5cdFx0XHRjb25zdCBwYXRoID0gYmFzZVBhdGguY29uY2F0KFtpXSlcblx0XHRcdGludmVyc2VQYXRjaGVzLnB1c2goe1xuXHRcdFx0XHRvcDogUkVNT1ZFLFxuXHRcdFx0XHRwYXRoXG5cdFx0XHR9KVxuXHRcdH1cblx0fVxuXG5cdC8vIFRoaXMgaXMgdXNlZCBmb3IgYm90aCBNYXAgb2JqZWN0cyBhbmQgbm9ybWFsIG9iamVjdHMuXG5cdGZ1bmN0aW9uIGdlbmVyYXRlUGF0Y2hlc0Zyb21Bc3NpZ25lZChcblx0XHRzdGF0ZTogTWFwU3RhdGUgfCBQcm94eU9iamVjdFN0YXRlLFxuXHRcdGJhc2VQYXRoOiBQYXRjaFBhdGgsXG5cdFx0cGF0Y2hlczogUGF0Y2hbXSxcblx0XHRpbnZlcnNlUGF0Y2hlczogUGF0Y2hbXVxuXHQpIHtcblx0XHRjb25zdCB7YmFzZV8sIGNvcHlffSA9IHN0YXRlXG5cdFx0ZWFjaChzdGF0ZS5hc3NpZ25lZF8hLCAoa2V5LCBhc3NpZ25lZFZhbHVlKSA9PiB7XG5cdFx0XHRjb25zdCBvcmlnVmFsdWUgPSBnZXQoYmFzZV8sIGtleSlcblx0XHRcdGNvbnN0IHZhbHVlID0gZ2V0KGNvcHlfISwga2V5KVxuXHRcdFx0Y29uc3Qgb3AgPSAhYXNzaWduZWRWYWx1ZSA/IFJFTU9WRSA6IGhhcyhiYXNlXywga2V5KSA/IFJFUExBQ0UgOiBBRERcblx0XHRcdGlmIChvcmlnVmFsdWUgPT09IHZhbHVlICYmIG9wID09PSBSRVBMQUNFKSByZXR1cm5cblx0XHRcdGNvbnN0IHBhdGggPSBiYXNlUGF0aC5jb25jYXQoa2V5IGFzIGFueSlcblx0XHRcdHBhdGNoZXMucHVzaChvcCA9PT0gUkVNT1ZFID8ge29wLCBwYXRofSA6IHtvcCwgcGF0aCwgdmFsdWV9KVxuXHRcdFx0aW52ZXJzZVBhdGNoZXMucHVzaChcblx0XHRcdFx0b3AgPT09IEFERFxuXHRcdFx0XHRcdD8ge29wOiBSRU1PVkUsIHBhdGh9XG5cdFx0XHRcdFx0OiBvcCA9PT0gUkVNT1ZFXG5cdFx0XHRcdFx0PyB7b3A6IEFERCwgcGF0aCwgdmFsdWU6IGNsb25lUGF0Y2hWYWx1ZUlmTmVlZGVkKG9yaWdWYWx1ZSl9XG5cdFx0XHRcdFx0OiB7b3A6IFJFUExBQ0UsIHBhdGgsIHZhbHVlOiBjbG9uZVBhdGNoVmFsdWVJZk5lZWRlZChvcmlnVmFsdWUpfVxuXHRcdFx0KVxuXHRcdH0pXG5cdH1cblxuXHRmdW5jdGlvbiBnZW5lcmF0ZVNldFBhdGNoZXMoXG5cdFx0c3RhdGU6IFNldFN0YXRlLFxuXHRcdGJhc2VQYXRoOiBQYXRjaFBhdGgsXG5cdFx0cGF0Y2hlczogUGF0Y2hbXSxcblx0XHRpbnZlcnNlUGF0Y2hlczogUGF0Y2hbXVxuXHQpIHtcblx0XHRsZXQge2Jhc2VfLCBjb3B5X30gPSBzdGF0ZVxuXG5cdFx0bGV0IGkgPSAwXG5cdFx0YmFzZV8uZm9yRWFjaCgodmFsdWU6IGFueSkgPT4ge1xuXHRcdFx0aWYgKCFjb3B5XyEuaGFzKHZhbHVlKSkge1xuXHRcdFx0XHRjb25zdCBwYXRoID0gYmFzZVBhdGguY29uY2F0KFtpXSlcblx0XHRcdFx0cGF0Y2hlcy5wdXNoKHtcblx0XHRcdFx0XHRvcDogUkVNT1ZFLFxuXHRcdFx0XHRcdHBhdGgsXG5cdFx0XHRcdFx0dmFsdWVcblx0XHRcdFx0fSlcblx0XHRcdFx0aW52ZXJzZVBhdGNoZXMudW5zaGlmdCh7XG5cdFx0XHRcdFx0b3A6IEFERCxcblx0XHRcdFx0XHRwYXRoLFxuXHRcdFx0XHRcdHZhbHVlXG5cdFx0XHRcdH0pXG5cdFx0XHR9XG5cdFx0XHRpKytcblx0XHR9KVxuXHRcdGkgPSAwXG5cdFx0Y29weV8hLmZvckVhY2goKHZhbHVlOiBhbnkpID0+IHtcblx0XHRcdGlmICghYmFzZV8uaGFzKHZhbHVlKSkge1xuXHRcdFx0XHRjb25zdCBwYXRoID0gYmFzZVBhdGguY29uY2F0KFtpXSlcblx0XHRcdFx0cGF0Y2hlcy5wdXNoKHtcblx0XHRcdFx0XHRvcDogQURELFxuXHRcdFx0XHRcdHBhdGgsXG5cdFx0XHRcdFx0dmFsdWVcblx0XHRcdFx0fSlcblx0XHRcdFx0aW52ZXJzZVBhdGNoZXMudW5zaGlmdCh7XG5cdFx0XHRcdFx0b3A6IFJFTU9WRSxcblx0XHRcdFx0XHRwYXRoLFxuXHRcdFx0XHRcdHZhbHVlXG5cdFx0XHRcdH0pXG5cdFx0XHR9XG5cdFx0XHRpKytcblx0XHR9KVxuXHR9XG5cblx0ZnVuY3Rpb24gZ2VuZXJhdGVSZXBsYWNlbWVudFBhdGNoZXNfKFxuXHRcdGJhc2VWYWx1ZTogYW55LFxuXHRcdHJlcGxhY2VtZW50OiBhbnksXG5cdFx0cGF0Y2hlczogUGF0Y2hbXSxcblx0XHRpbnZlcnNlUGF0Y2hlczogUGF0Y2hbXVxuXHQpOiB2b2lkIHtcblx0XHRwYXRjaGVzLnB1c2goe1xuXHRcdFx0b3A6IFJFUExBQ0UsXG5cdFx0XHRwYXRoOiBbXSxcblx0XHRcdHZhbHVlOiByZXBsYWNlbWVudCA9PT0gTk9USElORyA/IHVuZGVmaW5lZCA6IHJlcGxhY2VtZW50XG5cdFx0fSlcblx0XHRpbnZlcnNlUGF0Y2hlcy5wdXNoKHtcblx0XHRcdG9wOiBSRVBMQUNFLFxuXHRcdFx0cGF0aDogW10sXG5cdFx0XHR2YWx1ZTogYmFzZVZhbHVlXG5cdFx0fSlcblx0fVxuXG5cdGZ1bmN0aW9uIGFwcGx5UGF0Y2hlc188VD4oZHJhZnQ6IFQsIHBhdGNoZXM6IFBhdGNoW10pOiBUIHtcblx0XHRwYXRjaGVzLmZvckVhY2gocGF0Y2ggPT4ge1xuXHRcdFx0Y29uc3Qge3BhdGgsIG9wfSA9IHBhdGNoXG5cblx0XHRcdGxldCBiYXNlOiBhbnkgPSBkcmFmdFxuXHRcdFx0Zm9yIChsZXQgaSA9IDA7IGkgPCBwYXRoLmxlbmd0aCAtIDE7IGkrKykge1xuXHRcdFx0XHRjb25zdCBwYXJlbnRUeXBlID0gZ2V0QXJjaHR5cGUoYmFzZSlcblx0XHRcdFx0bGV0IHAgPSBwYXRoW2ldXG5cdFx0XHRcdGlmICh0eXBlb2YgcCAhPT0gXCJzdHJpbmdcIiAmJiB0eXBlb2YgcCAhPT0gXCJudW1iZXJcIikge1xuXHRcdFx0XHRcdHAgPSBcIlwiICsgcFxuXHRcdFx0XHR9XG5cblx0XHRcdFx0Ly8gU2VlICM3MzgsIGF2b2lkIHByb3RvdHlwZSBwb2xsdXRpb25cblx0XHRcdFx0aWYgKFxuXHRcdFx0XHRcdChwYXJlbnRUeXBlID09PSBBcmNoVHlwZS5PYmplY3QgfHwgcGFyZW50VHlwZSA9PT0gQXJjaFR5cGUuQXJyYXkpICYmXG5cdFx0XHRcdFx0KHAgPT09IFwiX19wcm90b19fXCIgfHwgcCA9PT0gXCJjb25zdHJ1Y3RvclwiKVxuXHRcdFx0XHQpXG5cdFx0XHRcdFx0ZGllKGVycm9yT2Zmc2V0ICsgMylcblx0XHRcdFx0aWYgKHR5cGVvZiBiYXNlID09PSBcImZ1bmN0aW9uXCIgJiYgcCA9PT0gXCJwcm90b3R5cGVcIilcblx0XHRcdFx0XHRkaWUoZXJyb3JPZmZzZXQgKyAzKVxuXHRcdFx0XHRiYXNlID0gZ2V0KGJhc2UsIHApXG5cdFx0XHRcdGlmICh0eXBlb2YgYmFzZSAhPT0gXCJvYmplY3RcIikgZGllKGVycm9yT2Zmc2V0ICsgMiwgcGF0aC5qb2luKFwiL1wiKSlcblx0XHRcdH1cblxuXHRcdFx0Y29uc3QgdHlwZSA9IGdldEFyY2h0eXBlKGJhc2UpXG5cdFx0XHRjb25zdCB2YWx1ZSA9IGRlZXBDbG9uZVBhdGNoVmFsdWUocGF0Y2gudmFsdWUpIC8vIHVzZWQgdG8gY2xvbmUgcGF0Y2ggdG8gZW5zdXJlIG9yaWdpbmFsIHBhdGNoIGlzIG5vdCBtb2RpZmllZCwgc2VlICM0MTFcblx0XHRcdGNvbnN0IGtleSA9IHBhdGhbcGF0aC5sZW5ndGggLSAxXVxuXHRcdFx0c3dpdGNoIChvcCkge1xuXHRcdFx0XHRjYXNlIFJFUExBQ0U6XG5cdFx0XHRcdFx0c3dpdGNoICh0eXBlKSB7XG5cdFx0XHRcdFx0XHRjYXNlIEFyY2hUeXBlLk1hcDpcblx0XHRcdFx0XHRcdFx0cmV0dXJuIGJhc2Uuc2V0KGtleSwgdmFsdWUpXG5cdFx0XHRcdFx0XHQvKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xuXHRcdFx0XHRcdFx0Y2FzZSBBcmNoVHlwZS5TZXQ6XG5cdFx0XHRcdFx0XHRcdGRpZShlcnJvck9mZnNldClcblx0XHRcdFx0XHRcdGRlZmF1bHQ6XG5cdFx0XHRcdFx0XHRcdC8vIGlmIHZhbHVlIGlzIGFuIG9iamVjdCwgdGhlbiBpdCdzIGFzc2lnbmVkIGJ5IHJlZmVyZW5jZVxuXHRcdFx0XHRcdFx0XHQvLyBpbiB0aGUgZm9sbG93aW5nIGFkZCBvciByZW1vdmUgb3BzLCB0aGUgdmFsdWUgZmllbGQgaW5zaWRlIHRoZSBwYXRjaCB3aWxsIGFsc28gYmUgbW9kaWZ5ZWRcblx0XHRcdFx0XHRcdFx0Ly8gc28gd2UgdXNlIHZhbHVlIGZyb20gdGhlIGNsb25lZCBwYXRjaFxuXHRcdFx0XHRcdFx0XHQvLyBAdHMtaWdub3JlXG5cdFx0XHRcdFx0XHRcdHJldHVybiAoYmFzZVtrZXldID0gdmFsdWUpXG5cdFx0XHRcdFx0fVxuXHRcdFx0XHRjYXNlIEFERDpcblx0XHRcdFx0XHRzd2l0Y2ggKHR5cGUpIHtcblx0XHRcdFx0XHRcdGNhc2UgQXJjaFR5cGUuQXJyYXk6XG5cdFx0XHRcdFx0XHRcdHJldHVybiBrZXkgPT09IFwiLVwiXG5cdFx0XHRcdFx0XHRcdFx0PyBiYXNlLnB1c2godmFsdWUpXG5cdFx0XHRcdFx0XHRcdFx0OiBiYXNlLnNwbGljZShrZXkgYXMgYW55LCAwLCB2YWx1ZSlcblx0XHRcdFx0XHRcdGNhc2UgQXJjaFR5cGUuTWFwOlxuXHRcdFx0XHRcdFx0XHRyZXR1cm4gYmFzZS5zZXQoa2V5LCB2YWx1ZSlcblx0XHRcdFx0XHRcdGNhc2UgQXJjaFR5cGUuU2V0OlxuXHRcdFx0XHRcdFx0XHRyZXR1cm4gYmFzZS5hZGQodmFsdWUpXG5cdFx0XHRcdFx0XHRkZWZhdWx0OlxuXHRcdFx0XHRcdFx0XHRyZXR1cm4gKGJhc2Vba2V5XSA9IHZhbHVlKVxuXHRcdFx0XHRcdH1cblx0XHRcdFx0Y2FzZSBSRU1PVkU6XG5cdFx0XHRcdFx0c3dpdGNoICh0eXBlKSB7XG5cdFx0XHRcdFx0XHRjYXNlIEFyY2hUeXBlLkFycmF5OlxuXHRcdFx0XHRcdFx0XHRyZXR1cm4gYmFzZS5zcGxpY2Uoa2V5IGFzIGFueSwgMSlcblx0XHRcdFx0XHRcdGNhc2UgQXJjaFR5cGUuTWFwOlxuXHRcdFx0XHRcdFx0XHRyZXR1cm4gYmFzZS5kZWxldGUoa2V5KVxuXHRcdFx0XHRcdFx0Y2FzZSBBcmNoVHlwZS5TZXQ6XG5cdFx0XHRcdFx0XHRcdHJldHVybiBiYXNlLmRlbGV0ZShwYXRjaC52YWx1ZSlcblx0XHRcdFx0XHRcdGRlZmF1bHQ6XG5cdFx0XHRcdFx0XHRcdHJldHVybiBkZWxldGUgYmFzZVtrZXldXG5cdFx0XHRcdFx0fVxuXHRcdFx0XHRkZWZhdWx0OlxuXHRcdFx0XHRcdGRpZShlcnJvck9mZnNldCArIDEsIG9wKVxuXHRcdFx0fVxuXHRcdH0pXG5cblx0XHRyZXR1cm4gZHJhZnRcblx0fVxuXG5cdC8vIG9wdGltaXplOiB0aGlzIGlzIHF1aXRlIGEgcGVyZm9ybWFuY2UgaGl0LCBjYW4gd2UgZGV0ZWN0IGludGVsbGlnZW50bHkgd2hlbiBpdCBpcyBuZWVkZWQ/XG5cdC8vIEUuZy4gYXV0by1kcmFmdCB3aGVuIG5ldyBvYmplY3RzIGZyb20gb3V0c2lkZSBhcmUgYXNzaWduZWQgYW5kIG1vZGlmaWVkP1xuXHQvLyAoU2VlIGZhaWxpbmcgdGVzdCB3aGVuIGRlZXBDbG9uZSBqdXN0IHJldHVybnMgb2JqKVxuXHRmdW5jdGlvbiBkZWVwQ2xvbmVQYXRjaFZhbHVlPFQ+KG9iajogVCk6IFRcblx0ZnVuY3Rpb24gZGVlcENsb25lUGF0Y2hWYWx1ZShvYmo6IGFueSkge1xuXHRcdGlmICghaXNEcmFmdGFibGUob2JqKSkgcmV0dXJuIG9ialxuXHRcdGlmIChBcnJheS5pc0FycmF5KG9iaikpIHJldHVybiBvYmoubWFwKGRlZXBDbG9uZVBhdGNoVmFsdWUpXG5cdFx0aWYgKGlzTWFwKG9iaikpXG5cdFx0XHRyZXR1cm4gbmV3IE1hcChcblx0XHRcdFx0QXJyYXkuZnJvbShvYmouZW50cmllcygpKS5tYXAoKFtrLCB2XSkgPT4gW2ssIGRlZXBDbG9uZVBhdGNoVmFsdWUodildKVxuXHRcdFx0KVxuXHRcdGlmIChpc1NldChvYmopKSByZXR1cm4gbmV3IFNldChBcnJheS5mcm9tKG9iaikubWFwKGRlZXBDbG9uZVBhdGNoVmFsdWUpKVxuXHRcdGNvbnN0IGNsb25lZCA9IE9iamVjdC5jcmVhdGUoZ2V0UHJvdG90eXBlT2Yob2JqKSlcblx0XHRmb3IgKGNvbnN0IGtleSBpbiBvYmopIGNsb25lZFtrZXldID0gZGVlcENsb25lUGF0Y2hWYWx1ZShvYmpba2V5XSlcblx0XHRpZiAoaGFzKG9iaiwgaW1tZXJhYmxlKSkgY2xvbmVkW2ltbWVyYWJsZV0gPSBvYmpbaW1tZXJhYmxlXVxuXHRcdHJldHVybiBjbG9uZWRcblx0fVxuXG5cdGZ1bmN0aW9uIGNsb25lUGF0Y2hWYWx1ZUlmTmVlZGVkPFQ+KG9iajogVCk6IFQge1xuXHRcdGlmIChpc0RyYWZ0KG9iaikpIHtcblx0XHRcdHJldHVybiBkZWVwQ2xvbmVQYXRjaFZhbHVlKG9iailcblx0XHR9IGVsc2UgcmV0dXJuIG9ialxuXHR9XG5cblx0bG9hZFBsdWdpbihcIlBhdGNoZXNcIiwge1xuXHRcdGFwcGx5UGF0Y2hlc18sXG5cdFx0Z2VuZXJhdGVQYXRjaGVzXyxcblx0XHRnZW5lcmF0ZVJlcGxhY2VtZW50UGF0Y2hlc19cblx0fSlcbn1cbiIsICIvLyB0eXBlcyBvbmx5IVxuaW1wb3J0IHtcblx0SW1tZXJTdGF0ZSxcblx0QW55TWFwLFxuXHRBbnlTZXQsXG5cdE1hcFN0YXRlLFxuXHRTZXRTdGF0ZSxcblx0RFJBRlRfU1RBVEUsXG5cdGdldEN1cnJlbnRTY29wZSxcblx0bGF0ZXN0LFxuXHRpc0RyYWZ0YWJsZSxcblx0Y3JlYXRlUHJveHksXG5cdGxvYWRQbHVnaW4sXG5cdG1hcmtDaGFuZ2VkLFxuXHRkaWUsXG5cdEFyY2hUeXBlLFxuXHRlYWNoXG59IGZyb20gXCIuLi9pbnRlcm5hbFwiXG5cbmV4cG9ydCBmdW5jdGlvbiBlbmFibGVNYXBTZXQoKSB7XG5cdGNsYXNzIERyYWZ0TWFwIGV4dGVuZHMgTWFwIHtcblx0XHRbRFJBRlRfU1RBVEVdOiBNYXBTdGF0ZVxuXG5cdFx0Y29uc3RydWN0b3IodGFyZ2V0OiBBbnlNYXAsIHBhcmVudD86IEltbWVyU3RhdGUpIHtcblx0XHRcdHN1cGVyKClcblx0XHRcdHRoaXNbRFJBRlRfU1RBVEVdID0ge1xuXHRcdFx0XHR0eXBlXzogQXJjaFR5cGUuTWFwLFxuXHRcdFx0XHRwYXJlbnRfOiBwYXJlbnQsXG5cdFx0XHRcdHNjb3BlXzogcGFyZW50ID8gcGFyZW50LnNjb3BlXyA6IGdldEN1cnJlbnRTY29wZSgpISxcblx0XHRcdFx0bW9kaWZpZWRfOiBmYWxzZSxcblx0XHRcdFx0ZmluYWxpemVkXzogZmFsc2UsXG5cdFx0XHRcdGNvcHlfOiB1bmRlZmluZWQsXG5cdFx0XHRcdGFzc2lnbmVkXzogdW5kZWZpbmVkLFxuXHRcdFx0XHRiYXNlXzogdGFyZ2V0LFxuXHRcdFx0XHRkcmFmdF86IHRoaXMgYXMgYW55LFxuXHRcdFx0XHRpc01hbnVhbF86IGZhbHNlLFxuXHRcdFx0XHRyZXZva2VkXzogZmFsc2Vcblx0XHRcdH1cblx0XHR9XG5cblx0XHRnZXQgc2l6ZSgpOiBudW1iZXIge1xuXHRcdFx0cmV0dXJuIGxhdGVzdCh0aGlzW0RSQUZUX1NUQVRFXSkuc2l6ZVxuXHRcdH1cblxuXHRcdGhhcyhrZXk6IGFueSk6IGJvb2xlYW4ge1xuXHRcdFx0cmV0dXJuIGxhdGVzdCh0aGlzW0RSQUZUX1NUQVRFXSkuaGFzKGtleSlcblx0XHR9XG5cblx0XHRzZXQoa2V5OiBhbnksIHZhbHVlOiBhbnkpIHtcblx0XHRcdGNvbnN0IHN0YXRlOiBNYXBTdGF0ZSA9IHRoaXNbRFJBRlRfU1RBVEVdXG5cdFx0XHRhc3NlcnRVbnJldm9rZWQoc3RhdGUpXG5cdFx0XHRpZiAoIWxhdGVzdChzdGF0ZSkuaGFzKGtleSkgfHwgbGF0ZXN0KHN0YXRlKS5nZXQoa2V5KSAhPT0gdmFsdWUpIHtcblx0XHRcdFx0cHJlcGFyZU1hcENvcHkoc3RhdGUpXG5cdFx0XHRcdG1hcmtDaGFuZ2VkKHN0YXRlKVxuXHRcdFx0XHRzdGF0ZS5hc3NpZ25lZF8hLnNldChrZXksIHRydWUpXG5cdFx0XHRcdHN0YXRlLmNvcHlfIS5zZXQoa2V5LCB2YWx1ZSlcblx0XHRcdFx0c3RhdGUuYXNzaWduZWRfIS5zZXQoa2V5LCB0cnVlKVxuXHRcdFx0fVxuXHRcdFx0cmV0dXJuIHRoaXNcblx0XHR9XG5cblx0XHRkZWxldGUoa2V5OiBhbnkpOiBib29sZWFuIHtcblx0XHRcdGlmICghdGhpcy5oYXMoa2V5KSkge1xuXHRcdFx0XHRyZXR1cm4gZmFsc2Vcblx0XHRcdH1cblxuXHRcdFx0Y29uc3Qgc3RhdGU6IE1hcFN0YXRlID0gdGhpc1tEUkFGVF9TVEFURV1cblx0XHRcdGFzc2VydFVucmV2b2tlZChzdGF0ZSlcblx0XHRcdHByZXBhcmVNYXBDb3B5KHN0YXRlKVxuXHRcdFx0bWFya0NoYW5nZWQoc3RhdGUpXG5cdFx0XHRpZiAoc3RhdGUuYmFzZV8uaGFzKGtleSkpIHtcblx0XHRcdFx0c3RhdGUuYXNzaWduZWRfIS5zZXQoa2V5LCBmYWxzZSlcblx0XHRcdH0gZWxzZSB7XG5cdFx0XHRcdHN0YXRlLmFzc2lnbmVkXyEuZGVsZXRlKGtleSlcblx0XHRcdH1cblx0XHRcdHN0YXRlLmNvcHlfIS5kZWxldGUoa2V5KVxuXHRcdFx0cmV0dXJuIHRydWVcblx0XHR9XG5cblx0XHRjbGVhcigpIHtcblx0XHRcdGNvbnN0IHN0YXRlOiBNYXBTdGF0ZSA9IHRoaXNbRFJBRlRfU1RBVEVdXG5cdFx0XHRhc3NlcnRVbnJldm9rZWQoc3RhdGUpXG5cdFx0XHRpZiAobGF0ZXN0KHN0YXRlKS5zaXplKSB7XG5cdFx0XHRcdHByZXBhcmVNYXBDb3B5KHN0YXRlKVxuXHRcdFx0XHRtYXJrQ2hhbmdlZChzdGF0ZSlcblx0XHRcdFx0c3RhdGUuYXNzaWduZWRfID0gbmV3IE1hcCgpXG5cdFx0XHRcdGVhY2goc3RhdGUuYmFzZV8sIGtleSA9PiB7XG5cdFx0XHRcdFx0c3RhdGUuYXNzaWduZWRfIS5zZXQoa2V5LCBmYWxzZSlcblx0XHRcdFx0fSlcblx0XHRcdFx0c3RhdGUuY29weV8hLmNsZWFyKClcblx0XHRcdH1cblx0XHR9XG5cblx0XHRmb3JFYWNoKGNiOiAodmFsdWU6IGFueSwga2V5OiBhbnksIHNlbGY6IGFueSkgPT4gdm9pZCwgdGhpc0FyZz86IGFueSkge1xuXHRcdFx0Y29uc3Qgc3RhdGU6IE1hcFN0YXRlID0gdGhpc1tEUkFGVF9TVEFURV1cblx0XHRcdGxhdGVzdChzdGF0ZSkuZm9yRWFjaCgoX3ZhbHVlOiBhbnksIGtleTogYW55LCBfbWFwOiBhbnkpID0+IHtcblx0XHRcdFx0Y2IuY2FsbCh0aGlzQXJnLCB0aGlzLmdldChrZXkpLCBrZXksIHRoaXMpXG5cdFx0XHR9KVxuXHRcdH1cblxuXHRcdGdldChrZXk6IGFueSk6IGFueSB7XG5cdFx0XHRjb25zdCBzdGF0ZTogTWFwU3RhdGUgPSB0aGlzW0RSQUZUX1NUQVRFXVxuXHRcdFx0YXNzZXJ0VW5yZXZva2VkKHN0YXRlKVxuXHRcdFx0Y29uc3QgdmFsdWUgPSBsYXRlc3Qoc3RhdGUpLmdldChrZXkpXG5cdFx0XHRpZiAoc3RhdGUuZmluYWxpemVkXyB8fCAhaXNEcmFmdGFibGUodmFsdWUpKSB7XG5cdFx0XHRcdHJldHVybiB2YWx1ZVxuXHRcdFx0fVxuXHRcdFx0aWYgKHZhbHVlICE9PSBzdGF0ZS5iYXNlXy5nZXQoa2V5KSkge1xuXHRcdFx0XHRyZXR1cm4gdmFsdWUgLy8gZWl0aGVyIGFscmVhZHkgZHJhZnRlZCBvciByZWFzc2lnbmVkXG5cdFx0XHR9XG5cdFx0XHQvLyBkZXNwaXRlIHdoYXQgaXQgbG9va3MsIHRoaXMgY3JlYXRlcyBhIGRyYWZ0IG9ubHkgb25jZSwgc2VlIGFib3ZlIGNvbmRpdGlvblxuXHRcdFx0Y29uc3QgZHJhZnQgPSBjcmVhdGVQcm94eSh2YWx1ZSwgc3RhdGUpXG5cdFx0XHRwcmVwYXJlTWFwQ29weShzdGF0ZSlcblx0XHRcdHN0YXRlLmNvcHlfIS5zZXQoa2V5LCBkcmFmdClcblx0XHRcdHJldHVybiBkcmFmdFxuXHRcdH1cblxuXHRcdGtleXMoKTogSXRlcmFibGVJdGVyYXRvcjxhbnk+IHtcblx0XHRcdHJldHVybiBsYXRlc3QodGhpc1tEUkFGVF9TVEFURV0pLmtleXMoKVxuXHRcdH1cblxuXHRcdHZhbHVlcygpOiBJdGVyYWJsZUl0ZXJhdG9yPGFueT4ge1xuXHRcdFx0Y29uc3QgaXRlcmF0b3IgPSB0aGlzLmtleXMoKVxuXHRcdFx0cmV0dXJuIHtcblx0XHRcdFx0W1N5bWJvbC5pdGVyYXRvcl06ICgpID0+IHRoaXMudmFsdWVzKCksXG5cdFx0XHRcdG5leHQ6ICgpID0+IHtcblx0XHRcdFx0XHRjb25zdCByID0gaXRlcmF0b3IubmV4dCgpXG5cdFx0XHRcdFx0LyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cblx0XHRcdFx0XHRpZiAoci5kb25lKSByZXR1cm4gclxuXHRcdFx0XHRcdGNvbnN0IHZhbHVlID0gdGhpcy5nZXQoci52YWx1ZSlcblx0XHRcdFx0XHRyZXR1cm4ge1xuXHRcdFx0XHRcdFx0ZG9uZTogZmFsc2UsXG5cdFx0XHRcdFx0XHR2YWx1ZVxuXHRcdFx0XHRcdH1cblx0XHRcdFx0fVxuXHRcdFx0fSBhcyBhbnlcblx0XHR9XG5cblx0XHRlbnRyaWVzKCk6IEl0ZXJhYmxlSXRlcmF0b3I8W2FueSwgYW55XT4ge1xuXHRcdFx0Y29uc3QgaXRlcmF0b3IgPSB0aGlzLmtleXMoKVxuXHRcdFx0cmV0dXJuIHtcblx0XHRcdFx0W1N5bWJvbC5pdGVyYXRvcl06ICgpID0+IHRoaXMuZW50cmllcygpLFxuXHRcdFx0XHRuZXh0OiAoKSA9PiB7XG5cdFx0XHRcdFx0Y29uc3QgciA9IGl0ZXJhdG9yLm5leHQoKVxuXHRcdFx0XHRcdC8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovXG5cdFx0XHRcdFx0aWYgKHIuZG9uZSkgcmV0dXJuIHJcblx0XHRcdFx0XHRjb25zdCB2YWx1ZSA9IHRoaXMuZ2V0KHIudmFsdWUpXG5cdFx0XHRcdFx0cmV0dXJuIHtcblx0XHRcdFx0XHRcdGRvbmU6IGZhbHNlLFxuXHRcdFx0XHRcdFx0dmFsdWU6IFtyLnZhbHVlLCB2YWx1ZV1cblx0XHRcdFx0XHR9XG5cdFx0XHRcdH1cblx0XHRcdH0gYXMgYW55XG5cdFx0fVxuXG5cdFx0W1N5bWJvbC5pdGVyYXRvcl0oKSB7XG5cdFx0XHRyZXR1cm4gdGhpcy5lbnRyaWVzKClcblx0XHR9XG5cdH1cblxuXHRmdW5jdGlvbiBwcm94eU1hcF88VCBleHRlbmRzIEFueU1hcD4odGFyZ2V0OiBULCBwYXJlbnQ/OiBJbW1lclN0YXRlKTogVCB7XG5cdFx0Ly8gQHRzLWlnbm9yZVxuXHRcdHJldHVybiBuZXcgRHJhZnRNYXAodGFyZ2V0LCBwYXJlbnQpXG5cdH1cblxuXHRmdW5jdGlvbiBwcmVwYXJlTWFwQ29weShzdGF0ZTogTWFwU3RhdGUpIHtcblx0XHRpZiAoIXN0YXRlLmNvcHlfKSB7XG5cdFx0XHRzdGF0ZS5hc3NpZ25lZF8gPSBuZXcgTWFwKClcblx0XHRcdHN0YXRlLmNvcHlfID0gbmV3IE1hcChzdGF0ZS5iYXNlXylcblx0XHR9XG5cdH1cblxuXHRjbGFzcyBEcmFmdFNldCBleHRlbmRzIFNldCB7XG5cdFx0W0RSQUZUX1NUQVRFXTogU2V0U3RhdGVcblx0XHRjb25zdHJ1Y3Rvcih0YXJnZXQ6IEFueVNldCwgcGFyZW50PzogSW1tZXJTdGF0ZSkge1xuXHRcdFx0c3VwZXIoKVxuXHRcdFx0dGhpc1tEUkFGVF9TVEFURV0gPSB7XG5cdFx0XHRcdHR5cGVfOiBBcmNoVHlwZS5TZXQsXG5cdFx0XHRcdHBhcmVudF86IHBhcmVudCxcblx0XHRcdFx0c2NvcGVfOiBwYXJlbnQgPyBwYXJlbnQuc2NvcGVfIDogZ2V0Q3VycmVudFNjb3BlKCkhLFxuXHRcdFx0XHRtb2RpZmllZF86IGZhbHNlLFxuXHRcdFx0XHRmaW5hbGl6ZWRfOiBmYWxzZSxcblx0XHRcdFx0Y29weV86IHVuZGVmaW5lZCxcblx0XHRcdFx0YmFzZV86IHRhcmdldCxcblx0XHRcdFx0ZHJhZnRfOiB0aGlzLFxuXHRcdFx0XHRkcmFmdHNfOiBuZXcgTWFwKCksXG5cdFx0XHRcdHJldm9rZWRfOiBmYWxzZSxcblx0XHRcdFx0aXNNYW51YWxfOiBmYWxzZVxuXHRcdFx0fVxuXHRcdH1cblxuXHRcdGdldCBzaXplKCk6IG51bWJlciB7XG5cdFx0XHRyZXR1cm4gbGF0ZXN0KHRoaXNbRFJBRlRfU1RBVEVdKS5zaXplXG5cdFx0fVxuXG5cdFx0aGFzKHZhbHVlOiBhbnkpOiBib29sZWFuIHtcblx0XHRcdGNvbnN0IHN0YXRlOiBTZXRTdGF0ZSA9IHRoaXNbRFJBRlRfU1RBVEVdXG5cdFx0XHRhc3NlcnRVbnJldm9rZWQoc3RhdGUpXG5cdFx0XHQvLyBiaXQgb2YgdHJpY2tlcnkgaGVyZSwgdG8gYmUgYWJsZSB0byByZWNvZ25pemUgYm90aCB0aGUgdmFsdWUsIGFuZCB0aGUgZHJhZnQgb2YgaXRzIHZhbHVlXG5cdFx0XHRpZiAoIXN0YXRlLmNvcHlfKSB7XG5cdFx0XHRcdHJldHVybiBzdGF0ZS5iYXNlXy5oYXModmFsdWUpXG5cdFx0XHR9XG5cdFx0XHRpZiAoc3RhdGUuY29weV8uaGFzKHZhbHVlKSkgcmV0dXJuIHRydWVcblx0XHRcdGlmIChzdGF0ZS5kcmFmdHNfLmhhcyh2YWx1ZSkgJiYgc3RhdGUuY29weV8uaGFzKHN0YXRlLmRyYWZ0c18uZ2V0KHZhbHVlKSkpXG5cdFx0XHRcdHJldHVybiB0cnVlXG5cdFx0XHRyZXR1cm4gZmFsc2Vcblx0XHR9XG5cblx0XHRhZGQodmFsdWU6IGFueSk6IGFueSB7XG5cdFx0XHRjb25zdCBzdGF0ZTogU2V0U3RhdGUgPSB0aGlzW0RSQUZUX1NUQVRFXVxuXHRcdFx0YXNzZXJ0VW5yZXZva2VkKHN0YXRlKVxuXHRcdFx0aWYgKCF0aGlzLmhhcyh2YWx1ZSkpIHtcblx0XHRcdFx0cHJlcGFyZVNldENvcHkoc3RhdGUpXG5cdFx0XHRcdG1hcmtDaGFuZ2VkKHN0YXRlKVxuXHRcdFx0XHRzdGF0ZS5jb3B5XyEuYWRkKHZhbHVlKVxuXHRcdFx0fVxuXHRcdFx0cmV0dXJuIHRoaXNcblx0XHR9XG5cblx0XHRkZWxldGUodmFsdWU6IGFueSk6IGFueSB7XG5cdFx0XHRpZiAoIXRoaXMuaGFzKHZhbHVlKSkge1xuXHRcdFx0XHRyZXR1cm4gZmFsc2Vcblx0XHRcdH1cblxuXHRcdFx0Y29uc3Qgc3RhdGU6IFNldFN0YXRlID0gdGhpc1tEUkFGVF9TVEFURV1cblx0XHRcdGFzc2VydFVucmV2b2tlZChzdGF0ZSlcblx0XHRcdHByZXBhcmVTZXRDb3B5KHN0YXRlKVxuXHRcdFx0bWFya0NoYW5nZWQoc3RhdGUpXG5cdFx0XHRyZXR1cm4gKFxuXHRcdFx0XHRzdGF0ZS5jb3B5XyEuZGVsZXRlKHZhbHVlKSB8fFxuXHRcdFx0XHQoc3RhdGUuZHJhZnRzXy5oYXModmFsdWUpXG5cdFx0XHRcdFx0PyBzdGF0ZS5jb3B5XyEuZGVsZXRlKHN0YXRlLmRyYWZ0c18uZ2V0KHZhbHVlKSlcblx0XHRcdFx0XHQ6IC8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovIGZhbHNlKVxuXHRcdFx0KVxuXHRcdH1cblxuXHRcdGNsZWFyKCkge1xuXHRcdFx0Y29uc3Qgc3RhdGU6IFNldFN0YXRlID0gdGhpc1tEUkFGVF9TVEFURV1cblx0XHRcdGFzc2VydFVucmV2b2tlZChzdGF0ZSlcblx0XHRcdGlmIChsYXRlc3Qoc3RhdGUpLnNpemUpIHtcblx0XHRcdFx0cHJlcGFyZVNldENvcHkoc3RhdGUpXG5cdFx0XHRcdG1hcmtDaGFuZ2VkKHN0YXRlKVxuXHRcdFx0XHRzdGF0ZS5jb3B5XyEuY2xlYXIoKVxuXHRcdFx0fVxuXHRcdH1cblxuXHRcdHZhbHVlcygpOiBJdGVyYWJsZUl0ZXJhdG9yPGFueT4ge1xuXHRcdFx0Y29uc3Qgc3RhdGU6IFNldFN0YXRlID0gdGhpc1tEUkFGVF9TVEFURV1cblx0XHRcdGFzc2VydFVucmV2b2tlZChzdGF0ZSlcblx0XHRcdHByZXBhcmVTZXRDb3B5KHN0YXRlKVxuXHRcdFx0cmV0dXJuIHN0YXRlLmNvcHlfIS52YWx1ZXMoKVxuXHRcdH1cblxuXHRcdGVudHJpZXMoKTogSXRlcmFibGVJdGVyYXRvcjxbYW55LCBhbnldPiB7XG5cdFx0XHRjb25zdCBzdGF0ZTogU2V0U3RhdGUgPSB0aGlzW0RSQUZUX1NUQVRFXVxuXHRcdFx0YXNzZXJ0VW5yZXZva2VkKHN0YXRlKVxuXHRcdFx0cHJlcGFyZVNldENvcHkoc3RhdGUpXG5cdFx0XHRyZXR1cm4gc3RhdGUuY29weV8hLmVudHJpZXMoKVxuXHRcdH1cblxuXHRcdGtleXMoKTogSXRlcmFibGVJdGVyYXRvcjxhbnk+IHtcblx0XHRcdHJldHVybiB0aGlzLnZhbHVlcygpXG5cdFx0fVxuXG5cdFx0W1N5bWJvbC5pdGVyYXRvcl0oKSB7XG5cdFx0XHRyZXR1cm4gdGhpcy52YWx1ZXMoKVxuXHRcdH1cblxuXHRcdGZvckVhY2goY2I6IGFueSwgdGhpc0FyZz86IGFueSkge1xuXHRcdFx0Y29uc3QgaXRlcmF0b3IgPSB0aGlzLnZhbHVlcygpXG5cdFx0XHRsZXQgcmVzdWx0ID0gaXRlcmF0b3IubmV4dCgpXG5cdFx0XHR3aGlsZSAoIXJlc3VsdC5kb25lKSB7XG5cdFx0XHRcdGNiLmNhbGwodGhpc0FyZywgcmVzdWx0LnZhbHVlLCByZXN1bHQudmFsdWUsIHRoaXMpXG5cdFx0XHRcdHJlc3VsdCA9IGl0ZXJhdG9yLm5leHQoKVxuXHRcdFx0fVxuXHRcdH1cblx0fVxuXHRmdW5jdGlvbiBwcm94eVNldF88VCBleHRlbmRzIEFueVNldD4odGFyZ2V0OiBULCBwYXJlbnQ/OiBJbW1lclN0YXRlKTogVCB7XG5cdFx0Ly8gQHRzLWlnbm9yZVxuXHRcdHJldHVybiBuZXcgRHJhZnRTZXQodGFyZ2V0LCBwYXJlbnQpXG5cdH1cblxuXHRmdW5jdGlvbiBwcmVwYXJlU2V0Q29weShzdGF0ZTogU2V0U3RhdGUpIHtcblx0XHRpZiAoIXN0YXRlLmNvcHlfKSB7XG5cdFx0XHQvLyBjcmVhdGUgZHJhZnRzIGZvciBhbGwgZW50cmllcyB0byBwcmVzZXJ2ZSBpbnNlcnRpb24gb3JkZXJcblx0XHRcdHN0YXRlLmNvcHlfID0gbmV3IFNldCgpXG5cdFx0XHRzdGF0ZS5iYXNlXy5mb3JFYWNoKHZhbHVlID0+IHtcblx0XHRcdFx0aWYgKGlzRHJhZnRhYmxlKHZhbHVlKSkge1xuXHRcdFx0XHRcdGNvbnN0IGRyYWZ0ID0gY3JlYXRlUHJveHkodmFsdWUsIHN0YXRlKVxuXHRcdFx0XHRcdHN0YXRlLmRyYWZ0c18uc2V0KHZhbHVlLCBkcmFmdClcblx0XHRcdFx0XHRzdGF0ZS5jb3B5XyEuYWRkKGRyYWZ0KVxuXHRcdFx0XHR9IGVsc2Uge1xuXHRcdFx0XHRcdHN0YXRlLmNvcHlfIS5hZGQodmFsdWUpXG5cdFx0XHRcdH1cblx0XHRcdH0pXG5cdFx0fVxuXHR9XG5cblx0ZnVuY3Rpb24gYXNzZXJ0VW5yZXZva2VkKHN0YXRlOiBhbnkgLypFUzVTdGF0ZSB8IE1hcFN0YXRlIHwgU2V0U3RhdGUqLykge1xuXHRcdGlmIChzdGF0ZS5yZXZva2VkXykgZGllKDMsIEpTT04uc3RyaW5naWZ5KGxhdGVzdChzdGF0ZSkpKVxuXHR9XG5cblx0bG9hZFBsdWdpbihcIk1hcFNldFwiLCB7cHJveHlNYXBfLCBwcm94eVNldF99KVxufVxuIiwgImltcG9ydCB7XG5cdElQcm9kdWNlLFxuXHRJUHJvZHVjZVdpdGhQYXRjaGVzLFxuXHRJbW1lcixcblx0RHJhZnQsXG5cdEltbXV0YWJsZVxufSBmcm9tIFwiLi9pbnRlcm5hbFwiXG5cbmV4cG9ydCB7XG5cdERyYWZ0LFxuXHRJbW11dGFibGUsXG5cdFBhdGNoLFxuXHRQYXRjaExpc3RlbmVyLFxuXHRvcmlnaW5hbCxcblx0Y3VycmVudCxcblx0aXNEcmFmdCxcblx0aXNEcmFmdGFibGUsXG5cdE5PVEhJTkcgYXMgbm90aGluZyxcblx0RFJBRlRBQkxFIGFzIGltbWVyYWJsZSxcblx0ZnJlZXplXG59IGZyb20gXCIuL2ludGVybmFsXCJcblxuY29uc3QgaW1tZXIgPSBuZXcgSW1tZXIoKVxuXG4vKipcbiAqIFRoZSBgcHJvZHVjZWAgZnVuY3Rpb24gdGFrZXMgYSB2YWx1ZSBhbmQgYSBcInJlY2lwZSBmdW5jdGlvblwiICh3aG9zZVxuICogcmV0dXJuIHZhbHVlIG9mdGVuIGRlcGVuZHMgb24gdGhlIGJhc2Ugc3RhdGUpLiBUaGUgcmVjaXBlIGZ1bmN0aW9uIGlzXG4gKiBmcmVlIHRvIG11dGF0ZSBpdHMgZmlyc3QgYXJndW1lbnQgaG93ZXZlciBpdCB3YW50cy4gQWxsIG11dGF0aW9ucyBhcmVcbiAqIG9ubHkgZXZlciBhcHBsaWVkIHRvIGEgX19jb3B5X18gb2YgdGhlIGJhc2Ugc3RhdGUuXG4gKlxuICogUGFzcyBvbmx5IGEgZnVuY3Rpb24gdG8gY3JlYXRlIGEgXCJjdXJyaWVkIHByb2R1Y2VyXCIgd2hpY2ggcmVsaWV2ZXMgeW91XG4gKiBmcm9tIHBhc3NpbmcgdGhlIHJlY2lwZSBmdW5jdGlvbiBldmVyeSB0aW1lLlxuICpcbiAqIE9ubHkgcGxhaW4gb2JqZWN0cyBhbmQgYXJyYXlzIGFyZSBtYWRlIG11dGFibGUuIEFsbCBvdGhlciBvYmplY3RzIGFyZVxuICogY29uc2lkZXJlZCB1bmNvcHlhYmxlLlxuICpcbiAqIE5vdGU6IFRoaXMgZnVuY3Rpb24gaXMgX19ib3VuZF9fIHRvIGl0cyBgSW1tZXJgIGluc3RhbmNlLlxuICpcbiAqIEBwYXJhbSB7YW55fSBiYXNlIC0gdGhlIGluaXRpYWwgc3RhdGVcbiAqIEBwYXJhbSB7RnVuY3Rpb259IHByb2R1Y2VyIC0gZnVuY3Rpb24gdGhhdCByZWNlaXZlcyBhIHByb3h5IG9mIHRoZSBiYXNlIHN0YXRlIGFzIGZpcnN0IGFyZ3VtZW50IGFuZCB3aGljaCBjYW4gYmUgZnJlZWx5IG1vZGlmaWVkXG4gKiBAcGFyYW0ge0Z1bmN0aW9ufSBwYXRjaExpc3RlbmVyIC0gb3B0aW9uYWwgZnVuY3Rpb24gdGhhdCB3aWxsIGJlIGNhbGxlZCB3aXRoIGFsbCB0aGUgcGF0Y2hlcyBwcm9kdWNlZCBoZXJlXG4gKiBAcmV0dXJucyB7YW55fSBhIG5ldyBzdGF0ZSwgb3IgdGhlIGluaXRpYWwgc3RhdGUgaWYgbm90aGluZyB3YXMgbW9kaWZpZWRcbiAqL1xuZXhwb3J0IGNvbnN0IHByb2R1Y2U6IElQcm9kdWNlID0gaW1tZXIucHJvZHVjZVxuXG4vKipcbiAqIExpa2UgYHByb2R1Y2VgLCBidXQgYHByb2R1Y2VXaXRoUGF0Y2hlc2AgYWx3YXlzIHJldHVybnMgYSB0dXBsZVxuICogW25leHRTdGF0ZSwgcGF0Y2hlcywgaW52ZXJzZVBhdGNoZXNdIChpbnN0ZWFkIG9mIGp1c3QgdGhlIG5leHQgc3RhdGUpXG4gKi9cbmV4cG9ydCBjb25zdCBwcm9kdWNlV2l0aFBhdGNoZXM6IElQcm9kdWNlV2l0aFBhdGNoZXMgPSBpbW1lci5wcm9kdWNlV2l0aFBhdGNoZXMuYmluZChcblx0aW1tZXJcbilcblxuLyoqXG4gKiBQYXNzIHRydWUgdG8gYXV0b21hdGljYWxseSBmcmVlemUgYWxsIGNvcGllcyBjcmVhdGVkIGJ5IEltbWVyLlxuICpcbiAqIEFsd2F5cyBmcmVlemUgYnkgZGVmYXVsdCwgZXZlbiBpbiBwcm9kdWN0aW9uIG1vZGVcbiAqL1xuZXhwb3J0IGNvbnN0IHNldEF1dG9GcmVlemUgPSBpbW1lci5zZXRBdXRvRnJlZXplLmJpbmQoaW1tZXIpXG5cbi8qKlxuICogUGFzcyB0cnVlIHRvIGVuYWJsZSBzdHJpY3Qgc2hhbGxvdyBjb3B5LlxuICpcbiAqIEJ5IGRlZmF1bHQsIGltbWVyIGRvZXMgbm90IGNvcHkgdGhlIG9iamVjdCBkZXNjcmlwdG9ycyBzdWNoIGFzIGdldHRlciwgc2V0dGVyIGFuZCBub24tZW51bXJhYmxlIHByb3BlcnRpZXMuXG4gKi9cbmV4cG9ydCBjb25zdCBzZXRVc2VTdHJpY3RTaGFsbG93Q29weSA9IGltbWVyLnNldFVzZVN0cmljdFNoYWxsb3dDb3B5LmJpbmQoaW1tZXIpXG5cbi8qKlxuICogQXBwbHkgYW4gYXJyYXkgb2YgSW1tZXIgcGF0Y2hlcyB0byB0aGUgZmlyc3QgYXJndW1lbnQuXG4gKlxuICogVGhpcyBmdW5jdGlvbiBpcyBhIHByb2R1Y2VyLCB3aGljaCBtZWFucyBjb3B5LW9uLXdyaXRlIGlzIGluIGVmZmVjdC5cbiAqL1xuZXhwb3J0IGNvbnN0IGFwcGx5UGF0Y2hlcyA9IGltbWVyLmFwcGx5UGF0Y2hlcy5iaW5kKGltbWVyKVxuXG4vKipcbiAqIENyZWF0ZSBhbiBJbW1lciBkcmFmdCBmcm9tIHRoZSBnaXZlbiBiYXNlIHN0YXRlLCB3aGljaCBtYXkgYmUgYSBkcmFmdCBpdHNlbGYuXG4gKiBUaGUgZHJhZnQgY2FuIGJlIG1vZGlmaWVkIHVudGlsIHlvdSBmaW5hbGl6ZSBpdCB3aXRoIHRoZSBgZmluaXNoRHJhZnRgIGZ1bmN0aW9uLlxuICovXG5leHBvcnQgY29uc3QgY3JlYXRlRHJhZnQgPSBpbW1lci5jcmVhdGVEcmFmdC5iaW5kKGltbWVyKVxuXG4vKipcbiAqIEZpbmFsaXplIGFuIEltbWVyIGRyYWZ0IGZyb20gYSBgY3JlYXRlRHJhZnRgIGNhbGwsIHJldHVybmluZyB0aGUgYmFzZSBzdGF0ZVxuICogKGlmIG5vIGNoYW5nZXMgd2VyZSBtYWRlKSBvciBhIG1vZGlmaWVkIGNvcHkuIFRoZSBkcmFmdCBtdXN0ICpub3QqIGJlXG4gKiBtdXRhdGVkIGFmdGVyd2FyZHMuXG4gKlxuICogUGFzcyBhIGZ1bmN0aW9uIGFzIHRoZSAybmQgYXJndW1lbnQgdG8gZ2VuZXJhdGUgSW1tZXIgcGF0Y2hlcyBiYXNlZCBvbiB0aGVcbiAqIGNoYW5nZXMgdGhhdCB3ZXJlIG1hZGUuXG4gKi9cbmV4cG9ydCBjb25zdCBmaW5pc2hEcmFmdCA9IGltbWVyLmZpbmlzaERyYWZ0LmJpbmQoaW1tZXIpXG5cbi8qKlxuICogVGhpcyBmdW5jdGlvbiBpcyBhY3R1YWxseSBhIG5vLW9wLCBidXQgY2FuIGJlIHVzZWQgdG8gY2FzdCBhbiBpbW11dGFibGUgdHlwZVxuICogdG8gYW4gZHJhZnQgdHlwZSBhbmQgbWFrZSBUeXBlU2NyaXB0IGhhcHB5XG4gKlxuICogQHBhcmFtIHZhbHVlXG4gKi9cbmV4cG9ydCBmdW5jdGlvbiBjYXN0RHJhZnQ8VD4odmFsdWU6IFQpOiBEcmFmdDxUPiB7XG5cdHJldHVybiB2YWx1ZSBhcyBhbnlcbn1cblxuLyoqXG4gKiBUaGlzIGZ1bmN0aW9uIGlzIGFjdHVhbGx5IGEgbm8tb3AsIGJ1dCBjYW4gYmUgdXNlZCB0byBjYXN0IGEgbXV0YWJsZSB0eXBlXG4gKiB0byBhbiBpbW11dGFibGUgdHlwZSBhbmQgbWFrZSBUeXBlU2NyaXB0IGhhcHB5XG4gKiBAcGFyYW0gdmFsdWVcbiAqL1xuZXhwb3J0IGZ1bmN0aW9uIGNhc3RJbW11dGFibGU8VD4odmFsdWU6IFQpOiBJbW11dGFibGU8VD4ge1xuXHRyZXR1cm4gdmFsdWUgYXMgYW55XG59XG5cbmV4cG9ydCB7SW1tZXJ9XG5cbmV4cG9ydCB7ZW5hYmxlUGF0Y2hlc30gZnJvbSBcIi4vcGx1Z2lucy9wYXRjaGVzXCJcbmV4cG9ydCB7ZW5hYmxlTWFwU2V0fSBmcm9tIFwiLi9wbHVnaW5zL21hcHNldFwiXG4iLCAiaW1wb3J0IHR5cGUgeyBQYXRjaCBhcyBJbW1lclBhdGNoIH0gZnJvbSAnaW1tZXInO1xuaW1wb3J0IHsgYXBwbHlQYXRjaGVzLCBlbmFibGVQYXRjaGVzLCBwcm9kdWNlIH0gZnJvbSAnaW1tZXInO1xuaW1wb3J0IHsgY3JlYXRlU3RvcmUgfSBmcm9tICd6dXN0YW5kJztcblxuZW5hYmxlUGF0Y2hlcygpO1xuXG50eXBlIFdvcmtmbG93UHJvcHMgPSB7XG4gIHRyaWdnZXJzOiB7fVtdO1xuICBqb2JzOiB7fVtdO1xuICBlZGdlczoge31bXTtcbiAgZWRpdEpvYlVybDogc3RyaW5nO1xufTtcblxuZXhwb3J0IGludGVyZmFjZSBXb3JrZmxvd1N0YXRlIGV4dGVuZHMgV29ya2Zsb3dQcm9wcyB7XG4gIGFkZEVkZ2U6IChlZGdlOiBhbnkpID0+IHZvaWQ7XG4gIGFkZEpvYjogKGpvYjogYW55KSA9PiB2b2lkO1xuICBhZGRUcmlnZ2VyOiAobm9kZTogYW55KSA9PiB2b2lkO1xuICBvbkNoYW5nZTogKHBlbmRpbmdBY3Rpb246IFBlbmRpbmdBY3Rpb24pID0+IHZvaWQ7XG4gIGFwcGx5UGF0Y2hlczogKHBhdGNoZXM6IFBhdGNoW10pID0+IHZvaWQ7XG59XG5cbi8vIEltbWVyJ3MgUGF0Y2ggdHlwZSBoYXMgYW4gYXJyYXkgb2Ygc3RyaW5ncyBmb3IgdGhlIHBhdGgsIGJ1dCBSRkMgNjkwMlxuLy8gc3BlY2lmaWVzIHRoYXQgdGhlIHBhdGggc2hvdWxkIGJlIGEgc3RyaW5nLiBUaGlzIGlzIGEgd29ya2Fyb3VuZC5cbmV4cG9ydCB0eXBlIFBhdGNoID0ge1xuICBwYXRoOiBzdHJpbmc7XG59ICYgT21pdDxJbW1lclBhdGNoLCAncGF0aCc+O1xuXG4vLyBUT0RPOiB3ZSBhcmVuJ3QgdXNpbmcgdGhlIGBpZGAgcHJvcGVydHkgYW55d2hlcmUgY3VycmVudGx5LCBidXQgaXQgY291bGQgYmVcbi8vIHJlcXVpcmVkIHdoZW4gcmVjb25jaWxpbmcgb3V0IG9mIGRhdGUgY2hhbmdlcy5cbmV4cG9ydCBpbnRlcmZhY2UgUGVuZGluZ0FjdGlvbiB7XG4gIGlkOiBzdHJpbmc7XG4gIGZuOiAoZHJhZnQ6IFdvcmtmbG93U3RhdGUpID0+IHZvaWQ7XG4gIHBhdGNoZXM6IFBhdGNoW107XG59XG5cbi8vIEJ1aWxkIGEgbmV3IG5vZGUsIHdpdGggdGhlIGJhcmUgbWluaW11bSBwcm9wZXJ0aWVzLlxuZnVuY3Rpb24gYnVpbGROb2RlKCkge1xuICByZXR1cm4geyBpZDogY3J5cHRvLnJhbmRvbVVVSUQoKSB9O1xufVxuXG4vLyBCdWlsZCBhIG5ldyB0cmlnZ2VyLCB3aXRoIHRoZSBiYXJlIG1pbmltdW0gcHJvcGVydGllcy5cbmZ1bmN0aW9uIGJ1aWxkVHJpZ2dlcigpIHtcbiAgcmV0dXJuIHsgaWQ6IGNyeXB0by5yYW5kb21VVUlEKCkgfTtcbn1cblxuLy8gQnVpbGQgYSBuZXcgZWRnZSwgd2l0aCB0aGUgYmFyZSBtaW5pbXVtIHByb3BlcnRpZXMuXG5mdW5jdGlvbiBidWlsZEVkZ2UoKSB7XG4gIHJldHVybiB7IGlkOiBjcnlwdG8ucmFuZG9tVVVJRCgpIH07XG59XG5cbmZ1bmN0aW9uIHRvUkZDNjkwMlBhdGNoKHBhdGNoOiBJbW1lclBhdGNoKTogUGF0Y2gge1xuICByZXR1cm4ge1xuICAgIC4uLnBhdGNoLFxuICAgIHBhdGg6IGAvJHtwYXRjaC5wYXRoLmpvaW4oJy8nKX1gLFxuICB9O1xufVxuXG5leHBvcnQgY29uc3QgY3JlYXRlV29ya2Zsb3dTdG9yZSA9IChcbiAgaW5pdFByb3BzPzogUGFydGlhbDxXb3JrZmxvd1Byb3BzPixcbiAgb25DaGFuZ2U/OiAocGVuZGluZ0FjdGlvbjogUGVuZGluZ0FjdGlvbikgPT4gdm9pZFxuKSA9PiB7XG4gIGNvbnN0IERFRkFVTFRfUFJPUFM6IFdvcmtmbG93UHJvcHMgPSB7XG4gICAgdHJpZ2dlcnM6IFtdLFxuICAgIGpvYnM6IFtdLFxuICAgIGVkZ2VzOiBbXSxcbiAgICBlZGl0Sm9iVXJsOiAnJyxcbiAgfTtcblxuICAvLyBDYWxjdWxhdGUgdGhlIG5leHQgc3RhdGUgdXNpbmcgSW1tZXIsIGFuZCB0aGVuIGNhbGwgdGhlIG9uQ2hhbmdlIGNhbGxiYWNrXG4gIC8vIHdpdGggdGhlIHBhdGNoZXMgcmVzdWx0aW5nIGZyb20gdGhlIGNoYW5nZS5cbiAgZnVuY3Rpb24gcHJvcG9zZUNoYW5nZXMoXG4gICAgc3RhdGU6IFdvcmtmbG93U3RhdGUsXG4gICAgZm46IChkcmFmdDogV29ya2Zsb3dTdGF0ZSkgPT4gdm9pZFxuICApIHtcbiAgICBsZXQgcGF0Y2hlczogUGF0Y2hbXSA9IFtdO1xuXG4gICAgY29uc3QgbmV4dFN0YXRlID0gcHJvZHVjZShcbiAgICAgIHN0YXRlLFxuICAgICAgZHJhZnQgPT4ge1xuICAgICAgICBmbihkcmFmdCk7XG4gICAgICB9LFxuICAgICAgKHA6IEltbWVyUGF0Y2hbXSwgX2ludmVyc2U6IEltbWVyUGF0Y2hbXSkgPT4ge1xuICAgICAgICBwYXRjaGVzID0gcC5tYXAodG9SRkM2OTAyUGF0Y2gpO1xuICAgICAgfVxuICAgICk7XG5cbiAgICBpZiAob25DaGFuZ2UpIG9uQ2hhbmdlKHsgaWQ6IGNyeXB0by5yYW5kb21VVUlEKCksIGZuLCBwYXRjaGVzIH0pO1xuXG4gICAgcmV0dXJuIG5leHRTdGF0ZTtcbiAgfVxuXG4gIHJldHVybiBjcmVhdGVTdG9yZTxXb3JrZmxvd1N0YXRlPigpKHNldCA9PiAoe1xuICAgIC4uLkRFRkFVTFRfUFJPUFMsXG4gICAgLi4uaW5pdFByb3BzLFxuICAgIGFkZEpvYjogam9iID0+IHtcbiAgICAgIHNldChzdGF0ZSA9PlxuICAgICAgICBwcm9wb3NlQ2hhbmdlcyhzdGF0ZSwgZHJhZnQgPT4ge1xuICAgICAgICAgIGNvbnN0IG5ld0pvYiA9IGJ1aWxkTm9kZSgpO1xuICAgICAgICAgIGRyYWZ0LmpvYnMucHVzaChuZXdKb2IpO1xuICAgICAgICB9KVxuICAgICAgKTtcbiAgICB9LFxuICAgIGFkZFRyaWdnZXI6IHRyaWdnZXIgPT4ge1xuICAgICAgc2V0KHN0YXRlID0+XG4gICAgICAgIHByb3Bvc2VDaGFuZ2VzKHN0YXRlLCBkcmFmdCA9PiB7XG4gICAgICAgICAgY29uc3QgbmV3VHJpZ2dlciA9IGJ1aWxkVHJpZ2dlcigpO1xuICAgICAgICAgIGRyYWZ0LnRyaWdnZXJzLnB1c2gobmV3VHJpZ2dlcik7XG4gICAgICAgIH0pXG4gICAgICApO1xuICAgIH0sXG4gICAgYWRkRWRnZTogZWRnZSA9PiB7XG4gICAgICBzZXQoc3RhdGUgPT5cbiAgICAgICAgcHJvcG9zZUNoYW5nZXMoc3RhdGUsIGRyYWZ0ID0+IHtcbiAgICAgICAgICBjb25zdCBuZXdFZGdlID0gYnVpbGRFZGdlKCk7XG4gICAgICAgICAgZHJhZnQuZWRnZXMucHVzaChuZXdFZGdlKTtcbiAgICAgICAgfSlcbiAgICAgICk7XG4gICAgfSxcbiAgICBhcHBseVBhdGNoZXM6IHBhdGNoZXMgPT4ge1xuICAgICAgY29uc3QgaW1tZXJQYXRjaGVzOiBJbW1lclBhdGNoW10gPSBwYXRjaGVzLm1hcChwYXRjaCA9PiAoe1xuICAgICAgICAuLi5wYXRjaCxcbiAgICAgICAgcGF0aDogcGF0Y2gucGF0aC5zcGxpdCgnLycpLmZpbHRlcihCb29sZWFuKSxcbiAgICAgIH0pKTtcblxuICAgICAgc2V0KHN0YXRlID0+IGFwcGx5UGF0Y2hlcyhzdGF0ZSwgaW1tZXJQYXRjaGVzKSk7XG4gICAgfSxcbiAgICBvbkNoYW5nZTogb25DaGFuZ2UgPyBvbkNoYW5nZSA6ICgpID0+IHt9LFxuICB9KSk7XG59O1xuIiwgIi8vIEhvb2sgZm9yIFdvcmtmbG93IEVkaXRvciBDb21wb25lbnRcbmltcG9ydCB0eXBlIHsgbW91bnQgfSBmcm9tICcuL2NvbXBvbmVudCc7XG5pbXBvcnQgeyBQYXRjaCwgUGVuZGluZ0FjdGlvbiwgY3JlYXRlV29ya2Zsb3dTdG9yZSB9IGZyb20gJy4vc3RvcmUnO1xuXG5pbnRlcmZhY2UgUGhvZW5peEhvb2sge1xuICBtb3VudGVkKCk6IHZvaWQ7XG4gIGVsOiBIVE1MRWxlbWVudDtcbiAgZGVzdHJveWVkKCk6IHZvaWQ7XG4gIGhhbmRsZUV2ZW50PFQgPSB7fT4oZXZlbnROYW1lOiBzdHJpbmcsIGNhbGxiYWNrOiAocGF5bG9hZDogVCkgPT4gdm9pZCk6IHZvaWQ7XG4gIHB1c2hFdmVudFRvPFAgPSB7fSwgUiA9IGFueT4oXG4gICAgc2VsZWN0b3JPclRhcmdldDogc3RyaW5nIHwgSFRNTEVsZW1lbnQsXG4gICAgZXZlbnQ6IHN0cmluZyxcbiAgICBwYXlsb2FkOiBQLFxuICAgIGNhbGxiYWNrPzogKHJlcGx5OiBSLCByZWY6IGFueSkgPT4gdm9pZFxuICApOiB2b2lkO1xufVxuXG5pbnRlcmZhY2UgV29ya2Zsb3dFZGl0b3JFbnRyeXBvaW50IGV4dGVuZHMgUGhvZW5peEhvb2sge1xuICBjb21wb25lbnQ6IFJldHVyblR5cGU8dHlwZW9mIG1vdW50PiB8IG51bGw7XG4gIHdvcmtmbG93U3RvcmU6IFJldHVyblR5cGU8dHlwZW9mIGNyZWF0ZVdvcmtmbG93U3RvcmU+O1xuICBjb21wb25lbnRNb2R1bGU6IFByb21pc2U8eyBtb3VudDogdHlwZW9mIG1vdW50IH0+O1xuICBfcGVuZGluZ1dvcmtlcjogUHJvbWlzZTx2b2lkPjtcbiAgcGVuZGluZ0NoYW5nZXM6IFBlbmRpbmdBY3Rpb25bXTtcbiAgcHJvY2Vzc1BlbmRpbmdDaGFuZ2VzKCk6IHZvaWQ7XG4gIHB1c2hQZW5kaW5nQ2hhbmdlKFxuICAgIHBlbmRpbmdDaGFuZ2U6IFBlbmRpbmdBY3Rpb24sXG4gICAgYWJvcnRDb250cm9sbGVyOiBBYm9ydENvbnRyb2xsZXJcbiAgKTogUHJvbWlzZTxib29sZWFuPjtcbiAgYWJvcnRDb250cm9sbGVyOiBBYm9ydENvbnRyb2xsZXIgfCBudWxsO1xuICBlZGl0Sm9iVXJsOiBzdHJpbmc7XG4gIHNlbGVjdEpvYihpZDogc3RyaW5nKTogdm9pZDtcbn1cblxuZXhwb3J0IGRlZmF1bHQge1xuICBtb3VudGVkKHRoaXM6IFdvcmtmbG93RWRpdG9yRW50cnlwb2ludCkge1xuICAgIHRoaXMuX3BlbmRpbmdXb3JrZXIgPSBQcm9taXNlLnJlc29sdmUoKTtcbiAgICAvLyBUT0RPOiBlbnN1cmUgdGhhdCB0aGlzIGlzIHNldFxuICAgIHRoaXMuZWRpdEpvYlVybCA9IHRoaXMuZWwuZGF0YXNldC5lZGl0Sm9iVXJsITtcbiAgICB0aGlzLnBlbmRpbmdDaGFuZ2VzID0gW107XG5cbiAgICAvLyBTZXR1cCBvdXIgYWJvcnQgY29udHJvbGxlciB0byBzdG9wIGFueSBwZW5kaW5nIGNoYW5nZXMuXG4gICAgdGhpcy5hYm9ydENvbnRyb2xsZXIgPSBuZXcgQWJvcnRDb250cm9sbGVyKCk7XG5cbiAgICAvLyBQcmVsb2FkIHRoZSBjb21wb25lbnRcbiAgICB0aGlzLmNvbXBvbmVudE1vZHVsZSA9IGltcG9ydCgnLi9jb21wb25lbnQnKTtcblxuICAgIHRoaXMuaGFuZGxlRXZlbnQoJ3BhdGNoZXMtYXBwbGllZCcsIChyZXNwb25zZTogeyBwYXRjaGVzOiBQYXRjaFtdIH0pID0+IHtcbiAgICAgIGNvbnNvbGUuZGVidWcoJ3BhdGNoZXMtYXBwbGllZCcsIHJlc3BvbnNlLnBhdGNoZXMpO1xuICAgICAgdGhpcy53b3JrZmxvd1N0b3JlLmdldFN0YXRlKCkuYXBwbHlQYXRjaGVzKHJlc3BvbnNlLnBhdGNoZXMpO1xuICAgIH0pO1xuXG4gICAgLy8gR2V0IHRoZSBpbml0aWFsIGRhdGEgZnJvbSB0aGUgc2VydmVyXG4gICAgdGhpcy5wdXNoRXZlbnRUbyh0aGlzLmVsLCAnZ2V0LWluaXRpYWwtc3RhdGUnLCB7fSwgKHBheWxvYWQ6IGFueSkgPT4ge1xuICAgICAgdGhpcy53b3JrZmxvd1N0b3JlID0gY3JlYXRlV29ya2Zsb3dTdG9yZShcbiAgICAgICAgeyAuLi5wYXlsb2FkLCBlZGl0Sm9iVXJsOiB0aGlzLmVkaXRKb2JVcmwgfSxcbiAgICAgICAgcGVuZGluZ0NoYW5nZSA9PiB7XG4gICAgICAgICAgdGhpcy5wZW5kaW5nQ2hhbmdlcy5wdXNoKHBlbmRpbmdDaGFuZ2UpO1xuXG4gICAgICAgICAgdGhpcy5wcm9jZXNzUGVuZGluZ0NoYW5nZXMoKTtcbiAgICAgICAgfVxuICAgICAgKTtcblxuICAgICAgdGhpcy5jb21wb25lbnRNb2R1bGUudGhlbigoeyBtb3VudCB9KSA9PiB7XG4gICAgICAgIHRoaXMuY29tcG9uZW50ID0gbW91bnQodGhpcy5lbCwgdGhpcy53b3JrZmxvd1N0b3JlKTtcbiAgICAgIH0pO1xuICAgIH0pO1xuICB9LFxuICBkZXN0cm95ZWQoKSB7XG4gICAgaWYgKHRoaXMuY29tcG9uZW50KSB7XG4gICAgICB0aGlzLmNvbXBvbmVudC51bm1vdW50KCk7XG4gICAgfVxuXG4gICAgaWYgKHRoaXMuYWJvcnRDb250cm9sbGVyKSB7XG4gICAgICB0aGlzLmFib3J0Q29udHJvbGxlci5hYm9ydCgpO1xuICAgIH1cbiAgfSxcbiAgcHJvY2Vzc1BlbmRpbmdDaGFuZ2VzKCkge1xuICAgIC8vIEVuc3VyZSB0aGF0IGNoYW5nZXMgYXJlIHB1c2hlZCBpbiBvcmRlclxuICAgIC8vIFRPRE86IG9uIHRoZSBldmVudCBvZiBhIGNoYW5nZSBmYWlsaW5nIGRvIHdlIGNvbGxlY3QgdXAgYWxsIHRoZVxuICAgIC8vIHBlbmRpbmcgY2hhbmdlcyBhbmQgcmV2ZXJ0IHRoZW0/XG4gICAgdGhpcy5fcGVuZGluZ1dvcmtlciA9IHRoaXMuX3BlbmRpbmdXb3JrZXIudGhlbihcbiAgICAgIChhc3luYyAoKSA9PiB7XG4gICAgICAgIHdoaWxlIChcbiAgICAgICAgICB0aGlzLnBlbmRpbmdDaGFuZ2VzLmxlbmd0aCA+IDAgJiZcbiAgICAgICAgICAhdGhpcy5hYm9ydENvbnRyb2xsZXIhLnNpZ25hbC5hYm9ydGVkXG4gICAgICAgICkge1xuICAgICAgICAgIGNvbnN0IHBlbmRpbmdDaGFuZ2UgPSB0aGlzLnBlbmRpbmdDaGFuZ2VzLnNoaWZ0KCkhO1xuXG4gICAgICAgICAgLy8gVE9ETzogaWYgdGhpcyBmYWlscyBvciB0aW1lcyBvdXQsIHdlIG5lZWQgdG8gdW5kbyB0aGUgY2hhbmdlXG4gICAgICAgICAgLy8gSW1tZXIncyBwYXRjaCBjYWxsYmFjayBhbHNvIHByb2R1Y2VzIGEgbGlzdCBvZiBpbnZlcnNlIHBhdGNoZXMuXG4gICAgICAgICAgYXdhaXQgdGhpcy5wdXNoUGVuZGluZ0NoYW5nZShwZW5kaW5nQ2hhbmdlLCB0aGlzLmFib3J0Q29udHJvbGxlciEpO1xuICAgICAgICB9XG4gICAgICB9KVxuICAgICk7XG4gIH0sXG4gIHB1c2hQZW5kaW5nQ2hhbmdlKHBlbmRpbmdDaGFuZ2UsIGFib3J0Q29udHJvbGxlcj8pIHtcbiAgICByZXR1cm4gbmV3IFByb21pc2UoKHJlc29sdmUsIHJlamVjdCkgPT4ge1xuICAgICAgY29uc29sZS5kZWJ1ZygncHVzaGluZyBjaGFuZ2UnLCBwZW5kaW5nQ2hhbmdlKTtcbiAgICAgIC8vIEhvdyBkbyB3ZSBfdW5kb18gdGhlIGNoYW5nZSBpZiBpdCBmYWlscz9cbiAgICAgIHRoaXMucHVzaEV2ZW50VG88UGVuZGluZ0FjdGlvbiwgeyBwYXRjaGVzOiBQYXRjaFtdIH0+KFxuICAgICAgICB0aGlzLmVsLFxuICAgICAgICAncHVzaC1jaGFuZ2UnLFxuICAgICAgICBwZW5kaW5nQ2hhbmdlLFxuICAgICAgICByZXNwb25zZSA9PiB7XG4gICAgICAgICAgYWJvcnRDb250cm9sbGVyPy5zaWduYWwuYWRkRXZlbnRMaXN0ZW5lcignYWJvcnQnLCAoKSA9PlxuICAgICAgICAgICAgcmVqZWN0KGZhbHNlKVxuICAgICAgICAgICk7XG5cbiAgICAgICAgICB0aGlzLndvcmtmbG93U3RvcmUuZ2V0U3RhdGUoKS5hcHBseVBhdGNoZXMocmVzcG9uc2UucGF0Y2hlcyk7XG4gICAgICAgICAgcmVzb2x2ZSh0cnVlKTtcbiAgICAgICAgfVxuICAgICAgKTtcbiAgICB9KTtcbiAgfSxcbn0gYXMgV29ya2Zsb3dFZGl0b3JFbnRyeXBvaW50O1xuIiwgImludGVyZmFjZSBUYWJTZWxlY3RvciB7XG4gIGVsOiBIVE1MRWxlbWVudDtcbiAgdGFiSXRlbXM6IE5vZGVMaXN0T2Y8SFRNTEVsZW1lbnQ+O1xuICBjb250ZW50SXRlbXM6IE5vZGVMaXN0T2Y8SFRNTEVsZW1lbnQ+O1xuICBkZWZhdWx0SGFzaDogc3RyaW5nO1xuICBhY3RpdmVDbGFzc2VzOiBzdHJpbmdbXTtcbiAgaW5hY3RpdmVDbGFzc2VzOiBzdHJpbmdbXTtcbiAgX29uSGFzaENoYW5nZShlOiBFdmVudCk6IHZvaWQ7XG4gIG1vdW50ZWQoKTogdm9pZDtcbiAgZGVzdHJveWVkKCk6IHZvaWQ7XG4gIGhhc2hDaGFuZ2VkKGhhc2g6IHN0cmluZyk6IHZvaWQ7XG4gIGhhbmRsZUV2ZW50KGV2ZW50TmFtZTogc3RyaW5nLCBjYWxsYmFjazogKGQ6IHt9KSA9PiB2b2lkKTogYW55O1xufVxuXG5leHBvcnQgZGVmYXVsdCB7XG4gIG1vdW50ZWQodGhpczogVGFiU2VsZWN0b3IpIHtcbiAgICB0aGlzLnRhYkl0ZW1zID0gdGhpcy5lbC5xdWVyeVNlbGVjdG9yQWxsKCdbaWRePXRhYi1pdGVtXScpO1xuICAgIHRoaXMuY29udGVudEl0ZW1zID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgnW2RhdGEtcGFuZWwtaGFzaF0nKTtcblxuICAgIGNvbnN0IHsgYWN0aXZlQ2xhc3NlcywgaW5hY3RpdmVDbGFzc2VzLCBkZWZhdWx0SGFzaCB9ID0gdGhpcy5lbC5kYXRhc2V0O1xuICAgIGlmICghYWN0aXZlQ2xhc3NlcyB8fCAhaW5hY3RpdmVDbGFzc2VzIHx8ICFkZWZhdWx0SGFzaCkge1xuICAgICAgdGhyb3cgbmV3IEVycm9yKFxuICAgICAgICAnVGFiU2VsZWN0b3IgdGFiX2JhciBjb21wb25lbnQgbWlzc2luZyBkYXRhLWFjdGl2ZS1jbGFzc2VzLCBkYXRhLWluYWN0aXZlLWNsYXNzZXMgb3IgZGF0YS1kZWZhdWx0LWhhc2guJ1xuICAgICAgKTtcbiAgICB9XG5cbiAgICAvLyBUcmlnZ2VyIGEgVVJMIGhhc2ggY2hhbmdlIHdoZW4gdGhlIHNlcnZlciBzZW5kcyBhICdwdXNoLWhhc2gnIGV2ZW50LlxuICAgIHRoaXMuaGFuZGxlRXZlbnQoJ3B1c2gtaGFzaCcsICh7IGhhc2ggfSkgPT4ge1xuICAgICAgd2luZG93LmxvY2F0aW9uLmhhc2ggPSBoYXNoO1xuICAgIH0pO1xuXG4gICAgdGhpcy5fb25IYXNoQ2hhbmdlID0gX2V2dCA9PiB7XG4gICAgICBjb25zdCBoYXNoID0gd2luZG93LmxvY2F0aW9uLmhhc2gucmVwbGFjZSgnIycsICcnKTtcbiAgICAgIHRoaXMuaGFzaENoYW5nZWQoaGFzaCk7XG4gICAgfTtcblxuICAgIHRoaXMuYWN0aXZlQ2xhc3NlcyA9IGFjdGl2ZUNsYXNzZXMuc3BsaXQoJyAnKTtcbiAgICB0aGlzLmluYWN0aXZlQ2xhc3NlcyA9IGluYWN0aXZlQ2xhc3Nlcy5zcGxpdCgnICcpO1xuICAgIHRoaXMuZGVmYXVsdEhhc2ggPSBkZWZhdWx0SGFzaDtcblxuICAgIHdpbmRvdy5hZGRFdmVudExpc3RlbmVyKCdoYXNoY2hhbmdlJywgdGhpcy5fb25IYXNoQ2hhbmdlKTtcblxuICAgIHRoaXMuaGFzaENoYW5nZWQod2luZG93LmxvY2F0aW9uLmhhc2gucmVwbGFjZSgnIycsICcnKSB8fCB0aGlzLmRlZmF1bHRIYXNoKTtcbiAgfSxcbiAgaGFzaENoYW5nZWQobmV3SGFzaDogc3RyaW5nKSB7XG4gICAgdGhpcy50YWJJdGVtcy5mb3JFYWNoKGVsZW0gPT4ge1xuICAgICAgY29uc3QgeyBoYXNoIH0gPSBlbGVtLmRhdGFzZXQ7XG4gICAgICBjb25zdCBwYW5lbCA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoXG4gICAgICAgIGBbZGF0YS1wYW5lbC1oYXNoPSR7aGFzaH1dYFxuICAgICAgKSBhcyBIVE1MRWxlbWVudDtcblxuICAgICAgaWYgKG5ld0hhc2ggPT0gaGFzaCkge1xuICAgICAgICBwYW5lbC5zdHlsZS5kaXNwbGF5ID0gJ2Jsb2NrJztcblxuICAgICAgICBlbGVtLmNsYXNzTGlzdC5yZW1vdmUoLi4udGhpcy5pbmFjdGl2ZUNsYXNzZXMpO1xuICAgICAgICBlbGVtLmNsYXNzTGlzdC5hZGQoLi4udGhpcy5hY3RpdmVDbGFzc2VzKTtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHBhbmVsLnN0eWxlLmRpc3BsYXkgPSAnbm9uZSc7XG5cbiAgICAgICAgZWxlbS5jbGFzc0xpc3QucmVtb3ZlKC4uLnRoaXMuYWN0aXZlQ2xhc3Nlcyk7XG4gICAgICAgIGVsZW0uY2xhc3NMaXN0LmFkZCguLi50aGlzLmluYWN0aXZlQ2xhc3Nlcyk7XG4gICAgICB9XG4gICAgfSk7XG4gIH0sXG4gIGRlc3Ryb3llZCgpIHtcbiAgICB3aW5kb3cucmVtb3ZlRXZlbnRMaXN0ZW5lcignaGFzaGNoYW5nZScsIHRoaXMuX29uSGFzaENoYW5nZSk7XG4gIH0sXG59IGFzIFRhYlNlbGVjdG9yO1xuIiwgIi8vIFRoZSBkcmFnIG1hc2sgc3RvcHMgdGhlIGN1cnNvciBpbnRlcmFjdGluZyB3aXRoIHRoZSBwYWdlIHdoaWxlIGRyYWdnaW5nXG5jb25zdCBhZGREcmFnTWFzayA9ICgpID0+IHtcbiAgY29uc3QgZHJhZ01hc2sgPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdkaXYnKTtcbiAgZHJhZ01hc2suaWQgPSAnZHJhZy1tYXNrJztcbiAgZHJhZ01hc2suc3R5bGUucG9zaXRpb24gPSAnYWJzb2x1dGUnO1xuICBkcmFnTWFzay5zdHlsZS5sZWZ0ID0gJzAnO1xuICBkcmFnTWFzay5zdHlsZS5yaWdodCA9ICcwJztcbiAgZHJhZ01hc2suc3R5bGUudG9wID0gJzAnO1xuICBkcmFnTWFzay5zdHlsZS5ib3R0b20gPSAnMCc7XG4gIGRyYWdNYXNrLnN0eWxlLnVzZXJTZWxlY3QgPSAnbm9uZSc7XG4gIGRyYWdNYXNrLnN0eWxlLnpJbmRleCA9ICc5OTknO1xuICBkcmFnTWFzay5zdHlsZS5jdXJzb3IgPSAnZXctcmVzaXplJztcbiAgZG9jdW1lbnQuYm9keS5hcHBlbmRDaGlsZChkcmFnTWFzayk7XG59O1xuXG5pbnRlcmZhY2UgUmVzaXplckhvb2sge1xuICBlbDogSFRNTEVsZW1lbnQ7XG4gIGNvbnRhaW5lcjogSFRNTEVsZW1lbnQ7XG4gIG1vdW50ZWQoKTogdm9pZDtcbiAgZGVzdHJveWVkKCk6IHZvaWQ7XG5cbiAgb25Qb2ludGVyRG93bigpOiB2b2lkO1xuICBvblBvaW50ZXJVcCgpOiB2b2lkO1xuICBvblBvaW50ZXJNb3ZlKCk6IHZvaWQ7XG4gIGRyYWdMaXN0ZW5lcj8oKTogdm9pZDtcblxuICBjb250YWluZXJCb3VuZHM6IERPTVJlY3Q7XG4gIHdpZHRoPzogbnVtYmVyO1xufVxuXG5jb25zdCBob29rID0ge1xuICBvblBvaW50ZXJEb3duKHRoaXM6IFJlc2l6ZXJIb29rLCBlOiBhbnkpIHtcbiAgICB0aGlzLmNvbnRhaW5lckJvdW5kcyA9IHRoaXMuY29udGFpbmVyLmdldEJvdW5kaW5nQ2xpZW50UmVjdCgpO1xuICAgIGFkZERyYWdNYXNrKCk7XG5cbiAgICBjb25zdCBvbk1vdmUgPSBlID0+IHRoaXMub25Qb2ludGVyTW92ZShlKTtcbiAgICBkb2N1bWVudC5hZGRFdmVudExpc3RlbmVyKCdwb2ludGVybW92ZScsIG9uTW92ZSk7XG4gICAgZG9jdW1lbnQuYWRkRXZlbnRMaXN0ZW5lcihcbiAgICAgICdwb2ludGVydXAnLFxuICAgICAgKCkgPT4ge1xuICAgICAgICBkb2N1bWVudC5yZW1vdmVFdmVudExpc3RlbmVyKCdwb2ludGVybW92ZScsIG9uTW92ZSk7XG4gICAgICAgIHRoaXMub25Qb2ludGVyVXAoKTtcbiAgICAgIH0sXG4gICAgICB7XG4gICAgICAgIG9uY2U6IHRydWUsXG4gICAgICB9XG4gICAgKTtcbiAgfSxcbiAgb25Qb2ludGVyVXAodGhpczogUmVzaXplckhvb2spIHtcbiAgICBjb25zdCBtYXNrID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ2RyYWctbWFzaycpO1xuICAgIGlmIChtYXNrKSB7XG4gICAgICAobWFzay5wYXJlbnROb2RlIGFzIEhUTUxFbGVtZW50KS5yZW1vdmVDaGlsZChtYXNrKTtcbiAgICAgIGlmICh0aGlzLndpZHRoKSB7XG4gICAgICAgIGxvY2FsU3RvcmFnZS5zZXRJdGVtKCdsaWdodG5pbmcuam9iLWVkaXRvci53aWR0aCcsIGAke3RoaXMud2lkdGh9YCk7XG4gICAgICB9XG4gICAgICAvLyB0cmlnZ2VycyBhIGxheW91dCBpbiBtb25hY29cbiAgICAgIGRvY3VtZW50LmRpc3BhdGNoRXZlbnQobmV3IEV2ZW50KCd1cGRhdGUtbGF5b3V0JykpO1xuICAgIH1cbiAgfSxcbiAgb25Qb2ludGVyTW92ZSh0aGlzOiBSZXNpemVySG9vaywgZTogYW55KSB7XG4gICAgY29uc3QgcGFyZW50ID0gdGhpcy5lbC5wYXJlbnROb2RlISBhcyBIVE1MRWxlbWVudDtcbiAgICBjb25zdCB7IHdpZHRoOiBjb250YWluZXJXaWR0aCwgbGVmdDogY29udGFpbmVyTGVmdCB9ID0gdGhpcy5jb250YWluZXJCb3VuZHM7XG4gICAgaWYgKGUuc2NyZWVuWCAhPT0gMCkge1xuICAgICAgLy8gV29yayBvdXQgdGhlIG1vdXNlIHBvc2l0aW9uIHJlbGF0aXZlIHRvIHRoZSBwYXJlbnRcbiAgICAgIGNvbnN0IHJlbGF0aXZlUG9zaXRpb24gPSBNYXRoLm1heChcbiAgICAgICAgMCxcbiAgICAgICAgTWF0aC5taW4oKGUuY2xpZW50WCAtIGNvbnRhaW5lckxlZnQpIC8gY29udGFpbmVyV2lkdGgpXG4gICAgICApO1xuICAgICAgLy8gSW52ZXJ0IHRoZSBwb3N0aW9uXG4gICAgICB0aGlzLndpZHRoID0gKDEgLSByZWxhdGl2ZVBvc2l0aW9uKSAqIDEwMDtcbiAgICAgIC8vIFVwZGF0ZSB0aGUgd2lkdGhcbiAgICAgIHBhcmVudC5zdHlsZS53aWR0aCA9IGAke3RoaXMud2lkdGh9JWA7XG4gICAgfVxuICB9LFxuICBtb3VudGVkKHRoaXM6IFJlc2l6ZXJIb29rKSB7XG4gICAgY29uc3QgcGFyZW50ID0gdGhpcy5lbC5wYXJlbnROb2RlISBhcyBIVE1MRWxlbWVudDtcblxuICAgIGxldCBjb250YWluZXI6IEhUTUxFbGVtZW50ID0gcGFyZW50O1xuICAgIHdoaWxlIChjb250YWluZXIgJiYgIWNvbnRhaW5lci5jbGFzc05hbWUubWF0Y2goJ2gtZnVsbCcpKSB7XG4gICAgICBjb250YWluZXIgPSBjb250YWluZXIucGFyZW50Tm9kZSBhcyBIVE1MRWxlbWVudDtcbiAgICB9XG4gICAgdGhpcy5jb250YWluZXIgPSBjb250YWluZXI7XG5cbiAgICBjb25zdCBzYXZlZFdpZHRoID0gbG9jYWxTdG9yYWdlLmdldEl0ZW0oJ2xpZ2h0bmluZy5qb2ItZWRpdG9yLndpZHRoJyk7XG4gICAgaWYgKHBhcmVudCkge1xuICAgICAgaWYgKHNhdmVkV2lkdGgpIHtcbiAgICAgICAgcGFyZW50LnN0eWxlLndpZHRoID0gYCR7c2F2ZWRXaWR0aH0lYDtcbiAgICAgIH1cbiAgICB9XG4gICAgdGhpcy5lbC5hZGRFdmVudExpc3RlbmVyKCdwb2ludGVyZG93bicsIGUgPT4gdGhpcy5vblBvaW50ZXJEb3duKGUpKTtcbiAgfSxcbn0gYXMgUmVzaXpl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QixnQkFBQUEsUUFBTyxLQUFLO0FBQ2QsQ0FBQztBQUVELE9BQU8saUJBQWlCLFdBQVcsV0FBUztBQUMxQyxRQUFNLGFBQWEsT0FBTyxTQUFTO0FBQ25DLFFBQU0sZUFBZTtBQUNyQixPQUFLLE1BQU0sV0FBVyxNQUFNLFlBQVksTUFBTSxRQUFRLEtBQUs7QUFDekQsUUFBSSxhQUFhLEtBQUssVUFBVSxHQUFHO0FBQ2pDLFlBQU0sZUFBZTtBQUNyQixjQUFRLElBQUksZ0JBQWdCO0FBQzVCLFVBQUksT0FBTyxTQUFTLGNBQWMseUJBQXlCO0FBQzNELFdBQUssTUFBTTtBQUFBLElBQ2I7QUFBQSxFQUNGO0FBQ0YsQ0FBQztBQUdELFdBQVcsUUFBUTtBQUtuQixPQUFPLGFBQWE7IiwKICAibmFtZXMiOiBbIndpbmRvdyIsICJkb2N1bWVudCIsICJ0b3BiYXIiLCAiQ3VzdG9tRXZlbnQiLCAiY2xvc3VyZTIiLCAibGl2ZVNvY2tldCIsICJjbG9zdXJlIiwgImxvY2FsU3RvcmFnZSIsICJjdXJyZW50IiwgImhvb2siLCAiUmVhY3QiLCAiaW1tZXIiLCAiaXNTZXQiLCAiY3VycmVudCIsICJJbW1lciIsICJzZWxmIiwgImJhc2UiLCAiSW1tZXIiLCAic2V0IiwgImUiLCAibW91bnRfZGVmYXVsdCIsICJIb29rcyIsICJtb3VudF9kZWZhdWx0IiwgInRvcGJhciJdCn0K
