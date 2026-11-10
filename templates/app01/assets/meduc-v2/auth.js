/* Reuse member.js validation, reCAPTCHA, CSRF and account endpoints. Modal responses stay on the current page. */
(() => {
  "use strict";
  document.addEventListener("click", (event) => {
    const button = event.target.closest("[data-ma-password]");
    if (!button) return;
    const input = document.getElementById(button.getAttribute("aria-controls"));
    if (!input) return;
    const visible = input.type === "password";
    input.type = visible ? "text" : "password";
    button.setAttribute("aria-pressed", String(visible));
    button.setAttribute("aria-label", visible ? "Ẩn mật khẩu" : "Hiện mật khẩu");
  });

  document.addEventListener("DOMContentLoaded", () => {
    const $ = window.jQuery;
    if (!$) return;
    const modal = document.getElementById("login-modal");
    if (!modal) return;
    const panels = [...modal.querySelectorAll("[data-ma-panel]")];
    const tabs = [...modal.querySelectorAll('[role="tab"][data-ma-view]')];
    const loginForm = modal.querySelector('[nh-form="member-login"]');
    const verifyForm = modal.querySelector("[data-ma-verify]");
    let requestedView = null;
    let opener = null;
    let contextMessage = "";
    let completedSinceOpen = false;
    const resendTimers = new WeakMap();
    let verifyInFlight = false;
    const resendButton = modal.querySelector("[data-ma-resend]");
    function countdown(seconds, button = resendButton) {
      if (!button) return;
      clearInterval(resendTimers.get(button));
      const until = Date.now() + Math.max(0, Number(seconds) || 0) * 1000;
      const update = () => {
        const remaining = Math.max(0, Math.ceil((until - Date.now()) / 1000));
        button.disabled = remaining > 0;
        button.textContent = remaining ? "Gửi lại sau " + remaining + "s" : "Gửi lại mã";
        if (!remaining) clearInterval(resendTimers.get(button));
      };
      update();
      if (until > Date.now()) resendTimers.set(button, setInterval(update, 1000));
    }

    const copy = {
      profile: ["Hoàn tất thông tin học viên.", "Bổ sung thông tin bên dưới để tiếp tục cùng MedUC. Những thông tin đã có sẽ được điền sẵn."],
      login: ["Chào mừng trở lại.", "Đăng nhập để tiếp tục hành trình học Y."],
      forgot: ["Quên mật khẩu?", "Nhập email đã đăng ký. MedUC sẽ gửi mã OTP để bạn đặt lại mật khẩu."],
      reset: ["Đặt mật khẩu mới.", "Nhập mã OTP từ email và chọn mật khẩu mới cho tài khoản của bạn."],
      register: ["Bắt đầu cùng MedUC.", "Tạo tài khoản để học, luyện tập và lưu lại hành trình của bạn."],
      verify: ["Xác thực email.", "Chỉ còn một bước: nhập mã OTP để hoàn tất đăng ký và tự động đăng nhập."]
    };
    function showView(view, focus = false) {
      if (!copy[view]) view = "login";
      panels.forEach((panel) => { panel.hidden = panel.dataset.maPanel !== view; });
      tabs.forEach((tab) => {
        const selected = tab.dataset.maView === view;
        tab.setAttribute("aria-selected", String(selected));
        tab.tabIndex = selected ? 0 : -1;
      });
      modal.classList.toggle("is-register", view === "register");
      modal.classList.toggle("is-profile", view === "profile");
      modal.querySelector('[role="tablist"]').hidden = !["login", "register"].includes(view);
      modal.querySelector(".ma-eyebrow").textContent = view === "verify" ? "BƯỚC 2 / 2 · XÁC THỰC EMAIL" : view === "forgot" ? "KHÔI PHỤC TÀI KHOẢN / 01" : view === "reset" ? "KHÔI PHỤC TÀI KHOẢN / 02" : "TÀI KHOẢN MEDUC";
      modal.querySelector("#ma-modal-title").textContent = copy[view][0];
      modal.querySelector("#ma-modal-description").textContent = contextMessage && ["login", "register"].includes(view) ? contextMessage : copy[view][1];
      modal.querySelector(".modal-body").scrollTop = 0;
      if (["login", "register"].includes(view)) renderGoogleButtons();
      if (focus) modal.querySelector('[data-ma-panel="' + view + '"] input:not([type="hidden"]):not([readonly])')?.focus({preventScroll:true});
    }
    function openAuth(view = "login", trigger = null, options = {}) {
      contextMessage = options.message || "";
      completedSinceOpen = false;
      opener = trigger || document.activeElement;
      const drawer = document.getElementById("mhi-drawer");
      if (drawer && !drawer.hidden) drawer.querySelector("[data-mhi-drawer-close]")?.click();
      requestedView = view;
      showView(view, modal.classList.contains("show"));
      if (modal.classList.contains("show")) requestedView = null;
      else $(modal).modal("show");
    }
    function setStatus(form, message, success = false) {
      const status = form?.querySelector(".ma-status");
      if (!status) return;
      status.textContent = message || "Không thể thực hiện. Vui lòng thử lại.";
      status.toggleAttribute("data-success", success);
      status.hidden = false;
    }
    function activate(email, data = {}, message = "") {
      const changedEmail = verifyForm.elements.email.value !== email;
      verifyForm.elements.email.value = email || "";
      verifyForm.elements.code.value = "";
      verifyForm.querySelector(".ma-status").hidden = true;
      if (changedEmail || data.resend_after !== undefined) countdown(data.resend_after || 0);
      showView("verify", true);
      if (message) setStatus(verifyForm, message, data.email_sent !== false);
    }
    function completeAuth(kind, result) {
      // Registration can return the member profile; login deliberately returns only a redirect.
      if (result.data?.customer_id && window.nhMain?.dataInit) nhMain.dataInit.member = result.data;
      if (window.nhMember?.login) nhMember.login.reloadMiniMember();
      document.querySelectorAll("[nh-mini-member]").forEach((element) => { element.hidden = false; });
      document.querySelectorAll('.mhi-header-cta[data-ma-open]').forEach((button) => { button.hidden = true; });
      document.querySelectorAll('[data-ma-member-link]').forEach((link) => { link.hidden = false; });
      modal.querySelectorAll('input[name="password"], input[name="verify_password"]').forEach((input) => { input.value = ""; });
      completedSinceOpen = true;
      $(modal).modal("hide");
      window.dispatchEvent(new CustomEvent("meduc:authenticated", {detail:{source:kind}}));
    }
    window.meducAuth = {
      open: openAuth,
      handleResponse(kind, form, response) {
        const outsideRegister = !modal.contains(form) && kind === "register";
        const outsideVerify = !modal.contains(form) && kind === "verify";
        if (!modal.contains(form) && !outsideRegister && !outsideVerify) return false;
        if (window.nhMain?.showLoading) nhMain.showLoading.remove();
        if (response?.code !== "success") {
          setStatus(form, response?.message);
          return true;
        }
        const data = response.data || {};
        if (data.profile_required) {
          showGoogleProfile(data);
        } else if (data.wait_active || data.waiting_confirm) {
          if (outsideRegister) openAuth("verify", form.querySelector('[type="submit"]'));
          activate(data.email, data, data.waiting_confirm ? response.message : "");
        } else {
          completeAuth(kind, response);
          if (outsideVerify) setStatus(form, response.message, true);
        }
        return true;
      }
    };

    const profileForm = modal.querySelector("[data-ma-google-profile]");
    let profileInFlight = false;
    let googleSetup = null;
    let googleSdk = null;
    let googleInFlight = false;

    function showGoogleProfile(data) {
      profileForm.reset();
      profileForm.elements.profile_token.value = data.profile_token || "";
      ["email", "full_name", "phone", "school_name", "student_year"].forEach((field) => {
        profileForm.elements[field].value = data.profile?.[field] || "";
      });
      profileForm.querySelector(".ma-status").hidden = true;
      if (!modal.classList.contains("show")) openAuth("profile");
      else showView("profile", true);
    }
    const accountRequest = (url, data = {}) => new Promise((resolve, reject) => {
      nhMain.callAjax({url, data}).done((response) => {
        if (response?.code === "success") resolve(response);
        else reject(new Error(response?.message || "Không thể thực hiện. Vui lòng thử lại."));
      }).fail(() => reject(new Error("Không thể kết nối. Vui lòng thử lại.")));
    });
    function googleStatus(message) {
      document.querySelectorAll("[data-ma-google-status]").forEach((element) => {
        element.textContent = message || "";
        element.hidden = !message;
      });
    }
    function resetGoogleButtons() {
      googleSetup = null;
      document.querySelectorAll("[data-ma-google]").forEach((element) => {
        delete element.dataset.googleRendered;
        element.replaceChildren();
      });
    }
    async function googleCredential(response) {
      if (googleInFlight) return;
      googleInFlight = true;
      googleStatus("");
      try {
        const result = await accountRequest("/member/social-login", {type:"google", credential:response.credential});
        if (result.data?.profile_required) showGoogleProfile(result.data);
        else completeAuth("google", result);
        resetGoogleButtons();
      } catch (error) {
        googleStatus(error.message);
        resetGoogleButtons();
        renderGoogleButtons();
      } finally {
        googleInFlight = false;
      }
    }
    function loadGoogleSdk() {
      if (window.google?.accounts?.id) return Promise.resolve();
      if (!googleSdk) googleSdk = new Promise((resolve, reject) => {
        const script = document.createElement("script");
        script.src = "https://accounts.google.com/gsi/client";
        script.async = true;
        script.onload = resolve;
        script.onerror = () => { googleSdk = null; script.remove(); reject(new Error("Chưa tải được Google. Vui lòng thử lại hoặc đăng nhập bằng email.")); };
        document.head.appendChild(script);
      });
      return googleSdk;
    }
    async function renderGoogleButtons() {
      const buttons = [...document.querySelectorAll("[data-ma-google]")].filter((element) => element.offsetWidth > 0 && !element.dataset.googleRendered);
      if (!buttons.length) return;
      try {
        if (!googleSetup) googleSetup = (async () => {
          const [result] = await Promise.all([accountRequest("/member/google-options"), loadGoogleSdk()]);
          google.accounts.id.initialize({client_id:result.data.client_id, nonce:result.data.nonce,
            callback:googleCredential, auto_select:false, ux_mode:"popup"});
        })();
        await googleSetup;
        googleStatus("");
        buttons.forEach((element) => {
          if (!element.isConnected || !element.offsetWidth || element.dataset.googleRendered) return;
          google.accounts.id.renderButton(element, {type:"standard", theme:"outline", size:"large", text:"continue_with",
            shape:"rectangular", locale:"vi", width:Math.min(400, Math.max(200, Math.floor(element.offsetWidth)))});
          element.dataset.googleRendered = "true";
        });
      } catch (error) {
        googleSetup = null;
        googleStatus(error.message);
      }
    }
    profileForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      if (profileInFlight || !profileForm.reportValidity()) return;
      profileInFlight = true;
      const submit = profileForm.querySelector('[type="submit"]');
      submit.disabled = true;
      profileForm.querySelector(".ma-status").hidden = true;
      try {
        completeAuth("google", await accountRequest(profileForm.action, $(profileForm).serialize()));
      } catch (error) {
        setStatus(profileForm, error.message);
      } finally {
        profileInFlight = false;
        submit.disabled = false;
      }
    });
    $(renderGoogleButtons);

    // Public links to either account page use the same dialog. Direct page URLs still work.
    document.addEventListener("click", (event) => {
      const viewButton = event.target.closest("[data-ma-view]");
      if (viewButton && modal.contains(viewButton)) {
        event.preventDefault();
        showView(viewButton.dataset.maView, viewButton.getAttribute("role") !== "tab");
        return;
      }
      let trigger = event.target.closest("[data-ma-open]");
      let view = trigger?.dataset.maOpen;
      if (!trigger) {
        const link = event.target.closest("a[href]");
        if (!link || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey || event.button !== 0) return;
        const url = new URL(link.href, location.origin);
        if (url.origin !== location.origin || !/^\/member\/(login|register|forgot-password)\/?$/.test(url.pathname)) return;
        trigger = link;
        view = /forgot-password/.test(url.pathname) ? "forgot" : /register/.test(url.pathname) ? "register" : "login";
      }
      if (!trigger) return;
      event.preventDefault();
      openAuth(view, trigger);
    });

    modal.querySelector('[role="tablist"]').addEventListener("keydown", (event) => {
      if (!["ArrowLeft","ArrowRight","Home","End"].includes(event.key)) return;
      event.preventDefault();
      const current = tabs.indexOf(document.activeElement);
      const next = event.key === "Home" ? 0 : event.key === "End" ? tabs.length - 1 :
        (current + (event.key === "ArrowLeft" ? -1 : 1) + tabs.length) % tabs.length;
      showView(tabs[next].dataset.maView);
      tabs[next].focus();
    });
    // Handles native submit as well as the legacy click/Enter bindings.
    modal.addEventListener("submit", (event) => {
      if (!event.target.matches('[nh-form="member-login"], [nh-form="member-register"]')) return;
      event.preventDefault();
      event.target.querySelector('[nh-btn-action="submit"]')?.click();
    });

    $(modal).on("show.bs.modal", () => {
      document.body.classList.add("ma-auth-open");
      showView(requestedView || "login");
      requestedView = null;
    }).on("shown.bs.modal", () => {
      renderGoogleButtons();
      const redirect = loginForm.querySelector('input[name="redirect"]');
      if (redirect) redirect.value = location.pathname + location.search + location.hash;
      modal.querySelector("[data-ma-panel]:not([hidden]) input:not([type=hidden]):not([readonly])")?.focus({preventScroll:true});
    }).on("hidden.bs.modal", () => {
      document.body.classList.remove("ma-auth-open");
      window.dispatchEvent(new CustomEvent("meduc:auth-closed", {detail:{authenticated:completedSinceOpen}}));
      contextMessage = "";
      if (opener?.isConnected) opener.focus({preventScroll:true});
      else document.querySelector("#member-info")?.focus({preventScroll:true});
    });

    verifyForm.addEventListener("submit", (event) => {
      event.preventDefault();
      if (verifyInFlight || !verifyForm.reportValidity()) return;
      verifyInFlight = true;
      const submit = verifyForm.querySelector('[type="submit"]');
      submit.disabled = true;
      nhMain.reCaptcha.check((token) => {
        let data = $(verifyForm).serialize();
        if (token != null) data += "&" + _TOKEN_RECAPTCHA + "=" + encodeURIComponent(token);
        nhMain.callAjax({url:verifyForm.action, data}).done((response) => {
          if (response.code === "success") completeAuth("verify", response);
        }).always(() => {
          verifyInFlight = false;
          submit.disabled = false;
        });
      });
    });
    resendButton.addEventListener("click", () => {
      if (resendButton.disabled || !verifyForm.elements.email.reportValidity()) return;
      resendButton.disabled = true;
      resendButton.textContent = "Đang gửi…";
      nhMain.reCaptcha.check((token) => {
        const data = {email:verifyForm.elements.email.value, generate_token:"active_account"};
        if (token != null) data[_TOKEN_RECAPTCHA] = token;
        nhMain.callAjax({url:"/member/resend-verify-code", data}).done((response) => {
          setStatus(verifyForm, response.message, response.code === "success");
          countdown(response.data?.resend_after || (response.code === "success" ? 60 : 0));
        }).fail(() => { countdown(0); });
      });
    });


    const resetForm = modal.querySelector("[data-ma-reset]");
    const recoveryInFlight = new WeakSet();
    const recoveryForms = [...document.querySelectorAll("[data-ma-recovery], [data-ma-reset]")];
    function recoveryRequest(form, resend = false) {
      if (recoveryInFlight.has(form)) return;
      const resetting = form.hasAttribute("data-ma-reset") && !resend;
      if (resetting) {
        form.elements.re_password.setCustomValidity(
          form.elements.new_password.value === form.elements.re_password.value ? "" : "Nhập lại mật khẩu mới chưa khớp."
        );
      }
      if (resend ? !form.elements.email.reportValidity() : !form.reportValidity()) return;
      recoveryInFlight.add(form);
      const submit = form.querySelector(resend ? "[data-ma-reset-resend]" : '[type="submit"]');
      submit.disabled = true;
      const finish = () => { recoveryInFlight.delete(form); if (!resend) submit.disabled = false; };
      nhMain.reCaptcha.check((token) => {
        let data = resetting ? $(form).serialize() : $.param({email:form.elements.email.value});
        if (token != null) data += "&" + _TOKEN_RECAPTCHA + "=" + encodeURIComponent(token);
        nhMain.callAjax({url:resetting ? form.action : "/member/ajax-forgot-password", data}).done((response) => {
          if (response.code !== "success") {
            setStatus(form, response.message);
            if (resend) countdown(response.data?.resend_after || 0, submit);
            return;
          }
          if (resetting) {
            const email = form.elements.email.value;
            form.reset();
            form.elements.code.value = "";
            loginForm.elements.username.value = email;
            loginForm.elements.password.value = "";
            if (modal.contains(form)) showView("login");
            else openAuth("login", submit);
            setStatus(loginForm, response.message, true);
            loginForm.elements.password.focus({preventScroll:true});
          } else if (resend) {
            setStatus(form, response.message, true);
            countdown(response.data?.resend_after || 60, submit);
          } else {
            resetForm.reset();
            resetForm.elements.email.value = response.data?.email || form.elements.email.value;
            countdown(response.data?.resend_after || 60, resetForm.querySelector("[data-ma-reset-resend]"));
            if (modal.contains(form)) showView("reset", true);
            else openAuth("reset", submit);
            setStatus(resetForm, response.message, true);
          }
        }).fail(() => {
          setStatus(form, "Không thể kết nối. Vui lòng thử lại.");
          if (resend) countdown(0, submit);
        }).always(finish);
      });
    }
    recoveryForms.forEach((form) => {
      form.addEventListener("submit", (event) => { event.preventDefault(); recoveryRequest(form); });
      form.querySelector("[data-ma-reset-resend]")?.addEventListener("click", (event) => {
        if (!event.currentTarget.disabled) recoveryRequest(form, true);
      });
      form.querySelector('[name="re_password"]')?.addEventListener("input", (event) => event.target.setCustomValidity(""));
      form.querySelector('[name="new_password"]')?.addEventListener("input", () => form.elements.re_password.setCustomValidity(""));
    });

    const requests = new WeakMap();
    const formFor = (settings) => {
      const pathname = new URL(settings.url, location.origin).pathname;
      if (!/^\/member\/(ajax-(login|register|forgot-password|verify-forgot-password|verify-email)|resend-verify-code)$/.test(pathname)) return null;
      const forms = [...document.querySelectorAll("form.ma-form")];
      return forms.find((form) => form.action.endsWith(pathname) && $(form).is(":visible")) ||
        (pathname === "/member/resend-verify-code" ? forms.find((form) => $(form).is(":visible") && form.querySelector("[nh-btn-action=resend-verify], [data-ma-resend]")) : null);
    };
    $(document).on("ajaxSend.meducAuth", (_, xhr, settings) => {
      const form = formFor(settings);
      if (!form) return;
      requests.set(xhr, form);
      form.setAttribute("aria-busy", "true");
      form.querySelectorAll('[nh-btn-action="submit"], [nh-btn-action="resend-verify"]').forEach((button) => { button.disabled = true; });
      const status = form.querySelector(".ma-status");
      if (status) status.hidden = true;
    });
    $(document).on("ajaxComplete.meducAuth", (_, xhr) => {
      const form = requests.get(xhr);
      if (!form) return;
      requests.delete(xhr);
      form.removeAttribute("aria-busy");
      form.querySelectorAll('[nh-btn-action="submit"], [nh-btn-action="resend-verify"]').forEach((button) => { button.disabled = false; });
      const result = xhr.responseJSON;
      if (!result || result.code !== "success") setStatus(form, result?.message || "Không thể kết nối. Vui lòng thử lại.");
      else if (result.message) setStatus(form, result.message, true);
    });
  });
})();
