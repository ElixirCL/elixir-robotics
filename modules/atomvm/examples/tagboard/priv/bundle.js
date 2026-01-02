(() => {
  // js/lit-core.min.js
  var t = globalThis;
  var s = t.ShadowRoot && (void 0 === t.ShadyCSS || t.ShadyCSS.nativeShadow) && "adoptedStyleSheets" in Document.prototype && "replace" in CSSStyleSheet.prototype;
  var i = Symbol();
  var e = /* @__PURE__ */ new WeakMap();
  var h = class {
    constructor(t2, s2, e2) {
      if (this._$cssResult$ = true, e2 !== i) throw Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");
      this.cssText = t2, this.t = s2;
    }
    get styleSheet() {
      let t2 = this.i;
      const i2 = this.t;
      if (s && void 0 === t2) {
        const s2 = void 0 !== i2 && 1 === i2.length;
        s2 && (t2 = e.get(i2)), void 0 === t2 && ((this.i = t2 = new CSSStyleSheet()).replaceSync(this.cssText), s2 && e.set(i2, t2));
      }
      return t2;
    }
    toString() {
      return this.cssText;
    }
  };
  var o = (t2) => new h("string" == typeof t2 ? t2 : t2 + "", void 0, i);
  var r = (t2, ...s2) => {
    const e2 = 1 === t2.length ? t2[0] : s2.reduce((s3, i2, e3) => s3 + ((t3) => {
      if (true === t3._$cssResult$) return t3.cssText;
      if ("number" == typeof t3) return t3;
      throw Error("Value passed to 'css' function must be a 'css' function result: " + t3 + ". Use 'unsafeCSS' to pass non-literal values, but take care to ensure page security.");
    })(i2) + t2[e3 + 1], t2[0]);
    return new h(e2, t2, i);
  };
  var n = (i2, e2) => {
    if (s) i2.adoptedStyleSheets = e2.map((t2) => t2 instanceof CSSStyleSheet ? t2 : t2.styleSheet);
    else for (const s2 of e2) {
      const e3 = document.createElement("style"), h2 = t.litNonce;
      void 0 !== h2 && e3.setAttribute("nonce", h2), e3.textContent = s2.cssText, i2.appendChild(e3);
    }
  };
  var c = s ? (t2) => t2 : (t2) => t2 instanceof CSSStyleSheet ? ((t3) => {
    let s2 = "";
    for (const i2 of t3.cssRules) s2 += i2.cssText;
    return o(s2);
  })(t2) : t2;
  var { is: a, defineProperty: l, getOwnPropertyDescriptor: u, getOwnPropertyNames: d, getOwnPropertySymbols: f, getPrototypeOf: p } = Object;
  var v = globalThis;
  var m = v.trustedTypes;
  var y = m ? m.emptyScript : "";
  var g = v.reactiveElementPolyfillSupport;
  var _ = (t2, s2) => t2;
  var b = { toAttribute(t2, s2) {
    switch (s2) {
      case Boolean:
        t2 = t2 ? y : null;
        break;
      case Object:
      case Array:
        t2 = null == t2 ? t2 : JSON.stringify(t2);
    }
    return t2;
  }, fromAttribute(t2, s2) {
    let i2 = t2;
    switch (s2) {
      case Boolean:
        i2 = null !== t2;
        break;
      case Number:
        i2 = null === t2 ? null : Number(t2);
        break;
      case Object:
      case Array:
        try {
          i2 = JSON.parse(t2);
        } catch (t3) {
          i2 = null;
        }
    }
    return i2;
  } };
  var S = (t2, s2) => !a(t2, s2);
  var w = { attribute: true, type: String, converter: b, reflect: false, useDefault: false, hasChanged: S };
  Symbol.metadata ??= Symbol("metadata"), v.litPropertyMetadata ??= /* @__PURE__ */ new WeakMap();
  var $ = class extends HTMLElement {
    static addInitializer(t2) {
      this.o(), (this.l ??= []).push(t2);
    }
    static get observedAttributes() {
      return this.finalize(), this.u && [...this.u.keys()];
    }
    static createProperty(t2, s2 = w) {
      if (s2.state && (s2.attribute = false), this.o(), this.prototype.hasOwnProperty(t2) && ((s2 = Object.create(s2)).wrapped = true), this.elementProperties.set(t2, s2), !s2.noAccessor) {
        const i2 = Symbol(), e2 = this.getPropertyDescriptor(t2, i2, s2);
        void 0 !== e2 && l(this.prototype, t2, e2);
      }
    }
    static getPropertyDescriptor(t2, s2, i2) {
      const { get: e2, set: h2 } = u(this.prototype, t2) ?? { get() {
        return this[s2];
      }, set(t3) {
        this[s2] = t3;
      } };
      return { get: e2, set(s3) {
        const o2 = e2?.call(this);
        h2?.call(this, s3), this.requestUpdate(t2, o2, i2);
      }, configurable: true, enumerable: true };
    }
    static getPropertyOptions(t2) {
      return this.elementProperties.get(t2) ?? w;
    }
    static o() {
      if (this.hasOwnProperty(_("elementProperties"))) return;
      const t2 = p(this);
      t2.finalize(), void 0 !== t2.l && (this.l = [...t2.l]), this.elementProperties = new Map(t2.elementProperties);
    }
    static finalize() {
      if (this.hasOwnProperty(_("finalized"))) return;
      if (this.finalized = true, this.o(), this.hasOwnProperty(_("properties"))) {
        const t3 = this.properties, s2 = [...d(t3), ...f(t3)];
        for (const i2 of s2) this.createProperty(i2, t3[i2]);
      }
      const t2 = this[Symbol.metadata];
      if (null !== t2) {
        const s2 = litPropertyMetadata.get(t2);
        if (void 0 !== s2) for (const [t3, i2] of s2) this.elementProperties.set(t3, i2);
      }
      this.u = /* @__PURE__ */ new Map();
      for (const [t3, s2] of this.elementProperties) {
        const i2 = this.p(t3, s2);
        void 0 !== i2 && this.u.set(i2, t3);
      }
      this.elementStyles = this.finalizeStyles(this.styles);
    }
    static finalizeStyles(t2) {
      const s2 = [];
      if (Array.isArray(t2)) {
        const i2 = new Set(t2.flat(1 / 0).reverse());
        for (const t3 of i2) s2.unshift(c(t3));
      } else void 0 !== t2 && s2.push(c(t2));
      return s2;
    }
    static p(t2, s2) {
      const i2 = s2.attribute;
      return false === i2 ? void 0 : "string" == typeof i2 ? i2 : "string" == typeof t2 ? t2.toLowerCase() : void 0;
    }
    constructor() {
      super(), this.v = void 0, this.isUpdatePending = false, this.hasUpdated = false, this.m = null, this._();
    }
    _() {
      this.S = new Promise((t2) => this.enableUpdating = t2), this._$AL = /* @__PURE__ */ new Map(), this.$(), this.requestUpdate(), this.constructor.l?.forEach((t2) => t2(this));
    }
    addController(t2) {
      (this.P ??= /* @__PURE__ */ new Set()).add(t2), void 0 !== this.renderRoot && this.isConnected && t2.hostConnected?.();
    }
    removeController(t2) {
      this.P?.delete(t2);
    }
    $() {
      const t2 = /* @__PURE__ */ new Map(), s2 = this.constructor.elementProperties;
      for (const i2 of s2.keys()) this.hasOwnProperty(i2) && (t2.set(i2, this[i2]), delete this[i2]);
      t2.size > 0 && (this.v = t2);
    }
    createRenderRoot() {
      const t2 = this.shadowRoot ?? this.attachShadow(this.constructor.shadowRootOptions);
      return n(t2, this.constructor.elementStyles), t2;
    }
    connectedCallback() {
      this.renderRoot ??= this.createRenderRoot(), this.enableUpdating(true), this.P?.forEach((t2) => t2.hostConnected?.());
    }
    enableUpdating(t2) {
    }
    disconnectedCallback() {
      this.P?.forEach((t2) => t2.hostDisconnected?.());
    }
    attributeChangedCallback(t2, s2, i2) {
      this._$AK(t2, i2);
    }
    C(t2, s2) {
      const i2 = this.constructor.elementProperties.get(t2), e2 = this.constructor.p(t2, i2);
      if (void 0 !== e2 && true === i2.reflect) {
        const h2 = (void 0 !== i2.converter?.toAttribute ? i2.converter : b).toAttribute(s2, i2.type);
        this.m = t2, null == h2 ? this.removeAttribute(e2) : this.setAttribute(e2, h2), this.m = null;
      }
    }
    _$AK(t2, s2) {
      const i2 = this.constructor, e2 = i2.u.get(t2);
      if (void 0 !== e2 && this.m !== e2) {
        const t3 = i2.getPropertyOptions(e2), h2 = "function" == typeof t3.converter ? { fromAttribute: t3.converter } : void 0 !== t3.converter?.fromAttribute ? t3.converter : b;
        this.m = e2;
        const o2 = h2.fromAttribute(s2, t3.type);
        this[e2] = o2 ?? this.T?.get(e2) ?? o2, this.m = null;
      }
    }
    requestUpdate(t2, s2, i2) {
      if (void 0 !== t2) {
        const e2 = this.constructor, h2 = this[t2];
        if (i2 ??= e2.getPropertyOptions(t2), !((i2.hasChanged ?? S)(h2, s2) || i2.useDefault && i2.reflect && h2 === this.T?.get(t2) && !this.hasAttribute(e2.p(t2, i2)))) return;
        this.M(t2, s2, i2);
      }
      false === this.isUpdatePending && (this.S = this.k());
    }
    M(t2, s2, { useDefault: i2, reflect: e2, wrapped: h2 }, o2) {
      i2 && !(this.T ??= /* @__PURE__ */ new Map()).has(t2) && (this.T.set(t2, o2 ?? s2 ?? this[t2]), true !== h2 || void 0 !== o2) || (this._$AL.has(t2) || (this.hasUpdated || i2 || (s2 = void 0), this._$AL.set(t2, s2)), true === e2 && this.m !== t2 && (this.A ??= /* @__PURE__ */ new Set()).add(t2));
    }
    async k() {
      this.isUpdatePending = true;
      try {
        await this.S;
      } catch (t3) {
        Promise.reject(t3);
      }
      const t2 = this.scheduleUpdate();
      return null != t2 && await t2, !this.isUpdatePending;
    }
    scheduleUpdate() {
      return this.performUpdate();
    }
    performUpdate() {
      if (!this.isUpdatePending) return;
      if (!this.hasUpdated) {
        if (this.renderRoot ??= this.createRenderRoot(), this.v) {
          for (const [t4, s3] of this.v) this[t4] = s3;
          this.v = void 0;
        }
        const t3 = this.constructor.elementProperties;
        if (t3.size > 0) for (const [s3, i2] of t3) {
          const { wrapped: t4 } = i2, e2 = this[s3];
          true !== t4 || this._$AL.has(s3) || void 0 === e2 || this.M(s3, void 0, i2, e2);
        }
      }
      let t2 = false;
      const s2 = this._$AL;
      try {
        t2 = this.shouldUpdate(s2), t2 ? (this.willUpdate(s2), this.P?.forEach((t3) => t3.hostUpdate?.()), this.update(s2)) : this.U();
      } catch (s3) {
        throw t2 = false, this.U(), s3;
      }
      t2 && this._$AE(s2);
    }
    willUpdate(t2) {
    }
    _$AE(t2) {
      this.P?.forEach((t3) => t3.hostUpdated?.()), this.hasUpdated || (this.hasUpdated = true, this.firstUpdated(t2)), this.updated(t2);
    }
    U() {
      this._$AL = /* @__PURE__ */ new Map(), this.isUpdatePending = false;
    }
    get updateComplete() {
      return this.getUpdateComplete();
    }
    getUpdateComplete() {
      return this.S;
    }
    shouldUpdate(t2) {
      return true;
    }
    update(t2) {
      this.A &&= this.A.forEach((t3) => this.C(t3, this[t3])), this.U();
    }
    updated(t2) {
    }
    firstUpdated(t2) {
    }
  };
  $.elementStyles = [], $.shadowRootOptions = { mode: "open" }, $[_("elementProperties")] = /* @__PURE__ */ new Map(), $[_("finalized")] = /* @__PURE__ */ new Map(), g?.({ ReactiveElement: $ }), (v.reactiveElementVersions ??= []).push("2.1.1");
  var P = globalThis;
  var C = P.trustedTypes;
  var T = C ? C.createPolicy("lit-html", { createHTML: (t2) => t2 }) : void 0;
  var M = "$lit$";
  var x = `lit$${Math.random().toFixed(9).slice(2)}$`;
  var k = "?" + x;
  var A = `<${k}>`;
  var E = document;
  var U = () => E.createComment("");
  var N = (t2) => null === t2 || "object" != typeof t2 && "function" != typeof t2;
  var O = Array.isArray;
  var R = (t2) => O(t2) || "function" == typeof t2?.[Symbol.iterator];
  var z = "[ 	\n\f\r]";
  var V = /<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g;
  var D = /-->/g;
  var L = />/g;
  var j = RegExp(`>|${z}(?:([^\\s"'>=/]+)(${z}*=${z}*(?:[^ 	
\f\r"'\`<>=]|("|')|))|$)`, "g");
  var I = /'/g;
  var H = /"/g;
  var B = /^(?:script|style|textarea|title)$/i;
  var W = (t2) => (s2, ...i2) => ({ _$litType$: t2, strings: s2, values: i2 });
  var q = W(1);
  var J = W(2);
  var Z = W(3);
  var F = Symbol.for("lit-noChange");
  var G = Symbol.for("lit-nothing");
  var K = /* @__PURE__ */ new WeakMap();
  var Q = E.createTreeWalker(E, 129);
  function X(t2, s2) {
    if (!O(t2) || !t2.hasOwnProperty("raw")) throw Error("invalid template strings array");
    return void 0 !== T ? T.createHTML(s2) : s2;
  }
  var Y = (t2, s2) => {
    const i2 = t2.length - 1, e2 = [];
    let h2, o2 = 2 === s2 ? "<svg>" : 3 === s2 ? "<math>" : "", r2 = V;
    for (let s3 = 0; s3 < i2; s3++) {
      const i3 = t2[s3];
      let n2, c2, a2 = -1, l2 = 0;
      for (; l2 < i3.length && (r2.lastIndex = l2, c2 = r2.exec(i3), null !== c2); ) l2 = r2.lastIndex, r2 === V ? "!--" === c2[1] ? r2 = D : void 0 !== c2[1] ? r2 = L : void 0 !== c2[2] ? (B.test(c2[2]) && (h2 = RegExp("</" + c2[2], "g")), r2 = j) : void 0 !== c2[3] && (r2 = j) : r2 === j ? ">" === c2[0] ? (r2 = h2 ?? V, a2 = -1) : void 0 === c2[1] ? a2 = -2 : (a2 = r2.lastIndex - c2[2].length, n2 = c2[1], r2 = void 0 === c2[3] ? j : '"' === c2[3] ? H : I) : r2 === H || r2 === I ? r2 = j : r2 === D || r2 === L ? r2 = V : (r2 = j, h2 = void 0);
      const u2 = r2 === j && t2[s3 + 1].startsWith("/>") ? " " : "";
      o2 += r2 === V ? i3 + A : a2 >= 0 ? (e2.push(n2), i3.slice(0, a2) + M + i3.slice(a2) + x + u2) : i3 + x + (-2 === a2 ? s3 : u2);
    }
    return [X(t2, o2 + (t2[i2] || "<?>") + (2 === s2 ? "</svg>" : 3 === s2 ? "</math>" : "")), e2];
  };
  var tt = class _tt {
    constructor({ strings: t2, _$litType$: s2 }, i2) {
      let e2;
      this.parts = [];
      let h2 = 0, o2 = 0;
      const r2 = t2.length - 1, n2 = this.parts, [c2, a2] = Y(t2, s2);
      if (this.el = _tt.createElement(c2, i2), Q.currentNode = this.el.content, 2 === s2 || 3 === s2) {
        const t3 = this.el.content.firstChild;
        t3.replaceWith(...t3.childNodes);
      }
      for (; null !== (e2 = Q.nextNode()) && n2.length < r2; ) {
        if (1 === e2.nodeType) {
          if (e2.hasAttributes()) for (const t3 of e2.getAttributeNames()) if (t3.endsWith(M)) {
            const s3 = a2[o2++], i3 = e2.getAttribute(t3).split(x), r3 = /([.?@])?(.*)/.exec(s3);
            n2.push({ type: 1, index: h2, name: r3[2], strings: i3, ctor: "." === r3[1] ? ot : "?" === r3[1] ? rt : "@" === r3[1] ? nt : ht }), e2.removeAttribute(t3);
          } else t3.startsWith(x) && (n2.push({ type: 6, index: h2 }), e2.removeAttribute(t3));
          if (B.test(e2.tagName)) {
            const t3 = e2.textContent.split(x), s3 = t3.length - 1;
            if (s3 > 0) {
              e2.textContent = C ? C.emptyScript : "";
              for (let i3 = 0; i3 < s3; i3++) e2.append(t3[i3], U()), Q.nextNode(), n2.push({ type: 2, index: ++h2 });
              e2.append(t3[s3], U());
            }
          }
        } else if (8 === e2.nodeType) if (e2.data === k) n2.push({ type: 2, index: h2 });
        else {
          let t3 = -1;
          for (; -1 !== (t3 = e2.data.indexOf(x, t3 + 1)); ) n2.push({ type: 7, index: h2 }), t3 += x.length - 1;
        }
        h2++;
      }
    }
    static createElement(t2, s2) {
      const i2 = E.createElement("template");
      return i2.innerHTML = t2, i2;
    }
  };
  function st(t2, s2, i2 = t2, e2) {
    if (s2 === F) return s2;
    let h2 = void 0 !== e2 ? i2.N?.[e2] : i2.O;
    const o2 = N(s2) ? void 0 : s2._$litDirective$;
    return h2?.constructor !== o2 && (h2?._$AO?.(false), void 0 === o2 ? h2 = void 0 : (h2 = new o2(t2), h2._$AT(t2, i2, e2)), void 0 !== e2 ? (i2.N ??= [])[e2] = h2 : i2.O = h2), void 0 !== h2 && (s2 = st(t2, h2._$AS(t2, s2.values), h2, e2)), s2;
  }
  var it = class {
    constructor(t2, s2) {
      this._$AV = [], this._$AN = void 0, this._$AD = t2, this._$AM = s2;
    }
    get parentNode() {
      return this._$AM.parentNode;
    }
    get _$AU() {
      return this._$AM._$AU;
    }
    R(t2) {
      const { el: { content: s2 }, parts: i2 } = this._$AD, e2 = (t2?.creationScope ?? E).importNode(s2, true);
      Q.currentNode = e2;
      let h2 = Q.nextNode(), o2 = 0, r2 = 0, n2 = i2[0];
      for (; void 0 !== n2; ) {
        if (o2 === n2.index) {
          let s3;
          2 === n2.type ? s3 = new et(h2, h2.nextSibling, this, t2) : 1 === n2.type ? s3 = new n2.ctor(h2, n2.name, n2.strings, this, t2) : 6 === n2.type && (s3 = new ct(h2, this, t2)), this._$AV.push(s3), n2 = i2[++r2];
        }
        o2 !== n2?.index && (h2 = Q.nextNode(), o2++);
      }
      return Q.currentNode = E, e2;
    }
    V(t2) {
      let s2 = 0;
      for (const i2 of this._$AV) void 0 !== i2 && (void 0 !== i2.strings ? (i2._$AI(t2, i2, s2), s2 += i2.strings.length - 2) : i2._$AI(t2[s2])), s2++;
    }
  };
  var et = class _et {
    get _$AU() {
      return this._$AM?._$AU ?? this.D;
    }
    constructor(t2, s2, i2, e2) {
      this.type = 2, this._$AH = G, this._$AN = void 0, this._$AA = t2, this._$AB = s2, this._$AM = i2, this.options = e2, this.D = e2?.isConnected ?? true;
    }
    get parentNode() {
      let t2 = this._$AA.parentNode;
      const s2 = this._$AM;
      return void 0 !== s2 && 11 === t2?.nodeType && (t2 = s2.parentNode), t2;
    }
    get startNode() {
      return this._$AA;
    }
    get endNode() {
      return this._$AB;
    }
    _$AI(t2, s2 = this) {
      t2 = st(this, t2, s2), N(t2) ? t2 === G || null == t2 || "" === t2 ? (this._$AH !== G && this._$AR(), this._$AH = G) : t2 !== this._$AH && t2 !== F && this.L(t2) : void 0 !== t2._$litType$ ? this.j(t2) : void 0 !== t2.nodeType ? this.I(t2) : R(t2) ? this.H(t2) : this.L(t2);
    }
    B(t2) {
      return this._$AA.parentNode.insertBefore(t2, this._$AB);
    }
    I(t2) {
      this._$AH !== t2 && (this._$AR(), this._$AH = this.B(t2));
    }
    L(t2) {
      this._$AH !== G && N(this._$AH) ? this._$AA.nextSibling.data = t2 : this.I(E.createTextNode(t2)), this._$AH = t2;
    }
    j(t2) {
      const { values: s2, _$litType$: i2 } = t2, e2 = "number" == typeof i2 ? this._$AC(t2) : (void 0 === i2.el && (i2.el = tt.createElement(X(i2.h, i2.h[0]), this.options)), i2);
      if (this._$AH?._$AD === e2) this._$AH.V(s2);
      else {
        const t3 = new it(e2, this), i3 = t3.R(this.options);
        t3.V(s2), this.I(i3), this._$AH = t3;
      }
    }
    _$AC(t2) {
      let s2 = K.get(t2.strings);
      return void 0 === s2 && K.set(t2.strings, s2 = new tt(t2)), s2;
    }
    H(t2) {
      O(this._$AH) || (this._$AH = [], this._$AR());
      const s2 = this._$AH;
      let i2, e2 = 0;
      for (const h2 of t2) e2 === s2.length ? s2.push(i2 = new _et(this.B(U()), this.B(U()), this, this.options)) : i2 = s2[e2], i2._$AI(h2), e2++;
      e2 < s2.length && (this._$AR(i2 && i2._$AB.nextSibling, e2), s2.length = e2);
    }
    _$AR(t2 = this._$AA.nextSibling, s2) {
      for (this._$AP?.(false, true, s2); t2 !== this._$AB; ) {
        const s3 = t2.nextSibling;
        t2.remove(), t2 = s3;
      }
    }
    setConnected(t2) {
      void 0 === this._$AM && (this.D = t2, this._$AP?.(t2));
    }
  };
  var ht = class {
    get tagName() {
      return this.element.tagName;
    }
    get _$AU() {
      return this._$AM._$AU;
    }
    constructor(t2, s2, i2, e2, h2) {
      this.type = 1, this._$AH = G, this._$AN = void 0, this.element = t2, this.name = s2, this._$AM = e2, this.options = h2, i2.length > 2 || "" !== i2[0] || "" !== i2[1] ? (this._$AH = Array(i2.length - 1).fill(new String()), this.strings = i2) : this._$AH = G;
    }
    _$AI(t2, s2 = this, i2, e2) {
      const h2 = this.strings;
      let o2 = false;
      if (void 0 === h2) t2 = st(this, t2, s2, 0), o2 = !N(t2) || t2 !== this._$AH && t2 !== F, o2 && (this._$AH = t2);
      else {
        const e3 = t2;
        let r2, n2;
        for (t2 = h2[0], r2 = 0; r2 < h2.length - 1; r2++) n2 = st(this, e3[i2 + r2], s2, r2), n2 === F && (n2 = this._$AH[r2]), o2 ||= !N(n2) || n2 !== this._$AH[r2], n2 === G ? t2 = G : t2 !== G && (t2 += (n2 ?? "") + h2[r2 + 1]), this._$AH[r2] = n2;
      }
      o2 && !e2 && this.W(t2);
    }
    W(t2) {
      t2 === G ? this.element.removeAttribute(this.name) : this.element.setAttribute(this.name, t2 ?? "");
    }
  };
  var ot = class extends ht {
    constructor() {
      super(...arguments), this.type = 3;
    }
    W(t2) {
      this.element[this.name] = t2 === G ? void 0 : t2;
    }
  };
  var rt = class extends ht {
    constructor() {
      super(...arguments), this.type = 4;
    }
    W(t2) {
      this.element.toggleAttribute(this.name, !!t2 && t2 !== G);
    }
  };
  var nt = class extends ht {
    constructor(t2, s2, i2, e2, h2) {
      super(t2, s2, i2, e2, h2), this.type = 5;
    }
    _$AI(t2, s2 = this) {
      if ((t2 = st(this, t2, s2, 0) ?? G) === F) return;
      const i2 = this._$AH, e2 = t2 === G && i2 !== G || t2.capture !== i2.capture || t2.once !== i2.once || t2.passive !== i2.passive, h2 = t2 !== G && (i2 === G || e2);
      e2 && this.element.removeEventListener(this.name, this, i2), h2 && this.element.addEventListener(this.name, this, t2), this._$AH = t2;
    }
    handleEvent(t2) {
      "function" == typeof this._$AH ? this._$AH.call(this.options?.host ?? this.element, t2) : this._$AH.handleEvent(t2);
    }
  };
  var ct = class {
    constructor(t2, s2, i2) {
      this.element = t2, this.type = 6, this._$AN = void 0, this._$AM = s2, this.options = i2;
    }
    get _$AU() {
      return this._$AM._$AU;
    }
    _$AI(t2) {
      st(this, t2);
    }
  };
  var lt = P.litHtmlPolyfillSupport;
  lt?.(tt, et), (P.litHtmlVersions ??= []).push("3.3.1");
  var ut = (t2, s2, i2) => {
    const e2 = i2?.renderBefore ?? s2;
    let h2 = e2._$litPart$;
    if (void 0 === h2) {
      const t3 = i2?.renderBefore ?? null;
      e2._$litPart$ = h2 = new et(s2.insertBefore(U(), t3), t3, void 0, i2 ?? {});
    }
    return h2._$AI(t2), h2;
  };
  var dt = globalThis;
  var ft = class extends $ {
    constructor() {
      super(...arguments), this.renderOptions = { host: this }, this.rt = void 0;
    }
    createRenderRoot() {
      const t2 = super.createRenderRoot();
      return this.renderOptions.renderBefore ??= t2.firstChild, t2;
    }
    update(t2) {
      const s2 = this.render();
      this.hasUpdated || (this.renderOptions.isConnected = this.isConnected), super.update(t2), this.rt = ut(s2, this.renderRoot, this.renderOptions);
    }
    connectedCallback() {
      super.connectedCallback(), this.rt?.setConnected(true);
    }
    disconnectedCallback() {
      super.disconnectedCallback(), this.rt?.setConnected(false);
    }
    render() {
      return F;
    }
  };
  ft._$litElement$ = true, ft["finalized"] = true, dt.litElementHydrateSupport?.({ LitElement: ft });
  var pt = dt.litElementPolyfillSupport;
  pt?.({ LitElement: ft });
  (dt.litElementVersions ??= []).push("4.2.1");

  // js/tag.js
  var Tag = class extends ft {
    static properties = {
      tag: {}
    };
    static styles = r`
    :host {
      color: blue;
      position: relative;
      width: 100%;
      flex-grow: 1;
    }

    p {
      padding: 0.5rem;
    }

    .author {
      color: black;
    }

    .date {
      position: absolute;
      top: 4px;
      left: 0;
      font-size: 0.6rem;
    }
  `;
    constructor() {
      super();
      this.tag = {};
    }
    renderDate(timestamp) {
      const date = new Date(parseInt(timestamp));
      return q`<span class="date">${date.toLocaleString()}</span>`;
    }
    render() {
      return q`<p>${this.renderDate(this.tag.timestamp)} <span class="author">${this.tag.author} > </span> ${this.tag.content}</p>`;
    }
  };
  customElements.define("my-tag", Tag);

  // js/board.js
  var TagBoard = class extends ft {
    static properties = {
      _username: { state: true },
      _tags: { state: true },
      _content: { state: true }
    };
    static styles = r`
    :host {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      justify-content: space-between;
      align-items: center;
      color: blue;
      border: 1px solid black;
    }

    .name-input-box {
      position: absolute;
      z-index: 10;

      padding: 2rem;
      border-radius: 0.5rem;
      background-color: white;
      box-shadow: 0 4px 8px rgba(0,0,0,0.2);
      max-width: 90%;
      width: 400px;
      text-align: center;
    }

    .name-input-box form {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      align-items: center;
    }

    .name-input-box input {
      padding: 0.5rem;
      border-radius: 0.25rem;
      border: 1px solid #ccc;
      width: 80%;
      max-width: 300px;
    }

    .name-input-box button {
      padding: 0.75rem 1.5rem;
      border: none;
      border-radius: 0.25rem;
      background-color: #007bff;
      color: white;
      cursor: pointer;
      font-size: 1rem;
    }

    .tags {
      display: flex;
      flex-direction: column;

      width: 36rem;
      height: 30rem;
      max-width: 100vw;
      max-height: 100vh;
      overflow-y: scroll;

      & > :not(:last-child) {
        border-bottom: 2px solid #000000;
      }
    }

    form {
      width: 100%;
      display: flex;
      gap: 0.5rem;
      padding-top: 0.5rem;
      padding-bottom: 0.5rem;
    }

    form input {
        flex-grow: 1;
    }
  `;
    constructor() {
      super();
      this._username = "";
      this._content = "";
      this._tags = [];
      this.fetchTags();
      setInterval(() => this.fetchTags(), 3e3);
    }
    onNameSubmit(e2) {
      e2.preventDefault();
    }
    onNameInput(e2) {
      this._username = e2.target.value;
    }
    async onTagSubmit(e2) {
      e2.preventDefault();
      const content = this._content;
      this._content = "";
      let body = { author: this._username, content, timestamp: (/* @__PURE__ */ new Date()).getTime().toString() };
      await fetch("/tags/create", { method: "POST", body: JSON.stringify(body) });
      setTimeout(() => this.fetchTags(), 500);
    }
    onTagInput(e2) {
      this._content = e2.target.value;
    }
    render() {
      return q`
      ${this._username == "" ? this.renderUsernameInput() : ""}

      <div class="tags">${this.renderTags(this._tags)}</div>
      <form @submit=${this.onTagSubmit}>
        <input placeholder="Mensaje" @input=${this.onTagInput} .value=${this._content} />
        <button>Enviar</button>
      </form>
      `;
    }
    async fetchTags() {
      try {
        const response = await fetch("/tags/get");
        const { tags } = await response.json();
        this._tags = tags == "" ? [] : tags;
      } catch (error) {
        console.error("Error fetching data:", error);
      }
    }
    renderTags(tags) {
      return tags.map((tag) => q`<my-tag .tag=${tag}  />`);
    }
    renderUsernameInput() {
      return q`
      <div class="name-input-box">
        <h2>Introduzca un nombre de usuario:</h2>
        <form @submit=${this.onNameSubmit}>
          <input @change=${this.onNameInput} .value=${this._username} placeholder="Nombre de usuario" />
          <button>Ok</button>
        </form>
      </div>
      `;
    }
  };
  customElements.define("tag-board", TagBoard);
})();
/**
 * @license
 * Copyright 2019 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
/**
 * @license
 * Copyright 2022 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
