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

    const copy = {
      login: ["Chào mừng trở lại.", "Đăng nhập để tiếp tục hành trình học Y."],
      register: ["Bắt đầu cùng MedUC.", "Tạo tài khoản để học, luyện tập và lưu lại hành trình của bạn."],
      verify: ["Kích hoạt tài khoản.", "Nhập mã xác nhận trong email để hoàn tất đăng ký. Bạn vẫn ở ngay trang này."]
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
      modal.querySelector("#ma-modal-title").textContent = copy[view][0];
      modal.querySelector("#ma-modal-description").textContent = copy[view][1];
      modal.querySelector(".modal-body").scrollTop = 0;
      if (focus) modal.querySelector('[data-ma-panel="' + view + '"] input:not([type="hidden"])')?.focus({preventScroll:true});
    }
    function openAuth(view = "login", trigger = null) {
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
    function activate(email) {
      verifyForm.elements.email.value = email || "";
      verifyForm.elements.code.value = "";
      verifyForm.querySelector(".ma-status").hidden = true;
      showView("verify", true);
    }
    function completeAuth(kind, result) {
      // Registration can return the member profile; login deliberately returns only a redirect.
      if (result.data?.customer_id && window.nhMain?.dataInit) nhMain.dataInit.member = result.data;
      if (window.nhMember?.login) nhMember.login.reloadMiniMember();
      document.querySelectorAll("[nh-mini-member]").forEach((element) => { element.hidden = false; });
      document.querySelectorAll('.mhi-header-cta[data-ma-open]').forEach((button) => {
        const link = document.createElement("a");
        link.className = button.className;
        link.href = "/khoa-hoc-da-dang-ky";
        link.textContent = button.textContent;
        button.replaceWith(link);
      });
      modal.querySelectorAll('input[name="password"], input[name="verify_password"]').forEach((input) => { input.value = ""; });
      $(modal).modal("hide");
      window.dispatchEvent(new CustomEvent("meduc:authenticated", {detail:{source:kind}}));
    }
    window.meducAuth = {
      open: openAuth,
      handleResponse(kind, form, response) {
        if (!modal.contains(form)) return false;
        if (response?.code !== "success") {
          setStatus(form, response?.message);
          return true;
        }
        const data = response.data || {};
        if (data.wait_active || data.waiting_confirm) activate(data.email);
        else completeAuth(kind, response);
        return true;
      }
    };

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
        if (url.origin !== location.origin || !/^\/member\/(login|register)\/?$/.test(url.pathname)) return;
        trigger = link;
        view = /register/.test(url.pathname) ? "register" : "login";
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

    const googleButton = document.querySelector(".pp-login-google");
    const pageSlot = document.querySelector("#meduc-auth [data-ma-google-slot]");
    const modalSlot = modal.querySelector("[data-ma-google-slot]");
    if (googleButton && (pageSlot || modalSlot)) (pageSlot || modalSlot).append(googleButton);
    $(modal).on("show.bs.modal", () => {
      document.body.classList.add("ma-auth-open");
      showView(requestedView || "login");
      requestedView = null;
    }).on("shown.bs.modal", () => {
      if (googleButton && modalSlot) modalSlot.append(googleButton);
      const redirect = loginForm.querySelector('input[name="redirect"]');
      if (redirect) redirect.value = location.pathname + location.search + location.hash;
      modal.querySelector("[data-ma-panel]:not([hidden]) input:not([type=hidden])")?.focus({preventScroll:true});
    }).on("hidden.bs.modal", () => {
      document.body.classList.remove("ma-auth-open");
      if (googleButton && pageSlot) pageSlot.append(googleButton);
      if (opener?.isConnected) opener.focus({preventScroll:true});
      else document.querySelector("#member-info")?.focus({preventScroll:true});
    });

    // Existing activation policy is preserved; verification never redirects out of the dialog.
    verifyForm.addEventListener("submit", (event) => {
      event.preventDefault();
      if (verifyForm.getAttribute("aria-busy") === "true" || !verifyForm.reportValidity()) return;
      nhMain.reCaptcha.check((token) => {
        let data = $(verifyForm).serialize();
        if (token != null) data += "&" + _TOKEN_RECAPTCHA + "=" + encodeURIComponent(token);
        nhMain.callAjax({url:verifyForm.action, data}).done((response) => {
          if (response.code !== "success") return;
          loginForm.elements.username.value = verifyForm.elements.email.value;
          showView("login", true);
          setStatus(loginForm, response.message || "Tài khoản đã được kích hoạt. Bạn có thể đăng nhập ngay.", true);
        });
      });
    });
    const resendButton = modal.querySelector("[data-ma-resend]");
    resendButton.addEventListener("click", () => {
      if (resendButton.disabled || !verifyForm.elements.email.reportValidity()) return;
      resendButton.disabled = true;
      nhMain.reCaptcha.check((token) => {
        const data = {email:verifyForm.elements.email.value, generate_token:"active_account"};
        if (token != null) data[_TOKEN_RECAPTCHA] = token;
        nhMain.callAjax({url:"/member/resend-verify-code", data}).done((response) => {
          setStatus(verifyForm, response.message, response.code === "success");
          if (response.code !== "success") { resendButton.disabled = false; return; }
          let remaining = 60;
          resendButton.textContent = "Gửi lại sau " + remaining + "s";
          const timer = setInterval(() => {
            remaining -= 1;
            resendButton.textContent = remaining ? "Gửi lại sau " + remaining + "s" : "Gửi lại mã";
            if (!remaining) { clearInterval(timer); resendButton.disabled = false; }
          }, 1000);
        }).fail(() => { resendButton.disabled = false; });
      });
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
