var __create = Object.create;
var __defProp = Object.defineProperty;
var __defProps = Object.defineProperties;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropDescs = Object.getOwnPropertyDescriptors;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getOwnPropSymbols = Object.getOwnPropertySymbols;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __propIsEnum = Object.prototype.propertyIsEnumerable;
var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
var __spreadValues = (a, b) => {
  for (var prop in b || (b = {}))
    if (__hasOwnProp.call(b, prop))
      __defNormalProp(a, prop, b[prop]);
  if (__getOwnPropSymbols)
    for (var prop of __getOwnPropSymbols(b)) {
      if (__propIsEnum.call(b, prop))
        __defNormalProp(a, prop, b[prop]);
    }
  return a;
};
var __spreadProps = (a, b) => __defProps(a, __getOwnPropDescs(b));
var __esm = (fn, res) => function __init() {
  return fn && (res = (0, fn[__getOwnPropNames(fn)[0]])(fn = 0)), res;
};
var __commonJS = (cb, mod) => function __require() {
  return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target, mod));

// node_modules/docker-modem/lib/utils.js
var require_utils = __commonJS({
  "node_modules/docker-modem/lib/utils.js"(exports, module2) {
    var arr = [];
    var each = arr.forEach;
    var slice = arr.slice;
    module2.exports.extend = function(obj) {
      each.call(slice.call(arguments, 1), function(source) {
        if (source) {
          for (var prop in source) {
            obj[prop] = source[prop];
          }
        }
      });
      return obj;
    };
    module2.exports.parseJSON = function(s) {
      try {
        return JSON.parse(s);
      } catch (e) {
        return null;
      }
    };
  }
});

// node_modules/docker-modem/lib/http.js
var require_http = __commonJS({
  "node_modules/docker-modem/lib/http.js"(exports, module2) {
    var nativeHttps = require("https");
    var nativeHttp = require("http");
    var url = require("url");
    var utils = require_utils();
    var maxRedirects = module2.exports.maxRedirects = 5;
    var protocols = {
      https: nativeHttps,
      http: nativeHttp
    };
    for (protocol in protocols) {
      h = function() {
      };
      h.prototype = protocols[protocol];
      h = new h();
      h.request = function(h2) {
        return function(options, callback, redirectOptions) {
          redirectOptions = redirectOptions || {};
          var max = typeof options === "object" && "maxRedirects" in options ? options.maxRedirects : exports.maxRedirects;
          var redirect = utils.extend({
            count: 0,
            max,
            clientRequest: null,
            userCallback: callback
          }, redirectOptions);
          if (redirect.count > redirect.max) {
            var err = new Error("Max redirects exceeded. To allow more redirects, pass options.maxRedirects property.");
            redirect.clientRequest.emit("error", err);
            return redirect.clientRequest;
          }
          redirect.count++;
          var reqUrl;
          if (typeof options === "string") {
            reqUrl = options;
          } else {
            reqUrl = url.format(utils.extend({
              protocol
            }, options));
          }
          var clientRequest = Object.getPrototypeOf(h2).request(options, redirectCallback(reqUrl, redirect));
          if (!redirect.clientRequest)
            redirect.clientRequest = clientRequest;
          function redirectCallback(reqUrl2, redirect2) {
            return function(res) {
              if (res.statusCode < 300 || res.statusCode > 399) {
                return redirect2.userCallback(res);
              }
              if (!("location" in res.headers)) {
                return redirect2.userCallback(res);
              }
              var redirectUrl = url.resolve(reqUrl2, res.headers.location);
              var proto = url.parse(redirectUrl).protocol;
              proto = proto.substr(0, proto.length - 1);
              return module2.exports[proto].get(redirectUrl, redirectCallback(reqUrl2, redirect2), redirect2);
            };
          }
          return clientRequest;
        };
      }(h);
      h.get = function(h2) {
        return function(options, cb, redirectOptions) {
          var req = h2.request(options, cb, redirectOptions);
          req.end();
          return req;
        };
      }(h);
      module2.exports[protocol] = h;
    }
    var h;
    var protocol;
  }
});

// node_modules/asn1/lib/ber/errors.js
var require_errors = __commonJS({
  "node_modules/asn1/lib/ber/errors.js"(exports, module2) {
    module2.exports = {
      newInvalidAsn1Error: function(msg) {
        var e = new Error();
        e.name = "InvalidAsn1Error";
        e.message = msg || "";
        return e;
      }
    };
  }
});

// node_modules/asn1/lib/ber/types.js
var require_types = __commonJS({
  "node_modules/asn1/lib/ber/types.js"(exports, module2) {
    module2.exports = {
      EOC: 0,
      Boolean: 1,
      Integer: 2,
      BitString: 3,
      OctetString: 4,
      Null: 5,
      OID: 6,
      ObjectDescriptor: 7,
      External: 8,
      Real: 9,
      Enumeration: 10,
      PDV: 11,
      Utf8String: 12,
      RelativeOID: 13,
      Sequence: 16,
      Set: 17,
      NumericString: 18,
      PrintableString: 19,
      T61String: 20,
      VideotexString: 21,
      IA5String: 22,
      UTCTime: 23,
      GeneralizedTime: 24,
      GraphicString: 25,
      VisibleString: 26,
      GeneralString: 28,
      UniversalString: 29,
      CharacterString: 30,
      BMPString: 31,
      Constructor: 32,
      Context: 128
    };
  }
});

// node_modules/safer-buffer/safer.js
var require_safer = __commonJS({
  "node_modules/safer-buffer/safer.js"(exports, module2) {
    "use strict";
    var buffer = require("buffer");
    var Buffer2 = buffer.Buffer;
    var safer = {};
    var key;
    for (key in buffer) {
      if (!buffer.hasOwnProperty(key))
        continue;
      if (key === "SlowBuffer" || key === "Buffer")
        continue;
      safer[key] = buffer[key];
    }
    var Safer = safer.Buffer = {};
    for (key in Buffer2) {
      if (!Buffer2.hasOwnProperty(key))
        continue;
      if (key === "allocUnsafe" || key === "allocUnsafeSlow")
        continue;
      Safer[key] = Buffer2[key];
    }
    safer.Buffer.prototype = Buffer2.prototype;
    if (!Safer.from || Safer.from === Uint8Array.from) {
      Safer.from = function(value, encodingOrOffset, length) {
        if (typeof value === "number") {
          throw new TypeError('The "value" argument must not be of type number. Received type ' + typeof value);
        }
        if (value && typeof value.length === "undefined") {
          throw new TypeError("The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type " + typeof value);
        }
        return Buffer2(value, encodingOrOffset, length);
      };
    }
    if (!Safer.alloc) {
      Safer.alloc = function(size, fill, encoding) {
        if (typeof size !== "number") {
          throw new TypeError('The "size" argument must be of type number. Received type ' + typeof size);
        }
        if (size < 0 || size >= 2 * (1 << 30)) {
          throw new RangeError('The value "' + size + '" is invalid for option "size"');
        }
        var buf = Buffer2(size);
        if (!fill || fill.length === 0) {
          buf.fill(0);
        } else if (typeof encoding === "string") {
          buf.fill(fill, encoding);
        } else {
          buf.fill(fill);
        }
        return buf;
      };
    }
    if (!safer.kStringMaxLength) {
      try {
        safer.kStringMaxLength = process.binding("buffer").kStringMaxLength;
      } catch (e) {
      }
    }
    if (!safer.constants) {
      safer.constants = {
        MAX_LENGTH: safer.kMaxLength
      };
      if (safer.kStringMaxLength) {
        safer.constants.MAX_STRING_LENGTH = safer.kStringMaxLength;
      }
    }
    module2.exports = safer;
  }
});

// node_modules/asn1/lib/ber/reader.js
var require_reader = __commonJS({
  "node_modules/asn1/lib/ber/reader.js"(exports, module2) {
    var assert = require("assert");
    var Buffer2 = require_safer().Buffer;
    var ASN1 = require_types();
    var errors = require_errors();
    var newInvalidAsn1Error = errors.newInvalidAsn1Error;
    function Reader(data) {
      if (!data || !Buffer2.isBuffer(data))
        throw new TypeError("data must be a node Buffer");
      this._buf = data;
      this._size = data.length;
      this._len = 0;
      this._offset = 0;
    }
    Object.defineProperty(Reader.prototype, "length", {
      enumerable: true,
      get: function() {
        return this._len;
      }
    });
    Object.defineProperty(Reader.prototype, "offset", {
      enumerable: true,
      get: function() {
        return this._offset;
      }
    });
    Object.defineProperty(Reader.prototype, "remain", {
      get: function() {
        return this._size - this._offset;
      }
    });
    Object.defineProperty(Reader.prototype, "buffer", {
      get: function() {
        return this._buf.slice(this._offset);
      }
    });
    Reader.prototype.readByte = function(peek) {
      if (this._size - this._offset < 1)
        return null;
      var b = this._buf[this._offset] & 255;
      if (!peek)
        this._offset += 1;
      return b;
    };
    Reader.prototype.peek = function() {
      return this.readByte(true);
    };
    Reader.prototype.readLength = function(offset) {
      if (offset === void 0)
        offset = this._offset;
      if (offset >= this._size)
        return null;
      var lenB = this._buf[offset++] & 255;
      if (lenB === null)
        return null;
      if ((lenB & 128) === 128) {
        lenB &= 127;
        if (lenB === 0)
          throw newInvalidAsn1Error("Indefinite length not supported");
        if (lenB > 4)
          throw newInvalidAsn1Error("encoding too long");
        if (this._size - offset < lenB)
          return null;
        this._len = 0;
        for (var i = 0; i < lenB; i++)
          this._len = (this._len << 8) + (this._buf[offset++] & 255);
      } else {
        this._len = lenB;
      }
      return offset;
    };
    Reader.prototype.readSequence = function(tag) {
      var seq = this.peek();
      if (seq === null)
        return null;
      if (tag !== void 0 && tag !== seq)
        throw newInvalidAsn1Error("Expected 0x" + tag.toString(16) + ": got 0x" + seq.toString(16));
      var o = this.readLength(this._offset + 1);
      if (o === null)
        return null;
      this._offset = o;
      return seq;
    };
    Reader.prototype.readInt = function() {
      return this._readTag(ASN1.Integer);
    };
    Reader.prototype.readBoolean = function() {
      return this._readTag(ASN1.Boolean) === 0 ? false : true;
    };
    Reader.prototype.readEnumeration = function() {
      return this._readTag(ASN1.Enumeration);
    };
    Reader.prototype.readString = function(tag, retbuf) {
      if (!tag)
        tag = ASN1.OctetString;
      var b = this.peek();
      if (b === null)
        return null;
      if (b !== tag)
        throw newInvalidAsn1Error("Expected 0x" + tag.toString(16) + ": got 0x" + b.toString(16));
      var o = this.readLength(this._offset + 1);
      if (o === null)
        return null;
      if (this.length > this._size - o)
        return null;
      this._offset = o;
      if (this.length === 0)
        return retbuf ? Buffer2.alloc(0) : "";
      var str = this._buf.slice(this._offset, this._offset + this.length);
      this._offset += this.length;
      return retbuf ? str : str.toString("utf8");
    };
    Reader.prototype.readOID = function(tag) {
      if (!tag)
        tag = ASN1.OID;
      var b = this.readString(tag, true);
      if (b === null)
        return null;
      var values = [];
      var value = 0;
      for (var i = 0; i < b.length; i++) {
        var byte = b[i] & 255;
        value <<= 7;
        value += byte & 127;
        if ((byte & 128) === 0) {
          values.push(value);
          value = 0;
        }
      }
      value = values.shift();
      values.unshift(value % 40);
      values.unshift(value / 40 >> 0);
      return values.join(".");
    };
    Reader.prototype._readTag = function(tag) {
      assert.ok(tag !== void 0);
      var b = this.peek();
      if (b === null)
        return null;
      if (b !== tag)
        throw newInvalidAsn1Error("Expected 0x" + tag.toString(16) + ": got 0x" + b.toString(16));
      var o = this.readLength(this._offset + 1);
      if (o === null)
        return null;
      if (this.length > 4)
        throw newInvalidAsn1Error("Integer too long: " + this.length);
      if (this.length > this._size - o)
        return null;
      this._offset = o;
      var fb = this._buf[this._offset];
      var value = 0;
      for (var i = 0; i < this.length; i++) {
        value <<= 8;
        value |= this._buf[this._offset++] & 255;
      }
      if ((fb & 128) === 128 && i !== 4)
        value -= 1 << i * 8;
      return value >> 0;
    };
    module2.exports = Reader;
  }
});

// node_modules/asn1/lib/ber/writer.js
var require_writer = __commonJS({
  "node_modules/asn1/lib/ber/writer.js"(exports, module2) {
    var assert = require("assert");
    var Buffer2 = require_safer().Buffer;
    var ASN1 = require_types();
    var errors = require_errors();
    var newInvalidAsn1Error = errors.newInvalidAsn1Error;
    var DEFAULT_OPTS = {
      size: 1024,
      growthFactor: 8
    };
    function merge(from, to) {
      assert.ok(from);
      assert.equal(typeof from, "object");
      assert.ok(to);
      assert.equal(typeof to, "object");
      var keys = Object.getOwnPropertyNames(from);
      keys.forEach(function(key) {
        if (to[key])
          return;
        var value = Object.getOwnPropertyDescriptor(from, key);
        Object.defineProperty(to, key, value);
      });
      return to;
    }
    function Writer(options) {
      options = merge(DEFAULT_OPTS, options || {});
      this._buf = Buffer2.alloc(options.size || 1024);
      this._size = this._buf.length;
      this._offset = 0;
      this._options = options;
      this._seq = [];
    }
    Object.defineProperty(Writer.prototype, "buffer", {
      get: function() {
        if (this._seq.length)
          throw newInvalidAsn1Error(this._seq.length + " unended sequence(s)");
        return this._buf.slice(0, this._offset);
      }
    });
    Writer.prototype.writeByte = function(b) {
      if (typeof b !== "number")
        throw new TypeError("argument must be a Number");
      this._ensure(1);
      this._buf[this._offset++] = b;
    };
    Writer.prototype.writeInt = function(i, tag) {
      if (typeof i !== "number")
        throw new TypeError("argument must be a Number");
      if (typeof tag !== "number")
        tag = ASN1.Integer;
      var sz = 4;
      while (((i & 4286578688) === 0 || (i & 4286578688) === 4286578688 >> 0) && sz > 1) {
        sz--;
        i <<= 8;
      }
      if (sz > 4)
        throw newInvalidAsn1Error("BER ints cannot be > 0xffffffff");
      this._ensure(2 + sz);
      this._buf[this._offset++] = tag;
      this._buf[this._offset++] = sz;
      while (sz-- > 0) {
        this._buf[this._offset++] = (i & 4278190080) >>> 24;
        i <<= 8;
      }
    };
    Writer.prototype.writeNull = function() {
      this.writeByte(ASN1.Null);
      this.writeByte(0);
    };
    Writer.prototype.writeEnumeration = function(i, tag) {
      if (typeof i !== "number")
        throw new TypeError("argument must be a Number");
      if (typeof tag !== "number")
        tag = ASN1.Enumeration;
      return this.writeInt(i, tag);
    };
    Writer.prototype.writeBoolean = function(b, tag) {
      if (typeof b !== "boolean")
        throw new TypeError("argument must be a Boolean");
      if (typeof tag !== "number")
        tag = ASN1.Boolean;
      this._ensure(3);
      this._buf[this._offset++] = tag;
      this._buf[this._offset++] = 1;
      this._buf[this._offset++] = b ? 255 : 0;
    };
    Writer.prototype.writeString = function(s, tag) {
      if (typeof s !== "string")
        throw new TypeError("argument must be a string (was: " + typeof s + ")");
      if (typeof tag !== "number")
        tag = ASN1.OctetString;
      var len = Buffer2.byteLength(s);
      this.writeByte(tag);
      this.writeLength(len);
      if (len) {
        this._ensure(len);
        this._buf.write(s, this._offset);
        this._offset += len;
      }
    };
    Writer.prototype.writeBuffer = function(buf, tag) {
      if (typeof tag !== "number")
        throw new TypeError("tag must be a number");
      if (!Buffer2.isBuffer(buf))
        throw new TypeError("argument must be a buffer");
      this.writeByte(tag);
      this.writeLength(buf.length);
      this._ensure(buf.length);
      buf.copy(this._buf, this._offset, 0, buf.length);
      this._offset += buf.length;
    };
    Writer.prototype.writeStringArray = function(strings) {
      if (!strings instanceof Array)
        throw new TypeError("argument must be an Array[String]");
      var self2 = this;
      strings.forEach(function(s) {
        self2.writeString(s);
      });
    };
    Writer.prototype.writeOID = function(s, tag) {
      if (typeof s !== "string")
        throw new TypeError("argument must be a string");
      if (typeof tag !== "number")
        tag = ASN1.OID;
      if (!/^([0-9]+\.){3,}[0-9]+$/.test(s))
        throw new Error("argument is not a valid OID string");
      function encodeOctet(bytes2, octet) {
        if (octet < 128) {
          bytes2.push(octet);
        } else if (octet < 16384) {
          bytes2.push(octet >>> 7 | 128);
          bytes2.push(octet & 127);
        } else if (octet < 2097152) {
          bytes2.push(octet >>> 14 | 128);
          bytes2.push((octet >>> 7 | 128) & 255);
          bytes2.push(octet & 127);
        } else if (octet < 268435456) {
          bytes2.push(octet >>> 21 | 128);
          bytes2.push((octet >>> 14 | 128) & 255);
          bytes2.push((octet >>> 7 | 128) & 255);
          bytes2.push(octet & 127);
        } else {
          bytes2.push((octet >>> 28 | 128) & 255);
          bytes2.push((octet >>> 21 | 128) & 255);
          bytes2.push((octet >>> 14 | 128) & 255);
          bytes2.push((octet >>> 7 | 128) & 255);
          bytes2.push(octet & 127);
        }
      }
      var tmp = s.split(".");
      var bytes = [];
      bytes.push(parseInt(tmp[0], 10) * 40 + parseInt(tmp[1], 10));
      tmp.slice(2).forEach(function(b) {
        encodeOctet(bytes, parseInt(b, 10));
      });
      var self2 = this;
      this._ensure(2 + bytes.length);
      this.writeByte(tag);
      this.writeLength(bytes.length);
      bytes.forEach(function(b) {
        self2.writeByte(b);
      });
    };
    Writer.prototype.writeLength = function(len) {
      if (typeof len !== "number")
        throw new TypeError("argument must be a Number");
      this._ensure(4);
      if (len <= 127) {
        this._buf[this._offset++] = len;
      } else if (len <= 255) {
        this._buf[this._offset++] = 129;
        this._buf[this._offset++] = len;
      } else if (len <= 65535) {
        this._buf[this._offset++] = 130;
        this._buf[this._offset++] = len >> 8;
        this._buf[this._offset++] = len;
      } else if (len <= 16777215) {
        this._buf[this._offset++] = 131;
        this._buf[this._offset++] = len >> 16;
        this._buf[this._offset++] = len >> 8;
        this._buf[this._offset++] = len;
      } else {
        throw newInvalidAsn1Error("Length too long (> 4 bytes)");
      }
    };
    Writer.prototype.startSequence = function(tag) {
      if (typeof tag !== "number")
        tag = ASN1.Sequence | ASN1.Constructor;
      this.writeByte(tag);
      this._seq.push(this._offset);
      this._ensure(3);
      this._offset += 3;
    };
    Writer.prototype.endSequence = function() {
      var seq = this._seq.pop();
      var start = seq + 3;
      var len = this._offset - start;
      if (len <= 127) {
        this._shift(start, len, -2);
        this._buf[seq] = len;
      } else if (len <= 255) {
        this._shift(start, len, -1);
        this._buf[seq] = 129;
        this._buf[seq + 1] = len;
      } else if (len <= 65535) {
        this._buf[seq] = 130;
        this._buf[seq + 1] = len >> 8;
        this._buf[seq + 2] = len;
      } else if (len <= 16777215) {
        this._shift(start, len, 1);
        this._buf[seq] = 131;
        this._buf[seq + 1] = len >> 16;
        this._buf[seq + 2] = len >> 8;
        this._buf[seq + 3] = len;
      } else {
        throw newInvalidAsn1Error("Sequence too long");
      }
    };
    Writer.prototype._shift = function(start, len, shift) {
      assert.ok(start !== void 0);
      assert.ok(len !== void 0);
      assert.ok(shift);
      this._buf.copy(this._buf, start + shift, start, start + len);
      this._offset += shift;
    };
    Writer.prototype._ensure = function(len) {
      assert.ok(len);
      if (this._size - this._offset < len) {
        var sz = this._size * this._options.growthFactor;
        if (sz - this._offset < len)
          sz += len;
        var buf = Buffer2.alloc(sz);
        this._buf.copy(buf, 0, 0, this._offset);
        this._buf = buf;
        this._size = sz;
      }
    };
    module2.exports = Writer;
  }
});

// node_modules/asn1/lib/ber/index.js
var require_ber = __commonJS({
  "node_modules/asn1/lib/ber/index.js"(exports, module2) {
    var errors = require_errors();
    var types = require_types();
    var Reader = require_reader();
    var Writer = require_writer();
    module2.exports = {
      Reader,
      Writer
    };
    for (t in types) {
      if (types.hasOwnProperty(t))
        module2.exports[t] = types[t];
    }
    var t;
    for (e in errors) {
      if (errors.hasOwnProperty(e))
        module2.exports[e] = errors[e];
    }
    var e;
  }
});

// node_modules/asn1/lib/index.js
var require_lib = __commonJS({
  "node_modules/asn1/lib/index.js"(exports, module2) {
    var Ber = require_ber();
    module2.exports = {
      Ber,
      BerReader: Ber.Reader,
      BerWriter: Ber.Writer
    };
  }
});

// node_modules/tweetnacl/nacl-fast.js
var require_nacl_fast = __commonJS({
  "node_modules/tweetnacl/nacl-fast.js"(exports, module2) {
    (function(nacl) {
      "use strict";
      var gf = function(init2) {
        var i, r = new Float64Array(16);
        if (init2)
          for (i = 0; i < init2.length; i++)
            r[i] = init2[i];
        return r;
      };
      var randombytes = function() {
        throw new Error("no PRNG");
      };
      var _0 = new Uint8Array(16);
      var _9 = new Uint8Array(32);
      _9[0] = 9;
      var gf0 = gf(), gf1 = gf([1]), _121665 = gf([56129, 1]), D = gf([30883, 4953, 19914, 30187, 55467, 16705, 2637, 112, 59544, 30585, 16505, 36039, 65139, 11119, 27886, 20995]), D2 = gf([61785, 9906, 39828, 60374, 45398, 33411, 5274, 224, 53552, 61171, 33010, 6542, 64743, 22239, 55772, 9222]), X = gf([54554, 36645, 11616, 51542, 42930, 38181, 51040, 26924, 56412, 64982, 57905, 49316, 21502, 52590, 14035, 8553]), Y = gf([26200, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214]), I = gf([41136, 18958, 6951, 50414, 58488, 44335, 6150, 12099, 55207, 15867, 153, 11085, 57099, 20417, 9344, 11139]);
      function ts64(x, i, h, l) {
        x[i] = h >> 24 & 255;
        x[i + 1] = h >> 16 & 255;
        x[i + 2] = h >> 8 & 255;
        x[i + 3] = h & 255;
        x[i + 4] = l >> 24 & 255;
        x[i + 5] = l >> 16 & 255;
        x[i + 6] = l >> 8 & 255;
        x[i + 7] = l & 255;
      }
      function vn(x, xi, y, yi, n) {
        var i, d = 0;
        for (i = 0; i < n; i++)
          d |= x[xi + i] ^ y[yi + i];
        return (1 & d - 1 >>> 8) - 1;
      }
      function crypto_verify_16(x, xi, y, yi) {
        return vn(x, xi, y, yi, 16);
      }
      function crypto_verify_32(x, xi, y, yi) {
        return vn(x, xi, y, yi, 32);
      }
      function core_salsa20(o, p, k, c) {
        var j0 = c[0] & 255 | (c[1] & 255) << 8 | (c[2] & 255) << 16 | (c[3] & 255) << 24, j1 = k[0] & 255 | (k[1] & 255) << 8 | (k[2] & 255) << 16 | (k[3] & 255) << 24, j2 = k[4] & 255 | (k[5] & 255) << 8 | (k[6] & 255) << 16 | (k[7] & 255) << 24, j3 = k[8] & 255 | (k[9] & 255) << 8 | (k[10] & 255) << 16 | (k[11] & 255) << 24, j4 = k[12] & 255 | (k[13] & 255) << 8 | (k[14] & 255) << 16 | (k[15] & 255) << 24, j5 = c[4] & 255 | (c[5] & 255) << 8 | (c[6] & 255) << 16 | (c[7] & 255) << 24, j6 = p[0] & 255 | (p[1] & 255) << 8 | (p[2] & 255) << 16 | (p[3] & 255) << 24, j7 = p[4] & 255 | (p[5] & 255) << 8 | (p[6] & 255) << 16 | (p[7] & 255) << 24, j8 = p[8] & 255 | (p[9] & 255) << 8 | (p[10] & 255) << 16 | (p[11] & 255) << 24, j9 = p[12] & 255 | (p[13] & 255) << 8 | (p[14] & 255) << 16 | (p[15] & 255) << 24, j10 = c[8] & 255 | (c[9] & 255) << 8 | (c[10] & 255) << 16 | (c[11] & 255) << 24, j11 = k[16] & 255 | (k[17] & 255) << 8 | (k[18] & 255) << 16 | (k[19] & 255) << 24, j12 = k[20] & 255 | (k[21] & 255) << 8 | (k[22] & 255) << 16 | (k[23] & 255) << 24, j13 = k[24] & 255 | (k[25] & 255) << 8 | (k[26] & 255) << 16 | (k[27] & 255) << 24, j14 = k[28] & 255 | (k[29] & 255) << 8 | (k[30] & 255) << 16 | (k[31] & 255) << 24, j15 = c[12] & 255 | (c[13] & 255) << 8 | (c[14] & 255) << 16 | (c[15] & 255) << 24;
        var x0 = j0, x1 = j1, x2 = j2, x3 = j3, x4 = j4, x5 = j5, x6 = j6, x7 = j7, x8 = j8, x9 = j9, x10 = j10, x11 = j11, x12 = j12, x13 = j13, x14 = j14, x15 = j15, u;
        for (var i = 0; i < 20; i += 2) {
          u = x0 + x12 | 0;
          x4 ^= u << 7 | u >>> 32 - 7;
          u = x4 + x0 | 0;
          x8 ^= u << 9 | u >>> 32 - 9;
          u = x8 + x4 | 0;
          x12 ^= u << 13 | u >>> 32 - 13;
          u = x12 + x8 | 0;
          x0 ^= u << 18 | u >>> 32 - 18;
          u = x5 + x1 | 0;
          x9 ^= u << 7 | u >>> 32 - 7;
          u = x9 + x5 | 0;
          x13 ^= u << 9 | u >>> 32 - 9;
          u = x13 + x9 | 0;
          x1 ^= u << 13 | u >>> 32 - 13;
          u = x1 + x13 | 0;
          x5 ^= u << 18 | u >>> 32 - 18;
          u = x10 + x6 | 0;
          x14 ^= u << 7 | u >>> 32 - 7;
          u = x14 + x10 | 0;
          x2 ^= u << 9 | u >>> 32 - 9;
          u = x2 + x14 | 0;
          x6 ^= u << 13 | u >>> 32 - 13;
          u = x6 + x2 | 0;
          x10 ^= u << 18 | u >>> 32 - 18;
          u = x15 + x11 | 0;
          x3 ^= u << 7 | u >>> 32 - 7;
          u = x3 + x15 | 0;
          x7 ^= u << 9 | u >>> 32 - 9;
          u = x7 + x3 | 0;
          x11 ^= u << 13 | u >>> 32 - 13;
          u = x11 + x7 | 0;
          x15 ^= u << 18 | u >>> 32 - 18;
          u = x0 + x3 | 0;
          x1 ^= u << 7 | u >>> 32 - 7;
          u = x1 + x0 | 0;
          x2 ^= u << 9 | u >>> 32 - 9;
          u = x2 + x1 | 0;
          x3 ^= u << 13 | u >>> 32 - 13;
          u = x3 + x2 | 0;
          x0 ^= u << 18 | u >>> 32 - 18;
          u = x5 + x4 | 0;
          x6 ^= u << 7 | u >>> 32 - 7;
          u = x6 + x5 | 0;
          x7 ^= u << 9 | u >>> 32 - 9;
          u = x7 + x6 | 0;
          x4 ^= u << 13 | u >>> 32 - 13;
          u = x4 + x7 | 0;
          x5 ^= u << 18 | u >>> 32 - 18;
          u = x10 + x9 | 0;
          x11 ^= u << 7 | u >>> 32 - 7;
          u = x11 + x10 | 0;
          x8 ^= u << 9 | u >>> 32 - 9;
          u = x8 + x11 | 0;
          x9 ^= u << 13 | u >>> 32 - 13;
          u = x9 + x8 | 0;
          x10 ^= u << 18 | u >>> 32 - 18;
          u = x15 + x14 | 0;
          x12 ^= u << 7 | u >>> 32 - 7;
          u = x12 + x15 | 0;
          x13 ^= u << 9 | u >>> 32 - 9;
          u = x13 + x12 | 0;
          x14 ^= u << 13 | u >>> 32 - 13;
          u = x14 + x13 | 0;
          x15 ^= u << 18 | u >>> 32 - 18;
        }
        x0 = x0 + j0 | 0;
        x1 = x1 + j1 | 0;
        x2 = x2 + j2 | 0;
        x3 = x3 + j3 | 0;
        x4 = x4 + j4 | 0;
        x5 = x5 + j5 | 0;
        x6 = x6 + j6 | 0;
        x7 = x7 + j7 | 0;
        x8 = x8 + j8 | 0;
        x9 = x9 + j9 | 0;
        x10 = x10 + j10 | 0;
        x11 = x11 + j11 | 0;
        x12 = x12 + j12 | 0;
        x13 = x13 + j13 | 0;
        x14 = x14 + j14 | 0;
        x15 = x15 + j15 | 0;
        o[0] = x0 >>> 0 & 255;
        o[1] = x0 >>> 8 & 255;
        o[2] = x0 >>> 16 & 255;
        o[3] = x0 >>> 24 & 255;
        o[4] = x1 >>> 0 & 255;
        o[5] = x1 >>> 8 & 255;
        o[6] = x1 >>> 16 & 255;
        o[7] = x1 >>> 24 & 255;
        o[8] = x2 >>> 0 & 255;
        o[9] = x2 >>> 8 & 255;
        o[10] = x2 >>> 16 & 255;
        o[11] = x2 >>> 24 & 255;
        o[12] = x3 >>> 0 & 255;
        o[13] = x3 >>> 8 & 255;
        o[14] = x3 >>> 16 & 255;
        o[15] = x3 >>> 24 & 255;
        o[16] = x4 >>> 0 & 255;
        o[17] = x4 >>> 8 & 255;
        o[18] = x4 >>> 16 & 255;
        o[19] = x4 >>> 24 & 255;
        o[20] = x5 >>> 0 & 255;
        o[21] = x5 >>> 8 & 255;
        o[22] = x5 >>> 16 & 255;
        o[23] = x5 >>> 24 & 255;
        o[24] = x6 >>> 0 & 255;
        o[25] = x6 >>> 8 & 255;
        o[26] = x6 >>> 16 & 255;
        o[27] = x6 >>> 24 & 255;
        o[28] = x7 >>> 0 & 255;
        o[29] = x7 >>> 8 & 255;
        o[30] = x7 >>> 16 & 255;
        o[31] = x7 >>> 24 & 255;
        o[32] = x8 >>> 0 & 255;
        o[33] = x8 >>> 8 & 255;
        o[34] = x8 >>> 16 & 255;
        o[35] = x8 >>> 24 & 255;
        o[36] = x9 >>> 0 & 255;
        o[37] = x9 >>> 8 & 255;
        o[38] = x9 >>> 16 & 255;
        o[39] = x9 >>> 24 & 255;
        o[40] = x10 >>> 0 & 255;
        o[41] = x10 >>> 8 & 255;
        o[42] = x10 >>> 16 & 255;
        o[43] = x10 >>> 24 & 255;
        o[44] = x11 >>> 0 & 255;
        o[45] = x11 >>> 8 & 255;
        o[46] = x11 >>> 16 & 255;
        o[47] = x11 >>> 24 & 255;
        o[48] = x12 >>> 0 & 255;
        o[49] = x12 >>> 8 & 255;
        o[50] = x12 >>> 16 & 255;
        o[51] = x12 >>> 24 & 255;
        o[52] = x13 >>> 0 & 255;
        o[53] = x13 >>> 8 & 255;
        o[54] = x13 >>> 16 & 255;
        o[55] = x13 >>> 24 & 255;
        o[56] = x14 >>> 0 & 255;
        o[57] = x14 >>> 8 & 255;
        o[58] = x14 >>> 16 & 255;
        o[59] = x14 >>> 24 & 255;
        o[60] = x15 >>> 0 & 255;
        o[61] = x15 >>> 8 & 255;
        o[62] = x15 >>> 16 & 255;
        o[63] = x15 >>> 24 & 255;
      }
      function core_hsalsa20(o, p, k, c) {
        var j0 = c[0] & 255 | (c[1] & 255) << 8 | (c[2] & 255) << 16 | (c[3] & 255) << 24, j1 = k[0] & 255 | (k[1] & 255) << 8 | (k[2] & 255) << 16 | (k[3] & 255) << 24, j2 = k[4] & 255 | (k[5] & 255) << 8 | (k[6] & 255) << 16 | (k[7] & 255) << 24, j3 = k[8] & 255 | (k[9] & 255) << 8 | (k[10] & 255) << 16 | (k[11] & 255) << 24, j4 = k[12] & 255 | (k[13] & 255) << 8 | (k[14] & 255) << 16 | (k[15] & 255) << 24, j5 = c[4] & 255 | (c[5] & 255) << 8 | (c[6] & 255) << 16 | (c[7] & 255) << 24, j6 = p[0] & 255 | (p[1] & 255) << 8 | (p[2] & 255) << 16 | (p[3] & 255) << 24, j7 = p[4] & 255 | (p[5] & 255) << 8 | (p[6] & 255) << 16 | (p[7] & 255) << 24, j8 = p[8] & 255 | (p[9] & 255) << 8 | (p[10] & 255) << 16 | (p[11] & 255) << 24, j9 = p[12] & 255 | (p[13] & 255) << 8 | (p[14] & 255) << 16 | (p[15] & 255) << 24, j10 = c[8] & 255 | (c[9] & 255) << 8 | (c[10] & 255) << 16 | (c[11] & 255) << 24, j11 = k[16] & 255 | (k[17] & 255) << 8 | (k[18] & 255) << 16 | (k[19] & 255) << 24, j12 = k[20] & 255 | (k[21] & 255) << 8 | (k[22] & 255) << 16 | (k[23] & 255) << 24, j13 = k[24] & 255 | (k[25] & 255) << 8 | (k[26] & 255) << 16 | (k[27] & 255) << 24, j14 = k[28] & 255 | (k[29] & 255) << 8 | (k[30] & 255) << 16 | (k[31] & 255) << 24, j15 = c[12] & 255 | (c[13] & 255) << 8 | (c[14] & 255) << 16 | (c[15] & 255) << 24;
        var x0 = j0, x1 = j1, x2 = j2, x3 = j3, x4 = j4, x5 = j5, x6 = j6, x7 = j7, x8 = j8, x9 = j9, x10 = j10, x11 = j11, x12 = j12, x13 = j13, x14 = j14, x15 = j15, u;
        for (var i = 0; i < 20; i += 2) {
          u = x0 + x12 | 0;
          x4 ^= u << 7 | u >>> 32 - 7;
          u = x4 + x0 | 0;
          x8 ^= u << 9 | u >>> 32 - 9;
          u = x8 + x4 | 0;
          x12 ^= u << 13 | u >>> 32 - 13;
          u = x12 + x8 | 0;
          x0 ^= u << 18 | u >>> 32 - 18;
          u = x5 + x1 | 0;
          x9 ^= u << 7 | u >>> 32 - 7;
          u = x9 + x5 | 0;
          x13 ^= u << 9 | u >>> 32 - 9;
          u = x13 + x9 | 0;
          x1 ^= u << 13 | u >>> 32 - 13;
          u = x1 + x13 | 0;
          x5 ^= u << 18 | u >>> 32 - 18;
          u = x10 + x6 | 0;
          x14 ^= u << 7 | u >>> 32 - 7;
          u = x14 + x10 | 0;
          x2 ^= u << 9 | u >>> 32 - 9;
          u = x2 + x14 | 0;
          x6 ^= u << 13 | u >>> 32 - 13;
          u = x6 + x2 | 0;
          x10 ^= u << 18 | u >>> 32 - 18;
          u = x15 + x11 | 0;
          x3 ^= u << 7 | u >>> 32 - 7;
          u = x3 + x15 | 0;
          x7 ^= u << 9 | u >>> 32 - 9;
          u = x7 + x3 | 0;
          x11 ^= u << 13 | u >>> 32 - 13;
          u = x11 + x7 | 0;
          x15 ^= u << 18 | u >>> 32 - 18;
          u = x0 + x3 | 0;
          x1 ^= u << 7 | u >>> 32 - 7;
          u = x1 + x0 | 0;
          x2 ^= u << 9 | u >>> 32 - 9;
          u = x2 + x1 | 0;
          x3 ^= u << 13 | u >>> 32 - 13;
          u = x3 + x2 | 0;
          x0 ^= u << 18 | u >>> 32 - 18;
          u = x5 + x4 | 0;
          x6 ^= u << 7 | u >>> 32 - 7;
          u = x6 + x5 | 0;
          x7 ^= u << 9 | u >>> 32 - 9;
          u = x7 + x6 | 0;
          x4 ^= u << 13 | u >>> 32 - 13;
          u = x4 + x7 | 0;
          x5 ^= u << 18 | u >>> 32 - 18;
          u = x10 + x9 | 0;
          x11 ^= u << 7 | u >>> 32 - 7;
          u = x11 + x10 | 0;
          x8 ^= u << 9 | u >>> 32 - 9;
          u = x8 + x11 | 0;
          x9 ^= u << 13 | u >>> 32 - 13;
          u = x9 + x8 | 0;
          x10 ^= u << 18 | u >>> 32 - 18;
          u = x15 + x14 | 0;
          x12 ^= u << 7 | u >>> 32 - 7;
          u = x12 + x15 | 0;
          x13 ^= u << 9 | u >>> 32 - 9;
          u = x13 + x12 | 0;
          x14 ^= u << 13 | u >>> 32 - 13;
          u = x14 + x13 | 0;
          x15 ^= u << 18 | u >>> 32 - 18;
        }
        o[0] = x0 >>> 0 & 255;
        o[1] = x0 >>> 8 & 255;
        o[2] = x0 >>> 16 & 255;
        o[3] = x0 >>> 24 & 255;
        o[4] = x5 >>> 0 & 255;
        o[5] = x5 >>> 8 & 255;
        o[6] = x5 >>> 16 & 255;
        o[7] = x5 >>> 24 & 255;
        o[8] = x10 >>> 0 & 255;
        o[9] = x10 >>> 8 & 255;
        o[10] = x10 >>> 16 & 255;
        o[11] = x10 >>> 24 & 255;
        o[12] = x15 >>> 0 & 255;
        o[13] = x15 >>> 8 & 255;
        o[14] = x15 >>> 16 & 255;
        o[15] = x15 >>> 24 & 255;
        o[16] = x6 >>> 0 & 255;
        o[17] = x6 >>> 8 & 255;
        o[18] = x6 >>> 16 & 255;
        o[19] = x6 >>> 24 & 255;
        o[20] = x7 >>> 0 & 255;
        o[21] = x7 >>> 8 & 255;
        o[22] = x7 >>> 16 & 255;
        o[23] = x7 >>> 24 & 255;
        o[24] = x8 >>> 0 & 255;
        o[25] = x8 >>> 8 & 255;
        o[26] = x8 >>> 16 & 255;
        o[27] = x8 >>> 24 & 255;
        o[28] = x9 >>> 0 & 255;
        o[29] = x9 >>> 8 & 255;
        o[30] = x9 >>> 16 & 255;
        o[31] = x9 >>> 24 & 255;
      }
      function crypto_core_salsa20(out, inp, k, c) {
        core_salsa20(out, inp, k, c);
      }
      function crypto_core_hsalsa20(out, inp, k, c) {
        core_hsalsa20(out, inp, k, c);
      }
      var sigma = new Uint8Array([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
      function crypto_stream_salsa20_xor(c, cpos, m, mpos, b, n, k) {
        var z = new Uint8Array(16), x = new Uint8Array(64);
        var u, i;
        for (i = 0; i < 16; i++)
          z[i] = 0;
        for (i = 0; i < 8; i++)
          z[i] = n[i];
        while (b >= 64) {
          crypto_core_salsa20(x, z, k, sigma);
          for (i = 0; i < 64; i++)
            c[cpos + i] = m[mpos + i] ^ x[i];
          u = 1;
          for (i = 8; i < 16; i++) {
            u = u + (z[i] & 255) | 0;
            z[i] = u & 255;
            u >>>= 8;
          }
          b -= 64;
          cpos += 64;
          mpos += 64;
        }
        if (b > 0) {
          crypto_core_salsa20(x, z, k, sigma);
          for (i = 0; i < b; i++)
            c[cpos + i] = m[mpos + i] ^ x[i];
        }
        return 0;
      }
      function crypto_stream_salsa20(c, cpos, b, n, k) {
        var z = new Uint8Array(16), x = new Uint8Array(64);
        var u, i;
        for (i = 0; i < 16; i++)
          z[i] = 0;
        for (i = 0; i < 8; i++)
          z[i] = n[i];
        while (b >= 64) {
          crypto_core_salsa20(x, z, k, sigma);
          for (i = 0; i < 64; i++)
            c[cpos + i] = x[i];
          u = 1;
          for (i = 8; i < 16; i++) {
            u = u + (z[i] & 255) | 0;
            z[i] = u & 255;
            u >>>= 8;
          }
          b -= 64;
          cpos += 64;
        }
        if (b > 0) {
          crypto_core_salsa20(x, z, k, sigma);
          for (i = 0; i < b; i++)
            c[cpos + i] = x[i];
        }
        return 0;
      }
      function crypto_stream(c, cpos, d, n, k) {
        var s = new Uint8Array(32);
        crypto_core_hsalsa20(s, n, k, sigma);
        var sn = new Uint8Array(8);
        for (var i = 0; i < 8; i++)
          sn[i] = n[i + 16];
        return crypto_stream_salsa20(c, cpos, d, sn, s);
      }
      function crypto_stream_xor(c, cpos, m, mpos, d, n, k) {
        var s = new Uint8Array(32);
        crypto_core_hsalsa20(s, n, k, sigma);
        var sn = new Uint8Array(8);
        for (var i = 0; i < 8; i++)
          sn[i] = n[i + 16];
        return crypto_stream_salsa20_xor(c, cpos, m, mpos, d, sn, s);
      }
      var poly1305 = function(key) {
        this.buffer = new Uint8Array(16);
        this.r = new Uint16Array(10);
        this.h = new Uint16Array(10);
        this.pad = new Uint16Array(8);
        this.leftover = 0;
        this.fin = 0;
        var t0, t1, t2, t3, t4, t5, t6, t7;
        t0 = key[0] & 255 | (key[1] & 255) << 8;
        this.r[0] = t0 & 8191;
        t1 = key[2] & 255 | (key[3] & 255) << 8;
        this.r[1] = (t0 >>> 13 | t1 << 3) & 8191;
        t2 = key[4] & 255 | (key[5] & 255) << 8;
        this.r[2] = (t1 >>> 10 | t2 << 6) & 7939;
        t3 = key[6] & 255 | (key[7] & 255) << 8;
        this.r[3] = (t2 >>> 7 | t3 << 9) & 8191;
        t4 = key[8] & 255 | (key[9] & 255) << 8;
        this.r[4] = (t3 >>> 4 | t4 << 12) & 255;
        this.r[5] = t4 >>> 1 & 8190;
        t5 = key[10] & 255 | (key[11] & 255) << 8;
        this.r[6] = (t4 >>> 14 | t5 << 2) & 8191;
        t6 = key[12] & 255 | (key[13] & 255) << 8;
        this.r[7] = (t5 >>> 11 | t6 << 5) & 8065;
        t7 = key[14] & 255 | (key[15] & 255) << 8;
        this.r[8] = (t6 >>> 8 | t7 << 8) & 8191;
        this.r[9] = t7 >>> 5 & 127;
        this.pad[0] = key[16] & 255 | (key[17] & 255) << 8;
        this.pad[1] = key[18] & 255 | (key[19] & 255) << 8;
        this.pad[2] = key[20] & 255 | (key[21] & 255) << 8;
        this.pad[3] = key[22] & 255 | (key[23] & 255) << 8;
        this.pad[4] = key[24] & 255 | (key[25] & 255) << 8;
        this.pad[5] = key[26] & 255 | (key[27] & 255) << 8;
        this.pad[6] = key[28] & 255 | (key[29] & 255) << 8;
        this.pad[7] = key[30] & 255 | (key[31] & 255) << 8;
      };
      poly1305.prototype.blocks = function(m, mpos, bytes) {
        var hibit = this.fin ? 0 : 1 << 11;
        var t0, t1, t2, t3, t4, t5, t6, t7, c;
        var d0, d1, d2, d3, d4, d5, d6, d7, d8, d9;
        var h0 = this.h[0], h1 = this.h[1], h2 = this.h[2], h3 = this.h[3], h4 = this.h[4], h5 = this.h[5], h6 = this.h[6], h7 = this.h[7], h8 = this.h[8], h9 = this.h[9];
        var r0 = this.r[0], r1 = this.r[1], r2 = this.r[2], r3 = this.r[3], r4 = this.r[4], r5 = this.r[5], r6 = this.r[6], r7 = this.r[7], r8 = this.r[8], r9 = this.r[9];
        while (bytes >= 16) {
          t0 = m[mpos + 0] & 255 | (m[mpos + 1] & 255) << 8;
          h0 += t0 & 8191;
          t1 = m[mpos + 2] & 255 | (m[mpos + 3] & 255) << 8;
          h1 += (t0 >>> 13 | t1 << 3) & 8191;
          t2 = m[mpos + 4] & 255 | (m[mpos + 5] & 255) << 8;
          h2 += (t1 >>> 10 | t2 << 6) & 8191;
          t3 = m[mpos + 6] & 255 | (m[mpos + 7] & 255) << 8;
          h3 += (t2 >>> 7 | t3 << 9) & 8191;
          t4 = m[mpos + 8] & 255 | (m[mpos + 9] & 255) << 8;
          h4 += (t3 >>> 4 | t4 << 12) & 8191;
          h5 += t4 >>> 1 & 8191;
          t5 = m[mpos + 10] & 255 | (m[mpos + 11] & 255) << 8;
          h6 += (t4 >>> 14 | t5 << 2) & 8191;
          t6 = m[mpos + 12] & 255 | (m[mpos + 13] & 255) << 8;
          h7 += (t5 >>> 11 | t6 << 5) & 8191;
          t7 = m[mpos + 14] & 255 | (m[mpos + 15] & 255) << 8;
          h8 += (t6 >>> 8 | t7 << 8) & 8191;
          h9 += t7 >>> 5 | hibit;
          c = 0;
          d0 = c;
          d0 += h0 * r0;
          d0 += h1 * (5 * r9);
          d0 += h2 * (5 * r8);
          d0 += h3 * (5 * r7);
          d0 += h4 * (5 * r6);
          c = d0 >>> 13;
          d0 &= 8191;
          d0 += h5 * (5 * r5);
          d0 += h6 * (5 * r4);
          d0 += h7 * (5 * r3);
          d0 += h8 * (5 * r2);
          d0 += h9 * (5 * r1);
          c += d0 >>> 13;
          d0 &= 8191;
          d1 = c;
          d1 += h0 * r1;
          d1 += h1 * r0;
          d1 += h2 * (5 * r9);
          d1 += h3 * (5 * r8);
          d1 += h4 * (5 * r7);
          c = d1 >>> 13;
          d1 &= 8191;
          d1 += h5 * (5 * r6);
          d1 += h6 * (5 * r5);
          d1 += h7 * (5 * r4);
          d1 += h8 * (5 * r3);
          d1 += h9 * (5 * r2);
          c += d1 >>> 13;
          d1 &= 8191;
          d2 = c;
          d2 += h0 * r2;
          d2 += h1 * r1;
          d2 += h2 * r0;
          d2 += h3 * (5 * r9);
          d2 += h4 * (5 * r8);
          c = d2 >>> 13;
          d2 &= 8191;
          d2 += h5 * (5 * r7);
          d2 += h6 * (5 * r6);
          d2 += h7 * (5 * r5);
          d2 += h8 * (5 * r4);
          d2 += h9 * (5 * r3);
          c += d2 >>> 13;
          d2 &= 8191;
          d3 = c;
          d3 += h0 * r3;
          d3 += h1 * r2;
          d3 += h2 * r1;
          d3 += h3 * r0;
          d3 += h4 * (5 * r9);
          c = d3 >>> 13;
          d3 &= 8191;
          d3 += h5 * (5 * r8);
          d3 += h6 * (5 * r7);
          d3 += h7 * (5 * r6);
          d3 += h8 * (5 * r5);
          d3 += h9 * (5 * r4);
          c += d3 >>> 13;
          d3 &= 8191;
          d4 = c;
          d4 += h0 * r4;
          d4 += h1 * r3;
          d4 += h2 * r2;
          d4 += h3 * r1;
          d4 += h4 * r0;
          c = d4 >>> 13;
          d4 &= 8191;
          d4 += h5 * (5 * r9);
          d4 += h6 * (5 * r8);
          d4 += h7 * (5 * r7);
          d4 += h8 * (5 * r6);
          d4 += h9 * (5 * r5);
          c += d4 >>> 13;
          d4 &= 8191;
          d5 = c;
          d5 += h0 * r5;
          d5 += h1 * r4;
          d5 += h2 * r3;
          d5 += h3 * r2;
          d5 += h4 * r1;
          c = d5 >>> 13;
          d5 &= 8191;
          d5 += h5 * r0;
          d5 += h6 * (5 * r9);
          d5 += h7 * (5 * r8);
          d5 += h8 * (5 * r7);
          d5 += h9 * (5 * r6);
          c += d5 >>> 13;
          d5 &= 8191;
          d6 = c;
          d6 += h0 * r6;
          d6 += h1 * r5;
          d6 += h2 * r4;
          d6 += h3 * r3;
          d6 += h4 * r2;
          c = d6 >>> 13;
          d6 &= 8191;
          d6 += h5 * r1;
          d6 += h6 * r0;
          d6 += h7 * (5 * r9);
          d6 += h8 * (5 * r8);
          d6 += h9 * (5 * r7);
          c += d6 >>> 13;
          d6 &= 8191;
          d7 = c;
          d7 += h0 * r7;
          d7 += h1 * r6;
          d7 += h2 * r5;
          d7 += h3 * r4;
          d7 += h4 * r3;
          c = d7 >>> 13;
          d7 &= 8191;
          d7 += h5 * r2;
          d7 += h6 * r1;
          d7 += h7 * r0;
          d7 += h8 * (5 * r9);
          d7 += h9 * (5 * r8);
          c += d7 >>> 13;
          d7 &= 8191;
          d8 = c;
          d8 += h0 * r8;
          d8 += h1 * r7;
          d8 += h2 * r6;
          d8 += h3 * r5;
          d8 += h4 * r4;
          c = d8 >>> 13;
          d8 &= 8191;
          d8 += h5 * r3;
          d8 += h6 * r2;
          d8 += h7 * r1;
          d8 += h8 * r0;
          d8 += h9 * (5 * r9);
          c += d8 >>> 13;
          d8 &= 8191;
          d9 = c;
          d9 += h0 * r9;
          d9 += h1 * r8;
          d9 += h2 * r7;
          d9 += h3 * r6;
          d9 += h4 * r5;
          c = d9 >>> 13;
          d9 &= 8191;
          d9 += h5 * r4;
          d9 += h6 * r3;
          d9 += h7 * r2;
          d9 += h8 * r1;
          d9 += h9 * r0;
          c += d9 >>> 13;
          d9 &= 8191;
          c = (c << 2) + c | 0;
          c = c + d0 | 0;
          d0 = c & 8191;
          c = c >>> 13;
          d1 += c;
          h0 = d0;
          h1 = d1;
          h2 = d2;
          h3 = d3;
          h4 = d4;
          h5 = d5;
          h6 = d6;
          h7 = d7;
          h8 = d8;
          h9 = d9;
          mpos += 16;
          bytes -= 16;
        }
        this.h[0] = h0;
        this.h[1] = h1;
        this.h[2] = h2;
        this.h[3] = h3;
        this.h[4] = h4;
        this.h[5] = h5;
        this.h[6] = h6;
        this.h[7] = h7;
        this.h[8] = h8;
        this.h[9] = h9;
      };
      poly1305.prototype.finish = function(mac, macpos) {
        var g = new Uint16Array(10);
        var c, mask, f, i;
        if (this.leftover) {
          i = this.leftover;
          this.buffer[i++] = 1;
          for (; i < 16; i++)
            this.buffer[i] = 0;
          this.fin = 1;
          this.blocks(this.buffer, 0, 16);
        }
        c = this.h[1] >>> 13;
        this.h[1] &= 8191;
        for (i = 2; i < 10; i++) {
          this.h[i] += c;
          c = this.h[i] >>> 13;
          this.h[i] &= 8191;
        }
        this.h[0] += c * 5;
        c = this.h[0] >>> 13;
        this.h[0] &= 8191;
        this.h[1] += c;
        c = this.h[1] >>> 13;
        this.h[1] &= 8191;
        this.h[2] += c;
        g[0] = this.h[0] + 5;
        c = g[0] >>> 13;
        g[0] &= 8191;
        for (i = 1; i < 10; i++) {
          g[i] = this.h[i] + c;
          c = g[i] >>> 13;
          g[i] &= 8191;
        }
        g[9] -= 1 << 13;
        mask = (c ^ 1) - 1;
        for (i = 0; i < 10; i++)
          g[i] &= mask;
        mask = ~mask;
        for (i = 0; i < 10; i++)
          this.h[i] = this.h[i] & mask | g[i];
        this.h[0] = (this.h[0] | this.h[1] << 13) & 65535;
        this.h[1] = (this.h[1] >>> 3 | this.h[2] << 10) & 65535;
        this.h[2] = (this.h[2] >>> 6 | this.h[3] << 7) & 65535;
        this.h[3] = (this.h[3] >>> 9 | this.h[4] << 4) & 65535;
        this.h[4] = (this.h[4] >>> 12 | this.h[5] << 1 | this.h[6] << 14) & 65535;
        this.h[5] = (this.h[6] >>> 2 | this.h[7] << 11) & 65535;
        this.h[6] = (this.h[7] >>> 5 | this.h[8] << 8) & 65535;
        this.h[7] = (this.h[8] >>> 8 | this.h[9] << 5) & 65535;
        f = this.h[0] + this.pad[0];
        this.h[0] = f & 65535;
        for (i = 1; i < 8; i++) {
          f = (this.h[i] + this.pad[i] | 0) + (f >>> 16) | 0;
          this.h[i] = f & 65535;
        }
        mac[macpos + 0] = this.h[0] >>> 0 & 255;
        mac[macpos + 1] = this.h[0] >>> 8 & 255;
        mac[macpos + 2] = this.h[1] >>> 0 & 255;
        mac[macpos + 3] = this.h[1] >>> 8 & 255;
        mac[macpos + 4] = this.h[2] >>> 0 & 255;
        mac[macpos + 5] = this.h[2] >>> 8 & 255;
        mac[macpos + 6] = this.h[3] >>> 0 & 255;
        mac[macpos + 7] = this.h[3] >>> 8 & 255;
        mac[macpos + 8] = this.h[4] >>> 0 & 255;
        mac[macpos + 9] = this.h[4] >>> 8 & 255;
        mac[macpos + 10] = this.h[5] >>> 0 & 255;
        mac[macpos + 11] = this.h[5] >>> 8 & 255;
        mac[macpos + 12] = this.h[6] >>> 0 & 255;
        mac[macpos + 13] = this.h[6] >>> 8 & 255;
        mac[macpos + 14] = this.h[7] >>> 0 & 255;
        mac[macpos + 15] = this.h[7] >>> 8 & 255;
      };
      poly1305.prototype.update = function(m, mpos, bytes) {
        var i, want;
        if (this.leftover) {
          want = 16 - this.leftover;
          if (want > bytes)
            want = bytes;
          for (i = 0; i < want; i++)
            this.buffer[this.leftover + i] = m[mpos + i];
          bytes -= want;
          mpos += want;
          this.leftover += want;
          if (this.leftover < 16)
            return;
          this.blocks(this.buffer, 0, 16);
          this.leftover = 0;
        }
        if (bytes >= 16) {
          want = bytes - bytes % 16;
          this.blocks(m, mpos, want);
          mpos += want;
          bytes -= want;
        }
        if (bytes) {
          for (i = 0; i < bytes; i++)
            this.buffer[this.leftover + i] = m[mpos + i];
          this.leftover += bytes;
        }
      };
      function crypto_onetimeauth(out, outpos, m, mpos, n, k) {
        var s = new poly1305(k);
        s.update(m, mpos, n);
        s.finish(out, outpos);
        return 0;
      }
      function crypto_onetimeauth_verify(h, hpos, m, mpos, n, k) {
        var x = new Uint8Array(16);
        crypto_onetimeauth(x, 0, m, mpos, n, k);
        return crypto_verify_16(h, hpos, x, 0);
      }
      function crypto_secretbox(c, m, d, n, k) {
        var i;
        if (d < 32)
          return -1;
        crypto_stream_xor(c, 0, m, 0, d, n, k);
        crypto_onetimeauth(c, 16, c, 32, d - 32, c);
        for (i = 0; i < 16; i++)
          c[i] = 0;
        return 0;
      }
      function crypto_secretbox_open(m, c, d, n, k) {
        var i;
        var x = new Uint8Array(32);
        if (d < 32)
          return -1;
        crypto_stream(x, 0, 32, n, k);
        if (crypto_onetimeauth_verify(c, 16, c, 32, d - 32, x) !== 0)
          return -1;
        crypto_stream_xor(m, 0, c, 0, d, n, k);
        for (i = 0; i < 32; i++)
          m[i] = 0;
        return 0;
      }
      function set25519(r, a) {
        var i;
        for (i = 0; i < 16; i++)
          r[i] = a[i] | 0;
      }
      function car25519(o) {
        var i, v, c = 1;
        for (i = 0; i < 16; i++) {
          v = o[i] + c + 65535;
          c = Math.floor(v / 65536);
          o[i] = v - c * 65536;
        }
        o[0] += c - 1 + 37 * (c - 1);
      }
      function sel25519(p, q, b) {
        var t, c = ~(b - 1);
        for (var i = 0; i < 16; i++) {
          t = c & (p[i] ^ q[i]);
          p[i] ^= t;
          q[i] ^= t;
        }
      }
      function pack25519(o, n) {
        var i, j, b;
        var m = gf(), t = gf();
        for (i = 0; i < 16; i++)
          t[i] = n[i];
        car25519(t);
        car25519(t);
        car25519(t);
        for (j = 0; j < 2; j++) {
          m[0] = t[0] - 65517;
          for (i = 1; i < 15; i++) {
            m[i] = t[i] - 65535 - (m[i - 1] >> 16 & 1);
            m[i - 1] &= 65535;
          }
          m[15] = t[15] - 32767 - (m[14] >> 16 & 1);
          b = m[15] >> 16 & 1;
          m[14] &= 65535;
          sel25519(t, m, 1 - b);
        }
        for (i = 0; i < 16; i++) {
          o[2 * i] = t[i] & 255;
          o[2 * i + 1] = t[i] >> 8;
        }
      }
      function neq25519(a, b) {
        var c = new Uint8Array(32), d = new Uint8Array(32);
        pack25519(c, a);
        pack25519(d, b);
        return crypto_verify_32(c, 0, d, 0);
      }
      function par25519(a) {
        var d = new Uint8Array(32);
        pack25519(d, a);
        return d[0] & 1;
      }
      function unpack25519(o, n) {
        var i;
        for (i = 0; i < 16; i++)
          o[i] = n[2 * i] + (n[2 * i + 1] << 8);
        o[15] &= 32767;
      }
      function A(o, a, b) {
        for (var i = 0; i < 16; i++)
          o[i] = a[i] + b[i];
      }
      function Z(o, a, b) {
        for (var i = 0; i < 16; i++)
          o[i] = a[i] - b[i];
      }
      function M(o, a, b) {
        var v, c, t0 = 0, t1 = 0, t2 = 0, t3 = 0, t4 = 0, t5 = 0, t6 = 0, t7 = 0, t8 = 0, t9 = 0, t10 = 0, t11 = 0, t12 = 0, t13 = 0, t14 = 0, t15 = 0, t16 = 0, t17 = 0, t18 = 0, t19 = 0, t20 = 0, t21 = 0, t22 = 0, t23 = 0, t24 = 0, t25 = 0, t26 = 0, t27 = 0, t28 = 0, t29 = 0, t30 = 0, b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5], b6 = b[6], b7 = b[7], b8 = b[8], b9 = b[9], b10 = b[10], b11 = b[11], b12 = b[12], b13 = b[13], b14 = b[14], b15 = b[15];
        v = a[0];
        t0 += v * b0;
        t1 += v * b1;
        t2 += v * b2;
        t3 += v * b3;
        t4 += v * b4;
        t5 += v * b5;
        t6 += v * b6;
        t7 += v * b7;
        t8 += v * b8;
        t9 += v * b9;
        t10 += v * b10;
        t11 += v * b11;
        t12 += v * b12;
        t13 += v * b13;
        t14 += v * b14;
        t15 += v * b15;
        v = a[1];
        t1 += v * b0;
        t2 += v * b1;
        t3 += v * b2;
        t4 += v * b3;
        t5 += v * b4;
        t6 += v * b5;
        t7 += v * b6;
        t8 += v * b7;
        t9 += v * b8;
        t10 += v * b9;
        t11 += v * b10;
        t12 += v * b11;
        t13 += v * b12;
        t14 += v * b13;
        t15 += v * b14;
        t16 += v * b15;
        v = a[2];
        t2 += v * b0;
        t3 += v * b1;
        t4 += v * b2;
        t5 += v * b3;
        t6 += v * b4;
        t7 += v * b5;
        t8 += v * b6;
        t9 += v * b7;
        t10 += v * b8;
        t11 += v * b9;
        t12 += v * b10;
        t13 += v * b11;
        t14 += v * b12;
        t15 += v * b13;
        t16 += v * b14;
        t17 += v * b15;
        v = a[3];
        t3 += v * b0;
        t4 += v * b1;
        t5 += v * b2;
        t6 += v * b3;
        t7 += v * b4;
        t8 += v * b5;
        t9 += v * b6;
        t10 += v * b7;
        t11 += v * b8;
        t12 += v * b9;
        t13 += v * b10;
        t14 += v * b11;
        t15 += v * b12;
        t16 += v * b13;
        t17 += v * b14;
        t18 += v * b15;
        v = a[4];
        t4 += v * b0;
        t5 += v * b1;
        t6 += v * b2;
        t7 += v * b3;
        t8 += v * b4;
        t9 += v * b5;
        t10 += v * b6;
        t11 += v * b7;
        t12 += v * b8;
        t13 += v * b9;
        t14 += v * b10;
        t15 += v * b11;
        t16 += v * b12;
        t17 += v * b13;
        t18 += v * b14;
        t19 += v * b15;
        v = a[5];
        t5 += v * b0;
        t6 += v * b1;
        t7 += v * b2;
        t8 += v * b3;
        t9 += v * b4;
        t10 += v * b5;
        t11 += v * b6;
        t12 += v * b7;
        t13 += v * b8;
        t14 += v * b9;
        t15 += v * b10;
        t16 += v * b11;
        t17 += v * b12;
        t18 += v * b13;
        t19 += v * b14;
        t20 += v * b15;
        v = a[6];
        t6 += v * b0;
        t7 += v * b1;
        t8 += v * b2;
        t9 += v * b3;
        t10 += v * b4;
        t11 += v * b5;
        t12 += v * b6;
        t13 += v * b7;
        t14 += v * b8;
        t15 += v * b9;
        t16 += v * b10;
        t17 += v * b11;
        t18 += v * b12;
        t19 += v * b13;
        t20 += v * b14;
        t21 += v * b15;
        v = a[7];
        t7 += v * b0;
        t8 += v * b1;
        t9 += v * b2;
        t10 += v * b3;
        t11 += v * b4;
        t12 += v * b5;
        t13 += v * b6;
        t14 += v * b7;
        t15 += v * b8;
        t16 += v * b9;
        t17 += v * b10;
        t18 += v * b11;
        t19 += v * b12;
        t20 += v * b13;
        t21 += v * b14;
        t22 += v * b15;
        v = a[8];
        t8 += v * b0;
        t9 += v * b1;
        t10 += v * b2;
        t11 += v * b3;
        t12 += v * b4;
        t13 += v * b5;
        t14 += v * b6;
        t15 += v * b7;
        t16 += v * b8;
        t17 += v * b9;
        t18 += v * b10;
        t19 += v * b11;
        t20 += v * b12;
        t21 += v * b13;
        t22 += v * b14;
        t23 += v * b15;
        v = a[9];
        t9 += v * b0;
        t10 += v * b1;
        t11 += v * b2;
        t12 += v * b3;
        t13 += v * b4;
        t14 += v * b5;
        t15 += v * b6;
        t16 += v * b7;
        t17 += v * b8;
        t18 += v * b9;
        t19 += v * b10;
        t20 += v * b11;
        t21 += v * b12;
        t22 += v * b13;
        t23 += v * b14;
        t24 += v * b15;
        v = a[10];
        t10 += v * b0;
        t11 += v * b1;
        t12 += v * b2;
        t13 += v * b3;
        t14 += v * b4;
        t15 += v * b5;
        t16 += v * b6;
        t17 += v * b7;
        t18 += v * b8;
        t19 += v * b9;
        t20 += v * b10;
        t21 += v * b11;
        t22 += v * b12;
        t23 += v * b13;
        t24 += v * b14;
        t25 += v * b15;
        v = a[11];
        t11 += v * b0;
        t12 += v * b1;
        t13 += v * b2;
        t14 += v * b3;
        t15 += v * b4;
        t16 += v * b5;
        t17 += v * b6;
        t18 += v * b7;
        t19 += v * b8;
        t20 += v * b9;
        t21 += v * b10;
        t22 += v * b11;
        t23 += v * b12;
        t24 += v * b13;
        t25 += v * b14;
        t26 += v * b15;
        v = a[12];
        t12 += v * b0;
        t13 += v * b1;
        t14 += v * b2;
        t15 += v * b3;
        t16 += v * b4;
        t17 += v * b5;
        t18 += v * b6;
        t19 += v * b7;
        t20 += v * b8;
        t21 += v * b9;
        t22 += v * b10;
        t23 += v * b11;
        t24 += v * b12;
        t25 += v * b13;
        t26 += v * b14;
        t27 += v * b15;
        v = a[13];
        t13 += v * b0;
        t14 += v * b1;
        t15 += v * b2;
        t16 += v * b3;
        t17 += v * b4;
        t18 += v * b5;
        t19 += v * b6;
        t20 += v * b7;
        t21 += v * b8;
        t22 += v * b9;
        t23 += v * b10;
        t24 += v * b11;
        t25 += v * b12;
        t26 += v * b13;
        t27 += v * b14;
        t28 += v * b15;
        v = a[14];
        t14 += v * b0;
        t15 += v * b1;
        t16 += v * b2;
        t17 += v * b3;
        t18 += v * b4;
        t19 += v * b5;
        t20 += v * b6;
        t21 += v * b7;
        t22 += v * b8;
        t23 += v * b9;
        t24 += v * b10;
        t25 += v * b11;
        t26 += v * b12;
        t27 += v * b13;
        t28 += v * b14;
        t29 += v * b15;
        v = a[15];
        t15 += v * b0;
        t16 += v * b1;
        t17 += v * b2;
        t18 += v * b3;
        t19 += v * b4;
        t20 += v * b5;
        t21 += v * b6;
        t22 += v * b7;
        t23 += v * b8;
        t24 += v * b9;
        t25 += v * b10;
        t26 += v * b11;
        t27 += v * b12;
        t28 += v * b13;
        t29 += v * b14;
        t30 += v * b15;
        t0 += 38 * t16;
        t1 += 38 * t17;
        t2 += 38 * t18;
        t3 += 38 * t19;
        t4 += 38 * t20;
        t5 += 38 * t21;
        t6 += 38 * t22;
        t7 += 38 * t23;
        t8 += 38 * t24;
        t9 += 38 * t25;
        t10 += 38 * t26;
        t11 += 38 * t27;
        t12 += 38 * t28;
        t13 += 38 * t29;
        t14 += 38 * t30;
        c = 1;
        v = t0 + c + 65535;
        c = Math.floor(v / 65536);
        t0 = v - c * 65536;
        v = t1 + c + 65535;
        c = Math.floor(v / 65536);
        t1 = v - c * 65536;
        v = t2 + c + 65535;
        c = Math.floor(v / 65536);
        t2 = v - c * 65536;
        v = t3 + c + 65535;
        c = Math.floor(v / 65536);
        t3 = v - c * 65536;
        v = t4 + c + 65535;
        c = Math.floor(v / 65536);
        t4 = v - c * 65536;
        v = t5 + c + 65535;
        c = Math.floor(v / 65536);
        t5 = v - c * 65536;
        v = t6 + c + 65535;
        c = Math.floor(v / 65536);
        t6 = v - c * 65536;
        v = t7 + c + 65535;
        c = Math.floor(v / 65536);
        t7 = v - c * 65536;
        v = t8 + c + 65535;
        c = Math.floor(v / 65536);
        t8 = v - c * 65536;
        v = t9 + c + 65535;
        c = Math.floor(v / 65536);
        t9 = v - c * 65536;
        v = t10 + c + 65535;
        c = Math.floor(v / 65536);
        t10 = v - c * 65536;
        v = t11 + c + 65535;
        c = Math.floor(v / 65536);
        t11 = v - c * 65536;
        v = t12 + c + 65535;
        c = Math.floor(v / 65536);
        t12 = v - c * 65536;
        v = t13 + c + 65535;
        c = Math.floor(v / 65536);
        t13 = v - c * 65536;
        v = t14 + c + 65535;
        c = Math.floor(v / 65536);
        t14 = v - c * 65536;
        v = t15 + c + 65535;
        c = Math.floor(v / 65536);
        t15 = v - c * 65536;
        t0 += c - 1 + 37 * (c - 1);
        c = 1;
        v = t0 + c + 65535;
        c = Math.floor(v / 65536);
        t0 = v - c * 65536;
        v = t1 + c + 65535;
        c = Math.floor(v / 65536);
        t1 = v - c * 65536;
        v = t2 + c + 65535;
        c = Math.floor(v / 65536);
        t2 = v - c * 65536;
        v = t3 + c + 65535;
        c = Math.floor(v / 65536);
        t3 = v - c * 65536;
        v = t4 + c + 65535;
        c = Math.floor(v / 65536);
        t4 = v - c * 65536;
        v = t5 + c + 65535;
        c = Math.floor(v / 65536);
        t5 = v - c * 65536;
        v = t6 + c + 65535;
        c = Math.floor(v / 65536);
        t6 = v - c * 65536;
        v = t7 + c + 65535;
        c = Math.floor(v / 65536);
        t7 = v - c * 65536;
        v = t8 + c + 65535;
        c = Math.floor(v / 65536);
        t8 = v - c * 65536;
        v = t9 + c + 65535;
        c = Math.floor(v / 65536);
        t9 = v - c * 65536;
        v = t10 + c + 65535;
        c = Math.floor(v / 65536);
        t10 = v - c * 65536;
        v = t11 + c + 65535;
        c = Math.floor(v / 65536);
        t11 = v - c * 65536;
        v = t12 + c + 65535;
        c = Math.floor(v / 65536);
        t12 = v - c * 65536;
        v = t13 + c + 65535;
        c = Math.floor(v / 65536);
        t13 = v - c * 65536;
        v = t14 + c + 65535;
        c = Math.floor(v / 65536);
        t14 = v - c * 65536;
        v = t15 + c + 65535;
        c = Math.floor(v / 65536);
        t15 = v - c * 65536;
        t0 += c - 1 + 37 * (c - 1);
        o[0] = t0;
        o[1] = t1;
        o[2] = t2;
        o[3] = t3;
        o[4] = t4;
        o[5] = t5;
        o[6] = t6;
        o[7] = t7;
        o[8] = t8;
        o[9] = t9;
        o[10] = t10;
        o[11] = t11;
        o[12] = t12;
        o[13] = t13;
        o[14] = t14;
        o[15] = t15;
      }
      function S(o, a) {
        M(o, a, a);
      }
      function inv25519(o, i) {
        var c = gf();
        var a;
        for (a = 0; a < 16; a++)
          c[a] = i[a];
        for (a = 253; a >= 0; a--) {
          S(c, c);
          if (a !== 2 && a !== 4)
            M(c, c, i);
        }
        for (a = 0; a < 16; a++)
          o[a] = c[a];
      }
      function pow2523(o, i) {
        var c = gf();
        var a;
        for (a = 0; a < 16; a++)
          c[a] = i[a];
        for (a = 250; a >= 0; a--) {
          S(c, c);
          if (a !== 1)
            M(c, c, i);
        }
        for (a = 0; a < 16; a++)
          o[a] = c[a];
      }
      function crypto_scalarmult(q, n, p) {
        var z = new Uint8Array(32);
        var x = new Float64Array(80), r, i;
        var a = gf(), b = gf(), c = gf(), d = gf(), e = gf(), f = gf();
        for (i = 0; i < 31; i++)
          z[i] = n[i];
        z[31] = n[31] & 127 | 64;
        z[0] &= 248;
        unpack25519(x, p);
        for (i = 0; i < 16; i++) {
          b[i] = x[i];
          d[i] = a[i] = c[i] = 0;
        }
        a[0] = d[0] = 1;
        for (i = 254; i >= 0; --i) {
          r = z[i >>> 3] >>> (i & 7) & 1;
          sel25519(a, b, r);
          sel25519(c, d, r);
          A(e, a, c);
          Z(a, a, c);
          A(c, b, d);
          Z(b, b, d);
          S(d, e);
          S(f, a);
          M(a, c, a);
          M(c, b, e);
          A(e, a, c);
          Z(a, a, c);
          S(b, a);
          Z(c, d, f);
          M(a, c, _121665);
          A(a, a, d);
          M(c, c, a);
          M(a, d, f);
          M(d, b, x);
          S(b, e);
          sel25519(a, b, r);
          sel25519(c, d, r);
        }
        for (i = 0; i < 16; i++) {
          x[i + 16] = a[i];
          x[i + 32] = c[i];
          x[i + 48] = b[i];
          x[i + 64] = d[i];
        }
        var x32 = x.subarray(32);
        var x16 = x.subarray(16);
        inv25519(x32, x32);
        M(x16, x16, x32);
        pack25519(q, x16);
        return 0;
      }
      function crypto_scalarmult_base(q, n) {
        return crypto_scalarmult(q, n, _9);
      }
      function crypto_box_keypair(y, x) {
        randombytes(x, 32);
        return crypto_scalarmult_base(y, x);
      }
      function crypto_box_beforenm(k, y, x) {
        var s = new Uint8Array(32);
        crypto_scalarmult(s, x, y);
        return crypto_core_hsalsa20(k, _0, s, sigma);
      }
      var crypto_box_afternm = crypto_secretbox;
      var crypto_box_open_afternm = crypto_secretbox_open;
      function crypto_box(c, m, d, n, y, x) {
        var k = new Uint8Array(32);
        crypto_box_beforenm(k, y, x);
        return crypto_box_afternm(c, m, d, n, k);
      }
      function crypto_box_open(m, c, d, n, y, x) {
        var k = new Uint8Array(32);
        crypto_box_beforenm(k, y, x);
        return crypto_box_open_afternm(m, c, d, n, k);
      }
      var K = [
        1116352408,
        3609767458,
        1899447441,
        602891725,
        3049323471,
        3964484399,
        3921009573,
        2173295548,
        961987163,
        4081628472,
        1508970993,
        3053834265,
        2453635748,
        2937671579,
        2870763221,
        3664609560,
        3624381080,
        2734883394,
        310598401,
        1164996542,
        607225278,
        1323610764,
        1426881987,
        3590304994,
        1925078388,
        4068182383,
        2162078206,
        991336113,
        2614888103,
        633803317,
        3248222580,
        3479774868,
        3835390401,
        2666613458,
        4022224774,
        944711139,
        264347078,
        2341262773,
        604807628,
        2007800933,
        770255983,
        1495990901,
        1249150122,
        1856431235,
        1555081692,
        3175218132,
        1996064986,
        2198950837,
        2554220882,
        3999719339,
        2821834349,
        766784016,
        2952996808,
        2566594879,
        3210313671,
        3203337956,
        3336571891,
        1034457026,
        3584528711,
        2466948901,
        113926993,
        3758326383,
        338241895,
        168717936,
        666307205,
        1188179964,
        773529912,
        1546045734,
        1294757372,
        1522805485,
        1396182291,
        2643833823,
        1695183700,
        2343527390,
        1986661051,
        1014477480,
        2177026350,
        1206759142,
        2456956037,
        344077627,
        2730485921,
        1290863460,
        2820302411,
        3158454273,
        3259730800,
        3505952657,
        3345764771,
        106217008,
        3516065817,
        3606008344,
        3600352804,
        1432725776,
        4094571909,
        1467031594,
        275423344,
        851169720,
        430227734,
        3100823752,
        506948616,
        1363258195,
        659060556,
        3750685593,
        883997877,
        3785050280,
        958139571,
        3318307427,
        1322822218,
        3812723403,
        1537002063,
        2003034995,
        1747873779,
        3602036899,
        1955562222,
        1575990012,
        2024104815,
        1125592928,
        2227730452,
        2716904306,
        2361852424,
        442776044,
        2428436474,
        593698344,
        2756734187,
        3733110249,
        3204031479,
        2999351573,
        3329325298,
        3815920427,
        3391569614,
        3928383900,
        3515267271,
        566280711,
        3940187606,
        3454069534,
        4118630271,
        4000239992,
        116418474,
        1914138554,
        174292421,
        2731055270,
        289380356,
        3203993006,
        460393269,
        320620315,
        685471733,
        587496836,
        852142971,
        1086792851,
        1017036298,
        365543100,
        1126000580,
        2618297676,
        1288033470,
        3409855158,
        1501505948,
        4234509866,
        1607167915,
        987167468,
        1816402316,
        1246189591
      ];
      function crypto_hashblocks_hl(hh, hl, m, n) {
        var wh = new Int32Array(16), wl = new Int32Array(16), bh0, bh1, bh2, bh3, bh4, bh5, bh6, bh7, bl0, bl1, bl2, bl3, bl4, bl5, bl6, bl7, th, tl, i, j, h, l, a, b, c, d;
        var ah0 = hh[0], ah1 = hh[1], ah2 = hh[2], ah3 = hh[3], ah4 = hh[4], ah5 = hh[5], ah6 = hh[6], ah7 = hh[7], al0 = hl[0], al1 = hl[1], al2 = hl[2], al3 = hl[3], al4 = hl[4], al5 = hl[5], al6 = hl[6], al7 = hl[7];
        var pos = 0;
        while (n >= 128) {
          for (i = 0; i < 16; i++) {
            j = 8 * i + pos;
            wh[i] = m[j + 0] << 24 | m[j + 1] << 16 | m[j + 2] << 8 | m[j + 3];
            wl[i] = m[j + 4] << 24 | m[j + 5] << 16 | m[j + 6] << 8 | m[j + 7];
          }
          for (i = 0; i < 80; i++) {
            bh0 = ah0;
            bh1 = ah1;
            bh2 = ah2;
            bh3 = ah3;
            bh4 = ah4;
            bh5 = ah5;
            bh6 = ah6;
            bh7 = ah7;
            bl0 = al0;
            bl1 = al1;
            bl2 = al2;
            bl3 = al3;
            bl4 = al4;
            bl5 = al5;
            bl6 = al6;
            bl7 = al7;
            h = ah7;
            l = al7;
            a = l & 65535;
            b = l >>> 16;
            c = h & 65535;
            d = h >>> 16;
            h = (ah4 >>> 14 | al4 << 32 - 14) ^ (ah4 >>> 18 | al4 << 32 - 18) ^ (al4 >>> 41 - 32 | ah4 << 32 - (41 - 32));
            l = (al4 >>> 14 | ah4 << 32 - 14) ^ (al4 >>> 18 | ah4 << 32 - 18) ^ (ah4 >>> 41 - 32 | al4 << 32 - (41 - 32));
            a += l & 65535;
            b += l >>> 16;
            c += h & 65535;
            d += h >>> 16;
            h = ah4 & ah5 ^ ~ah4 & ah6;
            l = al4 & al5 ^ ~al4 & al6;
            a += l & 65535;
            b += l >>> 16;
            c += h & 65535;
            d += h >>> 16;
            h = K[i * 2];
            l = K[i * 2 + 1];
            a += l & 65535;
            b += l >>> 16;
            c += h & 65535;
            d += h >>> 16;
            h = wh[i % 16];
            l = wl[i % 16];
            a += l & 65535;
            b += l >>> 16;
            c += h & 65535;
            d += h >>> 16;
            b += a >>> 16;
            c += b >>> 16;
            d += c >>> 16;
            th = c & 65535 | d << 16;
            tl = a & 65535 | b << 16;
            h = th;
            l = tl;
            a = l & 65535;
            b = l >>> 16;
            c = h & 65535;
            d = h >>> 16;
            h = (ah0 >>> 28 | al0 << 32 - 28) ^ (al0 >>> 34 - 32 | ah0 << 32 - (34 - 32)) ^ (al0 >>> 39 - 32 | ah0 << 32 - (39 - 32));
            l = (al0 >>> 28 | ah0 << 32 - 28) ^ (ah0 >>> 34 - 32 | al0 << 32 - (34 - 32)) ^ (ah0 >>> 39 - 32 | al0 << 32 - (39 - 32));
            a += l & 65535;
            b += l >>> 16;
            c += h & 65535;
            d += h >>> 16;
            h = ah0 & ah1 ^ ah0 & ah2 ^ ah1 & ah2;
            l = al0 & al1 ^ al0 & al2 ^ al1 & al2;
            a += l & 65535;
            b += l >>> 16;
            c += h & 65535;
            d += h >>> 16;
            b += a >>> 16;
            c += b >>> 16;
            d += c >>> 16;
            bh7 = c & 65535 | d << 16;
            bl7 = a & 65535 | b << 16;
            h = bh3;
            l = bl3;
            a = l & 65535;
            b = l >>> 16;
            c = h & 65535;
            d = h >>> 16;
            h = th;
            l = tl;
            a += l & 65535;
            b += l >>> 16;
            c += h & 65535;
            d += h >>> 16;
            b += a >>> 16;
            c += b >>> 16;
            d += c >>> 16;
            bh3 = c & 65535 | d << 16;
            bl3 = a & 65535 | b << 16;
            ah1 = bh0;
            ah2 = bh1;
            ah3 = bh2;
            ah4 = bh3;
            ah5 = bh4;
            ah6 = bh5;
            ah7 = bh6;
            ah0 = bh7;
            al1 = bl0;
            al2 = bl1;
            al3 = bl2;
            al4 = bl3;
            al5 = bl4;
            al6 = bl5;
            al7 = bl6;
            al0 = bl7;
            if (i % 16 === 15) {
              for (j = 0; j < 16; j++) {
                h = wh[j];
                l = wl[j];
                a = l & 65535;
                b = l >>> 16;
                c = h & 65535;
                d = h >>> 16;
                h = wh[(j + 9) % 16];
                l = wl[(j + 9) % 16];
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                th = wh[(j + 1) % 16];
                tl = wl[(j + 1) % 16];
                h = (th >>> 1 | tl << 32 - 1) ^ (th >>> 8 | tl << 32 - 8) ^ th >>> 7;
                l = (tl >>> 1 | th << 32 - 1) ^ (tl >>> 8 | th << 32 - 8) ^ (tl >>> 7 | th << 32 - 7);
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                th = wh[(j + 14) % 16];
                tl = wl[(j + 14) % 16];
                h = (th >>> 19 | tl << 32 - 19) ^ (tl >>> 61 - 32 | th << 32 - (61 - 32)) ^ th >>> 6;
                l = (tl >>> 19 | th << 32 - 19) ^ (th >>> 61 - 32 | tl << 32 - (61 - 32)) ^ (tl >>> 6 | th << 32 - 6);
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                b += a >>> 16;
                c += b >>> 16;
                d += c >>> 16;
                wh[j] = c & 65535 | d << 16;
                wl[j] = a & 65535 | b << 16;
              }
            }
          }
          h = ah0;
          l = al0;
          a = l & 65535;
          b = l >>> 16;
          c = h & 65535;
          d = h >>> 16;
          h = hh[0];
          l = hl[0];
          a += l & 65535;
          b += l >>> 16;
          c += h & 65535;
          d += h >>> 16;
          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;
          hh[0] = ah0 = c & 65535 | d << 16;
          hl[0] = al0 = a & 65535 | b << 16;
          h = ah1;
          l = al1;
          a = l & 65535;
          b = l >>> 16;
          c = h & 65535;
          d = h >>> 16;
          h = hh[1];
          l = hl[1];
          a += l & 65535;
          b += l >>> 16;
          c += h & 65535;
          d += h >>> 16;
          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;
          hh[1] = ah1 = c & 65535 | d << 16;
          hl[1] = al1 = a & 65535 | b << 16;
          h = ah2;
          l = al2;
          a = l & 65535;
          b = l >>> 16;
          c = h & 65535;
          d = h >>> 16;
          h = hh[2];
          l = hl[2];
          a += l & 65535;
          b += l >>> 16;
          c += h & 65535;
          d += h >>> 16;
          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;
          hh[2] = ah2 = c & 65535 | d << 16;
          hl[2] = al2 = a & 65535 | b << 16;
          h = ah3;
          l = al3;
          a = l & 65535;
          b = l >>> 16;
          c = h & 65535;
          d = h >>> 16;
          h = hh[3];
          l = hl[3];
          a += l & 65535;
          b += l >>> 16;
          c += h & 65535;
          d += h >>> 16;
          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;
          hh[3] = ah3 = c & 65535 | d << 16;
          hl[3] = al3 = a & 65535 | b << 16;
          h = ah4;
          l = al4;
          a = l & 65535;
          b = l >>> 16;
          c = h & 65535;
          d = h >>> 16;
          h = hh[4];
          l = hl[4];
          a += l & 65535;
          b += l >>> 16;
          c += h & 65535;
          d += h >>> 16;
          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;
          hh[4] = ah4 = c & 65535 | d << 16;
          hl[4] = al4 = a & 65535 | b << 16;
          h = ah5;
          l = al5;
          a = l & 65535;
          b = l >>> 16;
          c = h & 65535;
          d = h >>> 16;
          h = hh[5];
          l = hl[5];
          a += l & 65535;
          b += l >>> 16;
          c += h & 65535;
          d += h >>> 16;
          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;
          hh[5] = ah5 = c & 65535 | d << 16;
          hl[5] = al5 = a & 65535 | b << 16;
          h = ah6;
          l = al6;
          a = l & 65535;
          b = l >>> 16;
          c = h & 65535;
          d = h >>> 16;
          h = hh[6];
          l = hl[6];
          a += l & 65535;
          b += l >>> 16;
          c += h & 65535;
          d += h >>> 16;
          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;
          hh[6] = ah6 = c & 65535 | d << 16;
          hl[6] = al6 = a & 65535 | b << 16;
          h = ah7;
          l = al7;
          a = l & 65535;
          b = l >>> 16;
          c = h & 65535;
          d = h >>> 16;
          h = hh[7];
          l = hl[7];
          a += l & 65535;
          b += l >>> 16;
          c += h & 65535;
          d += h >>> 16;
          b += a >>> 16;
          c += b >>> 16;
          d += c >>> 16;
          hh[7] = ah7 = c & 65535 | d << 16;
          hl[7] = al7 = a & 65535 | b << 16;
          pos += 128;
          n -= 128;
        }
        return n;
      }
      function crypto_hash(out, m, n) {
        var hh = new Int32Array(8), hl = new Int32Array(8), x = new Uint8Array(256), i, b = n;
        hh[0] = 1779033703;
        hh[1] = 3144134277;
        hh[2] = 1013904242;
        hh[3] = 2773480762;
        hh[4] = 1359893119;
        hh[5] = 2600822924;
        hh[6] = 528734635;
        hh[7] = 1541459225;
        hl[0] = 4089235720;
        hl[1] = 2227873595;
        hl[2] = 4271175723;
        hl[3] = 1595750129;
        hl[4] = 2917565137;
        hl[5] = 725511199;
        hl[6] = 4215389547;
        hl[7] = 327033209;
        crypto_hashblocks_hl(hh, hl, m, n);
        n %= 128;
        for (i = 0; i < n; i++)
          x[i] = m[b - n + i];
        x[n] = 128;
        n = 256 - 128 * (n < 112 ? 1 : 0);
        x[n - 9] = 0;
        ts64(x, n - 8, b / 536870912 | 0, b << 3);
        crypto_hashblocks_hl(hh, hl, x, n);
        for (i = 0; i < 8; i++)
          ts64(out, 8 * i, hh[i], hl[i]);
        return 0;
      }
      function add(p, q) {
        var a = gf(), b = gf(), c = gf(), d = gf(), e = gf(), f = gf(), g = gf(), h = gf(), t = gf();
        Z(a, p[1], p[0]);
        Z(t, q[1], q[0]);
        M(a, a, t);
        A(b, p[0], p[1]);
        A(t, q[0], q[1]);
        M(b, b, t);
        M(c, p[3], q[3]);
        M(c, c, D2);
        M(d, p[2], q[2]);
        A(d, d, d);
        Z(e, b, a);
        Z(f, d, c);
        A(g, d, c);
        A(h, b, a);
        M(p[0], e, f);
        M(p[1], h, g);
        M(p[2], g, f);
        M(p[3], e, h);
      }
      function cswap(p, q, b) {
        var i;
        for (i = 0; i < 4; i++) {
          sel25519(p[i], q[i], b);
        }
      }
      function pack(r, p) {
        var tx = gf(), ty = gf(), zi = gf();
        inv25519(zi, p[2]);
        M(tx, p[0], zi);
        M(ty, p[1], zi);
        pack25519(r, ty);
        r[31] ^= par25519(tx) << 7;
      }
      function scalarmult(p, q, s) {
        var b, i;
        set25519(p[0], gf0);
        set25519(p[1], gf1);
        set25519(p[2], gf1);
        set25519(p[3], gf0);
        for (i = 255; i >= 0; --i) {
          b = s[i / 8 | 0] >> (i & 7) & 1;
          cswap(p, q, b);
          add(q, p);
          add(p, p);
          cswap(p, q, b);
        }
      }
      function scalarbase(p, s) {
        var q = [gf(), gf(), gf(), gf()];
        set25519(q[0], X);
        set25519(q[1], Y);
        set25519(q[2], gf1);
        M(q[3], X, Y);
        scalarmult(p, q, s);
      }
      function crypto_sign_keypair(pk, sk, seeded) {
        var d = new Uint8Array(64);
        var p = [gf(), gf(), gf(), gf()];
        var i;
        if (!seeded)
          randombytes(sk, 32);
        crypto_hash(d, sk, 32);
        d[0] &= 248;
        d[31] &= 127;
        d[31] |= 64;
        scalarbase(p, d);
        pack(pk, p);
        for (i = 0; i < 32; i++)
          sk[i + 32] = pk[i];
        return 0;
      }
      var L = new Float64Array([237, 211, 245, 92, 26, 99, 18, 88, 214, 156, 247, 162, 222, 249, 222, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16]);
      function modL(r, x) {
        var carry, i, j, k;
        for (i = 63; i >= 32; --i) {
          carry = 0;
          for (j = i - 32, k = i - 12; j < k; ++j) {
            x[j] += carry - 16 * x[i] * L[j - (i - 32)];
            carry = x[j] + 128 >> 8;
            x[j] -= carry * 256;
          }
          x[j] += carry;
          x[i] = 0;
        }
        carry = 0;
        for (j = 0; j < 32; j++) {
          x[j] += carry - (x[31] >> 4) * L[j];
          carry = x[j] >> 8;
          x[j] &= 255;
        }
        for (j = 0; j < 32; j++)
          x[j] -= carry * L[j];
        for (i = 0; i < 32; i++) {
          x[i + 1] += x[i] >> 8;
          r[i] = x[i] & 255;
        }
      }
      function reduce(r) {
        var x = new Float64Array(64), i;
        for (i = 0; i < 64; i++)
          x[i] = r[i];
        for (i = 0; i < 64; i++)
          r[i] = 0;
        modL(r, x);
      }
      function crypto_sign(sm, m, n, sk) {
        var d = new Uint8Array(64), h = new Uint8Array(64), r = new Uint8Array(64);
        var i, j, x = new Float64Array(64);
        var p = [gf(), gf(), gf(), gf()];
        crypto_hash(d, sk, 32);
        d[0] &= 248;
        d[31] &= 127;
        d[31] |= 64;
        var smlen = n + 64;
        for (i = 0; i < n; i++)
          sm[64 + i] = m[i];
        for (i = 0; i < 32; i++)
          sm[32 + i] = d[32 + i];
        crypto_hash(r, sm.subarray(32), n + 32);
        reduce(r);
        scalarbase(p, r);
        pack(sm, p);
        for (i = 32; i < 64; i++)
          sm[i] = sk[i];
        crypto_hash(h, sm, n + 64);
        reduce(h);
        for (i = 0; i < 64; i++)
          x[i] = 0;
        for (i = 0; i < 32; i++)
          x[i] = r[i];
        for (i = 0; i < 32; i++) {
          for (j = 0; j < 32; j++) {
            x[i + j] += h[i] * d[j];
          }
        }
        modL(sm.subarray(32), x);
        return smlen;
      }
      function unpackneg(r, p) {
        var t = gf(), chk = gf(), num = gf(), den = gf(), den2 = gf(), den4 = gf(), den6 = gf();
        set25519(r[2], gf1);
        unpack25519(r[1], p);
        S(num, r[1]);
        M(den, num, D);
        Z(num, num, r[2]);
        A(den, r[2], den);
        S(den2, den);
        S(den4, den2);
        M(den6, den4, den2);
        M(t, den6, num);
        M(t, t, den);
        pow2523(t, t);
        M(t, t, num);
        M(t, t, den);
        M(t, t, den);
        M(r[0], t, den);
        S(chk, r[0]);
        M(chk, chk, den);
        if (neq25519(chk, num))
          M(r[0], r[0], I);
        S(chk, r[0]);
        M(chk, chk, den);
        if (neq25519(chk, num))
          return -1;
        if (par25519(r[0]) === p[31] >> 7)
          Z(r[0], gf0, r[0]);
        M(r[3], r[0], r[1]);
        return 0;
      }
      function crypto_sign_open(m, sm, n, pk) {
        var i, mlen;
        var t = new Uint8Array(32), h = new Uint8Array(64);
        var p = [gf(), gf(), gf(), gf()], q = [gf(), gf(), gf(), gf()];
        mlen = -1;
        if (n < 64)
          return -1;
        if (unpackneg(q, pk))
          return -1;
        for (i = 0; i < n; i++)
          m[i] = sm[i];
        for (i = 0; i < 32; i++)
          m[i + 32] = pk[i];
        crypto_hash(h, m, n);
        reduce(h);
        scalarmult(p, q, h);
        scalarbase(q, sm.subarray(32));
        add(p, q);
        pack(t, p);
        n -= 64;
        if (crypto_verify_32(sm, 0, t, 0)) {
          for (i = 0; i < n; i++)
            m[i] = 0;
          return -1;
        }
        for (i = 0; i < n; i++)
          m[i] = sm[i + 64];
        mlen = n;
        return mlen;
      }
      var crypto_secretbox_KEYBYTES = 32, crypto_secretbox_NONCEBYTES = 24, crypto_secretbox_ZEROBYTES = 32, crypto_secretbox_BOXZEROBYTES = 16, crypto_scalarmult_BYTES = 32, crypto_scalarmult_SCALARBYTES = 32, crypto_box_PUBLICKEYBYTES = 32, crypto_box_SECRETKEYBYTES = 32, crypto_box_BEFORENMBYTES = 32, crypto_box_NONCEBYTES = crypto_secretbox_NONCEBYTES, crypto_box_ZEROBYTES = crypto_secretbox_ZEROBYTES, crypto_box_BOXZEROBYTES = crypto_secretbox_BOXZEROBYTES, crypto_sign_BYTES = 64, crypto_sign_PUBLICKEYBYTES = 32, crypto_sign_SECRETKEYBYTES = 64, crypto_sign_SEEDBYTES = 32, crypto_hash_BYTES = 64;
      nacl.lowlevel = {
        crypto_core_hsalsa20,
        crypto_stream_xor,
        crypto_stream,
        crypto_stream_salsa20_xor,
        crypto_stream_salsa20,
        crypto_onetimeauth,
        crypto_onetimeauth_verify,
        crypto_verify_16,
        crypto_verify_32,
        crypto_secretbox,
        crypto_secretbox_open,
        crypto_scalarmult,
        crypto_scalarmult_base,
        crypto_box_beforenm,
        crypto_box_afternm,
        crypto_box,
        crypto_box_open,
        crypto_box_keypair,
        crypto_hash,
        crypto_sign,
        crypto_sign_keypair,
        crypto_sign_open,
        crypto_secretbox_KEYBYTES,
        crypto_secretbox_NONCEBYTES,
        crypto_secretbox_ZEROBYTES,
        crypto_secretbox_BOXZEROBYTES,
        crypto_scalarmult_BYTES,
        crypto_scalarmult_SCALARBYTES,
        crypto_box_PUBLICKEYBYTES,
        crypto_box_SECRETKEYBYTES,
        crypto_box_BEFORENMBYTES,
        crypto_box_NONCEBYTES,
        crypto_box_ZEROBYTES,
        crypto_box_BOXZEROBYTES,
        crypto_sign_BYTES,
        crypto_sign_PUBLICKEYBYTES,
        crypto_sign_SECRETKEYBYTES,
        crypto_sign_SEEDBYTES,
        crypto_hash_BYTES
      };
      function checkLengths(k, n) {
        if (k.length !== crypto_secretbox_KEYBYTES)
          throw new Error("bad key size");
        if (n.length !== crypto_secretbox_NONCEBYTES)
          throw new Error("bad nonce size");
      }
      function checkBoxLengths(pk, sk) {
        if (pk.length !== crypto_box_PUBLICKEYBYTES)
          throw new Error("bad public key size");
        if (sk.length !== crypto_box_SECRETKEYBYTES)
          throw new Error("bad secret key size");
      }
      function checkArrayTypes() {
        var t, i;
        for (i = 0; i < arguments.length; i++) {
          if ((t = Object.prototype.toString.call(arguments[i])) !== "[object Uint8Array]")
            throw new TypeError("unexpected type " + t + ", use Uint8Array");
        }
      }
      function cleanup(arr) {
        for (var i = 0; i < arr.length; i++)
          arr[i] = 0;
      }
      if (!nacl.util) {
        nacl.util = {};
        nacl.util.decodeUTF8 = nacl.util.encodeUTF8 = nacl.util.encodeBase64 = nacl.util.decodeBase64 = function() {
          throw new Error("nacl.util moved into separate package: https://github.com/dchest/tweetnacl-util-js");
        };
      }
      nacl.randomBytes = function(n) {
        var b = new Uint8Array(n);
        randombytes(b, n);
        return b;
      };
      nacl.secretbox = function(msg, nonce, key) {
        checkArrayTypes(msg, nonce, key);
        checkLengths(key, nonce);
        var m = new Uint8Array(crypto_secretbox_ZEROBYTES + msg.length);
        var c = new Uint8Array(m.length);
        for (var i = 0; i < msg.length; i++)
          m[i + crypto_secretbox_ZEROBYTES] = msg[i];
        crypto_secretbox(c, m, m.length, nonce, key);
        return c.subarray(crypto_secretbox_BOXZEROBYTES);
      };
      nacl.secretbox.open = function(box, nonce, key) {
        checkArrayTypes(box, nonce, key);
        checkLengths(key, nonce);
        var c = new Uint8Array(crypto_secretbox_BOXZEROBYTES + box.length);
        var m = new Uint8Array(c.length);
        for (var i = 0; i < box.length; i++)
          c[i + crypto_secretbox_BOXZEROBYTES] = box[i];
        if (c.length < 32)
          return false;
        if (crypto_secretbox_open(m, c, c.length, nonce, key) !== 0)
          return false;
        return m.subarray(crypto_secretbox_ZEROBYTES);
      };
      nacl.secretbox.keyLength = crypto_secretbox_KEYBYTES;
      nacl.secretbox.nonceLength = crypto_secretbox_NONCEBYTES;
      nacl.secretbox.overheadLength = crypto_secretbox_BOXZEROBYTES;
      nacl.scalarMult = function(n, p) {
        checkArrayTypes(n, p);
        if (n.length !== crypto_scalarmult_SCALARBYTES)
          throw new Error("bad n size");
        if (p.length !== crypto_scalarmult_BYTES)
          throw new Error("bad p size");
        var q = new Uint8Array(crypto_scalarmult_BYTES);
        crypto_scalarmult(q, n, p);
        return q;
      };
      nacl.scalarMult.base = function(n) {
        checkArrayTypes(n);
        if (n.length !== crypto_scalarmult_SCALARBYTES)
          throw new Error("bad n size");
        var q = new Uint8Array(crypto_scalarmult_BYTES);
        crypto_scalarmult_base(q, n);
        return q;
      };
      nacl.scalarMult.scalarLength = crypto_scalarmult_SCALARBYTES;
      nacl.scalarMult.groupElementLength = crypto_scalarmult_BYTES;
      nacl.box = function(msg, nonce, publicKey, secretKey) {
        var k = nacl.box.before(publicKey, secretKey);
        return nacl.secretbox(msg, nonce, k);
      };
      nacl.box.before = function(publicKey, secretKey) {
        checkArrayTypes(publicKey, secretKey);
        checkBoxLengths(publicKey, secretKey);
        var k = new Uint8Array(crypto_box_BEFORENMBYTES);
        crypto_box_beforenm(k, publicKey, secretKey);
        return k;
      };
      nacl.box.after = nacl.secretbox;
      nacl.box.open = function(msg, nonce, publicKey, secretKey) {
        var k = nacl.box.before(publicKey, secretKey);
        return nacl.secretbox.open(msg, nonce, k);
      };
      nacl.box.open.after = nacl.secretbox.open;
      nacl.box.keyPair = function() {
        var pk = new Uint8Array(crypto_box_PUBLICKEYBYTES);
        var sk = new Uint8Array(crypto_box_SECRETKEYBYTES);
        crypto_box_keypair(pk, sk);
        return { publicKey: pk, secretKey: sk };
      };
      nacl.box.keyPair.fromSecretKey = function(secretKey) {
        checkArrayTypes(secretKey);
        if (secretKey.length !== crypto_box_SECRETKEYBYTES)
          throw new Error("bad secret key size");
        var pk = new Uint8Array(crypto_box_PUBLICKEYBYTES);
        crypto_scalarmult_base(pk, secretKey);
        return { publicKey: pk, secretKey: new Uint8Array(secretKey) };
      };
      nacl.box.publicKeyLength = crypto_box_PUBLICKEYBYTES;
      nacl.box.secretKeyLength = crypto_box_SECRETKEYBYTES;
      nacl.box.sharedKeyLength = crypto_box_BEFORENMBYTES;
      nacl.box.nonceLength = crypto_box_NONCEBYTES;
      nacl.box.overheadLength = nacl.secretbox.overheadLength;
      nacl.sign = function(msg, secretKey) {
        checkArrayTypes(msg, secretKey);
        if (secretKey.length !== crypto_sign_SECRETKEYBYTES)
          throw new Error("bad secret key size");
        var signedMsg = new Uint8Array(crypto_sign_BYTES + msg.length);
        crypto_sign(signedMsg, msg, msg.length, secretKey);
        return signedMsg;
      };
      nacl.sign.open = function(signedMsg, publicKey) {
        if (arguments.length !== 2)
          throw new Error("nacl.sign.open accepts 2 arguments; did you mean to use nacl.sign.detached.verify?");
        checkArrayTypes(signedMsg, publicKey);
        if (publicKey.length !== crypto_sign_PUBLICKEYBYTES)
          throw new Error("bad public key size");
        var tmp = new Uint8Array(signedMsg.length);
        var mlen = crypto_sign_open(tmp, signedMsg, signedMsg.length, publicKey);
        if (mlen < 0)
          return null;
        var m = new Uint8Array(mlen);
        for (var i = 0; i < m.length; i++)
          m[i] = tmp[i];
        return m;
      };
      nacl.sign.detached = function(msg, secretKey) {
        var signedMsg = nacl.sign(msg, secretKey);
        var sig = new Uint8Array(crypto_sign_BYTES);
        for (var i = 0; i < sig.length; i++)
          sig[i] = signedMsg[i];
        return sig;
      };
      nacl.sign.detached.verify = function(msg, sig, publicKey) {
        checkArrayTypes(msg, sig, publicKey);
        if (sig.length !== crypto_sign_BYTES)
          throw new Error("bad signature size");
        if (publicKey.length !== crypto_sign_PUBLICKEYBYTES)
          throw new Error("bad public key size");
        var sm = new Uint8Array(crypto_sign_BYTES + msg.length);
        var m = new Uint8Array(crypto_sign_BYTES + msg.length);
        var i;
        for (i = 0; i < crypto_sign_BYTES; i++)
          sm[i] = sig[i];
        for (i = 0; i < msg.length; i++)
          sm[i + crypto_sign_BYTES] = msg[i];
        return crypto_sign_open(m, sm, sm.length, publicKey) >= 0;
      };
      nacl.sign.keyPair = function() {
        var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
        var sk = new Uint8Array(crypto_sign_SECRETKEYBYTES);
        crypto_sign_keypair(pk, sk);
        return { publicKey: pk, secretKey: sk };
      };
      nacl.sign.keyPair.fromSecretKey = function(secretKey) {
        checkArrayTypes(secretKey);
        if (secretKey.length !== crypto_sign_SECRETKEYBYTES)
          throw new Error("bad secret key size");
        var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
        for (var i = 0; i < pk.length; i++)
          pk[i] = secretKey[32 + i];
        return { publicKey: pk, secretKey: new Uint8Array(secretKey) };
      };
      nacl.sign.keyPair.fromSeed = function(seed) {
        checkArrayTypes(seed);
        if (seed.length !== crypto_sign_SEEDBYTES)
          throw new Error("bad seed size");
        var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
        var sk = new Uint8Array(crypto_sign_SECRETKEYBYTES);
        for (var i = 0; i < 32; i++)
          sk[i] = seed[i];
        crypto_sign_keypair(pk, sk, true);
        return { publicKey: pk, secretKey: sk };
      };
      nacl.sign.publicKeyLength = crypto_sign_PUBLICKEYBYTES;
      nacl.sign.secretKeyLength = crypto_sign_SECRETKEYBYTES;
      nacl.sign.seedLength = crypto_sign_SEEDBYTES;
      nacl.sign.signatureLength = crypto_sign_BYTES;
      nacl.hash = function(msg) {
        checkArrayTypes(msg);
        var h = new Uint8Array(crypto_hash_BYTES);
        crypto_hash(h, msg, msg.length);
        return h;
      };
      nacl.hash.hashLength = crypto_hash_BYTES;
      nacl.verify = function(x, y) {
        checkArrayTypes(x, y);
        if (x.length === 0 || y.length === 0)
          return false;
        if (x.length !== y.length)
          return false;
        return vn(x, 0, y, 0, x.length) === 0 ? true : false;
      };
      nacl.setPRNG = function(fn) {
        randombytes = fn;
      };
      (function() {
        var crypto = typeof self !== "undefined" ? self.crypto || self.msCrypto : null;
        if (crypto && crypto.getRandomValues) {
          var QUOTA = 65536;
          nacl.setPRNG(function(x, n) {
            var i, v = new Uint8Array(n);
            for (i = 0; i < n; i += QUOTA) {
              crypto.getRandomValues(v.subarray(i, i + Math.min(n - i, QUOTA)));
            }
            for (i = 0; i < n; i++)
              x[i] = v[i];
            cleanup(v);
          });
        } else if (typeof require !== "undefined") {
          crypto = require("crypto");
          if (crypto && crypto.randomBytes) {
            nacl.setPRNG(function(x, n) {
              var i, v = crypto.randomBytes(n);
              for (i = 0; i < n; i++)
                x[i] = v[i];
              cleanup(v);
            });
          }
        }
      })();
    })(typeof module2 !== "undefined" && module2.exports ? module2.exports : self.nacl = self.nacl || {});
  }
});

// node_modules/bcrypt-pbkdf/index.js
var require_bcrypt_pbkdf = __commonJS({
  "node_modules/bcrypt-pbkdf/index.js"(exports, module2) {
    "use strict";
    var crypto_hash_sha512 = require_nacl_fast().lowlevel.crypto_hash;
    var BLF_J = 0;
    var Blowfish = function() {
      this.S = [
        new Uint32Array([
          3509652390,
          2564797868,
          805139163,
          3491422135,
          3101798381,
          1780907670,
          3128725573,
          4046225305,
          614570311,
          3012652279,
          134345442,
          2240740374,
          1667834072,
          1901547113,
          2757295779,
          4103290238,
          227898511,
          1921955416,
          1904987480,
          2182433518,
          2069144605,
          3260701109,
          2620446009,
          720527379,
          3318853667,
          677414384,
          3393288472,
          3101374703,
          2390351024,
          1614419982,
          1822297739,
          2954791486,
          3608508353,
          3174124327,
          2024746970,
          1432378464,
          3864339955,
          2857741204,
          1464375394,
          1676153920,
          1439316330,
          715854006,
          3033291828,
          289532110,
          2706671279,
          2087905683,
          3018724369,
          1668267050,
          732546397,
          1947742710,
          3462151702,
          2609353502,
          2950085171,
          1814351708,
          2050118529,
          680887927,
          999245976,
          1800124847,
          3300911131,
          1713906067,
          1641548236,
          4213287313,
          1216130144,
          1575780402,
          4018429277,
          3917837745,
          3693486850,
          3949271944,
          596196993,
          3549867205,
          258830323,
          2213823033,
          772490370,
          2760122372,
          1774776394,
          2652871518,
          566650946,
          4142492826,
          1728879713,
          2882767088,
          1783734482,
          3629395816,
          2517608232,
          2874225571,
          1861159788,
          326777828,
          3124490320,
          2130389656,
          2716951837,
          967770486,
          1724537150,
          2185432712,
          2364442137,
          1164943284,
          2105845187,
          998989502,
          3765401048,
          2244026483,
          1075463327,
          1455516326,
          1322494562,
          910128902,
          469688178,
          1117454909,
          936433444,
          3490320968,
          3675253459,
          1240580251,
          122909385,
          2157517691,
          634681816,
          4142456567,
          3825094682,
          3061402683,
          2540495037,
          79693498,
          3249098678,
          1084186820,
          1583128258,
          426386531,
          1761308591,
          1047286709,
          322548459,
          995290223,
          1845252383,
          2603652396,
          3431023940,
          2942221577,
          3202600964,
          3727903485,
          1712269319,
          422464435,
          3234572375,
          1170764815,
          3523960633,
          3117677531,
          1434042557,
          442511882,
          3600875718,
          1076654713,
          1738483198,
          4213154764,
          2393238008,
          3677496056,
          1014306527,
          4251020053,
          793779912,
          2902807211,
          842905082,
          4246964064,
          1395751752,
          1040244610,
          2656851899,
          3396308128,
          445077038,
          3742853595,
          3577915638,
          679411651,
          2892444358,
          2354009459,
          1767581616,
          3150600392,
          3791627101,
          3102740896,
          284835224,
          4246832056,
          1258075500,
          768725851,
          2589189241,
          3069724005,
          3532540348,
          1274779536,
          3789419226,
          2764799539,
          1660621633,
          3471099624,
          4011903706,
          913787905,
          3497959166,
          737222580,
          2514213453,
          2928710040,
          3937242737,
          1804850592,
          3499020752,
          2949064160,
          2386320175,
          2390070455,
          2415321851,
          4061277028,
          2290661394,
          2416832540,
          1336762016,
          1754252060,
          3520065937,
          3014181293,
          791618072,
          3188594551,
          3933548030,
          2332172193,
          3852520463,
          3043980520,
          413987798,
          3465142937,
          3030929376,
          4245938359,
          2093235073,
          3534596313,
          375366246,
          2157278981,
          2479649556,
          555357303,
          3870105701,
          2008414854,
          3344188149,
          4221384143,
          3956125452,
          2067696032,
          3594591187,
          2921233993,
          2428461,
          544322398,
          577241275,
          1471733935,
          610547355,
          4027169054,
          1432588573,
          1507829418,
          2025931657,
          3646575487,
          545086370,
          48609733,
          2200306550,
          1653985193,
          298326376,
          1316178497,
          3007786442,
          2064951626,
          458293330,
          2589141269,
          3591329599,
          3164325604,
          727753846,
          2179363840,
          146436021,
          1461446943,
          4069977195,
          705550613,
          3059967265,
          3887724982,
          4281599278,
          3313849956,
          1404054877,
          2845806497,
          146425753,
          1854211946
        ]),
        new Uint32Array([
          1266315497,
          3048417604,
          3681880366,
          3289982499,
          290971e4,
          1235738493,
          2632868024,
          2414719590,
          3970600049,
          1771706367,
          1449415276,
          3266420449,
          422970021,
          1963543593,
          2690192192,
          3826793022,
          1062508698,
          1531092325,
          1804592342,
          2583117782,
          2714934279,
          4024971509,
          1294809318,
          4028980673,
          1289560198,
          2221992742,
          1669523910,
          35572830,
          157838143,
          1052438473,
          1016535060,
          1802137761,
          1753167236,
          1386275462,
          3080475397,
          2857371447,
          1040679964,
          2145300060,
          2390574316,
          1461121720,
          2956646967,
          4031777805,
          4028374788,
          33600511,
          2920084762,
          1018524850,
          629373528,
          3691585981,
          3515945977,
          2091462646,
          2486323059,
          586499841,
          988145025,
          935516892,
          3367335476,
          2599673255,
          2839830854,
          265290510,
          3972581182,
          2759138881,
          3795373465,
          1005194799,
          847297441,
          406762289,
          1314163512,
          1332590856,
          1866599683,
          4127851711,
          750260880,
          613907577,
          1450815602,
          3165620655,
          3734664991,
          3650291728,
          3012275730,
          3704569646,
          1427272223,
          778793252,
          1343938022,
          2676280711,
          2052605720,
          1946737175,
          3164576444,
          3914038668,
          3967478842,
          3682934266,
          1661551462,
          3294938066,
          4011595847,
          840292616,
          3712170807,
          616741398,
          312560963,
          711312465,
          1351876610,
          322626781,
          1910503582,
          271666773,
          2175563734,
          1594956187,
          70604529,
          3617834859,
          1007753275,
          1495573769,
          4069517037,
          2549218298,
          2663038764,
          504708206,
          2263041392,
          3941167025,
          2249088522,
          1514023603,
          1998579484,
          1312622330,
          694541497,
          2582060303,
          2151582166,
          1382467621,
          776784248,
          2618340202,
          3323268794,
          2497899128,
          2784771155,
          503983604,
          4076293799,
          907881277,
          423175695,
          432175456,
          1378068232,
          4145222326,
          3954048622,
          3938656102,
          3820766613,
          2793130115,
          2977904593,
          26017576,
          3274890735,
          3194772133,
          1700274565,
          1756076034,
          4006520079,
          3677328699,
          720338349,
          1533947780,
          354530856,
          688349552,
          3973924725,
          1637815568,
          332179504,
          3949051286,
          53804574,
          2852348879,
          3044236432,
          1282449977,
          3583942155,
          3416972820,
          4006381244,
          1617046695,
          2628476075,
          3002303598,
          1686838959,
          431878346,
          2686675385,
          1700445008,
          1080580658,
          1009431731,
          832498133,
          3223435511,
          2605976345,
          2271191193,
          2516031870,
          1648197032,
          4164389018,
          2548247927,
          300782431,
          375919233,
          238389289,
          3353747414,
          2531188641,
          2019080857,
          1475708069,
          455242339,
          2609103871,
          448939670,
          3451063019,
          1395535956,
          2413381860,
          1841049896,
          1491858159,
          885456874,
          4264095073,
          4001119347,
          1565136089,
          3898914787,
          1108368660,
          540939232,
          1173283510,
          2745871338,
          3681308437,
          4207628240,
          3343053890,
          4016749493,
          1699691293,
          1103962373,
          3625875870,
          2256883143,
          3830138730,
          1031889488,
          3479347698,
          1535977030,
          4236805024,
          3251091107,
          2132092099,
          1774941330,
          1199868427,
          1452454533,
          157007616,
          2904115357,
          342012276,
          595725824,
          1480756522,
          206960106,
          497939518,
          591360097,
          863170706,
          2375253569,
          3596610801,
          1814182875,
          2094937945,
          3421402208,
          1082520231,
          3463918190,
          2785509508,
          435703966,
          3908032597,
          1641649973,
          2842273706,
          3305899714,
          1510255612,
          2148256476,
          2655287854,
          3276092548,
          4258621189,
          236887753,
          3681803219,
          274041037,
          1734335097,
          3815195456,
          3317970021,
          1899903192,
          1026095262,
          4050517792,
          356393447,
          2410691914,
          3873677099,
          3682840055
        ]),
        new Uint32Array([
          3913112168,
          2491498743,
          4132185628,
          2489919796,
          1091903735,
          1979897079,
          3170134830,
          3567386728,
          3557303409,
          857797738,
          1136121015,
          1342202287,
          507115054,
          2535736646,
          337727348,
          3213592640,
          1301675037,
          2528481711,
          1895095763,
          1721773893,
          3216771564,
          62756741,
          2142006736,
          835421444,
          2531993523,
          1442658625,
          3659876326,
          2882144922,
          676362277,
          1392781812,
          170690266,
          3921047035,
          1759253602,
          3611846912,
          1745797284,
          664899054,
          1329594018,
          3901205900,
          3045908486,
          2062866102,
          2865634940,
          3543621612,
          3464012697,
          1080764994,
          553557557,
          3656615353,
          3996768171,
          991055499,
          499776247,
          1265440854,
          648242737,
          3940784050,
          980351604,
          3713745714,
          1749149687,
          3396870395,
          4211799374,
          3640570775,
          1161844396,
          3125318951,
          1431517754,
          545492359,
          4268468663,
          3499529547,
          1437099964,
          2702547544,
          3433638243,
          2581715763,
          2787789398,
          1060185593,
          1593081372,
          2418618748,
          4260947970,
          69676912,
          2159744348,
          86519011,
          2512459080,
          3838209314,
          1220612927,
          3339683548,
          133810670,
          1090789135,
          1078426020,
          1569222167,
          845107691,
          3583754449,
          4072456591,
          1091646820,
          628848692,
          1613405280,
          3757631651,
          526609435,
          236106946,
          48312990,
          2942717905,
          3402727701,
          1797494240,
          859738849,
          992217954,
          4005476642,
          2243076622,
          3870952857,
          3732016268,
          765654824,
          3490871365,
          2511836413,
          1685915746,
          3888969200,
          1414112111,
          2273134842,
          3281911079,
          4080962846,
          172450625,
          2569994100,
          980381355,
          4109958455,
          2819808352,
          2716589560,
          2568741196,
          3681446669,
          3329971472,
          1835478071,
          660984891,
          3704678404,
          4045999559,
          3422617507,
          3040415634,
          1762651403,
          1719377915,
          3470491036,
          2693910283,
          3642056355,
          3138596744,
          1364962596,
          2073328063,
          1983633131,
          926494387,
          3423689081,
          2150032023,
          4096667949,
          1749200295,
          3328846651,
          309677260,
          2016342300,
          1779581495,
          3079819751,
          111262694,
          1274766160,
          443224088,
          298511866,
          1025883608,
          3806446537,
          1145181785,
          168956806,
          3641502830,
          3584813610,
          1689216846,
          3666258015,
          3200248200,
          1692713982,
          2646376535,
          4042768518,
          1618508792,
          1610833997,
          3523052358,
          4130873264,
          2001055236,
          3610705100,
          2202168115,
          4028541809,
          2961195399,
          1006657119,
          2006996926,
          3186142756,
          1430667929,
          3210227297,
          1314452623,
          4074634658,
          4101304120,
          2273951170,
          1399257539,
          3367210612,
          3027628629,
          1190975929,
          2062231137,
          2333990788,
          2221543033,
          2438960610,
          1181637006,
          548689776,
          2362791313,
          3372408396,
          3104550113,
          3145860560,
          296247880,
          1970579870,
          3078560182,
          3769228297,
          1714227617,
          3291629107,
          3898220290,
          166772364,
          1251581989,
          493813264,
          448347421,
          195405023,
          2709975567,
          677966185,
          3703036547,
          1463355134,
          2715995803,
          1338867538,
          1343315457,
          2802222074,
          2684532164,
          233230375,
          2599980071,
          2000651841,
          3277868038,
          1638401717,
          4028070440,
          3237316320,
          6314154,
          819756386,
          300326615,
          590932579,
          1405279636,
          3267499572,
          3150704214,
          2428286686,
          3959192993,
          3461946742,
          1862657033,
          1266418056,
          963775037,
          2089974820,
          2263052895,
          1917689273,
          448879540,
          3550394620,
          3981727096,
          150775221,
          3627908307,
          1303187396,
          508620638,
          2975983352,
          2726630617,
          1817252668,
          1876281319,
          1457606340,
          908771278,
          3720792119,
          3617206836,
          2455994898,
          1729034894,
          1080033504
        ]),
        new Uint32Array([
          976866871,
          3556439503,
          2881648439,
          1522871579,
          1555064734,
          1336096578,
          3548522304,
          2579274686,
          3574697629,
          3205460757,
          3593280638,
          3338716283,
          3079412587,
          564236357,
          2993598910,
          1781952180,
          1464380207,
          3163844217,
          3332601554,
          1699332808,
          1393555694,
          1183702653,
          3581086237,
          1288719814,
          691649499,
          2847557200,
          2895455976,
          3193889540,
          2717570544,
          1781354906,
          1676643554,
          2592534050,
          3230253752,
          1126444790,
          2770207658,
          2633158820,
          2210423226,
          2615765581,
          2414155088,
          3127139286,
          673620729,
          2805611233,
          1269405062,
          4015350505,
          3341807571,
          4149409754,
          1057255273,
          2012875353,
          2162469141,
          2276492801,
          2601117357,
          993977747,
          3918593370,
          2654263191,
          753973209,
          36408145,
          2530585658,
          25011837,
          3520020182,
          2088578344,
          530523599,
          2918365339,
          1524020338,
          1518925132,
          3760827505,
          3759777254,
          1202760957,
          3985898139,
          3906192525,
          674977740,
          4174734889,
          2031300136,
          2019492241,
          3983892565,
          4153806404,
          3822280332,
          352677332,
          2297720250,
          60907813,
          90501309,
          3286998549,
          1016092578,
          2535922412,
          2839152426,
          457141659,
          509813237,
          4120667899,
          652014361,
          1966332200,
          2975202805,
          55981186,
          2327461051,
          676427537,
          3255491064,
          2882294119,
          3433927263,
          1307055953,
          942726286,
          933058658,
          2468411793,
          3933900994,
          4215176142,
          1361170020,
          2001714738,
          2830558078,
          3274259782,
          1222529897,
          1679025792,
          2729314320,
          3714953764,
          1770335741,
          151462246,
          3013232138,
          1682292957,
          1483529935,
          471910574,
          1539241949,
          458788160,
          3436315007,
          1807016891,
          3718408830,
          978976581,
          1043663428,
          3165965781,
          1927990952,
          4200891579,
          2372276910,
          3208408903,
          3533431907,
          1412390302,
          2931980059,
          4132332400,
          1947078029,
          3881505623,
          4168226417,
          2941484381,
          1077988104,
          1320477388,
          886195818,
          18198404,
          3786409e3,
          2509781533,
          112762804,
          3463356488,
          1866414978,
          891333506,
          18488651,
          661792760,
          1628790961,
          3885187036,
          3141171499,
          876946877,
          2693282273,
          1372485963,
          791857591,
          2686433993,
          3759982718,
          3167212022,
          3472953795,
          2716379847,
          445679433,
          3561995674,
          3504004811,
          3574258232,
          54117162,
          3331405415,
          2381918588,
          3769707343,
          4154350007,
          1140177722,
          4074052095,
          668550556,
          3214352940,
          367459370,
          261225585,
          2610173221,
          4209349473,
          3468074219,
          3265815641,
          314222801,
          3066103646,
          3808782860,
          282218597,
          3406013506,
          3773591054,
          379116347,
          1285071038,
          846784868,
          2669647154,
          3771962079,
          3550491691,
          2305946142,
          453669953,
          1268987020,
          3317592352,
          3279303384,
          3744833421,
          2610507566,
          3859509063,
          266596637,
          3847019092,
          517658769,
          3462560207,
          3443424879,
          370717030,
          4247526661,
          2224018117,
          4143653529,
          4112773975,
          2788324899,
          2477274417,
          1456262402,
          2901442914,
          1517677493,
          1846949527,
          2295493580,
          3734397586,
          2176403920,
          1280348187,
          1908823572,
          3871786941,
          846861322,
          1172426758,
          3287448474,
          3383383037,
          1655181056,
          3139813346,
          901632758,
          1897031941,
          2986607138,
          3066810236,
          3447102507,
          1393639104,
          373351379,
          950779232,
          625454576,
          3124240540,
          4148612726,
          2007998917,
          544563296,
          2244738638,
          2330496472,
          2058025392,
          1291430526,
          424198748,
          50039436,
          29584100,
          3605783033,
          2429876329,
          2791104160,
          1057563949,
          3255363231,
          3075367218,
          3463963227,
          1469046755,
          985887462
        ])
      ];
      this.P = new Uint32Array([
        608135816,
        2242054355,
        320440878,
        57701188,
        2752067618,
        698298832,
        137296536,
        3964562569,
        1160258022,
        953160567,
        3193202383,
        887688300,
        3232508343,
        3380367581,
        1065670069,
        3041331479,
        2450970073,
        2306472731
      ]);
    };
    function F(S, x8, i) {
      return (S[0][x8[i + 3]] + S[1][x8[i + 2]] ^ S[2][x8[i + 1]]) + S[3][x8[i]];
    }
    Blowfish.prototype.encipher = function(x, x8) {
      if (x8 === void 0) {
        x8 = new Uint8Array(x.buffer);
        if (x.byteOffset !== 0)
          x8 = x8.subarray(x.byteOffset);
      }
      x[0] ^= this.P[0];
      for (var i = 1; i < 16; i += 2) {
        x[1] ^= F(this.S, x8, 0) ^ this.P[i];
        x[0] ^= F(this.S, x8, 4) ^ this.P[i + 1];
      }
      var t = x[0];
      x[0] = x[1] ^ this.P[17];
      x[1] = t;
    };
    Blowfish.prototype.decipher = function(x) {
      var x8 = new Uint8Array(x.buffer);
      if (x.byteOffset !== 0)
        x8 = x8.subarray(x.byteOffset);
      x[0] ^= this.P[17];
      for (var i = 16; i > 0; i -= 2) {
        x[1] ^= F(this.S, x8, 0) ^ this.P[i];
        x[0] ^= F(this.S, x8, 4) ^ this.P[i - 1];
      }
      var t = x[0];
      x[0] = x[1] ^ this.P[0];
      x[1] = t;
    };
    function stream2word(data, databytes) {
      var i, temp = 0;
      for (i = 0; i < 4; i++, BLF_J++) {
        if (BLF_J >= databytes)
          BLF_J = 0;
        temp = temp << 8 | data[BLF_J];
      }
      return temp;
    }
    Blowfish.prototype.expand0state = function(key, keybytes) {
      var d = new Uint32Array(2), i, k;
      var d8 = new Uint8Array(d.buffer);
      for (i = 0, BLF_J = 0; i < 18; i++) {
        this.P[i] ^= stream2word(key, keybytes);
      }
      BLF_J = 0;
      for (i = 0; i < 18; i += 2) {
        this.encipher(d, d8);
        this.P[i] = d[0];
        this.P[i + 1] = d[1];
      }
      for (i = 0; i < 4; i++) {
        for (k = 0; k < 256; k += 2) {
          this.encipher(d, d8);
          this.S[i][k] = d[0];
          this.S[i][k + 1] = d[1];
        }
      }
    };
    Blowfish.prototype.expandstate = function(data, databytes, key, keybytes) {
      var d = new Uint32Array(2), i, k;
      for (i = 0, BLF_J = 0; i < 18; i++) {
        this.P[i] ^= stream2word(key, keybytes);
      }
      for (i = 0, BLF_J = 0; i < 18; i += 2) {
        d[0] ^= stream2word(data, databytes);
        d[1] ^= stream2word(data, databytes);
        this.encipher(d);
        this.P[i] = d[0];
        this.P[i + 1] = d[1];
      }
      for (i = 0; i < 4; i++) {
        for (k = 0; k < 256; k += 2) {
          d[0] ^= stream2word(data, databytes);
          d[1] ^= stream2word(data, databytes);
          this.encipher(d);
          this.S[i][k] = d[0];
          this.S[i][k + 1] = d[1];
        }
      }
      BLF_J = 0;
    };
    Blowfish.prototype.enc = function(data, blocks) {
      for (var i = 0; i < blocks; i++) {
        this.encipher(data.subarray(i * 2));
      }
    };
    Blowfish.prototype.dec = function(data, blocks) {
      for (var i = 0; i < blocks; i++) {
        this.decipher(data.subarray(i * 2));
      }
    };
    var BCRYPT_BLOCKS = 8;
    var BCRYPT_HASHSIZE = 32;
    function bcrypt_hash(sha2pass, sha2salt, out) {
      var state = new Blowfish(), cdata = new Uint32Array(BCRYPT_BLOCKS), i, ciphertext = new Uint8Array([
        79,
        120,
        121,
        99,
        104,
        114,
        111,
        109,
        97,
        116,
        105,
        99,
        66,
        108,
        111,
        119,
        102,
        105,
        115,
        104,
        83,
        119,
        97,
        116,
        68,
        121,
        110,
        97,
        109,
        105,
        116,
        101
      ]);
      state.expandstate(sha2salt, 64, sha2pass, 64);
      for (i = 0; i < 64; i++) {
        state.expand0state(sha2salt, 64);
        state.expand0state(sha2pass, 64);
      }
      for (i = 0; i < BCRYPT_BLOCKS; i++)
        cdata[i] = stream2word(ciphertext, ciphertext.byteLength);
      for (i = 0; i < 64; i++)
        state.enc(cdata, cdata.byteLength / 8);
      for (i = 0; i < BCRYPT_BLOCKS; i++) {
        out[4 * i + 3] = cdata[i] >>> 24;
        out[4 * i + 2] = cdata[i] >>> 16;
        out[4 * i + 1] = cdata[i] >>> 8;
        out[4 * i + 0] = cdata[i];
      }
    }
    function bcrypt_pbkdf(pass, passlen, salt, saltlen, key, keylen, rounds) {
      var sha2pass = new Uint8Array(64), sha2salt = new Uint8Array(64), out = new Uint8Array(BCRYPT_HASHSIZE), tmpout = new Uint8Array(BCRYPT_HASHSIZE), countsalt = new Uint8Array(saltlen + 4), i, j, amt, stride, dest, count, origkeylen = keylen;
      if (rounds < 1)
        return -1;
      if (passlen === 0 || saltlen === 0 || keylen === 0 || keylen > out.byteLength * out.byteLength || saltlen > 1 << 20)
        return -1;
      stride = Math.floor((keylen + out.byteLength - 1) / out.byteLength);
      amt = Math.floor((keylen + stride - 1) / stride);
      for (i = 0; i < saltlen; i++)
        countsalt[i] = salt[i];
      crypto_hash_sha512(sha2pass, pass, passlen);
      for (count = 1; keylen > 0; count++) {
        countsalt[saltlen + 0] = count >>> 24;
        countsalt[saltlen + 1] = count >>> 16;
        countsalt[saltlen + 2] = count >>> 8;
        countsalt[saltlen + 3] = count;
        crypto_hash_sha512(sha2salt, countsalt, saltlen + 4);
        bcrypt_hash(sha2pass, sha2salt, tmpout);
        for (i = out.byteLength; i--; )
          out[i] = tmpout[i];
        for (i = 1; i < rounds; i++) {
          crypto_hash_sha512(sha2salt, tmpout, tmpout.byteLength);
          bcrypt_hash(sha2pass, sha2salt, tmpout);
          for (j = 0; j < out.byteLength; j++)
            out[j] ^= tmpout[j];
        }
        amt = Math.min(amt, keylen);
        for (i = 0; i < amt; i++) {
          dest = i * stride + (count - 1);
          if (dest >= origkeylen)
            break;
          key[dest] = out[i];
        }
        keylen -= i;
      }
      return 0;
    }
    module2.exports = {
      BLOCKS: BCRYPT_BLOCKS,
      HASHSIZE: BCRYPT_HASHSIZE,
      hash: bcrypt_hash,
      pbkdf: bcrypt_pbkdf
    };
  }
});

// node_modules/cpu-features/build/Release/cpufeatures.node
var cpufeatures_default;
var init_cpufeatures = __esm({
  "node_modules/cpu-features/build/Release/cpufeatures.node"() {
    cpufeatures_default = "./cpufeatures-2RTAUJ4L.node";
  }
});

// node-file:/home/castello/repos/platform/analytics-datastore-elastic-search/scripts/node_modules/cpu-features/build/Release/cpufeatures.node
var require_cpufeatures = __commonJS({
  "node-file:/home/castello/repos/platform/analytics-datastore-elastic-search/scripts/node_modules/cpu-features/build/Release/cpufeatures.node"(exports, module2) {
    init_cpufeatures();
    try {
      module2.exports = require(cpufeatures_default);
    } catch {
    }
  }
});

// node_modules/cpu-features/lib/index.js
var require_lib2 = __commonJS({
  "node_modules/cpu-features/lib/index.js"(exports, module2) {
    "use strict";
    var binding = require_cpufeatures();
    module2.exports = binding.getCPUInfo;
  }
});

// node_modules/ssh2/lib/protocol/constants.js
var require_constants = __commonJS({
  "node_modules/ssh2/lib/protocol/constants.js"(exports, module2) {
    "use strict";
    var crypto = require("crypto");
    var cpuInfo;
    try {
      cpuInfo = require_lib2()();
    } catch {
    }
    var { bindingAvailable, CIPHER_INFO, MAC_INFO } = require_crypto();
    var eddsaSupported = (() => {
      if (typeof crypto.sign === "function" && typeof crypto.verify === "function") {
        const key = "-----BEGIN PRIVATE KEY-----\r\nMC4CAQAwBQYDK2VwBCIEIHKj+sVa9WcD/q2DJUJaf43Kptc8xYuUQA4bOFj9vC8T\r\n-----END PRIVATE KEY-----";
        const data = Buffer.from("a");
        let sig;
        let verified;
        try {
          sig = crypto.sign(null, data, key);
          verified = crypto.verify(null, data, key, sig);
        } catch {
        }
        return Buffer.isBuffer(sig) && sig.length === 64 && verified === true;
      }
      return false;
    })();
    var curve25519Supported = typeof crypto.diffieHellman === "function" && typeof crypto.generateKeyPairSync === "function" && typeof crypto.createPublicKey === "function";
    var DEFAULT_KEX = [
      "ecdh-sha2-nistp256",
      "ecdh-sha2-nistp384",
      "ecdh-sha2-nistp521",
      "diffie-hellman-group-exchange-sha256",
      "diffie-hellman-group14-sha256",
      "diffie-hellman-group15-sha512",
      "diffie-hellman-group16-sha512",
      "diffie-hellman-group17-sha512",
      "diffie-hellman-group18-sha512"
    ];
    if (curve25519Supported) {
      DEFAULT_KEX.unshift("curve25519-sha256");
      DEFAULT_KEX.unshift("curve25519-sha256@libssh.org");
    }
    var SUPPORTED_KEX = DEFAULT_KEX.concat([
      "diffie-hellman-group-exchange-sha1",
      "diffie-hellman-group14-sha1",
      "diffie-hellman-group1-sha1"
    ]);
    var DEFAULT_SERVER_HOST_KEY = [
      "ecdsa-sha2-nistp256",
      "ecdsa-sha2-nistp384",
      "ecdsa-sha2-nistp521",
      "rsa-sha2-512",
      "rsa-sha2-256",
      "ssh-rsa"
    ];
    if (eddsaSupported)
      DEFAULT_SERVER_HOST_KEY.unshift("ssh-ed25519");
    var SUPPORTED_SERVER_HOST_KEY = DEFAULT_SERVER_HOST_KEY.concat([
      "ssh-dss"
    ]);
    var canUseCipher = (() => {
      const ciphers = crypto.getCiphers();
      return (name) => ciphers.includes(CIPHER_INFO[name].sslName);
    })();
    var DEFAULT_CIPHER = [
      "aes128-gcm@openssh.com",
      "aes256-gcm@openssh.com",
      "aes128-ctr",
      "aes192-ctr",
      "aes256-ctr"
    ];
    if (cpuInfo && cpuInfo.flags && !cpuInfo.flags.aes) {
      if (bindingAvailable)
        DEFAULT_CIPHER.unshift("chacha20-poly1305@openssh.com");
      else
        DEFAULT_CIPHER.push("chacha20-poly1305@openssh.com");
    } else if (bindingAvailable && cpuInfo && cpuInfo.arch === "x86") {
      DEFAULT_CIPHER.splice(4, 0, "chacha20-poly1305@openssh.com");
    } else {
      DEFAULT_CIPHER.push("chacha20-poly1305@openssh.com");
    }
    DEFAULT_CIPHER = DEFAULT_CIPHER.filter(canUseCipher);
    var SUPPORTED_CIPHER = DEFAULT_CIPHER.concat([
      "aes256-cbc",
      "aes192-cbc",
      "aes128-cbc",
      "blowfish-cbc",
      "3des-cbc",
      "aes128-gcm",
      "aes256-gcm",
      "arcfour256",
      "arcfour128",
      "cast128-cbc",
      "arcfour"
    ].filter(canUseCipher));
    var canUseMAC = (() => {
      const hashes = crypto.getHashes();
      return (name) => hashes.includes(MAC_INFO[name].sslName);
    })();
    var DEFAULT_MAC = [
      "hmac-sha2-256-etm@openssh.com",
      "hmac-sha2-512-etm@openssh.com",
      "hmac-sha1-etm@openssh.com",
      "hmac-sha2-256",
      "hmac-sha2-512",
      "hmac-sha1"
    ].filter(canUseMAC);
    var SUPPORTED_MAC = DEFAULT_MAC.concat([
      "hmac-md5",
      "hmac-sha2-256-96",
      "hmac-sha2-512-96",
      "hmac-ripemd160",
      "hmac-sha1-96",
      "hmac-md5-96"
    ].filter(canUseMAC));
    var DEFAULT_COMPRESSION = [
      "none",
      "zlib@openssh.com",
      "zlib"
    ];
    var SUPPORTED_COMPRESSION = DEFAULT_COMPRESSION.concat([]);
    var COMPAT = {
      BAD_DHGEX: 1 << 0,
      OLD_EXIT: 1 << 1,
      DYN_RPORT_BUG: 1 << 2,
      BUG_DHGEX_LARGE: 1 << 3
    };
    module2.exports = {
      MESSAGE: {
        DISCONNECT: 1,
        IGNORE: 2,
        UNIMPLEMENTED: 3,
        DEBUG: 4,
        SERVICE_REQUEST: 5,
        SERVICE_ACCEPT: 6,
        KEXINIT: 20,
        NEWKEYS: 21,
        KEXDH_INIT: 30,
        KEXDH_REPLY: 31,
        KEXDH_GEX_GROUP: 31,
        KEXDH_GEX_INIT: 32,
        KEXDH_GEX_REPLY: 33,
        KEXDH_GEX_REQUEST: 34,
        KEXECDH_INIT: 30,
        KEXECDH_REPLY: 31,
        USERAUTH_REQUEST: 50,
        USERAUTH_FAILURE: 51,
        USERAUTH_SUCCESS: 52,
        USERAUTH_BANNER: 53,
        USERAUTH_PASSWD_CHANGEREQ: 60,
        USERAUTH_PK_OK: 60,
        USERAUTH_INFO_REQUEST: 60,
        USERAUTH_INFO_RESPONSE: 61,
        GLOBAL_REQUEST: 80,
        REQUEST_SUCCESS: 81,
        REQUEST_FAILURE: 82,
        CHANNEL_OPEN: 90,
        CHANNEL_OPEN_CONFIRMATION: 91,
        CHANNEL_OPEN_FAILURE: 92,
        CHANNEL_WINDOW_ADJUST: 93,
        CHANNEL_DATA: 94,
        CHANNEL_EXTENDED_DATA: 95,
        CHANNEL_EOF: 96,
        CHANNEL_CLOSE: 97,
        CHANNEL_REQUEST: 98,
        CHANNEL_SUCCESS: 99,
        CHANNEL_FAILURE: 100
      },
      DISCONNECT_REASON: {
        HOST_NOT_ALLOWED_TO_CONNECT: 1,
        PROTOCOL_ERROR: 2,
        KEY_EXCHANGE_FAILED: 3,
        RESERVED: 4,
        MAC_ERROR: 5,
        COMPRESSION_ERROR: 6,
        SERVICE_NOT_AVAILABLE: 7,
        PROTOCOL_VERSION_NOT_SUPPORTED: 8,
        HOST_KEY_NOT_VERIFIABLE: 9,
        CONNECTION_LOST: 10,
        BY_APPLICATION: 11,
        TOO_MANY_CONNECTIONS: 12,
        AUTH_CANCELED_BY_USER: 13,
        NO_MORE_AUTH_METHODS_AVAILABLE: 14,
        ILLEGAL_USER_NAME: 15
      },
      DISCONNECT_REASON_STR: void 0,
      CHANNEL_OPEN_FAILURE: {
        ADMINISTRATIVELY_PROHIBITED: 1,
        CONNECT_FAILED: 2,
        UNKNOWN_CHANNEL_TYPE: 3,
        RESOURCE_SHORTAGE: 4
      },
      TERMINAL_MODE: {
        TTY_OP_END: 0,
        VINTR: 1,
        VQUIT: 2,
        VERASE: 3,
        VKILL: 4,
        VEOF: 5,
        VEOL: 6,
        VEOL2: 7,
        VSTART: 8,
        VSTOP: 9,
        VSUSP: 10,
        VDSUSP: 11,
        VREPRINT: 12,
        VWERASE: 13,
        VLNEXT: 14,
        VFLUSH: 15,
        VSWTCH: 16,
        VSTATUS: 17,
        VDISCARD: 18,
        IGNPAR: 30,
        PARMRK: 31,
        INPCK: 32,
        ISTRIP: 33,
        INLCR: 34,
        IGNCR: 35,
        ICRNL: 36,
        IUCLC: 37,
        IXON: 38,
        IXANY: 39,
        IXOFF: 40,
        IMAXBEL: 41,
        ISIG: 50,
        ICANON: 51,
        XCASE: 52,
        ECHO: 53,
        ECHOE: 54,
        ECHOK: 55,
        ECHONL: 56,
        NOFLSH: 57,
        TOSTOP: 58,
        IEXTEN: 59,
        ECHOCTL: 60,
        ECHOKE: 61,
        PENDIN: 62,
        OPOST: 70,
        OLCUC: 71,
        ONLCR: 72,
        OCRNL: 73,
        ONOCR: 74,
        ONLRET: 75,
        CS7: 90,
        CS8: 91,
        PARENB: 92,
        PARODD: 93,
        TTY_OP_ISPEED: 128,
        TTY_OP_OSPEED: 129
      },
      CHANNEL_EXTENDED_DATATYPE: {
        STDERR: 1
      },
      SIGNALS: [
        "ABRT",
        "ALRM",
        "FPE",
        "HUP",
        "ILL",
        "INT",
        "QUIT",
        "SEGV",
        "TERM",
        "USR1",
        "USR2",
        "KILL",
        "PIPE"
      ].reduce((cur, val) => __spreadProps(__spreadValues({}, cur), { [val]: 1 }), {}),
      COMPAT,
      COMPAT_CHECKS: [
        ["Cisco-1.25", COMPAT.BAD_DHGEX],
        [/^Cisco-1\./, COMPAT.BUG_DHGEX_LARGE],
        [/^[0-9.]+$/, COMPAT.OLD_EXIT],
        [/^OpenSSH_5\.\d+/, COMPAT.DYN_RPORT_BUG]
      ],
      DEFAULT_KEX,
      SUPPORTED_KEX,
      DEFAULT_SERVER_HOST_KEY,
      SUPPORTED_SERVER_HOST_KEY,
      DEFAULT_CIPHER,
      SUPPORTED_CIPHER,
      DEFAULT_MAC,
      SUPPORTED_MAC,
      DEFAULT_COMPRESSION,
      SUPPORTED_COMPRESSION,
      curve25519Supported,
      eddsaSupported
    };
    module2.exports.DISCONNECT_REASON_BY_VALUE = Array.from(Object.entries(module2.exports.DISCONNECT_REASON)).reduce((obj, [key, value]) => __spreadProps(__spreadValues({}, obj), { [value]: key }), {});
  }
});

// node_modules/ssh2/lib/protocol/utils.js
var require_utils2 = __commonJS({
  "node_modules/ssh2/lib/protocol/utils.js"(exports, module2) {
    "use strict";
    var Ber = require_lib().Ber;
    var DISCONNECT_REASON;
    var FastBuffer = Buffer[Symbol.species];
    var TypedArrayFill = Object.getPrototypeOf(Uint8Array.prototype).fill;
    function readUInt32BE(buf, offset) {
      return buf[offset++] * 16777216 + buf[offset++] * 65536 + buf[offset++] * 256 + buf[offset];
    }
    function bufferCopy(src, dest, srcStart, srcEnd, destStart) {
      if (!destStart)
        destStart = 0;
      if (srcEnd > src.length)
        srcEnd = src.length;
      let nb = srcEnd - srcStart;
      const destLeft = dest.length - destStart;
      if (nb > destLeft)
        nb = destLeft;
      dest.set(new Uint8Array(src.buffer, src.byteOffset + srcStart, nb), destStart);
      return nb;
    }
    function bufferSlice(buf, start, end) {
      if (end === void 0)
        end = buf.length;
      return new FastBuffer(buf.buffer, buf.byteOffset + start, end - start);
    }
    function makeBufferParser() {
      let pos = 0;
      let buffer;
      const self2 = {
        init: (buf, start) => {
          buffer = buf;
          pos = typeof start === "number" ? start : 0;
        },
        pos: () => pos,
        length: () => buffer ? buffer.length : 0,
        avail: () => buffer && pos < buffer.length ? buffer.length - pos : 0,
        clear: () => {
          buffer = void 0;
        },
        readUInt32BE: () => {
          if (!buffer || pos + 3 >= buffer.length)
            return;
          return buffer[pos++] * 16777216 + buffer[pos++] * 65536 + buffer[pos++] * 256 + buffer[pos++];
        },
        readUInt64BE: (behavior) => {
          if (!buffer || pos + 7 >= buffer.length)
            return;
          switch (behavior) {
            case "always":
              return BigInt(`0x${buffer.hexSlice(pos, pos += 8)}`);
            case "maybe":
              if (buffer[pos] > 31)
                return BigInt(`0x${buffer.hexSlice(pos, pos += 8)}`);
            default:
              return buffer[pos++] * 72057594037927940 + buffer[pos++] * 281474976710656 + buffer[pos++] * 1099511627776 + buffer[pos++] * 4294967296 + buffer[pos++] * 16777216 + buffer[pos++] * 65536 + buffer[pos++] * 256 + buffer[pos++];
          }
        },
        skip: (n) => {
          if (buffer && n > 0)
            pos += n;
        },
        skipString: () => {
          const len = self2.readUInt32BE();
          if (len === void 0)
            return;
          pos += len;
          return pos <= buffer.length ? len : void 0;
        },
        readByte: () => {
          if (buffer && pos < buffer.length)
            return buffer[pos++];
        },
        readBool: () => {
          if (buffer && pos < buffer.length)
            return !!buffer[pos++];
        },
        readList: () => {
          const list = self2.readString(true);
          if (list === void 0)
            return;
          return list ? list.split(",") : [];
        },
        readString: (dest, maxLen) => {
          if (typeof dest === "number") {
            maxLen = dest;
            dest = void 0;
          }
          const len = self2.readUInt32BE();
          if (len === void 0)
            return;
          if (buffer.length - pos < len || typeof maxLen === "number" && len > maxLen) {
            return;
          }
          if (dest) {
            if (Buffer.isBuffer(dest))
              return bufferCopy(buffer, dest, pos, pos += len);
            return buffer.utf8Slice(pos, pos += len);
          }
          return bufferSlice(buffer, pos, pos += len);
        },
        readRaw: (len) => {
          if (!buffer)
            return;
          if (typeof len !== "number")
            return bufferSlice(buffer, pos, pos += buffer.length - pos);
          if (buffer.length - pos >= len)
            return bufferSlice(buffer, pos, pos += len);
        }
      };
      return self2;
    }
    function makeError(msg, level, fatal) {
      const err = new Error(msg);
      if (typeof level === "boolean") {
        fatal = level;
        err.level = "protocol";
      } else {
        err.level = level || "protocol";
      }
      err.fatal = !!fatal;
      return err;
    }
    function writeUInt32BE(buf, value, offset) {
      buf[offset++] = value >>> 24;
      buf[offset++] = value >>> 16;
      buf[offset++] = value >>> 8;
      buf[offset++] = value;
      return offset;
    }
    var utilBufferParser = makeBufferParser();
    module2.exports = {
      bufferCopy,
      bufferSlice,
      FastBuffer,
      bufferFill: (buf, value, start, end) => {
        return TypedArrayFill.call(buf, value, start, end);
      },
      makeError,
      doFatalError: (protocol, msg, level, reason) => {
        let err;
        if (DISCONNECT_REASON === void 0)
          ({ DISCONNECT_REASON } = require_constants());
        if (msg instanceof Error) {
          err = msg;
          if (typeof level !== "number")
            reason = DISCONNECT_REASON.PROTOCOL_ERROR;
          else
            reason = level;
        } else {
          err = makeError(msg, level, true);
        }
        if (typeof reason !== "number")
          reason = DISCONNECT_REASON.PROTOCOL_ERROR;
        protocol.disconnect(reason);
        protocol._destruct();
        protocol._onError(err);
        return Infinity;
      },
      readUInt32BE,
      writeUInt32BE,
      writeUInt32LE: (buf, value, offset) => {
        buf[offset++] = value;
        buf[offset++] = value >>> 8;
        buf[offset++] = value >>> 16;
        buf[offset++] = value >>> 24;
        return offset;
      },
      makeBufferParser,
      bufferParser: makeBufferParser(),
      readString: (buffer, start, dest, maxLen) => {
        if (typeof dest === "number") {
          maxLen = dest;
          dest = void 0;
        }
        if (start === void 0)
          start = 0;
        const left = buffer.length - start;
        if (start < 0 || start >= buffer.length || left < 4)
          return;
        const len = readUInt32BE(buffer, start);
        if (left < 4 + len || typeof maxLen === "number" && len > maxLen)
          return;
        start += 4;
        const end = start + len;
        buffer._pos = end;
        if (dest) {
          if (Buffer.isBuffer(dest))
            return bufferCopy(buffer, dest, start, end);
          return buffer.utf8Slice(start, end);
        }
        return bufferSlice(buffer, start, end);
      },
      sigSSHToASN1: (sig, type) => {
        switch (type) {
          case "ssh-dss": {
            if (sig.length > 40)
              return sig;
            const asnWriter = new Ber.Writer();
            asnWriter.startSequence();
            let r = sig.slice(0, 20);
            let s = sig.slice(20);
            if (r[0] & 128) {
              const rNew = Buffer.allocUnsafe(21);
              rNew[0] = 0;
              r.copy(rNew, 1);
              r = rNew;
            } else if (r[0] === 0 && !(r[1] & 128)) {
              r = r.slice(1);
            }
            if (s[0] & 128) {
              const sNew = Buffer.allocUnsafe(21);
              sNew[0] = 0;
              s.copy(sNew, 1);
              s = sNew;
            } else if (s[0] === 0 && !(s[1] & 128)) {
              s = s.slice(1);
            }
            asnWriter.writeBuffer(r, Ber.Integer);
            asnWriter.writeBuffer(s, Ber.Integer);
            asnWriter.endSequence();
            return asnWriter.buffer;
          }
          case "ecdsa-sha2-nistp256":
          case "ecdsa-sha2-nistp384":
          case "ecdsa-sha2-nistp521": {
            utilBufferParser.init(sig, 0);
            const r = utilBufferParser.readString();
            const s = utilBufferParser.readString();
            utilBufferParser.clear();
            if (r === void 0 || s === void 0)
              return;
            const asnWriter = new Ber.Writer();
            asnWriter.startSequence();
            asnWriter.writeBuffer(r, Ber.Integer);
            asnWriter.writeBuffer(s, Ber.Integer);
            asnWriter.endSequence();
            return asnWriter.buffer;
          }
          default:
            return sig;
        }
      },
      convertSignature: (signature, keyType) => {
        switch (keyType) {
          case "ssh-dss": {
            if (signature.length <= 40)
              return signature;
            const asnReader = new Ber.Reader(signature);
            asnReader.readSequence();
            let r = asnReader.readString(Ber.Integer, true);
            let s = asnReader.readString(Ber.Integer, true);
            let rOffset = 0;
            let sOffset = 0;
            if (r.length < 20) {
              const rNew = Buffer.allocUnsafe(20);
              rNew.set(r, 1);
              r = rNew;
              r[0] = 0;
            }
            if (s.length < 20) {
              const sNew = Buffer.allocUnsafe(20);
              sNew.set(s, 1);
              s = sNew;
              s[0] = 0;
            }
            if (r.length > 20 && r[0] === 0)
              rOffset = 1;
            if (s.length > 20 && s[0] === 0)
              sOffset = 1;
            const newSig = Buffer.allocUnsafe(r.length - rOffset + (s.length - sOffset));
            bufferCopy(r, newSig, rOffset, r.length, 0);
            bufferCopy(s, newSig, sOffset, s.length, r.length - rOffset);
            return newSig;
          }
          case "ecdsa-sha2-nistp256":
          case "ecdsa-sha2-nistp384":
          case "ecdsa-sha2-nistp521": {
            if (signature[0] === 0)
              return signature;
            const asnReader = new Ber.Reader(signature);
            asnReader.readSequence();
            const r = asnReader.readString(Ber.Integer, true);
            const s = asnReader.readString(Ber.Integer, true);
            if (r === null || s === null)
              return;
            const newSig = Buffer.allocUnsafe(4 + r.length + 4 + s.length);
            writeUInt32BE(newSig, r.length, 0);
            newSig.set(r, 4);
            writeUInt32BE(newSig, s.length, 4 + r.length);
            newSig.set(s, 4 + 4 + r.length);
            return newSig;
          }
        }
        return signature;
      },
      sendPacket: (proto, packet, bypass) => {
        if (!bypass && proto._kexinit !== void 0) {
          if (proto._queue === void 0)
            proto._queue = [];
          proto._queue.push(packet);
          proto._debug && proto._debug("Outbound: ... packet queued");
          return false;
        }
        proto._cipher.encrypt(packet);
        return true;
      }
    };
  }
});

// node_modules/ssh2/lib/protocol/crypto/build/Release/sshcrypto.node
var sshcrypto_default;
var init_sshcrypto = __esm({
  "node_modules/ssh2/lib/protocol/crypto/build/Release/sshcrypto.node"() {
    sshcrypto_default = "./sshcrypto-MXPYBZCO.node";
  }
});

// node-file:/home/castello/repos/platform/analytics-datastore-elastic-search/scripts/node_modules/ssh2/lib/protocol/crypto/build/Release/sshcrypto.node
var require_sshcrypto = __commonJS({
  "node-file:/home/castello/repos/platform/analytics-datastore-elastic-search/scripts/node_modules/ssh2/lib/protocol/crypto/build/Release/sshcrypto.node"(exports, module2) {
    init_sshcrypto();
    try {
      module2.exports = require(sshcrypto_default);
    } catch {
    }
  }
});

// node_modules/ssh2/lib/protocol/crypto/poly1305.js
var require_poly1305 = __commonJS({
  "node_modules/ssh2/lib/protocol/crypto/poly1305.js"(exports, module2) {
    var createPoly1305 = function() {
      var _scriptDir = typeof document !== "undefined" && document.currentScript ? document.currentScript.src : void 0;
      if (typeof __filename !== "undefined")
        _scriptDir = _scriptDir || __filename;
      return function(createPoly13052) {
        createPoly13052 = createPoly13052 || {};
        var b;
        b || (b = typeof createPoly13052 !== "undefined" ? createPoly13052 : {});
        var q, r;
        b.ready = new Promise(function(a, c) {
          q = a;
          r = c;
        });
        var u = {}, w;
        for (w in b)
          b.hasOwnProperty(w) && (u[w] = b[w]);
        var x = typeof window === "object", y = typeof importScripts === "function", z = typeof process === "object" && typeof process.versions === "object" && typeof process.versions.node === "string", B = "", C, D, E, F, G;
        if (z)
          B = y ? require("path").dirname(B) + "/" : __dirname + "/", C = function(a, c) {
            var d = H(a);
            if (d)
              return c ? d : d.toString();
            F || (F = require("fs"));
            G || (G = require("path"));
            a = G.normalize(a);
            return F.readFileSync(a, c ? null : "utf8");
          }, E = function(a) {
            a = C(a, true);
            a.buffer || (a = new Uint8Array(a));
            assert(a.buffer);
            return a;
          }, D = function(a, c, d) {
            var e = H(a);
            e && c(e);
            F || (F = require("fs"));
            G || (G = require("path"));
            a = G.normalize(a);
            F.readFile(a, function(f, l) {
              f ? d(f) : c(l.buffer);
            });
          }, 1 < process.argv.length && process.argv[1].replace(/\\/g, "/"), process.argv.slice(2), b.inspect = function() {
            return "[Emscripten Module object]";
          };
        else if (x || y)
          y ? B = self.location.href : typeof document !== "undefined" && document.currentScript && (B = document.currentScript.src), _scriptDir && (B = _scriptDir), B.indexOf("blob:") !== 0 ? B = B.substr(0, B.lastIndexOf("/") + 1) : B = "", C = function(a) {
            try {
              var c = new XMLHttpRequest();
              c.open("GET", a, false);
              c.send(null);
              return c.responseText;
            } catch (f) {
              if (a = H(a)) {
                c = [];
                for (var d = 0; d < a.length; d++) {
                  var e = a[d];
                  255 < e && (ba && assert(false, "Character code " + e + " (" + String.fromCharCode(e) + ")  at offset " + d + " not in 0x00-0xFF."), e &= 255);
                  c.push(String.fromCharCode(e));
                }
                return c.join("");
              }
              throw f;
            }
          }, y && (E = function(a) {
            try {
              var c = new XMLHttpRequest();
              c.open("GET", a, false);
              c.responseType = "arraybuffer";
              c.send(null);
              return new Uint8Array(c.response);
            } catch (d) {
              if (a = H(a))
                return a;
              throw d;
            }
          }), D = function(a, c, d) {
            var e = new XMLHttpRequest();
            e.open("GET", a, true);
            e.responseType = "arraybuffer";
            e.onload = function() {
              if (e.status == 200 || e.status == 0 && e.response)
                c(e.response);
              else {
                var f = H(a);
                f ? c(f.buffer) : d();
              }
            };
            e.onerror = d;
            e.send(null);
          };
        b.print || console.log.bind(console);
        var I = b.printErr || console.warn.bind(console);
        for (w in u)
          u.hasOwnProperty(w) && (b[w] = u[w]);
        u = null;
        var J;
        b.wasmBinary && (J = b.wasmBinary);
        var noExitRuntime = b.noExitRuntime || true;
        typeof WebAssembly !== "object" && K("no native wasm support detected");
        var L, M = false;
        function assert(a, c) {
          a || K("Assertion failed: " + c);
        }
        function N(a) {
          var c = b["_" + a];
          assert(c, "Cannot call unknown function " + a + ", make sure it is exported");
          return c;
        }
        function ca(a, c, d, e) {
          var f = { string: function(g) {
            var p = 0;
            if (g !== null && g !== void 0 && g !== 0) {
              var n = (g.length << 2) + 1;
              p = O(n);
              var k = p, h = P;
              if (0 < n) {
                n = k + n - 1;
                for (var v = 0; v < g.length; ++v) {
                  var m = g.charCodeAt(v);
                  if (55296 <= m && 57343 >= m) {
                    var oa = g.charCodeAt(++v);
                    m = 65536 + ((m & 1023) << 10) | oa & 1023;
                  }
                  if (127 >= m) {
                    if (k >= n)
                      break;
                    h[k++] = m;
                  } else {
                    if (2047 >= m) {
                      if (k + 1 >= n)
                        break;
                      h[k++] = 192 | m >> 6;
                    } else {
                      if (65535 >= m) {
                        if (k + 2 >= n)
                          break;
                        h[k++] = 224 | m >> 12;
                      } else {
                        if (k + 3 >= n)
                          break;
                        h[k++] = 240 | m >> 18;
                        h[k++] = 128 | m >> 12 & 63;
                      }
                      h[k++] = 128 | m >> 6 & 63;
                    }
                    h[k++] = 128 | m & 63;
                  }
                }
                h[k] = 0;
              }
            }
            return p;
          }, array: function(g) {
            var p = O(g.length);
            Q.set(g, p);
            return p;
          } }, l = N(a), A = [];
          a = 0;
          if (e)
            for (var t = 0; t < e.length; t++) {
              var aa = f[d[t]];
              aa ? (a === 0 && (a = da()), A[t] = aa(e[t])) : A[t] = e[t];
            }
          d = l.apply(null, A);
          d = function(g) {
            if (c === "string")
              if (g) {
                for (var p = P, n = g + NaN, k = g; p[k] && !(k >= n); )
                  ++k;
                if (16 < k - g && p.subarray && ea)
                  g = ea.decode(p.subarray(g, k));
                else {
                  for (n = ""; g < k; ) {
                    var h = p[g++];
                    if (h & 128) {
                      var v = p[g++] & 63;
                      if ((h & 224) == 192)
                        n += String.fromCharCode((h & 31) << 6 | v);
                      else {
                        var m = p[g++] & 63;
                        h = (h & 240) == 224 ? (h & 15) << 12 | v << 6 | m : (h & 7) << 18 | v << 12 | m << 6 | p[g++] & 63;
                        65536 > h ? n += String.fromCharCode(h) : (h -= 65536, n += String.fromCharCode(55296 | h >> 10, 56320 | h & 1023));
                      }
                    } else
                      n += String.fromCharCode(h);
                  }
                  g = n;
                }
              } else
                g = "";
            else
              g = c === "boolean" ? !!g : g;
            return g;
          }(d);
          a !== 0 && fa(a);
          return d;
        }
        var ea = typeof TextDecoder !== "undefined" ? new TextDecoder("utf8") : void 0, ha, Q, P;
        function ia() {
          var a = L.buffer;
          ha = a;
          b.HEAP8 = Q = new Int8Array(a);
          b.HEAP16 = new Int16Array(a);
          b.HEAP32 = new Int32Array(a);
          b.HEAPU8 = P = new Uint8Array(a);
          b.HEAPU16 = new Uint16Array(a);
          b.HEAPU32 = new Uint32Array(a);
          b.HEAPF32 = new Float32Array(a);
          b.HEAPF64 = new Float64Array(a);
        }
        var R, ja = [], ka = [], la = [];
        function ma() {
          var a = b.preRun.shift();
          ja.unshift(a);
        }
        var S = 0, T = null, U = null;
        b.preloadedImages = {};
        b.preloadedAudios = {};
        function K(a) {
          if (b.onAbort)
            b.onAbort(a);
          I(a);
          M = true;
          a = new WebAssembly.RuntimeError("abort(" + a + "). Build with -s ASSERTIONS=1 for more info.");
          r(a);
          throw a;
        }
        var V = "data:application/octet-stream;base64,", W;
        W = "data:application/octet-stream;base64,AGFzbQEAAAABIAZgAX8Bf2ADf39/AGABfwBgAABgAAF/YAZ/f39/f38AAgcBAWEBYQAAAwsKAAEDAQAAAgQFAgQFAXABAQEFBwEBgAKAgAIGCQF/AUGAjMACCwclCQFiAgABYwADAWQACQFlAAgBZgAHAWcABgFoAAUBaQAKAWoBAAqGTQpPAQJ/QYAIKAIAIgEgAEEDakF8cSICaiEAAkAgAkEAIAAgAU0bDQAgAD8AQRB0SwRAIAAQAEUNAQtBgAggADYCACABDwtBhAhBMDYCAEF/C4wFAg5+Cn8gACgCJCEUIAAoAiAhFSAAKAIcIREgACgCGCESIAAoAhQhEyACQRBPBEAgAC0ATEVBGHQhFyAAKAIEIhZBBWytIQ8gACgCCCIYQQVsrSENIAAoAgwiGUEFbK0hCyAAKAIQIhpBBWytIQkgADUCACEIIBqtIRAgGa0hDiAYrSEMIBatIQoDQCASIAEtAAMiEiABLQAEQQh0ciABLQAFQRB0ciABLQAGIhZBGHRyQQJ2Qf///x9xaq0iAyAOfiABLwAAIAEtAAJBEHRyIBNqIBJBGHRBgICAGHFqrSIEIBB+fCARIAEtAAdBCHQgFnIgAS0ACEEQdHIgAS0ACSIRQRh0ckEEdkH///8fcWqtIgUgDH58IAEtAApBCHQgEXIgAS0AC0EQdHIgAS0ADEEYdHJBBnYgFWqtIgYgCn58IBQgF2ogAS8ADSABLQAPQRB0cmqtIgcgCH58IAMgDH4gBCAOfnwgBSAKfnwgBiAIfnwgByAJfnwgAyAKfiAEIAx+fCAFIAh+fCAGIAl+fCAHIAt+fCADIAh+IAQgCn58IAUgCX58IAYgC358IAcgDX58IAMgCX4gBCAIfnwgBSALfnwgBiANfnwgByAPfnwiA0IaiEL/////D4N8IgRCGohC/////w+DfCIFQhqIQv////8Pg3wiBkIaiEL/////D4N8IgdCGoinQQVsIAOnQf///x9xaiITQRp2IASnQf///x9xaiESIAWnQf///x9xIREgBqdB////H3EhFSAHp0H///8fcSEUIBNB////H3EhEyABQRBqIQEgAkEQayICQQ9LDQALCyAAIBQ2AiQgACAVNgIgIAAgETYCHCAAIBI2AhggACATNgIUCwMAAQu2BAEGfwJAIAAoAjgiBARAIABBPGohBQJAIAJBECAEayIDIAIgA0kbIgZFDQAgBkEDcSEHAkAgBkEBa0EDSQRAQQAhAwwBCyAGQXxxIQhBACEDA0AgBSADIARqaiABIANqLQAAOgAAIAUgA0EBciIEIAAoAjhqaiABIARqLQAAOgAAIAUgA0ECciIEIAAoAjhqaiABIARqLQAAOgAAIAUgA0EDciIEIAAoAjhqaiABIARqLQAAOgAAIANBBGohAyAAKAI4IQQgCEEEayIIDQALCyAHRQ0AA0AgBSADIARqaiABIANqLQAAOgAAIANBAWohAyAAKAI4IQQgB0EBayIHDQALCyAAIAQgBmoiAzYCOCADQRBJDQEgACAFQRAQAiAAQQA2AjggAiAGayECIAEgBmohAQsgAkEQTwRAIAAgASACQXBxIgMQAiACQQ9xIQIgASADaiEBCyACRQ0AIAJBA3EhBCAAQTxqIQVBACEDIAJBAWtBA08EQCACQXxxIQcDQCAFIAAoAjggA2pqIAEgA2otAAA6AAAgBSADQQFyIgYgACgCOGpqIAEgBmotAAA6AAAgBSADQQJyIgYgACgCOGpqIAEgBmotAAA6AAAgBSADQQNyIgYgACgCOGpqIAEgBmotAAA6AAAgA0EEaiEDIAdBBGsiBw0ACwsgBARAA0AgBSAAKAI4IANqaiABIANqLQAAOgAAIANBAWohAyAEQQFrIgQNAAsLIAAgACgCOCACajYCOAsLoS0BDH8jAEEQayIMJAACQAJAAkACQAJAAkACQAJAAkACQAJAAkAgAEH0AU0EQEGICCgCACIFQRAgAEELakF4cSAAQQtJGyIIQQN2IgJ2IgFBA3EEQCABQX9zQQFxIAJqIgNBA3QiAUG4CGooAgAiBEEIaiEAAkAgBCgCCCICIAFBsAhqIgFGBEBBiAggBUF+IAN3cTYCAAwBCyACIAE2AgwgASACNgIICyAEIANBA3QiAUEDcjYCBCABIARqIgEgASgCBEEBcjYCBAwNCyAIQZAIKAIAIgpNDQEgAQRAAkBBAiACdCIAQQAgAGtyIAEgAnRxIgBBACAAa3FBAWsiACAAQQx2QRBxIgJ2IgFBBXZBCHEiACACciABIAB2IgFBAnZBBHEiAHIgASAAdiIBQQF2QQJxIgByIAEgAHYiAUEBdkEBcSIAciABIAB2aiIDQQN0IgBBuAhqKAIAIgQoAggiASAAQbAIaiIARgRAQYgIIAVBfiADd3EiBTYCAAwBCyABIAA2AgwgACABNgIICyAEQQhqIQAgBCAIQQNyNgIEIAQgCGoiAiADQQN0IgEgCGsiA0EBcjYCBCABIARqIAM2AgAgCgRAIApBA3YiAUEDdEGwCGohB0GcCCgCACEEAn8gBUEBIAF0IgFxRQRAQYgIIAEgBXI2AgAgBwwBCyAHKAIICyEBIAcgBDYCCCABIAQ2AgwgBCAHNgIMIAQgATYCCAtBnAggAjYCAEGQCCADNgIADA0LQYwIKAIAIgZFDQEgBkEAIAZrcUEBayIAIABBDHZBEHEiAnYiAUEFdkEIcSIAIAJyIAEgAHYiAUECdkEEcSIAciABIAB2IgFBAXZBAnEiAHIgASAAdiIBQQF2QQFxIgByIAEgAHZqQQJ0QbgKaigCACIBKAIEQXhxIAhrIQMgASECA0ACQCACKAIQIgBFBEAgAigCFCIARQ0BCyAAKAIEQXhxIAhrIgIgAyACIANJIgIbIQMgACABIAIbIQEgACECDAELCyABIAhqIgkgAU0NAiABKAIYIQsgASABKAIMIgRHBEAgASgCCCIAQZgIKAIASRogACAENgIMIAQgADYCCAwMCyABQRRqIgIoAgAiAEUEQCABKAIQIgBFDQQgAUEQaiECCwNAIAIhByAAIgRBFGoiAigCACIADQAgBEEQaiECIAQoAhAiAA0ACyAHQQA2AgAMCwtBfyEIIABBv39LDQAgAEELaiIAQXhxIQhBjAgoAgAiCUUNAEEAIAhrIQMCQAJAAkACf0EAIAhBgAJJDQAaQR8gCEH///8HSw0AGiAAQQh2IgAgAEGA/j9qQRB2QQhxIgJ0IgAgAEGA4B9qQRB2QQRxIgF0IgAgAEGAgA9qQRB2QQJxIgB0QQ92IAEgAnIgAHJrIgBBAXQgCCAAQRVqdkEBcXJBHGoLIgVBAnRBuApqKAIAIgJFBEBBACEADAELQQAhACAIQQBBGSAFQQF2ayAFQR9GG3QhAQNAAkAgAigCBEF4cSAIayIHIANPDQAgAiEEIAciAw0AQQAhAyACIQAMAwsgACACKAIUIgcgByACIAFBHXZBBHFqKAIQIgJGGyAAIAcbIQAgAUEBdCEBIAINAAsLIAAgBHJFBEBBACEEQQIgBXQiAEEAIABrciAJcSIARQ0DIABBACAAa3FBAWsiACAAQQx2QRBxIgJ2IgFBBXZBCHEiACACciABIAB2IgFBAnZBBHEiAHIgASAAdiIBQQF2QQJxIgByIAEgAHYiAUEBdkEBcSIAciABIAB2akECdEG4CmooAgAhAAsgAEUNAQsDQCAAKAIEQXhxIAhrIgEgA0khAiABIAMgAhshAyAAIAQgAhshBCAAKAIQIgEEfyABBSAAKAIUCyIADQALCyAERQ0AIANBkAgoAgAgCGtPDQAgBCAIaiIGIARNDQEgBCgCGCEFIAQgBCgCDCIBRwRAIAQoAggiAEGYCCgCAEkaIAAgATYCDCABIAA2AggMCgsgBEEUaiICKAIAIgBFBEAgBCgCECIARQ0EIARBEGohAgsDQCACIQcgACIBQRRqIgIoAgAiAA0AIAFBEGohAiABKAIQIgANAAsgB0EANgIADAkLIAhBkAgoAgAiAk0EQEGcCCgCACEDAkAgAiAIayIBQRBPBEBBkAggATYCAEGcCCADIAhqIgA2AgAgACABQQFyNgIEIAIgA2ogATYCACADIAhBA3I2AgQMAQtBnAhBADYCAEGQCEEANgIAIAMgAkEDcjYCBCACIANqIgAgACgCBEEBcjYCBAsgA0EIaiEADAsLIAhBlAgoAgAiBkkEQEGUCCAGIAhrIgE2AgBBoAhBoAgoAgAiAiAIaiIANgIAIAAgAUEBcjYCBCACIAhBA3I2AgQgAkEIaiEADAsLQQAhACAIQS9qIgkCf0HgCygCAARAQegLKAIADAELQewLQn83AgBB5AtCgKCAgICABDcCAEHgCyAMQQxqQXBxQdiq1aoFczYCAEH0C0EANgIAQcQLQQA2AgBBgCALIgFqIgVBACABayIHcSICIAhNDQpBwAsoAgAiBARAQbgLKAIAIgMgAmoiASADTQ0LIAEgBEsNCwtBxAstAABBBHENBQJAAkBBoAgoAgAiAwRAQcgLIQADQCADIAAoAgAiAU8EQCABIAAoAgRqIANLDQMLIAAoAggiAA0ACwtBABABIgFBf0YNBiACIQVB5AsoAgAiA0EBayIAIAFxBEAgAiABayAAIAFqQQAgA2txaiEFCyAFIAhNDQYgBUH+////B0sNBkHACygCACIEBEBBuAsoAgAiAyAFaiIAIANNDQcgACAESw0HCyAFEAEiACABRw0BDAgLIAUgBmsgB3EiBUH+////B0sNBSAFEAEiASAAKAIAIAAoAgRqRg0EIAEhAAsCQCAAQX9GDQAgCEEwaiAFTQ0AQegLKAIAIgEgCSAFa2pBACABa3EiAUH+////B0sEQCAAIQEMCAsgARABQX9HBEAgASAFaiEFIAAhAQwIC0EAIAVrEAEaDAULIAAiAUF/Rw0GDAQLAAtBACEEDAcLQQAhAQwFCyABQX9HDQILQcQLQcQLKAIAQQRyNgIACyACQf7///8HSw0BIAIQASEBQQAQASEAIAFBf0YNASAAQX9GDQEgACABTQ0BIAAgAWsiBSAIQShqTQ0BC0G4C0G4CygCACAFaiIANgIAQbwLKAIAIABJBEBBvAsgADYCAAsCQAJAAkBBoAgoAgAiBwRAQcgLIQADQCABIAAoAgAiAyAAKAIEIgJqRg0CIAAoAggiAA0ACwwCC0GYCCgCACIAQQAgACABTRtFBEBBmAggATYCAAtBACEAQcwLIAU2AgBByAsgATYCAEGoCEF/NgIAQawIQeALKAIANgIAQdQLQQA2AgADQCAAQQN0IgNBuAhqIANBsAhqIgI2AgAgA0G8CGogAjYCACAAQQFqIgBBIEcNAAtBlAggBUEoayIDQXggAWtBB3FBACABQQhqQQdxGyIAayICNgIAQaAIIAAgAWoiADYCACAAIAJBAXI2AgQgASADakEoNgIEQaQIQfALKAIANgIADAILIAAtAAxBCHENACADIAdLDQAgASAHTQ0AIAAgAiAFajYCBEGgCCAHQXggB2tBB3FBACAHQQhqQQdxGyIAaiICNgIAQZQIQZQIKAIAIAVqIgEgAGsiADYCACACIABBAXI2AgQgASAHakEoNgIEQaQIQfALKAIANgIADAELQZgIKAIAIAFLBEBBmAggATYCAAsgASAFaiECQcgLIQACQAJAAkACQAJAAkADQCACIAAoAgBHBEAgACgCCCIADQEMAgsLIAAtAAxBCHFFDQELQcgLIQADQCAHIAAoAgAiAk8EQCACIAAoAgRqIgQgB0sNAwsgACgCCCEADAALAAsgACABNgIAIAAgACgCBCAFajYCBCABQXggAWtBB3FBACABQQhqQQdxG2oiCSAIQQNyNgIEIAJBeCACa0EHcUEAIAJBCGpBB3EbaiIFIAggCWoiBmshAiAFIAdGBEBBoAggBjYCAEGUCEGUCCgCACACaiIANgIAIAYgAEEBcjYCBAwDCyAFQZwIKAIARgRAQZwIIAY2AgBBkAhBkAgoAgAgAmoiADYCACAGIABBAXI2AgQgACAGaiAANgIADAMLIAUoAgQiAEEDcUEBRgRAIABBeHEhBwJAIABB/wFNBEAgBSgCCCIDIABBA3YiAEEDdEGwCGpGGiADIAUoAgwiAUYEQEGICEGICCgCAEF+IAB3cTYCAAwCCyADIAE2AgwgASADNgIIDAELIAUoAhghCAJAIAUgBSgCDCIBRwRAIAUoAggiACABNgIMIAEgADYCCAwBCwJAIAVBFGoiACgCACIDDQAgBUEQaiIAKAIAIgMNAEEAIQEMAQsDQCAAIQQgAyIBQRRqIgAoAgAiAw0AIAFBEGohACABKAIQIgMNAAsgBEEANgIACyAIRQ0AAkAgBSAFKAIcIgNBAnRBuApqIgAoAgBGBEAgACABNgIAIAENAUGMCEGMCCgCAEF+IAN3cTYCAAwCCyAIQRBBFCAIKAIQIAVGG2ogATYCACABRQ0BCyABIAg2AhggBSgCECIABEAgASAANgIQIAAgATYCGAsgBSgCFCIARQ0AIAEgADYCFCAAIAE2AhgLIAUgB2ohBSACIAdqIQILIAUgBSgCBEF+cTYCBCAGIAJBAXI2AgQgAiAGaiACNgIAIAJB/wFNBEAgAkEDdiIAQQN0QbAIaiECAn9BiAgoAgAiAUEBIAB0IgBxRQRAQYgIIAAgAXI2AgAgAgwBCyACKAIICyEAIAIgBjYCCCAAIAY2AgwgBiACNgIMIAYgADYCCAwDC0EfIQAgAkH///8HTQRAIAJBCHYiACAAQYD+P2pBEHZBCHEiA3QiACAAQYDgH2pBEHZBBHEiAXQiACAAQYCAD2pBEHZBAnEiAHRBD3YgASADciAAcmsiAEEBdCACIABBFWp2QQFxckEcaiEACyAGIAA2AhwgBkIANwIQIABBAnRBuApqIQQCQEGMCCgCACIDQQEgAHQiAXFFBEBBjAggASADcjYCACAEIAY2AgAgBiAENgIYDAELIAJBAEEZIABBAXZrIABBH0YbdCEAIAQoAgAhAQNAIAEiAygCBEF4cSACRg0DIABBHXYhASAAQQF0IQAgAyABQQRxaiIEKAIQIgENAAsgBCAGNgIQIAYgAzYCGAsgBiAGNgIMIAYgBjYCCAwCC0GUCCAFQShrIgNBeCABa0EHcUEAIAFBCGpBB3EbIgBrIgI2AgBBoAggACABaiIANgIAIAAgAkEBcjYCBCABIANqQSg2AgRBpAhB8AsoAgA2AgAgByAEQScgBGtBB3FBACAEQSdrQQdxG2pBL2siACAAIAdBEGpJGyICQRs2AgQgAkHQCykCADcCECACQcgLKQIANwIIQdALIAJBCGo2AgBBzAsgBTYCAEHICyABNgIAQdQLQQA2AgAgAkEYaiEAA0AgAEEHNgIEIABBCGohASAAQQRqIQAgASAESQ0ACyACIAdGDQMgAiACKAIEQX5xNgIEIAcgAiAHayIEQQFyNgIEIAIgBDYCACAEQf8BTQRAIARBA3YiAEEDdEGwCGohAgJ/QYgIKAIAIgFBASAAdCIAcUUEQEGICCAAIAFyNgIAIAIMAQsgAigCCAshACACIAc2AgggACAHNgIMIAcgAjYCDCAHIAA2AggMBAtBHyEAIAdCADcCECAEQf///wdNBEAgBEEIdiIAIABBgP4/akEQdkEIcSICdCIAIABBgOAfakEQdkEEcSIBdCIAIABBgIAPakEQdkECcSIAdEEPdiABIAJyIAByayIAQQF0IAQgAEEVanZBAXFyQRxqIQALIAcgADYCHCAAQQJ0QbgKaiEDAkBBjAgoAgAiAkEBIAB0IgFxRQRAQYwIIAEgAnI2AgAgAyAHNgIAIAcgAzYCGAwBCyAEQQBBGSAAQQF2ayAAQR9GG3QhACADKAIAIQEDQCABIgIoAgRBeHEgBEYNBCAAQR12IQEgAEEBdCEAIAIgAUEEcWoiAygCECIBDQALIAMgBzYCECAHIAI2AhgLIAcgBzYCDCAHIAc2AggMAwsgAygCCCIAIAY2AgwgAyAGNgIIIAZBADYCGCAGIAM2AgwgBiAANgIICyAJQQhqIQAMBQsgAigCCCIAIAc2AgwgAiAHNgIIIAdBADYCGCAHIAI2AgwgByAANgIIC0GUCCgCACIAIAhNDQBBlAggACAIayIBNgIAQaAIQaAIKAIAIgIgCGoiADYCACAAIAFBAXI2AgQgAiAIQQNyNgIEIAJBCGohAAwDC0GECEEwNgIAQQAhAAwCCwJAIAVFDQACQCAEKAIcIgJBAnRBuApqIgAoAgAgBEYEQCAAIAE2AgAgAQ0BQYwIIAlBfiACd3EiCTYCAAwCCyAFQRBBFCAFKAIQIARGG2ogATYCACABRQ0BCyABIAU2AhggBCgCECIABEAgASAANgIQIAAgATYCGAsgBCgCFCIARQ0AIAEgADYCFCAAIAE2AhgLAkAgA0EPTQRAIAQgAyAIaiIAQQNyNgIEIAAgBGoiACAAKAIEQQFyNgIEDAELIAQgCEEDcjYCBCAGIANBAXI2AgQgAyAGaiADNgIAIANB/wFNBEAgA0EDdiIAQQN0QbAIaiECAn9BiAgoAgAiAUEBIAB0IgBxRQRAQYgIIAAgAXI2AgAgAgwBCyACKAIICyEAIAIgBjYCCCAAIAY2AgwgBiACNgIMIAYgADYCCAwBC0EfIQAgA0H///8HTQRAIANBCHYiACAAQYD+P2pBEHZBCHEiAnQiACAAQYDgH2pBEHZBBHEiAXQiACAAQYCAD2pBEHZBAnEiAHRBD3YgASACciAAcmsiAEEBdCADIABBFWp2QQFxckEcaiEACyAGIAA2AhwgBkIANwIQIABBAnRBuApqIQICQAJAIAlBASAAdCIBcUUEQEGMCCABIAlyNgIAIAIgBjYCACAGIAI2AhgMAQsgA0EAQRkgAEEBdmsgAEEfRht0IQAgAigCACEIA0AgCCIBKAIEQXhxIANGDQIgAEEddiECIABBAXQhACABIAJBBHFqIgIoAhAiCA0ACyACIAY2AhAgBiABNgIYCyAGIAY2AgwgBiAGNgIIDAELIAEoAggiACAGNgIMIAEgBjYCCCAGQQA2AhggBiABNgIMIAYgADYCCAsgBEEIaiEADAELAkAgC0UNAAJAIAEoAhwiAkECdEG4CmoiACgCACABRgRAIAAgBDYCACAEDQFBjAggBkF+IAJ3cTYCAAwCCyALQRBBFCALKAIQIAFGG2ogBDYCACAERQ0BCyAEIAs2AhggASgCECIABEAgBCAANgIQIAAgBDYCGAsgASgCFCIARQ0AIAQgADYCFCAAIAQ2AhgLAkAgA0EPTQRAIAEgAyAIaiIAQQNyNgIEIAAgAWoiACAAKAIEQQFyNgIEDAELIAEgCEEDcjYCBCAJIANBAXI2AgQgAyAJaiADNgIAIAoEQCAKQQN2IgBBA3RBsAhqIQRBnAgoAgAhAgJ/QQEgAHQiACAFcUUEQEGICCAAIAVyNgIAIAQMAQsgBCgCCAshACAEIAI2AgggACACNgIMIAIgBDYCDCACIAA2AggLQZwIIAk2AgBBkAggAzYCAAsgAUEIaiEACyAMQRBqJAAgAAsQACMAIABrQXBxIgAkACAACwYAIAAkAAsEACMAC4AJAgh/BH4jAEGQAWsiBiQAIAYgBS0AA0EYdEGAgIAYcSAFLwAAIAUtAAJBEHRycjYCACAGIAUoAANBAnZBg/7/H3E2AgQgBiAFKAAGQQR2Qf+B/x9xNgIIIAYgBSgACUEGdkH//8AfcTYCDCAFLwANIQggBS0ADyEJIAZCADcCFCAGQgA3AhwgBkEANgIkIAYgCCAJQRB0QYCAPHFyNgIQIAYgBSgAEDYCKCAGIAUoABQ2AiwgBiAFKAAYNgIwIAUoABwhBSAGQQA6AEwgBkEANgI4IAYgBTYCNCAGIAEgAhAEIAQEQCAGIAMgBBAECyAGKAI4IgEEQCAGQTxqIgIgAWpBAToAACABQQFqQQ9NBEAgASAGakE9aiEEAkBBDyABayIDRQ0AIAMgBGoiAUEBa0EAOgAAIARBADoAACADQQNJDQAgAUECa0EAOgAAIARBADoAASABQQNrQQA6AAAgBEEAOgACIANBB0kNACABQQRrQQA6AAAgBEEAOgADIANBCUkNACAEQQAgBGtBA3EiAWoiBEEANgIAIAQgAyABa0F8cSIBaiIDQQRrQQA2AgAgAUEJSQ0AIARBADYCCCAEQQA2AgQgA0EIa0EANgIAIANBDGtBADYCACABQRlJDQAgBEEANgIYIARBADYCFCAEQQA2AhAgBEEANgIMIANBEGtBADYCACADQRRrQQA2AgAgA0EYa0EANgIAIANBHGtBADYCACABIARBBHFBGHIiAWsiA0EgSQ0AIAEgBGohAQNAIAFCADcDGCABQgA3AxAgAUIANwMIIAFCADcDACABQSBqIQEgA0EgayIDQR9LDQALCwsgBkEBOgBMIAYgAkEQEAILIAY1AjQhECAGNQIwIREgBjUCLCEOIAAgBjUCKCAGKAIkIAYoAiAgBigCHCAGKAIYIgNBGnZqIgJBGnZqIgFBGnZqIgtBgICAYHIgAUH///8fcSINIAJB////H3EiCCAGKAIUIAtBGnZBBWxqIgFB////H3EiCUEFaiIFQRp2IANB////H3EgAUEadmoiA2oiAUEadmoiAkEadmoiBEEadmoiDEEfdSIHIANxIAEgDEEfdkEBayIDQf///x9xIgpxciIBQRp0IAUgCnEgByAJcXJyrXwiDzwAACAAIA9CGIg8AAMgACAPQhCIPAACIAAgD0IIiDwAASAAIA4gByAIcSACIApxciICQRR0IAFBBnZyrXwgD0IgiHwiDjwABCAAIA5CGIg8AAcgACAOQhCIPAAGIAAgDkIIiDwABSAAIBEgByANcSAEIApxciIBQQ50IAJBDHZyrXwgDkIgiHwiDjwACCAAIA5CGIg8AAsgACAOQhCIPAAKIAAgDkIIiDwACSAAIBAgAyAMcSAHIAtxckEIdCABQRJ2cq18IA5CIIh8Ig48AAwgACAOQhiIPAAPIAAgDkIQiDwADiAAIA5CCIg8AA0gBkIANwIwIAZCADcCKCAGQgA3AiAgBkIANwIYIAZCADcCECAGQgA3AgggBkIANwIAIAZBkAFqJAALpwwBB38CQCAARQ0AIABBCGsiAyAAQQRrKAIAIgFBeHEiAGohBQJAIAFBAXENACABQQNxRQ0BIAMgAygCACIBayIDQZgIKAIASQ0BIAAgAWohACADQZwIKAIARwRAIAFB/wFNBEAgAygCCCICIAFBA3YiBEEDdEGwCGpGGiACIAMoAgwiAUYEQEGICEGICCgCAEF+IAR3cTYCAAwDCyACIAE2AgwgASACNgIIDAILIAMoAhghBgJAIAMgAygCDCIBRwRAIAMoAggiAiABNgIMIAEgAjYCCAwBCwJAIANBFGoiAigCACIEDQAgA0EQaiICKAIAIgQNAEEAIQEMAQsDQCACIQcgBCIBQRRqIgIoAgAiBA0AIAFBEGohAiABKAIQIgQNAAsgB0EANgIACyAGRQ0BAkAgAyADKAIcIgJBAnRBuApqIgQoAgBGBEAgBCABNgIAIAENAUGMCEGMCCgCAEF+IAJ3cTYCAAwDCyAGQRBBFCAGKAIQIANGG2ogATYCACABRQ0CCyABIAY2AhggAygCECICBEAgASACNgIQIAIgATYCGAsgAygCFCICRQ0BIAEgAjYCFCACIAE2AhgMAQsgBSgCBCIBQQNxQQNHDQBBkAggADYCACAFIAFBfnE2AgQgAyAAQQFyNgIEIAAgA2ogADYCAA8LIAMgBU8NACAFKAIEIgFBAXFFDQACQCABQQJxRQRAIAVBoAgoAgBGBEBBoAggAzYCAEGUCEGUCCgCACAAaiIANgIAIAMgAEEBcjYCBCADQZwIKAIARw0DQZAIQQA2AgBBnAhBADYCAA8LIAVBnAgoAgBGBEBBnAggAzYCAEGQCEGQCCgCACAAaiIANgIAIAMgAEEBcjYCBCAAIANqIAA2AgAPCyABQXhxIABqIQACQCABQf8BTQRAIAUoAggiAiABQQN2IgRBA3RBsAhqRhogAiAFKAIMIgFGBEBBiAhBiAgoAgBBfiAEd3E2AgAMAgsgAiABNgIMIAEgAjYCCAwBCyAFKAIYIQYCQCAFIAUoAgwiAUcEQCAFKAIIIgJBmAgoAgBJGiACIAE2AgwgASACNgIIDAELAkAgBUEUaiICKAIAIgQNACAFQRBqIgIoAgAiBA0AQQAhAQwBCwNAIAIhByAEIgFBFGoiAigCACIEDQAgAUEQaiECIAEoAhAiBA0ACyAHQQA2AgALIAZFDQACQCAFIAUoAhwiAkECdEG4CmoiBCgCAEYEQCAEIAE2AgAgAQ0BQYwIQYwIKAIAQX4gAndxNgIADAILIAZBEEEUIAYoAhAgBUYbaiABNgIAIAFFDQELIAEgBjYCGCAFKAIQIgIEQCABIAI2AhAgAiABNgIYCyAFKAIUIgJFDQAgASACNgIUIAIgATYCGAsgAyAAQQFyNgIEIAAgA2ogADYCACADQZwIKAIARw0BQZAIIAA2AgAPCyAFIAFBfnE2AgQgAyAAQQFyNgIEIAAgA2ogADYCAAsgAEH/AU0EQCAAQQN2IgFBA3RBsAhqIQACf0GICCgCACICQQEgAXQiAXFFBEBBiAggASACcjYCACAADAELIAAoAggLIQIgACADNgIIIAIgAzYCDCADIAA2AgwgAyACNgIIDwtBHyECIANCADcCECAAQf///wdNBEAgAEEIdiIBIAFBgP4/akEQdkEIcSIBdCICIAJBgOAfakEQdkEEcSICdCIEIARBgIAPakEQdkECcSIEdEEPdiABIAJyIARyayIBQQF0IAAgAUEVanZBAXFyQRxqIQILIAMgAjYCHCACQQJ0QbgKaiEBAkACQAJAQYwIKAIAIgRBASACdCIHcUUEQEGMCCAEIAdyNgIAIAEgAzYCACADIAE2AhgMAQsgAEEAQRkgAkEBdmsgAkEfRht0IQIgASgCACEBA0AgASIEKAIEQXhxIABGDQIgAkEddiEBIAJBAXQhAiAEIAFBBHFqIgdBEGooAgAiAQ0ACyAHIAM2AhAgAyAENgIYCyADIAM2AgwgAyADNgIIDAELIAQoAggiACADNgIMIAQgAzYCCCADQQA2AhggAyAENgIMIAMgADYCCAtBqAhBqAgoAgBBAWsiAEF/IAAbNgIACwsLCQEAQYEICwIGUA==";
        if (!W.startsWith(V)) {
          var na = W;
          W = b.locateFile ? b.locateFile(na, B) : B + na;
        }
        function pa() {
          var a = W;
          try {
            if (a == W && J)
              return new Uint8Array(J);
            var c = H(a);
            if (c)
              return c;
            if (E)
              return E(a);
            throw "both async and sync fetching of the wasm failed";
          } catch (d) {
            K(d);
          }
        }
        function qa() {
          if (!J && (x || y)) {
            if (typeof fetch === "function" && !W.startsWith("file://"))
              return fetch(W, { credentials: "same-origin" }).then(function(a) {
                if (!a.ok)
                  throw "failed to load wasm binary file at '" + W + "'";
                return a.arrayBuffer();
              }).catch(function() {
                return pa();
              });
            if (D)
              return new Promise(function(a, c) {
                D(W, function(d) {
                  a(new Uint8Array(d));
                }, c);
              });
          }
          return Promise.resolve().then(function() {
            return pa();
          });
        }
        function X(a) {
          for (; 0 < a.length; ) {
            var c = a.shift();
            if (typeof c == "function")
              c(b);
            else {
              var d = c.m;
              typeof d === "number" ? c.l === void 0 ? R.get(d)() : R.get(d)(c.l) : d(c.l === void 0 ? null : c.l);
            }
          }
        }
        var ba = false, ra = typeof atob === "function" ? atob : function(a) {
          var c = "", d = 0;
          a = a.replace(/[^A-Za-z0-9\+\/=]/g, "");
          do {
            var e = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=".indexOf(a.charAt(d++));
            var f = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=".indexOf(a.charAt(d++));
            var l = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=".indexOf(a.charAt(d++));
            var A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=".indexOf(a.charAt(d++));
            e = e << 2 | f >> 4;
            f = (f & 15) << 4 | l >> 2;
            var t = (l & 3) << 6 | A;
            c += String.fromCharCode(e);
            l !== 64 && (c += String.fromCharCode(f));
            A !== 64 && (c += String.fromCharCode(t));
          } while (d < a.length);
          return c;
        };
        function H(a) {
          if (a.startsWith(V)) {
            a = a.slice(V.length);
            if (typeof z === "boolean" && z) {
              var c = Buffer.from(a, "base64");
              c = new Uint8Array(c.buffer, c.byteOffset, c.byteLength);
            } else
              try {
                var d = ra(a), e = new Uint8Array(d.length);
                for (a = 0; a < d.length; ++a)
                  e[a] = d.charCodeAt(a);
                c = e;
              } catch (f) {
                throw Error("Converting base64 string to bytes failed.");
              }
            return c;
          }
        }
        var sa = { a: function(a) {
          var c = P.length;
          a >>>= 0;
          if (2147483648 < a)
            return false;
          for (var d = 1; 4 >= d; d *= 2) {
            var e = c * (1 + 0.2 / d);
            e = Math.min(e, a + 100663296);
            e = Math.max(a, e);
            0 < e % 65536 && (e += 65536 - e % 65536);
            a: {
              try {
                L.grow(Math.min(2147483648, e) - ha.byteLength + 65535 >>> 16);
                ia();
                var f = 1;
                break a;
              } catch (l) {
              }
              f = void 0;
            }
            if (f)
              return true;
          }
          return false;
        } };
        (function() {
          function a(f) {
            b.asm = f.exports;
            L = b.asm.b;
            ia();
            R = b.asm.j;
            ka.unshift(b.asm.c);
            S--;
            b.monitorRunDependencies && b.monitorRunDependencies(S);
            S == 0 && (T !== null && (clearInterval(T), T = null), U && (f = U, U = null, f()));
          }
          function c(f) {
            a(f.instance);
          }
          function d(f) {
            return qa().then(function(l) {
              return WebAssembly.instantiate(l, e);
            }).then(f, function(l) {
              I("failed to asynchronously prepare wasm: " + l);
              K(l);
            });
          }
          var e = { a: sa };
          S++;
          b.monitorRunDependencies && b.monitorRunDependencies(S);
          if (b.instantiateWasm)
            try {
              return b.instantiateWasm(e, a);
            } catch (f) {
              return I("Module.instantiateWasm callback failed with error: " + f), false;
            }
          (function() {
            return J || typeof WebAssembly.instantiateStreaming !== "function" || W.startsWith(V) || W.startsWith("file://") || typeof fetch !== "function" ? d(c) : fetch(W, { credentials: "same-origin" }).then(function(f) {
              return WebAssembly.instantiateStreaming(f, e).then(c, function(l) {
                I("wasm streaming compile failed: " + l);
                I("falling back to ArrayBuffer instantiation");
                return d(c);
              });
            });
          })().catch(r);
          return {};
        })();
        b.___wasm_call_ctors = function() {
          return (b.___wasm_call_ctors = b.asm.c).apply(null, arguments);
        };
        b._poly1305_auth = function() {
          return (b._poly1305_auth = b.asm.d).apply(null, arguments);
        };
        var da = b.stackSave = function() {
          return (da = b.stackSave = b.asm.e).apply(null, arguments);
        }, fa = b.stackRestore = function() {
          return (fa = b.stackRestore = b.asm.f).apply(null, arguments);
        }, O = b.stackAlloc = function() {
          return (O = b.stackAlloc = b.asm.g).apply(null, arguments);
        };
        b._malloc = function() {
          return (b._malloc = b.asm.h).apply(null, arguments);
        };
        b._free = function() {
          return (b._free = b.asm.i).apply(null, arguments);
        };
        b.cwrap = function(a, c, d, e) {
          d = d || [];
          var f = d.every(function(l) {
            return l === "number";
          });
          return c !== "string" && f && !e ? N(a) : function() {
            return ca(a, c, d, arguments);
          };
        };
        var Y;
        U = function ta() {
          Y || Z();
          Y || (U = ta);
        };
        function Z() {
          function a() {
            if (!Y && (Y = true, b.calledRun = true, !M)) {
              X(ka);
              q(b);
              if (b.onRuntimeInitialized)
                b.onRuntimeInitialized();
              if (b.postRun)
                for (typeof b.postRun == "function" && (b.postRun = [b.postRun]); b.postRun.length; ) {
                  var c = b.postRun.shift();
                  la.unshift(c);
                }
              X(la);
            }
          }
          if (!(0 < S)) {
            if (b.preRun)
              for (typeof b.preRun == "function" && (b.preRun = [b.preRun]); b.preRun.length; )
                ma();
            X(ja);
            0 < S || (b.setStatus ? (b.setStatus("Running..."), setTimeout(function() {
              setTimeout(function() {
                b.setStatus("");
              }, 1);
              a();
            }, 1)) : a());
          }
        }
        b.run = Z;
        if (b.preInit)
          for (typeof b.preInit == "function" && (b.preInit = [b.preInit]); 0 < b.preInit.length; )
            b.preInit.pop()();
        Z();
        return createPoly13052.ready;
      };
    }();
    if (typeof exports === "object" && typeof module2 === "object")
      module2.exports = createPoly1305;
    else if (typeof define === "function" && define["amd"])
      define([], function() {
        return createPoly1305;
      });
    else if (typeof exports === "object")
      exports["createPoly1305"] = createPoly1305;
  }
});

// node_modules/ssh2/lib/protocol/crypto.js
var require_crypto = __commonJS({
  "node_modules/ssh2/lib/protocol/crypto.js"(exports, module2) {
    "use strict";
    var {
      createCipheriv,
      createDecipheriv,
      createHmac,
      randomFillSync,
      timingSafeEqual
    } = require("crypto");
    var { readUInt32BE, writeUInt32BE } = require_utils2();
    var FastBuffer = Buffer[Symbol.species];
    var MAX_SEQNO = 2 ** 32 - 1;
    var EMPTY_BUFFER = Buffer.alloc(0);
    var BUF_INT = Buffer.alloc(4);
    var DISCARD_CACHE = /* @__PURE__ */ new Map();
    var MAX_PACKET_SIZE = 35e3;
    var binding;
    var AESGCMCipher;
    var ChaChaPolyCipher;
    var GenericCipher;
    var AESGCMDecipher;
    var ChaChaPolyDecipher;
    var GenericDecipher;
    try {
      binding = require_sshcrypto();
      ({
        AESGCMCipher,
        ChaChaPolyCipher,
        GenericCipher,
        AESGCMDecipher,
        ChaChaPolyDecipher,
        GenericDecipher
      } = binding);
    } catch {
    }
    var CIPHER_STREAM = 1 << 0;
    var CIPHER_INFO = (() => {
      function info(sslName, blockLen, keyLen, ivLen, authLen, discardLen, flags) {
        return {
          sslName,
          blockLen,
          keyLen,
          ivLen: ivLen !== 0 || flags & CIPHER_STREAM ? ivLen : blockLen,
          authLen,
          discardLen,
          stream: !!(flags & CIPHER_STREAM)
        };
      }
      return {
        "chacha20-poly1305@openssh.com": info("chacha20", 8, 64, 0, 16, 0, CIPHER_STREAM),
        "aes128-gcm": info("aes-128-gcm", 16, 16, 12, 16, 0, CIPHER_STREAM),
        "aes256-gcm": info("aes-256-gcm", 16, 32, 12, 16, 0, CIPHER_STREAM),
        "aes128-gcm@openssh.com": info("aes-128-gcm", 16, 16, 12, 16, 0, CIPHER_STREAM),
        "aes256-gcm@openssh.com": info("aes-256-gcm", 16, 32, 12, 16, 0, CIPHER_STREAM),
        "aes128-cbc": info("aes-128-cbc", 16, 16, 0, 0, 0, 0),
        "aes192-cbc": info("aes-192-cbc", 16, 24, 0, 0, 0, 0),
        "aes256-cbc": info("aes-256-cbc", 16, 32, 0, 0, 0, 0),
        "rijndael-cbc@lysator.liu.se": info("aes-256-cbc", 16, 32, 0, 0, 0, 0),
        "3des-cbc": info("des-ede3-cbc", 8, 24, 0, 0, 0, 0),
        "blowfish-cbc": info("bf-cbc", 8, 16, 0, 0, 0, 0),
        "idea-cbc": info("idea-cbc", 8, 16, 0, 0, 0, 0),
        "cast128-cbc": info("cast-cbc", 8, 16, 0, 0, 0, 0),
        "aes128-ctr": info("aes-128-ctr", 16, 16, 16, 0, 0, CIPHER_STREAM),
        "aes192-ctr": info("aes-192-ctr", 16, 24, 16, 0, 0, CIPHER_STREAM),
        "aes256-ctr": info("aes-256-ctr", 16, 32, 16, 0, 0, CIPHER_STREAM),
        "3des-ctr": info("des-ede3", 8, 24, 8, 0, 0, CIPHER_STREAM),
        "blowfish-ctr": info("bf-ecb", 8, 16, 8, 0, 0, CIPHER_STREAM),
        "cast128-ctr": info("cast5-ecb", 8, 16, 8, 0, 0, CIPHER_STREAM),
        "arcfour": info("rc4", 8, 16, 0, 0, 1536, CIPHER_STREAM),
        "arcfour128": info("rc4", 8, 16, 0, 0, 1536, CIPHER_STREAM),
        "arcfour256": info("rc4", 8, 32, 0, 0, 1536, CIPHER_STREAM),
        "arcfour512": info("rc4", 8, 64, 0, 0, 1536, CIPHER_STREAM)
      };
    })();
    var MAC_INFO = (() => {
      function info(sslName, len, actualLen, isETM) {
        return {
          sslName,
          len,
          actualLen,
          isETM
        };
      }
      return {
        "hmac-md5": info("md5", 16, 16, false),
        "hmac-md5-96": info("md5", 16, 12, false),
        "hmac-ripemd160": info("ripemd160", 20, 20, false),
        "hmac-sha1": info("sha1", 20, 20, false),
        "hmac-sha1-etm@openssh.com": info("sha1", 20, 20, true),
        "hmac-sha1-96": info("sha1", 20, 12, false),
        "hmac-sha2-256": info("sha256", 32, 32, false),
        "hmac-sha2-256-etm@openssh.com": info("sha256", 32, 32, true),
        "hmac-sha2-256-96": info("sha256", 32, 12, false),
        "hmac-sha2-512": info("sha512", 64, 64, false),
        "hmac-sha2-512-etm@openssh.com": info("sha512", 64, 64, true),
        "hmac-sha2-512-96": info("sha512", 64, 12, false)
      };
    })();
    var NullCipher = class {
      constructor(seqno, onWrite) {
        this.outSeqno = seqno;
        this._onWrite = onWrite;
        this._dead = false;
      }
      free() {
        this._dead = true;
      }
      allocPacket(payloadLen) {
        let pktLen = 4 + 1 + payloadLen;
        let padLen = 8 - (pktLen & 8 - 1);
        if (padLen < 4)
          padLen += 8;
        pktLen += padLen;
        const packet = Buffer.allocUnsafe(pktLen);
        writeUInt32BE(packet, pktLen - 4, 0);
        packet[4] = padLen;
        randomFillSync(packet, 5 + payloadLen, padLen);
        return packet;
      }
      encrypt(packet) {
        if (this._dead)
          return;
        this._onWrite(packet);
        this.outSeqno = this.outSeqno + 1 >>> 0;
      }
    };
    var POLY1305_ZEROS = Buffer.alloc(32);
    var POLY1305_OUT_COMPUTE = Buffer.alloc(16);
    var POLY1305_WASM_MODULE;
    var POLY1305_RESULT_MALLOC;
    var poly1305_auth;
    var ChaChaPolyCipherNative = class {
      constructor(config) {
        const enc = config.outbound;
        this.outSeqno = enc.seqno;
        this._onWrite = enc.onWrite;
        this._encKeyMain = enc.cipherKey.slice(0, 32);
        this._encKeyPktLen = enc.cipherKey.slice(32);
        this._dead = false;
      }
      free() {
        this._dead = true;
      }
      allocPacket(payloadLen) {
        let pktLen = 4 + 1 + payloadLen;
        let padLen = 8 - (pktLen - 4 & 8 - 1);
        if (padLen < 4)
          padLen += 8;
        pktLen += padLen;
        const packet = Buffer.allocUnsafe(pktLen);
        writeUInt32BE(packet, pktLen - 4, 0);
        packet[4] = padLen;
        randomFillSync(packet, 5 + payloadLen, padLen);
        return packet;
      }
      encrypt(packet) {
        if (this._dead)
          return;
        POLY1305_OUT_COMPUTE[0] = 0;
        writeUInt32BE(POLY1305_OUT_COMPUTE, this.outSeqno, 12);
        const polyKey = createCipheriv("chacha20", this._encKeyMain, POLY1305_OUT_COMPUTE).update(POLY1305_ZEROS);
        const pktLenEnc = createCipheriv("chacha20", this._encKeyPktLen, POLY1305_OUT_COMPUTE).update(packet.slice(0, 4));
        this._onWrite(pktLenEnc);
        POLY1305_OUT_COMPUTE[0] = 1;
        const payloadEnc = createCipheriv("chacha20", this._encKeyMain, POLY1305_OUT_COMPUTE).update(packet.slice(4));
        this._onWrite(payloadEnc);
        poly1305_auth(POLY1305_RESULT_MALLOC, pktLenEnc, pktLenEnc.length, payloadEnc, payloadEnc.length, polyKey);
        const mac = Buffer.allocUnsafe(16);
        mac.set(new Uint8Array(POLY1305_WASM_MODULE.HEAPU8.buffer, POLY1305_RESULT_MALLOC, 16), 0);
        this._onWrite(mac);
        this.outSeqno = this.outSeqno + 1 >>> 0;
      }
    };
    var ChaChaPolyCipherBinding = class {
      constructor(config) {
        const enc = config.outbound;
        this.outSeqno = enc.seqno;
        this._onWrite = enc.onWrite;
        this._instance = new ChaChaPolyCipher(enc.cipherKey);
        this._dead = false;
      }
      free() {
        this._dead = true;
        this._instance.free();
      }
      allocPacket(payloadLen) {
        let pktLen = 4 + 1 + payloadLen;
        let padLen = 8 - (pktLen - 4 & 8 - 1);
        if (padLen < 4)
          padLen += 8;
        pktLen += padLen;
        const packet = Buffer.allocUnsafe(pktLen + 16);
        writeUInt32BE(packet, pktLen - 4, 0);
        packet[4] = padLen;
        randomFillSync(packet, 5 + payloadLen, padLen);
        return packet;
      }
      encrypt(packet) {
        if (this._dead)
          return;
        this._instance.encrypt(packet, this.outSeqno);
        this._onWrite(packet);
        this.outSeqno = this.outSeqno + 1 >>> 0;
      }
    };
    var AESGCMCipherNative = class {
      constructor(config) {
        const enc = config.outbound;
        this.outSeqno = enc.seqno;
        this._onWrite = enc.onWrite;
        this._encSSLName = enc.cipherInfo.sslName;
        this._encKey = enc.cipherKey;
        this._encIV = enc.cipherIV;
        this._dead = false;
      }
      free() {
        this._dead = true;
      }
      allocPacket(payloadLen) {
        let pktLen = 4 + 1 + payloadLen;
        let padLen = 16 - (pktLen - 4 & 16 - 1);
        if (padLen < 4)
          padLen += 16;
        pktLen += padLen;
        const packet = Buffer.allocUnsafe(pktLen);
        writeUInt32BE(packet, pktLen - 4, 0);
        packet[4] = padLen;
        randomFillSync(packet, 5 + payloadLen, padLen);
        return packet;
      }
      encrypt(packet) {
        if (this._dead)
          return;
        const cipher = createCipheriv(this._encSSLName, this._encKey, this._encIV);
        cipher.setAutoPadding(false);
        const lenData = packet.slice(0, 4);
        cipher.setAAD(lenData);
        this._onWrite(lenData);
        const encrypted = cipher.update(packet.slice(4));
        this._onWrite(encrypted);
        const final = cipher.final();
        if (final.length)
          this._onWrite(final);
        const tag = cipher.getAuthTag();
        this._onWrite(tag);
        ivIncrement(this._encIV);
        this.outSeqno = this.outSeqno + 1 >>> 0;
      }
    };
    var AESGCMCipherBinding = class {
      constructor(config) {
        const enc = config.outbound;
        this.outSeqno = enc.seqno;
        this._onWrite = enc.onWrite;
        this._instance = new AESGCMCipher(enc.cipherInfo.sslName, enc.cipherKey, enc.cipherIV);
        this._dead = false;
      }
      free() {
        this._dead = true;
        this._instance.free();
      }
      allocPacket(payloadLen) {
        let pktLen = 4 + 1 + payloadLen;
        let padLen = 16 - (pktLen - 4 & 16 - 1);
        if (padLen < 4)
          padLen += 16;
        pktLen += padLen;
        const packet = Buffer.allocUnsafe(pktLen + 16);
        writeUInt32BE(packet, pktLen - 4, 0);
        packet[4] = padLen;
        randomFillSync(packet, 5 + payloadLen, padLen);
        return packet;
      }
      encrypt(packet) {
        if (this._dead)
          return;
        this._instance.encrypt(packet);
        this._onWrite(packet);
        this.outSeqno = this.outSeqno + 1 >>> 0;
      }
    };
    var GenericCipherNative = class {
      constructor(config) {
        const enc = config.outbound;
        this.outSeqno = enc.seqno;
        this._onWrite = enc.onWrite;
        this._encBlockLen = enc.cipherInfo.blockLen;
        this._cipherInstance = createCipheriv(enc.cipherInfo.sslName, enc.cipherKey, enc.cipherIV);
        this._macSSLName = enc.macInfo.sslName;
        this._macKey = enc.macKey;
        this._macActualLen = enc.macInfo.actualLen;
        this._macETM = enc.macInfo.isETM;
        this._aadLen = this._macETM ? 4 : 0;
        this._dead = false;
        const discardLen = enc.cipherInfo.discardLen;
        if (discardLen) {
          let discard = DISCARD_CACHE.get(discardLen);
          if (discard === void 0) {
            discard = Buffer.alloc(discardLen);
            DISCARD_CACHE.set(discardLen, discard);
          }
          this._cipherInstance.update(discard);
        }
      }
      free() {
        this._dead = true;
      }
      allocPacket(payloadLen) {
        const blockLen = this._encBlockLen;
        let pktLen = 4 + 1 + payloadLen;
        let padLen = blockLen - (pktLen - this._aadLen & blockLen - 1);
        if (padLen < 4)
          padLen += blockLen;
        pktLen += padLen;
        const packet = Buffer.allocUnsafe(pktLen);
        writeUInt32BE(packet, pktLen - 4, 0);
        packet[4] = padLen;
        randomFillSync(packet, 5 + payloadLen, padLen);
        return packet;
      }
      encrypt(packet) {
        if (this._dead)
          return;
        let mac;
        if (this._macETM) {
          const lenBytes = new Uint8Array(packet.buffer, packet.byteOffset, 4);
          const encrypted = this._cipherInstance.update(new Uint8Array(packet.buffer, packet.byteOffset + 4, packet.length - 4));
          this._onWrite(lenBytes);
          this._onWrite(encrypted);
          mac = createHmac(this._macSSLName, this._macKey);
          writeUInt32BE(BUF_INT, this.outSeqno, 0);
          mac.update(BUF_INT);
          mac.update(lenBytes);
          mac.update(encrypted);
        } else {
          const encrypted = this._cipherInstance.update(packet);
          this._onWrite(encrypted);
          mac = createHmac(this._macSSLName, this._macKey);
          writeUInt32BE(BUF_INT, this.outSeqno, 0);
          mac.update(BUF_INT);
          mac.update(packet);
        }
        let digest = mac.digest();
        if (digest.length > this._macActualLen)
          digest = digest.slice(0, this._macActualLen);
        this._onWrite(digest);
        this.outSeqno = this.outSeqno + 1 >>> 0;
      }
    };
    var GenericCipherBinding = class {
      constructor(config) {
        const enc = config.outbound;
        this.outSeqno = enc.seqno;
        this._onWrite = enc.onWrite;
        this._encBlockLen = enc.cipherInfo.blockLen;
        this._macLen = enc.macInfo.len;
        this._macActualLen = enc.macInfo.actualLen;
        this._aadLen = enc.macInfo.isETM ? 4 : 0;
        this._instance = new GenericCipher(enc.cipherInfo.sslName, enc.cipherKey, enc.cipherIV, enc.macInfo.sslName, enc.macKey, enc.macInfo.isETM);
        this._dead = false;
      }
      free() {
        this._dead = true;
        this._instance.free();
      }
      allocPacket(payloadLen) {
        const blockLen = this._encBlockLen;
        let pktLen = 4 + 1 + payloadLen;
        let padLen = blockLen - (pktLen - this._aadLen & blockLen - 1);
        if (padLen < 4)
          padLen += blockLen;
        pktLen += padLen;
        const packet = Buffer.allocUnsafe(pktLen + this._macLen);
        writeUInt32BE(packet, pktLen - 4, 0);
        packet[4] = padLen;
        randomFillSync(packet, 5 + payloadLen, padLen);
        return packet;
      }
      encrypt(packet) {
        if (this._dead)
          return;
        this._instance.encrypt(packet, this.outSeqno);
        if (this._macActualLen < this._macLen) {
          packet = new FastBuffer(packet.buffer, packet.byteOffset, packet.length - (this._macLen - this._macActualLen));
        }
        this._onWrite(packet);
        this.outSeqno = this.outSeqno + 1 >>> 0;
      }
    };
    var NullDecipher = class {
      constructor(seqno, onPayload) {
        this.inSeqno = seqno;
        this._onPayload = onPayload;
        this._len = 0;
        this._lenBytes = 0;
        this._packet = null;
        this._packetPos = 0;
      }
      free() {
      }
      decrypt(data, p, dataLen) {
        while (p < dataLen) {
          if (this._lenBytes < 4) {
            let nb = Math.min(4 - this._lenBytes, dataLen - p);
            this._lenBytes += nb;
            while (nb--)
              this._len = (this._len << 8) + data[p++];
            if (this._lenBytes < 4)
              return;
            if (this._len > MAX_PACKET_SIZE || this._len < 8 || (4 + this._len & 7) !== 0) {
              throw new Error("Bad packet length");
            }
            if (p >= dataLen)
              return;
          }
          if (this._packetPos < this._len) {
            const nb = Math.min(this._len - this._packetPos, dataLen - p);
            let chunk;
            if (p !== 0 || nb !== dataLen)
              chunk = new Uint8Array(data.buffer, data.byteOffset + p, nb);
            else
              chunk = data;
            if (nb === this._len) {
              this._packet = chunk;
            } else {
              if (!this._packet)
                this._packet = Buffer.allocUnsafe(this._len);
              this._packet.set(chunk, this._packetPos);
            }
            p += nb;
            this._packetPos += nb;
            if (this._packetPos < this._len)
              return;
          }
          const payload = !this._packet ? EMPTY_BUFFER : new FastBuffer(this._packet.buffer, this._packet.byteOffset + 1, this._packet.length - this._packet[0] - 1);
          this.inSeqno = this.inSeqno + 1 >>> 0;
          this._len = 0;
          this._lenBytes = 0;
          this._packet = null;
          this._packetPos = 0;
          {
            const ret = this._onPayload(payload);
            if (ret !== void 0)
              return ret === false ? p : ret;
          }
        }
      }
    };
    var ChaChaPolyDecipherNative = class {
      constructor(config) {
        const dec = config.inbound;
        this.inSeqno = dec.seqno;
        this._onPayload = dec.onPayload;
        this._decKeyMain = dec.decipherKey.slice(0, 32);
        this._decKeyPktLen = dec.decipherKey.slice(32);
        this._len = 0;
        this._lenBuf = Buffer.alloc(4);
        this._lenPos = 0;
        this._packet = null;
        this._pktLen = 0;
        this._mac = Buffer.allocUnsafe(16);
        this._calcMac = Buffer.allocUnsafe(16);
        this._macPos = 0;
      }
      free() {
      }
      decrypt(data, p, dataLen) {
        while (p < dataLen) {
          if (this._lenPos < 4) {
            let nb = Math.min(4 - this._lenPos, dataLen - p);
            while (nb--)
              this._lenBuf[this._lenPos++] = data[p++];
            if (this._lenPos < 4)
              return;
            POLY1305_OUT_COMPUTE[0] = 0;
            writeUInt32BE(POLY1305_OUT_COMPUTE, this.inSeqno, 12);
            const decLenBytes = createDecipheriv("chacha20", this._decKeyPktLen, POLY1305_OUT_COMPUTE).update(this._lenBuf);
            this._len = readUInt32BE(decLenBytes, 0);
            if (this._len > MAX_PACKET_SIZE || this._len < 8 || (this._len & 7) !== 0) {
              throw new Error("Bad packet length");
            }
          }
          if (this._pktLen < this._len) {
            if (p >= dataLen)
              return;
            const nb = Math.min(this._len - this._pktLen, dataLen - p);
            let encrypted;
            if (p !== 0 || nb !== dataLen)
              encrypted = new Uint8Array(data.buffer, data.byteOffset + p, nb);
            else
              encrypted = data;
            if (nb === this._len) {
              this._packet = encrypted;
            } else {
              if (!this._packet)
                this._packet = Buffer.allocUnsafe(this._len);
              this._packet.set(encrypted, this._pktLen);
            }
            p += nb;
            this._pktLen += nb;
            if (this._pktLen < this._len || p >= dataLen)
              return;
          }
          {
            const nb = Math.min(16 - this._macPos, dataLen - p);
            if (p !== 0 || nb !== dataLen) {
              this._mac.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._macPos);
            } else {
              this._mac.set(data, this._macPos);
            }
            p += nb;
            this._macPos += nb;
            if (this._macPos < 16)
              return;
          }
          POLY1305_OUT_COMPUTE[0] = 0;
          writeUInt32BE(POLY1305_OUT_COMPUTE, this.inSeqno, 12);
          const polyKey = createCipheriv("chacha20", this._decKeyMain, POLY1305_OUT_COMPUTE).update(POLY1305_ZEROS);
          poly1305_auth(POLY1305_RESULT_MALLOC, this._lenBuf, 4, this._packet, this._packet.length, polyKey);
          this._calcMac.set(new Uint8Array(POLY1305_WASM_MODULE.HEAPU8.buffer, POLY1305_RESULT_MALLOC, 16), 0);
          if (!timingSafeEqual(this._calcMac, this._mac))
            throw new Error("Invalid MAC");
          POLY1305_OUT_COMPUTE[0] = 1;
          const packet = createDecipheriv("chacha20", this._decKeyMain, POLY1305_OUT_COMPUTE).update(this._packet);
          const payload = new FastBuffer(packet.buffer, packet.byteOffset + 1, packet.length - packet[0] - 1);
          this.inSeqno = this.inSeqno + 1 >>> 0;
          this._len = 0;
          this._lenPos = 0;
          this._packet = null;
          this._pktLen = 0;
          this._macPos = 0;
          {
            const ret = this._onPayload(payload);
            if (ret !== void 0)
              return ret === false ? p : ret;
          }
        }
      }
    };
    var ChaChaPolyDecipherBinding = class {
      constructor(config) {
        const dec = config.inbound;
        this.inSeqno = dec.seqno;
        this._onPayload = dec.onPayload;
        this._instance = new ChaChaPolyDecipher(dec.decipherKey);
        this._len = 0;
        this._lenBuf = Buffer.alloc(4);
        this._lenPos = 0;
        this._packet = null;
        this._pktLen = 0;
        this._mac = Buffer.allocUnsafe(16);
        this._macPos = 0;
      }
      free() {
        this._instance.free();
      }
      decrypt(data, p, dataLen) {
        while (p < dataLen) {
          if (this._lenPos < 4) {
            let nb = Math.min(4 - this._lenPos, dataLen - p);
            while (nb--)
              this._lenBuf[this._lenPos++] = data[p++];
            if (this._lenPos < 4)
              return;
            this._len = this._instance.decryptLen(this._lenBuf, this.inSeqno);
            if (this._len > MAX_PACKET_SIZE || this._len < 8 || (this._len & 7) !== 0) {
              throw new Error("Bad packet length");
            }
            if (p >= dataLen)
              return;
          }
          if (this._pktLen < this._len) {
            const nb = Math.min(this._len - this._pktLen, dataLen - p);
            let encrypted;
            if (p !== 0 || nb !== dataLen)
              encrypted = new Uint8Array(data.buffer, data.byteOffset + p, nb);
            else
              encrypted = data;
            if (nb === this._len) {
              this._packet = encrypted;
            } else {
              if (!this._packet)
                this._packet = Buffer.allocUnsafe(this._len);
              this._packet.set(encrypted, this._pktLen);
            }
            p += nb;
            this._pktLen += nb;
            if (this._pktLen < this._len || p >= dataLen)
              return;
          }
          {
            const nb = Math.min(16 - this._macPos, dataLen - p);
            if (p !== 0 || nb !== dataLen) {
              this._mac.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._macPos);
            } else {
              this._mac.set(data, this._macPos);
            }
            p += nb;
            this._macPos += nb;
            if (this._macPos < 16)
              return;
          }
          this._instance.decrypt(this._packet, this._mac, this.inSeqno);
          const payload = new FastBuffer(this._packet.buffer, this._packet.byteOffset + 1, this._packet.length - this._packet[0] - 1);
          this.inSeqno = this.inSeqno + 1 >>> 0;
          this._len = 0;
          this._lenPos = 0;
          this._packet = null;
          this._pktLen = 0;
          this._macPos = 0;
          {
            const ret = this._onPayload(payload);
            if (ret !== void 0)
              return ret === false ? p : ret;
          }
        }
      }
    };
    var AESGCMDecipherNative = class {
      constructor(config) {
        const dec = config.inbound;
        this.inSeqno = dec.seqno;
        this._onPayload = dec.onPayload;
        this._decipherInstance = null;
        this._decipherSSLName = dec.decipherInfo.sslName;
        this._decipherKey = dec.decipherKey;
        this._decipherIV = dec.decipherIV;
        this._len = 0;
        this._lenBytes = 0;
        this._packet = null;
        this._packetPos = 0;
        this._pktLen = 0;
        this._tag = Buffer.allocUnsafe(16);
        this._tagPos = 0;
      }
      free() {
      }
      decrypt(data, p, dataLen) {
        while (p < dataLen) {
          if (this._lenBytes < 4) {
            let nb = Math.min(4 - this._lenBytes, dataLen - p);
            this._lenBytes += nb;
            while (nb--)
              this._len = (this._len << 8) + data[p++];
            if (this._lenBytes < 4)
              return;
            if (this._len + 20 > MAX_PACKET_SIZE || this._len < 16 || (this._len & 15) !== 0) {
              throw new Error("Bad packet length");
            }
            this._decipherInstance = createDecipheriv(this._decipherSSLName, this._decipherKey, this._decipherIV);
            this._decipherInstance.setAutoPadding(false);
            this._decipherInstance.setAAD(intToBytes(this._len));
          }
          if (this._pktLen < this._len) {
            if (p >= dataLen)
              return;
            const nb = Math.min(this._len - this._pktLen, dataLen - p);
            let decrypted;
            if (p !== 0 || nb !== dataLen) {
              decrypted = this._decipherInstance.update(new Uint8Array(data.buffer, data.byteOffset + p, nb));
            } else {
              decrypted = this._decipherInstance.update(data);
            }
            if (decrypted.length) {
              if (nb === this._len) {
                this._packet = decrypted;
              } else {
                if (!this._packet)
                  this._packet = Buffer.allocUnsafe(this._len);
                this._packet.set(decrypted, this._packetPos);
              }
              this._packetPos += decrypted.length;
            }
            p += nb;
            this._pktLen += nb;
            if (this._pktLen < this._len || p >= dataLen)
              return;
          }
          {
            const nb = Math.min(16 - this._tagPos, dataLen - p);
            if (p !== 0 || nb !== dataLen) {
              this._tag.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._tagPos);
            } else {
              this._tag.set(data, this._tagPos);
            }
            p += nb;
            this._tagPos += nb;
            if (this._tagPos < 16)
              return;
          }
          {
            this._decipherInstance.setAuthTag(this._tag);
            const decrypted = this._decipherInstance.final();
            if (decrypted.length) {
              if (this._packet)
                this._packet.set(decrypted, this._packetPos);
              else
                this._packet = decrypted;
            }
          }
          const payload = !this._packet ? EMPTY_BUFFER : new FastBuffer(this._packet.buffer, this._packet.byteOffset + 1, this._packet.length - this._packet[0] - 1);
          this.inSeqno = this.inSeqno + 1 >>> 0;
          ivIncrement(this._decipherIV);
          this._len = 0;
          this._lenBytes = 0;
          this._packet = null;
          this._packetPos = 0;
          this._pktLen = 0;
          this._tagPos = 0;
          {
            const ret = this._onPayload(payload);
            if (ret !== void 0)
              return ret === false ? p : ret;
          }
        }
      }
    };
    var AESGCMDecipherBinding = class {
      constructor(config) {
        const dec = config.inbound;
        this.inSeqno = dec.seqno;
        this._onPayload = dec.onPayload;
        this._instance = new AESGCMDecipher(dec.decipherInfo.sslName, dec.decipherKey, dec.decipherIV);
        this._len = 0;
        this._lenBytes = 0;
        this._packet = null;
        this._pktLen = 0;
        this._tag = Buffer.allocUnsafe(16);
        this._tagPos = 0;
      }
      free() {
      }
      decrypt(data, p, dataLen) {
        while (p < dataLen) {
          if (this._lenBytes < 4) {
            let nb = Math.min(4 - this._lenBytes, dataLen - p);
            this._lenBytes += nb;
            while (nb--)
              this._len = (this._len << 8) + data[p++];
            if (this._lenBytes < 4)
              return;
            if (this._len + 20 > MAX_PACKET_SIZE || this._len < 16 || (this._len & 15) !== 0) {
              throw new Error(`Bad packet length: ${this._len}`);
            }
          }
          if (this._pktLen < this._len) {
            if (p >= dataLen)
              return;
            const nb = Math.min(this._len - this._pktLen, dataLen - p);
            let encrypted;
            if (p !== 0 || nb !== dataLen)
              encrypted = new Uint8Array(data.buffer, data.byteOffset + p, nb);
            else
              encrypted = data;
            if (nb === this._len) {
              this._packet = encrypted;
            } else {
              if (!this._packet)
                this._packet = Buffer.allocUnsafe(this._len);
              this._packet.set(encrypted, this._pktLen);
            }
            p += nb;
            this._pktLen += nb;
            if (this._pktLen < this._len || p >= dataLen)
              return;
          }
          {
            const nb = Math.min(16 - this._tagPos, dataLen - p);
            if (p !== 0 || nb !== dataLen) {
              this._tag.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._tagPos);
            } else {
              this._tag.set(data, this._tagPos);
            }
            p += nb;
            this._tagPos += nb;
            if (this._tagPos < 16)
              return;
          }
          this._instance.decrypt(this._packet, this._len, this._tag);
          const payload = new FastBuffer(this._packet.buffer, this._packet.byteOffset + 1, this._packet.length - this._packet[0] - 1);
          this.inSeqno = this.inSeqno + 1 >>> 0;
          this._len = 0;
          this._lenBytes = 0;
          this._packet = null;
          this._pktLen = 0;
          this._tagPos = 0;
          {
            const ret = this._onPayload(payload);
            if (ret !== void 0)
              return ret === false ? p : ret;
          }
        }
      }
    };
    var GenericDecipherNative = class {
      constructor(config) {
        const dec = config.inbound;
        this.inSeqno = dec.seqno;
        this._onPayload = dec.onPayload;
        this._decipherInstance = createDecipheriv(dec.decipherInfo.sslName, dec.decipherKey, dec.decipherIV);
        this._decipherInstance.setAutoPadding(false);
        this._block = Buffer.allocUnsafe(dec.macInfo.isETM ? 4 : dec.decipherInfo.blockLen);
        this._blockSize = dec.decipherInfo.blockLen;
        this._blockPos = 0;
        this._len = 0;
        this._packet = null;
        this._packetPos = 0;
        this._pktLen = 0;
        this._mac = Buffer.allocUnsafe(dec.macInfo.actualLen);
        this._macPos = 0;
        this._macSSLName = dec.macInfo.sslName;
        this._macKey = dec.macKey;
        this._macActualLen = dec.macInfo.actualLen;
        this._macETM = dec.macInfo.isETM;
        this._macInstance = null;
        const discardLen = dec.decipherInfo.discardLen;
        if (discardLen) {
          let discard = DISCARD_CACHE.get(discardLen);
          if (discard === void 0) {
            discard = Buffer.alloc(discardLen);
            DISCARD_CACHE.set(discardLen, discard);
          }
          this._decipherInstance.update(discard);
        }
      }
      free() {
      }
      decrypt(data, p, dataLen) {
        while (p < dataLen) {
          if (this._blockPos < this._block.length) {
            const nb = Math.min(this._block.length - this._blockPos, dataLen - p);
            if (p !== 0 || nb !== dataLen || nb < data.length) {
              this._block.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._blockPos);
            } else {
              this._block.set(data, this._blockPos);
            }
            p += nb;
            this._blockPos += nb;
            if (this._blockPos < this._block.length)
              return;
            let decrypted;
            let need;
            if (this._macETM) {
              this._len = need = readUInt32BE(this._block, 0);
            } else {
              decrypted = this._decipherInstance.update(this._block);
              this._len = readUInt32BE(decrypted, 0);
              need = 4 + this._len - this._blockSize;
            }
            if (this._len > MAX_PACKET_SIZE || this._len < 5 || (need & this._blockSize - 1) !== 0) {
              throw new Error("Bad packet length");
            }
            this._macInstance = createHmac(this._macSSLName, this._macKey);
            writeUInt32BE(BUF_INT, this.inSeqno, 0);
            this._macInstance.update(BUF_INT);
            if (this._macETM) {
              this._macInstance.update(this._block);
            } else {
              this._macInstance.update(new Uint8Array(decrypted.buffer, decrypted.byteOffset, 4));
              this._pktLen = decrypted.length - 4;
              this._packetPos = this._pktLen;
              this._packet = Buffer.allocUnsafe(this._len);
              this._packet.set(new Uint8Array(decrypted.buffer, decrypted.byteOffset + 4, this._packetPos), 0);
            }
            if (p >= dataLen)
              return;
          }
          if (this._pktLen < this._len) {
            const nb = Math.min(this._len - this._pktLen, dataLen - p);
            let encrypted;
            if (p !== 0 || nb !== dataLen)
              encrypted = new Uint8Array(data.buffer, data.byteOffset + p, nb);
            else
              encrypted = data;
            if (this._macETM)
              this._macInstance.update(encrypted);
            const decrypted = this._decipherInstance.update(encrypted);
            if (decrypted.length) {
              if (nb === this._len) {
                this._packet = decrypted;
              } else {
                if (!this._packet)
                  this._packet = Buffer.allocUnsafe(this._len);
                this._packet.set(decrypted, this._packetPos);
              }
              this._packetPos += decrypted.length;
            }
            p += nb;
            this._pktLen += nb;
            if (this._pktLen < this._len || p >= dataLen)
              return;
          }
          {
            const nb = Math.min(this._macActualLen - this._macPos, dataLen - p);
            if (p !== 0 || nb !== dataLen) {
              this._mac.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._macPos);
            } else {
              this._mac.set(data, this._macPos);
            }
            p += nb;
            this._macPos += nb;
            if (this._macPos < this._macActualLen)
              return;
          }
          if (!this._macETM)
            this._macInstance.update(this._packet);
          let calculated = this._macInstance.digest();
          if (this._macActualLen < calculated.length) {
            calculated = new Uint8Array(calculated.buffer, calculated.byteOffset, this._macActualLen);
          }
          if (!timingSafeEquals(calculated, this._mac))
            throw new Error("Invalid MAC");
          const payload = new FastBuffer(this._packet.buffer, this._packet.byteOffset + 1, this._packet.length - this._packet[0] - 1);
          this.inSeqno = this.inSeqno + 1 >>> 0;
          this._blockPos = 0;
          this._len = 0;
          this._packet = null;
          this._packetPos = 0;
          this._pktLen = 0;
          this._macPos = 0;
          this._macInstance = null;
          {
            const ret = this._onPayload(payload);
            if (ret !== void 0)
              return ret === false ? p : ret;
          }
        }
      }
    };
    var GenericDecipherBinding = class {
      constructor(config) {
        const dec = config.inbound;
        this.inSeqno = dec.seqno;
        this._onPayload = dec.onPayload;
        this._instance = new GenericDecipher(dec.decipherInfo.sslName, dec.decipherKey, dec.decipherIV, dec.macInfo.sslName, dec.macKey, dec.macInfo.isETM, dec.macInfo.actualLen);
        this._block = Buffer.allocUnsafe(dec.macInfo.isETM || dec.decipherInfo.stream ? 4 : dec.decipherInfo.blockLen);
        this._blockPos = 0;
        this._len = 0;
        this._packet = null;
        this._pktLen = 0;
        this._mac = Buffer.allocUnsafe(dec.macInfo.actualLen);
        this._macPos = 0;
        this._macActualLen = dec.macInfo.actualLen;
        this._macETM = dec.macInfo.isETM;
      }
      free() {
        this._instance.free();
      }
      decrypt(data, p, dataLen) {
        while (p < dataLen) {
          if (this._blockPos < this._block.length) {
            const nb = Math.min(this._block.length - this._blockPos, dataLen - p);
            if (p !== 0 || nb !== dataLen || nb < data.length) {
              this._block.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._blockPos);
            } else {
              this._block.set(data, this._blockPos);
            }
            p += nb;
            this._blockPos += nb;
            if (this._blockPos < this._block.length)
              return;
            let need;
            if (this._macETM) {
              this._len = need = readUInt32BE(this._block, 0);
            } else {
              this._instance.decryptBlock(this._block);
              this._len = readUInt32BE(this._block, 0);
              need = 4 + this._len - this._block.length;
            }
            if (this._len > MAX_PACKET_SIZE || this._len < 5 || (need & this._block.length - 1) !== 0) {
              throw new Error("Bad packet length");
            }
            if (!this._macETM) {
              this._pktLen = this._block.length - 4;
              if (this._pktLen) {
                this._packet = Buffer.allocUnsafe(this._len);
                this._packet.set(new Uint8Array(this._block.buffer, this._block.byteOffset + 4, this._pktLen), 0);
              }
            }
            if (p >= dataLen)
              return;
          }
          if (this._pktLen < this._len) {
            const nb = Math.min(this._len - this._pktLen, dataLen - p);
            let encrypted;
            if (p !== 0 || nb !== dataLen)
              encrypted = new Uint8Array(data.buffer, data.byteOffset + p, nb);
            else
              encrypted = data;
            if (nb === this._len) {
              this._packet = encrypted;
            } else {
              if (!this._packet)
                this._packet = Buffer.allocUnsafe(this._len);
              this._packet.set(encrypted, this._pktLen);
            }
            p += nb;
            this._pktLen += nb;
            if (this._pktLen < this._len || p >= dataLen)
              return;
          }
          {
            const nb = Math.min(this._macActualLen - this._macPos, dataLen - p);
            if (p !== 0 || nb !== dataLen) {
              this._mac.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._macPos);
            } else {
              this._mac.set(data, this._macPos);
            }
            p += nb;
            this._macPos += nb;
            if (this._macPos < this._macActualLen)
              return;
          }
          this._instance.decrypt(this._packet, this.inSeqno, this._block, this._mac);
          const payload = new FastBuffer(this._packet.buffer, this._packet.byteOffset + 1, this._packet.length - this._packet[0] - 1);
          this.inSeqno = this.inSeqno + 1 >>> 0;
          this._blockPos = 0;
          this._len = 0;
          this._packet = null;
          this._pktLen = 0;
          this._macPos = 0;
          this._macInstance = null;
          {
            const ret = this._onPayload(payload);
            if (ret !== void 0)
              return ret === false ? p : ret;
          }
        }
      }
    };
    function ivIncrement(iv) {
      ++iv[11] >>> 8 && ++iv[10] >>> 8 && ++iv[9] >>> 8 && ++iv[8] >>> 8 && ++iv[7] >>> 8 && ++iv[6] >>> 8 && ++iv[5] >>> 8 && ++iv[4] >>> 8;
    }
    var intToBytes = (() => {
      const ret = Buffer.alloc(4);
      return (n) => {
        ret[0] = n >>> 24;
        ret[1] = n >>> 16;
        ret[2] = n >>> 8;
        ret[3] = n;
        return ret;
      };
    })();
    function timingSafeEquals(a, b) {
      if (a.length !== b.length) {
        timingSafeEqual(a, a);
        return false;
      }
      return timingSafeEqual(a, b);
    }
    function createCipher(config) {
      if (typeof config !== "object" || config === null)
        throw new Error("Invalid config");
      if (typeof config.outbound !== "object" || config.outbound === null)
        throw new Error("Invalid outbound");
      const outbound = config.outbound;
      if (typeof outbound.onWrite !== "function")
        throw new Error("Invalid outbound.onWrite");
      if (typeof outbound.cipherInfo !== "object" || outbound.cipherInfo === null)
        throw new Error("Invalid outbound.cipherInfo");
      if (!Buffer.isBuffer(outbound.cipherKey) || outbound.cipherKey.length !== outbound.cipherInfo.keyLen) {
        throw new Error("Invalid outbound.cipherKey");
      }
      if (outbound.cipherInfo.ivLen && (!Buffer.isBuffer(outbound.cipherIV) || outbound.cipherIV.length !== outbound.cipherInfo.ivLen)) {
        throw new Error("Invalid outbound.cipherIV");
      }
      if (typeof outbound.seqno !== "number" || outbound.seqno < 0 || outbound.seqno > MAX_SEQNO) {
        throw new Error("Invalid outbound.seqno");
      }
      const forceNative = !!outbound.forceNative;
      switch (outbound.cipherInfo.sslName) {
        case "aes-128-gcm":
        case "aes-256-gcm":
          return AESGCMCipher && !forceNative ? new AESGCMCipherBinding(config) : new AESGCMCipherNative(config);
        case "chacha20":
          return ChaChaPolyCipher && !forceNative ? new ChaChaPolyCipherBinding(config) : new ChaChaPolyCipherNative(config);
        default: {
          if (typeof outbound.macInfo !== "object" || outbound.macInfo === null)
            throw new Error("Invalid outbound.macInfo");
          if (!Buffer.isBuffer(outbound.macKey) || outbound.macKey.length !== outbound.macInfo.len) {
            throw new Error("Invalid outbound.macKey");
          }
          return GenericCipher && !forceNative ? new GenericCipherBinding(config) : new GenericCipherNative(config);
        }
      }
    }
    function createDecipher(config) {
      if (typeof config !== "object" || config === null)
        throw new Error("Invalid config");
      if (typeof config.inbound !== "object" || config.inbound === null)
        throw new Error("Invalid inbound");
      const inbound = config.inbound;
      if (typeof inbound.onPayload !== "function")
        throw new Error("Invalid inbound.onPayload");
      if (typeof inbound.decipherInfo !== "object" || inbound.decipherInfo === null) {
        throw new Error("Invalid inbound.decipherInfo");
      }
      if (!Buffer.isBuffer(inbound.decipherKey) || inbound.decipherKey.length !== inbound.decipherInfo.keyLen) {
        throw new Error("Invalid inbound.decipherKey");
      }
      if (inbound.decipherInfo.ivLen && (!Buffer.isBuffer(inbound.decipherIV) || inbound.decipherIV.length !== inbound.decipherInfo.ivLen)) {
        throw new Error("Invalid inbound.decipherIV");
      }
      if (typeof inbound.seqno !== "number" || inbound.seqno < 0 || inbound.seqno > MAX_SEQNO) {
        throw new Error("Invalid inbound.seqno");
      }
      const forceNative = !!inbound.forceNative;
      switch (inbound.decipherInfo.sslName) {
        case "aes-128-gcm":
        case "aes-256-gcm":
          return AESGCMDecipher && !forceNative ? new AESGCMDecipherBinding(config) : new AESGCMDecipherNative(config);
        case "chacha20":
          return ChaChaPolyDecipher && !forceNative ? new ChaChaPolyDecipherBinding(config) : new ChaChaPolyDecipherNative(config);
        default: {
          if (typeof inbound.macInfo !== "object" || inbound.macInfo === null)
            throw new Error("Invalid inbound.macInfo");
          if (!Buffer.isBuffer(inbound.macKey) || inbound.macKey.length !== inbound.macInfo.len) {
            throw new Error("Invalid inbound.macKey");
          }
          return GenericDecipher && !forceNative ? new GenericDecipherBinding(config) : new GenericDecipherNative(config);
        }
      }
    }
    module2.exports = {
      CIPHER_INFO,
      MAC_INFO,
      bindingAvailable: !!binding,
      init: (() => {
        return new Promise(async (resolve, reject) => {
          try {
            POLY1305_WASM_MODULE = await require_poly1305()();
            POLY1305_RESULT_MALLOC = POLY1305_WASM_MODULE._malloc(16);
            poly1305_auth = POLY1305_WASM_MODULE.cwrap("poly1305_auth", null, ["number", "array", "number", "array", "number", "array"]);
          } catch (ex) {
            return reject(ex);
          }
          resolve();
        });
      })(),
      NullCipher,
      createCipher,
      NullDecipher,
      createDecipher
    };
  }
});

// node_modules/ssh2/lib/protocol/keyParser.js
var require_keyParser = __commonJS({
  "node_modules/ssh2/lib/protocol/keyParser.js"(exports, module2) {
    "use strict";
    var {
      createDecipheriv,
      createECDH,
      createHash,
      createHmac,
      createSign,
      createVerify,
      getCiphers,
      sign: sign_,
      verify: verify_
    } = require("crypto");
    var supportedOpenSSLCiphers = getCiphers();
    var { Ber } = require_lib();
    var bcrypt_pbkdf = require_bcrypt_pbkdf().pbkdf;
    var { CIPHER_INFO } = require_crypto();
    var { eddsaSupported, SUPPORTED_CIPHER } = require_constants();
    var {
      bufferSlice,
      makeBufferParser,
      readString,
      readUInt32BE,
      writeUInt32BE
    } = require_utils2();
    var SYM_HASH_ALGO = Symbol("Hash Algorithm");
    var SYM_PRIV_PEM = Symbol("Private key PEM");
    var SYM_PUB_PEM = Symbol("Public key PEM");
    var SYM_PUB_SSH = Symbol("Public key SSH");
    var SYM_DECRYPTED = Symbol("Decrypted Key");
    var CIPHER_INFO_OPENSSL = /* @__PURE__ */ Object.create(null);
    {
      const keys = Object.keys(CIPHER_INFO);
      for (let i = 0; i < keys.length; ++i) {
        const cipherName = CIPHER_INFO[keys[i]].sslName;
        if (!cipherName || CIPHER_INFO_OPENSSL[cipherName])
          continue;
        CIPHER_INFO_OPENSSL[cipherName] = CIPHER_INFO[keys[i]];
      }
    }
    var binaryKeyParser = makeBufferParser();
    function makePEM(type, data) {
      data = data.base64Slice(0, data.length);
      let formatted = data.replace(/.{64}/g, "$&\n");
      if (data.length & 63)
        formatted += "\n";
      return `-----BEGIN ${type} KEY-----
${formatted}-----END ${type} KEY-----`;
    }
    function combineBuffers(buf1, buf2) {
      const result = Buffer.allocUnsafe(buf1.length + buf2.length);
      result.set(buf1, 0);
      result.set(buf2, buf1.length);
      return result;
    }
    function skipFields(buf, nfields) {
      const bufLen = buf.length;
      let pos = buf._pos || 0;
      for (let i = 0; i < nfields; ++i) {
        const left = bufLen - pos;
        if (pos >= bufLen || left < 4)
          return false;
        const len = readUInt32BE(buf, pos);
        if (left < 4 + len)
          return false;
        pos += 4 + len;
      }
      buf._pos = pos;
      return true;
    }
    function genOpenSSLRSAPub(n, e) {
      const asnWriter = new Ber.Writer();
      asnWriter.startSequence();
      asnWriter.startSequence();
      asnWriter.writeOID("1.2.840.113549.1.1.1");
      asnWriter.writeNull();
      asnWriter.endSequence();
      asnWriter.startSequence(Ber.BitString);
      asnWriter.writeByte(0);
      asnWriter.startSequence();
      asnWriter.writeBuffer(n, Ber.Integer);
      asnWriter.writeBuffer(e, Ber.Integer);
      asnWriter.endSequence();
      asnWriter.endSequence();
      asnWriter.endSequence();
      return makePEM("PUBLIC", asnWriter.buffer);
    }
    function genOpenSSHRSAPub(n, e) {
      const publicKey = Buffer.allocUnsafe(4 + 7 + 4 + e.length + 4 + n.length);
      writeUInt32BE(publicKey, 7, 0);
      publicKey.utf8Write("ssh-rsa", 4, 7);
      let i = 4 + 7;
      writeUInt32BE(publicKey, e.length, i);
      publicKey.set(e, i += 4);
      writeUInt32BE(publicKey, n.length, i += e.length);
      publicKey.set(n, i + 4);
      return publicKey;
    }
    var genOpenSSLRSAPriv = (() => {
      function genRSAASN1Buf(n, e, d, p, q, dmp1, dmq1, iqmp) {
        const asnWriter = new Ber.Writer();
        asnWriter.startSequence();
        asnWriter.writeInt(0, Ber.Integer);
        asnWriter.writeBuffer(n, Ber.Integer);
        asnWriter.writeBuffer(e, Ber.Integer);
        asnWriter.writeBuffer(d, Ber.Integer);
        asnWriter.writeBuffer(p, Ber.Integer);
        asnWriter.writeBuffer(q, Ber.Integer);
        asnWriter.writeBuffer(dmp1, Ber.Integer);
        asnWriter.writeBuffer(dmq1, Ber.Integer);
        asnWriter.writeBuffer(iqmp, Ber.Integer);
        asnWriter.endSequence();
        return asnWriter.buffer;
      }
      function bigIntFromBuffer(buf) {
        return BigInt(`0x${buf.hexSlice(0, buf.length)}`);
      }
      function bigIntToBuffer(bn) {
        let hex = bn.toString(16);
        if ((hex.length & 1) !== 0) {
          hex = `0${hex}`;
        } else {
          const sigbit = hex.charCodeAt(0);
          if (sigbit === 56 || sigbit === 57 || sigbit >= 97 && sigbit <= 102) {
            hex = `00${hex}`;
          }
        }
        return Buffer.from(hex, "hex");
      }
      return function genOpenSSLRSAPriv2(n, e, d, iqmp, p, q) {
        const bn_d = bigIntFromBuffer(d);
        const dmp1 = bigIntToBuffer(bn_d % (bigIntFromBuffer(p) - 1n));
        const dmq1 = bigIntToBuffer(bn_d % (bigIntFromBuffer(q) - 1n));
        return makePEM("RSA PRIVATE", genRSAASN1Buf(n, e, d, p, q, dmp1, dmq1, iqmp));
      };
    })();
    function genOpenSSLDSAPub(p, q, g, y) {
      const asnWriter = new Ber.Writer();
      asnWriter.startSequence();
      asnWriter.startSequence();
      asnWriter.writeOID("1.2.840.10040.4.1");
      asnWriter.startSequence();
      asnWriter.writeBuffer(p, Ber.Integer);
      asnWriter.writeBuffer(q, Ber.Integer);
      asnWriter.writeBuffer(g, Ber.Integer);
      asnWriter.endSequence();
      asnWriter.endSequence();
      asnWriter.startSequence(Ber.BitString);
      asnWriter.writeByte(0);
      asnWriter.writeBuffer(y, Ber.Integer);
      asnWriter.endSequence();
      asnWriter.endSequence();
      return makePEM("PUBLIC", asnWriter.buffer);
    }
    function genOpenSSHDSAPub(p, q, g, y) {
      const publicKey = Buffer.allocUnsafe(4 + 7 + 4 + p.length + 4 + q.length + 4 + g.length + 4 + y.length);
      writeUInt32BE(publicKey, 7, 0);
      publicKey.utf8Write("ssh-dss", 4, 7);
      let i = 4 + 7;
      writeUInt32BE(publicKey, p.length, i);
      publicKey.set(p, i += 4);
      writeUInt32BE(publicKey, q.length, i += p.length);
      publicKey.set(q, i += 4);
      writeUInt32BE(publicKey, g.length, i += q.length);
      publicKey.set(g, i += 4);
      writeUInt32BE(publicKey, y.length, i += g.length);
      publicKey.set(y, i + 4);
      return publicKey;
    }
    function genOpenSSLDSAPriv(p, q, g, y, x) {
      const asnWriter = new Ber.Writer();
      asnWriter.startSequence();
      asnWriter.writeInt(0, Ber.Integer);
      asnWriter.writeBuffer(p, Ber.Integer);
      asnWriter.writeBuffer(q, Ber.Integer);
      asnWriter.writeBuffer(g, Ber.Integer);
      asnWriter.writeBuffer(y, Ber.Integer);
      asnWriter.writeBuffer(x, Ber.Integer);
      asnWriter.endSequence();
      return makePEM("DSA PRIVATE", asnWriter.buffer);
    }
    function genOpenSSLEdPub(pub) {
      const asnWriter = new Ber.Writer();
      asnWriter.startSequence();
      asnWriter.startSequence();
      asnWriter.writeOID("1.3.101.112");
      asnWriter.endSequence();
      asnWriter.startSequence(Ber.BitString);
      asnWriter.writeByte(0);
      asnWriter._ensure(pub.length);
      asnWriter._buf.set(pub, asnWriter._offset);
      asnWriter._offset += pub.length;
      asnWriter.endSequence();
      asnWriter.endSequence();
      return makePEM("PUBLIC", asnWriter.buffer);
    }
    function genOpenSSHEdPub(pub) {
      const publicKey = Buffer.allocUnsafe(4 + 11 + 4 + pub.length);
      writeUInt32BE(publicKey, 11, 0);
      publicKey.utf8Write("ssh-ed25519", 4, 11);
      writeUInt32BE(publicKey, pub.length, 15);
      publicKey.set(pub, 19);
      return publicKey;
    }
    function genOpenSSLEdPriv(priv) {
      const asnWriter = new Ber.Writer();
      asnWriter.startSequence();
      asnWriter.writeInt(0, Ber.Integer);
      asnWriter.startSequence();
      asnWriter.writeOID("1.3.101.112");
      asnWriter.endSequence();
      asnWriter.startSequence(Ber.OctetString);
      asnWriter.writeBuffer(priv, Ber.OctetString);
      asnWriter.endSequence();
      asnWriter.endSequence();
      return makePEM("PRIVATE", asnWriter.buffer);
    }
    function genOpenSSLECDSAPub(oid, Q) {
      const asnWriter = new Ber.Writer();
      asnWriter.startSequence();
      asnWriter.startSequence();
      asnWriter.writeOID("1.2.840.10045.2.1");
      asnWriter.writeOID(oid);
      asnWriter.endSequence();
      asnWriter.startSequence(Ber.BitString);
      asnWriter.writeByte(0);
      asnWriter._ensure(Q.length);
      asnWriter._buf.set(Q, asnWriter._offset);
      asnWriter._offset += Q.length;
      asnWriter.endSequence();
      asnWriter.endSequence();
      return makePEM("PUBLIC", asnWriter.buffer);
    }
    function genOpenSSHECDSAPub(oid, Q) {
      let curveName;
      switch (oid) {
        case "1.2.840.10045.3.1.7":
          curveName = "nistp256";
          break;
        case "1.3.132.0.34":
          curveName = "nistp384";
          break;
        case "1.3.132.0.35":
          curveName = "nistp521";
          break;
        default:
          return;
      }
      const publicKey = Buffer.allocUnsafe(4 + 19 + 4 + 8 + 4 + Q.length);
      writeUInt32BE(publicKey, 19, 0);
      publicKey.utf8Write(`ecdsa-sha2-${curveName}`, 4, 19);
      writeUInt32BE(publicKey, 8, 23);
      publicKey.utf8Write(curveName, 27, 8);
      writeUInt32BE(publicKey, Q.length, 35);
      publicKey.set(Q, 39);
      return publicKey;
    }
    function genOpenSSLECDSAPriv(oid, pub, priv) {
      const asnWriter = new Ber.Writer();
      asnWriter.startSequence();
      asnWriter.writeInt(1, Ber.Integer);
      asnWriter.writeBuffer(priv, Ber.OctetString);
      asnWriter.startSequence(160);
      asnWriter.writeOID(oid);
      asnWriter.endSequence();
      asnWriter.startSequence(161);
      asnWriter.startSequence(Ber.BitString);
      asnWriter.writeByte(0);
      asnWriter._ensure(pub.length);
      asnWriter._buf.set(pub, asnWriter._offset);
      asnWriter._offset += pub.length;
      asnWriter.endSequence();
      asnWriter.endSequence();
      asnWriter.endSequence();
      return makePEM("EC PRIVATE", asnWriter.buffer);
    }
    function genOpenSSLECDSAPubFromPriv(curveName, priv) {
      const tempECDH = createECDH(curveName);
      tempECDH.setPrivateKey(priv);
      return tempECDH.getPublicKey();
    }
    var BaseKey = {
      sign: (() => {
        if (typeof sign_ === "function") {
          return function sign(data, algo) {
            const pem = this[SYM_PRIV_PEM];
            if (pem === null)
              return new Error("No private key available");
            if (!algo || typeof algo !== "string")
              algo = this[SYM_HASH_ALGO];
            try {
              return sign_(algo, data, pem);
            } catch (ex) {
              return ex;
            }
          };
        }
        return function sign(data, algo) {
          const pem = this[SYM_PRIV_PEM];
          if (pem === null)
            return new Error("No private key available");
          if (!algo || typeof algo !== "string")
            algo = this[SYM_HASH_ALGO];
          const signature = createSign(algo);
          signature.update(data);
          try {
            return signature.sign(pem);
          } catch (ex) {
            return ex;
          }
        };
      })(),
      verify: (() => {
        if (typeof verify_ === "function") {
          return function verify(data, signature, algo) {
            const pem = this[SYM_PUB_PEM];
            if (pem === null)
              return new Error("No public key available");
            if (!algo || typeof algo !== "string")
              algo = this[SYM_HASH_ALGO];
            try {
              return verify_(algo, data, pem, signature);
            } catch (ex) {
              return ex;
            }
          };
        }
        return function verify(data, signature, algo) {
          const pem = this[SYM_PUB_PEM];
          if (pem === null)
            return new Error("No public key available");
          if (!algo || typeof algo !== "string")
            algo = this[SYM_HASH_ALGO];
          const verifier = createVerify(algo);
          verifier.update(data);
          try {
            return verifier.verify(pem, signature);
          } catch (ex) {
            return ex;
          }
        };
      })(),
      isPrivateKey: function isPrivateKey() {
        return this[SYM_PRIV_PEM] !== null;
      },
      getPrivatePEM: function getPrivatePEM() {
        return this[SYM_PRIV_PEM];
      },
      getPublicPEM: function getPublicPEM() {
        return this[SYM_PUB_PEM];
      },
      getPublicSSH: function getPublicSSH() {
        return this[SYM_PUB_SSH];
      },
      equals: function equals(key) {
        const parsed = parseKey(key);
        if (parsed instanceof Error)
          return false;
        return this.type === parsed.type && this[SYM_PRIV_PEM] === parsed[SYM_PRIV_PEM] && this[SYM_PUB_PEM] === parsed[SYM_PUB_PEM] && this[SYM_PUB_SSH] === parsed[SYM_PUB_SSH];
      }
    };
    function OpenSSH_Private(type, comment, privPEM, pubPEM, pubSSH, algo, decrypted) {
      this.type = type;
      this.comment = comment;
      this[SYM_PRIV_PEM] = privPEM;
      this[SYM_PUB_PEM] = pubPEM;
      this[SYM_PUB_SSH] = pubSSH;
      this[SYM_HASH_ALGO] = algo;
      this[SYM_DECRYPTED] = decrypted;
    }
    OpenSSH_Private.prototype = BaseKey;
    {
      let parseOpenSSHPrivKeys = function(data, nkeys, decrypted) {
        const keys = [];
        if (data.length < 8)
          return new Error("Malformed OpenSSH private key");
        const check1 = readUInt32BE(data, 0);
        const check2 = readUInt32BE(data, 4);
        if (check1 !== check2) {
          if (decrypted) {
            return new Error("OpenSSH key integrity check failed -- bad passphrase?");
          }
          return new Error("OpenSSH key integrity check failed");
        }
        data._pos = 8;
        let i;
        let oid;
        for (i = 0; i < nkeys; ++i) {
          let algo;
          let privPEM;
          let pubPEM;
          let pubSSH;
          const type = readString(data, data._pos, true);
          if (type === void 0)
            return new Error("Malformed OpenSSH private key");
          switch (type) {
            case "ssh-rsa": {
              const n = readString(data, data._pos);
              if (n === void 0)
                return new Error("Malformed OpenSSH private key");
              const e = readString(data, data._pos);
              if (e === void 0)
                return new Error("Malformed OpenSSH private key");
              const d = readString(data, data._pos);
              if (d === void 0)
                return new Error("Malformed OpenSSH private key");
              const iqmp = readString(data, data._pos);
              if (iqmp === void 0)
                return new Error("Malformed OpenSSH private key");
              const p = readString(data, data._pos);
              if (p === void 0)
                return new Error("Malformed OpenSSH private key");
              const q = readString(data, data._pos);
              if (q === void 0)
                return new Error("Malformed OpenSSH private key");
              pubPEM = genOpenSSLRSAPub(n, e);
              pubSSH = genOpenSSHRSAPub(n, e);
              privPEM = genOpenSSLRSAPriv(n, e, d, iqmp, p, q);
              algo = "sha1";
              break;
            }
            case "ssh-dss": {
              const p = readString(data, data._pos);
              if (p === void 0)
                return new Error("Malformed OpenSSH private key");
              const q = readString(data, data._pos);
              if (q === void 0)
                return new Error("Malformed OpenSSH private key");
              const g = readString(data, data._pos);
              if (g === void 0)
                return new Error("Malformed OpenSSH private key");
              const y = readString(data, data._pos);
              if (y === void 0)
                return new Error("Malformed OpenSSH private key");
              const x = readString(data, data._pos);
              if (x === void 0)
                return new Error("Malformed OpenSSH private key");
              pubPEM = genOpenSSLDSAPub(p, q, g, y);
              pubSSH = genOpenSSHDSAPub(p, q, g, y);
              privPEM = genOpenSSLDSAPriv(p, q, g, y, x);
              algo = "sha1";
              break;
            }
            case "ssh-ed25519": {
              if (!eddsaSupported)
                return new Error(`Unsupported OpenSSH private key type: ${type}`);
              const edpub = readString(data, data._pos);
              if (edpub === void 0 || edpub.length !== 32)
                return new Error("Malformed OpenSSH private key");
              const edpriv = readString(data, data._pos);
              if (edpriv === void 0 || edpriv.length !== 64)
                return new Error("Malformed OpenSSH private key");
              pubPEM = genOpenSSLEdPub(edpub);
              pubSSH = genOpenSSHEdPub(edpub);
              privPEM = genOpenSSLEdPriv(bufferSlice(edpriv, 0, 32));
              algo = null;
              break;
            }
            case "ecdsa-sha2-nistp256":
              algo = "sha256";
              oid = "1.2.840.10045.3.1.7";
            case "ecdsa-sha2-nistp384":
              if (algo === void 0) {
                algo = "sha384";
                oid = "1.3.132.0.34";
              }
            case "ecdsa-sha2-nistp521": {
              if (algo === void 0) {
                algo = "sha512";
                oid = "1.3.132.0.35";
              }
              if (!skipFields(data, 1))
                return new Error("Malformed OpenSSH private key");
              const ecpub = readString(data, data._pos);
              if (ecpub === void 0)
                return new Error("Malformed OpenSSH private key");
              const ecpriv = readString(data, data._pos);
              if (ecpriv === void 0)
                return new Error("Malformed OpenSSH private key");
              pubPEM = genOpenSSLECDSAPub(oid, ecpub);
              pubSSH = genOpenSSHECDSAPub(oid, ecpub);
              privPEM = genOpenSSLECDSAPriv(oid, ecpub, ecpriv);
              break;
            }
            default:
              return new Error(`Unsupported OpenSSH private key type: ${type}`);
          }
          const privComment = readString(data, data._pos, true);
          if (privComment === void 0)
            return new Error("Malformed OpenSSH private key");
          keys.push(new OpenSSH_Private(type, privComment, privPEM, pubPEM, pubSSH, algo, decrypted));
        }
        let cnt = 0;
        for (i = data._pos; i < data.length; ++i) {
          if (data[i] !== ++cnt % 255)
            return new Error("Malformed OpenSSH private key");
        }
        return keys;
      };
      const regexp = /^-----BEGIN OPENSSH PRIVATE KEY-----(?:\r\n|\n)([\s\S]+)(?:\r\n|\n)-----END OPENSSH PRIVATE KEY-----$/;
      OpenSSH_Private.parse = (str, passphrase) => {
        const m = regexp.exec(str);
        if (m === null)
          return null;
        let ret;
        const data = Buffer.from(m[1], "base64");
        if (data.length < 31)
          return new Error("Malformed OpenSSH private key");
        const magic = data.utf8Slice(0, 15);
        if (magic !== "openssh-key-v1\0")
          return new Error(`Unsupported OpenSSH key magic: ${magic}`);
        const cipherName = readString(data, 15, true);
        if (cipherName === void 0)
          return new Error("Malformed OpenSSH private key");
        if (cipherName !== "none" && SUPPORTED_CIPHER.indexOf(cipherName) === -1)
          return new Error(`Unsupported cipher for OpenSSH key: ${cipherName}`);
        const kdfName = readString(data, data._pos, true);
        if (kdfName === void 0)
          return new Error("Malformed OpenSSH private key");
        if (kdfName !== "none") {
          if (cipherName === "none")
            return new Error("Malformed OpenSSH private key");
          if (kdfName !== "bcrypt")
            return new Error(`Unsupported kdf name for OpenSSH key: ${kdfName}`);
          if (!passphrase) {
            return new Error("Encrypted private OpenSSH key detected, but no passphrase given");
          }
        } else if (cipherName !== "none") {
          return new Error("Malformed OpenSSH private key");
        }
        let encInfo;
        let cipherKey;
        let cipherIV;
        if (cipherName !== "none")
          encInfo = CIPHER_INFO[cipherName];
        const kdfOptions = readString(data, data._pos);
        if (kdfOptions === void 0)
          return new Error("Malformed OpenSSH private key");
        if (kdfOptions.length) {
          switch (kdfName) {
            case "none":
              return new Error("Malformed OpenSSH private key");
            case "bcrypt":
              const salt = readString(kdfOptions, 0);
              if (salt === void 0 || kdfOptions._pos + 4 > kdfOptions.length)
                return new Error("Malformed OpenSSH private key");
              const rounds = readUInt32BE(kdfOptions, kdfOptions._pos);
              const gen = Buffer.allocUnsafe(encInfo.keyLen + encInfo.ivLen);
              const r = bcrypt_pbkdf(passphrase, passphrase.length, salt, salt.length, gen, gen.length, rounds);
              if (r !== 0)
                return new Error("Failed to generate information to decrypt key");
              cipherKey = bufferSlice(gen, 0, encInfo.keyLen);
              cipherIV = bufferSlice(gen, encInfo.keyLen, gen.length);
              break;
          }
        } else if (kdfName !== "none") {
          return new Error("Malformed OpenSSH private key");
        }
        if (data._pos + 3 >= data.length)
          return new Error("Malformed OpenSSH private key");
        const keyCount = readUInt32BE(data, data._pos);
        data._pos += 4;
        if (keyCount > 0) {
          for (let i = 0; i < keyCount; ++i) {
            const pubData = readString(data, data._pos);
            if (pubData === void 0)
              return new Error("Malformed OpenSSH private key");
            const type = readString(pubData, 0, true);
            if (type === void 0)
              return new Error("Malformed OpenSSH private key");
          }
          let privBlob = readString(data, data._pos);
          if (privBlob === void 0)
            return new Error("Malformed OpenSSH private key");
          if (cipherKey !== void 0) {
            if (privBlob.length < encInfo.blockLen || privBlob.length % encInfo.blockLen !== 0) {
              return new Error("Malformed OpenSSH private key");
            }
            try {
              const options = { authTagLength: encInfo.authLen };
              const decipher = createDecipheriv(encInfo.sslName, cipherKey, cipherIV, options);
              if (encInfo.authLen > 0) {
                if (data.length - data._pos < encInfo.authLen)
                  return new Error("Malformed OpenSSH private key");
                decipher.setAuthTag(bufferSlice(data, data._pos, data._pos += encInfo.authLen));
              }
              privBlob = combineBuffers(decipher.update(privBlob), decipher.final());
            } catch (ex) {
              return ex;
            }
          }
          if (data._pos !== data.length)
            return new Error("Malformed OpenSSH private key");
          ret = parseOpenSSHPrivKeys(privBlob, keyCount, cipherKey !== void 0);
        } else {
          ret = [];
        }
        if (ret instanceof Error)
          return ret;
        return ret[0];
      };
    }
    function OpenSSH_Old_Private(type, comment, privPEM, pubPEM, pubSSH, algo, decrypted) {
      this.type = type;
      this.comment = comment;
      this[SYM_PRIV_PEM] = privPEM;
      this[SYM_PUB_PEM] = pubPEM;
      this[SYM_PUB_SSH] = pubSSH;
      this[SYM_HASH_ALGO] = algo;
      this[SYM_DECRYPTED] = decrypted;
    }
    OpenSSH_Old_Private.prototype = BaseKey;
    {
      const regexp = /^-----BEGIN (RSA|DSA|EC) PRIVATE KEY-----(?:\r\n|\n)((?:[^:]+:\s*[\S].*(?:\r\n|\n))*)([\s\S]+)(?:\r\n|\n)-----END (RSA|DSA|EC) PRIVATE KEY-----$/;
      OpenSSH_Old_Private.parse = (str, passphrase) => {
        const m = regexp.exec(str);
        if (m === null)
          return null;
        let privBlob = Buffer.from(m[3], "base64");
        let headers = m[2];
        let decrypted = false;
        if (headers !== void 0) {
          headers = headers.split(/\r\n|\n/g);
          for (let i = 0; i < headers.length; ++i) {
            const header = headers[i];
            let sepIdx = header.indexOf(":");
            if (header.slice(0, sepIdx) === "DEK-Info") {
              const val = header.slice(sepIdx + 2);
              sepIdx = val.indexOf(",");
              if (sepIdx === -1)
                continue;
              const cipherName = val.slice(0, sepIdx).toLowerCase();
              if (supportedOpenSSLCiphers.indexOf(cipherName) === -1) {
                return new Error(`Cipher (${cipherName}) not supported for encrypted OpenSSH private key`);
              }
              const encInfo = CIPHER_INFO_OPENSSL[cipherName];
              if (!encInfo) {
                return new Error(`Cipher (${cipherName}) not supported for encrypted OpenSSH private key`);
              }
              const cipherIV = Buffer.from(val.slice(sepIdx + 1), "hex");
              if (cipherIV.length !== encInfo.ivLen)
                return new Error("Malformed encrypted OpenSSH private key");
              if (!passphrase) {
                return new Error("Encrypted OpenSSH private key detected, but no passphrase given");
              }
              const ivSlice = bufferSlice(cipherIV, 0, 8);
              let cipherKey = createHash("md5").update(passphrase).update(ivSlice).digest();
              while (cipherKey.length < encInfo.keyLen) {
                cipherKey = combineBuffers(cipherKey, createHash("md5").update(cipherKey).update(passphrase).update(ivSlice).digest());
              }
              if (cipherKey.length > encInfo.keyLen)
                cipherKey = bufferSlice(cipherKey, 0, encInfo.keyLen);
              try {
                const decipher = createDecipheriv(cipherName, cipherKey, cipherIV);
                decipher.setAutoPadding(false);
                privBlob = combineBuffers(decipher.update(privBlob), decipher.final());
                decrypted = true;
              } catch (ex) {
                return ex;
              }
            }
          }
        }
        let type;
        let privPEM;
        let pubPEM;
        let pubSSH;
        let algo;
        let reader;
        let errMsg = "Malformed OpenSSH private key";
        if (decrypted)
          errMsg += ". Bad passphrase?";
        switch (m[1]) {
          case "RSA":
            type = "ssh-rsa";
            privPEM = makePEM("RSA PRIVATE", privBlob);
            try {
              reader = new Ber.Reader(privBlob);
              reader.readSequence();
              reader.readInt();
              const n = reader.readString(Ber.Integer, true);
              if (n === null)
                return new Error(errMsg);
              const e = reader.readString(Ber.Integer, true);
              if (e === null)
                return new Error(errMsg);
              pubPEM = genOpenSSLRSAPub(n, e);
              pubSSH = genOpenSSHRSAPub(n, e);
            } catch {
              return new Error(errMsg);
            }
            algo = "sha1";
            break;
          case "DSA":
            type = "ssh-dss";
            privPEM = makePEM("DSA PRIVATE", privBlob);
            try {
              reader = new Ber.Reader(privBlob);
              reader.readSequence();
              reader.readInt();
              const p = reader.readString(Ber.Integer, true);
              if (p === null)
                return new Error(errMsg);
              const q = reader.readString(Ber.Integer, true);
              if (q === null)
                return new Error(errMsg);
              const g = reader.readString(Ber.Integer, true);
              if (g === null)
                return new Error(errMsg);
              const y = reader.readString(Ber.Integer, true);
              if (y === null)
                return new Error(errMsg);
              pubPEM = genOpenSSLDSAPub(p, q, g, y);
              pubSSH = genOpenSSHDSAPub(p, q, g, y);
            } catch {
              return new Error(errMsg);
            }
            algo = "sha1";
            break;
          case "EC":
            let ecSSLName;
            let ecPriv;
            let ecOID;
            try {
              reader = new Ber.Reader(privBlob);
              reader.readSequence();
              reader.readInt();
              ecPriv = reader.readString(Ber.OctetString, true);
              reader.readByte();
              const offset = reader.readLength();
              if (offset !== null) {
                reader._offset = offset;
                ecOID = reader.readOID();
                if (ecOID === null)
                  return new Error(errMsg);
                switch (ecOID) {
                  case "1.2.840.10045.3.1.7":
                    ecSSLName = "prime256v1";
                    type = "ecdsa-sha2-nistp256";
                    algo = "sha256";
                    break;
                  case "1.3.132.0.34":
                    ecSSLName = "secp384r1";
                    type = "ecdsa-sha2-nistp384";
                    algo = "sha384";
                    break;
                  case "1.3.132.0.35":
                    ecSSLName = "secp521r1";
                    type = "ecdsa-sha2-nistp521";
                    algo = "sha512";
                    break;
                  default:
                    return new Error(`Unsupported private key EC OID: ${ecOID}`);
                }
              } else {
                return new Error(errMsg);
              }
            } catch {
              return new Error(errMsg);
            }
            privPEM = makePEM("EC PRIVATE", privBlob);
            const pubBlob = genOpenSSLECDSAPubFromPriv(ecSSLName, ecPriv);
            pubPEM = genOpenSSLECDSAPub(ecOID, pubBlob);
            pubSSH = genOpenSSHECDSAPub(ecOID, pubBlob);
            break;
        }
        return new OpenSSH_Old_Private(type, "", privPEM, pubPEM, pubSSH, algo, decrypted);
      };
    }
    function PPK_Private(type, comment, privPEM, pubPEM, pubSSH, algo, decrypted) {
      this.type = type;
      this.comment = comment;
      this[SYM_PRIV_PEM] = privPEM;
      this[SYM_PUB_PEM] = pubPEM;
      this[SYM_PUB_SSH] = pubSSH;
      this[SYM_HASH_ALGO] = algo;
      this[SYM_DECRYPTED] = decrypted;
    }
    PPK_Private.prototype = BaseKey;
    {
      const EMPTY_PASSPHRASE = Buffer.alloc(0);
      const PPK_IV = Buffer.from([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      const PPK_PP1 = Buffer.from([0, 0, 0, 0]);
      const PPK_PP2 = Buffer.from([0, 0, 0, 1]);
      const regexp = /^PuTTY-User-Key-File-2: (ssh-(?:rsa|dss))\r?\nEncryption: (aes256-cbc|none)\r?\nComment: ([^\r\n]*)\r?\nPublic-Lines: \d+\r?\n([\s\S]+?)\r?\nPrivate-Lines: \d+\r?\n([\s\S]+?)\r?\nPrivate-MAC: ([^\r\n]+)/;
      PPK_Private.parse = (str, passphrase) => {
        const m = regexp.exec(str);
        if (m === null)
          return null;
        const cipherName = m[2];
        const encrypted = cipherName !== "none";
        if (encrypted && !passphrase) {
          return new Error("Encrypted PPK private key detected, but no passphrase given");
        }
        let privBlob = Buffer.from(m[5], "base64");
        if (encrypted) {
          const encInfo = CIPHER_INFO[cipherName];
          let cipherKey = combineBuffers(createHash("sha1").update(PPK_PP1).update(passphrase).digest(), createHash("sha1").update(PPK_PP2).update(passphrase).digest());
          if (cipherKey.length > encInfo.keyLen)
            cipherKey = bufferSlice(cipherKey, 0, encInfo.keyLen);
          try {
            const decipher = createDecipheriv(encInfo.sslName, cipherKey, PPK_IV);
            decipher.setAutoPadding(false);
            privBlob = combineBuffers(decipher.update(privBlob), decipher.final());
          } catch (ex) {
            return ex;
          }
        }
        const type = m[1];
        const comment = m[3];
        const pubBlob = Buffer.from(m[4], "base64");
        const mac = m[6];
        const typeLen = type.length;
        const cipherNameLen = cipherName.length;
        const commentLen = Buffer.byteLength(comment);
        const pubLen = pubBlob.length;
        const privLen = privBlob.length;
        const macData = Buffer.allocUnsafe(4 + typeLen + 4 + cipherNameLen + 4 + commentLen + 4 + pubLen + 4 + privLen);
        let p = 0;
        writeUInt32BE(macData, typeLen, p);
        macData.utf8Write(type, p += 4, typeLen);
        writeUInt32BE(macData, cipherNameLen, p += typeLen);
        macData.utf8Write(cipherName, p += 4, cipherNameLen);
        writeUInt32BE(macData, commentLen, p += cipherNameLen);
        macData.utf8Write(comment, p += 4, commentLen);
        writeUInt32BE(macData, pubLen, p += commentLen);
        macData.set(pubBlob, p += 4);
        writeUInt32BE(macData, privLen, p += pubLen);
        macData.set(privBlob, p + 4);
        if (!passphrase)
          passphrase = EMPTY_PASSPHRASE;
        const calcMAC = createHmac("sha1", createHash("sha1").update("putty-private-key-file-mac-key").update(passphrase).digest()).update(macData).digest("hex");
        if (calcMAC !== mac) {
          if (encrypted) {
            return new Error("PPK private key integrity check failed -- bad passphrase?");
          }
          return new Error("PPK private key integrity check failed");
        }
        let pubPEM;
        let pubSSH;
        let privPEM;
        pubBlob._pos = 0;
        skipFields(pubBlob, 1);
        switch (type) {
          case "ssh-rsa": {
            const e = readString(pubBlob, pubBlob._pos);
            if (e === void 0)
              return new Error("Malformed PPK public key");
            const n = readString(pubBlob, pubBlob._pos);
            if (n === void 0)
              return new Error("Malformed PPK public key");
            const d = readString(privBlob, 0);
            if (d === void 0)
              return new Error("Malformed PPK private key");
            const p2 = readString(privBlob, privBlob._pos);
            if (p2 === void 0)
              return new Error("Malformed PPK private key");
            const q = readString(privBlob, privBlob._pos);
            if (q === void 0)
              return new Error("Malformed PPK private key");
            const iqmp = readString(privBlob, privBlob._pos);
            if (iqmp === void 0)
              return new Error("Malformed PPK private key");
            pubPEM = genOpenSSLRSAPub(n, e);
            pubSSH = genOpenSSHRSAPub(n, e);
            privPEM = genOpenSSLRSAPriv(n, e, d, iqmp, p2, q);
            break;
          }
          case "ssh-dss": {
            const p2 = readString(pubBlob, pubBlob._pos);
            if (p2 === void 0)
              return new Error("Malformed PPK public key");
            const q = readString(pubBlob, pubBlob._pos);
            if (q === void 0)
              return new Error("Malformed PPK public key");
            const g = readString(pubBlob, pubBlob._pos);
            if (g === void 0)
              return new Error("Malformed PPK public key");
            const y = readString(pubBlob, pubBlob._pos);
            if (y === void 0)
              return new Error("Malformed PPK public key");
            const x = readString(privBlob, 0);
            if (x === void 0)
              return new Error("Malformed PPK private key");
            pubPEM = genOpenSSLDSAPub(p2, q, g, y);
            pubSSH = genOpenSSHDSAPub(p2, q, g, y);
            privPEM = genOpenSSLDSAPriv(p2, q, g, y, x);
            break;
          }
        }
        return new PPK_Private(type, comment, privPEM, pubPEM, pubSSH, "sha1", encrypted);
      };
    }
    function OpenSSH_Public(type, comment, pubPEM, pubSSH, algo) {
      this.type = type;
      this.comment = comment;
      this[SYM_PRIV_PEM] = null;
      this[SYM_PUB_PEM] = pubPEM;
      this[SYM_PUB_SSH] = pubSSH;
      this[SYM_HASH_ALGO] = algo;
      this[SYM_DECRYPTED] = false;
    }
    OpenSSH_Public.prototype = BaseKey;
    {
      let regexp;
      if (eddsaSupported)
        regexp = /^(((?:ssh-(?:rsa|dss|ed25519))|ecdsa-sha2-nistp(?:256|384|521))(?:-cert-v0[01]@openssh.com)?) ([A-Z0-9a-z/+=]+)(?:$|\s+([\S].*)?)$/;
      else
        regexp = /^(((?:ssh-(?:rsa|dss))|ecdsa-sha2-nistp(?:256|384|521))(?:-cert-v0[01]@openssh.com)?) ([A-Z0-9a-z/+=]+)(?:$|\s+([\S].*)?)$/;
      OpenSSH_Public.parse = (str) => {
        const m = regexp.exec(str);
        if (m === null)
          return null;
        const fullType = m[1];
        const baseType = m[2];
        const data = Buffer.from(m[3], "base64");
        const comment = m[4] || "";
        const type = readString(data, data._pos, true);
        if (type === void 0 || type.indexOf(baseType) !== 0)
          return new Error("Malformed OpenSSH public key");
        return parseDER(data, baseType, comment, fullType);
      };
    }
    function RFC4716_Public(type, comment, pubPEM, pubSSH, algo) {
      this.type = type;
      this.comment = comment;
      this[SYM_PRIV_PEM] = null;
      this[SYM_PUB_PEM] = pubPEM;
      this[SYM_PUB_SSH] = pubSSH;
      this[SYM_HASH_ALGO] = algo;
      this[SYM_DECRYPTED] = false;
    }
    RFC4716_Public.prototype = BaseKey;
    {
      const regexp = /^---- BEGIN SSH2 PUBLIC KEY ----(?:\r?\n)((?:.{0,72}\r?\n)+)---- END SSH2 PUBLIC KEY ----$/;
      const RE_DATA = /^[A-Z0-9a-z/+=\r\n]+$/;
      const RE_HEADER = /^([\x21-\x39\x3B-\x7E]{1,64}): ((?:[^\\]*\\\r?\n)*[^\r\n]+)\r?\n/gm;
      const RE_HEADER_ENDS = /\\\r?\n/g;
      RFC4716_Public.parse = (str) => {
        let m = regexp.exec(str);
        if (m === null)
          return null;
        const body = m[1];
        let dataStart = 0;
        let comment = "";
        while (m = RE_HEADER.exec(body)) {
          const headerName = m[1];
          const headerValue = m[2].replace(RE_HEADER_ENDS, "");
          if (headerValue.length > 1024) {
            RE_HEADER.lastIndex = 0;
            return new Error("Malformed RFC4716 public key");
          }
          dataStart = RE_HEADER.lastIndex;
          if (headerName.toLowerCase() === "comment") {
            comment = headerValue;
            if (comment.length > 1 && comment.charCodeAt(0) === 34 && comment.charCodeAt(comment.length - 1) === 34) {
              comment = comment.slice(1, -1);
            }
          }
        }
        let data = body.slice(dataStart);
        if (!RE_DATA.test(data))
          return new Error("Malformed RFC4716 public key");
        data = Buffer.from(data, "base64");
        const type = readString(data, 0, true);
        if (type === void 0)
          return new Error("Malformed RFC4716 public key");
        let pubPEM = null;
        let pubSSH = null;
        switch (type) {
          case "ssh-rsa": {
            const e = readString(data, data._pos);
            if (e === void 0)
              return new Error("Malformed RFC4716 public key");
            const n = readString(data, data._pos);
            if (n === void 0)
              return new Error("Malformed RFC4716 public key");
            pubPEM = genOpenSSLRSAPub(n, e);
            pubSSH = genOpenSSHRSAPub(n, e);
            break;
          }
          case "ssh-dss": {
            const p = readString(data, data._pos);
            if (p === void 0)
              return new Error("Malformed RFC4716 public key");
            const q = readString(data, data._pos);
            if (q === void 0)
              return new Error("Malformed RFC4716 public key");
            const g = readString(data, data._pos);
            if (g === void 0)
              return new Error("Malformed RFC4716 public key");
            const y = readString(data, data._pos);
            if (y === void 0)
              return new Error("Malformed RFC4716 public key");
            pubPEM = genOpenSSLDSAPub(p, q, g, y);
            pubSSH = genOpenSSHDSAPub(p, q, g, y);
            break;
          }
          default:
            return new Error("Malformed RFC4716 public key");
        }
        return new RFC4716_Public(type, comment, pubPEM, pubSSH, "sha1");
      };
    }
    function parseDER(data, baseType, comment, fullType) {
      if (!isSupportedKeyType(baseType))
        return new Error(`Unsupported OpenSSH public key type: ${baseType}`);
      let algo;
      let oid;
      let pubPEM = null;
      let pubSSH = null;
      switch (baseType) {
        case "ssh-rsa": {
          const e = readString(data, data._pos || 0);
          if (e === void 0)
            return new Error("Malformed OpenSSH public key");
          const n = readString(data, data._pos);
          if (n === void 0)
            return new Error("Malformed OpenSSH public key");
          pubPEM = genOpenSSLRSAPub(n, e);
          pubSSH = genOpenSSHRSAPub(n, e);
          algo = "sha1";
          break;
        }
        case "ssh-dss": {
          const p = readString(data, data._pos || 0);
          if (p === void 0)
            return new Error("Malformed OpenSSH public key");
          const q = readString(data, data._pos);
          if (q === void 0)
            return new Error("Malformed OpenSSH public key");
          const g = readString(data, data._pos);
          if (g === void 0)
            return new Error("Malformed OpenSSH public key");
          const y = readString(data, data._pos);
          if (y === void 0)
            return new Error("Malformed OpenSSH public key");
          pubPEM = genOpenSSLDSAPub(p, q, g, y);
          pubSSH = genOpenSSHDSAPub(p, q, g, y);
          algo = "sha1";
          break;
        }
        case "ssh-ed25519": {
          const edpub = readString(data, data._pos || 0);
          if (edpub === void 0 || edpub.length !== 32)
            return new Error("Malformed OpenSSH public key");
          pubPEM = genOpenSSLEdPub(edpub);
          pubSSH = genOpenSSHEdPub(edpub);
          algo = null;
          break;
        }
        case "ecdsa-sha2-nistp256":
          algo = "sha256";
          oid = "1.2.840.10045.3.1.7";
        case "ecdsa-sha2-nistp384":
          if (algo === void 0) {
            algo = "sha384";
            oid = "1.3.132.0.34";
          }
        case "ecdsa-sha2-nistp521": {
          if (algo === void 0) {
            algo = "sha512";
            oid = "1.3.132.0.35";
          }
          if (!skipFields(data, 1))
            return new Error("Malformed OpenSSH public key");
          const ecpub = readString(data, data._pos || 0);
          if (ecpub === void 0)
            return new Error("Malformed OpenSSH public key");
          pubPEM = genOpenSSLECDSAPub(oid, ecpub);
          pubSSH = genOpenSSHECDSAPub(oid, ecpub);
          break;
        }
        default:
          return new Error(`Unsupported OpenSSH public key type: ${baseType}`);
      }
      return new OpenSSH_Public(fullType, comment, pubPEM, pubSSH, algo);
    }
    function isSupportedKeyType(type) {
      switch (type) {
        case "ssh-rsa":
        case "ssh-dss":
        case "ecdsa-sha2-nistp256":
        case "ecdsa-sha2-nistp384":
        case "ecdsa-sha2-nistp521":
          return true;
        case "ssh-ed25519":
          if (eddsaSupported)
            return true;
        default:
          return false;
      }
    }
    function isParsedKey(val) {
      if (!val)
        return false;
      return typeof val[SYM_DECRYPTED] === "boolean";
    }
    function parseKey(data, passphrase) {
      if (isParsedKey(data))
        return data;
      let origBuffer;
      if (Buffer.isBuffer(data)) {
        origBuffer = data;
        data = data.utf8Slice(0, data.length).trim();
      } else if (typeof data === "string") {
        data = data.trim();
      } else {
        return new Error("Key data must be a Buffer or string");
      }
      if (passphrase != void 0) {
        if (typeof passphrase === "string")
          passphrase = Buffer.from(passphrase);
        else if (!Buffer.isBuffer(passphrase))
          return new Error("Passphrase must be a string or Buffer when supplied");
      }
      let ret;
      if ((ret = OpenSSH_Private.parse(data, passphrase)) !== null)
        return ret;
      if ((ret = OpenSSH_Old_Private.parse(data, passphrase)) !== null)
        return ret;
      if ((ret = PPK_Private.parse(data, passphrase)) !== null)
        return ret;
      if ((ret = OpenSSH_Public.parse(data)) !== null)
        return ret;
      if ((ret = RFC4716_Public.parse(data)) !== null)
        return ret;
      if (origBuffer) {
        binaryKeyParser.init(origBuffer, 0);
        const type = binaryKeyParser.readString(true);
        if (type !== void 0) {
          data = binaryKeyParser.readRaw();
          if (data !== void 0) {
            ret = parseDER(data, type, "", type);
            if (ret instanceof Error)
              ret = null;
          }
        }
        binaryKeyParser.clear();
      }
      if (ret)
        return ret;
      return new Error("Unsupported key format");
    }
    module2.exports = {
      isParsedKey,
      isSupportedKeyType,
      parseDERKey: (data, type) => parseDER(data, type, "", type),
      parseKey
    };
  }
});

// node_modules/ssh2/lib/agent.js
var require_agent = __commonJS({
  "node_modules/ssh2/lib/agent.js"(exports, module2) {
    "use strict";
    var { Socket } = require("net");
    var { Duplex } = require("stream");
    var { resolve } = require("path");
    var { readFile } = require("fs");
    var { execFile, spawn } = require("child_process");
    var { isParsedKey, parseKey } = require_keyParser();
    var {
      makeBufferParser,
      readUInt32BE,
      writeUInt32BE,
      writeUInt32LE
    } = require_utils2();
    function once(cb) {
      let called = false;
      return (...args) => {
        if (called)
          return;
        called = true;
        cb(...args);
      };
    }
    function concat(buf1, buf2) {
      const combined = Buffer.allocUnsafe(buf1.length + buf2.length);
      buf1.copy(combined, 0);
      buf2.copy(combined, buf1.length);
      return combined;
    }
    function noop() {
    }
    var EMPTY_BUF = Buffer.alloc(0);
    var binaryParser = makeBufferParser();
    var BaseAgent = class {
      getIdentities(cb) {
        cb(new Error("Missing getIdentities() implementation"));
      }
      sign(pubKey, data, options, cb) {
        if (typeof options === "function")
          cb = options;
        cb(new Error("Missing sign() implementation"));
      }
    };
    var OpenSSHAgent = class extends BaseAgent {
      constructor(socketPath) {
        super();
        this.socketPath = socketPath;
      }
      getStream(cb) {
        cb = once(cb);
        const sock = new Socket();
        sock.on("connect", () => {
          cb(null, sock);
        });
        sock.on("close", onFail).on("end", onFail).on("error", onFail);
        sock.connect(this.socketPath);
        function onFail() {
          try {
            sock.destroy();
          } catch {
          }
          cb(new Error("Failed to connect to agent"));
        }
      }
      getIdentities(cb) {
        cb = once(cb);
        this.getStream((err, stream) => {
          function onFail(err2) {
            if (stream) {
              try {
                stream.destroy();
              } catch {
              }
            }
            if (!err2)
              err2 = new Error("Failed to retrieve identities from agent");
            cb(err2);
          }
          if (err)
            return onFail(err);
          const protocol = new AgentProtocol(true);
          protocol.on("error", onFail);
          protocol.pipe(stream).pipe(protocol);
          stream.on("close", onFail).on("end", onFail).on("error", onFail);
          protocol.getIdentities((err2, keys) => {
            if (err2)
              return onFail(err2);
            try {
              stream.destroy();
            } catch {
            }
            cb(null, keys);
          });
        });
      }
      sign(pubKey, data, options, cb) {
        if (typeof options === "function") {
          cb = options;
          options = void 0;
        } else if (typeof options !== "object" || options === null) {
          options = void 0;
        }
        cb = once(cb);
        this.getStream((err, stream) => {
          function onFail(err2) {
            if (stream) {
              try {
                stream.destroy();
              } catch {
              }
            }
            if (!err2)
              err2 = new Error("Failed to sign data with agent");
            cb(err2);
          }
          if (err)
            return onFail(err);
          const protocol = new AgentProtocol(true);
          protocol.on("error", onFail);
          protocol.pipe(stream).pipe(protocol);
          stream.on("close", onFail).on("end", onFail).on("error", onFail);
          protocol.sign(pubKey, data, options, (err2, sig) => {
            if (err2)
              return onFail(err2);
            try {
              stream.destroy();
            } catch {
            }
            cb(null, sig);
          });
        });
      }
    };
    var PageantAgent = (() => {
      const RET_ERR_BADARGS = 10;
      const RET_ERR_UNAVAILABLE = 11;
      const RET_ERR_NOMAP = 12;
      const RET_ERR_BINSTDIN = 13;
      const RET_ERR_BINSTDOUT = 14;
      const RET_ERR_BADLEN = 15;
      const EXEPATH = resolve(__dirname, "..", "util/pagent.exe");
      const ERROR = {
        [RET_ERR_BADARGS]: new Error("Invalid pagent.exe arguments"),
        [RET_ERR_UNAVAILABLE]: new Error("Pageant is not running"),
        [RET_ERR_NOMAP]: new Error("pagent.exe could not create an mmap"),
        [RET_ERR_BINSTDIN]: new Error("pagent.exe could not set mode for stdin"),
        [RET_ERR_BINSTDOUT]: new Error("pagent.exe could not set mode for stdout"),
        [RET_ERR_BADLEN]: new Error("pagent.exe did not get expected input payload")
      };
      function destroy2(stream) {
        stream.buffer = null;
        if (stream.proc) {
          stream.proc.kill();
          stream.proc = void 0;
        }
      }
      class PageantSocket extends Duplex {
        constructor() {
          super();
          this.proc = void 0;
          this.buffer = null;
        }
        _read(n) {
        }
        _write(data, encoding, cb) {
          if (this.buffer === null) {
            this.buffer = data;
          } else {
            const newBuffer = Buffer.allocUnsafe(this.buffer.length + data.length);
            this.buffer.copy(newBuffer, 0);
            data.copy(newBuffer, this.buffer.length);
            this.buffer = newBuffer;
          }
          if (this.buffer.length < 4)
            return cb();
          const len = readUInt32BE(this.buffer, 0);
          if (this.buffer.length - 4 < len)
            return cb();
          data = this.buffer.slice(0, 4 + len);
          if (this.buffer.length > 4 + len)
            return cb(new Error("Unexpected multiple agent requests"));
          this.buffer = null;
          let error;
          const proc = this.proc = spawn(EXEPATH, [data.length]);
          proc.stdout.on("data", (data2) => {
            this.push(data2);
          });
          proc.on("error", (err) => {
            error = err;
            cb(error);
          });
          proc.on("close", (code) => {
            this.proc = void 0;
            if (!error) {
              if (error = ERROR[code])
                return cb(error);
              cb();
            }
          });
          proc.stdin.end(data);
        }
        _final(cb) {
          destroy2(this);
          cb();
        }
        _destroy(err, cb) {
          destroy2(this);
          cb();
        }
      }
      return class PageantAgent extends OpenSSHAgent {
        getStream(cb) {
          cb(null, new PageantSocket());
        }
      };
    })();
    var CygwinAgent = (() => {
      const RE_CYGWIN_SOCK = /^!<socket >(\d+) s ([A-Z0-9]{8}-[A-Z0-9]{8}-[A-Z0-9]{8}-[A-Z0-9]{8})/;
      return class CygwinAgent extends OpenSSHAgent {
        getStream(cb) {
          cb = once(cb);
          let socketPath = this.socketPath;
          let triedCygpath = false;
          readFile(socketPath, function readCygsocket(err, data) {
            if (err) {
              if (triedCygpath)
                return cb(new Error("Invalid cygwin unix socket path"));
              execFile("cygpath", ["-w", socketPath], (err2, stdout, stderr) => {
                if (err2 || stdout.length === 0)
                  return cb(new Error("Invalid cygwin unix socket path"));
                triedCygpath = true;
                socketPath = stdout.toString().replace(/[\r\n]/g, "");
                readFile(socketPath, readCygsocket);
              });
              return;
            }
            const m = RE_CYGWIN_SOCK.exec(data.toString("ascii"));
            if (!m)
              return cb(new Error("Malformed cygwin unix socket file"));
            let state;
            let bc = 0;
            let isRetrying = false;
            const inBuf = [];
            let sock;
            let credsBuf = Buffer.alloc(12);
            const port = parseInt(m[1], 10);
            const secret = m[2].replace(/-/g, "");
            const secretBuf = Buffer.allocUnsafe(16);
            for (let i = 0, j = 0; j < 32; ++i, j += 2)
              secretBuf[i] = parseInt(secret.substring(j, j + 2), 16);
            for (let i = 0; i < 16; i += 4)
              writeUInt32LE(secretBuf, readUInt32BE(secretBuf, i), i);
            tryConnect();
            function _onconnect() {
              bc = 0;
              state = "secret";
              sock.write(secretBuf);
            }
            function _ondata(data2) {
              bc += data2.length;
              if (state === "secret") {
                if (bc === 16) {
                  bc = 0;
                  state = "creds";
                  sock.write(credsBuf);
                }
                return;
              }
              if (state === "creds") {
                if (!isRetrying)
                  inBuf.push(data2);
                if (bc === 12) {
                  sock.removeListener("connect", _onconnect);
                  sock.removeListener("data", _ondata);
                  sock.removeListener("error", onFail);
                  sock.removeListener("end", onFail);
                  sock.removeListener("close", onFail);
                  if (isRetrying)
                    return cb(null, sock);
                  isRetrying = true;
                  credsBuf = Buffer.concat(inBuf);
                  writeUInt32LE(credsBuf, process.pid, 0);
                  sock.on("error", () => {
                  });
                  sock.destroy();
                  tryConnect();
                }
              }
            }
            function onFail() {
              cb(new Error("Problem negotiating cygwin unix socket security"));
            }
            function tryConnect() {
              sock = new Socket();
              sock.on("connect", _onconnect);
              sock.on("data", _ondata);
              sock.on("error", onFail);
              sock.on("end", onFail);
              sock.on("close", onFail);
              sock.connect(port);
            }
          });
        }
      };
    })();
    var WINDOWS_PIPE_REGEX = /^[/\\][/\\]\.[/\\]pipe[/\\].+/;
    function createAgent(path2) {
      if (process.platform === "win32" && !WINDOWS_PIPE_REGEX.test(path2)) {
        return path2 === "pageant" ? new PageantAgent() : new CygwinAgent(path2);
      }
      return new OpenSSHAgent(path2);
    }
    var AgentProtocol = (() => {
      const SSH_AGENTC_REQUEST_IDENTITIES = 11;
      const SSH_AGENTC_SIGN_REQUEST = 13;
      const SSH_AGENT_FAILURE = 5;
      const SSH_AGENT_IDENTITIES_ANSWER = 12;
      const SSH_AGENT_SIGN_RESPONSE = 14;
      const SSH_AGENT_RSA_SHA2_256 = 1 << 1;
      const SSH_AGENT_RSA_SHA2_512 = 1 << 2;
      const ROLE_CLIENT = 0;
      const ROLE_SERVER = 1;
      function processResponses(protocol) {
        let ret;
        while (protocol[SYM_REQS].length) {
          const nextResponse = protocol[SYM_REQS][0][SYM_RESP];
          if (nextResponse === void 0)
            break;
          protocol[SYM_REQS].shift();
          ret = protocol.push(nextResponse);
        }
        return ret;
      }
      const SYM_TYPE = Symbol("Inbound Request Type");
      const SYM_RESP = Symbol("Inbound Request Response");
      const SYM_CTX = Symbol("Inbound Request Context");
      class AgentInboundRequest {
        constructor(type, ctx) {
          this[SYM_TYPE] = type;
          this[SYM_RESP] = void 0;
          this[SYM_CTX] = ctx;
        }
        hasResponded() {
          return this[SYM_RESP] !== void 0;
        }
        getType() {
          return this[SYM_TYPE];
        }
        getContext() {
          return this[SYM_CTX];
        }
      }
      function respond(protocol, req, data) {
        req[SYM_RESP] = data;
        return processResponses(protocol);
      }
      function cleanup(protocol) {
        protocol[SYM_BUFFER] = null;
        if (protocol[SYM_MODE] === ROLE_CLIENT) {
          const reqs = protocol[SYM_REQS];
          if (reqs && reqs.length) {
            protocol[SYM_REQS] = [];
            for (const req of reqs)
              req.cb(new Error("No reply from server"));
          }
        }
        try {
          protocol.end();
        } catch {
        }
        setImmediate(() => {
          if (!protocol[SYM_ENDED])
            protocol.emit("end");
          if (!protocol[SYM_CLOSED])
            protocol.emit("close");
        });
      }
      function onClose() {
        this[SYM_CLOSED] = true;
      }
      function onEnd() {
        this[SYM_ENDED] = true;
      }
      const SYM_REQS = Symbol("Requests");
      const SYM_MODE = Symbol("Agent Protocol Role");
      const SYM_BUFFER = Symbol("Agent Protocol Buffer");
      const SYM_MSGLEN = Symbol("Agent Protocol Current Message Length");
      const SYM_CLOSED = Symbol("Agent Protocol Closed");
      const SYM_ENDED = Symbol("Agent Protocol Ended");
      return class AgentProtocol extends Duplex {
        constructor(isClient) {
          super({ autoDestroy: true, emitClose: false });
          this[SYM_MODE] = isClient ? ROLE_CLIENT : ROLE_SERVER;
          this[SYM_REQS] = [];
          this[SYM_BUFFER] = null;
          this[SYM_MSGLEN] = -1;
          this.once("end", onEnd);
          this.once("close", onClose);
        }
        _read(n) {
        }
        _write(data, encoding, cb) {
          if (this[SYM_BUFFER] === null)
            this[SYM_BUFFER] = data;
          else
            this[SYM_BUFFER] = concat(this[SYM_BUFFER], data);
          let buffer = this[SYM_BUFFER];
          let bufferLen = buffer.length;
          let p = 0;
          while (p < bufferLen) {
            if (bufferLen < 5)
              break;
            if (this[SYM_MSGLEN] === -1)
              this[SYM_MSGLEN] = readUInt32BE(buffer, p);
            if (bufferLen < 4 + this[SYM_MSGLEN])
              break;
            const msgType = buffer[p += 4];
            ++p;
            if (this[SYM_MODE] === ROLE_CLIENT) {
              if (this[SYM_REQS].length === 0)
                return cb(new Error("Received unexpected message from server"));
              const req = this[SYM_REQS].shift();
              switch (msgType) {
                case SSH_AGENT_FAILURE:
                  req.cb(new Error("Agent responded with failure"));
                  break;
                case SSH_AGENT_IDENTITIES_ANSWER: {
                  if (req.type !== SSH_AGENTC_REQUEST_IDENTITIES)
                    return cb(new Error("Agent responded with wrong message type"));
                  binaryParser.init(buffer, p);
                  const numKeys = binaryParser.readUInt32BE();
                  if (numKeys === void 0) {
                    binaryParser.clear();
                    return cb(new Error("Malformed agent response"));
                  }
                  const keys = [];
                  for (let i = 0; i < numKeys; ++i) {
                    let pubKey = binaryParser.readString();
                    if (pubKey === void 0) {
                      binaryParser.clear();
                      return cb(new Error("Malformed agent response"));
                    }
                    const comment = binaryParser.readString(true);
                    if (comment === void 0) {
                      binaryParser.clear();
                      return cb(new Error("Malformed agent response"));
                    }
                    pubKey = parseKey(pubKey);
                    if (pubKey instanceof Error)
                      continue;
                    pubKey.comment = pubKey.comment || comment;
                    keys.push(pubKey);
                  }
                  p = binaryParser.pos();
                  binaryParser.clear();
                  req.cb(null, keys);
                  break;
                }
                case SSH_AGENT_SIGN_RESPONSE: {
                  if (req.type !== SSH_AGENTC_SIGN_REQUEST)
                    return cb(new Error("Agent responded with wrong message type"));
                  binaryParser.init(buffer, p);
                  let signature = binaryParser.readString();
                  p = binaryParser.pos();
                  binaryParser.clear();
                  if (signature === void 0)
                    return cb(new Error("Malformed agent response"));
                  binaryParser.init(signature, 0);
                  binaryParser.readString(true);
                  signature = binaryParser.readString();
                  binaryParser.clear();
                  if (signature === void 0)
                    return cb(new Error("Malformed OpenSSH signature format"));
                  req.cb(null, signature);
                  break;
                }
                default:
                  return cb(new Error("Agent responded with unsupported message type"));
              }
            } else {
              switch (msgType) {
                case SSH_AGENTC_REQUEST_IDENTITIES: {
                  const req = new AgentInboundRequest(msgType);
                  this[SYM_REQS].push(req);
                  this.emit("identities", req);
                  break;
                }
                case SSH_AGENTC_SIGN_REQUEST: {
                  binaryParser.init(buffer, p);
                  let pubKey = binaryParser.readString();
                  const data2 = binaryParser.readString();
                  const flagsVal = binaryParser.readUInt32BE();
                  p = binaryParser.pos();
                  binaryParser.clear();
                  if (flagsVal === void 0) {
                    const req2 = new AgentInboundRequest(msgType);
                    this[SYM_REQS].push(req2);
                    return this.failureReply(req2);
                  }
                  pubKey = parseKey(pubKey);
                  if (pubKey instanceof Error) {
                    const req2 = new AgentInboundRequest(msgType);
                    this[SYM_REQS].push(req2);
                    return this.failureReply(req2);
                  }
                  const flags = {
                    hash: void 0
                  };
                  let ctx;
                  if (pubKey.type === "ssh-rsa") {
                    if (flagsVal & SSH_AGENT_RSA_SHA2_256) {
                      ctx = "rsa-sha2-256";
                      flags.hash = "sha256";
                    } else if (flagsVal & SSH_AGENT_RSA_SHA2_512) {
                      ctx = "rsa-sha2-512";
                      flags.hash = "sha512";
                    }
                  }
                  if (ctx === void 0)
                    ctx = pubKey.type;
                  const req = new AgentInboundRequest(msgType, ctx);
                  this[SYM_REQS].push(req);
                  this.emit("sign", req, pubKey, data2, flags);
                  break;
                }
                default: {
                  const req = new AgentInboundRequest(msgType);
                  this[SYM_REQS].push(req);
                  this.failureReply(req);
                }
              }
            }
            this[SYM_MSGLEN] = -1;
            if (p === bufferLen) {
              this[SYM_BUFFER] = null;
              break;
            } else {
              this[SYM_BUFFER] = buffer = buffer.slice(p);
              bufferLen = buffer.length;
              p = 0;
            }
          }
          cb();
        }
        _destroy(err, cb) {
          cleanup(this);
          cb();
        }
        _final(cb) {
          cleanup(this);
          cb();
        }
        sign(pubKey, data, options, cb) {
          if (this[SYM_MODE] !== ROLE_CLIENT)
            throw new Error("Client-only method called with server role");
          if (typeof options === "function") {
            cb = options;
            options = void 0;
          } else if (typeof options !== "object" || options === null) {
            options = void 0;
          }
          let flags = 0;
          pubKey = parseKey(pubKey);
          if (pubKey instanceof Error)
            throw new Error("Invalid public key argument");
          if (pubKey.type === "ssh-rsa" && options) {
            switch (options.hash) {
              case "sha256":
                flags = SSH_AGENT_RSA_SHA2_256;
                break;
              case "sha512":
                flags = SSH_AGENT_RSA_SHA2_512;
                break;
            }
          }
          pubKey = pubKey.getPublicSSH();
          const type = SSH_AGENTC_SIGN_REQUEST;
          const keyLen = pubKey.length;
          const dataLen = data.length;
          let p = 0;
          const buf = Buffer.allocUnsafe(4 + 1 + 4 + keyLen + 4 + dataLen + 4);
          writeUInt32BE(buf, buf.length - 4, p);
          buf[p += 4] = type;
          writeUInt32BE(buf, keyLen, ++p);
          pubKey.copy(buf, p += 4);
          writeUInt32BE(buf, dataLen, p += keyLen);
          data.copy(buf, p += 4);
          writeUInt32BE(buf, flags, p += dataLen);
          if (typeof cb !== "function")
            cb = noop;
          this[SYM_REQS].push({ type, cb });
          return this.push(buf);
        }
        getIdentities(cb) {
          if (this[SYM_MODE] !== ROLE_CLIENT)
            throw new Error("Client-only method called with server role");
          const type = SSH_AGENTC_REQUEST_IDENTITIES;
          let p = 0;
          const buf = Buffer.allocUnsafe(4 + 1);
          writeUInt32BE(buf, buf.length - 4, p);
          buf[p += 4] = type;
          if (typeof cb !== "function")
            cb = noop;
          this[SYM_REQS].push({ type, cb });
          return this.push(buf);
        }
        failureReply(req) {
          if (this[SYM_MODE] !== ROLE_SERVER)
            throw new Error("Server-only method called with client role");
          if (!(req instanceof AgentInboundRequest))
            throw new Error("Wrong request argument");
          if (req.hasResponded())
            return true;
          let p = 0;
          const buf = Buffer.allocUnsafe(4 + 1);
          writeUInt32BE(buf, buf.length - 4, p);
          buf[p += 4] = SSH_AGENT_FAILURE;
          return respond(this, req, buf);
        }
        getIdentitiesReply(req, keys) {
          if (this[SYM_MODE] !== ROLE_SERVER)
            throw new Error("Server-only method called with client role");
          if (!(req instanceof AgentInboundRequest))
            throw new Error("Wrong request argument");
          if (req.hasResponded())
            return true;
          if (req.getType() !== SSH_AGENTC_REQUEST_IDENTITIES)
            throw new Error("Invalid response to request");
          if (!Array.isArray(keys))
            throw new Error("Keys argument must be an array");
          let totalKeysLen = 4;
          const newKeys = [];
          for (let i = 0; i < keys.length; ++i) {
            const entry = keys[i];
            if (typeof entry !== "object" || entry === null)
              throw new Error(`Invalid key entry: ${entry}`);
            let pubKey;
            let comment;
            if (isParsedKey(entry)) {
              pubKey = entry;
            } else if (isParsedKey(entry.pubKey)) {
              pubKey = entry.pubKey;
            } else {
              if (typeof entry.pubKey !== "object" || entry.pubKey === null)
                continue;
              ({ pubKey, comment } = entry.pubKey);
              pubKey = parseKey(pubKey);
              if (pubKey instanceof Error)
                continue;
            }
            comment = pubKey.comment || comment;
            pubKey = pubKey.getPublicSSH();
            totalKeysLen += 4 + pubKey.length;
            if (comment && typeof comment === "string")
              comment = Buffer.from(comment);
            else if (!Buffer.isBuffer(comment))
              comment = EMPTY_BUF;
            totalKeysLen += 4 + comment.length;
            newKeys.push({ pubKey, comment });
          }
          let p = 0;
          const buf = Buffer.allocUnsafe(4 + 1 + totalKeysLen);
          writeUInt32BE(buf, buf.length - 4, p);
          buf[p += 4] = SSH_AGENT_IDENTITIES_ANSWER;
          writeUInt32BE(buf, newKeys.length, ++p);
          p += 4;
          for (let i = 0; i < newKeys.length; ++i) {
            const { pubKey, comment } = newKeys[i];
            writeUInt32BE(buf, pubKey.length, p);
            pubKey.copy(buf, p += 4);
            writeUInt32BE(buf, comment.length, p += pubKey.length);
            p += 4;
            if (comment.length) {
              comment.copy(buf, p);
              p += comment.length;
            }
          }
          return respond(this, req, buf);
        }
        signReply(req, signature) {
          if (this[SYM_MODE] !== ROLE_SERVER)
            throw new Error("Server-only method called with client role");
          if (!(req instanceof AgentInboundRequest))
            throw new Error("Wrong request argument");
          if (req.hasResponded())
            return true;
          if (req.getType() !== SSH_AGENTC_SIGN_REQUEST)
            throw new Error("Invalid response to request");
          if (!Buffer.isBuffer(signature))
            throw new Error("Signature argument must be a Buffer");
          if (signature.length === 0)
            throw new Error("Signature argument must be non-empty");
          let p = 0;
          const sigFormat = req.getContext();
          const sigFormatLen = Buffer.byteLength(sigFormat);
          const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + sigFormatLen + 4 + signature.length);
          writeUInt32BE(buf, buf.length - 4, p);
          buf[p += 4] = SSH_AGENT_SIGN_RESPONSE;
          writeUInt32BE(buf, 4 + sigFormatLen + 4 + signature.length, ++p);
          writeUInt32BE(buf, sigFormatLen, p += 4);
          buf.utf8Write(sigFormat, p += 4, sigFormatLen);
          writeUInt32BE(buf, signature.length, p += sigFormatLen);
          signature.copy(buf, p += 4);
          return respond(this, req, buf);
        }
      };
    })();
    var SYM_AGENT = Symbol("Agent");
    var SYM_AGENT_KEYS = Symbol("Agent Keys");
    var SYM_AGENT_KEYS_IDX = Symbol("Agent Keys Index");
    var SYM_AGENT_CBS = Symbol("Agent Init Callbacks");
    var AgentContext = class {
      constructor(agent) {
        if (typeof agent === "string")
          agent = createAgent(agent);
        else if (!isAgent(agent))
          throw new Error("Invalid agent argument");
        this[SYM_AGENT] = agent;
        this[SYM_AGENT_KEYS] = null;
        this[SYM_AGENT_KEYS_IDX] = -1;
        this[SYM_AGENT_CBS] = null;
      }
      init(cb) {
        if (typeof cb !== "function")
          cb = noop;
        if (this[SYM_AGENT_KEYS] === null) {
          if (this[SYM_AGENT_CBS] === null) {
            this[SYM_AGENT_CBS] = [cb];
            const doCbs = (...args) => {
              process.nextTick(() => {
                const cbs = this[SYM_AGENT_CBS];
                this[SYM_AGENT_CBS] = null;
                for (const cb2 of cbs)
                  cb2(...args);
              });
            };
            this[SYM_AGENT].getIdentities(once((err, keys) => {
              if (err)
                return doCbs(err);
              if (!Array.isArray(keys)) {
                return doCbs(new Error("Agent implementation failed to provide keys"));
              }
              const newKeys = [];
              for (let key of keys) {
                key = parseKey(key);
                if (key instanceof Error) {
                  continue;
                }
                newKeys.push(key);
              }
              this[SYM_AGENT_KEYS] = newKeys;
              this[SYM_AGENT_KEYS_IDX] = -1;
              doCbs();
            }));
          } else {
            this[SYM_AGENT_CBS].push(cb);
          }
        } else {
          process.nextTick(cb);
        }
      }
      nextKey() {
        if (this[SYM_AGENT_KEYS] === null || ++this[SYM_AGENT_KEYS_IDX] >= this[SYM_AGENT_KEYS].length) {
          return false;
        }
        return this[SYM_AGENT_KEYS][this[SYM_AGENT_KEYS_IDX]];
      }
      currentKey() {
        if (this[SYM_AGENT_KEYS] === null || this[SYM_AGENT_KEYS_IDX] >= this[SYM_AGENT_KEYS].length) {
          return null;
        }
        return this[SYM_AGENT_KEYS][this[SYM_AGENT_KEYS_IDX]];
      }
      pos() {
        if (this[SYM_AGENT_KEYS] === null || this[SYM_AGENT_KEYS_IDX] >= this[SYM_AGENT_KEYS].length) {
          return -1;
        }
        return this[SYM_AGENT_KEYS_IDX];
      }
      reset() {
        this[SYM_AGENT_KEYS_IDX] = -1;
      }
      sign(...args) {
        this[SYM_AGENT].sign(...args);
      }
    };
    function isAgent(val) {
      return val instanceof BaseAgent;
    }
    module2.exports = {
      AgentContext,
      AgentProtocol,
      BaseAgent,
      createAgent,
      CygwinAgent,
      isAgent,
      OpenSSHAgent,
      PageantAgent
    };
  }
});

// node_modules/ssh2/lib/protocol/zlib.js
var require_zlib = __commonJS({
  "node_modules/ssh2/lib/protocol/zlib.js"(exports, module2) {
    "use strict";
    var { kMaxLength } = require("buffer");
    var {
      createInflate,
      constants: {
        DEFLATE,
        INFLATE,
        Z_DEFAULT_CHUNK,
        Z_DEFAULT_COMPRESSION,
        Z_DEFAULT_MEMLEVEL,
        Z_DEFAULT_STRATEGY,
        Z_DEFAULT_WINDOWBITS,
        Z_PARTIAL_FLUSH
      }
    } = require("zlib");
    var ZlibHandle = createInflate()._handle.constructor;
    function processCallback() {
      throw new Error("Should not get here");
    }
    function zlibOnError(message, errno, code) {
      const self2 = this._owner;
      const error = new Error(message);
      error.errno = errno;
      error.code = code;
      self2._err = error;
    }
    function _close(engine) {
      if (!engine._handle)
        return;
      engine._handle.close();
      engine._handle = null;
    }
    var Zlib = class {
      constructor(mode) {
        const windowBits = Z_DEFAULT_WINDOWBITS;
        const level = Z_DEFAULT_COMPRESSION;
        const memLevel = Z_DEFAULT_MEMLEVEL;
        const strategy = Z_DEFAULT_STRATEGY;
        const dictionary = void 0;
        this._err = void 0;
        this._writeState = new Uint32Array(2);
        this._chunkSize = Z_DEFAULT_CHUNK;
        this._maxOutputLength = kMaxLength;
        this._outBuffer = Buffer.allocUnsafe(this._chunkSize);
        this._outOffset = 0;
        this._handle = new ZlibHandle(mode);
        this._handle._owner = this;
        this._handle.onerror = zlibOnError;
        this._handle.init(windowBits, level, memLevel, strategy, this._writeState, processCallback, dictionary);
      }
      writeSync(chunk, retChunks) {
        const handle = this._handle;
        if (!handle)
          throw new Error("Invalid Zlib instance");
        let availInBefore = chunk.length;
        let availOutBefore = this._chunkSize - this._outOffset;
        let inOff = 0;
        let availOutAfter;
        let availInAfter;
        let buffers;
        let nread = 0;
        const state = this._writeState;
        let buffer = this._outBuffer;
        let offset = this._outOffset;
        const chunkSize = this._chunkSize;
        while (true) {
          handle.writeSync(Z_PARTIAL_FLUSH, chunk, inOff, availInBefore, buffer, offset, availOutBefore);
          if (this._err)
            throw this._err;
          availOutAfter = state[0];
          availInAfter = state[1];
          const inDelta = availInBefore - availInAfter;
          const have = availOutBefore - availOutAfter;
          if (have > 0) {
            const out = offset === 0 && have === buffer.length ? buffer : buffer.slice(offset, offset + have);
            offset += have;
            if (!buffers)
              buffers = out;
            else if (buffers.push === void 0)
              buffers = [buffers, out];
            else
              buffers.push(out);
            nread += out.byteLength;
            if (nread > this._maxOutputLength) {
              _close(this);
              throw new Error(`Output length exceeded maximum of ${this._maxOutputLength}`);
            }
          } else if (have !== 0) {
            throw new Error("have should not go down");
          }
          if (availOutAfter === 0 || offset >= chunkSize) {
            availOutBefore = chunkSize;
            offset = 0;
            buffer = Buffer.allocUnsafe(chunkSize);
          }
          if (availOutAfter === 0) {
            inOff += inDelta;
            availInBefore = availInAfter;
          } else {
            break;
          }
        }
        this._outBuffer = buffer;
        this._outOffset = offset;
        if (nread === 0)
          buffers = Buffer.alloc(0);
        if (retChunks) {
          buffers.totalLen = nread;
          return buffers;
        }
        if (buffers.push === void 0)
          return buffers;
        const output = Buffer.allocUnsafe(nread);
        for (let i = 0, p = 0; i < buffers.length; ++i) {
          const buf = buffers[i];
          output.set(buf, p);
          p += buf.length;
        }
        return output;
      }
    };
    var ZlibPacketWriter = class {
      constructor(protocol) {
        this.allocStart = 0;
        this.allocStartKEX = 0;
        this._protocol = protocol;
        this._zlib = new Zlib(DEFLATE);
      }
      cleanup() {
        if (this._zlib)
          _close(this._zlib);
      }
      alloc(payloadSize, force) {
        return Buffer.allocUnsafe(payloadSize);
      }
      finalize(payload, force) {
        if (this._protocol._kexinit === void 0 || force) {
          const output = this._zlib.writeSync(payload, true);
          const packet = this._protocol._cipher.allocPacket(output.totalLen);
          if (output.push === void 0) {
            packet.set(output, 5);
          } else {
            for (let i = 0, p = 5; i < output.length; ++i) {
              const chunk = output[i];
              packet.set(chunk, p);
              p += chunk.length;
            }
          }
          return packet;
        }
        return payload;
      }
    };
    var PacketWriter = class {
      constructor(protocol) {
        this.allocStart = 5;
        this.allocStartKEX = 5;
        this._protocol = protocol;
      }
      cleanup() {
      }
      alloc(payloadSize, force) {
        if (this._protocol._kexinit === void 0 || force)
          return this._protocol._cipher.allocPacket(payloadSize);
        return Buffer.allocUnsafe(payloadSize);
      }
      finalize(packet, force) {
        return packet;
      }
    };
    var ZlibPacketReader = class {
      constructor() {
        this._zlib = new Zlib(INFLATE);
      }
      cleanup() {
        if (this._zlib)
          _close(this._zlib);
      }
      read(data) {
        return this._zlib.writeSync(data, false);
      }
    };
    var PacketReader = class {
      cleanup() {
      }
      read(data) {
        return data;
      }
    };
    module2.exports = {
      PacketReader,
      PacketWriter,
      ZlibPacketReader,
      ZlibPacketWriter
    };
  }
});

// node_modules/ssh2/lib/protocol/handlers.misc.js
var require_handlers_misc = __commonJS({
  "node_modules/ssh2/lib/protocol/handlers.misc.js"(exports, module2) {
    "use strict";
    var {
      bufferSlice,
      bufferParser,
      doFatalError,
      sigSSHToASN1,
      writeUInt32BE
    } = require_utils2();
    var {
      CHANNEL_OPEN_FAILURE,
      COMPAT,
      MESSAGE,
      TERMINAL_MODE
    } = require_constants();
    var {
      parseKey
    } = require_keyParser();
    var TERMINAL_MODE_BY_VALUE = Array.from(Object.entries(TERMINAL_MODE)).reduce((obj, [key, value]) => __spreadProps(__spreadValues({}, obj), { [key]: value }), {});
    module2.exports = {
      [MESSAGE.DISCONNECT]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const reason = bufferParser.readUInt32BE();
        const desc = bufferParser.readString(true);
        const lang = bufferParser.readString();
        bufferParser.clear();
        if (lang === void 0) {
          return doFatalError(self2, "Inbound: Malformed DISCONNECT packet");
        }
        self2._debug && self2._debug(`Inbound: Received DISCONNECT (${reason}, "${desc}")`);
        const handler = self2._handlers.DISCONNECT;
        handler && handler(self2, reason, desc);
      },
      [MESSAGE.IGNORE]: (self2, payload) => {
        self2._debug && self2._debug("Inbound: Received IGNORE");
      },
      [MESSAGE.UNIMPLEMENTED]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const seqno = bufferParser.readUInt32BE();
        bufferParser.clear();
        if (seqno === void 0) {
          return doFatalError(self2, "Inbound: Malformed UNIMPLEMENTED packet");
        }
        self2._debug && self2._debug(`Inbound: Received UNIMPLEMENTED (seqno ${seqno})`);
      },
      [MESSAGE.DEBUG]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const display = bufferParser.readBool();
        const msg = bufferParser.readString(true);
        const lang = bufferParser.readString();
        bufferParser.clear();
        if (lang === void 0) {
          return doFatalError(self2, "Inbound: Malformed DEBUG packet");
        }
        self2._debug && self2._debug("Inbound: Received DEBUG");
        const handler = self2._handlers.DEBUG;
        handler && handler(self2, display, msg);
      },
      [MESSAGE.SERVICE_REQUEST]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const name = bufferParser.readString(true);
        bufferParser.clear();
        if (name === void 0) {
          return doFatalError(self2, "Inbound: Malformed SERVICE_REQUEST packet");
        }
        self2._debug && self2._debug(`Inbound: Received SERVICE_REQUEST (${name})`);
        const handler = self2._handlers.SERVICE_REQUEST;
        handler && handler(self2, name);
      },
      [MESSAGE.SERVICE_ACCEPT]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const name = bufferParser.readString(true);
        bufferParser.clear();
        if (name === void 0) {
          return doFatalError(self2, "Inbound: Malformed SERVICE_ACCEPT packet");
        }
        self2._debug && self2._debug(`Inbound: Received SERVICE_ACCEPT (${name})`);
        const handler = self2._handlers.SERVICE_ACCEPT;
        handler && handler(self2, name);
      },
      [MESSAGE.USERAUTH_REQUEST]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const user = bufferParser.readString(true);
        const service = bufferParser.readString(true);
        const method = bufferParser.readString(true);
        let methodData;
        let methodDesc;
        switch (method) {
          case "none":
            methodData = null;
            break;
          case "password": {
            const isChange = bufferParser.readBool();
            if (isChange !== void 0) {
              methodData = bufferParser.readString(true);
              if (methodData !== void 0 && isChange) {
                const newPassword = bufferParser.readString(true);
                if (newPassword !== void 0)
                  methodData = { oldPassword: methodData, newPassword };
                else
                  methodData = void 0;
              }
            }
            break;
          }
          case "publickey": {
            const hasSig = bufferParser.readBool();
            if (hasSig !== void 0) {
              const keyAlgo = bufferParser.readString(true);
              const key = bufferParser.readString();
              if (hasSig) {
                const blobEnd = bufferParser.pos();
                let signature = bufferParser.readString();
                if (signature !== void 0) {
                  if (signature.length > 4 + keyAlgo.length + 4 && signature.utf8Slice(4, 4 + keyAlgo.length) === keyAlgo) {
                    signature = bufferSlice(signature, 4 + keyAlgo.length + 4);
                  }
                  signature = sigSSHToASN1(signature, keyAlgo);
                  if (signature) {
                    const sessionID = self2._kex.sessionID;
                    const blob = Buffer.allocUnsafe(4 + sessionID.length + blobEnd);
                    writeUInt32BE(blob, sessionID.length, 0);
                    blob.set(sessionID, 4);
                    blob.set(new Uint8Array(payload.buffer, payload.byteOffset, blobEnd), 4 + sessionID.length);
                    methodData = {
                      keyAlgo,
                      key,
                      signature,
                      blob
                    };
                  }
                }
              } else {
                methodData = { keyAlgo, key };
                methodDesc = "publickey -- check";
              }
            }
            break;
          }
          case "hostbased": {
            const keyAlgo = bufferParser.readString(true);
            const key = bufferParser.readString();
            const localHostname = bufferParser.readString(true);
            const localUsername = bufferParser.readString(true);
            const blobEnd = bufferParser.pos();
            let signature = bufferParser.readString();
            if (signature !== void 0) {
              if (signature.length > 4 + keyAlgo.length + 4 && signature.utf8Slice(4, 4 + keyAlgo.length) === keyAlgo) {
                signature = bufferSlice(signature, 4 + keyAlgo.length + 4);
              }
              signature = sigSSHToASN1(signature, keyAlgo);
              if (signature !== void 0) {
                const sessionID = self2._kex.sessionID;
                const blob = Buffer.allocUnsafe(4 + sessionID.length + blobEnd);
                writeUInt32BE(blob, sessionID.length, 0);
                blob.set(sessionID, 4);
                blob.set(new Uint8Array(payload.buffer, payload.byteOffset, blobEnd), 4 + sessionID.length);
                methodData = {
                  keyAlgo,
                  key,
                  signature,
                  blob,
                  localHostname,
                  localUsername
                };
              }
            }
            break;
          }
          case "keyboard-interactive":
            bufferParser.skipString();
            methodData = bufferParser.readList();
            break;
          default:
            if (method !== void 0)
              methodData = bufferParser.readRaw();
        }
        bufferParser.clear();
        if (methodData === void 0) {
          return doFatalError(self2, "Inbound: Malformed USERAUTH_REQUEST packet");
        }
        if (methodDesc === void 0)
          methodDesc = method;
        self2._authsQueue.push(method);
        self2._debug && self2._debug(`Inbound: Received USERAUTH_REQUEST (${methodDesc})`);
        const handler = self2._handlers.USERAUTH_REQUEST;
        handler && handler(self2, user, service, method, methodData);
      },
      [MESSAGE.USERAUTH_FAILURE]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const authMethods = bufferParser.readList();
        const partialSuccess = bufferParser.readBool();
        bufferParser.clear();
        if (partialSuccess === void 0) {
          return doFatalError(self2, "Inbound: Malformed USERAUTH_FAILURE packet");
        }
        self2._debug && self2._debug(`Inbound: Received USERAUTH_FAILURE (${authMethods})`);
        self2._authsQueue.shift();
        const handler = self2._handlers.USERAUTH_FAILURE;
        handler && handler(self2, authMethods, partialSuccess);
      },
      [MESSAGE.USERAUTH_SUCCESS]: (self2, payload) => {
        self2._debug && self2._debug("Inbound: Received USERAUTH_SUCCESS");
        self2._authsQueue.shift();
        const handler = self2._handlers.USERAUTH_SUCCESS;
        handler && handler(self2);
      },
      [MESSAGE.USERAUTH_BANNER]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const msg = bufferParser.readString(true);
        const lang = bufferParser.readString();
        bufferParser.clear();
        if (lang === void 0) {
          return doFatalError(self2, "Inbound: Malformed USERAUTH_BANNER packet");
        }
        self2._debug && self2._debug("Inbound: Received USERAUTH_BANNER");
        const handler = self2._handlers.USERAUTH_BANNER;
        handler && handler(self2, msg);
      },
      60: (self2, payload) => {
        if (!self2._authsQueue.length) {
          self2._debug && self2._debug("Inbound: Received payload type 60 without auth");
          return;
        }
        switch (self2._authsQueue[0]) {
          case "password": {
            bufferParser.init(payload, 1);
            const prompt = bufferParser.readString(true);
            const lang = bufferParser.readString();
            bufferParser.clear();
            if (lang === void 0) {
              return doFatalError(self2, "Inbound: Malformed USERAUTH_PASSWD_CHANGEREQ packet");
            }
            self2._debug && self2._debug("Inbound: Received USERAUTH_PASSWD_CHANGEREQ");
            const handler = self2._handlers.USERAUTH_PASSWD_CHANGEREQ;
            handler && handler(self2, prompt);
            break;
          }
          case "publickey": {
            bufferParser.init(payload, 1);
            const keyAlgo = bufferParser.readString(true);
            const key = bufferParser.readString();
            bufferParser.clear();
            if (key === void 0) {
              return doFatalError(self2, "Inbound: Malformed USERAUTH_PK_OK packet");
            }
            self2._debug && self2._debug("Inbound: Received USERAUTH_PK_OK");
            self2._authsQueue.shift();
            const handler = self2._handlers.USERAUTH_PK_OK;
            handler && handler(self2, keyAlgo, key);
            break;
          }
          case "keyboard-interactive": {
            bufferParser.init(payload, 1);
            const name = bufferParser.readString(true);
            const instructions = bufferParser.readString(true);
            bufferParser.readString();
            const numPrompts = bufferParser.readUInt32BE();
            let prompts;
            if (numPrompts !== void 0) {
              prompts = new Array(numPrompts);
              let i;
              for (i = 0; i < numPrompts; ++i) {
                const prompt = bufferParser.readString(true);
                const echo = bufferParser.readBool();
                if (echo === void 0)
                  break;
                prompts[i] = { prompt, echo };
              }
              if (i !== numPrompts)
                prompts = void 0;
            }
            bufferParser.clear();
            if (prompts === void 0) {
              return doFatalError(self2, "Inbound: Malformed USERAUTH_INFO_REQUEST packet");
            }
            self2._debug && self2._debug("Inbound: Received USERAUTH_INFO_REQUEST");
            const handler = self2._handlers.USERAUTH_INFO_REQUEST;
            handler && handler(self2, name, instructions, prompts);
            break;
          }
          default:
            self2._debug && self2._debug("Inbound: Received unexpected payload type 60");
        }
      },
      61: (self2, payload) => {
        if (!self2._authsQueue.length) {
          self2._debug && self2._debug("Inbound: Received payload type 61 without auth");
          return;
        }
        if (self2._authsQueue[0] !== "keyboard-interactive") {
          return doFatalError(self2, "Inbound: Received unexpected payload type 61");
        }
        bufferParser.init(payload, 1);
        const numResponses = bufferParser.readUInt32BE();
        let responses;
        if (numResponses !== void 0) {
          responses = new Array(numResponses);
          let i;
          for (i = 0; i < numResponses; ++i) {
            const response = bufferParser.readString(true);
            if (response === void 0)
              break;
            responses[i] = response;
          }
          if (i !== numResponses)
            responses = void 0;
        }
        bufferParser.clear();
        if (responses === void 0) {
          return doFatalError(self2, "Inbound: Malformed USERAUTH_INFO_RESPONSE packet");
        }
        self2._debug && self2._debug("Inbound: Received USERAUTH_INFO_RESPONSE");
        const handler = self2._handlers.USERAUTH_INFO_RESPONSE;
        handler && handler(self2, responses);
      },
      [MESSAGE.GLOBAL_REQUEST]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const name = bufferParser.readString(true);
        const wantReply = bufferParser.readBool();
        let data;
        if (wantReply !== void 0) {
          switch (name) {
            case "tcpip-forward":
            case "cancel-tcpip-forward": {
              const bindAddr = bufferParser.readString(true);
              const bindPort = bufferParser.readUInt32BE();
              if (bindPort !== void 0)
                data = { bindAddr, bindPort };
              break;
            }
            case "streamlocal-forward@openssh.com":
            case "cancel-streamlocal-forward@openssh.com": {
              const socketPath = bufferParser.readString(true);
              if (socketPath !== void 0)
                data = { socketPath };
              break;
            }
            case "no-more-sessions@openssh.com":
              data = null;
              break;
            case "hostkeys-00@openssh.com": {
              data = [];
              while (bufferParser.avail() > 0) {
                const keyRaw = bufferParser.readString();
                if (keyRaw === void 0) {
                  data = void 0;
                  break;
                }
                const key = parseKey(keyRaw);
                if (!(key instanceof Error))
                  data.push(key);
              }
              break;
            }
            default:
              data = bufferParser.readRaw();
          }
        }
        bufferParser.clear();
        if (data === void 0) {
          return doFatalError(self2, "Inbound: Malformed GLOBAL_REQUEST packet");
        }
        self2._debug && self2._debug(`Inbound: GLOBAL_REQUEST (${name})`);
        const handler = self2._handlers.GLOBAL_REQUEST;
        if (handler)
          handler(self2, name, wantReply, data);
        else
          self2.requestFailure();
      },
      [MESSAGE.REQUEST_SUCCESS]: (self2, payload) => {
        const data = payload.length > 1 ? bufferSlice(payload, 1) : null;
        self2._debug && self2._debug("Inbound: REQUEST_SUCCESS");
        const handler = self2._handlers.REQUEST_SUCCESS;
        handler && handler(self2, data);
      },
      [MESSAGE.REQUEST_FAILURE]: (self2, payload) => {
        self2._debug && self2._debug("Inbound: Received REQUEST_FAILURE");
        const handler = self2._handlers.REQUEST_FAILURE;
        handler && handler(self2);
      },
      [MESSAGE.CHANNEL_OPEN]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const type = bufferParser.readString(true);
        const sender = bufferParser.readUInt32BE();
        const window2 = bufferParser.readUInt32BE();
        const packetSize = bufferParser.readUInt32BE();
        let channelInfo;
        switch (type) {
          case "forwarded-tcpip":
          case "direct-tcpip": {
            const destIP = bufferParser.readString(true);
            const destPort = bufferParser.readUInt32BE();
            const srcIP = bufferParser.readString(true);
            const srcPort = bufferParser.readUInt32BE();
            if (srcPort !== void 0) {
              channelInfo = {
                type,
                sender,
                window: window2,
                packetSize,
                data: { destIP, destPort, srcIP, srcPort }
              };
            }
            break;
          }
          case "forwarded-streamlocal@openssh.com":
          case "direct-streamlocal@openssh.com": {
            const socketPath = bufferParser.readString(true);
            if (socketPath !== void 0) {
              channelInfo = {
                type,
                sender,
                window: window2,
                packetSize,
                data: { socketPath }
              };
            }
            break;
          }
          case "x11": {
            const srcIP = bufferParser.readString(true);
            const srcPort = bufferParser.readUInt32BE();
            if (srcPort !== void 0) {
              channelInfo = {
                type,
                sender,
                window: window2,
                packetSize,
                data: { srcIP, srcPort }
              };
            }
            break;
          }
          default:
            channelInfo = {
              type,
              sender,
              window: window2,
              packetSize,
              data: {}
            };
        }
        bufferParser.clear();
        if (channelInfo === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_OPEN packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_OPEN (s:${sender}, ${type})`);
        const handler = self2._handlers.CHANNEL_OPEN;
        if (handler) {
          handler(self2, channelInfo);
        } else {
          self2.channelOpenFail(channelInfo.sender, CHANNEL_OPEN_FAILURE.ADMINISTRATIVELY_PROHIBITED, "", "");
        }
      },
      [MESSAGE.CHANNEL_OPEN_CONFIRMATION]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        const sender = bufferParser.readUInt32BE();
        const window2 = bufferParser.readUInt32BE();
        const packetSize = bufferParser.readUInt32BE();
        const data = bufferParser.avail() ? bufferParser.readRaw() : void 0;
        bufferParser.clear();
        if (packetSize === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_OPEN_CONFIRMATION packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_OPEN_CONFIRMATION (r:${recipient}, s:${sender})`);
        const handler = self2._handlers.CHANNEL_OPEN_CONFIRMATION;
        if (handler)
          handler(self2, { recipient, sender, window: window2, packetSize, data });
      },
      [MESSAGE.CHANNEL_OPEN_FAILURE]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        const reason = bufferParser.readUInt32BE();
        const description = bufferParser.readString(true);
        const lang = bufferParser.readString();
        bufferParser.clear();
        if (lang === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_OPEN_FAILURE packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_OPEN_FAILURE (r:${recipient})`);
        const handler = self2._handlers.CHANNEL_OPEN_FAILURE;
        handler && handler(self2, recipient, reason, description);
      },
      [MESSAGE.CHANNEL_WINDOW_ADJUST]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        const bytesToAdd = bufferParser.readUInt32BE();
        bufferParser.clear();
        if (bytesToAdd === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_WINDOW_ADJUST packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_WINDOW_ADJUST (r:${recipient}, ${bytesToAdd})`);
        const handler = self2._handlers.CHANNEL_WINDOW_ADJUST;
        handler && handler(self2, recipient, bytesToAdd);
      },
      [MESSAGE.CHANNEL_DATA]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        const data = bufferParser.readString();
        bufferParser.clear();
        if (data === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_DATA packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_DATA (r:${recipient}, ${data.length})`);
        const handler = self2._handlers.CHANNEL_DATA;
        handler && handler(self2, recipient, data);
      },
      [MESSAGE.CHANNEL_EXTENDED_DATA]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        const type = bufferParser.readUInt32BE();
        const data = bufferParser.readString();
        bufferParser.clear();
        if (data === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_EXTENDED_DATA packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_EXTENDED_DATA (r:${recipient}, ${data.length})`);
        const handler = self2._handlers.CHANNEL_EXTENDED_DATA;
        handler && handler(self2, recipient, data, type);
      },
      [MESSAGE.CHANNEL_EOF]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        bufferParser.clear();
        if (recipient === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_EOF packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_EOF (r:${recipient})`);
        const handler = self2._handlers.CHANNEL_EOF;
        handler && handler(self2, recipient);
      },
      [MESSAGE.CHANNEL_CLOSE]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        bufferParser.clear();
        if (recipient === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_CLOSE packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_CLOSE (r:${recipient})`);
        const handler = self2._handlers.CHANNEL_CLOSE;
        handler && handler(self2, recipient);
      },
      [MESSAGE.CHANNEL_REQUEST]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        const type = bufferParser.readString(true);
        const wantReply = bufferParser.readBool();
        let data;
        if (wantReply !== void 0) {
          switch (type) {
            case "exit-status":
              data = bufferParser.readUInt32BE();
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type}: ${data})`);
              break;
            case "exit-signal": {
              let signal;
              let coreDumped;
              if (self2._compatFlags & COMPAT.OLD_EXIT) {
                const num = bufferParser.readUInt32BE();
                switch (num) {
                  case 1:
                    signal = "HUP";
                    break;
                  case 2:
                    signal = "INT";
                    break;
                  case 3:
                    signal = "QUIT";
                    break;
                  case 6:
                    signal = "ABRT";
                    break;
                  case 9:
                    signal = "KILL";
                    break;
                  case 14:
                    signal = "ALRM";
                    break;
                  case 15:
                    signal = "TERM";
                    break;
                  default:
                    if (num !== void 0) {
                      signal = `UNKNOWN (${num})`;
                    }
                }
                coreDumped = false;
              } else {
                signal = bufferParser.readString(true);
                coreDumped = bufferParser.readBool();
                if (coreDumped === void 0)
                  signal = void 0;
              }
              const errorMessage = bufferParser.readString(true);
              if (bufferParser.skipString() !== void 0)
                data = { signal, coreDumped, errorMessage };
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type}: ${signal})`);
              break;
            }
            case "pty-req": {
              const term = bufferParser.readString(true);
              const cols = bufferParser.readUInt32BE();
              const rows = bufferParser.readUInt32BE();
              const width = bufferParser.readUInt32BE();
              const height = bufferParser.readUInt32BE();
              const modesBinary = bufferParser.readString();
              if (modesBinary !== void 0) {
                bufferParser.init(modesBinary, 1);
                let modes = {};
                while (bufferParser.avail()) {
                  const opcode = bufferParser.readByte();
                  if (opcode === TERMINAL_MODE.TTY_OP_END)
                    break;
                  const name = TERMINAL_MODE_BY_VALUE[opcode];
                  const value = bufferParser.readUInt32BE();
                  if (opcode === void 0 || name === void 0 || value === void 0) {
                    modes = void 0;
                    break;
                  }
                  modes[name] = value;
                }
                if (modes !== void 0)
                  data = { term, cols, rows, width, height, modes };
              }
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type})`);
              break;
            }
            case "window-change": {
              const cols = bufferParser.readUInt32BE();
              const rows = bufferParser.readUInt32BE();
              const width = bufferParser.readUInt32BE();
              const height = bufferParser.readUInt32BE();
              if (height !== void 0)
                data = { cols, rows, width, height };
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type})`);
              break;
            }
            case "x11-req": {
              const single = bufferParser.readBool();
              const protocol = bufferParser.readString(true);
              const cookie = bufferParser.readString();
              const screen = bufferParser.readUInt32BE();
              if (screen !== void 0)
                data = { single, protocol, cookie, screen };
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type})`);
              break;
            }
            case "env": {
              const name = bufferParser.readString(true);
              const value = bufferParser.readString(true);
              if (value !== void 0)
                data = { name, value };
              if (self2._debug) {
                self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type}: ${name}=${value})`);
              }
              break;
            }
            case "shell":
              data = null;
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type})`);
              break;
            case "exec":
              data = bufferParser.readString(true);
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type}: ${data})`);
              break;
            case "subsystem":
              data = bufferParser.readString(true);
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type}: ${data})`);
              break;
            case "signal":
              data = bufferParser.readString(true);
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type}: ${data})`);
              break;
            case "xon-xoff":
              data = bufferParser.readBool();
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type}: ${data})`);
              break;
            case "auth-agent-req@openssh.com":
              data = null;
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type})`);
              break;
            default:
              data = bufferParser.avail() ? bufferParser.readRaw() : null;
              self2._debug && self2._debug(`Inbound: CHANNEL_REQUEST (r:${recipient}, ${type})`);
          }
        }
        bufferParser.clear();
        if (data === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_REQUEST packet");
        }
        const handler = self2._handlers.CHANNEL_REQUEST;
        handler && handler(self2, recipient, type, wantReply, data);
      },
      [MESSAGE.CHANNEL_SUCCESS]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        bufferParser.clear();
        if (recipient === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_SUCCESS packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_SUCCESS (r:${recipient})`);
        const handler = self2._handlers.CHANNEL_SUCCESS;
        handler && handler(self2, recipient);
      },
      [MESSAGE.CHANNEL_FAILURE]: (self2, payload) => {
        bufferParser.init(payload, 1);
        const recipient = bufferParser.readUInt32BE();
        bufferParser.clear();
        if (recipient === void 0) {
          return doFatalError(self2, "Inbound: Malformed CHANNEL_FAILURE packet");
        }
        self2._debug && self2._debug(`Inbound: CHANNEL_FAILURE (r:${recipient})`);
        const handler = self2._handlers.CHANNEL_FAILURE;
        handler && handler(self2, recipient);
      }
    };
  }
});

// node_modules/ssh2/lib/protocol/handlers.js
var require_handlers = __commonJS({
  "node_modules/ssh2/lib/protocol/handlers.js"(exports, module2) {
    "use strict";
    var MESSAGE_HANDLERS = new Array(256);
    [
      require_kex().HANDLERS,
      require_handlers_misc()
    ].forEach((handlers) => {
      for (let [type, handler] of Object.entries(handlers)) {
        type = +type;
        if (isFinite(type) && type >= 0 && type < MESSAGE_HANDLERS.length)
          MESSAGE_HANDLERS[type] = handler;
      }
    });
    module2.exports = MESSAGE_HANDLERS;
  }
});

// node_modules/ssh2/lib/protocol/kex.js
var require_kex = __commonJS({
  "node_modules/ssh2/lib/protocol/kex.js"(exports, module2) {
    "use strict";
    var {
      createDiffieHellman,
      createDiffieHellmanGroup,
      createECDH,
      createHash,
      createPublicKey,
      diffieHellman,
      generateKeyPairSync,
      randomFillSync
    } = require("crypto");
    var { Ber } = require_lib();
    var {
      COMPAT,
      curve25519Supported,
      DEFAULT_KEX,
      DEFAULT_SERVER_HOST_KEY,
      DEFAULT_CIPHER,
      DEFAULT_MAC,
      DEFAULT_COMPRESSION,
      DISCONNECT_REASON,
      MESSAGE
    } = require_constants();
    var {
      CIPHER_INFO,
      createCipher,
      createDecipher,
      MAC_INFO
    } = require_crypto();
    var { parseDERKey } = require_keyParser();
    var {
      bufferFill,
      bufferParser,
      convertSignature,
      doFatalError,
      FastBuffer,
      sigSSHToASN1,
      writeUInt32BE
    } = require_utils2();
    var {
      PacketReader,
      PacketWriter,
      ZlibPacketReader,
      ZlibPacketWriter
    } = require_zlib();
    var MESSAGE_HANDLERS;
    var GEX_MIN_BITS = 2048;
    var GEX_MAX_BITS = 8192;
    var EMPTY_BUFFER = Buffer.alloc(0);
    function kexinit(self2) {
      let payload;
      if (self2._compatFlags & COMPAT.BAD_DHGEX) {
        const entry = self2._offer.lists.kex;
        let kex = entry.array;
        let found = false;
        for (let i = 0; i < kex.length; ++i) {
          if (kex[i].includes("group-exchange")) {
            if (!found) {
              found = true;
              kex = kex.slice();
            }
            kex.splice(i--, 1);
          }
        }
        if (found) {
          let len = 1 + 16 + self2._offer.totalSize + 1 + 4;
          const newKexBuf = Buffer.from(kex.join(","));
          len -= entry.buffer.length - newKexBuf.length;
          const all = self2._offer.lists.all;
          const rest = new Uint8Array(all.buffer, all.byteOffset + 4 + entry.buffer.length, all.length - (4 + entry.buffer.length));
          payload = Buffer.allocUnsafe(len);
          writeUInt32BE(payload, newKexBuf.length, 17);
          payload.set(newKexBuf, 17 + 4);
          payload.set(rest, 17 + 4 + newKexBuf.length);
        }
      }
      if (payload === void 0) {
        payload = Buffer.allocUnsafe(1 + 16 + self2._offer.totalSize + 1 + 4);
        self2._offer.copyAllTo(payload, 17);
      }
      self2._debug && self2._debug("Outbound: Sending KEXINIT");
      payload[0] = MESSAGE.KEXINIT;
      randomFillSync(payload, 1, 16);
      bufferFill(payload, 0, payload.length - 5);
      self2._kexinit = payload;
      self2._packetRW.write.allocStart = 0;
      {
        const p = self2._packetRW.write.allocStartKEX;
        const packet = self2._packetRW.write.alloc(payload.length, true);
        packet.set(payload, p);
        self2._cipher.encrypt(self2._packetRW.write.finalize(packet, true));
      }
    }
    function handleKexInit(self2, payload) {
      const init2 = {
        kex: void 0,
        serverHostKey: void 0,
        cs: {
          cipher: void 0,
          mac: void 0,
          compress: void 0,
          lang: void 0
        },
        sc: {
          cipher: void 0,
          mac: void 0,
          compress: void 0,
          lang: void 0
        }
      };
      bufferParser.init(payload, 17);
      if ((init2.kex = bufferParser.readList()) === void 0 || (init2.serverHostKey = bufferParser.readList()) === void 0 || (init2.cs.cipher = bufferParser.readList()) === void 0 || (init2.sc.cipher = bufferParser.readList()) === void 0 || (init2.cs.mac = bufferParser.readList()) === void 0 || (init2.sc.mac = bufferParser.readList()) === void 0 || (init2.cs.compress = bufferParser.readList()) === void 0 || (init2.sc.compress = bufferParser.readList()) === void 0 || (init2.cs.lang = bufferParser.readList()) === void 0 || (init2.sc.lang = bufferParser.readList()) === void 0) {
        bufferParser.clear();
        return doFatalError(self2, "Received malformed KEXINIT", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
      }
      const pos = bufferParser.pos();
      const firstFollows = pos < payload.length && payload[pos] === 1;
      bufferParser.clear();
      const local = self2._offer;
      const remote = init2;
      let localKex = local.lists.kex.array;
      if (self2._compatFlags & COMPAT.BAD_DHGEX) {
        let found = false;
        for (let i2 = 0; i2 < localKex.length; ++i2) {
          if (localKex[i2].indexOf("group-exchange") !== -1) {
            if (!found) {
              found = true;
              localKex = localKex.slice();
            }
            localKex.splice(i2--, 1);
          }
        }
      }
      let clientList;
      let serverList;
      let i;
      const debug = self2._debug;
      debug && debug("Inbound: Handshake in progress");
      debug && debug(`Handshake: (local) KEX method: ${localKex}`);
      debug && debug(`Handshake: (remote) KEX method: ${remote.kex}`);
      if (self2._server) {
        serverList = localKex;
        clientList = remote.kex;
      } else {
        serverList = remote.kex;
        clientList = localKex;
      }
      for (i = 0; i < clientList.length && serverList.indexOf(clientList[i]) === -1; ++i)
        ;
      if (i === clientList.length) {
        debug && debug("Handshake: No matching key exchange algorithm");
        return doFatalError(self2, "Handshake failed: no matching key exchange algorithm", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
      }
      init2.kex = clientList[i];
      debug && debug(`Handshake: KEX algorithm: ${clientList[i]}`);
      if (firstFollows && (!remote.kex.length || clientList[i] !== remote.kex[0])) {
        self2._skipNextInboundPacket = true;
      }
      const localSrvHostKey = local.lists.serverHostKey.array;
      debug && debug(`Handshake: (local) Host key format: ${localSrvHostKey}`);
      debug && debug(`Handshake: (remote) Host key format: ${remote.serverHostKey}`);
      if (self2._server) {
        serverList = localSrvHostKey;
        clientList = remote.serverHostKey;
      } else {
        serverList = remote.serverHostKey;
        clientList = localSrvHostKey;
      }
      for (i = 0; i < clientList.length && serverList.indexOf(clientList[i]) === -1; ++i)
        ;
      if (i === clientList.length) {
        debug && debug("Handshake: No matching host key format");
        return doFatalError(self2, "Handshake failed: no matching host key format", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
      }
      init2.serverHostKey = clientList[i];
      debug && debug(`Handshake: Host key format: ${clientList[i]}`);
      const localCSCipher = local.lists.cs.cipher.array;
      debug && debug(`Handshake: (local) C->S cipher: ${localCSCipher}`);
      debug && debug(`Handshake: (remote) C->S cipher: ${remote.cs.cipher}`);
      if (self2._server) {
        serverList = localCSCipher;
        clientList = remote.cs.cipher;
      } else {
        serverList = remote.cs.cipher;
        clientList = localCSCipher;
      }
      for (i = 0; i < clientList.length && serverList.indexOf(clientList[i]) === -1; ++i)
        ;
      if (i === clientList.length) {
        debug && debug("Handshake: No matching C->S cipher");
        return doFatalError(self2, "Handshake failed: no matching C->S cipher", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
      }
      init2.cs.cipher = clientList[i];
      debug && debug(`Handshake: C->S Cipher: ${clientList[i]}`);
      const localSCCipher = local.lists.sc.cipher.array;
      debug && debug(`Handshake: (local) S->C cipher: ${localSCCipher}`);
      debug && debug(`Handshake: (remote) S->C cipher: ${remote.sc.cipher}`);
      if (self2._server) {
        serverList = localSCCipher;
        clientList = remote.sc.cipher;
      } else {
        serverList = remote.sc.cipher;
        clientList = localSCCipher;
      }
      for (i = 0; i < clientList.length && serverList.indexOf(clientList[i]) === -1; ++i)
        ;
      if (i === clientList.length) {
        debug && debug("Handshake: No matching S->C cipher");
        return doFatalError(self2, "Handshake failed: no matching S->C cipher", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
      }
      init2.sc.cipher = clientList[i];
      debug && debug(`Handshake: S->C cipher: ${clientList[i]}`);
      const localCSMAC = local.lists.cs.mac.array;
      debug && debug(`Handshake: (local) C->S MAC: ${localCSMAC}`);
      debug && debug(`Handshake: (remote) C->S MAC: ${remote.cs.mac}`);
      if (CIPHER_INFO[init2.cs.cipher].authLen > 0) {
        init2.cs.mac = "";
        debug && debug("Handshake: C->S MAC: <implicit>");
      } else {
        if (self2._server) {
          serverList = localCSMAC;
          clientList = remote.cs.mac;
        } else {
          serverList = remote.cs.mac;
          clientList = localCSMAC;
        }
        for (i = 0; i < clientList.length && serverList.indexOf(clientList[i]) === -1; ++i)
          ;
        if (i === clientList.length) {
          debug && debug("Handshake: No matching C->S MAC");
          return doFatalError(self2, "Handshake failed: no matching C->S MAC", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
        }
        init2.cs.mac = clientList[i];
        debug && debug(`Handshake: C->S MAC: ${clientList[i]}`);
      }
      const localSCMAC = local.lists.sc.mac.array;
      debug && debug(`Handshake: (local) S->C MAC: ${localSCMAC}`);
      debug && debug(`Handshake: (remote) S->C MAC: ${remote.sc.mac}`);
      if (CIPHER_INFO[init2.sc.cipher].authLen > 0) {
        init2.sc.mac = "";
        debug && debug("Handshake: S->C MAC: <implicit>");
      } else {
        if (self2._server) {
          serverList = localSCMAC;
          clientList = remote.sc.mac;
        } else {
          serverList = remote.sc.mac;
          clientList = localSCMAC;
        }
        for (i = 0; i < clientList.length && serverList.indexOf(clientList[i]) === -1; ++i)
          ;
        if (i === clientList.length) {
          debug && debug("Handshake: No matching S->C MAC");
          return doFatalError(self2, "Handshake failed: no matching S->C MAC", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
        }
        init2.sc.mac = clientList[i];
        debug && debug(`Handshake: S->C MAC: ${clientList[i]}`);
      }
      const localCSCompress = local.lists.cs.compress.array;
      debug && debug(`Handshake: (local) C->S compression: ${localCSCompress}`);
      debug && debug(`Handshake: (remote) C->S compression: ${remote.cs.compress}`);
      if (self2._server) {
        serverList = localCSCompress;
        clientList = remote.cs.compress;
      } else {
        serverList = remote.cs.compress;
        clientList = localCSCompress;
      }
      for (i = 0; i < clientList.length && serverList.indexOf(clientList[i]) === -1; ++i)
        ;
      if (i === clientList.length) {
        debug && debug("Handshake: No matching C->S compression");
        return doFatalError(self2, "Handshake failed: no matching C->S compression", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
      }
      init2.cs.compress = clientList[i];
      debug && debug(`Handshake: C->S compression: ${clientList[i]}`);
      const localSCCompress = local.lists.sc.compress.array;
      debug && debug(`Handshake: (local) S->C compression: ${localSCCompress}`);
      debug && debug(`Handshake: (remote) S->C compression: ${remote.sc.compress}`);
      if (self2._server) {
        serverList = localSCCompress;
        clientList = remote.sc.compress;
      } else {
        serverList = remote.sc.compress;
        clientList = localSCCompress;
      }
      for (i = 0; i < clientList.length && serverList.indexOf(clientList[i]) === -1; ++i)
        ;
      if (i === clientList.length) {
        debug && debug("Handshake: No matching S->C compression");
        return doFatalError(self2, "Handshake failed: no matching S->C compression", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
      }
      init2.sc.compress = clientList[i];
      debug && debug(`Handshake: S->C compression: ${clientList[i]}`);
      init2.cs.lang = "";
      init2.sc.lang = "";
      if (self2._kex) {
        if (!self2._kexinit) {
          kexinit(self2);
        }
        self2._decipher._onPayload = onKEXPayload.bind(self2, { firstPacket: false });
      }
      self2._kex = createKeyExchange(init2, self2, payload);
      self2._kex.start();
    }
    var createKeyExchange = (() => {
      function convertToMpint(buf) {
        let idx = 0;
        let length = buf.length;
        while (buf[idx] === 0) {
          ++idx;
          --length;
        }
        let newBuf;
        if (buf[idx] & 128) {
          newBuf = Buffer.allocUnsafe(1 + length);
          newBuf[0] = 0;
          buf.copy(newBuf, 1, idx);
          buf = newBuf;
        } else if (length !== buf.length) {
          newBuf = Buffer.allocUnsafe(length);
          buf.copy(newBuf, 0, idx);
          buf = newBuf;
        }
        return buf;
      }
      class KeyExchange {
        constructor(negotiated, protocol, remoteKexinit) {
          this._protocol = protocol;
          this.sessionID = protocol._kex ? protocol._kex.sessionID : void 0;
          this.negotiated = negotiated;
          this._step = 1;
          this._public = null;
          this._dh = null;
          this._sentNEWKEYS = false;
          this._receivedNEWKEYS = false;
          this._finished = false;
          this._hostVerified = false;
          this._kexinit = protocol._kexinit;
          this._remoteKexinit = remoteKexinit;
          this._identRaw = protocol._identRaw;
          this._remoteIdentRaw = protocol._remoteIdentRaw;
          this._hostKey = void 0;
          this._dhData = void 0;
          this._sig = void 0;
        }
        finish() {
          if (this._finished)
            return false;
          this._finished = true;
          const isServer = this._protocol._server;
          const negotiated = this.negotiated;
          const pubKey = this.convertPublicKey(this._dhData);
          let secret = this.computeSecret(this._dhData);
          if (secret instanceof Error) {
            secret.message = `Error while computing DH secret (${this.type}): ${secret.message}`;
            secret.level = "handshake";
            return doFatalError(this._protocol, secret, DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
          }
          const hash = createHash(this.hashName);
          hashString(hash, isServer ? this._remoteIdentRaw : this._identRaw);
          hashString(hash, isServer ? this._identRaw : this._remoteIdentRaw);
          hashString(hash, isServer ? this._remoteKexinit : this._kexinit);
          hashString(hash, isServer ? this._kexinit : this._remoteKexinit);
          const serverPublicHostKey = isServer ? this._hostKey.getPublicSSH() : this._hostKey;
          hashString(hash, serverPublicHostKey);
          if (this.type === "groupex") {
            const params = this.getDHParams();
            const num = Buffer.allocUnsafe(4);
            writeUInt32BE(num, this._minBits, 0);
            hash.update(num);
            writeUInt32BE(num, this._prefBits, 0);
            hash.update(num);
            writeUInt32BE(num, this._maxBits, 0);
            hash.update(num);
            hashString(hash, params.prime);
            hashString(hash, params.generator);
          }
          hashString(hash, isServer ? pubKey : this.getPublicKey());
          const serverPublicKey = isServer ? this.getPublicKey() : pubKey;
          hashString(hash, serverPublicKey);
          hashString(hash, secret);
          const exchangeHash = hash.digest();
          if (!isServer) {
            bufferParser.init(this._sig, 0);
            const sigType = bufferParser.readString(true);
            if (!sigType) {
              return doFatalError(this._protocol, "Malformed packet while reading signature", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
            }
            if (sigType !== negotiated.serverHostKey) {
              return doFatalError(this._protocol, `Wrong signature type: ${sigType}, expected: ${negotiated.serverHostKey}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
            }
            let sigValue = bufferParser.readString();
            bufferParser.clear();
            if (sigValue === void 0) {
              return doFatalError(this._protocol, "Malformed packet while reading signature", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
            }
            if (!(sigValue = sigSSHToASN1(sigValue, sigType))) {
              return doFatalError(this._protocol, "Malformed signature", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
            }
            let parsedHostKey;
            {
              bufferParser.init(this._hostKey, 0);
              const name = bufferParser.readString(true);
              const hostKey = this._hostKey.slice(bufferParser.pos());
              bufferParser.clear();
              parsedHostKey = parseDERKey(hostKey, name);
              if (parsedHostKey instanceof Error) {
                parsedHostKey.level = "handshake";
                return doFatalError(this._protocol, parsedHostKey, DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
              }
            }
            let hashAlgo;
            switch (this.negotiated.serverHostKey) {
              case "rsa-sha2-256":
                hashAlgo = "sha256";
                break;
              case "rsa-sha2-512":
                hashAlgo = "sha512";
                break;
            }
            this._protocol._debug && this._protocol._debug("Verifying signature ...");
            const verified = parsedHostKey.verify(exchangeHash, sigValue, hashAlgo);
            if (verified !== true) {
              if (verified instanceof Error) {
                this._protocol._debug && this._protocol._debug(`Signature verification failed: ${verified.stack}`);
              } else {
                this._protocol._debug && this._protocol._debug("Signature verification failed");
              }
              return doFatalError(this._protocol, "Handshake failed: signature verification failed", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
            }
            this._protocol._debug && this._protocol._debug("Verified signature");
          } else {
            let hashAlgo;
            switch (this.negotiated.serverHostKey) {
              case "rsa-sha2-256":
                hashAlgo = "sha256";
                break;
              case "rsa-sha2-512":
                hashAlgo = "sha512";
                break;
            }
            this._protocol._debug && this._protocol._debug("Generating signature ...");
            let signature = this._hostKey.sign(exchangeHash, hashAlgo);
            if (signature instanceof Error) {
              return doFatalError(this._protocol, `Handshake failed: signature generation failed for ${this._hostKey.type} host key: ${signature.message}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
            }
            signature = convertSignature(signature, this._hostKey.type);
            if (signature === false) {
              return doFatalError(this._protocol, `Handshake failed: signature conversion failed for ${this._hostKey.type} host key`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
            }
            const sigType = this.negotiated.serverHostKey;
            const sigTypeLen = Buffer.byteLength(sigType);
            const sigLen = 4 + sigTypeLen + 4 + signature.length;
            let p = this._protocol._packetRW.write.allocStartKEX;
            const packet = this._protocol._packetRW.write.alloc(1 + 4 + serverPublicHostKey.length + 4 + serverPublicKey.length + 4 + sigLen, true);
            packet[p] = MESSAGE.KEXDH_REPLY;
            writeUInt32BE(packet, serverPublicHostKey.length, ++p);
            packet.set(serverPublicHostKey, p += 4);
            writeUInt32BE(packet, serverPublicKey.length, p += serverPublicHostKey.length);
            packet.set(serverPublicKey, p += 4);
            writeUInt32BE(packet, sigLen, p += serverPublicKey.length);
            writeUInt32BE(packet, sigTypeLen, p += 4);
            packet.utf8Write(sigType, p += 4, sigTypeLen);
            writeUInt32BE(packet, signature.length, p += sigTypeLen);
            packet.set(signature, p += 4);
            if (this._protocol._debug) {
              let type;
              switch (this.type) {
                case "group":
                  type = "KEXDH_REPLY";
                  break;
                case "groupex":
                  type = "KEXDH_GEX_REPLY";
                  break;
                default:
                  type = "KEXECDH_REPLY";
              }
              this._protocol._debug(`Outbound: Sending ${type}`);
            }
            this._protocol._cipher.encrypt(this._protocol._packetRW.write.finalize(packet, true));
          }
          trySendNEWKEYS(this);
          const completeHandshake = () => {
            if (!this.sessionID)
              this.sessionID = exchangeHash;
            {
              const newSecret = Buffer.allocUnsafe(4 + secret.length);
              writeUInt32BE(newSecret, secret.length, 0);
              newSecret.set(secret, 4);
              secret = newSecret;
            }
            const csCipherInfo = CIPHER_INFO[negotiated.cs.cipher];
            const scCipherInfo = CIPHER_INFO[negotiated.sc.cipher];
            const csIV = generateKEXVal(csCipherInfo.ivLen, this.hashName, secret, exchangeHash, this.sessionID, "A");
            const scIV = generateKEXVal(scCipherInfo.ivLen, this.hashName, secret, exchangeHash, this.sessionID, "B");
            const csKey = generateKEXVal(csCipherInfo.keyLen, this.hashName, secret, exchangeHash, this.sessionID, "C");
            const scKey = generateKEXVal(scCipherInfo.keyLen, this.hashName, secret, exchangeHash, this.sessionID, "D");
            let csMacInfo;
            let csMacKey;
            if (!csCipherInfo.authLen) {
              csMacInfo = MAC_INFO[negotiated.cs.mac];
              csMacKey = generateKEXVal(csMacInfo.len, this.hashName, secret, exchangeHash, this.sessionID, "E");
            }
            let scMacInfo;
            let scMacKey;
            if (!scCipherInfo.authLen) {
              scMacInfo = MAC_INFO[negotiated.sc.mac];
              scMacKey = generateKEXVal(scMacInfo.len, this.hashName, secret, exchangeHash, this.sessionID, "F");
            }
            const config = {
              inbound: {
                onPayload: this._protocol._onPayload,
                seqno: this._protocol._decipher.inSeqno,
                decipherInfo: !isServer ? scCipherInfo : csCipherInfo,
                decipherIV: !isServer ? scIV : csIV,
                decipherKey: !isServer ? scKey : csKey,
                macInfo: !isServer ? scMacInfo : csMacInfo,
                macKey: !isServer ? scMacKey : csMacKey
              },
              outbound: {
                onWrite: this._protocol._onWrite,
                seqno: this._protocol._cipher.outSeqno,
                cipherInfo: isServer ? scCipherInfo : csCipherInfo,
                cipherIV: isServer ? scIV : csIV,
                cipherKey: isServer ? scKey : csKey,
                macInfo: isServer ? scMacInfo : csMacInfo,
                macKey: isServer ? scMacKey : csMacKey
              }
            };
            this._protocol._cipher && this._protocol._cipher.free();
            this._protocol._decipher && this._protocol._decipher.free();
            this._protocol._cipher = createCipher(config);
            this._protocol._decipher = createDecipher(config);
            const rw = {
              read: void 0,
              write: void 0
            };
            switch (negotiated.cs.compress) {
              case "zlib":
                if (isServer)
                  rw.read = new ZlibPacketReader();
                else
                  rw.write = new ZlibPacketWriter(this._protocol);
                break;
              case "zlib@openssh.com":
                if (this._protocol._authenticated) {
                  if (isServer)
                    rw.read = new ZlibPacketReader();
                  else
                    rw.write = new ZlibPacketWriter(this._protocol);
                  break;
                }
              default:
                if (isServer)
                  rw.read = new PacketReader();
                else
                  rw.write = new PacketWriter(this._protocol);
            }
            switch (negotiated.sc.compress) {
              case "zlib":
                if (isServer)
                  rw.write = new ZlibPacketWriter(this._protocol);
                else
                  rw.read = new ZlibPacketReader();
                break;
              case "zlib@openssh.com":
                if (this._protocol._authenticated) {
                  if (isServer)
                    rw.write = new ZlibPacketWriter(this._protocol);
                  else
                    rw.read = new ZlibPacketReader();
                  break;
                }
              default:
                if (isServer)
                  rw.write = new PacketWriter(this._protocol);
                else
                  rw.read = new PacketReader();
            }
            this._protocol._packetRW.read.cleanup();
            this._protocol._packetRW.write.cleanup();
            this._protocol._packetRW = rw;
            this._public = null;
            this._dh = null;
            this._kexinit = this._protocol._kexinit = void 0;
            this._remoteKexinit = void 0;
            this._identRaw = void 0;
            this._remoteIdentRaw = void 0;
            this._hostKey = void 0;
            this._dhData = void 0;
            this._sig = void 0;
            this._protocol._onHandshakeComplete(negotiated);
            return false;
          };
          if (!isServer)
            return completeHandshake();
          this.finish = completeHandshake;
        }
        start() {
          if (!this._protocol._server) {
            if (this._protocol._debug) {
              let type;
              switch (this.type) {
                case "group":
                  type = "KEXDH_INIT";
                  break;
                default:
                  type = "KEXECDH_INIT";
              }
              this._protocol._debug(`Outbound: Sending ${type}`);
            }
            const pubKey = this.getPublicKey();
            let p = this._protocol._packetRW.write.allocStartKEX;
            const packet = this._protocol._packetRW.write.alloc(1 + 4 + pubKey.length, true);
            packet[p] = MESSAGE.KEXDH_INIT;
            writeUInt32BE(packet, pubKey.length, ++p);
            packet.set(pubKey, p += 4);
            this._protocol._cipher.encrypt(this._protocol._packetRW.write.finalize(packet, true));
          }
        }
        getPublicKey() {
          this.generateKeys();
          const key = this._public;
          if (key)
            return this.convertPublicKey(key);
        }
        convertPublicKey(key) {
          let newKey;
          let idx = 0;
          let len = key.length;
          while (key[idx] === 0) {
            ++idx;
            --len;
          }
          if (key[idx] & 128) {
            newKey = Buffer.allocUnsafe(1 + len);
            newKey[0] = 0;
            key.copy(newKey, 1, idx);
            return newKey;
          }
          if (len !== key.length) {
            newKey = Buffer.allocUnsafe(len);
            key.copy(newKey, 0, idx);
            key = newKey;
          }
          return key;
        }
        computeSecret(otherPublicKey) {
          this.generateKeys();
          try {
            return convertToMpint(this._dh.computeSecret(otherPublicKey));
          } catch (ex) {
            return ex;
          }
        }
        parse(payload) {
          const type = payload[0];
          switch (this._step) {
            case 1:
              if (this._protocol._server) {
                if (type !== MESSAGE.KEXDH_INIT) {
                  return doFatalError(this._protocol, `Received packet ${type} instead of ${MESSAGE.KEXDH_INIT}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                }
                this._protocol._debug && this._protocol._debug("Received DH Init");
                bufferParser.init(payload, 1);
                const dhData = bufferParser.readString();
                bufferParser.clear();
                if (dhData === void 0) {
                  return doFatalError(this._protocol, "Received malformed KEX*_INIT", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                }
                this._dhData = dhData;
                let hostKey = this._protocol._hostKeys[this.negotiated.serverHostKey];
                if (Array.isArray(hostKey))
                  hostKey = hostKey[0];
                this._hostKey = hostKey;
                this.finish();
              } else {
                if (type !== MESSAGE.KEXDH_REPLY) {
                  return doFatalError(this._protocol, `Received packet ${type} instead of ${MESSAGE.KEXDH_REPLY}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                }
                this._protocol._debug && this._protocol._debug("Received DH Reply");
                bufferParser.init(payload, 1);
                let hostPubKey;
                let dhData;
                let sig;
                if ((hostPubKey = bufferParser.readString()) === void 0 || (dhData = bufferParser.readString()) === void 0 || (sig = bufferParser.readString()) === void 0) {
                  bufferParser.clear();
                  return doFatalError(this._protocol, "Received malformed KEX*_REPLY", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                }
                bufferParser.clear();
                bufferParser.init(hostPubKey, 0);
                const hostPubKeyType = bufferParser.readString(true);
                bufferParser.clear();
                if (hostPubKeyType === void 0) {
                  return doFatalError(this._protocol, "Received malformed host public key", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                }
                if (hostPubKeyType !== this.negotiated.serverHostKey) {
                  switch (this.negotiated.serverHostKey) {
                    case "rsa-sha2-256":
                    case "rsa-sha2-512":
                      if (hostPubKeyType === "ssh-rsa")
                        break;
                    default:
                      return doFatalError(this._protocol, "Host key does not match negotiated type", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                  }
                }
                this._hostKey = hostPubKey;
                this._dhData = dhData;
                this._sig = sig;
                let checked = false;
                let ret;
                if (this._protocol._hostVerifier === void 0) {
                  ret = true;
                  this._protocol._debug && this._protocol._debug("Host accepted by default (no verification)");
                } else {
                  ret = this._protocol._hostVerifier(hostPubKey, (permitted) => {
                    if (checked)
                      return;
                    checked = true;
                    if (permitted === false) {
                      this._protocol._debug && this._protocol._debug("Host denied (verification failed)");
                      return doFatalError(this._protocol, "Host denied (verification failed)", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                    }
                    this._protocol._debug && this._protocol._debug("Host accepted (verified)");
                    this._hostVerified = true;
                    if (this._receivedNEWKEYS)
                      this.finish();
                    else
                      trySendNEWKEYS(this);
                  });
                }
                if (ret === void 0) {
                  ++this._step;
                  return;
                }
                checked = true;
                if (ret === false) {
                  this._protocol._debug && this._protocol._debug("Host denied (verification failed)");
                  return doFatalError(this._protocol, "Host denied (verification failed)", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                }
                this._protocol._debug && this._protocol._debug("Host accepted (verified)");
                this._hostVerified = true;
                trySendNEWKEYS(this);
              }
              ++this._step;
              break;
            case 2:
              if (type !== MESSAGE.NEWKEYS) {
                return doFatalError(this._protocol, `Received packet ${type} instead of ${MESSAGE.NEWKEYS}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
              }
              this._protocol._debug && this._protocol._debug("Inbound: NEWKEYS");
              this._receivedNEWKEYS = true;
              ++this._step;
              if (this._protocol._server || this._hostVerified)
                return this.finish();
              return false;
            default:
              return doFatalError(this._protocol, `Received unexpected packet ${type} after NEWKEYS`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
          }
        }
      }
      class Curve25519Exchange extends KeyExchange {
        constructor(hashName, ...args) {
          super(...args);
          this.type = "25519";
          this.hashName = hashName;
          this._keys = null;
        }
        generateKeys() {
          if (!this._keys)
            this._keys = generateKeyPairSync("x25519");
        }
        getPublicKey() {
          this.generateKeys();
          const key = this._keys.publicKey.export({ type: "spki", format: "der" });
          return key.slice(-32);
        }
        convertPublicKey(key) {
          let newKey;
          let idx = 0;
          let len = key.length;
          while (key[idx] === 0) {
            ++idx;
            --len;
          }
          if (key.length === 32)
            return key;
          if (len !== key.length) {
            newKey = Buffer.allocUnsafe(len);
            key.copy(newKey, 0, idx);
            key = newKey;
          }
          return key;
        }
        computeSecret(otherPublicKey) {
          this.generateKeys();
          try {
            const asnWriter = new Ber.Writer();
            asnWriter.startSequence();
            asnWriter.startSequence();
            asnWriter.writeOID("1.3.101.110");
            asnWriter.endSequence();
            asnWriter.startSequence(Ber.BitString);
            asnWriter.writeByte(0);
            asnWriter._ensure(otherPublicKey.length);
            otherPublicKey.copy(asnWriter._buf, asnWriter._offset, 0, otherPublicKey.length);
            asnWriter._offset += otherPublicKey.length;
            asnWriter.endSequence();
            asnWriter.endSequence();
            return convertToMpint(diffieHellman({
              privateKey: this._keys.privateKey,
              publicKey: createPublicKey({
                key: asnWriter.buffer,
                type: "spki",
                format: "der"
              })
            }));
          } catch (ex) {
            return ex;
          }
        }
      }
      class ECDHExchange extends KeyExchange {
        constructor(curveName, hashName, ...args) {
          super(...args);
          this.type = "ecdh";
          this.curveName = curveName;
          this.hashName = hashName;
        }
        generateKeys() {
          if (!this._dh) {
            this._dh = createECDH(this.curveName);
            this._public = this._dh.generateKeys();
          }
        }
      }
      class DHGroupExchange extends KeyExchange {
        constructor(hashName, ...args) {
          super(...args);
          this.type = "groupex";
          this.hashName = hashName;
          this._prime = null;
          this._generator = null;
          this._minBits = GEX_MIN_BITS;
          this._prefBits = dhEstimate(this.negotiated);
          if (this._protocol._compatFlags & COMPAT.BUG_DHGEX_LARGE)
            this._prefBits = Math.min(this._prefBits, 4096);
          this._maxBits = GEX_MAX_BITS;
        }
        start() {
          if (this._protocol._server)
            return;
          this._protocol._debug && this._protocol._debug("Outbound: Sending KEXDH_GEX_REQUEST");
          let p = this._protocol._packetRW.write.allocStartKEX;
          const packet = this._protocol._packetRW.write.alloc(1 + 4 + 4 + 4, true);
          packet[p] = MESSAGE.KEXDH_GEX_REQUEST;
          writeUInt32BE(packet, this._minBits, ++p);
          writeUInt32BE(packet, this._prefBits, p += 4);
          writeUInt32BE(packet, this._maxBits, p += 4);
          this._protocol._cipher.encrypt(this._protocol._packetRW.write.finalize(packet, true));
        }
        generateKeys() {
          if (!this._dh && this._prime && this._generator) {
            this._dh = createDiffieHellman(this._prime, this._generator);
            this._public = this._dh.generateKeys();
          }
        }
        setDHParams(prime, generator) {
          if (!Buffer.isBuffer(prime))
            throw new Error("Invalid prime value");
          if (!Buffer.isBuffer(generator))
            throw new Error("Invalid generator value");
          this._prime = prime;
          this._generator = generator;
        }
        getDHParams() {
          if (this._dh) {
            return {
              prime: convertToMpint(this._dh.getPrime()),
              generator: convertToMpint(this._dh.getGenerator())
            };
          }
        }
        parse(payload) {
          const type = payload[0];
          switch (this._step) {
            case 1:
              if (this._protocol._server) {
                if (type !== MESSAGE.KEXDH_GEX_REQUEST) {
                  return doFatalError(this._protocol, `Received packet ${type} instead of ` + MESSAGE.KEXDH_GEX_REQUEST, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                }
                return doFatalError(this._protocol, "Group exchange not implemented for server", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
              }
              if (type !== MESSAGE.KEXDH_GEX_GROUP) {
                return doFatalError(this._protocol, `Received packet ${type} instead of ${MESSAGE.KEXDH_GEX_GROUP}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
              }
              this._protocol._debug && this._protocol._debug("Received DH GEX Group");
              bufferParser.init(payload, 1);
              let prime;
              let gen;
              if ((prime = bufferParser.readString()) === void 0 || (gen = bufferParser.readString()) === void 0) {
                bufferParser.clear();
                return doFatalError(this._protocol, "Received malformed KEXDH_GEX_GROUP", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
              }
              bufferParser.clear();
              this.setDHParams(prime, gen);
              this.generateKeys();
              const pubkey = this.getPublicKey();
              this._protocol._debug && this._protocol._debug("Outbound: Sending KEXDH_GEX_INIT");
              let p = this._protocol._packetRW.write.allocStartKEX;
              const packet = this._protocol._packetRW.write.alloc(1 + 4 + pubkey.length, true);
              packet[p] = MESSAGE.KEXDH_GEX_INIT;
              writeUInt32BE(packet, pubkey.length, ++p);
              packet.set(pubkey, p += 4);
              this._protocol._cipher.encrypt(this._protocol._packetRW.write.finalize(packet, true));
              ++this._step;
              break;
            case 2:
              if (this._protocol._server) {
                if (type !== MESSAGE.KEXDH_GEX_INIT) {
                  return doFatalError(this._protocol, `Received packet ${type} instead of ${MESSAGE.KEXDH_GEX_INIT}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
                }
                this._protocol._debug && this._protocol._debug("Received DH GEX Init");
                return doFatalError(this._protocol, "Group exchange not implemented for server", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
              } else if (type !== MESSAGE.KEXDH_GEX_REPLY) {
                return doFatalError(this._protocol, `Received packet ${type} instead of ${MESSAGE.KEXDH_GEX_REPLY}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
              }
              this._protocol._debug && this._protocol._debug("Received DH GEX Reply");
              this._step = 1;
              payload[0] = MESSAGE.KEXDH_REPLY;
              this.parse = KeyExchange.prototype.parse;
              this.parse(payload);
          }
        }
      }
      class DHExchange extends KeyExchange {
        constructor(groupName, hashName, ...args) {
          super(...args);
          this.type = "group";
          this.groupName = groupName;
          this.hashName = hashName;
        }
        start() {
          if (!this._protocol._server) {
            this._protocol._debug && this._protocol._debug("Outbound: Sending KEXDH_INIT");
            const pubKey = this.getPublicKey();
            let p = this._protocol._packetRW.write.allocStartKEX;
            const packet = this._protocol._packetRW.write.alloc(1 + 4 + pubKey.length, true);
            packet[p] = MESSAGE.KEXDH_INIT;
            writeUInt32BE(packet, pubKey.length, ++p);
            packet.set(pubKey, p += 4);
            this._protocol._cipher.encrypt(this._protocol._packetRW.write.finalize(packet, true));
          }
        }
        generateKeys() {
          if (!this._dh) {
            this._dh = createDiffieHellmanGroup(this.groupName);
            this._public = this._dh.generateKeys();
          }
        }
        getDHParams() {
          if (this._dh) {
            return {
              prime: convertToMpint(this._dh.getPrime()),
              generator: convertToMpint(this._dh.getGenerator())
            };
          }
        }
      }
      return (negotiated, ...args) => {
        if (typeof negotiated !== "object" || negotiated === null)
          throw new Error("Invalid negotiated argument");
        const kexType = negotiated.kex;
        if (typeof kexType === "string") {
          args = [negotiated, ...args];
          switch (kexType) {
            case "curve25519-sha256":
            case "curve25519-sha256@libssh.org":
              if (!curve25519Supported)
                break;
              return new Curve25519Exchange("sha256", ...args);
            case "ecdh-sha2-nistp256":
              return new ECDHExchange("prime256v1", "sha256", ...args);
            case "ecdh-sha2-nistp384":
              return new ECDHExchange("secp384r1", "sha384", ...args);
            case "ecdh-sha2-nistp521":
              return new ECDHExchange("secp521r1", "sha512", ...args);
            case "diffie-hellman-group1-sha1":
              return new DHExchange("modp2", "sha1", ...args);
            case "diffie-hellman-group14-sha1":
              return new DHExchange("modp14", "sha1", ...args);
            case "diffie-hellman-group14-sha256":
              return new DHExchange("modp14", "sha256", ...args);
            case "diffie-hellman-group15-sha512":
              return new DHExchange("modp15", "sha512", ...args);
            case "diffie-hellman-group16-sha512":
              return new DHExchange("modp16", "sha512", ...args);
            case "diffie-hellman-group17-sha512":
              return new DHExchange("modp17", "sha512", ...args);
            case "diffie-hellman-group18-sha512":
              return new DHExchange("modp18", "sha512", ...args);
            case "diffie-hellman-group-exchange-sha1":
              return new DHGroupExchange("sha1", ...args);
            case "diffie-hellman-group-exchange-sha256":
              return new DHGroupExchange("sha256", ...args);
          }
          throw new Error(`Unsupported key exchange algorithm: ${kexType}`);
        }
        throw new Error(`Invalid key exchange type: ${kexType}`);
      };
    })();
    var KexInit = (() => {
      const KEX_PROPERTY_NAMES = [
        "kex",
        "serverHostKey",
        ["cs", "cipher"],
        ["sc", "cipher"],
        ["cs", "mac"],
        ["sc", "mac"],
        ["cs", "compress"],
        ["sc", "compress"],
        ["cs", "lang"],
        ["sc", "lang"]
      ];
      return class KexInit {
        constructor(obj) {
          if (typeof obj !== "object" || obj === null)
            throw new TypeError("Argument must be an object");
          const lists = {
            kex: void 0,
            serverHostKey: void 0,
            cs: {
              cipher: void 0,
              mac: void 0,
              compress: void 0,
              lang: void 0
            },
            sc: {
              cipher: void 0,
              mac: void 0,
              compress: void 0,
              lang: void 0
            },
            all: void 0
          };
          let totalSize = 0;
          for (const prop of KEX_PROPERTY_NAMES) {
            let base;
            let val;
            let desc;
            let key;
            if (typeof prop === "string") {
              base = lists;
              val = obj[prop];
              desc = key = prop;
            } else {
              const parent = prop[0];
              base = lists[parent];
              key = prop[1];
              val = obj[parent][key];
              desc = `${parent}.${key}`;
            }
            const entry = { array: void 0, buffer: void 0 };
            if (Buffer.isBuffer(val)) {
              entry.array = ("" + val).split(",");
              entry.buffer = val;
              totalSize += 4 + val.length;
            } else {
              if (typeof val === "string")
                val = val.split(",");
              if (Array.isArray(val)) {
                entry.array = val;
                entry.buffer = Buffer.from(val.join(","));
              } else {
                throw new TypeError(`Invalid \`${desc}\` type: ${typeof val}`);
              }
              totalSize += 4 + entry.buffer.length;
            }
            base[key] = entry;
          }
          const all = Buffer.allocUnsafe(totalSize);
          lists.all = all;
          let allPos = 0;
          for (const prop of KEX_PROPERTY_NAMES) {
            let data;
            if (typeof prop === "string")
              data = lists[prop].buffer;
            else
              data = lists[prop[0]][prop[1]].buffer;
            allPos = writeUInt32BE(all, data.length, allPos);
            all.set(data, allPos);
            allPos += data.length;
          }
          this.totalSize = totalSize;
          this.lists = lists;
        }
        copyAllTo(buf, offset) {
          const src = this.lists.all;
          if (typeof offset !== "number")
            throw new TypeError(`Invalid offset value: ${typeof offset}`);
          if (buf.length - offset < src.length)
            throw new Error("Insufficient space to copy list");
          buf.set(src, offset);
          return src.length;
        }
      };
    })();
    var hashString = (() => {
      const LEN = Buffer.allocUnsafe(4);
      return (hash, buf) => {
        writeUInt32BE(LEN, buf.length, 0);
        hash.update(LEN);
        hash.update(buf);
      };
    })();
    function generateKEXVal(len, hashName, secret, exchangeHash, sessionID, char) {
      let ret;
      if (len) {
        let digest = createHash(hashName).update(secret).update(exchangeHash).update(char).update(sessionID).digest();
        while (digest.length < len) {
          const chunk = createHash(hashName).update(secret).update(exchangeHash).update(digest).digest();
          const extended = Buffer.allocUnsafe(digest.length + chunk.length);
          extended.set(digest, 0);
          extended.set(chunk, digest.length);
          digest = extended;
        }
        if (digest.length === len)
          ret = digest;
        else
          ret = new FastBuffer(digest.buffer, digest.byteOffset, len);
      } else {
        ret = EMPTY_BUFFER;
      }
      return ret;
    }
    function onKEXPayload(state, payload) {
      if (payload.length === 0) {
        this._debug && this._debug("Inbound: Skipping empty packet payload");
        return;
      }
      if (this._skipNextInboundPacket) {
        this._skipNextInboundPacket = false;
        return;
      }
      payload = this._packetRW.read.read(payload);
      const type = payload[0];
      switch (type) {
        case MESSAGE.DISCONNECT:
        case MESSAGE.IGNORE:
        case MESSAGE.UNIMPLEMENTED:
        case MESSAGE.DEBUG:
          if (!MESSAGE_HANDLERS)
            MESSAGE_HANDLERS = require_handlers();
          return MESSAGE_HANDLERS[type](this, payload);
        case MESSAGE.KEXINIT:
          if (!state.firstPacket) {
            return doFatalError(this, "Received extra KEXINIT during handshake", "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
          }
          state.firstPacket = false;
          return handleKexInit(this, payload);
        default:
          if (type < 20 || type > 49) {
            return doFatalError(this, `Received unexpected packet type ${type}`, "handshake", DISCONNECT_REASON.KEY_EXCHANGE_FAILED);
          }
      }
      return this._kex.parse(payload);
    }
    function dhEstimate(neg) {
      const csCipher = CIPHER_INFO[neg.cs.cipher];
      const scCipher = CIPHER_INFO[neg.sc.cipher];
      const bits = Math.max(0, csCipher.sslName === "des-ede3-cbc" ? 14 : csCipher.keyLen, csCipher.blockLen, csCipher.ivLen, scCipher.sslName === "des-ede3-cbc" ? 14 : scCipher.keyLen, scCipher.blockLen, scCipher.ivLen) * 8;
      if (bits <= 112)
        return 2048;
      if (bits <= 128)
        return 3072;
      if (bits <= 192)
        return 7680;
      return 8192;
    }
    function trySendNEWKEYS(kex) {
      if (!kex._sentNEWKEYS) {
        kex._protocol._debug && kex._protocol._debug("Outbound: Sending NEWKEYS");
        const p = kex._protocol._packetRW.write.allocStartKEX;
        const packet = kex._protocol._packetRW.write.alloc(1, true);
        packet[p] = MESSAGE.NEWKEYS;
        kex._protocol._cipher.encrypt(kex._protocol._packetRW.write.finalize(packet, true));
        kex._sentNEWKEYS = true;
      }
    }
    module2.exports = {
      KexInit,
      kexinit,
      onKEXPayload,
      DEFAULT_KEXINIT: new KexInit({
        kex: DEFAULT_KEX,
        serverHostKey: DEFAULT_SERVER_HOST_KEY,
        cs: {
          cipher: DEFAULT_CIPHER,
          mac: DEFAULT_MAC,
          compress: DEFAULT_COMPRESSION,
          lang: []
        },
        sc: {
          cipher: DEFAULT_CIPHER,
          mac: DEFAULT_MAC,
          compress: DEFAULT_COMPRESSION,
          lang: []
        }
      }),
      HANDLERS: {
        [MESSAGE.KEXINIT]: handleKexInit
      }
    };
  }
});

// node_modules/ssh2/package.json
var require_package = __commonJS({
  "node_modules/ssh2/package.json"(exports, module2) {
    module2.exports = {
      name: "ssh2",
      version: "1.10.0",
      author: "Brian White <mscdex@mscdex.net>",
      description: "SSH2 client and server modules written in pure JavaScript for node.js",
      main: "./lib/index.js",
      engines: {
        node: ">=10.16.0"
      },
      dependencies: {
        asn1: "^0.2.4",
        "bcrypt-pbkdf": "^1.0.2"
      },
      devDependencies: {
        "@mscdex/eslint-config": "^1.0.0",
        eslint: "^7.0.0"
      },
      optionalDependencies: {
        "cpu-features": "~0.0.4",
        nan: "^2.15.0"
      },
      scripts: {
        install: "node install.js",
        rebuild: "node install.js",
        test: "node test/test.js",
        lint: "eslint --cache --report-unused-disable-directives --ext=.js .eslintrc.js examples lib test",
        "lint:fix": "npm run lint -- --fix"
      },
      keywords: [
        "ssh",
        "ssh2",
        "sftp",
        "secure",
        "shell",
        "exec",
        "remote",
        "client"
      ],
      licenses: [
        {
          type: "MIT",
          url: "http://github.com/mscdex/ssh2/raw/master/LICENSE"
        }
      ],
      repository: {
        type: "git",
        url: "http://github.com/mscdex/ssh2.git"
      }
    };
  }
});

// node_modules/ssh2/lib/protocol/Protocol.js
var require_Protocol = __commonJS({
  "node_modules/ssh2/lib/protocol/Protocol.js"(exports, module2) {
    "use strict";
    var { inspect } = require("util");
    var { bindingAvailable, NullCipher, NullDecipher } = require_crypto();
    var {
      COMPAT_CHECKS,
      DISCONNECT_REASON,
      MESSAGE,
      SIGNALS,
      TERMINAL_MODE
    } = require_constants();
    var {
      DEFAULT_KEXINIT,
      KexInit,
      kexinit,
      onKEXPayload
    } = require_kex();
    var {
      parseKey
    } = require_keyParser();
    var MESSAGE_HANDLERS = require_handlers();
    var {
      bufferCopy,
      bufferFill,
      bufferSlice,
      convertSignature,
      sendPacket,
      writeUInt32BE
    } = require_utils2();
    var {
      PacketReader,
      PacketWriter,
      ZlibPacketReader,
      ZlibPacketWriter
    } = require_zlib();
    var MODULE_VER = require_package().version;
    var VALID_DISCONNECT_REASONS = new Map(Object.values(DISCONNECT_REASON).map((n) => [n, 1]));
    var IDENT_RAW = Buffer.from(`SSH-2.0-ssh2js${MODULE_VER}`);
    var IDENT = Buffer.from(`${IDENT_RAW}\r
`);
    var MAX_LINE_LEN = 8192;
    var MAX_LINES = 1024;
    var PING_PAYLOAD = Buffer.from([
      MESSAGE.GLOBAL_REQUEST,
      0,
      0,
      0,
      21,
      107,
      101,
      101,
      112,
      97,
      108,
      105,
      118,
      101,
      64,
      111,
      112,
      101,
      110,
      115,
      115,
      104,
      46,
      99,
      111,
      109,
      1
    ]);
    var NO_TERMINAL_MODES_BUFFER = Buffer.from([TERMINAL_MODE.TTY_OP_END]);
    function noop() {
    }
    var Protocol = class {
      constructor(config) {
        const onWrite = config.onWrite;
        if (typeof onWrite !== "function")
          throw new Error("Missing onWrite function");
        this._onWrite = (data) => {
          onWrite(data);
        };
        const onError = config.onError;
        if (typeof onError !== "function")
          throw new Error("Missing onError function");
        this._onError = (err) => {
          onError(err);
        };
        const debug = config.debug;
        this._debug = typeof debug === "function" ? (msg) => {
          debug(msg);
        } : void 0;
        const onHeader = config.onHeader;
        this._onHeader = typeof onHeader === "function" ? (...args) => {
          onHeader(...args);
        } : noop;
        const onPacket = config.onPacket;
        this._onPacket = typeof onPacket === "function" ? () => {
          onPacket();
        } : noop;
        let onHandshakeComplete = config.onHandshakeComplete;
        if (typeof onHandshakeComplete !== "function")
          onHandshakeComplete = noop;
        this._onHandshakeComplete = (...args) => {
          this._debug && this._debug("Handshake completed");
          const oldQueue = this._queue;
          if (oldQueue) {
            this._queue = void 0;
            this._debug && this._debug(`Draining outbound queue (${oldQueue.length}) ...`);
            for (let i = 0; i < oldQueue.length; ++i) {
              const data = oldQueue[i];
              let finalized = this._packetRW.write.finalize(data);
              if (finalized === data) {
                const packet = this._cipher.allocPacket(data.length);
                packet.set(data, 5);
                finalized = packet;
              }
              sendPacket(this, finalized);
            }
            this._debug && this._debug("... finished draining outbound queue");
          }
          onHandshakeComplete(...args);
        };
        this._queue = void 0;
        const messageHandlers = config.messageHandlers;
        if (typeof messageHandlers === "object" && messageHandlers !== null)
          this._handlers = messageHandlers;
        else
          this._handlers = {};
        this._onPayload = onPayload.bind(this);
        this._server = !!config.server;
        this._banner = void 0;
        let greeting;
        if (this._server) {
          if (typeof config.hostKeys !== "object" || config.hostKeys === null)
            throw new Error("Missing server host key(s)");
          this._hostKeys = config.hostKeys;
          if (typeof config.greeting === "string" && config.greeting.length) {
            greeting = config.greeting.slice(-2) === "\r\n" ? config.greeting : `${config.greeting}\r
`;
          }
          if (typeof config.banner === "string" && config.banner.length) {
            this._banner = config.banner.slice(-2) === "\r\n" ? config.banner : `${config.banner}\r
`;
          }
        } else {
          this._hostKeys = void 0;
        }
        let offer = config.offer;
        if (typeof offer !== "object" || offer === null)
          offer = DEFAULT_KEXINIT;
        else if (offer.constructor !== KexInit)
          offer = new KexInit(offer);
        this._kex = void 0;
        this._kexinit = void 0;
        this._offer = offer;
        this._cipher = new NullCipher(0, this._onWrite);
        this._decipher = void 0;
        this._skipNextInboundPacket = false;
        this._packetRW = {
          read: new PacketReader(),
          write: new PacketWriter(this)
        };
        this._hostVerifier = !this._server && typeof config.hostVerifier === "function" ? config.hostVerifier : void 0;
        this._parse = parseHeader;
        this._buffer = void 0;
        this._authsQueue = [];
        this._authenticated = false;
        this._remoteIdentRaw = void 0;
        let sentIdent;
        if (typeof config.ident === "string") {
          this._identRaw = Buffer.from(`SSH-2.0-${config.ident}`);
          sentIdent = Buffer.allocUnsafe(this._identRaw.length + 2);
          sentIdent.set(this._identRaw, 0);
          sentIdent[sentIdent.length - 2] = 13;
          sentIdent[sentIdent.length - 1] = 10;
        } else if (Buffer.isBuffer(config.ident)) {
          const fullIdent = Buffer.allocUnsafe(8 + config.ident.length);
          fullIdent.latin1Write("SSH-2.0-", 0, 8);
          fullIdent.set(config.ident, 8);
          this._identRaw = fullIdent;
          sentIdent = Buffer.allocUnsafe(fullIdent.length + 2);
          sentIdent.set(fullIdent, 0);
          sentIdent[sentIdent.length - 2] = 13;
          sentIdent[sentIdent.length - 1] = 10;
        } else {
          this._identRaw = IDENT_RAW;
          sentIdent = IDENT;
        }
        this._compatFlags = 0;
        if (this._debug) {
          if (bindingAvailable)
            this._debug("Custom crypto binding available");
          else
            this._debug("Custom crypto binding not available");
        }
        this._debug && this._debug(`Local ident: ${inspect(this._identRaw.toString())}`);
        this.start = () => {
          this.start = void 0;
          if (greeting)
            this._onWrite(greeting);
          this._onWrite(sentIdent);
        };
      }
      _destruct(reason) {
        this._packetRW.read.cleanup();
        this._packetRW.write.cleanup();
        this._cipher && this._cipher.free();
        this._decipher && this._decipher.free();
        if (typeof reason !== "string" || reason.length === 0)
          reason = "fatal error";
        this.parse = () => {
          throw new Error(`Instance unusable after ${reason}`);
        };
        this._onWrite = () => {
          throw new Error(`Instance unusable after ${reason}`);
        };
        this._destruct = void 0;
      }
      cleanup() {
        this._destruct && this._destruct();
      }
      parse(chunk, i, len) {
        while (i < len)
          i = this._parse(chunk, i, len);
      }
      disconnect(reason) {
        const pktLen = 1 + 4 + 4 + 4;
        let p = this._packetRW.write.allocStartKEX;
        const packet = this._packetRW.write.alloc(pktLen, true);
        const end = p + pktLen;
        if (!VALID_DISCONNECT_REASONS.has(reason))
          reason = DISCONNECT_REASON.PROTOCOL_ERROR;
        packet[p] = MESSAGE.DISCONNECT;
        writeUInt32BE(packet, reason, ++p);
        packet.fill(0, p += 4, end);
        this._debug && this._debug(`Outbound: Sending DISCONNECT (${reason})`);
        sendPacket(this, this._packetRW.write.finalize(packet, true), true);
      }
      ping() {
        const p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(PING_PAYLOAD.length);
        packet.set(PING_PAYLOAD, p);
        this._debug && this._debug("Outbound: Sending ping (GLOBAL_REQUEST: keepalive@openssh.com)");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      rekey() {
        if (this._kexinit === void 0) {
          this._debug && this._debug("Outbound: Initiated explicit rekey");
          this._queue = [];
          kexinit(this);
        } else {
          this._debug && this._debug("Outbound: Ignoring rekey during handshake");
        }
      }
      requestSuccess(data) {
        let p = this._packetRW.write.allocStart;
        let packet;
        if (Buffer.isBuffer(data)) {
          packet = this._packetRW.write.alloc(1 + data.length);
          packet[p] = MESSAGE.REQUEST_SUCCESS;
          packet.set(data, ++p);
        } else {
          packet = this._packetRW.write.alloc(1);
          packet[p] = MESSAGE.REQUEST_SUCCESS;
        }
        this._debug && this._debug("Outbound: Sending REQUEST_SUCCESS");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      requestFailure() {
        const p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1);
        packet[p] = MESSAGE.REQUEST_FAILURE;
        this._debug && this._debug("Outbound: Sending REQUEST_FAILURE");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelSuccess(chan) {
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4);
        packet[p] = MESSAGE.CHANNEL_SUCCESS;
        writeUInt32BE(packet, chan, ++p);
        this._debug && this._debug(`Outbound: Sending CHANNEL_SUCCESS (r:${chan})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelFailure(chan) {
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4);
        packet[p] = MESSAGE.CHANNEL_FAILURE;
        writeUInt32BE(packet, chan, ++p);
        this._debug && this._debug(`Outbound: Sending CHANNEL_FAILURE (r:${chan})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelEOF(chan) {
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4);
        packet[p] = MESSAGE.CHANNEL_EOF;
        writeUInt32BE(packet, chan, ++p);
        this._debug && this._debug(`Outbound: Sending CHANNEL_EOF (r:${chan})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelClose(chan) {
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4);
        packet[p] = MESSAGE.CHANNEL_CLOSE;
        writeUInt32BE(packet, chan, ++p);
        this._debug && this._debug(`Outbound: Sending CHANNEL_CLOSE (r:${chan})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelWindowAdjust(chan, amount) {
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4);
        packet[p] = MESSAGE.CHANNEL_WINDOW_ADJUST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, amount, p += 4);
        this._debug && this._debug(`Outbound: Sending CHANNEL_WINDOW_ADJUST (r:${chan}, ${amount})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelData(chan, data) {
        const isBuffer = Buffer.isBuffer(data);
        const dataLen = isBuffer ? data.length : Buffer.byteLength(data);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + dataLen);
        packet[p] = MESSAGE.CHANNEL_DATA;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, dataLen, p += 4);
        if (isBuffer)
          packet.set(data, p += 4);
        else
          packet.utf8Write(data, p += 4, dataLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_DATA (r:${chan}, ${dataLen})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelExtData(chan, data, type) {
        const isBuffer = Buffer.isBuffer(data);
        const dataLen = isBuffer ? data.length : Buffer.byteLength(data);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 4 + dataLen);
        packet[p] = MESSAGE.CHANNEL_EXTENDED_DATA;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, type, p += 4);
        writeUInt32BE(packet, dataLen, p += 4);
        if (isBuffer)
          packet.set(data, p += 4);
        else
          packet.utf8Write(data, p += 4, dataLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_EXTENDED_DATA (r:${chan})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelOpenConfirm(remote, local, initWindow, maxPacket) {
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 4 + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN_CONFIRMATION;
        writeUInt32BE(packet, remote, ++p);
        writeUInt32BE(packet, local, p += 4);
        writeUInt32BE(packet, initWindow, p += 4);
        writeUInt32BE(packet, maxPacket, p += 4);
        this._debug && this._debug(`Outbound: Sending CHANNEL_OPEN_CONFIRMATION (r:${remote}, l:${local})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      channelOpenFail(remote, reason, desc) {
        if (typeof desc !== "string")
          desc = "";
        const descLen = Buffer.byteLength(desc);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 4 + descLen + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN_FAILURE;
        writeUInt32BE(packet, remote, ++p);
        writeUInt32BE(packet, reason, p += 4);
        writeUInt32BE(packet, descLen, p += 4);
        p += 4;
        if (descLen) {
          packet.utf8Write(desc, p, descLen);
          p += descLen;
        }
        writeUInt32BE(packet, 0, p);
        this._debug && this._debug(`Outbound: Sending CHANNEL_OPEN_FAILURE (r:${remote})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      service(name) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const nameLen = Buffer.byteLength(name);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + nameLen);
        packet[p] = MESSAGE.SERVICE_REQUEST;
        writeUInt32BE(packet, nameLen, ++p);
        packet.utf8Write(name, p += 4, nameLen);
        this._debug && this._debug(`Outbound: Sending SERVICE_REQUEST (${name})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      authPassword(username, password, newPassword) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const userLen = Buffer.byteLength(username);
        const passLen = Buffer.byteLength(password);
        const newPassLen = newPassword ? Buffer.byteLength(newPassword) : 0;
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + userLen + 4 + 14 + 4 + 8 + 1 + 4 + passLen + (newPassword ? 4 + newPassLen : 0));
        packet[p] = MESSAGE.USERAUTH_REQUEST;
        writeUInt32BE(packet, userLen, ++p);
        packet.utf8Write(username, p += 4, userLen);
        writeUInt32BE(packet, 14, p += userLen);
        packet.utf8Write("ssh-connection", p += 4, 14);
        writeUInt32BE(packet, 8, p += 14);
        packet.utf8Write("password", p += 4, 8);
        packet[p += 8] = newPassword ? 1 : 0;
        writeUInt32BE(packet, passLen, ++p);
        if (Buffer.isBuffer(password))
          bufferCopy(password, packet, 0, passLen, p += 4);
        else
          packet.utf8Write(password, p += 4, passLen);
        if (newPassword) {
          writeUInt32BE(packet, newPassLen, p += passLen);
          if (Buffer.isBuffer(newPassword))
            bufferCopy(newPassword, packet, 0, newPassLen, p += 4);
          else
            packet.utf8Write(newPassword, p += 4, newPassLen);
          this._debug && this._debug("Outbound: Sending USERAUTH_REQUEST (changed password)");
        } else {
          this._debug && this._debug("Outbound: Sending USERAUTH_REQUEST (password)");
        }
        this._authsQueue.push("password");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      authPK(username, pubKey, cbSign) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        pubKey = parseKey(pubKey);
        if (pubKey instanceof Error)
          throw new Error("Invalid key");
        const keyType = pubKey.type;
        pubKey = pubKey.getPublicSSH();
        const userLen = Buffer.byteLength(username);
        const algoLen = Buffer.byteLength(keyType);
        const pubKeyLen = pubKey.length;
        const sessionID = this._kex.sessionID;
        const sesLen = sessionID.length;
        const payloadLen = (cbSign ? 4 + sesLen : 0) + 1 + 4 + userLen + 4 + 14 + 4 + 9 + 1 + 4 + algoLen + 4 + pubKeyLen;
        let packet;
        let p;
        if (cbSign) {
          packet = Buffer.allocUnsafe(payloadLen);
          p = 0;
          writeUInt32BE(packet, sesLen, p);
          packet.set(sessionID, p += 4);
          p += sesLen;
        } else {
          packet = this._packetRW.write.alloc(payloadLen);
          p = this._packetRW.write.allocStart;
        }
        packet[p] = MESSAGE.USERAUTH_REQUEST;
        writeUInt32BE(packet, userLen, ++p);
        packet.utf8Write(username, p += 4, userLen);
        writeUInt32BE(packet, 14, p += userLen);
        packet.utf8Write("ssh-connection", p += 4, 14);
        writeUInt32BE(packet, 9, p += 14);
        packet.utf8Write("publickey", p += 4, 9);
        packet[p += 9] = cbSign ? 1 : 0;
        writeUInt32BE(packet, algoLen, ++p);
        packet.utf8Write(keyType, p += 4, algoLen);
        writeUInt32BE(packet, pubKeyLen, p += algoLen);
        packet.set(pubKey, p += 4);
        if (!cbSign) {
          this._authsQueue.push("publickey");
          this._debug && this._debug("Outbound: Sending USERAUTH_REQUEST (publickey -- check)");
          sendPacket(this, this._packetRW.write.finalize(packet));
          return;
        }
        cbSign(packet, (signature) => {
          signature = convertSignature(signature, keyType);
          if (signature === false)
            throw new Error("Error while converting handshake signature");
          const sigLen = signature.length;
          p = this._packetRW.write.allocStart;
          packet = this._packetRW.write.alloc(1 + 4 + userLen + 4 + 14 + 4 + 9 + 1 + 4 + algoLen + 4 + pubKeyLen + 4 + 4 + algoLen + 4 + sigLen);
          packet[p] = MESSAGE.USERAUTH_REQUEST;
          writeUInt32BE(packet, userLen, ++p);
          packet.utf8Write(username, p += 4, userLen);
          writeUInt32BE(packet, 14, p += userLen);
          packet.utf8Write("ssh-connection", p += 4, 14);
          writeUInt32BE(packet, 9, p += 14);
          packet.utf8Write("publickey", p += 4, 9);
          packet[p += 9] = 1;
          writeUInt32BE(packet, algoLen, ++p);
          packet.utf8Write(keyType, p += 4, algoLen);
          writeUInt32BE(packet, pubKeyLen, p += algoLen);
          packet.set(pubKey, p += 4);
          writeUInt32BE(packet, 4 + algoLen + 4 + sigLen, p += pubKeyLen);
          writeUInt32BE(packet, algoLen, p += 4);
          packet.utf8Write(keyType, p += 4, algoLen);
          writeUInt32BE(packet, sigLen, p += algoLen);
          packet.set(signature, p += 4);
          this._authsQueue.push("publickey");
          this._debug && this._debug("Outbound: Sending USERAUTH_REQUEST (publickey)");
          sendPacket(this, this._packetRW.write.finalize(packet));
        });
      }
      authHostbased(username, pubKey, hostname, userlocal, cbSign) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        pubKey = parseKey(pubKey);
        if (pubKey instanceof Error)
          throw new Error("Invalid key");
        const keyType = pubKey.type;
        pubKey = pubKey.getPublicSSH();
        const userLen = Buffer.byteLength(username);
        const algoLen = Buffer.byteLength(keyType);
        const pubKeyLen = pubKey.length;
        const sessionID = this._kex.sessionID;
        const sesLen = sessionID.length;
        const hostnameLen = Buffer.byteLength(hostname);
        const userlocalLen = Buffer.byteLength(userlocal);
        const data = Buffer.allocUnsafe(4 + sesLen + 1 + 4 + userLen + 4 + 14 + 4 + 9 + 4 + algoLen + 4 + pubKeyLen + 4 + hostnameLen + 4 + userlocalLen);
        let p = 0;
        writeUInt32BE(data, sesLen, p);
        data.set(sessionID, p += 4);
        data[p += sesLen] = MESSAGE.USERAUTH_REQUEST;
        writeUInt32BE(data, userLen, ++p);
        data.utf8Write(username, p += 4, userLen);
        writeUInt32BE(data, 14, p += userLen);
        data.utf8Write("ssh-connection", p += 4, 14);
        writeUInt32BE(data, 9, p += 14);
        data.utf8Write("hostbased", p += 4, 9);
        writeUInt32BE(data, algoLen, p += 9);
        data.utf8Write(keyType, p += 4, algoLen);
        writeUInt32BE(data, pubKeyLen, p += algoLen);
        data.set(pubKey, p += 4);
        writeUInt32BE(data, hostnameLen, p += pubKeyLen);
        data.utf8Write(hostname, p += 4, hostnameLen);
        writeUInt32BE(data, userlocalLen, p += hostnameLen);
        data.utf8Write(userlocal, p += 4, userlocalLen);
        cbSign(data, (signature) => {
          signature = convertSignature(signature, keyType);
          if (!signature)
            throw new Error("Error while converting handshake signature");
          const sigLen = signature.length;
          const reqDataLen = data.length - sesLen - 4;
          p = this._packetRW.write.allocStart;
          const packet = this._packetRW.write.alloc(reqDataLen + 4 + 4 + algoLen + 4 + sigLen);
          bufferCopy(data, packet, 4 + sesLen, data.length, p);
          writeUInt32BE(packet, 4 + algoLen + 4 + sigLen, p += reqDataLen);
          writeUInt32BE(packet, algoLen, p += 4);
          packet.utf8Write(keyType, p += 4, algoLen);
          writeUInt32BE(packet, sigLen, p += algoLen);
          packet.set(signature, p += 4);
          this._authsQueue.push("hostbased");
          this._debug && this._debug("Outbound: Sending USERAUTH_REQUEST (hostbased)");
          sendPacket(this, this._packetRW.write.finalize(packet));
        });
      }
      authKeyboard(username) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const userLen = Buffer.byteLength(username);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + userLen + 4 + 14 + 4 + 20 + 4 + 4);
        packet[p] = MESSAGE.USERAUTH_REQUEST;
        writeUInt32BE(packet, userLen, ++p);
        packet.utf8Write(username, p += 4, userLen);
        writeUInt32BE(packet, 14, p += userLen);
        packet.utf8Write("ssh-connection", p += 4, 14);
        writeUInt32BE(packet, 20, p += 14);
        packet.utf8Write("keyboard-interactive", p += 4, 20);
        writeUInt32BE(packet, 0, p += 20);
        writeUInt32BE(packet, 0, p += 4);
        this._authsQueue.push("keyboard-interactive");
        this._debug && this._debug("Outbound: Sending USERAUTH_REQUEST (keyboard-interactive)");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      authNone(username) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const userLen = Buffer.byteLength(username);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + userLen + 4 + 14 + 4 + 4);
        packet[p] = MESSAGE.USERAUTH_REQUEST;
        writeUInt32BE(packet, userLen, ++p);
        packet.utf8Write(username, p += 4, userLen);
        writeUInt32BE(packet, 14, p += userLen);
        packet.utf8Write("ssh-connection", p += 4, 14);
        writeUInt32BE(packet, 4, p += 14);
        packet.utf8Write("none", p += 4, 4);
        this._authsQueue.push("none");
        this._debug && this._debug("Outbound: Sending USERAUTH_REQUEST (none)");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      authInfoRes(responses) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        let responsesTotalLen = 0;
        let responseLens;
        if (responses) {
          responseLens = new Array(responses.length);
          for (let i = 0; i < responses.length; ++i) {
            const len = Buffer.byteLength(responses[i]);
            responseLens[i] = len;
            responsesTotalLen += 4 + len;
          }
        }
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + responsesTotalLen);
        packet[p] = MESSAGE.USERAUTH_INFO_RESPONSE;
        if (responses) {
          writeUInt32BE(packet, responses.length, ++p);
          p += 4;
          for (let i = 0; i < responses.length; ++i) {
            const len = responseLens[i];
            writeUInt32BE(packet, len, p);
            p += 4;
            if (len) {
              packet.utf8Write(responses[i], p, len);
              p += len;
            }
          }
        } else {
          writeUInt32BE(packet, 0, ++p);
        }
        this._debug && this._debug("Outbound: Sending USERAUTH_INFO_RESPONSE");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      tcpipForward(bindAddr, bindPort, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const addrLen = Buffer.byteLength(bindAddr);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 13 + 1 + 4 + addrLen + 4);
        packet[p] = MESSAGE.GLOBAL_REQUEST;
        writeUInt32BE(packet, 13, ++p);
        packet.utf8Write("tcpip-forward", p += 4, 13);
        packet[p += 13] = wantReply === void 0 || wantReply === true ? 1 : 0;
        writeUInt32BE(packet, addrLen, ++p);
        packet.utf8Write(bindAddr, p += 4, addrLen);
        writeUInt32BE(packet, bindPort, p += addrLen);
        this._debug && this._debug("Outbound: Sending GLOBAL_REQUEST (tcpip-forward)");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      cancelTcpipForward(bindAddr, bindPort, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const addrLen = Buffer.byteLength(bindAddr);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 20 + 1 + 4 + addrLen + 4);
        packet[p] = MESSAGE.GLOBAL_REQUEST;
        writeUInt32BE(packet, 20, ++p);
        packet.utf8Write("cancel-tcpip-forward", p += 4, 20);
        packet[p += 20] = wantReply === void 0 || wantReply === true ? 1 : 0;
        writeUInt32BE(packet, addrLen, ++p);
        packet.utf8Write(bindAddr, p += 4, addrLen);
        writeUInt32BE(packet, bindPort, p += addrLen);
        this._debug && this._debug("Outbound: Sending GLOBAL_REQUEST (cancel-tcpip-forward)");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      openssh_streamLocalForward(socketPath, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const socketPathLen = Buffer.byteLength(socketPath);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 31 + 1 + 4 + socketPathLen);
        packet[p] = MESSAGE.GLOBAL_REQUEST;
        writeUInt32BE(packet, 31, ++p);
        packet.utf8Write("streamlocal-forward@openssh.com", p += 4, 31);
        packet[p += 31] = wantReply === void 0 || wantReply === true ? 1 : 0;
        writeUInt32BE(packet, socketPathLen, ++p);
        packet.utf8Write(socketPath, p += 4, socketPathLen);
        this._debug && this._debug("Outbound: Sending GLOBAL_REQUEST (streamlocal-forward@openssh.com)");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      openssh_cancelStreamLocalForward(socketPath, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const socketPathLen = Buffer.byteLength(socketPath);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 38 + 1 + 4 + socketPathLen);
        packet[p] = MESSAGE.GLOBAL_REQUEST;
        writeUInt32BE(packet, 38, ++p);
        packet.utf8Write("cancel-streamlocal-forward@openssh.com", p += 4, 38);
        packet[p += 38] = wantReply === void 0 || wantReply === true ? 1 : 0;
        writeUInt32BE(packet, socketPathLen, ++p);
        packet.utf8Write(socketPath, p += 4, socketPathLen);
        if (this._debug) {
          this._debug("Outbound: Sending GLOBAL_REQUEST (cancel-streamlocal-forward@openssh.com)");
        }
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      directTcpip(chan, initWindow, maxPacket, cfg) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const srcLen = Buffer.byteLength(cfg.srcIP);
        const dstLen = Buffer.byteLength(cfg.dstIP);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 12 + 4 + 4 + 4 + 4 + srcLen + 4 + 4 + dstLen + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN;
        writeUInt32BE(packet, 12, ++p);
        packet.utf8Write("direct-tcpip", p += 4, 12);
        writeUInt32BE(packet, chan, p += 12);
        writeUInt32BE(packet, initWindow, p += 4);
        writeUInt32BE(packet, maxPacket, p += 4);
        writeUInt32BE(packet, dstLen, p += 4);
        packet.utf8Write(cfg.dstIP, p += 4, dstLen);
        writeUInt32BE(packet, cfg.dstPort, p += dstLen);
        writeUInt32BE(packet, srcLen, p += 4);
        packet.utf8Write(cfg.srcIP, p += 4, srcLen);
        writeUInt32BE(packet, cfg.srcPort, p += srcLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_OPEN (r:${chan}, direct-tcpip)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      openssh_directStreamLocal(chan, initWindow, maxPacket, cfg) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const pathLen = Buffer.byteLength(cfg.socketPath);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 30 + 4 + 4 + 4 + 4 + pathLen + 4 + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN;
        writeUInt32BE(packet, 30, ++p);
        packet.utf8Write("direct-streamlocal@openssh.com", p += 4, 30);
        writeUInt32BE(packet, chan, p += 30);
        writeUInt32BE(packet, initWindow, p += 4);
        writeUInt32BE(packet, maxPacket, p += 4);
        writeUInt32BE(packet, pathLen, p += 4);
        packet.utf8Write(cfg.socketPath, p += 4, pathLen);
        bufferFill(packet, 0, p += pathLen, p + 8);
        if (this._debug) {
          this._debug(`Outbound: Sending CHANNEL_OPEN (r:${chan}, direct-streamlocal@openssh.com)`);
        }
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      openssh_noMoreSessions(wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 28 + 1);
        packet[p] = MESSAGE.GLOBAL_REQUEST;
        writeUInt32BE(packet, 28, ++p);
        packet.utf8Write("no-more-sessions@openssh.com", p += 4, 28);
        packet[p += 28] = wantReply === void 0 || wantReply === true ? 1 : 0;
        this._debug && this._debug("Outbound: Sending GLOBAL_REQUEST (no-more-sessions@openssh.com)");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      session(chan, initWindow, maxPacket) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 7 + 4 + 4 + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN;
        writeUInt32BE(packet, 7, ++p);
        packet.utf8Write("session", p += 4, 7);
        writeUInt32BE(packet, chan, p += 7);
        writeUInt32BE(packet, initWindow, p += 4);
        writeUInt32BE(packet, maxPacket, p += 4);
        this._debug && this._debug(`Outbound: Sending CHANNEL_OPEN (r:${chan}, session)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      windowChange(chan, rows, cols, height, width) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 13 + 1 + 4 + 4 + 4 + 4);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 13, p += 4);
        packet.utf8Write("window-change", p += 4, 13);
        packet[p += 13] = 0;
        writeUInt32BE(packet, cols, ++p);
        writeUInt32BE(packet, rows, p += 4);
        writeUInt32BE(packet, width, p += 4);
        writeUInt32BE(packet, height, p += 4);
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, window-change)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      pty(chan, rows, cols, height, width, term, modes, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        if (!term || !term.length)
          term = "vt100";
        if (modes && !Buffer.isBuffer(modes) && !Array.isArray(modes) && typeof modes === "object" && modes !== null) {
          modes = modesToBytes(modes);
        }
        if (!modes || !modes.length)
          modes = NO_TERMINAL_MODES_BUFFER;
        const termLen = term.length;
        const modesLen = modes.length;
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 7 + 1 + 4 + termLen + 4 + 4 + 4 + 4 + 4 + modesLen);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 7, p += 4);
        packet.utf8Write("pty-req", p += 4, 7);
        packet[p += 7] = wantReply === void 0 || wantReply === true ? 1 : 0;
        writeUInt32BE(packet, termLen, ++p);
        packet.utf8Write(term, p += 4, termLen);
        writeUInt32BE(packet, cols, p += termLen);
        writeUInt32BE(packet, rows, p += 4);
        writeUInt32BE(packet, width, p += 4);
        writeUInt32BE(packet, height, p += 4);
        writeUInt32BE(packet, modesLen, p += 4);
        p += 4;
        if (Array.isArray(modes)) {
          for (let i = 0; i < modesLen; ++i)
            packet[p++] = modes[i];
        } else if (Buffer.isBuffer(modes)) {
          packet.set(modes, p);
        }
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, pty-req)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      shell(chan, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 5 + 1);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 5, p += 4);
        packet.utf8Write("shell", p += 4, 5);
        packet[p += 5] = wantReply === void 0 || wantReply === true ? 1 : 0;
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, shell)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      exec(chan, cmd, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const isBuf = Buffer.isBuffer(cmd);
        const cmdLen = isBuf ? cmd.length : Buffer.byteLength(cmd);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 4 + 1 + 4 + cmdLen);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 4, p += 4);
        packet.utf8Write("exec", p += 4, 4);
        packet[p += 4] = wantReply === void 0 || wantReply === true ? 1 : 0;
        writeUInt32BE(packet, cmdLen, ++p);
        if (isBuf)
          packet.set(cmd, p += 4);
        else
          packet.utf8Write(cmd, p += 4, cmdLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, exec: ${cmd})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      signal(chan, signal) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const origSignal = signal;
        signal = signal.toUpperCase();
        if (signal.slice(0, 3) === "SIG")
          signal = signal.slice(3);
        if (SIGNALS[signal] !== 1)
          throw new Error(`Invalid signal: ${origSignal}`);
        const signalLen = signal.length;
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 6 + 1 + 4 + signalLen);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 6, p += 4);
        packet.utf8Write("signal", p += 4, 6);
        packet[p += 6] = 0;
        writeUInt32BE(packet, signalLen, ++p);
        packet.utf8Write(signal, p += 4, signalLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, signal: ${signal})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      env(chan, key, val, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const keyLen = Buffer.byteLength(key);
        const isBuf = Buffer.isBuffer(val);
        const valLen = isBuf ? val.length : Buffer.byteLength(val);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 3 + 1 + 4 + keyLen + 4 + valLen);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 3, p += 4);
        packet.utf8Write("env", p += 4, 3);
        packet[p += 3] = wantReply === void 0 || wantReply === true ? 1 : 0;
        writeUInt32BE(packet, keyLen, ++p);
        packet.utf8Write(key, p += 4, keyLen);
        writeUInt32BE(packet, valLen, p += keyLen);
        if (isBuf)
          packet.set(val, p += 4);
        else
          packet.utf8Write(val, p += 4, valLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, env: ${key}=${val})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      x11Forward(chan, cfg, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const protocol = cfg.protocol;
        const cookie = cfg.cookie;
        const isBufProto = Buffer.isBuffer(protocol);
        const protoLen = isBufProto ? protocol.length : Buffer.byteLength(protocol);
        const isBufCookie = Buffer.isBuffer(cookie);
        const cookieLen = isBufCookie ? cookie.length : Buffer.byteLength(cookie);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 7 + 1 + 1 + 4 + protoLen + 4 + cookieLen + 4);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 7, p += 4);
        packet.utf8Write("x11-req", p += 4, 7);
        packet[p += 7] = wantReply === void 0 || wantReply === true ? 1 : 0;
        packet[++p] = cfg.single ? 1 : 0;
        writeUInt32BE(packet, protoLen, ++p);
        if (isBufProto)
          packet.set(protocol, p += 4);
        else
          packet.utf8Write(protocol, p += 4, protoLen);
        writeUInt32BE(packet, cookieLen, p += protoLen);
        if (isBufCookie)
          packet.set(cookie, p += 4);
        else
          packet.latin1Write(cookie, p += 4, cookieLen);
        writeUInt32BE(packet, cfg.screen || 0, p += cookieLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, x11-req)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      subsystem(chan, name, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        const nameLen = Buffer.byteLength(name);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 9 + 1 + 4 + nameLen);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 9, p += 4);
        packet.utf8Write("subsystem", p += 4, 9);
        packet[p += 9] = wantReply === void 0 || wantReply === true ? 1 : 0;
        writeUInt32BE(packet, nameLen, ++p);
        packet.utf8Write(name, p += 4, nameLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, subsystem: ${name})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      openssh_agentForward(chan, wantReply) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 26 + 1);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 26, p += 4);
        packet.utf8Write("auth-agent-req@openssh.com", p += 4, 26);
        packet[p += 26] = wantReply === void 0 || wantReply === true ? 1 : 0;
        if (this._debug) {
          this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, auth-agent-req@openssh.com)`);
        }
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      openssh_hostKeysProve(keys) {
        if (this._server)
          throw new Error("Client-only method called in server mode");
        let keysTotal = 0;
        const publicKeys = [];
        for (const key of keys) {
          const publicKey = key.getPublicSSH();
          keysTotal += 4 + publicKey.length;
          publicKeys.push(publicKey);
        }
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 29 + 1 + keysTotal);
        packet[p] = MESSAGE.GLOBAL_REQUEST;
        writeUInt32BE(packet, 29, ++p);
        packet.utf8Write("hostkeys-prove-00@openssh.com", p += 4, 29);
        packet[p += 29] = 1;
        ++p;
        for (const buf of publicKeys) {
          writeUInt32BE(packet, buf.length, p);
          bufferCopy(buf, packet, 0, buf.length, p += 4);
          p += buf.length;
        }
        if (this._debug) {
          this._debug("Outbound: Sending GLOBAL_REQUEST (hostkeys-prove-00@openssh.com)");
        }
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      serviceAccept(svcName) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        const svcNameLen = Buffer.byteLength(svcName);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + svcNameLen);
        packet[p] = MESSAGE.SERVICE_ACCEPT;
        writeUInt32BE(packet, svcNameLen, ++p);
        packet.utf8Write(svcName, p += 4, svcNameLen);
        this._debug && this._debug(`Outbound: Sending SERVICE_ACCEPT (${svcName})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
        if (this._server && this._banner && svcName === "ssh-userauth") {
          const banner = this._banner;
          this._banner = void 0;
          const bannerLen = Buffer.byteLength(banner);
          p = this._packetRW.write.allocStart;
          const packet2 = this._packetRW.write.alloc(1 + 4 + bannerLen + 4);
          packet2[p] = MESSAGE.USERAUTH_BANNER;
          writeUInt32BE(packet2, bannerLen, ++p);
          packet2.utf8Write(banner, p += 4, bannerLen);
          writeUInt32BE(packet2, 0, p += bannerLen);
          this._debug && this._debug("Outbound: Sending USERAUTH_BANNER");
          sendPacket(this, this._packetRW.write.finalize(packet2));
        }
      }
      forwardedTcpip(chan, initWindow, maxPacket, cfg) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        const boundAddrLen = Buffer.byteLength(cfg.boundAddr);
        const remoteAddrLen = Buffer.byteLength(cfg.remoteAddr);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 15 + 4 + 4 + 4 + 4 + boundAddrLen + 4 + 4 + remoteAddrLen + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN;
        writeUInt32BE(packet, 15, ++p);
        packet.utf8Write("forwarded-tcpip", p += 4, 15);
        writeUInt32BE(packet, chan, p += 15);
        writeUInt32BE(packet, initWindow, p += 4);
        writeUInt32BE(packet, maxPacket, p += 4);
        writeUInt32BE(packet, boundAddrLen, p += 4);
        packet.utf8Write(cfg.boundAddr, p += 4, boundAddrLen);
        writeUInt32BE(packet, cfg.boundPort, p += boundAddrLen);
        writeUInt32BE(packet, remoteAddrLen, p += 4);
        packet.utf8Write(cfg.remoteAddr, p += 4, remoteAddrLen);
        writeUInt32BE(packet, cfg.remotePort, p += remoteAddrLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_OPEN (r:${chan}, forwarded-tcpip)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      x11(chan, initWindow, maxPacket, cfg) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        const addrLen = Buffer.byteLength(cfg.originAddr);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 3 + 4 + 4 + 4 + 4 + addrLen + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN;
        writeUInt32BE(packet, 3, ++p);
        packet.utf8Write("x11", p += 4, 3);
        writeUInt32BE(packet, chan, p += 3);
        writeUInt32BE(packet, initWindow, p += 4);
        writeUInt32BE(packet, maxPacket, p += 4);
        writeUInt32BE(packet, addrLen, p += 4);
        packet.utf8Write(cfg.originAddr, p += 4, addrLen);
        writeUInt32BE(packet, cfg.originPort, p += addrLen);
        this._debug && this._debug(`Outbound: Sending CHANNEL_OPEN (r:${chan}, x11)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      openssh_authAgent(chan, initWindow, maxPacket) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 22 + 4 + 4 + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN;
        writeUInt32BE(packet, 22, ++p);
        packet.utf8Write("auth-agent@openssh.com", p += 4, 22);
        writeUInt32BE(packet, chan, p += 22);
        writeUInt32BE(packet, initWindow, p += 4);
        writeUInt32BE(packet, maxPacket, p += 4);
        this._debug && this._debug(`Outbound: Sending CHANNEL_OPEN (r:${chan}, auth-agent@openssh.com)`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      openssh_forwardedStreamLocal(chan, initWindow, maxPacket, cfg) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        const pathLen = Buffer.byteLength(cfg.socketPath);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 33 + 4 + 4 + 4 + 4 + pathLen + 4);
        packet[p] = MESSAGE.CHANNEL_OPEN;
        writeUInt32BE(packet, 33, ++p);
        packet.utf8Write("forwarded-streamlocal@openssh.com", p += 4, 33);
        writeUInt32BE(packet, chan, p += 33);
        writeUInt32BE(packet, initWindow, p += 4);
        writeUInt32BE(packet, maxPacket, p += 4);
        writeUInt32BE(packet, pathLen, p += 4);
        packet.utf8Write(cfg.socketPath, p += 4, pathLen);
        writeUInt32BE(packet, 0, p += pathLen);
        if (this._debug) {
          this._debug(`Outbound: Sending CHANNEL_OPEN (r:${chan}, forwarded-streamlocal@openssh.com)`);
        }
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      exitStatus(chan, status) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 11 + 1 + 4);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 11, p += 4);
        packet.utf8Write("exit-status", p += 4, 11);
        packet[p += 11] = 0;
        writeUInt32BE(packet, status, ++p);
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, exit-status: ${status})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      exitSignal(chan, name, coreDumped, msg) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        const origSignal = name;
        if (typeof origSignal !== "string" || !origSignal)
          throw new Error(`Invalid signal: ${origSignal}`);
        let signal = name.toUpperCase();
        if (signal.slice(0, 3) === "SIG")
          signal = signal.slice(3);
        if (SIGNALS[signal] !== 1)
          throw new Error(`Invalid signal: ${origSignal}`);
        const nameLen = Buffer.byteLength(signal);
        const msgLen = msg ? Buffer.byteLength(msg) : 0;
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + 4 + 11 + 1 + 4 + nameLen + 1 + 4 + msgLen + 4);
        packet[p] = MESSAGE.CHANNEL_REQUEST;
        writeUInt32BE(packet, chan, ++p);
        writeUInt32BE(packet, 11, p += 4);
        packet.utf8Write("exit-signal", p += 4, 11);
        packet[p += 11] = 0;
        writeUInt32BE(packet, nameLen, ++p);
        packet.utf8Write(signal, p += 4, nameLen);
        packet[p += nameLen] = coreDumped ? 1 : 0;
        writeUInt32BE(packet, msgLen, ++p);
        p += 4;
        if (msgLen) {
          packet.utf8Write(msg, p, msgLen);
          p += msgLen;
        }
        writeUInt32BE(packet, 0, p);
        this._debug && this._debug(`Outbound: Sending CHANNEL_REQUEST (r:${chan}, exit-signal: ${name})`);
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      authFailure(authMethods, isPartial) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        if (this._authsQueue.length === 0)
          throw new Error("No auth in progress");
        let methods;
        if (typeof authMethods === "boolean") {
          isPartial = authMethods;
          authMethods = void 0;
        }
        if (authMethods) {
          methods = [];
          for (let i = 0; i < authMethods.length; ++i) {
            if (authMethods[i].toLowerCase() === "none")
              continue;
            methods.push(authMethods[i]);
          }
          methods = methods.join(",");
        } else {
          methods = "";
        }
        const methodsLen = methods.length;
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + methodsLen + 1);
        packet[p] = MESSAGE.USERAUTH_FAILURE;
        writeUInt32BE(packet, methodsLen, ++p);
        packet.utf8Write(methods, p += 4, methodsLen);
        packet[p += methodsLen] = isPartial === true ? 1 : 0;
        this._authsQueue.shift();
        this._debug && this._debug("Outbound: Sending USERAUTH_FAILURE");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      authSuccess() {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        if (this._authsQueue.length === 0)
          throw new Error("No auth in progress");
        const p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1);
        packet[p] = MESSAGE.USERAUTH_SUCCESS;
        this._authsQueue.shift();
        this._authenticated = true;
        this._debug && this._debug("Outbound: Sending USERAUTH_SUCCESS");
        sendPacket(this, this._packetRW.write.finalize(packet));
        if (this._kex.negotiated.cs.compress === "zlib@openssh.com")
          this._packetRW.read = new ZlibPacketReader();
        if (this._kex.negotiated.sc.compress === "zlib@openssh.com")
          this._packetRW.write = new ZlibPacketWriter(this);
      }
      authPKOK(keyAlgo, key) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        if (this._authsQueue.length === 0 || this._authsQueue[0] !== "publickey")
          throw new Error('"publickey" auth not in progress');
        const keyAlgoLen = Buffer.byteLength(keyAlgo);
        const keyLen = key.length;
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + keyAlgoLen + 4 + keyLen);
        packet[p] = MESSAGE.USERAUTH_PK_OK;
        writeUInt32BE(packet, keyAlgoLen, ++p);
        packet.utf8Write(keyAlgo, p += 4, keyAlgoLen);
        writeUInt32BE(packet, keyLen, p += keyAlgoLen);
        packet.set(key, p += 4);
        this._authsQueue.shift();
        this._debug && this._debug("Outbound: Sending USERAUTH_PK_OK");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      authPasswdChg(prompt) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        const promptLen = Buffer.byteLength(prompt);
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + promptLen + 4);
        packet[p] = MESSAGE.USERAUTH_PASSWD_CHANGEREQ;
        writeUInt32BE(packet, promptLen, ++p);
        packet.utf8Write(prompt, p += 4, promptLen);
        writeUInt32BE(packet, 0, p += promptLen);
        this._debug && this._debug("Outbound: Sending USERAUTH_PASSWD_CHANGEREQ");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
      authInfoReq(name, instructions, prompts) {
        if (!this._server)
          throw new Error("Server-only method called in client mode");
        let promptsLen = 0;
        const nameLen = name ? Buffer.byteLength(name) : 0;
        const instrLen = instructions ? Buffer.byteLength(instructions) : 0;
        for (let i = 0; i < prompts.length; ++i)
          promptsLen += 4 + Buffer.byteLength(prompts[i].prompt) + 1;
        let p = this._packetRW.write.allocStart;
        const packet = this._packetRW.write.alloc(1 + 4 + nameLen + 4 + instrLen + 4 + 4 + promptsLen);
        packet[p] = MESSAGE.USERAUTH_INFO_REQUEST;
        writeUInt32BE(packet, nameLen, ++p);
        p += 4;
        if (name) {
          packet.utf8Write(name, p, nameLen);
          p += nameLen;
        }
        writeUInt32BE(packet, instrLen, p);
        p += 4;
        if (instructions) {
          packet.utf8Write(instructions, p, instrLen);
          p += instrLen;
        }
        writeUInt32BE(packet, 0, p);
        writeUInt32BE(packet, prompts.length, p += 4);
        p += 4;
        for (let i = 0; i < prompts.length; ++i) {
          const prompt = prompts[i];
          const promptLen = Buffer.byteLength(prompt.prompt);
          writeUInt32BE(packet, promptLen, p);
          p += 4;
          if (promptLen) {
            packet.utf8Write(prompt.prompt, p, promptLen);
            p += promptLen;
          }
          packet[p++] = prompt.echo ? 1 : 0;
        }
        this._debug && this._debug("Outbound: Sending USERAUTH_INFO_REQUEST");
        sendPacket(this, this._packetRW.write.finalize(packet));
      }
    };
    var RE_IDENT = /^SSH-(2\.0|1\.99)-([^ ]+)(?: (.*))?$/;
    function parseHeader(chunk, p, len) {
      let data;
      let chunkOffset;
      if (this._buffer) {
        data = Buffer.allocUnsafe(this._buffer.length + (len - p));
        data.set(this._buffer, 0);
        if (p === 0) {
          data.set(chunk, this._buffer.length);
        } else {
          data.set(new Uint8Array(chunk.buffer, chunk.byteOffset + p, len - p), this._buffer.length);
        }
        chunkOffset = this._buffer.length;
        p = 0;
      } else {
        data = chunk;
        chunkOffset = 0;
      }
      const op = p;
      let start = p;
      let end = p;
      let needNL = false;
      let lineLen = 0;
      let lines = 0;
      for (; p < data.length; ++p) {
        const ch = data[p];
        if (ch === 13) {
          needNL = true;
          continue;
        }
        if (ch === 10) {
          if (end > start && end - start > 4 && data[start] === 83 && data[start + 1] === 83 && data[start + 2] === 72 && data[start + 3] === 45) {
            const full = data.latin1Slice(op, end + 1);
            const identRaw = start === op ? full : full.slice(start - op);
            const m = RE_IDENT.exec(identRaw);
            if (!m)
              throw new Error("Invalid identification string");
            const header = {
              greeting: start === op ? "" : full.slice(0, start - op),
              identRaw,
              versions: {
                protocol: m[1],
                software: m[2]
              },
              comments: m[3]
            };
            this._remoteIdentRaw = Buffer.from(identRaw);
            this._debug && this._debug(`Remote ident: ${inspect(identRaw)}`);
            this._compatFlags = getCompatFlags(header);
            this._buffer = void 0;
            this._decipher = new NullDecipher(0, onKEXPayload.bind(this, { firstPacket: true }));
            this._parse = parsePacket;
            this._onHeader(header);
            if (!this._destruct) {
              return len;
            }
            kexinit(this);
            return p + 1 - chunkOffset;
          }
          if (this._server)
            throw new Error("Greetings from clients not permitted");
          if (++lines > MAX_LINES)
            throw new Error("Max greeting lines exceeded");
          needNL = false;
          start = p + 1;
          lineLen = 0;
        } else if (needNL) {
          throw new Error("Invalid header: expected newline");
        } else if (++lineLen >= MAX_LINE_LEN) {
          throw new Error("Header line too long");
        }
        end = p;
      }
      if (!this._buffer)
        this._buffer = bufferSlice(data, op);
      return p - chunkOffset;
    }
    function parsePacket(chunk, p, len) {
      return this._decipher.decrypt(chunk, p, len);
    }
    function onPayload(payload) {
      this._onPacket();
      if (payload.length === 0) {
        this._debug && this._debug("Inbound: Skipping empty packet payload");
        return;
      }
      payload = this._packetRW.read.read(payload);
      const type = payload[0];
      if (type === MESSAGE.USERAUTH_SUCCESS && !this._server && !this._authenticated) {
        this._authenticated = true;
        if (this._kex.negotiated.cs.compress === "zlib@openssh.com")
          this._packetRW.write = new ZlibPacketWriter(this);
        if (this._kex.negotiated.sc.compress === "zlib@openssh.com")
          this._packetRW.read = new ZlibPacketReader();
      }
      const handler = MESSAGE_HANDLERS[type];
      if (handler === void 0) {
        this._debug && this._debug(`Inbound: Unsupported message type: ${type}`);
        return;
      }
      return handler(this, payload);
    }
    function getCompatFlags(header) {
      const software = header.versions.software;
      let flags = 0;
      for (const rule of COMPAT_CHECKS) {
        if (typeof rule[0] === "string") {
          if (software === rule[0])
            flags |= rule[1];
        } else if (rule[0].test(software)) {
          flags |= rule[1];
        }
      }
      return flags;
    }
    function modesToBytes(modes) {
      const keys = Object.keys(modes);
      const bytes = Buffer.allocUnsafe(5 * keys.length + 1);
      let b = 0;
      for (let i = 0; i < keys.length; ++i) {
        const key = keys[i];
        if (key === "TTY_OP_END")
          continue;
        const opcode = TERMINAL_MODE[key];
        if (opcode === void 0)
          continue;
        const val = modes[key];
        if (typeof val === "number" && isFinite(val)) {
          bytes[b++] = opcode;
          bytes[b++] = val >>> 24;
          bytes[b++] = val >>> 16;
          bytes[b++] = val >>> 8;
          bytes[b++] = val;
        }
      }
      bytes[b++] = TERMINAL_MODE.TTY_OP_END;
      if (b < bytes.length)
        return bufferSlice(bytes, 0, b);
      return bytes;
    }
    module2.exports = Protocol;
  }
});

// node_modules/ssh2/lib/protocol/node-fs-compat.js
var require_node_fs_compat = __commonJS({
  "node_modules/ssh2/lib/protocol/node-fs-compat.js"(exports) {
    "use strict";
    var assert = require("assert");
    var { inspect } = require("util");
    function addNumericalSeparator(val) {
      let res = "";
      let i = val.length;
      const start = val[0] === "-" ? 1 : 0;
      for (; i >= start + 4; i -= 3)
        res = `_${val.slice(i - 3, i)}${res}`;
      return `${val.slice(0, i)}${res}`;
    }
    function oneOf(expected, thing) {
      assert(typeof thing === "string", "`thing` has to be of type string");
      if (Array.isArray(expected)) {
        const len = expected.length;
        assert(len > 0, "At least one expected value needs to be specified");
        expected = expected.map((i) => String(i));
        if (len > 2) {
          return `one of ${thing} ${expected.slice(0, len - 1).join(", ")}, or ` + expected[len - 1];
        } else if (len === 2) {
          return `one of ${thing} ${expected[0]} or ${expected[1]}`;
        }
        return `of ${thing} ${expected[0]}`;
      }
      return `of ${thing} ${String(expected)}`;
    }
    exports.ERR_INTERNAL_ASSERTION = class ERR_INTERNAL_ASSERTION extends Error {
      constructor(message) {
        super();
        Error.captureStackTrace(this, ERR_INTERNAL_ASSERTION);
        const suffix = "This is caused by either a bug in ssh2 or incorrect usage of ssh2 internals.\nPlease open an issue with this stack trace at https://github.com/mscdex/ssh2/issues\n";
        this.message = message === void 0 ? suffix : `${message}
${suffix}`;
      }
    };
    var MAX_32BIT_INT = 2 ** 32;
    var MAX_32BIT_BIGINT = (() => {
      try {
        return new Function("return 2n ** 32n")();
      } catch {
      }
    })();
    exports.ERR_OUT_OF_RANGE = class ERR_OUT_OF_RANGE extends RangeError {
      constructor(str, range, input, replaceDefaultBoolean) {
        super();
        Error.captureStackTrace(this, ERR_OUT_OF_RANGE);
        assert(range, 'Missing "range" argument');
        let msg = replaceDefaultBoolean ? str : `The value of "${str}" is out of range.`;
        let received;
        if (Number.isInteger(input) && Math.abs(input) > MAX_32BIT_INT) {
          received = addNumericalSeparator(String(input));
        } else if (typeof input === "bigint") {
          received = String(input);
          if (input > MAX_32BIT_BIGINT || input < -MAX_32BIT_BIGINT)
            received = addNumericalSeparator(received);
          received += "n";
        } else {
          received = inspect(input);
        }
        msg += ` It must be ${range}. Received ${received}`;
        this.message = msg;
      }
    };
    var ERR_INVALID_ARG_TYPE = class extends TypeError {
      constructor(name, expected, actual) {
        super();
        Error.captureStackTrace(this, ERR_INVALID_ARG_TYPE);
        assert(typeof name === "string", `'name' must be a string`);
        let determiner;
        if (typeof expected === "string" && expected.startsWith("not ")) {
          determiner = "must not be";
          expected = expected.replace(/^not /, "");
        } else {
          determiner = "must be";
        }
        let msg;
        if (name.endsWith(" argument")) {
          msg = `The ${name} ${determiner} ${oneOf(expected, "type")}`;
        } else {
          const type = name.includes(".") ? "property" : "argument";
          msg = `The "${name}" ${type} ${determiner} ${oneOf(expected, "type")}`;
        }
        msg += `. Received type ${typeof actual}`;
        this.message = msg;
      }
    };
    exports.ERR_INVALID_ARG_TYPE = ERR_INVALID_ARG_TYPE;
    exports.validateNumber = function validateNumber(value, name) {
      if (typeof value !== "number")
        throw new ERR_INVALID_ARG_TYPE(name, "number", value);
    };
  }
});

// node_modules/ssh2/lib/protocol/SFTP.js
var require_SFTP = __commonJS({
  "node_modules/ssh2/lib/protocol/SFTP.js"(exports, module2) {
    "use strict";
    var EventEmitter = require("events");
    var fs2 = require("fs");
    var { constants } = fs2;
    var {
      Readable: ReadableStream,
      Writable: WritableStream
    } = require("stream");
    var { inherits, isDate } = require("util");
    var FastBuffer = Buffer[Symbol.species];
    var {
      bufferCopy,
      bufferSlice,
      makeBufferParser,
      writeUInt32BE
    } = require_utils2();
    var ATTR = {
      SIZE: 1,
      UIDGID: 2,
      PERMISSIONS: 4,
      ACMODTIME: 8,
      EXTENDED: 2147483648
    };
    var ATTRS_BUF = Buffer.alloc(28);
    var STATUS_CODE = {
      OK: 0,
      EOF: 1,
      NO_SUCH_FILE: 2,
      PERMISSION_DENIED: 3,
      FAILURE: 4,
      BAD_MESSAGE: 5,
      NO_CONNECTION: 6,
      CONNECTION_LOST: 7,
      OP_UNSUPPORTED: 8
    };
    var VALID_STATUS_CODES = new Map(Object.values(STATUS_CODE).map((n) => [n, 1]));
    var STATUS_CODE_STR = {
      [STATUS_CODE.OK]: "No error",
      [STATUS_CODE.EOF]: "End of file",
      [STATUS_CODE.NO_SUCH_FILE]: "No such file or directory",
      [STATUS_CODE.PERMISSION_DENIED]: "Permission denied",
      [STATUS_CODE.FAILURE]: "Failure",
      [STATUS_CODE.BAD_MESSAGE]: "Bad message",
      [STATUS_CODE.NO_CONNECTION]: "No connection",
      [STATUS_CODE.CONNECTION_LOST]: "Connection lost",
      [STATUS_CODE.OP_UNSUPPORTED]: "Operation unsupported"
    };
    var REQUEST = {
      INIT: 1,
      OPEN: 3,
      CLOSE: 4,
      READ: 5,
      WRITE: 6,
      LSTAT: 7,
      FSTAT: 8,
      SETSTAT: 9,
      FSETSTAT: 10,
      OPENDIR: 11,
      READDIR: 12,
      REMOVE: 13,
      MKDIR: 14,
      RMDIR: 15,
      REALPATH: 16,
      STAT: 17,
      RENAME: 18,
      READLINK: 19,
      SYMLINK: 20,
      EXTENDED: 200
    };
    var RESPONSE = {
      VERSION: 2,
      STATUS: 101,
      HANDLE: 102,
      DATA: 103,
      NAME: 104,
      ATTRS: 105,
      EXTENDED: 201
    };
    var OPEN_MODE = {
      READ: 1,
      WRITE: 2,
      APPEND: 4,
      CREAT: 8,
      TRUNC: 16,
      EXCL: 32
    };
    var PKT_RW_OVERHEAD = 2 * 1024;
    var MAX_REQID = 2 ** 32 - 1;
    var CLIENT_VERSION_BUFFER = Buffer.from([
      0,
      0,
      0,
      5,
      REQUEST.INIT,
      0,
      0,
      0,
      3
    ]);
    var SERVER_VERSION_BUFFER = Buffer.from([
      0,
      0,
      0,
      5,
      RESPONSE.VERSION,
      0,
      0,
      0,
      3
    ]);
    var RE_OPENSSH = /^SSH-2.0-(?:OpenSSH|dropbear)/;
    var OPENSSH_MAX_PKT_LEN = 256 * 1024;
    var bufferParser = makeBufferParser();
    var fakeStderr = {
      readable: false,
      writable: false,
      push: (data) => {
      },
      once: () => {
      },
      on: () => {
      },
      emit: () => {
      },
      end: () => {
      }
    };
    function noop() {
    }
    var SFTP = class extends EventEmitter {
      constructor(client, chanInfo, cfg) {
        super();
        if (typeof cfg !== "object" || !cfg)
          cfg = {};
        const remoteIdentRaw = client._protocol._remoteIdentRaw;
        this.server = !!cfg.server;
        this._debug = typeof cfg.debug === "function" ? cfg.debug : void 0;
        this._isOpenSSH = remoteIdentRaw && RE_OPENSSH.test(remoteIdentRaw);
        this._version = -1;
        this._extensions = {};
        this._biOpt = cfg.biOpt;
        this._pktLenBytes = 0;
        this._pktLen = 0;
        this._pktPos = 0;
        this._pktType = 0;
        this._pktData = void 0;
        this._writeReqid = -1;
        this._requests = {};
        this._maxInPktLen = OPENSSH_MAX_PKT_LEN;
        this._maxOutPktLen = 34e3;
        this._maxReadLen = (this._isOpenSSH ? OPENSSH_MAX_PKT_LEN : 34e3) - PKT_RW_OVERHEAD;
        this._maxWriteLen = (this._isOpenSSH ? OPENSSH_MAX_PKT_LEN : 34e3) - PKT_RW_OVERHEAD;
        this.maxOpenHandles = void 0;
        this._client = client;
        this._protocol = client._protocol;
        this._callbacks = [];
        this._hasX11 = false;
        this._exit = {
          code: void 0,
          signal: void 0,
          dump: void 0,
          desc: void 0
        };
        this._waitWindow = false;
        this._chunkcb = void 0;
        this._buffer = [];
        this.type = chanInfo.type;
        this.subtype = void 0;
        this.incoming = chanInfo.incoming;
        this.outgoing = chanInfo.outgoing;
        this.stderr = fakeStderr;
        this.readable = true;
      }
      push(data) {
        if (data === null) {
          cleanupRequests(this);
          if (!this.readable)
            return;
          this.readable = false;
          this.emit("end");
          return;
        }
        let p = 0;
        while (p < data.length) {
          if (this._pktLenBytes < 4) {
            let nb = Math.min(4 - this._pktLenBytes, data.length - p);
            this._pktLenBytes += nb;
            while (nb--)
              this._pktLen = (this._pktLen << 8) + data[p++];
            if (this._pktLenBytes < 4)
              return;
            if (this._pktLen === 0)
              return doFatalSFTPError(this, "Invalid packet length");
            if (this._pktLen > this._maxInPktLen) {
              const max = this._maxInPktLen;
              return doFatalSFTPError(this, `Packet length ${this._pktLen} exceeds max length of ${max}`);
            }
            if (p >= data.length)
              return;
          }
          if (this._pktPos < this._pktLen) {
            const nb = Math.min(this._pktLen - this._pktPos, data.length - p);
            if (p !== 0 || nb !== data.length) {
              if (nb === this._pktLen) {
                this._pkt = new FastBuffer(data.buffer, data.byteOffset + p, nb);
              } else {
                if (!this._pkt)
                  this._pkt = Buffer.allocUnsafe(this._pktLen);
                this._pkt.set(new Uint8Array(data.buffer, data.byteOffset + p, nb), this._pktPos);
              }
            } else if (nb === this._pktLen) {
              this._pkt = data;
            } else {
              if (!this._pkt)
                this._pkt = Buffer.allocUnsafe(this._pktLen);
              this._pkt.set(data, this._pktPos);
            }
            p += nb;
            this._pktPos += nb;
            if (this._pktPos < this._pktLen)
              return;
          }
          const type = this._pkt[0];
          const payload = this._pkt;
          this._pktLen = 0;
          this._pktLenBytes = 0;
          this._pkt = void 0;
          this._pktPos = 0;
          const handler = this.server ? SERVER_HANDLERS[type] : CLIENT_HANDLERS[type];
          if (!handler)
            return doFatalSFTPError(this, `Unknown packet type ${type}`);
          if (this._version === -1) {
            if (this.server) {
              if (type !== REQUEST.INIT)
                return doFatalSFTPError(this, `Expected INIT packet, got ${type}`);
            } else if (type !== RESPONSE.VERSION) {
              return doFatalSFTPError(this, `Expected VERSION packet, got ${type}`);
            }
          }
          if (handler(this, payload) === false)
            return;
        }
      }
      end() {
        this.destroy();
      }
      destroy() {
        if (this.outgoing.state === "open" || this.outgoing.state === "eof") {
          this.outgoing.state = "closing";
          this._protocol.channelClose(this.outgoing.id);
        }
      }
      _init() {
        this._init = noop;
        if (!this.server)
          sendOrBuffer(this, CLIENT_VERSION_BUFFER);
      }
      createReadStream(path2, options) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        return new ReadStream(this, path2, options);
      }
      createWriteStream(path2, options) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        return new WriteStream(this, path2, options);
      }
      open(path2, flags_, attrs, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (typeof attrs === "function") {
          cb = attrs;
          attrs = void 0;
        }
        const flags = typeof flags_ === "number" ? flags_ : stringToFlags(flags_);
        if (flags === null)
          throw new Error(`Unknown flags string: ${flags_}`);
        let attrsFlags = 0;
        let attrsLen = 0;
        if (typeof attrs === "string" || typeof attrs === "number")
          attrs = { mode: attrs };
        if (typeof attrs === "object" && attrs !== null) {
          attrs = attrsToBytes(attrs);
          attrsFlags = attrs.flags;
          attrsLen = attrs.nb;
        }
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen + 4 + 4 + attrsLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.OPEN;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        writeUInt32BE(buf, flags, p += pathLen);
        writeUInt32BE(buf, attrsFlags, p += 4);
        if (attrsLen) {
          p += 4;
          if (attrsLen === ATTRS_BUF.length)
            buf.set(ATTRS_BUF, p);
          else
            bufferCopy(ATTRS_BUF, buf, 0, attrsLen, p);
          p += attrsLen;
        }
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} OPEN`);
      }
      close(handle, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (!Buffer.isBuffer(handle))
          throw new Error("handle is not a Buffer");
        const handleLen = handle.length;
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + handleLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.CLOSE;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, handleLen, p);
        buf.set(handle, p += 4);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} CLOSE`);
      }
      read(handle, buf, off, len, position, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (!Buffer.isBuffer(handle))
          throw new Error("handle is not a Buffer");
        if (!Buffer.isBuffer(buf))
          throw new Error("buffer is not a Buffer");
        if (off >= buf.length)
          throw new Error("offset is out of bounds");
        if (off + len > buf.length)
          throw new Error("length extends beyond buffer");
        if (position === null)
          throw new Error("null position currently unsupported");
        read_(this, handle, buf, off, len, position, cb);
      }
      readData(handle, buf, off, len, position, cb) {
        this.read(handle, buf, off, len, position, cb);
      }
      write(handle, buf, off, len, position, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (!Buffer.isBuffer(handle))
          throw new Error("handle is not a Buffer");
        if (!Buffer.isBuffer(buf))
          throw new Error("buffer is not a Buffer");
        if (off > buf.length)
          throw new Error("offset is out of bounds");
        if (off + len > buf.length)
          throw new Error("length extends beyond buffer");
        if (position === null)
          throw new Error("null position currently unsupported");
        if (!len) {
          cb && process.nextTick(cb, void 0, 0);
          return;
        }
        const maxDataLen = this._maxWriteLen;
        const overflow = Math.max(len - maxDataLen, 0);
        const origPosition = position;
        if (overflow)
          len = maxDataLen;
        const handleLen = handle.length;
        let p = 9;
        const out = Buffer.allocUnsafe(4 + 1 + 4 + 4 + handleLen + 8 + 4 + len);
        writeUInt32BE(out, out.length - 4, 0);
        out[4] = REQUEST.WRITE;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(out, reqid, 5);
        writeUInt32BE(out, handleLen, p);
        out.set(handle, p += 4);
        p += handleLen;
        for (let i = 7; i >= 0; --i) {
          out[p + i] = position & 255;
          position /= 256;
        }
        writeUInt32BE(out, len, p += 8);
        bufferCopy(buf, out, off, off + len, p += 4);
        this._requests[reqid] = {
          cb: (err) => {
            if (err) {
              if (typeof cb === "function")
                cb(err);
            } else if (overflow) {
              this.write(handle, buf, off + len, overflow, origPosition + len, cb);
            } else if (typeof cb === "function") {
              cb(void 0, off + len);
            }
          }
        };
        const isSent = sendOrBuffer(this, out);
        if (this._debug) {
          const how = isSent ? "Sent" : "Buffered";
          this._debug(`SFTP: Outbound: ${how} WRITE (id:${reqid})`);
        }
      }
      writeData(handle, buf, off, len, position, cb) {
        this.write(handle, buf, off, len, position, cb);
      }
      fastGet(remotePath, localPath, opts, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        fastXfer(this, fs2, remotePath, localPath, opts, cb);
      }
      fastPut(localPath, remotePath, opts, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        fastXfer(fs2, this, localPath, remotePath, opts, cb);
      }
      readFile(path2, options, callback_) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        let callback;
        if (typeof callback_ === "function") {
          callback = callback_;
        } else if (typeof options === "function") {
          callback = options;
          options = void 0;
        }
        if (typeof options === "string")
          options = { encoding: options, flag: "r" };
        else if (!options)
          options = { encoding: null, flag: "r" };
        else if (typeof options !== "object")
          throw new TypeError("Bad arguments");
        const encoding = options.encoding;
        if (encoding && !Buffer.isEncoding(encoding))
          throw new Error(`Unknown encoding: ${encoding}`);
        let size;
        let buffer;
        let buffers;
        let pos = 0;
        let handle;
        let bytesRead = 0;
        const flag = options.flag || "r";
        const read = () => {
          if (size === 0) {
            buffer = Buffer.allocUnsafe(8192);
            this.read(handle, buffer, 0, 8192, bytesRead, afterRead);
          } else {
            this.read(handle, buffer, pos, size - pos, bytesRead, afterRead);
          }
        };
        const afterRead = (er, nbytes) => {
          let eof;
          if (er) {
            eof = er.code === STATUS_CODE.EOF;
            if (!eof) {
              return this.close(handle, () => {
                return callback && callback(er);
              });
            }
          } else {
            eof = false;
          }
          if (eof || size === 0 && nbytes === 0)
            return close();
          bytesRead += nbytes;
          pos += nbytes;
          if (size !== 0) {
            if (pos === size)
              close();
            else
              read();
          } else {
            buffers.push(bufferSlice(buffer, 0, nbytes));
            read();
          }
        };
        afterRead._wantEOFError = true;
        const close = () => {
          this.close(handle, (er) => {
            if (size === 0) {
              buffer = Buffer.concat(buffers, pos);
            } else if (pos < size) {
              buffer = bufferSlice(buffer, 0, pos);
            }
            if (encoding)
              buffer = buffer.toString(encoding);
            return callback && callback(er, buffer);
          });
        };
        this.open(path2, flag, 438, (er, handle_) => {
          if (er)
            return callback && callback(er);
          handle = handle_;
          const tryStat = (er2, st) => {
            if (er2) {
              this.stat(path2, (er_, st_) => {
                if (er_) {
                  return this.close(handle, () => {
                    callback && callback(er2);
                  });
                }
                tryStat(null, st_);
              });
              return;
            }
            size = st.size || 0;
            if (size === 0) {
              buffers = [];
              return read();
            }
            buffer = Buffer.allocUnsafe(size);
            read();
          };
          this.fstat(handle, tryStat);
        });
      }
      writeFile(path2, data, options, callback_) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        let callback;
        if (typeof callback_ === "function") {
          callback = callback_;
        } else if (typeof options === "function") {
          callback = options;
          options = void 0;
        }
        if (typeof options === "string")
          options = { encoding: options, mode: 438, flag: "w" };
        else if (!options)
          options = { encoding: "utf8", mode: 438, flag: "w" };
        else if (typeof options !== "object")
          throw new TypeError("Bad arguments");
        if (options.encoding && !Buffer.isEncoding(options.encoding))
          throw new Error(`Unknown encoding: ${options.encoding}`);
        const flag = options.flag || "w";
        this.open(path2, flag, options.mode, (openErr, handle) => {
          if (openErr) {
            callback && callback(openErr);
          } else {
            const buffer = Buffer.isBuffer(data) ? data : Buffer.from("" + data, options.encoding || "utf8");
            const position = /a/.test(flag) ? null : 0;
            if (position === null) {
              const tryStat = (er, st) => {
                if (er) {
                  this.stat(path2, (er_, st_) => {
                    if (er_) {
                      return this.close(handle, () => {
                        callback && callback(er);
                      });
                    }
                    tryStat(null, st_);
                  });
                  return;
                }
                writeAll(this, handle, buffer, 0, buffer.length, st.size, callback);
              };
              this.fstat(handle, tryStat);
              return;
            }
            writeAll(this, handle, buffer, 0, buffer.length, position, callback);
          }
        });
      }
      appendFile(path2, data, options, callback_) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        let callback;
        if (typeof callback_ === "function") {
          callback = callback_;
        } else if (typeof options === "function") {
          callback = options;
          options = void 0;
        }
        if (typeof options === "string")
          options = { encoding: options, mode: 438, flag: "a" };
        else if (!options)
          options = { encoding: "utf8", mode: 438, flag: "a" };
        else if (typeof options !== "object")
          throw new TypeError("Bad arguments");
        if (!options.flag)
          options = Object.assign({ flag: "a" }, options);
        this.writeFile(path2, data, options, callback);
      }
      exists(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        this.stat(path2, (err) => {
          cb && cb(err ? false : true);
        });
      }
      unlink(filename, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const fnameLen = Buffer.byteLength(filename);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + fnameLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.REMOVE;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, fnameLen, p);
        buf.utf8Write(filename, p += 4, fnameLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} REMOVE`);
      }
      rename(oldPath, newPath, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const oldLen = Buffer.byteLength(oldPath);
        const newLen = Buffer.byteLength(newPath);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + oldLen + 4 + newLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.RENAME;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, oldLen, p);
        buf.utf8Write(oldPath, p += 4, oldLen);
        writeUInt32BE(buf, newLen, p += oldLen);
        buf.utf8Write(newPath, p += 4, newLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} RENAME`);
      }
      mkdir(path2, attrs, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        let flags = 0;
        let attrsLen = 0;
        if (typeof attrs === "function") {
          cb = attrs;
          attrs = void 0;
        }
        if (typeof attrs === "object" && attrs !== null) {
          attrs = attrsToBytes(attrs);
          flags = attrs.flags;
          attrsLen = attrs.nb;
        }
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen + 4 + attrsLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.MKDIR;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        writeUInt32BE(buf, flags, p += pathLen);
        if (attrsLen) {
          p += 4;
          if (attrsLen === ATTRS_BUF.length)
            buf.set(ATTRS_BUF, p);
          else
            bufferCopy(ATTRS_BUF, buf, 0, attrsLen, p);
          p += attrsLen;
        }
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} MKDIR`);
      }
      rmdir(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.RMDIR;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} RMDIR`);
      }
      readdir(where, opts, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (typeof opts === "function") {
          cb = opts;
          opts = {};
        }
        if (typeof opts !== "object" || opts === null)
          opts = {};
        const doFilter = opts && opts.full ? false : true;
        if (!Buffer.isBuffer(where) && typeof where !== "string")
          throw new Error("missing directory handle or path");
        if (typeof where === "string") {
          const entries = [];
          let e = 0;
          const reread = (err, handle) => {
            if (err)
              return cb(err);
            this.readdir(handle, opts, (err2, list) => {
              const eof = err2 && err2.code === STATUS_CODE.EOF;
              if (err2 && !eof)
                return this.close(handle, () => cb(err2));
              if (eof) {
                return this.close(handle, (err3) => {
                  if (err3)
                    return cb(err3);
                  cb(void 0, entries);
                });
              }
              for (let i = 0; i < list.length; ++i, ++e)
                entries[e] = list[i];
              reread(void 0, handle);
            });
          };
          return this.opendir(where, reread);
        }
        const handleLen = where.length;
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + handleLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.READDIR;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, handleLen, p);
        buf.set(where, p += 4);
        this._requests[reqid] = {
          cb: doFilter ? (err, list) => {
            if (typeof cb !== "function")
              return;
            if (err)
              return cb(err);
            for (let i = list.length - 1; i >= 0; --i) {
              if (list[i].filename === "." || list[i].filename === "..")
                list.splice(i, 1);
            }
            cb(void 0, list);
          } : cb
        };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} READDIR`);
      }
      fstat(handle, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (!Buffer.isBuffer(handle))
          throw new Error("handle is not a Buffer");
        const handleLen = handle.length;
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + handleLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.FSTAT;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, handleLen, p);
        buf.set(handle, p += 4);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} FSTAT`);
      }
      stat(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.STAT;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} STAT`);
      }
      lstat(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.LSTAT;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} LSTAT`);
      }
      opendir(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.OPENDIR;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} OPENDIR`);
      }
      setstat(path2, attrs, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        let flags = 0;
        let attrsLen = 0;
        if (typeof attrs === "object" && attrs !== null) {
          attrs = attrsToBytes(attrs);
          flags = attrs.flags;
          attrsLen = attrs.nb;
        } else if (typeof attrs === "function") {
          cb = attrs;
        }
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen + 4 + attrsLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.SETSTAT;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        writeUInt32BE(buf, flags, p += pathLen);
        if (attrsLen) {
          p += 4;
          if (attrsLen === ATTRS_BUF.length)
            buf.set(ATTRS_BUF, p);
          else
            bufferCopy(ATTRS_BUF, buf, 0, attrsLen, p);
          p += attrsLen;
        }
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} SETSTAT`);
      }
      fsetstat(handle, attrs, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (!Buffer.isBuffer(handle))
          throw new Error("handle is not a Buffer");
        let flags = 0;
        let attrsLen = 0;
        if (typeof attrs === "object" && attrs !== null) {
          attrs = attrsToBytes(attrs);
          flags = attrs.flags;
          attrsLen = attrs.nb;
        } else if (typeof attrs === "function") {
          cb = attrs;
        }
        const handleLen = handle.length;
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + handleLen + 4 + attrsLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.FSETSTAT;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, handleLen, p);
        buf.set(handle, p += 4);
        writeUInt32BE(buf, flags, p += handleLen);
        if (attrsLen) {
          p += 4;
          if (attrsLen === ATTRS_BUF.length)
            buf.set(ATTRS_BUF, p);
          else
            bufferCopy(ATTRS_BUF, buf, 0, attrsLen, p);
          p += attrsLen;
        }
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} FSETSTAT`);
      }
      futimes(handle, atime, mtime, cb) {
        return this.fsetstat(handle, {
          atime: toUnixTimestamp(atime),
          mtime: toUnixTimestamp(mtime)
        }, cb);
      }
      utimes(path2, atime, mtime, cb) {
        return this.setstat(path2, {
          atime: toUnixTimestamp(atime),
          mtime: toUnixTimestamp(mtime)
        }, cb);
      }
      fchown(handle, uid, gid, cb) {
        return this.fsetstat(handle, {
          uid,
          gid
        }, cb);
      }
      chown(path2, uid, gid, cb) {
        return this.setstat(path2, {
          uid,
          gid
        }, cb);
      }
      fchmod(handle, mode, cb) {
        return this.fsetstat(handle, {
          mode
        }, cb);
      }
      chmod(path2, mode, cb) {
        return this.setstat(path2, {
          mode
        }, cb);
      }
      readlink(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.READLINK;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        this._requests[reqid] = {
          cb: (err, names) => {
            if (typeof cb !== "function")
              return;
            if (err)
              return cb(err);
            if (!names || !names.length)
              return cb(new Error("Response missing link info"));
            cb(void 0, names[0].filename);
          }
        };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} READLINK`);
      }
      symlink(targetPath, linkPath, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const linkLen = Buffer.byteLength(linkPath);
        const targetLen = Buffer.byteLength(targetPath);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + linkLen + 4 + targetLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.SYMLINK;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        if (this._isOpenSSH) {
          writeUInt32BE(buf, targetLen, p);
          buf.utf8Write(targetPath, p += 4, targetLen);
          writeUInt32BE(buf, linkLen, p += targetLen);
          buf.utf8Write(linkPath, p += 4, linkLen);
        } else {
          writeUInt32BE(buf, linkLen, p);
          buf.utf8Write(linkPath, p += 4, linkLen);
          writeUInt32BE(buf, targetLen, p += linkLen);
          buf.utf8Write(targetPath, p += 4, targetLen);
        }
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} SYMLINK`);
      }
      realpath(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + pathLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.REALPATH;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, pathLen, p);
        buf.utf8Write(path2, p += 4, pathLen);
        this._requests[reqid] = {
          cb: (err, names) => {
            if (typeof cb !== "function")
              return;
            if (err)
              return cb(err);
            if (!names || !names.length)
              return cb(new Error("Response missing path info"));
            cb(void 0, names[0].filename);
          }
        };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} REALPATH`);
      }
      ext_openssh_rename(oldPath, newPath, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const ext = this._extensions["posix-rename@openssh.com"];
        if (!ext || ext !== "1")
          throw new Error("Server does not support this extended request");
        const oldLen = Buffer.byteLength(oldPath);
        const newLen = Buffer.byteLength(newPath);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 24 + 4 + oldLen + 4 + newLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.EXTENDED;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, 24, p);
        buf.utf8Write("posix-rename@openssh.com", p += 4, 24);
        writeUInt32BE(buf, oldLen, p += 24);
        buf.utf8Write(oldPath, p += 4, oldLen);
        writeUInt32BE(buf, newLen, p += oldLen);
        buf.utf8Write(newPath, p += 4, newLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        if (this._debug) {
          const which = isBuffered ? "Buffered" : "Sending";
          this._debug(`SFTP: Outbound: ${which} posix-rename@openssh.com`);
        }
      }
      ext_openssh_statvfs(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const ext = this._extensions["statvfs@openssh.com"];
        if (!ext || ext !== "2")
          throw new Error("Server does not support this extended request");
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 19 + 4 + pathLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.EXTENDED;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, 19, p);
        buf.utf8Write("statvfs@openssh.com", p += 4, 19);
        writeUInt32BE(buf, pathLen, p += 19);
        buf.utf8Write(path2, p += 4, pathLen);
        this._requests[reqid] = { extended: "statvfs@openssh.com", cb };
        const isBuffered = sendOrBuffer(this, buf);
        if (this._debug) {
          const which = isBuffered ? "Buffered" : "Sending";
          this._debug(`SFTP: Outbound: ${which} statvfs@openssh.com`);
        }
      }
      ext_openssh_fstatvfs(handle, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const ext = this._extensions["fstatvfs@openssh.com"];
        if (!ext || ext !== "2")
          throw new Error("Server does not support this extended request");
        if (!Buffer.isBuffer(handle))
          throw new Error("handle is not a Buffer");
        const handleLen = handle.length;
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 20 + 4 + handleLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.EXTENDED;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, 20, p);
        buf.utf8Write("fstatvfs@openssh.com", p += 4, 20);
        writeUInt32BE(buf, handleLen, p += 20);
        buf.set(handle, p += 4);
        this._requests[reqid] = { extended: "fstatvfs@openssh.com", cb };
        const isBuffered = sendOrBuffer(this, buf);
        if (this._debug) {
          const which = isBuffered ? "Buffered" : "Sending";
          this._debug(`SFTP: Outbound: ${which} fstatvfs@openssh.com`);
        }
      }
      ext_openssh_hardlink(oldPath, newPath, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const ext = this._extensions["hardlink@openssh.com"];
        if (ext !== "1")
          throw new Error("Server does not support this extended request");
        const oldLen = Buffer.byteLength(oldPath);
        const newLen = Buffer.byteLength(newPath);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 20 + 4 + oldLen + 4 + newLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.EXTENDED;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, 20, p);
        buf.utf8Write("hardlink@openssh.com", p += 4, 20);
        writeUInt32BE(buf, oldLen, p += 20);
        buf.utf8Write(oldPath, p += 4, oldLen);
        writeUInt32BE(buf, newLen, p += oldLen);
        buf.utf8Write(newPath, p += 4, newLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        if (this._debug) {
          const which = isBuffered ? "Buffered" : "Sending";
          this._debug(`SFTP: Outbound: ${which} hardlink@openssh.com`);
        }
      }
      ext_openssh_fsync(handle, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const ext = this._extensions["fsync@openssh.com"];
        if (ext !== "1")
          throw new Error("Server does not support this extended request");
        if (!Buffer.isBuffer(handle))
          throw new Error("handle is not a Buffer");
        const handleLen = handle.length;
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 17 + 4 + handleLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.EXTENDED;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, 17, p);
        buf.utf8Write("fsync@openssh.com", p += 4, 17);
        writeUInt32BE(buf, handleLen, p += 17);
        buf.set(handle, p += 4);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} fsync@openssh.com`);
      }
      ext_openssh_lsetstat(path2, attrs, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const ext = this._extensions["lsetstat@openssh.com"];
        if (ext !== "1")
          throw new Error("Server does not support this extended request");
        let flags = 0;
        let attrsLen = 0;
        if (typeof attrs === "object" && attrs !== null) {
          attrs = attrsToBytes(attrs);
          flags = attrs.flags;
          attrsLen = attrs.nb;
        } else if (typeof attrs === "function") {
          cb = attrs;
        }
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 20 + 4 + pathLen + 4 + attrsLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.EXTENDED;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, 20, p);
        buf.utf8Write("lsetstat@openssh.com", p += 4, 20);
        writeUInt32BE(buf, pathLen, p += 20);
        buf.utf8Write(path2, p += 4, pathLen);
        writeUInt32BE(buf, flags, p += pathLen);
        if (attrsLen) {
          p += 4;
          if (attrsLen === ATTRS_BUF.length)
            buf.set(ATTRS_BUF, p);
          else
            bufferCopy(ATTRS_BUF, buf, 0, attrsLen, p);
          p += attrsLen;
        }
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        if (this._debug) {
          const status = isBuffered ? "Buffered" : "Sending";
          this._debug(`SFTP: Outbound: ${status} lsetstat@openssh.com`);
        }
      }
      ext_openssh_expandPath(path2, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const ext = this._extensions["expand-path@openssh.com"];
        if (ext !== "1")
          throw new Error("Server does not support this extended request");
        const pathLen = Buffer.byteLength(path2);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 23 + 4 + pathLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = REQUEST.EXTENDED;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, 23, p);
        buf.utf8Write("expand-path@openssh.com", p += 4, 23);
        writeUInt32BE(buf, pathLen, p += 20);
        buf.utf8Write(path2, p += 4, pathLen);
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        if (this._debug) {
          const status = isBuffered ? "Buffered" : "Sending";
          this._debug(`SFTP: Outbound: ${status} expand-path@openssh.com`);
        }
      }
      ext_copy_data(srcHandle, srcOffset, len, dstHandle, dstOffset, cb) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        const ext = this._extensions["copy-data"];
        if (ext !== "1")
          throw new Error("Server does not support this extended request");
        if (!Buffer.isBuffer(srcHandle))
          throw new Error("Source handle is not a Buffer");
        if (!Buffer.isBuffer(dstHandle))
          throw new Error("Destination handle is not a Buffer");
        let p = 0;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 9 + 4 + srcHandle.length + 8 + 8 + 4 + dstHandle.length + 8);
        writeUInt32BE(buf, buf.length - 4, p);
        p += 4;
        buf[p] = REQUEST.EXTENDED;
        ++p;
        const reqid = this._writeReqid = this._writeReqid + 1 & MAX_REQID;
        writeUInt32BE(buf, reqid, p);
        p += 4;
        writeUInt32BE(buf, 9, p);
        p += 4;
        buf.utf8Write("copy-data", p, 9);
        p += 9;
        writeUInt32BE(buf, srcHandle.length, p);
        p += 4;
        buf.set(srcHandle, p);
        p += srcHandle.length;
        for (let i = 7; i >= 0; --i) {
          buf[p + i] = srcOffset & 255;
          srcOffset /= 256;
        }
        p += 8;
        for (let i = 7; i >= 0; --i) {
          buf[p + i] = len & 255;
          len /= 256;
        }
        p += 8;
        writeUInt32BE(buf, dstHandle.length, p);
        p += 4;
        buf.set(dstHandle, p);
        p += dstHandle.length;
        for (let i = 7; i >= 0; --i) {
          buf[p + i] = dstOffset & 255;
          dstOffset /= 256;
        }
        this._requests[reqid] = { cb };
        const isBuffered = sendOrBuffer(this, buf);
        if (this._debug) {
          const status = isBuffered ? "Buffered" : "Sending";
          this._debug(`SFTP: Outbound: ${status} copy-data`);
        }
      }
      handle(reqid, handle) {
        if (!this.server)
          throw new Error("Server-only method called in client mode");
        if (!Buffer.isBuffer(handle))
          throw new Error("handle is not a Buffer");
        const handleLen = handle.length;
        if (handleLen > 256)
          throw new Error("handle too large (> 256 bytes)");
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + handleLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = RESPONSE.HANDLE;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, handleLen, p);
        if (handleLen)
          buf.set(handle, p += 4);
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} HANDLE`);
      }
      status(reqid, code, message) {
        if (!this.server)
          throw new Error("Server-only method called in client mode");
        if (!VALID_STATUS_CODES.has(code))
          throw new Error(`Bad status code: ${code}`);
        message || (message = "");
        const msgLen = Buffer.byteLength(message);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 4 + msgLen + 4);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = RESPONSE.STATUS;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, code, p);
        writeUInt32BE(buf, msgLen, p += 4);
        p += 4;
        if (msgLen) {
          buf.utf8Write(message, p, msgLen);
          p += msgLen;
        }
        writeUInt32BE(buf, 0, p);
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} STATUS`);
      }
      data(reqid, data, encoding) {
        if (!this.server)
          throw new Error("Server-only method called in client mode");
        const isBuffer = Buffer.isBuffer(data);
        if (!isBuffer && typeof data !== "string")
          throw new Error("data is not a Buffer or string");
        let isUTF8;
        if (!isBuffer && !encoding) {
          encoding = void 0;
          isUTF8 = true;
        }
        const dataLen = isBuffer ? data.length : Buffer.byteLength(data, encoding);
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + dataLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = RESPONSE.DATA;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, dataLen, p);
        if (dataLen) {
          if (isBuffer)
            buf.set(data, p += 4);
          else if (isUTF8)
            buf.utf8Write(data, p += 4, dataLen);
          else
            buf.write(data, p += 4, dataLen, encoding);
        }
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} DATA`);
      }
      name(reqid, names) {
        if (!this.server)
          throw new Error("Server-only method called in client mode");
        if (!Array.isArray(names)) {
          if (typeof names !== "object" || names === null)
            throw new Error("names is not an object or array");
          names = [names];
        }
        const count = names.length;
        let namesLen = 0;
        let nameAttrs;
        const attrs = [];
        for (let i = 0; i < count; ++i) {
          const name = names[i];
          const filename = !name || !name.filename || typeof name.filename !== "string" ? "" : name.filename;
          namesLen += 4 + Buffer.byteLength(filename);
          const longname = !name || !name.longname || typeof name.longname !== "string" ? "" : name.longname;
          namesLen += 4 + Buffer.byteLength(longname);
          if (typeof name.attrs === "object" && name.attrs !== null) {
            nameAttrs = attrsToBytes(name.attrs);
            namesLen += 4 + nameAttrs.nb;
            if (nameAttrs.nb) {
              let bytes;
              if (nameAttrs.nb === ATTRS_BUF.length) {
                bytes = new Uint8Array(ATTRS_BUF);
              } else {
                bytes = new Uint8Array(nameAttrs.nb);
                bufferCopy(ATTRS_BUF, bytes, 0, nameAttrs.nb, 0);
              }
              nameAttrs.bytes = bytes;
            }
            attrs.push(nameAttrs);
          } else {
            namesLen += 4;
            attrs.push(null);
          }
        }
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + namesLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = RESPONSE.NAME;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, count, p);
        p += 4;
        for (let i = 0; i < count; ++i) {
          const name = names[i];
          {
            const filename = !name || !name.filename || typeof name.filename !== "string" ? "" : name.filename;
            const len = Buffer.byteLength(filename);
            writeUInt32BE(buf, len, p);
            p += 4;
            if (len) {
              buf.utf8Write(filename, p, len);
              p += len;
            }
          }
          {
            const longname = !name || !name.longname || typeof name.longname !== "string" ? "" : name.longname;
            const len = Buffer.byteLength(longname);
            writeUInt32BE(buf, len, p);
            p += 4;
            if (len) {
              buf.utf8Write(longname, p, len);
              p += len;
            }
          }
          const attr = attrs[i];
          if (attr) {
            writeUInt32BE(buf, attr.flags, p);
            p += 4;
            if (attr.flags && attr.bytes) {
              buf.set(attr.bytes, p);
              p += attr.nb;
            }
          } else {
            writeUInt32BE(buf, 0, p);
            p += 4;
          }
        }
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} NAME`);
      }
      attrs(reqid, attrs) {
        if (!this.server)
          throw new Error("Server-only method called in client mode");
        if (typeof attrs !== "object" || attrs === null)
          throw new Error("attrs is not an object");
        attrs = attrsToBytes(attrs);
        const flags = attrs.flags;
        const attrsLen = attrs.nb;
        let p = 9;
        const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + attrsLen);
        writeUInt32BE(buf, buf.length - 4, 0);
        buf[4] = RESPONSE.ATTRS;
        writeUInt32BE(buf, reqid, 5);
        writeUInt32BE(buf, flags, p);
        if (attrsLen) {
          p += 4;
          if (attrsLen === ATTRS_BUF.length)
            buf.set(ATTRS_BUF, p);
          else
            bufferCopy(ATTRS_BUF, buf, 0, attrsLen, p);
          p += attrsLen;
        }
        const isBuffered = sendOrBuffer(this, buf);
        this._debug && this._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} ATTRS`);
      }
    };
    function tryCreateBuffer(size) {
      try {
        return Buffer.allocUnsafe(size);
      } catch (ex) {
        return ex;
      }
    }
    function read_(self2, handle, buf, off, len, position, cb, req_) {
      const maxDataLen = self2._maxReadLen;
      const overflow = Math.max(len - maxDataLen, 0);
      if (overflow)
        len = maxDataLen;
      const handleLen = handle.length;
      let p = 9;
      let pos = position;
      const out = Buffer.allocUnsafe(4 + 1 + 4 + 4 + handleLen + 8 + 4);
      writeUInt32BE(out, out.length - 4, 0);
      out[4] = REQUEST.READ;
      const reqid = self2._writeReqid = self2._writeReqid + 1 & MAX_REQID;
      writeUInt32BE(out, reqid, 5);
      writeUInt32BE(out, handleLen, p);
      out.set(handle, p += 4);
      p += handleLen;
      for (let i = 7; i >= 0; --i) {
        out[p + i] = pos & 255;
        pos /= 256;
      }
      writeUInt32BE(out, len, p += 8);
      if (typeof cb !== "function")
        cb = noop;
      const req = req_ || {
        nb: 0,
        position,
        off,
        origOff: off,
        len: void 0,
        overflow: void 0,
        cb: (err, data, nb) => {
          const len2 = req.len;
          const overflow2 = req.overflow;
          if (err) {
            if (cb._wantEOFError || err.code !== STATUS_CODE.EOF)
              return cb(err);
          } else if (nb > len2) {
            return cb(new Error("Received more data than requested"));
          } else if (nb === len2 && overflow2) {
            req.nb += nb;
            req.position += nb;
            req.off += nb;
            read_(self2, handle, buf, req.off, overflow2, req.position, cb, req);
            return;
          }
          nb = nb || 0;
          if (req.origOff === 0 && buf.length === req.nb)
            data = buf;
          else
            data = bufferSlice(buf, req.origOff, req.origOff + req.nb + nb);
          cb(void 0, req.nb + nb, data, req.position);
        },
        buffer: void 0
      };
      req.len = len;
      req.overflow = overflow;
      req.buffer = bufferSlice(buf, off, off + len);
      self2._requests[reqid] = req;
      const isBuffered = sendOrBuffer(self2, out);
      self2._debug && self2._debug(`SFTP: Outbound: ${isBuffered ? "Buffered" : "Sending"} READ`);
    }
    function fastXfer(src, dst, srcPath, dstPath, opts, cb) {
      let concurrency = 64;
      let chunkSize = 32768;
      let onstep;
      let mode;
      let fileSize;
      if (typeof opts === "function") {
        cb = opts;
      } else if (typeof opts === "object" && opts !== null) {
        if (typeof opts.concurrency === "number" && opts.concurrency > 0 && !isNaN(opts.concurrency)) {
          concurrency = opts.concurrency;
        }
        if (typeof opts.chunkSize === "number" && opts.chunkSize > 0 && !isNaN(opts.chunkSize)) {
          chunkSize = opts.chunkSize;
        }
        if (typeof opts.fileSize === "number" && opts.fileSize > 0 && !isNaN(opts.fileSize)) {
          fileSize = opts.fileSize;
        }
        if (typeof opts.step === "function")
          onstep = opts.step;
        if (typeof opts.mode === "string" || typeof opts.mode === "number")
          mode = modeNum(opts.mode);
      }
      let fsize;
      let pdst = 0;
      let total = 0;
      let hadError = false;
      let srcHandle;
      let dstHandle;
      let readbuf;
      let bufsize = chunkSize * concurrency;
      function onerror(err) {
        if (hadError)
          return;
        hadError = true;
        let left = 0;
        let cbfinal;
        if (srcHandle || dstHandle) {
          cbfinal = () => {
            if (--left === 0)
              cb(err);
          };
          if (srcHandle && (src === fs2 || src.outgoing.state === "open"))
            ++left;
          if (dstHandle && (dst === fs2 || dst.outgoing.state === "open"))
            ++left;
          if (srcHandle && (src === fs2 || src.outgoing.state === "open"))
            src.close(srcHandle, cbfinal);
          if (dstHandle && (dst === fs2 || dst.outgoing.state === "open"))
            dst.close(dstHandle, cbfinal);
        } else {
          cb(err);
        }
      }
      src.open(srcPath, "r", (err, sourceHandle) => {
        if (err)
          return onerror(err);
        srcHandle = sourceHandle;
        if (fileSize === void 0)
          src.fstat(srcHandle, tryStat);
        else
          tryStat(null, { size: fileSize });
        function tryStat(err2, attrs) {
          if (err2) {
            if (src !== fs2) {
              src.stat(srcPath, (err_, attrs_) => {
                if (err_)
                  return onerror(err2);
                tryStat(null, attrs_);
              });
              return;
            }
            return onerror(err2);
          }
          fsize = attrs.size;
          dst.open(dstPath, "w", (err3, destHandle) => {
            if (err3)
              return onerror(err3);
            dstHandle = destHandle;
            if (fsize <= 0)
              return onerror();
            while (bufsize > fsize) {
              if (concurrency === 1) {
                bufsize = fsize;
                break;
              }
              bufsize -= chunkSize;
              --concurrency;
            }
            readbuf = tryCreateBuffer(bufsize);
            if (readbuf instanceof Error)
              return onerror(readbuf);
            if (mode !== void 0) {
              dst.fchmod(dstHandle, mode, function tryAgain(err4) {
                if (err4) {
                  dst.chmod(dstPath, mode, (err_) => tryAgain());
                  return;
                }
                startReads();
              });
            } else {
              startReads();
            }
            function onread(err4, nb, data, dstpos, datapos, origChunkLen) {
              if (err4)
                return onerror(err4);
              datapos = datapos || 0;
              dst.write(dstHandle, readbuf, datapos, nb, dstpos, writeCb);
              function writeCb(err5) {
                if (err5)
                  return onerror(err5);
                total += nb;
                onstep && onstep(total, nb, fsize);
                if (nb < origChunkLen)
                  return singleRead(datapos, dstpos + nb, origChunkLen - nb);
                if (total === fsize) {
                  dst.close(dstHandle, (err6) => {
                    dstHandle = void 0;
                    if (err6)
                      return onerror(err6);
                    src.close(srcHandle, (err7) => {
                      srcHandle = void 0;
                      if (err7)
                        return onerror(err7);
                      cb();
                    });
                  });
                  return;
                }
                if (pdst >= fsize)
                  return;
                const chunk = pdst + chunkSize > fsize ? fsize - pdst : chunkSize;
                singleRead(datapos, pdst, chunk);
                pdst += chunk;
              }
            }
            function makeCb(psrc, pdst2, chunk) {
              return (err4, nb, data) => {
                onread(err4, nb, data, pdst2, psrc, chunk);
              };
            }
            function singleRead(psrc, pdst2, chunk) {
              src.read(srcHandle, readbuf, psrc, chunk, pdst2, makeCb(psrc, pdst2, chunk));
            }
            function startReads() {
              let reads = 0;
              let psrc = 0;
              while (pdst < fsize && reads < concurrency) {
                const chunk = pdst + chunkSize > fsize ? fsize - pdst : chunkSize;
                singleRead(psrc, pdst, chunk);
                psrc += chunk;
                pdst += chunk;
                ++reads;
              }
            }
          });
        }
      });
    }
    function writeAll(sftp, handle, buffer, offset, length, position, callback_) {
      const callback = typeof callback_ === "function" ? callback_ : void 0;
      sftp.write(handle, buffer, offset, length, position, (writeErr, written) => {
        if (writeErr) {
          return sftp.close(handle, () => {
            callback && callback(writeErr);
          });
        }
        if (written === length) {
          sftp.close(handle, callback);
        } else {
          offset += written;
          length -= written;
          position += written;
          writeAll(sftp, handle, buffer, offset, length, position, callback);
        }
      });
    }
    var Stats = class {
      constructor(initial) {
        this.mode = initial && initial.mode;
        this.uid = initial && initial.uid;
        this.gid = initial && initial.gid;
        this.size = initial && initial.size;
        this.atime = initial && initial.atime;
        this.mtime = initial && initial.mtime;
        this.extended = initial && initial.extended;
      }
      isDirectory() {
        return (this.mode & constants.S_IFMT) === constants.S_IFDIR;
      }
      isFile() {
        return (this.mode & constants.S_IFMT) === constants.S_IFREG;
      }
      isBlockDevice() {
        return (this.mode & constants.S_IFMT) === constants.S_IFBLK;
      }
      isCharacterDevice() {
        return (this.mode & constants.S_IFMT) === constants.S_IFCHR;
      }
      isSymbolicLink() {
        return (this.mode & constants.S_IFMT) === constants.S_IFLNK;
      }
      isFIFO() {
        return (this.mode & constants.S_IFMT) === constants.S_IFIFO;
      }
      isSocket() {
        return (this.mode & constants.S_IFMT) === constants.S_IFSOCK;
      }
    };
    function attrsToBytes(attrs) {
      let flags = 0;
      let nb = 0;
      if (typeof attrs === "object" && attrs !== null) {
        if (typeof attrs.size === "number") {
          flags |= ATTR.SIZE;
          const val = attrs.size;
          ATTRS_BUF[nb++] = val / 72057594037927940;
          ATTRS_BUF[nb++] = val / 281474976710656;
          ATTRS_BUF[nb++] = val / 1099511627776;
          ATTRS_BUF[nb++] = val / 4294967296;
          ATTRS_BUF[nb++] = val / 16777216;
          ATTRS_BUF[nb++] = val / 65536;
          ATTRS_BUF[nb++] = val / 256;
          ATTRS_BUF[nb++] = val;
        }
        if (typeof attrs.uid === "number" && typeof attrs.gid === "number") {
          flags |= ATTR.UIDGID;
          const uid = attrs.uid;
          const gid = attrs.gid;
          ATTRS_BUF[nb++] = uid >>> 24;
          ATTRS_BUF[nb++] = uid >>> 16;
          ATTRS_BUF[nb++] = uid >>> 8;
          ATTRS_BUF[nb++] = uid;
          ATTRS_BUF[nb++] = gid >>> 24;
          ATTRS_BUF[nb++] = gid >>> 16;
          ATTRS_BUF[nb++] = gid >>> 8;
          ATTRS_BUF[nb++] = gid;
        }
        if (typeof attrs.mode === "number" || typeof attrs.mode === "string") {
          const mode = modeNum(attrs.mode);
          flags |= ATTR.PERMISSIONS;
          ATTRS_BUF[nb++] = mode >>> 24;
          ATTRS_BUF[nb++] = mode >>> 16;
          ATTRS_BUF[nb++] = mode >>> 8;
          ATTRS_BUF[nb++] = mode;
        }
        if ((typeof attrs.atime === "number" || isDate(attrs.atime)) && (typeof attrs.mtime === "number" || isDate(attrs.mtime))) {
          const atime = toUnixTimestamp(attrs.atime);
          const mtime = toUnixTimestamp(attrs.mtime);
          flags |= ATTR.ACMODTIME;
          ATTRS_BUF[nb++] = atime >>> 24;
          ATTRS_BUF[nb++] = atime >>> 16;
          ATTRS_BUF[nb++] = atime >>> 8;
          ATTRS_BUF[nb++] = atime;
          ATTRS_BUF[nb++] = mtime >>> 24;
          ATTRS_BUF[nb++] = mtime >>> 16;
          ATTRS_BUF[nb++] = mtime >>> 8;
          ATTRS_BUF[nb++] = mtime;
        }
      }
      return { flags, nb };
    }
    function toUnixTimestamp(time) {
      if (typeof time === "number" && time === time)
        return time;
      if (isDate(time))
        return parseInt(time.getTime() / 1e3, 10);
      throw new Error(`Cannot parse time: ${time}`);
    }
    function modeNum(mode) {
      if (typeof mode === "number" && mode === mode)
        return mode;
      if (typeof mode === "string")
        return modeNum(parseInt(mode, 8));
      throw new Error(`Cannot parse mode: ${mode}`);
    }
    var stringFlagMap = {
      "r": OPEN_MODE.READ,
      "r+": OPEN_MODE.READ | OPEN_MODE.WRITE,
      "w": OPEN_MODE.TRUNC | OPEN_MODE.CREAT | OPEN_MODE.WRITE,
      "wx": OPEN_MODE.TRUNC | OPEN_MODE.CREAT | OPEN_MODE.WRITE | OPEN_MODE.EXCL,
      "xw": OPEN_MODE.TRUNC | OPEN_MODE.CREAT | OPEN_MODE.WRITE | OPEN_MODE.EXCL,
      "w+": OPEN_MODE.TRUNC | OPEN_MODE.CREAT | OPEN_MODE.READ | OPEN_MODE.WRITE,
      "wx+": OPEN_MODE.TRUNC | OPEN_MODE.CREAT | OPEN_MODE.READ | OPEN_MODE.WRITE | OPEN_MODE.EXCL,
      "xw+": OPEN_MODE.TRUNC | OPEN_MODE.CREAT | OPEN_MODE.READ | OPEN_MODE.WRITE | OPEN_MODE.EXCL,
      "a": OPEN_MODE.APPEND | OPEN_MODE.CREAT | OPEN_MODE.WRITE,
      "ax": OPEN_MODE.APPEND | OPEN_MODE.CREAT | OPEN_MODE.WRITE | OPEN_MODE.EXCL,
      "xa": OPEN_MODE.APPEND | OPEN_MODE.CREAT | OPEN_MODE.WRITE | OPEN_MODE.EXCL,
      "a+": OPEN_MODE.APPEND | OPEN_MODE.CREAT | OPEN_MODE.READ | OPEN_MODE.WRITE,
      "ax+": OPEN_MODE.APPEND | OPEN_MODE.CREAT | OPEN_MODE.READ | OPEN_MODE.WRITE | OPEN_MODE.EXCL,
      "xa+": OPEN_MODE.APPEND | OPEN_MODE.CREAT | OPEN_MODE.READ | OPEN_MODE.WRITE | OPEN_MODE.EXCL
    };
    function stringToFlags(str) {
      const flags = stringFlagMap[str];
      return flags !== void 0 ? flags : null;
    }
    var flagsToString = (() => {
      const stringFlagMapKeys = Object.keys(stringFlagMap);
      return (flags) => {
        for (let i = 0; i < stringFlagMapKeys.length; ++i) {
          const key = stringFlagMapKeys[i];
          if (stringFlagMap[key] === flags)
            return key;
        }
        return null;
      };
    })();
    function readAttrs(biOpt) {
      const flags = bufferParser.readUInt32BE();
      if (flags === void 0)
        return;
      const attrs = new Stats();
      if (flags & ATTR.SIZE) {
        const size = bufferParser.readUInt64BE(biOpt);
        if (size === void 0)
          return;
        attrs.size = size;
      }
      if (flags & ATTR.UIDGID) {
        const uid = bufferParser.readUInt32BE();
        const gid = bufferParser.readUInt32BE();
        if (gid === void 0)
          return;
        attrs.uid = uid;
        attrs.gid = gid;
      }
      if (flags & ATTR.PERMISSIONS) {
        const mode = bufferParser.readUInt32BE();
        if (mode === void 0)
          return;
        attrs.mode = mode;
      }
      if (flags & ATTR.ACMODTIME) {
        const atime = bufferParser.readUInt32BE();
        const mtime = bufferParser.readUInt32BE();
        if (mtime === void 0)
          return;
        attrs.atime = atime;
        attrs.mtime = mtime;
      }
      if (flags & ATTR.EXTENDED) {
        const count = bufferParser.readUInt32BE();
        if (count === void 0)
          return;
        const extended = {};
        for (let i = 0; i < count; ++i) {
          const type = bufferParser.readString(true);
          const data = bufferParser.readString();
          if (data === void 0)
            return;
          extended[type] = data;
        }
        attrs.extended = extended;
      }
      return attrs;
    }
    function sendOrBuffer(sftp, payload) {
      const ret = tryWritePayload(sftp, payload);
      if (ret !== void 0) {
        sftp._buffer.push(ret);
        return false;
      }
      return true;
    }
    function tryWritePayload(sftp, payload) {
      const outgoing = sftp.outgoing;
      if (outgoing.state !== "open")
        return;
      if (outgoing.window === 0) {
        sftp._waitWindow = true;
        sftp._chunkcb = drainBuffer;
        return payload;
      }
      let ret;
      const len = payload.length;
      let p = 0;
      while (len - p > 0 && outgoing.window > 0) {
        const actualLen = Math.min(len - p, outgoing.window, outgoing.packetSize);
        outgoing.window -= actualLen;
        if (outgoing.window === 0) {
          sftp._waitWindow = true;
          sftp._chunkcb = drainBuffer;
        }
        if (p === 0 && actualLen === len) {
          sftp._protocol.channelData(sftp.outgoing.id, payload);
        } else {
          sftp._protocol.channelData(sftp.outgoing.id, bufferSlice(payload, p, p + actualLen));
        }
        p += actualLen;
      }
      if (len - p > 0) {
        if (p > 0)
          ret = bufferSlice(payload, p, len);
        else
          ret = payload;
      }
      return ret;
    }
    function drainBuffer() {
      this._chunkcb = void 0;
      const buffer = this._buffer;
      let i = 0;
      while (i < buffer.length) {
        const payload = buffer[i];
        const ret = tryWritePayload(this, payload);
        if (ret !== void 0) {
          if (ret !== payload)
            buffer[i] = ret;
          if (i > 0)
            this._buffer = buffer.slice(i);
          return;
        }
        ++i;
      }
      if (i > 0)
        this._buffer = [];
    }
    function doFatalSFTPError(sftp, msg, noDebug) {
      const err = new Error(msg);
      err.level = "sftp-protocol";
      if (!noDebug && sftp._debug)
        sftp._debug(`SFTP: Inbound: ${msg}`);
      sftp.emit("error", err);
      sftp.destroy();
      cleanupRequests(sftp);
      return false;
    }
    function cleanupRequests(sftp) {
      const keys = Object.keys(sftp._requests);
      if (keys.length === 0)
        return;
      const reqs = sftp._requests;
      sftp._requests = {};
      const err = new Error("No response from server");
      for (let i = 0; i < keys.length; ++i) {
        const req = reqs[keys[i]];
        if (typeof req.cb === "function")
          req.cb(err);
      }
    }
    function requestLimits(sftp, cb) {
      let p = 9;
      const buf = Buffer.allocUnsafe(4 + 1 + 4 + 4 + 18);
      writeUInt32BE(buf, buf.length - 4, 0);
      buf[4] = REQUEST.EXTENDED;
      const reqid = sftp._writeReqid = sftp._writeReqid + 1 & MAX_REQID;
      writeUInt32BE(buf, reqid, 5);
      writeUInt32BE(buf, 18, p);
      buf.utf8Write("limits@openssh.com", p += 4, 18);
      sftp._requests[reqid] = { extended: "limits@openssh.com", cb };
      const isBuffered = sendOrBuffer(sftp, buf);
      if (sftp._debug) {
        const which = isBuffered ? "Buffered" : "Sending";
        sftp._debug(`SFTP: Outbound: ${which} limits@openssh.com`);
      }
    }
    var CLIENT_HANDLERS = {
      [RESPONSE.VERSION]: (sftp, payload) => {
        if (sftp._version !== -1)
          return doFatalSFTPError(sftp, "Duplicate VERSION packet");
        const extensions = {};
        bufferParser.init(payload, 1);
        let version = bufferParser.readUInt32BE();
        while (bufferParser.avail()) {
          const extName = bufferParser.readString(true);
          const extData = bufferParser.readString(true);
          if (extData === void 0) {
            version = void 0;
            break;
          }
          extensions[extName] = extData;
        }
        bufferParser.clear();
        if (version === void 0)
          return doFatalSFTPError(sftp, "Malformed VERSION packet");
        if (sftp._debug) {
          const names = Object.keys(extensions);
          if (names.length) {
            sftp._debug(`SFTP: Inbound: Received VERSION (v${version}, exts:${names})`);
          } else {
            sftp._debug(`SFTP: Inbound: Received VERSION (v${version})`);
          }
        }
        sftp._version = version;
        sftp._extensions = extensions;
        if (extensions["limits@openssh.com"] === "1") {
          return requestLimits(sftp, (err, limits) => {
            if (!err) {
              if (limits.maxPktLen > 0)
                sftp._maxOutPktLen = limits.maxPktLen;
              if (limits.maxReadLen > 0)
                sftp._maxReadLen = limits.maxReadLen;
              if (limits.maxWriteLen > 0)
                sftp._maxWriteLen = limits.maxWriteLen;
              sftp.maxOpenHandles = limits.maxOpenHandles > 0 ? limits.maxOpenHandles : Infinity;
            }
            sftp.emit("ready");
          });
        }
        sftp.emit("ready");
      },
      [RESPONSE.STATUS]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const errorCode = bufferParser.readUInt32BE();
        const errorMsg = bufferParser.readString(true);
        bufferParser.clear();
        if (sftp._debug) {
          const jsonMsg = JSON.stringify(errorMsg);
          sftp._debug(`SFTP: Inbound: Received STATUS (id:${reqID}, ${errorCode}, ${jsonMsg})`);
        }
        const req = sftp._requests[reqID];
        delete sftp._requests[reqID];
        if (req && typeof req.cb === "function") {
          if (errorCode === STATUS_CODE.OK) {
            req.cb();
            return;
          }
          const err = new Error(errorMsg || STATUS_CODE_STR[errorCode] || "Unknown status");
          err.code = errorCode;
          req.cb(err);
        }
      },
      [RESPONSE.HANDLE]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const handle = bufferParser.readString();
        bufferParser.clear();
        if (handle === void 0) {
          if (reqID !== void 0)
            delete sftp._requests[reqID];
          return doFatalSFTPError(sftp, "Malformed HANDLE packet");
        }
        sftp._debug && sftp._debug(`SFTP: Inbound: Received HANDLE (id:${reqID})`);
        const req = sftp._requests[reqID];
        delete sftp._requests[reqID];
        if (req && typeof req.cb === "function")
          req.cb(void 0, handle);
      },
      [RESPONSE.DATA]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        let req;
        if (reqID !== void 0) {
          req = sftp._requests[reqID];
          delete sftp._requests[reqID];
        }
        if (req && typeof req.cb === "function") {
          if (req.buffer) {
            const nb = bufferParser.readString(req.buffer);
            bufferParser.clear();
            if (nb !== void 0) {
              sftp._debug && sftp._debug(`SFTP: Inbound: Received DATA (id:${reqID}, ${nb})`);
              req.cb(void 0, req.buffer, nb);
              return;
            }
          } else {
            const data = bufferParser.readString();
            bufferParser.clear();
            if (data !== void 0) {
              sftp._debug && sftp._debug(`SFTP: Inbound: Received DATA (id:${reqID}, ${data.length})`);
              req.cb(void 0, data);
              return;
            }
          }
        } else {
          const nb = bufferParser.skipString();
          bufferParser.clear();
          if (nb !== void 0) {
            sftp._debug && sftp._debug(`SFTP: Inbound: Received DATA (id:${reqID}, ${nb})`);
            return;
          }
        }
        return doFatalSFTPError(sftp, "Malformed DATA packet");
      },
      [RESPONSE.NAME]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        let req;
        if (reqID !== void 0) {
          req = sftp._requests[reqID];
          delete sftp._requests[reqID];
        }
        const count = bufferParser.readUInt32BE();
        if (count !== void 0) {
          let names = [];
          for (let i = 0; i < count; ++i) {
            const filename = bufferParser.readString(true);
            const longname = bufferParser.readString(true);
            const attrs = readAttrs(sftp._biOpt);
            if (attrs === void 0) {
              names = void 0;
              break;
            }
            names.push({ filename, longname, attrs });
          }
          if (names !== void 0) {
            sftp._debug && sftp._debug(`SFTP: Inbound: Received NAME (id:${reqID}, ${names.length})`);
            bufferParser.clear();
            if (req && typeof req.cb === "function")
              req.cb(void 0, names);
            return;
          }
        }
        bufferParser.clear();
        return doFatalSFTPError(sftp, "Malformed NAME packet");
      },
      [RESPONSE.ATTRS]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        let req;
        if (reqID !== void 0) {
          req = sftp._requests[reqID];
          delete sftp._requests[reqID];
        }
        const attrs = readAttrs(sftp._biOpt);
        bufferParser.clear();
        if (attrs !== void 0) {
          sftp._debug && sftp._debug(`SFTP: Inbound: Received ATTRS (id:${reqID})`);
          if (req && typeof req.cb === "function")
            req.cb(void 0, attrs);
          return;
        }
        return doFatalSFTPError(sftp, "Malformed ATTRS packet");
      },
      [RESPONSE.EXTENDED]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        if (reqID !== void 0) {
          const req = sftp._requests[reqID];
          if (req) {
            delete sftp._requests[reqID];
            switch (req.extended) {
              case "statvfs@openssh.com":
              case "fstatvfs@openssh.com": {
                const biOpt = sftp._biOpt;
                const stats = {
                  f_bsize: bufferParser.readUInt64BE(biOpt),
                  f_frsize: bufferParser.readUInt64BE(biOpt),
                  f_blocks: bufferParser.readUInt64BE(biOpt),
                  f_bfree: bufferParser.readUInt64BE(biOpt),
                  f_bavail: bufferParser.readUInt64BE(biOpt),
                  f_files: bufferParser.readUInt64BE(biOpt),
                  f_ffree: bufferParser.readUInt64BE(biOpt),
                  f_favail: bufferParser.readUInt64BE(biOpt),
                  f_sid: bufferParser.readUInt64BE(biOpt),
                  f_flag: bufferParser.readUInt64BE(biOpt),
                  f_namemax: bufferParser.readUInt64BE(biOpt)
                };
                if (stats.f_namemax === void 0)
                  break;
                if (sftp._debug) {
                  sftp._debug(`SFTP: Inbound: Received EXTENDED_REPLY (id:${reqID}, ${req.extended})`);
                }
                bufferParser.clear();
                if (typeof req.cb === "function")
                  req.cb(void 0, stats);
                return;
              }
              case "limits@openssh.com": {
                const limits = {
                  maxPktLen: bufferParser.readUInt64BE(),
                  maxReadLen: bufferParser.readUInt64BE(),
                  maxWriteLen: bufferParser.readUInt64BE(),
                  maxOpenHandles: bufferParser.readUInt64BE()
                };
                if (limits.maxOpenHandles === void 0)
                  break;
                if (sftp._debug) {
                  sftp._debug(`SFTP: Inbound: Received EXTENDED_REPLY (id:${reqID}, ${req.extended})`);
                }
                bufferParser.clear();
                if (typeof req.cb === "function")
                  req.cb(void 0, limits);
                return;
              }
              default:
                sftp._debug && sftp._debug(`SFTP: Inbound: Received EXTENDED_REPLY (id:${reqID}, ???)`);
                bufferParser.clear();
                if (typeof req.cb === "function")
                  req.cb();
                return;
            }
          } else {
            sftp._debug && sftp._debug(`SFTP: Inbound: Received EXTENDED_REPLY (id:${reqID}, ???)`);
            bufferParser.clear();
            return;
          }
        }
        bufferParser.clear();
        return doFatalSFTPError(sftp, "Malformed EXTENDED_REPLY packet");
      }
    };
    var SERVER_HANDLERS = {
      [REQUEST.INIT]: (sftp, payload) => {
        if (sftp._version !== -1)
          return doFatalSFTPError(sftp, "Duplicate INIT packet");
        const extensions = {};
        bufferParser.init(payload, 1);
        let version = bufferParser.readUInt32BE();
        while (bufferParser.avail()) {
          const extName = bufferParser.readString(true);
          const extData = bufferParser.readString(true);
          if (extData === void 0) {
            version = void 0;
            break;
          }
          extensions[extName] = extData;
        }
        bufferParser.clear();
        if (version === void 0)
          return doFatalSFTPError(sftp, "Malformed INIT packet");
        if (sftp._debug) {
          const names = Object.keys(extensions);
          if (names.length) {
            sftp._debug(`SFTP: Inbound: Received INIT (v${version}, exts:${names})`);
          } else {
            sftp._debug(`SFTP: Inbound: Received INIT (v${version})`);
          }
        }
        sendOrBuffer(sftp, SERVER_VERSION_BUFFER);
        sftp._version = version;
        sftp._extensions = extensions;
        sftp.emit("ready");
      },
      [REQUEST.OPEN]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const filename = bufferParser.readString(true);
        const pflags = bufferParser.readUInt32BE();
        const attrs = readAttrs(sftp._biOpt);
        bufferParser.clear();
        if (attrs === void 0)
          return doFatalSFTPError(sftp, "Malformed OPEN packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received OPEN (id:${reqID})`);
        if (!sftp.emit("OPEN", reqID, filename, pflags, attrs)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.CLOSE]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const handle = bufferParser.readString();
        bufferParser.clear();
        if (handle === void 0 || handle.length > 256)
          return doFatalSFTPError(sftp, "Malformed CLOSE packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received CLOSE (id:${reqID})`);
        if (!sftp.emit("CLOSE", reqID, handle)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.READ]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const handle = bufferParser.readString();
        const offset = bufferParser.readUInt64BE(sftp._biOpt);
        const len = bufferParser.readUInt32BE();
        bufferParser.clear();
        if (len === void 0 || handle.length > 256)
          return doFatalSFTPError(sftp, "Malformed READ packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received READ (id:${reqID})`);
        if (!sftp.emit("READ", reqID, handle, offset, len)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.WRITE]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const handle = bufferParser.readString();
        const offset = bufferParser.readUInt64BE(sftp._biOpt);
        const data = bufferParser.readString();
        bufferParser.clear();
        if (data === void 0 || handle.length > 256)
          return doFatalSFTPError(sftp, "Malformed WRITE packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received WRITE (id:${reqID})`);
        if (!sftp.emit("WRITE", reqID, handle, offset, data)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.LSTAT]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        bufferParser.clear();
        if (path2 === void 0)
          return doFatalSFTPError(sftp, "Malformed LSTAT packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received LSTAT (id:${reqID})`);
        if (!sftp.emit("LSTAT", reqID, path2)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.FSTAT]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const handle = bufferParser.readString();
        bufferParser.clear();
        if (handle === void 0 || handle.length > 256)
          return doFatalSFTPError(sftp, "Malformed FSTAT packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received FSTAT (id:${reqID})`);
        if (!sftp.emit("FSTAT", reqID, handle)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.SETSTAT]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        const attrs = readAttrs(sftp._biOpt);
        bufferParser.clear();
        if (attrs === void 0)
          return doFatalSFTPError(sftp, "Malformed SETSTAT packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received SETSTAT (id:${reqID})`);
        if (!sftp.emit("SETSTAT", reqID, path2, attrs)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.FSETSTAT]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const handle = bufferParser.readString();
        const attrs = readAttrs(sftp._biOpt);
        bufferParser.clear();
        if (attrs === void 0 || handle.length > 256)
          return doFatalSFTPError(sftp, "Malformed FSETSTAT packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received FSETSTAT (id:${reqID})`);
        if (!sftp.emit("FSETSTAT", reqID, handle, attrs)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.OPENDIR]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        bufferParser.clear();
        if (path2 === void 0)
          return doFatalSFTPError(sftp, "Malformed OPENDIR packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received OPENDIR (id:${reqID})`);
        if (!sftp.emit("OPENDIR", reqID, path2)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.READDIR]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const handle = bufferParser.readString();
        bufferParser.clear();
        if (handle === void 0 || handle.length > 256)
          return doFatalSFTPError(sftp, "Malformed READDIR packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received READDIR (id:${reqID})`);
        if (!sftp.emit("READDIR", reqID, handle)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.REMOVE]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        bufferParser.clear();
        if (path2 === void 0)
          return doFatalSFTPError(sftp, "Malformed REMOVE packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received REMOVE (id:${reqID})`);
        if (!sftp.emit("REMOVE", reqID, path2)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.MKDIR]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        const attrs = readAttrs(sftp._biOpt);
        bufferParser.clear();
        if (attrs === void 0)
          return doFatalSFTPError(sftp, "Malformed MKDIR packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received MKDIR (id:${reqID})`);
        if (!sftp.emit("MKDIR", reqID, path2, attrs)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.RMDIR]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        bufferParser.clear();
        if (path2 === void 0)
          return doFatalSFTPError(sftp, "Malformed RMDIR packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received RMDIR (id:${reqID})`);
        if (!sftp.emit("RMDIR", reqID, path2)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.REALPATH]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        bufferParser.clear();
        if (path2 === void 0)
          return doFatalSFTPError(sftp, "Malformed REALPATH packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received REALPATH (id:${reqID})`);
        if (!sftp.emit("REALPATH", reqID, path2)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.STAT]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        bufferParser.clear();
        if (path2 === void 0)
          return doFatalSFTPError(sftp, "Malformed STAT packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received STAT (id:${reqID})`);
        if (!sftp.emit("STAT", reqID, path2)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.RENAME]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const oldPath = bufferParser.readString(true);
        const newPath = bufferParser.readString(true);
        bufferParser.clear();
        if (newPath === void 0)
          return doFatalSFTPError(sftp, "Malformed RENAME packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received RENAME (id:${reqID})`);
        if (!sftp.emit("RENAME", reqID, oldPath, newPath)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.READLINK]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const path2 = bufferParser.readString(true);
        bufferParser.clear();
        if (path2 === void 0)
          return doFatalSFTPError(sftp, "Malformed READLINK packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received READLINK (id:${reqID})`);
        if (!sftp.emit("READLINK", reqID, path2)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.SYMLINK]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const linkPath = bufferParser.readString(true);
        const targetPath = bufferParser.readString(true);
        bufferParser.clear();
        if (targetPath === void 0)
          return doFatalSFTPError(sftp, "Malformed SYMLINK packet");
        sftp._debug && sftp._debug(`SFTP: Inbound: Received SYMLINK (id:${reqID})`);
        let handled;
        if (sftp._isOpenSSH) {
          handled = sftp.emit("SYMLINK", reqID, targetPath, linkPath);
        } else {
          handled = sftp.emit("SYMLINK", reqID, linkPath, targetPath);
        }
        if (!handled) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      },
      [REQUEST.EXTENDED]: (sftp, payload) => {
        bufferParser.init(payload, 1);
        const reqID = bufferParser.readUInt32BE();
        const extName = bufferParser.readString(true);
        if (extName === void 0) {
          bufferParser.clear();
          return doFatalSFTPError(sftp, "Malformed EXTENDED packet");
        }
        let extData;
        if (bufferParser.avail())
          extData = bufferParser.readRaw();
        bufferParser.clear();
        sftp._debug && sftp._debug(`SFTP: Inbound: Received EXTENDED (id:${reqID})`);
        if (!sftp.emit("EXTENDED", reqID, extName, extData)) {
          sftp.status(reqID, STATUS_CODE.OP_UNSUPPORTED);
        }
      }
    };
    var {
      ERR_INVALID_ARG_TYPE,
      ERR_OUT_OF_RANGE,
      validateNumber
    } = require_node_fs_compat();
    var kMinPoolSpace = 128;
    var pool;
    var poolFragments = [];
    function allocNewPool(poolSize) {
      if (poolFragments.length > 0)
        pool = poolFragments.pop();
      else
        pool = Buffer.allocUnsafe(poolSize);
      pool.used = 0;
    }
    function checkPosition(pos, name) {
      if (!Number.isSafeInteger(pos)) {
        validateNumber(pos, name);
        if (!Number.isInteger(pos))
          throw new ERR_OUT_OF_RANGE(name, "an integer", pos);
        throw new ERR_OUT_OF_RANGE(name, ">= 0 and <= 2 ** 53 - 1", pos);
      }
      if (pos < 0)
        throw new ERR_OUT_OF_RANGE(name, ">= 0 and <= 2 ** 53 - 1", pos);
    }
    function roundUpToMultipleOf8(n) {
      return n + 7 & ~7;
    }
    function ReadStream(sftp, path2, options) {
      if (options === void 0)
        options = {};
      else if (typeof options === "string")
        options = { encoding: options };
      else if (options === null || typeof options !== "object")
        throw new TypeError('"options" argument must be a string or an object');
      else
        options = Object.create(options);
      if (options.highWaterMark === void 0)
        options.highWaterMark = 64 * 1024;
      options.emitClose = false;
      options.autoDestroy = false;
      ReadableStream.call(this, options);
      this.path = path2;
      this.flags = options.flags === void 0 ? "r" : options.flags;
      this.mode = options.mode === void 0 ? 438 : options.mode;
      this.start = options.start;
      this.end = options.end;
      this.autoClose = options.autoClose === void 0 ? true : options.autoClose;
      this.pos = 0;
      this.bytesRead = 0;
      this.isClosed = false;
      this.handle = options.handle === void 0 ? null : options.handle;
      this.sftp = sftp;
      this._opening = false;
      if (this.start !== void 0) {
        checkPosition(this.start, "start");
        this.pos = this.start;
      }
      if (this.end === void 0) {
        this.end = Infinity;
      } else if (this.end !== Infinity) {
        checkPosition(this.end, "end");
        if (this.start !== void 0 && this.start > this.end) {
          throw new ERR_OUT_OF_RANGE("start", `<= "end" (here: ${this.end})`, this.start);
        }
      }
      this.on("end", function() {
        if (this.autoClose)
          this.destroy();
      });
      if (!Buffer.isBuffer(this.handle))
        this.open();
    }
    inherits(ReadStream, ReadableStream);
    ReadStream.prototype.open = function() {
      if (this._opening)
        return;
      this._opening = true;
      this.sftp.open(this.path, this.flags, this.mode, (er, handle) => {
        this._opening = false;
        if (er) {
          this.emit("error", er);
          if (this.autoClose)
            this.destroy();
          return;
        }
        this.handle = handle;
        this.emit("open", handle);
        this.emit("ready");
        this.read();
      });
    };
    ReadStream.prototype._read = function(n) {
      if (!Buffer.isBuffer(this.handle))
        return this.once("open", () => this._read(n));
      if (this.destroyed)
        return;
      if (!pool || pool.length - pool.used < kMinPoolSpace) {
        allocNewPool(this.readableHighWaterMark || this._readableState.highWaterMark);
      }
      const thisPool = pool;
      let toRead = Math.min(pool.length - pool.used, n);
      const start = pool.used;
      if (this.end !== void 0)
        toRead = Math.min(this.end - this.pos + 1, toRead);
      if (toRead <= 0)
        return this.push(null);
      this.sftp.read(this.handle, pool, pool.used, toRead, this.pos, (er, bytesRead) => {
        if (er) {
          this.emit("error", er);
          if (this.autoClose)
            this.destroy();
          return;
        }
        let b = null;
        if (start + toRead === thisPool.used && thisPool === pool) {
          thisPool.used = roundUpToMultipleOf8(thisPool.used + bytesRead - toRead);
        } else {
          const alignedEnd = start + toRead & ~7;
          const alignedStart = roundUpToMultipleOf8(start + bytesRead);
          if (alignedEnd - alignedStart >= kMinPoolSpace)
            poolFragments.push(thisPool.slice(alignedStart, alignedEnd));
        }
        if (bytesRead > 0) {
          this.bytesRead += bytesRead;
          b = thisPool.slice(start, start + bytesRead);
        }
        this.pos += bytesRead;
        this.push(b);
      });
      pool.used = roundUpToMultipleOf8(pool.used + toRead);
    };
    ReadStream.prototype._destroy = function(err, cb) {
      if (this._opening && !Buffer.isBuffer(this.handle)) {
        this.once("open", closeStream.bind(null, this, cb, err));
        return;
      }
      closeStream(this, cb, err);
      this.handle = null;
      this._opening = false;
    };
    function closeStream(stream, cb, err) {
      if (!stream.handle)
        return onclose();
      stream.sftp.close(stream.handle, onclose);
      function onclose(er) {
        er = er || err;
        cb(er);
        stream.isClosed = true;
        if (!er)
          stream.emit("close");
      }
    }
    ReadStream.prototype.close = function(cb) {
      this.destroy(null, cb);
    };
    Object.defineProperty(ReadStream.prototype, "pending", {
      get() {
        return this.handle === null;
      },
      configurable: true
    });
    function WriteStream(sftp, path2, options) {
      if (options === void 0)
        options = {};
      else if (typeof options === "string")
        options = { encoding: options };
      else if (options === null || typeof options !== "object")
        throw new TypeError('"options" argument must be a string or an object');
      else
        options = Object.create(options);
      options.emitClose = false;
      options.autoDestroy = false;
      WritableStream.call(this, options);
      this.path = path2;
      this.flags = options.flags === void 0 ? "w" : options.flags;
      this.mode = options.mode === void 0 ? 438 : options.mode;
      this.start = options.start;
      this.autoClose = options.autoClose === void 0 ? true : options.autoClose;
      this.pos = 0;
      this.bytesWritten = 0;
      this.isClosed = false;
      this.handle = options.handle === void 0 ? null : options.handle;
      this.sftp = sftp;
      this._opening = false;
      if (this.start !== void 0) {
        checkPosition(this.start, "start");
        this.pos = this.start;
      }
      if (options.encoding)
        this.setDefaultEncoding(options.encoding);
      this.on("finish", function() {
        if (this._writableState.finalCalled)
          return;
        if (this.autoClose)
          this.destroy();
      });
      if (!Buffer.isBuffer(this.handle))
        this.open();
    }
    inherits(WriteStream, WritableStream);
    WriteStream.prototype._final = function(cb) {
      if (this.autoClose)
        this.destroy();
      cb();
    };
    WriteStream.prototype.open = function() {
      if (this._opening)
        return;
      this._opening = true;
      this.sftp.open(this.path, this.flags, this.mode, (er, handle) => {
        this._opening = false;
        if (er) {
          this.emit("error", er);
          if (this.autoClose)
            this.destroy();
          return;
        }
        this.handle = handle;
        const tryAgain = (err) => {
          if (err) {
            this.sftp.chmod(this.path, this.mode, (err_) => tryAgain());
            return;
          }
          if (this.flags[0] === "a") {
            const tryStat = (err2, st) => {
              if (err2) {
                this.sftp.stat(this.path, (err_, st_) => {
                  if (err_) {
                    this.destroy();
                    this.emit("error", err2);
                    return;
                  }
                  tryStat(null, st_);
                });
                return;
              }
              this.pos = st.size;
              this.emit("open", handle);
              this.emit("ready");
            };
            this.sftp.fstat(handle, tryStat);
            return;
          }
          this.emit("open", handle);
          this.emit("ready");
        };
        this.sftp.fchmod(handle, this.mode, tryAgain);
      });
    };
    WriteStream.prototype._write = function(data, encoding, cb) {
      if (!Buffer.isBuffer(data)) {
        const err = new ERR_INVALID_ARG_TYPE("data", "Buffer", data);
        return this.emit("error", err);
      }
      if (!Buffer.isBuffer(this.handle)) {
        return this.once("open", function() {
          this._write(data, encoding, cb);
        });
      }
      this.sftp.write(this.handle, data, 0, data.length, this.pos, (er, bytes) => {
        if (er) {
          if (this.autoClose)
            this.destroy();
          return cb(er);
        }
        this.bytesWritten += bytes;
        cb();
      });
      this.pos += data.length;
    };
    WriteStream.prototype._writev = function(data, cb) {
      if (!Buffer.isBuffer(this.handle)) {
        return this.once("open", function() {
          this._writev(data, cb);
        });
      }
      const sftp = this.sftp;
      const handle = this.handle;
      let writesLeft = data.length;
      const onwrite = (er, bytes) => {
        if (er) {
          this.destroy();
          return cb(er);
        }
        this.bytesWritten += bytes;
        if (--writesLeft === 0)
          cb();
      };
      for (let i = 0; i < data.length; ++i) {
        const chunk = data[i].chunk;
        sftp.write(handle, chunk, 0, chunk.length, this.pos, onwrite);
        this.pos += chunk.length;
      }
    };
    if (typeof WritableStream.prototype.destroy !== "function")
      WriteStream.prototype.destroy = ReadStream.prototype.destroy;
    WriteStream.prototype._destroy = ReadStream.prototype._destroy;
    WriteStream.prototype.close = function(cb) {
      if (cb) {
        if (this.isClosed) {
          process.nextTick(cb);
          return;
        }
        this.on("close", cb);
      }
      if (!this.autoClose)
        this.on("finish", this.destroy.bind(this));
      this.end();
    };
    WriteStream.prototype.destroySoon = WriteStream.prototype.end;
    Object.defineProperty(WriteStream.prototype, "pending", {
      get() {
        return this.handle === null;
      },
      configurable: true
    });
    module2.exports = {
      flagsToString,
      OPEN_MODE,
      SFTP,
      Stats,
      STATUS_CODE,
      stringToFlags
    };
  }
});

// node_modules/ssh2/lib/Channel.js
var require_Channel = __commonJS({
  "node_modules/ssh2/lib/Channel.js"(exports, module2) {
    "use strict";
    var {
      Duplex: DuplexStream,
      Readable: ReadableStream,
      Writable: WritableStream
    } = require("stream");
    var {
      CHANNEL_EXTENDED_DATATYPE: { STDERR }
    } = require_constants();
    var { bufferSlice } = require_utils2();
    var PACKET_SIZE = 32 * 1024;
    var MAX_WINDOW = 2 * 1024 * 1024;
    var WINDOW_THRESHOLD = MAX_WINDOW / 2;
    var ClientStderr = class extends ReadableStream {
      constructor(channel, streamOpts) {
        super(streamOpts);
        this._channel = channel;
      }
      _read(n) {
        if (this._channel._waitChanDrain) {
          this._channel._waitChanDrain = false;
          if (this._channel.incoming.window <= WINDOW_THRESHOLD)
            windowAdjust(this._channel);
        }
      }
    };
    var ServerStderr = class extends WritableStream {
      constructor(channel) {
        super({ highWaterMark: MAX_WINDOW });
        this._channel = channel;
      }
      _write(data, encoding, cb) {
        const channel = this._channel;
        const protocol = channel._client._protocol;
        const outgoing = channel.outgoing;
        const packetSize = outgoing.packetSize;
        const id = outgoing.id;
        let window2 = outgoing.window;
        const len = data.length;
        let p = 0;
        if (outgoing.state !== "open")
          return;
        while (len - p > 0 && window2 > 0) {
          let sliceLen = len - p;
          if (sliceLen > window2)
            sliceLen = window2;
          if (sliceLen > packetSize)
            sliceLen = packetSize;
          if (p === 0 && sliceLen === len)
            protocol.channelExtData(id, data, STDERR);
          else
            protocol.channelExtData(id, bufferSlice(data, p, p + sliceLen), STDERR);
          p += sliceLen;
          window2 -= sliceLen;
        }
        outgoing.window = window2;
        if (len - p > 0) {
          if (window2 === 0)
            channel._waitWindow = true;
          if (p > 0)
            channel._chunkErr = bufferSlice(data, p, len);
          else
            channel._chunkErr = data;
          channel._chunkcbErr = cb;
          return;
        }
        cb();
      }
    };
    var Channel = class extends DuplexStream {
      constructor(client, info, opts) {
        const streamOpts = {
          highWaterMark: MAX_WINDOW,
          allowHalfOpen: !opts || opts && opts.allowHalfOpen !== false,
          emitClose: false
        };
        super(streamOpts);
        this.allowHalfOpen = streamOpts.allowHalfOpen;
        const server = !!(opts && opts.server);
        this.server = server;
        this.type = info.type;
        this.subtype = void 0;
        this.incoming = info.incoming;
        this.outgoing = info.outgoing;
        this._callbacks = [];
        this._client = client;
        this._hasX11 = false;
        this._exit = {
          code: void 0,
          signal: void 0,
          dump: void 0,
          desc: void 0
        };
        this.stdin = this.stdout = this;
        if (server)
          this.stderr = new ServerStderr(this);
        else
          this.stderr = new ClientStderr(this, streamOpts);
        this._waitWindow = false;
        this._waitChanDrain = false;
        this._chunk = void 0;
        this._chunkcb = void 0;
        this._chunkErr = void 0;
        this._chunkcbErr = void 0;
        this.on("finish", onFinish).on("prefinish", onFinish);
        this.on("end", onEnd).on("close", onEnd);
      }
      _read(n) {
        if (this._waitChanDrain) {
          this._waitChanDrain = false;
          if (this.incoming.window <= WINDOW_THRESHOLD)
            windowAdjust(this);
        }
      }
      _write(data, encoding, cb) {
        const protocol = this._client._protocol;
        const outgoing = this.outgoing;
        const packetSize = outgoing.packetSize;
        const id = outgoing.id;
        let window2 = outgoing.window;
        const len = data.length;
        let p = 0;
        if (outgoing.state !== "open")
          return;
        while (len - p > 0 && window2 > 0) {
          let sliceLen = len - p;
          if (sliceLen > window2)
            sliceLen = window2;
          if (sliceLen > packetSize)
            sliceLen = packetSize;
          if (p === 0 && sliceLen === len)
            protocol.channelData(id, data);
          else
            protocol.channelData(id, bufferSlice(data, p, p + sliceLen));
          p += sliceLen;
          window2 -= sliceLen;
        }
        outgoing.window = window2;
        if (len - p > 0) {
          if (window2 === 0)
            this._waitWindow = true;
          if (p > 0)
            this._chunk = bufferSlice(data, p, len);
          else
            this._chunk = data;
          this._chunkcb = cb;
          return;
        }
        cb();
      }
      eof() {
        if (this.outgoing.state === "open") {
          this.outgoing.state = "eof";
          this._client._protocol.channelEOF(this.outgoing.id);
        }
      }
      close() {
        if (this.outgoing.state === "open" || this.outgoing.state === "eof") {
          this.outgoing.state = "closing";
          this._client._protocol.channelClose(this.outgoing.id);
        }
      }
      destroy() {
        this.end();
        this.close();
        return this;
      }
      setWindow(rows, cols, height, width) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (this.type === "session" && (this.subtype === "shell" || this.subtype === "exec") && this.writable && this.outgoing.state === "open") {
          this._client._protocol.windowChange(this.outgoing.id, rows, cols, height, width);
        }
      }
      signal(signalName) {
        if (this.server)
          throw new Error("Client-only method called in server mode");
        if (this.type === "session" && this.writable && this.outgoing.state === "open") {
          this._client._protocol.signal(this.outgoing.id, signalName);
        }
      }
      exit(statusOrSignal, coreDumped, msg) {
        if (!this.server)
          throw new Error("Server-only method called in client mode");
        if (this.type === "session" && this.writable && this.outgoing.state === "open") {
          if (typeof statusOrSignal === "number") {
            this._client._protocol.exitStatus(this.outgoing.id, statusOrSignal);
          } else {
            this._client._protocol.exitSignal(this.outgoing.id, statusOrSignal, coreDumped, msg);
          }
        }
      }
    };
    function onFinish() {
      this.eof();
      if (this.server || !this.allowHalfOpen)
        this.close();
      this.writable = false;
    }
    function onEnd() {
      this.readable = false;
    }
    function windowAdjust(self2) {
      if (self2.outgoing.state === "closed")
        return;
      const amt = MAX_WINDOW - self2.incoming.window;
      if (amt <= 0)
        return;
      self2.incoming.window += amt;
      self2._client._protocol.channelWindowAdjust(self2.outgoing.id, amt);
    }
    module2.exports = {
      Channel,
      MAX_WINDOW,
      PACKET_SIZE,
      windowAdjust,
      WINDOW_THRESHOLD
    };
  }
});

// node_modules/ssh2/lib/utils.js
var require_utils3 = __commonJS({
  "node_modules/ssh2/lib/utils.js"(exports, module2) {
    "use strict";
    var { SFTP } = require_SFTP();
    var MAX_CHANNEL = 2 ** 32 - 1;
    function onChannelOpenFailure(self2, recipient, info, cb) {
      self2._chanMgr.remove(recipient);
      if (typeof cb !== "function")
        return;
      let err;
      if (info instanceof Error) {
        err = info;
      } else if (typeof info === "object" && info !== null) {
        err = new Error(`(SSH) Channel open failure: ${info.description}`);
        err.reason = info.reason;
      } else {
        err = new Error("(SSH) Channel open failure: server closed channel unexpectedly");
        err.reason = "";
      }
      cb(err);
    }
    function onCHANNEL_CLOSE(self2, recipient, channel, err, dead) {
      if (typeof channel === "function") {
        onChannelOpenFailure(self2, recipient, err, channel);
        return;
      }
      if (typeof channel !== "object" || channel === null)
        return;
      if (channel.incoming && channel.incoming.state === "closed")
        return;
      self2._chanMgr.remove(recipient);
      if (channel.server && channel.constructor.name === "Session")
        return;
      channel.incoming.state = "closed";
      if (channel.readable)
        channel.push(null);
      if (channel.server) {
        if (channel.stderr.writable)
          channel.stderr.end();
      } else if (channel.stderr.readable) {
        channel.stderr.push(null);
      }
      if (channel.constructor !== SFTP && (channel.outgoing.state === "open" || channel.outgoing.state === "eof") && !dead) {
        channel.close();
      }
      if (channel.outgoing.state === "closing")
        channel.outgoing.state = "closed";
      const readState = channel._readableState;
      const writeState = channel._writableState;
      if (writeState && !writeState.ending && !writeState.finished && !dead)
        channel.end();
      const chanCallbacks = channel._callbacks;
      channel._callbacks = [];
      for (let i = 0; i < chanCallbacks.length; ++i)
        chanCallbacks[i](true);
      if (channel.server) {
        if (!channel.readable || channel.destroyed || readState && readState.endEmitted) {
          channel.emit("close");
        } else {
          channel.once("end", () => channel.emit("close"));
        }
      } else {
        let doClose;
        switch (channel.type) {
          case "direct-streamlocal@openssh.com":
          case "direct-tcpip":
            doClose = () => channel.emit("close");
            break;
          default: {
            const exit = channel._exit;
            doClose = () => {
              if (exit.code === null)
                channel.emit("close", exit.code, exit.signal, exit.dump, exit.desc);
              else
                channel.emit("close", exit.code);
            };
          }
        }
        if (!channel.readable || channel.destroyed || readState && readState.endEmitted) {
          doClose();
        } else {
          channel.once("end", doClose);
        }
        const errReadState = channel.stderr._readableState;
        if (!channel.stderr.readable || channel.stderr.destroyed || errReadState && errReadState.endEmitted) {
          channel.stderr.emit("close");
        } else {
          channel.stderr.once("end", () => channel.stderr.emit("close"));
        }
      }
    }
    var ChannelManager = class {
      constructor(client) {
        this._client = client;
        this._channels = {};
        this._cur = -1;
        this._count = 0;
      }
      add(val) {
        let id;
        if (this._cur < MAX_CHANNEL) {
          id = ++this._cur;
        } else if (this._count === 0) {
          this._cur = 0;
          id = 0;
        } else {
          const channels = this._channels;
          for (let i = 0; i < MAX_CHANNEL; ++i) {
            if (channels[i] === void 0) {
              id = i;
              break;
            }
          }
        }
        if (id === void 0)
          return -1;
        this._channels[id] = val || true;
        ++this._count;
        return id;
      }
      update(id, val) {
        if (typeof id !== "number" || id < 0 || id >= MAX_CHANNEL || !isFinite(id))
          throw new Error(`Invalid channel id: ${id}`);
        if (val && this._channels[id])
          this._channels[id] = val;
      }
      get(id) {
        if (typeof id !== "number" || id < 0 || id >= MAX_CHANNEL || !isFinite(id))
          throw new Error(`Invalid channel id: ${id}`);
        return this._channels[id];
      }
      remove(id) {
        if (typeof id !== "number" || id < 0 || id >= MAX_CHANNEL || !isFinite(id))
          throw new Error(`Invalid channel id: ${id}`);
        if (this._channels[id]) {
          delete this._channels[id];
          if (this._count)
            --this._count;
        }
      }
      cleanup(err) {
        const channels = this._channels;
        this._channels = {};
        this._cur = -1;
        this._count = 0;
        const chanIDs = Object.keys(channels);
        const client = this._client;
        for (let i = 0; i < chanIDs.length; ++i) {
          const id = +chanIDs[i];
          const channel = channels[id];
          onCHANNEL_CLOSE(client, id, channel._channel || channel, err, true);
        }
      }
    };
    var isRegExp = (() => {
      const toString = Object.prototype.toString;
      return (val) => toString.call(val) === "[object RegExp]";
    })();
    function generateAlgorithmList(algoList, defaultList, supportedList) {
      if (Array.isArray(algoList) && algoList.length > 0) {
        for (let i = 0; i < algoList.length; ++i) {
          if (supportedList.indexOf(algoList[i]) === -1)
            throw new Error(`Unsupported algorithm: ${algoList[i]}`);
        }
        return algoList;
      }
      if (typeof algoList === "object" && algoList !== null) {
        const keys = Object.keys(algoList);
        let list = defaultList;
        for (let i = 0; i < keys.length; ++i) {
          const key = keys[i];
          let val = algoList[key];
          switch (key) {
            case "append":
              if (!Array.isArray(val))
                val = [val];
              if (Array.isArray(val)) {
                for (let j = 0; j < val.length; ++j) {
                  const append = val[j];
                  if (typeof append === "string") {
                    if (!append || list.indexOf(append) !== -1)
                      continue;
                    if (supportedList.indexOf(append) === -1)
                      throw new Error(`Unsupported algorithm: ${append}`);
                    if (list === defaultList)
                      list = list.slice();
                    list.push(append);
                  } else if (isRegExp(append)) {
                    for (let k = 0; k < supportedList.length; ++k) {
                      const algo = supportedList[k];
                      if (append.test(algo)) {
                        if (list.indexOf(algo) !== -1)
                          continue;
                        if (list === defaultList)
                          list = list.slice();
                        list.push(algo);
                      }
                    }
                  }
                }
              }
              break;
            case "prepend":
              if (!Array.isArray(val))
                val = [val];
              if (Array.isArray(val)) {
                for (let j = val.length; j >= 0; --j) {
                  const prepend = val[j];
                  if (typeof prepend === "string") {
                    if (!prepend || list.indexOf(prepend) !== -1)
                      continue;
                    if (supportedList.indexOf(prepend) === -1)
                      throw new Error(`Unsupported algorithm: ${prepend}`);
                    if (list === defaultList)
                      list = list.slice();
                    list.unshift(prepend);
                  } else if (isRegExp(prepend)) {
                    for (let k = supportedList.length; k >= 0; --k) {
                      const algo = supportedList[k];
                      if (prepend.test(algo)) {
                        if (list.indexOf(algo) !== -1)
                          continue;
                        if (list === defaultList)
                          list = list.slice();
                        list.unshift(algo);
                      }
                    }
                  }
                }
              }
              break;
            case "remove":
              if (!Array.isArray(val))
                val = [val];
              if (Array.isArray(val)) {
                for (let j = 0; j < val.length; ++j) {
                  const search = val[j];
                  if (typeof search === "string") {
                    if (!search)
                      continue;
                    const idx = list.indexOf(search);
                    if (idx === -1)
                      continue;
                    if (list === defaultList)
                      list = list.slice();
                    list.splice(idx, 1);
                  } else if (isRegExp(search)) {
                    for (let k = 0; k < list.length; ++k) {
                      if (search.test(list[k])) {
                        if (list === defaultList)
                          list = list.slice();
                        list.splice(k, 1);
                        --k;
                      }
                    }
                  }
                }
              }
              break;
          }
        }
        return list;
      }
      return defaultList;
    }
    module2.exports = {
      ChannelManager,
      generateAlgorithmList,
      onChannelOpenFailure,
      onCHANNEL_CLOSE,
      isWritable: (stream) => {
        return stream && stream.writable && stream._readableState && stream._readableState.ended === false;
      }
    };
  }
});

// node_modules/ssh2/lib/client.js
var require_client = __commonJS({
  "node_modules/ssh2/lib/client.js"(exports, module2) {
    "use strict";
    var {
      createHash,
      getHashes,
      randomFillSync
    } = require("crypto");
    var { Socket } = require("net");
    var { lookup: dnsLookup } = require("dns");
    var EventEmitter = require("events");
    var HASHES = getHashes();
    var {
      COMPAT,
      CHANNEL_EXTENDED_DATATYPE: { STDERR },
      CHANNEL_OPEN_FAILURE,
      DEFAULT_CIPHER,
      DEFAULT_COMPRESSION,
      DEFAULT_KEX,
      DEFAULT_MAC,
      DEFAULT_SERVER_HOST_KEY,
      DISCONNECT_REASON,
      DISCONNECT_REASON_BY_VALUE,
      SUPPORTED_CIPHER,
      SUPPORTED_COMPRESSION,
      SUPPORTED_KEX,
      SUPPORTED_MAC,
      SUPPORTED_SERVER_HOST_KEY
    } = require_constants();
    var { init: cryptoInit } = require_crypto();
    var Protocol = require_Protocol();
    var { parseKey } = require_keyParser();
    var { SFTP } = require_SFTP();
    var {
      bufferCopy,
      makeBufferParser,
      makeError,
      readUInt32BE,
      sigSSHToASN1,
      writeUInt32BE
    } = require_utils2();
    var { AgentContext, createAgent, isAgent } = require_agent();
    var {
      Channel,
      MAX_WINDOW,
      PACKET_SIZE,
      windowAdjust,
      WINDOW_THRESHOLD
    } = require_Channel();
    var {
      ChannelManager,
      generateAlgorithmList,
      isWritable,
      onChannelOpenFailure,
      onCHANNEL_CLOSE
    } = require_utils3();
    var bufferParser = makeBufferParser();
    var sigParser = makeBufferParser();
    var RE_OPENSSH = /^OpenSSH_(?:(?![0-4])\d)|(?:\d{2,})/;
    var noop = (err) => {
    };
    var Client = class extends EventEmitter {
      constructor() {
        super();
        this.config = {
          host: void 0,
          port: void 0,
          localAddress: void 0,
          localPort: void 0,
          forceIPv4: void 0,
          forceIPv6: void 0,
          keepaliveCountMax: void 0,
          keepaliveInterval: void 0,
          readyTimeout: void 0,
          ident: void 0,
          username: void 0,
          password: void 0,
          privateKey: void 0,
          tryKeyboard: void 0,
          agent: void 0,
          allowAgentFwd: void 0,
          authHandler: void 0,
          hostHashAlgo: void 0,
          hostHashCb: void 0,
          strictVendor: void 0,
          debug: void 0
        };
        this._agent = void 0;
        this._readyTimeout = void 0;
        this._chanMgr = void 0;
        this._callbacks = void 0;
        this._forwarding = void 0;
        this._forwardingUnix = void 0;
        this._acceptX11 = void 0;
        this._agentFwdEnabled = void 0;
        this._remoteVer = void 0;
        this._protocol = void 0;
        this._sock = void 0;
        this._resetKA = void 0;
      }
      connect(cfg) {
        if (this._sock && isWritable(this._sock)) {
          this.once("close", () => {
            this.connect(cfg);
          });
          this.end();
          return this;
        }
        this.config.host = cfg.hostname || cfg.host || "localhost";
        this.config.port = cfg.port || 22;
        this.config.localAddress = typeof cfg.localAddress === "string" ? cfg.localAddress : void 0;
        this.config.localPort = typeof cfg.localPort === "string" || typeof cfg.localPort === "number" ? cfg.localPort : void 0;
        this.config.forceIPv4 = cfg.forceIPv4 || false;
        this.config.forceIPv6 = cfg.forceIPv6 || false;
        this.config.keepaliveCountMax = typeof cfg.keepaliveCountMax === "number" && cfg.keepaliveCountMax >= 0 ? cfg.keepaliveCountMax : 3;
        this.config.keepaliveInterval = typeof cfg.keepaliveInterval === "number" && cfg.keepaliveInterval > 0 ? cfg.keepaliveInterval : 0;
        this.config.readyTimeout = typeof cfg.readyTimeout === "number" && cfg.readyTimeout >= 0 ? cfg.readyTimeout : 2e4;
        this.config.ident = typeof cfg.ident === "string" || Buffer.isBuffer(cfg.ident) ? cfg.ident : void 0;
        const algorithms = {
          kex: void 0,
          serverHostKey: void 0,
          cs: {
            cipher: void 0,
            mac: void 0,
            compress: void 0,
            lang: []
          },
          sc: void 0
        };
        let allOfferDefaults = true;
        if (typeof cfg.algorithms === "object" && cfg.algorithms !== null) {
          algorithms.kex = generateAlgorithmList(cfg.algorithms.kex, DEFAULT_KEX, SUPPORTED_KEX);
          if (algorithms.kex !== DEFAULT_KEX)
            allOfferDefaults = false;
          algorithms.serverHostKey = generateAlgorithmList(cfg.algorithms.serverHostKey, DEFAULT_SERVER_HOST_KEY, SUPPORTED_SERVER_HOST_KEY);
          if (algorithms.serverHostKey !== DEFAULT_SERVER_HOST_KEY)
            allOfferDefaults = false;
          algorithms.cs.cipher = generateAlgorithmList(cfg.algorithms.cipher, DEFAULT_CIPHER, SUPPORTED_CIPHER);
          if (algorithms.cs.cipher !== DEFAULT_CIPHER)
            allOfferDefaults = false;
          algorithms.cs.mac = generateAlgorithmList(cfg.algorithms.hmac, DEFAULT_MAC, SUPPORTED_MAC);
          if (algorithms.cs.mac !== DEFAULT_MAC)
            allOfferDefaults = false;
          algorithms.cs.compress = generateAlgorithmList(cfg.algorithms.compress, DEFAULT_COMPRESSION, SUPPORTED_COMPRESSION);
          if (algorithms.cs.compress !== DEFAULT_COMPRESSION)
            allOfferDefaults = false;
          if (!allOfferDefaults)
            algorithms.sc = algorithms.cs;
        }
        if (typeof cfg.username === "string")
          this.config.username = cfg.username;
        else if (typeof cfg.user === "string")
          this.config.username = cfg.user;
        else
          throw new Error("Invalid username");
        this.config.password = typeof cfg.password === "string" ? cfg.password : void 0;
        this.config.privateKey = typeof cfg.privateKey === "string" || Buffer.isBuffer(cfg.privateKey) ? cfg.privateKey : void 0;
        this.config.localHostname = typeof cfg.localHostname === "string" ? cfg.localHostname : void 0;
        this.config.localUsername = typeof cfg.localUsername === "string" ? cfg.localUsername : void 0;
        this.config.tryKeyboard = cfg.tryKeyboard === true;
        if (typeof cfg.agent === "string" && cfg.agent.length)
          this.config.agent = createAgent(cfg.agent);
        else if (isAgent(cfg.agent))
          this.config.agent = cfg.agent;
        else
          this.config.agent = void 0;
        this.config.allowAgentFwd = cfg.agentForward === true && this.config.agent !== void 0;
        let authHandler = this.config.authHandler = typeof cfg.authHandler === "function" || Array.isArray(cfg.authHandler) ? cfg.authHandler : void 0;
        this.config.strictVendor = typeof cfg.strictVendor === "boolean" ? cfg.strictVendor : true;
        const debug = this.config.debug = typeof cfg.debug === "function" ? cfg.debug : void 0;
        if (cfg.agentForward === true && !this.config.allowAgentFwd) {
          throw new Error("You must set a valid agent path to allow agent forwarding");
        }
        let callbacks = this._callbacks = [];
        this._chanMgr = new ChannelManager(this);
        this._forwarding = {};
        this._forwardingUnix = {};
        this._acceptX11 = 0;
        this._agentFwdEnabled = false;
        this._agent = this.config.agent ? this.config.agent : void 0;
        this._remoteVer = void 0;
        let privateKey;
        if (this.config.privateKey) {
          privateKey = parseKey(this.config.privateKey, cfg.passphrase);
          if (privateKey instanceof Error)
            throw new Error(`Cannot parse privateKey: ${privateKey.message}`);
          if (Array.isArray(privateKey)) {
            privateKey = privateKey[0];
          }
          if (privateKey.getPrivatePEM() === null) {
            throw new Error("privateKey value does not contain a (valid) private key");
          }
        }
        let hostVerifier;
        if (typeof cfg.hostVerifier === "function") {
          const hashCb = cfg.hostVerifier;
          let hasher;
          if (HASHES.indexOf(cfg.hostHash) !== -1) {
            hasher = createHash(cfg.hostHash);
          }
          hostVerifier = (key, verify) => {
            if (hasher) {
              hasher.update(key);
              key = hasher.digest("hex");
            }
            const ret = hashCb(key, verify);
            if (ret !== void 0)
              verify(ret);
          };
        }
        const sock = this._sock = cfg.sock || new Socket();
        let ready = false;
        let sawHeader = false;
        if (this._protocol)
          this._protocol.cleanup();
        const DEBUG_HANDLER = !debug ? void 0 : (p, display, msg) => {
          debug(`Debug output from server: ${JSON.stringify(msg)}`);
        };
        const proto = this._protocol = new Protocol({
          ident: this.config.ident,
          offer: allOfferDefaults ? void 0 : algorithms,
          onWrite: (data) => {
            if (isWritable(sock))
              sock.write(data);
          },
          onError: (err) => {
            if (err.level === "handshake")
              clearTimeout(this._readyTimeout);
            if (!proto._destruct)
              sock.removeAllListeners("data");
            this.emit("error", err);
            try {
              sock.end();
            } catch {
            }
          },
          onHeader: (header) => {
            sawHeader = true;
            this._remoteVer = header.versions.software;
            if (header.greeting)
              this.emit("greeting", header.greeting);
          },
          onHandshakeComplete: (negotiated) => {
            this.emit("handshake", negotiated);
            if (!ready) {
              ready = true;
              proto.service("ssh-userauth");
            }
          },
          debug,
          hostVerifier,
          messageHandlers: {
            DEBUG: DEBUG_HANDLER,
            DISCONNECT: (p, reason, desc) => {
              if (reason !== DISCONNECT_REASON.BY_APPLICATION) {
                if (!desc) {
                  desc = DISCONNECT_REASON_BY_VALUE[reason];
                  if (desc === void 0)
                    desc = `Unexpected disconnection reason: ${reason}`;
                }
                const err = new Error(desc);
                err.code = reason;
                this.emit("error", err);
              }
              sock.end();
            },
            SERVICE_ACCEPT: (p, name) => {
              if (name === "ssh-userauth")
                tryNextAuth();
            },
            USERAUTH_BANNER: (p, msg) => {
              this.emit("banner", msg);
            },
            USERAUTH_SUCCESS: (p) => {
              resetKA();
              clearTimeout(this._readyTimeout);
              this.emit("ready");
            },
            USERAUTH_FAILURE: (p, authMethods, partialSuccess) => {
              if (curAuth.type === "agent") {
                const pos = curAuth.agentCtx.pos();
                debug && debug(`Client: Agent key #${pos + 1} failed`);
                return tryNextAgentKey();
              }
              debug && debug(`Client: ${curAuth.type} auth failed`);
              curPartial = partialSuccess;
              curAuthsLeft = authMethods;
              tryNextAuth();
            },
            USERAUTH_PASSWD_CHANGEREQ: (p, prompt) => {
              if (curAuth.type === "password") {
                this.emit("change password", prompt, (newPassword) => {
                  proto.authPassword(this.config.username, this.config.password, newPassword);
                });
              }
            },
            USERAUTH_PK_OK: (p) => {
              if (curAuth.type === "agent") {
                const key = curAuth.agentCtx.currentKey();
                proto.authPK(curAuth.username, key, (buf, cb) => {
                  curAuth.agentCtx.sign(key, buf, {}, (err, signed) => {
                    if (err) {
                      err.level = "agent";
                      this.emit("error", err);
                    } else {
                      return cb(signed);
                    }
                    tryNextAgentKey();
                  });
                });
              } else if (curAuth.type === "publickey") {
                proto.authPK(curAuth.username, curAuth.key, (buf, cb) => {
                  const signature = curAuth.key.sign(buf);
                  if (signature instanceof Error) {
                    signature.message = `Error signing data with key: ${signature.message}`;
                    signature.level = "client-authentication";
                    this.emit("error", signature);
                    return tryNextAuth();
                  }
                  cb(signature);
                });
              }
            },
            USERAUTH_INFO_REQUEST: (p, name, instructions, prompts) => {
              if (curAuth.type === "keyboard-interactive") {
                const nprompts = Array.isArray(prompts) ? prompts.length : 0;
                if (nprompts === 0) {
                  debug && debug("Client: Sending automatic USERAUTH_INFO_RESPONSE");
                  proto.authInfoRes();
                  return;
                }
                curAuth.prompt(name, instructions, "", prompts, (answers) => {
                  proto.authInfoRes(answers);
                });
              }
            },
            REQUEST_SUCCESS: (p, data) => {
              if (callbacks.length)
                callbacks.shift()(false, data);
            },
            REQUEST_FAILURE: (p) => {
              if (callbacks.length)
                callbacks.shift()(true);
            },
            GLOBAL_REQUEST: (p, name, wantReply, data) => {
              switch (name) {
                case "hostkeys-00@openssh.com":
                  hostKeysProve(this, data, (err, keys) => {
                    if (err)
                      return;
                    this.emit("hostkeys", keys);
                  });
                  if (wantReply)
                    proto.requestSuccess();
                  break;
                default:
                  if (wantReply)
                    proto.requestFailure();
              }
            },
            CHANNEL_OPEN: (p, info) => {
              onCHANNEL_OPEN(this, info);
            },
            CHANNEL_OPEN_CONFIRMATION: (p, info) => {
              const channel = this._chanMgr.get(info.recipient);
              if (typeof channel !== "function")
                return;
              const isSFTP = channel.type === "sftp";
              const type = isSFTP ? "session" : channel.type;
              const chanInfo = {
                type,
                incoming: {
                  id: info.recipient,
                  window: MAX_WINDOW,
                  packetSize: PACKET_SIZE,
                  state: "open"
                },
                outgoing: {
                  id: info.sender,
                  window: info.window,
                  packetSize: info.packetSize,
                  state: "open"
                }
              };
              const instance = isSFTP ? new SFTP(this, chanInfo, { debug }) : new Channel(this, chanInfo);
              this._chanMgr.update(info.recipient, instance);
              channel(void 0, instance);
            },
            CHANNEL_OPEN_FAILURE: (p, recipient, reason, description) => {
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "function")
                return;
              const info = { reason, description };
              onChannelOpenFailure(this, recipient, info, channel);
            },
            CHANNEL_DATA: (p, recipient, data) => {
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.incoming.window === 0)
                return;
              channel.incoming.window -= data.length;
              if (channel.push(data) === false) {
                channel._waitChanDrain = true;
                return;
              }
              if (channel.incoming.window <= WINDOW_THRESHOLD)
                windowAdjust(channel);
            },
            CHANNEL_EXTENDED_DATA: (p, recipient, data, type) => {
              if (type !== STDERR)
                return;
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.incoming.window === 0)
                return;
              channel.incoming.window -= data.length;
              if (!channel.stderr.push(data)) {
                channel._waitChanDrain = true;
                return;
              }
              if (channel.incoming.window <= WINDOW_THRESHOLD)
                windowAdjust(channel);
            },
            CHANNEL_WINDOW_ADJUST: (p, recipient, amount) => {
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              channel.outgoing.window += amount;
              if (channel._waitWindow) {
                channel._waitWindow = false;
                if (channel._chunk) {
                  channel._write(channel._chunk, null, channel._chunkcb);
                } else if (channel._chunkcb) {
                  channel._chunkcb();
                } else if (channel._chunkErr) {
                  channel.stderr._write(channel._chunkErr, null, channel._chunkcbErr);
                } else if (channel._chunkcbErr) {
                  channel._chunkcbErr();
                }
              }
            },
            CHANNEL_SUCCESS: (p, recipient) => {
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              this._resetKA();
              if (channel._callbacks.length)
                channel._callbacks.shift()(false);
            },
            CHANNEL_FAILURE: (p, recipient) => {
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              this._resetKA();
              if (channel._callbacks.length)
                channel._callbacks.shift()(true);
            },
            CHANNEL_REQUEST: (p, recipient, type, wantReply, data) => {
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              const exit = channel._exit;
              if (exit.code !== void 0)
                return;
              switch (type) {
                case "exit-status":
                  channel.emit("exit", exit.code = data);
                  return;
                case "exit-signal":
                  channel.emit("exit", exit.code = null, exit.signal = `SIG${data.signal}`, exit.dump = data.coreDumped, exit.desc = data.errorMessage);
                  return;
              }
              if (wantReply)
                p.channelFailure(channel.outgoing.id);
            },
            CHANNEL_EOF: (p, recipient) => {
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.incoming.state !== "open")
                return;
              channel.incoming.state = "eof";
              if (channel.readable)
                channel.push(null);
              if (channel.stderr.readable)
                channel.stderr.push(null);
            },
            CHANNEL_CLOSE: (p, recipient) => {
              onCHANNEL_CLOSE(this, recipient, this._chanMgr.get(recipient));
            }
          }
        });
        sock.pause();
        const kainterval = this.config.keepaliveInterval;
        const kacountmax = this.config.keepaliveCountMax;
        let kacount = 0;
        let katimer;
        const sendKA = () => {
          if (++kacount > kacountmax) {
            clearInterval(katimer);
            if (sock.readable) {
              const err = new Error("Keepalive timeout");
              err.level = "client-timeout";
              this.emit("error", err);
              sock.destroy();
            }
            return;
          }
          if (isWritable(sock)) {
            callbacks.push(resetKA);
            proto.ping();
          } else {
            clearInterval(katimer);
          }
        };
        function resetKA() {
          if (kainterval > 0) {
            kacount = 0;
            clearInterval(katimer);
            if (isWritable(sock))
              katimer = setInterval(sendKA, kainterval);
          }
        }
        this._resetKA = resetKA;
        const onDone = (() => {
          let called = false;
          return () => {
            if (called)
              return;
            called = true;
            if (wasConnected && !sawHeader) {
              const err = makeError("Connection lost before handshake", "protocol", true);
              this.emit("error", err);
            }
          };
        })();
        const onConnect = (() => {
          let called = false;
          return () => {
            if (called)
              return;
            called = true;
            wasConnected = true;
            debug && debug("Socket connected");
            this.emit("connect");
            cryptoInit.then(() => {
              proto.start();
              sock.on("data", (data) => {
                try {
                  proto.parse(data, 0, data.length);
                } catch (ex) {
                  this.emit("error", ex);
                  try {
                    if (isWritable(sock))
                      sock.end();
                  } catch {
                  }
                }
              });
              if (sock.stderr && typeof sock.stderr.resume === "function")
                sock.stderr.resume();
              sock.resume();
            }).catch((err) => {
              this.emit("error", err);
              try {
                if (isWritable(sock))
                  sock.end();
              } catch {
              }
            });
          };
        })();
        let wasConnected = false;
        sock.on("connect", onConnect).on("timeout", () => {
          this.emit("timeout");
        }).on("error", (err) => {
          debug && debug(`Socket error: ${err.message}`);
          clearTimeout(this._readyTimeout);
          err.level = "client-socket";
          this.emit("error", err);
        }).on("end", () => {
          debug && debug("Socket ended");
          onDone();
          proto.cleanup();
          clearTimeout(this._readyTimeout);
          clearInterval(katimer);
          this.emit("end");
        }).on("close", () => {
          debug && debug("Socket closed");
          onDone();
          proto.cleanup();
          clearTimeout(this._readyTimeout);
          clearInterval(katimer);
          this.emit("close");
          const callbacks_ = callbacks;
          callbacks = this._callbacks = [];
          const err = new Error("No response from server");
          for (let i = 0; i < callbacks_.length; ++i)
            callbacks_[i](err);
          this._chanMgr.cleanup(err);
        });
        let curAuth;
        let curPartial = null;
        let curAuthsLeft = null;
        const authsAllowed = ["none"];
        if (this.config.password !== void 0)
          authsAllowed.push("password");
        if (privateKey !== void 0)
          authsAllowed.push("publickey");
        if (this._agent !== void 0)
          authsAllowed.push("agent");
        if (this.config.tryKeyboard)
          authsAllowed.push("keyboard-interactive");
        if (privateKey !== void 0 && this.config.localHostname !== void 0 && this.config.localUsername !== void 0) {
          authsAllowed.push("hostbased");
        }
        if (Array.isArray(authHandler))
          authHandler = makeSimpleAuthHandler(authHandler);
        else if (typeof authHandler !== "function")
          authHandler = makeSimpleAuthHandler(authsAllowed);
        let hasSentAuth = false;
        const doNextAuth = (nextAuth) => {
          if (hasSentAuth)
            return;
          hasSentAuth = true;
          if (nextAuth === false) {
            const err = new Error("All configured authentication methods failed");
            err.level = "client-authentication";
            this.emit("error", err);
            this.end();
            return;
          }
          if (typeof nextAuth === "string") {
            const type = nextAuth;
            if (authsAllowed.indexOf(type) === -1)
              return skipAuth(`Authentication method not allowed: ${type}`);
            const username = this.config.username;
            switch (type) {
              case "password":
                nextAuth = { type, username, password: this.config.password };
                break;
              case "publickey":
                nextAuth = { type, username, key: privateKey };
                break;
              case "hostbased":
                nextAuth = {
                  type,
                  username,
                  key: privateKey,
                  localHostname: this.config.localHostname,
                  localUsername: this.config.localUsername
                };
                break;
              case "agent":
                nextAuth = {
                  type,
                  username,
                  agentCtx: new AgentContext(this._agent)
                };
                break;
              case "keyboard-interactive":
                nextAuth = {
                  type,
                  username,
                  prompt: (...args) => this.emit("keyboard-interactive", ...args)
                };
                break;
              case "none":
                nextAuth = { type, username };
                break;
              default:
                return skipAuth(`Skipping unsupported authentication method: ${nextAuth}`);
            }
          } else if (typeof nextAuth !== "object" || nextAuth === null) {
            return skipAuth(`Skipping invalid authentication attempt: ${nextAuth}`);
          } else {
            const username = nextAuth.username;
            if (typeof username !== "string") {
              return skipAuth(`Skipping invalid authentication attempt: ${nextAuth}`);
            }
            const type = nextAuth.type;
            switch (type) {
              case "password": {
                const { password } = nextAuth;
                if (typeof password !== "string" && !Buffer.isBuffer(password))
                  return skipAuth("Skipping invalid password auth attempt");
                nextAuth = { type, username, password };
                break;
              }
              case "publickey": {
                const key = parseKey(nextAuth.key, nextAuth.passphrase);
                if (key instanceof Error)
                  return skipAuth("Skipping invalid key auth attempt");
                if (!key.isPrivateKey())
                  return skipAuth("Skipping non-private key");
                nextAuth = { type, username, key };
                break;
              }
              case "hostbased": {
                const { localHostname, localUsername } = nextAuth;
                const key = parseKey(nextAuth.key, nextAuth.passphrase);
                if (key instanceof Error || typeof localHostname !== "string" || typeof localUsername !== "string") {
                  return skipAuth("Skipping invalid hostbased auth attempt");
                }
                if (!key.isPrivateKey())
                  return skipAuth("Skipping non-private key");
                nextAuth = { type, username, key, localHostname, localUsername };
                break;
              }
              case "agent": {
                let agent = nextAuth.agent;
                if (typeof agent === "string" && agent.length) {
                  agent = createAgent(agent);
                } else if (!isAgent(agent)) {
                  return skipAuth(`Skipping invalid agent: ${nextAuth.agent}`);
                }
                nextAuth = { type, username, agentCtx: new AgentContext(agent) };
                break;
              }
              case "keyboard-interactive": {
                const { prompt } = nextAuth;
                if (typeof prompt !== "function") {
                  return skipAuth("Skipping invalid keyboard-interactive auth attempt");
                }
                nextAuth = { type, username, prompt };
                break;
              }
              case "none":
                nextAuth = { type, username };
                break;
              default:
                return skipAuth(`Skipping unsupported authentication method: ${nextAuth}`);
            }
          }
          curAuth = nextAuth;
          try {
            const username = curAuth.username;
            switch (curAuth.type) {
              case "password":
                proto.authPassword(username, curAuth.password);
                break;
              case "publickey":
                proto.authPK(username, curAuth.key);
                break;
              case "hostbased":
                proto.authHostbased(username, curAuth.key, curAuth.localHostname, curAuth.localUsername, (buf, cb) => {
                  const signature = curAuth.key.sign(buf);
                  if (signature instanceof Error) {
                    signature.message = `Error while signing with key: ${signature.message}`;
                    signature.level = "client-authentication";
                    this.emit("error", signature);
                    return tryNextAuth();
                  }
                  cb(signature);
                });
                break;
              case "agent":
                curAuth.agentCtx.init((err) => {
                  if (err) {
                    err.level = "agent";
                    this.emit("error", err);
                    return tryNextAuth();
                  }
                  tryNextAgentKey();
                });
                break;
              case "keyboard-interactive":
                proto.authKeyboard(username);
                break;
              case "none":
                proto.authNone(username);
                break;
            }
          } finally {
            hasSentAuth = false;
          }
        };
        function skipAuth(msg) {
          debug && debug(msg);
          process.nextTick(tryNextAuth);
        }
        function tryNextAuth() {
          hasSentAuth = false;
          const auth = authHandler(curAuthsLeft, curPartial, doNextAuth);
          if (hasSentAuth || auth === void 0)
            return;
          doNextAuth(auth);
        }
        const tryNextAgentKey = () => {
          if (curAuth.type === "agent") {
            const key = curAuth.agentCtx.nextKey();
            if (key === false) {
              debug && debug("Agent: No more keys left to try");
              debug && debug("Client: agent auth failed");
              tryNextAuth();
            } else {
              const pos = curAuth.agentCtx.pos();
              debug && debug(`Agent: Trying key #${pos + 1}`);
              proto.authPK(curAuth.username, key);
            }
          }
        };
        const startTimeout = () => {
          if (this.config.readyTimeout > 0) {
            this._readyTimeout = setTimeout(() => {
              const err = new Error("Timed out while waiting for handshake");
              err.level = "client-timeout";
              this.emit("error", err);
              sock.destroy();
            }, this.config.readyTimeout);
          }
        };
        if (!cfg.sock) {
          let host = this.config.host;
          const forceIPv4 = this.config.forceIPv4;
          const forceIPv6 = this.config.forceIPv6;
          debug && debug(`Client: Trying ${host} on port ${this.config.port} ...`);
          const doConnect = () => {
            startTimeout();
            sock.connect({
              host,
              port: this.config.port,
              localAddress: this.config.localAddress,
              localPort: this.config.localPort
            });
            sock.setNoDelay(true);
            sock.setMaxListeners(0);
            sock.setTimeout(typeof cfg.timeout === "number" ? cfg.timeout : 0);
          };
          if (!forceIPv4 && !forceIPv6 || forceIPv4 && forceIPv6) {
            doConnect();
          } else {
            dnsLookup(host, forceIPv4 ? 4 : 6, (err, address, family) => {
              if (err) {
                const type = forceIPv4 ? "IPv4" : "IPv6";
                const error = new Error(`Error while looking up ${type} address for '${host}': ${err}`);
                clearTimeout(this._readyTimeout);
                error.level = "client-dns";
                this.emit("error", error);
                this.emit("close");
                return;
              }
              host = address;
              doConnect();
            });
          }
        } else {
          startTimeout();
          if (typeof sock.connecting === "boolean") {
            if (!sock.connecting) {
              onConnect();
            }
          } else {
            onConnect();
          }
        }
        return this;
      }
      end() {
        if (this._sock && isWritable(this._sock)) {
          this._protocol.disconnect(DISCONNECT_REASON.BY_APPLICATION);
          this._sock.end();
        }
        return this;
      }
      destroy() {
        this._sock && isWritable(this._sock) && this._sock.destroy();
        return this;
      }
      exec(cmd, opts, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        if (typeof opts === "function") {
          cb = opts;
          opts = {};
        }
        const extraOpts = { allowHalfOpen: opts.allowHalfOpen !== false };
        openChannel(this, "session", extraOpts, (err, chan) => {
          if (err) {
            cb(err);
            return;
          }
          const todo = [];
          function reqCb(err2) {
            if (err2) {
              chan.close();
              cb(err2);
              return;
            }
            if (todo.length)
              todo.shift()();
          }
          if (this.config.allowAgentFwd === true || opts && opts.agentForward === true && this._agent !== void 0) {
            todo.push(() => reqAgentFwd(chan, reqCb));
          }
          if (typeof opts === "object" && opts !== null) {
            if (typeof opts.env === "object" && opts.env !== null)
              reqEnv(chan, opts.env);
            if (typeof opts.pty === "object" && opts.pty !== null || opts.pty === true) {
              todo.push(() => reqPty(chan, opts.pty, reqCb));
            }
            if (typeof opts.x11 === "object" && opts.x11 !== null || opts.x11 === "number" || opts.x11 === true) {
              todo.push(() => reqX11(chan, opts.x11, reqCb));
            }
          }
          todo.push(() => reqExec(chan, cmd, opts, cb));
          todo.shift()();
        });
        return this;
      }
      shell(wndopts, opts, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        if (typeof wndopts === "function") {
          cb = wndopts;
          wndopts = opts = void 0;
        } else if (typeof opts === "function") {
          cb = opts;
          opts = void 0;
        }
        if (wndopts && (wndopts.x11 !== void 0 || wndopts.env !== void 0)) {
          opts = wndopts;
          wndopts = void 0;
        }
        openChannel(this, "session", (err, chan) => {
          if (err) {
            cb(err);
            return;
          }
          const todo = [];
          function reqCb(err2) {
            if (err2) {
              chan.close();
              cb(err2);
              return;
            }
            if (todo.length)
              todo.shift()();
          }
          if (this.config.allowAgentFwd === true || opts && opts.agentForward === true && this._agent !== void 0) {
            todo.push(() => reqAgentFwd(chan, reqCb));
          }
          if (wndopts !== false)
            todo.push(() => reqPty(chan, wndopts, reqCb));
          if (typeof opts === "object" && opts !== null) {
            if (typeof opts.env === "object" && opts.env !== null)
              reqEnv(chan, opts.env);
            if (typeof opts.x11 === "object" && opts.x11 !== null || opts.x11 === "number" || opts.x11 === true) {
              todo.push(() => reqX11(chan, opts.x11, reqCb));
            }
          }
          todo.push(() => reqShell(chan, cb));
          todo.shift()();
        });
        return this;
      }
      subsys(name, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        openChannel(this, "session", (err, chan) => {
          if (err) {
            cb(err);
            return;
          }
          reqSubsystem(chan, name, (err2, stream) => {
            if (err2) {
              cb(err2);
              return;
            }
            cb(void 0, stream);
          });
        });
        return this;
      }
      forwardIn(bindAddr, bindPort, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        const wantReply = typeof cb === "function";
        if (wantReply) {
          this._callbacks.push((had_err, data) => {
            if (had_err) {
              cb(had_err !== true ? had_err : new Error(`Unable to bind to ${bindAddr}:${bindPort}`));
              return;
            }
            let realPort = bindPort;
            if (bindPort === 0 && data && data.length >= 4) {
              realPort = readUInt32BE(data, 0);
              if (!(this._protocol._compatFlags & COMPAT.DYN_RPORT_BUG))
                bindPort = realPort;
            }
            this._forwarding[`${bindAddr}:${bindPort}`] = realPort;
            cb(void 0, realPort);
          });
        }
        this._protocol.tcpipForward(bindAddr, bindPort, wantReply);
        return this;
      }
      unforwardIn(bindAddr, bindPort, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        const wantReply = typeof cb === "function";
        if (wantReply) {
          this._callbacks.push((had_err) => {
            if (had_err) {
              cb(had_err !== true ? had_err : new Error(`Unable to unbind from ${bindAddr}:${bindPort}`));
              return;
            }
            delete this._forwarding[`${bindAddr}:${bindPort}`];
            cb();
          });
        }
        this._protocol.cancelTcpipForward(bindAddr, bindPort, wantReply);
        return this;
      }
      forwardOut(srcIP, srcPort, dstIP, dstPort, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        const cfg = {
          srcIP,
          srcPort,
          dstIP,
          dstPort
        };
        if (typeof cb !== "function")
          cb = noop;
        openChannel(this, "direct-tcpip", cfg, cb);
        return this;
      }
      openssh_noMoreSessions(cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        const wantReply = typeof cb === "function";
        if (!this.config.strictVendor || this.config.strictVendor && RE_OPENSSH.test(this._remoteVer)) {
          if (wantReply) {
            this._callbacks.push((had_err) => {
              if (had_err) {
                cb(had_err !== true ? had_err : new Error("Unable to disable future sessions"));
                return;
              }
              cb();
            });
          }
          this._protocol.openssh_noMoreSessions(wantReply);
          return this;
        }
        if (!wantReply)
          return this;
        process.nextTick(cb, new Error("strictVendor enabled and server is not OpenSSH or compatible version"));
        return this;
      }
      openssh_forwardInStreamLocal(socketPath, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        const wantReply = typeof cb === "function";
        if (!this.config.strictVendor || this.config.strictVendor && RE_OPENSSH.test(this._remoteVer)) {
          if (wantReply) {
            this._callbacks.push((had_err) => {
              if (had_err) {
                cb(had_err !== true ? had_err : new Error(`Unable to bind to ${socketPath}`));
                return;
              }
              this._forwardingUnix[socketPath] = true;
              cb();
            });
          }
          this._protocol.openssh_streamLocalForward(socketPath, wantReply);
          return this;
        }
        if (!wantReply)
          return this;
        process.nextTick(cb, new Error("strictVendor enabled and server is not OpenSSH or compatible version"));
        return this;
      }
      openssh_unforwardInStreamLocal(socketPath, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        const wantReply = typeof cb === "function";
        if (!this.config.strictVendor || this.config.strictVendor && RE_OPENSSH.test(this._remoteVer)) {
          if (wantReply) {
            this._callbacks.push((had_err) => {
              if (had_err) {
                cb(had_err !== true ? had_err : new Error(`Unable to unbind from ${socketPath}`));
                return;
              }
              delete this._forwardingUnix[socketPath];
              cb();
            });
          }
          this._protocol.openssh_cancelStreamLocalForward(socketPath, wantReply);
          return this;
        }
        if (!wantReply)
          return this;
        process.nextTick(cb, new Error("strictVendor enabled and server is not OpenSSH or compatible version"));
        return this;
      }
      openssh_forwardOutStreamLocal(socketPath, cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        if (typeof cb !== "function")
          cb = noop;
        if (!this.config.strictVendor || this.config.strictVendor && RE_OPENSSH.test(this._remoteVer)) {
          openChannel(this, "direct-streamlocal@openssh.com", { socketPath }, cb);
          return this;
        }
        process.nextTick(cb, new Error("strictVendor enabled and server is not OpenSSH or compatible version"));
        return this;
      }
      sftp(cb) {
        if (!this._sock || !isWritable(this._sock))
          throw new Error("Not connected");
        openChannel(this, "sftp", (err, sftp) => {
          if (err) {
            cb(err);
            return;
          }
          reqSubsystem(sftp, "sftp", (err2, sftp_) => {
            if (err2) {
              cb(err2);
              return;
            }
            function removeListeners() {
              sftp.removeListener("ready", onReady);
              sftp.removeListener("error", onError);
              sftp.removeListener("exit", onExit);
              sftp.removeListener("close", onExit);
            }
            function onReady() {
              removeListeners();
              cb(void 0, sftp);
            }
            function onError(err3) {
              removeListeners();
              cb(err3);
            }
            function onExit(code, signal) {
              removeListeners();
              let msg;
              if (typeof code === "number")
                msg = `Received exit code ${code} while establishing SFTP session`;
              else if (signal !== void 0)
                msg = `Received signal ${signal} while establishing SFTP session`;
              else
                msg = "Received unexpected SFTP session termination";
              const err3 = new Error(msg);
              err3.code = code;
              err3.signal = signal;
              cb(err3);
            }
            sftp.on("ready", onReady).on("error", onError).on("exit", onExit).on("close", onExit);
            sftp._init();
          });
        });
        return this;
      }
    };
    function openChannel(self2, type, opts, cb) {
      const initWindow = MAX_WINDOW;
      const maxPacket = PACKET_SIZE;
      if (typeof opts === "function") {
        cb = opts;
        opts = {};
      }
      const wrapper = (err, stream) => {
        cb(err, stream);
      };
      wrapper.type = type;
      const localChan = self2._chanMgr.add(wrapper);
      if (localChan === -1) {
        cb(new Error("No free channels available"));
        return;
      }
      switch (type) {
        case "session":
        case "sftp":
          self2._protocol.session(localChan, initWindow, maxPacket);
          break;
        case "direct-tcpip":
          self2._protocol.directTcpip(localChan, initWindow, maxPacket, opts);
          break;
        case "direct-streamlocal@openssh.com":
          self2._protocol.openssh_directStreamLocal(localChan, initWindow, maxPacket, opts);
          break;
        default:
          throw new Error(`Unsupported channel type: ${type}`);
      }
    }
    function reqX11(chan, screen, cb) {
      const cfg = {
        single: false,
        protocol: "MIT-MAGIC-COOKIE-1",
        cookie: void 0,
        screen: 0
      };
      if (typeof screen === "function") {
        cb = screen;
      } else if (typeof screen === "object" && screen !== null) {
        if (typeof screen.single === "boolean")
          cfg.single = screen.single;
        if (typeof screen.screen === "number")
          cfg.screen = screen.screen;
        if (typeof screen.protocol === "string")
          cfg.protocol = screen.protocol;
        if (typeof screen.cookie === "string")
          cfg.cookie = screen.cookie;
        else if (Buffer.isBuffer(screen.cookie))
          cfg.cookie = screen.cookie.hexSlice(0, screen.cookie.length);
      }
      if (cfg.cookie === void 0)
        cfg.cookie = randomCookie();
      const wantReply = typeof cb === "function";
      if (chan.outgoing.state !== "open") {
        if (wantReply)
          cb(new Error("Channel is not open"));
        return;
      }
      if (wantReply) {
        chan._callbacks.push((had_err) => {
          if (had_err) {
            cb(had_err !== true ? had_err : new Error("Unable to request X11"));
            return;
          }
          chan._hasX11 = true;
          ++chan._client._acceptX11;
          chan.once("close", () => {
            if (chan._client._acceptX11)
              --chan._client._acceptX11;
          });
          cb();
        });
      }
      chan._client._protocol.x11Forward(chan.outgoing.id, cfg, wantReply);
    }
    function reqPty(chan, opts, cb) {
      let rows = 24;
      let cols = 80;
      let width = 640;
      let height = 480;
      let term = "vt100";
      let modes = null;
      if (typeof opts === "function") {
        cb = opts;
      } else if (typeof opts === "object" && opts !== null) {
        if (typeof opts.rows === "number")
          rows = opts.rows;
        if (typeof opts.cols === "number")
          cols = opts.cols;
        if (typeof opts.width === "number")
          width = opts.width;
        if (typeof opts.height === "number")
          height = opts.height;
        if (typeof opts.term === "string")
          term = opts.term;
        if (typeof opts.modes === "object")
          modes = opts.modes;
      }
      const wantReply = typeof cb === "function";
      if (chan.outgoing.state !== "open") {
        if (wantReply)
          cb(new Error("Channel is not open"));
        return;
      }
      if (wantReply) {
        chan._callbacks.push((had_err) => {
          if (had_err) {
            cb(had_err !== true ? had_err : new Error("Unable to request a pseudo-terminal"));
            return;
          }
          cb();
        });
      }
      chan._client._protocol.pty(chan.outgoing.id, rows, cols, height, width, term, modes, wantReply);
    }
    function reqAgentFwd(chan, cb) {
      const wantReply = typeof cb === "function";
      if (chan.outgoing.state !== "open") {
        wantReply && cb(new Error("Channel is not open"));
        return;
      }
      if (chan._client._agentFwdEnabled) {
        wantReply && cb(false);
        return;
      }
      chan._client._agentFwdEnabled = true;
      chan._callbacks.push((had_err) => {
        if (had_err) {
          chan._client._agentFwdEnabled = false;
          if (wantReply) {
            cb(had_err !== true ? had_err : new Error("Unable to request agent forwarding"));
          }
          return;
        }
        if (wantReply)
          cb();
      });
      chan._client._protocol.openssh_agentForward(chan.outgoing.id, true);
    }
    function reqShell(chan, cb) {
      if (chan.outgoing.state !== "open") {
        cb(new Error("Channel is not open"));
        return;
      }
      chan._callbacks.push((had_err) => {
        if (had_err) {
          cb(had_err !== true ? had_err : new Error("Unable to open shell"));
          return;
        }
        chan.subtype = "shell";
        cb(void 0, chan);
      });
      chan._client._protocol.shell(chan.outgoing.id, true);
    }
    function reqExec(chan, cmd, opts, cb) {
      if (chan.outgoing.state !== "open") {
        cb(new Error("Channel is not open"));
        return;
      }
      chan._callbacks.push((had_err) => {
        if (had_err) {
          cb(had_err !== true ? had_err : new Error("Unable to exec"));
          return;
        }
        chan.subtype = "exec";
        chan.allowHalfOpen = opts.allowHalfOpen !== false;
        cb(void 0, chan);
      });
      chan._client._protocol.exec(chan.outgoing.id, cmd, true);
    }
    function reqEnv(chan, env) {
      if (chan.outgoing.state !== "open")
        return;
      const keys = Object.keys(env || {});
      for (let i = 0; i < keys.length; ++i) {
        const key = keys[i];
        const val = env[key];
        chan._client._protocol.env(chan.outgoing.id, key, val, false);
      }
    }
    function reqSubsystem(chan, name, cb) {
      if (chan.outgoing.state !== "open") {
        cb(new Error("Channel is not open"));
        return;
      }
      chan._callbacks.push((had_err) => {
        if (had_err) {
          cb(had_err !== true ? had_err : new Error(`Unable to start subsystem: ${name}`));
          return;
        }
        chan.subtype = "subsystem";
        cb(void 0, chan);
      });
      chan._client._protocol.subsystem(chan.outgoing.id, name, true);
    }
    function onCHANNEL_OPEN(self2, info) {
      let localChan = -1;
      let reason;
      const accept = () => {
        const chanInfo = {
          type: info.type,
          incoming: {
            id: localChan,
            window: MAX_WINDOW,
            packetSize: PACKET_SIZE,
            state: "open"
          },
          outgoing: {
            id: info.sender,
            window: info.window,
            packetSize: info.packetSize,
            state: "open"
          }
        };
        const stream = new Channel(self2, chanInfo);
        self2._chanMgr.update(localChan, stream);
        self2._protocol.channelOpenConfirm(info.sender, localChan, MAX_WINDOW, PACKET_SIZE);
        return stream;
      };
      const reject = () => {
        if (reason === void 0) {
          if (localChan === -1)
            reason = CHANNEL_OPEN_FAILURE.RESOURCE_SHORTAGE;
          else
            reason = CHANNEL_OPEN_FAILURE.CONNECT_FAILED;
        }
        if (localChan !== -1)
          self2._chanMgr.remove(localChan);
        self2._protocol.channelOpenFail(info.sender, reason, "");
      };
      const reserveChannel = () => {
        localChan = self2._chanMgr.add();
        if (localChan === -1) {
          reason = CHANNEL_OPEN_FAILURE.RESOURCE_SHORTAGE;
          if (self2.config.debug) {
            self2.config.debug("Client: Automatic rejection of incoming channel open: no channels available");
          }
        }
        return localChan !== -1;
      };
      const data = info.data;
      switch (info.type) {
        case "forwarded-tcpip": {
          const val = self2._forwarding[`${data.destIP}:${data.destPort}`];
          if (val !== void 0 && reserveChannel()) {
            if (data.destPort === 0)
              data.destPort = val;
            self2.emit("tcp connection", data, accept, reject);
            return;
          }
          break;
        }
        case "forwarded-streamlocal@openssh.com":
          if (self2._forwardingUnix[data.socketPath] !== void 0 && reserveChannel()) {
            self2.emit("unix connection", data, accept, reject);
            return;
          }
          break;
        case "auth-agent@openssh.com":
          if (self2._agentFwdEnabled && typeof self2._agent.getStream === "function" && reserveChannel()) {
            self2._agent.getStream((err, stream) => {
              if (err)
                return reject();
              const upstream = accept();
              upstream.pipe(stream).pipe(upstream);
            });
            return;
          }
          break;
        case "x11":
          if (self2._acceptX11 !== 0 && reserveChannel()) {
            self2.emit("x11", data, accept, reject);
            return;
          }
          break;
        default:
          reason = CHANNEL_OPEN_FAILURE.UNKNOWN_CHANNEL_TYPE;
          if (self2.config.debug) {
            self2.config.debug(`Client: Automatic rejection of unsupported incoming channel open type: ${info.type}`);
          }
      }
      if (reason === void 0) {
        reason = CHANNEL_OPEN_FAILURE.ADMINISTRATIVELY_PROHIBITED;
        if (self2.config.debug) {
          self2.config.debug("Client: Automatic rejection of unexpected incoming channel open for: " + info.type);
        }
      }
      reject();
    }
    var randomCookie = (() => {
      const buffer = Buffer.allocUnsafe(16);
      return () => {
        randomFillSync(buffer, 0, 16);
        return buffer.hexSlice(0, 16);
      };
    })();
    function makeSimpleAuthHandler(authList) {
      if (!Array.isArray(authList))
        throw new Error("authList must be an array");
      let a = 0;
      return (authsLeft, partialSuccess, cb) => {
        if (a === authList.length)
          return false;
        return authList[a++];
      };
    }
    function hostKeysProve(client, keys_, cb) {
      if (!client._sock || !isWritable(client._sock))
        return;
      if (typeof cb !== "function")
        cb = noop;
      if (!Array.isArray(keys_))
        throw new TypeError("Invalid keys argument type");
      const keys = [];
      for (const key of keys_) {
        const parsed = parseKey(key);
        if (parsed instanceof Error)
          throw parsed;
        keys.push(parsed);
      }
      if (!client.config.strictVendor || client.config.strictVendor && RE_OPENSSH.test(client._remoteVer)) {
        client._callbacks.push((had_err, data) => {
          if (had_err) {
            cb(had_err !== true ? had_err : new Error("Server failed to prove supplied keys"));
            return;
          }
          const ret = [];
          let keyIdx = 0;
          bufferParser.init(data, 0);
          while (bufferParser.avail()) {
            if (keyIdx === keys.length)
              break;
            const key = keys[keyIdx++];
            const keyPublic = key.getPublicSSH();
            const sigEntry = bufferParser.readString();
            sigParser.init(sigEntry, 0);
            const type = sigParser.readString(true);
            let value = sigParser.readString();
            let algo;
            if (type !== key.type) {
              if (key.type === "ssh-rsa") {
                switch (type) {
                  case "rsa-sha2-256":
                    algo = "sha256";
                    break;
                  case "rsa-sha2-512":
                    algo = "sha512";
                    break;
                  default:
                    continue;
                }
              } else {
                continue;
              }
            }
            const sessionID = client._protocol._kex.sessionID;
            const verifyData = Buffer.allocUnsafe(4 + 29 + 4 + sessionID.length + 4 + keyPublic.length);
            let p = 0;
            writeUInt32BE(verifyData, 29, p);
            verifyData.utf8Write("hostkeys-prove-00@openssh.com", p += 4, 29);
            writeUInt32BE(verifyData, sessionID.length, p += 29);
            bufferCopy(sessionID, verifyData, 0, sessionID.length, p += 4);
            writeUInt32BE(verifyData, keyPublic.length, p += sessionID.length);
            bufferCopy(keyPublic, verifyData, 0, keyPublic.length, p += 4);
            if (!(value = sigSSHToASN1(value, type)))
              continue;
            if (key.verify(verifyData, value, algo) === true)
              ret.push(key);
          }
          sigParser.clear();
          bufferParser.clear();
          cb(null, ret);
        });
        client._protocol.openssh_hostKeysProve(keys);
        return;
      }
      process.nextTick(cb, new Error("strictVendor enabled and server is not OpenSSH or compatible version"));
    }
    module2.exports = Client;
  }
});

// node_modules/ssh2/lib/http-agents.js
var require_http_agents = __commonJS({
  "node_modules/ssh2/lib/http-agents.js"(exports) {
    "use strict";
    var { Agent: HttpAgent } = require("http");
    var { Agent: HttpsAgent } = require("https");
    var { connect: tlsConnect } = require("tls");
    var Client;
    for (const ctor of [HttpAgent, HttpsAgent]) {
      class SSHAgent extends ctor {
        constructor(connectCfg, agentOptions) {
          super(agentOptions);
          this._connectCfg = connectCfg;
          this._defaultSrcIP = agentOptions && agentOptions.srcIP || "localhost";
        }
        createConnection(options, cb) {
          const srcIP = options && options.localAddress || this._defaultSrcIP;
          const srcPort = options && options.localPort || 0;
          const dstIP = options.host;
          const dstPort = options.port;
          if (Client === void 0)
            Client = require_client();
          const client = new Client();
          let triedForward = false;
          client.on("ready", () => {
            client.forwardOut(srcIP, srcPort, dstIP, dstPort, (err, stream) => {
              triedForward = true;
              if (err) {
                client.end();
                return cb(err);
              }
              stream.once("close", () => client.end());
              cb(null, decorateStream(stream, ctor, options));
            });
          }).on("error", cb).on("close", () => {
            if (!triedForward)
              cb(new Error("Unexpected connection close"));
          }).connect(this._connectCfg);
        }
      }
      exports[ctor === HttpAgent ? "SSHTTPAgent" : "SSHTTPSAgent"] = SSHAgent;
    }
    function noop() {
    }
    function decorateStream(stream, ctor, options) {
      if (ctor === HttpAgent) {
        stream.setKeepAlive = noop;
        stream.setNoDelay = noop;
        stream.setTimeout = noop;
        stream.ref = noop;
        stream.unref = noop;
        stream.destroySoon = stream.destroy;
        return stream;
      }
      options.socket = stream;
      const wrapped = tlsConnect(options);
      const onClose = (() => {
        let called = false;
        return () => {
          if (called)
            return;
          called = true;
          if (stream.isPaused())
            stream.resume();
        };
      })();
      wrapped.on("end", onClose).on("close", onClose);
      return wrapped;
    }
  }
});

// node_modules/ssh2/lib/server.js
var require_server = __commonJS({
  "node_modules/ssh2/lib/server.js"(exports, module2) {
    "use strict";
    var { Server: netServer } = require("net");
    var EventEmitter = require("events");
    var { listenerCount } = EventEmitter;
    var {
      CHANNEL_OPEN_FAILURE,
      DEFAULT_CIPHER,
      DEFAULT_COMPRESSION,
      DEFAULT_KEX,
      DEFAULT_MAC,
      DEFAULT_SERVER_HOST_KEY,
      DISCONNECT_REASON,
      DISCONNECT_REASON_BY_VALUE,
      SUPPORTED_CIPHER,
      SUPPORTED_COMPRESSION,
      SUPPORTED_KEX,
      SUPPORTED_MAC,
      SUPPORTED_SERVER_HOST_KEY
    } = require_constants();
    var { init: cryptoInit } = require_crypto();
    var { KexInit } = require_kex();
    var { parseKey } = require_keyParser();
    var Protocol = require_Protocol();
    var { SFTP } = require_SFTP();
    var { writeUInt32BE } = require_utils2();
    var {
      Channel,
      MAX_WINDOW,
      PACKET_SIZE,
      windowAdjust,
      WINDOW_THRESHOLD
    } = require_Channel();
    var {
      ChannelManager,
      generateAlgorithmList,
      isWritable,
      onChannelOpenFailure,
      onCHANNEL_CLOSE
    } = require_utils3();
    var MAX_PENDING_AUTHS = 10;
    var AuthContext = class extends EventEmitter {
      constructor(protocol, username, service, method, cb) {
        super();
        this.username = this.user = username;
        this.service = service;
        this.method = method;
        this._initialResponse = false;
        this._finalResponse = false;
        this._multistep = false;
        this._cbfinal = (allowed, methodsLeft, isPartial) => {
          if (!this._finalResponse) {
            this._finalResponse = true;
            cb(this, allowed, methodsLeft, isPartial);
          }
        };
        this._protocol = protocol;
      }
      accept() {
        this._cleanup && this._cleanup();
        this._initialResponse = true;
        this._cbfinal(true);
      }
      reject(methodsLeft, isPartial) {
        this._cleanup && this._cleanup();
        this._initialResponse = true;
        this._cbfinal(false, methodsLeft, isPartial);
      }
    };
    var KeyboardAuthContext = class extends AuthContext {
      constructor(protocol, username, service, method, submethods, cb) {
        super(protocol, username, service, method, cb);
        this._multistep = true;
        this._cb = void 0;
        this._onInfoResponse = (responses) => {
          const callback = this._cb;
          if (callback) {
            this._cb = void 0;
            callback(responses);
          }
        };
        this.submethods = submethods;
        this.on("abort", () => {
          this._cb && this._cb(new Error("Authentication request aborted"));
        });
      }
      prompt(prompts, title, instructions, cb) {
        if (!Array.isArray(prompts))
          prompts = [prompts];
        if (typeof title === "function") {
          cb = title;
          title = instructions = void 0;
        } else if (typeof instructions === "function") {
          cb = instructions;
          instructions = void 0;
        } else if (typeof cb !== "function") {
          cb = void 0;
        }
        for (let i = 0; i < prompts.length; ++i) {
          if (typeof prompts[i] === "string") {
            prompts[i] = {
              prompt: prompts[i],
              echo: true
            };
          }
        }
        this._cb = cb;
        this._initialResponse = true;
        this._protocol.authInfoReq(title, instructions, prompts);
      }
    };
    var PKAuthContext = class extends AuthContext {
      constructor(protocol, username, service, method, pkInfo, cb) {
        super(protocol, username, service, method, cb);
        this.key = { algo: pkInfo.keyAlgo, data: pkInfo.key };
        this.signature = pkInfo.signature;
        this.blob = pkInfo.blob;
      }
      accept() {
        if (!this.signature) {
          this._initialResponse = true;
          this._protocol.authPKOK(this.key.algo, this.key.data);
        } else {
          AuthContext.prototype.accept.call(this);
        }
      }
    };
    var HostbasedAuthContext = class extends AuthContext {
      constructor(protocol, username, service, method, pkInfo, cb) {
        super(protocol, username, service, method, cb);
        this.key = { algo: pkInfo.keyAlgo, data: pkInfo.key };
        this.signature = pkInfo.signature;
        this.blob = pkInfo.blob;
        this.localHostname = pkInfo.localHostname;
        this.localUsername = pkInfo.localUsername;
      }
    };
    var PwdAuthContext = class extends AuthContext {
      constructor(protocol, username, service, method, password, cb) {
        super(protocol, username, service, method, cb);
        this.password = password;
        this._changeCb = void 0;
      }
      requestChange(prompt, cb) {
        if (this._changeCb)
          throw new Error("Change request already in progress");
        if (typeof prompt !== "string")
          throw new Error("prompt argument must be a string");
        if (typeof cb !== "function")
          throw new Error("Callback argument must be a function");
        this._changeCb = cb;
        this._protocol.authPasswdChg(prompt);
      }
    };
    var Session = class extends EventEmitter {
      constructor(client, info, localChan) {
        super();
        this.type = "session";
        this.subtype = void 0;
        this.server = true;
        this._ending = false;
        this._channel = void 0;
        this._chanInfo = {
          type: "session",
          incoming: {
            id: localChan,
            window: MAX_WINDOW,
            packetSize: PACKET_SIZE,
            state: "open"
          },
          outgoing: {
            id: info.sender,
            window: info.window,
            packetSize: info.packetSize,
            state: "open"
          }
        };
      }
    };
    var Server = class extends EventEmitter {
      constructor(cfg, listener) {
        super();
        if (typeof cfg !== "object" || cfg === null)
          throw new Error("Missing configuration object");
        const hostKeys = /* @__PURE__ */ Object.create(null);
        const hostKeyAlgoOrder = [];
        const hostKeys_ = cfg.hostKeys;
        if (!Array.isArray(hostKeys_))
          throw new Error("hostKeys must be an array");
        const cfgAlgos = typeof cfg.algorithms === "object" && cfg.algorithms !== null ? cfg.algorithms : {};
        const hostKeyAlgos = generateAlgorithmList(cfgAlgos.serverHostKey, DEFAULT_SERVER_HOST_KEY, SUPPORTED_SERVER_HOST_KEY);
        for (let i = 0; i < hostKeys_.length; ++i) {
          let privateKey;
          if (Buffer.isBuffer(hostKeys_[i]) || typeof hostKeys_[i] === "string")
            privateKey = parseKey(hostKeys_[i]);
          else
            privateKey = parseKey(hostKeys_[i].key, hostKeys_[i].passphrase);
          if (privateKey instanceof Error)
            throw new Error(`Cannot parse privateKey: ${privateKey.message}`);
          if (Array.isArray(privateKey)) {
            privateKey = privateKey[0];
          }
          if (privateKey.getPrivatePEM() === null)
            throw new Error("privateKey value contains an invalid private key");
          if (hostKeyAlgoOrder.includes(privateKey.type))
            continue;
          if (privateKey.type === "ssh-rsa") {
            let sha1Pos = hostKeyAlgos.indexOf("ssh-rsa");
            const sha256Pos = hostKeyAlgos.indexOf("rsa-sha2-256");
            const sha512Pos = hostKeyAlgos.indexOf("rsa-sha2-512");
            if (sha1Pos === -1) {
              sha1Pos = Infinity;
            }
            [sha1Pos, sha256Pos, sha512Pos].sort(compareNumbers).forEach((pos) => {
              if (pos === -1)
                return;
              let type;
              switch (pos) {
                case sha1Pos:
                  type = "ssh-rsa";
                  break;
                case sha256Pos:
                  type = "rsa-sha2-256";
                  break;
                case sha512Pos:
                  type = "rsa-sha2-512";
                  break;
                default:
                  return;
              }
              hostKeys[type] = privateKey;
              hostKeyAlgoOrder.push(type);
            });
          } else {
            hostKeys[privateKey.type] = privateKey;
            hostKeyAlgoOrder.push(privateKey.type);
          }
        }
        const algorithms = {
          kex: generateAlgorithmList(cfgAlgos.kex, DEFAULT_KEX, SUPPORTED_KEX),
          serverHostKey: hostKeyAlgoOrder,
          cs: {
            cipher: generateAlgorithmList(cfgAlgos.cipher, DEFAULT_CIPHER, SUPPORTED_CIPHER),
            mac: generateAlgorithmList(cfgAlgos.hmac, DEFAULT_MAC, SUPPORTED_MAC),
            compress: generateAlgorithmList(cfgAlgos.compress, DEFAULT_COMPRESSION, SUPPORTED_COMPRESSION),
            lang: []
          },
          sc: void 0
        };
        algorithms.sc = algorithms.cs;
        if (typeof listener === "function")
          this.on("connection", listener);
        const origDebug = typeof cfg.debug === "function" ? cfg.debug : void 0;
        const ident = cfg.ident ? Buffer.from(cfg.ident) : void 0;
        const offer = new KexInit(algorithms);
        this._srv = new netServer((socket) => {
          if (this._connections >= this.maxConnections) {
            socket.destroy();
            return;
          }
          ++this._connections;
          socket.once("close", () => {
            --this._connections;
          });
          let debug;
          if (origDebug) {
            const debugPrefix = `[${process.hrtime().join(".")}] `;
            debug = (msg) => {
              origDebug(`${debugPrefix}${msg}`);
            };
          }
          new Client(socket, hostKeys, ident, offer, debug, this, cfg);
        }).on("error", (err) => {
          this.emit("error", err);
        }).on("listening", () => {
          this.emit("listening");
        }).on("close", () => {
          this.emit("close");
        });
        this._connections = 0;
        this.maxConnections = Infinity;
      }
      injectSocket(socket) {
        this._srv.emit("connection", socket);
      }
      listen(...args) {
        this._srv.listen(...args);
        return this;
      }
      address() {
        return this._srv.address();
      }
      getConnections(cb) {
        this._srv.getConnections(cb);
        return this;
      }
      close(cb) {
        this._srv.close(cb);
        return this;
      }
      ref() {
        this._srv.ref();
        return this;
      }
      unref() {
        this._srv.unref();
        return this;
      }
    };
    Server.KEEPALIVE_CLIENT_INTERVAL = 15e3;
    Server.KEEPALIVE_CLIENT_COUNT_MAX = 3;
    var Client = class extends EventEmitter {
      constructor(socket, hostKeys, ident, offer, debug, server, srvCfg) {
        super();
        let exchanges = 0;
        let acceptedAuthSvc = false;
        let pendingAuths = [];
        let authCtx;
        let kaTimer;
        let onPacket;
        const unsentGlobalRequestsReplies = [];
        this._sock = socket;
        this._chanMgr = new ChannelManager(this);
        this._debug = debug;
        this.noMoreSessions = false;
        this.authenticated = false;
        function onClientPreHeaderError(err) {
        }
        this.on("error", onClientPreHeaderError);
        const DEBUG_HANDLER = !debug ? void 0 : (p, display, msg) => {
          debug(`Debug output from client: ${JSON.stringify(msg)}`);
        };
        const kaIntvl = typeof srvCfg.keepaliveInterval === "number" && isFinite(srvCfg.keepaliveInterval) && srvCfg.keepaliveInterval > 0 ? srvCfg.keepaliveInterval : typeof Server.KEEPALIVE_CLIENT_INTERVAL === "number" && isFinite(Server.KEEPALIVE_CLIENT_INTERVAL) && Server.KEEPALIVE_CLIENT_INTERVAL > 0 ? Server.KEEPALIVE_CLIENT_INTERVAL : -1;
        const kaCountMax = typeof srvCfg.keepaliveCountMax === "number" && isFinite(srvCfg.keepaliveCountMax) && srvCfg.keepaliveCountMax >= 0 ? srvCfg.keepaliveCountMax : typeof Server.KEEPALIVE_CLIENT_COUNT_MAX === "number" && isFinite(Server.KEEPALIVE_CLIENT_COUNT_MAX) && Server.KEEPALIVE_CLIENT_COUNT_MAX >= 0 ? Server.KEEPALIVE_CLIENT_COUNT_MAX : -1;
        let kaCurCount = 0;
        if (kaIntvl !== -1 && kaCountMax !== -1) {
          this.once("ready", () => {
            const onClose = () => {
              clearInterval(kaTimer);
            };
            this.on("close", onClose).on("end", onClose);
            kaTimer = setInterval(() => {
              if (++kaCurCount > kaCountMax) {
                clearInterval(kaTimer);
                const err = new Error("Keepalive timeout");
                err.level = "client-timeout";
                this.emit("error", err);
                this.end();
              } else {
                proto.ping();
              }
            }, kaIntvl);
          });
          onPacket = () => {
            kaTimer && kaTimer.refresh();
            kaCurCount = 0;
          };
        }
        const proto = this._protocol = new Protocol({
          server: true,
          hostKeys,
          ident,
          offer,
          onPacket,
          greeting: srvCfg.greeting,
          banner: srvCfg.banner,
          onWrite: (data) => {
            if (isWritable(socket))
              socket.write(data);
          },
          onError: (err) => {
            if (!proto._destruct)
              socket.removeAllListeners("data");
            this.emit("error", err);
            try {
              socket.end();
            } catch {
            }
          },
          onHeader: (header) => {
            this.removeListener("error", onClientPreHeaderError);
            const info = {
              ip: socket.remoteAddress,
              family: socket.remoteFamily,
              port: socket.remotePort,
              header
            };
            if (!server.emit("connection", this, info)) {
              proto.disconnect(DISCONNECT_REASON.BY_APPLICATION);
              socket.end();
              return;
            }
            if (header.greeting)
              this.emit("greeting", header.greeting);
          },
          onHandshakeComplete: (negotiated) => {
            if (++exchanges > 1)
              this.emit("rekey");
            this.emit("handshake", negotiated);
          },
          debug,
          messageHandlers: {
            DEBUG: DEBUG_HANDLER,
            DISCONNECT: (p, reason, desc) => {
              if (reason !== DISCONNECT_REASON.BY_APPLICATION) {
                if (!desc) {
                  desc = DISCONNECT_REASON_BY_VALUE[reason];
                  if (desc === void 0)
                    desc = `Unexpected disconnection reason: ${reason}`;
                }
                const err = new Error(desc);
                err.code = reason;
                this.emit("error", err);
              }
              socket.end();
            },
            CHANNEL_OPEN: (p, info) => {
              if (info.type === "session" && this.noMoreSessions || !this.authenticated) {
                const reasonCode = CHANNEL_OPEN_FAILURE.ADMINISTRATIVELY_PROHIBITED;
                return proto.channelOpenFail(info.sender, reasonCode);
              }
              let localChan = -1;
              let reason;
              let replied = false;
              let accept;
              const reject = () => {
                if (replied)
                  return;
                replied = true;
                if (reason === void 0) {
                  if (localChan === -1)
                    reason = CHANNEL_OPEN_FAILURE.RESOURCE_SHORTAGE;
                  else
                    reason = CHANNEL_OPEN_FAILURE.CONNECT_FAILED;
                }
                if (localChan !== -1)
                  this._chanMgr.remove(localChan);
                proto.channelOpenFail(info.sender, reason, "");
              };
              const reserveChannel = () => {
                localChan = this._chanMgr.add();
                if (localChan === -1) {
                  reason = CHANNEL_OPEN_FAILURE.RESOURCE_SHORTAGE;
                  if (debug) {
                    debug("Automatic rejection of incoming channel open: no channels available");
                  }
                }
                return localChan !== -1;
              };
              const data = info.data;
              switch (info.type) {
                case "session":
                  if (listenerCount(this, "session") && reserveChannel()) {
                    accept = () => {
                      if (replied)
                        return;
                      replied = true;
                      const instance = new Session(this, info, localChan);
                      this._chanMgr.update(localChan, instance);
                      proto.channelOpenConfirm(info.sender, localChan, MAX_WINDOW, PACKET_SIZE);
                      return instance;
                    };
                    this.emit("session", accept, reject);
                    return;
                  }
                  break;
                case "direct-tcpip":
                  if (listenerCount(this, "tcpip") && reserveChannel()) {
                    accept = () => {
                      if (replied)
                        return;
                      replied = true;
                      const chanInfo = {
                        type: void 0,
                        incoming: {
                          id: localChan,
                          window: MAX_WINDOW,
                          packetSize: PACKET_SIZE,
                          state: "open"
                        },
                        outgoing: {
                          id: info.sender,
                          window: info.window,
                          packetSize: info.packetSize,
                          state: "open"
                        }
                      };
                      const stream = new Channel(this, chanInfo, { server: true });
                      this._chanMgr.update(localChan, stream);
                      proto.channelOpenConfirm(info.sender, localChan, MAX_WINDOW, PACKET_SIZE);
                      return stream;
                    };
                    this.emit("tcpip", accept, reject, data);
                    return;
                  }
                  break;
                case "direct-streamlocal@openssh.com":
                  if (listenerCount(this, "openssh.streamlocal") && reserveChannel()) {
                    accept = () => {
                      if (replied)
                        return;
                      replied = true;
                      const chanInfo = {
                        type: void 0,
                        incoming: {
                          id: localChan,
                          window: MAX_WINDOW,
                          packetSize: PACKET_SIZE,
                          state: "open"
                        },
                        outgoing: {
                          id: info.sender,
                          window: info.window,
                          packetSize: info.packetSize,
                          state: "open"
                        }
                      };
                      const stream = new Channel(this, chanInfo, { server: true });
                      this._chanMgr.update(localChan, stream);
                      proto.channelOpenConfirm(info.sender, localChan, MAX_WINDOW, PACKET_SIZE);
                      return stream;
                    };
                    this.emit("openssh.streamlocal", accept, reject, data);
                    return;
                  }
                  break;
                default:
                  reason = CHANNEL_OPEN_FAILURE.UNKNOWN_CHANNEL_TYPE;
                  if (debug) {
                    debug(`Automatic rejection of unsupported incoming channel open type: ${info.type}`);
                  }
              }
              if (reason === void 0) {
                reason = CHANNEL_OPEN_FAILURE.ADMINISTRATIVELY_PROHIBITED;
                if (debug) {
                  debug(`Automatic rejection of unexpected incoming channel open for: ${info.type}`);
                }
              }
              reject();
            },
            CHANNEL_OPEN_CONFIRMATION: (p, info) => {
              const channel = this._chanMgr.get(info.recipient);
              if (typeof channel !== "function")
                return;
              const chanInfo = {
                type: channel.type,
                incoming: {
                  id: info.recipient,
                  window: MAX_WINDOW,
                  packetSize: PACKET_SIZE,
                  state: "open"
                },
                outgoing: {
                  id: info.sender,
                  window: info.window,
                  packetSize: info.packetSize,
                  state: "open"
                }
              };
              const instance = new Channel(this, chanInfo, { server: true });
              this._chanMgr.update(info.recipient, instance);
              channel(void 0, instance);
            },
            CHANNEL_OPEN_FAILURE: (p, recipient, reason, description) => {
              const channel = this._chanMgr.get(recipient);
              if (typeof channel !== "function")
                return;
              const info = { reason, description };
              onChannelOpenFailure(this, recipient, info, channel);
            },
            CHANNEL_DATA: (p, recipient, data) => {
              let channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.constructor === Session) {
                channel = channel._channel;
                if (!channel)
                  return;
              }
              if (channel.incoming.window === 0)
                return;
              channel.incoming.window -= data.length;
              if (channel.push(data) === false) {
                channel._waitChanDrain = true;
                return;
              }
              if (channel.incoming.window <= WINDOW_THRESHOLD)
                windowAdjust(channel);
            },
            CHANNEL_EXTENDED_DATA: (p, recipient, data, type) => {
            },
            CHANNEL_WINDOW_ADJUST: (p, recipient, amount) => {
              let channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.constructor === Session) {
                channel = channel._channel;
                if (!channel)
                  return;
              }
              channel.outgoing.window += amount;
              if (channel._waitWindow) {
                channel._waitWindow = false;
                if (channel._chunk) {
                  channel._write(channel._chunk, null, channel._chunkcb);
                } else if (channel._chunkcb) {
                  channel._chunkcb();
                } else if (channel._chunkErr) {
                  channel.stderr._write(channel._chunkErr, null, channel._chunkcbErr);
                } else if (channel._chunkcbErr) {
                  channel._chunkcbErr();
                }
              }
            },
            CHANNEL_SUCCESS: (p, recipient) => {
              let channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.constructor === Session) {
                channel = channel._channel;
                if (!channel)
                  return;
              }
              if (channel._callbacks.length)
                channel._callbacks.shift()(false);
            },
            CHANNEL_FAILURE: (p, recipient) => {
              let channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.constructor === Session) {
                channel = channel._channel;
                if (!channel)
                  return;
              }
              if (channel._callbacks.length)
                channel._callbacks.shift()(true);
            },
            CHANNEL_REQUEST: (p, recipient, type, wantReply, data) => {
              const session = this._chanMgr.get(recipient);
              if (typeof session !== "object" || session === null)
                return;
              let replied = false;
              let accept;
              let reject;
              if (session.constructor !== Session) {
                if (wantReply)
                  proto.channelFailure(session.outgoing.id);
                return;
              }
              if (wantReply) {
                if (type !== "shell" && type !== "exec" && type !== "subsystem") {
                  accept = () => {
                    if (replied || session._ending || session._channel)
                      return;
                    replied = true;
                    proto.channelSuccess(session._chanInfo.outgoing.id);
                  };
                }
                reject = () => {
                  if (replied || session._ending || session._channel)
                    return;
                  replied = true;
                  proto.channelFailure(session._chanInfo.outgoing.id);
                };
              }
              if (session._ending) {
                reject && reject();
                return;
              }
              switch (type) {
                case "env":
                  if (listenerCount(session, "env")) {
                    session.emit("env", accept, reject, {
                      key: data.name,
                      val: data.value
                    });
                    return;
                  }
                  break;
                case "pty-req":
                  if (listenerCount(session, "pty")) {
                    session.emit("pty", accept, reject, data);
                    return;
                  }
                  break;
                case "window-change":
                  if (listenerCount(session, "window-change"))
                    session.emit("window-change", accept, reject, data);
                  else
                    reject && reject();
                  break;
                case "x11-req":
                  if (listenerCount(session, "x11")) {
                    session.emit("x11", accept, reject, data);
                    return;
                  }
                  break;
                case "signal":
                  if (listenerCount(session, "signal")) {
                    session.emit("signal", accept, reject, {
                      name: data
                    });
                    return;
                  }
                  break;
                case "auth-agent-req@openssh.com":
                  if (listenerCount(session, "auth-agent")) {
                    session.emit("auth-agent", accept, reject);
                    return;
                  }
                  break;
                case "shell":
                  if (listenerCount(session, "shell")) {
                    accept = () => {
                      if (replied || session._ending || session._channel)
                        return;
                      replied = true;
                      if (wantReply)
                        proto.channelSuccess(session._chanInfo.outgoing.id);
                      const channel = new Channel(this, session._chanInfo, { server: true });
                      channel.subtype = session.subtype = type;
                      session._channel = channel;
                      return channel;
                    };
                    session.emit("shell", accept, reject);
                    return;
                  }
                  break;
                case "exec":
                  if (listenerCount(session, "exec")) {
                    accept = () => {
                      if (replied || session._ending || session._channel)
                        return;
                      replied = true;
                      if (wantReply)
                        proto.channelSuccess(session._chanInfo.outgoing.id);
                      const channel = new Channel(this, session._chanInfo, { server: true });
                      channel.subtype = session.subtype = type;
                      session._channel = channel;
                      return channel;
                    };
                    session.emit("exec", accept, reject, {
                      command: data
                    });
                    return;
                  }
                  break;
                case "subsystem": {
                  let useSFTP = data === "sftp";
                  accept = () => {
                    if (replied || session._ending || session._channel)
                      return;
                    replied = true;
                    if (wantReply)
                      proto.channelSuccess(session._chanInfo.outgoing.id);
                    let instance;
                    if (useSFTP) {
                      instance = new SFTP(this, session._chanInfo, {
                        server: true,
                        debug
                      });
                    } else {
                      instance = new Channel(this, session._chanInfo, { server: true });
                      instance.subtype = session.subtype = `${type}:${data}`;
                    }
                    session._channel = instance;
                    return instance;
                  };
                  if (data === "sftp") {
                    if (listenerCount(session, "sftp")) {
                      session.emit("sftp", accept, reject);
                      return;
                    }
                    useSFTP = false;
                  }
                  if (listenerCount(session, "subsystem")) {
                    session.emit("subsystem", accept, reject, {
                      name: data
                    });
                    return;
                  }
                  break;
                }
              }
              debug && debug(`Automatic rejection of incoming channel request: ${type}`);
              reject && reject();
            },
            CHANNEL_EOF: (p, recipient) => {
              let channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.constructor === Session) {
                if (!channel._ending) {
                  channel._ending = true;
                  channel.emit("eof");
                  channel.emit("end");
                }
                channel = channel._channel;
                if (!channel)
                  return;
              }
              if (channel.incoming.state !== "open")
                return;
              channel.incoming.state = "eof";
              if (channel.readable)
                channel.push(null);
            },
            CHANNEL_CLOSE: (p, recipient) => {
              let channel = this._chanMgr.get(recipient);
              if (typeof channel !== "object" || channel === null)
                return;
              if (channel.constructor === Session) {
                channel._ending = true;
                channel.emit("close");
                channel = channel._channel;
                if (!channel)
                  return;
              }
              onCHANNEL_CLOSE(this, recipient, channel);
            },
            SERVICE_REQUEST: (p, service) => {
              if (exchanges === 0 || acceptedAuthSvc || this.authenticated || service !== "ssh-userauth") {
                proto.disconnect(DISCONNECT_REASON.SERVICE_NOT_AVAILABLE);
                socket.end();
                return;
              }
              acceptedAuthSvc = true;
              proto.serviceAccept(service);
            },
            USERAUTH_REQUEST: (p, username, service, method, methodData) => {
              if (exchanges === 0 || this.authenticated || authCtx && (authCtx.username !== username || authCtx.service !== service) || method !== "password" && method !== "publickey" && method !== "hostbased" && method !== "keyboard-interactive" && method !== "none" || pendingAuths.length === MAX_PENDING_AUTHS) {
                proto.disconnect(DISCONNECT_REASON.PROTOCOL_ERROR);
                socket.end();
                return;
              } else if (service !== "ssh-connection") {
                proto.disconnect(DISCONNECT_REASON.SERVICE_NOT_AVAILABLE);
                socket.end();
                return;
              }
              let ctx;
              switch (method) {
                case "keyboard-interactive":
                  ctx = new KeyboardAuthContext(proto, username, service, method, methodData, onAuthDecide);
                  break;
                case "publickey":
                  ctx = new PKAuthContext(proto, username, service, method, methodData, onAuthDecide);
                  break;
                case "hostbased":
                  ctx = new HostbasedAuthContext(proto, username, service, method, methodData, onAuthDecide);
                  break;
                case "password":
                  if (authCtx && authCtx instanceof PwdAuthContext && authCtx._changeCb) {
                    const cb = authCtx._changeCb;
                    authCtx._changeCb = void 0;
                    cb(methodData.newPassword);
                    return;
                  }
                  ctx = new PwdAuthContext(proto, username, service, method, methodData, onAuthDecide);
                  break;
                case "none":
                  ctx = new AuthContext(proto, username, service, method, onAuthDecide);
                  break;
              }
              if (authCtx) {
                if (!authCtx._initialResponse) {
                  return pendingAuths.push(ctx);
                } else if (authCtx._multistep && !authCtx._finalResponse) {
                  authCtx._cleanup && authCtx._cleanup();
                  authCtx.emit("abort");
                }
              }
              authCtx = ctx;
              if (listenerCount(this, "authentication"))
                this.emit("authentication", authCtx);
              else
                authCtx.reject();
            },
            USERAUTH_INFO_RESPONSE: (p, responses) => {
              if (authCtx && authCtx instanceof KeyboardAuthContext)
                authCtx._onInfoResponse(responses);
            },
            GLOBAL_REQUEST: (p, name, wantReply, data) => {
              const reply = {
                type: null,
                buf: null
              };
              function setReply(type, buf) {
                reply.type = type;
                reply.buf = buf;
                sendReplies();
              }
              if (wantReply)
                unsentGlobalRequestsReplies.push(reply);
              if ((name === "tcpip-forward" || name === "cancel-tcpip-forward" || name === "no-more-sessions@openssh.com" || name === "streamlocal-forward@openssh.com" || name === "cancel-streamlocal-forward@openssh.com") && listenerCount(this, "request") && this.authenticated) {
                let accept;
                let reject;
                if (wantReply) {
                  let replied = false;
                  accept = (chosenPort) => {
                    if (replied)
                      return;
                    replied = true;
                    let bufPort;
                    if (name === "tcpip-forward" && data.bindPort === 0 && typeof chosenPort === "number") {
                      bufPort = Buffer.allocUnsafe(4);
                      writeUInt32BE(bufPort, chosenPort, 0);
                    }
                    setReply("SUCCESS", bufPort);
                  };
                  reject = () => {
                    if (replied)
                      return;
                    replied = true;
                    setReply("FAILURE");
                  };
                }
                if (name === "no-more-sessions@openssh.com") {
                  this.noMoreSessions = true;
                  accept && accept();
                  return;
                }
                this.emit("request", accept, reject, name, data);
              } else if (wantReply) {
                setReply("FAILURE");
              }
            }
          }
        });
        socket.pause();
        cryptoInit.then(() => {
          proto.start();
          socket.on("data", (data) => {
            try {
              proto.parse(data, 0, data.length);
            } catch (ex) {
              this.emit("error", ex);
              try {
                if (isWritable(socket))
                  socket.end();
              } catch {
              }
            }
          });
          socket.resume();
        }).catch((err) => {
          this.emit("error", err);
          try {
            if (isWritable(socket))
              socket.end();
          } catch {
          }
        });
        socket.on("error", (err) => {
          err.level = "socket";
          this.emit("error", err);
        }).once("end", () => {
          debug && debug("Socket ended");
          proto.cleanup();
          this.emit("end");
        }).once("close", () => {
          debug && debug("Socket closed");
          proto.cleanup();
          this.emit("close");
          const err = new Error("No response from server");
          this._chanMgr.cleanup(err);
        });
        const onAuthDecide = (ctx, allowed, methodsLeft, isPartial) => {
          if (authCtx === ctx && !this.authenticated) {
            if (allowed) {
              authCtx = void 0;
              this.authenticated = true;
              proto.authSuccess();
              pendingAuths = [];
              this.emit("ready");
            } else {
              proto.authFailure(methodsLeft, isPartial);
              if (pendingAuths.length) {
                authCtx = pendingAuths.pop();
                if (listenerCount(this, "authentication"))
                  this.emit("authentication", authCtx);
                else
                  authCtx.reject();
              }
            }
          }
        };
        function sendReplies() {
          while (unsentGlobalRequestsReplies.length > 0 && unsentGlobalRequestsReplies[0].type) {
            const reply = unsentGlobalRequestsReplies.shift();
            if (reply.type === "SUCCESS")
              proto.requestSuccess(reply.buf);
            if (reply.type === "FAILURE")
              proto.requestFailure();
          }
        }
      }
      end() {
        if (this._sock && isWritable(this._sock)) {
          this._protocol.disconnect(DISCONNECT_REASON.BY_APPLICATION);
          this._sock.end();
        }
        return this;
      }
      x11(originAddr, originPort, cb) {
        const opts = { originAddr, originPort };
        openChannel(this, "x11", opts, cb);
        return this;
      }
      forwardOut(boundAddr, boundPort, remoteAddr, remotePort, cb) {
        const opts = { boundAddr, boundPort, remoteAddr, remotePort };
        openChannel(this, "forwarded-tcpip", opts, cb);
        return this;
      }
      openssh_forwardOutStreamLocal(socketPath, cb) {
        const opts = { socketPath };
        openChannel(this, "forwarded-streamlocal@openssh.com", opts, cb);
        return this;
      }
      rekey(cb) {
        let error;
        try {
          this._protocol.rekey();
        } catch (ex) {
          error = ex;
        }
        if (typeof cb === "function") {
          if (error)
            process.nextTick(cb, error);
          else
            this.once("rekey", cb);
        }
      }
    };
    function openChannel(self2, type, opts, cb) {
      const initWindow = MAX_WINDOW;
      const maxPacket = PACKET_SIZE;
      if (typeof opts === "function") {
        cb = opts;
        opts = {};
      }
      const wrapper = (err, stream) => {
        cb(err, stream);
      };
      wrapper.type = type;
      const localChan = self2._chanMgr.add(wrapper);
      if (localChan === -1) {
        cb(new Error("No free channels available"));
        return;
      }
      switch (type) {
        case "forwarded-tcpip":
          self2._protocol.forwardedTcpip(localChan, initWindow, maxPacket, opts);
          break;
        case "x11":
          self2._protocol.x11(localChan, initWindow, maxPacket, opts);
          break;
        case "forwarded-streamlocal@openssh.com":
          self2._protocol.openssh_forwardedStreamLocal(localChan, initWindow, maxPacket, opts);
          break;
        default:
          throw new Error(`Unsupported channel type: ${type}`);
      }
    }
    function compareNumbers(a, b) {
      return a - b;
    }
    module2.exports = Server;
    module2.exports.IncomingClient = Client;
  }
});

// node_modules/ssh2/lib/index.js
var require_lib3 = __commonJS({
  "node_modules/ssh2/lib/index.js"(exports, module2) {
    "use strict";
    var {
      AgentProtocol,
      BaseAgent,
      createAgent,
      CygwinAgent,
      OpenSSHAgent,
      PageantAgent
    } = require_agent();
    var {
      SSHTTPAgent: HTTPAgent,
      SSHTTPSAgent: HTTPSAgent
    } = require_http_agents();
    var { parseKey } = require_keyParser();
    var {
      flagsToString,
      OPEN_MODE,
      STATUS_CODE,
      stringToFlags
    } = require_SFTP();
    module2.exports = {
      AgentProtocol,
      BaseAgent,
      createAgent,
      Client: require_client(),
      CygwinAgent,
      HTTPAgent,
      HTTPSAgent,
      OpenSSHAgent,
      PageantAgent,
      Server: require_server(),
      utils: {
        parseKey,
        sftp: {
          flagsToString,
          OPEN_MODE,
          STATUS_CODE,
          stringToFlags
        }
      }
    };
  }
});

// node_modules/docker-modem/lib/ssh.js
var require_ssh = __commonJS({
  "node_modules/docker-modem/lib/ssh.js"(exports, module2) {
    var Client = require_lib3().Client;
    var http = require("http");
    module2.exports = function(opt) {
      var conn = new Client();
      var agent = new http.Agent();
      agent.createConnection = function(options, fn) {
        conn.once("ready", function() {
          conn.exec("docker system dial-stdio", function(err, stream) {
            if (err) {
              conn.end();
              agent.destroy();
              return;
            }
            fn(null, stream);
            stream.once("close", () => {
              conn.end();
              agent.destroy();
            });
          });
        }).connect(opt);
        conn.once("end", () => agent.destroy());
      };
      return agent;
    };
  }
});

// node_modules/readable-stream/lib/internal/streams/stream.js
var require_stream = __commonJS({
  "node_modules/readable-stream/lib/internal/streams/stream.js"(exports, module2) {
    module2.exports = require("stream");
  }
});

// node_modules/readable-stream/lib/internal/streams/buffer_list.js
var require_buffer_list = __commonJS({
  "node_modules/readable-stream/lib/internal/streams/buffer_list.js"(exports, module2) {
    "use strict";
    function ownKeys(object, enumerableOnly) {
      var keys = Object.keys(object);
      if (Object.getOwnPropertySymbols) {
        var symbols = Object.getOwnPropertySymbols(object);
        if (enumerableOnly)
          symbols = symbols.filter(function(sym) {
            return Object.getOwnPropertyDescriptor(object, sym).enumerable;
          });
        keys.push.apply(keys, symbols);
      }
      return keys;
    }
    function _objectSpread(target) {
      for (var i = 1; i < arguments.length; i++) {
        var source = arguments[i] != null ? arguments[i] : {};
        if (i % 2) {
          ownKeys(Object(source), true).forEach(function(key) {
            _defineProperty(target, key, source[key]);
          });
        } else if (Object.getOwnPropertyDescriptors) {
          Object.defineProperties(target, Object.getOwnPropertyDescriptors(source));
        } else {
          ownKeys(Object(source)).forEach(function(key) {
            Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key));
          });
        }
      }
      return target;
    }
    function _defineProperty(obj, key, value) {
      if (key in obj) {
        Object.defineProperty(obj, key, { value, enumerable: true, configurable: true, writable: true });
      } else {
        obj[key] = value;
      }
      return obj;
    }
    function _classCallCheck(instance, Constructor) {
      if (!(instance instanceof Constructor)) {
        throw new TypeError("Cannot call a class as a function");
      }
    }
    function _defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor)
          descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }
    function _createClass(Constructor, protoProps, staticProps) {
      if (protoProps)
        _defineProperties(Constructor.prototype, protoProps);
      if (staticProps)
        _defineProperties(Constructor, staticProps);
      return Constructor;
    }
    var _require = require("buffer");
    var Buffer2 = _require.Buffer;
    var _require2 = require("util");
    var inspect = _require2.inspect;
    var custom = inspect && inspect.custom || "inspect";
    function copyBuffer(src, target, offset) {
      Buffer2.prototype.copy.call(src, target, offset);
    }
    module2.exports = /* @__PURE__ */ function() {
      function BufferList() {
        _classCallCheck(this, BufferList);
        this.head = null;
        this.tail = null;
        this.length = 0;
      }
      _createClass(BufferList, [{
        key: "push",
        value: function push(v) {
          var entry = {
            data: v,
            next: null
          };
          if (this.length > 0)
            this.tail.next = entry;
          else
            this.head = entry;
          this.tail = entry;
          ++this.length;
        }
      }, {
        key: "unshift",
        value: function unshift(v) {
          var entry = {
            data: v,
            next: this.head
          };
          if (this.length === 0)
            this.tail = entry;
          this.head = entry;
          ++this.length;
        }
      }, {
        key: "shift",
        value: function shift() {
          if (this.length === 0)
            return;
          var ret = this.head.data;
          if (this.length === 1)
            this.head = this.tail = null;
          else
            this.head = this.head.next;
          --this.length;
          return ret;
        }
      }, {
        key: "clear",
        value: function clear() {
          this.head = this.tail = null;
          this.length = 0;
        }
      }, {
        key: "join",
        value: function join(s) {
          if (this.length === 0)
            return "";
          var p = this.head;
          var ret = "" + p.data;
          while (p = p.next) {
            ret += s + p.data;
          }
          return ret;
        }
      }, {
        key: "concat",
        value: function concat(n) {
          if (this.length === 0)
            return Buffer2.alloc(0);
          var ret = Buffer2.allocUnsafe(n >>> 0);
          var p = this.head;
          var i = 0;
          while (p) {
            copyBuffer(p.data, ret, i);
            i += p.data.length;
            p = p.next;
          }
          return ret;
        }
      }, {
        key: "consume",
        value: function consume(n, hasStrings) {
          var ret;
          if (n < this.head.data.length) {
            ret = this.head.data.slice(0, n);
            this.head.data = this.head.data.slice(n);
          } else if (n === this.head.data.length) {
            ret = this.shift();
          } else {
            ret = hasStrings ? this._getString(n) : this._getBuffer(n);
          }
          return ret;
        }
      }, {
        key: "first",
        value: function first() {
          return this.head.data;
        }
      }, {
        key: "_getString",
        value: function _getString(n) {
          var p = this.head;
          var c = 1;
          var ret = p.data;
          n -= ret.length;
          while (p = p.next) {
            var str = p.data;
            var nb = n > str.length ? str.length : n;
            if (nb === str.length)
              ret += str;
            else
              ret += str.slice(0, n);
            n -= nb;
            if (n === 0) {
              if (nb === str.length) {
                ++c;
                if (p.next)
                  this.head = p.next;
                else
                  this.head = this.tail = null;
              } else {
                this.head = p;
                p.data = str.slice(nb);
              }
              break;
            }
            ++c;
          }
          this.length -= c;
          return ret;
        }
      }, {
        key: "_getBuffer",
        value: function _getBuffer(n) {
          var ret = Buffer2.allocUnsafe(n);
          var p = this.head;
          var c = 1;
          p.data.copy(ret);
          n -= p.data.length;
          while (p = p.next) {
            var buf = p.data;
            var nb = n > buf.length ? buf.length : n;
            buf.copy(ret, ret.length - n, 0, nb);
            n -= nb;
            if (n === 0) {
              if (nb === buf.length) {
                ++c;
                if (p.next)
                  this.head = p.next;
                else
                  this.head = this.tail = null;
              } else {
                this.head = p;
                p.data = buf.slice(nb);
              }
              break;
            }
            ++c;
          }
          this.length -= c;
          return ret;
        }
      }, {
        key: custom,
        value: function value(_, options) {
          return inspect(this, _objectSpread({}, options, {
            depth: 0,
            customInspect: false
          }));
        }
      }]);
      return BufferList;
    }();
  }
});

// node_modules/readable-stream/lib/internal/streams/destroy.js
var require_destroy = __commonJS({
  "node_modules/readable-stream/lib/internal/streams/destroy.js"(exports, module2) {
    "use strict";
    function destroy2(err, cb) {
      var _this = this;
      var readableDestroyed = this._readableState && this._readableState.destroyed;
      var writableDestroyed = this._writableState && this._writableState.destroyed;
      if (readableDestroyed || writableDestroyed) {
        if (cb) {
          cb(err);
        } else if (err) {
          if (!this._writableState) {
            process.nextTick(emitErrorNT, this, err);
          } else if (!this._writableState.errorEmitted) {
            this._writableState.errorEmitted = true;
            process.nextTick(emitErrorNT, this, err);
          }
        }
        return this;
      }
      if (this._readableState) {
        this._readableState.destroyed = true;
      }
      if (this._writableState) {
        this._writableState.destroyed = true;
      }
      this._destroy(err || null, function(err2) {
        if (!cb && err2) {
          if (!_this._writableState) {
            process.nextTick(emitErrorAndCloseNT, _this, err2);
          } else if (!_this._writableState.errorEmitted) {
            _this._writableState.errorEmitted = true;
            process.nextTick(emitErrorAndCloseNT, _this, err2);
          } else {
            process.nextTick(emitCloseNT, _this);
          }
        } else if (cb) {
          process.nextTick(emitCloseNT, _this);
          cb(err2);
        } else {
          process.nextTick(emitCloseNT, _this);
        }
      });
      return this;
    }
    function emitErrorAndCloseNT(self2, err) {
      emitErrorNT(self2, err);
      emitCloseNT(self2);
    }
    function emitCloseNT(self2) {
      if (self2._writableState && !self2._writableState.emitClose)
        return;
      if (self2._readableState && !self2._readableState.emitClose)
        return;
      self2.emit("close");
    }
    function undestroy() {
      if (this._readableState) {
        this._readableState.destroyed = false;
        this._readableState.reading = false;
        this._readableState.ended = false;
        this._readableState.endEmitted = false;
      }
      if (this._writableState) {
        this._writableState.destroyed = false;
        this._writableState.ended = false;
        this._writableState.ending = false;
        this._writableState.finalCalled = false;
        this._writableState.prefinished = false;
        this._writableState.finished = false;
        this._writableState.errorEmitted = false;
      }
    }
    function emitErrorNT(self2, err) {
      self2.emit("error", err);
    }
    function errorOrDestroy(stream, err) {
      var rState = stream._readableState;
      var wState = stream._writableState;
      if (rState && rState.autoDestroy || wState && wState.autoDestroy)
        stream.destroy(err);
      else
        stream.emit("error", err);
    }
    module2.exports = {
      destroy: destroy2,
      undestroy,
      errorOrDestroy
    };
  }
});

// node_modules/readable-stream/errors.js
var require_errors2 = __commonJS({
  "node_modules/readable-stream/errors.js"(exports, module2) {
    "use strict";
    var codes = {};
    function createErrorType(code, message, Base) {
      if (!Base) {
        Base = Error;
      }
      function getMessage(arg1, arg2, arg3) {
        if (typeof message === "string") {
          return message;
        } else {
          return message(arg1, arg2, arg3);
        }
      }
      class NodeError extends Base {
        constructor(arg1, arg2, arg3) {
          super(getMessage(arg1, arg2, arg3));
        }
      }
      NodeError.prototype.name = Base.name;
      NodeError.prototype.code = code;
      codes[code] = NodeError;
    }
    function oneOf(expected, thing) {
      if (Array.isArray(expected)) {
        const len = expected.length;
        expected = expected.map((i) => String(i));
        if (len > 2) {
          return `one of ${thing} ${expected.slice(0, len - 1).join(", ")}, or ` + expected[len - 1];
        } else if (len === 2) {
          return `one of ${thing} ${expected[0]} or ${expected[1]}`;
        } else {
          return `of ${thing} ${expected[0]}`;
        }
      } else {
        return `of ${thing} ${String(expected)}`;
      }
    }
    function startsWith(str, search, pos) {
      return str.substr(!pos || pos < 0 ? 0 : +pos, search.length) === search;
    }
    function endsWith(str, search, this_len) {
      if (this_len === void 0 || this_len > str.length) {
        this_len = str.length;
      }
      return str.substring(this_len - search.length, this_len) === search;
    }
    function includes(str, search, start) {
      if (typeof start !== "number") {
        start = 0;
      }
      if (start + search.length > str.length) {
        return false;
      } else {
        return str.indexOf(search, start) !== -1;
      }
    }
    createErrorType("ERR_INVALID_OPT_VALUE", function(name, value) {
      return 'The value "' + value + '" is invalid for option "' + name + '"';
    }, TypeError);
    createErrorType("ERR_INVALID_ARG_TYPE", function(name, expected, actual) {
      let determiner;
      if (typeof expected === "string" && startsWith(expected, "not ")) {
        determiner = "must not be";
        expected = expected.replace(/^not /, "");
      } else {
        determiner = "must be";
      }
      let msg;
      if (endsWith(name, " argument")) {
        msg = `The ${name} ${determiner} ${oneOf(expected, "type")}`;
      } else {
        const type = includes(name, ".") ? "property" : "argument";
        msg = `The "${name}" ${type} ${determiner} ${oneOf(expected, "type")}`;
      }
      msg += `. Received type ${typeof actual}`;
      return msg;
    }, TypeError);
    createErrorType("ERR_STREAM_PUSH_AFTER_EOF", "stream.push() after EOF");
    createErrorType("ERR_METHOD_NOT_IMPLEMENTED", function(name) {
      return "The " + name + " method is not implemented";
    });
    createErrorType("ERR_STREAM_PREMATURE_CLOSE", "Premature close");
    createErrorType("ERR_STREAM_DESTROYED", function(name) {
      return "Cannot call " + name + " after a stream was destroyed";
    });
    createErrorType("ERR_MULTIPLE_CALLBACK", "Callback called multiple times");
    createErrorType("ERR_STREAM_CANNOT_PIPE", "Cannot pipe, not readable");
    createErrorType("ERR_STREAM_WRITE_AFTER_END", "write after end");
    createErrorType("ERR_STREAM_NULL_VALUES", "May not write null values to stream", TypeError);
    createErrorType("ERR_UNKNOWN_ENCODING", function(arg) {
      return "Unknown encoding: " + arg;
    }, TypeError);
    createErrorType("ERR_STREAM_UNSHIFT_AFTER_END_EVENT", "stream.unshift() after end event");
    module2.exports.codes = codes;
  }
});

// node_modules/readable-stream/lib/internal/streams/state.js
var require_state = __commonJS({
  "node_modules/readable-stream/lib/internal/streams/state.js"(exports, module2) {
    "use strict";
    var ERR_INVALID_OPT_VALUE = require_errors2().codes.ERR_INVALID_OPT_VALUE;
    function highWaterMarkFrom(options, isDuplex, duplexKey) {
      return options.highWaterMark != null ? options.highWaterMark : isDuplex ? options[duplexKey] : null;
    }
    function getHighWaterMark(state, options, duplexKey, isDuplex) {
      var hwm = highWaterMarkFrom(options, isDuplex, duplexKey);
      if (hwm != null) {
        if (!(isFinite(hwm) && Math.floor(hwm) === hwm) || hwm < 0) {
          var name = isDuplex ? duplexKey : "highWaterMark";
          throw new ERR_INVALID_OPT_VALUE(name, hwm);
        }
        return Math.floor(hwm);
      }
      return state.objectMode ? 16 : 16 * 1024;
    }
    module2.exports = {
      getHighWaterMark
    };
  }
});

// node_modules/inherits/inherits_browser.js
var require_inherits_browser = __commonJS({
  "node_modules/inherits/inherits_browser.js"(exports, module2) {
    if (typeof Object.create === "function") {
      module2.exports = function inherits(ctor, superCtor) {
        if (superCtor) {
          ctor.super_ = superCtor;
          ctor.prototype = Object.create(superCtor.prototype, {
            constructor: {
              value: ctor,
              enumerable: false,
              writable: true,
              configurable: true
            }
          });
        }
      };
    } else {
      module2.exports = function inherits(ctor, superCtor) {
        if (superCtor) {
          ctor.super_ = superCtor;
          var TempCtor = function() {
          };
          TempCtor.prototype = superCtor.prototype;
          ctor.prototype = new TempCtor();
          ctor.prototype.constructor = ctor;
        }
      };
    }
  }
});

// node_modules/inherits/inherits.js
var require_inherits = __commonJS({
  "node_modules/inherits/inherits.js"(exports, module2) {
    try {
      util = require("util");
      if (typeof util.inherits !== "function")
        throw "";
      module2.exports = util.inherits;
    } catch (e) {
      module2.exports = require_inherits_browser();
    }
    var util;
  }
});

// node_modules/util-deprecate/node.js
var require_node = __commonJS({
  "node_modules/util-deprecate/node.js"(exports, module2) {
    module2.exports = require("util").deprecate;
  }
});

// node_modules/readable-stream/lib/_stream_writable.js
var require_stream_writable = __commonJS({
  "node_modules/readable-stream/lib/_stream_writable.js"(exports, module2) {
    "use strict";
    module2.exports = Writable;
    function CorkedRequest(state) {
      var _this = this;
      this.next = null;
      this.entry = null;
      this.finish = function() {
        onCorkedFinish(_this, state);
      };
    }
    var Duplex;
    Writable.WritableState = WritableState;
    var internalUtil = {
      deprecate: require_node()
    };
    var Stream = require_stream();
    var Buffer2 = require("buffer").Buffer;
    var OurUint8Array = global.Uint8Array || function() {
    };
    function _uint8ArrayToBuffer(chunk) {
      return Buffer2.from(chunk);
    }
    function _isUint8Array(obj) {
      return Buffer2.isBuffer(obj) || obj instanceof OurUint8Array;
    }
    var destroyImpl = require_destroy();
    var _require = require_state();
    var getHighWaterMark = _require.getHighWaterMark;
    var _require$codes = require_errors2().codes;
    var ERR_INVALID_ARG_TYPE = _require$codes.ERR_INVALID_ARG_TYPE;
    var ERR_METHOD_NOT_IMPLEMENTED = _require$codes.ERR_METHOD_NOT_IMPLEMENTED;
    var ERR_MULTIPLE_CALLBACK = _require$codes.ERR_MULTIPLE_CALLBACK;
    var ERR_STREAM_CANNOT_PIPE = _require$codes.ERR_STREAM_CANNOT_PIPE;
    var ERR_STREAM_DESTROYED = _require$codes.ERR_STREAM_DESTROYED;
    var ERR_STREAM_NULL_VALUES = _require$codes.ERR_STREAM_NULL_VALUES;
    var ERR_STREAM_WRITE_AFTER_END = _require$codes.ERR_STREAM_WRITE_AFTER_END;
    var ERR_UNKNOWN_ENCODING = _require$codes.ERR_UNKNOWN_ENCODING;
    var errorOrDestroy = destroyImpl.errorOrDestroy;
    require_inherits()(Writable, Stream);
    function nop() {
    }
    function WritableState(options, stream, isDuplex) {
      Duplex = Duplex || require_stream_duplex();
      options = options || {};
      if (typeof isDuplex !== "boolean")
        isDuplex = stream instanceof Duplex;
      this.objectMode = !!options.objectMode;
      if (isDuplex)
        this.objectMode = this.objectMode || !!options.writableObjectMode;
      this.highWaterMark = getHighWaterMark(this, options, "writableHighWaterMark", isDuplex);
      this.finalCalled = false;
      this.needDrain = false;
      this.ending = false;
      this.ended = false;
      this.finished = false;
      this.destroyed = false;
      var noDecode = options.decodeStrings === false;
      this.decodeStrings = !noDecode;
      this.defaultEncoding = options.defaultEncoding || "utf8";
      this.length = 0;
      this.writing = false;
      this.corked = 0;
      this.sync = true;
      this.bufferProcessing = false;
      this.onwrite = function(er) {
        onwrite(stream, er);
      };
      this.writecb = null;
      this.writelen = 0;
      this.bufferedRequest = null;
      this.lastBufferedRequest = null;
      this.pendingcb = 0;
      this.prefinished = false;
      this.errorEmitted = false;
      this.emitClose = options.emitClose !== false;
      this.autoDestroy = !!options.autoDestroy;
      this.bufferedRequestCount = 0;
      this.corkedRequestsFree = new CorkedRequest(this);
    }
    WritableState.prototype.getBuffer = function getBuffer() {
      var current = this.bufferedRequest;
      var out = [];
      while (current) {
        out.push(current);
        current = current.next;
      }
      return out;
    };
    (function() {
      try {
        Object.defineProperty(WritableState.prototype, "buffer", {
          get: internalUtil.deprecate(function writableStateBufferGetter() {
            return this.getBuffer();
          }, "_writableState.buffer is deprecated. Use _writableState.getBuffer instead.", "DEP0003")
        });
      } catch (_) {
      }
    })();
    var realHasInstance;
    if (typeof Symbol === "function" && Symbol.hasInstance && typeof Function.prototype[Symbol.hasInstance] === "function") {
      realHasInstance = Function.prototype[Symbol.hasInstance];
      Object.defineProperty(Writable, Symbol.hasInstance, {
        value: function value(object) {
          if (realHasInstance.call(this, object))
            return true;
          if (this !== Writable)
            return false;
          return object && object._writableState instanceof WritableState;
        }
      });
    } else {
      realHasInstance = function realHasInstance2(object) {
        return object instanceof this;
      };
    }
    function Writable(options) {
      Duplex = Duplex || require_stream_duplex();
      var isDuplex = this instanceof Duplex;
      if (!isDuplex && !realHasInstance.call(Writable, this))
        return new Writable(options);
      this._writableState = new WritableState(options, this, isDuplex);
      this.writable = true;
      if (options) {
        if (typeof options.write === "function")
          this._write = options.write;
        if (typeof options.writev === "function")
          this._writev = options.writev;
        if (typeof options.destroy === "function")
          this._destroy = options.destroy;
        if (typeof options.final === "function")
          this._final = options.final;
      }
      Stream.call(this);
    }
    Writable.prototype.pipe = function() {
      errorOrDestroy(this, new ERR_STREAM_CANNOT_PIPE());
    };
    function writeAfterEnd(stream, cb) {
      var er = new ERR_STREAM_WRITE_AFTER_END();
      errorOrDestroy(stream, er);
      process.nextTick(cb, er);
    }
    function validChunk(stream, state, chunk, cb) {
      var er;
      if (chunk === null) {
        er = new ERR_STREAM_NULL_VALUES();
      } else if (typeof chunk !== "string" && !state.objectMode) {
        er = new ERR_INVALID_ARG_TYPE("chunk", ["string", "Buffer"], chunk);
      }
      if (er) {
        errorOrDestroy(stream, er);
        process.nextTick(cb, er);
        return false;
      }
      return true;
    }
    Writable.prototype.write = function(chunk, encoding, cb) {
      var state = this._writableState;
      var ret = false;
      var isBuf = !state.objectMode && _isUint8Array(chunk);
      if (isBuf && !Buffer2.isBuffer(chunk)) {
        chunk = _uint8ArrayToBuffer(chunk);
      }
      if (typeof encoding === "function") {
        cb = encoding;
        encoding = null;
      }
      if (isBuf)
        encoding = "buffer";
      else if (!encoding)
        encoding = state.defaultEncoding;
      if (typeof cb !== "function")
        cb = nop;
      if (state.ending)
        writeAfterEnd(this, cb);
      else if (isBuf || validChunk(this, state, chunk, cb)) {
        state.pendingcb++;
        ret = writeOrBuffer(this, state, isBuf, chunk, encoding, cb);
      }
      return ret;
    };
    Writable.prototype.cork = function() {
      this._writableState.corked++;
    };
    Writable.prototype.uncork = function() {
      var state = this._writableState;
      if (state.corked) {
        state.corked--;
        if (!state.writing && !state.corked && !state.bufferProcessing && state.bufferedRequest)
          clearBuffer(this, state);
      }
    };
    Writable.prototype.setDefaultEncoding = function setDefaultEncoding(encoding) {
      if (typeof encoding === "string")
        encoding = encoding.toLowerCase();
      if (!(["hex", "utf8", "utf-8", "ascii", "binary", "base64", "ucs2", "ucs-2", "utf16le", "utf-16le", "raw"].indexOf((encoding + "").toLowerCase()) > -1))
        throw new ERR_UNKNOWN_ENCODING(encoding);
      this._writableState.defaultEncoding = encoding;
      return this;
    };
    Object.defineProperty(Writable.prototype, "writableBuffer", {
      enumerable: false,
      get: function get() {
        return this._writableState && this._writableState.getBuffer();
      }
    });
    function decodeChunk(state, chunk, encoding) {
      if (!state.objectMode && state.decodeStrings !== false && typeof chunk === "string") {
        chunk = Buffer2.from(chunk, encoding);
      }
      return chunk;
    }
    Object.defineProperty(Writable.prototype, "writableHighWaterMark", {
      enumerable: false,
      get: function get() {
        return this._writableState.highWaterMark;
      }
    });
    function writeOrBuffer(stream, state, isBuf, chunk, encoding, cb) {
      if (!isBuf) {
        var newChunk = decodeChunk(state, chunk, encoding);
        if (chunk !== newChunk) {
          isBuf = true;
          encoding = "buffer";
          chunk = newChunk;
        }
      }
      var len = state.objectMode ? 1 : chunk.length;
      state.length += len;
      var ret = state.length < state.highWaterMark;
      if (!ret)
        state.needDrain = true;
      if (state.writing || state.corked) {
        var last = state.lastBufferedRequest;
        state.lastBufferedRequest = {
          chunk,
          encoding,
          isBuf,
          callback: cb,
          next: null
        };
        if (last) {
          last.next = state.lastBufferedRequest;
        } else {
          state.bufferedRequest = state.lastBufferedRequest;
        }
        state.bufferedRequestCount += 1;
      } else {
        doWrite(stream, state, false, len, chunk, encoding, cb);
      }
      return ret;
    }
    function doWrite(stream, state, writev, len, chunk, encoding, cb) {
      state.writelen = len;
      state.writecb = cb;
      state.writing = true;
      state.sync = true;
      if (state.destroyed)
        state.onwrite(new ERR_STREAM_DESTROYED("write"));
      else if (writev)
        stream._writev(chunk, state.onwrite);
      else
        stream._write(chunk, encoding, state.onwrite);
      state.sync = false;
    }
    function onwriteError(stream, state, sync, er, cb) {
      --state.pendingcb;
      if (sync) {
        process.nextTick(cb, er);
        process.nextTick(finishMaybe, stream, state);
        stream._writableState.errorEmitted = true;
        errorOrDestroy(stream, er);
      } else {
        cb(er);
        stream._writableState.errorEmitted = true;
        errorOrDestroy(stream, er);
        finishMaybe(stream, state);
      }
    }
    function onwriteStateUpdate(state) {
      state.writing = false;
      state.writecb = null;
      state.length -= state.writelen;
      state.writelen = 0;
    }
    function onwrite(stream, er) {
      var state = stream._writableState;
      var sync = state.sync;
      var cb = state.writecb;
      if (typeof cb !== "function")
        throw new ERR_MULTIPLE_CALLBACK();
      onwriteStateUpdate(state);
      if (er)
        onwriteError(stream, state, sync, er, cb);
      else {
        var finished = needFinish(state) || stream.destroyed;
        if (!finished && !state.corked && !state.bufferProcessing && state.bufferedRequest) {
          clearBuffer(stream, state);
        }
        if (sync) {
          process.nextTick(afterWrite, stream, state, finished, cb);
        } else {
          afterWrite(stream, state, finished, cb);
        }
      }
    }
    function afterWrite(stream, state, finished, cb) {
      if (!finished)
        onwriteDrain(stream, state);
      state.pendingcb--;
      cb();
      finishMaybe(stream, state);
    }
    function onwriteDrain(stream, state) {
      if (state.length === 0 && state.needDrain) {
        state.needDrain = false;
        stream.emit("drain");
      }
    }
    function clearBuffer(stream, state) {
      state.bufferProcessing = true;
      var entry = state.bufferedRequest;
      if (stream._writev && entry && entry.next) {
        var l = state.bufferedRequestCount;
        var buffer = new Array(l);
        var holder = state.corkedRequestsFree;
        holder.entry = entry;
        var count = 0;
        var allBuffers = true;
        while (entry) {
          buffer[count] = entry;
          if (!entry.isBuf)
            allBuffers = false;
          entry = entry.next;
          count += 1;
        }
        buffer.allBuffers = allBuffers;
        doWrite(stream, state, true, state.length, buffer, "", holder.finish);
        state.pendingcb++;
        state.lastBufferedRequest = null;
        if (holder.next) {
          state.corkedRequestsFree = holder.next;
          holder.next = null;
        } else {
          state.corkedRequestsFree = new CorkedRequest(state);
        }
        state.bufferedRequestCount = 0;
      } else {
        while (entry) {
          var chunk = entry.chunk;
          var encoding = entry.encoding;
          var cb = entry.callback;
          var len = state.objectMode ? 1 : chunk.length;
          doWrite(stream, state, false, len, chunk, encoding, cb);
          entry = entry.next;
          state.bufferedRequestCount--;
          if (state.writing) {
            break;
          }
        }
        if (entry === null)
          state.lastBufferedRequest = null;
      }
      state.bufferedRequest = entry;
      state.bufferProcessing = false;
    }
    Writable.prototype._write = function(chunk, encoding, cb) {
      cb(new ERR_METHOD_NOT_IMPLEMENTED("_write()"));
    };
    Writable.prototype._writev = null;
    Writable.prototype.end = function(chunk, encoding, cb) {
      var state = this._writableState;
      if (typeof chunk === "function") {
        cb = chunk;
        chunk = null;
        encoding = null;
      } else if (typeof encoding === "function") {
        cb = encoding;
        encoding = null;
      }
      if (chunk !== null && chunk !== void 0)
        this.write(chunk, encoding);
      if (state.corked) {
        state.corked = 1;
        this.uncork();
      }
      if (!state.ending)
        endWritable(this, state, cb);
      return this;
    };
    Object.defineProperty(Writable.prototype, "writableLength", {
      enumerable: false,
      get: function get() {
        return this._writableState.length;
      }
    });
    function needFinish(state) {
      return state.ending && state.length === 0 && state.bufferedRequest === null && !state.finished && !state.writing;
    }
    function callFinal(stream, state) {
      stream._final(function(err) {
        state.pendingcb--;
        if (err) {
          errorOrDestroy(stream, err);
        }
        state.prefinished = true;
        stream.emit("prefinish");
        finishMaybe(stream, state);
      });
    }
    function prefinish(stream, state) {
      if (!state.prefinished && !state.finalCalled) {
        if (typeof stream._final === "function" && !state.destroyed) {
          state.pendingcb++;
          state.finalCalled = true;
          process.nextTick(callFinal, stream, state);
        } else {
          state.prefinished = true;
          stream.emit("prefinish");
        }
      }
    }
    function finishMaybe(stream, state) {
      var need = needFinish(state);
      if (need) {
        prefinish(stream, state);
        if (state.pendingcb === 0) {
          state.finished = true;
          stream.emit("finish");
          if (state.autoDestroy) {
            var rState = stream._readableState;
            if (!rState || rState.autoDestroy && rState.endEmitted) {
              stream.destroy();
            }
          }
        }
      }
      return need;
    }
    function endWritable(stream, state, cb) {
      state.ending = true;
      finishMaybe(stream, state);
      if (cb) {
        if (state.finished)
          process.nextTick(cb);
        else
          stream.once("finish", cb);
      }
      state.ended = true;
      stream.writable = false;
    }
    function onCorkedFinish(corkReq, state, err) {
      var entry = corkReq.entry;
      corkReq.entry = null;
      while (entry) {
        var cb = entry.callback;
        state.pendingcb--;
        cb(err);
        entry = entry.next;
      }
      state.corkedRequestsFree.next = corkReq;
    }
    Object.defineProperty(Writable.prototype, "destroyed", {
      enumerable: false,
      get: function get() {
        if (this._writableState === void 0) {
          return false;
        }
        return this._writableState.destroyed;
      },
      set: function set(value) {
        if (!this._writableState) {
          return;
        }
        this._writableState.destroyed = value;
      }
    });
    Writable.prototype.destroy = destroyImpl.destroy;
    Writable.prototype._undestroy = destroyImpl.undestroy;
    Writable.prototype._destroy = function(err, cb) {
      cb(err);
    };
  }
});

// node_modules/readable-stream/lib/_stream_duplex.js
var require_stream_duplex = __commonJS({
  "node_modules/readable-stream/lib/_stream_duplex.js"(exports, module2) {
    "use strict";
    var objectKeys = Object.keys || function(obj) {
      var keys2 = [];
      for (var key in obj) {
        keys2.push(key);
      }
      return keys2;
    };
    module2.exports = Duplex;
    var Readable = require_stream_readable();
    var Writable = require_stream_writable();
    require_inherits()(Duplex, Readable);
    {
      keys = objectKeys(Writable.prototype);
      for (v = 0; v < keys.length; v++) {
        method = keys[v];
        if (!Duplex.prototype[method])
          Duplex.prototype[method] = Writable.prototype[method];
      }
    }
    var keys;
    var method;
    var v;
    function Duplex(options) {
      if (!(this instanceof Duplex))
        return new Duplex(options);
      Readable.call(this, options);
      Writable.call(this, options);
      this.allowHalfOpen = true;
      if (options) {
        if (options.readable === false)
          this.readable = false;
        if (options.writable === false)
          this.writable = false;
        if (options.allowHalfOpen === false) {
          this.allowHalfOpen = false;
          this.once("end", onend);
        }
      }
    }
    Object.defineProperty(Duplex.prototype, "writableHighWaterMark", {
      enumerable: false,
      get: function get() {
        return this._writableState.highWaterMark;
      }
    });
    Object.defineProperty(Duplex.prototype, "writableBuffer", {
      enumerable: false,
      get: function get() {
        return this._writableState && this._writableState.getBuffer();
      }
    });
    Object.defineProperty(Duplex.prototype, "writableLength", {
      enumerable: false,
      get: function get() {
        return this._writableState.length;
      }
    });
    function onend() {
      if (this._writableState.ended)
        return;
      process.nextTick(onEndNT, this);
    }
    function onEndNT(self2) {
      self2.end();
    }
    Object.defineProperty(Duplex.prototype, "destroyed", {
      enumerable: false,
      get: function get() {
        if (this._readableState === void 0 || this._writableState === void 0) {
          return false;
        }
        return this._readableState.destroyed && this._writableState.destroyed;
      },
      set: function set(value) {
        if (this._readableState === void 0 || this._writableState === void 0) {
          return;
        }
        this._readableState.destroyed = value;
        this._writableState.destroyed = value;
      }
    });
  }
});

// node_modules/safe-buffer/index.js
var require_safe_buffer = __commonJS({
  "node_modules/safe-buffer/index.js"(exports, module2) {
    var buffer = require("buffer");
    var Buffer2 = buffer.Buffer;
    function copyProps(src, dst) {
      for (var key in src) {
        dst[key] = src[key];
      }
    }
    if (Buffer2.from && Buffer2.alloc && Buffer2.allocUnsafe && Buffer2.allocUnsafeSlow) {
      module2.exports = buffer;
    } else {
      copyProps(buffer, exports);
      exports.Buffer = SafeBuffer;
    }
    function SafeBuffer(arg, encodingOrOffset, length) {
      return Buffer2(arg, encodingOrOffset, length);
    }
    SafeBuffer.prototype = Object.create(Buffer2.prototype);
    copyProps(Buffer2, SafeBuffer);
    SafeBuffer.from = function(arg, encodingOrOffset, length) {
      if (typeof arg === "number") {
        throw new TypeError("Argument must not be a number");
      }
      return Buffer2(arg, encodingOrOffset, length);
    };
    SafeBuffer.alloc = function(size, fill, encoding) {
      if (typeof size !== "number") {
        throw new TypeError("Argument must be a number");
      }
      var buf = Buffer2(size);
      if (fill !== void 0) {
        if (typeof encoding === "string") {
          buf.fill(fill, encoding);
        } else {
          buf.fill(fill);
        }
      } else {
        buf.fill(0);
      }
      return buf;
    };
    SafeBuffer.allocUnsafe = function(size) {
      if (typeof size !== "number") {
        throw new TypeError("Argument must be a number");
      }
      return Buffer2(size);
    };
    SafeBuffer.allocUnsafeSlow = function(size) {
      if (typeof size !== "number") {
        throw new TypeError("Argument must be a number");
      }
      return buffer.SlowBuffer(size);
    };
  }
});

// node_modules/string_decoder/lib/string_decoder.js
var require_string_decoder = __commonJS({
  "node_modules/string_decoder/lib/string_decoder.js"(exports) {
    "use strict";
    var Buffer2 = require_safe_buffer().Buffer;
    var isEncoding = Buffer2.isEncoding || function(encoding) {
      encoding = "" + encoding;
      switch (encoding && encoding.toLowerCase()) {
        case "hex":
        case "utf8":
        case "utf-8":
        case "ascii":
        case "binary":
        case "base64":
        case "ucs2":
        case "ucs-2":
        case "utf16le":
        case "utf-16le":
        case "raw":
          return true;
        default:
          return false;
      }
    };
    function _normalizeEncoding(enc) {
      if (!enc)
        return "utf8";
      var retried;
      while (true) {
        switch (enc) {
          case "utf8":
          case "utf-8":
            return "utf8";
          case "ucs2":
          case "ucs-2":
          case "utf16le":
          case "utf-16le":
            return "utf16le";
          case "latin1":
          case "binary":
            return "latin1";
          case "base64":
          case "ascii":
          case "hex":
            return enc;
          default:
            if (retried)
              return;
            enc = ("" + enc).toLowerCase();
            retried = true;
        }
      }
    }
    function normalizeEncoding(enc) {
      var nenc = _normalizeEncoding(enc);
      if (typeof nenc !== "string" && (Buffer2.isEncoding === isEncoding || !isEncoding(enc)))
        throw new Error("Unknown encoding: " + enc);
      return nenc || enc;
    }
    exports.StringDecoder = StringDecoder;
    function StringDecoder(encoding) {
      this.encoding = normalizeEncoding(encoding);
      var nb;
      switch (this.encoding) {
        case "utf16le":
          this.text = utf16Text;
          this.end = utf16End;
          nb = 4;
          break;
        case "utf8":
          this.fillLast = utf8FillLast;
          nb = 4;
          break;
        case "base64":
          this.text = base64Text;
          this.end = base64End;
          nb = 3;
          break;
        default:
          this.write = simpleWrite;
          this.end = simpleEnd;
          return;
      }
      this.lastNeed = 0;
      this.lastTotal = 0;
      this.lastChar = Buffer2.allocUnsafe(nb);
    }
    StringDecoder.prototype.write = function(buf) {
      if (buf.length === 0)
        return "";
      var r;
      var i;
      if (this.lastNeed) {
        r = this.fillLast(buf);
        if (r === void 0)
          return "";
        i = this.lastNeed;
        this.lastNeed = 0;
      } else {
        i = 0;
      }
      if (i < buf.length)
        return r ? r + this.text(buf, i) : this.text(buf, i);
      return r || "";
    };
    StringDecoder.prototype.end = utf8End;
    StringDecoder.prototype.text = utf8Text;
    StringDecoder.prototype.fillLast = function(buf) {
      if (this.lastNeed <= buf.length) {
        buf.copy(this.lastChar, this.lastTotal - this.lastNeed, 0, this.lastNeed);
        return this.lastChar.toString(this.encoding, 0, this.lastTotal);
      }
      buf.copy(this.lastChar, this.lastTotal - this.lastNeed, 0, buf.length);
      this.lastNeed -= buf.length;
    };
    function utf8CheckByte(byte) {
      if (byte <= 127)
        return 0;
      else if (byte >> 5 === 6)
        return 2;
      else if (byte >> 4 === 14)
        return 3;
      else if (byte >> 3 === 30)
        return 4;
      return byte >> 6 === 2 ? -1 : -2;
    }
    function utf8CheckIncomplete(self2, buf, i) {
      var j = buf.length - 1;
      if (j < i)
        return 0;
      var nb = utf8CheckByte(buf[j]);
      if (nb >= 0) {
        if (nb > 0)
          self2.lastNeed = nb - 1;
        return nb;
      }
      if (--j < i || nb === -2)
        return 0;
      nb = utf8CheckByte(buf[j]);
      if (nb >= 0) {
        if (nb > 0)
          self2.lastNeed = nb - 2;
        return nb;
      }
      if (--j < i || nb === -2)
        return 0;
      nb = utf8CheckByte(buf[j]);
      if (nb >= 0) {
        if (nb > 0) {
          if (nb === 2)
            nb = 0;
          else
            self2.lastNeed = nb - 3;
        }
        return nb;
      }
      return 0;
    }
    function utf8CheckExtraBytes(self2, buf, p) {
      if ((buf[0] & 192) !== 128) {
        self2.lastNeed = 0;
        return "\uFFFD";
      }
      if (self2.lastNeed > 1 && buf.length > 1) {
        if ((buf[1] & 192) !== 128) {
          self2.lastNeed = 1;
          return "\uFFFD";
        }
        if (self2.lastNeed > 2 && buf.length > 2) {
          if ((buf[2] & 192) !== 128) {
            self2.lastNeed = 2;
            return "\uFFFD";
          }
        }
      }
    }
    function utf8FillLast(buf) {
      var p = this.lastTotal - this.lastNeed;
      var r = utf8CheckExtraBytes(this, buf, p);
      if (r !== void 0)
        return r;
      if (this.lastNeed <= buf.length) {
        buf.copy(this.lastChar, p, 0, this.lastNeed);
        return this.lastChar.toString(this.encoding, 0, this.lastTotal);
      }
      buf.copy(this.lastChar, p, 0, buf.length);
      this.lastNeed -= buf.length;
    }
    function utf8Text(buf, i) {
      var total = utf8CheckIncomplete(this, buf, i);
      if (!this.lastNeed)
        return buf.toString("utf8", i);
      this.lastTotal = total;
      var end = buf.length - (total - this.lastNeed);
      buf.copy(this.lastChar, 0, end);
      return buf.toString("utf8", i, end);
    }
    function utf8End(buf) {
      var r = buf && buf.length ? this.write(buf) : "";
      if (this.lastNeed)
        return r + "\uFFFD";
      return r;
    }
    function utf16Text(buf, i) {
      if ((buf.length - i) % 2 === 0) {
        var r = buf.toString("utf16le", i);
        if (r) {
          var c = r.charCodeAt(r.length - 1);
          if (c >= 55296 && c <= 56319) {
            this.lastNeed = 2;
            this.lastTotal = 4;
            this.lastChar[0] = buf[buf.length - 2];
            this.lastChar[1] = buf[buf.length - 1];
            return r.slice(0, -1);
          }
        }
        return r;
      }
      this.lastNeed = 1;
      this.lastTotal = 2;
      this.lastChar[0] = buf[buf.length - 1];
      return buf.toString("utf16le", i, buf.length - 1);
    }
    function utf16End(buf) {
      var r = buf && buf.length ? this.write(buf) : "";
      if (this.lastNeed) {
        var end = this.lastTotal - this.lastNeed;
        return r + this.lastChar.toString("utf16le", 0, end);
      }
      return r;
    }
    function base64Text(buf, i) {
      var n = (buf.length - i) % 3;
      if (n === 0)
        return buf.toString("base64", i);
      this.lastNeed = 3 - n;
      this.lastTotal = 3;
      if (n === 1) {
        this.lastChar[0] = buf[buf.length - 1];
      } else {
        this.lastChar[0] = buf[buf.length - 2];
        this.lastChar[1] = buf[buf.length - 1];
      }
      return buf.toString("base64", i, buf.length - n);
    }
    function base64End(buf) {
      var r = buf && buf.length ? this.write(buf) : "";
      if (this.lastNeed)
        return r + this.lastChar.toString("base64", 0, 3 - this.lastNeed);
      return r;
    }
    function simpleWrite(buf) {
      return buf.toString(this.encoding);
    }
    function simpleEnd(buf) {
      return buf && buf.length ? this.write(buf) : "";
    }
  }
});

// node_modules/readable-stream/lib/internal/streams/end-of-stream.js
var require_end_of_stream = __commonJS({
  "node_modules/readable-stream/lib/internal/streams/end-of-stream.js"(exports, module2) {
    "use strict";
    var ERR_STREAM_PREMATURE_CLOSE = require_errors2().codes.ERR_STREAM_PREMATURE_CLOSE;
    function once(callback) {
      var called = false;
      return function() {
        if (called)
          return;
        called = true;
        for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
          args[_key] = arguments[_key];
        }
        callback.apply(this, args);
      };
    }
    function noop() {
    }
    function isRequest(stream) {
      return stream.setHeader && typeof stream.abort === "function";
    }
    function eos(stream, opts, callback) {
      if (typeof opts === "function")
        return eos(stream, null, opts);
      if (!opts)
        opts = {};
      callback = once(callback || noop);
      var readable = opts.readable || opts.readable !== false && stream.readable;
      var writable = opts.writable || opts.writable !== false && stream.writable;
      var onlegacyfinish = function onlegacyfinish2() {
        if (!stream.writable)
          onfinish();
      };
      var writableEnded = stream._writableState && stream._writableState.finished;
      var onfinish = function onfinish2() {
        writable = false;
        writableEnded = true;
        if (!readable)
          callback.call(stream);
      };
      var readableEnded = stream._readableState && stream._readableState.endEmitted;
      var onend = function onend2() {
        readable = false;
        readableEnded = true;
        if (!writable)
          callback.call(stream);
      };
      var onerror = function onerror2(err) {
        callback.call(stream, err);
      };
      var onclose = function onclose2() {
        var err;
        if (readable && !readableEnded) {
          if (!stream._readableState || !stream._readableState.ended)
            err = new ERR_STREAM_PREMATURE_CLOSE();
          return callback.call(stream, err);
        }
        if (writable && !writableEnded) {
          if (!stream._writableState || !stream._writableState.ended)
            err = new ERR_STREAM_PREMATURE_CLOSE();
          return callback.call(stream, err);
        }
      };
      var onrequest = function onrequest2() {
        stream.req.on("finish", onfinish);
      };
      if (isRequest(stream)) {
        stream.on("complete", onfinish);
        stream.on("abort", onclose);
        if (stream.req)
          onrequest();
        else
          stream.on("request", onrequest);
      } else if (writable && !stream._writableState) {
        stream.on("end", onlegacyfinish);
        stream.on("close", onlegacyfinish);
      }
      stream.on("end", onend);
      stream.on("finish", onfinish);
      if (opts.error !== false)
        stream.on("error", onerror);
      stream.on("close", onclose);
      return function() {
        stream.removeListener("complete", onfinish);
        stream.removeListener("abort", onclose);
        stream.removeListener("request", onrequest);
        if (stream.req)
          stream.req.removeListener("finish", onfinish);
        stream.removeListener("end", onlegacyfinish);
        stream.removeListener("close", onlegacyfinish);
        stream.removeListener("finish", onfinish);
        stream.removeListener("end", onend);
        stream.removeListener("error", onerror);
        stream.removeListener("close", onclose);
      };
    }
    module2.exports = eos;
  }
});

// node_modules/readable-stream/lib/internal/streams/async_iterator.js
var require_async_iterator = __commonJS({
  "node_modules/readable-stream/lib/internal/streams/async_iterator.js"(exports, module2) {
    "use strict";
    var _Object$setPrototypeO;
    function _defineProperty(obj, key, value) {
      if (key in obj) {
        Object.defineProperty(obj, key, { value, enumerable: true, configurable: true, writable: true });
      } else {
        obj[key] = value;
      }
      return obj;
    }
    var finished = require_end_of_stream();
    var kLastResolve = Symbol("lastResolve");
    var kLastReject = Symbol("lastReject");
    var kError = Symbol("error");
    var kEnded = Symbol("ended");
    var kLastPromise = Symbol("lastPromise");
    var kHandlePromise = Symbol("handlePromise");
    var kStream = Symbol("stream");
    function createIterResult(value, done) {
      return {
        value,
        done
      };
    }
    function readAndResolve(iter) {
      var resolve = iter[kLastResolve];
      if (resolve !== null) {
        var data = iter[kStream].read();
        if (data !== null) {
          iter[kLastPromise] = null;
          iter[kLastResolve] = null;
          iter[kLastReject] = null;
          resolve(createIterResult(data, false));
        }
      }
    }
    function onReadable(iter) {
      process.nextTick(readAndResolve, iter);
    }
    function wrapForNext(lastPromise, iter) {
      return function(resolve, reject) {
        lastPromise.then(function() {
          if (iter[kEnded]) {
            resolve(createIterResult(void 0, true));
            return;
          }
          iter[kHandlePromise](resolve, reject);
        }, reject);
      };
    }
    var AsyncIteratorPrototype = Object.getPrototypeOf(function() {
    });
    var ReadableStreamAsyncIteratorPrototype = Object.setPrototypeOf((_Object$setPrototypeO = {
      get stream() {
        return this[kStream];
      },
      next: function next() {
        var _this = this;
        var error = this[kError];
        if (error !== null) {
          return Promise.reject(error);
        }
        if (this[kEnded]) {
          return Promise.resolve(createIterResult(void 0, true));
        }
        if (this[kStream].destroyed) {
          return new Promise(function(resolve, reject) {
            process.nextTick(function() {
              if (_this[kError]) {
                reject(_this[kError]);
              } else {
                resolve(createIterResult(void 0, true));
              }
            });
          });
        }
        var lastPromise = this[kLastPromise];
        var promise;
        if (lastPromise) {
          promise = new Promise(wrapForNext(lastPromise, this));
        } else {
          var data = this[kStream].read();
          if (data !== null) {
            return Promise.resolve(createIterResult(data, false));
          }
          promise = new Promise(this[kHandlePromise]);
        }
        this[kLastPromise] = promise;
        return promise;
      }
    }, _defineProperty(_Object$setPrototypeO, Symbol.asyncIterator, function() {
      return this;
    }), _defineProperty(_Object$setPrototypeO, "return", function _return() {
      var _this2 = this;
      return new Promise(function(resolve, reject) {
        _this2[kStream].destroy(null, function(err) {
          if (err) {
            reject(err);
            return;
          }
          resolve(createIterResult(void 0, true));
        });
      });
    }), _Object$setPrototypeO), AsyncIteratorPrototype);
    var createReadableStreamAsyncIterator = function createReadableStreamAsyncIterator2(stream) {
      var _Object$create;
      var iterator = Object.create(ReadableStreamAsyncIteratorPrototype, (_Object$create = {}, _defineProperty(_Object$create, kStream, {
        value: stream,
        writable: true
      }), _defineProperty(_Object$create, kLastResolve, {
        value: null,
        writable: true
      }), _defineProperty(_Object$create, kLastReject, {
        value: null,
        writable: true
      }), _defineProperty(_Object$create, kError, {
        value: null,
        writable: true
      }), _defineProperty(_Object$create, kEnded, {
        value: stream._readableState.endEmitted,
        writable: true
      }), _defineProperty(_Object$create, kHandlePromise, {
        value: function value(resolve, reject) {
          var data = iterator[kStream].read();
          if (data) {
            iterator[kLastPromise] = null;
            iterator[kLastResolve] = null;
            iterator[kLastReject] = null;
            resolve(createIterResult(data, false));
          } else {
            iterator[kLastResolve] = resolve;
            iterator[kLastReject] = reject;
          }
        },
        writable: true
      }), _Object$create));
      iterator[kLastPromise] = null;
      finished(stream, function(err) {
        if (err && err.code !== "ERR_STREAM_PREMATURE_CLOSE") {
          var reject = iterator[kLastReject];
          if (reject !== null) {
            iterator[kLastPromise] = null;
            iterator[kLastResolve] = null;
            iterator[kLastReject] = null;
            reject(err);
          }
          iterator[kError] = err;
          return;
        }
        var resolve = iterator[kLastResolve];
        if (resolve !== null) {
          iterator[kLastPromise] = null;
          iterator[kLastResolve] = null;
          iterator[kLastReject] = null;
          resolve(createIterResult(void 0, true));
        }
        iterator[kEnded] = true;
      });
      stream.on("readable", onReadable.bind(null, iterator));
      return iterator;
    };
    module2.exports = createReadableStreamAsyncIterator;
  }
});

// node_modules/readable-stream/lib/internal/streams/from.js
var require_from = __commonJS({
  "node_modules/readable-stream/lib/internal/streams/from.js"(exports, module2) {
    "use strict";
    function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) {
      try {
        var info = gen[key](arg);
        var value = info.value;
      } catch (error) {
        reject(error);
        return;
      }
      if (info.done) {
        resolve(value);
      } else {
        Promise.resolve(value).then(_next, _throw);
      }
    }
    function _asyncToGenerator(fn) {
      return function() {
        var self2 = this, args = arguments;
        return new Promise(function(resolve, reject) {
          var gen = fn.apply(self2, args);
          function _next(value) {
            asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value);
          }
          function _throw(err) {
            asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err);
          }
          _next(void 0);
        });
      };
    }
    function ownKeys(object, enumerableOnly) {
      var keys = Object.keys(object);
      if (Object.getOwnPropertySymbols) {
        var symbols = Object.getOwnPropertySymbols(object);
        if (enumerableOnly)
          symbols = symbols.filter(function(sym) {
            return Object.getOwnPropertyDescriptor(object, sym).enumerable;
          });
        keys.push.apply(keys, symbols);
      }
      return keys;
    }
    function _objectSpread(target) {
      for (var i = 1; i < arguments.length; i++) {
        var source = arguments[i] != null ? arguments[i] : {};
        if (i % 2) {
          ownKeys(Object(source), true).forEach(function(key) {
            _defineProperty(target, key, source[key]);
          });
        } else if (Object.getOwnPropertyDescriptors) {
          Object.defineProperties(target, Object.getOwnPropertyDescriptors(source));
        } else {
          ownKeys(Object(source)).forEach(function(key) {
            Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key));
          });
        }
      }
      return target;
    }
    function _defineProperty(obj, key, value) {
      if (key in obj) {
        Object.defineProperty(obj, key, { value, enumerable: true, configurable: true, writable: true });
      } else {
        obj[key] = value;
      }
      return obj;
    }
    var ERR_INVALID_ARG_TYPE = require_errors2().codes.ERR_INVALID_ARG_TYPE;
    function from(Readable, iterable, opts) {
      var iterator;
      if (iterable && typeof iterable.next === "function") {
        iterator = iterable;
      } else if (iterable && iterable[Symbol.asyncIterator])
        iterator = iterable[Symbol.asyncIterator]();
      else if (iterable && iterable[Symbol.iterator])
        iterator = iterable[Symbol.iterator]();
      else
        throw new ERR_INVALID_ARG_TYPE("iterable", ["Iterable"], iterable);
      var readable = new Readable(_objectSpread({
        objectMode: true
      }, opts));
      var reading = false;
      readable._read = function() {
        if (!reading) {
          reading = true;
          next();
        }
      };
      function next() {
        return _next2.apply(this, arguments);
      }
      function _next2() {
        _next2 = _asyncToGenerator(function* () {
          try {
            var _ref = yield iterator.next(), value = _ref.value, done = _ref.done;
            if (done) {
              readable.push(null);
            } else if (readable.push(yield value)) {
              next();
            } else {
              reading = false;
            }
          } catch (err) {
            readable.destroy(err);
          }
        });
        return _next2.apply(this, arguments);
      }
      return readable;
    }
    module2.exports = from;
  }
});

// node_modules/readable-stream/lib/_stream_readable.js
var require_stream_readable = __commonJS({
  "node_modules/readable-stream/lib/_stream_readable.js"(exports, module2) {
    "use strict";
    module2.exports = Readable;
    var Duplex;
    Readable.ReadableState = ReadableState;
    var EE = require("events").EventEmitter;
    var EElistenerCount = function EElistenerCount2(emitter, type) {
      return emitter.listeners(type).length;
    };
    var Stream = require_stream();
    var Buffer2 = require("buffer").Buffer;
    var OurUint8Array = global.Uint8Array || function() {
    };
    function _uint8ArrayToBuffer(chunk) {
      return Buffer2.from(chunk);
    }
    function _isUint8Array(obj) {
      return Buffer2.isBuffer(obj) || obj instanceof OurUint8Array;
    }
    var debugUtil = require("util");
    var debug;
    if (debugUtil && debugUtil.debuglog) {
      debug = debugUtil.debuglog("stream");
    } else {
      debug = function debug2() {
      };
    }
    var BufferList = require_buffer_list();
    var destroyImpl = require_destroy();
    var _require = require_state();
    var getHighWaterMark = _require.getHighWaterMark;
    var _require$codes = require_errors2().codes;
    var ERR_INVALID_ARG_TYPE = _require$codes.ERR_INVALID_ARG_TYPE;
    var ERR_STREAM_PUSH_AFTER_EOF = _require$codes.ERR_STREAM_PUSH_AFTER_EOF;
    var ERR_METHOD_NOT_IMPLEMENTED = _require$codes.ERR_METHOD_NOT_IMPLEMENTED;
    var ERR_STREAM_UNSHIFT_AFTER_END_EVENT = _require$codes.ERR_STREAM_UNSHIFT_AFTER_END_EVENT;
    var StringDecoder;
    var createReadableStreamAsyncIterator;
    var from;
    require_inherits()(Readable, Stream);
    var errorOrDestroy = destroyImpl.errorOrDestroy;
    var kProxyEvents = ["error", "close", "destroy", "pause", "resume"];
    function prependListener(emitter, event, fn) {
      if (typeof emitter.prependListener === "function")
        return emitter.prependListener(event, fn);
      if (!emitter._events || !emitter._events[event])
        emitter.on(event, fn);
      else if (Array.isArray(emitter._events[event]))
        emitter._events[event].unshift(fn);
      else
        emitter._events[event] = [fn, emitter._events[event]];
    }
    function ReadableState(options, stream, isDuplex) {
      Duplex = Duplex || require_stream_duplex();
      options = options || {};
      if (typeof isDuplex !== "boolean")
        isDuplex = stream instanceof Duplex;
      this.objectMode = !!options.objectMode;
      if (isDuplex)
        this.objectMode = this.objectMode || !!options.readableObjectMode;
      this.highWaterMark = getHighWaterMark(this, options, "readableHighWaterMark", isDuplex);
      this.buffer = new BufferList();
      this.length = 0;
      this.pipes = null;
      this.pipesCount = 0;
      this.flowing = null;
      this.ended = false;
      this.endEmitted = false;
      this.reading = false;
      this.sync = true;
      this.needReadable = false;
      this.emittedReadable = false;
      this.readableListening = false;
      this.resumeScheduled = false;
      this.paused = true;
      this.emitClose = options.emitClose !== false;
      this.autoDestroy = !!options.autoDestroy;
      this.destroyed = false;
      this.defaultEncoding = options.defaultEncoding || "utf8";
      this.awaitDrain = 0;
      this.readingMore = false;
      this.decoder = null;
      this.encoding = null;
      if (options.encoding) {
        if (!StringDecoder)
          StringDecoder = require_string_decoder().StringDecoder;
        this.decoder = new StringDecoder(options.encoding);
        this.encoding = options.encoding;
      }
    }
    function Readable(options) {
      Duplex = Duplex || require_stream_duplex();
      if (!(this instanceof Readable))
        return new Readable(options);
      var isDuplex = this instanceof Duplex;
      this._readableState = new ReadableState(options, this, isDuplex);
      this.readable = true;
      if (options) {
        if (typeof options.read === "function")
          this._read = options.read;
        if (typeof options.destroy === "function")
          this._destroy = options.destroy;
      }
      Stream.call(this);
    }
    Object.defineProperty(Readable.prototype, "destroyed", {
      enumerable: false,
      get: function get() {
        if (this._readableState === void 0) {
          return false;
        }
        return this._readableState.destroyed;
      },
      set: function set(value) {
        if (!this._readableState) {
          return;
        }
        this._readableState.destroyed = value;
      }
    });
    Readable.prototype.destroy = destroyImpl.destroy;
    Readable.prototype._undestroy = destroyImpl.undestroy;
    Readable.prototype._destroy = function(err, cb) {
      cb(err);
    };
    Readable.prototype.push = function(chunk, encoding) {
      var state = this._readableState;
      var skipChunkCheck;
      if (!state.objectMode) {
        if (typeof chunk === "string") {
          encoding = encoding || state.defaultEncoding;
          if (encoding !== state.encoding) {
            chunk = Buffer2.from(chunk, encoding);
            encoding = "";
          }
          skipChunkCheck = true;
        }
      } else {
        skipChunkCheck = true;
      }
      return readableAddChunk(this, chunk, encoding, false, skipChunkCheck);
    };
    Readable.prototype.unshift = function(chunk) {
      return readableAddChunk(this, chunk, null, true, false);
    };
    function readableAddChunk(stream, chunk, encoding, addToFront, skipChunkCheck) {
      debug("readableAddChunk", chunk);
      var state = stream._readableState;
      if (chunk === null) {
        state.reading = false;
        onEofChunk(stream, state);
      } else {
        var er;
        if (!skipChunkCheck)
          er = chunkInvalid(state, chunk);
        if (er) {
          errorOrDestroy(stream, er);
        } else if (state.objectMode || chunk && chunk.length > 0) {
          if (typeof chunk !== "string" && !state.objectMode && Object.getPrototypeOf(chunk) !== Buffer2.prototype) {
            chunk = _uint8ArrayToBuffer(chunk);
          }
          if (addToFront) {
            if (state.endEmitted)
              errorOrDestroy(stream, new ERR_STREAM_UNSHIFT_AFTER_END_EVENT());
            else
              addChunk(stream, state, chunk, true);
          } else if (state.ended) {
            errorOrDestroy(stream, new ERR_STREAM_PUSH_AFTER_EOF());
          } else if (state.destroyed) {
            return false;
          } else {
            state.reading = false;
            if (state.decoder && !encoding) {
              chunk = state.decoder.write(chunk);
              if (state.objectMode || chunk.length !== 0)
                addChunk(stream, state, chunk, false);
              else
                maybeReadMore(stream, state);
            } else {
              addChunk(stream, state, chunk, false);
            }
          }
        } else if (!addToFront) {
          state.reading = false;
          maybeReadMore(stream, state);
        }
      }
      return !state.ended && (state.length < state.highWaterMark || state.length === 0);
    }
    function addChunk(stream, state, chunk, addToFront) {
      if (state.flowing && state.length === 0 && !state.sync) {
        state.awaitDrain = 0;
        stream.emit("data", chunk);
      } else {
        state.length += state.objectMode ? 1 : chunk.length;
        if (addToFront)
          state.buffer.unshift(chunk);
        else
          state.buffer.push(chunk);
        if (state.needReadable)
          emitReadable(stream);
      }
      maybeReadMore(stream, state);
    }
    function chunkInvalid(state, chunk) {
      var er;
      if (!_isUint8Array(chunk) && typeof chunk !== "string" && chunk !== void 0 && !state.objectMode) {
        er = new ERR_INVALID_ARG_TYPE("chunk", ["string", "Buffer", "Uint8Array"], chunk);
      }
      return er;
    }
    Readable.prototype.isPaused = function() {
      return this._readableState.flowing === false;
    };
    Readable.prototype.setEncoding = function(enc) {
      if (!StringDecoder)
        StringDecoder = require_string_decoder().StringDecoder;
      var decoder = new StringDecoder(enc);
      this._readableState.decoder = decoder;
      this._readableState.encoding = this._readableState.decoder.encoding;
      var p = this._readableState.buffer.head;
      var content = "";
      while (p !== null) {
        content += decoder.write(p.data);
        p = p.next;
      }
      this._readableState.buffer.clear();
      if (content !== "")
        this._readableState.buffer.push(content);
      this._readableState.length = content.length;
      return this;
    };
    var MAX_HWM = 1073741824;
    function computeNewHighWaterMark(n) {
      if (n >= MAX_HWM) {
        n = MAX_HWM;
      } else {
        n--;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        n++;
      }
      return n;
    }
    function howMuchToRead(n, state) {
      if (n <= 0 || state.length === 0 && state.ended)
        return 0;
      if (state.objectMode)
        return 1;
      if (n !== n) {
        if (state.flowing && state.length)
          return state.buffer.head.data.length;
        else
          return state.length;
      }
      if (n > state.highWaterMark)
        state.highWaterMark = computeNewHighWaterMark(n);
      if (n <= state.length)
        return n;
      if (!state.ended) {
        state.needReadable = true;
        return 0;
      }
      return state.length;
    }
    Readable.prototype.read = function(n) {
      debug("read", n);
      n = parseInt(n, 10);
      var state = this._readableState;
      var nOrig = n;
      if (n !== 0)
        state.emittedReadable = false;
      if (n === 0 && state.needReadable && ((state.highWaterMark !== 0 ? state.length >= state.highWaterMark : state.length > 0) || state.ended)) {
        debug("read: emitReadable", state.length, state.ended);
        if (state.length === 0 && state.ended)
          endReadable(this);
        else
          emitReadable(this);
        return null;
      }
      n = howMuchToRead(n, state);
      if (n === 0 && state.ended) {
        if (state.length === 0)
          endReadable(this);
        return null;
      }
      var doRead = state.needReadable;
      debug("need readable", doRead);
      if (state.length === 0 || state.length - n < state.highWaterMark) {
        doRead = true;
        debug("length less than watermark", doRead);
      }
      if (state.ended || state.reading) {
        doRead = false;
        debug("reading or ended", doRead);
      } else if (doRead) {
        debug("do read");
        state.reading = true;
        state.sync = true;
        if (state.length === 0)
          state.needReadable = true;
        this._read(state.highWaterMark);
        state.sync = false;
        if (!state.reading)
          n = howMuchToRead(nOrig, state);
      }
      var ret;
      if (n > 0)
        ret = fromList(n, state);
      else
        ret = null;
      if (ret === null) {
        state.needReadable = state.length <= state.highWaterMark;
        n = 0;
      } else {
        state.length -= n;
        state.awaitDrain = 0;
      }
      if (state.length === 0) {
        if (!state.ended)
          state.needReadable = true;
        if (nOrig !== n && state.ended)
          endReadable(this);
      }
      if (ret !== null)
        this.emit("data", ret);
      return ret;
    };
    function onEofChunk(stream, state) {
      debug("onEofChunk");
      if (state.ended)
        return;
      if (state.decoder) {
        var chunk = state.decoder.end();
        if (chunk && chunk.length) {
          state.buffer.push(chunk);
          state.length += state.objectMode ? 1 : chunk.length;
        }
      }
      state.ended = true;
      if (state.sync) {
        emitReadable(stream);
      } else {
        state.needReadable = false;
        if (!state.emittedReadable) {
          state.emittedReadable = true;
          emitReadable_(stream);
        }
      }
    }
    function emitReadable(stream) {
      var state = stream._readableState;
      debug("emitReadable", state.needReadable, state.emittedReadable);
      state.needReadable = false;
      if (!state.emittedReadable) {
        debug("emitReadable", state.flowing);
        state.emittedReadable = true;
        process.nextTick(emitReadable_, stream);
      }
    }
    function emitReadable_(stream) {
      var state = stream._readableState;
      debug("emitReadable_", state.destroyed, state.length, state.ended);
      if (!state.destroyed && (state.length || state.ended)) {
        stream.emit("readable");
        state.emittedReadable = false;
      }
      state.needReadable = !state.flowing && !state.ended && state.length <= state.highWaterMark;
      flow(stream);
    }
    function maybeReadMore(stream, state) {
      if (!state.readingMore) {
        state.readingMore = true;
        process.nextTick(maybeReadMore_, stream, state);
      }
    }
    function maybeReadMore_(stream, state) {
      while (!state.reading && !state.ended && (state.length < state.highWaterMark || state.flowing && state.length === 0)) {
        var len = state.length;
        debug("maybeReadMore read 0");
        stream.read(0);
        if (len === state.length)
          break;
      }
      state.readingMore = false;
    }
    Readable.prototype._read = function(n) {
      errorOrDestroy(this, new ERR_METHOD_NOT_IMPLEMENTED("_read()"));
    };
    Readable.prototype.pipe = function(dest, pipeOpts) {
      var src = this;
      var state = this._readableState;
      switch (state.pipesCount) {
        case 0:
          state.pipes = dest;
          break;
        case 1:
          state.pipes = [state.pipes, dest];
          break;
        default:
          state.pipes.push(dest);
          break;
      }
      state.pipesCount += 1;
      debug("pipe count=%d opts=%j", state.pipesCount, pipeOpts);
      var doEnd = (!pipeOpts || pipeOpts.end !== false) && dest !== process.stdout && dest !== process.stderr;
      var endFn = doEnd ? onend : unpipe;
      if (state.endEmitted)
        process.nextTick(endFn);
      else
        src.once("end", endFn);
      dest.on("unpipe", onunpipe);
      function onunpipe(readable, unpipeInfo) {
        debug("onunpipe");
        if (readable === src) {
          if (unpipeInfo && unpipeInfo.hasUnpiped === false) {
            unpipeInfo.hasUnpiped = true;
            cleanup();
          }
        }
      }
      function onend() {
        debug("onend");
        dest.end();
      }
      var ondrain = pipeOnDrain(src);
      dest.on("drain", ondrain);
      var cleanedUp = false;
      function cleanup() {
        debug("cleanup");
        dest.removeListener("close", onclose);
        dest.removeListener("finish", onfinish);
        dest.removeListener("drain", ondrain);
        dest.removeListener("error", onerror);
        dest.removeListener("unpipe", onunpipe);
        src.removeListener("end", onend);
        src.removeListener("end", unpipe);
        src.removeListener("data", ondata);
        cleanedUp = true;
        if (state.awaitDrain && (!dest._writableState || dest._writableState.needDrain))
          ondrain();
      }
      src.on("data", ondata);
      function ondata(chunk) {
        debug("ondata");
        var ret = dest.write(chunk);
        debug("dest.write", ret);
        if (ret === false) {
          if ((state.pipesCount === 1 && state.pipes === dest || state.pipesCount > 1 && indexOf(state.pipes, dest) !== -1) && !cleanedUp) {
            debug("false write response, pause", state.awaitDrain);
            state.awaitDrain++;
          }
          src.pause();
        }
      }
      function onerror(er) {
        debug("onerror", er);
        unpipe();
        dest.removeListener("error", onerror);
        if (EElistenerCount(dest, "error") === 0)
          errorOrDestroy(dest, er);
      }
      prependListener(dest, "error", onerror);
      function onclose() {
        dest.removeListener("finish", onfinish);
        unpipe();
      }
      dest.once("close", onclose);
      function onfinish() {
        debug("onfinish");
        dest.removeListener("close", onclose);
        unpipe();
      }
      dest.once("finish", onfinish);
      function unpipe() {
        debug("unpipe");
        src.unpipe(dest);
      }
      dest.emit("pipe", src);
      if (!state.flowing) {
        debug("pipe resume");
        src.resume();
      }
      return dest;
    };
    function pipeOnDrain(src) {
      return function pipeOnDrainFunctionResult() {
        var state = src._readableState;
        debug("pipeOnDrain", state.awaitDrain);
        if (state.awaitDrain)
          state.awaitDrain--;
        if (state.awaitDrain === 0 && EElistenerCount(src, "data")) {
          state.flowing = true;
          flow(src);
        }
      };
    }
    Readable.prototype.unpipe = function(dest) {
      var state = this._readableState;
      var unpipeInfo = {
        hasUnpiped: false
      };
      if (state.pipesCount === 0)
        return this;
      if (state.pipesCount === 1) {
        if (dest && dest !== state.pipes)
          return this;
        if (!dest)
          dest = state.pipes;
        state.pipes = null;
        state.pipesCount = 0;
        state.flowing = false;
        if (dest)
          dest.emit("unpipe", this, unpipeInfo);
        return this;
      }
      if (!dest) {
        var dests = state.pipes;
        var len = state.pipesCount;
        state.pipes = null;
        state.pipesCount = 0;
        state.flowing = false;
        for (var i = 0; i < len; i++) {
          dests[i].emit("unpipe", this, {
            hasUnpiped: false
          });
        }
        return this;
      }
      var index = indexOf(state.pipes, dest);
      if (index === -1)
        return this;
      state.pipes.splice(index, 1);
      state.pipesCount -= 1;
      if (state.pipesCount === 1)
        state.pipes = state.pipes[0];
      dest.emit("unpipe", this, unpipeInfo);
      return this;
    };
    Readable.prototype.on = function(ev, fn) {
      var res = Stream.prototype.on.call(this, ev, fn);
      var state = this._readableState;
      if (ev === "data") {
        state.readableListening = this.listenerCount("readable") > 0;
        if (state.flowing !== false)
          this.resume();
      } else if (ev === "readable") {
        if (!state.endEmitted && !state.readableListening) {
          state.readableListening = state.needReadable = true;
          state.flowing = false;
          state.emittedReadable = false;
          debug("on readable", state.length, state.reading);
          if (state.length) {
            emitReadable(this);
          } else if (!state.reading) {
            process.nextTick(nReadingNextTick, this);
          }
        }
      }
      return res;
    };
    Readable.prototype.addListener = Readable.prototype.on;
    Readable.prototype.removeListener = function(ev, fn) {
      var res = Stream.prototype.removeListener.call(this, ev, fn);
      if (ev === "readable") {
        process.nextTick(updateReadableListening, this);
      }
      return res;
    };
    Readable.prototype.removeAllListeners = function(ev) {
      var res = Stream.prototype.removeAllListeners.apply(this, arguments);
      if (ev === "readable" || ev === void 0) {
        process.nextTick(updateReadableListening, this);
      }
      return res;
    };
    function updateReadableListening(self2) {
      var state = self2._readableState;
      state.readableListening = self2.listenerCount("readable") > 0;
      if (state.resumeScheduled && !state.paused) {
        state.flowing = true;
      } else if (self2.listenerCount("data") > 0) {
        self2.resume();
      }
    }
    function nReadingNextTick(self2) {
      debug("readable nexttick read 0");
      self2.read(0);
    }
    Readable.prototype.resume = function() {
      var state = this._readableState;
      if (!state.flowing) {
        debug("resume");
        state.flowing = !state.readableListening;
        resume(this, state);
      }
      state.paused = false;
      return this;
    };
    function resume(stream, state) {
      if (!state.resumeScheduled) {
        state.resumeScheduled = true;
        process.nextTick(resume_, stream, state);
      }
    }
    function resume_(stream, state) {
      debug("resume", state.reading);
      if (!state.reading) {
        stream.read(0);
      }
      state.resumeScheduled = false;
      stream.emit("resume");
      flow(stream);
      if (state.flowing && !state.reading)
        stream.read(0);
    }
    Readable.prototype.pause = function() {
      debug("call pause flowing=%j", this._readableState.flowing);
      if (this._readableState.flowing !== false) {
        debug("pause");
        this._readableState.flowing = false;
        this.emit("pause");
      }
      this._readableState.paused = true;
      return this;
    };
    function flow(stream) {
      var state = stream._readableState;
      debug("flow", state.flowing);
      while (state.flowing && stream.read() !== null) {
        ;
      }
    }
    Readable.prototype.wrap = function(stream) {
      var _this = this;
      var state = this._readableState;
      var paused = false;
      stream.on("end", function() {
        debug("wrapped end");
        if (state.decoder && !state.ended) {
          var chunk = state.decoder.end();
          if (chunk && chunk.length)
            _this.push(chunk);
        }
        _this.push(null);
      });
      stream.on("data", function(chunk) {
        debug("wrapped data");
        if (state.decoder)
          chunk = state.decoder.write(chunk);
        if (state.objectMode && (chunk === null || chunk === void 0))
          return;
        else if (!state.objectMode && (!chunk || !chunk.length))
          return;
        var ret = _this.push(chunk);
        if (!ret) {
          paused = true;
          stream.pause();
        }
      });
      for (var i in stream) {
        if (this[i] === void 0 && typeof stream[i] === "function") {
          this[i] = function methodWrap(method) {
            return function methodWrapReturnFunction() {
              return stream[method].apply(stream, arguments);
            };
          }(i);
        }
      }
      for (var n = 0; n < kProxyEvents.length; n++) {
        stream.on(kProxyEvents[n], this.emit.bind(this, kProxyEvents[n]));
      }
      this._read = function(n2) {
        debug("wrapped _read", n2);
        if (paused) {
          paused = false;
          stream.resume();
        }
      };
      return this;
    };
    if (typeof Symbol === "function") {
      Readable.prototype[Symbol.asyncIterator] = function() {
        if (createReadableStreamAsyncIterator === void 0) {
          createReadableStreamAsyncIterator = require_async_iterator();
        }
        return createReadableStreamAsyncIterator(this);
      };
    }
    Object.defineProperty(Readable.prototype, "readableHighWaterMark", {
      enumerable: false,
      get: function get() {
        return this._readableState.highWaterMark;
      }
    });
    Object.defineProperty(Readable.prototype, "readableBuffer", {
      enumerable: false,
      get: function get() {
        return this._readableState && this._readableState.buffer;
      }
    });
    Object.defineProperty(Readable.prototype, "readableFlowing", {
      enumerable: false,
      get: function get() {
        return this._readableState.flowing;
      },
      set: function set(state) {
        if (this._readableState) {
          this._readableState.flowing = state;
        }
      }
    });
    Readable._fromList = fromList;
    Object.defineProperty(Readable.prototype, "readableLength", {
      enumerable: false,
      get: function get() {
        return this._readableState.length;
      }
    });
    function fromList(n, state) {
      if (state.length === 0)
        return null;
      var ret;
      if (state.objectMode)
        ret = state.buffer.shift();
      else if (!n || n >= state.length) {
        if (state.decoder)
          ret = state.buffer.join("");
        else if (state.buffer.length === 1)
          ret = state.buffer.first();
        else
          ret = state.buffer.concat(state.length);
        state.buffer.clear();
      } else {
        ret = state.buffer.consume(n, state.decoder);
      }
      return ret;
    }
    function endReadable(stream) {
      var state = stream._readableState;
      debug("endReadable", state.endEmitted);
      if (!state.endEmitted) {
        state.ended = true;
        process.nextTick(endReadableNT, state, stream);
      }
    }
    function endReadableNT(state, stream) {
      debug("endReadableNT", state.endEmitted, state.length);
      if (!state.endEmitted && state.length === 0) {
        state.endEmitted = true;
        stream.readable = false;
        stream.emit("end");
        if (state.autoDestroy) {
          var wState = stream._writableState;
          if (!wState || wState.autoDestroy && wState.finished) {
            stream.destroy();
          }
        }
      }
    }
    if (typeof Symbol === "function") {
      Readable.from = function(iterable, opts) {
        if (from === void 0) {
          from = require_from();
        }
        return from(Readable, iterable, opts);
      };
    }
    function indexOf(xs, x) {
      for (var i = 0, l = xs.length; i < l; i++) {
        if (xs[i] === x)
          return i;
      }
      return -1;
    }
  }
});

// node_modules/readable-stream/lib/_stream_transform.js
var require_stream_transform = __commonJS({
  "node_modules/readable-stream/lib/_stream_transform.js"(exports, module2) {
    "use strict";
    module2.exports = Transform;
    var _require$codes = require_errors2().codes;
    var ERR_METHOD_NOT_IMPLEMENTED = _require$codes.ERR_METHOD_NOT_IMPLEMENTED;
    var ERR_MULTIPLE_CALLBACK = _require$codes.ERR_MULTIPLE_CALLBACK;
    var ERR_TRANSFORM_ALREADY_TRANSFORMING = _require$codes.ERR_TRANSFORM_ALREADY_TRANSFORMING;
    var ERR_TRANSFORM_WITH_LENGTH_0 = _require$codes.ERR_TRANSFORM_WITH_LENGTH_0;
    var Duplex = require_stream_duplex();
    require_inherits()(Transform, Duplex);
    function afterTransform(er, data) {
      var ts = this._transformState;
      ts.transforming = false;
      var cb = ts.writecb;
      if (cb === null) {
        return this.emit("error", new ERR_MULTIPLE_CALLBACK());
      }
      ts.writechunk = null;
      ts.writecb = null;
      if (data != null)
        this.push(data);
      cb(er);
      var rs = this._readableState;
      rs.reading = false;
      if (rs.needReadable || rs.length < rs.highWaterMark) {
        this._read(rs.highWaterMark);
      }
    }
    function Transform(options) {
      if (!(this instanceof Transform))
        return new Transform(options);
      Duplex.call(this, options);
      this._transformState = {
        afterTransform: afterTransform.bind(this),
        needTransform: false,
        transforming: false,
        writecb: null,
        writechunk: null,
        writeencoding: null
      };
      this._readableState.needReadable = true;
      this._readableState.sync = false;
      if (options) {
        if (typeof options.transform === "function")
          this._transform = options.transform;
        if (typeof options.flush === "function")
          this._flush = options.flush;
      }
      this.on("prefinish", prefinish);
    }
    function prefinish() {
      var _this = this;
      if (typeof this._flush === "function" && !this._readableState.destroyed) {
        this._flush(function(er, data) {
          done(_this, er, data);
        });
      } else {
        done(this, null, null);
      }
    }
    Transform.prototype.push = function(chunk, encoding) {
      this._transformState.needTransform = false;
      return Duplex.prototype.push.call(this, chunk, encoding);
    };
    Transform.prototype._transform = function(chunk, encoding, cb) {
      cb(new ERR_METHOD_NOT_IMPLEMENTED("_transform()"));
    };
    Transform.prototype._write = function(chunk, encoding, cb) {
      var ts = this._transformState;
      ts.writecb = cb;
      ts.writechunk = chunk;
      ts.writeencoding = encoding;
      if (!ts.transforming) {
        var rs = this._readableState;
        if (ts.needTransform || rs.needReadable || rs.length < rs.highWaterMark)
          this._read(rs.highWaterMark);
      }
    };
    Transform.prototype._read = function(n) {
      var ts = this._transformState;
      if (ts.writechunk !== null && !ts.transforming) {
        ts.transforming = true;
        this._transform(ts.writechunk, ts.writeencoding, ts.afterTransform);
      } else {
        ts.needTransform = true;
      }
    };
    Transform.prototype._destroy = function(err, cb) {
      Duplex.prototype._destroy.call(this, err, function(err2) {
        cb(err2);
      });
    };
    function done(stream, er, data) {
      if (er)
        return stream.emit("error", er);
      if (data != null)
        stream.push(data);
      if (stream._writableState.length)
        throw new ERR_TRANSFORM_WITH_LENGTH_0();
      if (stream._transformState.transforming)
        throw new ERR_TRANSFORM_ALREADY_TRANSFORMING();
      return stream.push(null);
    }
  }
});

// node_modules/readable-stream/lib/_stream_passthrough.js
var require_stream_passthrough = __commonJS({
  "node_modules/readable-stream/lib/_stream_passthrough.js"(exports, module2) {
    "use strict";
    module2.exports = PassThrough;
    var Transform = require_stream_transform();
    require_inherits()(PassThrough, Transform);
    function PassThrough(options) {
      if (!(this instanceof PassThrough))
        return new PassThrough(options);
      Transform.call(this, options);
    }
    PassThrough.prototype._transform = function(chunk, encoding, cb) {
      cb(null, chunk);
    };
  }
});

// node_modules/readable-stream/lib/internal/streams/pipeline.js
var require_pipeline = __commonJS({
  "node_modules/readable-stream/lib/internal/streams/pipeline.js"(exports, module2) {
    "use strict";
    var eos;
    function once(callback) {
      var called = false;
      return function() {
        if (called)
          return;
        called = true;
        callback.apply(void 0, arguments);
      };
    }
    var _require$codes = require_errors2().codes;
    var ERR_MISSING_ARGS = _require$codes.ERR_MISSING_ARGS;
    var ERR_STREAM_DESTROYED = _require$codes.ERR_STREAM_DESTROYED;
    function noop(err) {
      if (err)
        throw err;
    }
    function isRequest(stream) {
      return stream.setHeader && typeof stream.abort === "function";
    }
    function destroyer(stream, reading, writing, callback) {
      callback = once(callback);
      var closed = false;
      stream.on("close", function() {
        closed = true;
      });
      if (eos === void 0)
        eos = require_end_of_stream();
      eos(stream, {
        readable: reading,
        writable: writing
      }, function(err) {
        if (err)
          return callback(err);
        closed = true;
        callback();
      });
      var destroyed = false;
      return function(err) {
        if (closed)
          return;
        if (destroyed)
          return;
        destroyed = true;
        if (isRequest(stream))
          return stream.abort();
        if (typeof stream.destroy === "function")
          return stream.destroy();
        callback(err || new ERR_STREAM_DESTROYED("pipe"));
      };
    }
    function call(fn) {
      fn();
    }
    function pipe(from, to) {
      return from.pipe(to);
    }
    function popCallback(streams) {
      if (!streams.length)
        return noop;
      if (typeof streams[streams.length - 1] !== "function")
        return noop;
      return streams.pop();
    }
    function pipeline() {
      for (var _len = arguments.length, streams = new Array(_len), _key = 0; _key < _len; _key++) {
        streams[_key] = arguments[_key];
      }
      var callback = popCallback(streams);
      if (Array.isArray(streams[0]))
        streams = streams[0];
      if (streams.length < 2) {
        throw new ERR_MISSING_ARGS("streams");
      }
      var error;
      var destroys = streams.map(function(stream, i) {
        var reading = i < streams.length - 1;
        var writing = i > 0;
        return destroyer(stream, reading, writing, function(err) {
          if (!error)
            error = err;
          if (err)
            destroys.forEach(call);
          if (reading)
            return;
          destroys.forEach(call);
          callback(error);
        });
      });
      return streams.reduce(pipe);
    }
    module2.exports = pipeline;
  }
});

// node_modules/readable-stream/readable.js
var require_readable = __commonJS({
  "node_modules/readable-stream/readable.js"(exports, module2) {
    var Stream = require("stream");
    if (process.env.READABLE_STREAM === "disable" && Stream) {
      module2.exports = Stream.Readable;
      Object.assign(module2.exports, Stream);
      module2.exports.Stream = Stream;
    } else {
      exports = module2.exports = require_stream_readable();
      exports.Stream = Stream || exports;
      exports.Readable = exports;
      exports.Writable = require_stream_writable();
      exports.Duplex = require_stream_duplex();
      exports.Transform = require_stream_transform();
      exports.PassThrough = require_stream_passthrough();
      exports.finished = require_end_of_stream();
      exports.pipeline = require_pipeline();
    }
  }
});

// node_modules/docker-modem/lib/http_duplex.js
var require_http_duplex = __commonJS({
  "node_modules/docker-modem/lib/http_duplex.js"(exports, module2) {
    module2.exports = HttpDuplex;
    var util = require("util");
    var stream = require_readable();
    util.inherits(HttpDuplex, stream.Duplex);
    function HttpDuplex(req, res, options) {
      var self2 = this;
      if (!(self2 instanceof HttpDuplex))
        return new HttpDuplex(req, res, options);
      stream.Duplex.call(self2, options);
      self2._output = null;
      self2.connect(req, res);
    }
    HttpDuplex.prototype.connect = function(req, res) {
      var self2 = this;
      self2.req = req;
      self2._output = res;
      self2.emit("response", res);
      res.on("data", function(c) {
        if (!self2.push(c))
          self2._output.pause();
      });
      res.on("end", function() {
        self2.push(null);
      });
    };
    HttpDuplex.prototype._read = function(n) {
      if (this._output)
        this._output.resume();
    };
    HttpDuplex.prototype._write = function(chunk, encoding, cb) {
      this.req.write(chunk, encoding);
      cb();
    };
    HttpDuplex.prototype.end = function(chunk, encoding, cb) {
      this._output.socket.destroy();
      return this.req.end(chunk, encoding, cb);
    };
    HttpDuplex.prototype.destroy = function() {
      this.req.destroy();
      this._output.socket.destroy();
    };
  }
});

// node_modules/ms/index.js
var require_ms = __commonJS({
  "node_modules/ms/index.js"(exports, module2) {
    var s = 1e3;
    var m = s * 60;
    var h = m * 60;
    var d = h * 24;
    var w = d * 7;
    var y = d * 365.25;
    module2.exports = function(val, options) {
      options = options || {};
      var type = typeof val;
      if (type === "string" && val.length > 0) {
        return parse(val);
      } else if (type === "number" && isFinite(val)) {
        return options.long ? fmtLong(val) : fmtShort(val);
      }
      throw new Error("val is not a non-empty string or a valid number. val=" + JSON.stringify(val));
    };
    function parse(str) {
      str = String(str);
      if (str.length > 100) {
        return;
      }
      var match = /^(-?(?:\d+)?\.?\d+) *(milliseconds?|msecs?|ms|seconds?|secs?|s|minutes?|mins?|m|hours?|hrs?|h|days?|d|weeks?|w|years?|yrs?|y)?$/i.exec(str);
      if (!match) {
        return;
      }
      var n = parseFloat(match[1]);
      var type = (match[2] || "ms").toLowerCase();
      switch (type) {
        case "years":
        case "year":
        case "yrs":
        case "yr":
        case "y":
          return n * y;
        case "weeks":
        case "week":
        case "w":
          return n * w;
        case "days":
        case "day":
        case "d":
          return n * d;
        case "hours":
        case "hour":
        case "hrs":
        case "hr":
        case "h":
          return n * h;
        case "minutes":
        case "minute":
        case "mins":
        case "min":
        case "m":
          return n * m;
        case "seconds":
        case "second":
        case "secs":
        case "sec":
        case "s":
          return n * s;
        case "milliseconds":
        case "millisecond":
        case "msecs":
        case "msec":
        case "ms":
          return n;
        default:
          return void 0;
      }
    }
    function fmtShort(ms) {
      var msAbs = Math.abs(ms);
      if (msAbs >= d) {
        return Math.round(ms / d) + "d";
      }
      if (msAbs >= h) {
        return Math.round(ms / h) + "h";
      }
      if (msAbs >= m) {
        return Math.round(ms / m) + "m";
      }
      if (msAbs >= s) {
        return Math.round(ms / s) + "s";
      }
      return ms + "ms";
    }
    function fmtLong(ms) {
      var msAbs = Math.abs(ms);
      if (msAbs >= d) {
        return plural(ms, msAbs, d, "day");
      }
      if (msAbs >= h) {
        return plural(ms, msAbs, h, "hour");
      }
      if (msAbs >= m) {
        return plural(ms, msAbs, m, "minute");
      }
      if (msAbs >= s) {
        return plural(ms, msAbs, s, "second");
      }
      return ms + " ms";
    }
    function plural(ms, msAbs, n, name) {
      var isPlural = msAbs >= n * 1.5;
      return Math.round(ms / n) + " " + name + (isPlural ? "s" : "");
    }
  }
});

// node_modules/debug/src/common.js
var require_common = __commonJS({
  "node_modules/debug/src/common.js"(exports, module2) {
    function setup(env) {
      createDebug.debug = createDebug;
      createDebug.default = createDebug;
      createDebug.coerce = coerce;
      createDebug.disable = disable;
      createDebug.enable = enable;
      createDebug.enabled = enabled;
      createDebug.humanize = require_ms();
      createDebug.destroy = destroy2;
      Object.keys(env).forEach((key) => {
        createDebug[key] = env[key];
      });
      createDebug.names = [];
      createDebug.skips = [];
      createDebug.formatters = {};
      function selectColor(namespace) {
        let hash = 0;
        for (let i = 0; i < namespace.length; i++) {
          hash = (hash << 5) - hash + namespace.charCodeAt(i);
          hash |= 0;
        }
        return createDebug.colors[Math.abs(hash) % createDebug.colors.length];
      }
      createDebug.selectColor = selectColor;
      function createDebug(namespace) {
        let prevTime;
        let enableOverride = null;
        let namespacesCache;
        let enabledCache;
        function debug(...args) {
          if (!debug.enabled) {
            return;
          }
          const self2 = debug;
          const curr = Number(new Date());
          const ms = curr - (prevTime || curr);
          self2.diff = ms;
          self2.prev = prevTime;
          self2.curr = curr;
          prevTime = curr;
          args[0] = createDebug.coerce(args[0]);
          if (typeof args[0] !== "string") {
            args.unshift("%O");
          }
          let index = 0;
          args[0] = args[0].replace(/%([a-zA-Z%])/g, (match, format) => {
            if (match === "%%") {
              return "%";
            }
            index++;
            const formatter = createDebug.formatters[format];
            if (typeof formatter === "function") {
              const val = args[index];
              match = formatter.call(self2, val);
              args.splice(index, 1);
              index--;
            }
            return match;
          });
          createDebug.formatArgs.call(self2, args);
          const logFn = self2.log || createDebug.log;
          logFn.apply(self2, args);
        }
        debug.namespace = namespace;
        debug.useColors = createDebug.useColors();
        debug.color = createDebug.selectColor(namespace);
        debug.extend = extend;
        debug.destroy = createDebug.destroy;
        Object.defineProperty(debug, "enabled", {
          enumerable: true,
          configurable: false,
          get: () => {
            if (enableOverride !== null) {
              return enableOverride;
            }
            if (namespacesCache !== createDebug.namespaces) {
              namespacesCache = createDebug.namespaces;
              enabledCache = createDebug.enabled(namespace);
            }
            return enabledCache;
          },
          set: (v) => {
            enableOverride = v;
          }
        });
        if (typeof createDebug.init === "function") {
          createDebug.init(debug);
        }
        return debug;
      }
      function extend(namespace, delimiter) {
        const newDebug = createDebug(this.namespace + (typeof delimiter === "undefined" ? ":" : delimiter) + namespace);
        newDebug.log = this.log;
        return newDebug;
      }
      function enable(namespaces) {
        createDebug.save(namespaces);
        createDebug.namespaces = namespaces;
        createDebug.names = [];
        createDebug.skips = [];
        let i;
        const split = (typeof namespaces === "string" ? namespaces : "").split(/[\s,]+/);
        const len = split.length;
        for (i = 0; i < len; i++) {
          if (!split[i]) {
            continue;
          }
          namespaces = split[i].replace(/\*/g, ".*?");
          if (namespaces[0] === "-") {
            createDebug.skips.push(new RegExp("^" + namespaces.slice(1) + "$"));
          } else {
            createDebug.names.push(new RegExp("^" + namespaces + "$"));
          }
        }
      }
      function disable() {
        const namespaces = [
          ...createDebug.names.map(toNamespace),
          ...createDebug.skips.map(toNamespace).map((namespace) => "-" + namespace)
        ].join(",");
        createDebug.enable("");
        return namespaces;
      }
      function enabled(name) {
        if (name[name.length - 1] === "*") {
          return true;
        }
        let i;
        let len;
        for (i = 0, len = createDebug.skips.length; i < len; i++) {
          if (createDebug.skips[i].test(name)) {
            return false;
          }
        }
        for (i = 0, len = createDebug.names.length; i < len; i++) {
          if (createDebug.names[i].test(name)) {
            return true;
          }
        }
        return false;
      }
      function toNamespace(regexp) {
        return regexp.toString().substring(2, regexp.toString().length - 2).replace(/\.\*\?$/, "*");
      }
      function coerce(val) {
        if (val instanceof Error) {
          return val.stack || val.message;
        }
        return val;
      }
      function destroy2() {
        console.warn("Instance method `debug.destroy()` is deprecated and no longer does anything. It will be removed in the next major version of `debug`.");
      }
      createDebug.enable(createDebug.load());
      return createDebug;
    }
    module2.exports = setup;
  }
});

// node_modules/debug/src/browser.js
var require_browser = __commonJS({
  "node_modules/debug/src/browser.js"(exports, module2) {
    exports.formatArgs = formatArgs;
    exports.save = save;
    exports.load = load;
    exports.useColors = useColors;
    exports.storage = localstorage();
    exports.destroy = (() => {
      let warned = false;
      return () => {
        if (!warned) {
          warned = true;
          console.warn("Instance method `debug.destroy()` is deprecated and no longer does anything. It will be removed in the next major version of `debug`.");
        }
      };
    })();
    exports.colors = [
      "#0000CC",
      "#0000FF",
      "#0033CC",
      "#0033FF",
      "#0066CC",
      "#0066FF",
      "#0099CC",
      "#0099FF",
      "#00CC00",
      "#00CC33",
      "#00CC66",
      "#00CC99",
      "#00CCCC",
      "#00CCFF",
      "#3300CC",
      "#3300FF",
      "#3333CC",
      "#3333FF",
      "#3366CC",
      "#3366FF",
      "#3399CC",
      "#3399FF",
      "#33CC00",
      "#33CC33",
      "#33CC66",
      "#33CC99",
      "#33CCCC",
      "#33CCFF",
      "#6600CC",
      "#6600FF",
      "#6633CC",
      "#6633FF",
      "#66CC00",
      "#66CC33",
      "#9900CC",
      "#9900FF",
      "#9933CC",
      "#9933FF",
      "#99CC00",
      "#99CC33",
      "#CC0000",
      "#CC0033",
      "#CC0066",
      "#CC0099",
      "#CC00CC",
      "#CC00FF",
      "#CC3300",
      "#CC3333",
      "#CC3366",
      "#CC3399",
      "#CC33CC",
      "#CC33FF",
      "#CC6600",
      "#CC6633",
      "#CC9900",
      "#CC9933",
      "#CCCC00",
      "#CCCC33",
      "#FF0000",
      "#FF0033",
      "#FF0066",
      "#FF0099",
      "#FF00CC",
      "#FF00FF",
      "#FF3300",
      "#FF3333",
      "#FF3366",
      "#FF3399",
      "#FF33CC",
      "#FF33FF",
      "#FF6600",
      "#FF6633",
      "#FF9900",
      "#FF9933",
      "#FFCC00",
      "#FFCC33"
    ];
    function useColors() {
      if (typeof window !== "undefined" && window.process && (window.process.type === "renderer" || window.process.__nwjs)) {
        return true;
      }
      if (typeof navigator !== "undefined" && navigator.userAgent && navigator.userAgent.toLowerCase().match(/(edge|trident)\/(\d+)/)) {
        return false;
      }
      return typeof document !== "undefined" && document.documentElement && document.documentElement.style && document.documentElement.style.WebkitAppearance || typeof window !== "undefined" && window.console && (window.console.firebug || window.console.exception && window.console.table) || typeof navigator !== "undefined" && navigator.userAgent && navigator.userAgent.toLowerCase().match(/firefox\/(\d+)/) && parseInt(RegExp.$1, 10) >= 31 || typeof navigator !== "undefined" && navigator.userAgent && navigator.userAgent.toLowerCase().match(/applewebkit\/(\d+)/);
    }
    function formatArgs(args) {
      args[0] = (this.useColors ? "%c" : "") + this.namespace + (this.useColors ? " %c" : " ") + args[0] + (this.useColors ? "%c " : " ") + "+" + module2.exports.humanize(this.diff);
      if (!this.useColors) {
        return;
      }
      const c = "color: " + this.color;
      args.splice(1, 0, c, "color: inherit");
      let index = 0;
      let lastC = 0;
      args[0].replace(/%[a-zA-Z%]/g, (match) => {
        if (match === "%%") {
          return;
        }
        index++;
        if (match === "%c") {
          lastC = index;
        }
      });
      args.splice(lastC, 0, c);
    }
    exports.log = console.debug || console.log || (() => {
    });
    function save(namespaces) {
      try {
        if (namespaces) {
          exports.storage.setItem("debug", namespaces);
        } else {
          exports.storage.removeItem("debug");
        }
      } catch (error) {
      }
    }
    function load() {
      let r;
      try {
        r = exports.storage.getItem("debug");
      } catch (error) {
      }
      if (!r && typeof process !== "undefined" && "env" in process) {
        r = process.env.DEBUG;
      }
      return r;
    }
    function localstorage() {
      try {
        return localStorage;
      } catch (error) {
      }
    }
    module2.exports = require_common()(exports);
    var { formatters } = module2.exports;
    formatters.j = function(v) {
      try {
        return JSON.stringify(v);
      } catch (error) {
        return "[UnexpectedJSONParseError]: " + error.message;
      }
    };
  }
});

// node_modules/debug/src/node.js
var require_node2 = __commonJS({
  "node_modules/debug/src/node.js"(exports, module2) {
    var tty = require("tty");
    var util = require("util");
    exports.init = init2;
    exports.log = log;
    exports.formatArgs = formatArgs;
    exports.save = save;
    exports.load = load;
    exports.useColors = useColors;
    exports.destroy = util.deprecate(() => {
    }, "Instance method `debug.destroy()` is deprecated and no longer does anything. It will be removed in the next major version of `debug`.");
    exports.colors = [6, 2, 3, 4, 5, 1];
    try {
      const supportsColor = require("supports-color");
      if (supportsColor && (supportsColor.stderr || supportsColor).level >= 2) {
        exports.colors = [
          20,
          21,
          26,
          27,
          32,
          33,
          38,
          39,
          40,
          41,
          42,
          43,
          44,
          45,
          56,
          57,
          62,
          63,
          68,
          69,
          74,
          75,
          76,
          77,
          78,
          79,
          80,
          81,
          92,
          93,
          98,
          99,
          112,
          113,
          128,
          129,
          134,
          135,
          148,
          149,
          160,
          161,
          162,
          163,
          164,
          165,
          166,
          167,
          168,
          169,
          170,
          171,
          172,
          173,
          178,
          179,
          184,
          185,
          196,
          197,
          198,
          199,
          200,
          201,
          202,
          203,
          204,
          205,
          206,
          207,
          208,
          209,
          214,
          215,
          220,
          221
        ];
      }
    } catch (error) {
    }
    exports.inspectOpts = Object.keys(process.env).filter((key) => {
      return /^debug_/i.test(key);
    }).reduce((obj, key) => {
      const prop = key.substring(6).toLowerCase().replace(/_([a-z])/g, (_, k) => {
        return k.toUpperCase();
      });
      let val = process.env[key];
      if (/^(yes|on|true|enabled)$/i.test(val)) {
        val = true;
      } else if (/^(no|off|false|disabled)$/i.test(val)) {
        val = false;
      } else if (val === "null") {
        val = null;
      } else {
        val = Number(val);
      }
      obj[prop] = val;
      return obj;
    }, {});
    function useColors() {
      return "colors" in exports.inspectOpts ? Boolean(exports.inspectOpts.colors) : tty.isatty(process.stderr.fd);
    }
    function formatArgs(args) {
      const { namespace: name, useColors: useColors2 } = this;
      if (useColors2) {
        const c = this.color;
        const colorCode = "\x1B[3" + (c < 8 ? c : "8;5;" + c);
        const prefix = `  ${colorCode};1m${name} \x1B[0m`;
        args[0] = prefix + args[0].split("\n").join("\n" + prefix);
        args.push(colorCode + "m+" + module2.exports.humanize(this.diff) + "\x1B[0m");
      } else {
        args[0] = getDate() + name + " " + args[0];
      }
    }
    function getDate() {
      if (exports.inspectOpts.hideDate) {
        return "";
      }
      return new Date().toISOString() + " ";
    }
    function log(...args) {
      return process.stderr.write(util.format(...args) + "\n");
    }
    function save(namespaces) {
      if (namespaces) {
        process.env.DEBUG = namespaces;
      } else {
        delete process.env.DEBUG;
      }
    }
    function load() {
      return process.env.DEBUG;
    }
    function init2(debug) {
      debug.inspectOpts = {};
      const keys = Object.keys(exports.inspectOpts);
      for (let i = 0; i < keys.length; i++) {
        debug.inspectOpts[keys[i]] = exports.inspectOpts[keys[i]];
      }
    }
    module2.exports = require_common()(exports);
    var { formatters } = module2.exports;
    formatters.o = function(v) {
      this.inspectOpts.colors = this.useColors;
      return util.inspect(v, this.inspectOpts).split("\n").map((str) => str.trim()).join(" ");
    };
    formatters.O = function(v) {
      this.inspectOpts.colors = this.useColors;
      return util.inspect(v, this.inspectOpts);
    };
  }
});

// node_modules/debug/src/index.js
var require_src = __commonJS({
  "node_modules/debug/src/index.js"(exports, module2) {
    if (typeof process === "undefined" || process.type === "renderer" || process.browser === true || process.__nwjs) {
      module2.exports = require_browser();
    } else {
      module2.exports = require_node2();
    }
  }
});

// node_modules/split-ca/index.js
var require_split_ca = __commonJS({
  "node_modules/split-ca/index.js"(exports, module2) {
    var fs2 = require("fs");
    module2.exports = function(filepath, split, encoding) {
      split = typeof split !== "undefined" ? split : "\n";
      encoding = typeof encoding !== "undefined" ? encoding : "utf8";
      var ca = [];
      var chain = fs2.readFileSync(filepath, encoding);
      if (chain.indexOf("-END CERTIFICATE-") < 0 || chain.indexOf("-BEGIN CERTIFICATE-") < 0) {
        throw Error("File does not contain 'BEGIN CERTIFICATE' or 'END CERTIFICATE'");
      }
      chain = chain.split(split);
      var cert = [];
      var _i, _len;
      for (_i = 0, _len = chain.length; _i < _len; _i++) {
        var line = chain[_i];
        if (!(line.length !== 0)) {
          continue;
        }
        cert.push(line);
        if (line.match(/-END CERTIFICATE-/)) {
          ca.push(cert.join(split));
          cert = [];
        }
      }
      return ca;
    };
  }
});

// node_modules/docker-modem/lib/modem.js
var require_modem = __commonJS({
  "node_modules/docker-modem/lib/modem.js"(exports, module2) {
    var querystring = require("querystring");
    var http = require_http();
    var fs2 = require("fs");
    var path2 = require("path");
    var url = require("url");
    var ssh = require_ssh();
    var HttpDuplex = require_http_duplex();
    var debug = require_src()("modem");
    var utils = require_utils();
    var util = require("util");
    var splitca = require_split_ca();
    var isWin = require("os").type() === "Windows_NT";
    var defaultOpts = function() {
      var host;
      var opts = {};
      if (!process.env.DOCKER_HOST) {
        opts.socketPath = isWin ? "//./pipe/docker_engine" : "/var/run/docker.sock";
      } else if (process.env.DOCKER_HOST.indexOf("unix://") === 0) {
        opts.socketPath = process.env.DOCKER_HOST.substring(7) || "/var/run/docker.sock";
      } else if (process.env.DOCKER_HOST.indexOf("npipe://") === 0) {
        opts.socketPath = process.env.DOCKER_HOST.substring(8) || "//./pipe/docker_engine";
      } else {
        var hostStr = process.env.DOCKER_HOST;
        if (hostStr.indexOf("//") < 0) {
          hostStr = "tcp://" + hostStr;
        }
        try {
          host = new url.URL(hostStr);
        } catch (err) {
          throw new Error("DOCKER_HOST env variable should be something like tcp://localhost:1234");
        }
        opts.port = host.port;
        if (process.env.DOCKER_TLS_VERIFY === "1" || opts.port === "2376") {
          opts.protocol = "https";
        } else if (host.protocol === "ssh:") {
          opts.protocol = "ssh";
          opts.username = host.username;
          opts.sshOptions = {
            agent: process.env.SSH_AUTH_SOCK
          };
        } else {
          opts.protocol = "http";
        }
        opts.host = host.hostname;
        if (process.env.DOCKER_CERT_PATH) {
          opts.ca = splitca(path2.join(process.env.DOCKER_CERT_PATH, "ca.pem"));
          opts.cert = fs2.readFileSync(path2.join(process.env.DOCKER_CERT_PATH, "cert.pem"));
          opts.key = fs2.readFileSync(path2.join(process.env.DOCKER_CERT_PATH, "key.pem"));
        }
        if (process.env.DOCKER_CLIENT_TIMEOUT) {
          opts.timeout = parseInt(process.env.DOCKER_CLIENT_TIMEOUT, 10);
        }
      }
      return opts;
    };
    var Modem = function(options) {
      var optDefaults = defaultOpts();
      var opts = Object.assign({}, optDefaults, options);
      this.host = opts.host;
      if (!this.host) {
        this.socketPath = opts.socketPath;
      }
      this.port = opts.port;
      this.username = opts.username;
      this.password = opts.password;
      this.version = opts.version;
      this.key = opts.key;
      this.cert = opts.cert;
      this.ca = opts.ca;
      this.timeout = opts.timeout;
      this.connectionTimeout = opts.connectionTimeout;
      this.checkServerIdentity = opts.checkServerIdentity;
      this.agent = opts.agent;
      this.headers = opts.headers || {};
      this.sshOptions = Object.assign({}, options ? options.sshOptions : {}, optDefaults.sshOptions);
      if (this.sshOptions.agentForward === void 0) {
        this.sshOptions.agentForward = opts.agentForward;
      }
      if (this.key && this.cert && this.ca) {
        this.protocol = "https";
      }
      this.protocol = opts.protocol || this.protocol || "http";
    };
    Modem.prototype.dial = function(options, callback) {
      var opts, address, data;
      var self2 = this;
      if (options.options) {
        opts = options.options;
      }
      if (opts && opts.authconfig) {
        delete opts.authconfig;
      }
      if (opts && opts.abortSignal) {
        delete opts.abortSignal;
      }
      if (this.version) {
        options.path = "/" + this.version + options.path;
      }
      if (this.host) {
        var parsed = url.parse(self2.host);
        address = url.format({
          "protocol": parsed.protocol || self2.protocol,
          "hostname": parsed.hostname || self2.host,
          "port": self2.port
        });
        address = url.resolve(address, options.path);
      } else {
        address = options.path;
      }
      if (options.path.indexOf("?") !== -1) {
        if (opts && Object.keys(opts).length > 0) {
          address += this.buildQuerystring(opts._query || opts);
        } else {
          address = address.substring(0, address.length - 1);
        }
      }
      var optionsf = {
        path: address,
        method: options.method,
        headers: options.headers || Object.assign({}, self2.headers),
        key: self2.key,
        cert: self2.cert,
        ca: self2.ca
      };
      if (this.checkServerIdentity) {
        optionsf.checkServerIdentity = this.checkServerIdentity;
      }
      if (this.agent) {
        optionsf.agent = this.agent;
      }
      if (options.authconfig) {
        optionsf.headers["X-Registry-Auth"] = options.authconfig.key || options.authconfig.base64 || Buffer.from(JSON.stringify(options.authconfig)).toString("base64").replace(/\+/g, "-").replace(/\//g, "_");
      }
      if (options.registryconfig) {
        optionsf.headers["X-Registry-Config"] = options.registryconfig.base64 || Buffer.from(JSON.stringify(options.registryconfig)).toString("base64");
      }
      if (options.abortSignal) {
        optionsf.signal = options.abortSignal;
      }
      if (options.file) {
        if (typeof options.file === "string") {
          data = fs2.createReadStream(path2.resolve(options.file));
        } else {
          data = options.file;
        }
        optionsf.headers["Content-Type"] = "application/tar";
      } else if (opts && options.method === "POST") {
        data = JSON.stringify(opts._body || opts);
        if (options.allowEmpty) {
          optionsf.headers["Content-Type"] = "application/json";
        } else {
          if (data !== "{}" && data !== '""') {
            optionsf.headers["Content-Type"] = "application/json";
          } else {
            data = void 0;
          }
        }
      }
      if (typeof data === "string") {
        optionsf.headers["Content-Length"] = Buffer.byteLength(data);
      } else if (Buffer.isBuffer(data) === true) {
        optionsf.headers["Content-Length"] = data.length;
      } else if (optionsf.method === "PUT" || options.hijack || options.openStdin) {
        optionsf.headers["Transfer-Encoding"] = "chunked";
      }
      if (options.hijack) {
        optionsf.headers.Connection = "Upgrade";
        optionsf.headers.Upgrade = "tcp";
      }
      if (this.socketPath) {
        optionsf.socketPath = this.socketPath;
      } else {
        var urlp = url.parse(address);
        optionsf.hostname = urlp.hostname;
        optionsf.port = urlp.port;
        optionsf.path = urlp.path;
      }
      this.buildRequest(optionsf, options, data, callback);
    };
    Modem.prototype.buildRequest = function(options, context, data, callback) {
      var self2 = this;
      var connectionTimeoutTimer;
      var opts = self2.protocol === "ssh" ? Object.assign(options, {
        agent: ssh(Object.assign({}, self2.sshOptions, {
          "host": self2.host,
          "port": self2.port,
          "username": self2.username,
          "password": self2.password
        })),
        protocol: "http:"
      }) : options;
      var req = http[self2.protocol === "ssh" ? "http" : self2.protocol].request(opts, function() {
      });
      debug("Sending: %s", util.inspect(options, {
        showHidden: true,
        depth: null
      }));
      if (self2.connectionTimeout) {
        connectionTimeoutTimer = setTimeout(function() {
          debug("Connection Timeout of %s ms exceeded", self2.connectionTimeout);
          req.abort();
        }, self2.connectionTimeout);
      }
      if (self2.timeout) {
        req.on("socket", function(socket) {
          socket.setTimeout(self2.timeout);
          socket.on("timeout", function() {
            debug("Timeout of %s ms exceeded", self2.timeout);
            req.abort();
          });
        });
      }
      if (context.hijack === true) {
        clearTimeout(connectionTimeoutTimer);
        req.on("upgrade", function(res, sock, head) {
          return callback(null, sock);
        });
      }
      req.on("connect", function() {
        clearTimeout(connectionTimeoutTimer);
      });
      req.on("disconnect", function() {
        clearTimeout(connectionTimeoutTimer);
      });
      req.on("response", function(res) {
        clearTimeout(connectionTimeoutTimer);
        if (context.isStream === true) {
          self2.buildPayload(null, context.isStream, context.statusCodes, context.openStdin, req, res, null, callback);
        } else {
          var chunks = [];
          res.on("data", function(chunk) {
            chunks.push(chunk);
          });
          res.on("end", function() {
            var buffer = Buffer.concat(chunks);
            var result = buffer.toString();
            debug("Received: %s", result);
            var json = utils.parseJSON(result) || buffer;
            self2.buildPayload(null, context.isStream, context.statusCodes, false, req, res, json, callback);
          });
        }
      });
      req.on("error", function(error) {
        clearTimeout(connectionTimeoutTimer);
        self2.buildPayload(error, context.isStream, context.statusCodes, false, {}, {}, null, callback);
      });
      if (typeof data === "string" || Buffer.isBuffer(data)) {
        req.write(data);
      } else if (data) {
        data.on("error", function(error) {
          req.destroy(error);
        });
        data.pipe(req);
      }
      if (!context.hijack && !context.openStdin && (typeof data === "string" || data === void 0 || Buffer.isBuffer(data))) {
        req.end();
      }
    };
    Modem.prototype.buildPayload = function(err, isStream, statusCodes, openStdin, req, res, json, cb) {
      if (err)
        return cb(err, null);
      if (statusCodes[res.statusCode] !== true) {
        getCause(isStream, res, json, function(err2, cause) {
          var msg = new Error("(HTTP code " + res.statusCode + ") " + (statusCodes[res.statusCode] || "unexpected") + " - " + (cause.message || cause) + " ");
          msg.reason = statusCodes[res.statusCode];
          msg.statusCode = res.statusCode;
          msg.json = json;
          cb(msg, null);
        });
      } else {
        if (openStdin) {
          cb(null, new HttpDuplex(req, res));
        } else if (isStream) {
          cb(null, res);
        } else {
          cb(null, json);
        }
      }
      function getCause(isStream2, res2, json2, callback) {
        var chunks = "";
        if (isStream2) {
          res2.on("data", function(chunk) {
            chunks += chunk;
          });
          res2.on("end", function() {
            callback(null, utils.parseJSON(chunks) || chunks);
          });
        } else {
          callback(null, json2);
        }
      }
    };
    Modem.prototype.demuxStream = function(stream, stdout, stderr) {
      var nextDataType = null;
      var nextDataLength = null;
      var buffer = Buffer.from("");
      function processData(data) {
        if (data) {
          buffer = Buffer.concat([buffer, data]);
        }
        if (!nextDataType) {
          if (buffer.length >= 8) {
            var header = bufferSlice(8);
            nextDataType = header.readUInt8(0);
            nextDataLength = header.readUInt32BE(4);
            processData();
          }
        } else {
          if (buffer.length >= nextDataLength) {
            var content = bufferSlice(nextDataLength);
            if (nextDataType === 1) {
              stdout.write(content);
            } else {
              stderr.write(content);
            }
            nextDataType = null;
            processData();
          }
        }
      }
      function bufferSlice(end) {
        var out = buffer.slice(0, end);
        buffer = Buffer.from(buffer.slice(end, buffer.length));
        return out;
      }
      stream.on("data", processData);
    };
    Modem.prototype.followProgress = function(stream, onFinished, onProgress) {
      var buf = "";
      var output = [];
      var finished = false;
      stream.on("data", onStreamEvent);
      stream.on("error", onStreamError);
      stream.on("end", onStreamEnd);
      stream.on("close", onStreamEnd);
      function onStreamEvent(data) {
        buf += data.toString();
        pump();
        function pump() {
          var pos;
          while ((pos = buf.indexOf("\n")) >= 0) {
            if (pos == 0) {
              buf = buf.slice(1);
              continue;
            }
            processLine(buf.slice(0, pos));
            buf = buf.slice(pos + 1);
          }
        }
        function processLine(line) {
          if (line[line.length - 1] == "\r")
            line = line.substr(0, line.length - 1);
          if (line.length > 0) {
            var obj = JSON.parse(line);
            output.push(obj);
            if (onProgress) {
              onProgress(obj);
            }
          }
        }
      }
      ;
      function onStreamError(err) {
        finished = true;
        stream.removeListener("data", onStreamEvent);
        stream.removeListener("error", onStreamError);
        stream.removeListener("end", onStreamEnd);
        stream.removeListener("close", onStreamEnd);
        onFinished(err, output);
      }
      function onStreamEnd() {
        if (!finished)
          onFinished(null, output);
        finished = true;
      }
    };
    Modem.prototype.buildQuerystring = function(opts) {
      var clone = {};
      Object.keys(opts).map(function(key, i) {
        if (opts[key] && typeof opts[key] === "object" && !["t", "extrahosts"].includes(key)) {
          clone[key] = JSON.stringify(opts[key]);
        } else {
          clone[key] = opts[key];
        }
      });
      return querystring.stringify(clone);
    };
    module2.exports = Modem;
  }
});

// node_modules/chownr/chownr.js
var require_chownr = __commonJS({
  "node_modules/chownr/chownr.js"(exports, module2) {
    "use strict";
    var fs2 = require("fs");
    var path2 = require("path");
    var LCHOWN = fs2.lchown ? "lchown" : "chown";
    var LCHOWNSYNC = fs2.lchownSync ? "lchownSync" : "chownSync";
    var needEISDIRHandled = fs2.lchown && !process.version.match(/v1[1-9]+\./) && !process.version.match(/v10\.[6-9]/);
    var lchownSync = (path3, uid, gid) => {
      try {
        return fs2[LCHOWNSYNC](path3, uid, gid);
      } catch (er) {
        if (er.code !== "ENOENT")
          throw er;
      }
    };
    var chownSync = (path3, uid, gid) => {
      try {
        return fs2.chownSync(path3, uid, gid);
      } catch (er) {
        if (er.code !== "ENOENT")
          throw er;
      }
    };
    var handleEISDIR = needEISDIRHandled ? (path3, uid, gid, cb) => (er) => {
      if (!er || er.code !== "EISDIR")
        cb(er);
      else
        fs2.chown(path3, uid, gid, cb);
    } : (_, __, ___, cb) => cb;
    var handleEISDirSync = needEISDIRHandled ? (path3, uid, gid) => {
      try {
        return lchownSync(path3, uid, gid);
      } catch (er) {
        if (er.code !== "EISDIR")
          throw er;
        chownSync(path3, uid, gid);
      }
    } : (path3, uid, gid) => lchownSync(path3, uid, gid);
    var nodeVersion = process.version;
    var readdir = (path3, options, cb) => fs2.readdir(path3, options, cb);
    var readdirSync = (path3, options) => fs2.readdirSync(path3, options);
    if (/^v4\./.test(nodeVersion))
      readdir = (path3, options, cb) => fs2.readdir(path3, cb);
    var chown = (cpath, uid, gid, cb) => {
      fs2[LCHOWN](cpath, uid, gid, handleEISDIR(cpath, uid, gid, (er) => {
        cb(er && er.code !== "ENOENT" ? er : null);
      }));
    };
    var chownrKid = (p, child, uid, gid, cb) => {
      if (typeof child === "string")
        return fs2.lstat(path2.resolve(p, child), (er, stats) => {
          if (er)
            return cb(er.code !== "ENOENT" ? er : null);
          stats.name = child;
          chownrKid(p, stats, uid, gid, cb);
        });
      if (child.isDirectory()) {
        chownr(path2.resolve(p, child.name), uid, gid, (er) => {
          if (er)
            return cb(er);
          const cpath = path2.resolve(p, child.name);
          chown(cpath, uid, gid, cb);
        });
      } else {
        const cpath = path2.resolve(p, child.name);
        chown(cpath, uid, gid, cb);
      }
    };
    var chownr = (p, uid, gid, cb) => {
      readdir(p, { withFileTypes: true }, (er, children) => {
        if (er) {
          if (er.code === "ENOENT")
            return cb();
          else if (er.code !== "ENOTDIR" && er.code !== "ENOTSUP")
            return cb(er);
        }
        if (er || !children.length)
          return chown(p, uid, gid, cb);
        let len = children.length;
        let errState = null;
        const then = (er2) => {
          if (errState)
            return;
          if (er2)
            return cb(errState = er2);
          if (--len === 0)
            return chown(p, uid, gid, cb);
        };
        children.forEach((child) => chownrKid(p, child, uid, gid, then));
      });
    };
    var chownrKidSync = (p, child, uid, gid) => {
      if (typeof child === "string") {
        try {
          const stats = fs2.lstatSync(path2.resolve(p, child));
          stats.name = child;
          child = stats;
        } catch (er) {
          if (er.code === "ENOENT")
            return;
          else
            throw er;
        }
      }
      if (child.isDirectory())
        chownrSync(path2.resolve(p, child.name), uid, gid);
      handleEISDirSync(path2.resolve(p, child.name), uid, gid);
    };
    var chownrSync = (p, uid, gid) => {
      let children;
      try {
        children = readdirSync(p, { withFileTypes: true });
      } catch (er) {
        if (er.code === "ENOENT")
          return;
        else if (er.code === "ENOTDIR" || er.code === "ENOTSUP")
          return handleEISDirSync(p, uid, gid);
        else
          throw er;
      }
      if (children && children.length)
        children.forEach((child) => chownrKidSync(p, child, uid, gid));
      return handleEISDirSync(p, uid, gid);
    };
    module2.exports = chownr;
    chownr.sync = chownrSync;
  }
});

// node_modules/bl/BufferList.js
var require_BufferList = __commonJS({
  "node_modules/bl/BufferList.js"(exports, module2) {
    "use strict";
    var { Buffer: Buffer2 } = require("buffer");
    var symbol = Symbol.for("BufferList");
    function BufferList(buf) {
      if (!(this instanceof BufferList)) {
        return new BufferList(buf);
      }
      BufferList._init.call(this, buf);
    }
    BufferList._init = function _init(buf) {
      Object.defineProperty(this, symbol, { value: true });
      this._bufs = [];
      this.length = 0;
      if (buf) {
        this.append(buf);
      }
    };
    BufferList.prototype._new = function _new(buf) {
      return new BufferList(buf);
    };
    BufferList.prototype._offset = function _offset(offset) {
      if (offset === 0) {
        return [0, 0];
      }
      let tot = 0;
      for (let i = 0; i < this._bufs.length; i++) {
        const _t = tot + this._bufs[i].length;
        if (offset < _t || i === this._bufs.length - 1) {
          return [i, offset - tot];
        }
        tot = _t;
      }
    };
    BufferList.prototype._reverseOffset = function(blOffset) {
      const bufferId = blOffset[0];
      let offset = blOffset[1];
      for (let i = 0; i < bufferId; i++) {
        offset += this._bufs[i].length;
      }
      return offset;
    };
    BufferList.prototype.get = function get(index) {
      if (index > this.length || index < 0) {
        return void 0;
      }
      const offset = this._offset(index);
      return this._bufs[offset[0]][offset[1]];
    };
    BufferList.prototype.slice = function slice(start, end) {
      if (typeof start === "number" && start < 0) {
        start += this.length;
      }
      if (typeof end === "number" && end < 0) {
        end += this.length;
      }
      return this.copy(null, 0, start, end);
    };
    BufferList.prototype.copy = function copy(dst, dstStart, srcStart, srcEnd) {
      if (typeof srcStart !== "number" || srcStart < 0) {
        srcStart = 0;
      }
      if (typeof srcEnd !== "number" || srcEnd > this.length) {
        srcEnd = this.length;
      }
      if (srcStart >= this.length) {
        return dst || Buffer2.alloc(0);
      }
      if (srcEnd <= 0) {
        return dst || Buffer2.alloc(0);
      }
      const copy2 = !!dst;
      const off = this._offset(srcStart);
      const len = srcEnd - srcStart;
      let bytes = len;
      let bufoff = copy2 && dstStart || 0;
      let start = off[1];
      if (srcStart === 0 && srcEnd === this.length) {
        if (!copy2) {
          return this._bufs.length === 1 ? this._bufs[0] : Buffer2.concat(this._bufs, this.length);
        }
        for (let i = 0; i < this._bufs.length; i++) {
          this._bufs[i].copy(dst, bufoff);
          bufoff += this._bufs[i].length;
        }
        return dst;
      }
      if (bytes <= this._bufs[off[0]].length - start) {
        return copy2 ? this._bufs[off[0]].copy(dst, dstStart, start, start + bytes) : this._bufs[off[0]].slice(start, start + bytes);
      }
      if (!copy2) {
        dst = Buffer2.allocUnsafe(len);
      }
      for (let i = off[0]; i < this._bufs.length; i++) {
        const l = this._bufs[i].length - start;
        if (bytes > l) {
          this._bufs[i].copy(dst, bufoff, start);
          bufoff += l;
        } else {
          this._bufs[i].copy(dst, bufoff, start, start + bytes);
          bufoff += l;
          break;
        }
        bytes -= l;
        if (start) {
          start = 0;
        }
      }
      if (dst.length > bufoff)
        return dst.slice(0, bufoff);
      return dst;
    };
    BufferList.prototype.shallowSlice = function shallowSlice(start, end) {
      start = start || 0;
      end = typeof end !== "number" ? this.length : end;
      if (start < 0) {
        start += this.length;
      }
      if (end < 0) {
        end += this.length;
      }
      if (start === end) {
        return this._new();
      }
      const startOffset = this._offset(start);
      const endOffset = this._offset(end);
      const buffers = this._bufs.slice(startOffset[0], endOffset[0] + 1);
      if (endOffset[1] === 0) {
        buffers.pop();
      } else {
        buffers[buffers.length - 1] = buffers[buffers.length - 1].slice(0, endOffset[1]);
      }
      if (startOffset[1] !== 0) {
        buffers[0] = buffers[0].slice(startOffset[1]);
      }
      return this._new(buffers);
    };
    BufferList.prototype.toString = function toString(encoding, start, end) {
      return this.slice(start, end).toString(encoding);
    };
    BufferList.prototype.consume = function consume(bytes) {
      bytes = Math.trunc(bytes);
      if (Number.isNaN(bytes) || bytes <= 0)
        return this;
      while (this._bufs.length) {
        if (bytes >= this._bufs[0].length) {
          bytes -= this._bufs[0].length;
          this.length -= this._bufs[0].length;
          this._bufs.shift();
        } else {
          this._bufs[0] = this._bufs[0].slice(bytes);
          this.length -= bytes;
          break;
        }
      }
      return this;
    };
    BufferList.prototype.duplicate = function duplicate() {
      const copy = this._new();
      for (let i = 0; i < this._bufs.length; i++) {
        copy.append(this._bufs[i]);
      }
      return copy;
    };
    BufferList.prototype.append = function append(buf) {
      if (buf == null) {
        return this;
      }
      if (buf.buffer) {
        this._appendBuffer(Buffer2.from(buf.buffer, buf.byteOffset, buf.byteLength));
      } else if (Array.isArray(buf)) {
        for (let i = 0; i < buf.length; i++) {
          this.append(buf[i]);
        }
      } else if (this._isBufferList(buf)) {
        for (let i = 0; i < buf._bufs.length; i++) {
          this.append(buf._bufs[i]);
        }
      } else {
        if (typeof buf === "number") {
          buf = buf.toString();
        }
        this._appendBuffer(Buffer2.from(buf));
      }
      return this;
    };
    BufferList.prototype._appendBuffer = function appendBuffer(buf) {
      this._bufs.push(buf);
      this.length += buf.length;
    };
    BufferList.prototype.indexOf = function(search, offset, encoding) {
      if (encoding === void 0 && typeof offset === "string") {
        encoding = offset;
        offset = void 0;
      }
      if (typeof search === "function" || Array.isArray(search)) {
        throw new TypeError('The "value" argument must be one of type string, Buffer, BufferList, or Uint8Array.');
      } else if (typeof search === "number") {
        search = Buffer2.from([search]);
      } else if (typeof search === "string") {
        search = Buffer2.from(search, encoding);
      } else if (this._isBufferList(search)) {
        search = search.slice();
      } else if (Array.isArray(search.buffer)) {
        search = Buffer2.from(search.buffer, search.byteOffset, search.byteLength);
      } else if (!Buffer2.isBuffer(search)) {
        search = Buffer2.from(search);
      }
      offset = Number(offset || 0);
      if (isNaN(offset)) {
        offset = 0;
      }
      if (offset < 0) {
        offset = this.length + offset;
      }
      if (offset < 0) {
        offset = 0;
      }
      if (search.length === 0) {
        return offset > this.length ? this.length : offset;
      }
      const blOffset = this._offset(offset);
      let blIndex = blOffset[0];
      let buffOffset = blOffset[1];
      for (; blIndex < this._bufs.length; blIndex++) {
        const buff = this._bufs[blIndex];
        while (buffOffset < buff.length) {
          const availableWindow = buff.length - buffOffset;
          if (availableWindow >= search.length) {
            const nativeSearchResult = buff.indexOf(search, buffOffset);
            if (nativeSearchResult !== -1) {
              return this._reverseOffset([blIndex, nativeSearchResult]);
            }
            buffOffset = buff.length - search.length + 1;
          } else {
            const revOffset = this._reverseOffset([blIndex, buffOffset]);
            if (this._match(revOffset, search)) {
              return revOffset;
            }
            buffOffset++;
          }
        }
        buffOffset = 0;
      }
      return -1;
    };
    BufferList.prototype._match = function(offset, search) {
      if (this.length - offset < search.length) {
        return false;
      }
      for (let searchOffset = 0; searchOffset < search.length; searchOffset++) {
        if (this.get(offset + searchOffset) !== search[searchOffset]) {
          return false;
        }
      }
      return true;
    };
    (function() {
      const methods = {
        readDoubleBE: 8,
        readDoubleLE: 8,
        readFloatBE: 4,
        readFloatLE: 4,
        readInt32BE: 4,
        readInt32LE: 4,
        readUInt32BE: 4,
        readUInt32LE: 4,
        readInt16BE: 2,
        readInt16LE: 2,
        readUInt16BE: 2,
        readUInt16LE: 2,
        readInt8: 1,
        readUInt8: 1,
        readIntBE: null,
        readIntLE: null,
        readUIntBE: null,
        readUIntLE: null
      };
      for (const m in methods) {
        (function(m2) {
          if (methods[m2] === null) {
            BufferList.prototype[m2] = function(offset, byteLength) {
              return this.slice(offset, offset + byteLength)[m2](0, byteLength);
            };
          } else {
            BufferList.prototype[m2] = function(offset = 0) {
              return this.slice(offset, offset + methods[m2])[m2](0);
            };
          }
        })(m);
      }
    })();
    BufferList.prototype._isBufferList = function _isBufferList(b) {
      return b instanceof BufferList || BufferList.isBufferList(b);
    };
    BufferList.isBufferList = function isBufferList(b) {
      return b != null && b[symbol];
    };
    module2.exports = BufferList;
  }
});

// node_modules/bl/bl.js
var require_bl = __commonJS({
  "node_modules/bl/bl.js"(exports, module2) {
    "use strict";
    var DuplexStream = require_readable().Duplex;
    var inherits = require_inherits();
    var BufferList = require_BufferList();
    function BufferListStream(callback) {
      if (!(this instanceof BufferListStream)) {
        return new BufferListStream(callback);
      }
      if (typeof callback === "function") {
        this._callback = callback;
        const piper = function piper2(err) {
          if (this._callback) {
            this._callback(err);
            this._callback = null;
          }
        }.bind(this);
        this.on("pipe", function onPipe(src) {
          src.on("error", piper);
        });
        this.on("unpipe", function onUnpipe(src) {
          src.removeListener("error", piper);
        });
        callback = null;
      }
      BufferList._init.call(this, callback);
      DuplexStream.call(this);
    }
    inherits(BufferListStream, DuplexStream);
    Object.assign(BufferListStream.prototype, BufferList.prototype);
    BufferListStream.prototype._new = function _new(callback) {
      return new BufferListStream(callback);
    };
    BufferListStream.prototype._write = function _write(buf, encoding, callback) {
      this._appendBuffer(buf);
      if (typeof callback === "function") {
        callback();
      }
    };
    BufferListStream.prototype._read = function _read(size) {
      if (!this.length) {
        return this.push(null);
      }
      size = Math.min(size, this.length);
      this.push(this.slice(0, size));
      this.consume(size);
    };
    BufferListStream.prototype.end = function end(chunk) {
      DuplexStream.prototype.end.call(this, chunk);
      if (this._callback) {
        this._callback(null, this.slice());
        this._callback = null;
      }
    };
    BufferListStream.prototype._destroy = function _destroy(err, cb) {
      this._bufs.length = 0;
      this.length = 0;
      cb(err);
    };
    BufferListStream.prototype._isBufferList = function _isBufferList(b) {
      return b instanceof BufferListStream || b instanceof BufferList || BufferListStream.isBufferList(b);
    };
    BufferListStream.isBufferList = BufferList.isBufferList;
    module2.exports = BufferListStream;
    module2.exports.BufferListStream = BufferListStream;
    module2.exports.BufferList = BufferList;
  }
});

// node_modules/tar-stream/headers.js
var require_headers = __commonJS({
  "node_modules/tar-stream/headers.js"(exports) {
    var alloc = Buffer.alloc;
    var ZEROS = "0000000000000000000";
    var SEVENS = "7777777777777777777";
    var ZERO_OFFSET = "0".charCodeAt(0);
    var USTAR_MAGIC = Buffer.from("ustar\0", "binary");
    var USTAR_VER = Buffer.from("00", "binary");
    var GNU_MAGIC = Buffer.from("ustar ", "binary");
    var GNU_VER = Buffer.from(" \0", "binary");
    var MASK = parseInt("7777", 8);
    var MAGIC_OFFSET = 257;
    var VERSION_OFFSET = 263;
    var clamp = function(index, len, defaultValue) {
      if (typeof index !== "number")
        return defaultValue;
      index = ~~index;
      if (index >= len)
        return len;
      if (index >= 0)
        return index;
      index += len;
      if (index >= 0)
        return index;
      return 0;
    };
    var toType = function(flag) {
      switch (flag) {
        case 0:
          return "file";
        case 1:
          return "link";
        case 2:
          return "symlink";
        case 3:
          return "character-device";
        case 4:
          return "block-device";
        case 5:
          return "directory";
        case 6:
          return "fifo";
        case 7:
          return "contiguous-file";
        case 72:
          return "pax-header";
        case 55:
          return "pax-global-header";
        case 27:
          return "gnu-long-link-path";
        case 28:
        case 30:
          return "gnu-long-path";
      }
      return null;
    };
    var toTypeflag = function(flag) {
      switch (flag) {
        case "file":
          return 0;
        case "link":
          return 1;
        case "symlink":
          return 2;
        case "character-device":
          return 3;
        case "block-device":
          return 4;
        case "directory":
          return 5;
        case "fifo":
          return 6;
        case "contiguous-file":
          return 7;
        case "pax-header":
          return 72;
      }
      return 0;
    };
    var indexOf = function(block, num, offset, end) {
      for (; offset < end; offset++) {
        if (block[offset] === num)
          return offset;
      }
      return end;
    };
    var cksum = function(block) {
      var sum = 8 * 32;
      for (var i = 0; i < 148; i++)
        sum += block[i];
      for (var j = 156; j < 512; j++)
        sum += block[j];
      return sum;
    };
    var encodeOct = function(val, n) {
      val = val.toString(8);
      if (val.length > n)
        return SEVENS.slice(0, n) + " ";
      else
        return ZEROS.slice(0, n - val.length) + val + " ";
    };
    function parse256(buf) {
      var positive;
      if (buf[0] === 128)
        positive = true;
      else if (buf[0] === 255)
        positive = false;
      else
        return null;
      var tuple = [];
      for (var i = buf.length - 1; i > 0; i--) {
        var byte = buf[i];
        if (positive)
          tuple.push(byte);
        else
          tuple.push(255 - byte);
      }
      var sum = 0;
      var l = tuple.length;
      for (i = 0; i < l; i++) {
        sum += tuple[i] * Math.pow(256, i);
      }
      return positive ? sum : -1 * sum;
    }
    var decodeOct = function(val, offset, length) {
      val = val.slice(offset, offset + length);
      offset = 0;
      if (val[offset] & 128) {
        return parse256(val);
      } else {
        while (offset < val.length && val[offset] === 32)
          offset++;
        var end = clamp(indexOf(val, 32, offset, val.length), val.length, val.length);
        while (offset < end && val[offset] === 0)
          offset++;
        if (end === offset)
          return 0;
        return parseInt(val.slice(offset, end).toString(), 8);
      }
    };
    var decodeStr = function(val, offset, length, encoding) {
      return val.slice(offset, indexOf(val, 0, offset, offset + length)).toString(encoding);
    };
    var addLength = function(str) {
      var len = Buffer.byteLength(str);
      var digits = Math.floor(Math.log(len) / Math.log(10)) + 1;
      if (len + digits >= Math.pow(10, digits))
        digits++;
      return len + digits + str;
    };
    exports.decodeLongPath = function(buf, encoding) {
      return decodeStr(buf, 0, buf.length, encoding);
    };
    exports.encodePax = function(opts) {
      var result = "";
      if (opts.name)
        result += addLength(" path=" + opts.name + "\n");
      if (opts.linkname)
        result += addLength(" linkpath=" + opts.linkname + "\n");
      var pax = opts.pax;
      if (pax) {
        for (var key in pax) {
          result += addLength(" " + key + "=" + pax[key] + "\n");
        }
      }
      return Buffer.from(result);
    };
    exports.decodePax = function(buf) {
      var result = {};
      while (buf.length) {
        var i = 0;
        while (i < buf.length && buf[i] !== 32)
          i++;
        var len = parseInt(buf.slice(0, i).toString(), 10);
        if (!len)
          return result;
        var b = buf.slice(i + 1, len - 1).toString();
        var keyIndex = b.indexOf("=");
        if (keyIndex === -1)
          return result;
        result[b.slice(0, keyIndex)] = b.slice(keyIndex + 1);
        buf = buf.slice(len);
      }
      return result;
    };
    exports.encode = function(opts) {
      var buf = alloc(512);
      var name = opts.name;
      var prefix = "";
      if (opts.typeflag === 5 && name[name.length - 1] !== "/")
        name += "/";
      if (Buffer.byteLength(name) !== name.length)
        return null;
      while (Buffer.byteLength(name) > 100) {
        var i = name.indexOf("/");
        if (i === -1)
          return null;
        prefix += prefix ? "/" + name.slice(0, i) : name.slice(0, i);
        name = name.slice(i + 1);
      }
      if (Buffer.byteLength(name) > 100 || Buffer.byteLength(prefix) > 155)
        return null;
      if (opts.linkname && Buffer.byteLength(opts.linkname) > 100)
        return null;
      buf.write(name);
      buf.write(encodeOct(opts.mode & MASK, 6), 100);
      buf.write(encodeOct(opts.uid, 6), 108);
      buf.write(encodeOct(opts.gid, 6), 116);
      buf.write(encodeOct(opts.size, 11), 124);
      buf.write(encodeOct(opts.mtime.getTime() / 1e3 | 0, 11), 136);
      buf[156] = ZERO_OFFSET + toTypeflag(opts.type);
      if (opts.linkname)
        buf.write(opts.linkname, 157);
      USTAR_MAGIC.copy(buf, MAGIC_OFFSET);
      USTAR_VER.copy(buf, VERSION_OFFSET);
      if (opts.uname)
        buf.write(opts.uname, 265);
      if (opts.gname)
        buf.write(opts.gname, 297);
      buf.write(encodeOct(opts.devmajor || 0, 6), 329);
      buf.write(encodeOct(opts.devminor || 0, 6), 337);
      if (prefix)
        buf.write(prefix, 345);
      buf.write(encodeOct(cksum(buf), 6), 148);
      return buf;
    };
    exports.decode = function(buf, filenameEncoding, allowUnknownFormat) {
      var typeflag = buf[156] === 0 ? 0 : buf[156] - ZERO_OFFSET;
      var name = decodeStr(buf, 0, 100, filenameEncoding);
      var mode = decodeOct(buf, 100, 8);
      var uid = decodeOct(buf, 108, 8);
      var gid = decodeOct(buf, 116, 8);
      var size = decodeOct(buf, 124, 12);
      var mtime = decodeOct(buf, 136, 12);
      var type = toType(typeflag);
      var linkname = buf[157] === 0 ? null : decodeStr(buf, 157, 100, filenameEncoding);
      var uname = decodeStr(buf, 265, 32);
      var gname = decodeStr(buf, 297, 32);
      var devmajor = decodeOct(buf, 329, 8);
      var devminor = decodeOct(buf, 337, 8);
      var c = cksum(buf);
      if (c === 8 * 32)
        return null;
      if (c !== decodeOct(buf, 148, 8))
        throw new Error("Invalid tar header. Maybe the tar is corrupted or it needs to be gunzipped?");
      if (USTAR_MAGIC.compare(buf, MAGIC_OFFSET, MAGIC_OFFSET + 6) === 0) {
        if (buf[345])
          name = decodeStr(buf, 345, 155, filenameEncoding) + "/" + name;
      } else if (GNU_MAGIC.compare(buf, MAGIC_OFFSET, MAGIC_OFFSET + 6) === 0 && GNU_VER.compare(buf, VERSION_OFFSET, VERSION_OFFSET + 2) === 0) {
      } else {
        if (!allowUnknownFormat) {
          throw new Error("Invalid tar header: unknown format.");
        }
      }
      if (typeflag === 0 && name && name[name.length - 1] === "/")
        typeflag = 5;
      return {
        name,
        mode,
        uid,
        gid,
        size,
        mtime: new Date(1e3 * mtime),
        type,
        linkname,
        uname,
        gname,
        devmajor,
        devminor
      };
    };
  }
});

// node_modules/tar-stream/extract.js
var require_extract = __commonJS({
  "node_modules/tar-stream/extract.js"(exports, module2) {
    var util = require("util");
    var bl = require_bl();
    var headers = require_headers();
    var Writable = require_readable().Writable;
    var PassThrough = require_readable().PassThrough;
    var noop = function() {
    };
    var overflow = function(size) {
      size &= 511;
      return size && 512 - size;
    };
    var emptyStream = function(self2, offset) {
      var s = new Source(self2, offset);
      s.end();
      return s;
    };
    var mixinPax = function(header, pax) {
      if (pax.path)
        header.name = pax.path;
      if (pax.linkpath)
        header.linkname = pax.linkpath;
      if (pax.size)
        header.size = parseInt(pax.size, 10);
      header.pax = pax;
      return header;
    };
    var Source = function(self2, offset) {
      this._parent = self2;
      this.offset = offset;
      PassThrough.call(this, { autoDestroy: false });
    };
    util.inherits(Source, PassThrough);
    Source.prototype.destroy = function(err) {
      this._parent.destroy(err);
    };
    var Extract = function(opts) {
      if (!(this instanceof Extract))
        return new Extract(opts);
      Writable.call(this, opts);
      opts = opts || {};
      this._offset = 0;
      this._buffer = bl();
      this._missing = 0;
      this._partial = false;
      this._onparse = noop;
      this._header = null;
      this._stream = null;
      this._overflow = null;
      this._cb = null;
      this._locked = false;
      this._destroyed = false;
      this._pax = null;
      this._paxGlobal = null;
      this._gnuLongPath = null;
      this._gnuLongLinkPath = null;
      var self2 = this;
      var b = self2._buffer;
      var oncontinue = function() {
        self2._continue();
      };
      var onunlock = function(err) {
        self2._locked = false;
        if (err)
          return self2.destroy(err);
        if (!self2._stream)
          oncontinue();
      };
      var onstreamend = function() {
        self2._stream = null;
        var drain = overflow(self2._header.size);
        if (drain)
          self2._parse(drain, ondrain);
        else
          self2._parse(512, onheader);
        if (!self2._locked)
          oncontinue();
      };
      var ondrain = function() {
        self2._buffer.consume(overflow(self2._header.size));
        self2._parse(512, onheader);
        oncontinue();
      };
      var onpaxglobalheader = function() {
        var size = self2._header.size;
        self2._paxGlobal = headers.decodePax(b.slice(0, size));
        b.consume(size);
        onstreamend();
      };
      var onpaxheader = function() {
        var size = self2._header.size;
        self2._pax = headers.decodePax(b.slice(0, size));
        if (self2._paxGlobal)
          self2._pax = Object.assign({}, self2._paxGlobal, self2._pax);
        b.consume(size);
        onstreamend();
      };
      var ongnulongpath = function() {
        var size = self2._header.size;
        this._gnuLongPath = headers.decodeLongPath(b.slice(0, size), opts.filenameEncoding);
        b.consume(size);
        onstreamend();
      };
      var ongnulonglinkpath = function() {
        var size = self2._header.size;
        this._gnuLongLinkPath = headers.decodeLongPath(b.slice(0, size), opts.filenameEncoding);
        b.consume(size);
        onstreamend();
      };
      var onheader = function() {
        var offset = self2._offset;
        var header;
        try {
          header = self2._header = headers.decode(b.slice(0, 512), opts.filenameEncoding, opts.allowUnknownFormat);
        } catch (err) {
          self2.emit("error", err);
        }
        b.consume(512);
        if (!header) {
          self2._parse(512, onheader);
          oncontinue();
          return;
        }
        if (header.type === "gnu-long-path") {
          self2._parse(header.size, ongnulongpath);
          oncontinue();
          return;
        }
        if (header.type === "gnu-long-link-path") {
          self2._parse(header.size, ongnulonglinkpath);
          oncontinue();
          return;
        }
        if (header.type === "pax-global-header") {
          self2._parse(header.size, onpaxglobalheader);
          oncontinue();
          return;
        }
        if (header.type === "pax-header") {
          self2._parse(header.size, onpaxheader);
          oncontinue();
          return;
        }
        if (self2._gnuLongPath) {
          header.name = self2._gnuLongPath;
          self2._gnuLongPath = null;
        }
        if (self2._gnuLongLinkPath) {
          header.linkname = self2._gnuLongLinkPath;
          self2._gnuLongLinkPath = null;
        }
        if (self2._pax) {
          self2._header = header = mixinPax(header, self2._pax);
          self2._pax = null;
        }
        self2._locked = true;
        if (!header.size || header.type === "directory") {
          self2._parse(512, onheader);
          self2.emit("entry", header, emptyStream(self2, offset), onunlock);
          return;
        }
        self2._stream = new Source(self2, offset);
        self2.emit("entry", header, self2._stream, onunlock);
        self2._parse(header.size, onstreamend);
        oncontinue();
      };
      this._onheader = onheader;
      this._parse(512, onheader);
    };
    util.inherits(Extract, Writable);
    Extract.prototype.destroy = function(err) {
      if (this._destroyed)
        return;
      this._destroyed = true;
      if (err)
        this.emit("error", err);
      this.emit("close");
      if (this._stream)
        this._stream.emit("close");
    };
    Extract.prototype._parse = function(size, onparse) {
      if (this._destroyed)
        return;
      this._offset += size;
      this._missing = size;
      if (onparse === this._onheader)
        this._partial = false;
      this._onparse = onparse;
    };
    Extract.prototype._continue = function() {
      if (this._destroyed)
        return;
      var cb = this._cb;
      this._cb = noop;
      if (this._overflow)
        this._write(this._overflow, void 0, cb);
      else
        cb();
    };
    Extract.prototype._write = function(data, enc, cb) {
      if (this._destroyed)
        return;
      var s = this._stream;
      var b = this._buffer;
      var missing = this._missing;
      if (data.length)
        this._partial = true;
      if (data.length < missing) {
        this._missing -= data.length;
        this._overflow = null;
        if (s)
          return s.write(data, cb);
        b.append(data);
        return cb();
      }
      this._cb = cb;
      this._missing = 0;
      var overflow2 = null;
      if (data.length > missing) {
        overflow2 = data.slice(missing);
        data = data.slice(0, missing);
      }
      if (s)
        s.end(data);
      else
        b.append(data);
      this._overflow = overflow2;
      this._onparse();
    };
    Extract.prototype._final = function(cb) {
      if (this._partial)
        return this.destroy(new Error("Unexpected end of data"));
      cb();
    };
    module2.exports = Extract;
  }
});

// node_modules/fs-constants/index.js
var require_fs_constants = __commonJS({
  "node_modules/fs-constants/index.js"(exports, module2) {
    module2.exports = require("fs").constants || require("constants");
  }
});

// node_modules/wrappy/wrappy.js
var require_wrappy = __commonJS({
  "node_modules/wrappy/wrappy.js"(exports, module2) {
    module2.exports = wrappy;
    function wrappy(fn, cb) {
      if (fn && cb)
        return wrappy(fn)(cb);
      if (typeof fn !== "function")
        throw new TypeError("need wrapper function");
      Object.keys(fn).forEach(function(k) {
        wrapper[k] = fn[k];
      });
      return wrapper;
      function wrapper() {
        var args = new Array(arguments.length);
        for (var i = 0; i < args.length; i++) {
          args[i] = arguments[i];
        }
        var ret = fn.apply(this, args);
        var cb2 = args[args.length - 1];
        if (typeof ret === "function" && ret !== cb2) {
          Object.keys(cb2).forEach(function(k) {
            ret[k] = cb2[k];
          });
        }
        return ret;
      }
    }
  }
});

// node_modules/once/once.js
var require_once = __commonJS({
  "node_modules/once/once.js"(exports, module2) {
    var wrappy = require_wrappy();
    module2.exports = wrappy(once);
    module2.exports.strict = wrappy(onceStrict);
    once.proto = once(function() {
      Object.defineProperty(Function.prototype, "once", {
        value: function() {
          return once(this);
        },
        configurable: true
      });
      Object.defineProperty(Function.prototype, "onceStrict", {
        value: function() {
          return onceStrict(this);
        },
        configurable: true
      });
    });
    function once(fn) {
      var f = function() {
        if (f.called)
          return f.value;
        f.called = true;
        return f.value = fn.apply(this, arguments);
      };
      f.called = false;
      return f;
    }
    function onceStrict(fn) {
      var f = function() {
        if (f.called)
          throw new Error(f.onceError);
        f.called = true;
        return f.value = fn.apply(this, arguments);
      };
      var name = fn.name || "Function wrapped with `once`";
      f.onceError = name + " shouldn't be called more than once";
      f.called = false;
      return f;
    }
  }
});

// node_modules/end-of-stream/index.js
var require_end_of_stream2 = __commonJS({
  "node_modules/end-of-stream/index.js"(exports, module2) {
    var once = require_once();
    var noop = function() {
    };
    var isRequest = function(stream) {
      return stream.setHeader && typeof stream.abort === "function";
    };
    var isChildProcess = function(stream) {
      return stream.stdio && Array.isArray(stream.stdio) && stream.stdio.length === 3;
    };
    var eos = function(stream, opts, callback) {
      if (typeof opts === "function")
        return eos(stream, null, opts);
      if (!opts)
        opts = {};
      callback = once(callback || noop);
      var ws = stream._writableState;
      var rs = stream._readableState;
      var readable = opts.readable || opts.readable !== false && stream.readable;
      var writable = opts.writable || opts.writable !== false && stream.writable;
      var cancelled = false;
      var onlegacyfinish = function() {
        if (!stream.writable)
          onfinish();
      };
      var onfinish = function() {
        writable = false;
        if (!readable)
          callback.call(stream);
      };
      var onend = function() {
        readable = false;
        if (!writable)
          callback.call(stream);
      };
      var onexit = function(exitCode) {
        callback.call(stream, exitCode ? new Error("exited with error code: " + exitCode) : null);
      };
      var onerror = function(err) {
        callback.call(stream, err);
      };
      var onclose = function() {
        process.nextTick(onclosenexttick);
      };
      var onclosenexttick = function() {
        if (cancelled)
          return;
        if (readable && !(rs && (rs.ended && !rs.destroyed)))
          return callback.call(stream, new Error("premature close"));
        if (writable && !(ws && (ws.ended && !ws.destroyed)))
          return callback.call(stream, new Error("premature close"));
      };
      var onrequest = function() {
        stream.req.on("finish", onfinish);
      };
      if (isRequest(stream)) {
        stream.on("complete", onfinish);
        stream.on("abort", onclose);
        if (stream.req)
          onrequest();
        else
          stream.on("request", onrequest);
      } else if (writable && !ws) {
        stream.on("end", onlegacyfinish);
        stream.on("close", onlegacyfinish);
      }
      if (isChildProcess(stream))
        stream.on("exit", onexit);
      stream.on("end", onend);
      stream.on("finish", onfinish);
      if (opts.error !== false)
        stream.on("error", onerror);
      stream.on("close", onclose);
      return function() {
        cancelled = true;
        stream.removeListener("complete", onfinish);
        stream.removeListener("abort", onclose);
        stream.removeListener("request", onrequest);
        if (stream.req)
          stream.req.removeListener("finish", onfinish);
        stream.removeListener("end", onlegacyfinish);
        stream.removeListener("close", onlegacyfinish);
        stream.removeListener("finish", onfinish);
        stream.removeListener("exit", onexit);
        stream.removeListener("end", onend);
        stream.removeListener("error", onerror);
        stream.removeListener("close", onclose);
      };
    };
    module2.exports = eos;
  }
});

// node_modules/tar-stream/pack.js
var require_pack = __commonJS({
  "node_modules/tar-stream/pack.js"(exports, module2) {
    var constants = require_fs_constants();
    var eos = require_end_of_stream2();
    var inherits = require_inherits();
    var alloc = Buffer.alloc;
    var Readable = require_readable().Readable;
    var Writable = require_readable().Writable;
    var StringDecoder = require("string_decoder").StringDecoder;
    var headers = require_headers();
    var DMODE = parseInt("755", 8);
    var FMODE = parseInt("644", 8);
    var END_OF_TAR = alloc(1024);
    var noop = function() {
    };
    var overflow = function(self2, size) {
      size &= 511;
      if (size)
        self2.push(END_OF_TAR.slice(0, 512 - size));
    };
    function modeToType(mode) {
      switch (mode & constants.S_IFMT) {
        case constants.S_IFBLK:
          return "block-device";
        case constants.S_IFCHR:
          return "character-device";
        case constants.S_IFDIR:
          return "directory";
        case constants.S_IFIFO:
          return "fifo";
        case constants.S_IFLNK:
          return "symlink";
      }
      return "file";
    }
    var Sink = function(to) {
      Writable.call(this);
      this.written = 0;
      this._to = to;
      this._destroyed = false;
    };
    inherits(Sink, Writable);
    Sink.prototype._write = function(data, enc, cb) {
      this.written += data.length;
      if (this._to.push(data))
        return cb();
      this._to._drain = cb;
    };
    Sink.prototype.destroy = function() {
      if (this._destroyed)
        return;
      this._destroyed = true;
      this.emit("close");
    };
    var LinkSink = function() {
      Writable.call(this);
      this.linkname = "";
      this._decoder = new StringDecoder("utf-8");
      this._destroyed = false;
    };
    inherits(LinkSink, Writable);
    LinkSink.prototype._write = function(data, enc, cb) {
      this.linkname += this._decoder.write(data);
      cb();
    };
    LinkSink.prototype.destroy = function() {
      if (this._destroyed)
        return;
      this._destroyed = true;
      this.emit("close");
    };
    var Void = function() {
      Writable.call(this);
      this._destroyed = false;
    };
    inherits(Void, Writable);
    Void.prototype._write = function(data, enc, cb) {
      cb(new Error("No body allowed for this entry"));
    };
    Void.prototype.destroy = function() {
      if (this._destroyed)
        return;
      this._destroyed = true;
      this.emit("close");
    };
    var Pack = function(opts) {
      if (!(this instanceof Pack))
        return new Pack(opts);
      Readable.call(this, opts);
      this._drain = noop;
      this._finalized = false;
      this._finalizing = false;
      this._destroyed = false;
      this._stream = null;
    };
    inherits(Pack, Readable);
    Pack.prototype.entry = function(header, buffer, callback) {
      if (this._stream)
        throw new Error("already piping an entry");
      if (this._finalized || this._destroyed)
        return;
      if (typeof buffer === "function") {
        callback = buffer;
        buffer = null;
      }
      if (!callback)
        callback = noop;
      var self2 = this;
      if (!header.size || header.type === "symlink")
        header.size = 0;
      if (!header.type)
        header.type = modeToType(header.mode);
      if (!header.mode)
        header.mode = header.type === "directory" ? DMODE : FMODE;
      if (!header.uid)
        header.uid = 0;
      if (!header.gid)
        header.gid = 0;
      if (!header.mtime)
        header.mtime = new Date();
      if (typeof buffer === "string")
        buffer = Buffer.from(buffer);
      if (Buffer.isBuffer(buffer)) {
        header.size = buffer.length;
        this._encode(header);
        var ok = this.push(buffer);
        overflow(self2, header.size);
        if (ok)
          process.nextTick(callback);
        else
          this._drain = callback;
        return new Void();
      }
      if (header.type === "symlink" && !header.linkname) {
        var linkSink = new LinkSink();
        eos(linkSink, function(err) {
          if (err) {
            self2.destroy();
            return callback(err);
          }
          header.linkname = linkSink.linkname;
          self2._encode(header);
          callback();
        });
        return linkSink;
      }
      this._encode(header);
      if (header.type !== "file" && header.type !== "contiguous-file") {
        process.nextTick(callback);
        return new Void();
      }
      var sink = new Sink(this);
      this._stream = sink;
      eos(sink, function(err) {
        self2._stream = null;
        if (err) {
          self2.destroy();
          return callback(err);
        }
        if (sink.written !== header.size) {
          self2.destroy();
          return callback(new Error("size mismatch"));
        }
        overflow(self2, header.size);
        if (self2._finalizing)
          self2.finalize();
        callback();
      });
      return sink;
    };
    Pack.prototype.finalize = function() {
      if (this._stream) {
        this._finalizing = true;
        return;
      }
      if (this._finalized)
        return;
      this._finalized = true;
      this.push(END_OF_TAR);
      this.push(null);
    };
    Pack.prototype.destroy = function(err) {
      if (this._destroyed)
        return;
      this._destroyed = true;
      if (err)
        this.emit("error", err);
      this.emit("close");
      if (this._stream && this._stream.destroy)
        this._stream.destroy();
    };
    Pack.prototype._encode = function(header) {
      if (!header.pax) {
        var buf = headers.encode(header);
        if (buf) {
          this.push(buf);
          return;
        }
      }
      this._encodePax(header);
    };
    Pack.prototype._encodePax = function(header) {
      var paxHeader = headers.encodePax({
        name: header.name,
        linkname: header.linkname,
        pax: header.pax
      });
      var newHeader = {
        name: "PaxHeader",
        mode: header.mode,
        uid: header.uid,
        gid: header.gid,
        size: paxHeader.length,
        mtime: header.mtime,
        type: "pax-header",
        linkname: header.linkname && "PaxHeader",
        uname: header.uname,
        gname: header.gname,
        devmajor: header.devmajor,
        devminor: header.devminor
      };
      this.push(headers.encode(newHeader));
      this.push(paxHeader);
      overflow(this, paxHeader.length);
      newHeader.size = header.size;
      newHeader.type = header.type;
      this.push(headers.encode(newHeader));
    };
    Pack.prototype._read = function(n) {
      var drain = this._drain;
      this._drain = noop;
      drain();
    };
    module2.exports = Pack;
  }
});

// node_modules/tar-stream/index.js
var require_tar_stream = __commonJS({
  "node_modules/tar-stream/index.js"(exports) {
    exports.extract = require_extract();
    exports.pack = require_pack();
  }
});

// node_modules/pump/index.js
var require_pump = __commonJS({
  "node_modules/pump/index.js"(exports, module2) {
    var once = require_once();
    var eos = require_end_of_stream2();
    var fs2 = require("fs");
    var noop = function() {
    };
    var ancient = /^v?\.0/.test(process.version);
    var isFn = function(fn) {
      return typeof fn === "function";
    };
    var isFS = function(stream) {
      if (!ancient)
        return false;
      if (!fs2)
        return false;
      return (stream instanceof (fs2.ReadStream || noop) || stream instanceof (fs2.WriteStream || noop)) && isFn(stream.close);
    };
    var isRequest = function(stream) {
      return stream.setHeader && isFn(stream.abort);
    };
    var destroyer = function(stream, reading, writing, callback) {
      callback = once(callback);
      var closed = false;
      stream.on("close", function() {
        closed = true;
      });
      eos(stream, { readable: reading, writable: writing }, function(err) {
        if (err)
          return callback(err);
        closed = true;
        callback();
      });
      var destroyed = false;
      return function(err) {
        if (closed)
          return;
        if (destroyed)
          return;
        destroyed = true;
        if (isFS(stream))
          return stream.close(noop);
        if (isRequest(stream))
          return stream.abort();
        if (isFn(stream.destroy))
          return stream.destroy();
        callback(err || new Error("stream was destroyed"));
      };
    };
    var call = function(fn) {
      fn();
    };
    var pipe = function(from, to) {
      return from.pipe(to);
    };
    var pump = function() {
      var streams = Array.prototype.slice.call(arguments);
      var callback = isFn(streams[streams.length - 1] || noop) && streams.pop() || noop;
      if (Array.isArray(streams[0]))
        streams = streams[0];
      if (streams.length < 2)
        throw new Error("pump requires two streams per minimum");
      var error;
      var destroys = streams.map(function(stream, i) {
        var reading = i < streams.length - 1;
        var writing = i > 0;
        return destroyer(stream, reading, writing, function(err) {
          if (!error)
            error = err;
          if (err)
            destroys.forEach(call);
          if (reading)
            return;
          destroys.forEach(call);
          callback(error);
        });
      });
      return streams.reduce(pipe);
    };
    module2.exports = pump;
  }
});

// node_modules/mkdirp-classic/index.js
var require_mkdirp_classic = __commonJS({
  "node_modules/mkdirp-classic/index.js"(exports, module2) {
    var path2 = require("path");
    var fs2 = require("fs");
    var _0777 = parseInt("0777", 8);
    module2.exports = mkdirP.mkdirp = mkdirP.mkdirP = mkdirP;
    function mkdirP(p, opts, f, made) {
      if (typeof opts === "function") {
        f = opts;
        opts = {};
      } else if (!opts || typeof opts !== "object") {
        opts = { mode: opts };
      }
      var mode = opts.mode;
      var xfs = opts.fs || fs2;
      if (mode === void 0) {
        mode = _0777 & ~process.umask();
      }
      if (!made)
        made = null;
      var cb = f || function() {
      };
      p = path2.resolve(p);
      xfs.mkdir(p, mode, function(er) {
        if (!er) {
          made = made || p;
          return cb(null, made);
        }
        switch (er.code) {
          case "ENOENT":
            mkdirP(path2.dirname(p), opts, function(er2, made2) {
              if (er2)
                cb(er2, made2);
              else
                mkdirP(p, opts, cb, made2);
            });
            break;
          default:
            xfs.stat(p, function(er2, stat) {
              if (er2 || !stat.isDirectory())
                cb(er, made);
              else
                cb(null, made);
            });
            break;
        }
      });
    }
    mkdirP.sync = function sync(p, opts, made) {
      if (!opts || typeof opts !== "object") {
        opts = { mode: opts };
      }
      var mode = opts.mode;
      var xfs = opts.fs || fs2;
      if (mode === void 0) {
        mode = _0777 & ~process.umask();
      }
      if (!made)
        made = null;
      p = path2.resolve(p);
      try {
        xfs.mkdirSync(p, mode);
        made = made || p;
      } catch (err0) {
        switch (err0.code) {
          case "ENOENT":
            made = sync(path2.dirname(p), opts, made);
            sync(p, opts, made);
            break;
          default:
            var stat;
            try {
              stat = xfs.statSync(p);
            } catch (err1) {
              throw err0;
            }
            if (!stat.isDirectory())
              throw err0;
            break;
        }
      }
      return made;
    };
  }
});

// node_modules/tar-fs/index.js
var require_tar_fs = __commonJS({
  "node_modules/tar-fs/index.js"(exports) {
    var chownr = require_chownr();
    var tar = require_tar_stream();
    var pump = require_pump();
    var mkdirp = require_mkdirp_classic();
    var fs2 = require("fs");
    var path2 = require("path");
    var os = require("os");
    var win32 = os.platform() === "win32";
    var noop = function() {
    };
    var echo = function(name) {
      return name;
    };
    var normalize = !win32 ? echo : function(name) {
      return name.replace(/\\/g, "/").replace(/[:?<>|]/g, "_");
    };
    var statAll = function(fs3, stat, cwd, ignore, entries, sort) {
      var queue = entries || ["."];
      return function loop(callback) {
        if (!queue.length)
          return callback();
        var next = queue.shift();
        var nextAbs = path2.join(cwd, next);
        stat(nextAbs, function(err, stat2) {
          if (err)
            return callback(err);
          if (!stat2.isDirectory())
            return callback(null, next, stat2);
          fs3.readdir(nextAbs, function(err2, files) {
            if (err2)
              return callback(err2);
            if (sort)
              files.sort();
            for (var i = 0; i < files.length; i++) {
              if (!ignore(path2.join(cwd, next, files[i])))
                queue.push(path2.join(next, files[i]));
            }
            callback(null, next, stat2);
          });
        });
      };
    };
    var strip = function(map, level) {
      return function(header) {
        header.name = header.name.split("/").slice(level).join("/");
        var linkname = header.linkname;
        if (linkname && (header.type === "link" || path2.isAbsolute(linkname))) {
          header.linkname = linkname.split("/").slice(level).join("/");
        }
        return map(header);
      };
    };
    exports.pack = function(cwd, opts) {
      if (!cwd)
        cwd = ".";
      if (!opts)
        opts = {};
      var xfs = opts.fs || fs2;
      var ignore = opts.ignore || opts.filter || noop;
      var map = opts.map || noop;
      var mapStream = opts.mapStream || echo;
      var statNext = statAll(xfs, opts.dereference ? xfs.stat : xfs.lstat, cwd, ignore, opts.entries, opts.sort);
      var strict = opts.strict !== false;
      var umask = typeof opts.umask === "number" ? ~opts.umask : ~processUmask();
      var dmode = typeof opts.dmode === "number" ? opts.dmode : 0;
      var fmode = typeof opts.fmode === "number" ? opts.fmode : 0;
      var pack = opts.pack || tar.pack();
      var finish = opts.finish || noop;
      if (opts.strip)
        map = strip(map, opts.strip);
      if (opts.readable) {
        dmode |= parseInt(555, 8);
        fmode |= parseInt(444, 8);
      }
      if (opts.writable) {
        dmode |= parseInt(333, 8);
        fmode |= parseInt(222, 8);
      }
      var onsymlink = function(filename, header) {
        xfs.readlink(path2.join(cwd, filename), function(err, linkname) {
          if (err)
            return pack.destroy(err);
          header.linkname = normalize(linkname);
          pack.entry(header, onnextentry);
        });
      };
      var onstat = function(err, filename, stat) {
        if (err)
          return pack.destroy(err);
        if (!filename) {
          if (opts.finalize !== false)
            pack.finalize();
          return finish(pack);
        }
        if (stat.isSocket())
          return onnextentry();
        var header = {
          name: normalize(filename),
          mode: (stat.mode | (stat.isDirectory() ? dmode : fmode)) & umask,
          mtime: stat.mtime,
          size: stat.size,
          type: "file",
          uid: stat.uid,
          gid: stat.gid
        };
        if (stat.isDirectory()) {
          header.size = 0;
          header.type = "directory";
          header = map(header) || header;
          return pack.entry(header, onnextentry);
        }
        if (stat.isSymbolicLink()) {
          header.size = 0;
          header.type = "symlink";
          header = map(header) || header;
          return onsymlink(filename, header);
        }
        header = map(header) || header;
        if (!stat.isFile()) {
          if (strict)
            return pack.destroy(new Error("unsupported type for " + filename));
          return onnextentry();
        }
        var entry = pack.entry(header, onnextentry);
        if (!entry)
          return;
        var rs = mapStream(xfs.createReadStream(path2.join(cwd, filename)), header);
        rs.on("error", function(err2) {
          entry.destroy(err2);
        });
        pump(rs, entry);
      };
      var onnextentry = function(err) {
        if (err)
          return pack.destroy(err);
        statNext(onstat);
      };
      onnextentry();
      return pack;
    };
    var head = function(list) {
      return list.length ? list[list.length - 1] : null;
    };
    var processGetuid = function() {
      return process.getuid ? process.getuid() : -1;
    };
    var processUmask = function() {
      return process.umask ? process.umask() : 0;
    };
    exports.extract = function(cwd, opts) {
      if (!cwd)
        cwd = ".";
      if (!opts)
        opts = {};
      var xfs = opts.fs || fs2;
      var ignore = opts.ignore || opts.filter || noop;
      var map = opts.map || noop;
      var mapStream = opts.mapStream || echo;
      var own = opts.chown !== false && !win32 && processGetuid() === 0;
      var extract = opts.extract || tar.extract();
      var stack = [];
      var now = new Date();
      var umask = typeof opts.umask === "number" ? ~opts.umask : ~processUmask();
      var dmode = typeof opts.dmode === "number" ? opts.dmode : 0;
      var fmode = typeof opts.fmode === "number" ? opts.fmode : 0;
      var strict = opts.strict !== false;
      if (opts.strip)
        map = strip(map, opts.strip);
      if (opts.readable) {
        dmode |= parseInt(555, 8);
        fmode |= parseInt(444, 8);
      }
      if (opts.writable) {
        dmode |= parseInt(333, 8);
        fmode |= parseInt(222, 8);
      }
      var utimesParent = function(name, cb) {
        var top;
        while ((top = head(stack)) && name.slice(0, top[0].length) !== top[0])
          stack.pop();
        if (!top)
          return cb();
        xfs.utimes(top[0], now, top[1], cb);
      };
      var utimes = function(name, header, cb) {
        if (opts.utimes === false)
          return cb();
        if (header.type === "directory")
          return xfs.utimes(name, now, header.mtime, cb);
        if (header.type === "symlink")
          return utimesParent(name, cb);
        xfs.utimes(name, now, header.mtime, function(err) {
          if (err)
            return cb(err);
          utimesParent(name, cb);
        });
      };
      var chperm = function(name, header, cb) {
        var link = header.type === "symlink";
        var chmod = link ? xfs.lchmod : xfs.chmod;
        var chown = link ? xfs.lchown : xfs.chown;
        if (!chmod)
          return cb();
        var mode = (header.mode | (header.type === "directory" ? dmode : fmode)) & umask;
        chmod(name, mode, function(err) {
          if (err)
            return cb(err);
          if (!own)
            return cb();
          if (!chown)
            return cb();
          chown(name, header.uid, header.gid, cb);
        });
      };
      extract.on("entry", function(header, stream, next) {
        header = map(header) || header;
        header.name = normalize(header.name);
        var name = path2.join(cwd, path2.join("/", header.name));
        if (ignore(name, header)) {
          stream.resume();
          return next();
        }
        var stat = function(err) {
          if (err)
            return next(err);
          utimes(name, header, function(err2) {
            if (err2)
              return next(err2);
            if (win32)
              return next();
            chperm(name, header, next);
          });
        };
        var onsymlink = function() {
          if (win32)
            return next();
          xfs.unlink(name, function() {
            xfs.symlink(header.linkname, name, stat);
          });
        };
        var onlink = function() {
          if (win32)
            return next();
          xfs.unlink(name, function() {
            var srcpath = path2.join(cwd, path2.join("/", header.linkname));
            xfs.link(srcpath, name, function(err) {
              if (err && err.code === "EPERM" && opts.hardlinkAsFilesFallback) {
                stream = xfs.createReadStream(srcpath);
                return onfile();
              }
              stat(err);
            });
          });
        };
        var onfile = function() {
          var ws = xfs.createWriteStream(name);
          var rs = mapStream(stream, header);
          ws.on("error", function(err) {
            rs.destroy(err);
          });
          pump(rs, ws, function(err) {
            if (err)
              return next(err);
            ws.on("close", stat);
          });
        };
        if (header.type === "directory") {
          stack.push([name, header.mtime]);
          return mkdirfix(name, {
            fs: xfs,
            own,
            uid: header.uid,
            gid: header.gid
          }, stat);
        }
        var dir = path2.dirname(name);
        validate(xfs, dir, path2.join(cwd, "."), function(err, valid) {
          if (err)
            return next(err);
          if (!valid)
            return next(new Error(dir + " is not a valid path"));
          mkdirfix(dir, {
            fs: xfs,
            own,
            uid: header.uid,
            gid: header.gid
          }, function(err2) {
            if (err2)
              return next(err2);
            switch (header.type) {
              case "file":
                return onfile();
              case "link":
                return onlink();
              case "symlink":
                return onsymlink();
            }
            if (strict)
              return next(new Error("unsupported type for " + name + " (" + header.type + ")"));
            stream.resume();
            next();
          });
        });
      });
      if (opts.finish)
        extract.on("finish", opts.finish);
      return extract;
    };
    function validate(fs3, name, root, cb) {
      if (name === root)
        return cb(null, true);
      fs3.lstat(name, function(err, st) {
        if (err && err.code !== "ENOENT")
          return cb(err);
        if (err || st.isDirectory())
          return validate(fs3, path2.join(name, ".."), root, cb);
        cb(null, false);
      });
    }
    function mkdirfix(name, opts, cb) {
      mkdirp(name, { fs: opts.fs }, function(err, made) {
        if (!err && made && opts.own) {
          chownr(made, opts.uid, opts.gid, cb);
        } else {
          cb(err);
        }
      });
    }
  }
});

// node_modules/dockerode/lib/util.js
var require_util = __commonJS({
  "node_modules/dockerode/lib/util.js"(exports, module2) {
    var arr = [];
    var each = arr.forEach;
    var slice = arr.slice;
    module2.exports.extend = function(obj) {
      each.call(slice.call(arguments, 1), function(source) {
        if (source) {
          for (var prop in source) {
            obj[prop] = source[prop];
          }
        }
      });
      return obj;
    };
    module2.exports.processArgs = function(opts, callback, defaultOpts) {
      if (!callback && typeof opts === "function") {
        callback = opts;
        opts = null;
      }
      return {
        callback,
        opts: module2.exports.extend({}, defaultOpts, opts)
      };
    };
    module2.exports.parseRepositoryTag = function(input) {
      var separatorPos;
      var digestPos = input.indexOf("@");
      var colonPos = input.lastIndexOf(":");
      if (digestPos >= 0) {
        separatorPos = digestPos;
      } else if (colonPos >= 0) {
        separatorPos = colonPos;
      } else {
        return {
          repository: input
        };
      }
      var tag = input.slice(separatorPos + 1);
      if (tag.indexOf("/") === -1) {
        return {
          repository: input.slice(0, separatorPos),
          tag
        };
      }
      return {
        repository: input
      };
    };
  }
});

// node_modules/dockerode/lib/exec.js
var require_exec = __commonJS({
  "node_modules/dockerode/lib/exec.js"(exports, module2) {
    var util = require_util();
    var Exec = function(modem, id) {
      this.modem = modem;
      this.id = id;
    };
    Exec.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Exec.prototype.start = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/exec/" + this.id + "/start",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        isStream: true,
        allowEmpty: true,
        hijack: args.opts.hijack,
        openStdin: args.opts.stdin,
        statusCodes: {
          200: true,
          204: true,
          404: "no such exec",
          409: "container stopped/paused",
          500: "container not running"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, data);
        });
      }
    };
    Exec.prototype.resize = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/exec/" + this.id + "/resize?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such exec",
          500: "container not running"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, data);
        });
      }
    };
    Exec.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/exec/" + this.id + "/json",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such exec",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return callback(err, data);
          args.callback(err, data);
        });
      }
    };
    module2.exports = Exec;
  }
});

// node_modules/dockerode/lib/container.js
var require_container = __commonJS({
  "node_modules/dockerode/lib/container.js"(exports, module2) {
    var extend = require_util().extend;
    var Exec = require_exec();
    var util = require_util();
    var Container = function(modem, id) {
      this.modem = modem;
      this.id = id;
      this.defaultOptions = {
        top: {},
        start: {},
        commit: {},
        stop: {},
        pause: {},
        unpause: {},
        restart: {},
        resize: {},
        attach: {},
        remove: {},
        copy: {},
        kill: {},
        exec: {},
        rename: {},
        log: {},
        stats: {},
        getArchive: {},
        infoArchive: {},
        putArchive: {},
        update: {},
        wait: {}
      };
    };
    Container.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Container.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/containers/" + this.id + "/json?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.rename = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.rename);
      var optsf = {
        path: "/containers/" + this.id + "/rename?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.update = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.update);
      var optsf = {
        path: "/containers/" + this.id + "/update",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          400: "bad parameter",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.top = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.top);
      var optsf = {
        path: "/containers/" + this.id + "/top?",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.changes = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/containers/" + this.id + "/changes",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.listCheckpoint = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/containers/" + this.id + "/checkpoints?",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.deleteCheckpoint = function(checkpoint, opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/containers/" + this.id + "/checkpoints/" + checkpoint + "?",
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.createCheckpoint = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/containers/" + this.id + "/checkpoints",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        allowEmpty: true,
        statusCodes: {
          200: true,
          201: true,
          204: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.export = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/containers/" + this.id + "/export",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.start = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.start);
      var optsf = {
        path: "/containers/" + this.id + "/start?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          304: "container already started",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.pause = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.pause);
      var optsf = {
        path: "/containers/" + this.id + "/pause",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.unpause = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.unpause);
      var optsf = {
        path: "/containers/" + this.id + "/unpause",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.exec = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.exec);
      var optsf = {
        path: "/containers/" + this.id + "/exec",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          404: "no such container",
          409: "container stopped/paused",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(new Exec(self2.modem, data.Id));
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, new Exec(self2.modem, data.Id));
        });
      }
    };
    Container.prototype.commit = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.commit);
      args.opts.container = this.id;
      var optsf = {
        path: "/commit?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.stop = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.stop);
      var optsf = {
        path: "/containers/" + this.id + "/stop?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          304: "container already stopped",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.restart = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.restart);
      var optsf = {
        path: "/containers/" + this.id + "/restart?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.kill = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.kill);
      var optsf = {
        path: "/containers/" + this.id + "/kill?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.resize = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.resize);
      var optsf = {
        path: "/containers/" + this.id + "/resize?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.attach = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.attach);
      var optsf = {
        path: "/containers/" + this.id + "/attach?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        isStream: true,
        hijack: args.opts.hijack,
        openStdin: args.opts.stdin,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, stream) {
            if (err) {
              return reject(err);
            }
            resolve(stream);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, stream) {
          args.callback(err, stream);
        });
      }
    };
    Container.prototype.wait = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.wait);
      var optsf = {
        path: "/containers/" + this.id + "/wait?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.remove);
      var optsf = {
        path: "/containers/" + this.id + "?",
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          400: "bad parameter",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.copy = function(opts, callback) {
      var self2 = this;
      console.log("container.copy is deprecated since Docker v1.8.x");
      var args = util.processArgs(opts, callback, this.defaultOptions.copy);
      var optsf = {
        path: "/containers/" + this.id + "/copy",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.getArchive = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.getArchive);
      var optsf = {
        path: "/containers/" + this.id + "/archive?",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          400: "client error, bad parameters",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.infoArchive = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.infoArchive);
      var optsf = {
        path: "/containers/" + this.id + "/archive?",
        method: "HEAD",
        abortSignal: args.opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          400: "client error, bad parameters",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.putArchive = function(file, opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.putArchive);
      var optsf = {
        path: "/containers/" + this.id + "/archive?",
        method: "PUT",
        file,
        abortSignal: args.opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          400: "client error, bad parameters",
          403: "client error, permission denied",
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.logs = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.log);
      var optsf = {
        path: "/containers/" + this.id + "/logs?",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        isStream: args.opts.follow || false,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Container.prototype.stats = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.stats);
      var isStream = true;
      if (args.opts.stream === false) {
        isStream = false;
      }
      var optsf = {
        path: "/containers/" + this.id + "/stats?",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        isStream,
        statusCodes: {
          200: true,
          404: "no such container",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Container;
  }
});

// node_modules/dockerode/lib/image.js
var require_image = __commonJS({
  "node_modules/dockerode/lib/image.js"(exports, module2) {
    var util = require_util();
    var Image = function(modem, name) {
      this.modem = modem;
      this.name = name;
    };
    Image.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Image.prototype.inspect = function(callback) {
      var self2 = this;
      var opts = {
        path: "/images/" + this.name + "/json",
        method: "GET",
        statusCodes: {
          200: true,
          404: "no such image",
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(opts, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(opts, function(err, data) {
          if (err)
            return callback(err, data);
          callback(err, data);
        });
      }
    };
    Image.prototype.distribution = function(opts, callback) {
      var args = util.processArgs(opts, callback);
      var self2 = this;
      var fopts = {
        path: "/distribution/" + this.name + "/json",
        method: "GET",
        statusCodes: {
          200: true,
          401: "no such image",
          500: "server error"
        },
        authconfig: args.opts ? args.opts.authconfig : void 0
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(fopts, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(fopts, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, data);
        });
      }
    };
    Image.prototype.history = function(callback) {
      var self2 = this;
      var opts = {
        path: "/images/" + this.name + "/history",
        method: "GET",
        statusCodes: {
          200: true,
          404: "no such image",
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(opts, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(opts, function(err, data) {
          if (err)
            return callback(err, data);
          callback(err, data);
        });
      }
    };
    Image.prototype.get = function(callback) {
      var self2 = this;
      var opts = {
        path: "/images/" + this.name + "/get",
        method: "GET",
        isStream: true,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(opts, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(opts, function(err, data) {
          if (err)
            return callback(err, data);
          callback(err, data);
        });
      }
    };
    Image.prototype.push = function(opts, callback, auth) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var isStream = true;
      if (args.opts.stream === false) {
        isStream = false;
      }
      var optsf = {
        path: "/images/" + this.name + "/push?",
        method: "POST",
        options: args.opts,
        authconfig: args.opts.authconfig || auth,
        abortSignal: args.opts.abortSignal,
        isStream,
        statusCodes: {
          200: true,
          404: "no such image",
          500: "server error"
        }
      };
      delete optsf.options.authconfig;
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Image.prototype.tag = function(opts, callback) {
      var self2 = this;
      var optsf = {
        path: "/images/" + this.name + "/tag?",
        method: "POST",
        options: opts,
        abortSignal: opts && opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          400: "bad parameter",
          404: "no such image",
          409: "conflict",
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Image.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/images/" + this.name + "?",
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such image",
          409: "conflict",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Image;
  }
});

// node_modules/dockerode/lib/volume.js
var require_volume = __commonJS({
  "node_modules/dockerode/lib/volume.js"(exports, module2) {
    var util = require_util();
    var Volume = function(modem, name) {
      this.modem = modem;
      this.name = name;
    };
    Volume.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Volume.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/volumes/" + this.name,
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such volume",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Volume.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/volumes/" + this.name,
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          204: true,
          404: "no such volume",
          409: "conflict",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Volume;
  }
});

// node_modules/dockerode/lib/network.js
var require_network = __commonJS({
  "node_modules/dockerode/lib/network.js"(exports, module2) {
    var util = require_util();
    var Network = function(modem, id) {
      this.modem = modem;
      this.id = id;
    };
    Network.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Network.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var opts = {
        path: "/networks/" + this.id + "?",
        method: "GET",
        statusCodes: {
          200: true,
          404: "no such network",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(opts, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(opts, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Network.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/networks/" + this.id,
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "no such network",
          409: "conflict",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Network.prototype.connect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/networks/" + this.id + "/connect",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          404: "network or container is not found",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Network.prototype.disconnect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/networks/" + this.id + "/disconnect",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          404: "network or container is not found",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Network;
  }
});

// node_modules/dockerode/lib/service.js
var require_service = __commonJS({
  "node_modules/dockerode/lib/service.js"(exports, module2) {
    var util = require_util();
    var Service = function(modem, id) {
      this.modem = modem;
      this.id = id;
    };
    Service.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Service.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/services/" + this.id,
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such service",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Service.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/services/" + this.id,
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "no such service",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Service.prototype.update = function(auth, opts, callback) {
      var self2 = this;
      if (!callback) {
        var t = typeof opts;
        if (t === "function") {
          callback = opts;
          opts = auth;
          auth = opts.authconfig || void 0;
        } else if (t === "undefined") {
          opts = auth;
          auth = opts.authconfig || void 0;
        }
      }
      var optsf = {
        path: "/services/" + this.id + "/update?",
        method: "POST",
        abortSignal: opts && opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such service",
          500: "server error"
        },
        authconfig: auth,
        options: opts
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Service.prototype.logs = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, {});
      var optsf = {
        path: "/services/" + this.id + "/logs?",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        isStream: args.opts.follow || false,
        statusCodes: {
          200: true,
          404: "no such service",
          500: "server error",
          503: "node is not part of a swarm"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Service;
  }
});

// node_modules/dockerode/lib/plugin.js
var require_plugin = __commonJS({
  "node_modules/dockerode/lib/plugin.js"(exports, module2) {
    var util = require_util();
    var Plugin = function(modem, name, remote) {
      this.modem = modem;
      this.name = name;
      this.remote = remote || name;
    };
    Plugin.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Plugin.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins/" + this.name,
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "plugin is not installed",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Plugin.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins/" + this.name + "?",
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "plugin is not installed",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, data);
        });
      }
    };
    Plugin.prototype.privileges = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins/privileges?",
        method: "GET",
        options: {
          "remote": this.remote
        },
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Plugin.prototype.pull = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      if (args.opts._query && !args.opts._query.name) {
        args.opts._query.name = this.name;
      }
      if (args.opts._query && !args.opts._query.remote) {
        args.opts._query.remote = this.remote;
      }
      var optsf = {
        path: "/plugins/pull?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        isStream: true,
        options: args.opts,
        statusCodes: {
          200: true,
          204: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Plugin.prototype.enable = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins/" + this.name + "/enable?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Plugin.prototype.disable = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins/" + this.name + "/disable",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Plugin.prototype.push = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins/" + this.name + "/push",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "plugin not installed",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Plugin.prototype.configure = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins/" + this.name + "/set",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "plugin not installed",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Plugin.prototype.upgrade = function(auth, opts, callback) {
      var self2 = this;
      if (!callback && typeof opts === "function") {
        callback = opts;
        opts = auth;
        auth = opts.authconfig || void 0;
      }
      var optsf = {
        path: "/plugins/" + this.name + "/upgrade?",
        method: "POST",
        abortSignal: opts && opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "plugin not installed",
          500: "server error"
        },
        authconfig: auth,
        options: opts
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    module2.exports = Plugin;
  }
});

// node_modules/dockerode/lib/secret.js
var require_secret = __commonJS({
  "node_modules/dockerode/lib/secret.js"(exports, module2) {
    var util = require_util();
    var Secret = function(modem, id) {
      this.modem = modem;
      this.id = id;
    };
    Secret.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Secret.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/secrets/" + this.id,
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "secret not found",
          406: "node is not part of a swarm",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Secret.prototype.update = function(opts, callback) {
      var self2 = this;
      if (!callback && typeof opts === "function") {
        callback = opts;
      }
      var optsf = {
        path: "/secrets/" + this.id + "/update?",
        method: "POST",
        abortSignal: opts && opts.abortSignal,
        statusCodes: {
          200: true,
          404: "secret not found",
          500: "server error"
        },
        options: opts
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Secret.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/secrets/" + this.id,
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "secret not found",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Secret;
  }
});

// node_modules/dockerode/lib/config.js
var require_config = __commonJS({
  "node_modules/dockerode/lib/config.js"(exports, module2) {
    var util = require_util();
    var Config = function(modem, id) {
      this.modem = modem;
      this.id = id;
    };
    Config.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Config.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/configs/" + this.id,
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "config not found",
          500: "server error",
          503: "node is not part of a swarm"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Config.prototype.update = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/configs/" + this.id + "/update?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "config not found",
          500: "server error",
          503: "node is not part of a swarm"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Config.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/configs/" + this.id,
        method: "DELETE",
        abortSignal: opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          404: "config not found",
          500: "server error",
          503: "node is not part of a swarm"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Config;
  }
});

// node_modules/dockerode/lib/task.js
var require_task = __commonJS({
  "node_modules/dockerode/lib/task.js"(exports, module2) {
    var util = require_util();
    var Task = function(modem, id) {
      this.modem = modem;
      this.id = id;
      this.defaultOptions = {
        log: {}
      };
    };
    Task.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Task.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/tasks/" + this.id,
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "unknown task",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Task.prototype.logs = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback, this.defaultOptions.log);
      var optsf = {
        path: "/tasks/" + this.id + "/logs?",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        isStream: args.opts.follow || false,
        statusCodes: {
          101: true,
          200: true,
          404: "no such container",
          500: "server error",
          503: "node is not part of a swarm"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Task;
  }
});

// node_modules/dockerode/lib/node.js
var require_node3 = __commonJS({
  "node_modules/dockerode/lib/node.js"(exports, module2) {
    var util = require_util();
    var Node = function(modem, id) {
      this.modem = modem;
      this.id = id;
    };
    Node.prototype[require("util").inspect.custom] = function() {
      return this;
    };
    Node.prototype.inspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/nodes/" + this.id,
        method: "GET",
        abortSignal: args.abortSignal,
        statusCodes: {
          200: true,
          404: "no such node",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Node.prototype.update = function(opts, callback) {
      var self2 = this;
      if (!callback && typeof opts === "function") {
        callback = opts;
      }
      var optsf = {
        path: "/nodes/" + this.id + "/update?",
        method: "POST",
        abortSignal: opts && opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such node",
          406: "node is not part of a swarm",
          500: "server error"
        },
        options: opts
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Node.prototype.remove = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/nodes/" + this.id + "?",
        method: "DELETE",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          404: "no such node",
          500: "server error"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    module2.exports = Node;
  }
});

// node_modules/dockerode/lib/docker.js
var require_docker = __commonJS({
  "node_modules/dockerode/lib/docker.js"(exports, module2) {
    var EventEmitter = require("events").EventEmitter;
    var Modem = require_modem();
    var tar = require_tar_fs();
    var zlib = require("zlib");
    var Container = require_container();
    var Image = require_image();
    var Volume = require_volume();
    var Network = require_network();
    var Service = require_service();
    var Plugin = require_plugin();
    var Secret = require_secret();
    var Config = require_config();
    var Task = require_task();
    var Node = require_node3();
    var Exec = require_exec();
    var util = require_util();
    var extend = util.extend;
    var Docker2 = function(opts) {
      if (!(this instanceof Docker2))
        return new Docker2(opts);
      var plibrary = global.Promise;
      if (opts && opts.Promise) {
        plibrary = opts.Promise;
        if (Object.keys(opts).length === 1) {
          opts = void 0;
        }
      }
      this.modem = new Modem(opts);
      this.modem.Promise = plibrary;
    };
    Docker2.prototype.createContainer = function(opts, callback) {
      var self2 = this;
      var optsf = {
        path: "/containers/create?",
        method: "POST",
        options: opts,
        authconfig: opts.authconfig,
        abortSignal: opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          404: "no such container",
          406: "impossible to attach",
          500: "server error"
        }
      };
      delete opts.authconfig;
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(self2.getContainer(data.Id));
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return callback(err, data);
          callback(err, self2.getContainer(data.Id));
        });
      }
    };
    Docker2.prototype.createImage = function(auth, opts, callback) {
      var self2 = this;
      if (!callback && typeof opts === "function") {
        callback = opts;
        opts = auth;
        auth = opts.authconfig || void 0;
      } else if (!callback && !opts) {
        opts = auth;
        auth = opts.authconfig;
      }
      var optsf = {
        path: "/images/create?",
        method: "POST",
        options: opts,
        authconfig: auth,
        abortSignal: opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Docker2.prototype.loadImage = function(file, opts, callback) {
      var self2 = this;
      if (!callback && typeof opts === "function") {
        callback = opts;
        opts = null;
      }
      var optsf = {
        path: "/images/load?",
        method: "POST",
        options: opts,
        file,
        abortSignal: opts && opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Docker2.prototype.importImage = function(file, opts, callback) {
      var self2 = this;
      if (!callback && typeof opts === "function") {
        callback = opts;
        opts = void 0;
      }
      if (!opts)
        opts = {};
      opts.fromSrc = "-";
      var optsf = {
        path: "/images/create?",
        method: "POST",
        options: opts,
        file,
        abortSignal: opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Docker2.prototype.checkAuth = function(opts, callback) {
      var self2 = this;
      var optsf = {
        path: "/auth",
        method: "POST",
        options: opts,
        abortSignal: opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Docker2.prototype.buildImage = function(file, opts, callback) {
      var self2 = this;
      if (!callback && typeof opts === "function") {
        callback = opts;
        opts = null;
      }
      function build(file2) {
        var optsf = {
          path: "/build?",
          method: "POST",
          file: file2,
          options: opts,
          abortSignal: opts && opts.abortSignal,
          isStream: true,
          statusCodes: {
            200: true,
            500: "server error"
          }
        };
        if (opts) {
          if (opts.registryconfig) {
            optsf.registryconfig = optsf.options.registryconfig;
            delete optsf.options.registryconfig;
          }
          if (opts.authconfig) {
            optsf.authconfig = optsf.options.authconfig;
            delete optsf.options.authconfig;
          }
        }
        if (callback === void 0) {
          return new self2.modem.Promise(function(resolve, reject) {
            self2.modem.dial(optsf, function(err, data) {
              if (err) {
                return reject(err);
              }
              resolve(data);
            });
          });
        } else {
          self2.modem.dial(optsf, function(err, data) {
            callback(err, data);
          });
        }
      }
      if (file && file.context) {
        var pack = tar.pack(file.context, {
          entries: file.src
        });
        return build(pack.pipe(zlib.createGzip()));
      } else {
        return build(file);
      }
    };
    Docker2.prototype.getContainer = function(id) {
      return new Container(this.modem, id);
    };
    Docker2.prototype.getImage = function(name) {
      return new Image(this.modem, name);
    };
    Docker2.prototype.getVolume = function(name) {
      return new Volume(this.modem, name);
    };
    Docker2.prototype.getPlugin = function(name, remote) {
      return new Plugin(this.modem, name, remote);
    };
    Docker2.prototype.getService = function(id) {
      return new Service(this.modem, id);
    };
    Docker2.prototype.getTask = function(id) {
      return new Task(this.modem, id);
    };
    Docker2.prototype.getNode = function(id) {
      return new Node(this.modem, id);
    };
    Docker2.prototype.getNetwork = function(id) {
      return new Network(this.modem, id);
    };
    Docker2.prototype.getSecret = function(id) {
      return new Secret(this.modem, id);
    };
    Docker2.prototype.getConfig = function(id) {
      return new Config(this.modem, id);
    };
    Docker2.prototype.getExec = function(id) {
      return new Exec(this.modem, id);
    };
    Docker2.prototype.listContainers = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/containers/json?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.listImages = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/images/json?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.getImages = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/images/get?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          400: "bad parameter",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.listServices = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/services?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.listNodes = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/nodes?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          404: "no such node",
          500: "server error",
          503: "node is not part of a swarm"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.listTasks = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/tasks?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.createSecret = function(opts, callback) {
      var args = util.processArgs(opts, callback);
      var self2 = this;
      var optsf = {
        path: "/secrets/create?",
        method: "POST",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          406: "server error or node is not part of a swarm",
          409: "name conflicts with an existing object",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(self2.getSecret(data.ID));
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, self2.getSecret(data.ID));
        });
      }
    };
    Docker2.prototype.createConfig = function(opts, callback) {
      var args = util.processArgs(opts, callback);
      var self2 = this;
      var optsf = {
        path: "/configs/create?",
        method: "POST",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          406: "server error or node is not part of a swarm",
          409: "name conflicts with an existing object",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(self2.getConfig(data.ID));
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, self2.getConfig(data.ID));
        });
      }
    };
    Docker2.prototype.listSecrets = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/secrets?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.listConfigs = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/configs?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.createPlugin = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins/create?",
        method: "POST",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          204: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(self2.getPlugin(args.opts.name));
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, self2.getPlugin(args.opts.name));
        });
      }
    };
    Docker2.prototype.listPlugins = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/plugins?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.pruneImages = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/images/prune?",
        method: "POST",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.pruneBuilder = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/build/prune",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.pruneContainers = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/containers/prune?",
        method: "POST",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.pruneVolumes = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/volumes/prune?",
        method: "POST",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.pruneNetworks = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/networks/prune?",
        method: "POST",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.createVolume = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/volumes/create?",
        method: "POST",
        allowEmpty: true,
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(self2.getVolume(data.Name));
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, self2.getVolume(data.Name));
        });
      }
    };
    Docker2.prototype.createService = function(auth, opts, callback) {
      if (!callback && typeof opts === "function") {
        callback = opts;
        opts = auth;
        auth = opts.authconfig || void 0;
      } else if (!opts && !callback) {
        opts = auth;
      }
      var self2 = this;
      var optsf = {
        path: "/services/create",
        method: "POST",
        options: opts,
        authconfig: auth,
        abortSignal: opts && opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(self2.getService(data.ID || data.Id));
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return callback(err, data);
          callback(err, self2.getService(data.ID || data.Id));
        });
      }
    };
    Docker2.prototype.listVolumes = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/volumes?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.createNetwork = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/networks/create?",
        method: "POST",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          201: true,
          404: "driver not found",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(self2.getNetwork(data.Id));
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          if (err)
            return args.callback(err, data);
          args.callback(err, self2.getNetwork(data.Id));
        });
      }
    };
    Docker2.prototype.listNetworks = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/networks?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.searchImages = function(opts, callback) {
      var self2 = this;
      var optsf = {
        path: "/images/search?",
        method: "GET",
        options: opts,
        authconfig: opts.authconfig,
        abortSignal: opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          callback(err, data);
        });
      }
    };
    Docker2.prototype.info = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var opts = {
        path: "/info",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(opts, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(opts, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.version = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var opts = {
        path: "/version",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(opts, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(opts, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.ping = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/_ping",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.df = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/system/df",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.getEvents = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/events?",
        method: "GET",
        options: args.opts,
        abortSignal: args.opts.abortSignal,
        isStream: true,
        statusCodes: {
          200: true,
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.pull = function(repoTag, opts, callback, auth) {
      var args = util.processArgs(opts, callback);
      var imageSrc = util.parseRepositoryTag(repoTag);
      args.opts.fromImage = imageSrc.repository;
      args.opts.tag = imageSrc.tag || "latest";
      var argsf = [args.opts, args.callback];
      if (auth) {
        argsf = [auth, args.opts, args.callback];
      }
      return this.createImage.apply(this, argsf);
    };
    Docker2.prototype.run = function(image, cmd, streamo, createOptions, startOptions, callback) {
      if (typeof arguments[arguments.length - 1] === "function") {
        return this.runCallback(image, cmd, streamo, createOptions, startOptions, callback);
      } else {
        return this.runPromise(image, cmd, streamo, createOptions, startOptions);
      }
    };
    Docker2.prototype.runCallback = function(image, cmd, streamo, createOptions, startOptions, callback) {
      if (!callback && typeof createOptions === "function") {
        callback = createOptions;
        createOptions = {};
        startOptions = {};
      } else if (!callback && typeof startOptions === "function") {
        callback = startOptions;
        startOptions = {};
      }
      var hub = new EventEmitter();
      function handler(err, container) {
        if (err)
          return callback(err, null, container);
        hub.emit("container", container);
        container.attach({
          stream: true,
          stdout: true,
          stderr: true
        }, function handler2(err2, stream) {
          if (err2)
            return callback(err2, null, container);
          hub.emit("stream", stream);
          if (streamo) {
            if (streamo instanceof Array) {
              stream.on("end", function() {
                try {
                  streamo[0].end();
                } catch (e) {
                }
                try {
                  streamo[1].end();
                } catch (e) {
                }
              });
              container.modem.demuxStream(stream, streamo[0], streamo[1]);
            } else {
              stream.setEncoding("utf8");
              stream.pipe(streamo, {
                end: true
              });
            }
          }
          container.start(startOptions, function(err3, data) {
            if (err3)
              return callback(err3, data, container);
            hub.emit("start", container);
            container.wait(function(err4, data2) {
              hub.emit("data", data2);
              callback(err4, data2, container);
            });
          });
        });
      }
      var optsc = {
        "Hostname": "",
        "User": "",
        "AttachStdin": false,
        "AttachStdout": true,
        "AttachStderr": true,
        "Tty": true,
        "OpenStdin": false,
        "StdinOnce": false,
        "Env": null,
        "Cmd": cmd,
        "Image": image,
        "Volumes": {},
        "VolumesFrom": []
      };
      extend(optsc, createOptions);
      this.createContainer(optsc, handler);
      return hub;
    };
    Docker2.prototype.runPromise = function(image, cmd, streamo, createOptions, startOptions) {
      var self2 = this;
      createOptions = createOptions || {};
      startOptions = startOptions || {};
      var optsc = {
        "Hostname": "",
        "User": "",
        "AttachStdin": false,
        "AttachStdout": true,
        "AttachStderr": true,
        "Tty": true,
        "OpenStdin": false,
        "StdinOnce": false,
        "Env": null,
        "Cmd": cmd,
        "Image": image,
        "Volumes": {},
        "VolumesFrom": []
      };
      extend(optsc, createOptions);
      var containero;
      return new this.modem.Promise(function(resolve, reject) {
        self2.createContainer(optsc).then(function(container) {
          containero = container;
          return container.attach({
            stream: true,
            stdout: true,
            stderr: true
          });
        }).then(function(stream) {
          if (streamo) {
            if (streamo instanceof Array) {
              stream.on("end", function() {
                try {
                  streamo[0].end();
                } catch (e) {
                }
                try {
                  streamo[1].end();
                } catch (e) {
                }
              });
              containero.modem.demuxStream(stream, streamo[0], streamo[1]);
            } else {
              stream.setEncoding("utf8");
              stream.pipe(streamo, {
                end: true
              });
            }
          }
          return containero.start(startOptions);
        }).then(function(data) {
          return containero.wait();
        }).then(function(data) {
          resolve([data, containero]);
        }).catch(function(err) {
          reject(err);
        });
      });
    };
    Docker2.prototype.swarmInit = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/swarm/init",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          406: "node is already part of a Swarm"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.swarmJoin = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/swarm/join",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          406: "node is already part of a Swarm"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.swarmLeave = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/swarm/leave?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          406: "node is not part of a Swarm"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.swarmUpdate = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/swarm/update?",
        method: "POST",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          400: "bad parameter",
          406: "node is already part of a Swarm"
        },
        options: args.opts
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.prototype.swarmInspect = function(opts, callback) {
      var self2 = this;
      var args = util.processArgs(opts, callback);
      var optsf = {
        path: "/swarm",
        method: "GET",
        abortSignal: args.opts.abortSignal,
        statusCodes: {
          200: true,
          406: "This node is not a swarm manager",
          500: "server error"
        }
      };
      if (args.callback === void 0) {
        return new this.modem.Promise(function(resolve, reject) {
          self2.modem.dial(optsf, function(err, data) {
            if (err) {
              return reject(err);
            }
            resolve(data);
          });
        });
      } else {
        this.modem.dial(optsf, function(err, data) {
          args.callback(err, data);
        });
      }
    };
    Docker2.Container = Container;
    Docker2.Image = Image;
    Docker2.Volume = Volume;
    Docker2.Network = Network;
    Docker2.Service = Service;
    Docker2.Plugin = Plugin;
    Docker2.Secret = Secret;
    Docker2.Task = Task;
    Docker2.Node = Node;
    Docker2.Exec = Exec;
    module2.exports = Docker2;
  }
});

// index.ts
var import_path = __toESM(require("path"));
var import_fs = __toESM(require("fs"));
var import_dockerode = __toESM(require_docker());
var import_child_process = require("child_process");
var Bash = (command) => {
  (0, import_child_process.exec)(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`error: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`stderr: ${stderr}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
  });
};
var GetPackageMetadata = (packageRoot) => {
  const packageMetadataFile = import_fs.default.readFileSync(import_path.default.join(packageRoot, "package-metadata.json"));
  return JSON.parse(packageMetadataFile);
};
var GetComposeFiles = (packageRoot, mode, statefulNodes) => {
  let composeFiles = [import_path.default.join(packageRoot, "docker-compose.yml")];
  if (mode === "dev") {
    composeFiles = [...composeFiles, import_path.default.join(packageRoot, "docker-compose.dev.yml")];
  }
  if (statefulNodes === "cluster") {
    composeFiles = [...composeFiles, import_path.default.join(packageRoot, "docker-compose.cluster.yml")];
  }
  return composeFiles;
};
var StackDeploy = (composeFiles, stackName = "instant") => {
  Bash(`docker stack deploy -c ${composeFiles.join(` -c `)} ${stackName}`);
};
var AwaitContainerStartup = async (docker, containerIdentifier) => {
  let containerFound = false;
  do {
    const containers = await docker.listContainers();
    console.log("\u{1F680} ~ file: index.ts ~ line 54 ~ AwaitContainerStartup ~ containers", containers);
    containerFound = containers.some((container2) => container2.Id === containerIdentifier);
  } while (!containerFound);
  const container = docker.getContainer(containerIdentifier);
  console.log("\u{1F680} ~ file: index.ts ~ line 56 ~ AwaitContainerStartup ~ container", container);
};
var AwaitContainerRunning = async (docker, containerIdentifier) => {
  var _a;
  let containerState = "";
  do {
    const container = docker.getContainer(containerIdentifier);
    console.log("\u{1F680} ~ file: index.ts ~ line 63 ~ AwaitContainerRunning ~ container", container);
    let containerInspect = await container.inspect();
    console.log("\u{1F680} ~ file: index.ts ~ line 65 ~ AwaitContainerRunning ~ containerInspect", containerInspect);
    containerState = (_a = containerInspect == null ? void 0 : containerInspect.State) == null ? void 0 : _a.Status;
  } while (containerState !== "running");
  console.log("Container is running");
};
var init = async ({ PACKAGE_ROOT, MODE, STATEFUL_NODES, docker }) => {
  const composeFiles = GetComposeFiles(PACKAGE_ROOT, MODE, STATEFUL_NODES);
  StackDeploy(composeFiles);
  console.info("Waiting for elasticsearch to start before automatically setting built-in passwords...");
  await AwaitContainerStartup(docker, "instant_analytics-datastore-elastic-search");
  await AwaitContainerRunning(docker, "instant_analytics-datastore-elastic-search");
};
var up = ({ PACKAGE_ROOT, MODE, STATEFUL_NODES }) => {
  const composeFiles = GetComposeFiles(PACKAGE_ROOT, MODE, STATEFUL_NODES);
  StackDeploy(composeFiles);
};
var down = ({ docker }) => {
  Bash("docker service scale instant_analytics-datastore-elastic-search=0");
};
var destroy = async ({ STATEFUL_NODES, docker }) => {
  await docker.getService("instant_analytics-datastore-elastic-search").remove();
  await docker.getVolume("instant_es-data").remove();
  if (STATEFUL_NODES === "cluster")
    console.info("Volumes are only deleted on the host on which the command is run. Elastic Search volumes on other nodes are not deleted");
};
var main = async () => {
  var _a;
  const [cmd, index, ACTION, MODE = "PROD"] = process.argv;
  const { STATEFUL_NODES = "cluster" } = process.env;
  const PROJECT_ROOT = import_path.default.join(__dirname, "../../../");
  const PACKAGE_ROOT = import_path.default.join(__dirname, "../../");
  const PACKAGE_NAME = (_a = GetPackageMetadata(PACKAGE_ROOT)) == null ? void 0 : _a.id;
  const docker = new import_dockerode.default({ socketPath: "/var/run/docker.sock" });
  const args = {
    ACTION,
    MODE,
    STATEFUL_NODES,
    PROJECT_ROOT,
    PACKAGE_ROOT,
    PACKAGE_NAME,
    docker
  };
  console.info(`Running Analytics Datastore Elastic Search package in ${STATEFUL_NODES.toUpperCase()} node mode`);
  console.info(`Running Analytics Datastore Elastic Search package in ${MODE.toUpperCase()} node mode`);
  switch (ACTION) {
    case "init":
      await init(args);
      break;
    case "up":
      up(args);
      break;
    case "down":
      down(args);
      break;
    case "destroy":
      await destroy(args);
      break;
    default:
      console.log("Valid options are: init, up, down, or destroy");
      break;
  }
};
main();
/*! safe-buffer. MIT License. Feross Aboukhadijeh <https://feross.org/opensource> */
