(() => {
  "use strict";

  const blog = document.querySelector("body.meduc-home-v2 > .mhi-home-blog");
  const source = [...document.querySelectorAll("body.meduc-home-v2 > [nh-row]")].find((row) =>
    row.querySelector('form[nh-form-contact="3HZO5VFWIK"]')
  );
  if (!blog || !source) return;

  // Move the original PHP form so its validation and contact endpoint stay intact.
  const form = source.querySelector('form[nh-form-contact="3HZO5VFWIK"]');
  const heading = source.querySelector(".subscription .header .title")?.textContent.replace(/\s+/g, " ").trim() || "Đăng ký nhận tư vấn miễn phí";
  const description = source.querySelector(".subscription .sub_title")?.textContent.replace(/[()]/g, "").replace(/\s+/g, " ").trim() || "Học Y cùng MedUC theo lộ trình phù hợp với bạn.";

  const section = document.createElement("section");
  section.className = "mhi-consult";
  section.setAttribute("aria-labelledby", "mhi-consult-heading");
  section.innerHTML = `
    <div class="mhi-consult-shell">
      <div class="mhi-consult-copy">
        <p class="mhi-consult-kicker">MEDUC / TƯ VẤN HỌC TẬP</p>
        <h2 id="mhi-consult-heading"></h2>
        <p class="mhi-consult-description"></p>
      </div>
      <div class="mhi-consult-form-wrap">
        <p class="mhi-consult-form-intro">Để lại thông tin, MedUC sẽ liên hệ tư vấn lộ trình học phù hợp với bạn.</p>
      </div>
    </div>`;
  section.querySelector("h2").textContent = heading;
  section.querySelector(".mhi-consult-description").textContent = description;

  const labels = {
    full_name: ["Họ và tên", "Nhập họ và tên của bạn"],
    phone: ["Số điện thoại", "Số điện thoại của bạn"],
    title: ["Chủ đề cần tư vấn", "Ví dụ: khóa học hoặc lộ trình ôn tập"],
    content: ["Bạn muốn được tư vấn điều gì?", "Chia sẻ điều bạn đang cần hỗ trợ"],
  };
  Object.entries(labels).forEach(([name, [text, placeholder]]) => {
    const control = form.querySelector(`[name="${name}"]`);
    if (!control) return;
    const id = `mhi-consult-${name}`;
    control.id = id;
    control.placeholder = placeholder;
    if (name === "phone") control.autocomplete = "tel";
    if (name === "full_name") control.autocomplete = "name";
    const label = document.createElement("label");
    label.htmlFor = id;
    label.textContent = text;
    if (control.required) {
      const required = document.createElement("span");
      required.textContent = " *";
      required.setAttribute("aria-hidden", "true");
      label.append(required);
    }
    control.before(label);
  });

  form.removeAttribute("data-sal");
  form.classList.add("mhi-consult-form");
  const oldSubmit = form.querySelector('[nh-btn-action="submit"]');
  if (oldSubmit) {
    const submit = document.createElement("button");
    submit.type = "button";
    submit.className = "mhi-consult-submit";
    submit.setAttribute("nh-btn-action", "submit");
    submit.innerHTML = 'Nhận tư vấn miễn phí <span aria-hidden="true">→</span>';
    oldSubmit.replaceWith(submit);
  }
  section.querySelector(".mhi-consult-form-wrap").append(form);
  blog.after(section);
  source.remove();
})();
