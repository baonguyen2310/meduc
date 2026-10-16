/* Keep member.js responsible for reCAPTCHA, CSRF, submission and session handling. */
(() => {
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
    // Reuse the existing Google SDK button instead of its floating legacy popup.
    const googleButton = document.querySelector(".pp-login-google");
    const pageSlot = document.querySelector("#meduc-auth [data-ma-google-slot]");
    const modalSlot = document.querySelector("#login-modal [data-ma-google-slot]");
    if (googleButton && (pageSlot || modalSlot)) (pageSlot || modalSlot).append(googleButton);
    $("#login-modal").on("shown.bs.modal", () => {
      if (googleButton && modalSlot) modalSlot.append(googleButton);
      if (!location.pathname.startsWith("/member/")) {
        const redirect = document.querySelector('#login-modal input[name="redirect"]');
        if (redirect) redirect.value = location.pathname + location.search;
      }
    }).on("hidden.bs.modal", () => {
      if (googleButton && pageSlot) pageSlot.append(googleButton);
    });
    const requests = new WeakMap();
    const formFor = (settings) => {
      const pathname = new URL(settings.url, location.origin).pathname;
      if (!/^\/member\/(ajax-(login|register|forgot-password|verify-forgot-password|verify-email)|resend-verify-code)$/.test(pathname)) return null;
      const forms = [...document.querySelectorAll("form.ma-form")];
      return forms.find((form) => form.action.endsWith(pathname) && $(form).is(":visible")) ||
        (pathname === "/member/resend-verify-code" ? forms.find((form) => form.querySelector('[nh-btn-action="resend-verify"]')) : null);
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
      const status = form.querySelector(".ma-status");
      if (!status) return;
      if (!result || result.code !== "success") {
        status.textContent = result && result.message ? result.message : "Không thể kết nối. Vui lòng thử lại.";
        status.removeAttribute("data-success");
        status.hidden = false;
      } else if (result.message) {
        status.textContent = result.message;
        status.setAttribute("data-success", "");
        status.hidden = false;
      }
    });
  });
})();
