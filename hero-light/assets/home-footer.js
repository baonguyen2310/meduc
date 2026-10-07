(() => {
  "use strict";

  const buildFooter = () => {
  const footer = document.querySelector("body.meduc-home-v2 > footer.edu-footer");
  const top = footer?.querySelector(".footer-top");
  const copyrightRow = footer?.querySelector('[nh-row="1q8e3l9"]');
  if (!footer || !top || !copyrightRow) return false;

  const originalColumns = [...top.querySelectorAll(":scope > .container > .row > div")];
  if (originalColumns.length < 4) return false;

  const brand = originalColumns[0].querySelector("address h5")?.textContent.trim();
  const address = originalColumns[0].querySelector("address p")?.textContent.trim();
  const contactText = [...originalColumns[1].querySelectorAll(".inner > p")].map((item) => item.textContent.trim());
  const contactLinks = [...originalColumns[1].querySelectorAll(".footer-link a")];
  const aboutLinks = [...originalColumns[2].querySelectorAll(".footer-link a")];
  const socialLinks = [...originalColumns[3].querySelectorAll(".social-list a")];
  const exploreLinks = [...document.querySelectorAll("#mhi-system-links a")];
  const copyright = copyrightRow.querySelector(".inner-copyright")?.textContent.trim();
  const dmcaLink = copyrightRow.querySelector(".inner-images a");
  if (!brand || !address || !contactText.length || !aboutLinks.length || !copyright) return false;

  const makeLink = (source, label = source.textContent.trim()) => {
    const link = document.createElement("a");
    link.href = source.href;
    link.textContent = label.replace(/↗/g, "").trim();
    if (source.target === "_blank") {
      link.target = "_blank";
      link.rel = "noopener noreferrer";
    }
    return link;
  };

  const makeColumn = (title, className) => {
    const column = document.createElement("div");
    column.className = `mhi-footer-column ${className}`;
    const heading = document.createElement("h2");
    heading.textContent = title;
    const list = document.createElement("nav");
    list.setAttribute("aria-label", title);
    column.append(heading, list);
    return { column, list };
  };

  const main = document.createElement("div");
  main.className = "mhi-footer-main";
  const grid = document.createElement("div");
  grid.className = "mhi-footer-grid";

  const explore = makeColumn("Khám phá", "mhi-footer-explore");
  exploreLinks.forEach((source) => explore.list.append(makeLink(source)));
  if (!exploreLinks.length) {
    [["Khóa học", "/khoa-hoc"], ["Sách y khoa", "/sach"], ["Đề thi", "/danh-sach-de-thi"], ["Blog", "/blog"]].forEach(([label, href]) => {
      const link = document.createElement("a");
      link.href = href;
      link.textContent = label;
      explore.list.append(link);
    });
  }

  const about = makeColumn("Về chúng tôi", "mhi-footer-about");
  aboutLinks.forEach((source) => about.list.append(makeLink(source)));

  const social = makeColumn("Kết nối", "mhi-footer-social");
  socialLinks.filter((source) => !["Email", "Phone"].includes(source.title)).forEach((source) => {
    const link = makeLink(source, source.title || "MedUC");
    const icon = source.querySelector("i")?.cloneNode(true);
    if (icon) {
      icon.setAttribute("aria-hidden", "true");
      link.prepend(icon);
    }
    social.list.append(link);
  });

  const contact = makeColumn("Liên hệ", "mhi-footer-contact");
  const phone = contactText.find((line) => line.startsWith("Hotline:"))?.replace(/^Hotline:\s*/, "");
  const email = contactText.find((line) => line.startsWith("Email:"))?.replace(/^Email:\s*/, "");
  const website = originalColumns[1].querySelector('.inner > p a[href^="http"]');
  if (phone) {
    const link = document.createElement("a");
    link.href = `tel:${phone.replace(/\s/g, "")}`;
    link.textContent = `Hotline: ${phone}`;
    contact.list.append(link);
  }
  if (email) {
    const link = document.createElement("a");
    link.href = `mailto:${email}`;
    link.textContent = `Email: ${email}`;
    contact.list.append(link);
  }
  if (website) contact.list.append(makeLink(website, `Website: ${website.textContent.trim()}`));
  contactLinks.forEach((source) => contact.list.append(makeLink(source)));

  grid.append(explore.column, about.column, social.column, contact.column);
  main.append(grid);

  const bottom = document.createElement("div");
  bottom.className = "mhi-footer-bottom";
  const brandBlock = document.createElement("div");
  brandBlock.className = "mhi-footer-brand";
  const logo = document.createElement("a");
  logo.href = "/";
  logo.setAttribute("aria-label", "MedUC — Trang chủ");
  const logoImage = document.createElement("img");
  logoImage.src = "https://cdn.meduc.vn/media/core/logo/logo-meduc.png";
  logoImage.alt = "MedUC";
  logo.append(logoImage);
  const brandText = document.createElement("div");
  const brandName = document.createElement("strong");
  brandName.textContent = brand;
  const addressText = document.createElement("p");
  addressText.textContent = address;
  brandText.append(brandName, addressText);
  brandBlock.append(logo, brandText);
  const legal = document.createElement("div");
  legal.className = "mhi-footer-legal";
  const copyrightText = document.createElement("span");
  copyrightText.textContent = copyright;
  legal.append(copyrightText);
  if (dmcaLink) {
    const badge = dmcaLink.cloneNode(true);
    badge.className = "mhi-footer-dmca";
    badge.setAttribute("aria-label", "Chứng nhận bảo vệ nội dung DMCA");
    badge.rel = "noopener noreferrer";
    const badgeImage = badge.querySelector("img");
    if (badgeImage?.dataset.src) badgeImage.src = badgeImage.dataset.src;
    badgeImage?.removeAttribute("nh-lazy");
    badgeImage?.removeAttribute("delay");
    legal.append(badge);
  }
  bottom.append(brandBlock, legal);

  footer.classList.add("mhi-footer");
  top.replaceWith(main);
  copyrightRow.replaceWith(bottom);
  return true;
  };

  if (!buildFooter()) {
    const observer = new MutationObserver(() => {
      if (buildFooter()) observer.disconnect();
    });
    observer.observe(document.body, { childList: true, subtree: true });
  }
})();
