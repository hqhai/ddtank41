// Portal page: server branding, login/register modal. Talks to the existing handlers:
//   checkuser.ashx?username=&password=<md5>       -> "ok" | error text
//   auth/register.ashx?username=&password=&repassword=&email=&code=  -> "ok" | "exit" (taken) | error text
//   auth/validatecode.ashx                        -> captcha image (stored in session)
(function () {
  var cfg = window.SITE_CONFIG || {};
  var name = cfg.name || "Bắn Súng";

  document.title = name + " – " + (cfg.slogan ? cfg.slogan : "Trang chủ");
  document.querySelectorAll('[data-site="name"]').forEach(function (el) { el.textContent = name; });
  if (cfg.slogan) document.querySelectorAll('[data-site="slogan"]').forEach(function (el) { el.textContent = cfg.slogan; });
  document.querySelectorAll('[data-site="community"]').forEach(function (el) {
    if (cfg.community) el.href = cfg.community;
    else { el.previousElementSibling && el.previousElementSibling.remove(); el.remove(); }
  });

  // ---- modal ----
  var modal = document.getElementById("auth");
  var captcha = document.getElementById("captcha");

  function refreshCaptcha() { captcha.src = "auth/validatecode.ashx?" + Date.now(); }

  function show(tab) {
    document.querySelectorAll("[data-tab]").forEach(function (b) { b.classList.toggle("active", b.dataset.tab === tab); });
    document.querySelectorAll(".form").forEach(function (f) { f.classList.toggle("active", f.id === "form-" + tab); });
    if (tab === "register") refreshCaptcha();
    modal.classList.add("open");
    var first = document.querySelector("#form-" + tab + " input");
    if (first) setTimeout(function () { first.focus(); }, 50);
  }
  function hide() { modal.classList.remove("open"); }

  document.querySelectorAll("[data-open]").forEach(function (b) {
    b.addEventListener("click", function (e) { e.preventDefault(); show(b.dataset.open); });
  });
  document.querySelectorAll("[data-tab]").forEach(function (b) {
    b.addEventListener("click", function () { show(b.dataset.tab); });
  });
  modal.addEventListener("click", function (e) { if (e.target === modal || e.target.hasAttribute("data-close")) hide(); });
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") hide(); });
  captcha.addEventListener("click", refreshCaptcha);

  function qs(obj) {
    return Object.keys(obj).map(function (k) { return k + "=" + encodeURIComponent(obj[k]); }).join("&");
  }
  function get(url, params) {
    return fetch(url + "?" + qs(params), { credentials: "same-origin", cache: "no-store" })
      .then(function (r) { return r.text(); })
      .then(function (t) { return t.trim(); });
  }
  function setMsg(form, text, ok) {
    var m = form.querySelector("[data-msg]");
    m.textContent = text || "";
    m.className = "msg " + (ok ? "ok" : "err");
  }
  function busy(form, on) { form.querySelector(".submit").disabled = on; }

  function login(user, pass, form) {
    return get("checkuser.ashx", { username: user, password: MD5(pass) }).then(function (res) {
      if (res === "ok") {
        setMsg(form, "Đăng nhập thành công, đang vào game…", true);
        location.href = "loading.htm";
        return true;
      }
      setMsg(form, res || "Tài khoản hoặc mật khẩu không đúng!");
      return false;
    });
  }

  document.getElementById("form-login").addEventListener("submit", function (e) {
    e.preventDefault();
    var f = e.target;
    busy(f, true); setMsg(f, "");
    login(f.username.value.trim(), f.password.value, f)
      .catch(function () { setMsg(f, "Không kết nối được máy chủ, thử lại sau."); })
      .then(function () { busy(f, false); });
  });

  document.getElementById("form-register").addEventListener("submit", function (e) {
    e.preventDefault();
    var f = e.target;
    if (f.password.value !== f.repassword.value) { setMsg(f, "Mật khẩu nhập lại không khớp."); return; }
    busy(f, true); setMsg(f, "");
    get("auth/register.ashx", {
      username: f.username.value.trim(), password: f.password.value, repassword: f.repassword.value,
      email: f.email.value.trim(), code: f.code.value.trim()
    }).then(function (res) {
      if (res === "ok") return login(f.username.value.trim(), f.password.value, f);
      setMsg(f, res === "exit" ? "Tài khoản đã có người dùng." : (res || "Đăng ký thất bại."));
      refreshCaptcha(); f.code.value = "";
    }).catch(function () { setMsg(f, "Không kết nối được máy chủ, thử lại sau."); })
      .then(function () { busy(f, false); });
  });

  // index.htm?open=self (sent back here when the game session expired) opens the login box
  if (/[?&]open=/.test(location.search)) show("login");
})();
